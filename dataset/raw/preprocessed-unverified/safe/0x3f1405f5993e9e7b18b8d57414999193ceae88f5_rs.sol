/**
 *Submitted for verification at Etherscan.io on 2020-12-05
*/

// SPDX-License-Identifier: MIT

pragma solidity 0.6.12;

// File: @openzeppelin/contracts/GSN/Context.sol

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

// File: @openzeppelin/contracts/introspection/IERC165.sol

/**
 * @dev Interface of the ERC165 standard, as defined in the
 * https://eips.ethereum.org/EIPS/eip-165[EIP].
 *
 * Implementers can declare support of contract interfaces, which can then be
 * queried by others ({ERC165Checker}).
 *
 * For an implementation, see {ERC165}.
 */


// File: @openzeppelin/contracts/token/ERC721/IERC721.sol

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

// File: @openzeppelin/contracts/token/ERC721/IERC721Metadata.sol

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

    /**
     * @dev Returns the Uniform Resource Identifier (URI) for `tokenId` token.
     */
    function tokenURI(uint256 tokenId) external view returns (string memory);
}

// File: @openzeppelin/contracts/token/ERC721/IERC721Enumerable.sol

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

// File: @openzeppelin/contracts/token/ERC721/IERC721Receiver.sol

/**
 * @title ERC721 token receiver interface
 * @dev Interface for any contract that wants to support safeTransfers
 * from ERC721 asset contracts.
 */


// File: @openzeppelin/contracts/introspection/ERC165.sol

/**
 * @dev Implementation of the {IERC165} interface.
 *
 * Contracts may inherit from this and call {_registerInterface} to declare
 * their support of an interface.
 */
