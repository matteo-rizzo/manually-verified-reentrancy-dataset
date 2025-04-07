/**
 *Submitted for verification at Etherscan.io on 2020-11-13
*/

// Dependency file: @openzeppelin/contracts/token/ERC20/IERC20.sol

// SPDX-License-Identifier: MIT

// pragma solidity ^0.6.0;

/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
 */



// Dependency file: @openzeppelin/contracts/introspection/IERC165.sol


// pragma solidity ^0.6.0;

/**
 * @dev Interface of the ERC165 standard, as defined in the
 * https://eips.ethereum.org/EIPS/eip-165[EIP].
 *
 * Implementers can declare support of contract interfaces, which can then be
 * queried by others ({ERC165Checker}).
 *
 * For an implementation, see {ERC165}.
 */



// Dependency file: @openzeppelin/contracts/token/ERC1155/IERC1155Receiver.sol


// pragma solidity ^0.6.0;

// import "@openzeppelin/contracts/introspection/IERC165.sol";

/**
 * _Available since v3.1._
 */
interface IERC1155Receiver is IERC165 {

    /**
        @dev Handles the receipt of a single ERC1155 token type. This function is
        called at the end of a `safeTransferFrom` after the balance has been updated.
        To accept the transfer, this must return
        `bytes4(keccak256("onERC1155Received(address,address,uint256,uint256,bytes)"))`
        (i.e. 0xf23a6e61, or its own function selector).
        @param operator The address which initiated the transfer (i.e. msg.sender)
        @param from The address which previously owned the token
        @param id The ID of the token being transferred
        @param value The amount of tokens being transferred
        @param data Additional data with no specified format
        @return `bytes4(keccak256("onERC1155Received(address,address,uint256,uint256,bytes)"))` if transfer is allowed
    */
    function onERC1155Received(
        address operator,
        address from,
        uint256 id,
        uint256 value,
        bytes calldata data
    )
        external
        returns(bytes4);

    /**
        @dev Handles the receipt of a multiple ERC1155 token types. This function
        is called at the end of a `safeBatchTransferFrom` after the balances have
        been updated. To accept the transfer(s), this must return
        `bytes4(keccak256("onERC1155BatchReceived(address,address,uint256[],uint256[],bytes)"))`
        (i.e. 0xbc197c81, or its own function selector).
        @param operator The address which initiated the batch transfer (i.e. msg.sender)
        @param from The address which previously owned the token
        @param ids An array containing ids of each token being transferred (order and length must match values array)
        @param values An array containing amounts of each token being transferred (order and length must match ids array)
        @param data Additional data with no specified format
        @return `bytes4(keccak256("onERC1155BatchReceived(address,address,uint256[],uint256[],bytes)"))` if transfer is allowed
    */
    function onERC1155BatchReceived(
        address operator,
        address from,
        uint256[] calldata ids,
        uint256[] calldata values,
        bytes calldata data
    )
        external
        returns(bytes4);
}


// Dependency file: @openzeppelin/contracts/introspection/ERC165.sol


// pragma solidity ^0.6.0;

// import "@openzeppelin/contracts/introspection/IERC165.sol";

/**
 * @dev Implementation of the {IERC165} interface.
 *
 * Contracts may inherit from this and call {_registerInterface} to declare
 * their support of an interface.
 */
contract ERC165 is IERC165 {
    /*
     * bytes4(keccak256('supportsInterface(bytes4)')) == 0x01ffc9a7
     */
    bytes4 private constant _INTERFACE_ID_ERC165 = 0x01ffc9a7;

    /**
     * @dev Mapping of interface ids to whether or not it's supported.
     */
    mapping(bytes4 => bool) private _supportedInterfaces;

    constructor () internal {
        // Derived contracts need only register support for their own interfaces,
        // we register support for ERC165 itself here
        _registerInterface(_INTERFACE_ID_ERC165);
    }

    /**
     * @dev See {IERC165-supportsInterface}.
     *
     * Time complexity O(1), guaranteed to always use less than 30 000 gas.
     */
    function supportsInterface(bytes4 interfaceId) public view override returns (bool) {
        return _supportedInterfaces[interfaceId];
    }

    /**
     * @dev Registers the contract as an implementer of the interface defined by
     * `interfaceId`. Support of the actual ERC165 interface is automatic and
     * registering its interface id is not required.
     *
     * See {IERC165-supportsInterface}.
     *
     * Requirements:
     *
     * - `interfaceId` cannot be the ERC165 invalid interface (`0xffffffff`).
     */
    function _registerInterface(bytes4 interfaceId) internal virtual {
        require(interfaceId != 0xffffffff, "ERC165: invalid interface id");
        _supportedInterfaces[interfaceId] = true;
    }
}


