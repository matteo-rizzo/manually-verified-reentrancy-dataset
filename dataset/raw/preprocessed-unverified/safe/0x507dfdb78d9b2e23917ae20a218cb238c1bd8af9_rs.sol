/**
 *Submitted for verification at Etherscan.io on 2021-09-18
*/

// SPDX-License-Identifier: GPL

pragma solidity 0.8.0;



// Part: Base64

/*

// 'path {fill:#1c1c00;stroke:none;}'


*/

/// [MIT License]
/// @title Base64
/// @notice Provides a function for encoding some bytes in base64
/// @author Brecht Devos <[email protected]>


// Part: OpenZeppelin/[email protected]/Address

/**
 * @dev Collection of functions related to the address type
 */


// Part: OpenZeppelin/[email protected]/Context

/*
 * @dev Provides information about the current execution context, including the
 * sender of the transaction and its data. While these are generally available
 * via msg.sender and msg.data, they should not be accessed in such a direct
 * manner, since when dealing with meta-transactions the account sending and
 * paying for execution may not be the actual sender (as far as an application
 * is concerned).
 *
 * This contract is only required for intermediate, library-like contracts.
 */
abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}

// Part: OpenZeppelin/[email protected]/IERC165

/**
 * @dev Interface of the ERC165 standard, as defined in the
 * https://eips.ethereum.org/EIPS/eip-165[EIP].
 *
 * Implementers can declare support of contract interfaces, which can then be
 * queried by others ({ERC165Checker}).
 *
 * For an implementation, see {ERC165}.
 */


// Part: OpenZeppelin/[email protected]/IERC721Receiver

/**
 * @title ERC721 token receiver interface
 * @dev Interface for any contract that wants to support safeTransfers
 * from ERC721 asset contracts.
 */


