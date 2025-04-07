/**
 *Submitted for verification at Etherscan.io on 2021-08-31
*/

// SPDX-License-Identifier: NONE

pragma solidity 0.6.2;



// Part: OpenZeppelin/[email protected]/Address

/**
 * @dev Collection of functions related to the address type
 */


// Part: OpenZeppelin/[email protected]/EnumerableSet

/**
 * @dev Library for managing
 * https://en.wikipedia.org/wiki/Set_(abstract_data_type)[sets] of primitive
 * types.
 *
 * Sets have the following properties:
 *
 * - Elements are added, removed, and checked for existence in constant time
 * (O(1)).
 * - Elements are enumerated in O(n). No guarantees are made on the ordering.
 *
 * ```
 * contract Example {
 *     // Add the library methods
 *     using EnumerableSet for EnumerableSet.AddressSet;
 *
 *     // Declare a set state variable
 *     EnumerableSet.AddressSet private mySet;
 * }
 * ```
 *
 * As of v3.3.0, sets of type `bytes32` (`Bytes32Set`), `address` (`AddressSet`)
 * and `uint256` (`UintSet`) are supported.
 */


// Part: OpenZeppelin/[email protected]/IERC20

/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
 */


// Part: OpenZeppelin/[email protected]/Math

/**
 * @dev Standard math utilities missing in the Solidity language.
 */


// Part: OpenZeppelin/[email protected]/SafeMath

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


// Part: OpenZeppelin/[email protected]/Arrays

/**
 * @dev Collection of functions related to array types.
 */


// Part: OpenZeppelin/[email protected]/Initializable

/**
 * @dev This is a base contract to aid in writing upgradeable contracts, or any kind of contract that will be deployed
 * behind a proxy. Since a proxied contract can't have a constructor, it's common to move constructor logic to an
 * external initializer function, usually called `initialize`. It then becomes necessary to protect this initializer
 * function so it can only be called once. The {initializer} modifier provided by this contract will have this effect.
 *
 * TIP: To avoid leaving the proxy in an uninitialized state, the initializer function should be called as early as
 * possible by providing the encoded function call as the `_data` argument to {UpgradeableProxy-constructor}.
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
        require(_initializing || _isConstructor() || !_initialized, "Initializable: contract is already initialized");

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

    /// @dev Returns true if and only if the function is running in the constructor
    function _isConstructor() private view returns (bool) {
        return !Address.isContract(address(this));
    }
}

// Part: ContextUpgradeSafe

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
contract ContextUpgradeSafe is Initializable {
    // Empty internal constructor, to prevent people from mistakenly deploying
    // an instance of this contract, which should be used via inheritance.

    function __Context_init() internal initializer {
        __Context_init_unchained();
    }

    function __Context_init_unchained() internal initializer {}

    function _msgSender() internal view virtual returns (address payable) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes memory) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }

    uint256[50] private __gap;
}

// Part: ReentrancyGuardUpgradeSafe

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
contract ReentrancyGuardUpgradeSafe is Initializable {
    bool private _notEntered;

    function __ReentrancyGuard_init() internal initializer {
        __ReentrancyGuard_init_unchained();
    }

    function __ReentrancyGuard_init_unchained() internal initializer {
        // Storing an initial non-zero value makes deployment a bit more
        // expensive, but in exchange the refund on every call to nonReentrant
        // will be lower in amount. Since refunds are capped to a percetange of
        // the total transaction's gas, it is best to keep them low in cases
        // like this one, to increase the likelihood of the full refund coming
        // into effect.
        _notEntered = true;
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
        require(_notEntered, "ReentrancyGuard: reentrant call");

        // Any calls to nonReentrant after this point will fail
        _notEntered = false;

        _;

        // By storing the original value once again, a refund is triggered (see
        // https://eips.ethereum.org/EIPS/eip-2200)
        _notEntered = true;
    }

    uint256[49] private __gap;
}

// Part: AccessControlUpgradeSafe

// contract ContextUpgradeSafe is Initializable {
//     // Empty internal constructor, to prevent people from mistakenly deploying
//     // an instance of this contract, which should be used via inheritance.

//     function __Context_init() internal initializer {
//         __Context_init_unchained();
//     }

//     function __Context_init_unchained() internal initializer {}

//     function _msgSender() internal view virtual returns (address payable) {
//         return msg.sender;
//     }

//     function _msgData() internal view virtual returns (bytes memory) {
//         this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
//         return msg.data;
//     }

//     uint256[50] private __gap;
// }

/**
 * @dev Contract module that allows children to implement role-based access
 * control mechanisms.
 *
 * Roles are referred to by their `bytes32` identifier. These should be exposed
 * in the external API and be unique. The best way to achieve this is by
 * using `public constant` hash digests:
 *
 * ```
 * bytes32 public constant MY_ROLE = keccak256("MY_ROLE");
 * ```
 *
 * Roles can be used to represent a set of permissions. To restrict access to a
 * function call, use {hasRole}:
 *
 * ```
 * function foo() public {
 *     require(hasRole(MY_ROLE, _msgSender()));
 *     ...
 * }
 * ```
 *
 * Roles can be granted and revoked dynamically via the {grantRole} and
 * {revokeRole} functions. Each role has an associated admin role, and only
 * accounts that have a role's admin role can call {grantRole} and {revokeRole}.
 *
 * By default, the admin role for all roles is `DEFAULT_ADMIN_ROLE`, which means
 * that only accounts with this role will be able to grant or revoke other
 * roles. More complex role relationships can be created by using
 * {_setRoleAdmin}.
 */
