/**
 *Submitted for verification at Etherscan.io on 2021-04-21
*/

pragma solidity 0.5.16;




/**
 * @dev Collection of functions related to the address type
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



contract Sacrifice {
    constructor(address payable _recipient) public payable {
        selfdestruct(_recipient);
    }
}











/**
 * @title Initializable
 *
 * @dev Helper contract to support initializer functions. To use it, replace
 * the constructor with a function that has the `initializer` modifier.
 * WARNING: Unlike constructors, initializer functions must be manually
 * invoked. This applies both to deploying an Initializable contract, as well
 * as extending an Initializable contract via inheritance.
 * WARNING: When used with inheritance, manual care must be taken to not invoke
 * a parent initializer twice, or ensure that all initializers are idempotent,
 * because this is not dealt with automatically as with constructors.
 */
contract Initializable {

  /**
   * @dev Indicates that the contract has been initialized.
   */
  bool private initialized;

  /**
   * @dev Indicates that the contract is in the process of being initialized.
   */
  bool private initializing;

  /**
   * @dev Modifier to use in the initializer function of a contract.
   */
  modifier initializer() {
    require(initializing || isConstructor() || !initialized, "Contract instance has already been initialized");

    bool isTopLevelCall = !initializing;
    if (isTopLevelCall) {
      initializing = true;
      initialized = true;
    }

    _;

    if (isTopLevelCall) {
      initializing = false;
    }
  }

  /// @dev Returns true if and only if the function is running in the constructor
  function isConstructor() private view returns (bool) {
    // extcodesize checks the size of the code stored in an address, and
    // address returns the current address. Since the code is still not
    // deployed when running a constructor, any checks on its code size will
    // yield zero, making it an effective way to detect if a contract is
    // under construction or not.
    address self = address(this);
    uint256 cs;
    assembly { cs := extcodesize(self) }
    return cs == 0;
  }

  // Reserved storage space to allow for layout changes in the future.
  uint256[50] private ______gap;
}






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
contract Context is Initializable {
    // Empty internal constructor, to prevent people from mistakenly deploying
    // an instance of this contract, which should be used via inheritance.
    constructor () internal { }
    // solhint-disable-previous-line no-empty-blocks

    function _msgSender() internal view returns (address payable) {
        return msg.sender;
    }

    function _msgData() internal view returns (bytes memory) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}


/**
 * @dev Contract module which provides a basic access control mechanism, where
 * there is an account (an owner) that can be granted exclusive access to
 * specific functions.
 *
 * This module is used through inheritance. It will make available the modifier
 * `onlyOwner`, which can be aplied to your functions to restrict their use to
 * the owner.
 */
contract Ownable is Initializable, Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    function initialize(address sender) public initializer {
        _owner = sender;
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
     * > Note: Renouncing ownership will leave the contract without an owner,
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
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }

    uint256[50] private ______gap;
}







/**
 * @dev Interface of the ERC20 standard as defined in the EIP. Does not include
 * the optional functions; to access them see {ERC20Detailed}.
 */





/**
 * @title SafeERC20
 * @dev Wrappers around ERC20 operations that throw on failure (when the token
 * contract returns false). Tokens that return no value (and instead revert or
 * throw on failure) are also supported, non-reverting calls are assumed to be
 * successful.
 * To use this library you can add a `using SafeERC20 for ERC20;` statement to your contract,
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
 */
contract ReentrancyGuard is Initializable {
    // counter to allow mutex lock with only one SSTORE operation
    uint256 private _guardCounter;

    function initialize() public initializer {
        // The counter starts at one to prevent changing it from zero to a non-zero
        // value, which is a more expensive operation.
        _guardCounter = 1;
    }

    /**
     * @dev Prevents a contract from calling itself, directly or indirectly.
     * Calling a `nonReentrant` function from another `nonReentrant`
     * function is not supported. It is possible to prevent this from happening
     * by making the `nonReentrant` function external, and make it call a
     * `private` function that does the actual work.
     */
    modifier nonReentrant() {
        _guardCounter += 1;
        uint256 localCounter = _guardCounter;
        _;
        require(localCounter == _guardCounter, "ReentrancyGuard: reentrant call");
    }

    uint256[50] private ______gap;
}



/**
 * @title EasyStaking
 *
 * Note: all percentage values are between 0 (0%) and 1 (100%)
 * and represented as fixed point numbers containing 18 decimals like with Ether
 * 100% == 1 ether
 */
