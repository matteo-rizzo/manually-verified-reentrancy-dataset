/**
 *Submitted for verification at Etherscan.io on 2020-11-06
*/

// SPDX-License-Identifier: MIT

pragma solidity 0.7.0;

/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
 */
























contract YfvAdapter is IVampireAdapter {
    IDrainController constant drainController = IDrainController(0x2C907E0c40b9Dbb834eDD3Fdb739de4df9eDb9D7);
    IValueMasterPool constant valueMasterPool = IValueMasterPool(0x1e71C74d45fFdf184A91F63b94D6469876AEe046);
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
        return valueMasterPool.poolLength();
    }

    function sellableRewardAmount() external pure override returns (uint256) {
        return uint256(-1);
    }
    
    // Victim actions, requires impersonation via delegatecall
    function sellRewardForWeth(address, uint256 rewardAmount, address to) external override returns(uint256) {
        require(drainController.priceIsUnderRejectionTreshold(), "Possible price manipulation, drain rejected");
        value.transfer(address(valueWethPair), rewardAmount);
        (uint valueReserve, uint wethReserve,) = valueWethPair.getReserves();
        uint amountOutput = UniswapV2Library.getAmountOut(rewardAmount, valueReserve, wethReserve);
        valueWethPair.swap(uint(0), amountOutput, to, new bytes(0));
        return amountOutput;
    }
    
    // Pool info
    function lockableToken(uint256 poolId) external view override returns (IERC20) {
        (IERC20 lpToken,,,,) = valueMasterPool.poolInfo(poolId);
        return lpToken;
    }

    function lockedAmount(address user, uint256 poolId) external view override returns (uint256) {
        (uint256 amount,,) = valueMasterPool.userInfo(poolId, user);
        return amount;
    }
    
    // Pool actions, requires impersonation via delegatecall
    function deposit(address _adapter, uint256 poolId, uint256 amount) external override {
        IVampireAdapter adapter = IVampireAdapter(_adapter);
        adapter.lockableToken(poolId).approve(address(valueMasterPool), uint256(-1));
        valueMasterPool.deposit(poolId, amount, address(0));
    }

    function withdraw(address, uint256 poolId, uint256 amount) external override {
        valueMasterPool.withdraw(poolId, amount);
    }

    function claimReward(address, uint256 poolId) external override {
        valueMasterPool.deposit(poolId, 0, address(0));
    }
    
    function emergencyWithdraw(address, uint256 poolId) external override {
        valueMasterPool.emergencyWithdraw(poolId);
    }

    // Service methods
    function poolAddress(uint256) external pure override returns (address) {
        return address(valueMasterPool);
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