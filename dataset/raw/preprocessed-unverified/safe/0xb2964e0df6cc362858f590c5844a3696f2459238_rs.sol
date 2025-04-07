/**
 *Submitted for verification at Etherscan.io on 2021-08-23
*/

// File: contracts/Dependencies/Context.sol

// SPDX-License-Identifier: MIT

pragma solidity ^0.6.12;
pragma experimental ABIEncoderV2;

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
        this;
        // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}

// File: contracts/proxy/Dependencies/Ownable.sol

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
        _transferOwnership(newOwner);
    }

    function _transferOwnership(address newOwner) internal {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}

// File: contracts/Dependencies/SafeMath.sol

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


// File: contracts/Dependencies/IERC20.sol

/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
 */


// File: contracts/Dependencies/Address.sol

/**
 * @dev Collection of functions related to the address type
 */


// File: contracts/Dependencies/SafeERC20.sol

/**
 * @title SafeERC20
 * @dev Wrappers around ERC20 operations that throw on failure (when the token
 * contract returns false). Tokens that return no value (and instead revert or
 * throw on failure) are also supported, non-reverting calls are assumed to be
 * successful.
 * To use this library you can add a `using SafeERC20 for IERC20;` statement to your contract,
 * which allows you to call the safe operations as `token.safeTransfer(...)`, etc.
 */


// File: contracts/Dependencies/IERC165.sol

/**
 * @dev Interface of the ERC165 standard, as defined in the
 * https://eips.ethereum.org/EIPS/eip-165[EIP].
 *
 * Implementers can declare support of contract interfaces, which can then be
 * queried by others ({ERC165Checker}).
 *
 * For an implementation, see {ERC165}.
 */


// File: contracts/Dependencies/IERC721.sol

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

// File: contracts/Dependencies/HasCopyright.sol



// File: contracts/Dependencies/ReentrancyGuard.sol

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

// File: contracts/proxy/FixedPriceTrade721.sol

