/**
 *Submitted for verification at Etherscan.io on 2021-08-12
*/

/**
 *Submitted for verification at Etherscan.io on 2021-06-12
 */

// SPDX-License-Identifier: AGPL-3.0-or-later
pragma solidity 0.7.5;



contract StakingWarmup {
    address public immutable staking;
    address public immutable sASG;

    constructor(address _staking, address _sASG) {
        require(_staking != address(0));
        staking = _staking;
        require(_sASG != address(0));
        sASG = _sASG;
    }

    function retrieve(address _staker, uint256 _amount) external {
        require(msg.sender == staking);
        IERC20(sASG).transfer(_staker, _amount);
    }
}