/**
 *Submitted for verification at Etherscan.io on 2021-06-03
*/

// SPDX-License-Identifier: GPL-3.0

pragma solidity 0.6.12;



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

// Part: IERC20

/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
 */


// Part: ReentrancyGuard

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


// Part: IO3

interface IO3 is IERC20 {
    function getUnlockFactor(address token) external view returns (uint256);
    function getUnlockBlockGap(address token) external view returns (uint256);

    function totalUnlocked() external view returns (uint256);
    function unlockedOf(address account) external view returns (uint256);
    function lockedOf(address account) external view returns (uint256);

    function getStaked(address token) external view returns (uint256);
    function getUnlockSpeed(address staker, address token) external view returns (uint256);
    function claimableUnlocked(address token) external view returns (uint256);

    function setUnlockFactor(address token, uint256 _factor) external;
    function setUnlockBlockGap(address token, uint256 _blockGap) external;

    function stake(address token, uint256 amount) external returns (bool);
    function unstake(address token, uint256 amount) external returns (bool);
    function claimUnlocked(address token) external returns (bool);

    function setAuthorizedMintCaller(address caller) external;
    function removeAuthorizedMintCaller(address caller) external;

    function mintUnlockedToken(address to, uint256 amount) external;
    function mintLockedToken(address to, uint256 amount) external;
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

// Part: SafeERC20

/**
 * @title SafeERC20
 * @dev Wrappers around ERC20 operations that throw on failure (when the token
 * contract returns false). Tokens that return no value (and instead revert or
 * throw on failure) are also supported, non-reverting calls are assumed to be
 * successful.
 * To use this library you can add a `using SafeERC20 for IERC20;` statement to your contract,
 * which allows you to call the safe operations as `token.safeTransfer(...)`, etc.
 */


// File: O3Staking.sol

contract O3Staking is Context, Ownable, ReentrancyGuard {
    using SafeMath for uint;
    using SafeMath for uint256;
    using SafeERC20 for IERC20;

    struct StakingRecord {
        address staker;
        uint blockIndex;
        uint staked;
        uint totalProfit;
    }

    event LOG_STAKE (
        address indexed staker,
        uint stakeAmount
    );

    event LOG_UNSTAKE (
        address indexed staker,
        uint withdrawAmount
    );

    event LOG_CLAIM_PROFIT (
        address indexed staker,
        uint profit
    );

    event LOG_CALL (
        bytes4 indexed sig,
        address indexed caller,
        bytes data
    ) anonymous;

    modifier _logs_() {
        emit LOG_CALL(msg.sig, _msgSender(), _msgData());
        _;
    }

    address public StakingToken;
    address public O3Token;
    uint public startStakingBlockIndex;
    uint public startUnstakeBlockIndex;
    uint public startClaimBlockIndex;
    uint public totalStaked;

    mapping(address => StakingRecord) private _stakingRecords;
    mapping(uint => uint) private _unitProfitAccumu;

    uint private _unitProfit; // Latest unit profit.
    uint private _upBlockIndex; // The block index `_unitProfit` refreshed.

    uint private _sharePerBlock;
    bool private _stakingPaused;
    bool private _withdarawPaused;
    bool private _claimProfitPaused;

    uint public constant ONE = 10**18;

    constructor(
        address _stakingToken,
        address _o3Token,
        uint _startStakingBlockIndex,
        uint _startUnstakeBlockIndex,
        uint _startClaimBlockIndex
    ) public {
        require(_stakingToken != address(0), "O3Staking: ZERO_STAKING_ADDRESS");
        require(_o3Token != address(0), "O3Staking: ZERO_O3TOKEN_ADDRESS");
        require(_startClaimBlockIndex >= _startStakingBlockIndex, "O3Staking: INVALID_START_CLAIM_BLOCK_INDEX");

        StakingToken = _stakingToken;
        O3Token = _o3Token;
        startStakingBlockIndex = _startStakingBlockIndex;
        startUnstakeBlockIndex = _startUnstakeBlockIndex;
        startClaimBlockIndex = _startClaimBlockIndex;
    }

    function getTotalProfit(address staker) external view returns (uint) {
        if (block.number <= startStakingBlockIndex) {
            return 0;
        }

        uint currentProfitAccumu = _unitProfitAccumu[block.number];
        if (_upBlockIndex < block.number) {
            uint unitProfitIncrease = _unitProfit.mul(block.number.sub(_upBlockIndex));
            currentProfitAccumu = _unitProfitAccumu[_upBlockIndex].add(unitProfitIncrease);
        }

        StakingRecord storage rec = _stakingRecords[staker];

        uint preUnitProfit = _unitProfitAccumu[rec.blockIndex];
        uint currentProfit = (currentProfitAccumu.sub(preUnitProfit)).mul(rec.staked).div(ONE);

        return rec.totalProfit.add(currentProfit);
    }

    function getStakingAmount(address staker) external view returns (uint) {
        StakingRecord storage rec = _stakingRecords[staker];
        return rec.staked;
    }

    function getSharePerBlock() external view returns (uint) {
        return _sharePerBlock;
    }

    function setStakingToke(address _token) external onlyOwner _logs_ {
        StakingToken = _token;
    }

    function setSharePerBlock(uint sharePerBlock) external onlyOwner _logs_ {
        _sharePerBlock = sharePerBlock;
        _updateUnitProfitState();
    }

    function setStartUnstakeBlockIndex(uint _startUnstakeBlockIndex) external onlyOwner _logs_ {
        startUnstakeBlockIndex = _startUnstakeBlockIndex;
    }

    function setStartClaimBlockIndex(uint _startClaimBlockIndex) external onlyOwner _logs_ {
        startClaimBlockIndex = _startClaimBlockIndex;
    }

    function stake(uint amount) external nonReentrant _logs_ {
        require(!_stakingPaused, "O3Staking: STAKING_PAUSED");
        require(amount > 0, "O3Staking: INVALID_STAKING_AMOUNT");

        totalStaked = amount.add(totalStaked);
        _updateUnitProfitState();

        StakingRecord storage rec = _stakingRecords[_msgSender()];

        uint userTotalProfit = _settleCurrentUserProfit(_msgSender());
        _updateUserStakingRecord(_msgSender(), rec.staked.add(amount), userTotalProfit);

        emit LOG_STAKE(_msgSender(), amount);

        _pullToken(StakingToken, _msgSender(), amount);
    }

    function unstake(uint amount) external nonReentrant _logs_ {
        require(!_withdarawPaused, "O3Staking: UNSTAKE_PAUSED");
        require(block.number >= startUnstakeBlockIndex, "O3Staking: UNSTAKE_NOT_STARTED");

        StakingRecord storage rec = _stakingRecords[_msgSender()];

        require(amount > 0, "O3Staking: ZERO_UNSTAKE_AMOUNT");
        require(amount <= rec.staked, "O3Staking: UNSTAKE_AMOUNT_EXCEEDED");

        totalStaked = totalStaked.sub(amount);
        _updateUnitProfitState();

        uint userTotalProfit = _settleCurrentUserProfit(_msgSender());
        _updateUserStakingRecord(_msgSender(), rec.staked.sub(amount), userTotalProfit);

        emit LOG_UNSTAKE(_msgSender(), amount);

        _pushToken(StakingToken, _msgSender(), amount);
    }

    function claimProfit() external nonReentrant _logs_ {
        require(!_claimProfitPaused, "O3Staking: CLAIM_PROFIT_PAUSED");
        require(block.number >= startClaimBlockIndex, "O3Staking: CLAIM_NOT_STARTED");

        uint totalProfit = _getTotalProfit(_msgSender());
        require(totalProfit > 0, "O3Staking: ZERO_PROFIT");

        StakingRecord storage rec = _stakingRecords[_msgSender()];
        _updateUserStakingRecord(_msgSender(), rec.staked, 0);

        emit LOG_CLAIM_PROFIT(_msgSender(), totalProfit);

        _pushShareToken(_msgSender(), totalProfit);
    }

    function _getTotalProfit(address staker) internal returns (uint) {
        _updateUnitProfitState();

        uint totalProfit = _settleCurrentUserProfit(staker);
        return totalProfit;
    }

    function _updateUserStakingRecord(address staker, uint staked, uint totalProfit) internal {
        _stakingRecords[staker].staked = staked;
        _stakingRecords[staker].totalProfit = totalProfit;
        _stakingRecords[staker].blockIndex = block.number;

        // Any action before `startStakingBlockIndex` is treated as acted in block `startStakingBlockIndex`.
        if (block.number < startStakingBlockIndex) {
            _stakingRecords[staker].blockIndex = startStakingBlockIndex;
        }
    }

    function _settleCurrentUserProfit(address staker) internal view returns (uint) {
        if (block.number <= startStakingBlockIndex) {
            return 0;
        }

        StakingRecord storage rec = _stakingRecords[staker];

        uint preUnitProfit = _unitProfitAccumu[rec.blockIndex];
        uint currUnitProfit = _unitProfitAccumu[block.number];
        uint currentProfit = (currUnitProfit.sub(preUnitProfit)).mul(rec.staked).div(ONE);

        return rec.totalProfit.add(currentProfit);
    }

    function _updateUnitProfitState() internal {
        uint currentBlockIndex = block.number;
        if (_upBlockIndex >= currentBlockIndex) {
            _updateUnitProfit();
            return;
        }

        // Accumulate unit profit.
        uint unitStakeProfitIncrease = _unitProfit.mul(currentBlockIndex.sub(_upBlockIndex));
        _unitProfitAccumu[currentBlockIndex] = unitStakeProfitIncrease.add(_unitProfitAccumu[_upBlockIndex]);

        _upBlockIndex = block.number;

        if (currentBlockIndex <= startStakingBlockIndex) {
            _unitProfitAccumu[startStakingBlockIndex] = _unitProfitAccumu[currentBlockIndex];
            _upBlockIndex = startStakingBlockIndex;
        }

        _updateUnitProfit();
    }

    function _updateUnitProfit() internal {
        if (totalStaked > 0) {
            _unitProfit = _sharePerBlock.mul(ONE).div(totalStaked);
        }
    }

    function pauseStaking() external onlyOwner _logs_ {
        _stakingPaused = true;
    }

    function unpauseStaking() external onlyOwner _logs_ {
        _stakingPaused = false;
    }

    function pauseUnstake() external onlyOwner _logs_ {
        _withdarawPaused = true;
    }

    function unpauseUnstake() external onlyOwner _logs_ {
        _withdarawPaused = false;
    }

    function pauseClaimProfit() external onlyOwner _logs_ {
        _claimProfitPaused = true;
    }

    function unpauseClaimProfit() external onlyOwner _logs_ {
        _claimProfitPaused = false;
    }

    function collect(address token, address to) external nonReentrant onlyOwner _logs_ {
        require(token != StakingToken, "O3Staking: COLLECT_NOT_ALLOWED");
        uint balance = IERC20(token).balanceOf(address(this));
        _pushToken(token, to, balance);
    }

    function _pushToken(address token, address to, uint amount) internal {
        SafeERC20.safeTransfer(IERC20(token), to, amount);
    }

    function _pushShareToken(address to, uint amount) internal {
        IO3(O3Token).mintLockedToken(to, amount);
    }

    function _pullToken(address token, address from, uint amount) internal {
        SafeERC20.safeTransferFrom(IERC20(token), from, address(this), amount);
    }
}