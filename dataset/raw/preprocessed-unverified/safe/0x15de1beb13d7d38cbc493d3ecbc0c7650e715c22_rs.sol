/**
 *Submitted for verification at Etherscan.io on 2021-08-15
*/

// SPDX-License-Identifier: Apache License, Version 2.0

pragma solidity 0.7.6;



// Part: Address

/**
 * @dev Collection of functions related to the address type
 */


// Part: Context

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

// Part: ERC165Checker

/**
 * @dev Library used to query support of an interface declared via {IERC165}.
 *
 * Note that these functions return the actual result of the query: they do not
 * `revert` if an interface is not supported. It is up to the caller to decide
 * what to do in these cases.
 */


// Part: IERC165

/**
 * @dev Interface of the ERC165 standard, as defined in the
 * https://eips.ethereum.org/EIPS/eip-165[EIP].
 *
 * Implementers can declare support of contract interfaces, which can then be
 * queried by others ({ERC165Checker}).
 *
 * For an implementation, see {ERC165}.
 */


// Part: SafeMath

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


// Part: ERC165

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

// Part: IERC1155

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

// Part: IERC1155Receiver

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

// Part: Ownable

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

// Part: IERC1155MetadataURI

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

// Part: IStarNFT

/**
 * @title IStarNFT
 * @author Galaxy Protocol
 *
 * Interface for operating with StarNFTs.
 */
interface IStarNFT is IERC1155 {
    /* ============ Events =============== */
//    event PowahUpdated(uint256 indexed id, uint256 indexed oldPoints, uint256 indexed newPoints);

    /* ============ Functions ============ */

    function isOwnerOf(address, uint256) external view returns (bool);
//    function starInfo(uint256) external view returns (uint128 powah, uint128 mintBlock, address originator);
//    function quasarInfo(uint256) external view returns (uint128 mintBlock, IERC20 stakeToken, uint256 amount, uint256 campaignID);
//    function superInfo(uint256) external view returns (uint128 mintBlock, IERC20[] memory stakeToken, uint256[] memory amount, uint256 campaignID);

    // mint
    function mint(address account, uint256 powah) external returns (uint256);
    function mintBatch(address account, uint256 amount, uint256[] calldata powahArr) external returns (uint256[] memory);
    function burn(address account, uint256 id) external;
    function burnBatch(address account, uint256[] calldata ids) external;

    // asset-backing mint
//    function mintQuasar(address account, uint256 powah, uint256 cid, IERC20 stakeToken, uint256 amount) external returns (uint256);
//    function burnQuasar(address account, uint256 id) external;

    // asset-backing forge
//    function mintSuper(address account, uint256 powah, uint256 campaignID, IERC20[] calldata stakeTokens, uint256[] calldata amounts) external returns (uint256);
//    function burnSuper(address account, uint256 id) external;
    // update
//    function updatePowah(address owner, uint256 id, uint256 powah) external;
}

// File: StarNFTV1.sol

//import "../../interfaces/listener/IStarUpdateListener.sol";


/**
 * based on https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/token/ERC1155/ERC1155.sol
 */
