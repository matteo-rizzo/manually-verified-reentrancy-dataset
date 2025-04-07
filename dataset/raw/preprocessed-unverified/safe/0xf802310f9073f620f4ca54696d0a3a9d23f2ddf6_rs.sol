/**
 *Submitted for verification at Etherscan.io on 2021-03-02
*/

// SPDX-License-Identifier: AGPL V3.0

pragma solidity 0.6.12;



// Part: AddressUpgradeable

/**
 * @dev Collection of functions related to the address type
 */


// Part: IERC20Upgradeable

/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
 */


// Part: Initializable

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

// Part: Roles

/**
 * @title Roles
 * @dev Library for managing addresses assigned to a Role.
 */


// Part: SafeMathUpgradeable

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


// Part: ContextUpgradeable

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
abstract contract ContextUpgradeable is Initializable {
    function __Context_init() internal initializer {
        __Context_init_unchained();
    }

    function __Context_init_unchained() internal initializer {
    }
    function _msgSender() internal view virtual returns (address payable) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes memory) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
    uint256[50] private __gap;
}

// Part: SafeERC20Upgradeable

/**
 * @title SafeERC20
 * @dev Wrappers around ERC20 operations that throw on failure (when the token
 * contract returns false). Tokens that return no value (and instead revert or
 * throw on failure) are also supported, non-reverting calls are assumed to be
 * successful.
 * To use this library you can add a `using SafeERC20 for IERC20;` statement to your contract,
 * which allows you to call the safe operations as `token.safeTransfer(...)`, etc.
 */


// Part: MinterRole

contract MinterRole is Initializable, ContextUpgradeable {
    using Roles for Roles.Role;

    event MinterAdded(address indexed account);
    event MinterRemoved(address indexed account);

    Roles.Role private _minters;

    function initialize(address sender) public virtual initializer {
        __Context_init_unchained();
        if (!isMinter(sender)) {
            _addMinter(sender);
        }
    }

    modifier onlyMinter() {
        require(isMinter(_msgSender()), "MinterRole: caller does not have the Minter role");
        _;
    }

    function isMinter(address account) public view returns (bool) {
        return _minters.has(account);
    }

    function addMinter(address account) public onlyMinter {
        _addMinter(account);
    }

    function renounceMinter() public {
        _removeMinter(_msgSender());
    }

    function _addMinter(address account) internal {
        _minters.add(account);
        emit MinterAdded(account);
    }

    function _removeMinter(address account) internal {
        _minters.remove(account);
        emit MinterRemoved(account);
    }

    uint256[50] private ______gap;
}

// Part: OwnableUpgradeable

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
    uint256[49] private __gap;
}

// Part: VestedAkroSenderRole

contract VestedAkroSenderRole is Initializable, ContextUpgradeable {
    using Roles for Roles.Role;

    event SenderAdded(address indexed account);
    event SenderRemoved(address indexed account);

    Roles.Role private _senders;

    function initialize(address sender) public virtual initializer {
        __Context_init_unchained();
        if (!isSender(sender)) {
            _addSender(sender);
        }
    }

    modifier onlySender() {
        require(isSender(_msgSender()), "SenderRole: caller does not have the Sender role");
        _;
    }

    function isSender(address account) public view returns (bool) {
        return _senders.has(account);
    }

    function addSender(address account) public onlySender {
        _addSender(account);
    }

    function renounceSender() public {
        _removeSender(_msgSender());
    }

    function _addSender(address account) internal {
        _senders.add(account);
        emit SenderAdded(account);
    }

    function _removeSender(address account) internal {
        _senders.remove(account);
        emit SenderRemoved(account);
    }

    uint256[50] private ______gap;
}

// File: VestedAkro.sol

/**
 * @notice VestedAkro token represents AKRO token vested for a vestingPeriod set by owner of this VestedAkro token.
 * Generic holders of this token CAN NOT transfer it. They only can redeem AKRO from unlocked vAKRO.
 * Minters can mint unlocked vAKRO from AKRO to special VestedAkroSenders.
 * VestedAkroSender can send his unlocked vAKRO to generic holders, and this vAKRO will be vested. He can not redeem AKRO himself.
 */
