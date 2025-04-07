/**
 *Submitted for verification at Etherscan.io on 2021-03-10
*/

// SPDX-License-Identifier: Apache-2.0
pragma solidity ^0.7.0;
pragma experimental ABIEncoderV2;
// File: contracts/lib/ReentrancyGuard.sol

// Copyright 2017 Loopring Technology Limited.


/// @title ReentrancyGuard
/// @author Brecht Devos - <[email protected]>
/// @dev Exposes a modifier that guards a function against reentrancy
///      Changing the value of the same storage value multiple times in a transaction
///      is cheap (starting from Istanbul) so there is no need to minimize
///      the number of times the value is changed
contract ReentrancyGuard
{
    //The default value must be 0 in order to work behind a proxy.
    uint private _guardValue;

    // Use this modifier on a function to prevent reentrancy
    modifier nonReentrant()
    {
        // Check if the guard value has its original value
        require(_guardValue == 0, "REENTRANCY");

        // Set the value to something else
        _guardValue = 1;

        // Function body
        _;

        // Set the value back
        _guardValue = 0;
    }
}

// File: contracts/lib/AddressUtil.sol

// Copyright 2017 Loopring Technology Limited.


/// @title Utility Functions for addresses
/// @author Daniel Wang - <[email protected]>
/// @author Brecht Devos - <[email protected]>


// File: contracts/lib/ERC20.sol

// Copyright 2017 Loopring Technology Limited.


/// @title ERC20 Token Interface
/// @dev see https://github.com/ethereum/EIPs/issues/20
/// @author Daniel Wang - <[email protected]>
abstract contract ERC20
{
    function totalSupply()
        public
        virtual
        view
        returns (uint);

    function balanceOf(
        address who
        )
        public
        virtual
        view
        returns (uint);

    function allowance(
        address owner,
        address spender
        )
        public
        virtual
        view
        returns (uint);

    function transfer(
        address to,
        uint value
        )
        public
        virtual
        returns (bool);

    function transferFrom(
        address from,
        address to,
        uint    value
        )
        public
        virtual
        returns (bool);

    function approve(
        address spender,
        uint    value
        )
        public
        virtual
        returns (bool);
}

// File: contracts/lib/ERC20SafeTransfer.sol

// Copyright 2017 Loopring Technology Limited.


/// @title ERC20 safe transfer
/// @dev see https://github.com/sec-bit/badERC20Fix
/// @author Brecht Devos - <[email protected]>


// File: contracts/lib/Drainable.sol

// Copyright 2017 Loopring Technology Limited.





/// @title Drainable
/// @author Brecht Devos - <[email protected]>
/// @dev Standard functionality to allow draining funds from a contract.
abstract contract Drainable
{
    using AddressUtil       for address;
    using ERC20SafeTransfer for address;

    event Drained(
        address to,
        address token,
        uint    amount
    );

    function drain(
        address to,
        address token
        )
        public
        returns (uint amount)
    {
        require(canDrain(msg.sender, token), "UNAUTHORIZED");

        if (token == address(0)) {
            amount = address(this).balance;
            to.sendETHAndVerify(amount, gasleft());   // ETH
        } else {
            amount = ERC20(token).balanceOf(address(this));
            token.safeTransferAndVerify(to, amount);  // ERC20 token
        }

        emit Drained(to, token, amount);
    }

    // Needs to return if the address is authorized to call drain.
    function canDrain(address drainer, address token)
        public
        virtual
        view
        returns (bool);
}

// File: contracts/aux/migrate/MigrationToLoopringExchangeV2.sol

// Copyright 2017 Loopring Technology Limited.



abstract contract ILoopringV3Partial
{
    function withdrawExchangeStake(
        uint    exchangeId,
        address recipient,
        uint    requestedAmount
        )
        external
        virtual
        returns (uint amount);
}

/// @author Kongliang Zhong - <[email protected]>
/// @dev This contract enables an alternative approach of getting back assets from Loopring Exchange v1.
/// Now you don't have to withdraw using merkle proofs (very expensive);
/// instead, all assets will be distributed on Loopring Exchange v2 - Loopring's new zkRollup implementation.
/// Please activate and unlock your address on https://exchange.loopring.io to claim your assets.
contract MigrationToLoopringExchangeV2 is Drainable
{
    string constant public version = "3.1.3";

    function canDrain(address /*drainer*/, address /*token*/)
        public
        override
        view
        returns (bool) {
        return isMigrationOperator();
    }

    function withdrawExchangeStake(
        address loopringV3,
        uint exchangeId,
        uint amount,
        address recipient
        )
        external
    {
        require(isMigrationOperator(), "INVALID_SENDER");
        ILoopringV3Partial(loopringV3).withdrawExchangeStake(exchangeId, recipient, amount);
    }

    function isMigrationOperator() internal view returns (bool) {
        return msg.sender == 0x4374D3d032B3c96785094ec9f384f07077792768;
    }

}