contract StarNFTV1 is ERC165, IERC1155, IERC1155MetadataURI, IStarNFT, Ownable {
    using SafeMath for uint256;
    using Address for address;
    using ERC165Checker for address;

    /* ============ Events ============ */
    /* ============ Modifiers ============ */
    /**
     * Only minter.
     */
    modifier onlyMinter() {
        require(minters[msg.sender], "must be minter");
        _;
    }
    /* ============ Enums ================ */
    /* ============ Structs ============ */
    /* ============ State Variables ============ */

    // Used as the URI for all token types by ID substitution, e.g. https://galaxy.eco/{address}/{id}.json
    string public baseURI;

    // Mint and burn star.
    mapping(address => bool) public minters;

    // Total star count, including burnt nft
    uint256 public starCount;
    // Mapping from token ID to account
    mapping(uint256 => address) public starBelongTo;

    // Mapping from account to operator approvals
    mapping(address => mapping(address => bool)) private _operatorApprovals;


    /* ============ Constructor ============ */
    constructor () public {}

    /* ============ External Functions ============ */
    /**
     * See {IERC1155-setApprovalForAll}.
     */
    function setApprovalForAll(address operator, bool approved) external override {
        require(msg.sender != operator, "Setting approval status for self");

        _operatorApprovals[msg.sender][operator] = approved;
        emit ApprovalForAll(msg.sender, operator, approved);
    }

    /**
     * See {IERC1155-safeTransferFrom}.
     */
    function safeTransferFrom(address from, address to, uint256 id, uint256 amount, bytes memory data) external override {
        require(to != address(0), "Transfer to must not be null address");
        require(amount == 1, "Invalid amount");
        require(
            from == msg.sender || isApprovedForAll(from, msg.sender),
            "Transfer caller is neither owner nor approved"
        );
        require(isOwnerOf(from, id), "Not the owner");

        starBelongTo[id] = to;

        emit TransferSingle(msg.sender, from, to, id, amount);

        _doSafeTransferAcceptanceCheck(msg.sender, from, to, id, amount, data);
    }

    /**
     * See {IERC1155-safeBatchTransferFrom}.
     */
    function safeBatchTransferFrom(address from, address to, uint256[] memory ids, uint256[] memory amounts, bytes memory data) external override {
        require(to != address(0), "Batch transfer to must not be null address");
        require(ids.length == amounts.length, "Array(ids, amounts) length mismatch");
        require(from == msg.sender || isApprovedForAll(from, msg.sender), "Transfer caller is neither owner nor approved");

        for (uint256 i = 0; i < ids.length; ++i) {
            uint256 id = ids[i];
            require(isOwnerOf(from, id), "Not the owner");
            starBelongTo[id] = to;
        }

        emit TransferBatch(msg.sender, from, to, ids, amounts);

        _doSafeBatchTransferAcceptanceCheck(msg.sender, from, to, ids, amounts, data);
    }

    function mint(address account, uint256 powah) external onlyMinter override returns (uint256) {
        return _mint(account, powah);
    }

    function mintBatch(address account, uint256 amount, uint256[] calldata powahArr) external onlyMinter override returns (uint256[] memory) {
        require(account != address(0), "Must not mint to null address");
        require(powahArr.length == amount, "Array(powah) length mismatch param(amount)");
        return _mintBatch(account, amount, powahArr);
    }

    function burn(address account, uint256 id) external onlyMinter override {
        require(isOwnerOf(account, id), "Not the owner");
        _burn(account, id);
    }

    function burnBatch(address account, uint256[] calldata ids) external onlyMinter override {
        for (uint i = 0; i < ids.length; i++) {
            require(isOwnerOf(account, ids[i]), "Not the owner");
        }
        _burnBatch(account, ids);
    }

    /**
     * PRIVILEGED MODULE FUNCTION. Sets a new baseURI for all token types.
     */
    function setURI(string memory newURI) external onlyOwner {
        baseURI = newURI;
    }

    /**
     * PRIVILEGED MODULE FUNCTION. Add a new minter.
     */
    function addMinter(address minter) external onlyOwner {
        require(minter != address(0), "Minter must not be null address");
        require(!minters[minter], "Minter already added");
        minters[minter] = true;
    }

    /**
     * PRIVILEGED MODULE FUNCTION. Remove a old minter.
     */
    function removeMinter(address minter) external onlyOwner {
        require(minters[minter], "Minter does not exist");
        delete minters[minter];
    }

    /* ============ External Getter Functions ============ */
    /**
     * See {IERC1155-isApprovedForAll}.
     */
    function isApprovedForAll(address account, address operator) public view override returns (bool) {
        return _operatorApprovals[account][operator];
    }

    /**
     * See {IERC1155MetadataURI-uri}.
     *
     * This implementation returns the same URI for *all* token types. It relies
     * on the token type ID substitution mechanism
     * https://eips.ethereum.org/EIPS/eip-1155#metadata[defined in the EIP].
     *
     * Clients calling this function must replace the `\{id\}` substring with the
     * actual token type ID.
     */
    function uri(uint256 id) external view override returns (string memory) {
        require(id <= starCount, "NFT does not exist");
        // Even if there is a base URI, it is only appended to non-empty token-specific URIs
        if (bytes(baseURI).length == 0) {
            return "";
        } else {
            // bytes memory b = new bytes(32);
            // assembly { mstore(add(b, 32), id) }
            // abi.encodePacked is being used to concatenate strings
            return string(abi.encodePacked(baseURI, uint2str(id), ".json"));
        }
    }

    /**
     * Is the nft owner.
     * Requirements:
     * - `account` must not be zero address.
     */
    function isOwnerOf(address account, uint256 id) public view override returns (bool) {
        if (account == address(0)) {
            return false;
        } else {
            return starBelongTo[id] == account;
        }
    }

    /**
     * See {IERC1155-balanceOf}.
     * Requirements:
     * - `account` must not be zero address.
     */
    function balanceOf(address account, uint256 id) public view override returns (uint256) {
        if (isOwnerOf(account, id)) {
            return 1;
        }
        return 0;
    }

    /**
     * See {IERC1155-balanceOfBatch}.
     * Requirements:
     * - `accounts` and `ids` must have the same length.
     */
    function balanceOfBatch(address[] memory accounts, uint256[] memory ids) public view override returns (uint256[] memory){
        require(accounts.length == ids.length, "Array(accounts, ids) length mismatch");

        uint256[] memory batchBalances = new uint256[](accounts.length);

        for (uint256 i = 0; i < accounts.length; ++i) {
            batchBalances[i] = balanceOf(accounts[i], ids[i]);
        }

        return batchBalances;
    }

    /* ============ Internal Functions ============ */
    /* ============ Private Functions ============ */
    /**
     * Create star with `powah`, and assign it to `account`.
     *
     * Emits a {TransferSingle} event.
     *
     * Requirements:
     * - `account` must not be zero address.
     * - If `account` refers to a smart contract, it must implement {IERC1155Receiver-onERC1155Received} and return the
     * acceptance magic value.
     */
    function _mint(address account, uint256 powah) private returns (uint256) {
        require(account != address(0), "Must not mint to null address");
        starCount++;
        uint256 sID = starCount;
        starBelongTo[sID] = account;
        //        _stars[sID] = NFTInfo({
        //        powah : uint128(powah),
        //        mintBlock : uint128(block.number),
        //        originator : address(0)
        //        });

        emit TransferSingle(msg.sender, address(0), account, sID, 1);

        _doSafeTransferAcceptanceCheck(msg.sender, address(0), account, sID, 1, "");

        return sID;
    }

    /**
     * Mint `amount` star nft to `to`
     *
     * Requirements:
     * - If `to` refers to a smart contract, it must implement {IERC1155Receiver-onERC1155BatchReceived} and return the
     * acceptance magic value.
     */
    function _mintBatch(address to, uint256 amount, uint256[] calldata powahArr) private returns (uint256[] memory) {
        uint256[] memory ids = new uint256[](amount);
        uint256[] memory amounts = new uint256[](amount);
        for (uint i = 0; i < ids.length; i++) {
            starCount++;
            starBelongTo[starCount] = to;
            //            _stars[_starCount] = NFTInfo({
            //            powah : uint128(powahArr[i]),
            //            mintBlock : uint128(block.number),
            //            originator : to
            //            });
            ids[i] = starCount;
            amounts[i] = 1;
        }

        emit TransferBatch(msg.sender, address(0), to, ids, amounts);

        _doSafeBatchTransferAcceptanceCheck(msg.sender, address(0), to, ids, amounts, "");

        return ids;
    }

    /**
     * Burn `id` nft from `account`.
     */
    function _burn(address account, uint256 id) private {
        delete starBelongTo[id];

        emit TransferSingle(msg.sender, account, address(0), id, 1);
    }

    /**
     * xref:ROOT:erc1155.doc#batch-operations[Batched] version of {_burn}.
     *
     * Requirements:
     * - `ids` and `amounts` must have the same length.
     */
    function _burnBatch(address account, uint256[] memory ids) private {
        uint256[] memory amounts = new uint256[](ids.length);
        for (uint i = 0; i < ids.length; i++) {
            delete starBelongTo[ids[i]];
            //            delete _quasars[ids[i]];
            //            delete _supers[ids[i]];
            //            delete _stars[ids[i]];
            amounts[i] = 1;
        }

        emit TransferBatch(msg.sender, account, address(0), ids, amounts);
    }

    function _doSafeTransferAcceptanceCheck(address operator, address from, address to, uint256 id, uint256 amount, bytes memory data) private {
        if (to.isContract()) {
            try IERC1155Receiver(to).onERC1155Received(operator, from, id, amount, data) returns (bytes4 response) {
                if (response != IERC1155Receiver(to).onERC1155Received.selector) {
                    revert("ERC1155Receiver rejected tokens");
                }
            } catch Error(string memory reason) {
                revert(reason);
            } catch {
                revert("transfer to non ERC1155Receiver implementer");
            }
        }
    }

    function _doSafeBatchTransferAcceptanceCheck(address operator, address from, address to, uint256[] memory ids, uint256[] memory amounts, bytes memory data) private {
        if (to.isContract()) {
            try IERC1155Receiver(to).onERC1155BatchReceived(operator, from, ids, amounts, data) returns (bytes4 response) {
                if (response != IERC1155Receiver(to).onERC1155BatchReceived.selector) {
                    revert("ERC1155Receiver rejected tokens");
                }
            } catch Error(string memory reason) {
                revert(reason);
            } catch {
                revert("transfer to non ERC1155Receiver implementer");
            }
        }
    }

    /* ============ Util Functions ============ */
    function uint2str(uint _i) internal pure returns (string memory) {
        if (_i == 0) {
            return "0";
        }
        uint j = _i;
        uint len;
        while (j != 0) {
            len++;
            j /= 10;
        }
        bytes memory bStr = new bytes(len);
        uint k = len;
        while (_i != 0) {
            k = k - 1;
            uint8 temp = (48 + uint8(_i - _i / 10 * 10));
            bytes1 b1 = bytes1(temp);
            bStr[k] = b1;
            _i /= 10;
        }
        return string(bStr);
    }
}