/**
 *Submitted for verification at Etherscan.io on 2021-04-22
*/

pragma solidity ^0.7.0;



abstract contract Context {
    function _msgSender() internal view virtual returns (address payable) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes memory) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}


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






contract CompoundRateKeeper is Ownable {
    using SafeMath for uint256;

    struct CompoundRate {
        uint256 rate;
        uint256 lastUpdate;
    }

    CompoundRate public compoundRate;

    constructor () {
        compoundRate.rate = 1 * 10 ** 27;
        compoundRate.lastUpdate = block.timestamp;
    }

    function getCurrentRate() view external returns(uint256) {
        return compoundRate.rate;
    }

    function getLastUpdate() view external returns(uint256) {
        return compoundRate.lastUpdate;
    }

    function update(uint256 _interestRate) external onlyOwner returns(uint256) {
        uint256 _decimal = 10 ** 27;
        uint256 _period = (block.timestamp).sub(compoundRate.lastUpdate);
        uint256 _newRate = compoundRate.rate
        .mul(DSMath.rpow(_interestRate.add(_decimal), _period, _decimal)).div(_decimal);

        compoundRate.rate = _newRate;
        compoundRate.lastUpdate = block.timestamp;

        return _newRate;
    }
}




contract EpanStaking is IEpanStaking, Ownable {
    using SafeMath for uint;

    CompoundRateKeeper public compRateKeeper;
    CompoundRateKeeper public compRateKeeperTimeframe;
    IERC20 public epanToken;

    struct Stake {
        uint256 amount;
        uint256 normalizedAmount;
    }

    struct StakeTimeframe {
        uint256 amount;
        uint256 normalizedAmount;
        uint256 lastStakeTime;
    }

    uint256 public interestRate;
    uint256 public interestRateTimeframe;

    mapping(address => Stake) public userStakes;
    mapping(address => StakeTimeframe) public userStakesTimeframe;

    uint256 public aggregatedNormalizedStake;
    uint256 public aggregatedNormalizedStakeTimeframe;

    constructor(address _token, address _compRateKeeper, address _compRateKeeperTimeframe) {
        compRateKeeper = CompoundRateKeeper(_compRateKeeper);
        compRateKeeperTimeframe = CompoundRateKeeper(_compRateKeeperTimeframe);
        epanToken = IERC20(_token);
    }

    /**
     * @notice Update compound rate
     */
    function updateCompoundRate() public override {
        compRateKeeper.update(interestRate);
    }

    /**
     * @notice Update compound rate timeframe
     */
    function updateCompoundRateTimeframe() public override {
        compRateKeeperTimeframe.update(interestRateTimeframe);
    }

    /**
     * @notice Update both compound rates
     */
    function updateCompoundRates() public override {
        updateCompoundRate();
        updateCompoundRateTimeframe();
    }

    /**
     * @notice Update compound rate and stake tokens to user balance
     * @param _amount Amount to stake
     * @param _isTimeframe If true, stake to timeframe structure
     */
    function updateCompoundAndStake(uint256 _amount, bool _isTimeframe) external override returns (bool) {
        updateCompoundRates();
        return stake(_amount, _isTimeframe);
    }

    /**
     * @notice Update compound rate and withdraw tokens from contract
     * @param _amount Amount to stake
     * @param _isTimeframe If true, withdraw from timeframe structure
     */
    function updateCompoundAndWithdraw(uint256 _amount, bool _isTimeframe) external override returns (bool) {
        updateCompoundRates();
        return withdraw(_amount, _isTimeframe);
    }

    /**
     * @notice Stake tokens to user balance
     * @param _amount Amount to stake
     * @param _isTimeframe If true, stake to timeframe structure
     */
    function stake(uint256 _amount, bool _isTimeframe) public override returns (bool) {
        require(_amount > 0, "[E-11]-Invalid value for the stake amount, failed to stake a zero value.");

        if (_isTimeframe) {
            StakeTimeframe memory _stake = userStakesTimeframe[msg.sender];

            uint256 _newAmount = _getBalance(_stake.normalizedAmount, true).add(_amount);
            uint256 _newNormalizedAmount = _newAmount.mul(10 ** 27).div(compRateKeeperTimeframe.getCurrentRate());

            aggregatedNormalizedStakeTimeframe = aggregatedNormalizedStakeTimeframe.add(_newNormalizedAmount)
            .sub(_stake.normalizedAmount);

            userStakesTimeframe[msg.sender].amount = _stake.amount.add(_amount);
            userStakesTimeframe[msg.sender].normalizedAmount = _newNormalizedAmount;
            userStakesTimeframe[msg.sender].lastStakeTime = block.timestamp;

        } else {
            Stake memory _stake = userStakes[msg.sender];

            uint256 _newAmount = _getBalance(_stake.normalizedAmount, false).add(_amount);
            uint256 _newNormalizedAmount = _newAmount.mul(10 ** 27).div(compRateKeeper.getCurrentRate());

            aggregatedNormalizedStake = aggregatedNormalizedStake.add(_newNormalizedAmount)
            .sub(_stake.normalizedAmount);

            userStakes[msg.sender].amount = _stake.amount.add(_amount);
            userStakes[msg.sender].normalizedAmount = _newNormalizedAmount;
        }

        require(epanToken.transferFrom(msg.sender, address(this), _amount), "[E-12]-Failed to transfer token.");

        return true;
    }

    /**
     * @notice Withdraw tokens from user balance. Only for timeframe stake
     * @param _amount Amount to withdraw
     * @param _isTimeframe If true, withdraws from timeframe structure
     */
    function withdraw(uint256 _amount, bool _isTimeframe) public override returns (bool) {
        uint256 _withdrawAmount = _amount;

        if (_isTimeframe) {
            StakeTimeframe memory _stake = userStakesTimeframe[msg.sender];

            uint256 _userAmount = _getBalance(_stake.normalizedAmount, true);

            require(_userAmount != 0, "[E-31]-The deposit does not exist, failed to withdraw.");
            require(block.timestamp - _stake.lastStakeTime > 180 days, "[E-32]-Funds are not available for withdraw.");

            if (_userAmount < _withdrawAmount) _withdrawAmount = _userAmount;

            uint256 _newAmount = _userAmount.sub(_withdrawAmount);
            uint256 _newNormalizedAmount = _newAmount.mul(10 ** 27).div(compRateKeeperTimeframe.getCurrentRate());

            aggregatedNormalizedStakeTimeframe = aggregatedNormalizedStakeTimeframe.add(_newNormalizedAmount)
            .sub(_stake.normalizedAmount);

            if (_withdrawAmount > _getRewardAmount(_stake.amount, _stake.normalizedAmount, _isTimeframe)) {
                userStakesTimeframe[msg.sender].amount = _newAmount;
            }
            userStakesTimeframe[msg.sender].normalizedAmount = _newNormalizedAmount;

        } else {
            Stake memory _stake = userStakes[msg.sender];

            uint256 _userAmount = _getBalance(_stake.normalizedAmount, false);

            require(_userAmount != 0, "[E-33]-The deposit does not exist, failed to withdraw.");

            if (_userAmount < _withdrawAmount) _withdrawAmount = _userAmount;

            uint256 _newAmount = _getBalance(_stake.normalizedAmount, false).sub(_withdrawAmount);
            uint256 _newNormalizedAmount = _newAmount.mul(10 ** 27).div(compRateKeeper.getCurrentRate());

            aggregatedNormalizedStake = aggregatedNormalizedStake.add(_newNormalizedAmount)
            .sub(_stake.normalizedAmount);

            if (_withdrawAmount > _getRewardAmount(_stake.amount, _stake.normalizedAmount, _isTimeframe)) {
                userStakes[msg.sender].amount = _newAmount;
            }
            userStakes[msg.sender].normalizedAmount = _newNormalizedAmount;
        }

        require(epanToken.transfer(msg.sender, _withdrawAmount), "[E-34]-Failed to transfer token.");

        return true;
    }

    /**
     * @notice Returns the staking balance of the user
     * @param _isTimeframe If true, return balance from timeframe structure
     */
    function getBalance(bool _isTimeframe) public view override returns (uint256) {
        if (_isTimeframe) {
            return _getBalance(userStakesTimeframe[msg.sender].normalizedAmount, true);
        }
        return _getBalance(userStakes[msg.sender].normalizedAmount, false);
    }

    /**
     * @notice Returns the staking balance of the user
     * @param _normalizedAmount User normalized amount
     * @param _isTimeframe If true, return balance from timeframe structure
     */
    function _getBalance(uint256 _normalizedAmount, bool _isTimeframe) private view returns (uint256) {
        if (_isTimeframe) {
            return _normalizedAmount.mul(compRateKeeperTimeframe.getCurrentRate()).div(10 ** 27);
        }
        return _normalizedAmount.mul(compRateKeeper.getCurrentRate()).div(10 ** 27);
    }

    /**
     * @notice Set interest rate
     */
    function setInterestRate(uint256 _newInterestRate) external override onlyOwner {
        require(_newInterestRate <= 158548959918822932522, "[E-202]-Can't be more than 500%.");
        
        updateCompoundRate();
        interestRate = _newInterestRate;
    }

    /**
    * @notice Set interest rate timeframe
    * @param _newInterestRate New interest rate
    */
    function setInterestRateTimeframe(uint256 _newInterestRate) external override onlyOwner {
        require(_newInterestRate <= 158548959918822932522, "[E-211]-Can't be more than 500%.");

        updateCompoundRateTimeframe();
        interestRateTimeframe = _newInterestRate;
    }

    /**
     * @notice Set interest rates
     * @param _newInterestRateTimeframe New interest rate timeframe
     */
    function setInterestRates(uint256 _newInterestRate, uint256 _newInterestRateTimeframe) external override onlyOwner {
        require(_newInterestRate <= 158548959918822932522 && _newInterestRateTimeframe <= 158548959918822932522,
            "[E-221]-Can't be more than 500%.");

        updateCompoundRate();
        updateCompoundRateTimeframe();
        interestRate = _newInterestRate;
        interestRateTimeframe = _newInterestRateTimeframe;
    }

    /**
     * @notice Add tokens to contract address to be spent as rewards
     * @param _amount Token amount that will be added to contract as reward
     */
    function supplyRewardPool(uint256 _amount) external override onlyOwner returns (bool) {
        require(epanToken.transferFrom(msg.sender, address(this), _amount), "[E-231]-Failed to transfer token.");
        return true;
    }

    /**
     * @notice Get reward amount for sender address
     * @param _isTimeframe If timeframe, calculate reward for user from timeframe structure
     */
    function getRewardAmount(bool _isTimeframe) external view override returns (uint256) {
        if (_isTimeframe) {
            StakeTimeframe memory _stake = userStakesTimeframe[msg.sender];
            return _getRewardAmount(_stake.amount, _stake.normalizedAmount, true);
        }

        Stake memory _stake = userStakes[msg.sender];
        return _getRewardAmount(_stake.amount, _stake.normalizedAmount, false);
    }

    /**
     * @notice Get reward amount by params
     * @param _amount Token amount
     * @param _normalizedAmount Normalized token amount
     * @param _isTimeframe If timeframe, calculate reward for user from timeframe structure
     */
    function _getRewardAmount(uint256 _amount, uint256 _normalizedAmount, bool _isTimeframe) private view returns (uint256) {
        uint256 _balance = 0;

        if (_isTimeframe) {
            _balance = _getBalance(_normalizedAmount, _isTimeframe);
        } else {
            _balance = _getBalance(_normalizedAmount, _isTimeframe);
        }

        if (_balance <= _amount) return 0;
        return _balance.sub(_amount);
    }

    /**
     * @notice Get coefficient. Tokens on the contract / total stake + total reward to be paid
     */
    function monitorSecurityMargin() external view override onlyOwner returns (uint256) {
        uint256 _contractBalance = epanToken.balanceOf(address(this));
        uint256 _toReward = aggregatedNormalizedStake.mul(compRateKeeper.getCurrentRate()).div(10 ** 27);
        uint256 _toRewardTimeframe = aggregatedNormalizedStakeTimeframe.mul(compRateKeeperTimeframe.getCurrentRate())
        .div(10 ** 27);

        return _contractBalance.mul(10 ** 27).div(_toReward.add(_toRewardTimeframe));
    }
}