// Dependency file: @openzeppelin/contracts/token/ERC1155/ERC1155Receiver.sol


// pragma solidity ^0.6.0;

// import "@openzeppelin/contracts/token/ERC1155/IERC1155Receiver.sol";
// import "@openzeppelin/contracts/introspection/ERC165.sol";

/**
 * @dev _Available since v3.1._
 */
abstract contract ERC1155Receiver is ERC165, IERC1155Receiver {
    constructor() public {
        _registerInterface(
            ERC1155Receiver(0).onERC1155Received.selector ^
            ERC1155Receiver(0).onERC1155BatchReceived.selector
        );
    }
}


// Dependency file: @openzeppelin/contracts/math/SafeMath.sol


// pragma solidity ^0.6.0;

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



// Dependency file: @openzeppelin/contracts/utils/Address.sol


// pragma solidity ^0.6.2;

/**
 * @dev Collection of functions related to the address type
 */



// Dependency file: @openzeppelin/contracts/token/ERC20/SafeERC20.sol


// pragma solidity ^0.6.0;

// import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
// import "@openzeppelin/contracts/math/SafeMath.sol";
// import "@openzeppelin/contracts/utils/Address.sol";

/**
 * @title SafeERC20
 * @dev Wrappers around ERC20 operations that throw on failure (when the token
 * contract returns false). Tokens that return no value (and instead revert or
 * throw on failure) are also supported, non-reverting calls are assumed to be
 * successful.
 * To use this library you can add a `using SafeERC20 for IERC20;` statement to your contract,
 * which allows you to call the safe operations as `token.safeTransfer(...)`, etc.
 */



// Dependency file: @openzeppelin/contracts/utils/EnumerableMap.sol


// pragma solidity ^0.6.0;

/**
 * @dev Library for managing an enumerable variant of Solidity's
 * https://solidity.readthedocs.io/en/latest/types.html#mapping-types[`mapping`]
 * type.
 *
 * Maps have the following properties:
 *
 * - Entries are added, removed, and checked for existence in constant time
 * (O(1)).
 * - Entries are enumerated in O(n). No guarantees are made on the ordering.
 *
 * ```
 * contract Example {
 *     // Add the library methods
 *     using EnumerableMap for EnumerableMap.UintToAddressMap;
 *
 *     // Declare a set state variable
 *     EnumerableMap.UintToAddressMap private myMap;
 * }
 * ```
 *
 * As of v3.0.0, only maps of type `uint256 -> address` (`UintToAddressMap`) are
 * supported.
 */



// Dependency file: @openzeppelin/contracts/utils/ReentrancyGuard.sol


// pragma solidity ^0.6.0;

/**
 * @dev Contract module that helps prevent reentrant calls to a function.
 *
 * Inheriting from `ReentrancyGuard` will make the {nonReentrant} modifier
 * available, which can be applied to functions to make sure there are no nested
 * (reentrant) calls to them.
 *
 * Note that because there is a single `nonReentrant` guard, functions marked as
 * `nonReentrant` may not call one another. This can be worked around by making
 * those functions `private`, and then adding `external` `nonReentrant` entry
 * points to them.
 *
 * TIP: If you would like to learn more about reentrancy and alternative ways
 * to protect against it, check out our blog post
 * https://blog.openzeppelin.com/reentrancy-after-istanbul/[Reentrancy After Istanbul].
 */
