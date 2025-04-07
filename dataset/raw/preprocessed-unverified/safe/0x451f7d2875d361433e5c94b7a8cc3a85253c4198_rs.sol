/**
 *Submitted for verification at Etherscan.io on 2021-07-20
*/

pragma solidity ^0.8.0;

// SPDX-License-Identifier: MIT

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

// CAUTION
// This version of SafeMath should only be used with Solidity 0.8 or later,
// because it relies on the compiler's built in overflow checks.

/**
 * @dev Wrappers over Solidity's arithmetic operations.
 *
 * NOTE: `SafeMath` is no longer needed starting with Solidity 0.8. The compiler
 * now has built in overflow checking.
 */



interface ISingleNFT is IERC721 {

    function setTokenOnSale(uint256 tokenId) external;

    function cancelTokenSale(uint256 tokenId) external;

    function setTokenOnAuction(uint256 tokenId) external;

    function setTokenOnBasic(uint256 tokenId) external;

    function tokenStatus(uint256 tokenID) external view returns(uint256);

    function getRoyaltyFee(uint256 id) external view returns (uint256);

    function getRoyaltyAddress(uint256 id) external view returns (address payable);
}


contract Escrow is Ownable {

    using SafeMath for uint256;

    address payable public DAO = payable(0x42D374c81dD21b12Ef2b05CA4Add1Ea63AA8DBe6);       // send 1% of royalty to dao

    ISingleNFT public singleNFT;

    struct Winner{
        uint256 price;
        address winner;
    }

    constructor(ISingleNFT _singleNFT) {
        singleNFT = _singleNFT;
    }

    mapping(uint256 => Winner) public items;

    function bid(uint256 tokenID, address bidder) payable external onlyOwner {
        address payable oldWinner = payable(items[tokenID].winner);
        uint256 oldPrice = items[tokenID].price;
        oldWinner.transfer(oldPrice);
        items[tokenID].winner = bidder;
        items[tokenID].price = msg.value;
    }

    function finishAuction(uint256 tokenID) external onlyOwner {
        if(items[tokenID].winner == address(0x0)){
            items[tokenID].price = 0;
            return;
        }
        address payable owner = payable(singleNFT.ownerOf(tokenID));
        uint256 payAmount = items[tokenID].price;
        address payable royaltyAddress = singleNFT.getRoyaltyAddress(tokenID);
        uint256 royaltyFee = singleNFT.getRoyaltyFee(tokenID);
        uint256 royaltyAmount = payAmount.mul(royaltyFee).div(100);
        owner.transfer(payAmount.sub(royaltyAmount));
        royaltyAddress.transfer(royaltyAmount.mul(99).div(100));
        DAO.transfer(royaltyAmount.div(100));

        items[tokenID].winner = address(0x0);
        items[tokenID].price = 0;
    }

    function startAuction(uint256 tokenID, uint256 _price) external onlyOwner {
        Winner memory _winner = Winner({winner: address(0x0), price: _price});
        items[tokenID] = _winner;
    }

    function getFinalPrice(uint256 tokenId) external view returns(uint256) {
        return items[tokenId].price;
    }
}

contract Treasury is Ownable {

    using SafeMath for uint256;

    mapping(uint256 => uint256) public price;
    mapping(uint256 => uint256) public auctionDuration;

    ISingleNFT public single;
    Escrow public escrow;

    address payable public DAO = payable(0x42D374c81dD21b12Ef2b05CA4Add1Ea63AA8DBe6);       // send 1% of royalty to dao

    constructor(ISingleNFT _singleNFT, Escrow _escrow) {
        single = _singleNFT;
        escrow = _escrow;
    }

    function setOnSale(uint256 tokenId, uint256 _price) external {
        require(single.ownerOf(tokenId) == msg.sender, 'Treasury: not owner');
        require(single.isApprovedForAll(msg.sender, address(this)) == true, 'Treasury: not operator');
        require(single.tokenStatus(tokenId) == 0, 'Treasury: not available');
        price[tokenId] = _price;
        single.setTokenOnSale(tokenId);
    }

    function buyToken(uint256 tokenId) external payable{
        require(single.ownerOf(tokenId) != msg.sender, 'Treasury: not owner');
        require(single.isApprovedForAll(single.ownerOf(tokenId), address(this)) == true, 'Treasury: not operator');
        require(single.tokenStatus(tokenId) == 1, 'Treasury: not on Sale');
        require(msg.value >= price[tokenId], "Treasury: insufficient funds");

        address payable currentOwner = payable(single.ownerOf(tokenId));
        address payable royaltyAddress = single.getRoyaltyAddress(tokenId);
        uint256 royaltyFee = single.getRoyaltyFee(tokenId);
        uint256 royaltyValue = msg.value.mul(royaltyFee).div(100);
        royaltyAddress.transfer(msg.value.sub(royaltyValue));   // send ETH to seller (except royalty Fee)

        DAO.transfer(royaltyValue.div(100));                    // send 1% of royalty to DAO
        currentOwner.transfer(royaltyValue.mul(99).div(100));                    // send royalty Fee to creator

        single.setTokenOnBasic(tokenId);
        single.safeTransferFrom(currentOwner, msg.sender, tokenId);
    }

    function cancelOnSale(uint256 tokenId) external {
        require(single.ownerOf(tokenId) == msg.sender, 'Treasury: not owner');
        require(single.isApprovedForAll(msg.sender, address(this)) == true, 'Treasury: not operator');
        require(single.tokenStatus(tokenId) == 1, 'Treasury: not on Sale');

        single.cancelTokenSale(tokenId);
    }

    function setOnAuction(uint256 tokenId, uint256 _price, uint256 duration) external {
        require(single.ownerOf(tokenId) == msg.sender, 'Treasury: not owner');
        require(single.isApprovedForAll(msg.sender, address(this)) == true, 'Treasury: not operator');
        require(single.tokenStatus(tokenId) == 0, 'Treasury: not available');

        single.setTokenOnAuction(tokenId);
        escrow.startAuction(tokenId, _price);
        auctionDuration[tokenId] = block.timestamp.add(duration);
    }

    function bidOnAuction(uint256 tokenId) external payable {
        require(single.ownerOf(tokenId) != msg.sender, 'Treasury: should not be owner');
        require(single.isApprovedForAll(single.ownerOf(tokenId), address(this)) == true, 'Treasury: not operator');
        require(single.tokenStatus(tokenId) == 2, 'Treasury: not on Auction');
        require(auctionDuration[tokenId] > block.timestamp, 'Treasury: not live');
        require(msg.value > escrow.getFinalPrice(tokenId), 'Treasury: should be bigger than current auction');

        escrow.bid{value:msg.value}(tokenId, msg.sender);
    }

    function finishAuction(uint256 tokenId) external {
        require(auctionDuration[tokenId] <= block.timestamp, 'Treasury: live auction');

        escrow.finishAuction(tokenId);
        single.setTokenOnBasic(tokenId);
        single.safeTransferFrom(single.ownerOf(tokenId), msg.sender, tokenId);
    }
}