abstract contract AccessControlUpgradeSafe is Initializable, ContextUpgradeSafe {
    function __AccessControl_init() internal initializer {
        __Context_init_unchained();
        __AccessControl_init_unchained();
    }

    function __AccessControl_init_unchained() internal initializer {}

    using EnumerableSet for EnumerableSet.AddressSet;
    using Address for address;

    struct RoleData {
        EnumerableSet.AddressSet members;
        bytes32 adminRole;
    }

    mapping(bytes32 => RoleData) private _roles;

    bytes32 public constant DEFAULT_ADMIN_ROLE = 0x00;

    /**
     * @dev Emitted when `account` is granted `role`.
     *
     * `sender` is the account that originated the contract call, an admin role
     * bearer except when using {_setupRole}.
     */
    event RoleGranted(bytes32 indexed role, address indexed account, address indexed sender);

    /**
     * @dev Emitted when `account` is revoked `role`.
     *
     * `sender` is the account that originated the contract call:
     *   - if using `revokeRole`, it is the admin role bearer
     *   - if using `renounceRole`, it is the role bearer (i.e. `account`)
     */
    event RoleRevoked(bytes32 indexed role, address indexed account, address indexed sender);

    /**
     * @dev Returns `true` if `account` has been granted `role`.
     */
    function hasRole(bytes32 role, address account) public view returns (bool) {
        return _roles[role].members.contains(account);
    }

    /**
     * @dev Returns the number of accounts that have `role`. Can be used
     * together with {getRoleMember} to enumerate all bearers of a role.
     */
    function getRoleMemberCount(bytes32 role) public view returns (uint256) {
        return _roles[role].members.length();
    }

    /**
     * @dev Returns one of the accounts that have `role`. `index` must be a
     * value between 0 and {getRoleMemberCount}, non-inclusive.
     *
     * Role bearers are not sorted in any particular way, and their ordering may
     * change at any point.
     *
     * WARNING: When using {getRoleMember} and {getRoleMemberCount}, make sure
     * you perform all queries on the same block. See the following
     * https://forum.openzeppelin.com/t/iterating-over-elements-on-enumerableset-in-openzeppelin-contracts/2296[forum post]
     * for more information.
     */
    function getRoleMember(bytes32 role, uint256 index) public view returns (address) {
        return _roles[role].members.at(index);
    }

    /**
     * @dev Returns the admin role that controls `role`. See {grantRole} and
     * {revokeRole}.
     *
     * To change a role's admin, use {_setRoleAdmin}.
     */
    function getRoleAdmin(bytes32 role) public view returns (bytes32) {
        return _roles[role].adminRole;
    }

    /**
     * @dev Grants `role` to `account`.
     *
     * If `account` had not been already granted `role`, emits a {RoleGranted}
     * event.
     *
     * Requirements:
     *
     * - the caller must have ``role``'s admin role.
     */
    function grantRole(bytes32 role, address account) public virtual {
        require(hasRole(_roles[role].adminRole, _msgSender()), "AccessControl: sender must be an admin to grant");

        _grantRole(role, account);
    }

    /**
     * @dev Revokes `role` from `account`.
     *
     * If `account` had been granted `role`, emits a {RoleRevoked} event.
     *
     * Requirements:
     *
     * - the caller must have ``role``'s admin role.
     */
    function revokeRole(bytes32 role, address account) public virtual {
        require(hasRole(_roles[role].adminRole, _msgSender()), "AccessControl: sender must be an admin to revoke");

        _revokeRole(role, account);
    }

    /**
     * @dev Revokes `role` from the calling account.
     *
     * Roles are often managed via {grantRole} and {revokeRole}: this function's
     * purpose is to provide a mechanism for accounts to lose their privileges
     * if they are compromised (such as when a trusted device is misplaced).
     *
     * If the calling account had been granted `role`, emits a {RoleRevoked}
     * event.
     *
     * Requirements:
     *
     * - the caller must be `account`.
     */
    function renounceRole(bytes32 role, address account) public virtual {
        require(account == _msgSender(), "AccessControl: can only renounce roles for self");

        _revokeRole(role, account);
    }

    /**
     * @dev Grants `role` to `account`.
     *
     * If `account` had not been already granted `role`, emits a {RoleGranted}
     * event. Note that unlike {grantRole}, this function doesn't perform any
     * checks on the calling account.
     *
     * [WARNING]
     * ====
     * This function should only be called from the constructor when setting
     * up the initial roles for the system.
     *
     * Using this function in any other way is effectively circumventing the admin
     * system imposed by {AccessControl}.
     * ====
     */
    function _setupRole(bytes32 role, address account) internal virtual {
        _grantRole(role, account);
    }

    /**
     * @dev Sets `adminRole` as ``role``'s admin role.
     */
    function _setRoleAdmin(bytes32 role, bytes32 adminRole) internal virtual {
        _roles[role].adminRole = adminRole;
    }

    function _grantRole(bytes32 role, address account) private {
        if (_roles[role].members.add(account)) {
            emit RoleGranted(role, account, _msgSender());
        }
    }

    function _revokeRole(bytes32 role, address account) private {
        if (_roles[role].members.remove(account)) {
            emit RoleRevoked(role, account, _msgSender());
        }
    }

    uint256[49] private __gap;
}

