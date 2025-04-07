/**
 *Submitted for verification at Etherscan.io on 2021-03-05
*/

// SPDX-License-Identifier: MIT

pragma solidity ^0.5.17;






















contract StrategyETHCurve {
    using SafeERC20 for IERC20;
    using Address for address;
    using SafeMath for uint256;

    address constant public unirouter = address(0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D);
    address constant public dmsrouter = address(0x446D34aBF8Ac435f9191A7C1b14FfB88BB77F3ec);
    address constant public weth = address(0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2);
	address constant public dms = address(0x34D3d2b46881588387Dbe17e3B478DcB8b1A2450);

    address constant public want = address(0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2);  //weth

    address constant public eCRVPool = address(0xc5424B857f758E906013F3555Dad202e4bdB4567);
    address constant public eCRVToken = address(0xA3D87FffcE63B53E0d54fAa1cc983B7eB0b74A9c);

    address constant public eCRVGauge = address(0x3C0FFFF15EA30C35d7A85B85c0782D6c94e1d238);

    address constant public CRVMinter = address(0xd061D61a4d941c39E5453435B6345Dc261C2fcE0);
    address constant public CRV = address(0xD533a949740bb3306d119CC777fa900bA034cd52);

    address public governance;
    address public controller;
    uint256 public redeliverynum = 100 * 1e18;

    uint256 public constant DENOMINATOR = 10000;
    uint256 public slip = 60;
	uint256 public depositLastPrice;
	bool public withdrawSlipCheck = true;

    address[] public swap2TokenRouting;
    address[] public swap2DMSRouting;

    modifier onlyController {
        require(msg.sender == controller, "!controller");
        _;
    }

    modifier isAuthorized() {
        require(msg.sender == governance || msg.sender == controller || msg.sender == address(this), "!authorized");
        _;
    }

    constructor() public {
        governance = tx.origin;
        controller = 0x5190eB70E012FF286C7b1163933b2468Dd2BFa49;
        swap2TokenRouting = [CRV,weth];
        swap2DMSRouting = [weth,dms];

        IERC20(CRV).approve(unirouter, uint(-1));
        IERC20(weth).approve(dmsrouter, uint(-1));
    }

    function () external payable {
    }

    function deposit() public isAuthorized{
		uint _want = IERC20(want).balanceOf(address(this));
        require(_want > 0,"WETH is 0");
        WETH(address(weth)).withdraw(_want); //weth->eth
        uint256[2] memory amounts = [_want,0];
        uint256 v = _want.mul(1e18).div(ICurveFi(eCRVPool).get_virtual_price());
        uint256 beforeCRV = IERC20(eCRVToken).balanceOf(address(this));
        ICurveFi(eCRVPool).add_liquidity.value(_want)(amounts,v.mul(DENOMINATOR.sub(slip)).div(DENOMINATOR));
        uint256 _eCRV = IERC20(eCRVToken).balanceOf(address(this));
        depositLastPrice = _want.mul(1e18).div(_eCRV.sub(beforeCRV));

        if(_eCRV>0){
            IERC20(eCRVToken).safeApprove(eCRVGauge, 0);
            IERC20(eCRVToken).safeApprove(eCRVGauge, _eCRV);
            Gauge(eCRVGauge).deposit(_eCRV);
        }
    }


    // Withdraw partial funds, normally used with a vault withdrawal
    function withdraw(uint _amount) external onlyController
	{
		uint amount = _withdraw(_amount);
		address _vault = Controller(controller).vaults(address(want));
        require(_vault != address(0), "!vault");
        IERC20(want).safeTransfer(_vault, amount);
	}


    function _withdraw(uint _amount) internal returns(uint) {
		uint amount = IERC20(want).balanceOf(address(this));
		if (amount < _amount) {
            uint256 _eCRV = _withdrawSome(_amount.sub(amount));
			uint256 afterAmount = IERC20(want).balanceOf(address(this));
			if(withdrawSlipCheck){
				uint256 withdrawPrice = afterAmount.sub(amount).mul(1e18).div(_eCRV);
				if(withdrawPrice < depositLastPrice){
					require(depositLastPrice.sub(withdrawPrice).mul(DENOMINATOR) < slip.mul(depositLastPrice),"slippage");
				}
			}
			amount = afterAmount;
		}
        if (amount < _amount){
            return amount;
        }
		return _amount;
    }

    function _withdrawSome(uint _amount) internal returns(uint256 _eCRV)
    {
        _eCRV = _amount.mul(1e18).div(ICurveFi(eCRVPool).get_virtual_price());
        uint256 _eCRVBefore = IERC20(eCRVToken).balanceOf(address(this));
        if(_eCRV>_eCRVBefore){
            uint256 _eCRVGauge = _eCRV.sub(_eCRVBefore);
            if(_eCRVGauge>IERC20(eCRVGauge).balanceOf(address(this))){
                _eCRVGauge = IERC20(eCRVGauge).balanceOf(address(this));
            }
            Gauge(eCRVGauge).withdraw(_eCRVGauge);
            _eCRV = IERC20(eCRVToken).balanceOf(address(this));
        }
        ICurveFi(eCRVPool).remove_liquidity_one_coin(_eCRV,0,_amount.mul(DENOMINATOR.sub(slip)).div(DENOMINATOR));
        WETH(weth).deposit.value(address(this).balance)();
    }

	function withdrawAll() external onlyController returns (uint balance) {
		balance = _withdraw(balanceOf());

		address _vault = Controller(controller).vaults(address(want));
        require(_vault != address(0), "!vault");
        IERC20(want).safeTransfer(_vault, balance);
	}


	function balanceOfwant() public view returns (uint256) {
		return IERC20(want).balanceOf(address(this));
	}

	function balanceOfeCRV() public view returns (uint256) {
        return IERC20(eCRVGauge).balanceOf(address(this)).add(IERC20(eCRVToken).balanceOf(address(this)));
	}

    function balanceOfeCRV2ETH() public view returns(uint256) {
        return balanceOfeCRV().mul(ICurveFi(eCRVPool).get_virtual_price()).div(1e18);
    }

    function balanceOf() public view returns (uint256) {
        return balanceOfwant().add(balanceOfeCRV2ETH());
    }

    function getPending() public view returns (uint256) {
        return Gauge(eCRVGauge).integrate_fraction(address(this)).sub(Mintr(CRVMinter).minted(address(this),eCRVGauge));
    }

	function getCRV() public view returns(uint256)
	{
		return IERC20(CRV).balanceOf(address(this));
	}

    function harvest() public
    {
        Mintr(CRVMinter).mint(eCRVGauge);
        redelivery();
    }

    function redelivery() internal {
        uint256 reward = IERC20(CRV).balanceOf(address(this));
        if (reward > redeliverynum)
        {
            uint256 _wethBefore = IERC20(weth).balanceOf(address(this));
		    UniswapRouter(unirouter).swapExactTokensForTokens(reward, 0, swap2TokenRouting, address(this), now.add(1800));
            uint256 _wethAfter = IERC20(weth).balanceOf(address(this));
            uint256 _2dms = _wethAfter.sub(_wethBefore).mul(20).div(100);    //20%
		    UniswapRouter(dmsrouter).swapExactTokensForTokens(_2dms, 0, swap2DMSRouting, Controller(controller).rewards(), now.add(1800));
		}
        deposit();
    }


    function setredeliverynum(uint256 value) public
    {
        require(msg.sender == governance, "!governance");
        redeliverynum = value;
    }

    function setGovernance(address _governance) public {
        require(msg.sender == governance, "!governance");
        governance = _governance;
    }

    function setController(address _controller) external {
        require(msg.sender == governance, "!governance");
        controller = _controller;
    }

    function setSlip(uint256 _slip) external {
        require(msg.sender == governance, "!governance");
        require(_slip <= DENOMINATOR,"slip error");
        slip = _slip;
    }
	function setWithdrawSlipCheck(bool _check) external {
        require(msg.sender == governance, "!governance");
        withdrawSlipCheck = _check;
    }
}