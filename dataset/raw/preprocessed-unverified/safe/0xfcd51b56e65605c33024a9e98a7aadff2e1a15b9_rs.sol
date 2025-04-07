/**
 *Submitted for verification at Etherscan.io on 2021-08-23
*/

pragma solidity 0.8.0;

// SPDX-License-Identifier: MIT



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
 * As of v3.3.0, sets of type `bytes32` (`Bytes32Set`), `address` (`AddressSet`)
 * and `uint256` (`UintSet`) are supported.
 */





// CAUTION
// This version of SafeMath should only be used with Solidity 0.8 or later,
// because it relies on the compiler's built in overflow checks.

/**
 * @dev Wrappers over Solidity's arithmetic operations.
 *
 * NOTE: `SafeMath` is no longer needed starting with Solidity 0.8. The compiler
 * now has built in overflow checking.
 */





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















contract ChefLinkMaki is Ownable, ReentrancyGuard {
    using SafeMath for uint256;
    using SafeERC20 for IERC20;

    // The Skybridge contract.
    ISwapContractMin public immutable swapContract;
    // The reward token.
    IERC20 public immutable rewardToken;
    // The staked token.
    IERC20 public immutable stakedToken;
    // The BTCT address.
    address public immutable BTCT_ADDR;
    // Accrued token per share.
    uint256 public accTokenPerShare;
    // The block number when token distribute ends.
    uint256 public bonusEndBlock;
    // The block number when token distribute starts.
    uint256 public startBlock;
    // The block number of the last pool update.
    uint256 public lastRewardBlock;
    // Tokens per block.
    uint256 public rewardPerBlock;
    // default param that for rewardPerBlock.
    uint256 public defaultRewardPerBlock;
    // the maximum size of rewardPerBlock.
    uint256 public maxRewardPerBlock;
    // A falg for dynamic changing ths rewardPerBlock.
    bool public isDynamic = true;
    // The flag for active BTC pool.
    bool public isDynamicBTC;
    // The flag for active BTCT pool.
    bool public isDynamicBTCT;
    // latest tilt size which is updated when updated pool.
    uint256 public latestTilt;
    // Info of each user that stakes tokens (stakedToken).
    mapping(address => UserInfo) public userInfo;

    struct UserInfo {
        uint256 amount; // How many staked tokens the user has provided
        uint256 rewardDebt; // Reward debt
    }

    event AdminTokenRecovery(address tokenRecovered, uint256 amount);
    event Deposit(address indexed user, uint256 amount);
    event EmergencyWithdraw(address indexed user, uint256 amount);
    event NewStartAndEndBlocks(uint256 startBlock, uint256 endBlock);
    event NewRewardPerBlock(uint256 rewardPerBlock);
    event NewPoolLimit(uint256 poolLimitPerUser);
    event RewardsStop(uint256 blockNumber);
    event Withdraw(address indexed user, uint256 amount);

    constructor(
        IERC20 _stakedToken,
        IERC20 _rewardToken,
        ISwapContractMin _swapContract,
        address _btct,
        uint256 _rewardPerBlock,
        uint256 _maxRewardPerBlock,
        uint256 _startBlock,
        uint256 _bonusEndBlock
    ) public {
        stakedToken = _stakedToken;
        rewardToken = _rewardToken;
        rewardPerBlock = _rewardPerBlock;
        defaultRewardPerBlock = rewardPerBlock;
        require(_maxRewardPerBlock >= _rewardPerBlock);
        maxRewardPerBlock = _maxRewardPerBlock;
        startBlock = _startBlock;
        bonusEndBlock = _bonusEndBlock;
        // Set the lastRewardBlock as the startBlock
        lastRewardBlock = startBlock;
        // Sst Skybridge contract
        swapContract = _swapContract;
        // Set BTCT
        BTCT_ADDR = _btct;
    }

    /**
     * @notice Deposit staked tokens and collect reward tokens (if any)
     * @param _amount: amount to withdraw (in rewardToken)
     */
    function deposit(uint256 _amount) external nonReentrant {
        UserInfo storage user = userInfo[msg.sender];
        _updatePool();

        if (user.amount > 0) {
            uint256 pending = user.amount.mul(accTokenPerShare).div(1e12).sub(
                user.rewardDebt
            );
            if (pending > 0) {
                rewardToken.safeTransfer(address(msg.sender), pending);
            }
        }

        if (_amount > 0) {
            user.amount = user.amount.add(_amount);
            stakedToken.safeTransferFrom(
                address(msg.sender),
                address(this),
                _amount
            );
        }

        user.rewardDebt = user.amount.mul(accTokenPerShare).div(1e12);

        emit Deposit(msg.sender, _amount);
    }

    /**
     * @notice Withdraw staked tokens and collect reward tokens
     * @param _amount: amount to withdraw (in rewardToken)
     */
    function withdraw(uint256 _amount) external nonReentrant {
        UserInfo storage user = userInfo[msg.sender];
        require(user.amount >= _amount, "Amount to withdraw too high");

        _updatePool();

        uint256 pending = user.amount.mul(accTokenPerShare).div(1e12).sub(
            user.rewardDebt
        );

        if (_amount > 0) {
            user.amount = user.amount.sub(_amount);
            stakedToken.safeTransfer(address(msg.sender), _amount);
        }

        if (pending > 0) {
            rewardToken.safeTransfer(address(msg.sender), pending);
        }

        user.rewardDebt = user.amount.mul(accTokenPerShare).div(1e12);

        emit Withdraw(msg.sender, _amount);
    }

    /**
     * @notice Withdraw staked tokens without caring about rewards rewards
     * @dev Needs to be for emergency.
     */
    function emergencyWithdraw() external nonReentrant {
        UserInfo storage user = userInfo[msg.sender];
        uint256 amountToTransfer = user.amount;
        user.amount = 0;
        user.rewardDebt = 0;

        if (amountToTransfer > 0) {
            stakedToken.safeTransfer(address(msg.sender), amountToTransfer);
        }

        emit EmergencyWithdraw(msg.sender, user.amount);
    }

    /**
     * @notice Stop rewards
     * @dev Only callable by owner. Needs to be for emergency.
     */
    function emergencyRewardWithdraw(uint256 _amount) external onlyOwner {
        rewardToken.safeTransfer(address(msg.sender), _amount);
    }

    /**
     * @notice It allows the admin to recover wrong tokens sent to the contract
     * @param _tokenAddress: the address of the token to withdraw
     * @param _tokenAmount: the number of tokens to withdraw
     * @dev This function is only callable by admin.
     */
    function recoverWrongTokens(address _tokenAddress, uint256 _tokenAmount)
        external
        onlyOwner
    {
        require(
            _tokenAddress != address(stakedToken),
            "Cannot be staked token"
        );
        require(
            _tokenAddress != address(rewardToken),
            "Cannot be reward token"
        );

        IERC20(_tokenAddress).safeTransfer(address(msg.sender), _tokenAmount);

        emit AdminTokenRecovery(_tokenAddress, _tokenAmount);
    }

    /**
     * @notice Stop rewards
     * @dev Only callable by owner
     */
    function stopReward() external onlyOwner {
        bonusEndBlock = block.number;
    }

    /**
     * @notice Update reward per block
     * @dev Only callable by owner.
     * @param _rewardPerBlock: the reward per block
     * @param _maxRewardPerBlock: the max nubmer of reward per block
     * @param _isDynamic: the flag for enalble dynamic changing the rewardPerBlock
     */
    function updateRewardPerBlock(
        uint256 _rewardPerBlock,
        uint256 _maxRewardPerBlock,
        bool _isDynamic
    ) external onlyOwner {
        require(_rewardPerBlock >= 1e17);
        require(_rewardPerBlock <= 3e18);
        require(_maxRewardPerBlock >= _rewardPerBlock);
        _updatePool();
        rewardPerBlock = _rewardPerBlock;
        defaultRewardPerBlock = rewardPerBlock;
        maxRewardPerBlock = _maxRewardPerBlock;
        isDynamic = _isDynamic;
        if (!_isDynamic) {
            isDynamicBTC = false;
            isDynamicBTCT = false;
        }
        emit NewRewardPerBlock(_rewardPerBlock);
    }

    /**
     * @notice It allows the admin to update start and end blocks
     * @dev This function is only callable by owner.
     * @param _startBlock: the new start block
     * @param _bonusEndBlock: the new end block
     */
    function updateStartAndEndBlocks(
        uint256 _startBlock,
        uint256 _bonusEndBlock
    ) external onlyOwner {
        require(block.number < startBlock, "Pool has started");
        require(
            _startBlock < _bonusEndBlock,
            "New startBlock must be lower than new endBlock"
        );
        require(
            block.number < _startBlock,
            "New startBlock must be higher than current block"
        );

        startBlock = _startBlock;
        bonusEndBlock = _bonusEndBlock;

        // Set the lastRewardBlock as the startBlock
        lastRewardBlock = startBlock;

        emit NewStartAndEndBlocks(_startBlock, _bonusEndBlock);
    }

    /**
     * @notice Update bonusEndBlock of the given pool to be up-to-date.
     * @param _bonusEndBlock: next bonusEndBlock
     */

    function updateEndBlocks(uint256 _bonusEndBlock) external onlyOwner {
        require(
            block.number < _bonusEndBlock,
            "New bonusEndBlock must be higher than current height"
        );
        bonusEndBlock = _bonusEndBlock;
    }

    /**
     * @notice View function to see pending reward on frontend.
     * @param _user: user address
     * @return Pending reward for a given user
     */
    function pendingReward(address _user) external view returns (uint256) {
        UserInfo storage user = userInfo[_user];
        uint256 stakedTokenSupply = stakedToken.balanceOf(address(this));
        if (block.number > lastRewardBlock && stakedTokenSupply != 0) {
            uint256 multiplier = _getMultiplier(lastRewardBlock, block.number);
            uint256 tokenReward = multiplier.mul(rewardPerBlock);
            uint256 adjustedTokenPerShare = accTokenPerShare.add(
                tokenReward.mul(1e12).div(stakedTokenSupply)
            );
            return
                user.amount.mul(adjustedTokenPerShare).div(1e12).sub(
                    user.rewardDebt
                );
        } else {
            return
                user.amount.mul(accTokenPerShare).div(1e12).sub(
                    user.rewardDebt
                );
        }
    }

    /**
     * @notice Update reward variables of the given pool to be up-to-date.
     */
    function _updatePool() internal {
        if (block.number <= lastRewardBlock) {
            return;
        }
        uint256 stakedTokenSupply = stakedToken.balanceOf(address(this));

        if (stakedTokenSupply == 0) {
            lastRewardBlock = block.number;
            return;
        }
        uint256 multiplier = _getMultiplier(lastRewardBlock, block.number);
        uint256 tokenReward = multiplier.mul(rewardPerBlock);
        accTokenPerShare = accTokenPerShare.add(
            tokenReward.mul(1e12).div(stakedTokenSupply)
        );
        if (isDynamic) _updateRewardPerBlock();
        lastRewardBlock = block.number;
    }

    /**
     * @notice View function to see next expected rewardPerBlock on frontend.
     * @param _token: token address which is supported on Swingby Skybridge.
     * @param _amountOfFloat: a float amount when deposited on skybridge in the future.
     */

    function getExpectedRewardPerBlock(address _token, uint256 _amountOfFloat)
        public
        view
        returns (
            uint256 updatedRewards,
            uint256 reserveBTC,
            uint256 reserveBTCT,
            uint256 tilt
        )
    {
        uint256 blocks = block.number - lastRewardBlock != 0
            ? block.number.sub(lastRewardBlock)
            : 1;

        updatedRewards = rewardPerBlock;
        (reserveBTC, reserveBTCT) = swapContract.getFloatReserve(
            address(0),
            BTCT_ADDR
        );

        require(_token == address(0x0) || _token == BTCT_ADDR);

        if (_token == address(0x0)) reserveBTC = reserveBTC.add(_amountOfFloat);
        else reserveBTCT = reserveBTCT.add(_amountOfFloat);

        tilt = (reserveBTC >= reserveBTCT)
            ? reserveBTC.sub(reserveBTCT)
            : reserveBTCT.sub(reserveBTC);

        if ((isDynamicBTC || isDynamicBTCT) && isDynamic)
            if (latestTilt > tilt) {
                updatedRewards = rewardPerBlock.add(
                    latestTilt.sub(tilt).mul(1e10).div(blocks)
                ); // moved == decimals 8
            } else {
                if (tilt.sub(latestTilt).mul(1e10) <= rewardPerBlock)
                    updatedRewards = rewardPerBlock.sub(
                        tilt.sub(latestTilt).mul(1e10).div(blocks)
                    ); // moved == decimals 8
                else updatedRewards = defaultRewardPerBlock;
            }

        if (updatedRewards >= maxRewardPerBlock) {
            updatedRewards = maxRewardPerBlock;
        }
        if (updatedRewards <= defaultRewardPerBlock) {
            updatedRewards = defaultRewardPerBlock;
        }
        return (updatedRewards, reserveBTC, reserveBTCT, tilt);
    }

    /**
     * @notice Update rewardPerBlock
     */
    function _updateRewardPerBlock() internal {
        (
            uint256 updatedRewards,
            uint256 reserveBTC,
            uint256 reserveBTCT,
            uint256 tilt
        ) = getExpectedRewardPerBlock(address(0x0), 0); // check the current numbers.

        rewardPerBlock = updatedRewards;

        // Reback the rate is going to be posive after reached to a threshold.
        if (reserveBTC >= reserveBTCT && isDynamicBTC) {
            // Disable additonal rewards rate for btc
            isDynamicBTC = false;
            rewardPerBlock = defaultRewardPerBlock;
        }

        // Reback the rate is going to be negative after reached to a threshold.
        if (reserveBTCT >= reserveBTC && isDynamicBTCT) {
            // Disable additonal rewards rate for btct
            isDynamicBTCT = false;
            rewardPerBlock = defaultRewardPerBlock;
        }

        // Check the deposit fees rate for checking the tilt of float balances
        uint256 feesForDepositBTC = swapContract.getDepositFeeRate(
            address(0x0),
            0
        );
        uint256 feesForDepositBTCT = swapContract.getDepositFeeRate(
            BTCT_ADDR,
            0
        );

        // if the deposit fees for BTC are exist, have to be activated isDynamicBTCT
        if (feesForDepositBTC != 0) {
            isDynamicBTCT = true;
        }
        // if the deposit fees for BTC are exist, have to be activated isDynamicBTC
        if (feesForDepositBTCT != 0) {
            isDynamicBTC = true;
        }
        latestTilt = tilt;
    }

    /**
     * @notice Return reward multiplier over the given _from to _to block.
     * @param _from: block to start
     * @param _to: block to finish
     */
    function _getMultiplier(uint256 _from, uint256 _to)
        internal
        view
        returns (uint256)
    {
        if (_to <= bonusEndBlock) {
            return _to.sub(_from);
        } else if (_from >= bonusEndBlock) {
            return 0;
        } else {
            return bonusEndBlock.sub(_from);
        }
    }
}