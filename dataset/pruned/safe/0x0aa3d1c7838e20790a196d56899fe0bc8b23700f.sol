/**
 *Submitted for verification at Etherscan.io on 2021-04-16
*/

// Sources flattened with hardhat v2.1.1 https://hardhat.org

// File @openzeppelin/contracts/math/[email protected]



pragma solidity >=0.6.0 <0.8.0;

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



// File @openzeppelin/contracts/token/ERC20/[email protected]



pragma solidity >=0.6.0 <0.8.0;

/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
 */



// File @openzeppelin/contracts/utils/[email protected]



pragma solidity >=0.6.2 <0.8.0;

/**
 * @dev Collection of functions related to the address type
 */



// File @openzeppelin/contracts/token/ERC20/[email protected]



pragma solidity >=0.6.0 <0.8.0;



/**
 * @title SafeERC20
 * @dev Wrappers around ERC20 operations that throw on failure (when the token
 * contract returns false). Tokens that return no value (and instead revert or
 * throw on failure) are also supported, non-reverting calls are assumed to be
 * successful.
 * To use this library you can add a `using SafeERC20 for IERC20;` statement to your contract,
 * which allows you to call the safe operations as `token.safeTransfer(...)`, etc.
 */



// File @openzeppelin/contracts/utils/[email protected]



pragma solidity >=0.6.0 <0.8.0;

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


// File @openzeppelin/contracts/utils/[email protected]



pragma solidity >=0.6.0 <0.8.0;

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


// File @openzeppelin/contracts/access/[email protected]



pragma solidity >=0.6.0 <0.8.0;

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


// File contracts/v7/interfaces/IPoolAllowance.sol


pragma solidity 0.7.4;

interface IPoolAllowance is IERC20 {
    function mintAllowance(address _account, uint256 _amount) external;

    function burnAllowance(address _account, uint256 _amount) external;
}


// File contracts/v7/interfaces/IRewardsPool.sol


pragma solidity 0.7.4;

interface IRewardsPool is IERC20 {
    function updateReward(address _account) external;

    function withdraw() external;

    function depositReward(uint256 _reward) external;
}


// File contracts/v7/interfaces/IOwnersRewardsPool.sol


pragma solidity 0.7.4;

interface IOwnersRewardsPool is IRewardsPool {
    function withdraw(address _account) external;
}


// File contracts/v7/interfaces/IERC677.sol


pragma solidity 0.7.4;

interface IERC677 is IERC20 {
    function transferAndCall(address _to, uint256 _value, bytes calldata _data) external returns (bool success);
}


// File contracts/v7/PoolOwners.sol


pragma solidity 0.7.4;







/**
 * @title Pool Owners
 * @dev Handles owners token staking, allowance token distribution, & owners rewards assets
 */
