/**
 *Submitted for verification at Etherscan.io on 2021-04-19
*/

//SPDX-License-Identifier: MIT 
pragma solidity 0.6.11; 
pragma experimental ABIEncoderV2;

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

// File: contracts\@openzeppelin\contracts\access\Ownable.sol
// License: MIT


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
contract Ownable is Context {
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


// File: contracts\@openzeppelin\contracts\token\ERC20\IERC20.sol
// License: MIT

/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
 */


// File: contracts\@openzeppelin\contracts\utils\Address.sol
// License: MIT

/**
 * @dev Collection of functions related to the address type
 */


// File: contracts\@openzeppelin\contracts\token\ERC20\SafeERC20.sol
// License: MIT




/**
 * @title SafeERC20
 * @dev Wrappers around ERC20 operations that throw on failure (when the token
 * contract returns false). Tokens that return no value (and instead revert or
 * throw on failure) are also supported, non-reverting calls are assumed to be
 * successful.
 * To use this library you can add a `using SafeERC20 for IERC20;` statement to your contract,
 * which allows you to call the safe operations as `token.safeTransfer(...)`, etc.
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

// File: contracts\Share\IShareToken.sol
// License: MIT



interface IShareToken is IERC20 {  
    function pool_mint(address m_address, uint256 m_amount) external; 
    function pool_burn_from(address b_address, uint256 b_amount) external; 
    function burn(uint256 amount) external;
}

// File: contracts\Oracle\IUniswapPairOracle.sol
// License: MIT

// Fixed window oracle that recomputes the average price for the entire period once every period
// Note that the price average is only guaranteed to be over at least 1 period, but may be over a longer period


// File: contracts\USE\IUSEStablecoin.sol
// License: MIT




// File: contracts\USE\Pools\IUSEPool.sol
// License: MIT



// File: contracts\Uniswap\Interfaces\IUniswapV2Pair.sol
// License: MIT



// File: contracts\Uniswap\Interfaces\IUniswapV2Factory.sol
// License: MIT



// File: contracts\Uniswap\Interfaces\IUniswapV2Router01.sol
// License: MIT



// File: contracts\Comptroller\ProtocolValue.sol
//License: MIT


abstract contract ProtocolValue  { 
    using SafeMath for uint256;
    using SafeERC20 for IERC20;
    uint256 public constant PERCENT = 1e6;  
    struct PCVInfo{
        //remove 
        uint256 targetTokenRemoved;
        uint256 otherTokenRemoved;
        uint256 liquidityRemoved;
        //swap
        uint256 otherTokenIn;
        uint256 targetTokenOut;
        //add
        uint256 targetTokenAdded;
        uint256 otherTokenAdded;
        uint256 liquidityAdded; 
        //remain
        uint256 targetTokenRemain;       
    }
    event PCVResult(address targetToken,address otherToken,uint256 lpp,uint256 cp,PCVInfo pcv);
    function _getPair(address router,address token0,address token1) internal view returns(address){
        address _factory =  IUniswapV2Router01(router).factory();
        return IUniswapV2Factory(_factory).getPair(token0,token1);
    }
    function _checkOrApproveRouter(address _router,address _token,uint256 _amount) internal{
        if(IERC20(_token).allowance(address(this),_router) < _amount){
            IERC20(_token).safeApprove(_router,0);
            IERC20(_token).safeApprove(_router,uint256(-1));
        }        
    }
    function _swapToken(address router,address tokenIn,address tokenOut,uint256 amountIn) internal returns (uint256){
        address[] memory path = new address[](2);
        path[0] = tokenIn;
        path[1] = tokenOut; 
        uint256 exptime = block.timestamp+60;
        _checkOrApproveRouter(router,tokenIn,amountIn); 
        return IUniswapV2Router01(router).swapExactTokensForTokens(amountIn,0,path,address(this),exptime)[1];
    }
    function _addLiquidity(
        address router,
        address tokenA,
        address tokenB,
        uint amountADesired,
        uint amountBDesired,
        uint amountAMin,
        uint amountBMin
    ) internal returns (uint amountA, uint amountB, uint liquidity){
         uint256 exptime = block.timestamp+60;
        _checkOrApproveRouter(router,tokenA,amountADesired);
        _checkOrApproveRouter(router,tokenB,amountBDesired);
        return IUniswapV2Router01(router).addLiquidity(tokenA,tokenB,amountADesired,amountBDesired,amountAMin,amountBMin,address(this), exptime);
    }
    function _removeLiquidity(
        address router,
        address pair,
        address tokenA,
        address tokenB,
        uint256 lpp 
    ) internal returns (uint amountA, uint amountB,uint256 liquidity){
        uint256 exptime = block.timestamp+60;
        liquidity = IERC20(pair).balanceOf(address(this)).mul(lpp).div(PERCENT);
        _checkOrApproveRouter(router,pair,liquidity);
        (amountA, amountB) = IUniswapV2Router01(router).removeLiquidity(tokenA,tokenB,liquidity,0,0,address(this),exptime);
    }
    function getOtherToken(address _pair,address _targetToken) public view returns(address){
        address token0 = IUniswapV2Pair(_pair).token0();
        address token1 = IUniswapV2Pair(_pair).token1(); 
        require(token0 == _targetToken || token1 == _targetToken,"!_targetToken");
        return _targetToken == token0 ? token1 : token0;
    } 
    function _protocolValue(address _router,address _pair,address _targetToken,uint256 _lpp,uint256 _cp) internal returns(uint256){
        //only guard _targetToken 
        address otherToken = getOtherToken(_pair,_targetToken); 
        PCVInfo memory pcv =  PCVInfo(0,0,0,0,0,0,0,0,0);
        //removeLiquidity 
        (pcv.targetTokenRemoved,pcv.otherTokenRemoved,pcv.liquidityRemoved) = _removeLiquidity(_router,_pair,_targetToken,otherToken,_lpp);
        //swap _targetToken
        pcv.otherTokenIn = pcv.otherTokenRemoved.mul(_cp).div(PERCENT);
        pcv.targetTokenOut = _swapToken(_router,otherToken,_targetToken,pcv.otherTokenIn);
        //addLiquidity
        uint256 otherTokenRemain  = (pcv.otherTokenRemoved).sub((pcv.otherTokenIn));
        uint256 targetTokenAmount = (pcv.targetTokenRemoved).add(pcv.targetTokenOut);        
        (pcv.targetTokenAdded, pcv.otherTokenAdded, pcv.liquidityAdded) = _addLiquidity(_router,
                                                                                        _targetToken,otherToken,
                                                                                        targetTokenAmount,otherTokenRemain,
                                                                                        0,otherTokenRemain);
        pcv.targetTokenRemain = targetTokenAmount.sub(pcv.targetTokenAdded);
        emit PCVResult(_targetToken,otherToken,_lpp,_cp,pcv);
        return pcv.targetTokenRemain;  
    }
}

// File: contracts\Comptroller\USEMasterChefPool.sol
// License: MIT

// MasterChef is the master of rewardToken. He can make rewardToken and he is a fair guy.
//
// Note that it's ownable and the owner wields tremendous power. The ownership
// will be transferred to a governance smart contract once rewardToken is sufficiently
// distributed and the community can show to govern itself.
//
// Have fun reading it. Hopefully it's bug-free. God bless.
contract USEMasterChefPool is IUSEPool,AccessControl,ProtocolValue {
    using SafeMath for uint256;
    using SafeERC20 for IERC20;
    // Info of each user.
    struct UserInfo {
        uint256 amount; // How many LP tokens the user has provided.
        uint256 rewardDebt; // Reward debt. See explanation below.
        //
        // We do some fancy math here. Basically, any point in time, the amount of rewardTokens
        // entitled to a user but is pending to be distributed is:
        //
        //   pending reward = (user.amount * pool.accrewardTokenPerShare) - user.rewardDebt
        //
        // Whenever a user deposits or withdraws LP tokens to a pool. Here's what happens:
        //   1. The pool's `accrewardTokenPerShare` (and `lastRewardBlock`) gets updated.
        //   2. User receives the pending reward sent to his/her address.
        //   3. User's `amount` gets updated.
        //   4. User's `rewardDebt` gets updated.
    }
    // Info of each pool.
    struct PoolInfo {
        IERC20 lpToken; // Address of LP token contract.
        uint256 allocPoint; // How many allocation points assigned to this pool. rewardTokens to distribute per block.
        uint256 lastRewardBlock; // Last block number that rewardTokens distribution occurs.
        uint256 accrewardTokenPerShare; // Accumulated rewardTokens per share, times 1e12. See below.
    }
    uint256 public constant PRECISION = 1e6;
    bytes32 public constant COMMUNITY_MASTER = keccak256("COMMUNITY_MASTER");
    bytes32 public constant COMMUNITY_MASTER_PCV = keccak256("COMMUNITY_MASTER_PCV");
    // The rewardToken TOKEN!
    IShareToken public rewardToken;
    address public swapRouter;
    // Dev address.
    address public communityaddr;
    uint256 public communityRateAmount; 
    // rewardToken tokens created per block.
    uint256 public rewardTokenPerBlock; 
    // Info of each pool.
    PoolInfo[] public poolInfo;
    // Info of each user that stakes LP tokens.
    mapping(uint256 => mapping(address => UserInfo)) public userInfo;
    // Total allocation poitns. Must be the sum of all allocation points in all pools.
    uint256 public totalAllocPoint = 0;
    // The block number when rewardToken mining starts.
    uint256 public startBlock;
    uint256 public miningEndBlock;
    event Deposit(address indexed user, uint256 indexed pid, uint256 amount,uint256 rewardToken);
    event Withdraw(address indexed user, uint256 indexed pid, uint256 amount,uint256 rewardToken);
    event EmergencyWithdraw(
        address indexed user,
        uint256 indexed pid,
        uint256 amount
    );
    constructor(
        address _rewardToken,
        address _communityaddr,
        address _swapRouter,
        uint256 _rewardTokenPerBlock,
        uint256 _startBlock,
        uint256 _miningEndBlock
    ) public {
        rewardToken =IShareToken(_rewardToken);
        communityaddr = _communityaddr;
        swapRouter = _swapRouter;
        rewardTokenPerBlock = _rewardTokenPerBlock; 
        startBlock = _startBlock;
        miningEndBlock = _miningEndBlock;
        _setupRole(DEFAULT_ADMIN_ROLE, _msgSender());
        grantRole(COMMUNITY_MASTER, _communityaddr);
        grantRole(COMMUNITY_MASTER_PCV, _communityaddr);        
    }
    modifier onlyAdmin(){
         require(hasRole(DEFAULT_ADMIN_ROLE, msg.sender));
         _;
    }
    modifier onlyPCVMaster(){
         require(hasRole(COMMUNITY_MASTER_PCV, msg.sender));
         _;
    }
    function collatDollarBalance() external view override returns (uint256){
         return 0;
     }
    function poolLength() external view returns (uint256) {
        return poolInfo.length;
    }
    // Add a new lp to the pool. Can only be called by the owner.
    // XXX DO NOT add the same LP token more than once. Rewards will be messed up if you do.
    function add(uint256 _allocPoint, IERC20 _lpToken, bool _withUpdate) public onlyAdmin {
        if (_withUpdate) {
            massUpdatePools();
        }
        uint256 lastRewardBlock =  block.number > startBlock ? block.number : startBlock;
        totalAllocPoint = totalAllocPoint.add(_allocPoint);
        poolInfo.push(
            PoolInfo({
                lpToken: _lpToken,
                allocPoint: _allocPoint,
                lastRewardBlock: lastRewardBlock,
                accrewardTokenPerShare: 0
            })
        );
    }
    // Update the given pool's rewardToken allocation point. Can only be called by the owner.
    function set(uint256 _pid,uint256 _allocPoint, bool _withUpdate) public onlyAdmin {
        if (_withUpdate) {
            massUpdatePools();
        }
        totalAllocPoint = totalAllocPoint.sub(poolInfo[_pid].allocPoint).add(
            _allocPoint
        );
        poolInfo[_pid].allocPoint = _allocPoint;
    }
    // Return reward multiplier over the given _from to _to block.
    function getMultiplier(uint256 _from, uint256 _to) public pure returns (uint256){
        return _to.sub(_from);
    }
    // View function to see pending rewardTokens on frontend.
    function pendingrewardToken(uint256 _pid, address _user)external view returns (uint256){
        PoolInfo storage pool = poolInfo[_pid];
        UserInfo storage user = userInfo[_pid][_user];
        uint256 accrewardTokenPerShare = pool.accrewardTokenPerShare;
        uint256 lpSupply = pool.lpToken.balanceOf(address(this));
        if (block.number > pool.lastRewardBlock && lpSupply != 0) {
            uint256 multiplier =
                getMultiplier(pool.lastRewardBlock, block.number);
            uint256 rewardTokenReward =
                multiplier.mul(rewardTokenPerBlock).mul(pool.allocPoint).div(
                    totalAllocPoint
                );
            accrewardTokenPerShare = accrewardTokenPerShare.add(
                rewardTokenReward.mul(1e12).div(lpSupply)
            );
        }
        return user.amount.mul(accrewardTokenPerShare).div(1e12).sub(user.rewardDebt);
    }
    // Update reward vairables for all pools. Be careful of gas spending!
    function massUpdatePools() public {
        uint256 length = poolInfo.length;
        for (uint256 pid = 0; pid < length; ++pid) {
            updatePool(pid);
        }
    }
    // Update reward variables of the given pool to be up-to-date.
    function updatePool(uint256 _pid) public {
        PoolInfo storage pool = poolInfo[_pid];
        if (block.number <= pool.lastRewardBlock) {
            return;
        }
        uint256 lpSupply = pool.lpToken.balanceOf(address(this));
        if (lpSupply == 0) {
            pool.lastRewardBlock = block.number;
            return;
        }
        uint256 multiplier = getMultiplier(pool.lastRewardBlock, block.number);
        uint256 rewardTokenReward = multiplier.mul(rewardTokenPerBlock).mul(pool.allocPoint).div(totalAllocPoint);
        communityRateAmount = communityRateAmount.add(rewardTokenReward.div(5));
        rewardToken.pool_mint(address(this), rewardTokenReward);
        pool.accrewardTokenPerShare = pool.accrewardTokenPerShare.add(
            rewardTokenReward.mul(1e12).div(lpSupply)
        );
        pool.lastRewardBlock = block.number;
    }
    // Deposit LP tokens to MasterChef for rewardToken allocation.
    function deposit(uint256 _pid, uint256 _amount) public {
        uint256 pending = 0;
        require(block.number > startBlock,"!!!start");
        PoolInfo storage pool = poolInfo[_pid];
        UserInfo storage user = userInfo[_pid][msg.sender];
        updatePool(_pid);
        if (user.amount > 0) {
            pending = user.amount.mul(pool.accrewardTokenPerShare).div(1e12).sub(user.rewardDebt);
            safeRewardTokenTransfer(msg.sender, pending);
        }
        //save gas for claimReward
        if(_amount > 0){
            pool.lpToken.safeTransferFrom(address(msg.sender), address(this), _amount);
            user.amount = user.amount.add(_amount);
        }
        user.rewardDebt = user.amount.mul(pool.accrewardTokenPerShare).div(1e12);
        emit Deposit(msg.sender, _pid, _amount,pending);
    }
    // Withdraw LP tokens from MasterChef.
    function withdraw(uint256 _pid, uint256 _amount) public {
        PoolInfo storage pool = poolInfo[_pid];
        UserInfo storage user = userInfo[_pid][msg.sender];
        require(user.amount >= _amount, "withdraw: not good");
        updatePool(_pid);
        uint256 pending = user.amount.mul(pool.accrewardTokenPerShare).div(1e12).sub(user.rewardDebt);
        safeRewardTokenTransfer(msg.sender, pending);
        user.amount = user.amount.sub(_amount);
        user.rewardDebt = user.amount.mul(pool.accrewardTokenPerShare).div(1e12);
        pool.lpToken.safeTransfer(address(msg.sender), _amount);
        emit Withdraw(msg.sender, _pid, _amount,pending);
    }
    function claimReward(uint256 _pid) public {
        deposit(_pid,0);
    }
    function protocolValueForUSE(address _pair,address _use,uint256 _lpp,uint256 _cp) public onlyPCVMaster{
        require(block.number >= miningEndBlock,"pcv: only start after mining");
        uint256 _useRemain =  _protocolValue(swapRouter,_pair,_use,_lpp,_cp);
        IUSEStablecoin(_use).burn(_useRemain); 
    }
    // Withdraw without caring about rewards. EMERGENCY ONLY.
    function emergencyWithdraw(uint256 _pid) public {
        PoolInfo storage pool = poolInfo[_pid];
        UserInfo storage user = userInfo[_pid][msg.sender];
        pool.lpToken.safeTransfer(address(msg.sender), user.amount);
        emit EmergencyWithdraw(msg.sender, _pid, user.amount);
        user.amount = 0;
        user.rewardDebt = 0;
    }
    // Safe rewardToken transfer function, just in case if rounding error causes pool to not have enough rewardTokens.
    function safeRewardTokenTransfer(address _to, uint256 _amount) internal {
        uint256 rewardTokenBal = rewardToken.balanceOf(address(this));
        if (_amount > rewardTokenBal) {
            rewardToken.transfer(_to, rewardTokenBal);
        } else {
            rewardToken.transfer(_to, _amount);
        }
    }
    function communityRate(uint256 _rate) public{
        require(communityRateAmount > 0,"No community rate");
        require(hasRole(COMMUNITY_MASTER, msg.sender),"!role");
        uint256 _community_amount = communityRateAmount.mul(_rate).div(PRECISION);
        communityRateAmount = communityRateAmount.sub(_community_amount);
        rewardToken.pool_mint(msg.sender,_community_amount);   
    }
    function rewardTokenRate(uint256 _rewardTokenPerBlock) public onlyAdmin{ 
         rewardTokenPerBlock = _rewardTokenPerBlock;
    }
    function updateStartBlock(uint256 _startBlock,uint256 _miningEndBlock) public onlyAdmin{ 
         startBlock = _startBlock;
         miningEndBlock = _miningEndBlock;
    }
}