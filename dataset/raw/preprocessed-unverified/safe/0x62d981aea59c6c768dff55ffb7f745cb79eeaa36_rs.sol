/**
 *Submitted for verification at Etherscan.io on 2019-10-18
*/

pragma solidity ^0.5.5;



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
 * @dev Required interface of an ERC721 compliant contract.
 */
contract IERC721 is IERC165 {
    event Transfer(address indexed from, address indexed to, uint256 indexed tokenId);
    event Approval(address indexed owner, address indexed approved, uint256 indexed tokenId);
    event ApprovalForAll(address indexed owner, address indexed operator, bool approved);

    /**
     * @dev Returns the number of NFTs in `owner`'s account.
     */
    function balanceOf(address owner) public view returns (uint256 balance);

    /**
     * @dev Returns the owner of the NFT specified by `tokenId`.
     */
    function ownerOf(uint256 tokenId) public view returns (address owner);

    /**
     * @dev Transfers a specific NFT (`tokenId`) from one account (`from`) to
     * another (`to`).
     *
     *
     *
     * Requirements:
     * - `from`, `to` cannot be zero.
     * - `tokenId` must be owned by `from`.
     * - If the caller is not `from`, it must be have been allowed to move this
     * NFT by either {approve} or {setApprovalForAll}.
     */
    function safeTransferFrom(address from, address to, uint256 tokenId) public;
    /**
     * @dev Transfers a specific NFT (`tokenId`) from one account (`from`) to
     * another (`to`).
     *
     * Requirements:
     * - If the caller is not `from`, it must be approved to move this NFT by
     * either {approve} or {setApprovalForAll}.
     */
    function transferFrom(address from, address to, uint256 tokenId) public;
    function approve(address to, uint256 tokenId) public;
    function getApproved(uint256 tokenId) public view returns (address operator);

    function setApprovalForAll(address operator, bool _approved) public;
    function isApprovedForAll(address owner, address operator) public view returns (bool);


    function safeTransferFrom(address from, address to, uint256 tokenId, bytes memory data) public;
}


/**
 * @title ERC-721 Non-Fungible Token Standard, optional metadata extension
 * @dev See https://eips.ethereum.org/EIPS/eip-721
 */
contract IERC721Metadata is IERC721 {
    function name() external view returns (string memory);
    function symbol() external view returns (string memory);
    function tokenURI(uint256 tokenId) external view returns (string memory);
}

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
contract Context {
    // Empty internal constructor, to prevent people from mistakenly deploying
    // an instance of this contract, which should be used via inheritance.
    constructor () internal { }
    // solhint-disable-previous-line no-empty-blocks

    function _msgSender() internal view returns (address payable) {
        return msg.sender;
    }

    function _msgData() internal view returns (bytes memory) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}

/**
 * @title ERC-721 Non-Fungible Token Standard, optional enumeration extension
 * @dev See https://eips.ethereum.org/EIPS/eip-721
 */
contract IERC721Enumerable is IERC721 {
    function totalSupply() public view returns (uint256);
    function tokenOfOwnerByIndex(address owner, uint256 index) public view returns (uint256 tokenId);

    function tokenByIndex(uint256 index) public view returns (uint256);
}

/**
 * @title ERC721 token receiver interface
 * @dev Interface for any contract that wants to support safeTransfers
 * from ERC721 asset contracts.
 */
contract IERC721Receiver {
    /**
     * @notice Handle the receipt of an NFT
     * @dev The ERC721 smart contract calls this function on the recipient
     * after a {IERC721-safeTransferFrom}. This function MUST return the function selector,
     * otherwise the caller will revert the transaction. The selector to be
     * returned can be obtained as `this.onERC721Received.selector`. This
     * function MAY throw to revert and reject the transfer.
     * Note: the ERC721 contract address is always the message sender.
     * @param operator The address which called `safeTransferFrom` function
     * @param from The address which previously owned the token
     * @param tokenId The NFT identifier which is being transferred
     * @param data Additional data with no specified format
     * @return bytes4 `bytes4(keccak256("onERC721Received(address,address,uint256,bytes)"))`
     */
    function onERC721Received(address operator, address from, uint256 tokenId, bytes memory data)
    public returns (bytes4);
}

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


/**
 * @dev Collection of functions related to the address type
 */


/**
 * @title Counters
 * @author Matt Condon (@shrugs)
 * @dev Provides counters that can only be incremented or decremented by one. This can be used e.g. to track the number
 * of elements in a mapping, issuing ERC721 ids, or counting request ids.
 *
 * Include with `using Counters for Counters.Counter;`
 * Since it is not possible to overflow a 256 bit integer with increments of one, `increment` can skip the {SafeMath}
 * overflow check, thereby saving gas. This does assume however correct usage, in that the underlying `_value` is never
 * directly accessed.
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
    function supportsInterface(bytes4 interfaceId) external view returns (bool) {
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
    function _registerInterface(bytes4 interfaceId) internal {
        require(interfaceId != 0xffffffff, "ERC165: invalid interface id");
        _supportedInterfaces[interfaceId] = true;
    }
}

/**
 * @title ERC721 Non-Fungible Token Standard basic implementation
 * @dev see https://eips.ethereum.org/EIPS/eip-721
 */