// Part: PausableUpgradeSafe

/**
 * @dev Contract module which allows children to implement an emergency stop
 * mechanism that can be triggered by an authorized account.
 *
 * This module is used through inheritance. It will make available the
 * modifiers `whenNotPaused` and `whenPaused`, which can be applied to
 * the functions of your contract. Note that they will not be pausable by
 * simply including this module, only once the modifiers are put in place.
 */
contract PausableUpgradeSafe is Initializable, ContextUpgradeSafe {
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
    function paused() public view returns (bool) {
        return _paused;
    }

    /**
     * @dev Modifier to make a function callable only when the contract is not paused.
     */
    modifier whenNotPaused() {
        require(!_paused, "Pausable: paused");
        _;
    }

    /**
     * @dev Modifier to make a function callable only when the contract is paused.
     */
    modifier whenPaused() {
        require(_paused, "Pausable: not paused");
        _;
    }

    /**
     * @dev Triggers stopped state.
     */
    function _pause() internal virtual whenNotPaused {
        _paused = true;
        emit Paused(_msgSender());
    }

    /**
     * @dev Returns to normal state.
     */
    function _unpause() internal virtual whenPaused {
        _paused = false;
        emit Unpaused(_msgSender());
    }

    uint256[49] private __gap;
}

// Part: SwapStakingContract

