/**
 *Submitted for verification at Etherscan.io on 2020-11-11
*/

// SPDX-License-Identifier: MIT

pragma solidity ^0.6.2;


// 
/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
 */


// 
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


// 
/**
 * @dev Collection of functions related to the address type
 */


// 
/**
 * @title SafeERC20
 * @dev Wrappers around ERC20 operations that throw on failure (when the token
 * contract returns false). Tokens that return no value (and instead revert or
 * throw on failure) are also supported, non-reverting calls are assumed to be
 * successful.
 * To use this library you can add a `using SafeERC20 for IERC20;` statement to your contract,
 * which allows you to call the safe operations as `token.safeTransfer(...)`, etc.
 */


// 
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


// 
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

// 
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

// 
/**
 * @dev Interface of the ERC165 standard, as defined in the
 * https://eips.ethereum.org/EIPS/eip-165[EIP].
 *
 * Implementers can declare support of contract interfaces, which can then be
 * queried by others ({ERC165Checker}).
 *
 * For an implementation, see {ERC165}.
 */


// 
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

// 
contract BooLottery is Ownable {
    using NameFilter for string;
    using SafeMath for uint256;
    using SafeERC20 for IERC20;

    // How long the lottery should run for
    uint256 public runTime = 2 days;

    // Price per ticket/entry - Initial price is 1 BOOB but can be adjusted
    uint256 public ticketPrice = 1000000000000000000;

    // BooBanker ERC20 Token address
    IERC20 public boob;
    IERC721 public nft;

    struct Lottery {
        uint256 ticketPrice;
        uint256 potValue; // Total value of pot
        uint256 startTs; // Lottery start timestamp
        uint256 endTs; // Lottery end timestamp (should be at startTs + runTime or as close after as possible)
        uint256 startBlock; // Lottery start block
        uint256 endBlock; // Lottery end block
        address winner; // Address of winner
        uint256 luckyNumber; // rnd number
        uint256 fee; // How much was earmarked for devs
        bool running; // Is still running - just to keep track of whether it's been processed
        uint256 totalTickets; // Tickets sold
    }

    struct Ticket {
        uint256 price; // Price of ticket
        address ticketHolder; // Address of ticket holder
        uint256 ts; // timestamp
    }

    // User details
    struct UserInfo {
        address wallet;
        bytes32 name; // Yep you can name your wallet
        uint256 wins;
        uint256 entries;
    }

    // All lottery games
    Lottery[] public lotteryInfo;

    // Mapping of tickets/entries for user
    mapping (uint256 => mapping (address => uint256)) public userPlayRecord;
    mapping (uint256 => mapping (address => bool)) public freeEntry;
    mapping (uint256 => address[]) public lotteryTickets;
    mapping (address => UserInfo) public userInfo;

    // Dev fee - percentage, set to 1%
    uint256 public feeDivisor;

    // Fee address
    address public feeAddress;

    event TicketPurchase(address indexed user, uint256 indexed lottery, uint256 tickets, uint256 amount);
    event FreeTicket(address indexed user, uint256 indexed lottery, address nft, uint256 id);
    event LotteryStart(uint256 indexed lottery, uint256 startTimestamp);
    event LotteryEnd(uint256 prize, address indexed winner, uint256 totalTickets);
    event NameChange(address indexed user, bytes32 name);

    constructor(IERC20 _boob, IERC721 _nft) public
    {
        boob = _boob;
        nft = _nft;
        feeAddress = msg.sender;
        feeDivisor = 100;
        startLottery();
    }

    function lotteryInfoLength() external view returns (uint256) {
        return lotteryInfo.length;
    }

    function currentLotteryPotValue() external view returns (uint256) {
        if (lotteryInfo.length == 0) {
            return 0;
        }

        return lotteryInfo[lotteryInfo.length - 1].potValue;
    }

    function getUserPlayRecord(address _user, uint256 _lottery) external view returns (uint256 _tickets) {
        return userPlayRecord[_lottery][_user];
    }

    function getLotteryEntries(uint256 _lottery) external view returns (address[] memory _tickets) {
        return lotteryTickets[_lottery];
    }

    function totalLotteryEntries(uint256 _lottery) external view returns (uint256) {
        return lotteryInfo[_lottery].totalTickets;
    }

    function currentLotteryEntryCount() external view returns (uint256) {
        return lotteryInfo[lotteryInfo.length - 1].totalTickets;
    }

    function setBoobAddress(IERC20 _boob) public onlyOwner {
        require(address(_boob) != address(0), 'Cannot be 0x0');
        boob = _boob;
    }

    function setBoobNftAddress(IERC721 _nft) public onlyOwner {
        require(address(_nft) != address(0), 'Cannot be 0x0');
        nft = _nft;
    }

    function rand(uint256 _to) internal returns(uint256) {
        uint256 seed = uint256(keccak256(abi.encodePacked(
                (block.timestamp).add
                (block.difficulty).add
                ((uint256(keccak256(abi.encodePacked(block.coinbase)))).div(now)).add
                (block.gaslimit).add
                ((uint256(keccak256(abi.encodePacked(msg.sender)))).div(now)).add
                (block.number)
            )));

        return (seed - ((seed.div(_to)).mul(_to)));
    }

    // Sets dev fee divisor - 255 = 0.4%, 100 = 1%, 50 = 2%, 40 = 2.5% etc
    function setFee(uint256 _fee) public onlyOwner {
        feeDivisor = _fee;
    }

    // Sets dev address
    function setFeeAddress(IERC20 _feeAddress) public onlyOwner {
        feeAddress = address(_feeAddress);
    }

    // Set how long a lottery should run for - does not apply any active lotteries, only to the next one
    function setRunTime(uint _runTime) public onlyOwner {
        require(_runTime > 1 days, 'runTime must be greater than 1 day');
        runTime = _runTime;
    }

    // Sets price for each ticket
    function setTicketPrice(uint256 _ticketPrice) public onlyOwner {
        require(_ticketPrice > 0, 'price must be greater than zero');
        ticketPrice = _ticketPrice;
    }

    // Processes lottery
    function checkLotteryStatus() public {
        if (lotteryInfo.length > 0) {
            Lottery storage _lottery = lotteryInfo[lotteryInfo.length - 1];
            if (_lottery.endTs <= block.timestamp && _lottery.running) {
                concludeLottery(_lottery);
            }
        } else {
            startLottery();
        }
    }

    // In case the contract somehow fails to start new lottery after the previous one ends
    function xEmergencyStartLottery() public onlyOwner {
        startLottery();
    }

    // In case the contract somehow fails to start new lottery after the previous one ends
    function xEmergencyStopLottery() public onlyOwner {
        // to be removed before mainnet deployment - if I dont forget about it... Either way, it doesn't harm anyone.
        Lottery storage lottery = lotteryInfo[lotteryInfo.length - 1];
        lottery.endTs = 1;
        concludeLottery(lottery);
    }

    function startLottery() internal {
        lotteryInfo.push(Lottery({
            ticketPrice: ticketPrice,
            potValue: 0,
            startTs: now,
            endTs: now.add(runTime),
            startBlock: block.number,
            endBlock: 0,
            winner: address(0),
            luckyNumber: 0,
            fee: 0,
            running: true,
            totalTickets: 0
        }));

        emit LotteryStart(lotteryInfo.length - 1, block.timestamp);
    }

    function concludeLottery(Lottery storage lottery) internal {
        lottery.running = false;
        lottery.endTs = block.timestamp;
        lottery.endBlock = block.number;

        if (feeDivisor > 0 && lottery.potValue > 0) {
            lottery.fee = lottery.potValue.div(feeDivisor);
            lottery.potValue = lottery.potValue.sub(lottery.fee);
        }

        if (lotteryTickets[lotteryInfo.length - 1].length > 0) {
            uint256 rnd = rand(lotteryTickets[lotteryInfo.length - 1].length);
            address winningTicket = lotteryTickets[lotteryInfo.length - 1][rnd];
            lottery.winner = winningTicket;
            lottery.luckyNumber = rnd;

            UserInfo storage user = userInfo[lottery.winner];
            user.wins = user.wins + 1;

            if (lottery.fee > 0) {
                safeBoobTransfer(feeAddress, lottery.fee);
            }

            // Burn varies so we send whatever is in the pot
            safeBoobTransfer(lottery.winner, lottery.potValue);

            emit LotteryEnd(lottery.potValue, lottery.winner, lottery.totalTickets);
        }
        // Starts next pot
        startLottery();
    }

    function safeBoobTransfer(address _to, uint256 _amount) internal {
        uint256 boobBal = boob.balanceOf(address(this));
        if (_amount > boobBal) {
            boob.transfer(_to, boobBal);
        } else {
            boob.transfer(_to, _amount);
        }
    }


    function buyTicket(uint256 _ticketCount) public {
        require(_ticketCount > 0, 'You must buy at least one ticket');
        uint256 amount = _ticketCount.mul(ticketPrice);
        require(boob.balanceOf(msg.sender) > amount, 'Insufficient funds for amount of tickets requested');

        if (lotteryInfo.length > 0) {
            boob.safeTransferFrom(msg.sender, address(this), amount);
            uint256 _lot = lotteryInfo.length - 1;
            Lottery storage lottery = lotteryInfo[_lot];
            lottery.potValue = lottery.potValue.add(amount);

            if (
                address(nft) != address(0) &&
                nft.balanceOf(address(msg.sender)) > 0 &&
                !freeEntry[_lot][msg.sender]
            ) {
                freeEntry[_lot][msg.sender] = true;
                _ticketCount++;
            }

            lottery.totalTickets = lottery.totalTickets.add(_ticketCount);

            for (uint256 _t = 0; _t < _ticketCount; _t++) {
                lotteryTickets[_lot].push(msg.sender);
            }

            emit TicketPurchase(msg.sender, _lot, _ticketCount, amount);
        }
    }

    function getUserTicketCountForLottery(uint256 _lot, address _user) external view returns (uint256) {
        uint256 _count = 0;

        for (uint256 i = 0; i < lotteryTickets[_lot].length; i++) {
            if (lotteryTickets[_lot][i] == _user) {
                _count++;
            }
        }

        return _count;
    }

    // Name your wallet
    function registerName(string memory _nameString) public {
        bytes32 _name = _nameString.nameFilter();
        address _addr = msg.sender;
        UserInfo storage user = userInfo[_addr];
        user.wallet = _addr;
        user.name = _name;

        emit NameChange(_addr, _name);
    }
}

