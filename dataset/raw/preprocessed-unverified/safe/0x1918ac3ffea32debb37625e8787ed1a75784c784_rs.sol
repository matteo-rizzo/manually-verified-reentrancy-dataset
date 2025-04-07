/**
 *Submitted for verification at Etherscan.io on 2021-05-17
*/

// Dependency file: @openzeppelin/contracts/introspection/IERC165.sol

// SPDX-License-Identifier: MIT

// pragma solidity ^0.7.0;

/**
 * @dev Interface of the ERC165 standard, as defined in the
 * https://eips.ethereum.org/EIPS/eip-165[EIP].
 *
 * Implementers can declare support of contract interfaces, which can then be
 * queried by others ({ERC165Checker}).
 *
 * For an implementation, see {ERC165}.
 */



// Dependency file: @openzeppelin/contracts/token/ERC721/IERC721.sol


// pragma solidity ^0.7.0;

// import "@openzeppelin/contracts/introspection/IERC165.sol";

/**
 * @dev Required interface of an ERC721 compliant contract.
 */
interface IERC721 is IERC165 {
    /**
     * @dev Emitted when `tokenId` token is transferred from `from` to `to`.
     */
    event Transfer(address indexed from, address indexed to, uint256 indexed tokenId);

    /**
     * @dev Emitted when `owner` enables `approved` to manage the `tokenId` token.
     */
    event Approval(address indexed owner, address indexed approved, uint256 indexed tokenId);

    /**
     * @dev Emitted when `owner` enables or disables (`approved`) `operator` to manage all of its assets.
     */
    event ApprovalForAll(address indexed owner, address indexed operator, bool approved);

    /**
     * @dev Returns the number of tokens in ``owner``'s account.
     */
    function balanceOf(address owner) external view returns (uint256 balance);

    /**
     * @dev Returns the owner of the `tokenId` token.
     *
     * Requirements:
     *
     * - `tokenId` must exist.
     */
    function ownerOf(uint256 tokenId) external view returns (address owner);

    /**
     * @dev Safely transfers `tokenId` token from `from` to `to`, checking first that contract recipients
     * are aware of the ERC721 protocol to prevent tokens from being forever locked.
     *
     * Requirements:
     *
     * - `from` cannot be the zero address.
     * - `to` cannot be the zero address.
     * - `tokenId` token must exist and be owned by `from`.
     * - If the caller is not `from`, it must be have been allowed to move this token by either {approve} or {setApprovalForAll}.
     * - If `to` refers to a smart contract, it must implement {IERC721Receiver-onERC721Received}, which is called upon a safe transfer.
     *
     * Emits a {Transfer} event.
     */
    function safeTransferFrom(address from, address to, uint256 tokenId) external;

    /**
     * @dev Transfers `tokenId` token from `from` to `to`.
     *
     * WARNING: Usage of this method is discouraged, use {safeTransferFrom} whenever possible.
     *
     * Requirements:
     *
     * - `from` cannot be the zero address.
     * - `to` cannot be the zero address.
     * - `tokenId` token must be owned by `from`.
     * - If the caller is not `from`, it must be approved to move this token by either {approve} or {setApprovalForAll}.
     *
     * Emits a {Transfer} event.
     */
    function transferFrom(address from, address to, uint256 tokenId) external;

    /**
     * @dev Gives permission to `to` to transfer `tokenId` token to another account.
     * The approval is cleared when the token is transferred.
     *
     * Only a single account can be approved at a time, so approving the zero address clears previous approvals.
     *
     * Requirements:
     *
     * - The caller must own the token or be an approved operator.
     * - `tokenId` must exist.
     *
     * Emits an {Approval} event.
     */
    function approve(address to, uint256 tokenId) external;

    /**
     * @dev Returns the account approved for `tokenId` token.
     *
     * Requirements:
     *
     * - `tokenId` must exist.
     */
    function getApproved(uint256 tokenId) external view returns (address operator);

    /**
     * @dev Approve or remove `operator` as an operator for the caller.
     * Operators can call {transferFrom} or {safeTransferFrom} for any token owned by the caller.
     *
     * Requirements:
     *
     * - The `operator` cannot be the caller.
     *
     * Emits an {ApprovalForAll} event.
     */
    function setApprovalForAll(address operator, bool _approved) external;

    /**
     * @dev Returns if the `operator` is allowed to manage all of the assets of `owner`.
     *
     * See {setApprovalForAll}
     */
    function isApprovedForAll(address owner, address operator) external view returns (bool);

