/**
 *Submitted for verification at Etherscan.io on 2021-08-13
*/

/**
 * Copyright 2017-2021, bZeroX, LLC. All Rights Reserved.
 * Licensed under the Apache License, Version 2.0.
 */

pragma solidity 0.6.12;


/**
 * @dev Wrappers over Solidity's arithmetic operations with added overflow
 * checks.
 *
 * Arithmetic operations in Solidity wrap on overflow. This can easily result
 * in bugs, because programmers usually assume that an overflow raises an
 * error, which is the standard behavior in high level programming languages.
 * `SafeMath` restores this intuition by reverting the transaction when an
 * operation overflows.
 *
 * Using this library instead of the unchecked operations eliminates an entire
 * class of bugs, so it's recommended to use it always.
 */




contract VotingPassthrough_ETH {
    function balanceOf(
        address account)
        external
        view
        returns (uint256)
    {
        return VotingPassthrough_ETH_Interface(0xe95Ebce2B02Ee07dEF5Ed6B53289801F7Fc137A4).votingBalanceOfNow(account);
    }
}