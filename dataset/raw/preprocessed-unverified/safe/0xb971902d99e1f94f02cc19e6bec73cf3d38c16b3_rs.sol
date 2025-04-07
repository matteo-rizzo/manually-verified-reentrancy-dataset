/**
 *Submitted for verification at Etherscan.io on 2020-10-29
*/

// SPDX-License-Identifier: Apache-2.0
// Copyright 2017 Loopring Technology Limited.
pragma solidity ^0.7.0;


/// @title Utility Functions for uint
/// @author Daniel Wang - <daniel@loopring.org>


// Copyright 2017 Loopring Technology Limited.



/// @title Ownable
/// @author Brecht Devos - <brecht@loopring.org>
/// @dev The Ownable contract has an owner address, and provides basic
///      authorization control functions, this simplifies the implementation of
///      "user permissions".


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

//Mainly taken from https://github.com/GNSPS/solidity-bytes-utils/blob/master/contracts/BytesLib.sol



// Copyright 2017 Loopring Technology Limited.

pragma experimental ABIEncoderV2;



// Copyright 2017 Loopring Technology Limited.




// Copyright 2017 Loopring Technology Limited.







// Copyright 2017 Loopring Technology Limited.






/// @title IBlockVerifier
/// @author Brecht Devos - <brecht@loopring.org>
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
    ///      This will stop NEW blocks from using the given circuit, blocks that were already committed
    ///      can still be verified.
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


// Copyright 2017 Loopring Technology Limited.



/// @title IDepositContract.
/// @dev   Contract storing and transferring funds for an exchange.
///
///        ERC1155 tokens can be supported by registering pseudo token addresses calculated
///        as `address(keccak256(real_token_address, token_params))`. Then the custom
///        deposit contract can look up the real token address and paramsters with the
///        pseudo token address before doing the transfers.
/// @author Brecht Devos - <brecht@loopring.org>


// Copyright 2017 Loopring Technology Limited.





