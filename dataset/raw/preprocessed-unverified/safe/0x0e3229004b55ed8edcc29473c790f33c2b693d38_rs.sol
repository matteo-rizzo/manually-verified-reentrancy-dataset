/**
 *Submitted for verification at Etherscan.io on 2021-08-28
*/

// SPDX-License-Identifier: Apache-2.0
pragma solidity ^0.7.0;
pragma experimental ABIEncoderV2;
// File: contracts/lib/MathUint.sol

// Copyright 2017 Loopring Technology Limited.


/// @title Utility Functions for uint
/// @author Daniel Wang - <[email protected]>


// File: contracts/core/iface/IAgentRegistry.sol

// Copyright 2017 Loopring Technology Limited.



abstract contract IAgentRegistry
{
    /// @dev Returns whether an agent address is an agent of an account owner
    /// @param owner The account owner.
    /// @param agent The agent address
    /// @return True if the agent address is an agent for the account owner, else false
    function isAgent(
        address owner,
        address agent
        )
        external
        virtual
        view
        returns (bool);

    /// @dev Returns whether an agent address is an agent of all account owners
    /// @param owners The account owners.
    /// @param agent The agent address
    /// @return True if the agent address is an agent for the account owner, else false
    function isAgent(
        address[] calldata owners,
        address            agent
        )
        external
        virtual
        view
        returns (bool);

    /// @dev Returns whether an agent address is a universal agent.
    /// @param agent The agent address
    /// @return True if the agent address is a universal agent, else false
    function isUniversalAgent(address agent)
        public
        virtual
        view
        returns (bool);
}

// File: contracts/lib/Ownable.sol

// Copyright 2017 Loopring Technology Limited.


/// @title Ownable
/// @author Brecht Devos - <[email protected]>
/// @dev The Ownable contract has an owner address, and provides basic
///      authorization control functions, this simplifies the implementation of
///      "user permissions".


// File: contracts/lib/Claimable.sol

// Copyright 2017 Loopring Technology Limited.



/// @title Claimable
/// @author Brecht Devos - <[email protected]>
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

// File: contracts/core/iface/IBlockVerifier.sol

// Copyright 2017 Loopring Technology Limited.



/// @title IBlockVerifier
/// @author Brecht Devos - <[email protected]>
abstract contract IBlockVerifier is Claimable
{
    // -- Events --

    event CircuitRegistered(
        uint8  indexed blockType,
        uint16         blockSize,
        uint8          blockVersion
    );

    event CircuitDisabled(
        uint8  indexed blockType,
        uint16         blockSize,
        uint8          blockVersion
    );

    // -- Public functions --

    /// @dev Sets the verifying key for the specified circuit.
    ///      Every block permutation needs its own circuit and thus its own set of
    ///      verification keys. Only a limited number of block sizes per block
    ///      type are supported.
    /// @param blockType The type of the block
    /// @param blockSize The number of requests handled in the block
    /// @param blockVersion The block version (i.e. which circuit version needs to be used)
    /// @param vk The verification key
    function registerCircuit(
        uint8    blockType,
        uint16   blockSize,
        uint8    blockVersion,
        uint[18] calldata vk
        )
        external
        virtual;

    /// @dev Disables the use of the specified circuit.
    /// @param blockType The type of the block
    /// @param blockSize The number of requests handled in the block
    /// @param blockVersion The block version (i.e. which circuit version needs to be used)
    function disableCircuit(
        uint8  blockType,
        uint16 blockSize,
        uint8  blockVersion
        )
        external
        virtual;

    /// @dev Verifies blocks with the given public data and proofs.
    ///      Verifying a block makes sure all requests handled in the block
    ///      are correctly handled by the operator.
    /// @param blockType The type of block
    /// @param blockSize The number of requests handled in the block
    /// @param blockVersion The block version (i.e. which circuit version needs to be used)
    /// @param publicInputs The hash of all the public data of the blocks
    /// @param proofs The ZK proofs proving that the blocks are correct
    /// @return True if the block is valid, false otherwise
    function verifyProofs(
        uint8  blockType,
        uint16 blockSize,
        uint8  blockVersion,
        uint[] calldata publicInputs,
        uint[] calldata proofs
        )
        external
        virtual
        view
        returns (bool);

    /// @dev Checks if a circuit with the specified parameters is registered.
    /// @param blockType The type of the block
    /// @param blockSize The number of requests handled in the block
    /// @param blockVersion The block version (i.e. which circuit version needs to be used)
    /// @return True if the circuit is registered, false otherwise
    function isCircuitRegistered(
        uint8  blockType,
        uint16 blockSize,
        uint8  blockVersion
        )
        external
        virtual
        view
        returns (bool);

    /// @dev Checks if a circuit can still be used to commit new blocks.
    /// @param blockType The type of the block
    /// @param blockSize The number of requests handled in the block
    /// @param blockVersion The block version (i.e. which circuit version needs to be used)
    /// @return True if the circuit is enabled, false otherwise
    function isCircuitEnabled(
        uint8  blockType,
        uint16 blockSize,
        uint8  blockVersion
        )
        external
        virtual
        view
        returns (bool);
}

// File: contracts/core/iface/IDepositContract.sol

// Copyright 2017 Loopring Technology Limited.