    /**
      * @dev Safely transfers `tokenId` token from `from` to `to`.
      *
      * Requirements:
      *
     * - `from` cannot be the zero address.
     * - `to` cannot be the zero address.
      * - `tokenId` token must exist and be owned by `from`.
      * - If the caller is not `from`, it must be approved to move this token by either {approve} or {setApprovalForAll}.
      * - If `to` refers to a smart contract, it must implement {IERC721Receiver-onERC721Received}, which is called upon a safe transfer.
      *
      * Emits a {Transfer} event.
      */
    function safeTransferFrom(address from, address to, uint256 tokenId, bytes calldata data) external;
}


// Dependency file: @openzeppelin/contracts/utils/EnumerableSet.sol


// pragma solidity ^0.7.0;

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
 * As of v3.3.0, sets of type `bytes32` (`Bytes32Set`), `address` (`AddressSet`)
 * and `uint256` (`UintSet`) are supported.
 */



// Dependency file: @openzeppelin/contracts/token/ERC721/IERC721Receiver.sol


// pragma solidity ^0.7.0;

/**
 * @title ERC721 token receiver interface
 * @dev Interface for any contract that wants to support safeTransfers
 * from ERC721 asset contracts.
 */



// Dependency file: contracts/handlers/IHandler.sol


// pragma solidity 0.7.3;




// Dependency file: contracts/handlers/ERC721/ERC721HandlerStorage.sol


// pragma solidity 0.7.3;

// import "@openzeppelin/contracts/utils/EnumerableSet.sol";

abstract contract ERC721HandlerStorage {
    // Initializable.sol
    bool internal _initialized;
    bool internal _initializing;

    // Ownable.sol
    address internal _owner;

    // ERC721Handler.sol
    mapping(address => bool) internal _supportedTokens;
    mapping(address => mapping(uint256 => address)) internal _tokenOwners;
    mapping(address => mapping(address => EnumerableSet.UintSet)) internal _ownedTokens;
    mapping(address => mapping(uint256 => uint256)) internal _depositTimestamp;
}


// Dependency file: contracts/handlers/ERC721/Initializable.sol


// pragma solidity 0.7.3;

// import "contracts/handlers/ERC721/ERC721HandlerStorage.sol";

/**
 * @title Initializable
 *
 * @dev Helper contract to support initializer functions. To use it, replace
 * the constructor with a function that has the `initializer` modifier.
 * WARNING: Unlike constructors, initializer functions must be manually
 * invoked. This applies both to deploying an Initializable contract, as well
 * as extending an Initializable contract via inheritance.
 * WARNING: When used with inheritance, manual care must be taken to not invoke
 * a parent initializer twice, or ensure that all initializers are idempotent,
 * because this is not dealt with automatically as with constructors.
 */
contract Initializable is ERC721HandlerStorage {
    /**
     * @dev Indicates that the contract has been initialized.
     */
    // bool _initialized;

    /**
     * @dev Indicates that the contract is in the process of being initialized.
     */
    // bool _initializing;

    /**
     * @dev Modifier to use in the initializer function of a contract.
     */
    modifier initializer() {
        require(_initializing || isConstructor() || !_initialized, "Contract instance has already been initialized");

        bool isTopLevelCall = !_initializing;
        if (isTopLevelCall) {
            _initializing = true;
            _initialized = true;
        }

        _;

        if (isTopLevelCall) {
            _initializing = false;
        }
    }

    /// @dev Returns true if and only if the function is running in the constructor
    function isConstructor() private view returns (bool) {
        // extcodesize checks the size of the code stored in an address, and
        // address returns the current address. Since the code is still not
        // deployed when running a constructor, any checks on its code size will
        // yield zero, making it an effective way to detect if a contract is
        // under construction or not.
        address self = address(this);
        uint256 cs;
        // solhint-disable-next-line no-inline-assembly
        assembly {
            cs := extcodesize(self)
        }
        return cs == 0;
    }
}


// Dependency file: contracts/handlers/ERC721/Ownable.sol


// pragma solidity 0.7.3;

