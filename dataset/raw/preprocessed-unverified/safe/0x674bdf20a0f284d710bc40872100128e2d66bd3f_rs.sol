/**
 *Submitted for verification at Etherscan.io on 2020-10-29
*/

// SPDX-License-Identifier: Apache-2.0
// Copyright 2017 Loopring Technology Limited.
pragma solidity ^0.7.0;


/// @title Ownable
/// @author Brecht Devos - <brecht@loopring.org>
/// @dev The Ownable contract has an owner address, and provides basic
///      authorization control functions, this simplifies the implementation of
///      "user permissions".


// Copyright 2017 Loopring Technology Limited.



/// @title Utility Functions for uint
/// @author Daniel Wang - <daniel@loopring.org>


// Copyright 2017 Loopring Technology Limited.



/// @title ERC20 Token Interface
/// @dev see https://github.com/ethereum/EIPs/issues/20
/// @author Daniel Wang - <daniel@loopring.org>
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

// Copyright 2017 Loopring Technology Limited.



// Copyright 2017 Loopring Technology Limited.



/// @title Utility Functions for addresses
/// @author Daniel Wang - <daniel@loopring.org>
/// @author Brecht Devos - <brecht@loopring.org>



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



// Copyright 2017 Loopring Technology Limited.



/// @title ERC20 safe transfer
/// @dev see https://github.com/sec-bit/badERC20Fix
/// @author Brecht Devos - <brecht@loopring.org>



// Taken from https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/utils/SafeCast.sol




/**
 * @dev Wrappers over Solidity's uintXX/intXX casting operators with added overflow
 * checks.
 *
 * Downcasting from uint256/int256 in Solidity does not revert on overflow. This can
 * easily result in undesired exploitation or bugs, since developers usually
 * assume that overflows raise errors. `SafeCast` restores this intuition by
 * reverting the transaction when such an operation overflows.
 *
 * Using this library instead of the unchecked operations eliminates an entire
 * class of bugs, so it's recommended to use it always.
 *
 * Can be combined with {SafeMath} and {SignedSafeMath} to extend it to smaller types, by performing
 * all math on `uint256` and `int256` and then downcasting.
 */


// Copyright 2017 Loopring Technology Limited.



/// @title IDepositContract.
/// @dev   Contract storing and transferring funds for an exchange.
///
///        ERC1155 tokens can be supported by registering pseudo token addresses calculated
///        as `address(keccak256(real_token_address, token_params))`. Then the custom
///        deposit contract can look up the real token address and paramsters with the
///        pseudo token address before doing the transfers.
/// @author Brecht Devos - <brecht@loopring.org>



/// @title DefaultDepositContract
/// @dev   Default implementation of IDepositContract that just stores
///        all funds without doing anything with them.
///
///        Should be able to work with proxy contracts so the contract
///        can be updated easily (but with great caution and transparency!)
///        when necessary.
///
/// @author Brecht Devos - <brecht@loopring.org>
contract DefaultDepositContract is IDepositContract, Claimable
{
    using AddressUtil       for address;
    using ERC20SafeTransfer for address;
    using MathUint          for uint;
    using SafeCast          for uint;

    address public exchange;

    mapping (address => bool) needCheckBalance;

    modifier onlyExchange()
    {
        require(msg.sender == exchange, "UNAUTHORIZED");
        _;
    }

    modifier ifNotZero(uint amount)
    {
        if (amount == 0) return;
        else  _;
    }

    event CheckBalance(
        address indexed token,
        bool            checkBalance
    );

    function initialize(
        address _exchange
        )
        external
    {
        require(
            exchange == address(0) && _exchange != address(0),
            "INVALID_EXCHANGE"
        );
        owner = msg.sender;
        exchange = _exchange;
    }

    function setCheckBalance(
        address token,
        bool    checkBalance
        )
        external
        onlyOwner
    {
        require(needCheckBalance[token] != checkBalance, "INVALID_VALUE");

        needCheckBalance[token] = checkBalance;
        emit CheckBalance(token, checkBalance);
    }

    function isTokenSupported(address /*token*/)
        external
        override
        pure
        returns (bool)
    {
        return true;
    }

    function deposit(
        address from,
        address token,
        uint96  amount,
        bytes   calldata /*extraData*/
        )
        external
        override
        payable
        onlyExchange
        ifNotZero(amount)
        returns (uint96 amountReceived)
    {
        uint ethToReturn = 0;

        if (isETHInternal(token)) {
            require(msg.value >= amount, "INVALID_ETH_DEPOSIT");
            amountReceived = amount;
            ethToReturn = msg.value - amount;
        } else {
            bool checkBalance = needCheckBalance[token];
            uint balanceBefore = checkBalance ? ERC20(token).balanceOf(address(this)) : 0;

            token.safeTransferFromAndVerify(from, address(this), uint(amount));

            uint balanceAfter = checkBalance ? ERC20(token).balanceOf(address(this)) : amount;
            uint diff = balanceAfter.sub(balanceBefore);
            amountReceived = diff.toUint96();

            ethToReturn = msg.value;
        }

        if (ethToReturn > 0) {
            from.sendETHAndVerify(ethToReturn, gasleft());
        }
    }

    function withdraw(
        address /*from*/,
        address to,
        address token,
        uint    amount,
        bytes   calldata /*extraData*/
        )
        external
        override
        payable
        onlyExchange
        ifNotZero(amount)
    {
        if (isETHInternal(token)) {
            to.sendETHAndVerify(amount, gasleft());
        } else {
            if (!token.safeTransfer(to, amount)){
                uint amountPaid = ERC20(token).balanceOf(address(this));
                require(amountPaid < amount, "UNEXPECTED");
                token.safeTransferAndVerify(to, amountPaid);
            }
        }
    }

    function transfer(
        address from,
        address to,
        address token,
        uint    amount
        )
        external
        override
        payable
        onlyExchange
        ifNotZero(amount)
    {
        token.safeTransferFromAndVerify(from, to, amount);
    }

    function isETH(address addr)
        external
        override
        pure
        returns (bool)
    {
        return isETHInternal(addr);
    }

    // -- Internal --

    function isETHInternal(address addr)
        internal
        pure
        returns (bool)
    {
        return addr == address(0);
    }
}