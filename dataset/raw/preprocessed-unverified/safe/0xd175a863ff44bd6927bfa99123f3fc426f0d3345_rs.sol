/**
 *Submitted for verification at Etherscan.io on 2021-06-12
*/

// SPDX-License-Identifier: AGPL-3.0-or-later
pragma solidity 0.7.5;




contract StakingWarmup {

    address public immutable staking;
    address public immutable sOHM;

    constructor ( address _staking, address _sOHM ) {
        require( _staking != address(0) );
        staking = _staking;
        require( _sOHM != address(0) );
        sOHM = _sOHM;
    }

    function send( address _staker, uint _amount ) external {
        require( msg.sender == staking );
        IERC20( sOHM ).transfer( _staker, _amount );
    }
}