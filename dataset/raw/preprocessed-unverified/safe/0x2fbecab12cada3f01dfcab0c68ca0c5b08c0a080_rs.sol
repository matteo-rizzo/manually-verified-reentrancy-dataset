/**
 *Submitted for verification at Etherscan.io on 2021-06-02
*/

/*
 * Crypto stamp Bridge: Bridged ERC-1155 Token
 * Prototype contract for all ERC-1155 tokens deployed by bridging an original
 * ERC-1155 token from the other side of the bridge
 *
 * Developed by Capacity Blockchain Solutions GmbH <capacity.at>
 * for Österreichische Post AG <post.at>
 *
 * Any usage of or interaction with this set of contracts is subject to the
 * Terms & Conditions available at https://crypto.post.at/
 */

// SPDX-License-Identifier: UNLICENSED

pragma solidity ^0.8.0;

// File: @openzeppelin/contracts/token/ERC20/IERC20.sol

/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
 */


// File: @openzeppelin/contracts/utils/introspection/IERC165.sol


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

// File: @openzeppelin/contracts/token/ERC1155/IERC1155.sol



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

// File: @openzeppelin/contracts/token/ERC1155/IERC1155Receiver.sol



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

// File: @openzeppelin/contracts/token/ERC1155/extensions/IERC1155MetadataURI.sol



/**
 * @dev Interface of the optional ERC1155MetadataExtension interface, as defined
 * in the https://eips.ethereum.org/EIPS/eip-1155#metadata-extensions[EIP].
 *
 * _Available since v3.1._
 */
interface IERC1155MetadataURI is IERC1155 {
    /**
     * @dev Returns the URI for token type `id`.
     *
     * If the `\{id\}` substring is present in the URI, it must be replaced by
     * clients with the actual token type ID.
     */
    function uri(uint256 id) external view returns (string memory);
}

// File: @openzeppelin/contracts/utils/Address.sol


/**
 * @dev Collection of functions related to the address type
 */


// File: @openzeppelin/contracts/utils/Context.sol


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

// File: @openzeppelin/contracts/utils/introspection/ERC165.sol



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

// File: contracts/OZ_ERC1155.sol

/*
 * This is a 1:1 copy of OpenZeppelin ERC1155.sol from master branch as of 2021-05-03.
 * This contains a patch that enables us to do signedTransfer without an ugly workaround.
 * See https://github.com/OpenZeppelin/openzeppelin-contracts/pull/2636
 */








/**
 * @dev Implementation of the basic standard multi-token.
 * See https://eips.ethereum.org/EIPS/eip-1155
 * Originally based on code by Enjin: https://github.com/enjin/erc-1155
 *
 * _Available since v3.1._
 */