contract EasyStaking is Ownable, ReentrancyGuard {
    using Address for address;
    using SafeMath for uint256;
    using SafeERC20 for IERC20;


    /**
     * @dev Emitted when a user deposits tokens.
     * @param sender User address.
     * @param id User's unique deposit ID.
     * @param amount The amount of deposited tokens.
     * @param balance Current user balance.
     * @param accruedEmission User's accrued emission.
     * @param prevDepositDuration Duration of the previous deposit in seconds.
     */
    event Deposited(
        address indexed sender,
        uint256 indexed id,
        uint256 amount,
        uint256 balance,
        uint256 accruedEmission,
        uint256 prevDepositDuration
    );


    /**
     * @dev Emitted when a user withdraws tokens.
     * @param sender User address.
     * @param id User's unique deposit ID.
     * @param amount The amount of withdrawn tokens.
     * @param balance Current user balance.
     * @param accruedEmission User's accrued emission.
     * @param lastDepositDuration Duration of the last deposit in seconds.
     */
    event Withdrawn(
        address indexed sender,
        uint256 indexed id,
        uint256 amount,
        uint256 balance,
        uint256 accruedEmission,
        uint256 lastDepositDuration
    );

    /**
     * @dev Emitted when a user withdraws Reward tokens.
     * @param sender User address.
     * @param id User's unique deposit ID.
     * @param rewardAmount The amount of withdrawn tokens.
     * @param claimedRewards The amount of already claimed rewards.
     */
    event WithdrawnRewards(
        address indexed sender,
        uint256 indexed id,
        uint256 rewardAmount,
        uint256 claimedRewards
    );
    

    /**
     * @dev Emitted when a new Liquidity Provider address value is set.
     * @param value A new address value.
     * @param sender The owner address at the moment of address changing.
     */
    event LiquidityProviderAddressSet(address value, address sender);

    uint256 private constant YEAR = 365 days;
    // The maximum emission rate (in percentage)
    uint256 public constant MAX_EMISSION_RATE = 150 finney; // 15%, 0.15 ether
    // The period after which the new value of the parameter is set
    uint256 public constant PARAM_UPDATE_DELAY = 7 days;

    // STAKE token
    IERC20Mintable public token;
    
    // Reward Token
    IERC20Mintable public tokenReward;
    
    
    struct UintParam {
        uint256 oldValue;
        uint256 newValue;
        uint256 timestamp;
    }

    struct AddressParam {
        address oldValue;
        address newValue;
        uint256 timestamp;
    }


    // The address for the Liquidity Providers 
    AddressParam public liquidityProviderAddressParam;

    // The deposit balances of users
    mapping (address => mapping (uint256 => uint256)) public balances;
    // The dates of users' deposits
    mapping (address => mapping (uint256 => uint256)) public depositDates;
    // The last deposit id
    mapping (address => uint256) public lastDepositIds;
    // Rewards tokens sum 
    mapping (address => mapping (uint256 => uint256)) public claimedRewards;
    // To claim rewards tokens sum
    mapping (address => mapping (uint256 => uint256)) public toClaimRewards;
    // The total staked amount
    uint256 public totalStaked;

    // Variable that prevents _deposit method from being called 2 times
    bool private locked;
    // The library that is used to calculate user's current emission rate


    /**
     * @dev Initializes the contract.
     * @param _owner The owner of the contract.
     * @param _tokenAddress The address of the STAKE token contract.
     * @param _liquidityProviderAddress The address for the Liquidity Providers reward.
     */
    function initialize(
        address _owner,
        address _tokenAddress,
        address _tokenReward,
        address _liquidityProviderAddress
    ) external initializer {
        require(_owner != address(0), "zero address");
        require(_tokenAddress.isContract(), "not a contract address");
        Ownable.initialize(msg.sender);
        ReentrancyGuard.initialize();
        token = IERC20Mintable(_tokenAddress);
        tokenReward = IERC20Mintable(_tokenReward);
        setLiquidityProviderAddress(_liquidityProviderAddress);
        Ownable.transferOwnership(_owner);
    }


    /**
     * @dev This method is used to deposit tokens to the deposit opened before.
     * It calls the internal "_deposit" method and transfers tokens from sender to contract.
     * Sender must approve tokens first.
     *
     * Instead this, user can use the simple "transfer" method of STAKE token contract to make a deposit.
     * Sender's approval is not needed in this case.
     *
     * Note: each call updates the deposit date so be careful if you want to make a long staking.
     *
     * @param _depositId User's unique deposit ID.
     * @param _amount The amount to deposit.
     */
    function deposit(uint256 _depositId, uint256 _amount) public {
        require (_depositId <=4 );
        lastDepositIds[msg.sender]=3;
        _deposit(msg.sender, _depositId, _amount);
        _setLocked(true);
        require(token.transferFrom(msg.sender, address(this), _amount), "transfer failed");
        _setLocked(false);
    }

 
    /**
     * @dev This method is used to make a withdrawal.
     * It calls the internal "_withdraw" method.
     * @param _depositId User's unique deposit ID
     * @param _amount The amount to withdraw (0 - to withdraw all).
     */
    function makeWithdrawal(uint256 _depositId, uint256 _amount) external {
        uint256 requestDate = depositDates[msg.sender][_depositId];
        uint256 timestamp = _now();
        uint256 lockEnd = 0;
        if (_depositId==1) {
            lockEnd=60;
        } else if (_depositId==2) {
            lockEnd=60*60*24*30*3; // 3 months
        } else {
            lockEnd=60*60*24*30*6; // 6 months
        }
        require(timestamp >= requestDate+lockEnd, "too early. Lockup period");
        _withdraw(msg.sender, _depositId, _amount);
    }

    /**
     * @dev This method is used to make a Rewards withdrawal.
     * It calls the internal "_withdraw" method.
     * @param _depositId User's unique deposit ID
     */
    function makeWithdrawalRewards(uint256 _depositId) external {
        _withdrawRewards(msg.sender, _depositId);
    }


    /**
     * @dev This method is used to claim unsupported tokens accidentally sent to the contract.
     * It can only be called by the owner.
     * @param _token The address of the token contract (zero address for claiming native coins).
     * @param _to The address of the tokens/coins receiver.
     * @param _amount Amount to claim.
     */
    function claimTokens(address _token, address payable _to, uint256 _amount) external onlyOwner {
        require(_to != address(0) && _to != address(this), "not a valid recipient");
        require(_amount > 0, "amount should be greater than 0");
        if (_token == address(0)) {
            if (!_to.send(_amount)) { // solium-disable-line security/no-send
                (new Sacrifice).value(_amount)(_to);
            }
        } else if (_token == address(token)) {
            uint256 availableAmount = token.balanceOf(address(this)).sub(totalStaked);
            require(availableAmount >= _amount, "insufficient funds");
            require(token.transfer(_to, _amount), "transfer failed");
        } else {
            IERC20 customToken = IERC20(_token);
            customToken.safeTransfer(_to, _amount);
        }
    }


    /**
     * @dev Sets the address for the Liquidity Providers reward.
     * Can only be called by owner.
     * @param _address The new address.
     */
    function setLiquidityProviderAddress(address _address) public onlyOwner {
        require(_address != address(0), "zero address");
        require(_address != address(this), "wrong address");
        AddressParam memory param = liquidityProviderAddressParam;
        if (param.timestamp == 0) {
            param.oldValue = _address;
        } else if (_paramUpdateDelayElapsed(param.timestamp)) {
            param.oldValue = param.newValue;
        }
        param.newValue = _address;
        param.timestamp = _now();
        liquidityProviderAddressParam = param;
        emit LiquidityProviderAddressSet(_address, msg.sender);
    }
    
    /**
     * @param _depositDate Deposit date.
     * @param _amount Amount based on which emission is calculated and accrued.
     * @return Total accrued emission user share, and seconds passed since the previous deposit started.
     */
    function getAccruedEmission(
        uint256 _depositDate,
        uint256 _amount,
        uint256 stakeType
    ) public view returns (uint256 userShare, uint256 timePassed) {
        if (_amount == 0 || _depositDate == 0) return (0, 0);
        timePassed = _now().sub(_depositDate);
        if (timePassed == 0) return (0, 0);
        
        uint256 stakeRate = 0 finney; 
        
        if (stakeType==1) {
            stakeRate = 50 finney; //5%
        } else if (stakeType==2) {
            stakeRate = 100 finney; //10%
        } else if (stakeType==3) {
            stakeRate = 150 finney; //15%
        }
        userShare = _amount.mul(stakeRate).mul(timePassed).div(YEAR * 1 ether);
    }


    /**
     * @dev Calls internal "_mint" method, increases the user balance, and updates the deposit date.
     * @param _sender The address of the sender.
     * @param _id User's unique deposit ID.
     * @param _amount The amount to deposit.
     */
    function _deposit(address _sender, uint256 _id, uint256 _amount) internal nonReentrant {
        require(_amount > 0, "deposit amount should be more than 0");
        //(uint256 sigmoidParamA,,) = getSigmoidParameters();
        //if (sigmoidParamA == 0 && totalSupplyFactor() == 0) revert("emission stopped");
        // new deposit, calculate interests
        (uint256 userShare, uint256 timePassed) = _calcRewards(_sender, _id, 0);
        uint256 newBalance = balances[_sender][_id].add(_amount);
        balances[_sender][_id] = newBalance;
        totalStaked = totalStaked.add(_amount);
        depositDates[_sender][_id] = _now();
        emit Deposited(_sender, _id, _amount, newBalance, userShare, timePassed);
    }

    /**
     * @dev Calls internal "_mint" method and then transfers tokens to the sender.
     * @param _sender The address of the sender.
     * @param _id User's unique deposit ID.
     * @param _amount The amount to withdraw (0 - to withdraw all).
     */
    function _withdraw(address _sender, uint256 _id, uint256 _amount) internal nonReentrant {
        require(_id > 0, "wrong deposit id");
        require(balances[_sender][_id] > 0 && balances[_sender][_id] >= _amount, "insufficient funds");
        uint256 amount = _amount == 0 ? balances[_sender][_id] : _amount;
        require(token.transfer(_sender, amount), "transfer failed");

        (uint256 accruedEmission, uint256 timePassed) = _calcRewards(_sender, _id, amount);
        balances[_sender][_id] = balances[_sender][_id].sub(amount);
        totalStaked = totalStaked.sub(amount);
        if (balances[_sender][_id] == 0) {
            depositDates[_sender][_id] = 0;
        }
        emit Withdrawn(_sender, _id, _amount, balances[_sender][_id], accruedEmission, timePassed);
    }

    /**
     * @dev Calls internal "_mint" method and then transfers tokens to the sender.
     * @param _sender The address of the sender.
     * @param _id User's unique deposit ID.
     */
    function _withdrawRewards(address _sender, uint256 _id) internal nonReentrant {
        require(_id > 0, "wrong deposit id");
        (uint256 userShare, uint256 timePassed) = _calcRewards(_sender, _id, 0);
        uint256 toClaim=0;
        if (toClaimRewards[_sender][_id] < claimedRewards[_sender][_id]) {
            toClaim = 0;
        } else {
            toClaim = toClaimRewards[_sender][_id].sub(claimedRewards[_sender][_id]);
        }
        require(toClaim > 0, "nothing to claim");
        claimedRewards[_sender][_id]=claimedRewards[_sender][_id].add(toClaimRewards[_sender][_id]); 
        require(tokenReward.transferFrom(liquidityProviderAddress(),_sender, toClaim), "Liquidity pool transfer failed");
        emit WithdrawnRewards(
        _sender,
        _id,
        toClaim,
        claimedRewards[_sender][_id]);
    }
    

    /**
     * @dev Calculate MAX_EMISSION_RATE per annum and distributes.
     * @param _user User's address.
     * @param _id User's unique deposit ID.
     * @param _amount Amount based on which emission is calculated and accrued. When 0, current deposit balance is used.
     */
    function _calcRewards(address _user, uint256 _id, uint256 _amount) internal returns (uint256, uint256) {
        uint256 currentBalance = balances[_user][_id]; 
        uint256 amount = _amount == 0 ? currentBalance : _amount;
        (uint256 accruedEmission, uint256 timePassed) = getAccruedEmission(depositDates[_user][_id], amount,_id);
        toClaimRewards[_user][_id]=toClaimRewards[_user][_id].add(accruedEmission);
        return (accruedEmission, timePassed);
    }

    /**
     * @dev Sets the next value of the parameter and the timestamp of this setting.
     */
    function _updateUintParam(UintParam storage _param, uint256 _newValue) internal {
        if (_param.timestamp == 0) {
            _param.oldValue = _newValue;
        } else if (_paramUpdateDelayElapsed(_param.timestamp)) {
            _param.oldValue = _param.newValue;
        }
        _param.newValue = _newValue;
        _param.timestamp = _now();
    }

    /**
     * @return Returns current liquidity providers reward address.
     */
    function liquidityProviderAddress() public view returns (address) {
        AddressParam memory param = liquidityProviderAddressParam;
        return param.newValue;
    }
    
    /**
     * @return Returns the current value of the parameter.
     */
    function _getUintParamValue(UintParam memory _param) internal view returns (uint256) {
        return _paramUpdateDelayElapsed(_param.timestamp) ? _param.newValue : _param.oldValue;
    }

    /**
     * @return Returns true if param update delay elapsed.
     */
    function _paramUpdateDelayElapsed(uint256 _paramTimestamp) internal view returns (bool) {
        return _now() > _paramTimestamp.add(PARAM_UPDATE_DELAY);
    }

    /**
     * @dev Sets lock to prevent reentrance.
     */
    function _setLocked(bool _locked) internal {
        locked = _locked;
    }

    /**
     * @return Returns current timestamp.
     */
    function _now() internal view returns (uint256) {
        // Note that the timestamp can have a 900-second error:
        // https://github.com/ethereum/wiki/blob/c02254611f218f43cbb07517ca8e5d00fd6d6d75/Block-Protocol-2.0.md
        return now; // solium-disable-line security/no-block-members
    }
}