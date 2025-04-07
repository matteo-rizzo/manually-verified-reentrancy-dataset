/**
 *Submitted for verification at Etherscan.io on 2021-09-30
*/

pragma solidity 0.5.16;

// INTERFACE


/**
 * @dev Interface of the ERC20 standard as defined in the EIP. Does not include
 * the optional functions; to access them see {ERC20Detailed}.
 */


// LIB

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
 * @title SafeERC20
 * @dev Wrappers around ERC20 operations that throw on failure (when the token
 * contract returns false). Tokens that return no value (and instead revert or
 * throw on failure) are also supported, non-reverting calls are assumed to be
 * successful.
 * To use this library you can add a `using SafeERC20 for ERC20;` statement to your contract,
 * which allows you to call the safe operations as `token.safeTransfer(...)`, etc.
 */


/**
 * Smart contract library of mathematical functions operating with signed
 * 64.64-bit fixed point numbers.  Signed 64.64-bit fixed point number is
 * basically a simple fraction whose numerator is signed 128-bit integer and
 * denominator is 2^64.  As long as denominator is always the same, there is no
 * need to store it, thus in Solidity signed 64.64-bit fixed point numbers are
 * represented by int128 type holding only the numerator.
 */


/**
 * Smart contract library of mathematical functions operating with IEEE 754
 * quadruple-precision binary floating-point numbers (quadruple precision
 * numbers).  As long as quadruple precision numbers are 16-bytes long, they are
 * represented by bytes16 type.
 */



// CONTRACTS

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
        require(
            initializing || isConstructor() || !initialized,
            "Contract instance has already been initialized"
        );

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
        assembly {
            cs := extcodesize(self)
        }
        return cs == 0;
    }

    // Reserved storage space to allow for layout changes in the future.
    uint256[50] private ______gap;
}

