/**
 *Submitted for verification at Etherscan.io on 2021-04-28
*/

// SPDX-License-Identifier: NONE

pragma solidity 0.6.12;



// Part: IGazeRewards



// Part: IUniswapV2Pair



// Part: IWETH



// Part: OpenZeppelin/[email protected]/Address

/**
 * @dev Collection of functions related to the address type
 */


// Part: OpenZeppelin/[email protected]/Context

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
 * As of v3.0.0, only sets of type `address` (`AddressSet`) and `uint256`
 * (`UintSet`) are supported.
 */


// Part: OpenZeppelin/[email protected]/IERC20

/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
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


// Part: OpenZeppelin/[email protected]/AccessControl

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

// Part: OpenZeppelin/[email protected]/SafeERC20

/**
 * @title SafeERC20
 * @dev Wrappers around ERC20 operations that throw on failure (when the token
 * contract returns false). Tokens that return no value (and instead revert or
 * throw on failure) are also supported, non-reverting calls are assumed to be
 * successful.
 * To use this library you can add a `using SafeERC20 for IERC20;` statement to your contract,
 * which allows you to call the safe operations as `token.safeTransfer(...)`, etc.
 */


// Part: UniswapV2Library



// Part: GazeAccessControls

/**
 * @notice Access Controls contract for the Gaze Platform
 * @author BlockRocket.tech
 */
contract GazeAccessControls is AccessControl {
    /// @notice Role definitions
    bytes32 public constant MINTER_ROLE = keccak256("MINTER_ROLE");
    bytes32 public constant OPERATOR_ROLE = keccak256("OPERATOR_ROLE");

    /// @notice Events for adding and removing various roles
    event AdminRoleGranted(
        address indexed beneficiary,
        address indexed caller
    );

    event AdminRoleRemoved(
        address indexed beneficiary,
        address indexed caller
    );

    event MinterRoleGranted(
        address indexed beneficiary,
        address indexed caller
    );

    event MinterRoleRemoved(
        address indexed beneficiary,
        address indexed caller
    );

    event OperatorRoleGranted(
        address indexed beneficiary,
        address indexed caller
    );

    event OperatorRoleRemoved(
        address indexed beneficiary,
        address indexed caller
    );

    /**
     * @notice The deployer is automatically given the admin role which will allow them to then grant roles to other addresses
     */
    constructor() public {
        _setupRole(DEFAULT_ADMIN_ROLE, _msgSender());
    }

    /////////////
    // Lookups //
    /////////////

    /**
     * @notice Used to check whether an address has the admin role
     * @param _address EOA or contract being checked
     * @return bool True if the account has the role or false if it does not
     */
    function hasAdminRole(address _address) external view returns (bool) {
        return hasRole(DEFAULT_ADMIN_ROLE, _address);
    }

    /**
     * @notice Used to check whether an address has the minter role
     * @param _address EOA or contract being checked
     * @return bool True if the account has the role or false if it does not
     */
    function hasMinterRole(address _address) external view returns (bool) {
        return hasRole(MINTER_ROLE, _address);
    }

    /**
     * @notice Used to check whether an address has the smart contract role
     * @param _address EOA or contract being checked
     * @return bool True if the account has the role or false if it does not
     */
    function hasOperatorRole(address _address) external view returns (bool) {
        return hasRole(OPERATOR_ROLE, _address);
    }

    ///////////////
    // Modifiers //
    ///////////////

    /**
     * @notice Grants the admin role to an address
     * @dev The sender must have the admin role
     * @param _address EOA or contract receiving the new role
     */
    function addAdminRole(address _address) external {
        grantRole(DEFAULT_ADMIN_ROLE, _address);
        emit AdminRoleGranted(_address, _msgSender());
    }

    /**
     * @notice Removes the admin role from an address
     * @dev The sender must have the admin role
     * @param _address EOA or contract affected
     */
    function removeAdminRole(address _address) external {
        revokeRole(DEFAULT_ADMIN_ROLE, _address);
        emit AdminRoleRemoved(_address, _msgSender());
    }

    /**
     * @notice Grants the minter role to an address
     * @dev The sender must have the admin role
     * @param _address EOA or contract receiving the new role
     */
    function addMinterRole(address _address) external {
        grantRole(MINTER_ROLE, _address);
        emit MinterRoleGranted(_address, _msgSender());
    }

    /**
     * @notice Removes the minter role from an address
     * @dev The sender must have the admin role
     * @param _address EOA or contract affected
     */
    function removeMinterRole(address _address) external {
        revokeRole(MINTER_ROLE, _address);
        emit MinterRoleRemoved(_address, _msgSender());
    }

    /**
     * @notice Grants the smart contract role to an address
     * @dev The sender must have the admin role
     * @param _address EOA or contract receiving the new role
     */
    function addOperatorRole(address _address) external {
        grantRole(OPERATOR_ROLE, _address);
        emit OperatorRoleGranted(_address, _msgSender());
    }

    /**
     * @notice Removes the smart contract role from an address
     * @dev The sender must have the admin role
     * @param _address EOA or contract affected
     */
    function removeOperatorRole(address _address) external {
        revokeRole(OPERATOR_ROLE, _address);
        emit OperatorRoleRemoved(_address, _msgSender());
    }
}