// Part: OpenZeppelin/[email protected]/ReentrancyGuard

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

    constructor () {
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

// Part: OpenZeppelin/[email protected]/Strings

/**
 * @dev String operations.
 */


// Part: OpenZeppelin/[email protected]/ERC165

/**
 * @dev Implementation of the {IERC165} interface.
 *
 * Contracts that want to implement ERC165 should inherit from this contract and override {supportsInterface} to check
 * for the additional interface id that will be supported. For example:
 *
 * ```solidity
 * function supportsInterface(bytes4 interfaceId) public view virtual override returns (bool) {
 *     return interfaceId == type(MyInterface).interfaceId || super.supportsInterface(interfaceId);
 * }
 * ```
 *
 * Alternatively, {ERC165Storage} provides an easier to use but more expensive implementation.
 */
abstract contract ERC165 is IERC165 {
    /**
     * @dev See {IERC165-supportsInterface}.
     */
    function supportsInterface(bytes4 interfaceId) public view virtual override returns (bool) {
        return interfaceId == type(IERC165).interfaceId;
    }
}

// Part: OpenZeppelin/[email protected]/IERC721

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

// Part: OpenZeppelin/[email protected]/Ownable

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
    constructor () {
        address msgSender = _msgSender();
        _owner = msgSender;
        emit OwnershipTransferred(address(0), msgSender);
    }

    /**
     * @dev Returns the address of the current owner.
     */
    function owner() public view virtual returns (address) {
        return _owner;
    }

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
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

// Part: OpenZeppelin/[email protected]/IERC721Enumerable

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

// Part: OpenZeppelin/[email protected]/IERC721Metadata

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

// Part: OpenZeppelin/[email protected]/ERC721

/**
 * @dev Implementation of https://eips.ethereum.org/EIPS/eip-721[ERC721] Non-Fungible Token Standard, including
 * the Metadata extension, but not including the Enumerable extension, which is available separately as
 * {ERC721Enumerable}.
 */
contract ERC721 is Context, ERC165, IERC721, IERC721Metadata {
    using Address for address;
    using Strings for uint256;

    // Token name
    string private _name;

    // Token symbol
    string private _symbol;

    // Mapping from token ID to owner address
    mapping (uint256 => address) private _owners;

    // Mapping owner address to token count
    mapping (address => uint256) private _balances;

    // Mapping from token ID to approved address
    mapping (uint256 => address) private _tokenApprovals;

    // Mapping from owner to operator approvals
    mapping (address => mapping (address => bool)) private _operatorApprovals;

    /**
     * @dev Initializes the contract by setting a `name` and a `symbol` to the token collection.
     */
    constructor (string memory name_, string memory symbol_) {
        _name = name_;
        _symbol = symbol_;
    }

    /**
     * @dev See {IERC165-supportsInterface}.
     */
    function supportsInterface(bytes4 interfaceId) public view virtual override(ERC165, IERC165) returns (bool) {
        return interfaceId == type(IERC721).interfaceId
            || interfaceId == type(IERC721Metadata).interfaceId
            || super.supportsInterface(interfaceId);
    }

    /**
     * @dev See {IERC721-balanceOf}.
     */
    function balanceOf(address owner) public view virtual override returns (uint256) {
        require(owner != address(0), "ERC721: balance query for the zero address");
        return _balances[owner];
    }

    /**
     * @dev See {IERC721-ownerOf}.
     */
    function ownerOf(uint256 tokenId) public view virtual override returns (address) {
        address owner = _owners[tokenId];
        require(owner != address(0), "ERC721: owner query for nonexistent token");
        return owner;
    }

    /**
     * @dev See {IERC721Metadata-name}.
     */
    function name() public view virtual override returns (string memory) {
        return _name;
    }

    /**
     * @dev See {IERC721Metadata-symbol}.
     */
    function symbol() public view virtual override returns (string memory) {
        return _symbol;
    }

    /**
     * @dev See {IERC721Metadata-tokenURI}.
     */
    function tokenURI(uint256 tokenId) public view virtual override returns (string memory) {
        require(_exists(tokenId), "ERC721Metadata: URI query for nonexistent token");

        string memory baseURI = _baseURI();
        return bytes(baseURI).length > 0
            ? string(abi.encodePacked(baseURI, tokenId.toString()))
            : '';
    }

    /**
     * @dev Base URI for computing {tokenURI}. Empty by default, can be overriden
     * in child contracts.
     */
    function _baseURI() internal view virtual returns (string memory) {
        return "";
    }

    /**
     * @dev See {IERC721-approve}.
     */
    function approve(address to, uint256 tokenId) public virtual override {
        address owner = ERC721.ownerOf(tokenId);
        require(to != owner, "ERC721: approval to current owner");

        require(_msgSender() == owner || ERC721.isApprovedForAll(owner, _msgSender()),
            "ERC721: approve caller is not owner nor approved for all"
        );

        _approve(to, tokenId);
    }

    /**
     * @dev See {IERC721-getApproved}.
     */
    function getApproved(uint256 tokenId) public view virtual override returns (address) {
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
    function isApprovedForAll(address owner, address operator) public view virtual override returns (bool) {
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
    function _exists(uint256 tokenId) internal view virtual returns (bool) {
        return _owners[tokenId] != address(0);
    }

    /**
     * @dev Returns whether `spender` is allowed to manage `tokenId`.
     *
     * Requirements:
     *
     * - `tokenId` must exist.
     */
    function _isApprovedOrOwner(address spender, uint256 tokenId) internal view virtual returns (bool) {
        require(_exists(tokenId), "ERC721: operator query for nonexistent token");
        address owner = ERC721.ownerOf(tokenId);
        return (spender == owner || getApproved(tokenId) == spender || ERC721.isApprovedForAll(owner, spender));
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

        _balances[to] += 1;
        _owners[tokenId] = to;

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
        address owner = ERC721.ownerOf(tokenId);

        _beforeTokenTransfer(owner, address(0), tokenId);

        // Clear approvals
        _approve(address(0), tokenId);

        _balances[owner] -= 1;
        delete _owners[tokenId];

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
        require(ERC721.ownerOf(tokenId) == from, "ERC721: transfer of token that is not own");
        require(to != address(0), "ERC721: transfer to the zero address");

        _beforeTokenTransfer(from, to, tokenId);

        // Clear approvals from the previous owner
        _approve(address(0), tokenId);

        _balances[from] -= 1;
        _balances[to] += 1;
        _owners[tokenId] = to;

        emit Transfer(from, to, tokenId);
    }

    /**
     * @dev Approve `to` to operate on `tokenId`
     *
     * Emits a {Approval} event.
     */
    function _approve(address to, uint256 tokenId) internal virtual {
        _tokenApprovals[tokenId] = to;
        emit Approval(ERC721.ownerOf(tokenId), to, tokenId);
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
        if (to.isContract()) {
            try IERC721Receiver(to).onERC721Received(_msgSender(), from, tokenId, _data) returns (bytes4 retval) {
                return retval == IERC721Receiver(to).onERC721Received.selector;
            } catch (bytes memory reason) {
                if (reason.length == 0) {
                    revert("ERC721: transfer to non ERC721Receiver implementer");
                } else {
                    // solhint-disable-next-line no-inline-assembly
                    assembly {
                        revert(add(32, reason), mload(reason))
                    }
                }
            }
        } else {
            return true;
        }
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

// Part: OpenZeppelin/[email protected]/ERC721Enumerable

/**
 * @dev This implements an optional extension of {ERC721} defined in the EIP that adds
 * enumerability of all the token ids in the contract as well as all token ids owned by each
 * account.
 */
abstract contract ERC721Enumerable is ERC721, IERC721Enumerable {
    // Mapping from owner to list of owned token IDs
    mapping(address => mapping(uint256 => uint256)) private _ownedTokens;

    // Mapping from token ID to index of the owner tokens list
    mapping(uint256 => uint256) private _ownedTokensIndex;

    // Array with all token ids, used for enumeration
    uint256[] private _allTokens;

    // Mapping from token id to position in the allTokens array
    mapping(uint256 => uint256) private _allTokensIndex;

    /**
     * @dev See {IERC165-supportsInterface}.
     */
    function supportsInterface(bytes4 interfaceId) public view virtual override(IERC165, ERC721) returns (bool) {
        return interfaceId == type(IERC721Enumerable).interfaceId
            || super.supportsInterface(interfaceId);
    }

    /**
     * @dev See {IERC721Enumerable-tokenOfOwnerByIndex}.
     */
    function tokenOfOwnerByIndex(address owner, uint256 index) public view virtual override returns (uint256) {
        require(index < ERC721.balanceOf(owner), "ERC721Enumerable: owner index out of bounds");
        return _ownedTokens[owner][index];
    }

    /**
     * @dev See {IERC721Enumerable-totalSupply}.
     */
    function totalSupply() public view virtual override returns (uint256) {
        return _allTokens.length;
    }

    /**
     * @dev See {IERC721Enumerable-tokenByIndex}.
     */
    function tokenByIndex(uint256 index) public view virtual override returns (uint256) {
        require(index < ERC721Enumerable.totalSupply(), "ERC721Enumerable: global index out of bounds");
        return _allTokens[index];
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
    function _beforeTokenTransfer(address from, address to, uint256 tokenId) internal virtual override {
        super._beforeTokenTransfer(from, to, tokenId);

        if (from == address(0)) {
            _addTokenToAllTokensEnumeration(tokenId);
        } else if (from != to) {
            _removeTokenFromOwnerEnumeration(from, tokenId);
        }
        if (to == address(0)) {
            _removeTokenFromAllTokensEnumeration(tokenId);
        } else if (to != from) {
            _addTokenToOwnerEnumeration(to, tokenId);
        }
    }

    /**
     * @dev Private function to add a token to this extension's ownership-tracking data structures.
     * @param to address representing the new owner of the given token ID
     * @param tokenId uint256 ID of the token to be added to the tokens list of the given address
     */
    function _addTokenToOwnerEnumeration(address to, uint256 tokenId) private {
        uint256 length = ERC721.balanceOf(to);
        _ownedTokens[to][length] = tokenId;
        _ownedTokensIndex[tokenId] = length;
    }

    /**
     * @dev Private function to add a token to this extension's token tracking data structures.
     * @param tokenId uint256 ID of the token to be added to the tokens list
     */
    function _addTokenToAllTokensEnumeration(uint256 tokenId) private {
        _allTokensIndex[tokenId] = _allTokens.length;
        _allTokens.push(tokenId);
    }

    /**
     * @dev Private function to remove a token from this extension's ownership-tracking data structures. Note that
     * while the token is not assigned a new owner, the `_ownedTokensIndex` mapping is _not_ updated: this allows for
     * gas optimizations e.g. when performing a transfer operation (avoiding double writes).
     * This has O(1) time complexity, but alters the order of the _ownedTokens array.
     * @param from address representing the previous owner of the given token ID
     * @param tokenId uint256 ID of the token to be removed from the tokens list of the given address
     */
    function _removeTokenFromOwnerEnumeration(address from, uint256 tokenId) private {
        // To prevent a gap in from's tokens array, we store the last token in the index of the token to delete, and
        // then delete the last slot (swap and pop).

        uint256 lastTokenIndex = ERC721.balanceOf(from) - 1;
        uint256 tokenIndex = _ownedTokensIndex[tokenId];

        // When the token to delete is the last token, the swap operation is unnecessary
        if (tokenIndex != lastTokenIndex) {
            uint256 lastTokenId = _ownedTokens[from][lastTokenIndex];

            _ownedTokens[from][tokenIndex] = lastTokenId; // Move the last token to the slot of the to-delete token
            _ownedTokensIndex[lastTokenId] = tokenIndex; // Update the moved token's index
        }

        // This also deletes the contents at the last position of the array
        delete _ownedTokensIndex[tokenId];
        delete _ownedTokens[from][lastTokenIndex];
    }

    /**
     * @dev Private function to remove a token from this extension's token tracking data structures.
     * This has O(1) time complexity, but alters the order of the _allTokens array.
     * @param tokenId uint256 ID of the token to be removed from the tokens list
     */
    function _removeTokenFromAllTokensEnumeration(uint256 tokenId) private {
        // To prevent a gap in the tokens array, we store the last token in the index of the token to delete, and
        // then delete the last slot (swap and pop).

        uint256 lastTokenIndex = _allTokens.length - 1;
        uint256 tokenIndex = _allTokensIndex[tokenId];

        // When the token to delete is the last token, the swap operation is unnecessary. However, since this occurs so
        // rarely (when the last minted token is burnt) that we still do the swap here to avoid the gas cost of adding
        // an 'if' statement (like in _removeTokenFromOwnerEnumeration)
        uint256 lastTokenId = _allTokens[lastTokenIndex];

        _allTokens[tokenIndex] = lastTokenId; // Move the last token to the slot of the to-delete token
        _allTokensIndex[lastTokenId] = tokenIndex; // Update the moved token's index

        // This also deletes the contents at the last position of the array
        delete _allTokensIndex[tokenId];
        _allTokens.pop();
    }
}

// File: AdventureDogs.sol

contract AdventureDogs is ERC721Enumerable, ReentrancyGuard, Ownable {
    using Strings for uint256;

    string[] private _evil_dog_prefix = [
        "Disloyal",
        "Possessed",
        "Vengeful",
        "Marauding",
        "Grim",
        "Malicious",
        "Zombie",
        "Murderous",
        "Scheming",
        "Frenzied",
        "Demonic"
    ];

    string[] private _neutral_dog_prefix = [
        "Cantankerous",
        "Short",
        "Muscular",
        "Sloppy",
        "Wet",
        "Slobbery",
        "Stinky",
        "Eager",
        "Stretched",
        "Wrinkly",
        "Chubby",
        "Malnourished",
        "Slender",
        "Youthful",
        "Sleepy",
        "Anxious",
        "Protective",
        "Over-protective",
        "Sleek",
        "Catatonic",
        "Goofy",
        "Fanciful",
        "Pitiful",
        "Feral",
        "Flea bitten",
        "Ravenous",
        "Shaggy",
        "Ecstatic",
        "Mongrel",
        "Alert",
        "Drowsy",
        "Three headed",
        "Pregnant",
        "Salacious",
        "Gossipy",
        "Hesitant",
        "Incontinent",
        "Shameful",
        "Lost",
        "Stoic",
        "Ethereal",
        "Spoiled",
        "Comfort seeking",
        "Stubborn",
        "Immortal",
        "Amoral"
    ];

    string[] private _good_dog_prefix = [
        "Loyal",
        "Wise",
        "Gentle",
        "Cuddly",
        "Priestly",
        "Majestic",
        "Beautiful",
        "Supernatural",
        "Benevolent",
        "Friendly",
        "Divine"
    ];


    string[] private _dog_type = [
        "hound",
        "greyhound",
        "mongrel",
        "spaniel",
        "cur",
        "demi-wolf",
        "wolf",
        "guard dog",
        "sheepdog",
        "terrier",
        "lap dog",
        "doge",
        "mutt",
        "retriever",
        "chihuahua",
        "cat in a dog costume",
        "corgi",
        "collie",
        "husky",
        "mastiff",
        "puppy",
        "water dog",
        "hell hound",
        "poodle",
        "basenji",
        "dingo"
    ];


    string[] private _movement_prefix = [
        "Trackless",
        "Pristine",
        "Careful",
        "Careless",
        "Enthusiastic",
        "Leggy",
        "Sloppy",
        "Meandering",
        "Stumbling",
        "Purposeful",
        "Stealthy",
        "Loping",
        "Steady",
        "Boastful",
        "Obsequious",
        "Mischievous",
        "Low",
        "Worried",
        "Waggling",
        "Lethal",
        "Dramatic",
        "Relentless",
        "Awe inspiring",
        "Woeful",
        "Backwards",
        "Lolling",
        "Stately",
        "Elegant",
        "Commonplace",
        "High-stepping",
        "Carefree",
        "Cautious",
        "Decisive",
        "Unhurried",
        "Swift",
        "Dignified",
        "Doddering",
        "Sickly",
        "Steady",
        "Brisk",
        "Menacing",
        "Ominous",
        "Lecherous",
        "Springing",
        "Stiff",
        "Righteous",
        "Indignant"
    ];

    string[] private _movement_type = [
        "waddle",
        "butt waddle",
        "prance",
        "shuffle",
        "frollick",
        "leap",
        "bound",
        "march",
        "creep",
        "waggle",
        "plod",
        "stagger",
        "saunter",
        "gallop",
        "limp",
        "promenade",
        "dance",
        "bodyslam",
        "chase",
        "trot",
        "blunder",
        "stride",
        "lurch",
        "prowl",
        "amble",
        "pounce",
        "stomp",
        "sprint"
    ];

    string[] private _good_sound_prefix = [
        "Other-worldly",
        "Blissful",
        "Soothing",
        "Enchanting",
        "Healing",
        "Melodious"
    ];


    string[] private _evil_sound_prefix = [
        "Screeching",
        "Intimidating",
        "Deranged",
        "Demoralizing",
        "Cacophonous",
        "Forboding"
    ];

    string[] private _neutral_sound_prefix = [
        "Humble",
        "Deafening",
        "Inaudible",
        "Proud",
        "Didactic",
        "Dry",
        "Sardonic",
        "Wistful",
        "Weary",
        "Fearful",
        "Quiet",
        "Loud",
        "Fearless",
        "Hushed",
        "Muted",
        "Raucous",
        "Enthusiastic",
        "Emotional",
        "Woeful",
        "Anxious",
        "Reasonable",
        "Understated",
        "Underhanded",
        "Worrisome",
        "Boisterous",
        "Ear-splitting",
        "Philosophical",
        "Frenzied",
        "Desperate",
        "Pleading",
        "Masterful",
        "Confident",
        "Demanding",
        "Decisive",
        "Indecipherable",
        "Grumpy",
        "Joyful",
        "Laconic",
        "Contented",
        "Rhythmic"
    ];

    string[] private _sound_type = [
        "yap",
        "yip",
        "growl",
        "simper",
        "wimper",
        "bark",
        "grumble",
        "gurgle",
        "cough",
        "whine",
        "yowl",
        "howl",
        "whisper",
        "yodel",
        "purr",
        "groan",
        "silence",
        "grunt",
        "declaration",
        "pronouncement",
        "snort",
        "chortle",
        "wheeze",
        "scream",
        "sigh",
        "cry",
        "snarl",
        "bay",
        "gasp",
        "slurp",
        "roar",
        "laugh"
    ];

    string[] private _obj_prefix = [
        "Diamond studded",
        "Fluffy",
        "Fuzzy",
        "Iridescent",
        "Lush",
        "Plush",
        "Simple",
        "Artisanal",
        "Utilitarian",
        "Degraded",
        "Faded",
        "Torn",
        "Camoflauge",
        "Phosphorescent",
        "Leather",
        "Pleather",
        "Basilisk scale",
        "Dragon scale",
        "Blessed",
        "Cursed",
        "Sentient",
        "Monogrammed",
        "Charmed",
        "Fasionable",
        "Forbidden",
        "Fancy",
        "Ostentatious",
        "Beloved",
        "Flaming"
    ];


    string[] _obj_type = [
        "chew toy",
        "bone",
        "collar",
        "leash",
        "eyepatch",
        "cone of shame",
        "bandana",
        "sweater",
        "dish",
        "ball",
        "helmet",
        "booties",
        "rain coat",
        "carcass",
        "earmuffs",
        "harness",
        "goggles",
        "diadem",
        "tiara",
        "amulet",
        "backpack",
        "bow tie",
        "hat",
        "cape",
        "satchel",
        "liatard",
        "robe",
        "false tooth",
        "vest"
    ];

    string[] private _obj_suffix = [
        "Anubis",
        "Fenrir",
        "Cerberus",
        "Ninkarrak",
        "Egalmah",
        "Sarvara",
        "Balto",
        "Hachiko",
        "Strelka",
        "Belka",
        "Laika"
    ];

    string[] private _good_action_verb = [
        "Espouses wisdom",
        "Regenerates limbs",
        "Heals mortal wounds",
        "Cures illness",
        "Lights the darkness",
        "Inspires enlightenment",
        "Relieves confusion",
        "Confers luck"
    ];


    string[] private _evil_action_verb = [
        "Consumes souls",
        "Strikes fear",
        "Foments strife",
        "Extinguishes light",
        "Defiles the innocent",
        "Accelerates aging",
        "Hypnotizes the weak",
        "Induces paralysis"
    ];

    string[] private _neutral_action_verb = [
        "Vanquishes foes",
        "Pauses time",
        "Proves theorems",
        "Reveals secrets",
        "Summons ghosts",
        "Breaks locks",
        "Tames wild beasts",
        "Feralizes pets",
        "Lights fires",
        "Extinguishes fires",
        "Alters tides",
        "Questions authority",
        "Controls ants",
        "Pacifies babies",
        "Identifies vampires",
        "Picks fights",
        "Finds psychedelic plants",
        "Composes poetry",
        "Freezes water",
        "Tells time",
        "Finds the way",
        "Uncovers treasure",
        "Inspires joy"
    ];

    string[] private _action_body_part = [
        "stare",
        "eyes",
        "bark",
        "howl",
        "claws",
        "thoughts",
        "whiskers",
        "wrinkles",
        "tail wag",
        "tail",
        "tongue",
        "nose",
        "charm",
        "gait",
        "phermones",
        "earwax",
        "poop",
        "drool",
        "pee",
        "tears",
        "mind",
        "belly",
        "spots",
        "snores",
        "butt scoot",
        "elegance"
    ];

     function pluck(
            uint256 tokenId,
            string memory keyPrefix,
            string[] memory sourceArray) internal view returns (string memory) {
        return sourceArray[uint256(keccak256(
            abi.encodePacked(
                tokenId,
                keyPrefix))) % sourceArray.length];

    }

    function getAlignmentInt(uint256 tokenId) public view returns (int) {
        uint raw_number = uint(keccak256(abi.encodePacked(tokenId, "AL"))) % 10;

        // generate -1 and +1 with probability 1/10 each and 0 with prob 8/10
        // special exceptions: multiples of 666, 777, and 770

        // Return values:
        // 1 = good
        // 0 = neutral
        // -1 = evil
        return (tokenId % 666 == 0) ? int(-1) : (
            (tokenId % 777 == 0) ? int(1) : (
                (raw_number == 0) ? int(-1) : ((raw_number == 1) ? int(1) : int(0))
            )
        );
    }

    function getAlignment(uint256 tokenId) public view returns (string memory) {
        int alignment  = getAlignmentInt(tokenId);
        return (alignment == 0) ? "neutral" : (
            (alignment == -1) ? "evil" : "good"
        );
    }

    function getDogPrefix(uint256 tokenId) public view returns (string memory)  {
        int alignment = getAlignmentInt(tokenId);
        string[] memory arr = (alignment == 0) ? _neutral_dog_prefix : (
            (alignment == -1) ? _evil_dog_prefix : _good_dog_prefix
        );
        return pluck(tokenId, "DP", arr);
     }

    function getDogType(uint256 tokenId) public view returns (string memory)  {
        return pluck(tokenId, "D", _dog_type);
    }

    function getMovementPrefix(uint256 tokenId) public view returns (string memory)  {
        return pluck(tokenId, "MP", _movement_prefix);
    }

    function getMovementType(uint256 tokenId) public view returns (string memory)  {
        return pluck(tokenId, "M", _movement_type);
    }

    /*
    function getSpeed(uint256 tokenId) public view returns (int) {
        bytes32 movement_prefix_hash = keccak256(bytes(getMovementPrefix(tokenId)));
        bytes32 movement_type_hash =  keccak256(bytes(getMovementType(tokenId)));
        int bonus = 0;
        if (
            movement_prefix_hash == keccak256("Unhurried") ||
            movement_prefix_hash == keccak256("Stumbling") ||
            movement_prefix_hash == keccak256("Doddering") ||
            movement_prefix_hash == keccak256("Sickly") ||
            movement_prefix_hash == keccak256("Meandering")
        ) { bonus -= 1; }
        else if (
            movement_prefix_hash == keccak256("Steady") ||
            movement_prefix_hash == keccak256("Swift") ||
            movement_prefix_hash == keccak256("Brisk") ||
            movement_prefix_hash == keccak256("Springing") ||
            movement_prefix_hash == keccak256("Demonic") ||
            movement_prefix_hash == keccak256("Divine")
        ) { bonus += 1; }

         if (
            movement_type_hash == keccak256("butt waddle") ||
            movement_type_hash == keccak256("creep") ||
            movement_type_hash == keccak256("stagger") ||
            movement_type_hash == keccak256("blunder") ||
            movement_type_hash == keccak256("limp")
        ) { bonus -= 1; }
        else if (
            movement_type_hash == keccak256("chase") ||
            movement_type_hash == keccak256("sprint") ||
            movement_type_hash == keccak256("gallop")

        ) { bonus += 1; }


        return 1 + bonus;
    }
    */

    function getSoundPrefix(uint256 tokenId) public view returns (string memory) {
        if (tokenId == 770) {
            return "Yeshivish";
        }
        int alignment = getAlignmentInt(tokenId);
        string[] memory arr = (alignment == 0) ? _neutral_sound_prefix : (
            (alignment == 1) ? _good_sound_prefix : _evil_sound_prefix
        );
        return pluck(tokenId, "SP", arr);
    }

    function getSoundType(uint256 tokenId) public view returns (string memory)  {
        return pluck(tokenId, "S", _sound_type);
    }

    function getObjectPrefix(uint256 tokenId) public view returns (string memory)  {
        return pluck(tokenId, "OP", _obj_prefix);
    }


    function getObjectType(uint256 tokenId) public view returns (string memory)  {
        return pluck(tokenId, "O", _obj_type);
    }

    function getObjectSuffix(uint256 tokenId) public view returns (string memory)  {
        // only attach "of X" 1 in 10 times
        if (uint256(keccak256(abi.encodePacked(tokenId, "US"))) % 10 != 0) {
            return "";
        } else {
            return pluck(tokenId, "OS", _obj_suffix);
        }

    }

    function getAction(uint256 tokenId) public view returns (string memory)  {
        int alignment = getAlignmentInt(tokenId);
        string[] memory arr = (alignment == 0) ? _neutral_action_verb : (
            (alignment == 1) ? _good_action_verb : _evil_action_verb);
        return pluck(tokenId, "A", arr);
    }

    function getActionBodyPart(uint256 tokenId) public view returns (string memory)  {
        return pluck(tokenId, "B", _action_body_part);
    }

    function tokenURI(uint256 tokenId) public view override returns (string memory) {
        bytes memory first_three_lines = abi.encodePacked(
            '<text x="16" y="35" class="bold">',
            getDogPrefix(tokenId),
            " ",
            getDogType(tokenId),
            '</text>\n<text x="16" y="65">',
            getMovementPrefix(tokenId),
            " ",
            getMovementType(tokenId),
            '</text>\n <text x="16" y="90">',
            getSoundPrefix(tokenId),
            " ",
            getSoundType(tokenId),
            '</text>\n');

        string memory suffix = getObjectSuffix(tokenId);
        bytes memory last_two_lines = abi.encodePacked(
                '<text x="16" y="115">',
                 getObjectPrefix(tokenId),
                " ",
                getObjectType(tokenId),
                (bytes(suffix).length == 0) ?  bytes("") : abi.encodePacked(" of ", suffix),
                '</text>\n <text x="16" y="140">',
                getAction(tokenId),
                " with its ",
                getActionBodyPart(tokenId),
                '</text>\n');

        bytes memory svg = abi.encodePacked(
                '<svg xmlns="http://www.w3.org/2000/svg" preserveAspectRatio="xMinYMin meet" viewBox="0 0 350 250">'
                    '<style>text{fill:#ffd0cc;font-family:serif;font-size:16px;letter-spacing:0.05em;}'
                    '.bold{font-size:24px;}'
                    '</style>'
                    '<rect width="100%" height="100%" fill="#2c2c2b"/>'
                    '<rect x="2%" y="2.8%" width="96%" height="94.4%" stroke="#515151" fill="transparent" stroke-width="2"/>\n'
                ,
                first_three_lines,
                last_two_lines,
                '</svg>');
        return string(abi.encodePacked(
            "data:application/json;base64,",
            Base64.encode(abi.encodePacked(
                '{"name": "Adventure Dog #', tokenId.toString(), '", ',
                '"description": "Every dog stands out from the pack.", ',
                '"image": "data:image/svg+xml;base64,',
                Base64.encode(svg),
                '"}'
            ))));
    }

    function mint() public payable nonReentrant {
        require(tx.origin == msg.sender);
        require(msg.value > 0, "Ether value cannot be 0");
        uint tokenId = totalSupply() + 1;
        require(tokenId > 0 && tokenId <= 5000, "Token ID invalid");
        _safeMint(_msgSender(), tokenId);
    }


    function withdraw() public onlyOwner {
        payable(0xF4303fc370C50126E2e72e8fb19aFedce6EAEFB9).transfer(address(this).balance);
    }

    constructor() ERC721("Adventure Dogs", "ADOGS") Ownable() {

    }

}