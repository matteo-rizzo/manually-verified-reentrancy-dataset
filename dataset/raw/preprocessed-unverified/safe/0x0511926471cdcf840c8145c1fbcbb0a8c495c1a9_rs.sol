/**
 *Submitted for verification at Etherscan.io on 2020-11-11
*/

// Dependency file: @openzeppelin/contracts/introspection/IERC165.sol

// SPDX-License-Identifier: MIT

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


// Dependency file: @openzeppelin/contracts/utils/EnumerableSet.sol


// pragma solidity ^0.6.0;

/**
 * @dev Library for managing
 * https://en.wikipedia.org/wiki/Set_(abstract_data_type)[sets] of primitive
 * types.
 *
 * Sets have the following properties:
 *
 * - Elements are added, removed, and checked for existence in constant time
 * (O(1)).
 * - Elements are enumerated in O(n). No guarantees are made on the ordering.
 *
 * ```
 * contract Example {
 *     // Add the library methods
 *     using EnumerableSet for EnumerableSet.AddressSet;
 *
 *     // Declare a set state variable
 *     EnumerableSet.AddressSet private mySet;
 * }
 * ```
 *
 * As of v3.0.0, only sets of type `address` (`AddressSet`) and `uint256`
 * (`UintSet`) are supported.
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



// Dependency file: @openzeppelin/contracts/math/Math.sol


// pragma solidity ^0.6.0;

/**
 * @dev Standard math utilities missing in the Solidity language.
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


// Dependency file: contracts/AlpacaPresaleV2/AccessControl.sol


// pragma solidity =0.6.12;

// import "@openzeppelin/contracts/access/Ownable.sol";
// import "@openzeppelin/contracts/utils/EnumerableSet.sol";

contract AccessControl is Ownable {
    using EnumerableSet for EnumerableSet.AddressSet;

    /* ========== STATE VARIABLES ========== */

    uint256 public startBlock;

    uint256 public endBlock;

    bool internal whitelistEnabled = true;

    // Set of address that are approved to purchase alpaca
    EnumerableSet.AddressSet internal whitelist;

    /* ========== EXTERNAL MUTATIVE FUNCTIONS ========== */

    function setStartBlock(uint256 _block) external onlyOwner {
        startBlock = _block;
    }

    function setEndBlock(uint256 _block) external onlyOwner {
        endBlock = _block;
    }

    function setWhitelistEnabled(bool _enabled) external onlyOwner {
        whitelistEnabled = _enabled;
    }

    /**
     * @dev Allow owner to change alpaca price
     */
    function addToWhitelist(address[] calldata _addresses) external onlyOwner {
        for (uint256 i = 0; i < _addresses.length; i++) {
            whitelist.add(_addresses[i]);
        }
    }

    /* ========== MODIFIER ========== */

    modifier whenInProgress() {
        require(block.number >= startBlock, "Event not yet started");
        require(block.number < endBlock, "Event Ended");
        _;
    }

    modifier whenEnded() {
        require(block.number >= endBlock, "Event not yet ended");
        _;
    }
}


// Root file: contracts/AlpacaPresaleV2/AlpacaPresaleV2.sol


pragma solidity =0.6.12;

// import "@openzeppelin/contracts/token/ERC1155/IERC1155.sol";
// import "@openzeppelin/contracts/token/ERC1155/ERC1155Receiver.sol";
// import "@openzeppelin/contracts/utils/EnumerableSet.sol";
// import "@openzeppelin/contracts/access/Ownable.sol";
// import "@openzeppelin/contracts/math/SafeMath.sol";
// import "@openzeppelin/contracts/math/Math.sol";
// import "@openzeppelin/contracts/utils/ReentrancyGuard.sol";

// import "contracts/AlpacaPresaleV2/AccessControl.sol";