contract ReentrancyGuard {
    // Booleans are more expensive than uint256 or any type that takes up a full
    // word because each write operation emits an extra SLOAD to first read the
    // slot's contents, replace the bits taken up by the boolean, and then write
    // back. This is the compiler's defense against contract upgrades and
    // pointer aliasing, and it cannot be disabled.

    // The values being non-zero value makes deployment a bit more expensive,
    // but in exchange the refund on every call to nonReentrant will be lower in
    // amount. Since refunds are capped to a percentage of the total
    // transaction's gas, it is best to keep them low in cases like this one, to
    // increase the likelihood of the full refund coming into effect.
    uint256 private constant _NOT_ENTERED = 1;
    uint256 private constant _ENTERED = 2;

    uint256 private _status;

    constructor () internal {
        _status = _NOT_ENTERED;
    }

    /**
     * @dev Prevents a contract from calling itself, directly or indirectly.
     * Calling a `nonReentrant` function from another `nonReentrant`
     * function is not supported. It is possible to prevent this from happening
     * by making the `nonReentrant` function external, and make it call a
     * `private` function that does the actual work.
     */
    modifier nonReentrant() {
        // On the first call to nonReentrant, _notEntered will be true
        require(_status != _ENTERED, "ReentrancyGuard: reentrant call");

        // Any calls to nonReentrant after this point will fail
        _status = _ENTERED;

        _;

        // By storing the original value once again, a refund is triggered (see
        // https://eips.ethereum.org/EIPS/eip-2200)
        _status = _NOT_ENTERED;
    }
}


// Dependency file: @openzeppelin/contracts/math/Math.sol


// pragma solidity ^0.6.0;

/**
 * @dev Standard math utilities missing in the Solidity language.
 */



// Dependency file: @openzeppelin/contracts/GSN/Context.sol


// pragma solidity ^0.6.0;

/*
 * @dev Provides information about the current execution context, including the
 * sender of the transaction and its data. While these are generally available
 * via msg.sender and msg.data, they should not be accessed in such a direct
 * manner, since when dealing with GSN meta-transactions the account sending and
 * paying for execution may not be the actual sender (as far as an application
 * is concerned).
 *
 * This contract is only required for intermediate, library-like contracts.
 */
abstract contract Context {
    function _msgSender() internal view virtual returns (address payable) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes memory) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}


// Dependency file: @openzeppelin/contracts/access/Ownable.sol


// pragma solidity ^0.6.0;

// import "@openzeppelin/contracts/GSN/Context.sol";
/**
 * @dev Contract module which provides a basic access control mechanism, where
 * there is an account (an owner) that can be granted exclusive access to
 * specific functions.
 *
 * By default, the owner account will be the one that deploys the contract. This
 * can later be changed with {transferOwnership}.
 *
 * This module is used through inheritance. It will make available the modifier
 * `onlyOwner`, which can be applied to your functions to restrict their use to
 * the owner.
 */
contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    constructor () internal {
        address msgSender = _msgSender();
        _owner = msgSender;
        emit OwnershipTransferred(address(0), msgSender);
    }

    /**
     * @dev Returns the address of the current owner.
     */
    function owner() public view returns (address) {
        return _owner;
    }

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        require(_owner == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    /**
     * @dev Leaves the contract without owner. It will not be possible to call
     * `onlyOwner` functions anymore. Can only be called by the current owner.
     *
     * NOTE: Renouncing ownership will leave the contract without an owner,
     * thereby removing any functionality that is only available to the owner.
     */
    function renounceOwnership() public virtual onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}


// Dependency file: contracts/interfaces/IAlpaToken.sol


// pragma solidity 0.6.12;

// import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
// import "@openzeppelin/contracts/access/Ownable.sol";

interface IAlpaToken is IERC20 {
    function mint(address _to, uint256 _amount) external;
}


// Dependency file: contracts/interfaces/IAlpaSupplier.sol


// pragma solidity 0.6.12;




// Dependency file: @openzeppelin/contracts/token/ERC1155/IERC1155.sol


// pragma solidity ^0.6.2;

// import "@openzeppelin/contracts/introspection/IERC165.sol";

/**
 * @dev Required interface of an ERC1155 compliant contract, as defined in the
 * https://eips.ethereum.org/EIPS/eip-1155[EIP].
 *
 * _Available since v3.1._
 */