contract FixedPriceTrade721 is Ownable, ReentrancyGuard {
    using SafeMath for uint;
    using SafeERC20 for IERC20;

    uint private orderIDCounter;
    bool private onlyInitOnce;
    address public erc721AddressWithCopyright;

    struct Order {
        // address of maker
        address maker;
        // address of ERC721 token to sell
        address tokenAddress;
        // tokenID of ERC721 token to sell
        uint tokenID;
        // address of ERC20 token to pay
        address payTokenAddress;
        // price of ERC20 token to pay
        uint fixedPrice;
        // whether the order is available
        bool isAvailable;
    }

    // order ID -> order
    mapping(uint => Order) orders;

    event MakeOrder(uint _orderID, address _maker, address _tokenAddress, uint _tokenID, address _payTokenAddress, uint _fixedPrice);
    event CancelOrder(uint _orderID, address _maker);
    event UpdatePrice(uint _orderID, address _maker, address _newPayTokenAddress, uint _newPrice);
    event TakeOrder(uint _orderID, address _taker, address _maker, address _tokenAddress, uint _tokenID, address _payTokenAddress, uint _fixedPrice);
    event Erc721AddressWithCopyrightChanged(address _previousAddress, address _currentAddress);
    event PayCopyrightFee(uint _orderID, address _taker, address _author, uint _copyrightFee);

    function init(address _erc721AddressWithCopyright, address _newOwner) public {
        require(!onlyInitOnce, "already initialized");

        erc721AddressWithCopyright = _erc721AddressWithCopyright;
        emit Erc721AddressWithCopyrightChanged(address(0), _erc721AddressWithCopyright);

        _transferOwnership(_newOwner);
        onlyInitOnce = true;
    }

    // ask
    function ask(address _tokenAddress, uint _tokenID, address _payTokenAddress, uint _fixedPrice) external nonReentrant {
        // 1. check the validity of params
        require(IERC721(_tokenAddress).ownerOf(_tokenID) == msg.sender,
            "unmatched ownership of target ERC721 token");
        require(_fixedPrice > 0,
            "the fixed price must be > 0");

        // 2. build order
        Order memory order = Order({
        maker : msg.sender,
        tokenAddress : _tokenAddress,
        tokenID : _tokenID,
        payTokenAddress : _payTokenAddress,
        fixedPrice : _fixedPrice,
        isAvailable : true
        });

        // 3. store order
        uint currentOrderID = orderIDCounter;
        orders[currentOrderID] = order;
        orderIDCounter = orderIDCounter.add(1);

        // 4. check the approve of ERC721 transferring
        IERC721 tokenAddressCached = IERC721(order.tokenAddress);
        require(tokenAddressCached.getApproved(order.tokenID) == address(this) ||
            tokenAddressCached.isApprovedForAll(msg.sender, address(this)),
            "the contract hasn't been approved for ERC721 transferring");

        emit MakeOrder(currentOrderID, order.maker, order.tokenAddress, order.tokenID, order.payTokenAddress, order.fixedPrice);
    }

    function cancelOrder(uint _orderID) external {
        Order memory order = _getOrderByID(_orderID);
        _requireOrderByMaker(msg.sender, order);

        orders[_orderID].isAvailable = false;
        emit CancelOrder(_orderID, msg.sender);
    }

    function updatePrice(uint _orderID, address _payTokenAddress, uint _price) external nonReentrant {
        Order memory order = _getOrderByID(_orderID);
        _requireOrderByMaker(msg.sender, order);
        require(_price > 0,
            "the price to update must be > 0");
        // check the approve of ERC721 transferring
        IERC721 tokenAddressCached = IERC721(order.tokenAddress);
        require(tokenAddressCached.getApproved(order.tokenID) == address(this) ||
            tokenAddressCached.isApprovedForAll(msg.sender, address(this)),
            "the contract hasn't been approved for ERC721 transferring");

        orders[_orderID].payTokenAddress = _payTokenAddress;
        orders[_orderID].fixedPrice = _price;
        emit UpdatePrice(_orderID, msg.sender, _payTokenAddress, _price);
    }

    // bid
    function bid(uint _orderID) external nonReentrant {
        Order memory order = _getOrderByID(_orderID);
        require(order.isAvailable,
            "the order isn't available");
        require(order.maker != msg.sender,
            "the maker can't bid for its own order");

        // check && pay copyright fee
        (uint transferAmount, uint copyrightFee,address author) = _getTransferAndCopyrightFeeAndAuthor(order);
        IERC20 tokenToPay = IERC20(order.payTokenAddress);

        if (copyrightFee != 0) {
            // pay the copyright fee
            tokenToPay.safeTransferFrom(msg.sender, author, copyrightFee);
            emit PayCopyrightFee(_orderID, msg.sender, author, copyrightFee);
        }

        // pay the transfer
        tokenToPay.safeTransferFrom(msg.sender, order.maker, transferAmount);

        // transfer ERC721 token to taker
        IERC721(order.tokenAddress).safeTransferFrom(order.maker, msg.sender, order.tokenID);

        // close the order
        orders[_orderID].isAvailable = false;
        emit TakeOrder(_orderID, msg.sender, order.maker, order.tokenAddress, order.tokenID, order.payTokenAddress, order.fixedPrice);
    }

    function setErc721AddressWithCopyright(address _erc721AddressWithCopyright) public onlyOwner {
        address previousAddress = erc721AddressWithCopyright;
        erc721AddressWithCopyright = _erc721AddressWithCopyright;
        emit Erc721AddressWithCopyrightChanged(previousAddress, _erc721AddressWithCopyright);
    }

    function getOrder(uint _orderID) public view returns (Order memory){
        return _getOrderByID(_orderID);
    }

    function _getTransferAndCopyrightFeeAndAuthor(Order memory _order) internal returns (uint transferAmount, uint copyrightFee, address author){
        transferAmount = _order.fixedPrice;
        if (_order.tokenAddress != erc721AddressWithCopyright) {
            // not the official address of ERC721 token
            return (transferAmount, copyrightFee, author);
        }

        HasCopyright erc721WithCopyrightCached = HasCopyright(_order.tokenAddress);
        HasCopyright.Copyright memory copyright = erc721WithCopyrightCached.getCopyright(_order.tokenID);
        uint feeRateDenominator = erc721WithCopyrightCached.getFeeRateDenominator();
        if (copyright.author == address(0) || copyright.feeRateNumerator == 0 || copyright.feeRateNumerator > feeRateDenominator) {
            // the official ERC721 token has an invalid copyright
            return (transferAmount, copyrightFee, author);
        }

        author = copyright.author;
        copyrightFee = transferAmount.mul(copyright.feeRateNumerator).div(feeRateDenominator);
        transferAmount = transferAmount.sub(copyrightFee);
    }

    function _requireOrderByMaker(address _maker, Order memory _order) internal pure {
        require(_order.isAvailable,
            "the order isn't available");
        require(_order.maker == _maker,
            "an order can only be updated or cancelled by its maker");
    }

    function _getOrderByID(uint _orderID) internal view returns (Order memory order){
        order = orders[_orderID];
        require(order.maker != address(0),
            "the target order doesn't exist");
    }
}