contract ERC1155 is Context, ERC165, IERC1155, IERC1155MetadataURI {
    using Address for address;

    // Mapping from token ID to account balances
    mapping (uint256 => mapping(address => uint256)) private _balances;

    // Mapping from account to operator approvals
    mapping (address => mapping(address => bool)) private _operatorApprovals;

    // Used as the URI for all token types by relying on ID substitution, e.g. https://token-cdn-domain/{id}.json
    string private _uri;

    /**
     * @dev See {_setURI}.
     */
    constructor (string memory uri_) {
        _setURI(uri_);
    }

    /**
     * @dev See {IERC165-supportsInterface}.
     */
    function supportsInterface(bytes4 interfaceId) public view virtual override(ERC165, IERC165) returns (bool) {
        return interfaceId == type(IERC1155).interfaceId
            || interfaceId == type(IERC1155MetadataURI).interfaceId
            || super.supportsInterface(interfaceId);
    }

    /**
     * @dev See {IERC1155MetadataURI-uri}.
     *
     * This implementation returns the same URI for *all* token types. It relies
     * on the token type ID substitution mechanism
     * https://eips.ethereum.org/EIPS/eip-1155#metadata[defined in the EIP].
     *
     * Clients calling this function must replace the `\{id\}` substring with the
     * actual token type ID.
     */
    function uri(uint256) public view virtual override returns (string memory) {
        return _uri;
    }

    /**
     * @dev See {IERC1155-balanceOf}.
     *
     * Requirements:
     *
     * - `account` cannot be the zero address.
     */
    function balanceOf(address account, uint256 id) public view virtual override returns (uint256) {
        require(account != address(0), "ERC1155: balance query for the zero address");
        return _balances[id][account];
    }

    /**
     * @dev See {IERC1155-balanceOfBatch}.
     *
     * Requirements:
     *
     * - `accounts` and `ids` must have the same length.
     */
    function balanceOfBatch(
        address[] memory accounts,
        uint256[] memory ids
    )
        public
        view
        virtual
        override
        returns (uint256[] memory)
    {
        require(accounts.length == ids.length, "ERC1155: accounts and ids length mismatch");

        uint256[] memory batchBalances = new uint256[](accounts.length);

        for (uint256 i = 0; i < accounts.length; ++i) {
            batchBalances[i] = balanceOf(accounts[i], ids[i]);
        }

        return batchBalances;
    }

    /**
     * @dev See {IERC1155-setApprovalForAll}.
     */
    function setApprovalForAll(address operator, bool approved) public virtual override {
        require(_msgSender() != operator, "ERC1155: setting approval status for self");

        _operatorApprovals[_msgSender()][operator] = approved;
        emit ApprovalForAll(_msgSender(), operator, approved);
    }

    /**
     * @dev See {IERC1155-isApprovedForAll}.
     */
    function isApprovedForAll(address account, address operator) public view virtual override returns (bool) {
        return _operatorApprovals[account][operator];
    }

    /**
     * @dev See {IERC1155-safeTransferFrom}.
     */
    function safeTransferFrom(
        address from,
        address to,
        uint256 id,
        uint256 amount,
        bytes memory data
    )
        public
        virtual
        override
    {
        require(
            from == _msgSender() || isApprovedForAll(from, _msgSender()),
            "ERC1155: caller is not owner nor approved"
        );
        _safeTransferFrom(from, to, id, amount, data);
    }

    /**
     * @dev See {IERC1155-safeBatchTransferFrom}.
     */
    function safeBatchTransferFrom(
        address from,
        address to,
        uint256[] memory ids,
        uint256[] memory amounts,
        bytes memory data
    )
        public
        virtual
        override
    {
        require(
            from == _msgSender() || isApprovedForAll(from, _msgSender()),
            "ERC1155: transfer caller is not owner nor approved"
        );
        _safeBatchTransferFrom(from, to, ids, amounts, data);
    }

    /**
     * @dev Transfers `amount` tokens of token type `id` from `from` to `to`.
     *
     * Emits a {TransferSingle} event.
     *
     * Requirements:
     *
     * - `to` cannot be the zero address.
     * - `from` must have a balance of tokens of type `id` of at least `amount`.
     * - If `to` refers to a smart contract, it must implement {IERC1155Receiver-onERC1155Received} and return the
     * acceptance magic value.
     */
    function _safeTransferFrom(
        address from,
        address to,
        uint256 id,
        uint256 amount,
        bytes memory data
    )
        internal
        virtual
    {
        require(to != address(0), "ERC1155: transfer to the zero address");

        address operator = _msgSender();

        _beforeTokenTransfer(operator, from, to, _asSingletonArray(id), _asSingletonArray(amount), data);

        uint256 fromBalance = _balances[id][from];
        require(fromBalance >= amount, "ERC1155: insufficient balance for transfer");
        _balances[id][from] = fromBalance - amount;
        _balances[id][to] += amount;

        emit TransferSingle(operator, from, to, id, amount);

        _doSafeTransferAcceptanceCheck(operator, from, to, id, amount, data);
    }

    /**
     * @dev xref:ROOT:erc1155.adoc#batch-operations[Batched] version of {_safeTransferFrom}.
     *
     * Emits a {TransferBatch} event.
     *
     * Requirements:
     *
     * - If `to` refers to a smart contract, it must implement {IERC1155Receiver-onERC1155BatchReceived} and return the
     * acceptance magic value.
     */
    function _safeBatchTransferFrom(
        address from,
        address to,
        uint256[] memory ids,
        uint256[] memory amounts,
        bytes memory data
    )
        internal
        virtual
    {
        require(ids.length == amounts.length, "ERC1155: ids and amounts length mismatch");
        require(to != address(0), "ERC1155: transfer to the zero address");

        address operator = _msgSender();

        _beforeTokenTransfer(operator, from, to, ids, amounts, data);

        for (uint256 i = 0; i < ids.length; ++i) {
            uint256 id = ids[i];
            uint256 amount = amounts[i];

            uint256 fromBalance = _balances[id][from];
            require(fromBalance >= amount, "ERC1155: insufficient balance for transfer");
            _balances[id][from] = fromBalance - amount;
            _balances[id][to] += amount;
        }

        emit TransferBatch(operator, from, to, ids, amounts);

        _doSafeBatchTransferAcceptanceCheck(operator, from, to, ids, amounts, data);
    }

    /**
     * @dev Sets a new URI for all token types, by relying on the token type ID
     * substitution mechanism
     * https://eips.ethereum.org/EIPS/eip-1155#metadata[defined in the EIP].
     *
     * By this mechanism, any occurrence of the `\{id\}` substring in either the
     * URI or any of the amounts in the JSON file at said URI will be replaced by
     * clients with the token type ID.
     *
     * For example, the `https://token-cdn-domain/\{id\}.json` URI would be
     * interpreted by clients as
     * `https://token-cdn-domain/000000000000000000000000000000000000000000000000000000000004cce0.json`
     * for token type ID 0x4cce0.
     *
     * See {uri}.
     *
     * Because these URIs cannot be meaningfully represented by the {URI} event,
     * this function emits no events.
     */
    function _setURI(string memory newuri) internal virtual {
        _uri = newuri;
    }

    /**
     * @dev Creates `amount` tokens of token type `id`, and assigns them to `account`.
     *
     * Emits a {TransferSingle} event.
     *
     * Requirements:
     *
     * - `account` cannot be the zero address.
     * - If `account` refers to a smart contract, it must implement {IERC1155Receiver-onERC1155Received} and return the
     * acceptance magic value.
     */
    function _mint(address account, uint256 id, uint256 amount, bytes memory data) internal virtual {
        require(account != address(0), "ERC1155: mint to the zero address");

        address operator = _msgSender();

        _beforeTokenTransfer(operator, address(0), account, _asSingletonArray(id), _asSingletonArray(amount), data);

        _balances[id][account] += amount;
        emit TransferSingle(operator, address(0), account, id, amount);

        _doSafeTransferAcceptanceCheck(operator, address(0), account, id, amount, data);
    }

    /**
     * @dev xref:ROOT:erc1155.adoc#batch-operations[Batched] version of {_mint}.
     *
     * Requirements:
     *
     * - `ids` and `amounts` must have the same length.
     * - If `to` refers to a smart contract, it must implement {IERC1155Receiver-onERC1155BatchReceived} and return the
     * acceptance magic value.
     */
    function _mintBatch(address to, uint256[] memory ids, uint256[] memory amounts, bytes memory data) internal virtual {
        require(to != address(0), "ERC1155: mint to the zero address");
        require(ids.length == amounts.length, "ERC1155: ids and amounts length mismatch");

        address operator = _msgSender();

        _beforeTokenTransfer(operator, address(0), to, ids, amounts, data);

        for (uint i = 0; i < ids.length; i++) {
            _balances[ids[i]][to] += amounts[i];
        }

        emit TransferBatch(operator, address(0), to, ids, amounts);

        _doSafeBatchTransferAcceptanceCheck(operator, address(0), to, ids, amounts, data);
    }

    /**
     * @dev Destroys `amount` tokens of token type `id` from `account`
     *
     * Requirements:
     *
     * - `account` cannot be the zero address.
     * - `account` must have at least `amount` tokens of token type `id`.
     */
    function _burn(address account, uint256 id, uint256 amount) internal virtual {
        require(account != address(0), "ERC1155: burn from the zero address");

        address operator = _msgSender();

        _beforeTokenTransfer(operator, account, address(0), _asSingletonArray(id), _asSingletonArray(amount), "");

        uint256 accountBalance = _balances[id][account];
        require(accountBalance >= amount, "ERC1155: burn amount exceeds balance");
        _balances[id][account] = accountBalance - amount;

        emit TransferSingle(operator, account, address(0), id, amount);
    }

    /**
     * @dev xref:ROOT:erc1155.adoc#batch-operations[Batched] version of {_burn}.
     *
     * Requirements:
     *
     * - `ids` and `amounts` must have the same length.
     */
    function _burnBatch(address account, uint256[] memory ids, uint256[] memory amounts) internal virtual {
        require(account != address(0), "ERC1155: burn from the zero address");
        require(ids.length == amounts.length, "ERC1155: ids and amounts length mismatch");

        address operator = _msgSender();

        _beforeTokenTransfer(operator, account, address(0), ids, amounts, "");

        for (uint i = 0; i < ids.length; i++) {
            uint256 id = ids[i];
            uint256 amount = amounts[i];

            uint256 accountBalance = _balances[id][account];
            require(accountBalance >= amount, "ERC1155: burn amount exceeds balance");
            _balances[id][account] = accountBalance - amount;
        }

        emit TransferBatch(operator, account, address(0), ids, amounts);
    }

    /**
     * @dev Hook that is called before any token transfer. This includes minting
     * and burning, as well as batched variants.
     *
     * The same hook is called on both single and batched variants. For single
     * transfers, the length of the `id` and `amount` arrays will be 1.
     *
     * Calling conditions (for each `id` and `amount` pair):
     *
     * - When `from` and `to` are both non-zero, `amount` of ``from``'s tokens
     * of token type `id` will be  transferred to `to`.
     * - When `from` is zero, `amount` tokens of token type `id` will be minted
     * for `to`.
     * - when `to` is zero, `amount` of ``from``'s tokens of token type `id`
     * will be burned.
     * - `from` and `to` are never both zero.
     * - `ids` and `amounts` have the same, non-zero length.
     *
     * To learn more about hooks, head to xref:ROOT:extending-contracts.adoc#using-hooks[Using Hooks].
     */
    function _beforeTokenTransfer(
        address operator,
        address from,
        address to,
        uint256[] memory ids,
        uint256[] memory amounts,
        bytes memory data
    )
        internal
        virtual
    { }

    function _doSafeTransferAcceptanceCheck(
        address operator,
        address from,
        address to,
        uint256 id,
        uint256 amount,
        bytes memory data
    )
        private
    {
        if (to.isContract()) {
            try IERC1155Receiver(to).onERC1155Received(operator, from, id, amount, data) returns (bytes4 response) {
                if (response != IERC1155Receiver(to).onERC1155Received.selector) {
                    revert("ERC1155: ERC1155Receiver rejected tokens");
                }
            } catch Error(string memory reason) {
                revert(reason);
            } catch {
                revert("ERC1155: transfer to non ERC1155Receiver implementer");
            }
        }
    }

    function _doSafeBatchTransferAcceptanceCheck(
        address operator,
        address from,
        address to,
        uint256[] memory ids,
        uint256[] memory amounts,
        bytes memory data
    )
        private
    {
        if (to.isContract()) {
            try IERC1155Receiver(to).onERC1155BatchReceived(operator, from, ids, amounts, data) returns (bytes4 response) {
                if (response != IERC1155Receiver(to).onERC1155BatchReceived.selector) {
                    revert("ERC1155: ERC1155Receiver rejected tokens");
                }
            } catch Error(string memory reason) {
                revert(reason);
            } catch {
                revert("ERC1155: transfer to non ERC1155Receiver implementer");
            }
        }
    }

    function _asSingletonArray(uint256 element) private pure returns (uint256[] memory) {
        uint256[] memory array = new uint256[](1);
        array[0] = element;

        return array;
    }
}