contract PoolOwners is ReentrancyGuard, Ownable {
    using SafeMath for uint256;
    using SafeERC20 for IERC677;

    IERC677 public stakingToken;
    uint256 public totalStaked;
    mapping(address => uint256) private stakedBalances;

    uint16 public totalRewardTokens;
    mapping(uint16 => address) public rewardTokens;
    mapping(address => address) public rewardPools;
    mapping(address => address) public allowanceTokens;
    mapping(address => mapping(address => uint256)) private mintedAllowanceTokens;

    event Staked(address indexed user, uint256 amount);
    event Withdrawn(address indexed user, uint256 amount);
    event RewardsWithdrawn(address indexed user);
    event AllowanceMinted(address indexed user);
    event RewardTokenAdded(address indexed token, address allowanceToken, address rewardsPool);
    event RewardTokenRemoved(address indexed token);

    constructor(address _stakingToken) {
        stakingToken = IERC677(_stakingToken);
    }

    modifier updateRewards(address _account) {
        for (uint16 i = 0; i < totalRewardTokens; i++) {
            IOwnersRewardsPool(rewardPools[rewardTokens[i]]).updateReward(_account);
        }
        _;
    }

    /**
     * @dev returns a user's staked balance
     * @param _account user to return balance for
     * @return user's staked balance
     **/
    function balanceOf(address _account) public view returns (uint256) {
        return stakedBalances[_account];
    }

    /**
     * @dev returns how many allowance tokens have been minted for a user
     * @param _allowanceToken allowance token to return minted amount for
     * @param _account user to return minted amount for
     * @return total allowance tokens a user has minted
     **/
    function mintedAllowance(address _allowanceToken, address _account) public view returns (uint256) {
        return mintedAllowanceTokens[_allowanceToken][_account];
    }

    /**
     * @dev returns total amount staked
     * @return total amount staked
     **/
    function totalSupply() public view returns (uint256) {
        return totalStaked;
    }

    /**
     * @dev ERC677 implementation that proxies staking
     * @param _sender of the token transfer
     * @param _value of the token transfer
     **/
    function onTokenTransfer(address _sender, uint256 _value, bytes calldata) external nonReentrant {
        require(msg.sender == address(stakingToken), "Sender must be staking token");
        require(_value > 0, "Cannot stake 0");
        _stake(_sender, _value);
    }

    /**
     * @dev stakes owners tokens & mints staking allowance tokens in return
     * @param _amount amount to stake
     **/
    function stake(uint256 _amount) external nonReentrant {
        require(_amount > 0, "Cannot stake 0");
        stakingToken.safeTransferFrom(msg.sender, address(this), _amount);
        _stake(msg.sender, _amount);
    }

    /**
     * @dev burns staking allowance tokens and withdraws staked owners tokens
     * @param _amount amount to withdraw
     **/
    function withdraw(uint256 _amount) public nonReentrant updateRewards(msg.sender) {
        require(_amount > 0, "Cannot withdraw 0");
        stakedBalances[msg.sender] = stakedBalances[msg.sender].sub(_amount);
        totalStaked -= _amount;
        _burnAllowance(msg.sender);
        stakingToken.safeTransfer(msg.sender, _amount);
        emit Withdrawn(msg.sender, _amount);
    }

    /**
     * @dev withdraws user's earned rewards for a all assets
     **/
    function withdrawAllRewards() public nonReentrant {
        for (uint16 i = 0; i < totalRewardTokens; i++) {
            _withdrawReward(rewardTokens[i], msg.sender);
        }
        emit RewardsWithdrawn(msg.sender);
    }

    /**
     * @dev withdraws users earned rewards for all assets and withdraws their owners tokens
     **/
    function exit() external {
        withdraw(balanceOf(msg.sender));
        withdrawAllRewards();
    }

    /**
     * @dev mints a user's unclaimed allowance tokens (used if a new asset is added
     * after a user has already staked)
     **/
    function mintAllowance() external nonReentrant {
        _mintAllowance(msg.sender);
        emit AllowanceMinted(msg.sender);
    }

    /**
     * @dev adds a new asset
     * @param _token asset to add
     * @param _allowanceToken asset pool allowance token to add
     * @param _rewardPool asset reward pool to add
     **/
    function addRewardToken(
        address _token,
        address _allowanceToken,
        address _rewardPool
    ) external onlyOwner() {
        require(rewardPools[_token] == address(0), "Reward token already exists");
        rewardTokens[totalRewardTokens] = _token;
        allowanceTokens[_token] = _allowanceToken;
        rewardPools[_token] = _rewardPool;
        totalRewardTokens++;
        emit RewardTokenAdded(_token, _allowanceToken, _rewardPool);
    }

    /**
     * @dev removes an existing asset
     * @param _index index of asset to remove
     **/
    function removeRewardToken(uint16 _index) external onlyOwner() {
        require(_index < totalRewardTokens, "Reward token does not exist");
        address token = rewardTokens[_index];
        if (totalRewardTokens > 1) {
            rewardTokens[_index] = rewardTokens[totalRewardTokens - 1];
        }
        delete rewardTokens[totalRewardTokens - 1];
        delete allowanceTokens[token];
        delete rewardPools[token];
        totalRewardTokens--;
        emit RewardTokenRemoved(token);
    }

    /**
     * @dev stakes owners tokens & mints staking allowance tokens in return
     * @param _amount amount to stake
     **/
    function _stake(address _sender, uint256 _amount) private updateRewards(_sender) {
        stakedBalances[_sender] = stakedBalances[_sender].add(_amount);
        totalStaked += _amount;
        _mintAllowance(_sender);
        emit Staked(_sender, _amount);
    }

    /**
     * @dev withdraws rewards for a specific asset & account
     * @param _token asset to withdraw
     * @param _account user to withdraw for
     **/
    function _withdrawReward(address _token, address _account) private {
        require(rewardPools[_token] != address(0), "Reward token does not exist");
        IOwnersRewardsPool(rewardPools[_token]).withdraw(_account);
    }

    /**
     * @dev mints allowance tokens based on a user's staked balance
     * @param _account user to mint tokens for
     **/
    function _mintAllowance(address _account) private {
        uint256 stakedAmount = balanceOf(_account);
        for (uint16 i = 0; i < totalRewardTokens; i++) {
            address token = allowanceTokens[rewardTokens[i]];
            uint256 minted = mintedAllowance(token, _account);
            if (minted < stakedAmount) {
                IPoolAllowance(token).mintAllowance(_account, stakedAmount.sub(minted));
                mintedAllowanceTokens[token][_account] = stakedAmount;
            }
        }
    }

    /**
     * @dev burns allowance tokens based on a user's staked balance
     * @param _account user to burn tokens for
     **/
    function _burnAllowance(address _account) private {
        uint256 stakedAmount = balanceOf(_account);
        for (uint16 i = 0; i < totalRewardTokens; i++) {
            address token = allowanceTokens[rewardTokens[i]];
            uint256 minted = mintedAllowance(token, _account);
            if (minted > stakedAmount) {
                IPoolAllowance(token).burnAllowance(_account, minted.sub(stakedAmount));
                mintedAllowanceTokens[token][_account] = stakedAmount;
            }
        }
    }
}