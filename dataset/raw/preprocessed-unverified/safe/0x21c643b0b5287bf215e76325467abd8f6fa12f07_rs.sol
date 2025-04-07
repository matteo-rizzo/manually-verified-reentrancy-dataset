/**
 *Submitted for verification at Etherscan.io on 2021-04-07
*/

pragma solidity ^0.5.12;


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
 * @dev Interface of the ERC20 standard as defined in the EIP. Does not include
 * the optional functions; to access them see {ERC20Detailed}.
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
 *
 * _Since v2.5.0:_ this module is now much more gas efficient, given net gas
 * metering changes introduced in the Istanbul hardfork.
 */
contract ReentrancyGuard {
    bool private _notEntered;

    constructor () internal {
        // Storing an initial non-zero value makes deployment a bit more
        // expensive, but in exchange the refund on every call to nonReentrant
        // will be lower in amount. Since refunds are capped to a percetange of
        // the total transaction's gas, it is best to keep them low in cases
        // like this one, to increase the likelihood of the full refund coming
        // into effect.
        _notEntered = true;
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
        require(_notEntered, "ReentrancyGuard: reentrant call");

        // Any calls to nonReentrant after this point will fail
        _notEntered = false;

        _;

        // By storing the original value once again, a refund is triggered (see
        // https://eips.ethereum.org/EIPS/eip-2200)
        _notEntered = true;
    }
}

/**
 * @title ERC165
 * @dev https://github.com/ethereum/EIPs/blob/master/EIPS/eip-165.md
 */


/**
 * @dev ERC-1155 interface for accepting safe transfers.
 */


contract DRFTokenWrapper {
    using SafeMath for uint256;
    IERC20 public drf;

    constructor(address _drfAddress) public {
        drf = IERC20(_drfAddress);
    }

    uint256 private _totalSupply;
    // Objects balances [id][address] => balance
    mapping(uint256 => mapping(address => uint256)) internal _balances;
    mapping(uint256 => uint256) private _totalDeposits;

    function totalSupply() public view returns (uint256) {
        return _totalSupply;
    }

    function totalDeposits(uint256 id) public view returns (uint256) {
        return _totalDeposits[id];
    }

    function balanceOf(address account, uint256 id) public view returns (uint256) {
        return _balances[id][account];
    }

    function bid(uint256 id, uint256 amount) public {
        _totalSupply = _totalSupply.add(amount);
        _totalDeposits[id] = _totalDeposits[id].add(amount);
        _balances[id][msg.sender] = _balances[id][msg.sender].add(amount);
        drf.transferFrom(msg.sender, address(this), amount);
    }

    function withdraw(uint256 id) public {
        uint256 amount = balanceOf(msg.sender, id);
        _totalSupply = _totalSupply.sub(amount);
        _totalDeposits[id] = _totalDeposits[id].sub(amount);
        _balances[id][msg.sender] = _balances[id][msg.sender].sub(amount);
        drf.transfer(msg.sender, amount);
    }

    function _emergencyWithdraw(address account, uint256 id) internal {
        uint256 amount = _balances[id][account];

        _totalSupply = _totalSupply.sub(amount);
        _totalDeposits[id] = _totalDeposits[id].sub(amount);
        _balances[id][account] = _balances[id][account].sub(amount);
        drf.transfer(account, amount);
    }

    function _end(
        uint256 id,
        address highestBidder,
        address beneficiary,
        address runner,
        uint256 fee,
        uint256 amount
    ) internal {
        uint256 accountDeposits = _balances[id][highestBidder];
        require(accountDeposits == amount);

        _totalSupply = _totalSupply.sub(amount);
        uint256 drfFee = (amount.mul(fee)).div(100);

        _totalDeposits[id] = _totalDeposits[id].sub(amount);
        _balances[id][highestBidder] = _balances[id][highestBidder].sub(amount);
        drf.transfer(beneficiary, amount.sub(drfFee));
        drf.transfer(runner, drfFee);
    }
}