// File: @openzeppelin/contracts/utils/cryptography/ECDSA.sol


/**
 * @dev Elliptic Curve Digital Signature Algorithm (ECDSA) operations.
 *
 * These functions can be used to verify that a message was signed by the holder
 * of the private keys of a given address.
 */


// File: @openzeppelin/contracts/utils/Strings.sol


/**
 * @dev String operations.
 */


// File: contracts/ENSReverseRegistrarI.sol

/*
 * Interfaces for ENS Reverse Registrar
 * See https://github.com/ensdomains/ens/blob/master/contracts/ReverseRegistrar.sol for full impl
 * Also see https://github.com/wealdtech/wealdtech-solidity/blob/master/contracts/ens/ENSReverseRegister.sol
 *
 * Use this as follows (registryAddress is the address of the ENS registry to use):
 * -----
 * // This hex value is caclulated by namehash('addr.reverse')
 * bytes32 public constant ENS_ADDR_REVERSE_NODE = 0x91d1777781884d03a6757a803996e38de2a42967fb37eeaca72729271025a9e2;
 * function registerReverseENS(address registryAddress, string memory calldata) external {
 *     require(registryAddress != address(0), "need a valid registry");
 *     address reverseRegistrarAddress = ENSRegistryOwnerI(registryAddress).owner(ENS_ADDR_REVERSE_NODE)
 *     require(reverseRegistrarAddress != address(0), "need a valid reverse registrar");
 *     ENSReverseRegistrarI(reverseRegistrarAddress).setName(name);
 * }
 * -----
 * or
 * -----
 * function registerReverseENS(address reverseRegistrarAddress, string memory calldata) external {
 *    require(reverseRegistrarAddress != address(0), "need a valid reverse registrar");
 *     ENSReverseRegistrarI(reverseRegistrarAddress).setName(name);
 * }
 * -----
 * ENS deployments can be found at https://docs.ens.domains/ens-deployments
 * E.g. Etherscan can be used to look up that owner on those contracts.
 * namehash.hash("addr.reverse") == "0x91d1777781884d03a6757a803996e38de2a42967fb37eeaca72729271025a9e2"
 * Ropsten: ens.owner(namehash.hash("addr.reverse")) == "0x6F628b68b30Dc3c17f345c9dbBb1E483c2b7aE5c"
 * Mainnet: ens.owner(namehash.hash("addr.reverse")) == "0x084b1c3C81545d370f3634392De611CaaBFf8148"
 */