contract VestedAkro is OwnableUpgradeable, IERC20Upgradeable, MinterRole, VestedAkroSenderRole {
    using SafeMathUpgradeable for uint256;
    using SafeERC20Upgradeable for IERC20Upgradeable;

    event Locked(address indexed holder, uint256 amount);
    event Unlocked(address indexed holder, uint256 amount);
    event AkroAdded(uint256 amount);

    struct VestedBatch {
        uint256 amount;     // Full amount of vAKRO vested in this batch
        uint256 start;      // Vesting start time;
        uint256 end;        // Vesting end time
        uint256 claimed;    // vAKRO already claimed from this batch to unlocked balance of holder
    }

    struct Balance {
        VestedBatch[] batches;  // Array of vesting batches
        uint256 locked;         // Amount locked in batches
        uint256 unlocked;       // Amount of unlocked vAKRO (which either was previously claimed, or received from Minter)
        uint256 firstUnclaimedBatch; // First batch which is not fully claimed
    }

    string private _name;
    string private _symbol;
    uint8 private _decimals;

    uint256 public override totalSupply;
    IERC20Upgradeable public akro;
    uint256 public vestingPeriod; //set by owner of this VestedAkro token
    uint256 public vestingStart; //set by owner, default value 01 May 2021, 00:00:00 GMT+0
    uint256 public vestingCliff; //set by owner, cliff for akro unlock, 1 month by default
    mapping (address => mapping (address => uint256)) private allowances;
    mapping (address => Balance) private holders;


    function initialize(address _akro, uint256 _vestingPeriod) public initializer {
        __Ownable_init();
        MinterRole.initialize(_msgSender());
        VestedAkroSenderRole.initialize(_msgSender());

        _name = "Vested AKRO";
        _symbol = "vAKRO";
        _decimals = 18;
        
        akro = IERC20Upgradeable(_akro);
        require(_vestingPeriod > 0, "VestedAkro: vestingPeriod should be > 0");
        vestingPeriod = _vestingPeriod;
        vestingStart = 1619827200; //01 May 2021, 00:00:00 GMT+0
        vestingCliff = 31 * 24 * 60 * 60; //1 month - 31 day in May
    }

    // Stub for compiler purposes only
    function initialize(address sender) public override(MinterRole, VestedAkroSenderRole) {
    }

    function name() public view returns (string memory) {
        return _name;
    }

    function symbol() public view returns (string memory) {
        return _symbol;
    }

    function decimals() public view returns (uint8) {
        return _decimals;
    }

    function allowance(address owner, address spender) public override view returns (uint256) {
        return allowances[owner][spender];
    }
    function approve(address spender, uint256 amount) public override returns (bool) {
        _approve(_msgSender(), spender, amount);
        return true;
    }
    function transferFrom(address sender, address recipient, uint256 amount) public override onlySender returns (bool) {
        // We require both sender and _msgSender() to have VestedAkroSender role
        // to prevent sender from redeem and prevent unauthorized transfers via transferFrom.
        require(isSender(sender), "VestedAkro: sender should have VestedAkroSender role");

        _transfer(sender, recipient, amount);
        _approve(sender, _msgSender(), allowances[sender][_msgSender()].sub(amount, "VestedAkro: transfer amount exceeds allowance"));
        return true;
    }

    function transfer(address recipient, uint256 amount) public override onlySender returns (bool) {
        _transfer(_msgSender(), recipient, amount);
        return true;
    }

    function setVestingPeriod(uint256 _vestingPeriod) public onlyOwner {
        require(_vestingPeriod > 0, "VestedAkro: vestingPeriod should be > 0");
        vestingPeriod = _vestingPeriod;
    }

    /**
     * @notice Sets vesting start date (as unix timestamp). Owner only
     * @param _vestingStart Unix timestamp.
     */
    function setVestingStart(uint256 _vestingStart) public onlyOwner {
        require(_vestingStart > 0, "VestedAkro: vestingStart should be > 0");
        vestingStart = _vestingStart;
    }

    /**
     * @notice Sets vesting start date (as unix timestamp). Owner only
     * @param _vestingCliff Cliff in seconds (1 month by default)
     */
    function setVestingCliff(uint256 _vestingCliff) public onlyOwner {
        vestingCliff = _vestingCliff;
    }

    function mint(address beneficiary, uint256 amount) public onlyMinter {
        totalSupply = totalSupply.add(amount);
        holders[beneficiary].unlocked = holders[beneficiary].unlocked.add(amount);
        emit Transfer(address(0), beneficiary, amount);
    }

    /**
     * @notice Adds AKRO liquidity to the swap contract
     * @param _amount Amout of AKRO added to the contract.
     */
    function addAkroLiquidity(uint256 _amount) public onlyMinter {
        require(_amount > 0, "Incorrect amount");
        
        IERC20Upgradeable(akro).safeTransferFrom(_msgSender(), address(this), _amount);
        
        emit AkroAdded(_amount);
    }

    /**
     * @notice Unlocks all avilable vAKRO for a holder
     * @param holder Whose funds to unlock
     * @return total unlocked amount awailable for redeem
     */
    function unlockAvailable(address holder) public returns(uint256) {
        require(holders[holder].batches.length > 0, "VestedAkro: nothing to unlock");
        claimAllFromBatches(holder);
        return holders[holder].unlocked;
    }

    /**
     * @notice Unlock all available vAKRO and redeem it
     * @return Amount redeemed
     */
    function unlockAndRedeemAll() public returns(uint256){
        address beneficiary = _msgSender();
        claimAllFromBatches(beneficiary);
        return redeemAllUnlocked();
    }

    /**
     * @notice Redeem all already unlocked vAKRO
     * @return Amount redeemed
     */
    function redeemAllUnlocked() public returns(uint256){
        address beneficiary = _msgSender();
        require(!isSender(beneficiary), "VestedAkro: VestedAkroSender is not allowed to redeem");
        uint256 amount = holders[beneficiary].unlocked;
        if(amount == 0) return 0;
        require(akro.balanceOf(address(this)) >= amount, "Not enough AKRO");

        holders[beneficiary].unlocked = 0;
        totalSupply = totalSupply.sub(amount);
        akro.transfer(beneficiary, amount);
        emit Transfer(beneficiary, address(0), amount);
        return amount;
    }

    function balanceOf(address account) public override view returns (uint256) {
        Balance storage b = holders[account];
        return b.locked.add(b.unlocked);
    }

    function balanceInfoOf(address account) public view returns(uint256 locked, uint256 unlocked, uint256 unlockable) {
        Balance storage b = holders[account];
        return (b.locked, b.unlocked, calculateClaimableFromBatches(account));
    }

    function batchesInfoOf(address account) public view returns(uint256 firstUnclaimedBatch, uint256 totalBatches) {
        Balance storage b = holders[account];
        return (b.firstUnclaimedBatch, b.batches.length);
    }

    function batchInfo(address account, uint256 batch) public view 
    returns(uint256 amount, uint256 start, uint256 end, uint256 claimed, uint256 claimable) {
        VestedBatch storage vb = holders[account].batches[batch];
        (claimable,) = calculateClaimableFromBatch(vb);
        return (vb.amount, vb.start, vb.end, vb.claimed, claimable);
    }

    function _approve(address owner, address spender, uint256 amount) internal {
        require(owner != address(0), "VestedAkro: approve from the zero address");
        require(spender != address(0), "VestedAkro: approve to the zero address");

        allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    function _transfer(address sender, address recipient, uint256 amount) internal {
        require(sender != address(0), "VestedAkro: transfer from the zero address");
        require(recipient != address(0), "VestedAkro: transfer to the zero address");

        holders[sender].unlocked = holders[sender].unlocked.sub(amount, "VestedAkro: transfer amount exceeds unlocked balance");
        createOrModifyBatch(recipient, amount);

        emit Transfer(sender, recipient, amount);
    }


    function createOrModifyBatch(address holder, uint256 amount) internal {
        Balance storage b = holders[holder];

        if (b.batches.length == 0 || b.firstUnclaimedBatch == b.batches.length) {
            b.batches.push(VestedBatch({
                amount: amount,
                start: vestingStart,
                end: vestingStart.add(vestingPeriod),
                claimed: 0
            }));
        }
        else {
            uint256 batchAmount = b.batches[b.firstUnclaimedBatch].amount;
            b.batches[b.firstUnclaimedBatch].amount = batchAmount.add(amount);
        }
        b.locked = b.locked.add(amount);
        emit Locked(holder, amount);
    }

    function claimAllFromBatches(address holder) internal {
        claimAllFromBatches(holder, holders[holder].batches.length);
    }

    function claimAllFromBatches(address holder, uint256 tillBatch) internal {
        Balance storage b = holders[holder];
        bool firstUnclaimedFound;
        uint256 claiming;
        for(uint256 i = b.firstUnclaimedBatch; i < tillBatch; i++) {
            (uint256 claimable, bool fullyClaimable) = calculateClaimableFromBatch(b.batches[i]);
            if(claimable > 0) {
                b.batches[i].claimed = b.batches[i].claimed.add(claimable);
                claiming = claiming.add(claimable);
            }
            if(!fullyClaimable && !firstUnclaimedFound) {
                b.firstUnclaimedBatch = i;
                firstUnclaimedFound = true;
            }
        }
        if(!firstUnclaimedFound) {
            b.firstUnclaimedBatch = b.batches.length;
        }
        if(claiming > 0){
            b.locked = b.locked.sub(claiming);
            b.unlocked = b.unlocked.add(claiming);
            emit Unlocked(holder, claiming);
        }
    }

    /**
     * @notice Calculates claimable amount from all batches
     * @param holder pointer to a batch
     * @return claimable amount
     */
    function calculateClaimableFromBatches(address holder) internal view returns(uint256) {
        Balance storage b = holders[holder];
        uint256 claiming;
        for(uint256 i = b.firstUnclaimedBatch; i < b.batches.length; i++) {
            (uint256 claimable,) = calculateClaimableFromBatch(b.batches[i]);
            claiming = claiming.add(claimable);
        }
        return claiming;
    }

    /**
     * @notice Calculates one batch
     * @param vb pointer to a batch
     * @return claimable amount and bool which is true if batch is fully claimable
     */
    function calculateClaimableFromBatch(VestedBatch storage vb) internal view returns(uint256, bool) {
        if (now < vb.start.add(vestingCliff) ) {
            return (0, false); // No unlcoks before cliff period is over
        }
        if(now >= vb.end) {
            return (vb.amount.sub(vb.claimed), true);
        }
        uint256 claimable = (vb.amount.mul(now.sub(vb.start)).div(vb.end.sub(vb.start))).sub(vb.claimed);
        return (claimable, false);
    }
}