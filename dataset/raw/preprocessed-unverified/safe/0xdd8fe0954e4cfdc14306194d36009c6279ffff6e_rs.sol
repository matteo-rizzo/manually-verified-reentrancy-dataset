/**
 *Submitted for verification at Etherscan.io on 2020-11-25
*/

/**
 *Submitted for verification at Etherscan.io on 2020-11-17
*/

// SPDX-License-Identifier: MIT
pragma solidity 0.6.0;

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

/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
 */










contract Airpool is Ownable {
    using SafeMath for uint256;
    
    event Staked(
        address lpToken,
        address user,
        uint256 amountToken,
        uint256 amountETH,
        uint256 liquidity
    );
    
    event Unstaked(
        address user,
        address lpToken,
        uint256 amountToken
    );
    
    event RewardWithdrawn(
        address user,
        uint256 amount
    );
    
    uint256 private constant rewardMultiplier = 1e17;
    
    struct Stake {
        uint256 stakeAmount; // lp token address to token amount
        uint256 totalStakedAmountByUser; // sum of all lp tokens
        uint256 lastInteractionBlockNumber; // block number at last withdraw
        uint256 stakingPeriodEndTime;
    }
    
    mapping(address => Stake) public userToStakes; // user to stake
    uint256 public totalStakedAmount; // sum of stakes by all of the users across all lp
    
    address internal uniswapFactoryAddress = 0x5C69bEe701ef814a2B6a3EDD4B1652CB9cc5aA6f;
    address internal uniswapRouterAddress = 0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D;
     
    IUniswapV2Factory public uniswapFactory = IUniswapV2Factory(uniswapFactoryAddress);
    IUniswapV2Router02 public uniswapRouter = IUniswapV2Router02(uniswapRouterAddress);

    address public token;
    address public lpToken;
    
    uint256 public blockMiningTime = 15;
    uint256 public blockReward = 50000000000000000;
    uint256 public stakingDuration = 2592000;
    uint256 public minimumAmount = 1000000000000000;
    uint256 public maximumAmount = 100000000000000000000; 

    constructor(address airdropToken, address pairToken) public {
        token = airdropToken;
        lpToken = pairToken;
        
        IERC20(token).approve(uniswapRouterAddress, 1e52); // approve uniswap router
    }
    
    fallback() external payable {}
    
    receive() external payable {}
    
    function setMinimumAmount(uint256 amount) external onlyOwner {
        require(
            amount != 0,
            "minimum amount cannot be zero"
        );
        minimumAmount = amount;
    }
    
    function setMaximumAmount(uint256 amount) external onlyOwner {
        require(
            amount != 0,
            "maximum amount cannot be zero"
        );
        maximumAmount = amount;
    }
    
    function setBlockReward(uint256 rewardAmount) external onlyOwner {
        require(
            rewardAmount != 0,
            "new reward cannot be zero"
        );
        blockReward = rewardAmount;
    }
    
    function setStakingDuration(uint256 duration) external onlyOwner {
        require(
            duration != 0,
            "new reward cannot be zero"
        );
        stakingDuration = duration;
    }

    function changeBlockMiningTime(uint256 newTime) external onlyOwner {
        require(
            newTime != 0,
            "new time cannot be zero"
        );
        blockMiningTime = newTime;
    }

    function supplyAirpool(
        uint256 amountTokenDesired,
        uint256 amountTokenMin,
        uint256 amountETHMin
    ) external payable {
        require(
            msg.value != 0, // must send ether
            "amount should be greater than 0"
        );
        
        require(
            msg.value >= minimumAmount,
            "amount too low"
        );
        
        require(
            msg.value <= maximumAmount,
            "amount too high"
        );

        uint deadline = block.timestamp.add(2 hours); // set deadline to 2 hours from now

        (uint amountToken, uint amountETH, uint liquidity) = uniswapRouter.addLiquidityETH.value(msg.value)(
            token,
            amountTokenDesired,
            amountTokenMin,
            amountETHMin,
            address(this),
            deadline 
        );
        
        if (msg.value > amountETH) {
            _msgSender().transfer(msg.value - amountETH); // transfer dust eth back to sender
        }
        
        _withdrawReward(_msgSender()); // withdraw any existing rewards

        totalStakedAmount = totalStakedAmount.add(liquidity); // add stake amount to sum of all stakes across al lps
        
        Stake storage currentStake = userToStakes[_msgSender()];
        currentStake.stakingPeriodEndTime = block.timestamp.add(
            stakingDuration
        ); // set the staking period end time

        currentStake.stakeAmount =  currentStake.stakeAmount // add stake amount by lp
            .add(liquidity);
        
        currentStake.totalStakedAmountByUser = currentStake.totalStakedAmountByUser // add stake amount to sum of all stakes by user
            .add(liquidity);

        emit Staked(
            lpToken,
            _msgSender(),
            amountToken,
            amountETH,
            liquidity
        ); // broadcast event
    }
    
    function unstake() external {
        _withdrawReward(_msgSender());
        Stake storage currentStake = userToStakes[_msgSender()];
        uint256 stakeAmountToDeduct;
        bool executeUnstaking;
        uint256 stakeAmount = currentStake.stakeAmount;
            
        if (currentStake.stakeAmount == 0) {
            revert("no stake");
        }

        if (currentStake.stakingPeriodEndTime <= block.timestamp) {
            executeUnstaking = true;
        }

        require(
            executeUnstaking,
            "cannot unstake"
        );
        
        currentStake.stakeAmount = 0;
        
        currentStake.totalStakedAmountByUser = currentStake.totalStakedAmountByUser
            .sub(stakeAmount);
        
        stakeAmountToDeduct = stakeAmountToDeduct.add(stakeAmount);
        
        require(
            IERC20(lpToken).transfer(_msgSender(), stakeAmount), // transfer staked tokens back to the user
            "#transferFrom failed"
        );
        
        emit Unstaked(lpToken, _msgSender(), stakeAmount);
        
        totalStakedAmount = totalStakedAmount.sub(stakeAmountToDeduct); // subtract unstaked amount from total staked amount
    }
    
    function withdrawReward() external {
        _withdrawReward(_msgSender());
    }
    
    function getBlockCountSinceLastIntreraction(address user) public view returns(uint256) {
        uint256 lastInteractionBlockNum = userToStakes[user].lastInteractionBlockNumber;
        if (lastInteractionBlockNum == 0) {
            return 0;
        }
        
        return block.number.sub(lastInteractionBlockNum);
    }
    
    function getTotalStakeAmountByUser(address user) public view returns(uint256) {
        return userToStakes[user].totalStakedAmountByUser;
    }
    
    function getStakeAmountByUser(
        address user
    ) public view returns(uint256) {
        return userToStakes[user].stakeAmount;
    }
    
    function getRewardByAddress(
        address user
    ) public view returns(uint256) {
        if (totalStakedAmount == 0) {
            return 0;
        }
        
        Stake storage currentStake = userToStakes[user];
        
        uint256 blockCount = block.number
            .sub(currentStake.lastInteractionBlockNumber);
        
        uint256 totalReward = blockCount.mul(blockReward);
        
        return totalReward
            .mul(currentStake.totalStakedAmountByUser)
            .div(totalStakedAmount);
    }
    
    function _withdrawReward(address user) internal {
        uint256 rewardAmount = getRewardByAddress(user);
        
        uint256 totalSupply = IERC20(token).totalSupply();
        uint256 cap = IERC20Capped(token).cap();
        
        if (rewardAmount != 0) {
            if (totalSupply.add(rewardAmount) <= cap) {
                require(
                    IMintable(token).mint(user, rewardAmount), // reward user with newly minted tokens
                    "#mint failed"
                );
                emit RewardWithdrawn(user, rewardAmount);
            }
        }
        
        userToStakes[user].lastInteractionBlockNumber = block.number;
    }
}