contract Sacrifice {
    constructor(address payable _recipient) public payable {
        selfdestruct(_recipient);
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


// ----------------------------------------------------------------------------
// ERC Token Standard #20 Interface
// ----------------------------------------------------------------------------
contract ERC20Interface {
    function totalSupply() public view returns (uint256);

    function balanceOf(address tokenOwner) public view returns (uint256 balance);

    function allowance(address tokenOwner, address spender) public view returns (uint256 remaining);

    function transfer(address to, uint256 tokens) public returns (bool success);

    function approve(address spender, uint256 tokens) public returns (bool success);

    function transferFrom(
        address from,
        address to,
        uint256 tokens
    ) public returns (bool success);

    event Transfer(address indexed from, address indexed to, uint256 tokens);
    event Approval(address indexed tokenOwner, address indexed spender, uint256 tokens);
}

// ----------------------------------------------------------------------------
// Safe Math Library
// ----------------------------------------------------------------------------

contract SafeMathERC20 {
    function safeAdd(uint256 a, uint256 b) public pure returns (uint256 c) {
        c = a + b;
        require(c >= a);
    }

    function safeSub(uint256 a, uint256 b) public pure returns (uint256 c) {
        require(b <= a);
        c = a - b;
    }

    function safeMul(uint256 a, uint256 b) public pure returns (uint256 c) {
        c = a * b;
        require(a == 0 || c / a == b);
    }

    function safeDiv(uint256 a, uint256 b) public pure returns (uint256 c) {
        require(b > 0);
        c = a / b;
    }
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
    constructor() internal {}

    // solhint-disable-previous-line no-empty-blocks

    function _msgSender() internal view returns (address payable) {
        return msg.sender;
    }

    function _msgData() internal view returns (bytes memory) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
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


/**
 * @dev Contract module which provides a basic access control mechanism, where
 * there is an account (an owner) that can be granted exclusive access to
 * specific functions.
 *
 * This module is used through inheritance. It will make available the modifier
 * `onlyOwner`, which can be applied to your functions to restrict their use to
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

contract StakingV2 is Ownable, ReentrancyGuard {
    using Address for address;
    using SafeMath for uint256;
    using SafeERC20 for IERC20;

    // EVENTS

    /**
     * @dev Emitted when a user deposits tokens.
     * @param sender User address.
     * @param id User's unique deposit ID.
     * @param amount The amount of deposited tokens.
     * @param currentBalance Current user balance.
     * @param timestamp Operation date
     */
    event Deposited(
        address indexed sender,
        uint256 indexed id,
        uint256 amount,
        uint256 currentBalance,
        uint256 timestamp
    );

    /**
     * @dev Emitted when a user withdraws tokens.
     * @param sender User address.
     * @param id User's unique deposit ID.
     * @param totalWithdrawalAmount The total amount of withdrawn tokens.
     * @param currentBalance Balance before withdrawal
     * @param timestamp Operation date
     */
    event WithdrawnAll(
        address indexed sender,
        uint256 indexed id,
        uint256 totalWithdrawalAmount,
        uint256 currentBalance,
        uint256 timestamp
    );

    /**
     * @dev Emitted when a user extends lockup.
     * @param sender User address.
     * @param id User's unique deposit ID.
     * @param currentBalance Balance before lockup extension
     * @param finalBalance Final balance
     * @param timestamp The instant when the lockup is extended.
     */
    event ExtendedLockup(
        address indexed sender,
        uint256 indexed id,
        uint256 currentBalance,
        uint256 finalBalance,
        uint256 timestamp
    );

    /**
     * @dev Emitted when a new Liquidity Provider address value is set.
     * @param value A new address value.
     * @param sender The owner address at the moment of address changing.
     */
    event LiquidityProviderAddressSet(address value, address sender);

    struct AddressParam {
        address oldValue;
        address newValue;
        uint256 timestamp;
    }

    // The deposit user balaces
    mapping(address => mapping(uint256 => uint256)) public balances;
    // The dates of users deposits/withdraws/extendLockups
    mapping(address => mapping(uint256 => uint256)) public depositDates;

    // Variable that prevents _deposit method from being called 2 times TODO CHECK
    bool private locked;

    // Variable to pause all operations
    bool private contractPaused = false;

    bool private pausedDepositsAndLockupExtensions = false;

    // STAKE token
    IERC20Mintable public token;
    // Reward Token
    IERC20Mintable public tokenReward;

    // The address for the Liquidity Providers
    AddressParam public liquidityProviderAddressParam;

    uint256 private constant DAY = 1 days;
    uint256 private constant MONTH = 30 days;
    uint256 private constant YEAR = 365 days;

    // The period after which the new value of the parameter is set
    uint256 public constant PARAM_UPDATE_DELAY = 7 days;

    // MODIFIERS

    /*
     *      1   |     2    |     3    |     4    |     5
     * 0 Months | 3 Months | 6 Months | 9 Months | 12 Months
     */
    modifier validDepositId(uint256 _depositId) {
        require(_depositId >= 1 && _depositId <= 5, "Invalid depositId");
        _;
    }

    // Impossible to withdrawAll if you have never deposited.
    modifier balanceExists(uint256 _depositId) {
        require(balances[msg.sender][_depositId] > 0, "Your deposit is zero");
        _;
    }

    modifier isNotLocked() {
        require(locked == false, "Locked, try again later");
        _;
    }

    modifier isNotPaused() {
        require(contractPaused == false, "Paused");
        _;
    }

    modifier isNotPausedOperations() {
        require(contractPaused == false, "Paused");
        _;
    }

    modifier isNotPausedDepositAndLockupExtensions() {
        require(pausedDepositsAndLockupExtensions == false, "Paused Deposits and Extensions");
        _;
    }

    /**
     * @dev Pause Deposits, Withdraw, Lockup Extension
     */
    function pauseContract(bool value) public onlyOwner {
        contractPaused = value;
    }

    /**
     * @dev Pause Deposits and Lockup Extension
     */
    function pauseDepositAndLockupExtensions(bool value) public onlyOwner {
        pausedDepositsAndLockupExtensions = value;
    }

    /**
     * @dev Initializes the contract. _tokenAddress _tokenReward will have the same address
     * @param _owner The owner of the contract.
     * @param _tokenAddress The address of the STAKE token contract.
     * @param _tokenReward The address of token rewards.
     * @param _liquidityProviderAddress The address for the Liquidity Providers reward.
     */
    function initializeStaking(
        address _owner,
        address _tokenAddress,
        address _tokenReward,
        address _liquidityProviderAddress
    ) external initializer {
        require(_owner != address(0), "Zero address");
        require(_tokenAddress.isContract(), "Not a contract address");
        Ownable.initialize(msg.sender);
        ReentrancyGuard.initialize();
        token = IERC20Mintable(_tokenAddress);
        tokenReward = IERC20Mintable(_tokenReward);
        setLiquidityProviderAddress(_liquidityProviderAddress);
        Ownable.transferOwnership(_owner);
    }

    /**
     * @dev Sets the address for the Liquidity Providers reward.
     * Can only be called by owner.
     * @param _address The new address.
     */
    function setLiquidityProviderAddress(address _address) public onlyOwner {
        require(_address != address(0), "Zero address");
        require(_address != address(this), "Wrong address");
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
     * @return Returns true if param update delay elapsed.
     */
    function _paramUpdateDelayElapsed(uint256 _paramTimestamp) internal view returns (bool) {
        return _now() > _paramTimestamp.add(PARAM_UPDATE_DELAY);
    }

    /**
     * @dev This method is used to deposit tokens to the deposit opened before.
     * It calls the internal "_deposit" method and transfers tokens from sender to contract.
     * Sender must approve tokens first.
     *
     * Instead this, user can use the simple "transferFrom" method of OVR token contract to make a deposit.
     *
     * @param _depositId User's unique deposit ID.
     * @param _amount The amount to deposit.
     */
    function deposit(uint256 _depositId, uint256 _amount)
        public
        validDepositId(_depositId)
        isNotLocked
        isNotPaused
        isNotPausedDepositAndLockupExtensions
    {
        require(_amount > 0, "Amount should be more than 0");

        _deposit(msg.sender, _depositId, _amount);

        _setLocked(true);
        require(token.transferFrom(msg.sender, address(this), _amount), "Transfer failed");
        _setLocked(false);
    }

    /**
     * @param _sender The address of the sender.
     * @param _depositId User's deposit ID.
     * @param _amount The amount to deposit.
     */
    function _deposit(
        address _sender,
        uint256 _depositId,
        uint256 _amount
    ) internal nonReentrant {
        uint256 currentBalance = getCurrentBalance(_depositId, _sender);
        uint256 finalBalance = calcRewards(_sender, _depositId);
        uint256 timestamp = _now();

        balances[_sender][_depositId] = _amount.add(finalBalance);
        depositDates[_sender][_depositId] = _now();
        emit Deposited(_sender, _depositId, _amount, currentBalance, timestamp);
    }

    /**
     * @dev This method is used to withdraw rewards and balance.
     * It calls the internal "_withdrawAll" method.
     * @param _depositId User's unique deposit ID
     */
    function withdrawAll(uint256 _depositId) external balanceExists(_depositId) validDepositId(_depositId) isNotPaused {
        require(isLockupPeriodExpired(_depositId), "Too early, Lockup period");
        _withdrawAll(msg.sender, _depositId);
    }

    function _withdrawAll(address _sender, uint256 _depositId)
        internal
        balanceExists(_depositId)
        validDepositId(_depositId)
        nonReentrant
    {
        uint256 currentBalance = getCurrentBalance(_depositId, _sender);
        uint256 finalBalance = calcRewards(_sender, _depositId);

        require(finalBalance > 0, "Nothing to withdraw");
        balances[_sender][_depositId] = 0;

        _setLocked(true);
        require(tokenReward.transfer(_sender, finalBalance), "Liquidity pool transfer failed");
        _setLocked(false);

        emit WithdrawnAll(_sender, _depositId, finalBalance, currentBalance, _now());
    }

    /**
     * This method is used to extend lockup. It is available if your lockup period is expired and if depositId != 1
     * It calls the internal "_extendLockup" method.
     * @param _depositId User's unique deposit ID
     */
    function extendLockup(uint256 _depositId)
        external
        balanceExists(_depositId)
        validDepositId(_depositId)
        isNotPaused
        isNotPausedDepositAndLockupExtensions
    {
        require(_depositId != 1, "No lockup is set up");
        _extendLockup(msg.sender, _depositId);
    }

    function _extendLockup(address _sender, uint256 _depositId) internal nonReentrant {
        uint256 timestamp = _now();
        uint256 currentBalance = getCurrentBalance(_depositId, _sender);
        uint256 finalBalance = calcRewards(_sender, _depositId);

        balances[_sender][_depositId] = finalBalance;
        depositDates[_sender][_depositId] = timestamp;
        emit ExtendedLockup(_sender, _depositId, currentBalance, finalBalance, timestamp);
    }

    function isLockupPeriodExpired(uint256 _depositId) public view validDepositId(_depositId) returns (bool) {
        uint256 lockPeriod;

        if (_depositId == 1) {
            lockPeriod = 0;
        } else if (_depositId == 2) {
            lockPeriod = MONTH * 3; // 3 months
        } else if (_depositId == 3) {
            lockPeriod = MONTH * 6; // 6 months
        } else if (_depositId == 4) {
            lockPeriod = MONTH * 9; // 9 months
        } else if (_depositId == 5) {
            lockPeriod = MONTH * 12; // 12 months
        }

        if (_now() > depositDates[msg.sender][_depositId].add(lockPeriod)) {
            return true;
        } else {
            return false;
        }
    }

    function pow(int128 _x, uint256 _n) public pure returns (int128 r) {
        r = ABDKMath64x64.fromUInt(1);
        while (_n > 0) {
            if (_n % 2 == 1) {
                r = ABDKMath64x64.mul(r, _x);
                _n -= 1;
            } else {
                _x = ABDKMath64x64.mul(_x, _x);
                _n /= 2;
            }
        }
    }

    /**
     * This method is calcuate final compouded capital.
     * @param _principal User's balance
     * @param _ratio Interest rate
     * @param _n Periods is timestamp
     * @return finalBalance The final compounded capital
     *
     * A = C ( 1 + rate )^t
     */
    function compound(
        uint256 _principal,
        uint256 _ratio,
        uint256 _n
    ) public view returns (uint256) {
        uint256 daysCount = _n.div(DAY);

        return
            ABDKMath64x64.mulu(
                pow(ABDKMath64x64.add(ABDKMath64x64.fromUInt(1), ABDKMath64x64.divu(_ratio, 10**18)), daysCount),
                _principal
            );
    }

    /**
     * This moethod is used to calculate final compounded balance and is based on deposit duration and deposit id.
     * Each deposit mode is characterized by the lockup period and interest rate.
     * At the expiration of the lockup period the final compounded capital
     * will use minimum interest rate.
     *
     * This function can be called at any time to get the current total reward.
     * @param _sender Sender Address.
     * @param _depositId The depositId
     * @return finalBalance The final compounded capital
     */
    function calcRewards(address _sender, uint256 _depositId) public view validDepositId(_depositId) returns (uint256) {
        uint256 timePassed = _now().sub(depositDates[_sender][_depositId]);
        uint256 currentBalance = getCurrentBalance(_depositId, _sender);
        uint256 finalBalance;

        uint256 ratio;
        uint256 lockPeriod;

        if (_depositId == 1) {
            ratio = 100000000000000; // APY 3.7% InterestRate = 0.01
            lockPeriod = 0;
        } else if (_depositId == 2) {
            ratio = 300000000000000; // APY 11.6% InterestRate = 0.03
            lockPeriod = MONTH * 3; // 3 months
        } else if (_depositId == 3) {
            ratio = 400000000000000; // APY 15.7% InterestRate = 0.04
            lockPeriod = MONTH * 6; // 6 months
        } else if (_depositId == 4) {
            ratio = 600000000000000; // APY 25.5% InterestRate = 0.06
            lockPeriod = MONTH * 9; // 9 months
        } else if (_depositId == 5) {
            ratio = 800000000000000; // APY 33.9% InterestRate = 0.08
            lockPeriod = YEAR; // 12 months
        }

        // You can't have earnings without balance
        if (currentBalance == 0) {
            return finalBalance = 0;
        }

        // No lockup
        if (_depositId == 1) {
            finalBalance = compound(currentBalance, ratio, timePassed);
            return finalBalance;
        }

        // If you have an uncovered period from lockup, you still get rewards at the minimum rate
        if (timePassed > lockPeriod) {
            uint256 rewardsWithLockup = compound(currentBalance, ratio, lockPeriod).sub(currentBalance);
            finalBalance = compound(rewardsWithLockup.add(currentBalance), 100000000000000, timePassed.sub(lockPeriod));


            return finalBalance;
        }

        finalBalance = compound(currentBalance, ratio, timePassed);
        return finalBalance;
    }

    function getCurrentBalance(uint256 _depositId, address _address) public view returns (uint256 addressBalance) {
        addressBalance = balances[_address][_depositId];
    }

    /**
     * @return Returns current liquidity providers reward address.
     */
    function liquidityProviderAddress() public view returns (address) {
        AddressParam memory param = liquidityProviderAddressParam;
        return param.newValue;
    }

    /**
     * @dev Sets lock to prevent reentrance.
     */
    function _setLocked(bool _locked) internal {
        locked = _locked;
    }

    function senderCurrentBalance() public view returns (uint256) {
        return msg.sender.balance;
    }

    /**
     * @return Returns current timestamp.
     */
    function _now() internal view returns (uint256) {
        // Note that the timestamp can have a 900-second error:
        // https://github.com/ethereum/wiki/blob/c02254611f218f43cbb07517ca8e5d00fd6d6d75/Block-Protocol-2.0.md
        // return now; // solium-disable-line security/no-block-members
        return block.timestamp;
    }
}