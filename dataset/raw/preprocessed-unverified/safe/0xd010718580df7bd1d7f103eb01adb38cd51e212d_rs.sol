/**
 *Submitted for verification at Etherscan.io on 2020-12-30
*/

// SPDX-License-Identifier: MIT

pragma solidity ^0.7.0;

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
 * @dev Interface of the ERC20 standard as defined in the EIP.
 */


// File: node_modules\@openzeppelin\contracts\math\SafeMath.sol



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


// File: node_modules\@openzeppelin\contracts\utils\Address.sol

/**
 * @dev Collection of functions related to the address type
 */


// File: @openzeppelin\contracts\token\ERC20\ERC20.sol


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
  using Address for address;

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
  constructor (string memory name_, string memory symbol_) {
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
     * required by the EIP. See the note at the beginning of {ERC20};
     *
       * Requirements:
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
               * Requirements
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
                 * Requirements
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
}

// File: @openzeppelin\contracts\math\SafeMath.sol

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
 *   // Add the library methods
 *   using EnumerableSet for EnumerableSet.AddressSet;
 *
 *   // Declare a set state variable
 *   EnumerableSet.AddressSet private mySet;
 * }
 * ```
 *
 * As of v3.0.0, only sets of type `address` (`AddressSet`) and `uint256`
 * (`UintSet`) are supported.
 */


// File: @openzeppelin\contracts\access\AccessControl.sol


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
 *   require(hasRole(MY_ROLE, msg.sender));
 *   ...
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
   *  - if using `revokeRole`, it is the admin role bearer
   *  - if using `renounceRole`, it is the role bearer (i.e. `account`)
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

// File: contracts\EAccessControl.sol

/**
 * @title Elysia's Access Control
 * @notice Control admin and whitelisted account
 * @author Elysia
 */
contract EAccessControl is AccessControl {
  bytes32 public constant WHITELISTED = keccak256("WHITELISTED");

  /*** Admin Functions on Whitelist ***/

  /**
   * @notice Add an 'account' to the whitelist
   * @param account The address of account to add
   */
  function addAddressToWhitelist(address account) public virtual onlyAdmin {
    grantRole(WHITELISTED, account);
  }

  function addAddressesToWhitelist(address[] memory accounts)
    public
    virtual
    onlyAdmin
  {
    uint256 len = accounts.length;

    for (uint256 i = 0; i < len; i++) {
      grantRole(WHITELISTED, accounts[i]);
    }
  }

  /**
   * @notice remove an 'account' from the whitelist
   * @param account The address of account to remove
   */
  function removeAddressFromWhitelist(address account)
    public
    virtual
    onlyAdmin
  {
    revokeRole(WHITELISTED, account);
  }

  function removeAddressesFromWhitelist(address[] memory accounts)
    public
    virtual
    onlyAdmin
  {
    uint256 len = accounts.length;

    for (uint256 i = 0; i < len; i++) {
      revokeRole(WHITELISTED, accounts[i]);
    }
  }

  /*** Access Controllers ***/

  /// @dev Restricted to members of the whitelisted user.
  modifier onlyWhitelisted() {
    require(isWhitelisted(msg.sender), "Restricted to whitelisted.");
    _;
  }

  /// @dev Restricted to members of the admin role.
  modifier onlyAdmin() {
    require(isAdmin(msg.sender), "Restricted to admin.");
    _;
  }

  /// @dev Return `true` if the account belongs to whitelist.
  function isWhitelisted(address account) public virtual view returns (bool) {
      return hasRole(WHITELISTED, account);
    }

    /// @dev Return `true` if the account belongs to the admin role.
    function isAdmin(address account) public virtual view returns (bool) {
        return hasRole(DEFAULT_ADMIN_ROLE, account);
      }
}

// File: contracts\PriceManager.sol



/**
 * @title PriceManager
 * @notice Manage elysia price and asset token price
 * @author Elysia
 */
contract PriceManager is EAccessControl {
	/// @notice Emitted when el Price is changed
	event NewElPrice(uint256 newElPrice);

	/// @notice Emitted when price is changed
	event NewPrice(uint256 newPrice);

	/// @notice Emitted when price contract address is changed
	// event NewPriceContractAddress(address priceContractAddress);
	event NewSetPriceContract(address priceContractAddress);

	// USD per Elysia token
	// decimals: 18
	uint256 public _elPrice;

	// USD per Elysia Asset Token
	// decimals: 18
	uint256 public _price;

	OraclePrice public oracle_price;

	// TODO
	// Use oracle like chainlink
	function getElPrice() public view returns (uint256) {
		if(address(oracle_price) != address(0)) {
			uint256 _elOraclePrice = oracle_price.getCurrentPrice();
			return _elOraclePrice;
		} else {
			return _elPrice;
		}
	}

	function getPrice() public view returns (uint256) {
		return _price;
	}

	function setElPrice(uint256 elPrice_) external onlyAdmin returns (bool) {
		_elPrice = elPrice_;

		emit NewElPrice(elPrice_);

		return true;
	}

	function setPrice(uint256 price_) external onlyAdmin returns (bool) {
		_price = price_;

		emit NewPrice(price_);

		return true;
	}

	function toElAmount(uint256 amount) public view returns (uint256) {
		uint256 amountEl = (amount * _price * (10**18)) / _elPrice;
		require(
			(amountEl / amount) == ((_price * (10**18)) / _elPrice),
			"PriceManager: multiplication overflow"
		);

		return amountEl;
	}

	function setPriceContract(address priceContractAddress_) external onlyAdmin returns (bool) {
		oracle_price = OraclePrice(priceContractAddress_);

		emit NewSetPriceContract(priceContractAddress_);

		return true;
	}

	function getOracleContract() external view returns (address) {
		return address(oracle_price);
	}
}

contract EErc20 is Context, IERC20 {
  using SafeMath for uint256;

  mapping(address => uint256) public _balances;

  mapping(address => mapping(address => uint256)) public _allowances;

  uint256 public _totalSupply;

  string public _name;
  string public _symbol;
  uint8 public _decimals;

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
  function totalSupply() public override view returns (uint256) {
    return _totalSupply;
  }

  /**
   * @dev See {IERC20-balanceOf}.
   */
  function balanceOf(address account) public override view returns (uint256) {
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
  function transfer(address recipient, uint256 amount)
    public
    virtual
    override
    returns (bool)
  {
    _transfer(_msgSender(), recipient, amount);
    return true;
  }

  /**
   * @dev See {IERC20-allowance}.
   */
  function allowance(address owner, address spender)
    public
    virtual
    override
    view
    returns (uint256)
  {
    return _allowances[owner][spender];
  }

  /**
   * @dev See {IERC20-approve}.
   *
   * Requirements:
   *
   * - `spender` cannot be the zero address.
   */
  function approve(address spender, uint256 amount)
    public
    virtual
    override
    returns (bool)
  {
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
      _allowances[sender][_msgSender()].sub(
        amount,
        "ERC20: transfer amount exceeds allowance"
      )
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
  function increaseAllowance(address spender, uint256 addedValue)
    public
    virtual
    returns (bool)
  {
    _approve(
      _msgSender(),
      spender,
      _allowances[_msgSender()][spender].add(addedValue)
    );
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
  function decreaseAllowance(address spender, uint256 subtractedValue)
    public
    virtual
    returns (bool)
  {
    _approve(
      _msgSender(),
      spender,
      _allowances[_msgSender()][spender].sub(
        subtractedValue,
        "ERC20: decreased allowance below zero"
      )
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

    _balances[sender] = _balances[sender].sub(
      amount,
      "ERC20: transfer amount exceeds balance"
    );
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

    _balances[account] = _balances[account].sub(
      amount,
      "ERC20: burn amount exceeds balance"
    );
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
}

// File: contracts\RewardManager.sol


/**
 * @title RewardManager
 * @notice Manage rewards by _refToken and block numbers
 * @author Elysia
 */
contract RewardManager is EAccessControl {
  /// @notice Emitted when rewards per block is changed
  event NewRewardPerBlock(uint256 newRewardPerBlock);

  EErc20 public _refToken; // reftoken should be initialized by EAssetToken

  // monthlyRent$/(secondsPerMonth*averageBlockPerSecond)
  // Decimals: 18
  uint256 public _rewardPerBlock;

  // Account rewards (USD)
  // Decimals: 18
  mapping(address => uint256) private _rewards;

  // Account block numbers
  mapping(address => uint256) private _blockNumbers;

  function getRewardPerBlock() public view returns (uint256) {
    return _rewardPerBlock;
  }

  function setRewardPerBlock(uint256 rewardPerBlock_)
    external
    onlyAdmin
    returns (bool)
  {
    _rewardPerBlock = rewardPerBlock_;

    emit NewRewardPerBlock(rewardPerBlock_);

    return true;
  }

  /*** Reward functions ***/

  /**
   * @notice Get reward
   * @param account Addresss
   * @return saved reward + new reward
   */
  function getReward(address account) public view returns (uint256) {
    uint256 newReward = 0;

    if (
      _blockNumbers[account] != 0 && block.number > _blockNumbers[account]
    ) {
      newReward =
        (_refToken.balanceOf(account) *
          (block.number - _blockNumbers[account]) *
          _rewardPerBlock) /
        _refToken.totalSupply();
    }

    return newReward + _rewards[account];
  }

  function _saveReward(address account) internal returns (bool) {
    if (account == address(this)) {
      return true;
    }

    _rewards[account] = getReward(account);
    _blockNumbers[account] = block.number;

    return true;
  }

  function _clearReward(address account) internal returns (bool) {
    _rewards[account] = 0;
    _blockNumbers[account] = block.number;

    return true;
  }
}

// File: contracts\AssetToken.sol


/**
 * @title Elysia's AssetToken
 * @author Elysia
 */
contract AssetToken is EErc20, PriceManager, RewardManager {
  using SafeMath for uint256;
  ERC20 private _el;

  uint256 public _latitude;
  uint256 public _longitude;
  uint256 public _assetPrice;
  uint256 public _interestRate;

  /// @notice Emitted when an user claimed reward
  event RewardClaimed(address account, uint256 reward);

  constructor(
    ERC20 el_,
    string memory name_,
    string memory symbol_,
    uint8 decimals_,
    uint256 amount_,
    address admin_,
    uint256 elPrice_,
    uint256 price_,
    uint256 rewardPerBlock_,
    uint256 latitude_,
    uint256 longitude_,
    uint256 assetPrice_,
    uint256 interestRate_
  ){
    _el = el_;
    _name = name_;
    _symbol = symbol_;
    _decimals = decimals_;
    _elPrice = elPrice_;
    _price = price_;
    _rewardPerBlock = rewardPerBlock_;
    _latitude = latitude_;
    _longitude = longitude_;
    _assetPrice = assetPrice_;
    _interestRate = interestRate_;

    _mint(address(this), amount_);

    _setupRole(DEFAULT_ADMIN_ROLE, admin_);
    _setRoleAdmin(WHITELISTED, DEFAULT_ADMIN_ROLE);

    _refToken = this;
  }

  /**
   * @dev purchase asset token with el.
   *
   * This can be used to purchase asset token with Elysia Token (EL).
   *
   * Requirements:
   * - `amount` this contract should have more asset token than the amount.
   * - `amount` msg.sender should have more el than elAmount converted from the amount.
   */
  function purchase(uint256 amount) public returns (bool) {
    _checkBalance(msg.sender, address(this), amount);

    require(_el.transferFrom(msg.sender, address(this), toElAmount(amount)), 'EL : transferFrom failed');
    _transfer(address(this), msg.sender, amount);

    return true;
  }

  /**
   * @dev retund asset token.
   *
   * This can be used to refund asset token with Elysia Token (EL).
   *
   * Requirements:
   * - `amount` msg.sender should have more asset token than the amount.
   * - `amount` this contract should have more el than elAmount converted from the amount.
   */
  function refund(uint256 amount) public returns (bool) {
    _checkBalance(address(this), msg.sender, amount);

    require(_el.transfer(msg.sender, toElAmount(amount)), 'EL : transfer failed');
    _transfer(msg.sender, address(this), amount);

    return true;
  }


  /**
   * @dev check if buyer and seller have sufficient balance.
   *
   * This can be used to check balance of buyer and seller before swap.
   *
   * Requirements:
   * - `amount` buyer should have more asset token than the amount.
   * - `amount` seller should have more el than elAmount converted from the amount.
   */
  function _checkBalance(address buyer, address seller, uint256 amount) internal {
    require(_el.balanceOf(buyer) > toElAmount(amount), 'AssetToken: Insufficient buyer el balance.');
    require(balanceOf(seller) > amount, 'AssetToken: Insufficient seller balance.');
  }

  /**
   * @dev Claim account reward.
   *
   * This can be used to claim account accumulated rewrard with Elysia Token (EL).
   *
   * Emits a {RewardClaimed} event.
   *
   * Requirements:
   * - `elPrice` cannot be the zero.
   */
  function claimReward() external onlyWhitelisted {
    uint256 reward = getReward(msg.sender) * 10 ** 18 / _elPrice;

    require(reward < _el.balanceOf(address(this)), 'AssetToken: Insufficient seller balance.');
    _el.transfer(msg.sender, reward);
    _clearReward(msg.sender);

    emit RewardClaimed(msg.sender, reward);
  }

  /**
   * @dev tokens `amount` from `sender` to `recipient`.
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
function _transfer(address sender, address recipient, uint256 amount) internal override(EErc20) {
  require(sender != address(0), "AssetToken: transfer from the zero address");
  require(recipient != address(0), "AssetToken: transfer to the zero address");

  _beforeTokenTransfer(sender, recipient, amount);

  require(_balances[sender] >= amount, "AssetToken: transfer amount exceeds balance");

    /* RewardManager */
    _saveReward(sender);
    _saveReward(recipient);

    _balances[sender] = _balances[sender] - amount;
    _balances[recipient] = _balances[recipient].add(amount);

    emit Transfer(sender, recipient, amount);
  }

  /**
   * @dev Withdraw all El from this contract to admin
   */
  function withdrawElToAdmin() public onlyAdmin {
    _el.transfer(msg.sender, _el.balanceOf(address(this)));
  }
}