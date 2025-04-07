/**
 *Submitted for verification at Etherscan.io on 2021-05-21
*/

// SPDX-License-Identifier: MIT

pragma solidity ^0.5.15;



















contract StrategyalUSD3CRV {
    using SafeERC20 for IERC20;
    using Address for address;
    using SafeMath for uint256;

    uint256 poolId = 4;

    address constant public unirouter = address(0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D);
    address constant public weth = address(0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2);
	address constant public bt = address(0x76c5449F4950f6338A393F53CdA8b53B0cd3Ca3a);
    address constant public usdt = address(0xdAC17F958D2ee523a2206206994597C13D831ec7);

    address constant public want = address(0x43b4FdFD4Ff969587185cDB6f0BD875c5Fc83f8c);  //alUSD3CRV

    address constant public stakingPools = address(0xAB8e74017a8Cc7c15FFcCd726603790d26d7DeCa);     //StakingPools

    address constant public ALCX = address(0xdBdb4d16EdA451D0503b854CF79D55697F90c8DF);        //ALCX

    address constant public alUSD3CRV = address(0xA79828DF1850E8a3A3064576f380D90aECDD3359);
    address constant public alUSDPool = address(0x43b4FdFD4Ff969587185cDB6f0BD875c5Fc83f8c);

    address public governance;
    address public controller;

    uint256 public redeliverynum = 100 * 1e18;

	address[] public swap2BTRouting;
    address[] public swap2TokenRouting;

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
        doApprove();
		swap2BTRouting = [ALCX,weth,bt];
        swap2TokenRouting = [ALCX,weth, usdt];
    }

	function doApprove () internal{
        IERC20(ALCX).approve(unirouter, uint(-1));
    }

    function deposit() public isAuthorized{
		uint256 _wantAmount = IERC20(want).balanceOf(address(this));
		if (_wantAmount > 0) {
            IERC20(want).safeApprove(stakingPools, 0);
            IERC20(want).safeApprove(stakingPools, _wantAmount);

            StakingPools(stakingPools).deposit(poolId,_wantAmount);
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
            amount = _amount.sub(amount);
            uint256 allAmount = StakingPools(stakingPools).getStakeTotalDeposited(address(this),poolId);
            if(amount > allAmount){
                amount = allAmount;
            }
            StakingPools(stakingPools).withdraw(poolId,amount);
			amount = IERC20(want).balanceOf(address(this));
            if (amount < _amount){
                return amount;
            }
        }
		return _amount;
    }

	function withdrawAll() external onlyController returns (uint balance){
		balance = _withdraw(balanceOf());

		address _vault = Controller(controller).vaults(address(want));
        require(_vault != address(0), "!vault");
        IERC20(want).safeTransfer(_vault, balance);
	}

    // Governance only function for creating additional rewards from dust
    function withdrawAsset(address _asset,address _to) external returns(uint256 balance){
        require(msg.sender == governance, "!governance");
        require(_to != address(0x0) && _asset != address(0x0) ,"Invalid address");
        require(want != _asset , "want");
        balance = IERC20(_asset).balanceOf(address(this));
        IERC20(_asset).safeTransfer(_to, balance);
    }

    function balanceOfwant() public view returns (uint256) {
		return IERC20(want).balanceOf(address(this));
	}

	function balanceOfStakingPool() public view returns (uint256) {
		return StakingPools(stakingPools).getStakeTotalDeposited(address(this),poolId);
	}

    function balanceOf() public view returns (uint256) {
        return balanceOfwant().add(balanceOfStakingPool());
    }

    function getALCXToken()public view returns(uint256) {
        return IERC20(ALCX).balanceOf(address(this));
    }

    function getPending()public view returns(uint256){
        return StakingPools(stakingPools).getStakeTotalUnclaimed(address(this),poolId);
    }

    function harvest() public
    {
        StakingPools(stakingPools).claim(poolId);
        redelivery();
    }

    function redelivery() internal {
        uint256 reward = IERC20(ALCX).balanceOf(address(this));
        if(reward > redeliverynum){
            uint256 _2token = reward.mul(80).div(100); //80%
		    uint256 _2bt = reward.sub(_2token);  //20%
		    UniswapRouter(unirouter).swapExactTokensForTokens(_2token, 0, swap2TokenRouting, address(this), now.add(1800));
		    UniswapRouter(unirouter).swapExactTokensForTokens(_2bt, 0, swap2BTRouting, Controller(controller).rewards(), now.add(1800));

            uint _usdtAmount = IERC20(usdt).balanceOf(address(this));
            if (_usdtAmount > 0) {
                IERC20(usdt).safeApprove(alUSD3CRV, 0);
                IERC20(usdt).safeApprove(alUSD3CRV, _usdtAmount);
                ICurveFi(alUSD3CRV).add_liquidity(alUSDPool,[0,0,0, _usdtAmount],0,address(this));
            }

            deposit();
        }
    }

    function setredeliverynum(uint256 value) public {
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