// File: contracts/BridgeDataI.sol

/*
 * Interface for data storage of the bridge.
 */



// File: contracts/ERC1155MintableI.sol

/*
 * Interfaces for mintable ERC721 compliant contracts.
 */


/**
 * @dev ERC1155 compliant contract with mint() and mintBatch() functions.
 */
interface ERC1155MintableI is IERC1155 {

    /**
     * @dev Creates `amount` tokens of token type `id`, and assigns them to `account`.
     *
     * Emits a {TransferSingle} event.
     *
     * Requirements:
     *
     * - `account` cannot be the zero address.
     * - If `account` refers to a smart contract, it must implement {IERC1155Receiver-onERC1155Received} and return the
     * acceptance magic value.
     */
    function mint(address account, uint256 id, uint256 amount) external;

    /**
     * @dev Batched version of {_mint}.
     *
     * Requirements:
     *
     * - `ids` and `amounts` must have the same length.
     * - If `to` refers to a smart contract, it must implement {IERC1155Receiver-onERC1155BatchReceived} and return the
     * acceptance magic value.
     */
    function mintBatch(address to, uint256[] memory ids, uint256[] memory amounts) external;

}

// File: contracts/BridgedERC1155I.sol

/*
 * Interface for a Bridged ERC721 token.
 */