/// @title IDepositContract.
/// @dev   Contract storing and transferring funds for an exchange.
///
///        ERC1155 tokens can be supported by registering pseudo token addresses calculated
///        as `address(keccak256(real_token_address, token_params))`. Then the custom
///        deposit contract can look up the real token address and paramsters with the
///        pseudo token address before doing the transfers.
/// @author Brecht Devos - <[email protected]>


// File: contracts/core/iface/ILoopringV3.sol

// Copyright 2017 Loopring Technology Limited.



/// @title ILoopringV3
/// @author Brecht Devos - <[email protected]>
/// @author Daniel Wang  - <[email protected]>
abstract contract ILoopringV3 is Claimable
{
    // == Events ==
    event ExchangeStakeDeposited(address exchangeAddr, uint amount);
    event ExchangeStakeWithdrawn(address exchangeAddr, uint amount);
    event ExchangeStakeBurned(address exchangeAddr, uint amount);
    event SettingsUpdated(uint time);

    // == Public Variables ==
    mapping (address => uint) internal exchangeStake;

    uint    public totalStake;
    address public blockVerifierAddress;
    uint    public forcedWithdrawalFee;
    uint    public tokenRegistrationFeeLRCBase;
    uint    public tokenRegistrationFeeLRCDelta;
    uint8   public protocolTakerFeeBips;
    uint8   public protocolMakerFeeBips;

    address payable public protocolFeeVault;

    // == Public Functions ==

    /// @dev Returns the LRC token address
    /// @return the LRC token address
    function lrcAddress()
        external
        view
        virtual
        returns (address);

    /// @dev Updates the global exchange settings.
    ///      This function can only be called by the owner of this contract.
    ///
    ///      Warning: these new values will be used by existing and
    ///      new Loopring exchanges.
    function updateSettings(
        address payable _protocolFeeVault,   // address(0) not allowed
        address _blockVerifierAddress,       // address(0) not allowed
        uint    _forcedWithdrawalFee
        )
        external
        virtual;

    /// @dev Updates the global protocol fee settings.
    ///      This function can only be called by the owner of this contract.
    ///
    ///      Warning: these new values will be used by existing and
    ///      new Loopring exchanges.
    function updateProtocolFeeSettings(
        uint8 _protocolTakerFeeBips,
        uint8 _protocolMakerFeeBips
        )
        external
        virtual;

    /// @dev Gets the amount of staked LRC for an exchange.
    /// @param exchangeAddr The address of the exchange
    /// @return stakedLRC The amount of LRC
    function getExchangeStake(
        address exchangeAddr
        )
        public
        virtual
        view
        returns (uint stakedLRC);

    /// @dev Burns a certain amount of staked LRC for a specific exchange.
    ///      This function is meant to be called only from exchange contracts.
    /// @return burnedLRC The amount of LRC burned. If the amount is greater than
    ///         the staked amount, all staked LRC will be burned.
    function burnExchangeStake(
        uint amount
        )
        external
        virtual
        returns (uint burnedLRC);

    /// @dev Stakes more LRC for an exchange.
    /// @param  exchangeAddr The address of the exchange
    /// @param  amountLRC The amount of LRC to stake
    /// @return stakedLRC The total amount of LRC staked for the exchange
    function depositExchangeStake(
        address exchangeAddr,
        uint    amountLRC
        )
        external
        virtual
        returns (uint stakedLRC);

    /// @dev Withdraws a certain amount of staked LRC for an exchange to the given address.
    ///      This function is meant to be called only from within exchange contracts.
    /// @param  recipient The address to receive LRC
    /// @param  requestedAmount The amount of LRC to withdraw
    /// @return amountLRC The amount of LRC withdrawn
    function withdrawExchangeStake(
        address recipient,
        uint    requestedAmount
        )
        external
        virtual
        returns (uint amountLRC);

    /// @dev Gets the protocol fee values for an exchange.
    /// @return takerFeeBips The protocol taker fee
    /// @return makerFeeBips The protocol maker fee
    function getProtocolFeeValues(
        )
        public
        virtual
        view
        returns (
            uint8 takerFeeBips,
            uint8 makerFeeBips
        );
}

// File: contracts/core/iface/ExchangeData.sol

// Copyright 2017 Loopring Technology Limited.






/// @title ExchangeData
/// @dev All methods in this lib are internal, therefore, there is no need
///      to deploy this library independently.
/// @author Daniel Wang  - <[email protected]>
/// @author Brecht Devos - <[email protected]>


// File: contracts/lib/ERC20SafeTransfer.sol

// Copyright 2017 Loopring Technology Limited.


/// @title ERC20 safe transfer
/// @dev see https://github.com/sec-bit/badERC20Fix
/// @author Brecht Devos - <[email protected]>


// File: contracts/core/impl/libexchange/ExchangeMode.sol

// Copyright 2017 Loopring Technology Limited.




/// @title ExchangeMode.
/// @dev All methods in this lib are internal, therefore, there is no need
///      to deploy this library independently.
/// @author Brecht Devos - <[email protected]>
/// @author Daniel Wang  - <[email protected]>


// File: contracts/core/impl/libexchange/ExchangeTokens.sol

// Copyright 2017 Loopring Technology Limited.






/// @title ExchangeTokens.
/// @author Daniel Wang  - <[email protected]>
/// @author Brecht Devos - <[email protected]>


// File: contracts/core/impl/libexchange/ExchangeGenesis.sol

// Copyright 2017 Loopring Technology Limited.








/// @title ExchangeGenesis.
/// @author Daniel Wang  - <[email protected]>
/// @author Brecht Devos - <[email protected]>