contract DRFAuctionExtending is Ownable, ReentrancyGuard, DRFTokenWrapper, IERC1155TokenReceiver {
    using SafeMath for uint256;

    address public drfLtdAddress;
    address public runner;

    // info about a particular auction
    struct AuctionInfo {
        address beneficiary;
        uint256 fee;
        uint256 auctionStart;
        uint256 auctionEnd;
        uint256 originalAuctionEnd;
        uint256 extension;
        uint256 nft;
        address highestBidder;
        uint256 highestBid;
        bool auctionEnded;
    }

    mapping(uint256 => AuctionInfo) public auctionsById;
    uint256[] public auctions;

    // Events that will be fired on changes.
    event BidPlaced(address indexed user, uint256 indexed id, uint256 amount);
    event Withdrawn(address indexed user, uint256 indexed id, uint256 amount);
    event Ended(address indexed user, uint256 indexed id, uint256 amount);

    constructor(
        address _runner,
        address _drfAddress,
        address _drfLtdAddress
    ) public DRFTokenWrapper(_drfAddress) {
        runner = _runner;
        drfLtdAddress = _drfLtdAddress;
    }

    function auctionStart(uint256 id) public view returns (uint256) {
        return auctionsById[id].auctionStart;
    }

    function beneficiary(uint256 id) public view returns (address) {
        return auctionsById[id].beneficiary;
    }

    function auctionEnd(uint256 id) public view returns (uint256) {
        return auctionsById[id].auctionEnd;
    }

    function drfLtdNft(uint256 id) public view returns (uint256) {
        return auctionsById[id].nft;
    }

    function highestBidder(uint256 id) public view returns (address) {
        return auctionsById[id].highestBidder;
    }

    function highestBid(uint256 id) public view returns (uint256) {
        return auctionsById[id].highestBid;
    }

    function ended(uint256 id) public view returns (bool) {
        return now >= auctionsById[id].auctionEnd;
    }

    function runnerFee(uint256 id) public view returns (uint256) {
        return auctionsById[id].fee;
    }

    function setRunnerAddress(address account) public onlyOwner {
        runner = account;
    }

    function create(
        uint256 id,
        address beneficiaryAddress,
        uint256 fee,
        uint256 start,
        uint256 duration,
        uint256 extension // in minutes
    ) public onlyOwner {
        AuctionInfo storage auction = auctionsById[id];
        require(auction.beneficiary == address(0), "DRFAuction::create: auction already created");

        auction.beneficiary = beneficiaryAddress;
        auction.fee = fee;
        auction.auctionStart = start;
        auction.auctionEnd = start.add(duration * 1 days);
        auction.originalAuctionEnd = start.add(duration * 1 days);
        auction.extension = extension * 60;

        auctions.push(id);

        uint256 tokenId = IERC1155(drfLtdAddress).create(1, 1, "", "");
        require(tokenId > 0, "DRFAuction::create: ERC1155 create did not succeed");
        auction.nft = tokenId;
    }

    function bid(uint256 id, uint256 amount) public nonReentrant {
        AuctionInfo storage auction = auctionsById[id];
        require(auction.beneficiary != address(0), "DRFAuction::bid: auction does not exist");
        require(now >= auction.auctionStart, "DRFAuction::bid: auction has not started");
        require(now <= auction.auctionEnd, "DRFAuction::bid: auction has ended");

        uint256 newAmount = amount.add(balanceOf(msg.sender, id));
        require(newAmount > auction.highestBid, "DRFAuction::bid: bid is less than highest bid");

        auction.highestBidder = msg.sender;
        auction.highestBid = newAmount;

        if (auction.extension > 0 && auction.auctionEnd.sub(now) <= auction.extension) {
            auction.auctionEnd = now.add(auction.extension);
        }

        super.bid(id, amount);
        emit BidPlaced(msg.sender, id, amount);
    }

    function withdraw(uint256 id) public nonReentrant {
        AuctionInfo storage auction = auctionsById[id];
        uint256 amount = balanceOf(msg.sender, id);
        require(auction.beneficiary != address(0), "DRFAuction::withdraw: auction does not exist");
        require(amount > 0, "DRFAuction::withdraw: cannot withdraw 0");

        require(
            auction.highestBidder != msg.sender,
            "DRFAuction::withdraw: you are the highest bidder and cannot withdraw"
        );

        super.withdraw(id);
        emit Withdrawn(msg.sender, id, amount);
    }

    function emergencyWithdraw(uint256 id) public onlyOwner {
        AuctionInfo storage auction = auctionsById[id];
        require(auction.beneficiary != address(0), "DRFAuction::create: auction does not exist");
        require(now >= auction.auctionEnd, "DRFAuction::emergencyWithdraw: the auction has not ended");
        require(!auction.auctionEnded, "DRFAuction::emergencyWithdraw: auction ended and item sent");

        _emergencyWithdraw(auction.highestBidder, id);
        emit Withdrawn(auction.highestBidder, id, auction.highestBid);
    }

    function end(uint256 id) public nonReentrant {
        AuctionInfo storage auction = auctionsById[id];
        require(auction.beneficiary != address(0), "DRFAuction::end: auction does not exist");
        require(now >= auction.auctionEnd, "DRFAuction::end: the auction has not ended");
        require(!auction.auctionEnded, "DRFAuction::end: auction already ended");

        auction.auctionEnded = true;
        _end(id, auction.highestBidder, auction.beneficiary, runner, auction.fee, auction.highestBid);
        IERC1155(drfLtdAddress).safeTransferFrom(address(this), auction.highestBidder, auction.nft, 1, "");
        emit Ended(auction.highestBidder, id, auction.highestBid);
    }

    function onERC1155Received(
        address _operator,
        address, // _from
        uint256, // _id
        uint256, // _amount
        bytes memory // _data
    ) public returns (bytes4) {
        require(msg.sender == address(drfLtdAddress), "DRFAuction::onERC1155BatchReceived:: invalid token address");
        require(_operator == address(this), "DRFAuction::onERC1155BatchReceived:: operator must be auction contract");

        // Return success
        return this.onERC1155Received.selector;
    }

    function onERC1155BatchReceived(
        address _operator,
        address, // _from,
        uint256[] memory, // _ids,
        uint256[] memory, // _amounts,
        bytes memory // _data
    ) public returns (bytes4) {
        require(msg.sender == address(drfLtdAddress), "DRFAuction::onERC1155BatchReceived:: invalid token address");
        require(_operator == address(this), "DRFAuction::onERC1155BatchReceived:: operator must be auction contract");

        // Return success
        return this.onERC1155BatchReceived.selector;
    }

    function supportsInterface(bytes4 interfaceID) external view returns (bool) {
        return
        interfaceID == 0x01ffc9a7 || // ERC-165 support
        interfaceID == 0x4e2312e0; // ERC-1155 `ERC1155TokenReceiver` support
    }
}