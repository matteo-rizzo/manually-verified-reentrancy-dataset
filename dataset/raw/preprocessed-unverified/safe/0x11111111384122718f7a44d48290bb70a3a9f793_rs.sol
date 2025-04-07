/**
 *Submitted for verification at Etherscan.io on 2021-09-05
*/

// SPDX-License-Identifier: MIT

pragma solidity 0.8.4;

//  _______  ______    __   __  _______  _______  _______    _______  _______  _______  __   __  ___
// |       ||    _ |  |  | |  ||       ||       ||       |  |       ||       ||       ||  | |  ||   |
// |       ||   | ||  |  |_|  ||    _  ||_     _||   _   |  |    _  ||   _   ||       ||  |_|  ||   |
// |       ||   |_||_ |       ||   |_| |  |   |  |  | |  |  |   |_| ||  | |  ||       ||       ||   |
// |      _||    __  ||_     _||    ___|  |   |  |  |_|  |  |    ___||  |_|  ||      _||       ||   |
// |     |_ |   |  | |  |   |  |   |      |   |  |       |  |   |    |       ||     |_ |   _   ||   |
// |_______||___|  |_|  |___|  |___|      |___|  |_______|  |___|    |_______||_______||__| |__||___|
//

/**
 * @dev String operations.
 */


/**
 * @dev Collection of functions related to the address type
 */


/**
 * @dev Interface of the ERC165 standard, as defined in the
 * https://eips.ethereum.org/EIPS/eip-165[EIP].
 *
 * Implementers can declare support of contract interfaces, which can then be
 * queried by others ({ERC165Checker}).
 *
 * For an implementation, see {ERC165}.
 */


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

    constructor() {
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

/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
 */


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
    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId
    ) external;

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
    function transferFrom(
        address from,
        address to,
        uint256 tokenId
    ) external;

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
    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId,
        bytes calldata data
    ) external;
}

/**
 * @title ERC-721 Non-Fungible Token Standard, optional enumeration extension
 * @dev See https://eips.ethereum.org/EIPS/eip-721
 */
interface IERC721Enumerable is IERC721 {
    /**
     * @dev Returns the total amount of tokens stored by the contract.
     */
    function totalSupply() external view returns (uint256);

    /**
     * @dev Returns a token ID owned by `owner` at a given `index` of its token list.
     * Use along with {balanceOf} to enumerate all of ``owner``'s tokens.
     */
    function tokenOfOwnerByIndex(address owner, uint256 index) external view returns (uint256 tokenId);

    /**
     * @dev Returns a token ID at a given `index` of all the tokens stored by the contract.
     * Use along with {totalSupply} to enumerate all tokens.
     */
    function tokenByIndex(uint256 index) external view returns (uint256);
}

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




/**
 * @title ERC-721 Non-Fungible Token Standard, optional metadata extension
 * @dev See https://eips.ethereum.org/EIPS/eip-721
 */
interface IERC721Metadata is IERC721 {
    /**
     * @dev Returns the token collection name.
     */
    function name() external view returns (string memory);

    /**
     * @dev Returns the token collection symbol.
     */
    function symbol() external view returns (string memory);
}

