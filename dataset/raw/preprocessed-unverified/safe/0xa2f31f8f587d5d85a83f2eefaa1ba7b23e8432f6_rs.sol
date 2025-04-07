/**
 *Submitted for verification at Etherscan.io on 2020-12-02
*/

// SPDX-License-Identifier: Apache-2.0
pragma solidity ^0.7.0;
pragma experimental ABIEncoderV2;
// File: contracts/lib/Ownable.sol

// Copyright 2017 Loopring Technology Limited.


/// @title Ownable
/// @author Brecht Devos - <brecht@loopring.org>
/// @dev The Ownable contract has an owner address, and provides basic
///      authorization control functions, this simplifies the implementation of
///      "user permissions".


// File: contracts/lib/Claimable.sol

// Copyright 2017 Loopring Technology Limited.



/// @title Claimable
/// @author Brecht Devos - <brecht@loopring.org>
/// @dev Extension for the Ownable contract, where the ownership needs
///      to be claimed. This allows the new owner to accept the transfer.
contract Claimable is Ownable
{
    address public pendingOwner;

    /// @dev Modifier throws if called by any account other than the pendingOwner.
    modifier onlyPendingOwner() {
        require(msg.sender == pendingOwner, "UNAUTHORIZED");
        _;
    }

    /// @dev Allows the current owner to set the pendingOwner address.
    /// @param newOwner The address to transfer ownership to.
    function transferOwnership(
        address newOwner
        )
        public
        override
        onlyOwner
    {
        require(newOwner != address(0) && newOwner != owner, "INVALID_ADDRESS");
        pendingOwner = newOwner;
    }

    /// @dev Allows the pendingOwner address to finalize the transfer.
    function claimOwnership()
        public
        onlyPendingOwner
    {
        emit OwnershipTransferred(owner, pendingOwner);
        owner = pendingOwner;
        pendingOwner = address(0);
    }
}

// File: contracts/lib/AddressUtil.sol

// Copyright 2017 Loopring Technology Limited.


/// @title Utility Functions for addresses
/// @author Daniel Wang - <daniel@loopring.org>
/// @author Brecht Devos - <brecht@loopring.org>


// File: contracts/lib/ERC20.sol

// Copyright 2017 Loopring Technology Limited.


/// @title ERC20 Token Interface
/// @dev see https://github.com/ethereum/EIPs/issues/20
/// @author Daniel Wang - <daniel@loopring.org>
abstract contract ERC20
{
    function totalSupply()
        public
        view
        virtual
        returns (uint);

    function balanceOf(
        address who
        )
        public
        view
        virtual
        returns (uint);

    function allowance(
        address owner,
        address spender
        )
        public
        view
        virtual
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
/// @author Brecht Devos - <brecht@loopring.org>


// File: contracts/lib/Drainable.sol

// Copyright 2017 Loopring Technology Limited.





/// @title Drainable
/// @author Brecht Devos - <brecht@loopring.org>
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
        external
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

// File: contracts/aux/BatchTransactor.sol

// Copyright 2017 Loopring Technology Limited.




/// @title BatchTransactor
/// @author Daniel Wang - <daniel@loopring.org>
contract BatchTransactor is Drainable, Claimable
{

    function batchTransact(
        address target,
        bytes[] calldata txs,
        uint[]  calldata gasLimits
        )
        external
    {
        require(target != address(0), "EMPTY_TARGET");
        require(txs.length == gasLimits.length, "SIZE_DIFF");

        for (uint i = 0; i < txs.length; i++) {
            (bool success, bytes memory returnData) = target.call{gas: gasLimits[i]}(txs[i]);
            if (!success) {
                assembly {
                    revert(add(returnData, 32), mload(returnData))
                }
            }
        }
    }

    function canDrain(address drainer, address /*token*/)
        public
        override
        view
        returns (bool)
    {
        return drainer == owner;
    }
}