contract ERC721 is Context, ERC165, IERC721 {
    using SafeMath for uint256;
    using Address for address;
    using Counters for Counters.Counter;

    // Equals to `bytes4(keccak256("onERC721Received(address,address,uint256,bytes)"))`
    // which can be also obtained as `IERC721Receiver(0).onERC721Received.selector`
    bytes4 private constant _ERC721_RECEIVED = 0x150b7a02;

    // Mapping from token ID to owner
    mapping (uint256 => address) private _tokenOwner;

    // Mapping from token ID to approved address
    mapping (uint256 => address) private _tokenApprovals;

    // Mapping from owner to number of owned token
    mapping (address => Counters.Counter) private _ownedTokensCount;

    // Mapping from owner to operator approvals
    mapping (address => mapping (address => bool)) private _operatorApprovals;

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
     *        0xa22cb465 ^ 0xe985e9c ^ 0x23b872dd ^ 0x42842e0e ^ 0xb88d4fde == 0x80ac58cd
     */
    bytes4 private constant _INTERFACE_ID_ERC721 = 0x80ac58cd;

    constructor () public {
        // register the supported interfaces to conform to ERC721 via ERC165
        _registerInterface(_INTERFACE_ID_ERC721);
    }

    /**
     * @dev Gets the balance of the specified address.
     * @param owner address to query the balance of
     * @return uint256 representing the amount owned by the passed address
     */
    function balanceOf(address owner) public view returns (uint256) {
        require(owner != address(0), "ERC721: balance query for the zero address");

        return _ownedTokensCount[owner].current();
    }

    /**
     * @dev Gets the owner of the specified token ID.
     * @param tokenId uint256 ID of the token to query the owner of
     * @return address currently marked as the owner of the given token ID
     */
    function ownerOf(uint256 tokenId) public view returns (address) {
        address owner = _tokenOwner[tokenId];
        require(owner != address(0), "ERC721: owner query for nonexistent token");

        return owner;
    }

    /**
     * @dev Approves another address to transfer the given token ID
     * The zero address indicates there is no approved address.
     * There can only be one approved address per token at a given time.
     * Can only be called by the token owner or an approved operator.
     * @param to address to be approved for the given token ID
     * @param tokenId uint256 ID of the token to be approved
     */
    function approve(address to, uint256 tokenId) public {
        address owner = ownerOf(tokenId);
        require(to != owner, "ERC721: approval to current owner");

        require(_msgSender() == owner || isApprovedForAll(owner, _msgSender()),
            "ERC721: approve caller is not owner nor approved for all"
        );

        _tokenApprovals[tokenId] = to;
        emit Approval(owner, to, tokenId);
    }

    /**
     * @dev Gets the approved address for a token ID, or zero if no address set
     * Reverts if the token ID does not exist.
     * @param tokenId uint256 ID of the token to query the approval of
     * @return address currently approved for the given token ID
     */
    function getApproved(uint256 tokenId) public view returns (address) {
        require(_exists(tokenId), "ERC721: approved query for nonexistent token");

        return _tokenApprovals[tokenId];
    }

    /**
     * @dev Sets or unsets the approval of a given operator
     * An operator is allowed to transfer all tokens of the sender on their behalf.
     * @param to operator address to set the approval
     * @param approved representing the status of the approval to be set
     */
    function setApprovalForAll(address to, bool approved) public {
        require(to != _msgSender(), "ERC721: approve to caller");

        _operatorApprovals[_msgSender()][to] = approved;
        emit ApprovalForAll(_msgSender(), to, approved);
    }

    /**
     * @dev Tells whether an operator is approved by a given owner.
     * @param owner owner address which you want to query the approval of
     * @param operator operator address which you want to query the approval of
     * @return bool whether the given operator is approved by the given owner
     */
    function isApprovedForAll(address owner, address operator) public view returns (bool) {
        return _operatorApprovals[owner][operator];
    }

    /**
     * @dev Transfers the ownership of a given token ID to another address.
     * Usage of this method is discouraged, use {safeTransferFrom} whenever possible.
     * Requires the msg.sender to be the owner, approved, or operator.
     * @param from current owner of the token
     * @param to address to receive the ownership of the given token ID
     * @param tokenId uint256 ID of the token to be transferred
     */
    function transferFrom(address from, address to, uint256 tokenId) public {
        //solhint-disable-next-line max-line-length
        require(_isApprovedOrOwner(_msgSender(), tokenId), "ERC721: transfer caller is not owner nor approved");

        _transferFrom(from, to, tokenId);
    }

    /**
     * @dev Safely transfers the ownership of a given token ID to another address
     * If the target address is a contract, it must implement {IERC721Receiver-onERC721Received},
     * which is called upon a safe transfer, and return the magic value
     * `bytes4(keccak256("onERC721Received(address,address,uint256,bytes)"))`; otherwise,
     * the transfer is reverted.
     * Requires the msg.sender to be the owner, approved, or operator
     * @param from current owner of the token
     * @param to address to receive the ownership of the given token ID
     * @param tokenId uint256 ID of the token to be transferred
     */
    function safeTransferFrom(address from, address to, uint256 tokenId) public {
        safeTransferFrom(from, to, tokenId, "");
    }

    /**
     * @dev Safely transfers the ownership of a given token ID to another address
     * If the target address is a contract, it must implement {IERC721Receiver-onERC721Received},
     * which is called upon a safe transfer, and return the magic value
     * `bytes4(keccak256("onERC721Received(address,address,uint256,bytes)"))`; otherwise,
     * the transfer is reverted.
     * Requires the _msgSender() to be the owner, approved, or operator
     * @param from current owner of the token
     * @param to address to receive the ownership of the given token ID
     * @param tokenId uint256 ID of the token to be transferred
     * @param _data bytes data to send along with a safe transfer check
     */
    function safeTransferFrom(address from, address to, uint256 tokenId, bytes memory _data) public {
        require(_isApprovedOrOwner(_msgSender(), tokenId), "ERC721: transfer caller is not owner nor approved");
        _safeTransferFrom(from, to, tokenId, _data);
    }

    /**
     * @dev Safely transfers the ownership of a given token ID to another address
     * If the target address is a contract, it must implement `onERC721Received`,
     * which is called upon a safe transfer, and return the magic value
     * `bytes4(keccak256("onERC721Received(address,address,uint256,bytes)"))`; otherwise,
     * the transfer is reverted.
     * Requires the msg.sender to be the owner, approved, or operator
     * @param from current owner of the token
     * @param to address to receive the ownership of the given token ID
     * @param tokenId uint256 ID of the token to be transferred
     * @param _data bytes data to send along with a safe transfer check
     */
    function _safeTransferFrom(address from, address to, uint256 tokenId, bytes memory _data) internal {
        _transferFrom(from, to, tokenId);
        require(_checkOnERC721Received(from, to, tokenId, _data), "ERC721: transfer to non ERC721Receiver implementer");
    }

    /**
     * @dev Returns whether the specified token exists.
     * @param tokenId uint256 ID of the token to query the existence of
     * @return bool whether the token exists
     */
    function _exists(uint256 tokenId) internal view returns (bool) {
        address owner = _tokenOwner[tokenId];
        return owner != address(0);
    }

    /**
     * @dev Returns whether the given spender can transfer a given token ID.
     * @param spender address of the spender to query
     * @param tokenId uint256 ID of the token to be transferred
     * @return bool whether the msg.sender is approved for the given token ID,
     * is an operator of the owner, or is the owner of the token
     */
    function _isApprovedOrOwner(address spender, uint256 tokenId) internal view returns (bool) {
        require(_exists(tokenId), "ERC721: operator query for nonexistent token");
        address owner = ownerOf(tokenId);
        return (spender == owner || getApproved(tokenId) == spender || isApprovedForAll(owner, spender));
    }

    /**
     * @dev Internal function to safely mint a new token.
     * Reverts if the given token ID already exists.
     * If the target address is a contract, it must implement `onERC721Received`,
     * which is called upon a safe transfer, and return the magic value
     * `bytes4(keccak256("onERC721Received(address,address,uint256,bytes)"))`; otherwise,
     * the transfer is reverted.
     * @param to The address that will own the minted token
     * @param tokenId uint256 ID of the token to be minted
     */
    function _safeMint(address to, uint256 tokenId) internal {
        _safeMint(to, tokenId, "");
    }

    /**
     * @dev Internal function to safely mint a new token.
     * Reverts if the given token ID already exists.
     * If the target address is a contract, it must implement `onERC721Received`,
     * which is called upon a safe transfer, and return the magic value
     * `bytes4(keccak256("onERC721Received(address,address,uint256,bytes)"))`; otherwise,
     * the transfer is reverted.
     * @param to The address that will own the minted token
     * @param tokenId uint256 ID of the token to be minted
     * @param _data bytes data to send along with a safe transfer check
     */
    function _safeMint(address to, uint256 tokenId, bytes memory _data) internal {
        _mint(to, tokenId);
        require(_checkOnERC721Received(address(0), to, tokenId, _data), "ERC721: transfer to non ERC721Receiver implementer");
    }

    /**
     * @dev Internal function to mint a new token.
     * Reverts if the given token ID already exists.
     * @param to The address that will own the minted token
     * @param tokenId uint256 ID of the token to be minted
     */
    function _mint(address to, uint256 tokenId) internal {
        require(to != address(0), "ERC721: mint to the zero address");
        require(!_exists(tokenId), "ERC721: token already minted");

        _tokenOwner[tokenId] = to;
        _ownedTokensCount[to].increment();

        emit Transfer(address(0), to, tokenId);
    }

    /**
     * @dev Internal function to burn a specific token.
     * Reverts if the token does not exist.
     * Deprecated, use {_burn} instead.
     * @param owner owner of the token to burn
     * @param tokenId uint256 ID of the token being burned
     */
    function _burn(address owner, uint256 tokenId) internal {
        require(ownerOf(tokenId) == owner, "ERC721: burn of token that is not own");

        _clearApproval(tokenId);

        _ownedTokensCount[owner].decrement();
        _tokenOwner[tokenId] = address(0);

        emit Transfer(owner, address(0), tokenId);
    }

    /**
     * @dev Internal function to burn a specific token.
     * Reverts if the token does not exist.
     * @param tokenId uint256 ID of the token being burned
     */
    function _burn(uint256 tokenId) internal {
        _burn(ownerOf(tokenId), tokenId);
    }

    /**
     * @dev Internal function to transfer ownership of a given token ID to another address.
     * As opposed to {transferFrom}, this imposes no restrictions on msg.sender.
     * @param from current owner of the token
     * @param to address to receive the ownership of the given token ID
     * @param tokenId uint256 ID of the token to be transferred
     */
    function _transferFrom(address from, address to, uint256 tokenId) internal {
        require(ownerOf(tokenId) == from, "ERC721: transfer of token that is not own");
        require(to != address(0), "ERC721: transfer to the zero address");

        _clearApproval(tokenId);

        _ownedTokensCount[from].decrement();
        _ownedTokensCount[to].increment();

        _tokenOwner[tokenId] = to;

        emit Transfer(from, to, tokenId);
    }

    /**
     * @dev Internal function to invoke {IERC721Receiver-onERC721Received} on a target address.
     * The call is not executed if the target address is not a contract.
     *
     * This function is deprecated.
     * @param from address representing the previous owner of the given token ID
     * @param to target address that will receive the tokens
     * @param tokenId uint256 ID of the token to be transferred
     * @param _data bytes optional data to send along with the call
     * @return bool whether the call correctly returned the expected magic value
     */
    function _checkOnERC721Received(address from, address to, uint256 tokenId, bytes memory _data)
        internal returns (bool)
    {
        if (!to.isContract()) {
            return true;
        }

        bytes4 retval = IERC721Receiver(to).onERC721Received(_msgSender(), from, tokenId, _data);
        return (retval == _ERC721_RECEIVED);
    }

    /**
     * @dev Private function to clear current approval of a given token ID.
     * @param tokenId uint256 ID of the token to be transferred
     */
    function _clearApproval(uint256 tokenId) private {
        if (_tokenApprovals[tokenId] != address(0)) {
            _tokenApprovals[tokenId] = address(0);
        }
    }
}

/**
 * @title ERC-721 Non-Fungible Token with optional enumeration extension logic
 * @dev See https://eips.ethereum.org/EIPS/eip-721
 */
