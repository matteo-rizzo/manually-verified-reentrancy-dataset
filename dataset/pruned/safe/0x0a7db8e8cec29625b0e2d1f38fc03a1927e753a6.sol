/**
 *Submitted for verification at Etherscan.io on 2021-03-05
*/

// SPDX-License-Identifier: MIT

// File @openzeppelin/contracts-upgradeable/proxy/[email protected]

// solhint-disable-next-line compiler-version
pragma solidity >=0.4.24 <0.8.0;

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
        // extcodesize checks the size of the code stored in an address, and
        // address returns the current address. Since the code is still not
        // deployed when running a constructor, any checks on its code size will
        // yield zero, making it an effective way to detect if a contract is
        // under construction or not.
        address self = address(this);
        uint256 cs;
        // solhint-disable-next-line no-inline-assembly
        assembly {
            cs := extcodesize(self)
        }
        return cs == 0;
    }
}

// File @openzeppelin/contracts-upgradeable/GSN/[email protected]

pragma solidity >=0.6.0 <0.8.0;

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

// File @openzeppelin/contracts-upgradeable/token/ERC20/[email protected]

pragma solidity >=0.6.0 <0.8.0;

/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
 */


// File @openzeppelin/contracts-upgradeable/math/[email protected]

pragma solidity >=0.6.0 <0.8.0;

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


// File @openzeppelin/contracts-upgradeable/token/ERC20/[email protected]

