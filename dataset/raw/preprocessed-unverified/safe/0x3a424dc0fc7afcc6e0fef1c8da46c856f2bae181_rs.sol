/**
 *Submitted for verification at Etherscan.io on 2021-08-12
*/

/**
 *Submitted for verification at Etherscan.io on 2021-06-12
 */

// SPDX-License-Identifier: AGPL-3.0-or-later
pragma solidity 0.7.5;





contract StakingHelper {
    address public immutable staking;
    address public immutable ASG;

    constructor(address _staking, address _ASG) {
        require(_staking != address(0));
        staking = _staking;
        require(_ASG != address(0));
        ASG = _ASG;
    }

    function stake(uint256 _amount, address _recipient) external {
        IERC20(ASG).transferFrom(msg.sender, address(this), _amount);
        IERC20(ASG).approve(staking, _amount);
        IStaking(staking).stake(_amount, _recipient);
        IStaking(staking).claim(_recipient);
    }
}