contract ERC721Enumerable is Context, ERC165, ERC721, IERC721Enumerable {
    // Mapping from owner to list of owned token IDs
    mapping(address => uint256[]) private _ownedTokens;

    // Mapping from token ID to index of the owner tokens list
    mapping(uint256 => uint256) private _ownedTokensIndex;

    // Array with all token ids, used for enumeration
    uint256[] private _allTokens;

    // Mapping from token id to position in the allTokens array
    mapping(uint256 => uint256) private _allTokensIndex;

    /*
     *     bytes4(keccak256('totalSupply()')) == 0x18160ddd
     *     bytes4(keccak256('tokenOfOwnerByIndex(address,uint256)')) == 0x2f745c59
     *     bytes4(keccak256('tokenByIndex(uint256)')) == 0x4f6ccce7
     *
     *     => 0x18160ddd ^ 0x2f745c59 ^ 0x4f6ccce7 == 0x780e9d63
     */
    bytes4 private constant _INTERFACE_ID_ERC721_ENUMERABLE = 0x780e9d63;

    /**
     * @dev Constructor function.
     */
    constructor () public {
        // register the supported interface to conform to ERC721Enumerable via ERC165
        _registerInterface(_INTERFACE_ID_ERC721_ENUMERABLE);
    }

    /**
     * @dev Gets the token ID at a given index of the tokens list of the requested owner.
     * @param owner address owning the tokens list to be accessed
     * @param index uint256 representing the index to be accessed of the requested tokens list
     * @return uint256 token ID at the given index of the tokens list owned by the requested address
     */
    function tokenOfOwnerByIndex(address owner, uint256 index) public view returns (uint256) {
        require(index < balanceOf(owner), "ERC721Enumerable: owner index out of bounds");
        return _ownedTokens[owner][index];
    }

    /**
     * @dev Gets the total amount of tokens stored by the contract.
     * @return uint256 representing the total amount of tokens
     */
    function totalSupply() public view returns (uint256) {
        return _allTokens.length;
    }

    /**
     * @dev Gets the token ID at a given index of all the tokens in this contract
     * Reverts if the index is greater or equal to the total number of tokens.
     * @param index uint256 representing the index to be accessed of the tokens list
     * @return uint256 token ID at the given index of the tokens list
     */
    function tokenByIndex(uint256 index) public view returns (uint256) {
        require(index < totalSupply(), "ERC721Enumerable: global index out of bounds");
        return _allTokens[index];
    }

    /**
     * @dev Internal function to transfer ownership of a given token ID to another address.
     * As opposed to transferFrom, this imposes no restrictions on msg.sender.
     * @param from current owner of the token
     * @param to address to receive the ownership of the given token ID
     * @param tokenId uint256 ID of the token to be transferred
     */
    function _transferFrom(address from, address to, uint256 tokenId) internal {
        super._transferFrom(from, to, tokenId);

        _removeTokenFromOwnerEnumeration(from, tokenId);

        _addTokenToOwnerEnumeration(to, tokenId);
    }

    /**
     * @dev Internal function to mint a new token.
     * Reverts if the given token ID already exists.
     * @param to address the beneficiary that will own the minted token
     * @param tokenId uint256 ID of the token to be minted
     */
    function _mint(address to, uint256 tokenId) internal {
        super._mint(to, tokenId);

        _addTokenToOwnerEnumeration(to, tokenId);

        _addTokenToAllTokensEnumeration(tokenId);
    }

    /**
     * @dev Internal function to burn a specific token.
     * Reverts if the token does not exist.
     * Deprecated, use {ERC721-_burn} instead.
     * @param owner owner of the token to burn
     * @param tokenId uint256 ID of the token being burned
     */
    function _burn(address owner, uint256 tokenId) internal {
        super._burn(owner, tokenId);

        _removeTokenFromOwnerEnumeration(owner, tokenId);
        // Since tokenId will be deleted, we can clear its slot in _ownedTokensIndex to trigger a gas refund
        _ownedTokensIndex[tokenId] = 0;

        _removeTokenFromAllTokensEnumeration(tokenId);
    }

    /**
     * @dev Gets the list of token IDs of the requested owner.
     * @param owner address owning the tokens
     * @return uint256[] List of token IDs owned by the requested address
     */
    function _tokensOfOwner(address owner) internal view returns (uint256[] storage) {
        return _ownedTokens[owner];
    }

    /**
     * @dev Private function to add a token to this extension's ownership-tracking data structures.
     * @param to address representing the new owner of the given token ID
     * @param tokenId uint256 ID of the token to be added to the tokens list of the given address
     */
    function _addTokenToOwnerEnumeration(address to, uint256 tokenId) private {
        _ownedTokensIndex[tokenId] = _ownedTokens[to].length;
        _ownedTokens[to].push(tokenId);
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

        uint256 lastTokenIndex = _ownedTokens[from].length.sub(1);
        uint256 tokenIndex = _ownedTokensIndex[tokenId];

        // When the token to delete is the last token, the swap operation is unnecessary
        if (tokenIndex != lastTokenIndex) {
            uint256 lastTokenId = _ownedTokens[from][lastTokenIndex];

            _ownedTokens[from][tokenIndex] = lastTokenId; // Move the last token to the slot of the to-delete token
            _ownedTokensIndex[lastTokenId] = tokenIndex; // Update the moved token's index
        }

        // This also deletes the contents at the last position of the array
        _ownedTokens[from].length--;

        // Note that _ownedTokensIndex[tokenId] hasn't been cleared: it still points to the old slot (now occupied by
        // lastTokenId, or just over the end of the array if the token was the last one).
    }

    /**
     * @dev Private function to remove a token from this extension's token tracking data structures.
     * This has O(1) time complexity, but alters the order of the _allTokens array.
     * @param tokenId uint256 ID of the token to be removed from the tokens list
     */
    function _removeTokenFromAllTokensEnumeration(uint256 tokenId) private {
        // To prevent a gap in the tokens array, we store the last token in the index of the token to delete, and
        // then delete the last slot (swap and pop).

        uint256 lastTokenIndex = _allTokens.length.sub(1);
        uint256 tokenIndex = _allTokensIndex[tokenId];

        // When the token to delete is the last token, the swap operation is unnecessary. However, since this occurs so
        // rarely (when the last minted token is burnt) that we still do the swap here to avoid the gas cost of adding
        // an 'if' statement (like in _removeTokenFromOwnerEnumeration)
        uint256 lastTokenId = _allTokens[lastTokenIndex];

        _allTokens[tokenIndex] = lastTokenId; // Move the last token to the slot of the to-delete token
        _allTokensIndex[lastTokenId] = tokenIndex; // Update the moved token's index

        // This also deletes the contents at the last position of the array
        _allTokens.length--;
        _allTokensIndex[tokenId] = 0;
    }
}

