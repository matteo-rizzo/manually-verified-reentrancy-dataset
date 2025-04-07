/**
 *Submitted for verification at Etherscan.io on 2021-03-17
*/

// SPDX-License-Identifier: UNLICENSED
// produced by the Solididy File Flattener (c) David Appleton 2018 - 2020 and beyond
// contact : [emailÂ protected]
// source  : https://github.com/DaveAppleton/SolidityFlattery
// released under Apache 2.0 licence
// input  /Users/daveappleton/Documents/akombalabs/ec_traits/contracts/ethercards.sol
// flattened :  Monday, 01-Mar-21 20:16:06 UTC
pragma solidity ^0.7.3;










abstract contract Context {
    function _msgSender() internal view virtual returns (address payable) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes memory) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}





abstract contract IRNG {

    function requestRandomNumber() external virtual returns (bytes32 requestId) ;

    function isRequestComplete(bytes32 requestId) external virtual view returns (bool isCompleted) ; 

    function randomNumber(bytes32 requestId) external view virtual returns (uint256 randomNum) ;
}


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
    function supportsInterface(bytes4 interfaceId) public view virtual override returns (bool) {
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

abstract contract Pausable is Context {
    /**
     * @dev Emitted when the pause is triggered by `account`.
     */
    event Paused(address account);

    /**
     * @dev Emitted when the pause is lifted by `account`.
     */
    event Unpaused(address account);

    bool private _paused;

    /**
     * @dev Initializes the contract in unpaused state.
     */
    constructor () internal {
        _paused = false;
    }

    /**
     * @dev Returns true if the contract is paused, and false otherwise.
     */
    function paused() public view virtual returns (bool) {
        return _paused;
    }

    /**
     * @dev Modifier to make a function callable only when the contract is not paused.
     *
     * Requirements:
     *
     * - The contract must not be paused.
     */
    modifier whenNotPaused() {
        require(!paused(), "Pausable: paused");
        _;
    }

    /**
     * @dev Modifier to make a function callable only when the contract is paused.
     *
     * Requirements:
     *
     * - The contract must be paused.
     */
    modifier whenPaused() {
        require(paused(), "Pausable: not paused");
        _;
    }

    /**
     * @dev Triggers stopped state.
     *
     * Requirements:
     *
     * - The contract must not be paused.
     */
    function _pause() internal virtual whenNotPaused {
        _paused = true;
        emit Paused(_msgSender());
    }

    /**
     * @dev Returns to normal state.
     *
     * Requirements:
     *
     * - The contract must be paused.
     */
    function _unpause() internal virtual whenPaused {
        _paused = false;
        emit Unpaused(_msgSender());
    }
}

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
    function balanceOf(address owner) public view virtual override returns (uint256) {
        require(owner != address(0), "ERC721: balance query for the zero address");
        return _holderTokens[owner].length();
    }

    /**
     * @dev See {IERC721-ownerOf}.
     */
    function ownerOf(uint256 tokenId) public view virtual override returns (address) {
        return _tokenOwners.get(tokenId, "ERC721: owner query for nonexistent token");
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

        string memory _tokenURI = _tokenURIs[tokenId];
        string memory base = baseURI();

        // If there is no base URI, return the token URI.
        if (bytes(base).length == 0) {
            return _tokenURI;
        }
        // If both are set, concatenate the baseURI and tokenURI (via abi.encodePacked).
        if (bytes(_tokenURI).length > 0) {
            return string(abi.encodePacked(base, _tokenURI));
        }
        // If there is a baseURI but no tokenURI, concatenate the tokenID to the baseURI.
        return string(abi.encodePacked(base, uint256(tokenId).toString()));
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
     * @dev See {IERC721Enumerable-tokenOfOwnerByIndex}.
     */
    function tokenOfOwnerByIndex(address owner, uint256 index) public view virtual override returns (uint256) {
        return _holderTokens[owner].at(index);
    }

    /**
     * @dev See {IERC721Enumerable-totalSupply}.
     */
    function totalSupply() public view virtual override returns (uint256) {
        // _tokenOwners are indexed by tokenIds, so .length() returns the number of tokenIds
        return _tokenOwners.length();
    }

    /**
     * @dev See {IERC721Enumerable-tokenByIndex}.
     */
    function tokenByIndex(uint256 index) public view virtual override returns (uint256) {
        (uint256 tokenId, ) = _tokenOwners.at(index);
        return tokenId;
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
        return _tokenOwners.contains(tokenId);
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
        address owner = ERC721.ownerOf(tokenId); // internal owner

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
        require(ERC721.ownerOf(tokenId) == from, "ERC721: transfer of token that is not own"); // internal owner
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
        emit Approval(ERC721.ownerOf(tokenId), to, tokenId); // internal owner
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

abstract contract xERC20 {
    function transfer(address,uint256) public virtual returns (bool);
    function balanceOf(address) public view virtual returns (uint256);
}

contract ethercards is ERC721 , Ownable, Pausable{
    using Strings for uint256;
    using SafeMath for uint256;

    IRNG rng;

    enum CardType { OG, Alpha, Random, Common, Founder,  Unresolved } 

    uint256   constant oStart = 10;
    uint256   constant aStart = 100;
    uint256   constant cStart = 1000;
    uint256   constant oMax = 99;
    uint256   constant aMax = 999;
    uint256   constant cMax = 9999;

    uint256   constant tr_ass_order_length = 14;
    uint256   constant tr_ass_order_mask   = 0x3ff;

    uint256   extra_trait_offset ;



    // sale conditions
    uint256   immutable sale_start;
    uint256   immutable sale_end;

    
    bool      curve_set;


    // sold AND resolved
    uint256   public oSold;
    uint256   public aSold;
    uint256   public cSold;
    // pending resolution
    uint256   public oPending;
    uint256   public aPending;
    uint256   public cPending;
    
    uint256   public nextTokenId = 10;
    // Random Stuff
    mapping (uint256 => bytes32) public randomRequests;
    uint256                      public lastRandomRequested;
    uint256                      public lastRandomProcessed;
    uint256                      public randomOneOfEight;

    // pricing stuff
    uint256[]                   og_stop;
    uint256[]                   og_price;
    uint256[]                   alpha_stop;
    uint256[]                   alpha_price;
    uint256[]                   common_stop;
    uint256[]                   common_price;
    uint256                     og_pointer;
    uint256                     alpha_pointer;
    uint256                     common_pointer;

    address payable             wallet;


    // traits stuff
    bytes32[50] public           traitHashes;
    mapping (uint256 => uint256)  traitAssignmentOrder;
    // Validation
    uint256                     startPos;
    bytes32                     tokenIdHash;


    //mapping(uint256 => uint256) serialToTokenId;
    //mapping(uint256 => uint256) tokenIdToSerial;
    mapping(uint256 => uint256) cardTraits;
    

    bytes32      public fullTokenIDHash;
    bytes32[50]  public allTokenIDHashes;


    
    bool    presale_closed;
    bool    founders_done;
    address oracle;
    address controller;

    event OG_Ordered(address buyer, uint256 price_paid, uint256 tokenID);
    event ALPHA_Ordered(address buyer, uint256 price_paid, uint256 tokenID);
    event COMMON_Ordered(address buyer, uint256 price_paid, uint256 tokenID);

    event Resolution(uint256 tokenId,uint256 chance);

    event PresaleClosed();
    event OracleSet( address oracle);
    event ControllerSet( address oracle);
    event SaleSet(uint256 start, uint256 end);
    event RandomSet(address random);
    event HashesSet();
    
    event WheresWallet(address wallet);
    event Upgrade(uint256 tokenID, uint256 position);

    event UpgradeToOG(uint256 tokenId,uint256 pos);
    event UpgradeToAlpha(uint256 tokenId,uint256 pos);

    event TraitsClaimed(uint tokenID,uint traits);
    event TraitsAlreadyClaimed(uint tokenID);
 
    
    modifier onlyOracle() {
        require(msg.sender == oracle,"Not Authorised");
        _;
    }

    modifier onlyAllowed() {
        require(
            msg.sender == owner() ||
            msg.sender == controller,"Not Authorised");
        _;
    }

    // SECTIONS IN CAPS TO RETAIN SANITY

    // CONSTRUCTOR
    // traitHashes : hashes of 50 x 200 elements

    constructor(
        IRNG _rng, 
        uint256 _start, uint256 _end,
        address payable _wallet, address _oracle
        ) ERC721("Ether Cards Founder","ECF") {

        
        rng = _rng;
        sale_start = _start;
        sale_end = _end;
        wallet = _wallet;
        oracle = _oracle;
// need events
        emit OracleSet(_oracle);
        emit SaleSet(_start,_end);
        emit RandomSet(address(_rng));
        emit WheresWallet(_wallet);
    }

    function setTraitHashes(bytes32[50] memory _traitHashes) external onlyOwner {
        traitHashes = _traitHashes;
        emit HashesSet();
    }

    function setCurve(
        uint256[] memory _og_stop, uint256[] memory _og_price,
        uint256[] memory _alpha_stop, uint256[] memory _alpha_price,
        uint256[] memory _random_stop, uint256[] memory _random_price) external onlyOwner {
        og_stop = _og_stop;
        og_price = _og_price;
        alpha_stop = _alpha_stop;
        alpha_price = _alpha_price;
        common_stop = _random_stop;
        common_price = _random_price;
        curve_set = true;
        _setBaseURI("temp.ether.cards/metadata");
    }


    // ENTRY POINT TO SALE CONTRACT
    // 0 = OG
    // 1 = ALPHA
    // 2 = RANDOM

    event Refund(address buyer, uint sent, uint purchased, uint refund);

    function buyCard(uint card_type) external payable sale_active whenNotPaused {
        buyCardInternal(card_type);
    }


    function buyCardInternal(uint card_type) internal {
        require(curve_set,"price curve not set");
        uint balance = msg.value;
        uint price;
        require(card_type < 3, "Invalid card type");
        for (uint j = 0; j < 100; j++) {
            if (card_type == 0) {
                price = OG_price();
            }  else if (card_type == 1) {
                price =  ALPHA_price();
            } else {
                price = COMMON_price();
            }
            if (balance < price) {
                if (j == 0) require(false,"Not enough sent");
                payable(wallet).transfer(msg.value.sub(balance));
                payable(msg.sender).transfer(balance);
                emit Refund(msg.sender,msg.value, j,balance);
                return;
            }
            assignCard(msg.sender,card_type);
            balance = balance.sub(price);
        }
        payable(wallet).transfer(msg.value.sub(balance));
        payable(msg.sender).transfer(balance);
        emit Refund(msg.sender,msg.value, 100,balance);
}

    // PRESALE FUNCTIONS
    // 0 - OG
    // 1 - ALPHA
    // 2 - COMMON

    function allocateManyCards(address[] memory buyers, uint256 card_type) external onlyOwner {
        require(curve_set,"price curve not set");
         require(founders_done, "mint founders first");
        require(card_type < 3 , "Invalid Card Type");
        require(!presale_closed,"Presale is over");
        for (uint j = 0; j < buyers.length; j++) {
            assignCard(buyers[j],card_type);
        }
    }
    
    function allocateCard(address buyer, uint256 card_type) external onlyOwner {
        require(curve_set,"price curve not set");
         require(founders_done, "mint founders first");
        require(card_type < 3, "Invalid Card Type");
        require((!presale_closed) || sale_is_over() ,"Presale is over");
        assignCard(buyer,card_type);
    }

    function closePresalePartOne() external onlyOwner {
        if (randomOneOfEight % 16 > 7) {
            request_random();
        }
        if (randomOneOfEight % 16 > 0) {
            request_random();
        }
    }

    function closePresalePartTwo() external onlyOwner {
        processRand();
        presale_closed = true;
        emit PresaleClosed();
    }


    // FOUNDERS CARDS

    function mintFounders(address[10] memory founders) external onlyOwner {
        require(!founders_done, "Founders already minted");
        for (uint j = 0; j < 10; j++) {
            _mint(founders[j],j);
            traitAssignmentOrder[j] = 1;
        }
        founders_done = true;
    }

    // Extra Traits

    function setExtraTraits(uint256 tokenId, uint256 bitNumber) external onlyAllowed {
        require((bitNumber >= extra_trait_offset) && (bitNumber < 256), "illegal bit number");
        cardTraits[tokenId] |=   (1 << bitNumber);
    }

    function setExtraTraitOffset(uint256 _offset) external onlyOwner {
        require(extra_trait_offset == 0, "Extra Trait offset already set");
        extra_trait_offset = _offset;
    }

    // ORACLE ACTIVATION

    function numberPending() public view returns (uint256) {
        return oPending + cPending  +aPending;
    }

    function needProcessing() public view returns (bool) {
        uint count = 15;
        
        return (oPending + cPending  +aPending > count || nextTokenId > cMax) && randomAvailable();
    }

    event ProcessRandom();
    function processRandom() external onlyOracle {
        processRand();
    }

    function processRand() internal {
        emit ProcessRandom();
        uint random = nextRandom();
    
        uint count = 16;
        uint mask = 0xffff;
        uint shift = 16;
        
        uint pending = oPending + cPending +aPending;
        for (uint i = 0; i < count; i++) {
            if (pending-- == 0) {
                return;
            }
            resolve(random & mask);
            random = random >> shift;
        }
    }

    function setOracle(address _oracle) external onlyOwner {
        oracle = _oracle;
        emit OracleSet(_oracle);
    }

   function setController(address _controller) external onlyOwner {
        controller = _controller;
        emit ControllerSet(_controller);
    }

    // WEB3 SALE SUPPORT


    function OG_remaining() public view returns (uint256) {
        return oMax - (oStart + oSold + oPending)+1;
    }

    function ALPHA_remaining() public view returns (uint256) {
        return aMax - (aStart + aSold + aPending)+1;
    }

    function COMMON_remaining() public view returns (uint256) {
        return cMax - (cStart + cSold + cPending)+1;
    }

    function OG_price() public view returns (uint256) {
        require(OG_remaining() > 0,"OG Cards sold out"); 
        return og_price[og_pointer];
    }

    function ALPHA_price() public view returns (uint256) {
        require(ALPHA_remaining() > 0,"Alpha Cards sold out"); 
        return alpha_price[alpha_pointer];        
    }

    function COMMON_price() public view returns (uint256) {
        require(COMMON_remaining() > 0,"Random Cards sold out"); 
        return common_price[common_pointer];
    }

    modifier sale_active() {
        require(block.timestamp >= sale_start,"Sale not started");
        require(block.timestamp <= sale_end,"Sale ended");
        require(nextTokenId <= cMax, "Sorry. Sold out");
        _;
    }


    function request_random_if_needed() internal {

        if (randomOneOfEight++ % 16 == 15) {
            request_random();
        }

    }

 
    function assignCard(address buyer, uint256 card_type) internal {
        require(curve_set,"price curve not set");
        
        uint common_remaining = COMMON_remaining();
        uint alpha_remaining = ALPHA_remaining();
        request_random_if_needed();
        if (card_type == 2) {
            require(common_remaining > 0, "Sorry no random tickets available");
            uint cSum = cStart+cSold+cPending;
            _mint(buyer,cSum);
            cPending++;
            common_pointer = bump(cSold , cPending , common_stop,common_pointer);
            emit COMMON_Ordered(msg.sender, msg.value,cSum);
            return;
        } else if (card_type == 1)  {
            require (alpha_remaining > 0,"Sorry - no Alpha tickets available");
            uint aSum =aStart+aSold+aPending;
            _mint(buyer,aSum);
            emit ALPHA_Ordered(msg.sender, msg.value,aSum);
            aPending++;
            alpha_pointer = bump(aSold , aPending , alpha_stop,alpha_pointer);
            return;
        }
        require (OG_remaining() > 0, "Sorry, no OG cards available");
        uint oSum = oStart + oSold+oPending;
        _mint(buyer,oSum);
        emit OG_Ordered(msg.sender, msg.value,oSum);
        oPending++;
        og_pointer = bump(oSold,oPending,og_stop,og_pointer);
        return;
    }
 
   function resolve(uint256 random) internal {
        //bool upgrade;
        uint256 card_pos;
        //uint256 draw_pos;  // let's not get them confused
        uint256 r = random;
        if (cPending > 0) {
            card_pos = cStart + cSold++;
            cPending--;
        } else if (aPending > 0) {
            card_pos = aStart + aSold++;
            aPending--;
        } else if (oPending > 0) {
            card_pos = oStart+oSold++;
            oPending--;
        }   else {
            return; // NOTHING TO DO
        }
        uint256 chance = (r & tr_ass_order_mask)+1;       
        traitAssignmentOrder[card_pos] = chance;
        emit Resolution(card_pos,chance);
    }

    function bump(uint sold, uint pending, uint[] memory stop, uint pointer) internal pure returns (uint256) {
        if (pointer == stop.length - 1) return pointer; 
        if (sold + pending > stop[pointer]) {
            return pointer + 1;
        }
        return pointer;
    }
    
    function mintTheRest(uint card_type, address target) external onlyOwner {
        require(sale_is_over(), "not until it's over");
        require(card_type < 3,"invalid card type");
        uint remaining;
        uint toMint = 50;
        if (card_type == 0) remaining = OG_remaining();
        else if (card_type == 1) remaining = ALPHA_remaining();
        else if (card_type == 2) {
            remaining = COMMON_remaining();
            toMint = 30;
        }
        remaining = Math.min(remaining,toMint);
        for (uint j = 0; j < remaining; j++) {
            assignCard(target,card_type);
        }
    }


  
    function setSimpleHash200(uint pos,bytes32 hashX) external onlyAllowed {        
        allTokenIDHashes[pos] = hashX;
    }

    function hash10k(uint256[10000] memory data) public pure returns (bytes32) {
        return keccak256(abi.encodePacked(data));
    }

    function hash200(uint256[200] memory data) public pure returns (bytes32) {
        return keccak256(abi.encodePacked(data));
    }

    // ensures that the hashes are all correct
    function checkSimpleHash200( uint[10000] calldata input) public view returns (bool) {
        uint256[200] memory data;
        for (uint pos = 0; pos < 50; pos++){  
            for (uint j = 0; j < 200; j++) {
                data[j] = input[j+pos*200];
            }
            bytes32 h32 = hash200(data);
            if(allTokenIDHashes[pos]!= h32) {
                return (false);
            }
        }
        return (true);
    }

    function getTokenIDPosition(uint tokenID, uint[10000] calldata tokenIdArray) external pure returns (uint blockOf200, uint position) {
        for (uint j = 0; j < 100000; j++) {
            if (tokenID == tokenIdArray[j]) 
                return (j/200,j%200);
        }
        require(false,"Not Found");
    }

    function verifyTokenAt(uint256 position, uint[10000] calldata tokenIdArray) public view returns (bool) {
        require (position < 10000,"invalid position") ;
        if (position < 11) return true; // founder or first OG
        if (position == 100) return true; // First Alpha
        if (position == 1000) return true; // First Common
        uint tokenId = tokenIdArray[position];
        uint prevToken = tokenIdArray[position-1];
        require(_exists(tokenId),"Token does not exist");
        require(_exists(prevToken),"Prev Token does not exist");
        require(cardType(tokenId) == cardType(prevToken),"different types of card");
        if (traitAssignmentOrder[tokenId] > traitAssignmentOrder[prevToken]) return true;
        if (traitAssignmentOrder[tokenId] < traitAssignmentOrder[prevToken]) return false;
        return (tokenId > prevToken );
    }

    function revealTokenAt(uint256 hashBlock, uint256 hashBlockPos,uint256[200] memory _tokenIds, uint256[200] memory _traits) external {
        require(hash200(_tokenIds)==allTokenIDHashes[hashBlock],"IDs in wrong order");
        require(hash200(_traits)==traitHashes[hashBlock],"Traits in wrong order");
 
        uint tokenID = _tokenIds[hashBlockPos];
        require(ownerOf(tokenID) == msg.sender,"Not your token");
        if (cardTraits[tokenID] == 0) {
            cardTraits[tokenID] = _traits[hashBlockPos];
            emit TraitsClaimed(tokenID,_traits[hashBlockPos]);
        } else {
            emit TraitsAlreadyClaimed(tokenID);
        }       
    }

    event TraitSet(uint pos,uint256 tokenId, uint256 traits);

    function randomAvailable() public view returns (bool) {
        return (lastRandomRequested > lastRandomProcessed) && rng.isRequestComplete(randomRequests[lastRandomProcessed]);
    }

    function nextRandom() internal returns (uint256) {
        require(randomAvailable(),"Nothing to process");
        return rng.randomNumber(randomRequests[lastRandomProcessed++]);
    }

    function request_random() internal {
        randomRequests[lastRandomRequested++] = rng.requestRandomNumber();
    }

    function request_another_random() external onlyOwner {
        request_random();
    }

    // View Function to get graphic properties

    function isCardResolved(uint256 tokenId) public view returns (bool) {
        return traitAssignmentOrder[tokenId] > 0;
    }


    function fullTrait(uint256 tokenId) external view returns (uint256) {
        return cardTraits[tokenId];
    }

    function cardType(uint256 serial) public view returns(CardType) {
        if (!isCardResolved(serial)) return CardType.Unresolved;
        if (serial < oStart) return CardType.Founder;
        if (serial < aStart) return CardType.OG;
        if (serial < cStart) return CardType.Alpha;
        return CardType.Common;
    }

     function traitAssignment(uint256 tokenId) external view returns (uint256) {
        return traitAssignmentOrder[tokenId];
    }

  
    function OG_next() external view returns (uint256 left, uint256 nextPrice) {
        return CARD_next(og_stop, og_price, oSold,oPending,og_pointer);
    }

    function ALPHA_next() external view returns (uint256 left, uint256 nextPrice) {
            return CARD_next(alpha_stop, alpha_price, aSold,aPending,alpha_pointer);
    }
    function RANDOM_next() external view returns (uint256 left, uint256 nextPrice) {
            return CARD_next(common_stop, common_price, cSold,cPending,common_pointer);
    }

    function CARD_next(uint256[] storage stop, uint256[] memory price, uint256 sold, uint256 pending, uint256 pointer) internal view returns (uint256 left, uint256 nextPrice) {
        left = stop[pointer] - (sold + pending);
        if (pointer < stop.length - 1)
            nextPrice = price[pointer+1];
        else
            nextPrice = price[pointer];
    }

        function drain(xERC20 token) external onlyOwner {
        if (address(token) == 0x0000000000000000000000000000000000000000) {
            payable(owner()).transfer(address(this).balance);
        } else {
            token.transfer(owner(),token.balanceOf(address(this)));
        }
    }

    bool _FuzeBlown;
    // after finalization the images will be assigned to match the trait data
    // but due to onboarding more artists we will have a late assignment.
    // when it is proven OK we burn

    // should be of the format ipfs://<hash>/path
    function setDataFolder(string memory _baseURI) external onlyAllowed {
        require(!_FuzeBlown,"This data can no longer be changed");
        _setBaseURI(_baseURI);
    }

    function burnDataFolder() external onlyAllowed {
        _FuzeBlown = true;
    }

    function tokenURI(uint256 tokenId) public view override returns (string memory) {
        require(_exists(tokenId), "ERC721Metadata: URI query for nonexistent token");
        CardType ct = cardType(tokenId);
        if (ct == CardType.Unresolved) {
            return "https://temp.ether.cards/metadata/Unresolved";
        }
        // reformat to directory structure as below
        string memory folder = (tokenId % 100).toString(); 
        string memory file = tokenId.toString();
        string memory slash = "/";
        return string(abi.encodePacked(baseURI(),folder,slash,file,".json"));
    }

    /// 1 ... 10000
    /// 1 - 100 / 1 - 100

    function is_sale_on() external view returns (bool) {
        if (sale_is_over()) return false;
        if (block.timestamp < sale_start) return false;
        if (nextTokenId > cMax) return false;
        return true;
    }

    function TokenExists(uint tokenId) external view returns (bool) {
        return _exists(tokenId);
    }
    
    uint launch_date = 1616072400;

    function sale_is_over() public view returns (bool) {
        return (block.timestamp > sale_end);
    }
    
    function how_long_more() public view returns (uint Days, uint Hours, uint Minutes, uint Seconds) {
        require(block.timestamp < launch_date,"Missed It");
        uint gap = launch_date - block.timestamp;
        Days = gap / (24 * 60 * 60);
        gap = gap %  (24 * 60 * 60);
        Hours = gap / (60 * 60);
        gap = gap % (60 * 60);
        Minutes = gap / 60;
        Seconds = gap % 60;
        return (Days,Hours,Minutes,Seconds);
    }

    function _beforeTokenTransfer(address from, address to, uint256 tokenId) internal virtual override {
        super._beforeTokenTransfer(from, to, tokenId);

        require(!paused(), "ERC721Pausable: token transfer while paused");
    }

    function pause() external onlyAllowed {
        _pause();
    }

    function unpause() external onlyAllowed {
        _unpause();
    }

}