interface BridgedERC1155I is IERC1155MetadataURI, ERC1155MintableI {

    event SignedBatchTransfer(address operator, address indexed from, address indexed to, uint256[] ids, uint256[] amounts, uint256 signedTransferNonce);

    /**
     * @dev True if this is the prototype, false if this is an active (clone/proxy) token contract.
     */
    function isPrototype() external view returns (bool);

    /**
     * @dev The address of the bridge data contract storing all addresses and chain info for this bridge
     */
    function bridgeData() external view returns (BridgeDataI);

    /**
     * @dev Do initial registration of a clone. Should be called in the same
     * transaction as the actual cloning. Can only be called once.
     */
    function initialRegister(address _bridgeDataAddress, string memory _orginalChainName, address _originalChainAddress) external;

    /**
     * @dev The name of the original chain this token is bridged from.
     */
    function originalChainName() external view returns (string memory);

    /**
     * @dev The address of this token on the original chain this is bridged from.
     */
    function originalChainAddress() external view returns (address);

    /**
     * @dev The signed transfer nonce for an account.
     */
    function signedTransferNonce(address account) external view returns (uint256);

    /**
     * @dev True if transfers are possible at this time.
     */
    function transferEnabled() external view returns (bool);

    /**
     * @dev Outward-facing function for signed transfer: assembles the expected data and then calls the internal function to do the rest.
     * Can called by anyone knowing about the right signature, but can only transfer to the given specific target.
     */
    function signedBatchTransfer(address from, address to, uint256[] memory ids, uint256[] memory amounts, bytes memory signature) external;