interface IERC1155 is IERC165 {
    /**
     * @dev Emitted when `value` tokens of token type `id` are transferred from `from` to `to` by `operator`.
     */
    event TransferSingle(address indexed operator, address indexed from, address indexed to, uint256 id, uint256 value);

    /**
     * @dev Equivalent to multiple {TransferSingle} events, where `operator`, `from` and `to` are the same for all
     * transfers.
     */
    event TransferBatch(address indexed operator, address indexed from, address indexed to, uint256[] ids, uint256[] values);

    /**
     * @dev Emitted when `account` grants or revokes permission to `operator` to transfer their tokens, according to
     * `approved`.
     */
    event ApprovalForAll(address indexed account, address indexed operator, bool approved);

    /**
     * @dev Emitted when the URI for token type `id` changes to `value`, if it is a non-programmatic URI.
     *
     * If an {URI} event was emitted for `id`, the standard
     * https://eips.ethereum.org/EIPS/eip-1155#metadata-extensions[guarantees] that `value` will equal the value
     * returned by {IERC1155MetadataURI-uri}.
     */
    event URI(string value, uint256 indexed id);

    /**
     * @dev Returns the amount of tokens of token type `id` owned by `account`.
     *
     * Requirements:
     *
     * - `account` cannot be the zero address.
     */
    function balanceOf(address account, uint256 id) external view returns (uint256);

    /**
     * @dev xref:ROOT:erc1155.adoc#batch-operations[Batched] version of {balanceOf}.
     *
     * Requirements:
     *
     * - `accounts` and `ids` must have the same length.
     */
    function balanceOfBatch(address[] calldata accounts, uint256[] calldata ids) external view returns (uint256[] memory);

    /**
     * @dev Grants or revokes permission to `operator` to transfer the caller's tokens, according to `approved`,
     *
     * Emits an {ApprovalForAll} event.
     *
     * Requirements:
     *
     * - `operator` cannot be the caller.
     */
    function setApprovalForAll(address operator, bool approved) external;

    /**
     * @dev Returns true if `operator` is approved to transfer ``account``'s tokens.
     *
     * See {setApprovalForAll}.
     */
    function isApprovedForAll(address account, address operator) external view returns (bool);

    /**
     * @dev Transfers `amount` tokens of token type `id` from `from` to `to`.
     *
     * Emits a {TransferSingle} event.
     *
     * Requirements:
     *
     * - `to` cannot be the zero address.
     * - If the caller is not `from`, it must be have been approved to spend ``from``'s tokens via {setApprovalForAll}.
     * - `from` must have a balance of tokens of type `id` of at least `amount`.
     * - If `to` refers to a smart contract, it must implement {IERC1155Receiver-onERC1155Received} and return the
     * acceptance magic value.
     */
    function safeTransferFrom(address from, address to, uint256 id, uint256 amount, bytes calldata data) external;

    /**
     * @dev xref:ROOT:erc1155.adoc#batch-operations[Batched] version of {safeTransferFrom}.
     *
     * Emits a {TransferBatch} event.
     *
     * Requirements:
     *
     * - `ids` and `amounts` must have the same length.
     * - If `to` refers to a smart contract, it must implement {IERC1155Receiver-onERC1155BatchReceived} and return the
     * acceptance magic value.
     */
    function safeBatchTransferFrom(address from, address to, uint256[] calldata ids, uint256[] calldata amounts, bytes calldata data) external;
}


// Dependency file: contracts/interfaces/ICryptoAlpaca.sol


// pragma solidity =0.6.12;

// import "@openzeppelin/contracts/token/ERC1155/IERC1155.sol";

interface ICryptoAlpaca is IERC1155 {
    function getAlpaca(uint256 _id)
        external
        view
        returns (
            uint256 id,
            bool isReady,
            uint256 cooldownEndBlock,
            uint256 birthTime,
            uint256 matronId,
            uint256 sireId,
            uint256 hatchingCost,
            uint256 hatchingCostMultiplier,
            uint256 hatchCostMultiplierEndBlock,
            uint256 generation,
            uint256 gene,
            uint256 energy,
            uint256 state
        );

