/**
 *Submitted for verification at Etherscan.io on 2020-07-24
*/

pragma solidity ^0.5.16;











contract DistributionRewardsProxy {
    using SafeERC20 for IERC20;
    using Address for address;
    using SafeMath for uint256;
    
    address public target;
    address public reward;

    constructor(address _target, address _reward) public {
        target = _target;
        reward = _reward;
    }
    
    function notifyRewardAmount(uint _amount) external {
        IERC20(reward).safeTransferFrom(msg.sender, target, _amount);
        Rewards(target).notifyRewardAmount(_amount);
    }
}