    /**
     * @dev Outward-facing function for operator-driven signed transfer: assembles the expected data and then calls the internal function to do the rest.
     * Can transfer to any target, but only be called by the trusted operator contained in the signature.
     */
    function signedBatchTransferWithOperator(address from, address to, uint256[] memory ids, uint256[] memory amounts, bytes memory signature) external;

}

// File: contracts/BridgedERC1155.sol

/*
 * A generic bridged semi-fungible token, to be deployed by the bridge when a
 * token from the other side is exiting on this side of the bridge.
 * Implements ERC 1155 token standard: https://eips.ethereum.org/EIPS/eip-1155
 */








contract BridgedERC1155 is ERC1155, BridgedERC1155I {
    using Strings for uint256;

    bool public override isPrototype;
    BridgeDataI public override bridgeData;
    string public override originalChainName;
    address public override originalChainAddress;

    mapping(address => uint256) public override signedTransferNonce;

    event BridgeDataChanged(address indexed previousBridgeData, address indexed newBridgeData);

    constructor(address _bridgeDataAddress)
    ERC1155("")
    {
        bridgeData = BridgeDataI(_bridgeDataAddress);
        // The initially deployed contract is just a prototype and code holder.
        // Clones will proxy their commends to this one and actually work.
        isPrototype = true;
    }

    modifier requireActive {
        require(!isPrototype, "Needs an active contract, not the prototype.");
        _;
    }

    modifier onlyBridgeControl()
    {
        require(msg.sender == bridgeData.getAddress("bridgeControl"), "bridgeControl key required for this function.");
        _;
    }

    modifier onlyBridge()
    {
        require(msg.sender == bridgeData.getAddress("bridgeControl") || msg.sender == bridgeData.getAddress("bridgeHead"), "bridgeControl key or bridge head required for this function.");
        _;
    }

    modifier onlyTokenAssignmentControl() {
        require(msg.sender == bridgeData.getAddress("tokenAssignmentControl"), "tokenAssignmentControl key required for this function.");
        _;
    }

    modifier requireTransferEnabled() {
        require(transferEnabled() == true, "This call only works when transfers are enabled.");
        _;
    }

    /*** Initialize the basic variables ***/

    function initialRegister(address _bridgeDataAddress, string memory _originalChainName, address _originalChainAddress)
    external override
    requireActive
    {
        // Make sure that this function has not been called on this contract yet.
        require(address(bridgeData) == address(0), "Cannot be initialized twice.");
        bridgeData = BridgeDataI(_bridgeDataAddress);
        originalChainName = _originalChainName;
        originalChainAddress = _originalChainAddress;
    }

    /*** Enable adjusting variables after deployment ***/

    function setBridgeData(BridgeDataI _newBridgeData)
    external
    onlyBridgeControl
    {
        require(address(_newBridgeData) != address(0x0), "You need to provide an actual bridge data contract.");
        emit BridgeDataChanged(address(bridgeData), address(_newBridgeData));
        bridgeData = _newBridgeData;
    }

    // Return true if transfers are possible.
    // This can have additional conditions to just the sunset variable.
    function transferEnabled()
    public view override
    requireActive
    returns (bool)
    {
        uint256 tokenSunsetTimestamp = bridgeData.tokenSunsetTimestamp();
        // solhint-disable-next-line not-rely-on-time
        return (tokenSunsetTimestamp == 0 || tokenSunsetTimestamp > block.timestamp);
    }

    function uri(uint256 _tokenId) public view override(ERC1155, IERC1155MetadataURI) returns (string memory) {
        return string(abi.encodePacked(bridgeData.tokenURIBase(), uint256(uint160(address(this))).toHexString(20), "/meta/", _tokenId.toString()));
    }

    /*** Implement mintable and exists interfaces ***/

    // Mint a token. Calls onERC1155Received() on the `_to` address if it's a contract.
    function mint(address _account, uint256 _id, uint256 _amount)
    public override
    requireTransferEnabled
    onlyBridge
    {
        _mint(_account, _id, _amount, "");
    }

    // Mint a batch of tokens. Calls onERC1155Received() on the `_to` address if it's a contract.
    function mintBatch(address _to, uint256[] memory _ids, uint256[] memory _amounts)
    public override
    requireTransferEnabled
    onlyBridge
    {
        _mintBatch(_to, _ids, _amounts, "");
    }

    // Burn a batch of NFTs.
    function burnBatch(address _account, uint256[] memory _ids, uint256[] memory _amounts)
    public
    requireTransferEnabled
    onlyBridge
    {
        _burnBatch(_account, _ids, _amounts);
    }

    /*** Override internal functionality for special rules on approvals and transfers ***/

    // When the bridge is sunset, all token actions will be blocked.
    function _beforeTokenTransfer(address _operator, address _from, address _to, uint256[] memory _ids, uint256[] memory _amounts, bytes memory _data)
    internal override
    requireTransferEnabled
    {
        super._beforeTokenTransfer(_operator, _from, _to, _ids, _amounts, _data);
    }

    /*** Allows any user to initiate a transfer with the signature of the current stamp owner  ***/

    // Outward-facing function for signed transfer: assembles the expected data and then calls the internal function to do the rest.
    // Can called by anyone knowing about the right signature, but can only transfer to the given specific target.
    function signedBatchTransfer(address _from, address _to, uint256[] memory _ids, uint256[] memory _amounts, bytes memory _signature)
    public override
    requireTransferEnabled
    {
        // The signed data contains the token IDs, amounts, the transfer source and target as well as a nonce.
        bytes32 data = keccak256(abi.encodePacked(address(this), this.signedBatchTransfer.selector, _from, _to, _ids, _amounts, signedTransferNonce[_from]));
        _signedBatchTransferInternal(_from, _to, _ids, _amounts, data, _signature);
    }

    // Outward-facing function for operator-driven signed transfer: assembles the expected data and then calls the internal function to do the rest.
    // Can transfer to any target, but only be called by the trusted operator contained in the signature.
    function signedBatchTransferWithOperator(address _from, address _to, uint256[] memory _ids, uint256[] memory _amounts, bytes memory _signature)
    public override
    requireTransferEnabled
    {
        // The signed data contains the operator, the token IDs, amounts, and a nonce. Note that we use the selector of the external function here!
        bytes32 data = keccak256(abi.encodePacked(address(this), this.signedBatchTransferWithOperator.selector, msg.sender, _from, _ids, _amounts, signedTransferNonce[_from]));
        _signedBatchTransferInternal(_from, _to, _ids, _amounts, data, _signature);
    }

    // Actually check the signature and perform a signed transfer.
    function _signedBatchTransferInternal(address _from, address _to, uint256[] memory _ids, uint256[] memory _amounts, bytes32 _data, bytes memory _signature)
    internal
    {
        bytes32 hash = ECDSA.toEthSignedMessageHash(_data);
        address signer = ECDSA.recover(hash, _signature);
        require(signer == _from, "Signature needs to match parameters, nonce, and current owner.");
        // Now that we checked that the signature is correct, do the actual transfer and increase the nonce.
        emit SignedBatchTransfer(msg.sender, _from, _to, _ids, _amounts, signedTransferNonce[_from]);
        signedTransferNonce[_from]++;
        _safeBatchTransferFrom(_from, _to, _ids, _amounts, "");
    }

    /*** Enable reverse ENS registration ***/

    // Call this with the address of the reverse registrar for the respective network and the ENS name to register.
    // The reverse registrar can be found as the owner of 'addr.reverse' in the ENS system.
    // For Mainnet, the address needed is 0x9062c0a6dbd6108336bcbe4593a3d1ce05512069
    function registerReverseENS(address _reverseRegistrarAddress, string calldata _name)
    external
    onlyTokenAssignmentControl
    {
        require(_reverseRegistrarAddress != address(0), "need a valid reverse registrar");
        ENSReverseRegistrarI(_reverseRegistrarAddress).setName(_name);
    }

    /*** Make sure currency or NFT doesn't get stranded in this contract ***/

    // If this contract gets a balance in some ERC20 contract after it's finished, then we can rescue it.
    function rescueToken(address _foreignToken, address _to)
    external
    onlyTokenAssignmentControl
    {
        IERC20 erc20Token = IERC20(_foreignToken);
        erc20Token.transfer(_to, erc20Token.balanceOf(address(this)));
    }

    // If this contract gets a balance in some ERC721 contract after it's finished, then we can rescue it.
    function approveNFTrescue(IERC721 _foreignNFT, address _to)
    external
    onlyTokenAssignmentControl
    {
        _foreignNFT.setApprovalForAll(_to, true);
    }

}