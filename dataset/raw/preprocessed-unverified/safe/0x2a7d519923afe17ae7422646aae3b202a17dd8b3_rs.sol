/**
 *Submitted for verification at Etherscan.io on 2019-09-10
*/

/*

    Copyright 2019 dYdX Trading Inc.

    Licensed under the Apache License, Version 2.0 (the "License");
    you may not use this file except in compliance with the License.
    You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

    Unless required by applicable law or agreed to in writing, software
    distributed under the License is distributed on an "AS IS" BASIS,
    WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
    See the License for the specific language governing permissions and
    limitations under the License.

*/

pragma solidity 0.5.7;
pragma experimental ABIEncoderV2;

// File: openzeppelin-solidity/contracts/math/SafeMath.sol

/**
 * @title SafeMath
 * @dev Unsigned math operations with safety checks that revert on error
 */


// File: openzeppelin-solidity/contracts/ownership/Ownable.sol

/**
 * @title Ownable
 * @dev The Ownable contract has an owner address, and provides basic authorization control
 * functions, this simplifies the implementation of "user permissions".
 */


// File: contracts/protocol/lib/Require.sol

/**
 * @title Require
 * @author dYdX
 *
 * Stringifies parameters to pretty-print revert messages. Costs more gas than regular require()
 */


// File: contracts/protocol/lib/Math.sol

/**
 * @title Math
 * @author dYdX
 *
 * Library for non-standard Math functions
 */


// File: contracts/protocol/lib/Types.sol

/**
 * @title Types
 * @author dYdX
 *
 * Library for interacting with the basic structs used in Solo
 */


// File: contracts/protocol/lib/Account.sol

/**
 * @title Account
 * @author dYdX
 *
 * Library of structs and functions that represent an account
 */


// File: contracts/protocol/lib/Actions.sol

/**
 * @title Actions
 * @author dYdX
 *
 * Library that defines and parses valid Actions
 */


// File: contracts/protocol/SoloMargin.sol


/**
 * @title SoloMargin
 * @author dYdX
 *
 * Main contract that inherits from other contracts
 */
contract SoloMargin {
    // ============ Public Functions ============

    /**
     * The main entry-point to Solo that allows users and contracts to manage accounts.
     * Take one or more actions on one or more accounts. The msg.sender must be the owner or
     * operator of all accounts except for those being liquidated, vaporized, or traded with.
     * One call to operate() is considered a singular "operation". Account collateralization is
     * ensured only after the completion of the entire operation.
     *
     * @param  accounts  A list of all accounts that will be used in this operation. Cannot contain
     *                   duplicates. In each action, the relevant account will be referred-to by its
     *                   index in the list.
     * @param  actions   An ordered list of all actions that will be taken in this operation. The
     *                   actions will be processed in order.
     */
    function operate(
        Account.Info[] memory accounts,
        Actions.ActionArgs[] memory actions
    )
        public;

    // ============ Getters for Permissions ============

    /**
     * Return true if a particular address is approved as an operator for an owner's accounts.
     * Approved operators can act on the accounts of the owner as if it were the operator's own.
     *
     * @param  owner     The owner of the accounts
     * @param  operator  The possible operator
     * @return           True if operator is approved for owner's accounts
     */
    function getIsLocalOperator(
        address owner,
        address operator
    )
        public
        view
        returns (bool);

    /* ... */
}

// File: contracts/external/helpers/OnlySolo.sol

/**
 * @title OnlySolo
 * @author dYdX
 *
 * Inheritable contract that restricts the calling of certain functions to Solo only
 */
contract OnlySolo {

    // ============ Constants ============

    bytes32 constant FILE = "OnlySolo";

    // ============ Storage ============

    SoloMargin public SOLO_MARGIN;

    // ============ Constructor ============

    constructor (
        address soloMargin
    )
        public
    {
        SOLO_MARGIN = SoloMargin(soloMargin);
    }

    // ============ Modifiers ============

    modifier onlySolo(address from) {
        Require.that(
            from == address(SOLO_MARGIN),
            FILE,
            "Only Solo can call function",
            from
        );
        _;
    }
}

// File: contracts/external/lib/TypedSignature.sol

/**
 * @title TypedSignature
 * @author dYdX
 *
 * Library to unparse typed signatures
 */


// File: contracts/external/proxies/SignedOperationProxy.sol

/**
 * @title SignedOperationProxy
 * @author dYdX
 *
 * Contract for sending operations on behalf of others
 */