abstract contract ERC165 is IERC165 {
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

// File: @openzeppelin/contracts/math/SafeMath.sol

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


// File: @openzeppelin/contracts/utils/Address.sol

/**
 * @dev Collection of functions related to the address type
 */


// File: @openzeppelin/contracts/utils/EnumerableSet.sol

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


// File: @openzeppelin/contracts/utils/EnumerableMap.sol

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


// File: @openzeppelin/contracts/utils/Strings.sol

/**
 * @dev String operations.
 */


// File: @openzeppelin/contracts/token/ERC721/ERC721.sol

/**
 * @title ERC721 Non-Fungible Token Standard basic implementation
 * @dev see https://eips.ethereum.org/EIPS/eip-721
 */
contract ERC721 is Context, ERC165, IERC721, IERC721Metadata, IERC721Enumerable {
    using SafeMath for uint256;
    using Address for address;
    using EnumerableSet for EnumerableSet.UintSet;
    using EnumerableMap for EnumerableMap.UintToAddressMap;
    using Strings for uint256;

    // Equals to `bytes4(keccak256("onERC721Received(address,address,uint256,bytes)"))`
    // which can be also obtained as `IERC721Receiver(0).onERC721Received.selector`
    bytes4 private constant _ERC721_RECEIVED = 0x150b7a02;

    // Mapping from holder address to their (enumerable) set of owned tokens
    mapping (address => EnumerableSet.UintSet) private _holderTokens;

    // Enumerable mapping from token ids to their owners
    EnumerableMap.UintToAddressMap private _tokenOwners;

    // Mapping from token ID to approved address
    mapping (uint256 => address) private _tokenApprovals;

    // Mapping from owner to operator approvals
    mapping (address => mapping (address => bool)) private _operatorApprovals;

    // Token name
    string private _name;

    // Token symbol
    string private _symbol;

    // Optional mapping for token URIs
    mapping (uint256 => string) private _tokenURIs;

    // Base URI
    string private _baseURI;

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
     *     bytes4(keccak256('tokenURI(uint256)')) == 0xc87b56dd
     *
     *     => 0x06fdde03 ^ 0x95d89b41 ^ 0xc87b56dd == 0x5b5e139f
     */
    bytes4 private constant _INTERFACE_ID_ERC721_METADATA = 0x5b5e139f;

    /*
     *     bytes4(keccak256('totalSupply()')) == 0x18160ddd
     *     bytes4(keccak256('tokenOfOwnerByIndex(address,uint256)')) == 0x2f745c59
     *     bytes4(keccak256('tokenByIndex(uint256)')) == 0x4f6ccce7
     *
     *     => 0x18160ddd ^ 0x2f745c59 ^ 0x4f6ccce7 == 0x780e9d63
     */
    bytes4 private constant _INTERFACE_ID_ERC721_ENUMERABLE = 0x780e9d63;

    /**
     * @dev Initializes the contract by setting a `name` and a `symbol` to the token collection.
     */
    constructor (string memory name_, string memory symbol_) public {
        _name = name_;
        _symbol = symbol_;

        // register the supported interfaces to conform to ERC721 via ERC165
        _registerInterface(_INTERFACE_ID_ERC721);
        _registerInterface(_INTERFACE_ID_ERC721_METADATA);
        _registerInterface(_INTERFACE_ID_ERC721_ENUMERABLE);
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
    function name() public view override returns (string memory) {
        return _name;
    }

    /**
     * @dev See {IERC721Metadata-symbol}.
     */
    function symbol() public view override returns (string memory) {
        return _symbol;
    }

    /**
     * @dev See {IERC721Metadata-tokenURI}.
     */
    function tokenURI(uint256 tokenId) public view override returns (string memory) {
        require(_exists(tokenId), "ERC721Metadata: URI query for nonexistent token");

        string memory _tokenURI = _tokenURIs[tokenId];

        // If there is no base URI, return the token URI.
        if (bytes(_baseURI).length == 0) {
            return _tokenURI;
        }
        // If both are set, concatenate the baseURI and tokenURI (via abi.encodePacked).
        if (bytes(_tokenURI).length > 0) {
            return string(abi.encodePacked(_baseURI, _tokenURI));
        }
        // If there is a baseURI but no tokenURI, concatenate the tokenID to the baseURI.
        return string(abi.encodePacked(_baseURI, tokenId.toString()));
    }

    /**
    * @dev Returns the base URI set via {_setBaseURI}. This will be
    * automatically added as a prefix in {tokenURI} to each token's URI, or
    * to the token ID if no specific URI is set for that token ID.
    */
    function baseURI() public view returns (string memory) {
        return _baseURI;
    }

    /**
     * @dev See {IERC721Enumerable-tokenOfOwnerByIndex}.
     */
    function tokenOfOwnerByIndex(address owner, uint256 index) public view override returns (uint256) {
        return _holderTokens[owner].at(index);
    }

    /**
     * @dev See {IERC721Enumerable-totalSupply}.
     */
    function totalSupply() public view override returns (uint256) {
        // _tokenOwners are indexed by tokenIds, so .length() returns the number of tokenIds
        return _tokenOwners.length();
    }

    /**
     * @dev See {IERC721Enumerable-tokenByIndex}.
     */
    function tokenByIndex(uint256 index) public view override returns (uint256) {
        (uint256 tokenId, ) = _tokenOwners.at(index);
        return tokenId;
    }

    /**
     * @dev See {IERC721-approve}.
     */
    function approve(address to, uint256 tokenId) public virtual override {
        address owner = ownerOf(tokenId);
        require(to != owner, "ERC721: approval to current owner");

        require(_msgSender() == owner || isApprovedForAll(owner, _msgSender()),
            "ERC721: approve caller is not owner nor approved for all"
        );

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
    function setApprovalForAll(address operator, bool approved) public virtual override {
        require(operator != _msgSender(), "ERC721: approve to caller");

        _operatorApprovals[_msgSender()][operator] = approved;
        emit ApprovalForAll(_msgSender(), operator, approved);
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
    function transferFrom(address from, address to, uint256 tokenId) public virtual override {
        //solhint-disable-next-line max-line-length
        require(_isApprovedOrOwner(_msgSender(), tokenId), "ERC721: transfer caller is not owner nor approved");

        _transfer(from, to, tokenId);
    }

    /**
     * @dev See {IERC721-safeTransferFrom}.
     */
    function safeTransferFrom(address from, address to, uint256 tokenId) public virtual override {
        safeTransferFrom(from, to, tokenId, "");
    }

    /**
     * @dev See {IERC721-safeTransferFrom}.
     */
    function safeTransferFrom(address from, address to, uint256 tokenId, bytes memory _data) public virtual override {
        require(_isApprovedOrOwner(_msgSender(), tokenId), "ERC721: transfer caller is not owner nor approved");
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
    function _safeTransfer(address from, address to, uint256 tokenId, bytes memory _data) internal virtual {
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
     * @dev Safely mints `tokenId` and transfers it to `to`.
     *
     * Requirements:
     d*
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
    function _safeMint(address to, uint256 tokenId, bytes memory _data) internal virtual {
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

        // Clear metadata (if any)
        if (bytes(_tokenURIs[tokenId]).length != 0) {
            delete _tokenURIs[tokenId];
        }

        _holderTokens[owner].remove(tokenId);

        _tokenOwners.remove(tokenId);

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
    function _transfer(address from, address to, uint256 tokenId) internal virtual {
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
     * @dev Sets `_tokenURI` as the tokenURI of `tokenId`.
     *
     * Requirements:
     *
     * - `tokenId` must exist.
     */
    function _setTokenURI(uint256 tokenId, string memory _tokenURI) internal virtual {
        require(_exists(tokenId), "ERC721Metadata: URI set of nonexistent token");
        _tokenURIs[tokenId] = _tokenURI;
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
     * @dev Internal function to invoke {IERC721Receiver-onERC721Received} on a target address.
     * The call is not executed if the target address is not a contract.
     *
     * @param from address representing the previous owner of the given token ID
     * @param to target address that will receive the tokens
     * @param tokenId uint256 ID of the token to be transferred
     * @param _data bytes optional data to send along with the call
     * @return bool whether the call correctly returned the expected magic value
     */
    function _checkOnERC721Received(address from, address to, uint256 tokenId, bytes memory _data)
        private returns (bool)
    {
        if (!to.isContract()) {
            return true;
        }
        bytes memory returndata = to.functionCall(abi.encodeWithSelector(
            IERC721Receiver(to).onERC721Received.selector,
            _msgSender(),
            from,
            tokenId,
            _data
        ), "ERC721: transfer to non ERC721Receiver implementer");
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
    function _beforeTokenTransfer(address from, address to, uint256 tokenId) internal virtual { }
}

// File: @openzeppelin/contracts/token/ERC20/IERC20.sol

/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
 */


// File: @openzeppelin/contracts/token/ERC20/SafeERC20.sol

/**
 * @title SafeERC20
 * @dev Wrappers around ERC20 operations that throw on failure (when the token
 * contract returns false). Tokens that return no value (and instead revert or
 * throw on failure) are also supported, non-reverting calls are assumed to be
 * successful.
 * To use this library you can add a `using SafeERC20 for IERC20;` statement to your contract,
 * which allows you to call the safe operations as `token.safeTransfer(...)`, etc.
 */


// File: @openzeppelin/contracts/access/Ownable.sol

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
abstract contract Ownable is Context {
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

// File: contracts/lib/Roles.sol

/**
 * @title Roles
 * @dev Library for managing addresses assigned to a Role.
 */


// File: contracts/lib/SignerRole.sol

contract SignerRole is Context {
    using Roles for Roles.Role;

    event SignerAdded(address indexed account);
    event SignerRemoved(address indexed account);

    Roles.Role private _signers;

    constructor () internal {
        _addSigner(_msgSender());
    }

    modifier onlySigner() {
        require(isSigner(_msgSender()), "SignerRole: caller does not have the Signer role");
        _;
    }

    function isSigner(address account) public view returns (bool) {
        return _signers.has(account);
    }

    function addSigner(address account) public onlySigner {
        _addSigner(account);
    }

    function renounceSigner() public {
        _removeSigner(_msgSender());
    }

    function _addSigner(address account) internal {
        _signers.add(account);
        emit SignerAdded(account);
    }

    function _removeSigner(address account) internal {
        _signers.remove(account);
        emit SignerRemoved(account);
    }
}

// File: contracts/IyYFL.sol

pragma experimental ABIEncoderV2;

interface IyYFL is IERC20 {
    // Event emitted when a new proposal is created
    event ProposalCreated(
        uint256 id,
        address indexed proposer,
        address[] targets,
        uint256[] values,
        string[] signatures,
        bytes[] calldatas,
        uint256 startBlock,
        uint256 endBlock,
        string description
    );
    // Event emitted when a vote has been cast on a proposal
    event VoteCast(address indexed voter, uint256 proposalId, bool support, uint256 votes);
    // Event emitted when a proposal has been executed
    // Success=true if all actions were executed successfully
    // Success=false if not all actions were executed successfully (executeProposal will not revert)
    event ProposalExecuted(uint256 id, bool success);

    // Maximum number of actions that can be included in a proposal
    function MAX_OPERATIONS() external pure returns (uint256);

    // https://etherscan.io/token/0x28cb7e841ee97947a86B06fA4090C8451f64c0be
    function YFL() external pure returns (IERC20);

    struct Proposal {
        // Address that created the proposal
        address proposer;
        // Number of votes in support of the proposal by a particular address
        mapping(address => uint256) forVotes;
        // Number of votes against the proposal by a particular address
        mapping(address => uint256) againstVotes;
        // Total number of votes in support of the proposal
        uint256 totalForVotes;
        // Total number of votes against the proposal
        uint256 totalAgainstVotes;
        // Number of votes in support of a proposal required for a quorum to be reached and for a vote to succeed
        uint256 quorumVotes;
        // Block at which voting ends: votes must be cast prior to this block
        uint256 endBlock;
        // Ordered list of target addresses for calls to be made on
        address[] targets;
        // Ordered list of ETH values (i.e. msg.value) to be passed to the calls to be made
        uint256[] values;
        // Ordered list of function signatures to be called
        string[] signatures;
        // Ordered list of calldata to be passed to each call
        bytes[] calldatas;
        // Flag marking whether the proposal has been executed
        bool executed;
    }

    // Number of blocks after staking when the early withdrawal fee stops applying
    function blocksForNoWithdrawalFee() external view returns (uint256);

    // Fee for withdrawing before blocksForNoWithdrawalFee have passed, divide by 1,000,000 to get decimal form
    function earlyWithdrawalFeePercent() external view returns (uint256);

    function earlyWithdrawalFeeExpiry(address) external view returns (uint256);

    function treasury() external view returns (address);

    // Share of early withdrawal fee that goes to treasury (remainder goes to governance),
    // divide by 1,000,000 to get decimal form
    function treasuryEarlyWithdrawalFeeShare() external view returns (uint256);

    // Smart contract that exchanges ERC20 tokens for YFL
    function yflPurchaser() external view returns (address);

    // Amount of an address's stake that is locked for voting
    function voteLockAmount(address) external view returns (uint256);

    // Block number when an address's vote-locked amount will be unlock
    function voteLockExpiry(address) external view returns (uint256);

    function hasActiveProposal(address) external view returns (bool);

    function proposals(uint256 id)
        external
        view
        returns (
            address proposer,
            uint256 totalForVotes,
            uint256 totalAgainstVotes,
            uint256 quorumVotes,
            uint256 endBlock,
            bool executed
        );

    // Number of proposals created, used as the id for the next proposal
    function proposalCount() external view returns (uint256);

    // Length of voting period in blocks
    function votingPeriodBlocks() external view returns (uint256);

    function minYflForProposal() external view returns (uint256);

    // Need to divide by 1,000,000
    function quorumPercent() external view returns (uint256);

    // Need to divide by 1,000,000
    function voteThresholdPercent() external view returns (uint256);

    // Number of blocks after voting ends where proposals are allowed to be executed
    function executionPeriodBlocks() external view returns (uint256);

    function stake(uint256 amount) external;

    // call this to swap token revenue to YFL for YFL stakers
    function convertTokensToYfl(address[] calldata tokens, uint256[] calldata amounts) external;

    function withdraw(uint256 shares) external;

    function getPricePerFullShare() external view returns (uint256);

    function getStakeYflValue(address staker) external view returns (uint256);

    function propose(
        address[] calldata targets,
        uint256[] calldata values,
        string[] calldata signatures,
        bytes[] calldata calldatas,
        string calldata description
    ) external returns (uint256 id);

    function vote(
        uint256 id,
        bool support,
        uint256 voteAmount
    ) external;

    function executeProposal(uint256 id) external payable;

    function getVotes(uint256 proposalId, address voter) external view returns (bool support, uint256 voteAmount);

    function getProposalCalls(uint256 proposalId)
        external
        view
        returns (
            address[] memory targets,
            uint256[] memory values,
            string[] memory signatures,
            bytes[] memory calldatas
        );

    function setTreasury(address) external;

    function setTreasuryEarlyWithdrawalFeeShare(uint256) external;

    function setYflPurchaser(address) external;

    function setBlocksForNoWithdrawalFee(uint256) external;

    function setEarlyWithdrawalFeePercent(uint256) external;

    function setVotingPeriodBlocks(uint256) external;

    function setMinYflForProposal(uint256) external;

    function setQuorumPercent(uint256) external;

    function setVoteThresholdPercent(uint256) external;

    function setExecutionPeriodBlocks(uint256) external;
}

// File: contracts/YFLArt.sol

/**
 * @title YFLArt
 * @notice The YFLArt NFT contract allows NFTs to be registered and bought
 * which are backed by a specific amount of YFL. NFTs can also optionally
 * charge a fee of any token that must be paid on purchase.
 */
contract YFLArt is ERC721, Ownable, SignerRole {
  using Address for address;
  using SafeERC20 for IERC20;

  IyYFL public immutable yYFL;
  uint256 public yflLocked;

  struct Registry {
    string tokenURI;
    address artist;
    address paymentToken;
    uint256 paymentAmount;
    uint256 yflAmount;
  }

  mapping(uint256 => Registry) public registry;
  // The YFL-backed balances of each NFT
  mapping(uint256 => uint256) public balances;

  event Registered(
    uint256 _tokenId,
    string _tokenURI,
    address _artist,
    address _paymentToken,
    uint256 _paymentAmount,
    uint256 _yflAmount
  );

  /**
   * @param _name The name of the NFT
   * @param _symbol The symbol of the NFT
   * @param _baseURI The base URI of the NFT
   * @param _yYFL The address of the yYFL governance contract
   */
  constructor(
    string memory _name,
    string memory _symbol,
    string memory _baseURI,
    address _yYFL
  )
    public
    ERC721(_name, _symbol)
  {
    yYFL = IyYFL(_yYFL);
    _setBaseURI(_baseURI);
  }

  /**
   * EXTERNAL FUNCTIONS
   * (SIGNER FUNCTIONS)
   */

  /**
   * @notice Called by a signer to register the pre-sale of an NFT
   * @param _tokenId The unique ID of the NFT
   * @param _v Recovery ID of the signer
   * @param _r First 32 bytes of the signature
   * @param _s Second 32 bytes of the signature
   * @param _tokenURI The token URI of the NFT
   * @param _artist The address of the artist
   * @param _paymentToken The address of the token for payment
   * @param _paymentAmount The amount of payment of the payment token
   * @param _yflAmount The amount of YFL backing the NFT
   */
  function signerRegister(
    uint256 _tokenId,
    uint8 _v,
    bytes32 _r,
    bytes32 _s,
    string memory _tokenURI,
    address _artist,
    address _paymentToken,
    uint256 _paymentAmount,
    uint256 _yflAmount
  )
    external
  {
    require(isSigner(ecrecover(
        keccak256(abi.encodePacked("\x19Ethereum Signed Message:\n32",
        keccak256(abi.encodePacked(_tokenId)))), _v, _r, _s)),
      "!signer");
    _register(_tokenId, _tokenURI, _artist, _paymentToken, _paymentAmount, _yflAmount);
  }

  /**
   * EXTERNAL FUNCTIONS
   * (OWNER FUNCTIONS)
   */

  /**
   * @notice Recovers stuck tokens from this contract. Does not allow pulling locked YFL out.
   * @param _token The token to withdraw
   * @param _receiver The address to receive the token
   * @param _amount The amount of tokens to withdraw
   */
  function recoverStuckTokens(IERC20 _token, address _receiver, uint256 _amount) external onlyOwner() {
    if (address(_token) == address(yYFL.YFL())) {
      require(_amount <= yYFL.YFL().balanceOf(address(this)).sub(yflLocked), "!_amount");
    }
    _token.safeTransfer(_receiver, _amount);
  }

  /**
   * @notice Called by the owner to register the pre-sale of an NFT
   * @param _tokenId The unique ID of the NFT
   * @param _tokenURI The token URI of the NFT
   * @param _artist The address of the artist
   * @param _paymentToken The address of the token for payment
   * @param _paymentAmount The amount of payment of the payment token
   * @param _yflAmount The amount of YFL backing the NFT
   */
  function register(
    uint256 _tokenId,
    string memory _tokenURI,
    address _artist,
    address _paymentToken,
    uint256 _paymentAmount,
    uint256 _yflAmount
  )
    external
    onlyOwner()
  {
    _register(_tokenId, _tokenURI, _artist, _paymentToken, _paymentAmount, _yflAmount);
  }

  /**
   * @notice Called by the owner to set the baseURI of the NFT
   * @param _baseURI The base URI of the NFT
   */
  function setBaseURI(string memory _baseURI) external onlyOwner() {
    _setBaseURI(_baseURI);
  }

  /**
   * EXTERNAL FUNCTIONS
   * (USER FUNCTIONS)
   */

  /**
   * @notice Called by a user to buy a registered NFT
   * @param _tokenId The ID of the registered NFT
   */
  function buy(
    uint256 _tokenId
  )
    external
  {
    Registry memory token = registry[_tokenId];
    require(token.yflAmount > 0, "!registered");
    yYFL.YFL().safeTransferFrom(msg.sender, address(this), token.yflAmount);
    IERC20(token.paymentToken).safeTransferFrom(msg.sender, address(this), token.paymentAmount);
    uint256 serviceFee = token.paymentAmount.div(100).mul(80);
    uint256 artistFee = token.paymentAmount.sub(serviceFee);
    IERC20(token.paymentToken).safeTransfer(yYFL.treasury(), serviceFee);
    IERC20(token.paymentToken).safeTransfer(token.artist, artistFee);
    balances[_tokenId] = token.yflAmount;
    yflLocked = yflLocked.add(token.yflAmount);
    _mint(msg.sender, _tokenId);
    _setTokenURI(_tokenId, token.tokenURI);
  }

  /**
   * @notice Called by the owner of the NFT to stake the backed YFL in governance
   * @param _tokenId The ID of the registered NFT
   */
  function stake(uint256 _tokenId) external {
    require(msg.sender == ownerOf(_tokenId), "!ownerOf");
    uint256 amount = balances[_tokenId];
    require(amount > 0, "staked");
    delete balances[_tokenId];
    yflLocked = yflLocked.sub(amount);
    uint256 shares = _stake(amount);
    IERC20(yYFL).safeTransfer(msg.sender, shares);
  }

  /**
   * @notice Called by the owner of the NFT to unstake the backed YFL from governance
   * @param _tokenId The ID of the registered NFT
   */
  function unstake(uint256 _tokenId) external {
    require(msg.sender == ownerOf(_tokenId), "!ownerOf");
    require(!isFunded(_tokenId), "funded");
    uint256 amount = registry[_tokenId].yflAmount;
    balances[_tokenId] = amount;
    yflLocked = yflLocked.add(amount);
    IERC20(yYFL).safeTransferFrom(msg.sender, address(this), amount);
    yYFL.withdraw(amount);
    uint256 balanceDiff = yYFL.YFL().balanceOf(address(this)).sub(amount);
    if (balanceDiff > 0) {
      yYFL.YFL().safeTransfer(msg.sender, balanceDiff);
    }
  }

  /**
   * PUBLIC FUNCTIONS
   * (USER FUNCTIONS)
   */

  /**
   * @notice Can be called by any address to fund an unfunded NFT with YFL
   * @param _tokenId The ID of the registered NFT
   */
  function fund(uint256 _tokenId) public {
    require(_exists(_tokenId), "!exists");
    require(!isFunded(_tokenId), "isFunded");
    uint256 amount = registry[_tokenId].yflAmount;
    balances[_tokenId] = amount;
    yflLocked = yflLocked.add(amount);
    yYFL.YFL().safeTransferFrom(msg.sender, address(this), amount);
  }

  /**
   * VIEWS
   */

  /**
   * @notice Can be called by any address to check if a NFT is funded
   * @param _tokenId The ID of the registered NFT
   */
  function isFunded(uint256 _tokenId) public view returns (bool) {
    return registry[_tokenId].yflAmount == balances[_tokenId];
  }

  /**
   * INTERNAL FUNCTIONS
   */

  /**
   * @notice This function is called before any NFT token transfer
   * @dev Requires the NFT to be backed by YFL before transferring
   */
  function _beforeTokenTransfer(
    address _from,
    address _to,
    uint256 _tokenId
  )
    internal
    override
  {
    if (!isFunded(_tokenId)) {
      fund(_tokenId);
    }
  }

  /**
   * @notice Shared register function
   */
  function _register(
    uint256 _tokenId,
    string memory _tokenURI,
    address _artist,
    address _paymentToken,
    uint256 _paymentAmount,
    uint256 _yflAmount
  )
    internal
  {
    require(!_exists(_tokenId), "exists");
    require(registry[_tokenId].yflAmount == 0, "registered");
    require(_yflAmount > 0, "!_yflAmount");
    require(_artist != address(0), "!_artist");
    registry[_tokenId] = Registry({
      tokenURI: _tokenURI,
      artist: _artist,
      paymentToken: _paymentToken,
      paymentAmount: _paymentAmount,
      yflAmount: _yflAmount
    });
    emit Registered(_tokenId, _tokenURI, _artist, _paymentToken, _paymentAmount, _yflAmount);
  }

  /**
   * @notice Internal function to help with getting shares from yYFL
   */
  function _stake(uint256 _amount) internal returns (uint256 shares) {
    yYFL.YFL().approve(address(yYFL), 0);
    yYFL.YFL().approve(address(yYFL), _amount);
    uint256 sharesBefore = yYFL.balanceOf(address(this));
    yYFL.stake(_amount);
    uint256 sharesAfter = yYFL.balanceOf(address(this));
    shares = sharesAfter.sub(sharesBefore);
  }
}