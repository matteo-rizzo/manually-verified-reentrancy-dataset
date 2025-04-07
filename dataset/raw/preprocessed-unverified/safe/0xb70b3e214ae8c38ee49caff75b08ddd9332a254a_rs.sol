/**
 *Submitted for verification at Etherscan.io on 2021-04-17
*/

pragma solidity 0.6.6;
pragma experimental ABIEncoderV2;


// SPDX-License-Identifier: MIT
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

// SPDX-License-Identifier: MIT
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
abstract contract Ownable is Context {
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

// SPDX-License-Identifier: MIT
/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
 */


// SPDX-License-Identifier: MIT
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


// SPDX-License-Identifier: MIT
/**
 * @dev Collection of functions related to the address type
 */


// SPDX-License-Identifier: MIT
/**
 * @title SafeERC20
 * @dev Wrappers around ERC20 operations that throw on failure (when the token
 * contract returns false). Tokens that return no value (and instead revert or
 * throw on failure) are also supported, non-reverting calls are assumed to be
 * successful.
 * To use this library you can add a `using SafeERC20 for IERC20;` statement to your contract,
 * which allows you to call the safe operations as `token.safeTransfer(...)`, etc.
 */


// SPDX-License-Identifier: MIT
abstract contract ReentrancyGuard {
    uint256 private constant _NOT_ENTERED = 1;
    uint256 private constant _ENTERED = 2;

    uint256 private _status;

    constructor() public {
        _status = _NOT_ENTERED;
    }

    modifier nonReentrant() {
        require(_status != _ENTERED, "REENTRANCY_ERROR");

        _status = _ENTERED;

        _;

        _status = _NOT_ENTERED;
    }
}

// SPDX-License-Identifier: GPL-3.0-or-later
// Interface declarations
/* solhint-disable func-order */


// SPDX-License-Identifier: GPL-3.0-or-later
// Interface declarations
/* solhint-disable func-order */


// SPDX-License-Identifier: MIT


// SPDX-License-Identifier: MIT
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


// SPDX-License-Identifier: MIT
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

// SPDX-License-Identifier: MIT
/**
 * @dev Implementation of the {IERC20} interface.
 *
 * This implementation is agnostic to the way tokens are created. This means
 * that a supply mechanism has to be added in a derived contract using {_mint}.
 * For a generic mechanism see {ERC20PresetMinterPauser}.
 *
 * TIP: For a detailed writeup see our guide
 * https://forum.zeppelin.solutions/t/how-to-implement-erc20-supply-mechanisms/226[How
 * to implement supply mechanisms].
 *
 * We have followed general OpenZeppelin guidelines: functions revert instead
 * of returning `false` on failure. This behavior is nonetheless conventional
 * and does not conflict with the expectations of ERC20 applications.
 *
 * Additionally, an {Approval} event is emitted on calls to {transferFrom}.
 * This allows applications to reconstruct the allowance for all accounts just
 * by listening to said events. Other implementations of the EIP may not emit
 * these events, as it isn't required by the specification.
 *
 * Finally, the non-standard {decreaseAllowance} and {increaseAllowance}
 * functions have been added to mitigate the well-known issues around setting
 * allowances. See {IERC20-approve}.
 */
contract ERC20 is Context, IERC20 {
    using SafeMath for uint256;

    mapping (address => uint256) private _balances;

    mapping (address => mapping (address => uint256)) private _allowances;

    uint256 private _totalSupply;

    string private _name;
    string private _symbol;
    uint8 private _decimals;

    /**
     * @dev Sets the values for {name} and {symbol}, initializes {decimals} with
     * a default value of 18.
     *
     * To select a different value for {decimals}, use {_setupDecimals}.
     *
     * All three of these values are immutable: they can only be set once during
     * construction.
     */
    constructor (string memory name_, string memory symbol_) public {
        _name = name_;
        _symbol = symbol_;
        _decimals = 18;
    }

    /**
     * @dev Returns the name of the token.
     */
    function name() public view virtual returns (string memory) {
        return _name;
    }

    /**
     * @dev Returns the symbol of the token, usually a shorter version of the
     * name.
     */
    function symbol() public view virtual returns (string memory) {
        return _symbol;
    }

    /**
     * @dev Returns the number of decimals used to get its user representation.
     * For example, if `decimals` equals `2`, a balance of `505` tokens should
     * be displayed to a user as `5,05` (`505 / 10 ** 2`).
     *
     * Tokens usually opt for a value of 18, imitating the relationship between
     * Ether and Wei. This is the value {ERC20} uses, unless {_setupDecimals} is
     * called.
     *
     * NOTE: This information is only used for _display_ purposes: it in
     * no way affects any of the arithmetic of the contract, including
     * {IERC20-balanceOf} and {IERC20-transfer}.
     */
    function decimals() public view virtual returns (uint8) {
        return _decimals;
    }

    /**
     * @dev See {IERC20-totalSupply}.
     */
    function totalSupply() public view virtual override returns (uint256) {
        return _totalSupply;
    }

    /**
     * @dev See {IERC20-balanceOf}.
     */
    function balanceOf(address account) public view virtual override returns (uint256) {
        return _balances[account];
    }

    /**
     * @dev See {IERC20-transfer}.
     *
     * Requirements:
     *
     * - `recipient` cannot be the zero address.
     * - the caller must have a balance of at least `amount`.
     */
    function transfer(address recipient, uint256 amount) public virtual override returns (bool) {
        _transfer(_msgSender(), recipient, amount);
        return true;
    }

    /**
     * @dev See {IERC20-allowance}.
     */
    function allowance(address owner, address spender) public view virtual override returns (uint256) {
        return _allowances[owner][spender];
    }

    /**
     * @dev See {IERC20-approve}.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     */
    function approve(address spender, uint256 amount) public virtual override returns (bool) {
        _approve(_msgSender(), spender, amount);
        return true;
    }

    /**
     * @dev See {IERC20-transferFrom}.
     *
     * Emits an {Approval} event indicating the updated allowance. This is not
     * required by the EIP. See the note at the beginning of {ERC20}.
     *
     * Requirements:
     *
     * - `sender` and `recipient` cannot be the zero address.
     * - `sender` must have a balance of at least `amount`.
     * - the caller must have allowance for ``sender``'s tokens of at least
     * `amount`.
     */
    function transferFrom(address sender, address recipient, uint256 amount) public virtual override returns (bool) {
        _transfer(sender, recipient, amount);
        _approve(sender, _msgSender(), _allowances[sender][_msgSender()].sub(amount, "ERC20: transfer amount exceeds allowance"));
        return true;
    }

    /**
     * @dev Atomically increases the allowance granted to `spender` by the caller.
     *
     * This is an alternative to {approve} that can be used as a mitigation for
     * problems described in {IERC20-approve}.
     *
     * Emits an {Approval} event indicating the updated allowance.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     */
    function increaseAllowance(address spender, uint256 addedValue) public virtual returns (bool) {
        _approve(_msgSender(), spender, _allowances[_msgSender()][spender].add(addedValue));
        return true;
    }

    /**
     * @dev Atomically decreases the allowance granted to `spender` by the caller.
     *
     * This is an alternative to {approve} that can be used as a mitigation for
     * problems described in {IERC20-approve}.
     *
     * Emits an {Approval} event indicating the updated allowance.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     * - `spender` must have allowance for the caller of at least
     * `subtractedValue`.
     */
    function decreaseAllowance(address spender, uint256 subtractedValue) public virtual returns (bool) {
        _approve(_msgSender(), spender, _allowances[_msgSender()][spender].sub(subtractedValue, "ERC20: decreased allowance below zero"));
        return true;
    }

    /**
     * @dev Moves tokens `amount` from `sender` to `recipient`.
     *
     * This is internal function is equivalent to {transfer}, and can be used to
     * e.g. implement automatic token fees, slashing mechanisms, etc.
     *
     * Emits a {Transfer} event.
     *
     * Requirements:
     *
     * - `sender` cannot be the zero address.
     * - `recipient` cannot be the zero address.
     * - `sender` must have a balance of at least `amount`.
     */
    function _transfer(address sender, address recipient, uint256 amount) internal virtual {
        require(sender != address(0), "ERC20: transfer from the zero address");
        require(recipient != address(0), "ERC20: transfer to the zero address");

        _beforeTokenTransfer(sender, recipient, amount);

        _balances[sender] = _balances[sender].sub(amount, "ERC20: transfer amount exceeds balance");
        _balances[recipient] = _balances[recipient].add(amount);
        emit Transfer(sender, recipient, amount);
    }

    /** @dev Creates `amount` tokens and assigns them to `account`, increasing
     * the total supply.
     *
     * Emits a {Transfer} event with `from` set to the zero address.
     *
     * Requirements:
     *
     * - `to` cannot be the zero address.
     */
    function _mint(address account, uint256 amount) internal virtual {
        require(account != address(0), "ERC20: mint to the zero address");

        _beforeTokenTransfer(address(0), account, amount);

        _totalSupply = _totalSupply.add(amount);
        _balances[account] = _balances[account].add(amount);
        emit Transfer(address(0), account, amount);
    }

    /**
     * @dev Destroys `amount` tokens from `account`, reducing the
     * total supply.
     *
     * Emits a {Transfer} event with `to` set to the zero address.
     *
     * Requirements:
     *
     * - `account` cannot be the zero address.
     * - `account` must have at least `amount` tokens.
     */
    function _burn(address account, uint256 amount) internal virtual {
        require(account != address(0), "ERC20: burn from the zero address");

        _beforeTokenTransfer(account, address(0), amount);

        _balances[account] = _balances[account].sub(amount, "ERC20: burn amount exceeds balance");
        _totalSupply = _totalSupply.sub(amount);
        emit Transfer(account, address(0), amount);
    }

    /**
     * @dev Sets `amount` as the allowance of `spender` over the `owner` s tokens.
     *
     * This internal function is equivalent to `approve`, and can be used to
     * e.g. set automatic allowances for certain subsystems, etc.
     *
     * Emits an {Approval} event.
     *
     * Requirements:
     *
     * - `owner` cannot be the zero address.
     * - `spender` cannot be the zero address.
     */
    function _approve(address owner, address spender, uint256 amount) internal virtual {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    /**
     * @dev Sets {decimals} to a value other than the default one of 18.
     *
     * WARNING: This function should only be called from the constructor. Most
     * applications that interact with token contracts will not expect
     * {decimals} to ever change, and may work incorrectly if it does.
     */
    function _setupDecimals(uint8 decimals_) internal virtual {
        _decimals = decimals_;
    }

    /**
     * @dev Hook that is called before any transfer of tokens. This includes
     * minting and burning.
     *
     * Calling conditions:
     *
     * - when `from` and `to` are both non-zero, `amount` of ``from``'s tokens
     * will be to transferred to `to`.
     * - when `from` is zero, `amount` tokens will be minted for `to`.
     * - when `to` is zero, `amount` of ``from``'s tokens will be burned.
     * - `from` and `to` are never both zero.
     *
     * To learn more about hooks, head to xref:ROOT:extending-contracts.adoc#using-hooks[Using Hooks].
     */
    function _beforeTokenTransfer(address from, address to, uint256 amount) internal virtual { }
}

// This contract is used for printing receipt tokens
// Whenever someone joins a pool, a receipt token will be printed for that person
contract ReceiptToken is ERC20, AccessControl {
    bytes32 public constant MINTER_ROLE = keccak256("MINTER_ROLE");
    bytes32 public constant BURNER_ROLE = keccak256("BURNER_ROLE");

    constructor()
        public
        ERC20("pAT", "Parachain Auction Token")
    {
        // Grant the contract deployer the default admin role: it will be able
        // to grant and revoke any roles
        _setupRole(DEFAULT_ADMIN_ROLE, msg.sender);
    }

    /**
     * @notice Mint new receipt tokens to some user
     * @param to Address of the user that gets the receipt tokens
     * @param amount Amount of receipt tokens that will get minted
    */
    function mint(address to, uint256 amount) public {
        require(
            hasRole(MINTER_ROLE, msg.sender),
            "ReceiptToken: Caller is not a minter"
        );
        _mint(to, amount);
    }

    /**
     * @notice Burn receipt tokens from some user
     * @param from Address of the user that gets the receipt tokens burne
     * @param amount Amount of receipt tokens that will get burned
    */
    function burn(address from, uint256 amount) public {
        require(
            hasRole(BURNER_ROLE, msg.sender),
            "ReceiptToken: Caller is not a burner"
        );
        _burn(from, amount);
    }
}

// SPDX-License-Identifier: MIT
/*
  |Strategy Flow| 
      - User shows up with ETH. 
      - We swap half of his ETH to DAI/USDC/USDT
      - Next step is to add liquidity to Sushiswap for ETH-USDT pair
      - Then we deposit SLPs in MasterChef and weget SUSHI rewards

    - Withdrawal flow does same thing, but backwards. 
*/
contract SushiETHSLP is Ownable, ReentrancyGuard {
    using SafeERC20 for IERC20;
    using SafeMath for uint256;

    ReceiptToken public receiptToken;
    address public token;
    address public weth;
    address public sushi;
    address payable public treasuryAddress;

    IUniswapRouter public sushiswapRouter;
    IUniswapFactory public sushiswapFactory;
    IMasterChef public masterChef;

    /// @notice Info of each user.
    struct UserInfo {
        uint256 amountEth; //amount of eth user invested
        uint256 amount; // How many SLP tokens the user has provided.
        uint256 sushiRewardDebt; // Reward debt for Sushi rewards. See explanation below.
        uint256 userTreasuryEth; //how much eth the user sent to treasury
        uint256 userCollectedFees; //how much eth the user sent to fee address
        uint256 userAccumulatedSushi; //how many rewards this user has
        uint256 amountReceiptToken; //receipt tokens printed for user; should be equal to amountfDai
        bool wasUserBlacklisted; //if user was blacklist at deposit time, he is not receiving receipt tokens
        uint256 timestamp; //first deposit timestamp; used for withdrawal lock time check
        uint256 earnedRewards; //before fees
        //
        //   pending reward = (user.amount * pool.accRewardsPerShare) - user.rewardDebt
        //
        // Whenever a user deposits or withdraws tokens to a pool. Here's what happens:
        //   1. The pool's `accRewardsPerShare` (and `lastRewardBlock`) gets updated.
        //   2. User receives the pending reward sent to his/her address.
        //   3. User's `amount` gets updated.
        //   4. User's `rewardDebt` gets updated.
    }

    mapping(address => UserInfo) public userInfo;
    mapping(address => bool) public blacklisted; //blacklisted users do not receive a receipt token

    uint256 public masterChefPoolId = 0;

    uint256 public ethDust;
    uint256 public tokenDust;
    uint256 public treasueryEthDust;
    uint256 public treasuryTokenDust;

    uint256 public cap = uint256(1000); //eth cap
    uint256 public totalEth; //total invested eth
    uint256 public ethPrice; //for UI; to be updated from a script
    uint256 public lockTime = 10368000; //120 days

    address payable public feeAddress;
    uint256 public fee = uint256(50);
    uint256 constant feeFactor = uint256(10000);

    //events
    event RewardsExchanged(
        address indexed user,
        uint256 rewardsAmount,
        uint256 obtainedEth
    );
    event RewardsEarned(address indexed user, uint256 amount);
    event FeeSet(address indexed sender, uint256 feeAmount);
    event FeeAddressSet(address indexed sender, address indexed feeAddress);

    /// @notice Event emitted when blacklist status for an address changes
    event BlacklistChanged(
        string actionType,
        address indexed user,
        bool oldVal,
        bool newVal
    );
    /// @notice Event emitted when user makes a deposit and receipt token is minted
    event ReceiptMinted(address indexed user, uint256 amount);
    /// @notice Event emitted when user withdraws and receipt token is burned
    event ReceiptBurned(address indexed user, uint256 amount);

    /// @notice Event emitted when owner changes the master chef pool id
    event PoolIdChanged(address indexed sender, uint256 oldPid, uint256 newPid);

    /// @notice Event emitted when user makes a deposit
    event Deposit(
        address indexed user,
        address indexed origin,
        uint256 pid,
        uint256 amount
    );

    /// @notice Event emitted when user withdraws
    event Withdraw(
        address indexed user,
        address indexed origin,
        uint256 pid,
        uint256 amount,
        uint256 auctionedAmount
    );

    /// @notice Event emitted when owner changes any contract address
    event ChangedAddress(
        string indexed addressType,
        address indexed oldAddress,
        address indexed newAddress
    );

    /// @notice Event emitted when owner makes a rescue dust request
    event RescuedDust(string indexed dustType, uint256 amount);

    //internal
    mapping(address => bool) public approved; //to defend against non whitelisted contracts

    /// @notice Used internally for avoiding "stack-too-deep" error when depositing
    struct DepositData {
        uint256 toSwapAmount;
        address[] swapPath;
        uint256[] swapAmounts;
        uint256 obtainedToken;
        uint256 liquidityTokenAmount;
        uint256 liquidityEthAmount;
        uint256 liquidity;
        address pair;
        uint256 pendingSushiTokens;
    }

    /// @notice Used internally for avoiding "stack-too-deep" error when withdrawing
    struct WithdrawData {
        uint256 prevSushiAmount;
        uint256 prevTokenAmount;
        uint256 prevSlpAmount;
        uint256 sushiAmount;
        uint256 tokenAmount;
        uint256 slpAmount;
        address pair;
        uint256 tokenLiquidityAmount;
        uint256 ethLiquidityAmount;
        uint256 totalToken;
        uint256 totalSushi;
        uint256 totalEth;
        uint256 feeableEth;
        uint256 auctionedEth;
        uint256 prevDustEthBalance;
        uint256 prevDustTokenBalance;
    }

    /**
     * @notice Create a new SushiETHSLP contract
     * @param _token Token address
     * @param _weth WETH address
     * @param _sushi SUSHI address
     * @param _sushiswapRouter Sushiswap Router address
     * @param _sushiswapFactory Sushiswap Factory address
     * @param _masterChef SushiSwap MasterChef address
     * @param _treasuryAddress treasury address
     * @param _receiptToken Receipt token that is minted and burned
     * @param _feeAddress fee address
     */
    constructor(
        address _token,
        address _weth,
        address _sushi,
        address _sushiswapRouter,
        address _sushiswapFactory,
        address _masterChef,
        address payable _treasuryAddress,
        uint256 _poolId,
        address _receiptToken,
        address payable _feeAddress
    ) public {
        require(_token != address(0), "token_0x0");
        require(_weth != address(0), "WETH_0x0");
        require(_sushi != address(0), "SUSHI_0x0");
        require(_sushiswapRouter != address(0), "ROUTER_0x0");
        require(_sushiswapFactory != address(0), "FACTORY_0x0");
        require(_masterChef != address(0), "CHEF_0x0");
        require(_treasuryAddress != address(0), "TREASURY_0x0");
        require(_receiptToken != address(0), "RECEIPT_0x0");
        require(_feeAddress != address(0), "FEE_0x0");

        token = _token;
        weth = _weth;
        sushi = _sushi;
        sushiswapRouter = IUniswapRouter(_sushiswapRouter);
        sushiswapFactory = IUniswapFactory(_sushiswapFactory);
        masterChef = IMasterChef(_masterChef);
        treasuryAddress = _treasuryAddress;
        masterChefPoolId = _poolId;
        receiptToken = ReceiptToken(_receiptToken);
        feeAddress = _feeAddress;
    }

    //-----------------------------------------------------------------------------------------------------------------//
    //------------------------------------ Setters -------------------------------------------------//
    //-----------------------------------------------------------------------------------------------------------------//

    /**
     * @notice Update the address of TOKEN
     * @dev Can only be called by the owner
     * @param _token Address of TOKEN
     */
    function setTokenAddress(address _token) public onlyOwner {
        require(_token != address(0), "0x0");
        emit ChangedAddress("TOKEN", address(token), address(_token));
        token = _token;
    }

    /**
     * @notice Update the address of WETH
     * @dev Can only be called by the owner
     * @param _weth Address of WETH
     */
    function setWethAddress(address _weth) public onlyOwner {
        require(_weth != address(0), "0x0");
        emit ChangedAddress("WETH", address(weth), address(_weth));
        weth = _weth;
    }

    /**
     * @notice Update the address of Sushi
     * @dev Can only be called by the owner
     * @param _sushi Address of Sushi
     */
    function setSushiAddress(address _sushi) public onlyOwner {
        require(_sushi != address(0), "0x0");
        emit ChangedAddress("SUSHI", address(sushi), address(_sushi));
        sushi = _sushi;
    }

    /**
     * @notice Update the address of Sushiswap Router
     * @dev Can only be called by the owner
     * @param _sushiswapRouter Address of Sushiswap Router
     */
    function setSushiswapRouter(address _sushiswapRouter) public onlyOwner {
        require(_sushiswapRouter != address(0), "0x0");
        emit ChangedAddress(
            "SUSHISWAP_ROUTER",
            address(sushiswapRouter),
            address(_sushiswapRouter)
        );
        sushiswapRouter = IUniswapRouter(_sushiswapRouter);
    }

    /**
     * @notice Update the address of Sushiswap Factory
     * @dev Can only be called by the owner
     * @param _sushiswapFactory Address of Sushiswap Factory
     */
    function setSushiswapFactory(address _sushiswapFactory) public onlyOwner {
        require(_sushiswapFactory != address(0), "0x0");
        emit ChangedAddress(
            "SUSHISWAP_FACTORY",
            address(sushiswapFactory),
            address(_sushiswapFactory)
        );
        sushiswapFactory = IUniswapFactory(_sushiswapFactory);
    }

    /**
     * @notice Update the address of Sushiswap Masterchef
     * @dev Can only be called by the owner
     * @param _masterChef Address of Sushiswap Masterchef
     */
    function setMasterChef(address _masterChef) public onlyOwner {
        require(_masterChef != address(0), "0x0");
        emit ChangedAddress(
            "MASTER_CHEF",
            address(masterChef),
            address(_masterChef)
        );
        masterChef = IMasterChef(_masterChef);
    }

    /**
     * @notice Update the address for fees
     * @dev Can only be called by the owner
     * @param _feeAddress Fee's address
     */
    function setTreasury(address payable _feeAddress) public onlyOwner {
        require(_feeAddress != address(0), "0x0");
        emit ChangedAddress(
            "TREASURY",
            address(treasuryAddress),
            address(_feeAddress)
        );
        treasuryAddress = _feeAddress;
    }

    /**
     * @notice Approve contract (only approved contracts or msg.sender==tx.origin can call this strategy)
     * @dev Can only be called by the owner
     * @param account Contract's address
     */
    function approveContractAccess(address account) external onlyOwner {
        require(account != address(0), "0x0");
        approved[account] = true;
    }

    /**
     * @notice Revoke contract's access (only approved contracts or msg.sender==tx.origin can call this strategy)
     * @dev Can only be called by the owner
     * @param account Contract's address
     */
    function revokeContractAccess(address account) external onlyOwner {
        require(account != address(0), "0x0");
        approved[account] = false;
    }

    /**
     * @notice Blacklist address; blacklisted addresses do not receive receipt tokens
     * @dev Can only be called by the owner
     * @param account User/contract address
     */
    function blacklistAddress(address account) external onlyOwner {
        require(account != address(0), "0x0");
        emit BlacklistChanged("BLACKLIST", account, blacklisted[account], true);
        blacklisted[account] = true;
    }

    /**
     * @notice Remove address from blacklisted addresses; blacklisted addresses do not receive receipt tokens
     * @dev Can only be called by the owner
     * @param account User/contract address
     */
    function removeFromBlacklist(address account) external onlyOwner {
        require(account != address(0), "0x0");
        emit BlacklistChanged("REMOVE", account, blacklisted[account], false);
        blacklisted[account] = false;
    }

    /**
     * @notice Set max ETH cap for this strategy
     * @dev Can only be called by the owner
     * @param _cap ETH amount
     */
    function setCap(uint256 _cap) external onlyOwner {
        cap = _cap;
    }

    /**
     * @notice Set ETH price
     * @dev Can only be called by the owner
     * @param _price ETH price
     */
    function setEthPrice(uint256 _price) external onlyOwner {
        require(_price > 0, "PRICE_0");
        ethPrice = _price;
    }

    /**
     * @notice Set lock time
     * @dev Can only be called by the owner
     * @param _lockTime lock time in seconds
     */
    function setLockTime(uint256 _lockTime) external onlyOwner {
        require(_lockTime > 0, "TIME_0");
        lockTime = _lockTime;
    }

    /**
     * @notice Update the pool id
     * @dev Can only be called by the owner
     * @param _pid pool id
     */
    function setPoolId(uint256 _pid) public onlyOwner {
        uint256 old = masterChefPoolId;
        masterChefPoolId = _pid;
        emit PoolIdChanged(msg.sender, old, _pid);
    }

    function setFeeAddress(address payable _feeAddress) public onlyOwner {
        feeAddress = _feeAddress;
        emit FeeAddressSet(msg.sender, _feeAddress);
    }

    function setFee(uint256 _fee) public onlyOwner {
        require(_fee <= uint256(9000), "FEE_TOO_HIGH");
        fee = _fee;
        emit FeeSet(msg.sender, _fee);
    }

    /**
     * @notice Rescue dust resulted from swaps/liquidity
     * @dev Can only be called by the owner
     */
    function rescueDust() public onlyOwner {
        if (ethDust > 0) {
            treasuryAddress.transfer(ethDust);
            treasueryEthDust = treasueryEthDust.add(ethDust);
            emit RescuedDust("ETH", ethDust);
            ethDust = 0;
        }
        if (tokenDust > 0) {
            IERC20(token).safeTransfer(treasuryAddress, tokenDust);
            treasuryTokenDust = treasuryTokenDust.add(tokenDust);
            emit RescuedDust("TOKEN", tokenDust);
            tokenDust = 0;
        }
    }

    /**
     * @notice Rescue any non-reward token that was airdropped to this contract
     * @dev Can only be called by the owner
     */
    function rescueAirdroppedTokens(address _token, address to)
        public
        onlyOwner
    {
        require(_token != address(0), "token_0x0");
        require(to != address(0), "to_0x0");
        require(_token != sushi, "rescue_reward_error");

        uint256 balanceOfToken = IERC20(_token).balanceOf(address(this));
        require(balanceOfToken > 0, "balance_0");

        require(IERC20(_token).transfer(to, balanceOfToken), "rescue_failed");
    }

    /**
     * @notice Check if user can withdraw based on current lock time
     * @param user Address of the user
     * @return true or false
     */
    function isWithdrawalAvailable(address user) public view returns (bool) {
        if (lockTime > 0) {
            return userInfo[user].timestamp.add(lockTime) <= block.timestamp;
        }
        return true;
    }

    /**
     * @notice Deposit to this strategy for rewards
     * @param deadline Number of blocks until transaction expires
     * @return Amount of LPs
     */
    function deposit(uint256 deadline)
        public
        payable
        nonReentrant
        returns (uint256)
    {
        // -----
        // validate
        // -----
        _defend();
        require(msg.value > 0, "ETH_0");
        require(deadline >= block.timestamp, "DEADLINE_ERROR");
        require(totalEth.add(msg.value) <= cap, "CAP_REACHED");

        uint256 prevEthBalance = address(this).balance.sub(msg.value);
        uint256 prevTokenBalance = IERC20(token).balanceOf(address(this));

        DepositData memory results;
        UserInfo storage user = userInfo[msg.sender];

        if (user.amount == 0) {
            user.wasUserBlacklisted = blacklisted[msg.sender];
        }
        if (user.timestamp == 0) {
            user.timestamp = block.timestamp;
        }
        totalEth = totalEth.add(msg.value);
        user.amountEth = user.amountEth.add(msg.value);

        // -----
        // obtain TOKEN from received ETH and add liquidity
        // -----
        results.toSwapAmount = msg.value.div(2);
        results.swapPath = new address[](2);
        results.swapPath[0] = weth;
        results.swapPath[1] = token;

        results.swapAmounts = sushiswapRouter.swapExactETHForTokens{
            value: results.toSwapAmount
        }(uint256(0), results.swapPath, address(this), deadline);

        results.obtainedToken = results.swapAmounts[
            results.swapAmounts.length - 1
        ];

        IERC20(token).safeIncreaseAllowance(
            address(sushiswapRouter),
            results.obtainedToken
        );
        (
            results.liquidityTokenAmount,
            results.liquidityEthAmount,
            results.liquidity
        ) = sushiswapRouter.addLiquidityETH{value: results.toSwapAmount}(
            token,
            results.obtainedToken,
            uint256(0),
            uint256(0),
            address(this),
            deadline
        );

        results.pair = sushiswapFactory.getPair(token, weth);

        IERC20(results.pair).safeIncreaseAllowance(
            address(masterChef),
            results.liquidity
        );

        // -----
        // deposit into master chef
        // -----
        masterChef.updatePool(masterChefPoolId);
        results.pendingSushiTokens = user
            .amount
            .mul(masterChef.poolInfo(masterChefPoolId).accSushiPerShare)
            .div(1e12)
            .sub(user.sushiRewardDebt);

        user.amount = user.amount.add(results.liquidity);
        if (!user.wasUserBlacklisted) {
            user.amountReceiptToken = user.amountReceiptToken.add(
                results.liquidity
            );
            receiptToken.mint(msg.sender, results.liquidity);
            emit ReceiptMinted(msg.sender, results.liquidity);
        }

        masterChef.updatePool(masterChefPoolId);
        user.sushiRewardDebt = user
            .amount
            .mul(masterChef.poolInfo(masterChefPoolId).accSushiPerShare)
            .div(1e12);

        uint256 prevSushiBalance = IERC20(sushi).balanceOf(address(this));

        masterChef.deposit(masterChefPoolId, results.liquidity);

        if (results.pendingSushiTokens > 0) {
            uint256 sushiBalance = IERC20(sushi).balanceOf(address(this));
            uint256 actualSushiTokens = sushiBalance.sub(prevSushiBalance);

            if (results.pendingSushiTokens > actualSushiTokens) {
                user.userAccumulatedSushi = user.userAccumulatedSushi.add(
                    actualSushiTokens
                );
            } else {
                user.userAccumulatedSushi = user.userAccumulatedSushi.add(
                    results.pendingSushiTokens
                );
            }
        }

        emit Deposit(
            msg.sender,
            tx.origin,
            masterChefPoolId,
            results.liquidity
        );

        ethDust = ethDust.add(address(this).balance.sub(prevEthBalance));
        tokenDust = tokenDust.add(
            (IERC20(token).balanceOf(address(this))).sub(prevTokenBalance)
        );

        return results.liquidity;
    }

    /**
     * @notice Withdraw tokens and claim rewards
     * @param deadline Number of blocks until transaction expires
     * @return Amount of ETH obtained
     */
    function withdraw(uint256 amount, uint256 deadline)
        public
        nonReentrant
        returns (uint256)
    {
        // -----
        // validation
        // -----
        uint256 receiptBalance = receiptToken.balanceOf(msg.sender);

        _defend();
        require(deadline >= block.timestamp, "DEADLINE_ERROR");
        require(amount > 0, "AMOUNT_0");
        UserInfo storage user = userInfo[msg.sender];
        require(user.amount >= amount, "AMOUNT_GREATER_THAN_BALANCE");
        if (!user.wasUserBlacklisted) {
            require(receiptBalance >= user.amount, "RECEIPT_AMOUNT");
        }

        if (lockTime > 0) {
            require(
                user.timestamp.add(lockTime) <= block.timestamp,
                "LOCK_TIME"
            );
        }

        WithdrawData memory results;

        results.prevDustEthBalance = address(this).balance;
        results.prevDustTokenBalance = IERC20(token).balanceOf(address(this));

        // -----
        // withdraw from sushi master chef
        // -----
        masterChef.updatePool(masterChefPoolId);
        uint256 pendingSushiTokens =
            user
                .amount
                .mul(masterChef.poolInfo(masterChefPoolId).accSushiPerShare)
                .div(1e12)
                .sub(user.sushiRewardDebt);

        (
            results.pair,
            results.tokenAmount,
            results.sushiAmount,
            results.slpAmount
        ) = _witdraw(amount);
        require(results.slpAmount > 0, "SLP_AMOUNT_0");

        user.amount = user.amount.sub(amount);
        if (!user.wasUserBlacklisted) {
            user.amountReceiptToken = user.amountReceiptToken.sub(amount);
            receiptToken.burn(msg.sender, amount);
            emit ReceiptBurned(msg.sender, amount);
        }

        user.sushiRewardDebt = user
            .amount
            .mul(masterChef.poolInfo(masterChefPoolId).accSushiPerShare)
            .div(1e12);

        uint256 sushiBalance = IERC20(sushi).balanceOf(address(this));
        if (pendingSushiTokens > 0) {
            if (pendingSushiTokens > sushiBalance) {
                user.userAccumulatedSushi = user.userAccumulatedSushi.add(
                    sushiBalance
                );
            } else {
                user.userAccumulatedSushi = user.userAccumulatedSushi.add(
                    pendingSushiTokens
                );
            }
        }

        // -----
        // remove liquidity & convert everything to ETH
        // -----
        IERC20(results.pair).safeIncreaseAllowance(
            address(sushiswapRouter),
            results.slpAmount
        );
        (
            results.tokenLiquidityAmount,
            results.ethLiquidityAmount
        ) = sushiswapRouter.removeLiquidityETH(
            token,
            results.slpAmount,
            uint256(0),
            uint256(0),
            address(this),
            deadline
        );

        require(results.tokenLiquidityAmount > 0, "TOKEN_LIQUIDITY_0");
        require(results.ethLiquidityAmount > 0, "ETH_LIQUIDITY_0");

        results.totalSushi = user.userAccumulatedSushi;
        results.totalToken = results.totalToken.add(
            results.tokenLiquidityAmount
        );
        results.totalEth = results.ethLiquidityAmount;

        //swap sushi with eth
        address[] memory swapPath = new address[](2);
        swapPath[0] = sushi;
        swapPath[1] = weth;

        if (results.totalSushi > 0) {
            emit RewardsEarned(msg.sender, results.totalSushi);
            user.earnedRewards = user.earnedRewards.add(results.totalSushi);

            IERC20(sushi).safeIncreaseAllowance(
                address(sushiswapRouter),
                results.totalSushi
            );

            uint256[] memory sushiSwapAmounts =
                sushiswapRouter.swapExactTokensForETH(
                    results.totalSushi,
                    uint256(0),
                    swapPath,
                    address(this),
                    deadline
                );

            emit RewardsExchanged(
                msg.sender,
                results.totalSushi,
                sushiSwapAmounts[sushiSwapAmounts.length - 1]
            );
            results.feeableEth = results.feeableEth.add(
                sushiSwapAmounts[sushiSwapAmounts.length - 1]
            );
        }

        if (results.totalToken > 0) {
            IERC20(token).safeIncreaseAllowance(
                address(sushiswapRouter),
                results.totalToken
            );
            swapPath[0] = token;

            uint256[] memory tokenSwapAmounts =
                sushiswapRouter.swapExactTokensForETH(
                    results.totalToken,
                    uint256(0),
                    swapPath,
                    address(this),
                    deadline
                );

            results.totalEth = results.totalEth.add(
                tokenSwapAmounts[tokenSwapAmounts.length - 1]
            );
        }

        // -----
        // transfer ETH to user
        // -----
        results.auctionedEth = results.feeableEth.div(2);
        results.feeableEth = results.feeableEth.sub(results.auctionedEth);
        results.totalEth = results.totalEth.add(results.feeableEth);

        if (user.amountEth > results.totalEth) {
            user.amountEth = user.amountEth.sub(results.totalEth);
        } else {
            user.amountEth = 0;
        }

        if (results.totalEth < totalEth) {
            totalEth = totalEth.sub(results.totalEth);
        } else {
            totalEth = 0;
        }

        //at some point we might not have any fees
        if (fee > 0) {
            uint256 feeEth = _calculateFee(results.totalEth);
            results.totalEth = results.totalEth.sub(feeEth);

            feeAddress.transfer(feeEth);
            user.userCollectedFees = user.userCollectedFees.add(feeEth);
        }

        msg.sender.transfer(results.totalEth);

        treasuryAddress.transfer(results.auctionedEth);
        user.userTreasuryEth = user.userTreasuryEth.add(results.auctionedEth);

        emit Withdraw(
            msg.sender,
            tx.origin,
            masterChefPoolId,
            results.totalEth,
            results.auctionedEth
        );
        user.userAccumulatedSushi = 0;

        ethDust = ethDust.add(
            address(this).balance.sub(results.prevDustEthBalance)
        );
        tokenDust = tokenDust.add(
            (IERC20(token).balanceOf(address(this))).sub(
                results.prevDustTokenBalance
            )
        );

        return results.totalEth;
    }

    function _witdraw(uint256 amount)
        private
        returns (
            address,
            uint256,
            uint256,
            uint256
        )
    {
        WithdrawData memory results;
        results.pair = sushiswapFactory.getPair(token, weth);

        results.prevTokenAmount = IERC20(token).balanceOf(address(this));
        results.prevSushiAmount = IERC20(sushi).balanceOf(address(this));
        results.prevSlpAmount = IERC20(results.pair).balanceOf(address(this));

        masterChef.updatePool(masterChefPoolId);
        masterChef.withdraw(masterChefPoolId, amount);

        results.tokenAmount = (IERC20(token).balanceOf(address(this))).sub(
            results.prevTokenAmount
        );
        results.sushiAmount = (IERC20(sushi).balanceOf(address(this))).sub(
            results.prevSushiAmount
        );
        results.slpAmount = (IERC20(results.pair).balanceOf(address(this))).sub(
            results.prevSlpAmount
        );

        return (
            results.pair,
            results.tokenAmount,
            results.sushiAmount,
            results.slpAmount
        );
    }

    //-----------------------------------------------------------------------------------------------------------------//
    //------------------------------------ Getters -------------------------------------------------//
    //-----------------------------------------------------------------------------------------------------------------//
    /**
     * @notice View function to see pending rewards for account.
     * @param account user account to check
     * @return pending rewards
     */
    function getPendingRewards(address account) public view returns (uint256) {
        UserInfo storage user = userInfo[account];
        IMasterChef.PoolInfo memory sushiPool =
            masterChef.poolInfo(masterChefPoolId);
        uint256 sushiPerBlock = masterChef.sushiPerBlock();
        uint256 totalSushiAllocPoint = masterChef.totalAllocPoint();
        uint256 accSushiPerShare = sushiPool.accSushiPerShare;
        uint256 lpSupply = sushiPool.lpToken.balanceOf(address(masterChef));

        if (block.number > sushiPool.lastRewardBlock && lpSupply != 0) {
            uint256 multiplier =
                masterChef.getMultiplier(
                    sushiPool.lastRewardBlock,
                    block.number
                );
            uint256 sushiReward =
                multiplier.mul(sushiPerBlock).mul(sushiPool.allocPoint).div(
                    totalSushiAllocPoint
                );
            accSushiPerShare = accSushiPerShare.add(
                sushiReward.mul(1e12).div(lpSupply)
            );
        }

        uint256 accumulatedSushi = user.amount.mul(accSushiPerShare).div(1e12);

        if (accumulatedSushi < user.sushiRewardDebt) {
            return 0;
        }

        return accumulatedSushi.sub(user.sushiRewardDebt);
    }

    function _calculateFee(uint256 amount) private view returns (uint256) {
        return (amount.mul(fee)).div(feeFactor);
    }

    /// @notice Private method to check if contract is approved or this strategy is called by a normal user
    function _defend() private view returns (bool) {
        require(
            approved[msg.sender] || msg.sender == tx.origin,
            "access_denied"
        );
    }

    receive() external payable {}
}