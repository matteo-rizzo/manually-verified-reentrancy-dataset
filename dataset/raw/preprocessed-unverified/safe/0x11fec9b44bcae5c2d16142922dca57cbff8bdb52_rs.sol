/**
 *Submitted for verification at Etherscan.io on 2020-11-04
*/

// SPDX-License-Identifier: MIT

pragma solidity 0.7.0;

/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
 */
























contract YfvAdapter is IVampireAdapter {
    IDrainController constant drainController = IDrainController(0x2C907E0c40b9Dbb834eDD3Fdb739de4df9eDb9D7);
    IValueMinorPool constant valueMinorPool = IValueMinorPool(0xcC51169c21158084371C63BC260abA4AfdcfBd2f);
    IERC20 constant value = IERC20(0x49E833337ECe7aFE375e44F4E3e8481029218E5c);
    IERC20 constant weth = IERC20(0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2);
    IUniswapV2Pair constant valueWethPair = IUniswapV2Pair(0xd9159376499936868A5B061a4633481131e70732);
    // token 0 -  value
    // token 1 - weth

    constructor() {
    }

    // Victim info
    function rewardToken() external pure override returns (IERC20) {
        return value;
    }

    function poolCount() external view override returns (uint256) {
        return valueMinorPool.poolLength();
    }

    function sellableRewardAmount() external pure override returns (uint256) {
        return uint256(-1);
    }
    
    // Victim actions, requires impersonation via delegatecall
    function sellRewardForWeth(address, uint256 rewardAmount, address to) external override returns(uint256) {
        require(drainController.priceIsUnderRejectionTreshold(), "Possible price manipulation, drain rejected");
        value.transfer(address(valueWethPair), rewardAmount);
        (uint sushiReserve, uint wethReserve,) = valueWethPair.getReserves();
        uint amountOutput = UniswapV2Library.getAmountOut(rewardAmount, sushiReserve, wethReserve);
        valueWethPair.swap(uint(0), amountOutput, to, new bytes(0));
        return amountOutput;
    }
    
    // Pool info
    function lockableToken(uint256 poolId) external view override returns (IERC20) {
        (IERC20 lpToken,,,,) = valueMinorPool.poolInfo(poolId);
        return lpToken;
    }

    function lockedAmount(address user, uint256 poolId) external view override returns (uint256) {
        (uint256 amount,,) = valueMinorPool.userInfo(poolId, user);
        return amount;
    }
    
    // Pool actions, requires impersonation via delegatecall
    function deposit(address _adapter, uint256 poolId, uint256 amount) external override {
        IVampireAdapter adapter = IVampireAdapter(_adapter);
        adapter.lockableToken(poolId).approve(address(valueMinorPool), uint256(-1));
        valueMinorPool.deposit(poolId, amount, address(0));
    }

    function withdraw(address, uint256 poolId, uint256 amount) external override {
        valueMinorPool.withdraw(poolId, amount);
    }

    function claimReward(address, uint256 poolId) external override {
        valueMinorPool.deposit(poolId, 0, address(0));
    }
    
    function emergencyWithdraw(address, uint256 poolId) external override {
        valueMinorPool.emergencyWithdraw(poolId);
    }

    // Service methods
    function poolAddress(uint256) external pure override returns (address) {
        return address(valueMinorPool);
    }

    function rewardToWethPool() external pure override returns (address) {
        return address(valueWethPair);
    }
    
    function lockedValue(address, uint256) external override pure returns (uint256) {
        require(false, "not implemented");
    }    

    function totalLockedValue(uint256) external override pure returns (uint256) {
        require(false, "not implemented"); 
    }

    function normalizedAPY(uint256) external override pure returns (uint256) {
        require(false, "not implemented");
    }
}