/**
 * @dev Contract module which provides a basic access control mechanism, where
 * there is an account (an owner) that can be granted exclusive access to
 * specific functions.
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
        require(isOwner(), "Ownable: caller is not the owner");
        _;
    }

    /**
     * @dev Returns true if the caller is the current owner.
     */
    function isOwner() public view returns (bool) {
        return _msgSender() == _owner;
    }

    /**
     * @dev Leaves the contract without owner. It will not be possible to call
     * `onlyOwner` functions anymore. Can only be called by the current owner.
     *
     * NOTE: Renouncing ownership will leave the contract without an owner,
     * thereby removing any functionality that is only available to the owner.
     */
    function renounceOwnership() public onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) public onlyOwner {
        _transferOwnership(newOwner);
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     */
    function _transferOwnership(address newOwner) internal {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}

/**
 * @title ERC721 Non-Fungible Token Standard basic implementation
 * Modified to remove the mint function and to replace it
 * with the _addTokenTo function.
 * This function is very similar to the _mint function, but it
 * does not emit a Transfer event
 * @dev see https://eips.ethereum.org/EIPS/eip-721
 */
contract NoMintERC721 is Context, ERC165, IERC721 {
    using SafeMath for uint256;
    using Address for address;
    using Counters for Counters.Counter;

    // Equals to `bytes4(keccak256("onERC721Received(address,address,uint256,bytes)"))`
    // which can be also obtained as `IERC721Receiver(0).onERC721Received.selector`
    bytes4 private constant _ERC721_RECEIVED = 0x150b7a02;

    // Mapping from token ID to owner
    mapping (uint256 => address) private _tokenOwner;

    // Mapping from token ID to approved address
    mapping (uint256 => address) private _tokenApprovals;

    // Mapping from owner to number of owned token
    mapping (address => Counters.Counter) private _ownedTokensCount;

    // Mapping from owner to operator approvals
    mapping (address => mapping (address => bool)) private _operatorApprovals;

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
     *        0xa22cb465 ^ 0xe985e9c ^ 0x23b872dd ^ 0x42842e0e ^ 0xb88d4fde == 0x80ac58cd
     */
    bytes4 private constant _INTERFACE_ID_ERC721 = 0x80ac58cd;

    constructor () public {
        // register the supported interfaces to conform to ERC721 via ERC165
        _registerInterface(_INTERFACE_ID_ERC721);
    }

    /**
     * @dev Gets the balance of the specified address.
     * @param owner address to query the balance of
     * @return uint256 representing the amount owned by the passed address
     */
    function balanceOf(address owner) public view returns (uint256) {
        require(owner != address(0), "ERC721: balance query for the zero address");

        return _ownedTokensCount[owner].current();
    }

    /**
     * @dev Gets the owner of the specified token ID.
     * @param tokenId uint256 ID of the token to query the owner of
     * @return address currently marked as the owner of the given token ID
     */
    function ownerOf(uint256 tokenId) public view returns (address) {
        address owner = _tokenOwner[tokenId];
        require(owner != address(0), "ERC721: owner query for nonexistent token");

        return owner;
    }

    /**
     * @dev Approves another address to transfer the given token ID
     * The zero address indicates there is no approved address.
     * There can only be one approved address per token at a given time.
     * Can only be called by the token owner or an approved operator.
     * @param to address to be approved for the given token ID
     * @param tokenId uint256 ID of the token to be approved
     */
    function approve(address to, uint256 tokenId) public {
        address owner = ownerOf(tokenId);
        require(to != owner, "ERC721: approval to current owner");

        require(_msgSender() == owner || isApprovedForAll(owner, _msgSender()),
            "ERC721: approve caller is not owner nor approved for all"
        );

        _tokenApprovals[tokenId] = to;
        emit Approval(owner, to, tokenId);
    }

    /**
     * @dev Gets the approved address for a token ID, or zero if no address set
     * Reverts if the token ID does not exist.
     * @param tokenId uint256 ID of the token to query the approval of
     * @return address currently approved for the given token ID
     */
    function getApproved(uint256 tokenId) public view returns (address) {
        require(_exists(tokenId), "ERC721: approved query for nonexistent token");

        return _tokenApprovals[tokenId];
    }

    /**
     * @dev Sets or unsets the approval of a given operator
     * An operator is allowed to transfer all tokens of the sender on their behalf.
     * @param to operator address to set the approval
     * @param approved representing the status of the approval to be set
     */
    function setApprovalForAll(address to, bool approved) public {
        require(to != _msgSender(), "ERC721: approve to caller");

        _operatorApprovals[_msgSender()][to] = approved;
        emit ApprovalForAll(_msgSender(), to, approved);
    }

    /**
     * @dev Tells whether an operator is approved by a given owner.
     * @param owner owner address which you want to query the approval of
     * @param operator operator address which you want to query the approval of
     * @return bool whether the given operator is approved by the given owner
     */
    function isApprovedForAll(address owner, address operator) public view returns (bool) {
        return _operatorApprovals[owner][operator];
    }

    /**
     * @dev Transfers the ownership of a given token ID to another address.
     * Usage of this method is discouraged, use {safeTransferFrom} whenever possible.
     * Requires the msg.sender to be the owner, approved, or operator.
     * @param from current owner of the token
     * @param to address to receive the ownership of the given token ID
     * @param tokenId uint256 ID of the token to be transferred
     */
    function transferFrom(address from, address to, uint256 tokenId) public {
        //solhint-disable-next-line max-line-length
        require(_isApprovedOrOwner(_msgSender(), tokenId), "ERC721: transfer caller is not owner nor approved");

        _transferFrom(from, to, tokenId);
    }

    /**
     * @dev Safely transfers the ownership of a given token ID to another address
     * If the target address is a contract, it must implement {IERC721Receiver-onERC721Received},
     * which is called upon a safe transfer, and return the magic value
     * `bytes4(keccak256("onERC721Received(address,address,uint256,bytes)"))`; otherwise,
     * the transfer is reverted.
     * Requires the msg.sender to be the owner, approved, or operator
     * @param from current owner of the token
     * @param to address to receive the ownership of the given token ID
     * @param tokenId uint256 ID of the token to be transferred
     */
    function safeTransferFrom(address from, address to, uint256 tokenId) public {
        safeTransferFrom(from, to, tokenId, "");
    }

    /**
     * @dev Safely transfers the ownership of a given token ID to another address
     * If the target address is a contract, it must implement {IERC721Receiver-onERC721Received},
     * which is called upon a safe transfer, and return the magic value
     * `bytes4(keccak256("onERC721Received(address,address,uint256,bytes)"))`; otherwise,
     * the transfer is reverted.
     * Requires the _msgSender() to be the owner, approved, or operator
     * @param from current owner of the token
     * @param to address to receive the ownership of the given token ID
     * @param tokenId uint256 ID of the token to be transferred
     * @param _data bytes data to send along with a safe transfer check
     */
    function safeTransferFrom(address from, address to, uint256 tokenId, bytes memory _data) public {
        require(_isApprovedOrOwner(_msgSender(), tokenId), "ERC721: transfer caller is not owner nor approved");
        _safeTransferFrom(from, to, tokenId, _data);
    }

    /**
     * @dev Safely transfers the ownership of a given token ID to another address
     * If the target address is a contract, it must implement `onERC721Received`,
     * which is called upon a safe transfer, and return the magic value
     * `bytes4(keccak256("onERC721Received(address,address,uint256,bytes)"))`; otherwise,
     * the transfer is reverted.
     * Requires the msg.sender to be the owner, approved, or operator
     * @param from current owner of the token
     * @param to address to receive the ownership of the given token ID
     * @param tokenId uint256 ID of the token to be transferred
     * @param _data bytes data to send along with a safe transfer check
     */
    function _safeTransferFrom(address from, address to, uint256 tokenId, bytes memory _data) internal {
        _transferFrom(from, to, tokenId);
        require(_checkOnERC721Received(from, to, tokenId, _data), "ERC721: transfer to non ERC721Receiver implementer");
    }

    /**
     * @dev Returns whether the specified token exists.
     * @param tokenId uint256 ID of the token to query the existence of
     * @return bool whether the token exists
     */
    function _exists(uint256 tokenId) internal view returns (bool) {
        address owner = _tokenOwner[tokenId];
        return owner != address(0);
    }

    /**
     * @dev Returns whether the given spender can transfer a given token ID.
     * @param spender address of the spender to query
     * @param tokenId uint256 ID of the token to be transferred
     * @return bool whether the msg.sender is approved for the given token ID,
     * is an operator of the owner, or is the owner of the token
     */
    function _isApprovedOrOwner(address spender, uint256 tokenId) internal view returns (bool) {
        require(_exists(tokenId), "ERC721: operator query for nonexistent token");
        address owner = ownerOf(tokenId);
        return (spender == owner || getApproved(tokenId) == spender || isApprovedForAll(owner, spender));
    }

    /**
     * @dev Internal function to mint a new token.
     * Reverts if the given token ID already exists.
     * @param to The address that will own the minted token
     * @param tokenId uint256 ID of the token to be minted
     */
    function _addTokenTo(address to, uint256 tokenId) internal {
        require(to != address(0), "ERC721: mint to the zero address");
        require(!_exists(tokenId), "ERC721: token already minted");

        _tokenOwner[tokenId] = to;
        _ownedTokensCount[to].increment();
    }

    /**
     * @dev Internal function to burn a specific token.
     * Reverts if the token does not exist.
     * Deprecated, use {_burn} instead.
     * @param owner owner of the token to burn
     * @param tokenId uint256 ID of the token being burned
     */
    function _burn(address owner, uint256 tokenId) internal {
        require(ownerOf(tokenId) == owner, "ERC721: burn of token that is not own");

        _clearApproval(tokenId);

        _ownedTokensCount[owner].decrement();
        _tokenOwner[tokenId] = address(0);

        emit Transfer(owner, address(0), tokenId);
    }

    /**
     * @dev Internal function to burn a specific token.
     * Reverts if the token does not exist.
     * @param tokenId uint256 ID of the token being burned
     */
    function _burn(uint256 tokenId) internal {
        _burn(ownerOf(tokenId), tokenId);
    }

    /**
     * @dev Internal function to transfer ownership of a given token ID to another address.
     * As opposed to {transferFrom}, this imposes no restrictions on msg.sender.
     * @param from current owner of the token
     * @param to address to receive the ownership of the given token ID
     * @param tokenId uint256 ID of the token to be transferred
     */
    function _transferFrom(address from, address to, uint256 tokenId) internal {
        require(ownerOf(tokenId) == from, "ERC721: transfer of token that is not own");
        require(to != address(0), "ERC721: transfer to the zero address");

        _clearApproval(tokenId);

        _ownedTokensCount[from].decrement();
        _ownedTokensCount[to].increment();

        _tokenOwner[tokenId] = to;

        emit Transfer(from, to, tokenId);
    }

    /**
     * @dev Internal function to invoke {IERC721Receiver-onERC721Received} on a target address.
     * The call is not executed if the target address is not a contract.
     *
     * This function is deprecated.
     * @param from address representing the previous owner of the given token ID
     * @param to target address that will receive the tokens
     * @param tokenId uint256 ID of the token to be transferred
     * @param _data bytes optional data to send along with the call
     * @return bool whether the call correctly returned the expected magic value
     */
    function _checkOnERC721Received(address from, address to, uint256 tokenId, bytes memory _data)
        internal returns (bool)
    {
        if (!to.isContract()) {
            return true;
        }

        bytes4 retval = IERC721Receiver(to).onERC721Received(_msgSender(), from, tokenId, _data);
        return (retval == _ERC721_RECEIVED);
    }

    /**
     * @dev Private function to clear current approval of a given token ID.
     * @param tokenId uint256 ID of the token to be transferred
     */
    function _clearApproval(uint256 tokenId) private {
        if (_tokenApprovals[tokenId] != address(0)) {
            _tokenApprovals[tokenId] = address(0);
        }
    }
}

/**
 * @title ERC-721 Non-Fungible Token with optional enumeration extension logic
 * Modified to work with the NoMintERC721 contract
 * @dev See https://eips.ethereum.org/EIPS/eip-721
 */
contract NoMintERC721Enumerable is Context, ERC165, NoMintERC721, IERC721Enumerable {
    // Mapping from owner to list of owned token IDs
    mapping(address => uint256[]) private _ownedTokens;

    // Mapping from token ID to index of the owner tokens list
    mapping(uint256 => uint256) private _ownedTokensIndex;

    // Array with all token ids, used for enumeration
    uint256[] private _allTokens;

    // Mapping from token id to position in the allTokens array
    mapping(uint256 => uint256) private _allTokensIndex;

    /*
     *     bytes4(keccak256('totalSupply()')) == 0x18160ddd
     *     bytes4(keccak256('tokenOfOwnerByIndex(address,uint256)')) == 0x2f745c59
     *     bytes4(keccak256('tokenByIndex(uint256)')) == 0x4f6ccce7
     *
     *     => 0x18160ddd ^ 0x2f745c59 ^ 0x4f6ccce7 == 0x780e9d63
     */
    bytes4 private constant _INTERFACE_ID_ERC721_ENUMERABLE = 0x780e9d63;

    /**
     * @dev Constructor function.
     */
    constructor () public {
        // register the supported interface to conform to ERC721Enumerable via ERC165
        _registerInterface(_INTERFACE_ID_ERC721_ENUMERABLE);
    }

    /**
     * @dev Gets the token ID at a given index of the tokens list of the requested owner.
     * @param owner address owning the tokens list to be accessed
     * @param index uint256 representing the index to be accessed of the requested tokens list
     * @return uint256 token ID at the given index of the tokens list owned by the requested address
     */
    function tokenOfOwnerByIndex(address owner, uint256 index) public view returns (uint256) {
        require(index < balanceOf(owner), "ERC721Enumerable: owner index out of bounds");
        return _ownedTokens[owner][index];
    }

    /**
     * @dev Gets the total amount of tokens stored by the contract.
     * @return uint256 representing the total amount of tokens
     */
    function totalSupply() public view returns (uint256) {
        return _allTokens.length;
    }

    /**
     * @dev Gets the token ID at a given index of all the tokens in this contract
     * Reverts if the index is greater or equal to the total number of tokens.
     * @param index uint256 representing the index to be accessed of the tokens list
     * @return uint256 token ID at the given index of the tokens list
     */
    function tokenByIndex(uint256 index) public view returns (uint256) {
        require(index < totalSupply(), "ERC721Enumerable: global index out of bounds");
        return _allTokens[index];
    }

    /**
     * @dev Internal function to transfer ownership of a given token ID to another address.
     * As opposed to transferFrom, this imposes no restrictions on msg.sender.
     * @param from current owner of the token
     * @param to address to receive the ownership of the given token ID
     * @param tokenId uint256 ID of the token to be transferred
     */
    function _transferFrom(address from, address to, uint256 tokenId) internal {
        super._transferFrom(from, to, tokenId);

        _removeTokenFromOwnerEnumeration(from, tokenId);

        _addTokenToOwnerEnumeration(to, tokenId);
    }

    /**
     * @dev Internal function to mint a new token.
     * Reverts if the given token ID already exists.
     * @param to address the beneficiary that will own the minted token
     * @param tokenId uint256 ID of the token to be minted
     */
    function _addTokenTo(address to, uint256 tokenId) internal {
        super._addTokenTo(to, tokenId);

        _addTokenToOwnerEnumeration(to, tokenId);

        _addTokenToAllTokensEnumeration(tokenId);
    }

    /**
     * @dev Internal function to burn a specific token.
     * Reverts if the token does not exist.
     * Deprecated, use {ERC721-_burn} instead.
     * @param owner owner of the token to burn
     * @param tokenId uint256 ID of the token being burned
     */
    function _burn(address owner, uint256 tokenId) internal {
        super._burn(owner, tokenId);

        _removeTokenFromOwnerEnumeration(owner, tokenId);
        // Since tokenId will be deleted, we can clear its slot in _ownedTokensIndex to trigger a gas refund
        _ownedTokensIndex[tokenId] = 0;

        _removeTokenFromAllTokensEnumeration(tokenId);
    }

    /**
     * @dev Gets the list of token IDs of the requested owner.
     * @param owner address owning the tokens
     * @return uint256[] List of token IDs owned by the requested address
     */
    function _tokensOfOwner(address owner) internal view returns (uint256[] storage) {
        return _ownedTokens[owner];
    }

    /**
     * @dev Private function to add a token to this extension's ownership-tracking data structures.
     * @param to address representing the new owner of the given token ID
     * @param tokenId uint256 ID of the token to be added to the tokens list of the given address
     */
    function _addTokenToOwnerEnumeration(address to, uint256 tokenId) private {
        _ownedTokensIndex[tokenId] = _ownedTokens[to].length;
        _ownedTokens[to].push(tokenId);
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

        uint256 lastTokenIndex = _ownedTokens[from].length.sub(1);
        uint256 tokenIndex = _ownedTokensIndex[tokenId];

        // When the token to delete is the last token, the swap operation is unnecessary
        if (tokenIndex != lastTokenIndex) {
            uint256 lastTokenId = _ownedTokens[from][lastTokenIndex];

            _ownedTokens[from][tokenIndex] = lastTokenId; // Move the last token to the slot of the to-delete token
            _ownedTokensIndex[lastTokenId] = tokenIndex; // Update the moved token's index
        }

        // This also deletes the contents at the last position of the array
        _ownedTokens[from].length--;

        // Note that _ownedTokensIndex[tokenId] hasn't been cleared: it still points to the old slot (now occupied by
        // lastTokenId, or just over the end of the array if the token was the last one).
    }

    /**
     * @dev Private function to remove a token from this extension's token tracking data structures.
     * This has O(1) time complexity, but alters the order of the _allTokens array.
     * @param tokenId uint256 ID of the token to be removed from the tokens list
     */
    function _removeTokenFromAllTokensEnumeration(uint256 tokenId) private {
        // To prevent a gap in the tokens array, we store the last token in the index of the token to delete, and
        // then delete the last slot (swap and pop).

        uint256 lastTokenIndex = _allTokens.length.sub(1);
        uint256 tokenIndex = _allTokensIndex[tokenId];

        // When the token to delete is the last token, the swap operation is unnecessary. However, since this occurs so
        // rarely (when the last minted token is burnt) that we still do the swap here to avoid the gas cost of adding
        // an 'if' statement (like in _removeTokenFromOwnerEnumeration)
        uint256 lastTokenId = _allTokens[lastTokenIndex];

        _allTokens[tokenIndex] = lastTokenId; // Move the last token to the slot of the to-delete token
        _allTokensIndex[lastTokenId] = tokenIndex; // Update the moved token's index

        // This also deletes the contents at the last position of the array
        _allTokens.length--;
        _allTokensIndex[tokenId] = 0;
    }
}

/**
 * @title ERC-721 Non-Fungible Token Standard, optional metadata extension
 * Modified to change
 * function tokenURI(uint256 tokenId) external view returns (string memory);
 * to
 * function tokenURI(uint256 tokenId) public view returns (string memory);
 * @dev See https://eips.ethereum.org/EIPS/eip-721
 */
contract OveridableERC721Metadata is Context, ERC165, NoMintERC721, IERC721Metadata {
    // Token name
    string private _name;

    // Token symbol
    string private _symbol;

    // Optional mapping for token URIs
    mapping(uint256 => string) private _tokenURIs;

    /*
     *     bytes4(keccak256('name()')) == 0x06fdde03
     *     bytes4(keccak256('symbol()')) == 0x95d89b41
     *     bytes4(keccak256('tokenURI(uint256)')) == 0xc87b56dd
     *
     *     => 0x06fdde03 ^ 0x95d89b41 ^ 0xc87b56dd == 0x5b5e139f
     */
    bytes4 private constant _INTERFACE_ID_ERC721_METADATA = 0x5b5e139f;

    /**
     * @dev Constructor function
     */
    constructor (string memory name, string memory symbol) public {
        _name = name;
        _symbol = symbol;

        // register the supported interfaces to conform to ERC721 via ERC165
        _registerInterface(_INTERFACE_ID_ERC721_METADATA);
    }

    /**
     * @dev Gets the token name.
     * @return string representing the token name
     */
    function name() external view returns (string memory) {
        return _name;
    }

    /**
     * @dev Gets the token symbol.
     * @return string representing the token symbol
     */
    function symbol() external view returns (string memory) {
        return _symbol;
    }

    /**
     * @dev Returns an URI for a given token ID.
     * Throws if the token ID does not exist. May return an empty string.
     * @param tokenId uint256 ID of the token to query
     */
    function tokenURI(uint256 tokenId) public view returns (string memory) {
        require(_exists(tokenId), "ERC721Metadata: URI query for nonexistent token");
        return _tokenURIs[tokenId];
    }

    /**
     * @dev Internal function to set the token URI for a given token.
     * Reverts if the token ID does not exist.
     * @param tokenId uint256 ID of the token to set its URI
     * @param uri string URI to assign
     */
    function _setTokenURI(uint256 tokenId, string memory uri) internal {
        require(_exists(tokenId), "ERC721Metadata: URI set of nonexistent token");
        _tokenURIs[tokenId] = uri;
    }

    /**
     * @dev Internal function to burn a specific token.
     * Reverts if the token does not exist.
     * Deprecated, use _burn(uint256) instead.
     * @param owner owner of the token to burn
     * @param tokenId uint256 ID of the token being burned by the msg.sender
     */
    function _burn(address owner, uint256 tokenId) internal {
        super._burn(owner, tokenId);

        // Clear metadata (if any)
        if (bytes(_tokenURIs[tokenId]).length != 0) {
            delete _tokenURIs[tokenId];
        }
    }
}

/**
 * ERC-721 implementation that allows 
 * tokens (of the same category) to be minted in batches. Each batch
 * contains enough data to generate all
 * token ids inside the batch, and to
 * generate the tokenURI in the batch
 */
contract GunToken is NoMintERC721, NoMintERC721Enumerable, OveridableERC721Metadata, Ownable {
    using strings for *;
    
    address internal factory;
    
    uint16 public constant maxAllocation = 4000;
    uint256 public lastAllocation = 0;
    
    event BatchTransfer(address indexed from, address indexed to, uint256 indexed batchIndex);
    
    struct Batch {
        address owner;
        uint16 size;
        uint8 category;
        uint256 startId;
        uint256 startTokenId;
    }
    
    Batch[] public allBatches;
    mapping(address => uint256) unactivatedBalance;
    mapping(uint256 => bool) isActivated;
    
    //Used for enumeration
    mapping(address => Batch[]) public batchesOwned;
    //Batch index to owner batch index
    mapping(uint256 => uint256) public ownedBatchIndex;
    
    mapping(uint8 => uint256) internal totalGunsMintedByCategory;
    uint256 internal _totalSupply;

    modifier onlyFactory {
        require(msg.sender == factory, "Not authorized");
        _;
    }

    constructor(address factoryAddress) public OveridableERC721Metadata("WarRiders Gun", "WRG") {
        factory = factoryAddress;
    }
    
    function categoryTypeToId(uint8 category, uint256 categoryId) public view returns (uint256) {
        for (uint i = 0; i < allBatches.length; i++) {
            Batch memory a = allBatches[i];
            if (a.category != category)
                continue;
            
            uint256 endId = a.startId + a.size;
            if (categoryId >= a.startId && categoryId < endId) {
                uint256 dif = categoryId - a.startId;
                
                return a.startTokenId + dif;
            }
        }
        
        revert();
    }
    
    /**
     * @dev Gets the token ID at a given index of the tokens list of the requested owner.
     * @param owner address owning the tokens list to be accessed
     * @param index uint256 representing the index to be accessed of the requested tokens list
     * @return uint256 token ID at the given index of the tokens list owned by the requested address
     */
    function tokenOfOwnerByIndex(address owner, uint256 index) public view returns (uint256) {
        return tokenOfOwner(owner)[index];
    }
    
    function getBatchCount(address owner) public view returns(uint256) {
        return batchesOwned[owner].length;
    }
    
    function getTokensInBatch(address owner, uint256 index) public view returns (uint256[] memory) {
        Batch memory a = batchesOwned[owner][index];
        uint256[] memory result = new uint256[](a.size);
        
        uint256 pos = 0;
        uint end = a.startTokenId + a.size;
        for (uint i = a.startTokenId; i < end; i++) {
            if (isActivated[i] && super.ownerOf(i) != owner) {
                continue;
            }
            
            result[pos] = i;
            pos++;
        }
        
        require(pos > 0);
        
        uint256 subAmount = a.size - pos;
        
        assembly { mstore(result, sub(mload(result), subAmount)) }
        
        return result;
    }
    
    function tokenByIndex(uint256 index) public view returns (uint256) {
        return allTokens()[index];
    }
    
    function allTokens() public view returns (uint256[] memory) {
        uint256[] memory result = new uint256[](totalSupply());
        
        uint pos = 0;
        for (uint i = 0; i < allBatches.length; i++) {
            Batch memory a = allBatches[i];
            uint end = a.startTokenId + a.size;
            for (uint j = a.startTokenId; j < end; j++) {
                result[pos] = j;
                pos++;
            }
        }
        
        return result;
    }
    
    function tokenOfOwner(address owner) public view returns (uint256[] memory) {
        uint256[] memory result = new uint256[](balanceOf(owner));
        
        uint pos = 0;
        for (uint i = 0; i < batchesOwned[owner].length; i++) {
            Batch memory a = batchesOwned[owner][i];
            uint end = a.startTokenId + a.size;
            for (uint j = a.startTokenId; j < end; j++) {
                if (isActivated[j] && super.ownerOf(j) != owner) {
                    continue;
                }
                
                result[pos] = j;
                pos++;
            }
        }
        
        uint256[] memory fallbackOwned = _tokensOfOwner(owner);
        for (uint i = 0; i < fallbackOwned.length; i++) {
            result[pos] = fallbackOwned[i];
            pos++;
        }
        
        return result;
    }
    
    function balanceOf(address owner) public view returns (uint256) {
        require(owner != address(0), "ERC721: balance query for the zero address");

        return super.balanceOf(owner) + unactivatedBalance[owner];
    }
    
     function ownerOf(uint256 tokenId) public view returns (address) {
         require(exists(tokenId), "Token doesn't exist!");
         
         if (isActivated[tokenId]) {
             return super.ownerOf(tokenId);
         }
         uint256 index = getBatchIndex(tokenId);
         require(index < allBatches.length, "Token batch doesn't exist");
         Batch memory a = allBatches[index];
         require(tokenId < a.startTokenId + a.size);
         return a.owner;
     }
    
    function exists(uint256 _tokenId) public view returns (bool) {
        if (isActivated[_tokenId]) {
            return super._exists(_tokenId);
        } else {
            uint256 index = getBatchIndex(_tokenId);
            if (index < allBatches.length) {
                Batch memory a = allBatches[index];
                uint end = a.startTokenId + a.size;
                
                return _tokenId < end;
            }
            return false;
        }
    }
    
    function totalSupply() public view returns (uint256) {
        return _totalSupply;
    }
    
    function claimAllocation(address to, uint16 size, uint8 category) public onlyFactory returns (uint) {
        require(size < maxAllocation, "Size must be smaller than maxAllocation");
        
        allBatches.push(Batch({
            owner: to,
            size: size,
            category: category,
            startId: totalGunsMintedByCategory[category],
            startTokenId: lastAllocation
        }));
        
        uint end = lastAllocation + size;
        for (uint i = lastAllocation; i < end; i++) {
            emit Transfer(address(0), to, i);
        }
        
        lastAllocation += maxAllocation;
        
        unactivatedBalance[to] += size;
        totalGunsMintedByCategory[category] += size;
        
        _addBatchToOwner(to, allBatches[allBatches.length - 1]);
        
        _totalSupply += size;
        return lastAllocation;
    }
    
    function transferFrom(address from, address to, uint256 tokenId) public {
        if (!isActivated[tokenId]) {
            activate(tokenId);
        }
        super.transferFrom(from, to, tokenId);
    }
    
    function activate(uint256 tokenId) public {
        require(!isActivated[tokenId], "Token already activated");
        uint256 index = getBatchIndex(tokenId);
        require(index < allBatches.length, "Token batch doesn't exist");
        Batch memory a = allBatches[index];
        require(tokenId < a.startTokenId + a.size);
        isActivated[tokenId] = true;
        addTokenTo(a.owner, tokenId);
        unactivatedBalance[a.owner]--;
    }
    
    function getBatchIndex(uint256 tokenId) public pure returns (uint256) {
        uint256 index = (tokenId / maxAllocation);
        
        return index;
    }
    
    function categoryForToken(uint256 tokenId) public view returns (uint8) {
        uint256 index = getBatchIndex(tokenId);
        require(index < allBatches.length, "Token batch doesn't exist");
        
        Batch memory a = allBatches[index];
        
        return a.category;
    }
    
    function categoryIdForToken(uint256 tokenId) public view returns (uint256) {
        uint256 index = getBatchIndex(tokenId);
        require(index < allBatches.length, "Token batch doesn't exist");
        
        Batch memory a = allBatches[index];
        
        uint256 categoryId = (tokenId % maxAllocation) + a.startId;
        
        return categoryId;
    }
    
    function uintToString(uint v) internal pure returns (string memory) {
        if (v == 0) {
            return "0";
        }
        uint j = v;
        uint len;
        while (j != 0) {
            len++;
            j /= 10;
        }
        bytes memory bstr = new bytes(len);
        uint k = len - 1;
        while (v != 0) {
            bstr[k--] = byte(uint8(48 + v % 10));
            v /= 10;
        }
        
        return string(bstr);
    }
    
    function tokenURI(uint256 tokenId) public view returns (string memory) {
        require(exists(tokenId), "Token doesn't exist!");
        if (isActivated[tokenId]) {
            return super.tokenURI(tokenId);
        } else {
            //Predict the token URI
            uint8 category = categoryForToken(tokenId);
            uint256 _categoryId = categoryIdForToken(tokenId);
            
            string memory id = uintToString(category).toSlice().concat("/".toSlice()).toSlice().concat(uintToString(_categoryId).toSlice().concat(".json".toSlice()).toSlice());
            string memory _base = "https://vault.warriders.com/guns/";
            
            //Final URL: https://vault.warriders.com/guns/<category>/<category_id>.json
            string memory _metadata = _base.toSlice().concat(id.toSlice());
            
            return _metadata;
        }
    }
    
    function addTokenTo(address _to, uint256 _tokenId) internal {
        //Predict the token URI
        uint8 category = categoryForToken(_tokenId);
        uint256 _categoryId = categoryIdForToken(_tokenId);
            
        string memory id = uintToString(category).toSlice().concat("/".toSlice()).toSlice().concat(uintToString(_categoryId).toSlice().concat(".json".toSlice()).toSlice());
        string memory _base = "https://vault.warriders.com/guns/";
            
        //Final URL: https://vault.warriders.com/guns/<category>/<category_id>.json
        string memory _metadata = _base.toSlice().concat(id.toSlice());
        
        super._addTokenTo(_to, _tokenId);
        super._setTokenURI(_tokenId, _metadata);
    }
    
    function ceil(uint a, uint m) internal pure returns (uint ) {
        return ((a + m - 1) / m) * m;
    }
    
    function _removeBatchFromOwner(address from, Batch memory batch) private {
        // To prevent a gap in from's tokens array, we store the last token in the index of the token to delete, and
        // then delete the last slot (swap and pop).
        
        uint256 globalIndex = getBatchIndex(batch.startTokenId);

        uint256 lastBatchIndex = batchesOwned[from].length.sub(1);
        uint256 batchIndex = ownedBatchIndex[globalIndex];

        // When the token to delete is the last token, the swap operation is unnecessary
        if (batchIndex != lastBatchIndex) {
            Batch memory lastBatch = batchesOwned[from][lastBatchIndex];
            uint256 lastGlobalIndex = getBatchIndex(lastBatch.startTokenId);

            batchesOwned[from][batchIndex] = lastBatch; // Move the last batch to the slot of the to-delete batch
            ownedBatchIndex[lastGlobalIndex] = batchIndex; // Update the moved batch's index
        }

        // This also deletes the contents at the last position of the array
        batchesOwned[from].length--;

        // Note that ownedBatchIndex[batch] hasn't been cleared: it still points to the old slot (now occupied by
        // lastBatch, or just over the end of the array if the batch was the last one).
    }
    
    function _addBatchToOwner(address to, Batch memory batch) private {
        uint256 globalIndex = getBatchIndex(batch.startTokenId);
        
        ownedBatchIndex[globalIndex] = batchesOwned[to].length;
        batchesOwned[to].push(batch);
    }
    
    function batchTransfer(uint256 batchIndex, address to) public {
        Batch storage a = allBatches[batchIndex];
        
        address previousOwner = a.owner;
        
        require(a.owner == msg.sender);
        
        _removeBatchFromOwner(previousOwner, a);
        
        a.owner = to;
        
        _addBatchToOwner(to, a);
        
        emit BatchTransfer(previousOwner, to, batchIndex);
        
        //Now to need to emit a bunch of transfer events
        uint end = a.startTokenId + a.size;
        uint256 unActivated = 0;
        for (uint i = a.startTokenId; i < end; i++) {
            if (isActivated[i]) {
                if (ownerOf(i) != previousOwner)
                    continue; //The previous owner didn't own this token, don't emit an event
            } else {
                unActivated++;
            }
            emit Transfer(previousOwner, to, i);
        }
        
        unactivatedBalance[to] += unActivated;
        unactivatedBalance[previousOwner] -= unActivated;
    }
}

contract ApproveAndCallFallBack {
    function receiveApproval(address from, uint256 tokens, address token, bytes memory data) public payable returns (bool);
}

/**
 * @title ERC20Basic
 * @dev Simpler version of ERC20 interface
 * @dev see https://github.com/ethereum/EIPs/issues/179
 */
contract ERC20Basic {
  function totalSupply() public view returns (uint256);
  function balanceOf(address who) public view returns (uint256);
  function transfer(address to, uint256 value) public returns (bool);
  event Transfer(address indexed from, address indexed to, uint256 value);
}

contract ERC20 is ERC20Basic {
  function allowance(address owner, address spender)
    public view returns (uint256);

  function transferFrom(address from, address to, uint256 value)
    public returns (bool);

  function approve(address spender, uint256 value) public returns (bool);
  event Approval(
    address indexed owner,
    address indexed spender,
    uint256 value
  );
}

contract BurnableToken is ERC20 {
  event Burn(address indexed burner, uint256 value);
  function burn(uint256 _value) public;
}

contract StandardBurnableToken is BurnableToken {
  function burnFrom(address _from, uint256 _value) public;
}



contract SimpleBZNFeed is BZNFeed, Ownable {
    
    uint256 private conversion;
    
    function updateConversion(uint256 conversionRate) public onlyOwner {
        conversion = conversionRate;
    }
    
    function convert(uint256 usd) external view returns (uint256) {
        return usd * conversion;
    }
}





contract GunPreOrder is Ownable, ApproveAndCallFallBack {
    using BytesLib for bytes;
    using SafeMath for uint256;
    
    //Event for when a bulk buy order has been placed
    event consumerBulkBuy(uint8 category, uint256 quanity, address reserver);
    //Event for when a gun has been bought
    event GunsBought(uint256 gunId, address owner, uint8 category);
    //Event for when ether is taken out of this contract
    event Withdrawal(uint256 amount);

    //Default referal commision percent
    uint256 public constant COMMISSION_PERCENT = 5;
    
    //Whether category is open
    mapping(uint8 => bool) public categoryExists;
    mapping(uint8 => bool) public categoryOpen;
    mapping(uint8 => bool) public categoryKilled;
    
    //The additional referal commision percent for any given referal address (default is 0)
    mapping(address => uint256) internal commissionRate;
    
    //How many guns in a given category an address has reserved
    mapping(uint8 => mapping(address => uint256)) public categoryReserveAmount;
    
    //Opensea buy address
    address internal constant OPENSEA = 0x5b3256965e7C3cF26E11FCAf296DfC8807C01073;

    //The percent increase and percent base for a given category
    mapping(uint8 => uint256) public categoryPercentIncrease;
    mapping(uint8 => uint256) public categoryPercentBase;

    //Price of a givevn category in USD WEI
    mapping(uint8 => uint256) public categoryPrice;
    
    //The percent of ether required for buying in BZN
    mapping(uint8 => uint256) public requiredEtherPercent;
    mapping(uint8 => uint256) public requiredEtherPercentBase;
    bool public allowCreateCategory = true;

    //The gun token contract
    GunToken public token;
    //The gun factory contract
    GunFactory internal factory;
    //The BZN contract
    StandardBurnableToken internal bzn;
    //The Maker ETH/USD price feed
    IDSValue public ethFeed;
    BZNFeed public bznFeed;
    //The gamepool address
    address internal gamePool;
    
    //Require the skinned/regular shop to be opened
    modifier ensureShopOpen(uint8 category) {
        require(categoryExists[category], "Category doesn't exist!");
        require(categoryOpen[category], "Category is not open!");
        _;
    }
    
    //Allow a function to accept ETH payment
    modifier payInETH(address referal, uint8 category, address new_owner, uint16 quanity) {
        uint256 usdPrice;
        uint256 totalPrice;
        (usdPrice, totalPrice) = priceFor(category, quanity);
        require(usdPrice > 0, "Price not yet set");
        
        categoryPrice[category] = usdPrice; //Save last price
        
        uint256 price = convert(totalPrice, false);
        
        require(msg.value >= price, "Not enough Ether sent!");
        
        _;
        
        if (msg.value > price) {
            uint256 change = msg.value - price;

            msg.sender.transfer(change);
        }
        
        if (referal != address(0)) {
            require(referal != msg.sender, "The referal cannot be the sender");
            require(referal != tx.origin, "The referal cannot be the tranaction origin");
            require(referal != new_owner, "The referal cannot be the new owner");

            //The commissionRate map adds any partner bonuses, or 0 if a normal user referral
            uint256 totalCommision = COMMISSION_PERCENT + commissionRate[referal];

            uint256 commision = (price * totalCommision) / 100;
            
            address payable _referal = address(uint160(referal));

            _referal.transfer(commision);
        }

    }
    
    //Allow function to accept BZN payment
    modifier payInBZN(address referal, uint8 category, address payable new_owner, uint16 quanity) {
        uint256[] memory prices = new uint256[](4); //Hack to work around local var limit (usdPrice, bznPrice, commision, totalPrice)
        (prices[0], prices[3]) = priceFor(category, quanity);
        require(prices[0] > 0, "Price not yet set");
            
        categoryPrice[category] = prices[0];
        
        prices[1] = convert(prices[3], true); //Convert the totalPrice to BZN

        //The commissionRate map adds any partner bonuses, or 0 if a normal user referral
        if (referal != address(0)) {
            prices[2] = (prices[1] * (COMMISSION_PERCENT + commissionRate[referal])) / 100;
        }
        
        uint256 requiredEther = (convert(prices[3], false) * requiredEtherPercent[category]) / requiredEtherPercentBase[category];
        
        require(msg.value >= requiredEther, "Buying with BZN requires some Ether!");
        
        bzn.burnFrom(new_owner, (((prices[1] - prices[2]) * 30) / 100));
        bzn.transferFrom(new_owner, gamePool, prices[1] - prices[2] - (((prices[1] - prices[2]) * 30) / 100));
        
        _;
        
        if (msg.value > requiredEther) {
            new_owner.transfer(msg.value - requiredEther);
        }
        
        if (referal != address(0)) {
            require(referal != msg.sender, "The referal cannot be the sender");
            require(referal != tx.origin, "The referal cannot be the tranaction origin");
            require(referal != new_owner, "The referal cannot be the new owner");
            
            bzn.transferFrom(new_owner, referal, prices[2]);
            
            prices[2] = (requiredEther * (COMMISSION_PERCENT + commissionRate[referal])) / 100;
            
            address payable _referal = address(uint160(referal));

            _referal.transfer(prices[2]);
        }
    }

    //Constructor
    constructor(
        address tokenAddress,
        address tokenFactory,
        address gp,
        address isd,
        address bzn_address
    ) public {
        token = GunToken(tokenAddress);

        factory = GunFactory(tokenFactory);
        
        ethFeed = IDSValue(isd);
        bzn = StandardBurnableToken(bzn_address);

        gamePool = gp;

        //Set percent increases
        categoryPercentIncrease[1] = 100035;
        categoryPercentBase[1] = 100000;
        
        categoryPercentIncrease[2] = 100025;
        categoryPercentBase[2] = 100000;
        
        categoryPercentIncrease[3] = 100015;
        categoryPercentBase[3] = 100000;
        
        commissionRate[OPENSEA] = 10;
    }
    
    function createCategory(uint8 category) public onlyOwner {
        require(allowCreateCategory);
        
        categoryExists[category] = true;
    }
    
    function disableCreateCategories() public onlyOwner {
        allowCreateCategory = false;
    }
    
    //Set the referal commision rate for an address
    function setCommission(address referral, uint256 percent) public onlyOwner {
        require(percent > COMMISSION_PERCENT);
        require(percent < 95);
        percent = percent - COMMISSION_PERCENT;
        
        commissionRate[referral] = percent;
    }
    
    //Set the price increase/base for skinned or regular guns
    function setPercentIncrease(uint256 increase, uint256 base, uint8 category) public onlyOwner {
        require(increase > base);
        
        categoryPercentIncrease[category] = increase;
        categoryPercentBase[category] = base;
    }
    
    function setEtherPercent(uint256 percent, uint256 base, uint8 category) public onlyOwner {
        requiredEtherPercent[category] = percent;
        requiredEtherPercentBase[category] = base;
    }
    
    function killCategory(uint8 category) public onlyOwner {
        require(!categoryKilled[category]);
        
        categoryOpen[category] = false;
        categoryKilled[category] = true;
    }

    //Open/Close the skinned or regular guns shop
    function setShopState(uint8 category, bool open) public onlyOwner {
        require(category == 1 || category == 2 || category == 3);
        require(!categoryKilled[category]);
        require(categoryExists[category]);
        
        categoryOpen[category] = open;
    }

    /**
     * Set the price for any given category in USD.
     */
    function setPrice(uint8 category, uint256 price, bool inWei) public onlyOwner {
        uint256 multiply = 1e18;
        if (inWei) {
            multiply = 1;
        }
        
        categoryPrice[category] = price * multiply;
    }

    /**
    Withdraw the amount from the contract's balance. Only the contract owner can execute this function
    */
    function withdraw(uint256 amount) public onlyOwner {
        uint256 balance = address(this).balance;

        require(amount <= balance, "Requested to much");
        
        address payable _owner = address(uint160(owner()));
        
        _owner.transfer(amount);

        emit Withdrawal(amount);
    }
    
    function setBZNFeedContract(address new_bzn_feed) public onlyOwner {
        bznFeed = BZNFeed(new_bzn_feed);
    }
    
    //Buy many skinned or regular guns with BZN. This will reserve the amount of guns and allows the new_owner to invoke claimGuns for free
    function buyWithBZN(address referal, uint8 category, address payable new_owner, uint16 quanity) ensureShopOpen(category) payInBZN(referal, category, new_owner, quanity) public payable returns (bool) {
        factory.mintFor(new_owner, quanity, category);
            
        return true;
    }
    
    //Buy many skinned or regular guns with ETH. This will reserve the amount of guns and allows the new_owner to invoke claimGuns for free
    function buyWithEther(address referal, uint8 category, address new_owner, uint16 quanity) ensureShopOpen(category) payInETH(referal, category, new_owner, quanity) public payable returns (bool) {
        factory.mintFor(new_owner, quanity, category);
        
        return true;
    }
    
    function convert(uint256 usdValue, bool isBZN) public view returns (uint256) {
        if (isBZN) {
            return bznFeed.convert(usdValue);
        } else {
            bool temp;
            bytes32 aaa;
            (aaa, temp) = ethFeed.peek();
                
            uint256 priceForEtherInUsdWei = uint256(aaa);
            
            return usdValue / (priceForEtherInUsdWei / 1e18);
        }
    }
    
    /**
    Get the price for skinned or regular guns in USD (wei)
    */
    function priceFor(uint8 category, uint16 quanity) public view returns (uint256, uint256) {
        require(quanity > 0);
        uint256 percent = categoryPercentIncrease[category];
        uint256 base = categoryPercentBase[category];

        uint256 currentPrice = categoryPrice[category];
        uint256 nextPrice = currentPrice;
        uint256 totalPrice = 0;
        //We can't use exponents because we'll overflow quickly
        //Only for loop :(
        for (uint i = 0; i < quanity; i++) {
            nextPrice = (currentPrice * percent) / base;
            
            currentPrice = nextPrice;
            
            totalPrice += nextPrice;
        }

        //Return the next price, as this is the true price
        return (nextPrice, totalPrice);
    }

    //Determine if a tokenId exists (has been sold)
    function sold(uint256 _tokenId) public view returns (bool) {
        return token.exists(_tokenId);
    }
    
    function receiveApproval(address from, uint256 tokenAmount, address tokenContract, bytes memory data) public payable returns (bool) {
        address referal;
        uint8 category;
        uint16 quanity;
        
        (referal, category, quanity) = abi.decode(data, (address, uint8, uint16));
        
        require(quanity >= 1);
        
        address payable _from = address(uint160(from)); 
        
        buyWithBZN(referal, category, _from, quanity);
        
        return true;
    }
}

contract GunFactory is Ownable {
    using strings for *;
    
    uint8 public constant PREMIUM_CATEGORY = 1;
    uint8 public constant MIDGRADE_CATEGORY = 2;
    uint8 public constant REGULAR_CATEGORY = 3;
    uint256 public constant ONE_MONTH = 2628000;
    
    uint256 public mintedGuns = 0;
    address preOrderAddress;
    GunToken token;
    
    mapping(uint8 => uint256) internal gunsMintedByCategory;
    mapping(uint8 => uint256) internal totalGunsMintedByCategory;
    
    mapping(uint8 => uint256) internal firstMonthLimit;
    mapping(uint8 => uint256) internal secondMonthLimit;
    mapping(uint8 => uint256) internal thirdMonthLimit;
    
    uint256 internal startTime;
    mapping(uint8 => uint256) internal currentMonthEnd;
    uint256 internal monthOneEnd;
    uint256 internal monthTwoEnd;

    modifier onlyPreOrder {
        require(msg.sender == preOrderAddress, "Not authorized");
        _;
    }

    modifier isInitialized {
        require(preOrderAddress != address(0), "No linked preorder");
        require(address(token) != address(0), "No linked token");
        _;
    }
    
    constructor() public {
        firstMonthLimit[PREMIUM_CATEGORY] = 5000;
        firstMonthLimit[MIDGRADE_CATEGORY] = 20000;
        firstMonthLimit[REGULAR_CATEGORY] = 30000;
        
        secondMonthLimit[PREMIUM_CATEGORY] = 2500;
        secondMonthLimit[MIDGRADE_CATEGORY] = 10000;
        secondMonthLimit[REGULAR_CATEGORY] = 15000;
        
        thirdMonthLimit[PREMIUM_CATEGORY] = 600;
        thirdMonthLimit[MIDGRADE_CATEGORY] = 3000;
        thirdMonthLimit[REGULAR_CATEGORY] = 6000;
        
        startTime = block.timestamp;
        monthOneEnd = startTime + ONE_MONTH;
        monthTwoEnd = startTime + ONE_MONTH + ONE_MONTH;
        
        currentMonthEnd[PREMIUM_CATEGORY] = monthOneEnd;
        currentMonthEnd[MIDGRADE_CATEGORY] = monthOneEnd;
        currentMonthEnd[REGULAR_CATEGORY] = monthOneEnd;
    }

    function uintToString(uint v) internal pure returns (string memory) {
        if (v == 0) {
            return "0";
        }
        uint j = v;
        uint len;
        while (j != 0) {
            len++;
            j /= 10;
        }
        bytes memory bstr = new bytes(len);
        uint k = len - 1;
        while (v != 0) {
            bstr[k--] = byte(uint8(48 + v % 10));
            v /= 10;
        }
        
        return string(bstr);
    }

    function mintFor(address newOwner, uint16 size, uint8 category) public onlyPreOrder isInitialized returns (uint256) {
        GunPreOrder preOrder = GunPreOrder(preOrderAddress);
        require(preOrder.categoryExists(category), "Invalid category");
        
        require(!hasReachedLimit(category), "The monthly limit has been reached");
        
        token.claimAllocation(newOwner, size, category);
        
        mintedGuns++;
        
        gunsMintedByCategory[category] = gunsMintedByCategory[category] + 1;
        totalGunsMintedByCategory[category] = totalGunsMintedByCategory[category] + 1;
    }
    
    function hasReachedLimit(uint8 category) internal returns (bool) {
        uint256 currentTime = block.timestamp;
        uint256 limit = currentLimit(category);
        
        uint256 monthEnd = currentMonthEnd[category];
        
        //If the current block time is greater than or equal to the end of the month
        if (currentTime >= monthEnd) {
            //It's a new month, reset all limits
            //gunsMintedByCategory[PREMIUM_CATEGORY] = 0;
            //gunsMintedByCategory[MIDGRADE_CATEGORY] = 0;
            //gunsMintedByCategory[REGULAR_CATEGORY] = 0;
            gunsMintedByCategory[category] = 0;
            
            //Set next month end to be equal one month in advance
            //do this while the current time is greater than the next month end
            while (currentTime >= monthEnd) {
                monthEnd = monthEnd + ONE_MONTH;
            }
            
            //Finally, update the limit
            limit = currentLimit(category);
            currentMonthEnd[category] = monthEnd;
        }
        
        //Check if the limit has been reached
        return gunsMintedByCategory[category] >= limit;
    }
    
    function reachedLimit(uint8 category) public view returns (bool) {
        uint256 limit = currentLimit(category);
        
        return gunsMintedByCategory[category] >= limit;
    }
    
    function currentLimit(uint8 category) public view returns (uint256) {
        uint256 currentTime = block.timestamp;
        uint256 limit;
        if (currentTime < monthOneEnd) {
            limit = firstMonthLimit[category];
        } else if (currentTime < monthTwoEnd) {
            limit = secondMonthLimit[category];
        } else {
            limit = thirdMonthLimit[category];
        }
        
        return limit;
    }
    
    function setCategoryLimit(uint8 category, uint256 firstLimit, uint256 secondLimit, uint256 thirdLimit) public onlyOwner {
        require(firstMonthLimit[category] == 0);
        require(secondMonthLimit[category] == 0);
        require(thirdMonthLimit[category] == 0);
        
        firstMonthLimit[category] = firstLimit;
        secondMonthLimit[category] = secondLimit;
        thirdMonthLimit[category] = thirdLimit;
    }
    
    /**
    Attach the preOrder that will be receiving tokens being marked for sale by the
    sellCar function
    */
    function attachPreOrder(address dst) public onlyOwner {
        //Enforce that address is indeed a preorder
        GunPreOrder preOrder = GunPreOrder(dst);

        preOrderAddress = address(preOrder);
    }

    /**
    Attach the token being used for things
    */
    function attachToken(address dst) public onlyOwner {
        require(address(token) == address(0));
        require(dst != address(0));

        //Enforce that address is indeed a preorder
        GunToken ct = GunToken(dst);

        token = ct;
    }
}