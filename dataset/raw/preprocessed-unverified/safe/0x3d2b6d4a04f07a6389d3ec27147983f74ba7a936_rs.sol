/**
 *Submitted for verification at Etherscan.io on 2021-02-03
*/

// SPDX-License-Identifier: MIT

pragma solidity ^0.5.17;




















contract StrategyWBTCCurve {
    using SafeERC20 for IERC20;
    using Address for address;
    using SafeMath for uint256;

    address constant public unirouter = address(0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D);
    address constant public dmsrouter = address(0x446D34aBF8Ac435f9191A7C1b14FfB88BB77F3ec);
    address constant public weth = address(0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2);
	address constant public dms = address(0x34D3d2b46881588387Dbe17e3B478DcB8b1A2450);

    address constant public want = address(0x2260FAC5E5542a773Aa44fBCfeDf7C193bc2C599);  //WBTC

    address constant public cruvefi = address(0xC45b2EEe6e09cA176Ca3bB5f7eEe7C47bF93c756);
    address constant public bBtc = address(0x410e3E86ef427e30B9235497143881f717d93c2A);

    address constant public bBtcGauge = address(0xdFc7AdFa664b08767b735dE28f9E84cd30492aeE);

    address constant public CRVMinter = address(0xd061D61a4d941c39E5453435B6345Dc261C2fcE0);
    address constant public CRV = address(0xD533a949740bb3306d119CC777fa900bA034cd52);

    address public governance;
    address public controller;
    uint256 public redeliverynum = 100 * 1e18;

    address[] public swap2TokenRouting;
    address[] public swap2WETHRouting;
    address[] public swap2DMSRouting;

    modifier onlyController {
        require(msg.sender == controller, "!controller");
        _;
    }

    constructor() public {
        governance = tx.origin;
        controller = 0xEE79a912B31e85a3245fb1A431D68b577993B7dC;
		swap2WETHRouting = [CRV,weth];
		swap2DMSRouting = [weth, dms];
        swap2TokenRouting = [CRV,weth,want];

        IERC20(CRV).approve(unirouter, uint(-1));
        IERC20(bBtc).approve(cruvefi,uint(-1));
        IERC20(weth).approve(dmsrouter, uint(-1));
    }


    function deposit() public {
		uint _wbtc = IERC20(want).balanceOf(address(this));

        require(_wbtc > 0,"WBTC is 0");
        IERC20(want).safeApprove(cruvefi, 0);
        IERC20(want).safeApprove(cruvefi, _wbtc);
        ICurveFi(cruvefi).add_liquidity([0, 0, _wbtc,0],0);

        uint256 _bBtc = IERC20(bBtc).balanceOf(address(this));
        require(_wbtc > 0,"bBtc is 0");
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
			_withdrawSome(_amount.sub(amount));
			amount = IERC20(want).balanceOf(address(this));
		}
        if (amount < _amount){
            return amount;
        }
		return _amount;
    }

    function _withdrawSome(uint _amount) internal
    {
        uint256 _bBtc =  ICurveFi(cruvefi).calc_token_amount([0,0,_amount,0],false);
        uint256 _bBtcBefore = IERC20(bBtc).balanceOf(address(this));
        if(_bBtc > _bBtcBefore){
            uint256 _bBtcGauge = _bBtc.sub(_bBtcBefore);
            if(_bBtcGauge >IERC20(bBtcGauge).balanceOf(address(this))){
                _bBtcGauge = IERC20(bBtcGauge).balanceOf(address(this));
            }
            Gauge(bBtcGauge).withdraw(_bBtcGauge);
            _bBtc = IERC20(bBtc).balanceOf(address(this));
        }
        ICurveFi(cruvefi).remove_liquidity_one_coin(_bBtc,2,0);
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
            uint256 _2want = reward.mul(80).div(100); //80%
		    UniswapRouter(unirouter).swapExactTokensForTokens(_2want, 0, swap2TokenRouting, address(this), now.add(1800));
		    uint256 _2weth = reward.sub(_2want);  //20%
            UniswapRouter(unirouter).swapExactTokensForTokens(_2weth, 0, swap2WETHRouting, address(this), now.add(1800));
            uint256 _weth = IERC20(weth).balanceOf(address(this));
		    UniswapRouter(dmsrouter).swapExactTokensForTokens(_weth, 0, swap2DMSRouting, Controller(controller).rewards(), now.add(1800));
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
}