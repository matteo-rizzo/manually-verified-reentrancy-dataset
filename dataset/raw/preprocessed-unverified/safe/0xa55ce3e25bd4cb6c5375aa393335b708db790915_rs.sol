/**
 *Submitted for verification at Etherscan.io on 2021-06-20
*/

/**
 *Submitted for verification at Etherscan.io on 2021-06-12
*/

// SPDX-License-Identifier: AGPL-3.0-or-later
pragma solidity 0.7.5;






contract StakingHelper {

    address public immutable staking;
    address public immutable OHM;

    constructor ( address _staking, address _OHM ) {
        require( _staking != address(0) );
        staking = _staking;
        require( _OHM != address(0) );
        OHM = _OHM;
    }

    function stake( uint _amount, address _recipient ) external {
        IERC20( OHM ).transferFrom( msg.sender, address(this), _amount );
        IERC20( OHM ).approve( staking, _amount );
        IStaking( staking ).stake( _amount, _recipient );
        IStaking( staking ).claim( _recipient );
    }
}