    function hasPermissionToBreedAsSire(address _addr, uint256 _id)
        external
        view
        returns (bool);

    function grandPermissionToBreed(address _addr, uint256 _sireId) external;

    function clearPermissionToBreed(uint256 _alpacaId) external;

    function hatch(uint256 _matronId, uint256 _sireId)
        external
        payable
        returns (uint256);

    function crack(uint256 _id) external;
}


// Dependency file: contracts/interfaces/ICryptoAlpacaEnergyListener.sol


// pragma solidity 0.6.12;

// import "@openzeppelin/contracts/introspection/IERC165.sol";

interface ICryptoAlpacaEnergyListener is IERC165 {
    /**
        @dev Handles the Alpaca energy change callback.
        @param id The id of the Alpaca which the energy changed
        @param oldEnergy The ID of the token being transferred
        @param newEnergy The amount of tokens being transferred
    */
    function onCryptoAlpacaEnergyChanged(
        uint256 id,
        uint256 oldEnergy,
        uint256 newEnergy
    ) external;
}


// Dependency file: contracts/interfaces/CryptoAlpacaEnergyListener.sol


// pragma solidity 0.6.12;

// import "@openzeppelin/contracts/introspection/ERC165.sol";
// import "contracts/interfaces/ICryptoAlpacaEnergyListener.sol";

abstract contract CryptoAlpacaEnergyListener is
    ERC165,
    ICryptoAlpacaEnergyListener
{
    constructor() public {
        _registerInterface(
            CryptoAlpacaEnergyListener(0).onCryptoAlpacaEnergyChanged.selector
        );
    }
}


// Root file: contracts/AlpacaSquad/AlpacaSquad.sol


pragma solidity 0.6.12;

// import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
// import "@openzeppelin/contracts/token/ERC1155/ERC1155Receiver.sol";
// import "@openzeppelin/contracts/token/ERC20/SafeERC20.sol";
// import "@openzeppelin/contracts/utils/EnumerableMap.sol";
// import "@openzeppelin/contracts/utils/ReentrancyGuard.sol";
// import "@openzeppelin/contracts/math/SafeMath.sol";
// import "@openzeppelin/contracts/math/Math.sol";
// import "@openzeppelin/contracts/access/Ownable.sol";

// import "contracts/interfaces/IAlpaToken.sol";
// import "contracts/interfaces/IAlpaSupplier.sol";
// import "contracts/interfaces/ICryptoAlpaca.sol";
// import "contracts/interfaces/CryptoAlpacaEnergyListener.sol";