/**
 * @title ERC721 token receiver interface
 * @dev Interface for any contract that wants to support safeTransfers
 * from ERC721 asset contracts.
 */


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
abstract contract ReentrancyGuard {
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

    constructor() {
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

/**
 * @title CryptoPochi - an interactive NFT project
 *
 * @dev Extends ERC721 Non-Fungible Token Standard basic implementation
 */
contract Pochi is ReentrancyGuard, Ownable, ERC165, IERC721Enumerable, IERC721Metadata {
    using Address for address;
    using EnumerableSet for EnumerableSet.UintSet;
    using EnumerableMap for EnumerableMap.UintToAddressMap;
    using Strings for uint256;

    uint256 public constant MAX_NFT_SUPPLY = 1500;
    uint256 public constant MAX_EARLY_ACCESS_SUPPLY = 750;

    // This will be set after the collection is fully minted and before sealing the contract
    string public PROVENANCE = "";

    uint256 public EARLY_ACCESS_START_TIMESTAMP = 1630854000; // 2021-09-05 15:00:00 UTC
    uint256 public SALE_START_TIMESTAMP = 1630940400; // 2021-09-06 15:00:00 UTC

    // The unit here is per half hour. Price decreases in a step function every half hour
    uint256 public SALE_DURATION = 12;
    uint256 public SALE_DURATION_SEC_PER_STEP = 1800; // 30 minutes

    uint256 public DUTCH_AUCTION_START_FEE = 8 ether;
    uint256 public DUTCH_AUCTION_END_FEE = 2 ether;

    uint256 public EARLY_ACCESS_MINT_FEE = 0.5 ether;
    uint256 public earlyAccessMinted;

    uint256 public POCHI_ACTION_PUBLIC_FEE = 0.01 ether;
    uint256 public POCHI_ACTION_OWNER_FEE = 0 ether;

    uint256 public constant POCHI_ACTION_PLEASE_JUMP = 1;
    uint256 public constant POCHI_ACTION_PLEASE_SAY_SOMETHING = 2;
    uint256 public constant POCHI_ACTION_PLEASE_GO_HAM = 3;

    // Seal contracts for minting, provenance
    bool public contractSealed;

    // tokenId -> tokenHash
    mapping(uint256 => bytes32) public tokenIdToHash;

    // Early access for ham holders
    mapping(address => uint256) public earlyAccessList;

    string private _baseURI;

    // Equals to `bytes4(keccak256("onERC721Received(address,address,uint256,bytes)"))`
    // which can be also obtained as `IERC721Receiver(0).onERC721Received.selector`
    bytes4 private constant _ERC721_RECEIVED = 0x150b7a02;

    // Mapping from holder address to their (enumerable) set of owned tokens
    mapping(address => EnumerableSet.UintSet) private _holderTokens;

    // Enumerable mapping from token ids to their owners
    EnumerableMap.UintToAddressMap private _tokenOwners;

    // Mapping from token ID to approved address
    mapping(uint256 => address) private _tokenApprovals;

    // Mapping from owner to operator approvals
    mapping(address => mapping(address => bool)) private _operatorApprovals;

    // Token name
    string private _name;

    // Token symbol
    string private _symbol;

    /*
     *     bytes4(keccak256('balanceOf(address)')) == 0x70a08231
     *     bytes4(keccak256('ownerOf(uint256)')) == 0x6352211e
     *     bytes4(keccak256('approve(address,uint256)')) == 0x095ea7b3
     *     bytes4(keccak256('getApproved(uint256)')) == 0x081812fc
     *     bytes4(keccak256('setApprovalForAll(address,bool)')) == 0xa22cb465
     *     bytes4(keccak256('isApprovedForAll(address,address)')) == 0xe985e9c5
     *     bytes4(keccak256('transferFrom(address,address,uint256)')) == 0x23b872dd
     *     bytes4(keccak256('safeTransferFrom(address,address,uint256)')) == 0x42842e0e
     *     bytes4(keccak256('safeTransferFrom(address,address,uint256,bytes)')) == 0xb88d4fde
     *
     *     => 0x70a08231 ^ 0x6352211e ^ 0x095ea7b3 ^ 0x081812fc ^
     *        0xa22cb465 ^ 0xe985e9c5 ^ 0x23b872dd ^ 0x42842e0e ^ 0xb88d4fde == 0x80ac58cd
     */
    bytes4 private constant _INTERFACE_ID_ERC721 = 0x80ac58cd;

    /*
     *     bytes4(keccak256('name()')) == 0x06fdde03
     *     bytes4(keccak256('symbol()')) == 0x95d89b41
     *
     *     => 0x06fdde03 ^ 0x95d89b41 == 0x93254542
     */
    bytes4 private constant _INTERFACE_ID_ERC721_METADATA = 0x93254542;

    /*
     *     bytes4(keccak256('totalSupply()')) == 0x18160ddd
     *     bytes4(keccak256('tokenOfOwnerByIndex(address,uint256)')) == 0x2f745c59
     *     bytes4(keccak256('tokenByIndex(uint256)')) == 0x4f6ccce7
     *
     *     => 0x18160ddd ^ 0x2f745c59 ^ 0x4f6ccce7 == 0x780e9d63
     */
    bytes4 private constant _INTERFACE_ID_ERC721_ENUMERABLE = 0x780e9d63;

    // Events
    event NewTokenHash(uint256 indexed tokenId, bytes32 tokenHash);
    event PochiAction(uint256 indexed timestamp, uint256 actionType, string actionText, string actionTarget, address indexed requester);

    /**
     * @dev Initializes the contract by setting a `name` and a `symbol` to the token collection.
     */
    constructor(string memory finalName, string memory finalSymbol) {
        _name = finalName;
        _symbol = finalSymbol;

        // register the supported interfaces to conform to ERC721 via ERC165
        _registerInterface(_INTERFACE_ID_ERC721);
        _registerInterface(_INTERFACE_ID_ERC721_METADATA);
        _registerInterface(_INTERFACE_ID_ERC721_ENUMERABLE);
    }

    /**
     * @dev See {IERC721Enumerable-totalSupply}.
     */
    function totalSupply() public view override returns (uint256) {
        // _tokenOwners are indexed by tokenIds, so .length() returns the number of tokenIds
        return _tokenOwners.length();
    }

    /**
     * @dev See {IERC721-balanceOf}.
     */
    function balanceOf(address owner) public view override returns (uint256) {
        require(owner != address(0), "ERC721: balance query for the zero address");

        return _holderTokens[owner].length();
    }

    /**
     * @dev See {IERC721-ownerOf}.
     */
    function ownerOf(uint256 tokenId) public view override returns (address) {
        return _tokenOwners.get(tokenId, "ERC721: owner query for nonexistent token");
    }

    /**
     * @dev See {IERC721Metadata-name}.
     */
    function name() external view override returns (string memory) {
        return _name;
    }

    /**
     * @dev See {IERC721Metadata-symbol}.
     */
    function symbol() external view override returns (string memory) {
        return _symbol;
    }

    /**
     * @dev See {IERC721Enumerable-tokenOfOwnerByIndex}.
     */
    function tokenOfOwnerByIndex(address owner, uint256 index) public view override returns (uint256) {
        return _holderTokens[owner].at(index);
    }

    /**
     * @dev Fetch all tokens owned by an address
     */
    function tokensOfOwner(address _owner) external view returns (uint256[] memory) {
        uint256 tokenCount = balanceOf(_owner);
        if (tokenCount == 0) {
            // Return an empty array
            return new uint256[](0);
        } else {
            uint256[] memory result = new uint256[](tokenCount);
            uint256 index;
            for (index = 0; index < tokenCount; index++) {
                result[index] = tokenOfOwnerByIndex(_owner, index);
            }
            return result;
        }
    }

    /**
     * @dev Fetch all tokens and their tokenHash owned by an address
     */
    function tokenHashesOfOwner(address _owner) external view returns (uint256[] memory, bytes32[] memory) {
        uint256 tokenCount = balanceOf(_owner);
        if (tokenCount == 0) {
            // Return an empty array
            return (new uint256[](0), new bytes32[](0));
        } else {
            uint256[] memory result = new uint256[](tokenCount);
            bytes32[] memory hashes = new bytes32[](tokenCount);
            uint256 index;
            for (index = 0; index < tokenCount; index++) {
                result[index] = tokenOfOwnerByIndex(_owner, index);
                hashes[index] = tokenIdToHash[index];
            }
            return (result, hashes);
        }
    }

    /**
     * @dev See {IERC721Enumerable-tokenByIndex}.
     */
    function tokenByIndex(uint256 index) external view override returns (uint256) {
        (uint256 tokenId, ) = _tokenOwners.at(index);
        return tokenId;
    }

    /**
     * @dev Returns current token price
     */
    function getNFTPrice() public view returns (uint256) {
        require(block.timestamp >= SALE_START_TIMESTAMP, "Sale has not started");

        uint256 count = totalSupply();
        require(count < MAX_NFT_SUPPLY, "Sale has already ended");

        uint256 elapsed = block.timestamp - SALE_START_TIMESTAMP;
        if (elapsed >= SALE_DURATION * SALE_DURATION_SEC_PER_STEP) {
            return DUTCH_AUCTION_END_FEE;
        } else {
            return (((SALE_DURATION * SALE_DURATION_SEC_PER_STEP - elapsed - 1) / SALE_DURATION_SEC_PER_STEP + 1) * (DUTCH_AUCTION_START_FEE - DUTCH_AUCTION_END_FEE)) / SALE_DURATION + DUTCH_AUCTION_END_FEE;
        }
    }

    /**
     * @dev Mint tokens and refund any excessive amount of ETH sent in
     */
    function mintAndRefundExcess(uint256 numberOfNfts) external payable nonReentrant {
        // Checks
        require(!contractSealed, "Contract sealed");

        require(block.timestamp >= SALE_START_TIMESTAMP, "Sale has not started");

        require(numberOfNfts > 0, "Cannot mint 0 NFTs");
        require(numberOfNfts <= 50, "Cannot mint more than 50 in 1 tx");

        uint256 total = totalSupply();
        require(total + numberOfNfts <= MAX_NFT_SUPPLY, "Sold out");

        uint256 price = getNFTPrice();
        require(msg.value >= numberOfNfts * price, "Ether value sent is insufficient");

        // Effects
        _safeMintWithHash(msg.sender, numberOfNfts, total);

        if (msg.value > numberOfNfts * price) {
            (bool success, ) = msg.sender.call{value: msg.value - numberOfNfts * price}("");
            require(success, "Refund excess failed.");
        }
    }

    /**
     * @dev Mint early access tokens
     */
    function mintEarlyAccess(uint256 numberOfNfts) external payable nonReentrant {
        // Checks
        require(!contractSealed, "Contract sealed");

        require(block.timestamp < SALE_START_TIMESTAMP, "Early access is over");
        require(block.timestamp >= EARLY_ACCESS_START_TIMESTAMP, "Early access has not started");

        require(numberOfNfts > 0, "Cannot mint 0 NFTs");
        require(numberOfNfts <= 50, "Cannot mint more than 50 in 1 tx");

        uint256 total = totalSupply();
        require(total + numberOfNfts <= MAX_NFT_SUPPLY, "Sold out");
        require(earlyAccessMinted + numberOfNfts <= MAX_EARLY_ACCESS_SUPPLY, "No more early access tokens left");

        require(earlyAccessList[msg.sender] >= numberOfNfts, "Invalid early access mint");

        require(msg.value == numberOfNfts * EARLY_ACCESS_MINT_FEE, "Ether value sent is incorrect");

        // Effects
        earlyAccessList[msg.sender] = earlyAccessList[msg.sender] - numberOfNfts;
        earlyAccessMinted = earlyAccessMinted + numberOfNfts;

        _safeMintWithHash(msg.sender, numberOfNfts, total);
    }

    /**
     * @dev Return if we are in the early access time period
     */
    function isInEarlyAccess() external view returns (bool) {
        return block.timestamp >= EARLY_ACCESS_START_TIMESTAMP && block.timestamp < SALE_START_TIMESTAMP;
    }

    /**
     * @dev Interact with Pochi. Directly from Ethereum!
     */
    function pochiAction(
        uint256 actionType,
        string calldata actionText,
        string calldata actionTarget
    ) external payable {
        if (balanceOf(msg.sender) > 0) {
            require(msg.value >= POCHI_ACTION_OWNER_FEE, "Ether value sent is incorrect");
        } else {
            require(msg.value >= POCHI_ACTION_PUBLIC_FEE, "Ether value sent is incorrect");
        }

        emit PochiAction(block.timestamp, actionType, actionText, actionTarget, msg.sender);
    }

    /**
     * @dev Internal function to set the base URI for all token IDs. It is
     * automatically added as a prefix to the value returned in {tokenURI},
     * or to the token ID if {tokenURI} is empty.
     */
    function _setBaseURI(string memory baseURI_) internal virtual {
        _baseURI = baseURI_;
    }

    /**
     * @dev Returns the base URI set via {_setBaseURI}. This will be
     * automatically added as a prefix in {tokenURI} to each token's URI, or
     * to the token ID if no specific URI is set for that token ID.
     */
    function baseURI() public view virtual returns (string memory) {
        return _baseURI;
    }

    /**
     * @dev See {IERC721Metadata-tokenURI}.
     */
    function tokenURI(uint256 tokenId) external view virtual returns (string memory) {
        require(_exists(tokenId), "ERC721Metadata: URI query for nonexistent token");

        string memory base = baseURI();

        // If there is no base URI, return the token id.
        if (bytes(base).length == 0) {
            return tokenId.toString();
        }

        return string(abi.encodePacked(base, tokenId.toString()));
    }

    /**
     * @dev See {IERC721-approve}.
     */
    function approve(address to, uint256 tokenId) external virtual override {
        address owner = ownerOf(tokenId);
        require(to != owner, "ERC721: approval to current owner");

        require(msg.sender == owner || isApprovedForAll(owner, msg.sender), "ERC721: approve caller is not owner nor approved for all");

        _approve(to, tokenId);
    }

    /**
     * @dev See {IERC721-getApproved}.
     */
    function getApproved(uint256 tokenId) public view override returns (address) {
        require(_exists(tokenId), "ERC721: approved query for nonexistent token");

        return _tokenApprovals[tokenId];
    }

    /**
     * @dev See {IERC721-setApprovalForAll}.
     */
    function setApprovalForAll(address operator, bool approved) external virtual override {
        require(operator != msg.sender, "ERC721: approve to caller");

        _operatorApprovals[msg.sender][operator] = approved;
        emit ApprovalForAll(msg.sender, operator, approved);
    }

    /**
     * @dev See {IERC721-isApprovedForAll}.
     */
    function isApprovedForAll(address owner, address operator) public view override returns (bool) {
        return _operatorApprovals[owner][operator];
    }

    /**
     * @dev See {IERC721-transferFrom}.
     */
    function transferFrom(
        address from,
        address to,
        uint256 tokenId
    ) external virtual override {
        //solhint-disable-next-line max-line-length
        require(_isApprovedOrOwner(msg.sender, tokenId), "ERC721: transfer caller is not owner nor approved");

        _transfer(from, to, tokenId);
    }

    /**
     * @dev See {IERC721-safeTransferFrom}.
     */
    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId
    ) public virtual override {
        safeTransferFrom(from, to, tokenId, "");
    }

    /**
     * @dev See {IERC721-safeTransferFrom}.
     */
    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId,
        bytes memory _data
    ) public virtual override {
        require(_isApprovedOrOwner(msg.sender, tokenId), "ERC721: transfer caller is not owner nor approved");
        _safeTransfer(from, to, tokenId, _data);
    }

    /**
     * @dev Safely transfers `tokenId` token from `from` to `to`, checking first that contract recipients
     * are aware of the ERC721 protocol to prevent tokens from being forever locked.
     *
     * `_data` is additional data, it has no specified format and it is sent in call to `to`.
     *
     * This internal function is equivalent to {safeTransferFrom}, and can be used to e.g.
     * implement alternative mechanisms to perform token transfer, such as signature-based.
     *
     * Requirements:
     *
     * - `from` cannot be the zero address.
     * - `to` cannot be the zero address.
     * - `tokenId` token must exist and be owned by `from`.
     * - If `to` refers to a smart contract, it must implement {IERC721Receiver-onERC721Received}, which is called upon a safe transfer.
     *
     * Emits a {Transfer} event.
     */
    function _safeTransfer(
        address from,
        address to,
        uint256 tokenId,
        bytes memory _data
    ) internal virtual {
        _transfer(from, to, tokenId);
        require(_checkOnERC721Received(from, to, tokenId, _data), "ERC721: transfer to non ERC721Receiver implementer");
    }

    /**
     * @dev Returns whether `tokenId` exists.
     *
     * Tokens can be managed by their owner or approved accounts via {approve} or {setApprovalForAll}.
     *
     * Tokens start existing when they are minted (`_mint`),
     * and stop existing when they are burned (`_burn`).
     */
    function _exists(uint256 tokenId) internal view returns (bool) {
        return _tokenOwners.contains(tokenId);
    }

    /**
     * @dev Returns whether `spender` is allowed to manage `tokenId`.
     *
     * Requirements:
     *
     * - `tokenId` must exist.
     */
    function _isApprovedOrOwner(address spender, uint256 tokenId) internal view returns (bool) {
        require(_exists(tokenId), "ERC721: operator query for nonexistent token");
        address owner = ownerOf(tokenId);
        return (spender == owner || getApproved(tokenId) == spender || isApprovedForAll(owner, spender));
    }

    /**
     * @dev Safely mint tokens, and assign tokenHash to the new tokens
     *
     * Emits a {NewTokenHash} event.
     */
    function _safeMintWithHash(
        address to,
        uint256 numberOfNfts,
        uint256 startingTokenId
    ) internal virtual {
        for (uint256 i = 0; i < numberOfNfts; i++) {
            uint256 tokenId = startingTokenId + i;
            bytes32 tokenHash = keccak256(abi.encodePacked(tokenId, block.number, block.coinbase, block.timestamp, blockhash(block.number - 1), msg.sender));

            tokenIdToHash[tokenId] = tokenHash;

            _safeMint(to, tokenId, "");

            emit NewTokenHash(tokenId, tokenHash);
        }
    }

    /**
     * @dev Safely mints `tokenId` and transfers it to `to`.
     *
     * Requirements:
     *
     * - `tokenId` must not exist.
     * - If `to` refers to a smart contract, it must implement {IERC721Receiver-onERC721Received}, which is called upon a safe transfer.
     *
     * Emits a {Transfer} event.
     */
    function _safeMint(address to, uint256 tokenId) internal virtual {
        _safeMint(to, tokenId, "");
    }

    /**
     * @dev Same as {xref-ERC721-_safeMint-address-uint256-}[`_safeMint`], with an additional `data` parameter which is
     * forwarded in {IERC721Receiver-onERC721Received} to contract recipients.
     */
    function _safeMint(
        address to,
        uint256 tokenId,
        bytes memory _data
    ) internal virtual {
        _mint(to, tokenId);
        require(_checkOnERC721Received(address(0), to, tokenId, _data), "ERC721: transfer to non ERC721Receiver implementer");
    }

    /**
     * @dev Mints `tokenId` and transfers it to `to`.
     *
     * WARNING: Usage of this method is discouraged, use {_safeMint} whenever possible
     *
     * Requirements:
     *
     * - `tokenId` must not exist.
     * - `to` cannot be the zero address.
     *
     * Emits a {Transfer} event.
     */
    function _mint(address to, uint256 tokenId) internal virtual {
        require(to != address(0), "ERC721: mint to the zero address");
        require(!_exists(tokenId), "ERC721: token already minted");

        _beforeTokenTransfer(address(0), to, tokenId);

        _holderTokens[to].add(tokenId);

        _tokenOwners.set(tokenId, to);

        emit Transfer(address(0), to, tokenId);
    }

    /**
     * @dev Destroys `tokenId`.
     * The approval is cleared when the token is burned.
     *
     * Requirements:
     *
     * - `tokenId` must exist.
     *
     * Emits a {Transfer} event.
     */
    function _burn(uint256 tokenId) internal virtual {
        address owner = ownerOf(tokenId);

        _beforeTokenTransfer(owner, address(0), tokenId);

        // Clear approvals
        _approve(address(0), tokenId);

        _holderTokens[owner].remove(tokenId);

        // Burn the token by reassigning owner to the null address
        _tokenOwners.set(tokenId, address(0));

        emit Transfer(owner, address(0), tokenId);
    }

    /**
     * @dev Transfers `tokenId` from `from` to `to`.
     *  As opposed to {transferFrom}, this imposes no restrictions on msg.sender.
     *
     * Requirements:
     *
     * - `to` cannot be the zero address.
     * - `tokenId` token must be owned by `from`.
     *
     * Emits a {Transfer} event.
     */
    function _transfer(
        address from,
        address to,
        uint256 tokenId
    ) internal virtual {
        require(ownerOf(tokenId) == from, "ERC721: transfer of token that is not own");
        require(to != address(0), "ERC721: transfer to the zero address");

        _beforeTokenTransfer(from, to, tokenId);

        // Clear approvals from the previous owner
        _approve(address(0), tokenId);

        _holderTokens[from].remove(tokenId);
        _holderTokens[to].add(tokenId);

        _tokenOwners.set(tokenId, to);

        emit Transfer(from, to, tokenId);
    }

    /**
     * @dev Internal function to invoke {IERC721Receiver-onERC721Received} on a target address.
     * The call is not executed if the target address is not a contract.
     *
     * @param from address representing the previous owner of the given token ID
     * @param to target address that will receive the tokens
     * @param tokenId uint256 ID of the token to be transferred
     * @param _data bytes optional data to send along with the call
     * @return bool whether the call correctly returned the expected magic value
     */
    function _checkOnERC721Received(
        address from,
        address to,
        uint256 tokenId,
        bytes memory _data
    ) private returns (bool) {
        if (!to.isContract()) {
            return true;
        }
        bytes memory returndata = to.functionCall(abi.encodeWithSelector(IERC721Receiver(to).onERC721Received.selector, msg.sender, from, tokenId, _data), "ERC721: transfer to non ERC721Receiver implementer");
        bytes4 retval = abi.decode(returndata, (bytes4));
        return (retval == _ERC721_RECEIVED);
    }

    function _approve(address to, uint256 tokenId) private {
        _tokenApprovals[tokenId] = to;
        emit Approval(ownerOf(tokenId), to, tokenId);
    }

    /**
     * @dev Hook that is called before any token transfer. This includes minting
     * and burning.
     *
     * Calling conditions:
     *
     * - When `from` and `to` are both non-zero, ``from``'s `tokenId` will be
     * transferred to `to`.
     * - When `from` is zero, `tokenId` will be minted for `to`.
     * - When `to` is zero, ``from``'s `tokenId` will be burned.
     * - `from` cannot be the zero address.
     * - `to` cannot be the zero address.
     *
     * To learn more about hooks, head to xref:ROOT:extending-contracts.adoc#using-hooks[Using Hooks].
     */
    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 tokenId
    ) internal virtual {}

    /**
     * @dev Deployer parameters
     */
    function deployerSetParam(uint256 key, uint256 value) external onlyDeployer {
        require(!contractSealed, "Contract sealed");

        if (key == 0) {
            EARLY_ACCESS_START_TIMESTAMP = value;
        } else if (key == 1) {
            SALE_START_TIMESTAMP = value;
        } else if (key == 2) {
            SALE_DURATION = value;
        } else if (key == 3) {
            SALE_DURATION_SEC_PER_STEP = value;
        } else if (key == 10) {
            EARLY_ACCESS_MINT_FEE = value;
        } else if (key == 11) {
            DUTCH_AUCTION_START_FEE = value;
        } else if (key == 12) {
            DUTCH_AUCTION_END_FEE = value;
        } else if (key == 20) {
            POCHI_ACTION_PUBLIC_FEE = value;
        } else if (key == 21) {
            POCHI_ACTION_OWNER_FEE = value;
        } else {
            revert();
        }
    }

    /**
     * @dev Add to the early access list
     */
    function deployerAddEarlyAccess(address[] calldata recipients, uint256[] calldata limits) external onlyDeployer {
        require(!contractSealed, "Contract sealed");

        for (uint256 i = 0; i < recipients.length; i++) {
            require(recipients[i] != address(0), "Can't add the null address");

            earlyAccessList[recipients[i]] = limits[i];
        }
    }

    /**
     * @dev Remove from the early access list
     */
    function deployerRemoveEarlyAccess(address[] calldata recipients) external onlyDeployer {
        require(!contractSealed, "Contract sealed");

        for (uint256 i = 0; i < recipients.length; i++) {
            require(recipients[i] != address(0), "Can't remove the null address");

            earlyAccessList[recipients[i]] = 0;
        }
    }

    /**
     * @dev Reserve dev tokens and air drop tokens to craft ham holders
     */
    function deployerMintMultiple(address[] calldata recipients) external payable onlyDeployer {
        require(!contractSealed, "Contract sealed");

        uint256 total = totalSupply();
        require(total + recipients.length <= MAX_NFT_SUPPLY, "Sold out");

        for (uint256 i = 0; i < recipients.length; i++) {
            require(recipients[i] != address(0), "Can't mint to null address");

            _safeMintWithHash(recipients[i], 1, total + i);
        }
    }

    /**
     * @dev Deployer withdraws ether from this contract
     */
    function deployerWithdraw(uint256 amount) external onlyDeployer {
        (bool success, ) = msg.sender.call{value: amount}("");
        require(success, "Transfer failed.");
    }

    /**
     * @dev Deployer withdraws ERC20s
     */
    function deployerWithdraw20(IERC20 token) external onlyDeployer {
        if (address(token) == 0x0000000000000000000000000000000000000000) {
            payable(owner()).transfer(address(this).balance);
            (bool success, ) = owner().call{value: address(this).balance}("");
            require(success, "Transfer failed.");
        } else {
            token.transfer(owner(), token.balanceOf(address(this)));
        }
    }

    /**
     * @dev Deployer sets baseURI
     */
    function deployerSetBaseURI(string memory finalBaseURI) external onlyDeployer {
        _setBaseURI(finalBaseURI);
    }

    /**
     * @dev Deployer sets PROVENANCE
     */
    function deployerSetProvenance(string memory finalProvenance) external onlyDeployer {
        require(!contractSealed, "Contract sealed");
        PROVENANCE = finalProvenance;
    }

    /**
     * @dev Seal this contract
     */
    function deployerSealContract() external onlyDeployer {
        require(bytes(PROVENANCE).length != 0, "PROVENANCE must be set first");
        contractSealed = true;
    }
}