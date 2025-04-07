/**
 *Submitted for verification at Etherscan.io on 2021-02-02
*/

// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.7.4;


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



/**
 * @dev Collection of functions related to the address type
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
 *     require(hasRole(MY_ROLE, msg.sender));
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
 *
 * WARNING: The `DEFAULT_ADMIN_ROLE` is also its own admin: it has permission to
 * grant and revoke this role. Extra precautions should be taken to secure
 * accounts that have been granted it.
 */
abstract contract AccessControl is Context {
    using EnumerableSet for EnumerableSet.AddressSet;
    using Address for address;

    struct RoleData {
        EnumerableSet.AddressSet members;
        bytes32 adminRole;
    }

    mapping (bytes32 => RoleData) private _roles;

    bytes32 public constant DEFAULT_ADMIN_ROLE = 0x00;

    /**
     * @dev Emitted when `newAdminRole` is set as ``role``'s admin role, replacing `previousAdminRole`
     *
     * `DEFAULT_ADMIN_ROLE` is the starting admin for all roles, despite
     * {RoleAdminChanged} not being emitted signaling this.
     *
     * _Available since v3.1._
     */
    event RoleAdminChanged(bytes32 indexed role, bytes32 indexed previousAdminRole, bytes32 indexed newAdminRole);

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
     *
     * Emits a {RoleAdminChanged} event.
     */
    function _setRoleAdmin(bytes32 role, bytes32 adminRole) internal virtual {
        emit RoleAdminChanged(role, _roles[role].adminRole, adminRole);
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
}

/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
 */



contract CliqStaking is AccessControl {
    using SafeMath for uint256;

    string public constant NAME = "Cliq Staking Contract";
    bytes32 public constant REWARD_PROVIDER = keccak256("REWARD_PROVIDER"); // i upgraded solc and used REWARD_PROVIDER instead of whitelist role and DEFAULT_ADMIN_ROLE instead of whiteloist admin
    uint256 private constant TIME_UNIT = 86400;
    // we can improve this with a "unstaked:false" flag when the user force withdraws the funds
    // so he can collect the reward later
    struct Stake {
        uint256 _amount;
        uint256 _timestamp;
        bytes32 _packageName;
        uint256 _withdrawnTimestamp;
        uint16 _stakeRewardType; // 0 for native coin reward, 1 for CLIQ stake reward
    }

    struct YieldType {
        bytes32 _packageName;
        uint256 _daysLocked;
        uint256 _daysBlocked;
        uint256 _packageInterest;
        uint256 _packageCliqReward; // the number of cliq token received for each native token staked
    }

    IERC20 public tokenContract;
    IERC20 public CLIQ;

    bytes32[] public packageNames;
    uint256 decimals = 18;
    mapping(bytes32 => YieldType) public packages;
    mapping(address => uint256) public totalStakedBalance;
    mapping(address => Stake[]) public stakes;
    mapping(address => bool) public hasStaked;
    address private owner;
    address[] stakers;
    uint256 rewardProviderTokenAllowance = 0;
    uint256 public totalStakedFunds = 0;
    uint256 cliqRewardUnits = 1000000; // ciq reward for 1.000.000 tokens staked
    bool public paused = false;

    event NativeTokenRewardAdded(address indexed _from, uint256 _val);
    event NativeTokenRewardRemoved(address indexed _to, uint256 _val);
    event StakeAdded(
        address indexed _usr,
        bytes32 _packageName,
        uint256 _amount,
        uint16 _stakeRewardType,
        uint256 _stakeIndex
    );
    event Unstaked(address indexed _usr, uint256 stakeIndex);
    event ForcefullyWithdrawn(address indexed _usr, uint256 stakeIndex);
    event Paused();
    event Unpaused();

    modifier onlyRewardProvider() {
        require(
            hasRole(REWARD_PROVIDER, _msgSender()),
            "caller does not have the REWARD_PROVIDER role"
        );
        _;
    }

    modifier onlyMaintainer() {
        require(
            hasRole(DEFAULT_ADMIN_ROLE, _msgSender()),
            "caller does not have the Maintainer role"
        );
        _;
    }

    constructor(address _stakedToken, address _CLIQ) {
        _setupRole(DEFAULT_ADMIN_ROLE, _msgSender());
        tokenContract = IERC20(_stakedToken);
        CLIQ = IERC20(_CLIQ);
        //define packages here
        _definePackage("Silver Package", 30, 15, 1740084, 0); // in 30 days you receive: 1.740084% of staked token OR 0 cliq for 1 token staked || 6 decimals
        _definePackage("Gold Package", 60, 30, 4735920, 0); // 0 cliq for 1 token staked
        _definePackage("Platinum Package", 90, 45, 11217430, 0); // 0 cliq for 1 token staked
    }

    function stakesLength(address _address) external view returns (uint256) {
        return stakes[_address].length;
    }

    function packageLength() external view returns (uint256) {
        return packageNames.length;
    }

    function stakeTokens(
        uint256 _amount,
        bytes32 _packageName,
        uint16 _stakeRewardType
    ) public {
        require(paused == false, "Staking is  paused");
        require(_amount > 0, " stake a positive number of tokens ");
        require(
            packages[_packageName]._daysLocked > 0,
            "there is no staking package with the declared name, or the staking package is poorly formated"
        );
        require(
            _stakeRewardType == 0 || _stakeRewardType == 1,
            "reward type not known: 0 is native token, 1 is CLIQ"
        );

        //add to stake sum of address
        totalStakedBalance[msg.sender] = totalStakedBalance[msg.sender].add(
            _amount
        );

        //add to stakes
        Stake memory currentStake;
        currentStake._amount = _amount;
        currentStake._timestamp = block.timestamp;
        currentStake._packageName = _packageName;
        currentStake._stakeRewardType = _stakeRewardType;
        currentStake._withdrawnTimestamp = 0;
        stakes[msg.sender].push(currentStake);

        //if user is not declared as a staker, push him into the staker array
        if (!hasStaked[msg.sender]) {
            stakers.push(msg.sender);
        }

        //update the bool mapping of past and current stakers
        hasStaked[msg.sender] = true;
        totalStakedFunds = totalStakedFunds.add(_amount);

        //transfer from (need allowance)
        tokenContract.transferFrom(msg.sender, address(this), _amount);

        StakeAdded(
            msg.sender,
            _packageName,
            _amount,
            _stakeRewardType,
            stakes[msg.sender].length - 1
        );
    }

    function checkStakeReward(address _address, uint256 stakeIndex)
        public
        view
        returns (uint256 yieldReward, uint256 timeDiff)
    {
        require(
            stakes[_address][stakeIndex]._stakeRewardType == 0,
            "use checkStakeCliqReward for stakes accumulating reward in CLIQ"
        );

        uint256 currentTime = block.timestamp;
        if (stakes[_address][stakeIndex]._withdrawnTimestamp != 0) {
            currentTime = stakes[_address][stakeIndex]._withdrawnTimestamp;
        }

        uint256 stakingTime = stakes[_address][stakeIndex]._timestamp;
        uint256 daysLocked =
            packages[stakes[_address][stakeIndex]._packageName]._daysLocked;
        uint256 packageInterest =
            packages[stakes[_address][stakeIndex]._packageName]
                ._packageInterest;

        timeDiff = currentTime.sub(stakingTime).div(TIME_UNIT);

        uint256 yieldPeriods = timeDiff.div(daysLocked); // the _days is in seconds for now so can fucking test stuff

        yieldReward = 0;
        uint256 totalStake = stakes[_address][stakeIndex]._amount;

        // for each period of days defined in the package, compound the interest
        while (yieldPeriods > 0) {
            uint256 currentReward =
                totalStake.mul(packageInterest).div(100000000); //6 decimals to package interest percentage

            totalStake = totalStake.add(currentReward);

            yieldReward = yieldReward.add(currentReward);

            yieldPeriods--;
        }
    }

    // function checkStakeCliqReward(address _address, uint256 stakeIndex)
    //     public
    //     view
    //     returns (uint256 yieldReward, uint256 timeDiff)
    // {
    //     require(
    //         stakes[_address][stakeIndex]._stakeRewardType == 1,
    //         "use checkStakeReward for stakes accumulating reward in the Native Token"
    //     );

    //     uint256 currentTime = block.timestamp;
    //     if (stakes[_address][stakeIndex]._withdrawnTimestamp != 0) {
    //         currentTime = stakes[_address][stakeIndex]._withdrawnTimestamp;
    //     }

    //     uint256 stakingTime = stakes[_address][stakeIndex]._timestamp;
    //     uint256 daysLocked =
    //         packages[stakes[_address][stakeIndex]._packageName]._daysLocked;
    //     uint256 packageCliqInterest =
    //         packages[stakes[_address][stakeIndex]._packageName]
    //             ._packageCliqReward;

    //     timeDiff = currentTime.sub(stakingTime).div(TIME_UNIT);

    //     uint256 yieldPeriods = timeDiff.div(daysLocked);

    //     yieldReward = stakes[_address][stakeIndex]._amount.mul(
    //         packageCliqInterest
    //     );

    //     yieldReward = yieldReward.div(cliqRewardUnits);

    //     yieldReward = yieldReward.mul(yieldPeriods);
    // }

    function unstake(uint256 stakeIndex) public {
        require(
            stakeIndex < stakes[msg.sender].length,
            "The stake you are searching for is not defined"
        );
        require(
            stakes[msg.sender][stakeIndex]._withdrawnTimestamp == 0,
            "Stake already withdrawn"
        );

        // decrease total balance
        totalStakedFunds = totalStakedFunds.sub(
            stakes[msg.sender][stakeIndex]._amount
        );

        //decrease user total staked balance
        totalStakedBalance[msg.sender] = totalStakedBalance[msg.sender].sub(
            stakes[msg.sender][stakeIndex]._amount
        );

        //close the staking package (fix the withdrawn timestamp)
        stakes[msg.sender][stakeIndex]._withdrawnTimestamp = block.timestamp;

        if (stakes[msg.sender][stakeIndex]._stakeRewardType == 0) {
            (uint256 reward, uint256 daysSpent) =
                checkStakeReward(msg.sender, stakeIndex);

            require(
                rewardProviderTokenAllowance > reward,
                "Token creators did not place enough liquidity in the contract for your reward to be paid"
            );

            require(
                daysSpent >
                    packages[stakes[msg.sender][stakeIndex]._packageName]
                        ._daysBlocked,
                "cannot unstake sooner than the blocked time time"
            );

            rewardProviderTokenAllowance = rewardProviderTokenAllowance.sub(
                reward
            );

            uint256 totalStake =
                stakes[msg.sender][stakeIndex]._amount.add(reward);

            tokenContract.transfer(msg.sender, totalStake);
        }
        // else if (stakes[msg.sender][stakeIndex]._stakeRewardType == 1) {
        //     (uint256 cliqReward, uint256 daysSpent) =
        //         checkStakeCliqReward(msg.sender, stakeIndex);
        //     require(
        //         CLIQ.balanceOf(address(this)) >= cliqReward,
        //         "the isn't enough CLIQ in this contract to pay your reward right now"
        //     );
        //     require(
        //         daysSpent >
        //             packages[stakes[msg.sender][stakeIndex]._packageName]
        //                 ._daysBlocked,
        //         "cannot unstake sooner than the blocked time time"
        //     );
        //     CLIQ.transfer(msg.sender, cliqReward);
        //     tokenContract.transfer(
        //         msg.sender,
        //         stakes[msg.sender][stakeIndex]._amount
        //     );
        // }
        else {
            revert();
        }

        emit Unstaked(msg.sender, stakeIndex);
    }

    function forceWithdraw(uint256 stakeIndex) public {
        require(
            stakes[msg.sender][stakeIndex]._amount > 0,
            "The stake you are searching for is not defined"
        );
        require(
            stakes[msg.sender][stakeIndex]._withdrawnTimestamp == 0,
            "Stake already withdrawn"
        );

        stakes[msg.sender][stakeIndex]._withdrawnTimestamp = block.timestamp;
        totalStakedFunds = totalStakedFunds.sub(
            stakes[msg.sender][stakeIndex]._amount
        );
        totalStakedBalance[msg.sender] = totalStakedBalance[msg.sender].sub(
            stakes[msg.sender][stakeIndex]._amount
        );

        uint256 daysSpent =
            block.timestamp.sub(stakes[msg.sender][stakeIndex]._timestamp).div(
                TIME_UNIT
            ); //86400

        require(
            daysSpent >
                packages[stakes[msg.sender][stakeIndex]._packageName]
                    ._daysBlocked,
            "cannot unstake sooner than the blocked time time"
        );

        tokenContract.transfer(
            msg.sender,
            stakes[msg.sender][stakeIndex]._amount
        );

        emit ForcefullyWithdrawn(msg.sender, stakeIndex);
    }

    function pauseStaking() public onlyMaintainer {
        paused = true;
        emit Paused();
    }

    function unpauseStaking() public onlyMaintainer {
        paused = false;
        emit Unpaused();
    }

    function addStakedTokenReward(uint256 _amount)
        public
        onlyRewardProvider
        returns (bool)
    {
        //transfer from (need allowance)
        rewardProviderTokenAllowance = rewardProviderTokenAllowance.add(
            _amount
        );
        tokenContract.transferFrom(msg.sender, address(this), _amount);

        emit NativeTokenRewardAdded(msg.sender, _amount);
        return true;
    }

    function removeStakedTokenReward(uint256 _amount)
        public
        onlyRewardProvider
        returns (bool)
    {
        require(
            _amount <= rewardProviderTokenAllowance,
            "you cannot withdraw this amount"
        );
        rewardProviderTokenAllowance = rewardProviderTokenAllowance.sub(
            _amount
        );
        tokenContract.transfer(msg.sender, _amount);
        emit NativeTokenRewardRemoved(msg.sender, _amount);
        return true;
    }

    function _definePackage(
        bytes32 _name,
        uint256 _days,
        uint256 _daysBlocked,
        uint256 _packageInterest,
        uint256 _packageCliqReward
    ) private {
        YieldType memory package;
        package._packageName = _name;
        package._daysLocked = _days;
        package._packageInterest = _packageInterest;
        package._packageCliqReward = _packageCliqReward;
        package._daysBlocked = _daysBlocked;
        packages[_name] = package;
        packageNames.push(_name);
    }
}