// Alpaca Squad manages your you alpacas
contract AlpacaSquad is
    Ownable,
    ReentrancyGuard,
    ERC1155Receiver,
    CryptoAlpacaEnergyListener
{
    using SafeMath for uint256;
    using Math for uint256;
    using SafeERC20 for IERC20;
    using EnumerableMap for EnumerableMap.UintToAddressMap;

    // Info of each user.
    struct UserInfo {
        // Reward debt
        uint256 rewardDebt;
        // share
        uint256 share;
        // number of alpacas in this squad
        uint256 numAlpacas;
        // sum of alpaca energy
        uint256 sumEnergy;
    }

    // Info of Reward.
    struct RewardInfo {
        // Last block number that ALPAs distribution occurs.
        uint256 lastRewardBlock;
        // Accumulated ALPAs per share. Share is determined by LP deposit and total alpaca's energy
        uint256 accAlpaPerShare;
        // Accumulated Share
        uint256 accShare;
    }

    /* ========== STATES ========== */

    // The ALPA ERC20 token
    IAlpaToken public alpa;

    // Crypto alpaca contract
    ICryptoAlpaca public cryptoAlpaca;

    // Alpa Supplier
    IAlpaSupplier public supplier;

    // farm pool info
    RewardInfo public rewardInfo;

    uint256 public maxAlpacaSquadCount = 20;

    // Info of each user.
    mapping(address => UserInfo) public userInfo;

    // map that keep tracks of the alpaca's original owner so contract knows where to send back when
    // users retrieves their alpacas
    EnumerableMap.UintToAddressMap private alpacaOriginalOwner;

    uint256 public constant SAFE_MULTIPLIER = 1e16;

    /* ========== CONSTRUCTOR ========== */

    constructor(
        IAlpaToken _alpa,
        ICryptoAlpaca _cryptoAlpaca,
        IAlpaSupplier _supplier,
        uint256 _startBlock
    ) public {
        alpa = _alpa;
        cryptoAlpaca = _cryptoAlpaca;
        supplier = _supplier;
        rewardInfo = RewardInfo({
            lastRewardBlock: block.number.max(_startBlock),
            accAlpaPerShare: 0,
            accShare: 0
        });
    }

    /* ========== PUBLIC ========== */

    /**
     * @dev View `_user` pending ALPAs
     */
    function pendingAlpa(address _user) external view returns (uint256) {
        UserInfo storage user = userInfo[_user];

        uint256 accAlpaPerShare = rewardInfo.accAlpaPerShare;

        if (
            block.number > rewardInfo.lastRewardBlock &&
            rewardInfo.accShare != 0
        ) {
            uint256 total = supplier.preview(
                address(this),
                rewardInfo.lastRewardBlock
            );

            accAlpaPerShare = accAlpaPerShare.add(
                total.mul(SAFE_MULTIPLIER).div(rewardInfo.accShare)
            );
        }

        return
            user.share.mul(accAlpaPerShare).div(SAFE_MULTIPLIER).sub(
                user.rewardDebt
            );
    }

    /**
     * @dev Update reward variables of the given pool to be up-to-date.
     */
    function updatePool() public {
        if (block.number <= rewardInfo.lastRewardBlock) {
            return;
        }

        if (rewardInfo.accShare == 0) {
            rewardInfo.lastRewardBlock = block.number;
            return;
        }

        uint256 reward = supplier.distribute(rewardInfo.lastRewardBlock);
        rewardInfo.accAlpaPerShare = rewardInfo.accAlpaPerShare.add(
            reward.mul(SAFE_MULTIPLIER).div(rewardInfo.accShare)
        );

        rewardInfo.lastRewardBlock = block.number;
    }

    /**
     * @dev Retrieve caller's alpacas
     */
    function retrieve(uint256[] memory _ids) public nonReentrant {
        require(_ids.length > 0, "AlpacaSquad: invalid argument");

        address sender = msg.sender;
        UserInfo storage user = userInfo[sender];
        (
            uint256 share,
            uint256 numAlpacas,
            uint256 sumEnergy
        ) = _calculateDeletion(sender, user, _ids);

        updatePool();

        uint256 pending = user
            .share
            .mul(rewardInfo.accAlpaPerShare)
            .div(SAFE_MULTIPLIER)
            .sub(user.rewardDebt);
        if (pending > 0) {
            _safeAlpaTransfer(sender, pending);
        }

        // Update user reward debt with new share
        user.rewardDebt = share.mul(rewardInfo.accAlpaPerShare).div(
            SAFE_MULTIPLIER
        );

        // Update reward info accumulated share
        rewardInfo.accShare = rewardInfo.accShare.add(share).sub(user.share);

        user.share = share;
        user.numAlpacas = numAlpacas;
        user.sumEnergy = sumEnergy;

        for (uint256 i = 0; i < _ids.length; i++) {
            alpacaOriginalOwner.remove(_ids[i]);
            cryptoAlpaca.safeTransferFrom(
                address(this),
                sender,
                _ids[i],
                1,
                ""
            );
        }
    }

    /**
     * @dev Claim user reward
     */
    function claim() public nonReentrant {
        updatePool();
        address sender = msg.sender;

        UserInfo storage user = userInfo[sender];
        if (user.sumEnergy > 0) {
            uint256 pending = user
                .share
                .mul(rewardInfo.accAlpaPerShare)
                .div(SAFE_MULTIPLIER)
                .sub(user.rewardDebt);

            if (pending > 0) {
                _safeAlpaTransfer(sender, pending);
            }

            user.rewardDebt = user.share.mul(rewardInfo.accAlpaPerShare).div(
                SAFE_MULTIPLIER
            );
        }
    }

    /* ========== ERC1155Receiver ========== */

    /**
     * @dev onERC1155Received implementation per IERC1155Receiver spec
     */
    function onERC1155Received(
        address,
        address _from,
        uint256 _id,
        uint256,
        bytes memory
    ) external override nonReentrant fromCryptoAlpaca returns (bytes4) {
        UserInfo storage user = userInfo[_from];
        uint256[] memory ids = _asSingletonArray(_id);
        (
            uint256 share,
            uint256 numAlpacas,
            uint256 sumEnergy
        ) = _calculateAddition(user, ids);

        updatePool();

        if (user.sumEnergy > 0) {
            uint256 pending = user
                .share
                .mul(rewardInfo.accAlpaPerShare)
                .div(SAFE_MULTIPLIER)
                .sub(user.rewardDebt);
            if (pending > 0) {
                _safeAlpaTransfer(_from, pending);
            }
        }

        // Update user reward debt with new share
        user.rewardDebt = share.mul(rewardInfo.accAlpaPerShare).div(
            SAFE_MULTIPLIER
        );

        // Update reward info accumulated share
        rewardInfo.accShare = rewardInfo.accShare.add(share).sub(user.share);

        user.share = share;
        user.numAlpacas = numAlpacas;
        user.sumEnergy = sumEnergy;

        // Give original owner the right to breed
        cryptoAlpaca.grandPermissionToBreed(_from, _id);

        // store original owner
        alpacaOriginalOwner.set(_id, _from);

        return
            bytes4(
                keccak256(
                    "onERC1155Received(address,address,uint256,uint256,bytes)"
                )
            );
    }

    /**
     * @dev onERC1155BatchReceived implementation per IERC1155Receiver spec
     */
    function onERC1155BatchReceived(
        address,
        address _from,
        uint256[] memory _ids,
        uint256[] memory,
        bytes memory
    ) external override nonReentrant fromCryptoAlpaca returns (bytes4) {
        UserInfo storage user = userInfo[_from];
        (
            uint256 share,
            uint256 numAlpacas,
            uint256 sumEnergy
        ) = _calculateAddition(user, _ids);

        updatePool();

        if (user.sumEnergy > 0) {
            uint256 pending = user
                .share
                .mul(rewardInfo.accAlpaPerShare)
                .div(SAFE_MULTIPLIER)
                .sub(user.rewardDebt);
            if (pending > 0) {
                _safeAlpaTransfer(_from, pending);
            }
        }

        // Update user reward debt with new share
        user.rewardDebt = share.mul(rewardInfo.accAlpaPerShare).div(
            SAFE_MULTIPLIER
        );

        // Update reward info accumulated share
        rewardInfo.accShare = rewardInfo.accShare.add(share).sub(user.share);

        user.share = share;
        user.numAlpacas = numAlpacas;
        user.sumEnergy = sumEnergy;

        // Give original owner the right to breed
        for (uint256 i = 0; i < _ids.length; i++) {
            // store original owner
            alpacaOriginalOwner.set(_ids[i], _from);

            // Give original owner the right to breed
            cryptoAlpaca.grandPermissionToBreed(_from, _ids[i]);
        }

        return
            bytes4(
                keccak256(
                    "onERC1155BatchReceived(address,address,uint256[],uint256[],bytes)"
                )
            );
    }

    /* ========== ICryptoAlpacaEnergyListener ========== */

    /**
        @dev Handles the Alpaca energy change callback.
        @param _id The id of the Alpaca which the energy changed
        @param _newEnergy The new alpaca energy it changed to
    */
    function onCryptoAlpacaEnergyChanged(
        uint256 _id,
        uint256 _oldEnergy,
        uint256 _newEnergy
    ) external override fromCryptoAlpaca ownsAlpaca(_id) {
        address from = alpacaOriginalOwner.get(_id);
        UserInfo storage user = userInfo[from];

        uint256 sumEnergy = user.sumEnergy.add(_newEnergy).sub(_oldEnergy);
        uint256 share = sumEnergy.mul(sumEnergy).div(user.numAlpacas);

        updatePool();

        if (user.sumEnergy > 0) {
            uint256 pending = user
                .share
                .mul(rewardInfo.accAlpaPerShare)
                .div(SAFE_MULTIPLIER)
                .sub(user.rewardDebt);
            if (pending > 0) {
                _safeAlpaTransfer(from, pending);
            }
        }
        // Update user reward debt with new share
        user.rewardDebt = share.mul(rewardInfo.accAlpaPerShare).div(
            SAFE_MULTIPLIER
        );

        // Update reward info accumulated share
        rewardInfo.accShare = rewardInfo.accShare.add(share).sub(user.share);

        user.share = share;
        user.sumEnergy = sumEnergy;
    }

    /* ========== PRIVATE ========== */

    /**
     * @dev given user and array of alpacas ids, it validate the alpacas
     * and calculates the user share, numAlpacas, and sumEnergy after the addition
     */
    function _calculateAddition(UserInfo storage _user, uint256[] memory _ids)
        private
        view
        returns (
            uint256 share,
            uint256 numAlpacas,
            uint256 sumEnergy
        )
    {
        require(
            _user.numAlpacas + _ids.length <= maxAlpacaSquadCount,
            "AlpacaSquad: Max alpaca reached"
        );
        numAlpacas = _user.numAlpacas + _ids.length;
        sumEnergy = _user.sumEnergy;

        for (uint256 i = 0; i < _ids.length; i++) {
            uint256 id = _ids[i];
            require(id != 0, "AlpacaSquad: invalid alpaca");

            // Fetch alpaca energy and state
            (, , , , , , , , , , , uint256 energy, uint256 state) = cryptoAlpaca
                .getAlpaca(id);
            require(state == 1, "AlpacaFarm: invalid alpaca state");
            require(energy > 0, "AlpacaFarm: invalid alpaca energy");
            sumEnergy = sumEnergy.add(energy);
        }

        share = sumEnergy.mul(sumEnergy).div(numAlpacas);
    }

    function _calculateDeletion(
        address owner,
        UserInfo storage _user,
        uint256[] memory _ids
    )
        private
        view
        returns (
            uint256 share,
            uint256 numAlpacas,
            uint256 sumEnergy
        )
    {
        numAlpacas = _user.numAlpacas.sub(_ids.length);
        sumEnergy = _user.sumEnergy;

        for (uint256 i = 0; i < _ids.length; i++) {
            uint256 id = _ids[i];
            require(
                alpacaOriginalOwner.get(id) == owner,
                "AlpacaFarm: original owner not found"
            );

            // Fetch alpaca energy and state
            (, , , , , , , , , , , uint256 energy, ) = cryptoAlpaca.getAlpaca(
                id
            );
            sumEnergy = sumEnergy.sub(energy);
        }

        if (numAlpacas > 0) {
            share = sumEnergy.mul(sumEnergy).div(numAlpacas);
        }
    }

    function _asSingletonArray(uint256 element)
        private
        pure
        returns (uint256[] memory)
    {
        uint256[] memory array = new uint256[](1);
        array[0] = element;

        return array;
    }

    // Safe alpa transfer function, just in case if rounding error causes pool to not have enough ALPAs.
    function _safeAlpaTransfer(address _to, uint256 _amount) private {
        uint256 alpaBal = alpa.balanceOf(address(this));
        if (_amount > alpaBal) {
            alpa.transfer(_to, alpaBal);
        } else {
            alpa.transfer(_to, _amount);
        }
    }

    /* ========== Owner ========== */

    function setMaxAlpacaSquadCount(uint256 _count) public onlyOwner {
        maxAlpacaSquadCount = _count;
    }

    /* ========== MODIFIER ========== */

    modifier fromCryptoAlpaca() {
        require(
            msg.sender == address(cryptoAlpaca),
            "AlpacaFarm: received alpaca from unauthenticated contract"
        );
        _;
    }

    modifier ownsAlpaca(uint256 _id) {
        require(
            alpacaOriginalOwner.contains(_id),
            "AlpacaFarm: original owner not found"
        );
        _;
    }
}