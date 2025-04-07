/**
 *Submitted for verification at Etherscan.io on 2021-05-14
*/

// ====================================================================
//     ________                   _______                           
//    / ____/ /__  ____  ____ _  / ____(_)___  ____ _____  ________ 
//   / __/ / / _ \/ __ \/ __ `/ / /_  / / __ \/ __ `/ __ \/ ___/ _ \
//  / /___/ /  __/ / / / /_/ / / __/ / / / / / /_/ / / / / /__/  __/
// /_____/_/\___/_/ /_/\__,_(_)_/   /_/_/ /_/\__,_/_/ /_/\___/\___/                                                                                                                     
//                                                                        
// ====================================================================
// ====================== Elena Protocol (USE) ========================
// ====================================================================

// Dapp    :  https://elena.finance
// Twitter :  https://twitter.com/ElenaProtocol
// Telegram:  https://t.me/ElenaFinance
// ====================================================================

//SPDX-License-Identifier: MIT 
pragma solidity 0.6.11; 
pragma experimental ABIEncoderV2;


// File: contracts\@openzeppelin\contracts\math\SafeMath.sol
// License: MIT

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


// File: contracts\@openzeppelin\contracts\utils\EnumerableSet.sol
// License: MIT

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


// File: contracts\@openzeppelin\contracts\utils\Address.sol
// License: MIT

/**
 * @dev Collection of functions related to the address type
 */


// File: contracts\@openzeppelin\contracts\GSN\Context.sol
// License: MIT

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

// File: contracts\@openzeppelin\contracts\access\AccessControl.sol
// License: MIT




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

// File: contracts\Uniswap\Interfaces\IUniswapV2Router01.sol
// License: MIT



// File: contracts\@interface\IUniswapPairOracle.sol
// License: MIT

// Fixed window oracle that recomputes the average price for the entire period once every period
// Note that the price average is only guaranteed to be over at least 1 period, but may be over a longer period


// File: contracts\@interface\IUSEStablecoin.sol
// License: MIT




// File: contracts\@interface\IUSEPool.sol
// License: MIT



// File: contracts\@interface\IUSEComptrollerPool.sol
// License: MIT



// File: contracts\Comptroller\USEComptrollerV2.sol
// License: MIT

contract USEComptrollerV2 is AccessControl{ 
    using SafeMath for uint256; 
    struct PCVResult{
       uint256 share_price_before;
       uint256 share_price_after;
       uint256 share_price_oracle_before;
       uint256 share_price_oracle_after;
       bool    redeem_paused;
    }
    uint256 public constant PERCENT = 100;
    uint256 public constant PRICE_PRECISION = 1e6;
    address public useVaultPool;
    address public comptrollerPool;  
    uint256 public sharePriceLevelPercent = 94;  //6%
    bytes32 public constant COMPTROLLER_POOL_MGR = keccak256("COMPTROLLER_POOL_MGR");
    constructor() public { 
        _setupRole(DEFAULT_ADMIN_ROLE, _msgSender());
        grantRole(COMPTROLLER_POOL_MGR, _msgSender());      
    }
    modifier onlyAuthorized{
        require(hasRole(COMPTROLLER_POOL_MGR, msg.sender),"not mgr");
        _;
    }     
    function init(address _usePool,address _elenaPool,uint256 _percent)  public onlyAuthorized{
        require(_percent > 80 && _percent < 120,"!_percent");
        useVaultPool = _usePool;
        comptrollerPool = _elenaPool; 
        sharePriceLevelPercent = _percent;
    } 
    function getOracleTimeElapsed() public view returns(uint256,uint256){
        address _use = IUSEComptrollerPool(comptrollerPool).use();
        IUniswapPairOracle _oracle1 = IUSEStablecoin(_use).USEDAIOracle();
        IUniswapPairOracle _oracle2 = IUSEStablecoin(_use).USESharesOracle();
        return(_oracle1.getTimeElapsed(),_oracle2.getTimeElapsed());
    }
    function getSharePrice() public view returns(uint256){
        address[] memory _paths = new address[](3);
        address _use = IUSEComptrollerPool(comptrollerPool).use();
        address _router =  IUSEComptrollerPool(comptrollerPool).router();
        _paths[0] = IUSEComptrollerPool(comptrollerPool).shares();
        _paths[1] = _use;
        _paths[2] = IUSEPool(useVaultPool).collateral_address();
        uint256 _amount = IUniswapV2Router01(_router).getAmountsOut(1e18,_paths)[2]; 
        return _amount.mul(PRICE_PRECISION).div(1e18);
    }
    function getShareOraclePrice() public view returns(uint256){
       address _use = IUSEComptrollerPool(comptrollerPool).use();
       return IUSEStablecoin(_use).share_price();
    }
    function addUseElenaPair(uint256 _use_amount_d18,uint256 _shares_amount_d18) public onlyAuthorized{ 
        IUSEComptrollerPool(comptrollerPool).addUseElenaPair(_use_amount_d18,_shares_amount_d18); 
    }
    function guardUSEValue(uint256 _lpp_d6) public onlyAuthorized{
        IUSEComptrollerPool(comptrollerPool).guardUSEValue(_lpp_d6); 
    }
    function protocolValueForElena(uint256 _lpp_d6,uint256 _cp_d6,uint256 _price_d6) public  onlyAuthorized returns(PCVResult memory){
        PCVResult memory _result =  PCVResult(0,0,0,0,false);
        _result.share_price_before = getSharePrice();
        _result.share_price_oracle_before = getShareOraclePrice();
        require(_result.share_price_before <= _price_d6,"price changed");  
        //pcv action      
        IUSEComptrollerPool(comptrollerPool).protocolValueForElena(_lpp_d6,_cp_d6); 
        //try update oracle
        IUSEPool(useVaultPool).updateOraclePrice();
        //pause redeem if need        
        _result.share_price_after =  getSharePrice();
        _result.share_price_oracle_after = getShareOraclePrice();
        if(IUSEPool(useVaultPool).redeemPaused() == false){
            //pause redeem for: USE--->Redeem with low sharePrice-->Sell Elena
            if(_result.share_price_oracle_after < _result.share_price_after.mul(sharePriceLevelPercent).div(PERCENT)){
                 IUSEPool(useVaultPool).toggleRedeeming();
            } 
        } 
        _result.redeem_paused = IUSEPool(useVaultPool).redeemPaused();
        return _result;
    } 
}