contract SwapStakingContract is
    Initializable,
    ContextUpgradeSafe,
    AccessControlUpgradeSafe,
    PausableUpgradeSafe,
    ReentrancyGuardUpgradeSafe
{
    using SafeMath for uint256;
    using Math for uint256;
    //using Address for address;
    using Arrays for uint256[];

    bytes32 private constant PAUSER_ROLE = keccak256("PAUSER_ROLE");
    bytes32 private constant OWNER_ROLE = keccak256("OWNER_ROLE");
    bytes32 private constant REWARDS_DISTRIBUTOR_ROLE = keccak256("REWARDS_DISTRIBUTOR_ROLE");

    // EVENTS
    event StakeDeposited(address indexed account, uint256 amount);
    event WithdrawInitiated(address indexed account, uint256 amount, uint256 initiateDate);
    event WithdrawExecuted(address indexed account, uint256 amount, uint256 reward);
    event RewardsWithdrawn(address indexed account, uint256 reward);
    event RewardsDistributed(uint256 amount);

    // STRUCT DECLARATIONS
    struct StakeDeposit {
        uint256 amount;
        uint256 startDate;
        uint256 endDate;
        uint256 entryRewardPoints;
        uint256 exitRewardPoints;
        bool exists;
    }

    // STRUCT WITHDRAWAL
    struct WithdrawalState {
        uint256 initiateDate;
        uint256 amount;
    }

    // CONTRACT STATE VARIABLES
    IERC20 public token;
    address public rewardsAddress;
    uint256 public maxStakingAmount;
    uint256 public minStakingAmount;
    uint256 public currentTotalStake;
    uint256 public unstakingPeriod;
    uint256 public dayLength;

    //reward calculations
    uint256 private totalRewardPoints;
    uint256 public rewardsDistributed;
    uint256 public rewardsWithdrawn;
    uint256 public totalRewardsDistributed;

    mapping(address => StakeDeposit) private _stakeDeposits;
    mapping(address => WithdrawalState) private _withdrawStates;

    // MODIFIERS
    modifier guardMaxStakingLimit(uint256 amount) {
        uint256 resultedStakedAmount = currentTotalStake.add(amount);
        require(
            resultedStakedAmount <= maxStakingAmount,
            "[Deposit] Your deposit would exceed the current staking limit"
        );
        _;
    }

    modifier onlyContract(address account) {
        require(account.isContract(), "[Validation] The address does not contain a contract");
        _;
    }

    // PUBLIC FUNCTIONS
    function initialize(
        address _token,
        address _rewardsAddress,
        uint256 _maxStakingAmount,
        uint256 _unstakingPeriod
    ) public onlyContract(_token) {
        __SwapStakingContract_init(_token, _rewardsAddress, _maxStakingAmount, _unstakingPeriod);
        dayLength = 7 days;
    }

    function __SwapStakingContract_init(
        address _token,
        address _rewardsAddress,
        uint256 _maxStakingAmount,
        uint256 _unstakingPeriod
    ) internal initializer {
        require(_token != address(0), "[Validation] Invalid swap token address");
        require(_maxStakingAmount > 0, "[Validation] _maxStakingAmount has to be larger than 0");
        __Context_init_unchained();
        __AccessControl_init_unchained();
        __Pausable_init_unchained();
        __ReentrancyGuard_init_unchained();
        __SwapStakingContract_init_unchained();

        pause();
        setRewardAddress(_rewardsAddress);
        unpause();

        token = IERC20(_token);
        maxStakingAmount = _maxStakingAmount;
        unstakingPeriod = _unstakingPeriod;
    }

    function __SwapStakingContract_init_unchained() internal initializer {
        _setupRole(DEFAULT_ADMIN_ROLE, _msgSender());
        _setupRole(PAUSER_ROLE, _msgSender());
        _setupRole(OWNER_ROLE, _msgSender());
        _setupRole(REWARDS_DISTRIBUTOR_ROLE, _msgSender());
    }

    function pause() public {
        require(hasRole(PAUSER_ROLE, _msgSender()), "SwapStakingContract: must have pauser role to pause");
        _pause();
    }

    function unpause() public {
        require(hasRole(PAUSER_ROLE, _msgSender()), "SwapStakingContract: must have pauser role to unpause");
        _unpause();
    }

    function setRewardAddress(address _rewardsAddress) public whenPaused {
        require(
            hasRole(OWNER_ROLE, _msgSender()),
            "[Validation] The caller must have owner role to set rewards address"
        );
        require(_rewardsAddress != address(0), "[Validation] _rewardsAddress is the zero address");
        require(_rewardsAddress != rewardsAddress, "[Validation] _rewardsAddress is already set to given address");
        rewardsAddress = _rewardsAddress;
    }

    function setTokenAddress(address _token) external onlyContract(_token) whenPaused {
        require(hasRole(OWNER_ROLE, _msgSender()), "[Validation] The caller must have owner role to set token address");
        require(_token != address(0), "[Validation] Invalid swap token address");
        token = IERC20(_token);
    }

    function deposit(uint256 amount) external nonReentrant whenNotPaused {
        StakeDeposit storage stakeDeposit = _stakeDeposits[msg.sender];
        require(stakeDeposit.endDate == 0, "[Deposit] You have already initiated the withdrawal");

        uint256 oldPrincipal = stakeDeposit.amount;
        uint256 reward = _computeReward(stakeDeposit);
        uint256 newPrincipal = oldPrincipal.add(amount).add(reward);
        require(newPrincipal > oldPrincipal, "[Validation] The stake deposit has to be larger than 0");

        uint256 resultedStakedAmount = currentTotalStake.add(newPrincipal.sub(oldPrincipal));
        require(
            resultedStakedAmount <= maxStakingAmount,
            "[Deposit] Your deposit would exceed the current staking limit"
        );

        require(
            resultedStakedAmount > minStakingAmount,
            "[Deposit] Your deposit would less the current staking limit"
        );

        stakeDeposit.amount = newPrincipal;
        stakeDeposit.startDate = block.timestamp;
        stakeDeposit.exists = true;
        stakeDeposit.entryRewardPoints = totalRewardPoints;

        currentTotalStake = resultedStakedAmount;

        // Transfer the Tokens to this contract
        require(
            token.transferFrom(msg.sender, address(this), amount),
            "[Deposit] Something went wrong during the token transfer"
        );

        if (reward > 0) {
            //calculate withdrawed rewards in single distribution cycle
            rewardsWithdrawn = rewardsWithdrawn.add(reward);
            require(
                token.transferFrom(rewardsAddress, address(this), reward),
                "[Deposit] Something went wrong while transferring reward"
            );
        }

        emit StakeDeposited(msg.sender, amount.add(reward));
    }

    function initiateWithdrawal(uint256 withdrawAmount) external nonReentrant whenNotPaused {
        StakeDeposit storage stakeDeposit = _stakeDeposits[msg.sender];
        WithdrawalState storage withdrawState = _withdrawStates[msg.sender];
        require(withdrawAmount > 0, "[Initiate Withdrawal] Invalid withdrawal amount");
        require(withdrawAmount <= stakeDeposit.amount, "[Initiate Withdrawal] Withdraw amount exceed the stake amount");
        require(
            stakeDeposit.exists && stakeDeposit.amount != 0,
            "[Initiate Withdrawal] There is no stake deposit for this account"
        );
        require(stakeDeposit.endDate == 0, "[Initiate Withdrawal] You have already initiated the withdrawal");
        require(withdrawState.amount == 0, "[Initiate Withdrawal] You have already initiated the withdrawal");

        stakeDeposit.endDate = block.timestamp;
        stakeDeposit.exitRewardPoints = totalRewardPoints;
        withdrawState.amount = withdrawAmount;
        withdrawState.initiateDate = block.timestamp;

        currentTotalStake = currentTotalStake.sub(withdrawAmount);

        emit WithdrawInitiated(msg.sender, withdrawAmount, block.timestamp);
    }

    function executeWithdrawal() external virtual nonReentrant whenNotPaused {
        StakeDeposit memory stakeDeposit = _stakeDeposits[msg.sender];
        WithdrawalState memory withdrawState = _withdrawStates[msg.sender];

        require(
            stakeDeposit.endDate != 0 || withdrawState.amount != 0,
            "[Withdraw] Withdraw amount is not initialized"
        );
        require(
            stakeDeposit.exists && stakeDeposit.amount != 0,
            "[Withdraw] There is no stake deposit for this account"
        );

        // validate enough days have passed from initiating the withdrawal
        uint256 daysPassed = (block.timestamp - stakeDeposit.endDate) / dayLength;
        require(unstakingPeriod <= daysPassed, "[Withdraw] The unstaking period did not pass");

        //TODO Need for test
        uint256 amount = withdrawState.amount != 0 ? withdrawState.amount : stakeDeposit.amount;
        uint256 reward = _computeReward(stakeDeposit);

        require(
            stakeDeposit.amount >= amount,
            "[withdraw] Remaining stakedeposit amount must be higher than withdraw amount"
        );
        if (stakeDeposit.amount > amount) {
            _stakeDeposits[msg.sender].amount = _stakeDeposits[msg.sender].amount.sub(amount);
            _stakeDeposits[msg.sender].endDate = 0;
            _stakeDeposits[msg.sender].entryRewardPoints = totalRewardPoints;
        } else {
            delete _stakeDeposits[msg.sender];
        }

        require(
            token.transfer(msg.sender, amount),
            "[Withdraw] Something went wrong while transferring your initial deposit"
        );

        if (reward > 0) {
            //calculate withdrawed rewards in single distribution cycle
            rewardsWithdrawn = rewardsWithdrawn.add(reward);
            require(
                token.transferFrom(rewardsAddress, msg.sender, reward),
                "[Withdraw] Something went wrong while transferring your reward"
            );
        }

        _withdrawStates[msg.sender].amount = 0;
        _withdrawStates[msg.sender].initiateDate = 0;

        emit WithdrawExecuted(msg.sender, amount, reward);
    }

    function withdrawRewards() external nonReentrant whenNotPaused {
        StakeDeposit storage stakeDeposit = _stakeDeposits[msg.sender];
        require(
            stakeDeposit.exists && stakeDeposit.amount != 0,
            "[Rewards Withdrawal] There is no stake deposit for this account"
        );
        require(stakeDeposit.endDate == 0, "[Rewards Withdrawal] You already initiated the full withdrawal");

        uint256 reward = _computeReward(stakeDeposit);

        require(reward > 0, "[Rewards Withdrawal] The reward amount has to be larger than 0");

        stakeDeposit.entryRewardPoints = totalRewardPoints;

        //calculate withdrawed rewards in single distribution cycle
        rewardsWithdrawn = rewardsWithdrawn.add(reward);

        require(
            token.transferFrom(rewardsAddress, msg.sender, reward),
            "[Rewards Withdrawal] Something went wrong while transferring your reward"
        );

        emit RewardsWithdrawn(msg.sender, reward);
    }

    ///////////////////////////////////////////////////////////////////
    ///////  AdminFunctions                                        ////
    function setMinStakingAmount(uint256 _minAmount) external {
        require(
            hasRole(OWNER_ROLE, msg.sender),
            "[Validation] The caller must have owner role to set minStakingAmount"
        );
        minStakingAmount = _minAmount;
    }

    ///////////////////////////////////////////////////////////////////

    // VIEW FUNCTIONS FOR HELPING THE USER AND CLIENT INTERFACE
    function getCurrentStake(address account) external view whenNotPaused returns (uint256) {
        if (_stakeDeposits[account].amount == 0 || _stakeDeposits[account].amount <= _withdrawStates[account].amount) {
            return (0);
        } else {
            return (_stakeDeposits[account].amount.sub(_withdrawStates[account].amount));
        }
    }

    function getCurrentTotalStake() external view whenNotPaused returns (uint256) {
        return (currentTotalStake);
    }

    function getStakeDetails(address account)
        external
        view
        returns (
            uint256 initialDeposit,
            uint256 startDate,
            uint256 endDate,
            uint256 rewards
        )
    {
        require(
            _stakeDeposits[account].exists && _stakeDeposits[account].amount != 0,
            "[Validation] This account doesn't have a stake deposit"
        );

        StakeDeposit memory s = _stakeDeposits[account];

        return (s.amount, s.startDate, s.endDate, _computeReward(s));
    }

    function getInitiatedWithdrawal(address account) external view returns (uint256, uint256) {
        return (_withdrawStates[account].amount, _withdrawStates[account].initiateDate + unstakingPeriod * dayLength);
    }

    function _computeReward(StakeDeposit memory stakeDeposit) internal view returns (uint256) {
        uint256 rewardsPoints = 0;

        if (stakeDeposit.endDate == 0) {
            rewardsPoints = totalRewardPoints.sub(stakeDeposit.entryRewardPoints);
        } else {
            //withdrawal is initiated
            rewardsPoints = stakeDeposit.exitRewardPoints.sub(stakeDeposit.entryRewardPoints);
        }
        return stakeDeposit.amount.mul(rewardsPoints).div(10**18);
    }

    function distributeRewards() external nonReentrant whenNotPaused {
        require(
            hasRole(REWARDS_DISTRIBUTOR_ROLE, _msgSender()),
            "[Validation] The caller must have rewards distributor role"
        );
        _distributeRewards();
    }

    function _distributeRewards() internal whenNotPaused {
        require(
            hasRole(REWARDS_DISTRIBUTOR_ROLE, _msgSender()),
            "[Validation] The caller must have rewards distributor role"
        );
        require(currentTotalStake > 0, "[Validation] not enough total stake accumulated");
        uint256 rewardPoolBalance = token.balanceOf(rewardsAddress);
        require(rewardPoolBalance > 0, "[Validation] not enough rewards accumulated");

        uint256 newlyAdded = rewardPoolBalance.add(rewardsWithdrawn).sub(rewardsDistributed);
        uint256 ratio = newlyAdded.mul(10**18).div(currentTotalStake);
        totalRewardPoints = totalRewardPoints.add(ratio);
        rewardsDistributed = rewardPoolBalance;
        rewardsWithdrawn = 0;
        totalRewardsDistributed = totalRewardsDistributed.add(newlyAdded);

        emit RewardsDistributed(newlyAdded);
    }

    function version() public pure returns (string memory) {
        return "v2";
    }
}

// File: StakeWrapper.sol

contract SwapStakingContractWrapper is SwapStakingContract {
    bytes32 private constant PAUSER_ROLE = keccak256("PAUSER_ROLE");
    bytes32 private constant OWNER_ROLE = keccak256("OWNER_ROLE");
    bytes32 private constant REWARDS_DISTRIBUTOR_ROLE = keccak256("REWARDS_DISTRIBUTOR_ROLE");

    constructor(
        address _token,
        address _rewardsAddress,
        uint256 _maxStakingAmount,
        uint256 _unstakingPeriod
    ) public {
        initialize(_token, _rewardsAddress, _maxStakingAmount, _unstakingPeriod);
    }

}