/// @title ILoopringV3
/// @author Brecht Devos - <brecht@loopring.org>
/// @author Daniel Wang  - <daniel@loopring.org>
abstract contract ILoopringV3 is Claimable
{
    // == Events ==
    event ExchangeStakeDeposited(address exchangeAddr, uint amount);
    event ExchangeStakeWithdrawn(address exchangeAddr, uint amount);
    event ExchangeStakeBurned(address exchangeAddr, uint amount);
    event SettingsUpdated(uint time);

    // == Public Variables ==
    mapping (address => uint) internal exchangeStake;

    address public lrcAddress;
    uint    public totalStake;
    address public blockVerifierAddress;
    uint    public forcedWithdrawalFee;
    uint    public tokenRegistrationFeeLRCBase;
    uint    public tokenRegistrationFeeLRCDelta;
    uint8   public protocolTakerFeeBips;
    uint8   public protocolMakerFeeBips;

    address payable public protocolFeeVault;

    // == Public Functions ==
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



/// @title ExchangeData
/// @dev All methods in this lib are internal, therefore, there is no need
///      to deploy this library independently.
/// @author Daniel Wang  - <daniel@loopring.org>
/// @author Brecht Devos - <brecht@loopring.org>


// Copyright 2017 Loopring Technology Limited.


abstract contract ERC1271 {
    // bytes4(keccak256("isValidSignature(bytes32,bytes)")
    bytes4 constant internal ERC1271_MAGICVALUE = 0x1626ba7e;

    function isValidSignature(
        bytes32      _hash,
        bytes memory _signature)
        public
        view
        virtual
        returns (bytes4 magicValueB32);

}

// Copyright 2017 Loopring Technology Limited.



/// @title Utility Functions for addresses
/// @author Daniel Wang - <daniel@loopring.org>
/// @author Brecht Devos - <brecht@loopring.org>


// Copyright 2017 Loopring Technology Limited.




// Copyright 2017 Loopring Technology Limited.









/// @title SignatureUtil
/// @author Daniel Wang - <daniel@loopring.org>
/// @dev This method supports multihash standard. Each signature's last byte indicates
///      the signature's type.


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







/// @title IExchangeV3
/// @dev Note that Claimable and RentrancyGuard are inherited here to
///      ensure all data members are declared on IExchangeV3 to make it
///      easy to support upgradability through proxies.
///
///      Subclasses of this contract must NOT define constructor to
///      initialize data.
///
/// @author Brecht Devos - <brecht@loopring.org>
/// @author Daniel Wang  - <daniel@loopring.org>
abstract contract IExchangeV3 is Claimable
{
    // -- Events --

    event ExchangeCloned(
        address exchangeAddress,
        address owner,
        bytes32 genesisMerkleRoot
    );

    event TokenRegistered(
        address token,
        uint16  tokenId
    );

    event Shutdown(
        uint timestamp
    );

    event WithdrawalModeActivated(
        uint timestamp
    );

    event BlockSubmitted(
        uint    indexed blockIdx,
        bytes32         merkleRoot,
        bytes32         publicDataHash
    );

    event DepositRequested(
        address from,
        address to,
        address token,
        uint16  tokenId,
        uint96  amount
    );

    event ForcedWithdrawalRequested(
        address owner,
        address token,
        uint32  accountID
    );

    event WithdrawalCompleted(
        uint8   category,
        address from,
        address to,
        address token,
        uint    amount
    );

    event WithdrawalFailed(
        uint8   category,
        address from,
        address to,
        address token,
        uint    amount
    );

    event ProtocolFeesUpdated(
        uint8 takerFeeBips,
        uint8 makerFeeBips,
        uint8 previousTakerFeeBips,
        uint8 previousMakerFeeBips
    );

    event TransactionApproved(
        address owner,
        bytes32 transactionHash
    );

    // events from libraries
    /*event DepositProcessed(
        address to,
        uint32  toAccountId,
        uint16  token,
        uint    amount
    );*/

    /*event ForcedWithdrawalProcessed(
        uint32 fromAccountID,
        uint16 tokenID,
        uint   amount
    );*/

    /*event ConditionalTransferProcessed(
        address from,
        address to,
        uint16  token,
        uint    amount
    );*/

    /*event AccountUpdated(
        uint32 owner,
        uint   publicKey
    );*/


    // -- Initialization --
    /// @dev Initializes this exchange. This method can only be called once.
    /// @param  loopring The LoopringV3 contract address.
    /// @param  owner The owner of this exchange.
    /// @param  genesisMerkleRoot The initial Merkle tree state.
    function initialize(
        address loopring,
        address owner,
        bytes32 genesisMerkleRoot
        )
        virtual
        external;

    /// @dev Initialized the agent registry contract used by the exchange.
    ///      Can only be called by the exchange owner once.
    /// @param agentRegistry The agent registry contract to be used
    function setAgentRegistry(address agentRegistry)
        external
        virtual;

    /// @dev Gets the agent registry contract used by the exchange.
    /// @return the agent registry contract
    function getAgentRegistry()
        external
        virtual
        view
        returns (IAgentRegistry);

    ///      Can only be called by the exchange owner once.
    /// @param depositContract The deposit contract to be used
    function setDepositContract(address depositContract)
        external
        virtual;

    /// @dev Gets the deposit contract used by the exchange.
    /// @return the deposit contract
    function getDepositContract()
        external
        virtual
        view
        returns (IDepositContract);

    // @dev Exchange owner withdraws fees from the exchange.
    // @param token Fee token address
    // @param feeRecipient Fee recipient address
    function withdrawExchangeFees(
        address token,
        address feeRecipient
        )
        external
        virtual;

    // -- Constants --
    /// @dev Returns a list of constants used by the exchange.
    /// @return constants The list of constants.
    function getConstants()
        external
        virtual
        pure
        returns(ExchangeData.Constants memory);

    // -- Mode --
    /// @dev Returns hether the exchange is in withdrawal mode.
    /// @return Returns true if the exchange is in withdrawal mode, else false.
    function isInWithdrawalMode()
        external
        virtual
        view
        returns (bool);

    /// @dev Returns whether the exchange is shutdown.
    /// @return Returns true if the exchange is shutdown, else false.
    function isShutdown()
        external
        virtual
        view
        returns (bool);

    // -- Tokens --
    /// @dev Registers an ERC20 token for a token id. Note that different exchanges may have
    ///      different ids for the same ERC20 token.
    ///
    ///      Please note that 1 is reserved for Ether (ETH), 2 is reserved for Wrapped Ether (ETH),
    ///      and 3 is reserved for Loopring Token (LRC).
    ///
    ///      This function is only callable by the exchange owner.
    ///
    /// @param  tokenAddress The token's address
    /// @return tokenID The token's ID in this exchanges.
    function registerToken(
        address tokenAddress
        )
        external
        virtual
        returns (uint16 tokenID);

    /// @dev Returns the id of a registered token.
    /// @param  tokenAddress The token's address
    /// @return tokenID The token's ID in this exchanges.
    function getTokenID(
        address tokenAddress
        )
        external
        virtual
        view
        returns (uint16 tokenID);

    /// @dev Returns the address of a registered token.
    /// @param  tokenID The token's ID in this exchanges.
    /// @return tokenAddress The token's address
    function getTokenAddress(
        uint16 tokenID
        )
        external
        virtual
        view
        returns (address tokenAddress);

    // -- Stakes --
    /// @dev Gets the amount of LRC the owner has staked onchain for this exchange.
    ///      The stake will be burned if the exchange does not fulfill its duty by
    ///      processing user requests in time. Please note that order matching may potentially
    ///      performed by another party and is not part of the exchange's duty.
    ///
    /// @return The amount of LRC staked
    function getExchangeStake()
        external
        virtual
        view
        returns (uint);

    /// @dev Withdraws the amount staked for this exchange.
    ///      This can only be done if the exchange has been correctly shutdown:
    ///      - The exchange owner has shutdown the exchange
    ///      - All deposit requests are processed
    ///      - All funds are returned to the users (merkle root is reset to initial state)
    ///
    ///      Can only be called by the exchange owner.
    ///
    /// @return amountLRC The amount of LRC withdrawn
    function withdrawExchangeStake(
        address recipient
        )
        external
        virtual
        returns (uint amountLRC);

    /// @dev Can by called by anyone to burn the stake of the exchange when certain
    ///      conditions are fulfilled.
    ///
    ///      Currently this will only burn the stake of the exchange if
    ///      the exchange is in withdrawal mode.
    function burnExchangeStake()
        external
        virtual;

    // -- Blocks --

    /// @dev Gets the current Merkle root of this exchange's virtual blockchain.
    /// @return The current Merkle root.
    function getMerkleRoot()
        external
        virtual
        view
        returns (bytes32);

    /// @dev Gets the height of this exchange's virtual blockchain. The block height for a
    ///      new exchange is 1.
    /// @return The virtual blockchain height which is the index of the last block.
    function getBlockHeight()
        external
        virtual
        view
        returns (uint);

    /// @dev Gets some minimal info of a previously submitted block that's kept onchain.
    ///      A DEX can use this function to implement a payment receipt verification
    ///      contract with a challange-response scheme.
    /// @param blockIdx The block index.
    function getBlockInfo(uint blockIdx)
        external
        virtual
        view
        returns (ExchangeData.BlockInfo memory);

    /// @dev Sumbits new blocks to the rollup blockchain.
    ///
    ///      This function can only be called by the exchange operator.
    ///
    /// @param blocks The blocks being submitted
    ///      - blockType: The type of the new block
    ///      - blockSize: The number of onchain or offchain requests/settlements
    ///        that have been processed in this block
    ///      - blockVersion: The circuit version to use for verifying the block
    ///      - storeBlockInfoOnchain: If the block info for this block needs to be stored on-chain
    ///      - data: The data for this block
    ///      - offchainData: Arbitrary data, mainly for off-chain data-availability, i.e.,
    ///        the multihash of the IPFS file that contains the block data.
    function submitBlocks(ExchangeData.Block[] calldata blocks)
        external
        virtual;

    /// @dev Gets the number of available forced request slots.
    /// @return The number of available slots.
    function getNumAvailableForcedSlots()
        external
        virtual
        view
        returns (uint);

    // -- Deposits --

    /// @dev Deposits Ether or ERC20 tokens to the specified account.
    ///
    ///      This function is only callable by an agent of 'from'.
    ///
    ///      A fee to the owner is paid in ETH to process the deposit.
    ///      The operator is not forced to do the deposit and the user can send
    ///      any fee amount.
    ///
    /// @param from The address that deposits the funds to the exchange
    /// @param to The account owner's address receiving the funds
    /// @param tokenAddress The address of the token, use `0x0` for Ether.
    /// @param amount The amount of tokens to deposit
    /// @param auxiliaryData Optional extra data used by the deposit contract
    function deposit(
        address from,
        address to,
        address tokenAddress,
        uint96  amount,
        bytes   calldata auxiliaryData
        )
        external
        virtual
        payable;

    /// @dev Gets the amount of tokens that may be added to the owner's account.
    /// @param owner The destination address for the amount deposited.
    /// @param tokenAddress The address of the token, use `0x0` for Ether.
    /// @return The amount of tokens pending.
    function getPendingDepositAmount(
        address owner,
        address tokenAddress
        )
        external
        virtual
        view
        returns (uint96);

    // -- Withdrawals --
    /// @dev Submits an onchain request to force withdraw Ether or ERC20 tokens.
    ///      This request always withdraws the full balance.
    ///
    ///      This function is only callable by an agent of the account.
    ///
    ///      The total fee in ETH that the user needs to pay is 'withdrawalFee'.
    ///      If the user sends too much ETH the surplus is sent back immediately.
    ///
    ///      Note that after such an operation, it will take the owner some
    ///      time (no more than MAX_AGE_FORCED_REQUEST_UNTIL_WITHDRAW_MODE) to process the request
    ///      and create the deposit to the offchain account.
    ///
    /// @param owner The expected owner of the account
    /// @param tokenAddress The address of the token, use `0x0` for Ether.
    /// @param accountID The address the account in the Merkle tree.
    function forceWithdraw(
        address owner,
        address tokenAddress,
        uint32  accountID
        )
        external
        virtual
        payable;

    /// @dev Checks if a forced withdrawal is pending for an account balance.
    /// @param  accountID The accountID of the account to check.
    /// @param  token The token address
    /// @return True if a request is pending, false otherwise
    function isForcedWithdrawalPending(
        uint32  accountID,
        address token
        )
        external
        virtual
        view
        returns (bool);

    /// @dev Submits an onchain request to withdraw Ether or ERC20 tokens from the
    ///      protocol fees account. The complete balance is always withdrawn.
    ///
    ///      Anyone can request a withdrawal of the protocol fees.
    ///
    ///      Note that after such an operation, it will take the owner some
    ///      time (no more than MAX_AGE_FORCED_REQUEST_UNTIL_WITHDRAW_MODE) to process the request
    ///      and create the deposit to the offchain account.
    ///
    /// @param tokenAddress The address of the token, use `0x0` for Ether.
    function withdrawProtocolFees(
        address tokenAddress
        )
        external
        virtual
        payable;

    /// @dev Gets the time the protocol fee for a token was last withdrawn.
    /// @param tokenAddress The address of the token, use `0x0` for Ether.
    /// @return The time the protocol fee was last withdrawn.
    function getProtocolFeeLastWithdrawnTime(
        address tokenAddress
        )
        external
        virtual
        view
        returns (uint);

    /// @dev Allows anyone to withdraw funds for a specified user using the balances stored
    ///      in the Merkle tree. The funds will be sent to the owner of the acount.
    ///
    ///      Can only be used in withdrawal mode (i.e. when the owner has stopped
    ///      committing blocks and is not able to commit any more blocks).
    ///
    ///      This will NOT modify the onchain merkle root! The merkle root stored
    ///      onchain will remain the same after the withdrawal. We store if the user
    ///      has withdrawn the balance in State.withdrawnInWithdrawMode.
    ///
    /// @param  merkleProof The Merkle inclusion proof
    function withdrawFromMerkleTree(
        ExchangeData.MerkleProof calldata merkleProof
        )
        external
        virtual;

    /// @dev Checks if the balance for the account was withdrawn with `withdrawFromMerkleTree`.
    /// @param  accountID The accountID of the balance to check.
    /// @param  token The token address
    /// @return True if it was already withdrawn, false otherwise
    function isWithdrawnInWithdrawalMode(
        uint32  accountID,
        address token
        )
        external
        virtual
        view
        returns (bool);

    /// @dev Allows withdrawing funds deposited to the contract in a deposit request when
    ///      it was never processed by the owner within the maximum time allowed.
    ///
    ///      Can be called by anyone. The deposited tokens will be sent back to
    ///      the owner of the account they were deposited in.
    ///
    /// @param  owner The address of the account the withdrawal was done for.
    /// @param  token The token address
    function withdrawFromDepositRequest(
        address owner,
        address token
        )
        external
        virtual;

    /// @dev Allows withdrawing funds after a withdrawal request (either onchain
    ///      or offchain) was submitted in a block by the operator.
    ///
    ///      Can be called by anyone. The withdrawn tokens will be sent to
    ///      the owner of the account they were withdrawn out.
    ///
    ///      Normally it is should not be needed for users to call this manually.
    ///      Funds from withdrawal requests will be sent to the account owner
    ///      immediately by the owner when the block is submitted.
    ///      The user will however need to call this manually if the transfer failed.
    ///
    ///      Tokens and owners must have the same size.
    ///
    /// @param  owners The addresses of the account the withdrawal was done for.
    /// @param  tokens The token addresses
    function withdrawFromApprovedWithdrawals(
        address[] calldata owners,
        address[] calldata tokens
        )
        external
        virtual;

    /// @dev Gets the amount that can be withdrawn immediately with `withdrawFromApprovedWithdrawals`.
    /// @param  owner The address of the account the withdrawal was done for.
    /// @param  token The token address
    /// @return The amount withdrawable
    function getAmountWithdrawable(
        address owner,
        address token
        )
        external
        virtual
        view
        returns (uint);

    /// @dev Notifies the exchange that the owner did not process a forced request.
    ///      If this is indeed the case, the exchange will enter withdrawal mode.
    ///
    ///      Can be called by anyone.
    ///
    /// @param  accountID The accountID the forced request was made for
    /// @param  token The token address of the the forced request
    function notifyForcedRequestTooOld(
        uint32  accountID,
        address token
        )
        external
        virtual;

    /// @dev Allows a withdrawal to be done to an adddresss that is different
    ///      than initialy specified in the withdrawal request. This can be used to
    ///      implement functionality like fast withdrawals.
    ///
    ///      This function can only be called by an agent.
    ///
    /// @param from The address of the account that does the withdrawal.
    /// @param to The address to which 'amount' tokens were going to be withdrawn.
    /// @param token The address of the token that is withdrawn ('0x0' for ETH).
    /// @param amount The amount of tokens that are going to be withdrawn.
    /// @param storageID The storageID of the withdrawal request.
    /// @param newRecipient The new recipient address of the withdrawal.
    function setWithdrawalRecipient(
        address from,
        address to,
        address token,
        uint96  amount,
        uint32  storageID,
        address newRecipient
        )
        external
        virtual;

    /// @dev Gets the withdrawal recipient.
    ///
    /// @param from The address of the account that does the withdrawal.
    /// @param to The address to which 'amount' tokens were going to be withdrawn.
    /// @param token The address of the token that is withdrawn ('0x0' for ETH).
    /// @param amount The amount of tokens that are going to be withdrawn.
    /// @param storageID The storageID of the withdrawal request.
    function getWithdrawalRecipient(
        address from,
        address to,
        address token,
        uint96  amount,
        uint32  storageID
        )
        external
        virtual
        view
        returns (address);

    /// @dev Allows an agent to transfer ERC-20 tokens for a user using the allowance
    ///      the user has set for the exchange. This way the user only needs to approve a single exchange contract
    ///      for all exchange/agent features, which allows for a more seamless user experience.
    ///
    ///      This function can only be called by an agent.
    ///
    /// @param from The address of the account that sends the tokens.
    /// @param to The address to which 'amount' tokens are transferred.
    /// @param token The address of the token to transfer (ETH is and cannot be suppported).
    /// @param amount The amount of tokens transferred.
    function onchainTransferFrom(
        address from,
        address to,
        address token,
        uint    amount
        )
        external
        virtual;

    /// @dev Allows an agent to approve a rollup tx.
    ///
    ///      This function can only be called by an agent.
    ///
    /// @param owner The owner of the account
    /// @param txHash The hash of the transaction
    function approveTransaction(
        address owner,
        bytes32 txHash
        )
        external
        virtual;

    /// @dev Allows an agent to approve multiple rollup txs.
    ///
    ///      This function can only be called by an agent.
    ///
    /// @param owners The account owners
    /// @param txHashes The hashes of the transactions
    function approveTransactions(
        address[] calldata owners,
        bytes32[] calldata txHashes
        )
        external
        virtual;

    /// @dev Checks if a rollup tx is approved using the tx's hash.
    ///
    /// @param owner The owner of the account that needs to authorize the tx
    /// @param txHash The hash of the transaction
    /// @return True if the tx is approved, else false
    function isTransactionApproved(
        address owner,
        bytes32 txHash
        )
        external
        virtual
        view
        returns (bool);

    // -- Admins --
    /// @dev Sets the max time deposits have to wait before becoming withdrawable.
    /// @param newValue The new value.
    /// @return  The old value.
    function setMaxAgeDepositUntilWithdrawable(
        uint32 newValue
        )
        external
        virtual
        returns (uint32);

    /// @dev Returns the max time deposits have to wait before becoming withdrawable.
    /// @return The value.
    function getMaxAgeDepositUntilWithdrawable()
        external
        virtual
        view
        returns (uint32);

    /// @dev Shuts down the exchange.
    ///      Once the exchange is shutdown all onchain requests are permanently disabled.
    ///      When all requirements are fulfilled the exchange owner can withdraw
    ///      the exchange stake with withdrawStake.
    ///
    ///      Note that the exchange can still enter the withdrawal mode after this function
    ///      has been invoked successfully. To prevent entering the withdrawal mode before the
    ///      the echange stake can be withdrawn, all withdrawal requests still need to be handled
    ///      for at least MIN_TIME_IN_SHUTDOWN seconds.
    ///
    ///      Can only be called by the exchange owner.
    ///
    /// @return success True if the exchange is shutdown, else False
    function shutdown()
        external
        virtual
        returns (bool success);

    /// @dev Gets the protocol fees for this exchange.
    /// @return syncedAt The timestamp the protocol fees were last updated
    /// @return takerFeeBips The protocol taker fee
    /// @return makerFeeBips The protocol maker fee
    /// @return previousTakerFeeBips The previous protocol taker fee
    /// @return previousMakerFeeBips The previous protocol maker fee
    function getProtocolFeeValues()
        external
        virtual
        view
        returns (
            uint32 syncedAt,
            uint8 takerFeeBips,
            uint8 makerFeeBips,
            uint8 previousTakerFeeBips,
            uint8 previousMakerFeeBips
        );

    /// @dev Gets the domain separator used in this exchange.
    function getDomainSeparator()
        external
        virtual
        view
        returns (bytes32);
}

// Copyright 2017 Loopring Technology Limited.








/// @title AmmData


// Copyright 2017 Loopring Technology Limited.









/// @title AmmPoolToken


// Copyright 2017 Loopring Technology Limited.








// Copyright 2017 Loopring Technology Limited.














/// @title AmmStatus



// Copyright 2017 Loopring Technology Limited.




// Copyright 2017 Loopring Technology Limited.





// Copyright 2017 Loopring Technology Limited.




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



/// @title Utility Functions for floats
/// @author Brecht Devos - <brecht@loopring.org>






// Copyright 2017 Loopring Technology Limited.







/// @title ExchangeSignatures.
/// @dev All methods in this lib are internal, therefore, there is no need
///      to deploy this library independently.
/// @author Brecht Devos - <brecht@loopring.org>
/// @author Daniel Wang  - <daniel@loopring.org>




/// @title TransferTransaction
/// @author Brecht Devos - <brecht@loopring.org>




// Copyright 2017 Loopring Technology Limited.



/// @title ERC20 safe transfer
/// @dev see https://github.com/sec-bit/badERC20Fix
/// @author Brecht Devos - <brecht@loopring.org>





/// @title AmmUtil




/// @title AmmWithdrawal