pragma solidity >=0.6.0 <0.8.0;

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
contract ERC20Upgradeable is Initializable, ContextUpgradeable, IERC20Upgradeable {
    using SafeMathUpgradeable for uint256;

    mapping(address => uint256) private _balances;

    mapping(address => mapping(address => uint256)) private _allowances;

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
    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) public virtual override returns (bool) {
        _transfer(sender, recipient, amount);
        _approve(
            sender,
            _msgSender(),
            _allowances[sender][_msgSender()].sub(amount, "ERC20: transfer amount exceeds allowance")
        );
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
        _approve(
            _msgSender(),
            spender,
            _allowances[_msgSender()][spender].sub(subtractedValue, "ERC20: decreased allowance below zero")
        );
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
    function _transfer(
        address sender,
        address recipient,
        uint256 amount
    ) internal virtual {
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
    function _approve(
        address owner,
        address spender,
        uint256 amount
    ) internal virtual {
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
    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual {}

    uint256[44] private __gap;
}

// File contracts/interfaces/ILnAccessControl.sol

pragma solidity ^0.6.12;



// File contracts/LnAdmin.sol

pragma solidity ^0.6.12;

contract LnAdmin {
    address public admin;
    address public candidate;

    constructor(address _admin) public {
        require(_admin != address(0), "admin address cannot be 0");
        admin = _admin;
        emit AdminChanged(address(0), _admin);
    }

    function setCandidate(address _candidate) external onlyAdmin {
        address old = candidate;
        candidate = _candidate;
        emit CandidateChanged(old, candidate);
    }

    function becomeAdmin() external {
        require(msg.sender == candidate, "Only candidate can become admin");
        address old = admin;
        admin = candidate;
        emit AdminChanged(old, admin);
    }

    modifier onlyAdmin {
        require((msg.sender == admin), "Only the contract admin can perform this action");
        _;
    }

    event CandidateChanged(address oldCandidate, address newCandidate);
    event AdminChanged(address oldAdmin, address newAdmin);
}

// File contracts/interfaces/ILnAddressStorage.sol

pragma solidity ^0.6.12;



// File contracts/LnAddressCache.sol

pragma solidity ^0.6.12;

abstract contract LnAddressCache {
    function updateAddressCache(ILnAddressStorage _addressStorage) external virtual;

    event CachedAddressUpdated(bytes32 name, address addr);
}

contract testAddressCache is LnAddressCache, LnAdmin {
    address public addr1;
    address public addr2;

    constructor(address _admin) public LnAdmin(_admin) {}

    function updateAddressCache(ILnAddressStorage _addressStorage) public override onlyAdmin {
        addr1 = _addressStorage.getAddressWithRequire("a", "");
        addr2 = _addressStorage.getAddressWithRequire("b", "");
        emit CachedAddressUpdated("a", addr1);
        emit CachedAddressUpdated("b", addr2);
    }
}

// File contracts/upgradeable/LnAdminUpgradeable.sol

pragma solidity >=0.6.12 <0.8.0;

/**
 * @title LnAdminUpgradeable
 *
 * @dev This is an upgradeable version of `LnAdmin` by replacing the constructor with
 * an initializer and reserving storage slots.
 */
contract LnAdminUpgradeable is Initializable {
    event CandidateChanged(address oldCandidate, address newCandidate);
    event AdminChanged(address oldAdmin, address newAdmin);

    address public admin;
    address public candidate;

    function __LnAdminUpgradeable_init(address _admin) public initializer {
        require(_admin != address(0), "LnAdminUpgradeable: zero address");
        admin = _admin;
        emit AdminChanged(address(0), _admin);
    }

    function setCandidate(address _candidate) external onlyAdmin {
        address old = candidate;
        candidate = _candidate;
        emit CandidateChanged(old, candidate);
    }

    function becomeAdmin() external {
        require(msg.sender == candidate, "LnAdminUpgradeable: only candidate can become admin");
        address old = admin;
        admin = candidate;
        emit AdminChanged(old, admin);
    }

    modifier onlyAdmin {
        require((msg.sender == admin), "LnAdminUpgradeable: only the contract admin can perform this action");
        _;
    }

    // Reserved storage space to allow for layout changes in the future.
    uint256[48] private __gap;
}

// File contracts/LnAssetUpgradeable.sol

pragma solidity ^0.6.12;

/**
 * @title LnAssetUpgradeable
 *
 * @dev This is an upgradeable version of `LnAsset`.
 */
contract LnAssetUpgradeable is ERC20Upgradeable, LnAdminUpgradeable, LnAddressCache {
    bytes32 mKeyName;
    ILnAccessControl accessCtrl;

    bytes32 private constant ROLE_ISSUE_ASSET = "ISSUE_ASSET";
    bytes32 private constant ROLE_BURN_ASSET = "BURN_ASSET";
    bytes32 private constant ROLE_MOVE_ASSET = "MOVE_ASSET";

    modifier onlyIssueAssetRole() {
        require(accessCtrl.hasRole(ROLE_ISSUE_ASSET, msg.sender), "LnAssetUpgradeable: not ISSUE_ASSET role");
        _;
    }

    modifier onlyBurnAssetRole() {
        require(accessCtrl.hasRole(ROLE_BURN_ASSET, msg.sender), "LnAssetUpgradeable: not BURN_ASSET role");
        _;
    }

    modifier onlyMoveAssetRole() {
        require(accessCtrl.hasRole(ROLE_MOVE_ASSET, msg.sender), "LnAssetUpgradeable: not MOVE_ASSET role");
        _;
    }

    function __LnAssetUpgradeable_init(
        bytes32 _key,
        string memory _name,
        string memory _symbol,
        address _admin
    ) public initializer {
        __ERC20_init(_name, _symbol);
        __LnAdminUpgradeable_init(_admin);

        mKeyName = _key;
    }

    function keyName() external view returns (bytes32) {
        return mKeyName;
    }

    function updateAddressCache(ILnAddressStorage _addressStorage) public override onlyAdmin {
        accessCtrl = ILnAccessControl(
            _addressStorage.getAddressWithRequire("LnAccessControl", "LnAccessControl address not valid")
        );

        emit CachedAddressUpdated("LnAccessControl", address(accessCtrl));
    }

    function mint(address account, uint256 amount) external onlyIssueAssetRole {
        _mint(account, amount);
    }

    function burn(address account, uint256 amount) external onlyBurnAssetRole {
        _burn(account, amount);
    }

    function move(
        address from,
        address to,
        uint256 amount
    ) external onlyMoveAssetRole {
        _transfer(from, to, amount);
    }

    // Reserved storage space to allow for layout changes in the future.
    uint256[48] private __gap;
}