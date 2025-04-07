/**
 *Submitted for verification at Etherscan.io on 2021-04-21
*/

// SPDX-License-Identifier: MIT
pragma solidity 0.7.4;

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
 * @dev Standard math utilities missing in the Solidity language.
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
abstract contract Context {
    function _msgSender() internal view virtual returns (address payable) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes memory) {
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
    constructor() internal {
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
 * @dev Interface of the ERC20 standard as defined in the EIP.
 */


/**
 * @dev Collection of functions related to the address type
 */


/**
 * @title SafeERC20
 * @dev Wrappers around ERC20 operations that throw on failure (when the token
 * contract returns false). Tokens that return no value (and instead revert or
 * throw on failure) are also supported, non-reverting calls are assumed to be
 * successful.
 * To use this library you can add a `using SafeERC20 for IERC20;` statement to your contract,
 * which allows you to call the safe operations as `token.safeTransfer(...)`, etc.
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

    constructor() internal {
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



contract MCBCrowdsale is Ownable, ReentrancyGuard {
    using Math for uint256;
    using SafeMath for uint256;
    using SafeMathExt for uint256;
    using SafeERC20 for IERC20;

    address public constant MCB_TOKEN_ADDRESS = 0x4e352cF164E64ADCBad318C3a1e222E9EBa4Ce42;
    address public constant USDC_TOKEN_ADDRESS = 0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48;
    address public constant MCDEX_FOUNDATION_ADDRESS = 0x38ca50c6E3391A5bf73c2504bd9Cd9c0b9D89053;

    uint256 public constant MAX_SUPPLY = 100000 * 1e18;
    uint256 public constant USDC_DEPOSIT_RATE = 10 * 1e6;
    uint256 public constant MCB_DEPOSIT_RATE = 4 * 1e18;

    bool public isEmergency;
    uint256 public beginTime;
    uint256 public endTime;
    uint256 public unlockTime;

    uint256 internal _totalCommitment;
    mapping(address => uint256) internal _commitments;
    mapping(address => bool) internal _settlementFlags;

    event Purchase(uint256 amount, uint256 depositedMCB, uint256 depositUSDC);
    event Settle(address indexed account, uint256 settledAmount, uint256 refundUSDC);
    event ForwardFunds(uint256 claimableUSDCAmount);
    event SetEmergency();
    event EmergencySettle(address indexed account, uint256 mcbAmount, uint256 usdcAmount);
    event EmergencyForwardFunds(uint256 mcbAmount, uint256 usdcAmount);

    constructor(
        uint256 beginTime_,
        uint256 endTime_,
        uint256 lockPeriod_
    ) Ownable() ReentrancyGuard() {
        require(beginTime_ <= endTime_, "start time cannot be later than end time");
        require(lockPeriod_ <= 86400 * 7, "lock period too long");

        beginTime = beginTime_;
        endTime = endTime_;
        unlockTime = endTime_.add(lockPeriod_);
    }

    /**
     * @notice  Turn contract to emergency state. Make emergencySettle available.
     *          Only can be called before unlock.
     */
    function setEmergency() external onlyOwner {
        require(_blockTimestamp() < unlockTime, "can only set emergency before unlock time");
        require(!isEmergency, "already in emergency state");
        isEmergency = true;
        emit SetEmergency();
    }

    /**
     * @notice  A boolean to indicate if currently commit interface is available.
     */
    function isCommitable() public view returns (bool) {
        uint256 currentTimestamp = _blockTimestamp();
        return currentTimestamp >= beginTime && currentTimestamp < endTime;
    }

    /**
     * @notice  A boolean to indicate if currently settle interface is available.
     */
    function isSettleable() public view returns (bool) {
        uint256 currentTimestamp = _blockTimestamp();
        return currentTimestamp >= unlockTime;
    }

    /**
     * @notice  A boolean to indicate if the given account is already settled.
     */
    function isAccountSettled(address account) public view returns (bool) {
        return _settlementFlags[account];
    }

    /**
     * @notice  Total raw amount of users commited. This amount may exceed MAX_SUPPLY.
     */
    function totalCommitment() external view returns (uint256) {
        return _totalCommitment;
    }

    /**
     * @notice  Total amount of MCB commited by user. It should not exceed MAX_SUPPLY.
     */
    function totalCommitedSupply() public view returns (uint256) {
        return _totalCommitment.min(MAX_SUPPLY);
    }

    /**
     * @notice  The percentage of token sold and total supply.
     */
    function commitmentRate() public view returns (uint256) {
        return _totalCommitment <= MAX_SUPPLY ? 1e18 : _totalCommitment.wdivFloor(MAX_SUPPLY);
    }

    /**
     * @notice  The raw amount of an account commited.
     */
    function commitmentOf(address account) external view returns (uint256) {
        return _commitments[account];
    }

    /**
     * @notice  The share of amount in total commited amount for an account.
     */
    function shareOf(address account) external view returns (uint256) {
        return _commitments[account].wdivFloor(commitmentRate());
    }

    /**
     * @notice  User is able to commit 1 MCB token with 4x MCB and 10x USDC.
     *          All MCB deposited and refund USDC (if any) will be sent back to user
     *          after an unlock period.
     */
    function commit(uint256 amount) external {
        require(!isEmergency, "commit is not available in emergency state");
        require(isCommitable(), "commit is not active now");
        require(amount > 0, "amount to buy cannot be zero");

        uint256 depositMCB = amount.wmul(MCB_DEPOSIT_RATE);
        uint256 depositUSDC = amount.wmul(USDC_DEPOSIT_RATE);
        // transfer
        _mcbToken().safeTransferFrom(msg.sender, address(this), depositMCB);
        _usdcToken().safeTransferFrom(msg.sender, address(this), depositUSDC);

        _commitments[msg.sender] = _commitments[msg.sender].add(amount);
        _totalCommitment = _totalCommitment.add(amount);

        emit Purchase(amount, depositMCB, depositUSDC);
    }

    /**
     * @notice  User is able to get usdc refund if the total subscriptions exceeds target supply.
     *
     * @param   account The address to settle, to which the refund and deposited MCB will be transferred.
     */
    function settle(address account) external nonReentrant {
        require(!isEmergency, "settle is not available in emergency state");
        require(isSettleable(), "settle is not active now");
        require(!isAccountSettled(account), "account has alreay settled");

        uint256 settledAmount = _commitments[account].wdivFloor(commitmentRate());
        uint256 depositMCB = _commitments[account].wmul(MCB_DEPOSIT_RATE);
        uint256 depositUSDC = _commitments[account].wmul(USDC_DEPOSIT_RATE);
        uint256 costUSDC = depositUSDC.wdivCeil(commitmentRate());
        uint256 refundUSDC = 0;
        // usdc refund
        _settlementFlags[account] = true;
        if (depositUSDC > costUSDC) {
            refundUSDC = depositUSDC.sub(costUSDC);
            _usdcToken().safeTransfer(account, refundUSDC);
        }
        _mcbToken().safeTransfer(account, depositMCB);

        emit Settle(account, settledAmount, refundUSDC);
    }

    /**
     * @notice  Forword funds up to sale target to a preset address.
     */
    function forwardFunds() external nonReentrant onlyOwner {
        require(!isEmergency, "forward is not available in emergency state");
        require(isSettleable(), "forward is not active now");
        require(!isAccountSettled(address(this)), "funds has alreay been forwarded");

        _settlementFlags[address(this)] = true;
        uint256 fundUSDC = totalCommitedSupply().wmul(USDC_DEPOSIT_RATE);
        _usdcToken().safeTransfer(_mcdexFoundation(), fundUSDC);

        emit ForwardFunds(fundUSDC);
    }

    /**
     * @notice  In emergency state, user is able to withdraw all deposited assets back directly.
     *
     * @param   account The address to settle, to which the deposited assets will be transferred.
     */
    function emergencySettle(address account) external nonReentrant {
        require(isEmergency, "emergency settle is only available in emergency state");
        require(!isAccountSettled(account), "account has alreay settled");

        uint256 depositedMCB = _commitments[account].wmul(MCB_DEPOSIT_RATE);
        uint256 depositedUSDC = _commitments[account].wmul(USDC_DEPOSIT_RATE);

        _totalCommitment = _totalCommitment.sub(_commitments[account]);
        _commitments[account] = 0;
        _settlementFlags[account] = true;

        _mcbToken().safeTransfer(account, depositedMCB);
        _usdcToken().safeTransfer(account, depositedUSDC);

        emit EmergencySettle(account, depositedMCB, depositedUSDC);
    }

    function _mcbToken() internal view virtual returns (IERC20) {
        return IERC20(MCB_TOKEN_ADDRESS);
    }

    function _usdcToken() internal view virtual returns (IERC20) {
        return IERC20(USDC_TOKEN_ADDRESS);
    }

    function _mcdexFoundation() internal view virtual returns (address) {
        return MCDEX_FOUNDATION_ADDRESS;
    }

    function _blockTimestamp() internal view virtual returns (uint256) {
        return block.timestamp;
    }
}