contract SignedOperationProxy is
    OnlySolo,
    Ownable
{
    using SafeMath for uint256;

    // ============ Constants ============

    bytes32 constant private FILE = "SignedOperationProxy";

    // EIP191 header for EIP712 prefix
    bytes2 constant private EIP191_HEADER = 0x1901;

    // EIP712 Domain Name value
    string constant private EIP712_DOMAIN_NAME = "SignedOperationProxy";

    // EIP712 Domain Version value
    string constant private EIP712_DOMAIN_VERSION = "1.1";

    // EIP712 encodeType of EIP712Domain
    bytes constant private EIP712_DOMAIN_STRING = abi.encodePacked(
        "EIP712Domain(",
        "string name,",
        "string version,",
        "uint256 chainId,",
        "address verifyingContract",
        ")"
    );

    // EIP712 encodeType of Operation
    bytes constant private EIP712_OPERATION_STRING = abi.encodePacked(
        "Operation(",
        "Action[] actions,",
        "uint256 expiration,",
        "uint256 salt,",
        "address sender,",
        "address signer",
        ")"
    );

    // EIP712 encodeType of Action
    bytes constant private EIP712_ACTION_STRING = abi.encodePacked(
        "Action(",
        "uint8 actionType,",
        "address accountOwner,",
        "uint256 accountNumber,",
        "AssetAmount assetAmount,",
        "uint256 primaryMarketId,",
        "uint256 secondaryMarketId,",
        "address otherAddress,",
        "address otherAccountOwner,",
        "uint256 otherAccountNumber,",
        "bytes data",
        ")"
    );

    // EIP712 encodeType of AssetAmount
    bytes constant private EIP712_ASSET_AMOUNT_STRING = abi.encodePacked(
        "AssetAmount(",
        "bool sign,",
        "uint8 denomination,",
        "uint8 ref,",
        "uint256 value",
        ")"
    );

    // EIP712 typeHash of EIP712Domain
    /* solium-disable-next-line indentation */
    bytes32 constant private EIP712_DOMAIN_SEPARATOR_SCHEMA_HASH = keccak256(abi.encodePacked(
        EIP712_DOMAIN_STRING
    ));

    // EIP712 typeHash of Operation
    /* solium-disable-next-line indentation */
    bytes32 constant private EIP712_OPERATION_HASH = keccak256(abi.encodePacked(
        EIP712_OPERATION_STRING,
        EIP712_ACTION_STRING,
        EIP712_ASSET_AMOUNT_STRING
    ));

    // EIP712 typeHash of Action
    /* solium-disable-next-line indentation */
    bytes32 constant private EIP712_ACTION_HASH = keccak256(abi.encodePacked(
        EIP712_ACTION_STRING,
        EIP712_ASSET_AMOUNT_STRING
    ));

    // EIP712 typeHash of AssetAmount
    /* solium-disable-next-line indentation */
    bytes32 constant private EIP712_ASSET_AMOUNT_HASH = keccak256(abi.encodePacked(
        EIP712_ASSET_AMOUNT_STRING
    ));

    // ============ Structs ============

    struct OperationHeader {
        uint256 expiration;
        uint256 salt;
        address sender;
        address signer;
    }

    struct Authorization {
        uint256 numActions;
        OperationHeader header;
        bytes signature;
    }

    // ============ Events ============

    event ContractStatusSet(
        bool operational
    );

    event LogOperationExecuted(
        bytes32 indexed operationHash,
        address indexed signer,
        address indexed sender
    );

    event LogOperationCanceled(
        bytes32 indexed operationHash,
        address indexed canceler
    );

    // ============ Immutable Storage ============

    // Hash of the EIP712 Domain Separator data
    bytes32 public EIP712_DOMAIN_HASH;

    // ============ Mutable Storage ============

     // true if this contract can process operationss
    bool public g_isOperational;

    // operation hash => was executed (or canceled)
    mapping (bytes32 => bool) public g_invalidated;

    // ============ Constructor ============

    constructor (
        address soloMargin,
        uint256 chainId
    )
        public
        OnlySolo(soloMargin)
    {
        g_isOperational = true;

        /* solium-disable-next-line indentation */
        EIP712_DOMAIN_HASH = keccak256(abi.encode(
            EIP712_DOMAIN_SEPARATOR_SCHEMA_HASH,
            keccak256(bytes(EIP712_DOMAIN_NAME)),
            keccak256(bytes(EIP712_DOMAIN_VERSION)),
            chainId,
            address(this)
        ));
    }

    // ============ Admin Functions ============

     /**
     * The owner can shut down the exchange.
     */
    function shutDown()
        external
        onlyOwner
    {
        g_isOperational = false;
        emit ContractStatusSet(false);
    }

     /**
     * The owner can start back up the exchange.
     */
    function startUp()
        external
        onlyOwner
    {
        g_isOperational = true;
        emit ContractStatusSet(true);
    }

    // ============ Public Functions ============

    /**
     * Allows a signer to permanently cancel an operation on-chain.
     *
     * @param  accounts  The accounts involved in the operation
     * @param  actions   The actions involved in the operation
     * @param  auth      The unsigned authorization of the operation
     */
    function cancel(
        Account.Info[] memory accounts,
        Actions.ActionArgs[] memory actions,
        Authorization memory auth
    )
        public
    {
        bytes32 operationHash = getOperationHash(
            accounts,
            actions,
            auth,
            0
        );
        Require.that(
            auth.header.signer == msg.sender,
            FILE,
            "Canceler must be signer"
        );
        g_invalidated[operationHash] = true;
        emit LogOperationCanceled(operationHash, msg.sender);
    }

    /**
     * Submits an operation to SoloMargin. Actions for accounts that the msg.sender does not control
     * must be authorized by a signed message. Each authorization can apply to multiple actions at
     * once which must occur in-order next to each other. An empty authorization must be supplied
     * explicitly for each group of actions that do not require a signed message.
     *
     * @param  accounts  The accounts to forward to SoloMargin.operate()
     * @param  actions   The actions to forward to SoloMargin.operate()
     * @param  auths     The signed authorizations for each group of actions
     *                   (or unsigned if msg.sender is already authorized)
     */
    function operate(
        Account.Info[] memory accounts,
        Actions.ActionArgs[] memory actions,
        Authorization[] memory auths
    )
        public
    {
        Require.that(
            g_isOperational,
            FILE,
            "Contract is not operational"
        );

        // cache the index of the first action for this auth
        uint256 actionStartIdx = 0;

        // loop over all auths
        for (uint256 authIdx = 0; authIdx < auths.length; authIdx++) {
            Authorization memory auth = auths[authIdx];

            // require that the message is not expired
            Require.that(
                auth.header.expiration == 0 || auth.header.expiration >= block.timestamp,
                FILE,
                "Signed operation is expired",
                authIdx
            );

            // require that the sender matches the authorization
            Require.that(
                auth.header.sender == address(0) || auth.header.sender == msg.sender,
                FILE,
                "Operation sender mismatch",
                authIdx
            );

            // consider the signer to be null unless there is a signature
            address signer = address(0);

            // if there is a signature, then validate it
            if (auth.signature.length != 0) {
                // get the hash of the operation
                bytes32 operationHash = getOperationHash(
                    accounts,
                    actions,
                    auth,
                    actionStartIdx
                );

                // require that this message is still valid
                Require.that(
                    !g_invalidated[operationHash],
                    FILE,
                    "Hash already used or canceled",
                    operationHash
                );

                // get the signer
                signer = TypedSignature.recover(operationHash, auth.signature);

                // require that this signer matches the authorization
                Require.that(
                    auth.header.signer == signer,
                    FILE,
                    "Invalid signature"
                );

                // consider this operationHash to be used (and therefore no longer valid)
                g_invalidated[operationHash] = true;
                emit LogOperationExecuted(operationHash, signer, msg.sender);
            }

            // cache the index of the first action after this auth
            uint256 actionEndIdx = actionStartIdx.add(auth.numActions);

            // loop over all actions for which this auth applies
            for (uint256 actionIdx = actionStartIdx; actionIdx < actionEndIdx; actionIdx++) {
                // validate primary account
                Actions.ActionArgs memory action = actions[actionIdx];
                validateAccountOwner(accounts[action.accountId].owner, signer);

                // validate second account in the case of a transfer
                if (action.actionType == Actions.ActionType.Transfer) {
                    validateAccountOwner(accounts[action.otherAccountId].owner, signer);
                }
            }

            // update actionStartIdx
            actionStartIdx = actionEndIdx;
        }

        // require that all actions are signed or from msg.sender
        Require.that(
            actionStartIdx == actions.length,
            FILE,
            "Not all actions are signed"
        );

        // send the operation
        SOLO_MARGIN.operate(accounts, actions);
    }

    // ============ Getters ============

    /**
     * Returns a bool for each operation. True if the operation is invalid (from being canceled or
     * previously executed).
     */
    function getOperationsAreInvalid(
        bytes32[] memory operationHashes
    )
        public
        view
        returns(bool[] memory)
    {
        uint256 numOperations = operationHashes.length;
        bool[] memory output = new bool[](numOperations);

        for (uint256 i = 0; i < numOperations; i++) {
            output[i] = g_invalidated[operationHashes[i]];
        }
        return output;
    }

    // ============ Private Helper Functions ============

    /**
     * Validates that either the signer or the msg.sender are the accountOwner (or that either are
     * localOperators of the accountOwner).
     */
    function validateAccountOwner(
        address accountOwner,
        address signer
    )
        private
        view
    {
        bool valid =
            msg.sender == accountOwner
            || signer == accountOwner
            || SOLO_MARGIN.getIsLocalOperator(accountOwner, msg.sender)
            || SOLO_MARGIN.getIsLocalOperator(accountOwner, signer);

        Require.that(
            valid,
            FILE,
            "Signer not authorized",
            signer
        );
    }

    /**
     * Returns the EIP712 hash of an Operation message.
     */
    function getOperationHash(
        Account.Info[] memory accounts,
        Actions.ActionArgs[] memory actions,
        Authorization memory auth,
        uint256 startIdx
    )
        private
        view
        returns (bytes32)
    {
        // get the bytes32 hash of each action, then packed together
        bytes32 actionsEncoding = getActionsEncoding(
            accounts,
            actions,
            auth,
            startIdx
        );

        // compute the EIP712 hashStruct of an Operation struct
        /* solium-disable-next-line indentation */
        bytes32 structHash = keccak256(abi.encode(
            EIP712_OPERATION_HASH,
            actionsEncoding,
            auth.header
        ));

        // compute eip712 compliant hash
        /* solium-disable-next-line indentation */
        return keccak256(abi.encodePacked(
            EIP191_HEADER,
            EIP712_DOMAIN_HASH,
            structHash
        ));
    }

    /**
     * Returns the EIP712 encodeData of an Action struct array.
     */
    function getActionsEncoding(
        Account.Info[] memory accounts,
        Actions.ActionArgs[] memory actions,
        Authorization memory auth,
        uint256 startIdx
    )
        private
        pure
        returns (bytes32)
    {
        // store hash of each action
        bytes32[] memory actionsBytes = new bytes32[](auth.numActions);

        // for each action that corresponds to the auth
        for (uint256 i = 0; i < auth.numActions; i++) {
            Actions.ActionArgs memory action = actions[startIdx + i];

            // if action type has no second account, assume null account
            Account.Info memory otherAccount =
                (Actions.getAccountLayout(action.actionType) == Actions.AccountLayout.OnePrimary)
                ? Account.Info({ owner: address(0), number: 0 })
                : accounts[action.otherAccountId];

            // compute the individual hash for the action
            /* solium-disable-next-line indentation */
            actionsBytes[i] = getActionHash(
                action,
                accounts[action.accountId],
                otherAccount
            );
        }

        return keccak256(abi.encodePacked(actionsBytes));
    }

    /**
     * Returns the EIP712 hashStruct of an Action struct.
     */
    function getActionHash(
        Actions.ActionArgs memory action,
        Account.Info memory primaryAccount,
        Account.Info memory secondaryAccount
    )
        private
        pure
        returns (bytes32)
    {
        /* solium-disable-next-line indentation */
        return keccak256(abi.encode(
            EIP712_ACTION_HASH,
            action.actionType,
            primaryAccount.owner,
            primaryAccount.number,
            getAssetAmountHash(action.amount),
            action.primaryMarketId,
            action.secondaryMarketId,
            action.otherAddress,
            secondaryAccount.owner,
            secondaryAccount.number,
            keccak256(action.data)
        ));
    }

    /**
     * Returns the EIP712 hashStruct of an AssetAmount struct.
     */
    function getAssetAmountHash(
        Types.AssetAmount memory amount
    )
        private
        pure
        returns (bytes32)
    {
        /* solium-disable-next-line indentation */
        return keccak256(abi.encode(
            EIP712_ASSET_AMOUNT_HASH,
            amount.sign,
            amount.denomination,
            amount.ref,
            amount.value
        ));
    }
}