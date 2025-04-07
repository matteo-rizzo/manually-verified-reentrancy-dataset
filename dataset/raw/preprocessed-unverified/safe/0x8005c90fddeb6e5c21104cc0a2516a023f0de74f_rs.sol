/**
 *Submitted for verification at Etherscan.io on 2021-07-27
*/

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

/**
 * @dev This is a base contract to aid in writing upgradeable contracts, or any kind of contract that will be deployed
 * behind a proxy. Since a proxied contract can't have a constructor, it's common to move constructor logic to an
 * external initializer function, usually called `initialize`. It then becomes necessary to protect this initializer
 * function so it can only be called once. The {initializer} modifier provided by this contract will have this effect.
 *
 * TIP: To avoid leaving the proxy in an uninitialized state, the initializer function should be called as early as
 * possible by providing the encoded function call as the `_data` argument to {ERC1967Proxy-constructor}.
 *
 * CAUTION: When used with inheritance, manual care must be taken to not invoke a parent initializer twice, or to ensure
 * that all initializers are idempotent. This is not verified automatically as constructors are by Solidity.
 */
abstract contract Initializable {
    /**
     * @dev Indicates that the contract has been initialized.
     */
    bool private _initialized;

    /**
     * @dev Indicates that the contract is in the process of being initialized.
     */
    bool private _initializing;

    /**
     * @dev Modifier to protect an initializer function from being invoked twice.
     */
    modifier initializer() {
        require(_initializing || !_initialized, "Initializable: contract is already initialized");

        bool isTopLevelCall = !_initializing;
        if (isTopLevelCall) {
            _initializing = true;
            _initialized = true;
        }

        _;

        if (isTopLevelCall) {
            _initializing = false;
        }
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
abstract contract ContextUpgradeable is Initializable {
    function __Context_init() internal initializer {
        __Context_init_unchained();
    }

    function __Context_init_unchained() internal initializer {
    }
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
    uint256[50] private __gap;
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
abstract contract OwnableUpgradeable is Initializable, ContextUpgradeable {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    function __Ownable_init() internal initializer {
        __Context_init_unchained();
        __Ownable_init_unchained();
    }

    function __Ownable_init_unchained() internal initializer {
        _setOwner(_msgSender());
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
        _setOwner(address(0));
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        _setOwner(newOwner);
    }

    function _setOwner(address newOwner) private {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
    uint256[49] private __gap;
}









/**
 * @dev Contract module which allows children to implement an emergency stop
 * mechanism that can be triggered by an authorized account.
 *
 * This module is used through inheritance. It will make available the
 * modifiers `whenNotPaused` and `whenPaused`, which can be applied to
 * the functions of your contract. Note that they will not be pausable by
 * simply including this module, only once the modifiers are put in place.
 */
abstract contract PausableUpgradeable is Initializable, ContextUpgradeable {
    /**
     * @dev Emitted when the pause is triggered by `account`.
     */
    event Paused(address account);

    /**
     * @dev Emitted when the pause is lifted by `account`.
     */
    event Unpaused(address account);

    bool private _paused;

    /**
     * @dev Initializes the contract in unpaused state.
     */
    function __Pausable_init() internal initializer {
        __Context_init_unchained();
        __Pausable_init_unchained();
    }

    function __Pausable_init_unchained() internal initializer {
        _paused = false;
    }

    /**
     * @dev Returns true if the contract is paused, and false otherwise.
     */
    function paused() public view virtual returns (bool) {
        return _paused;
    }

    /**
     * @dev Modifier to make a function callable only when the contract is not paused.
     *
     * Requirements:
     *
     * - The contract must not be paused.
     */
    modifier whenNotPaused() {
        require(!paused(), "Pausable: paused");
        _;
    }

    /**
     * @dev Modifier to make a function callable only when the contract is paused.
     *
     * Requirements:
     *
     * - The contract must be paused.
     */
    modifier whenPaused() {
        require(paused(), "Pausable: not paused");
        _;
    }

    /**
     * @dev Triggers stopped state.
     *
     * Requirements:
     *
     * - The contract must not be paused.
     */
    function _pause() internal virtual whenNotPaused {
        _paused = true;
        emit Paused(_msgSender());
    }

    /**
     * @dev Returns to normal state.
     *
     * Requirements:
     *
     * - The contract must be paused.
     */
    function _unpause() internal virtual whenPaused {
        _paused = false;
        emit Unpaused(_msgSender());
    }
    uint256[49] private __gap;
}




 abstract contract PureFiPaymentPlan is Initializable, OwnableUpgradeable, PausableUpgradeable {

  using SafeERC20Upgradeable for IERC20Upgradeable;

  struct Vesting{
    uint8 paymentPlan; //payment plan ID
    uint64 startDate; //payment plan initiation date. Can be 0 if PaymentPlan refers to exact unlock timestamps.
    uint256 totalAmount; //total amount of tokens vested for a person
    uint256 withdrawnAmount; //amount withdrawn by user
  }

  mapping (address => Vesting) internal vestedTokens;

  IERC20Upgradeable public token;
  uint256 public totalVestedAmount; // total amount of vested tokens under this contract control.
  address public farmingContract;
  uint8 public farmingContractPool;

  event Withdrawal(address indexed who, uint256 amount);
  event PaymentPlanAdded(uint256 index);
  event TokensVested(address indexed beneficiary, uint8 paymentPlan, uint64 startDate, uint256 amount);
  
  function initialize(
        address _token
    ) public initializer {
        __Ownable_init();
        __Pausable_init_unchained();

       require(_token != address(0),"incorrect token address");
       token = IERC20Upgradeable(_token);
    }

  function pause() onlyOwner public {
      super._pause();
  }
   
  function unpause() onlyOwner public {
      super._unpause();
  }

  function setFarmingContract(address _farmingContract, uint8 _farmingContractPool) onlyOwner public {
    farmingContract = _farmingContract;
    farmingContractPool = _farmingContractPool;
  }

  function vestTokens(uint8 _paymentPlan, uint64 _startDate, uint256 _amount, address _beneficiary) public onlyOwner whenNotPaused{
    require(vestedTokens[_beneficiary].totalAmount == 0, "This address already has vested tokens");
    require(_isPaymentPlanExists(_paymentPlan), "Incorrect payment plan index");
    require(_amount > 0, "Can't vest 0 tokens");
    require(token.balanceOf(address(this)) >= totalVestedAmount + _amount, "Not enough tokens for this vesting plan");
    vestedTokens[_beneficiary] = Vesting(_paymentPlan, _startDate, _amount, 0);
    totalVestedAmount += _amount;
    emit TokensVested(_beneficiary, _paymentPlan, _startDate, _amount);
  }

  function withdrawAvailableTokens() public whenNotPaused {
    (, uint256 available) = withdrawableAmount(msg.sender);
    _prepareWithdraw(available);
    token.safeTransfer(msg.sender, available);
  }

  function withdrawAndStakeAvailableTokens() public whenNotPaused {
    require(farmingContract != address(0),"Farming contract is not defined");
    (, uint256 available) = withdrawableAmount(msg.sender);
    _prepareWithdraw(available);
    //stake on farming contract instead of withdrawal
    token.safeApprove(farmingContract, available);
    IPureFiFarming(farmingContract).depositTo(farmingContractPool, available, msg.sender);
  }

  function withdraw(uint256 _amount) public whenNotPaused {
    _prepareWithdraw(_amount);
    token.safeTransfer(msg.sender, _amount);
  }

  function withdrawAndStake(uint256 _amount) public whenNotPaused{
    require(farmingContract != address(0),"Farming contract is not defined");
    _prepareWithdraw(_amount);
    //stake on farming contract instead of withdrawal
    token.safeApprove(farmingContract, _amount);
    IPureFiFarming(farmingContract).depositTo(farmingContractPool, _amount, msg.sender);
  }

  function _prepareWithdraw(uint256 _amount) private {
    require(vestedTokens[msg.sender].totalAmount > 0,"No tokens vested for this address");
    (, uint256 available) = withdrawableAmount(msg.sender);
    require(_amount <= available, "Amount exeeded current withdrawable amount");
    require(available > 0, "Nothing to withdraw");
    vestedTokens[msg.sender].withdrawnAmount += _amount;
    totalVestedAmount -= _amount;
    emit Withdrawal(msg.sender, _amount);
  } 
  
  /**
  * @param _beneficiary - address of the user who has his/her tokens vested on the contract
  * returns:
  * 0. next payout date for the user (0 if tokens are fully paid out)
  * 1. amount of tokens that user can withdraw as of now
  */
  function withdrawableAmount(address _beneficiary) public virtual view returns (uint64, uint256);

  /**
  * @param _beneficiary - address of the user who has his/her tokens vested on the contract
  * returns:
  * 0. payment plan ID
  * 1. vesting start date. no claims before start date allowed
  * 2. next unlock date. the date user can claim more tokens
  * 3. total amount of tokens vested
  * 4. withdrawn tokens amount (already claimed tokens, essentially) 
  * 5. amount of tokens that user can withdraw as of now
  */
  function vestingData(address _beneficiary) public view returns (uint8, uint64, uint64, uint256, uint256, uint256) {
    (uint64 nextUnlockDate, uint256 available) = withdrawableAmount(_beneficiary);
    return (vestedTokens[_beneficiary].paymentPlan, vestedTokens[_beneficiary].startDate, nextUnlockDate, vestedTokens[_beneficiary].totalAmount, vestedTokens[_beneficiary].withdrawnAmount, available);
  }

  function _isPaymentPlanExists(uint8 _id) internal virtual view returns (bool);

}

contract PureFiLinearPaymentPlan is PureFiPaymentPlan {

  struct PaymentPlan{
    uint64 cliff;
    uint64 period;
    uint64 initiallyUnlockedPercent;
    uint64 periodPayoutPercent; 
  }

  PaymentPlan[] internal paymentPlans;
  
  uint256 public constant PERCENT_100 = 100_000000; // 100% with extra denominator

  function addPaymentPlan(uint64 _cliff, uint64 _period, uint64 _initialPayoutPercent, uint64 _periodPayoutPercent) public onlyOwner whenNotPaused {
    require(_periodPayoutPercent > 0, "Incorrect _periodPayoutPercent");
    require(_period > 0, "Incorrect _period");
    paymentPlans.push(PaymentPlan(_cliff, _period, _initialPayoutPercent, _periodPayoutPercent));

    emit PaymentPlanAdded(paymentPlans.length - 1);
  }

  function withdrawableAmount(address _beneficiary) public override view returns (uint64, uint256) {
    require(vestedTokens[_beneficiary].totalAmount > 0,"No tokens vested for this address");
    uint64 paymentPlanStartDate = vestedTokens[_beneficiary].startDate;
    uint64 userCliff = paymentPlans[vestedTokens[_beneficiary].paymentPlan].cliff;

    uint256 unlockedPercent;
    uint64 nextUnlockDate;
    if(block.timestamp < paymentPlanStartDate){
      unlockedPercent = 0;
      nextUnlockDate = paymentPlanStartDate;
    } else if(block.timestamp >= paymentPlanStartDate && block.timestamp < paymentPlanStartDate + userCliff){
      unlockedPercent = paymentPlans[vestedTokens[_beneficiary].paymentPlan].initiallyUnlockedPercent;
      nextUnlockDate = paymentPlanStartDate + userCliff;
    } else {
      unlockedPercent = paymentPlans[vestedTokens[_beneficiary].paymentPlan].initiallyUnlockedPercent;
      uint256 multiplier = (block.timestamp - userCliff - paymentPlanStartDate) / paymentPlans[vestedTokens[_beneficiary].paymentPlan].period;
      unlockedPercent += multiplier * paymentPlans[vestedTokens[_beneficiary].paymentPlan].periodPayoutPercent; 
      if(unlockedPercent > PERCENT_100){
        unlockedPercent = PERCENT_100;
        nextUnlockDate = 0;
      }else{
        nextUnlockDate = paymentPlanStartDate + userCliff + uint64(multiplier + 1) * paymentPlans[vestedTokens[_beneficiary].paymentPlan].period;
      }
    }

    uint256 amountUnlocked = vestedTokens[_beneficiary].totalAmount * unlockedPercent / PERCENT_100;

    uint256 available = 0;
    if (vestedTokens[_beneficiary].withdrawnAmount < amountUnlocked){
      available = amountUnlocked - vestedTokens[_beneficiary].withdrawnAmount;
    } else {
      //overflow
      available = 0;
    }

    return (nextUnlockDate, available);
  }

  function paymentPlanData(uint256 _paymentPlan) public view returns (uint64, uint64, uint64, uint64){
    return (paymentPlans[_paymentPlan].cliff,
            paymentPlans[_paymentPlan].period,
            paymentPlans[_paymentPlan].initiallyUnlockedPercent,
            paymentPlans[_paymentPlan].periodPayoutPercent);
  }

  function _isPaymentPlanExists(uint8 _id) internal override view returns (bool){
    return (_id < paymentPlans.length);
  }
}