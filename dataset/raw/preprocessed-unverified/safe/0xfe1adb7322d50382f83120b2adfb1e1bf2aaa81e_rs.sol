/**
 *Submitted for verification at Etherscan.io on 2021-05-06
*/

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

/**
 * @dev Collection of functions related to the address type
 */


/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
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
contract OwnableData {
    address public owner;
    address public pendingOwner;
}

abstract contract Ownable is OwnableData {
    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor () {
        owner = msg.sender;
        emit OwnershipTransferred(address(0), msg.sender);
    }

    function transferOwnership(address newOwner, bool direct, bool renounce) public onlyOwner {
        if (direct) {

            require(newOwner != address(0) || renounce, "Ownable: zero address");

            emit OwnershipTransferred(owner, newOwner);
            owner = newOwner;
        } else {
            pendingOwner = newOwner;
        }
    }

    function claimOwnership() public {
        address _pendingOwner = pendingOwner;

        require(msg.sender == _pendingOwner, "Ownable: caller != pending owner");

        emit OwnershipTransferred(owner, _pendingOwner);
        owner = _pendingOwner;
        pendingOwner = address(0);
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "Ownable: caller is not the owner");
        _;
    }
}

contract StorageBuffer {

    // Reserved storage space to allow for layout changes in the future.
    uint256[20] private _gap;

    function getStore(uint a) internal view returns(uint) {
        require(a < 20, "Not allowed");
        return _gap[a];
    }

    function setStore(uint a, uint val) internal {
        require(a < 20, "Not allowed");
        _gap[a] = val;
    }
}

// This contract is dedicated to process LP tokens of the users. More precisely, this allows Popsicle to track how much tokens
// the user has deposited and indicate how much he is eligible to withdraw 
abstract contract LPTokenWrapper is StorageBuffer {
    using SafeERC20 for IERC20;

// Address of ICE token
    IERC20 public immutable ice;
    // Address of LP token
    IERC20 public immutable lpToken;

// Amount of Lp tokens deposited
    uint256 private _totalSupply;
    // A place where user token balance is stored
    mapping(address => uint256) private _balances;

// Function modifier that calls update reward function
    modifier updateReward(address account) {
        _updateReward(account);
        _;
    }

    constructor(address _ice, address _lpToken) {
        require(_ice != address(0) && _lpToken != address(0), "NULL_ADDRESS");
        ice = IERC20(_ice);
        lpToken = IERC20(_lpToken);
    }
// View function that provides tptal supply for the front end 
    function totalSupply() public view returns (uint256) {
        return _totalSupply;
    }
// View function that provides the LP balance of a user
    function balanceOf(address account) public view returns (uint256) {
        return _balances[account];
    }
// Fuction that is responsible for the recival of  LP tokens of the user and the update of the user balance 
    function stake(uint256 amount) virtual public {
        _totalSupply += amount;
        _balances[msg.sender] += amount;
        lpToken.safeTransferFrom(msg.sender, address(this), amount);
    }
// Function that is reponsible for releasing LP tokens to the user and for the update of the user balance 
    function withdraw(uint256 amount) virtual public {
        _totalSupply -= amount;
        _balances[msg.sender] -= amount;
        lpToken.safeTransfer(msg.sender, amount);
    }

//Interface 
    function _updateReward(address account) virtual internal;
}

/**
 * This contract is responsible fpr forwarding LP tokens to Masterchef contract.
 * It calculates ICE rewards and distrubutes both ICE and Sushi
 */
