/**
 *Submitted for verification at Etherscan.io on 2021-03-08
*/

pragma solidity ^0.7.6;



















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
        // extcodesize checks the size of the code stored in an address, and
        // address returns the current address. Since the code is still not
        // deployed when running a constructor, any checks on its code size will
        // yield zero, making it an effective way to detect if a contract is
        // under construction or not.
        address self = address(this);
        uint256 cs;
        // solhint-disable-next-line no-inline-assembly
        assembly { cs := extcodesize(self) }
        return cs == 0;
    }
}


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
    function paused() public view returns (bool) {
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
        require(!_paused, "Pausable: paused");
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
        require(_paused, "Pausable: not paused");
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





contract ERC20Upgradeable is Initializable, ContextUpgradeable, IERC20Upgradeable {
    using SafeMathUpgradeable for uint256;

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
    function __ERC20_init(string memory name_, string memory symbol_) internal initializer {
        __Context_init_unchained();
        __ERC20_init_unchained(name_, symbol_);
    }

    function __ERC20_init_unchained(string memory name_, string memory symbol_) internal initializer {
        _name = name_;
        _symbol = symbol_;
        _decimals = 18;
    }

    /**
     * @dev Returns the name of the token.
     */
    function name() public view returns (string memory) {
        return _name;
    }

    /**
     * @dev Returns the symbol of the token, usually a shorter version of the
     * name.
     */
    function symbol() public view returns (string memory) {
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
    function decimals() public view returns (uint8) {
        return _decimals;
    }

    /**
     * @dev See {IERC20-totalSupply}.
     */
    function totalSupply() public view override returns (uint256) {
        return _totalSupply;
    }

    /**
     * @dev See {IERC20-balanceOf}.
     */
    function balanceOf(address account) public view override returns (uint256) {
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
    function _setupDecimals(uint8 decimals_) internal {
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
    uint256[44] private __gap;
}




abstract contract ERC20PausableUpgradeable is Initializable, ERC20Upgradeable, PausableUpgradeable {
    function __ERC20Pausable_init() internal initializer {
        __Context_init_unchained();
        __Pausable_init_unchained();
        __ERC20Pausable_init_unchained();
    }

    function __ERC20Pausable_init_unchained() internal initializer {
    }
    /**
     * @dev See {ERC20-_beforeTokenTransfer}.
     *
     * Requirements:
     *
     * - the contract must not be paused.
     */
    function _beforeTokenTransfer(address from, address to, uint256 amount) internal virtual override {
        super._beforeTokenTransfer(from, to, amount);

        require(!paused(), "ERC20Pausable: token transfer while paused");
    }
    uint256[50] private __gap;
}





abstract contract ERC20BurnableUpgradeable is Initializable, ContextUpgradeable, ERC20Upgradeable {
    function __ERC20Burnable_init() internal initializer {
        __Context_init_unchained();
        __ERC20Burnable_init_unchained();
    }

    function __ERC20Burnable_init_unchained() internal initializer {
    }
    using SafeMathUpgradeable for uint256;

    /**
     * @dev Destroys `amount` tokens from the caller.
     *
     * See {ERC20-_burn}.
     */
    function burn(uint256 amount) public virtual {
        _burn(_msgSender(), amount);
    }

    /**
     * @dev Destroys `amount` tokens from `account`, deducting from the caller's
     * allowance.
     *
     * See {ERC20-_burn} and {ERC20-allowance}.
     *
     * Requirements:
     *
     * - the caller must have allowance for ``accounts``'s tokens of at least
     * `amount`.
     */
    function burnFrom(address account, uint256 amount) public virtual {
        uint256 decreasedAllowance = allowance(account, _msgSender()).sub(amount, "ERC20: burn amount exceeds allowance");

        _approve(account, _msgSender(), decreasedAllowance);
        _burn(account, amount);
    }
    uint256[50] private __gap;
}




abstract contract AccessControlUpgradeable is Initializable, ContextUpgradeable {
    function __AccessControl_init() internal initializer {
        __Context_init_unchained();
        __AccessControl_init_unchained();
    }

    function __AccessControl_init_unchained() internal initializer {
    }
    using EnumerableSetUpgradeable for EnumerableSetUpgradeable.AddressSet;
    using AddressUpgradeable for address;

    struct RoleData {
        EnumerableSetUpgradeable.AddressSet members;
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
    uint256[49] private __gap;
}















/**
 * @dev Collection of functions related to the address type
 */




/**
 * @title Proxy
 * @dev Implements delegation of calls to other contracts, with proper
 * forwarding of return values and bubbling of failures.
 * It defines a fallback function that delegates all calls to the address
 * returned by the abstract _implementation() internal function.
 */
abstract contract Proxy {
/**
 * @dev Fallback function.
 * Implemented entirely in `_fallback`.
 */
fallback () payable external {
_fallback();
}

/**
 * @return The Address of the implementation.
 */
function _implementation() internal virtual view returns (address);

/**
 * @dev Delegates execution to an implementation contract.
 * This is a low level function that doesn't return to its internal call site.
 * It will return to the external caller whatever the implementation returns.
 * @param implementation Address to delegate.
 */
function _delegate(address implementation) internal {
assembly {
// Copy msg.data. We take full control of memory in this inline assembly
// block because it will not return to Solidity code. We overwrite the
// Solidity scratch pad at memory position 0.
calldatacopy(0, 0, calldatasize())

// Call the implementation.
// out and outsize are 0 because we don't know the size yet.
let result := delegatecall(gas(), implementation, 0, calldatasize(), 0, 0)

// Copy the returned data.
returndatacopy(0, 0, returndatasize())

switch result
// delegatecall returns 0 on error.
case 0 { revert(0, returndatasize()) }
default { return(0, returndatasize()) }
}
}

/**
 * @dev Function that is run as the first thing in the fallback function.
 * Can be redefined in derived contracts to add functionality.
 * Redefinitions must call super._willFallback().
 */
function _willFallback() internal virtual {
}

/**
 * @dev fallback implementation.
 * Extracted to enable manual triggering.
 */
function _fallback() internal {
_willFallback();
_delegate(_implementation());
}
}



/**
 * @title BaseUpgradeabilityProxy
 * @dev This contract implements a proxy that allows to change the
 * implementation address to which it will delegate.
 * Such a change is called an implementation upgrade.
 */
contract BaseUpgradeabilityProxy is Proxy {
/**
 * @dev Emitted when the implementation is upgraded.
 * @param implementation Address of the new implementation.
 */
event Upgraded(address indexed implementation);

/**
 * @dev Storage slot with the address of the current implementation.
 * This is the keccak-256 hash of "eip1967.proxy.implementation" subtracted by 1, and is
 * validated in the constructor.
 */
bytes32 internal constant IMPLEMENTATION_SLOT = 0x360894a13ba1a3210667c828492db98dca3e2076cc3735a920a3ca505d382bbc;

/**
 * @dev Returns the current implementation.
 * @return impl Address of the current implementation
 */
function _implementation() internal override view returns (address impl) {
bytes32 slot = IMPLEMENTATION_SLOT;
assembly {
impl := sload(slot)
}
}

/**
 * @dev Upgrades the proxy to a new implementation.
 * @param newImplementation Address of the new implementation.
 */
function _upgradeTo(address newImplementation) internal {
_setImplementation(newImplementation);
emit Upgraded(newImplementation);
}

/**
 * @dev Sets the implementation address of the proxy.
 * @param newImplementation Address of the new implementation.
 */
function _setImplementation(address newImplementation) internal {
require(Address.isContract(newImplementation), "Cannot set a proxy implementation to a non-contract address");

bytes32 slot = IMPLEMENTATION_SLOT;

assembly {
sstore(slot, newImplementation)
}
}
}






/**
 * @title UpgradeabilityProxy
 * @dev Extends BaseUpgradeabilityProxy with a constructor for initializing
 * implementation and init data.
 */
contract UpgradeabilityProxy is BaseUpgradeabilityProxy {
/**
 * @dev Contract constructor.
 * @param _logic Address of the initial implementation.
 * @param _data Data to send as msg.data to the implementation to initialize the proxied contract.
 * It should include the signature and the parameters of the function to be called, as described in
 * https://solidity.readthedocs.io/en/v0.4.24/abi-spec.html#function-selector-and-argument-encoding.
 * This parameter is optional, if no data is given the initialization call to proxied contract will be skipped.
 */
constructor(address _logic, bytes memory _data) public payable {
assert(IMPLEMENTATION_SLOT == bytes32(uint256(keccak256('eip1967.proxy.implementation')) - 1));
_setImplementation(_logic);
if(_data.length > 0) {
(bool success,) = _logic.delegatecall(_data);
require(success);
}
}
}




/**
 * @title BaseAdminUpgradeabilityProxy
 * @dev This contract combines an upgradeability proxy with an authorization
 * mechanism for administrative tasks.
 * All external functions in this contract must be guarded by the
 * `ifAdmin` modifier. See ethereum/solidity#3864 for a Solidity
 * feature proposal that would enable this to be done automatically.
 */
contract BaseAdminUpgradeabilityProxy is BaseUpgradeabilityProxy {
/**
 * @dev Emitted when the administration has been transferred.
 * @param previousAdmin Address of the previous admin.
 * @param newAdmin Address of the new admin.
 */
event AdminChanged(address previousAdmin, address newAdmin);

/**
 * @dev Storage slot with the admin of the contract.
 * This is the keccak-256 hash of "eip1967.proxy.admin" subtracted by 1, and is
 * validated in the constructor.
 */

bytes32 internal constant ADMIN_SLOT = 0xb53127684a568b3173ae13b9f8a6016e243e63b6e8ee1178d6a717850b5d6103;

/**
 * @dev Modifier to check whether the `msg.sender` is the admin.
 * If it is, it will run the function. Otherwise, it will delegate the call
 * to the implementation.
 */
modifier ifAdmin() {
if (msg.sender == _admin()) {
_;
} else {
_fallback();
}
}

/**
 * @return The address of the proxy admin.
 */
function admin() external ifAdmin returns (address) {
return _admin();
}

/**
 * @return The address of the implementation.
 */
function implementation() external ifAdmin returns (address) {
return _implementation();
}

/**
 * @dev Changes the admin of the proxy.
 * Only the current admin can call this function.
 * @param newAdmin Address to transfer proxy administration to.
 */
function changeAdmin(address newAdmin) external ifAdmin {
require(newAdmin != address(0), "Cannot change the admin of a proxy to the zero address");
emit AdminChanged(_admin(), newAdmin);
_setAdmin(newAdmin);
}

/**
 * @dev Upgrade the backing implementation of the proxy.
 * Only the admin can call this function.
 * @param newImplementation Address of the new implementation.
 */
function upgradeTo(address newImplementation) external ifAdmin {
_upgradeTo(newImplementation);
}

/**
 * @dev Upgrade the backing implementation of the proxy and call a function
 * on the new implementation.
 * This is useful to initialize the proxied contract.
 * @param newImplementation Address of the new implementation.
 * @param data Data to send as msg.data in the low level call.
 * It should include the signature and the parameters of the function to be called, as described in
 * https://solidity.readthedocs.io/en/v0.4.24/abi-spec.html#function-selector-and-argument-encoding.
 */
function upgradeToAndCall(address newImplementation, bytes calldata data) payable external ifAdmin {
_upgradeTo(newImplementation);
(bool success,) = newImplementation.delegatecall(data);
require(success);
}

/**
 * @return adm The admin slot.
 */
function _admin() internal view returns (address adm) {
bytes32 slot = ADMIN_SLOT;
assembly {
adm := sload(slot)
}
}

/**
 * @dev Sets the address of the proxy admin.
 * @param newAdmin Address of the new proxy admin.
 */
function _setAdmin(address newAdmin) internal {
bytes32 slot = ADMIN_SLOT;

assembly {
sstore(slot, newAdmin)
}
}

/**
 * @dev Only fall back when the sender is not the admin.
 */
function _willFallback() internal override virtual {
require(msg.sender != _admin(), "Cannot call fallback function from the proxy admin");
super._willFallback();
}
}





/**
 * @title InitializableUpgradeabilityProxy
 * @dev Extends BaseUpgradeabilityProxy with an initializer for initializing
 * implementation and init data.
 */
contract InitializableUpgradeabilityProxy is BaseUpgradeabilityProxy {
/**
* @dev Contract initializer.
* @param _logic Address of the initial implementation.
* @param _data Data to send as msg.data to the implementation to initialize the proxied contract.
* It should include the signature and the parameters of the function to be called, as described in
* https://solidity.readthedocs.io/en/v0.4.24/abi-spec.html#function-selector-and-argument-encoding.
* This parameter is optional, if no data is given the initialization call to proxied contract will be skipped.
*/
function initialize(address _logic, bytes memory _data) public payable {
require(_implementation() == address(0));
assert(IMPLEMENTATION_SLOT == bytes32(uint256(keccak256("eip1967.proxy.implementation")) - 1));
_setImplementation(_logic);
if (_data.length > 0) {
(bool success, ) = _logic.delegatecall(_data);
require(success);
}
}
}










contract PUNDIXTokenProxy is BaseAdminUpgradeabilityProxy, InitializableUpgradeabilityProxy {
/**
* Contract initializer.
* @param _logic address of the initial implementation.
* @param _admin Address of the proxy administrator.
* @param _data Data to send as msg.data to the implementation to initialize the proxied contract.
* It should include the signature and the parameters of the function to be called, as described in
* https://solidity.readthedocs.io/en/v0.4.24/abi-spec.html#function-selector-and-argument-encoding.
* This parameter is optional, if no data is given the initialization call to proxied contract will be skipped.
*/
function initialize(address _logic, address _admin, bytes memory _data) public payable {
require(_implementation() == address(0));
InitializableUpgradeabilityProxy.initialize(_logic, _data);
assert(ADMIN_SLOT == bytes32(uint256(keccak256("eip1967.proxy.admin")) - 1));
_setAdmin(_admin);
}

/**
* @dev Only fall back when the sender is not the admin.
*/
function _willFallback() internal override(BaseAdminUpgradeabilityProxy, Proxy) {
BaseAdminUpgradeabilityProxy._willFallback();
}

}














abstract contract EIP712Upgradeable is Initializable {
/* solhint-disable var-name-mixedcase */
bytes32 private _HASHED_NAME;
bytes32 private _HASHED_VERSION;
bytes32 private constant _TYPE_HASH = keccak256("EIP712Domain(string name,string version,uint256 chainId,address verifyingContract)");
/* solhint-enable var-name-mixedcase */

/**
 * @dev Initializes the domain separator and parameter caches.
 *
 * The meaning of `name` and `version` is specified in
 * https://eips.ethereum.org/EIPS/eip-712#definition-of-domainseparator[EIP 712]:
 *
 * - `name`: the user readable name of the signing domain, i.e. the name of the DApp or the protocol.
 * - `version`: the current major version of the signing domain.
 *
 * NOTE: These parameters cannot be changed except through a xref:learn::upgrading-smart-contracts.adoc[smart
 * contract upgrade].
 */
function __EIP712_init(string memory name, string memory version) internal initializer {
__EIP712_init_unchained(name, version);
}

function __EIP712_init_unchained(string memory name, string memory version) internal initializer {
bytes32 hashedName = keccak256(bytes(name));
bytes32 hashedVersion = keccak256(bytes(version));
_HASHED_NAME = hashedName;
_HASHED_VERSION = hashedVersion;
}

/**
 * @dev Returns the domain separator for the current chain.
 */
function _domainSeparatorV4() internal view returns (bytes32) {
return _buildDomainSeparator(_TYPE_HASH, _EIP712NameHash(), _EIP712VersionHash());
}

function _buildDomainSeparator(bytes32 typeHash, bytes32 name, bytes32 version) private view returns (bytes32) {
return keccak256(
abi.encode(
typeHash,
name,
version,
_getChainId(),
address(this)
)
);
}

/**
 * @dev Given an already https://eips.ethereum.org/EIPS/eip-712#definition-of-hashstruct[hashed struct], this
 * function returns the hash of the fully encoded EIP712 message for this domain.
 *
 * This hash can be used together with {ECDSA-recover} to obtain the signer of a message. For example:
 *
 * ```solidity
 * bytes32 digest = _hashTypedDataV4(keccak256(abi.encode(
 *     keccak256("Mail(address to,string contents)"),
 *     mailTo,
 *     keccak256(bytes(mailContents))
 * )));
 * address signer = ECDSA.recover(digest, signature);
 * ```
 */
function _hashTypedDataV4(bytes32 structHash) internal view virtual returns (bytes32) {
return keccak256(abi.encodePacked("\x19\x01", _domainSeparatorV4(), structHash));
}

function _getChainId() private view returns (uint256 chainId) {
this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
// solhint-disable-next-line no-inline-assembly
assembly {
chainId := chainid()
}
}

/**
 * @dev The hash of the name parameter for the EIP712 domain.
 *
 * NOTE: This function reads from storage by default, but can be redefined to return a constant value if gas costs
 * are a concern.
 */
function _EIP712NameHash() internal virtual view returns (bytes32) {
return _HASHED_NAME;
}

/**
 * @dev The hash of the version parameter for the EIP712 domain.
 *
 * NOTE: This function reads from storage by default, but can be redefined to return a constant value if gas costs
 * are a concern.
 */
function _EIP712VersionHash() internal virtual view returns (bytes32) {
return _HASHED_VERSION;
}
uint256[50] private __gap;
}







abstract contract ERC20PermitUpgradeable is Initializable, ERC20Upgradeable, IERC20PermitUpgradeable, EIP712Upgradeable {
using CountersUpgradeable for CountersUpgradeable.Counter;

mapping (address => CountersUpgradeable.Counter) private _nonces;

// solhint-disable-next-line var-name-mixedcase
bytes32 private _PERMIT_TYPEHASH;

/**
 * @dev Initializes the {EIP712} domain separator using the `name` parameter, and setting `version` to `"1"`.
 *
 * It's a good idea to use the same `name` that is defined as the ERC20 token name.
 */
function __ERC20Permit_init(string memory name) internal initializer {
__Context_init_unchained();
__EIP712_init_unchained(name, "1");
__ERC20Permit_init_unchained(name);
}

function __ERC20Permit_init_unchained(string memory name) internal initializer {
_PERMIT_TYPEHASH = keccak256("Permit(address owner,address spender,uint256 value,uint256 nonce,uint256 deadline)");
}

/**
 * @dev See {IERC20Permit-permit}.
 */
function permit(address owner, address spender, uint256 value, uint256 deadline, uint8 v, bytes32 r, bytes32 s) public virtual override {
// solhint-disable-next-line not-rely-on-time
require(block.timestamp <= deadline, "ERC20Permit: expired deadline");

bytes32 structHash = keccak256(
abi.encode(
_PERMIT_TYPEHASH,
owner,
spender,
value,
_nonces[owner].current(),
deadline
)
);

bytes32 hash = _hashTypedDataV4(structHash);

address signer = ECDSAUpgradeable.recover(hash, v, r, s);
require(signer == owner, "ERC20Permit: invalid signature");

_nonces[owner].increment();
_approve(owner, spender, value);
}

/**
 * @dev See {IERC20Permit-nonces}.
 */
function nonces(address owner) public view override returns (uint256) {
return _nonces[owner].current();
}

/**
 * @dev See {IERC20Permit-DOMAIN_SEPARATOR}.
 */
// solhint-disable-next-line func-name-mixedcase
function DOMAIN_SEPARATOR() external view override returns (bytes32) {
return _domainSeparatorV4();
}
uint256[49] private __gap;
}









contract TokenRecipient {

    function tokenFallback(address _sender, uint256 _value, bytes memory _extraData) public virtual returns (bool) {}

}




contract PUNDIXToken is Initializable, ContextUpgradeable, AccessControlUpgradeable, ERC20BurnableUpgradeable, ERC20PausableUpgradeable, ERC20PermitUpgradeable {


    bytes32 public constant ADMIN_ROLE = keccak256("ADMIN_ROLE");



    function initialize(address to) public virtual initializer {
        __Context_init_unchained();
        __AccessControl_init_unchained();
        __ERC20_init_unchained("Pundi X Token", "PUNDIX");
        __ERC20Burnable_init_unchained();
        __Pausable_init_unchained();
        __ERC20Pausable_init_unchained();
        __ERC20Permit_init("PUNDIX");

        _setupRole(DEFAULT_ADMIN_ROLE, _msgSender());
        _setupRole(ADMIN_ROLE, _msgSender());

        _mint(to, 258498693019069996455928086);
    }




    function _beforeTokenTransfer(address from, address to, uint256 amount) internal virtual override(ERC20Upgradeable, ERC20PausableUpgradeable) {
        super._beforeTokenTransfer(from, to, amount);
    }



    function pause() public virtual {
        require(hasRole(ADMIN_ROLE, _msgSender()), "must have admin role to pause");
        _pause();
    }

    function unpause() public virtual {
        require(hasRole(ADMIN_ROLE, _msgSender()), "must have admin role to unpause");
        _unpause();
    }




    function transferERCToken(address tokenContractAddress, address to, uint256 amount) public {
        require(hasRole(ADMIN_ROLE, _msgSender()), "must have admin role to transfer other ERC20");
        require(IERC20Upgradeable(tokenContractAddress).transfer(to, amount));
    }


    function transferAndCall(address recipient, uint256 amount, bytes memory data) public {
        require(recipient != address(0), "transfer to the zero address");
        require(amount <= balanceOf(recipient), "insufficient balance");
        transfer(recipient, amount);
        require(TokenRecipient(recipient).tokenFallback(msg.sender, amount, data));
    }
}