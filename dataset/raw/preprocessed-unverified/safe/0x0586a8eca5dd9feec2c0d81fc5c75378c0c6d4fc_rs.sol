/**
 *Submitted for verification at Etherscan.io on 2020-11-22
*/

// SPDX-License-Identifier: MIT
/**
 *                                          
 *      \-^-/          (((           ___      
 *      (o o)         (o o)         (o o)     
 *  ooO--(_)--Ooo-ooO--(_)--Ooo-ooO--(_)--Ooo-
 *
 *
 *   __     __) __     __) _____   
 *  (, /   /   (, /|  /   (, /  |  
 *    /   /      / | /      /---|  
 *   /   /    ) /  |/    ) /    |_ 
 *  (___(_   (_/   '    (_/        
 *
 *
 *
 * URL: unidao.org
 * Symbol: UNA
 * Decimals: 18
 * 
 */

pragma solidity 0.6.12;

// File: @openzeppelin/contracts/utils/EnumerableSet.sol

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


// File: @openzeppelin/contracts/utils/Address.sol

/**
 * @dev Collection of functions related to the address type
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
abstract contract Context {
    function _msgSender() internal view virtual returns (address payable) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes memory) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}

// File: @openzeppelin/contracts/access/AccessControl.sol


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

// File: @openzeppelin/contracts/token/ERC20/IERC20.sol


/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
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


// File: @openzeppelin/contracts/token/ERC20/SafeERC20.sol

/**
 * @title SafeERC20
 * @dev Wrappers around ERC20 operations that throw on failure (when the token
 * contract returns false). Tokens that return no value (and instead revert or
 * throw on failure) are also supported, non-reverting calls are assumed to be
 * successful.
 * To use this library you can add a `using SafeERC20 for IERC20;` statement to your contract,
 * which allows you to call the safe operations as `token.safeTransfer(...)`, etc.
 */


// File: contracts/UNIDAOVestingContract.sol

contract UNIDAOVesting is AccessControl {

    struct TokenTimelock {
        uint256 _releaseTime;
        uint256 _tokenCount;
        bool _released;
    }
    
    using SafeERC20 for IERC20;
    using SafeMath for uint256;

    IERC20 public _unaToken;

    mapping( address => TokenTimelock ) private beneficiaryAllotments;
    address[] private beneficiaries;

    event TokenVested(address indexed vestingContract, address indexed beneficiary, uint256 indexed tokenCount);
    event TokenReleased(address indexed vestingContract, address indexed beneficiary, uint256 indexed tokenCount);
    event UpdateVestingPeriod(address indexed vestingContract, address indexed beneficiary, uint256 indexed newReleaseTime);

    bytes32 public constant ALLOTER_ROLE = keccak256("ALLOTER_ROLE");

    constructor() public {

        _setupRole(DEFAULT_ADMIN_ROLE, _msgSender());
        _setupRole(ALLOTER_ROLE, _msgSender());

    }

    /**
    * @dev Get UNA token contract address.
    *
    * @return account - Address of UNA Token contract
    */
    function getTokenContract() public view returns (address) {
        return address(_unaToken);
    }

    /**
    * @dev Set UNA token contract address.
    *
    * @param _token of UNA Token contract
    */
    function setTokenContract(address _token) public {
        require(hasRole(ALLOTER_ROLE, _msgSender()), "UNAVesting: sender must be an alloter to grant");
        _unaToken = IERC20(_token);
    }

    /**
    * @dev create allotments and freeze tokens
    * @param beneficiary - Address of the beneficiary
    * @param releaseTime - time in the future till when it is locked
    * @param tokenCount - number of tokens to be alloted
    * Requirements:
    *
    * - the caller must have the alloter role. 
    */
    function allotTokens(address beneficiary, uint256 releaseTime, uint256 tokenCount) external {
        
        require(hasRole(ALLOTER_ROLE, _msgSender()), "UNAVesting: sender must be an alloter to allot tokens");
        require(beneficiary != address(0), "UNAVesting: beneficiary is zero address");

        TokenTimelock memory allotment = TokenTimelock({ _releaseTime: releaseTime,_tokenCount: tokenCount, _released: false});

        beneficiaries.push(beneficiary);
        
        beneficiaryAllotments[beneficiary]= allotment;

        emit TokenVested(address(this), beneficiary, tokenCount);
    }

    /**
    * @dev sets the release time
    * @param beneficiary - Address of the TokenTimeLock
    * @param newReleaseTime - time in the future till when it is locked
    * Requirements:
    *
    * - the caller must have the alloter role. 
    */
    function setNewReleaseTime( address beneficiary, uint256 newReleaseTime) external {
        
        require(hasRole(ALLOTER_ROLE, _msgSender()), "UNAVesting: sender must be an alloter to extend release time");
        require(beneficiary != address(0), "UNAVesting: benficairy contract is zero address");

        TokenTimelock storage allotment = beneficiaryAllotments[beneficiary];
            require(newReleaseTime >= allotment._releaseTime, "UNAVesting: newReleaseTime should be greater than older value");
            allotment._releaseTime = newReleaseTime;

            emit UpdateVestingPeriod( address(this), beneficiary, allotment._releaseTime );
    }

    /**
    * @dev releases the specified allotment if applicable
    * @param beneficiary - Address of the TokenTimeLock
    */
    function releaseBeneficiaryAllotment(address beneficiary ) public {

        require(beneficiary != address(0), "UNAVesting: benficairy contract is zero address");

        TokenTimelock storage allotment = beneficiaryAllotments[beneficiary];
        
        require(block.timestamp >= allotment._releaseTime, "UNAVesting: current time is before release time");
        require( false == allotment._released, "UNAVesting: It is already relased");
        require( allotment._tokenCount > 0, "UNAVesting: It has no tokens to release");
        
        uint256 amount = allotment._tokenCount;
        allotment._tokenCount = 0;
        allotment._released = true;

        _unaToken.safeTransfer(beneficiary, amount);
        emit TokenReleased(address(this), beneficiary, amount );
    }

    /**
    * @dev gets all the beneficiary address
    */
    function getAllBeneficiaries() external view returns (address[] memory ){
        return beneficiaries;
    }

    /**
    * @dev gets all benefeciary allotments
    */
    function getBeneficiaryAllotments(address beneficiary) external view returns ( uint256, uint256, bool ){
        TokenTimelock memory t = beneficiaryAllotments[beneficiary];

        return (t._releaseTime,t._tokenCount,t._released);
    }

    /**
    * @dev gets sender's total balance (released + locked)
    */
    function getTotalBalance() external view returns ( uint256 ){
        TokenTimelock memory allotment = beneficiaryAllotments[_msgSender()];

        uint256 balance = _unaToken.balanceOf(_msgSender());

        balance.add(allotment._tokenCount);

        return balance;
    }
}