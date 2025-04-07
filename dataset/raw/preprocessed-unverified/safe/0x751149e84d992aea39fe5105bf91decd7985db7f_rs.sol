/**
 *Submitted for verification at Etherscan.io on 2021-03-15
*/

// SPDX-License-Identifier: MIT
pragma solidity 0.7.6;

/**
 * @dev Standard math utilities missing in the Solidity language.
 */


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
 * @dev Collection of functions related to the address type
 */



/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
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
        return payable(msg.sender);
    }

    function _msgData() internal view virtual returns (bytes memory) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}


 /* @dev Contract module which provides a basic access control mechanism, where
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
    constructor () {
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
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}



contract PolkazeckStake is Ownable {
    using SafeMath for uint256;
    
    uint256 constant DECIMALS = 10 ** 18;
    uint256 constant DIVISOR = 10 ** 10;
    uint256 constant STAKE_DURATION = 31540000;
    
    uint256 public allocation = 40000000 * DECIMALS;
    uint256 public maxStake = 500000 * DECIMALS;
    uint256 public minStake = 10000 * DECIMALS;
    uint256 public roiPerSeconds = 17361; // 0.15 / 1 day * DIVISOR;
    uint256 public totalStaked;
    uint256 public totalStakers;
    uint private unlocked = 1;

    IERC20 public stakeToken;
    IERC20[] public rewardToken;
    IUniswapV2Router02 public router;

    struct Stake {
        uint256 createdAt;
        uint256 amount;
        IERC20 rewardMode;
        uint256 lastWithdrawal;
    }
    
    mapping(address => Stake) stakes;
    
    
    modifier lock() {
        require(unlocked == 1, "PolkazeckStake: LOCKED");
        unlocked = 0;
        _;
        unlocked = 1;
    }

    constructor() {
        stakeToken = IERC20(0xeDB7b7842F7986a7f211d791e8F306C4Ce82Ba32);
        router = IUniswapV2Router02(0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D);
    }
    
    receive() payable external {
        revert();
    }
    
    function created(address _staker) external view returns(uint256) {
        return stakes[_staker].createdAt;
    }
    
    function staked(address _staker) external view returns(uint256) {
        return stakes[_staker].amount;
    }
    
    function rewardMode(address _staker) external view returns(IERC20) {
        return stakes[_staker].rewardMode;
    }
    
    function lastWithdrawal(address _staker) external view returns(uint256) {
        return stakes[_staker].lastWithdrawal;
    }
    
    function newStake(uint256 _amount, IERC20 selectedRewardToken) public lock {
        require(stakes[_msgSender()].amount == 0, "newStake: Staking");
        require(totalStaked.add(_amount) <= allocation, "newStake: Filled!");
        require(_amount <= maxStake, "newStake: Above maximum");
        require(_amount >= minStake, "newStake: Below minimum");
        require(isRewardToken(selectedRewardToken), "newStake: Reward not available");
        
        uint256 initialBalance = stakeToken.balanceOf(address(this));
        
        require(stakeToken.transferFrom(_msgSender(), address(this), _amount), "newStake: Transfer failed");
        
        uint256 latestBalance = stakeToken.balanceOf(address(this));
        uint256 amount = latestBalance.sub(initialBalance);
        
        stakes[_msgSender()] = Stake({createdAt: block.timestamp, amount: amount, rewardMode: selectedRewardToken, lastWithdrawal: block.timestamp});
        
        totalStakers = totalStakers.add(1);
        totalStaked = totalStaked.add(amount);
        
        emit NewStake(_msgSender(), address(selectedRewardToken), amount);
    }
    
    function withdraw() public lock {
        Stake storage stake = stakes[_msgSender()];
        if (stake.amount > 0 && stake.createdAt.add(STAKE_DURATION) > stake.lastWithdrawal) {
            uint256 thisReward = _roi(stake);
            // thisReward to rewardMode
            uint256 toReward = toRewardMode(thisReward, address(stake.rewardMode));
            require(stake.rewardMode.transfer(_msgSender(), toReward), "Withdraw: Transfer failed");
            stake.lastWithdrawal = block.timestamp;

            emit Withdraw(_msgSender(), address(stake.rewardMode), toReward);   
        }
    }
    
    function _exit() internal {
        Stake storage stake = stakes[_msgSender()];
        require(stake.amount > 0, "_exit: !Staking");
        require(stakeToken.transfer(_msgSender(), stake.amount), "_exit: Transfer failed");
        totalStaked = totalStaked.sub(stake.amount);
        totalStakers = totalStakers.sub(1);
        stake.amount = 0;
        emit Exit(_msgSender());
    }
    
    function exit() public lock {
        withdraw();
        _exit();
    }
    
    function emergencyExit() public lock {
        /*
        * Exit without rewards
        */
        _exit();
    }
    
    function roi(address _staker) public view returns(uint256) {
        Stake memory stake = stakes[_staker];
        return _roi(stake);
    }
    
    function _roi(Stake memory _stake) internal view returns(uint256) {
        uint256 periodBoundary = Math.min(block.timestamp, _stake.createdAt.add(STAKE_DURATION));
        uint256 thisRewardPeriod = periodBoundary.sub(_stake.lastWithdrawal);
        return _stake.amount.mul(thisRewardPeriod).mul(roiPerSeconds).div(DIVISOR);
    }
    
    function toRewardMode(uint256 _amount, address _token) public view returns(uint256) {
        address weth = router.WETH();
        address[] memory path;

        path[0] = address(stakeToken);
        path[1] = weth;

        if (_token != weth) {
           path[2] = _token;
        }

        uint256[] memory amountsOut = router.getAmountsOut(_amount, path);
        return amountsOut[amountsOut.length.sub(1)];
    }

    function estimateReward(uint256 _amount) public view returns(uint256) {
        return _amount.mul(STAKE_DURATION).mul(roiPerSeconds).div(DIVISOR);
    }
    
    function isRewardToken(IERC20 _token) public view returns(bool valid) {
        valid = false;
        for (uint i = 0; i < rewardToken.length; i++) {
            if (rewardToken[i] == _token) {
                valid = true;
                break;
            }
        }
    }
    
    function getAsset(IERC20 _tokenAddress, uint256 _amount) public onlyOwner {
        require(_tokenAddress != stakeToken, "getAsset: Not allowed!");
        require(_tokenAddress.balanceOf(address(this)) >= _amount, "getAsset: Not enough balance");
        _tokenAddress.transfer(owner(), _amount);
        
        emit Withdraw(_msgSender(), address(_tokenAddress), _amount);   
        
    }
    
    function setMaxStake(uint256 _max) external onlyOwner {
        maxStake = _max;
    }
    
    function setMinStake(uint256 _min) external onlyOwner {
        minStake = _min;
    }
    
    function setRoiPerSeconds(uint256 _roiPerSeconds) external onlyOwner {
        roiPerSeconds = _roiPerSeconds;
    }

    function setAllocation(uint256 _allocation) external onlyOwner {
        allocation = _allocation;
    }

    function addRewardToken(IERC20 _token) external onlyOwner {
        rewardToken.push(_token);
    } 
    
    event NewStake(address indexed staker, address indexed selectedRewardToken, uint256 amount);
    event Withdraw(address indexed staker, address indexed rewardToken, uint256 reward);
    event Exit(address indexed staker);
}