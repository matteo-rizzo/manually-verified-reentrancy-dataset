/**
 *Submitted for verification at Etherscan.io on 2021-03-02
*/

// SPDX-License-Identifier: MIT

pragma solidity ^0.5.17;




















contract StrategyUSDTCurve {
    using SafeERC20 for IERC20;
    using Address for address;
    using SafeMath for uint256;

    address constant public unirouter = address(0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D);
    address constant public weth = address(0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2);
	address constant public bt = address(0x76c5449F4950f6338A393F53CdA8b53B0cd3Ca3a);

    address constant public want = address(0xdAC17F958D2ee523a2206206994597C13D831ec7);  //USDT

    address constant public a3CRVPool = address(0xDeBF20617708857ebe4F679508E7b7863a8A8EeE);
    address constant public a3CRVToken = address(0xFd2a8fA60Abd58Efe3EeE34dd494cD491dC14900);

    address constant public a3CRVGauge = address(0xd662908ADA2Ea1916B3318327A97eB18aD588b5d);

    address constant public CRVMinter = address(0xd061D61a4d941c39E5453435B6345Dc261C2fcE0);
    address constant public CRV = address(0xD533a949740bb3306d119CC777fa900bA034cd52);

    address public governance;
    address public controller;
    uint256 public redeliverynum = 100 * 1e18;

    uint256 public constant DENOMINATOR = 10000;
    uint256 public slip = 20;
	uint256 public depositLastPrice;
	bool public withdrawSlipCheck = true;

    address[] public swap2TokenRouting;
    address[] public swap2BTRouting;

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
        controller = 0x5C6d3Cb5612b551452B3E9b48c920559634510D4;
		swap2BTRouting = [CRV,weth,bt];
        swap2TokenRouting = [CRV,weth,want];

        IERC20(CRV).approve(unirouter, uint(-1));
    }


    function deposit() public isAuthorized{
		uint _wantAmount = IERC20(want).balanceOf(address(this));
        if (_wantAmount > 0) {
            IERC20(want).safeApprove(a3CRVPool, 0);
            IERC20(want).safeApprove(a3CRVPool, _wantAmount);
            uint256 v = _wantAmount.mul(1e30).div(ICurveFi(a3CRVPool).get_virtual_price());
			uint256 before3CRV = IERC20(a3CRVToken).balanceOf(address(this));
            ICurveFi(a3CRVPool).add_liquidity([0, 0, _wantAmount], v.mul(DENOMINATOR.sub(slip)).div(DENOMINATOR),true);
            uint256 after3CRV = IERC20(a3CRVToken).balanceOf(address(this));
			depositLastPrice = _wantAmount.mul(1e30).div(after3CRV.sub(before3CRV));
        }

        uint256 _a3CRV = IERC20(a3CRVToken).balanceOf(address(this));
        if(_a3CRV >0){
            IERC20(a3CRVToken).safeApprove(a3CRVGauge, 0);
            IERC20(a3CRVToken).safeApprove(a3CRVGauge, _a3CRV);
            Gauge(a3CRVGauge).deposit(_a3CRV);
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
			uint256 _a3CRV = _withdrawSome(_amount.sub(amount));
			uint256 afterAmount = IERC20(want).balanceOf(address(this));
			if(withdrawSlipCheck){
				uint256 withdrawPrice = afterAmount.sub(amount).mul(1e30).div(_a3CRV);
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

    function _withdrawSome(uint _amount) internal returns(uint256 _a3CRV)
    {
        _a3CRV = _amount.mul(1e30).div(ICurveFi(a3CRVPool).get_virtual_price());//mul(1e18).mul(1e12)
        uint256 _a3CRVBefore = IERC20(a3CRVToken).balanceOf(address(this));
        if(_a3CRV > _a3CRVBefore){
            uint256 _eCRVGauge = _a3CRV.sub(_a3CRVBefore);
            if(_eCRVGauge>IERC20(a3CRVGauge).balanceOf(address(this))){
                _eCRVGauge = IERC20(a3CRVGauge).balanceOf(address(this));
            }
            Gauge(a3CRVGauge).withdraw(_eCRVGauge);
            _a3CRV = IERC20(a3CRVToken).balanceOf(address(this));
        }
        ICurveFi(a3CRVPool).remove_liquidity_one_coin(_a3CRV,2,_amount.mul(DENOMINATOR.sub(slip)).div(DENOMINATOR),true);
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
        return IERC20(a3CRVGauge).balanceOf(address(this)).add(IERC20(a3CRVToken).balanceOf(address(this)));
	}

    function balanceOfeCRV2Want() public view returns(uint256) {
        return balanceOfeCRV().mul(ICurveFi(a3CRVPool).get_virtual_price()).div(1e30);//div(1e18).div(1e12)
    }

    function balanceOf() public view returns (uint256) {
        return balanceOfwant().add(balanceOfeCRV2Want());
    }

    function getPending() public view returns (uint256) {
        return Gauge(a3CRVGauge).integrate_fraction(address(this)).sub(Mintr(CRVMinter).minted(address(this), a3CRVGauge));
    }

	function getCRV() public view returns(uint256)
	{
		return IERC20(CRV).balanceOf(address(this));
	}

    function harvest() public
    {
        Mintr(CRVMinter).mint(a3CRVGauge);
        redelivery();
    }

    function redelivery() internal {
        uint256 reward = IERC20(CRV).balanceOf(address(this));
        if (reward > redeliverynum)
        {
            uint256 _2weth = reward.mul(80).div(100); //80%
		    uint256 _2bt = reward.sub(_2weth);  //20%
		    UniswapRouter(unirouter).swapExactTokensForTokens(_2weth, 0, swap2TokenRouting, address(this), now.add(1800));
		    UniswapRouter(unirouter).swapExactTokensForTokens(_2bt, 0, swap2BTRouting, Controller(controller).rewards(), now.add(1800));
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