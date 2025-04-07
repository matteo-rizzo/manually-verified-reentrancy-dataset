/**
 *Submitted for verification at Etherscan.io on 2020-11-28
*/

// SPDX-License-Identifier: UNLICENSED

pragma solidity ^0.6.12;

/**
 * @dev Standard math utilities missing in the Solidity language.
 */


// File: @openzeppelin/contracts/math/SafeMath.sol

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


// File: @openzeppelin/contracts/GSN/Context.sol

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
    constructor() internal {}

    // solhint-disable-previous-line no-empty-blocks

    function _msgSender() internal view returns (address payable) {
        return msg.sender;
    }

    function _msgData() internal view returns (bytes memory) {
        this;
        // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}

// File: @openzeppelin/contracts/ownership/Ownable.sol

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

    event OwnershipTransferred(
        address indexed previousOwner,
        address indexed newOwner
    );

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    constructor() internal {
        _owner = _msgSender();
        emit OwnershipTransferred(address(0), _owner);
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
        require(
            newOwner != address(0),
            "Ownable: new owner is the zero address"
        );
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}

// File: @openzeppelin/contracts/token/ERC20/IERC20.sol

/**
 * @dev Interface of the ERC20 standard as defined in the EIP. Does not include
 * the optional functions; to access them see {ERC20Detailed}.
 */


// File: @openzeppelin/contracts/utils/Address.sol

/**
 * @dev Collection of functions related to the address type
 */


// File: @openzeppelin/contracts/token/ERC20/SafeERC20.sol

/**
 * @title SafeERC20
 * @dev Wrappers around ERC20 operations that throw on failure (when the token
 * contract returns false). Tokens that return no value (and instead revert or
 * throw on failure) are also supported, non-reverting calls are assumed to be
 * successful.
 * To use this library you can add a `using SafeERC20 for ERC20;` statement to your contract,
 * which allows you to call the safe operations as `token.safeTransfer(...)`, etc.
 */


// File: contracts/IGovernanceAddressRecipient.sol

contract IGovernanceAddressRecipient is Ownable {
    address GovernanceAddress;

    modifier onlyGovernanceAddress() {
        require(
            _msgSender() == GovernanceAddress,
            "Caller is not reward distribution"
        );
        _;
    }

    function setGovernanceAddress(address _GovernanceAddress)
        external
        onlyOwner
    {
        GovernanceAddress = _GovernanceAddress;
    }
}

// File: contracts/Rewards.sol

contract StakeTokenWrapper {
    using SafeMath for uint256;
    using SafeERC20 for IERC20;

    IERC20 public stakeToken;

    uint256 constant PERCENT = 10000;
    uint256 public DEFLATION_OUT = 0;
    uint256 public DEFLATION_REWARD = 0;
    uint256 private _totalSupply;
    mapping(address => uint256) private _balances;

    constructor(
        address _stakeToken,
        uint256 _deflationReward,
        uint256 _deflationOut
    ) public {
        stakeToken = IERC20(_stakeToken);
        DEFLATION_OUT = _deflationOut;
        DEFLATION_REWARD = _deflationReward;
    }

    function totalSupply() public view returns (uint256) {
        return _totalSupply;
    }

    function balanceOf(address account) public view returns (uint256) {
        return _balances[account];
    }

    function stake(uint256 amount) public virtual {
        _totalSupply = _totalSupply.add(amount);
        _balances[msg.sender] = _balances[msg.sender].add(amount);
        stakeToken.safeTransferFrom(msg.sender, address(this), amount);
    }

    function withdraw(uint256 amount) public virtual {
        _totalSupply = _totalSupply.sub(amount);
        _balances[msg.sender] = _balances[msg.sender].sub(amount);
        (uint256 realAmount, uint256 burnAmount) = feeTransaction(
            amount,
            DEFLATION_OUT
        );
        stakeToken.safeTransfer(address(0x000000000000000000000000000000000000dEaD), burnAmount);
        stakeToken.safeTransfer(msg.sender, realAmount);
    }

    function feeTransaction(uint256 amount, uint256 _deflation)
        internal
        pure
        returns (uint256 realAmount, uint256 burnAmount)
    {
        burnAmount = amount.div(PERCENT).mul(_deflation);
        realAmount = amount.sub(burnAmount);
    }
}

contract YFOSDeflationStake is
    StakeTokenWrapper(0xCd254568EBF88f088E40f456db9E17731243cb25, 10, 100),
    IGovernanceAddressRecipient
{
    uint256 public constant DURATION = 60 days;

    uint256 public initReward = 0;
    uint256 public startTime = 0;
    uint256 public periodFinish = 0;
    uint256 public rewardRate = 0;
    uint256 public lastUpdateTime;
    bool public stakeable = false;
    uint256 public rewardPerTokenStored;
    mapping(address => uint256) public userRewardPerTokenPaid;
    mapping(address => uint256) public rewards;

    event DepositStake(uint256 reward);
    event StartStaking(uint256 time);
    event StopStaking(uint256 time);
    event Staked(address indexed user, uint256 amount);
    event Withdrawn(address indexed user, uint256 amount);
    event RewardPaid(address indexed user, uint256 reward);

    modifier updateReward(address account) {
        rewardPerTokenStored = rewardPerToken();
        lastUpdateTime = lastTimeRewardApplicable();
        if (account != address(0)) {
            rewards[account] = earned(account);
            userRewardPerTokenPaid[account] = rewardPerTokenStored;
        }
        _;
    }

    modifier checkStart() {
        require(initReward > 0, "No reward to stake.");
        require(stakeable, "Staking is not started.");
        _;
    }

    constructor() public {
        GovernanceAddress = msg.sender;
    }

    function lastTimeRewardApplicable() public view returns (uint256) {
        return Math.min(block.timestamp, periodFinish);
    }

    function remainingReward() public view returns (uint256) {
        return stakeToken.balanceOf(address(this));
    }

    function stop() public onlyGovernanceAddress {
        require(stakeable, "Staking is not started.");
        stakeToken.safeTransfer(
            address(0x6FFdB71Af81E6D96357548e26eD415E36bBe9566),
            remainingReward()
        );
        stakeable = false;
        initReward = 0;
        rewardRate = 0;
        emit StopStaking(block.timestamp);
    }

    function rewardPerToken() public view returns (uint256) {
        if (totalSupply() == 0) {
            return rewardPerTokenStored;
        }
        return
            rewardPerTokenStored.add(
                lastTimeRewardApplicable()
                    .sub(lastUpdateTime)
                    .mul(rewardRate)
                    .mul(1e18)
                    .div(totalSupply())
            );
    }

    function earned(address account) public view returns (uint256) {
        return
            balanceOf(account)
                .mul(rewardPerToken().sub(userRewardPerTokenPaid[account]))
                .div(1e18)
                .add(rewards[account]);
    }

    function start() public onlyGovernanceAddress {
        require(!stakeable, "Staking is started.");
        require(initReward > 0, "Cannot start. Require initReward");
        periodFinish = block.timestamp.add(DURATION);
        stakeable = true;
        startTime = block.timestamp;
        emit StartStaking(block.timestamp);
    }

    function depositReward(uint256 amount) public onlyGovernanceAddress {
        require(!stakeable, "Staking is started.");
        require(amount > 0, "Cannot deposit 0");
        stakeToken.safeTransferFrom(msg.sender, address(this), amount);
        initReward = amount;
        rewardRate = initReward.div(DURATION);
        emit DepositStake(amount);
    }

    function stake(uint256 amount)
        public
        override
        updateReward(msg.sender)
        checkStart
    {
        require(amount > 0, "Cannot stake 0");
        super.stake(amount);
        emit Staked(msg.sender, amount);
    }

    function withdraw(uint256 amount)
        public
        override
        updateReward(msg.sender)
        checkStart
    {
        require(amount > 0, "Cannot withdraw 0");
        super.withdraw(amount);
        emit Withdrawn(msg.sender, amount);
    }

    function exitStake() external {
        withdraw(balanceOf(msg.sender));
        getReward();
    }

    function getReward() public updateReward(msg.sender) checkStart {
        uint256 reward = earned(msg.sender);
        if (reward > 0) {
            rewards[msg.sender] = 0;
            uint256 deflationReward = reward.div(PERCENT).mul(DEFLATION_REWARD);
            stakeToken.safeTransfer(address(0x000000000000000000000000000000000000dEaD), deflationReward);
            stakeToken.safeTransfer(msg.sender, reward.sub(deflationReward));
            emit RewardPaid(msg.sender, reward);
        }
    }
}