// import "contracts/handlers/ERC721/ERC721HandlerStorage.sol";
// import "contracts/handlers/ERC721/Initializable.sol";

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
contract Ownable is ERC721HandlerStorage, Initializable {
    // address _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    // solhint-disable-next-line func-name-mixedcase
    function __Ownable_init_unchained(address owner) internal initializer {
        _owner = owner;
        emit OwnershipTransferred(address(0), owner);
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
        require(_owner == msg.sender, "Ownable: caller is not the owner");
        _;
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


// Root file: contracts/handlers/ERC721/ERC721Handler.sol


pragma solidity 0.7.3;

// import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
// import "@openzeppelin/contracts/utils/EnumerableSet.sol";
// import "@openzeppelin/contracts/token/ERC721/IERC721Receiver.sol";
// import "contracts/handlers/IHandler.sol";
// import "contracts/handlers/ERC721/ERC721HandlerStorage.sol";
// import "contracts/handlers/ERC721/Initializable.sol";
// import "contracts/handlers/ERC721/Ownable.sol";

contract ERC721Handler is IHandler, IERC721Receiver, ERC721HandlerStorage, Initializable, Ownable {
    using EnumerableSet for EnumerableSet.UintSet;

    // ER721 token address => isSupported
    // mapping(address => bool) _supportedTokens;

    // ERC721 token address => tokenId => owner address
    // mapping(address => mapping(uint256 => address)) _tokenOwners;

    // ERC721 token address => owner address => tokenIds
    // mapping(address => mapping(address => EnumerableSet.UintSet)) _ownedTokens;

    // ERC721 token address => tokenId => deposit timestamp
    // mapping(address => mapping(uint256 => uint256)) internal _depositTimestamp;

    constructor(address owner) {
        initialize(owner);
    }

    function initialize(address owner) public initializer {
        __Ownable_init_unchained(owner);
    }

    function onERC721Received(address, address, uint256, bytes calldata) external pure override returns (bytes4) {
        revert("ERC721Handler: tokens cannot be transferred directly, use Pawnshop.depositItem function instead");
    }

    function supportToken(address tokenContract) external override onlyOwner {
        _supportedTokens[tokenContract] = true;
    }

    function stopSupportingToken(address tokenContract) external override onlyOwner {
        _supportedTokens[tokenContract] = false;
    }

    function deposit(address from, address tokenContract, uint256 tokenId) external override onlyOwner {
        require(isSupported(tokenContract), "ERC721Handler: token is not supported");
        IERC721(tokenContract).transferFrom(from, address(this), tokenId);
        _tokenOwners[tokenContract][tokenId] = from;
        _ownedTokens[tokenContract][from].add(tokenId);
        _depositTimestamp[tokenContract][tokenId] = block.timestamp;
    }

    function withdraw(address recipient, address tokenContract, uint256 tokenId) external override onlyOwner {
        require(ownerOf(tokenContract, tokenId) == recipient, "ERC721Handler: recipient address is not the owner of the token");
        IERC721(tokenContract).transferFrom(address(this), recipient, tokenId); // WARNING: Withdrawing to a contract which is not an ERC721 receiver can block an access to the item.
                                                                                // 'safeTransferFrom' cannot be used here because we want to support NFTs which do not implement this function.
                                                                                // Like CK i.e.
        delete _tokenOwners[tokenContract][tokenId];
        _ownedTokens[tokenContract][recipient].remove(tokenId);
        delete _depositTimestamp[tokenContract][tokenId];
    }

    function changeOwnership(address recipient, address tokenContract, uint256 tokenId) external override onlyOwner {
        require(IERC721(tokenContract).ownerOf(tokenId) == address(this), "ERC721Handler: to change the ownership of the item, it must be deposited to the handler first");
        address owner = ownerOf(tokenContract, tokenId);
        _tokenOwners[tokenContract][tokenId] = recipient;
        _ownedTokens[tokenContract][owner].remove(tokenId);
        _ownedTokens[tokenContract][recipient].add(tokenId);
    }

    function isSupported(address tokenContract) public override view returns (bool) {
        return _supportedTokens[tokenContract];
    }

    function ownerOf(address tokenContract, uint256 tokenId) public override view returns (address) {
        return _tokenOwners[tokenContract][tokenId];
    }

    function ownedTokens(address tokenContract, address owner) public view returns (uint256[] memory) {
        EnumerableSet.UintSet storage tokens = _ownedTokens[tokenContract][owner];
        uint256 ownedTokensLength = tokens.length();
        uint256[] memory tokenIds = new uint256[](ownedTokensLength);
        for (uint i = 0; i < ownedTokensLength; i++) {
            tokenIds[i] = tokens.at(i);
        }

        return tokenIds;
    }

    function depositTimestamp(address tokenContract, uint256 tokenId) public override view returns (uint256) {
        return _depositTimestamp[tokenContract][tokenId];
    }
}