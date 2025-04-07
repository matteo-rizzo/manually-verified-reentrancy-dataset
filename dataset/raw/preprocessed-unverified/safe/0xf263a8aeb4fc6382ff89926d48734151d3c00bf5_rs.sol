/**
 *Submitted for verification at Etherscan.io on 2021-03-10
*/

// SPDX-License-Identifier: MIT

pragma solidity ^0.5.17;




















contract StrategyWBTCCurve {
    using SafeERC20 for IERC20;
    using Address for address;
    using SafeMath for uint256;

    address constant public unirouter = address(0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D);
    address constant public weth = address(0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2);
	address constant public bt = address(0x76c5449F4950f6338A393F53CdA8b53B0cd3Ca3a);

    address constant public want = address(0x2260FAC5E5542a773Aa44fBCfeDf7C193bc2C599);  //WBTC

    address constant public cruvefi = address(0xC45b2EEe6e09cA176Ca3bB5f7eEe7C47bF93c756);
    address constant public bBtc = address(0x410e3E86ef427e30B9235497143881f717d93c2A);

    address constant public bBtcGauge = address(0xdFc7AdFa664b08767b735dE28f9E84cd30492aeE);

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
        IERC20(bBtc).approve(cruvefi,uint(-1));
    }


    function deposit() public {
		uint _wbtc = IERC20(want).balanceOf(address(this));

        require(_wbtc > 0,"WBTC is 0");
        IERC20(want).safeApprove(cruvefi, 0);
        IERC20(want).safeApprove(cruvefi, _wbtc);
        uint256 v = _wbtc.mul(1e28).div(ICurveFi(cruvefi).calc_token_amount([0,0,uint256(100000000),0],true));   //1e10 * 1e18
		uint256 beforebBtc = IERC20(bBtc).balanceOf(address(this));
        ICurveFi(cruvefi).add_liquidity([0, 0, _wbtc,0],v.mul(DENOMINATOR.sub(slip)).div(DENOMINATOR));
        uint256 _bBtc = IERC20(bBtc).balanceOf(address(this));
		depositLastPrice = _wbtc.mul(1e28).div(_bBtc.sub(beforebBtc));      //1e10 * 1e18

        require(_bBtc > 0,"bBtc is 0");
        IERC20(bBtc).safeApprove(bBtcGauge, 0);
        IERC20(bBtc).safeApprove(bBtcGauge, _bBtc);
        Gauge(bBtcGauge).deposit(_bBtc);
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
            uint256 _bBtc = _withdrawSome(_amount.sub(amount));
			uint256 afterAmount = IERC20(want).balanceOf(address(this));
			if(withdrawSlipCheck){
				uint256 withdrawPrice = afterAmount.sub(amount).mul(1e28).div(_bBtc);        //1e10 * 1e18
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

    function _withdrawSome(uint _amount) internal returns(uint256 _bBtc)
    {
        _bBtc =  ICurveFi(cruvefi).calc_token_amount([0,0,_amount,0],false);
        uint256 _bBtcBefore = IERC20(bBtc).balanceOf(address(this));
        if(_bBtc > _bBtcBefore){
            uint256 _bBtcGauge = _bBtc.sub(_bBtcBefore);
            if(_bBtcGauge >IERC20(bBtcGauge).balanceOf(address(this))){
                _bBtcGauge = IERC20(bBtcGauge).balanceOf(address(this));
            }
            Gauge(bBtcGauge).withdraw(_bBtcGauge);
            _bBtc = IERC20(bBtc).balanceOf(address(this));
        }
        ICurveFi(cruvefi).remove_liquidity_one_coin(_bBtc,2,_amount.mul(DENOMINATOR.sub(slip)).div(DENOMINATOR));
    }

	function withdrawAll() external onlyController returns (uint balance) {
        bool withdrawSlipTemp = withdrawSlipCheck;
        withdrawSlipCheck = false;
		_withdraw(balanceOf());
        withdrawSlipCheck = withdrawSlipTemp;
        balance = IERC20(want).balanceOf(address(this));

		address _vault = Controller(controller).vaults(address(want));
        require(_vault != address(0), "!vault");
        IERC20(want).safeTransfer(_vault, balance);
	}


	function balanceOfwant() public view returns (uint256) {
		return IERC20(want).balanceOf(address(this));
	}

	function balanceOfbBtc() public view returns (uint256) {
        return IERC20(bBtcGauge).balanceOf(address(this)).add(IERC20(bBtc).balanceOf(address(this)));
	}

    function balanceOfbBtc2WBTC() public view returns(uint256) {
        uint256 _bBtc = balanceOfbBtc();
        if (_bBtc == 0)
        {
            return 0;
        }
        return ICurveFi(cruvefi).calc_withdraw_one_coin(_bBtc,2);
    }

    function balanceOf() public view returns (uint256) {
        return balanceOfwant().add(balanceOfbBtc2WBTC());
    }

    function getPending() public view returns (uint256) {
        return Gauge(bBtcGauge).integrate_fraction(address(this)).sub(Mintr(CRVMinter).minted(address(this), bBtcGauge));
    }

	function getCRV() public view returns(uint256)
	{
		return IERC20(CRV).balanceOf(address(this));
	}

    function harvest() public
    {
        Mintr(CRVMinter).mint(bBtcGauge);
        redelivery();
    }

    function redelivery() internal {
        uint256 reward = IERC20(CRV).balanceOf(address(this));
        if (reward > redeliverynum)
        {
            uint256 _2wbtc = reward.mul(80).div(100); //80%
		    uint256 _2bt = reward.sub(_2wbtc);  //20%
		    UniswapRouter(unirouter).swapExactTokensForTokens(_2wbtc, 0, swap2TokenRouting, address(this), now.add(1800));
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