contract AlpacaPresaleV2 is
    Ownable,
    AccessControl,
    ReentrancyGuard,
    ERC1155Receiver
{
    using SafeMath for uint256;
    using Math for uint256;
    using EnumerableSet for EnumerableSet.UintSet;
    using EnumerableSet for EnumerableSet.AddressSet;

    /* ========== STATE VARIABLES ========== */

    IERC1155 public cryptoAlpaca;

    uint256 public pricePerAlpaca = 0.03 ether;

    uint256 public maxAdoptionCount = 4;

    // Mapping from address to alpaca count
    mapping(address => uint256) private accountAddoptionCount;

    // Set of alpaca IDs this contract owns
    EnumerableSet.UintSet private presaleAlpacaIDs;

    /* ========== CONSTRUCTOR ========== */

    constructor(IERC1155 _cryptoAlpaca) public {
        cryptoAlpaca = _cryptoAlpaca;
    }

    /* ========== OWNER ONLY ========== */

    /**
     * @dev Allow owner to change alpaca price
     */
    function setPricePerAlpaca(uint256 _price) public onlyOwner {
        pricePerAlpaca = _price;
    }

    /**
     * @dev Allow owner to update maximum number alpaca a given user can adopt
     */
    function setMaxAdoptionCount(uint256 _maxAdoptionCount) public onlyOwner {
        maxAdoptionCount = _maxAdoptionCount;
    }

    /**
     * @dev Allow owner to transfer a alpaca that didn't get adopted during presale
     */
    function reclaim(uint256 _id, address _to) public onlyOwner whenEnded {
        cryptoAlpaca.safeTransferFrom(address(this), _to, _id, 1, "");
    }

    /**
     * @dev Allow owner to transfer all alpaca that didn't get adopted during presale
     */
    function reclaimAll(address _to) public onlyOwner whenEnded {
        uint256 length = presaleAlpacaIDs.length();
        uint256[] memory ids = new uint256[](length);
        uint256[] memory amount = new uint256[](length);
        for (uint256 i = 0; i < length; i++) {
            ids[i] = presaleAlpacaIDs.at(i);
            amount[i] = 1;
        }

        cryptoAlpaca.safeBatchTransferFrom(address(this), _to, ids, amount, "");
    }

    /**
     * @dev Allows owner to withdrawal the presale balance to an account.
     */
    function withdraw(address payable _to) external onlyOwner {
        _to.transfer(address(this).balance);
    }

    /* ========== EXTERNAL MUTATIVE FUNCTIONS ========== */

    /**
     * @dev Adopt _count number of alpaca
     */
    function adoptAlpaca(uint256 _count)
        public
        payable
        whenInProgress
        nonReentrant
    {
        require(_count > 0, "AlpacaPresale: must adopt at least one alpaca");

        address account = msg.sender;
        uint256 credit = canAdoptCount(account);
        require(
            _count <= credit,
            "AlpacaPresale: adoption count larger than maximum adoption limit"
        );

        require(
            msg.value >= getAdoptionPrice(_count),
            "AlpacaPresale: insufficient funds"
        );

        uint256[] memory ids = new uint256[](_count);
        uint256[] memory counts = new uint256[](_count);
        for (uint256 i = 0; i < _count; i++) {
            ids[i] = _randRemoveAlpaca();
            counts[i] = 1;
        }

        accountAddoptionCount[account] += _count;

        cryptoAlpaca.safeBatchTransferFrom(
            address(this),
            account,
            ids,
            counts,
            ""
        );
    }

    /* ========== VIEW ========== */

    /**
     * @dev returns if `_account` is whitelisted to adopt alpaca
     */
    function allowedToAdopt(address _account) public view returns (bool) {
        return whitelistEnabled ? whitelist.contains(_account) : true;
    }

    /**
     * @dev returns number of _account has adopted presale alpaca
     */
    function getAdoptionCount(address _account) public view returns (uint256) {
        return accountAddoptionCount[_account];
    }

    /**
     * @dev total adoption price if adopt _count many
     */
    function getAdoptionPrice(uint256 _count) public view returns (uint256) {
        return _count.mul(pricePerAlpaca);
    }

    /**
     * @dev number of presale alpaca this contract owns
     */
    function getPresaleAlpacaCount() public view returns (uint256) {
        return presaleAlpacaIDs.length();
    }

    /**
     * @dev how many more _account can adopt alpaca
     */
    function canAdoptCount(address _account) public view returns (uint256) {
        if (!allowedToAdopt(_account)) {
            return 0;
        }

        uint256 credit = maxAdoptionCount.sub(accountAddoptionCount[_account]);

        uint256 alpacaCount = presaleAlpacaIDs.length();

        return credit.min(alpacaCount);
    }

    /**
     * @dev onERC1155Received implementation per IERC1155Receiver spec
     */
    function onERC1155Received(
        address,
        address,
        uint256 id,
        uint256,
        bytes calldata
    ) external override returns (bytes4) {
        require(
            msg.sender == address(cryptoAlpaca),
            "AlpacaPresale: received alpaca from unauthenticated contract"
        );

        uint256[] memory ids = new uint256[](1);
        ids[0] = id;

        _receivedAlpaca(ids);

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
        address,
        uint256[] calldata ids,
        uint256[] calldata,
        bytes calldata
    ) external override returns (bytes4) {
        require(
            msg.sender == address(cryptoAlpaca),
            "AlpacaPresale: received alpaca from unauthenticated contract"
        );

        _receivedAlpaca(ids);

        return
            bytes4(
                keccak256(
                    "onERC1155BatchReceived(address,address,uint256[],uint256[],bytes)"
                )
            );
    }

    /* ========== PRIVATE ========== */

    /**
     * @dev randomly select and remove a alpaca
     * returns selected alpaca ID
     */
    function _randRemoveAlpaca() private returns (uint256) {
        require(presaleAlpacaIDs.length() > 0, "No more presale alpaca");

        uint256 totalLength = presaleAlpacaIDs.length();

        uint256 randIndex = uint256(blockhash(block.number - 1));
        randIndex = uint256(keccak256(abi.encodePacked(randIndex, totalLength)))
            .mod(totalLength);

        uint256 randID = presaleAlpacaIDs.at(uint256(randIndex));

        require(presaleAlpacaIDs.remove(randID));

        return randID;
    }

    function _receivedAlpaca(uint256[] memory ids) private {
        for (uint256 i = 0; i < ids.length; i++) {
            presaleAlpacaIDs.add(ids[i]);
        }
    }
}