contract PopsicleJointStaking is LPTokenWrapper, Ownable {
    using SafeERC20 for IERC20;
    // Immutable Address of Sushi token
    IERC20 public immutable sushi;
    // Immutable masterchef contract address
    IMasterChef public immutable masterChef;
    uint256 public immutable pid; // sushi pool id

// Reward rate - This is done to set ICE reward rate proportion. 
    uint256 public rewardRate = 2000000;
// Custom divisioner that is implemented in order to give the ability to alter rate reward according to the project needs
    uint256 public constant DIVISIONER = 10 ** 6;

// Set of variables that is storing user Sushi rewards
    uint256 public sushiPerTokenStored;
    // Info of each user.
    struct UserInfo {
        uint256 remainingIceTokenReward; // Remaining Token amount that is owned to the user.
        uint256 sushiPerTokenPaid;
        uint256 sushiRewards;
    }
    
    // Info of each user that stakes ICE tokens.
    mapping(address => UserInfo) public userInfo;
    //mapping(address => uint256) public sushiPerTokenPaid;
    //mapping(address => uint256) public sushiRewards;

    event Staked(address indexed user, uint256 amount);
    event Withdrawn(address indexed user, uint256 amount);
    event RewardPaid(address indexed user, uint256 reward);
    event SushiPaid(address indexed user, uint256 reward);

    constructor(
        address _ice,
        address _sushi,
        address _lpToken,
        address _masterChef,
        uint256 _pid
    )
        LPTokenWrapper(_ice, _lpToken)
    {
        require(
           _sushi != address(0) && _masterChef != address(0),
           "NULL_ADDRESSES"
        );
        sushi = IERC20(_sushi);
        masterChef = IMasterChef(_masterChef);
        pid = _pid;
    }
// Function which tracks rewards of a user and harvests all sushi rewards from Masterchef
    function _updateReward(address account) override internal {
        UserInfo storage user = userInfo[msg.sender];
        uint _then = sushi.balanceOf(address(this));
        masterChef.withdraw(pid, 0); // harvests sushi
        sushiPerTokenStored = _sushiPerToken(sushi.balanceOf(address(this)) - _then);

        if (account != address(0)) {
            user.sushiRewards = _sushiEarned(account, sushiPerTokenStored);
            user.sushiPerTokenPaid = sushiPerTokenStored;
        }
    }

// View function which shows sushi rewards amount of our Pool 
    function sushiPerToken() public view returns (uint256) {
        return _sushiPerToken(masterChef.pendingSushi(pid, address(this)));
    }
// Calculates how much sushi is provied per LP token 
    function _sushiPerToken(uint earned_) internal view returns (uint256) {
        uint _totalSupply = totalSupply();
        if (_totalSupply > 0) {
            return (sushiPerTokenStored + earned_) * 1e18 / _totalSupply;
        }
        return sushiPerTokenStored;
    }
// View function which shows user ICE reward for displayment on frontend
    function earned(address account) public view returns (uint256) {
        UserInfo memory user = userInfo[account];
        return _sushiEarned(account, sushiPerToken()) * rewardRate / DIVISIONER + user.remainingIceTokenReward;
    }
// View function which shows user Sushi reward for displayment on frontend
    function sushiEarned(address account) public view returns (uint256) {
        return _sushiEarned(account, sushiPerToken());
    }
// Calculates how much sushi is entitled for a particular user
    function _sushiEarned(address account, uint256 sushiPerToken_) internal view returns (uint256) {
        UserInfo memory user = userInfo[account];
        return
            balanceOf(account) * (sushiPerToken_ - user.sushiPerTokenPaid) / 1e18 + user.sushiRewards;
    }

    // stake visibility is public as overriding LPTokenWrapper's stake() function
    //Recieves users LP tokens and deposits them to Masterchef contract
    function stake(uint256 amount) override public updateReward(msg.sender) {
        require(amount > 0, "Cannot stake 0");
        super.stake(amount);
        lpToken.approve(address(masterChef), amount);
        masterChef.deposit(pid, amount);
        emit Staked(msg.sender, amount);
    }
// Recieves Lp tokens from Masterchef and give it out to the user
    function withdraw(uint256 amount) override public updateReward(msg.sender) {
        require(amount > 0, "Cannot withdraw 0");
        masterChef.withdraw(pid, amount); // harvests sushi
        super.withdraw(amount);
        emit Withdrawn(msg.sender, amount);
    }

    // "Go home" function which withdraws all Funds and distributes all rewards to the user
    function exit() external {
        require(msg.sender != address(0));
        
        UserInfo storage user = userInfo[msg.sender];
        uint _then = sushi.balanceOf(address(this));
        uint256 amount = balanceOf(msg.sender);
        require(amount > 0, "Cannot withdraw 0");
        
        masterChef.withdraw(pid, amount); // harvests sushi
        sushiPerTokenStored = _sushiPerToken(sushi.balanceOf(address(this)) - _then);
        
        user.sushiRewards = _sushiEarned(msg.sender, sushiPerTokenStored);
        user.sushiPerTokenPaid = sushiPerTokenStored;
        
        super.withdraw(amount);
        emit Withdrawn(msg.sender, amount);
        
        uint256 reward = user.sushiRewards;
        if (reward > 0) {
            user.sushiRewards = 0;
            sushi.safeTransfer(msg.sender, reward);
            emit SushiPaid(msg.sender, reward);
        }
        reward = reward * rewardRate / DIVISIONER + user.remainingIceTokenReward;
        if (reward > 0)
        {
            user.remainingIceTokenReward = safeRewardTransfer(msg.sender, reward);
            emit RewardPaid(msg.sender, reward);
        }
        
    }
    // Changes rewards rate of ICE token
    function setRewardRate(uint256 _rewardRate) external onlyOwner {
        rewardRate = _rewardRate;
    }
// Harvests rewards to the user but leaves the Lp tokens deposited
    function getReward() public updateReward(msg.sender) {
        UserInfo storage user = userInfo[msg.sender];
        uint256 reward = user.sushiRewards;
        if (reward > 0) {
            user.sushiRewards = 0;
            sushi.safeTransfer(msg.sender, reward);
            emit SushiPaid(msg.sender, reward);
        }
        reward = reward * rewardRate / DIVISIONER + user.remainingIceTokenReward;
        if (reward > 0)
        {
            user.remainingIceTokenReward = safeRewardTransfer(msg.sender, reward);
            emit RewardPaid(msg.sender, reward);
        }
    }
    
    // Safe token distribution
    function safeRewardTransfer(address _to, uint256 _amount) internal returns(uint256) {
        uint256 rewardTokenBalance = ice.balanceOf(address(this));
        if (rewardTokenBalance == 0) { //save some gas fee
            return _amount;
        }
        if (_amount > rewardTokenBalance) { //save some gas fee
            ice.transfer(_to, rewardTokenBalance);
            return _amount - rewardTokenBalance;
        }
        ice.transfer(_to, _amount);
        return 0;
    }
}
// Implemented to call functions of masterChef