// File: GazeLPStaking.sol

contract GazeLPStaking {
    using SafeMath for uint256;
    using SafeERC20 for IERC20;

    /// @notice Reward token for LP staking.
    IERC20 public rewardsToken;

    /// @notice LP token to stake.
    address public lpToken;

    /// @notice WETH token.
    IWETH public WETH;

    GazeAccessControls public accessControls;
    IGazeRewards public rewardsContract;
    

    /// @notice Sets the token to be claimable or not (cannot claim if it set to false).
    bool public tokensClaimable;

    /// @notice Whether staking has been initialised or not.
    bool private initialised;
    
    /// @notice The sum of all the LP tokens staked.
    uint64 public lastUpdateTime;
    uint128 public stakedLPTotal;
    uint256 public rewardsPerTokenPoints;

    /// @notice The sum of all the unclaimed reward tokens.

    uint256 constant pointMultiplier = 10e22;

    struct Staker {
        uint256 balance;
        uint256 lastRewardPoints;
        uint128 rewardsEarned;
        uint128 rewardsReleased;
    }

    /// @notice Mapping from staker address to its current info.
    mapping (address => Staker) public stakers;



    /**
     * @notice Event emmited when a user has staked LPs.
     * @param owner Address of the staker.
     * @param amount Amount staked in LP tokens.
     */
    event Staked(address indexed owner, uint256 amount);

    /**
     * @notice Event emitted when a user has unstaked LPs.
     * @param owner Address of the unstaker.
     * @param amount Amount unstaked in LP tokens.
     */
    event Unstaked(address indexed owner, uint256 amount);

    /**
     * @notice Event emitted when a user claims rewards.
     * @param user Address of the user.
     * @param reward Reward amount.
     */
    event RewardPaid(address indexed user, uint256 reward);

    /**
     * @notice Event emitted when claimable status is updated.
     * @param status True or False.
     */
    event ClaimableStatusUpdated(bool status);

    /**
     * @notice Event emitted when user unstaked in emergency mode.
     * @param user Address of the user.
     * @param amount Amount unstaked in LP tokens.
     */
    event EmergencyUnstake(address indexed user, uint256 amount);

    /**
     * @notice Event emitted when rewards contract has been updated.
     * @param oldRewardsToken Address of the old reward token contract.
     * @param newRewardsToken Address of the new reward token contract.
     */
    event RewardsContractUpdated(address indexed oldRewardsToken, address newRewardsToken);

    /**
     * @notice Event emitted when LP token has been updated.
     * @param oldLpToken Address of the old LP token contract.
     * @param newLpToken Address of the new LP token contract.
     */
    event LpTokenUpdated(address indexed oldLpToken, address newLpToken);


    /**
     * @notice Initializes main contract variables.
     * @dev Init function.
     * @param _rewardsToken Reward token interface.
     * @param _lpToken Address of the LP token.
     * @param _WETH Wrapped Ether interface.
     * @param _accessControls Access controls interface.
     */
    function initLPStaking(
        IERC20 _rewardsToken,
        address _lpToken,
        IWETH _WETH,
        GazeAccessControls _accessControls
    ) public 
    {
        require(!initialised, "Already initialised");
        rewardsToken = _rewardsToken;
        lpToken = _lpToken;
        WETH = _WETH;
        accessControls = _accessControls;
        lastUpdateTime = uint64(block.timestamp);
        initialised = true;
    }
    
    receive() external payable {
        if(msg.sender != address(WETH)){
            zapEth();
        }
    }


     /// @notice Wrapper function zapEth() for UI 
    function zapEth() 
        public 
        payable
    {
        uint256 startBal = IERC20(lpToken).balanceOf(address(this));
        addLiquidityETHOnly(address(this));
        uint256 endBal = IERC20(lpToken).balanceOf(address(this));

        require(
            endBal > startBal ,
            "GazeStaking.zapEth: Zap amount must be greater than 0"
        );
        uint256 amount = endBal.sub(startBal);

        Staker storage staker = stakers[msg.sender];
        if (staker.balance == 0 && staker.lastRewardPoints == 0 ) {
          staker.lastRewardPoints = rewardsPerTokenPoints;
        }

        updateReward(msg.sender);
        staker.balance = staker.balance.add(amount);
        stakedLPTotal = uint128(uint256(stakedLPTotal).add(amount));
        emit Staked(msg.sender, amount);
    }


    /**
     * @notice Admin can change rewards contract through this function.
     * @param _addr Address of the new rewards contract.
     */
    function setRewardsContract(address _addr) external {
        require(accessControls.hasAdminRole(msg.sender), "GazeLPStaking.setRewardsContract: Sender must be admin");
        require(_addr != address(0));
        address oldAddr = address(rewardsContract);
        rewardsContract = IGazeRewards(_addr);
        emit RewardsContractUpdated(oldAddr, _addr);
    }

    /**
     * @notice Admin can change LP token through this function.
     * @param _addr Address of the new LP token contract.
     */
    function setLPToken(address _addr) external {
        require(accessControls.hasAdminRole(msg.sender), "GazeLPStaking.setLPToken: Sender must be admin");
        require(_addr != address(0));
        address oldAddr = lpToken;
        lpToken = _addr;
        emit LpTokenUpdated(oldAddr, _addr);
    }

    /**
     * @notice Admin can set reward tokens claimable through this function.
     * @param _enabled True or False.
     */
    function setTokensClaimable(bool _enabled) external {
        require(accessControls.hasAdminRole(msg.sender), "GazeLPStaking.setTokensClaimable: Sender must be admin");
        tokensClaimable = _enabled;
        emit ClaimableStatusUpdated(_enabled);
    }

    /**
     * @notice Function to retrieve balance of LP tokens staked by a user.
     * @param _user User address.
     * @return balance of LP tokens staked.
     */
    function getStakedBalance(address _user) external view returns (uint256 balance) {
        return stakers[_user].balance;
    }

    /// @dev Get the total ETH staked in Uniswap
    function stakedEthTotal()
        external
        view
        returns (uint256)
    {
        uint256 lpPerEth = getLPTokenPerEthUnit(1e18);
        return uint256(stakedLPTotal).mul(1e18).div(lpPerEth);
    }

    /**
     * @notice Function for staking exact amount of LP tokens.
     * @param _amount Number of LP tokens.
     */
    function stake(uint256 _amount) 
        external
    {       
            _stake(msg.sender, _amount);
    }

    function _stake(
        address _user,
        uint256 _amount
    )
        internal
    {
        require(
            _amount > 0,
            "GazeLPStaking._stake: Staked amount must be greater than 0"
        );    
    /**
     * @notice Function that executes the staking.
     * @param _user Stakers address.
     * @param _amount Number of LP tokens to stake.
     */
        Staker storage staker = stakers[_user];

        if (staker.balance == 0 && staker.lastRewardPoints == 0 ) {
          staker.lastRewardPoints = rewardsPerTokenPoints;
        }

        updateReward(_user);
        staker.balance = staker.balance.add(_amount);
        stakedLPTotal = uint128(uint256(stakedLPTotal).add(_amount));
        IERC20(lpToken).safeTransferFrom(
            address(_user),
            address(this),
            _amount
        );
        emit Staked(_user, _amount);
    }

    /**
     * @notice Function for unstaking exact amount of LP tokens.
     * @param _amount Number of LP tokens.
     */
    function unstake(uint256 _amount) external {
        _unstake(msg.sender, _amount);
    }

    // CC Either unstakeAll is missing or the unstake and _unstake could be merged into one function?

    /**
     * @notice Function that executes the unstaking.
     * @param _user Stakers address.
     * @param _amount Number of LP tokens to unstake.
     */
    function _unstake(address _user, uint256 _amount) internal {
        Staker storage staker = stakers[_user];

        require(
            staker.balance >= _amount,
            "GazeLPStaking._unstake: Sender must have staked tokens"
        );
        claimReward(_user);
        
        staker.balance = staker.balance.sub(_amount);
        stakedLPTotal = uint128(uint256(stakedLPTotal).sub(_amount));

        if (staker.balance == 0) {
            delete stakers[_user];
        }

        uint256 tokenBal = IERC20(lpToken).balanceOf(address(this));

        if (_amount > tokenBal) {
            IERC20(lpToken).safeTransfer(address(_user), tokenBal);
        } else {
            IERC20(lpToken).safeTransfer(address(_user), _amount);
        }
        emit Unstaked(_user, _amount);
    }


    /// @notice Unstake without caring about rewards. EMERGENCY ONLY.
    function emergencyUnstake() 
        external
    {
        uint256 amount = stakers[msg.sender].balance;
        stakers[msg.sender].balance = 0;
        stakers[msg.sender].rewardsEarned = 0;

        IERC20(lpToken).safeTransfer(address(msg.sender), amount);
        emit EmergencyUnstake(msg.sender, amount);
    }


    /// @dev Updates the amount of rewards owed for each user before any tokens are moved
    // TODO: revert for an non existing user?
    function updateReward(
        address _user
    ) 
        public 
    {

        rewardsContract.updateRewards();
        uint256 lpRewards = rewardsContract.LPRewards(uint256(lastUpdateTime), block.timestamp);

        if (stakedLPTotal > 0) {
            rewardsPerTokenPoints = rewardsPerTokenPoints.add(lpRewards.mul(1e18)
                        .mul(pointMultiplier)
                        .div(uint256(stakedLPTotal)));
        }
        
        lastUpdateTime = uint64(block.timestamp);
        uint256 rewards = rewardsOwing(_user);
        Staker storage staker = stakers[_user];
        if (_user != address(0)) {
            staker.rewardsEarned = uint128(uint256(staker.rewardsEarned).add(rewards));
            staker.lastRewardPoints = rewardsPerTokenPoints; 
        }
    }
     


    /// @notice Returns the rewards owing for a user
    /// @dev The rewards are dynamic and normalised from the other pools
    /// @dev This gets the rewards from each of the periods as one multiplier
    function rewardsOwing(
        address _user
    )
        public
        view
        returns(uint256)
    {
        Staker memory staker = stakers[_user];

        uint256 newRewardPerToken = rewardsPerTokenPoints.sub(staker.lastRewardPoints);
        uint256 rewards = staker.balance.mul(newRewardPerToken)
                                                .div(1e18)
                                                .div(pointMultiplier);
        return rewards;
    }


    /// @notice Returns the about of rewards yet to be claimed
    function unclaimedRewards(address _user) public view returns(uint256)
    {
        if (stakedLPTotal == 0) {
            return 0;
        }

        uint256 lpRewards = rewardsContract.LPRewards(uint256(lastUpdateTime), block.timestamp);

        uint256 newRewardPerToken = rewardsPerTokenPoints.add(lpRewards
                                                                .mul(1e18)
                                                                .mul(pointMultiplier)
                                                                .div(uint256(stakedLPTotal)))
                                                         .sub(stakers[_user].lastRewardPoints);

        uint256 rewards = stakers[_user].balance.mul(newRewardPerToken)
                                                .div(1e18)
                                                .div(pointMultiplier);
        return rewards.add(uint256(stakers[_user].rewardsEarned)).sub(uint256(stakers[_user].rewardsReleased));
    }


    /**
     * @notice Claiming rewards for user.
     * @param _user User address.
     */
    function claimReward(address _user) public {
        require(
            tokensClaimable == true,
            "Tokens cannnot be claimed yet"
        );
        updateReward(_user);

        Staker storage staker = stakers[_user];
    
        uint256 payableAmount = uint256(staker.rewardsEarned).sub(uint256(staker.rewardsReleased));
        staker.rewardsReleased = uint128(uint256(staker.rewardsReleased).add(payableAmount));

        /// @dev accounts for dust 
        uint256 rewardBal = rewardsToken.balanceOf(address(this));
        if (payableAmount > rewardBal) {
            payableAmount = rewardBal;
        }
        
        rewardsToken.safeTransfer(_user, payableAmount);
        emit RewardPaid(_user, payableAmount);
    }




     /* ========== Liquidity Zap ========== */
    //:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
    //
    // LiquidityZAP - UniswapZAP
    //   Copyright (c) 2020 deepyr.com
    //
    // UniswapZAP takes ETH and converts to a Uniswap liquidity tokens. 
    //
    // This program is free software: you can redistribute it and/or modify
    // it under the terms of the GNU General Public License as published by
    // the Free Software Foundation, either version 3 of the License
    //
    // This program is distributed in the hope that it will be useful,
    // but WITHOUT ANY WARRANTY; without even the implied warranty of
    // MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    // GNU General Public License for more details.
    //
    // You should have received a copy of the GNU General Public License
    // along with this program.  
    // If not, see <https://github.com/apguerrera/LiquidityZAP/>.
    //
    // The above copyright notice and this permission notice shall be included 
    // in all copies or substantial portions of the Software.
    //
    // Authors:
    // * Adrian Guerrera / Deepyr Pty Ltd
    // 
    // Attribution: CORE / cvault.finance
    //  https://github.com/cVault-finance/CORE-periphery/blob/master/contracts/COREv1Router.sol
    // ---------------------------------------------------------------------
    // SPDX-License-Identifier: GPL-3.0-or-later                        
    // ---------------------------------------------------------------------

    function addLiquidityETHOnly(address payable to) public payable {
        require(to != address(0), "Invalid address");

        uint256 buyAmount = msg.value.div(2);
        require(buyAmount > 0, "Insufficient ETH amount");
        WETH.deposit{value : msg.value}();

        (uint256 reserveWeth, uint256 reserveTokens) = getPairReserves();
        uint256 outTokens = UniswapV2Library.getAmountOut(buyAmount, reserveWeth, reserveTokens);
        
        WETH.transfer(lpToken, buyAmount);

        (address token0, address token1) = UniswapV2Library.sortTokens(address(WETH), address(rewardsToken));
        IUniswapV2Pair(lpToken).swap(address(rewardsToken) == token0 ? outTokens : 0, address(rewardsToken) == token1 ? outTokens : 0, address(this), "");

        _addLiquidity(outTokens, buyAmount, to);

    }

    function _addLiquidity(uint256 tokenAmount, uint256 wethAmount, address payable to) internal {
        (uint256 wethReserve, uint256 tokenReserve) = getPairReserves();

        uint256 optimalTokenAmount = UniswapV2Library.quote(wethAmount, wethReserve, tokenReserve);

        uint256 optimalWETHAmount;
        if (optimalTokenAmount > tokenAmount) {
            optimalWETHAmount = UniswapV2Library.quote(tokenAmount, tokenReserve, wethReserve);
            optimalTokenAmount = tokenAmount;
        }
        else
            optimalWETHAmount = wethAmount;

        assert(WETH.transfer(lpToken, optimalWETHAmount));
        assert(rewardsToken.transfer(lpToken, optimalTokenAmount));

        IUniswapV2Pair(lpToken).mint(to);
        
        //refund dust
        if (tokenAmount > optimalTokenAmount)
            rewardsToken.safeTransfer(to, tokenAmount.sub(optimalTokenAmount));

        if (wethAmount > optimalWETHAmount) {
            uint256 withdrawAmount = wethAmount.sub(optimalWETHAmount);
            WETH.withdraw(withdrawAmount);
            to.transfer(withdrawAmount);
        }
    }


    function getLPTokenPerEthUnit(uint ethAmt) public view  returns (uint liquidity){
        (uint256 reserveWeth, uint256 reserveTokens) = getPairReserves();
        uint256 outTokens = UniswapV2Library.getAmountOut(ethAmt.div(2), reserveWeth, reserveTokens);
        uint _totalSupply =  IUniswapV2Pair(lpToken).totalSupply();

        (address token0, ) = UniswapV2Library.sortTokens(address(WETH), address(rewardsToken));
        (uint256 amount0, uint256 amount1) = token0 == address(rewardsToken) ? (outTokens, ethAmt.div(2)) : (ethAmt.div(2), outTokens);
        (uint256 _reserve0, uint256 _reserve1) = token0 == address(rewardsToken) ? (reserveTokens, reserveWeth) : (reserveWeth, reserveTokens);
        liquidity = min(amount0.mul(_totalSupply) / _reserve0, amount1.mul(_totalSupply) / _reserve1);
    }

    function getPairReserves() internal view returns (uint256 wethReserves, uint256 tokenReserves) {
        (address token0,) = UniswapV2Library.sortTokens(address(WETH), address(rewardsToken));
        (uint256 reserve0, uint reserve1,) = IUniswapV2Pair(lpToken).getReserves();
        (wethReserves, tokenReserves) = token0 == address(rewardsToken) ? (reserve1, reserve0) : (reserve0, reserve1);
    }
    
    function min(uint256 a, uint256 b) internal pure returns (uint256 c) {
        c = a <= b ? a : b;
    }

}