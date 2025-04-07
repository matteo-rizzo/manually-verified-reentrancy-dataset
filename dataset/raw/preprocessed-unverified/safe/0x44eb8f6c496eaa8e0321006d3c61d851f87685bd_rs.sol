/**
 *Submitted for verification at Etherscan.io on 2021-07-03
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

/*
ðŸŒŽ Website: https://Lambo.DefiFactory.finance
ðŸ‘‰ Telegram: https://t.me/LamboTokenOwners
*/

struct TaxAmountsInput {
    address sender;
    address recipient;
    uint transferAmount;
    uint senderRealBalance;
    uint recipientRealBalance;
}
struct TaxAmountsOutput {
    uint senderRealBalance;
    uint recipientRealBalance;
    uint burnAndRewardAmount;
    uint recipientGetsAmount;
}
struct TemporaryReferralRealAmountsBulk {
    address addr;
    uint realBalance;
}



/*
 * @dev Provides information about the current execution context, including the
 * sender of the transaction and its data. While these are generally available
 * via msg.sender and msg.data, they should not be accessed in such a direct
 * manner, since when dealing with meta-transactions the account sending and
 * paying for execution may not be the actual sender (as far as an application
 * is concerned).
 *
 * This contract is only required for intermediate, library-like contracts.
 */
abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}

/**
 * @dev String operations.
 */


/**
 * @dev Interface of the ERC165 standard, as defined in the
 * https://eips.ethereum.org/EIPS/eip-165[EIP].
 *
 * Implementers can declare support of contract interfaces, which can then be
 * queried by others ({ERC165Checker}).
 *
 * For an implementation, see {ERC165}.
 */


/**
 * @dev Implementation of the {IERC165} interface.
 *
 * Contracts that want to implement ERC165 should inherit from this contract and override {supportsInterface} to check
 * for the additional interface id that will be supported. For example:
 *
 * ```solidity
 * function supportsInterface(bytes4 interfaceId) public view virtual override returns (bool) {
 *     return interfaceId == type(MyInterface).interfaceId || super.supportsInterface(interfaceId);
 * }
 * ```
 *
 * Alternatively, {ERC165Storage} provides an easier to use but more expensive implementation.
 */
abstract contract ERC165 is IERC165 {
    /**
     * @dev See {IERC165-supportsInterface}.
     */
    function supportsInterface(bytes4 interfaceId) public view virtual override returns (bool) {
        return interfaceId == type(IERC165).interfaceId;
    }
}

/**
 * @dev External interface of AccessControl declared to support ERC165 detection.
 */


/**
 * @dev Contract module that allows children to implement role-based access
 * control mechanisms. This is a lightweight version that doesn't allow enumerating role
 * members except through off-chain means by accessing the contract event logs. Some
 * applications may benefit from on-chain enumerability, for those cases see
 * {AccessControlEnumerable}.
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
 * By default, the admin role for all roles is `ROLE_ADMIN`, which means
 * that only accounts with this role will be able to grant or revoke other
 * roles. More complex role relationships can be created by using
 * {_setRoleAdmin}.
 *
 * WARNING: The `ROLE_ADMIN` is also its own admin: it has permission to
 * grant and revoke this role. Extra precautions should be taken to secure
 * accounts that have been granted it.
 */
abstract contract AccessControl is Context, IAccessControl, ERC165 {
    struct RoleData {
        mapping (address => bool) members;
        bytes32 adminRole;
    }

    mapping (bytes32 => RoleData) private _roles;

    bytes32 public constant ROLE_ADMIN = 0x00;

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
     * @dev Modifier that checks that an account has a specific role. Reverts
     * with a standardized message including the required role.
     *
     * The format of the revert reason is given by the following regular expression:
     *
     *  /^AccessControl: account (0x[0-9a-f]{20}) is missing role (0x[0-9a-f]{32})$/
     *
     * _Available since v4.1._
     */
    modifier onlyRole(bytes32 role) {
        _checkRole(role, _msgSender());
        _;
    }

    /**
     * @dev See {IERC165-supportsInterface}.
     */
    function supportsInterface(bytes4 interfaceId) public view virtual override returns (bool) {
        return interfaceId == type(IAccessControl).interfaceId
            || super.supportsInterface(interfaceId);
    }

    /**
     * @dev Returns `true` if `account` has been granted `role`.
     */
    function hasRole(bytes32 role, address account) public view override returns (bool) {
        return _roles[role].members[account];
    }

    /**
     * @dev Revert with a standard message if `account` is missing `role`.
     *
     * The format of the revert reason is given by the following regular expression:
     *
     *  /^AccessControl: account (0x[0-9a-f]{20}) is missing role (0x[0-9a-f]{32})$/
     */
    function _checkRole(bytes32 role, address account) internal view {
        if(!hasRole(role, account)) {
            revert(string(abi.encodePacked(
                "AccessControl: account ",
                Strings.toHexString(uint160(account), 20),
                " is missing role ",
                Strings.toHexString(uint256(role), 32)
            )));
        }
    }

    /**
     * @dev Returns the admin role that controls `role`. See {grantRole} and
     * {revokeRole}.
     *
     * To change a role's admin, use {_setRoleAdmin}.
     */
    function getRoleAdmin(bytes32 role) public view override returns (bytes32) {
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
    function grantRole(bytes32 role, address account) public virtual override onlyRole(getRoleAdmin(role)) {
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
    function revokeRole(bytes32 role, address account) public virtual override onlyRole(getRoleAdmin(role)) {
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
    function renounceRole(bytes32 role, address account) public virtual override {
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
        emit RoleAdminChanged(role, getRoleAdmin(role), adminRole);
        _roles[role].adminRole = adminRole;
    }

    function _grantRole(bytes32 role, address account) private {
        if (!hasRole(role, account)) {
            _roles[role].members[account] = true;
            emit RoleGranted(role, account, _msgSender());
        }
    }

    function _revokeRole(bytes32 role, address account) private {
        if (hasRole(role, account)) {
            _roles[role].members[account] = false;
            emit RoleRevoked(role, account, _msgSender());
        }
    }
}

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
 * @dev External interface of AccessControlEnumerable declared to support ERC165 detection.
 */


/**
 * @dev Extension of {AccessControl} that allows enumerating the members of each role.
 */
abstract contract AccessControlEnumerable is IAccessControlEnumerable, AccessControl {
    using EnumerableSet for EnumerableSet.AddressSet;

    mapping (bytes32 => EnumerableSet.AddressSet) private _roleMembers;

    /**
     * @dev See {IERC165-supportsInterface}.
     */
    function supportsInterface(bytes4 interfaceId) public view virtual override returns (bool) {
        return interfaceId == type(IAccessControlEnumerable).interfaceId
            || super.supportsInterface(interfaceId);
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
    function getRoleMember(bytes32 role, uint256 index) public view override returns (address) {
        return _roleMembers[role].at(index);
    }

    /**
     * @dev Returns the number of accounts that have `role`. Can be used
     * together with {getRoleMember} to enumerate all bearers of a role.
     */
    function getRoleMemberCount(bytes32 role) public view override returns (uint256) {
        return _roleMembers[role].length();
    }

    /**
     * @dev Overload {grantRole} to track enumerable memberships
     */
    function grantRole(bytes32 role, address account) public virtual override {
        super.grantRole(role, account);
        _roleMembers[role].add(account);
    }

    /**
     * @dev Overload {revokeRole} to track enumerable memberships
     */
    function revokeRole(bytes32 role, address account) public virtual override {
        super.revokeRole(role, account);
        _roleMembers[role].remove(account);
    }

    /**
     * @dev Overload {renounceRole} to track enumerable memberships
     */
    function renounceRole(bytes32 role, address account) public virtual override {
        super.renounceRole(role, account);
        _roleMembers[role].remove(account);
    }

    /**
     * @dev Overload {_setupRole} to track enumerable memberships
     */
    function _setupRole(bytes32 role, address account) internal virtual override {
        super._setupRole(role, account);
        _roleMembers[role].add(account);
    }
}

/**
 * @dev Interface of the ERC20 Permit extension allowing approvals to be made via signatures, as defined in
 * https://eips.ethereum.org/EIPS/eip-2612[EIP-2612].
 *
 * Adds the {permit} method, which can be used to change an account's ERC20 allowance (see {IERC20-allowance}) by
 * presenting a message signed by the account. By not relying on {IERC20-approve}, the token holder account doesn't
 * need to send a transaction, and thus is not required to hold Ether at all.
 */


/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
 */


/**
 * @dev Interface for the optional metadata functions from the ERC20 standard.
 *
 * _Available since v4.1._
 */
interface IERC20Metadata is IERC20 {
    /**
     * @dev Returns the name of the token.
     */
    function name() external view returns (string memory);

    /**
     * @dev Returns the symbol of the token.
     */
    function symbol() external view returns (string memory);

    /**
     * @dev Returns the decimals places of the token.
     */
    function decimals() external view returns (uint8);
}

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
contract ERC20Mod is Context, IERC20, IERC20Metadata {
    mapping (address => uint256) internal _RealBalances;

    mapping (address => mapping (address => uint256)) internal _allowances;


    string internal _name;
    string internal _symbol;

    /**
     * @dev Sets the values for {name} and {symbol}.
     *
     * The defaut value of {decimals} is 18. To select a different value for
     * {decimals} you should overload it.
     *
     * All two of these values are immutable: they can only be set once during
     * construction.
     */
    constructor (string memory name_, string memory symbol_) {
        _name = name_;
        _symbol = symbol_;
    }

    /**
     * @dev Returns the name of the token.
     */
    function name() public view virtual override returns (string memory) {
        return _name;
    }

    /**
     * @dev Returns the symbol of the token, usually a shorter version of the
     * name.
     */
    function symbol() public view virtual override returns (string memory) {
        return _symbol;
    }

    /**
     * @dev Returns the number of decimals used to get its user representation.
     * For example, if `decimals` equals `2`, a balance of `505` tokens should
     * be displayed to a user as `5,05` (`505 / 10 ** 2`).
     *
     * Tokens usually opt for a value of 18, imitating the relationship between
     * Ether and Wei. This is the value {ERC20} uses, unless this function is
     * overridden;
     *
     * NOTE: This information is only used for _display_ purposes: it in
     * no way affects any of the arithmetic of the contract, including
     * {IERC20-balanceOf} and {IERC20-transfer}.
     */
    function decimals() public view virtual override returns (uint8) {
        return 18;
    }

    /**
     * @dev See {IERC20-totalSupply}.
     */
    function totalSupply() public view virtual override returns (uint256) {
        // overriden in parent contract
    }

    /**
     * @dev See {IERC20-balanceOf}.
     */
    function balanceOf(address account) public view virtual override returns (uint256) {
        return _RealBalances[account];
    }

    /**
     * @dev See {IERC20-transfer}.
     *
     * Requirements:
     *
     * - `recipient` cannot be the zero address.
     * - the caller must have a balance of at least `amount`.
     */
    function transfer(address recipient, uint256 amount) public virtual override returns (bool) { }

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
    function transferFrom(address sender, address recipient, uint256 amount) public virtual override returns (bool) { }

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
        _approve(_msgSender(), spender, _allowances[_msgSender()][spender] + addedValue);
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
        uint256 currentAllowance = _allowances[_msgSender()][spender];
        require(currentAllowance >= subtractedValue, "ERC20: decreased allowance below zero");
        _approve(_msgSender(), spender, currentAllowance - subtractedValue);

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
    function _transfer(address sender, address recipient, uint256 amount) internal virtual { }


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
}


/**
 * @dev Elliptic Curve Digital Signature Algorithm (ECDSA) operations.
 *
 * These functions can be used to verify that a message was signed by the holder
 * of the private keys of a given address.
 */


/**
 * @dev https://eips.ethereum.org/EIPS/eip-712[EIP 712] is a standard for hashing and signing of typed structured data.
 *
 * The encoding specified in the EIP is very generic, and such a generic implementation in Solidity is not feasible,
 * thus this contract does not implement the encoding itself. Protocols need to implement the type-specific encoding
 * they need in their contracts using a combination of `abi.encode` and `keccak256`.
 *
 * This contract implements the EIP 712 domain separator ({_domainSeparatorV4}) that is used as part of the encoding
 * scheme, and the final step of the encoding to obtain the message digest that is then signed via ECDSA
 * ({_hashTypedDataV4}).
 *
 * The implementation of the domain separator was designed to be as efficient as possible while still properly updating
 * the chain id to protect against replay attacks on an eventual fork of the chain.
 *
 * NOTE: This contract implements the version of the encoding known as "v4", as implemented by the JSON RPC method
 * https://docs.metamask.io/guide/signing-data.html[`eth_signTypedDataV4` in MetaMask].
 *
 * _Available since v3.4._
 */
abstract contract EIP712 {
    /* solhint-disable var-name-mixedcase */
    // Cache the domain separator as an immutable value, but also store the chain id that it corresponds to, in order to
    // invalidate the cached domain separator if the chain id changes.
    bytes32 private immutable _CACHED_DOMAIN_SEPARATOR;
    uint256 private immutable _CACHED_CHAIN_ID;

    bytes32 private immutable _HASHED_NAME;
    bytes32 private immutable _HASHED_VERSION;
    bytes32 private immutable _TYPE_HASH;
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
    constructor(string memory name, string memory version) {
        bytes32 hashedName = keccak256(bytes(name));
        bytes32 hashedVersion = keccak256(bytes(version));
        bytes32 typeHash = keccak256("EIP712Domain(string name,string version,uint256 chainId,address verifyingContract)");
        _HASHED_NAME = hashedName;
        _HASHED_VERSION = hashedVersion;
        _CACHED_CHAIN_ID = block.chainid;
        _CACHED_DOMAIN_SEPARATOR = _buildDomainSeparator(typeHash, hashedName, hashedVersion);
        _TYPE_HASH = typeHash;
    }

    /**
     * @dev Returns the domain separator for the current chain.
     */
    function _domainSeparatorV4() internal view returns (bytes32) {
        if (block.chainid == _CACHED_CHAIN_ID) {
            return _CACHED_DOMAIN_SEPARATOR;
        } else {
            return _buildDomainSeparator(_TYPE_HASH, _HASHED_NAME, _HASHED_VERSION);
        }
    }

    function _buildDomainSeparator(bytes32 typeHash, bytes32 name, bytes32 version) private view returns (bytes32) {
        return keccak256(
            abi.encode(
                typeHash,
                name,
                version,
                block.chainid,
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
        return ECDSA.toTypedDataHash(_domainSeparatorV4(), structHash);
    }
}

/**
 * @title Counters
 * @author Matt Condon (@shrugs)
 * @dev Provides counters that can only be incremented or decremented by one. This can be used e.g. to track the number
 * of elements in a mapping, issuing ERC721 ids, or counting request ids.
 *
 * Include with `using Counters for Counters.Counter;`
 */


/**
 * @dev Implementation of the ERC20 Permit extension allowing approvals to be made via signatures, as defined in
 * https://eips.ethereum.org/EIPS/eip-2612[EIP-2612].
 *
 * Adds the {permit} method, which can be used to change an account's ERC20 allowance (see {IERC20-allowance}) by
 * presenting a message signed by the account. By not relying on `{IERC20-approve}`, the token holder account doesn't
 * need to send a transaction, and thus is not required to hold Ether at all.
 *
 * _Available since v3.4._
 */
abstract contract ERC20Permit is ERC20Mod, IERC20Permit, EIP712 {
    using Counters for Counters.Counter;

    mapping (address => Counters.Counter) private _nonces;

    // solhint-disable-next-line var-name-mixedcase
    bytes32 private immutable _PERMIT_TYPEHASH = keccak256("Permit(address owner,address spender,uint256 value,uint256 nonce,uint256 deadline)");

    /**
     * @dev Initializes the {EIP712} domain separator using the `name` parameter, and setting `version` to `"1"`.
     *
     * It's a good idea to use the same `name` that is defined as the ERC20 token name.
     */
    constructor(string memory name) EIP712(name, "1") {
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
                _useNonce(owner),
                deadline
            )
        );

        bytes32 hash = _hashTypedDataV4(structHash);

        address signer = ECDSA.recover(hash, v, r, s);
        require(signer == owner, "ERC20Permit: invalid signature");

        _approve(owner, spender, value);
    }

    /**
     * @dev See {IERC20Permit-nonces}.
     */
    function nonces(address owner) public view virtual override returns (uint256) {
        return _nonces[owner].current();
    }

    /**
     * @dev See {IERC20Permit-DOMAIN_SEPARATOR}.
     */
    // solhint-disable-next-line func-name-mixedcase
    function DOMAIN_SEPARATOR() external view override returns (bytes32) {
        return _domainSeparatorV4();
    }

    /**
     * @dev "Consume a nonce": return the current value and increment.
     *
     * _Available since v4.1._
     */
    function _useNonce(address owner) internal virtual returns (uint256 current) {
        Counters.Counter storage nonce = _nonces[owner];
        current = nonce.current();
        nonce.increment();
    }
}

contract LamboToken is Context, AccessControlEnumerable, ERC20Mod, ERC20Permit {
    bytes32 public constant ROLE_MINTER = keccak256("ROLE_MINTER");
    bytes32 public constant ROLE_BURNER = keccak256("ROLE_BURNER");
    bytes32 public constant ROLE_TRANSFERER = keccak256("ROLE_TRANSFERER");
    bytes32 public constant ROLE_MODERATOR = keccak256("ROLE_MODERATOR");
    bytes32 public constant ROLE_TAXER = keccak256("ROLE_TAXER");
    
    uint constant NOBOTS_TECH_CONTRACT_ID = 0;
    uint constant TEAM_VESTING_CONTRACT_ID = 1;
    
    address[] utilsContracts;
    
    struct AccessSettings {
        bool isMinter;
        bool isBurner;
        bool isTransferer;
        bool isModerator;
        bool isTaxer;
        
        address addr;
    }
    
    bool public isPaused;
    
    address constant BURN_ADDRESS = address(0x0);
    address constant DEAD_ADDRESS = 0xdEad000000000000000000000000000000000000;
    
    event VestedAmountClaimed(address recipient, uint amount);
    event UpdatedUtilsContracts(AccessSettings[] accessSettings);
    event TransferCustom(address sender, address recipient, uint amount);
    event MintHumanAddress(address recipient, uint amount);
    event BurnHumanAddress(address sender, uint amount);
    
    event MintedByBridge(address recipient, uint amount);
    event BurnedByBridge(address sender, uint amount);

    constructor() 
        ERC20Mod("Lambo Token t.me/LamboTokenOwners", "LAMBO") 
        ERC20Permit("Lambo Token")
    {
        _setupRole(ROLE_ADMIN, _msgSender());
        _setupRole(ROLE_MINTER, _msgSender());
        _setupRole(ROLE_BURNER, _msgSender());
        _setupRole(ROLE_TRANSFERER, _msgSender());
        _setupRole(ROLE_MODERATOR, _msgSender());
        _setupRole(ROLE_TAXER, _msgSender());
    }
    
    modifier notPausedContract {
        require(
            !isPaused,
            "T: paused"
        );
        _;
    }
    
    modifier pausedContract {
        require(
            isPaused,
            "T: !paused"
        );
        _;
    }
    
    function updateNameAndSymbol(string calldata __name, string calldata __symbol)
        external
        onlyRole(ROLE_ADMIN)
    {
        _name = __name;
        _symbol = __symbol;
    }
    
    function balanceOf(address account) 
        public 
        view 
        override 
        returns(uint) 
    {
        return INoBotsTech(utilsContracts[NOBOTS_TECH_CONTRACT_ID]).
            getBalance(account, _RealBalances[account]);
    }
    
    function totalSupply() 
        public 
        view 
        override 
        returns (uint) 
    {
        return INoBotsTech(utilsContracts[NOBOTS_TECH_CONTRACT_ID]).
            getTotalSupply();
    }
    
    function pauseContract()
        external
        notPausedContract
        onlyRole(ROLE_ADMIN)
    {
        isPaused = true;
    }
    
    function resumeContract()
        external
        pausedContract
        onlyRole(ROLE_ADMIN)
    {
        isPaused = false;
    }
    
    function transfer(address recipient, uint256 amount) 
        public 
        notPausedContract
        virtual 
        override 
        returns (bool) 
    {
        _transfer(_msgSender(), recipient, amount);
        return true;
    }
    
    function transferFrom(address sender, address recipient, uint256 amount) 
        public 
        notPausedContract
        virtual 
        override 
        returns (bool) 
    {
        require(
            sender != BURN_ADDRESS,
            "T: !burn"
        );
        _transfer(sender, recipient, amount);

        uint256 currentAllowance = _allowances[sender][_msgSender()];
        require(currentAllowance >= amount, "T: transfer amount exceeds allowance");
        _approve(sender, _msgSender(), currentAllowance - amount);

        return true;
    }
    
    function moderatorTransferFromWhilePaused(address sender, address recipient, uint256 amount) 
        external 
        pausedContract
        onlyRole(ROLE_MODERATOR)
        returns (bool) 
    {
        require(
            sender != BURN_ADDRESS,
            "T: !burn"
        );
        _transfer(sender, recipient, amount);

        return true;
    }
    
    function transferCustom(address sender, address recipient, uint256 amount)
        external
        notPausedContract
        onlyRole(ROLE_TRANSFERER)
    {
        require(
            sender != BURN_ADDRESS,
            "T: !burn"
        );
        _transfer(sender, recipient, amount);
        
        emit TransferCustom(sender, recipient, amount);
    }
    
    function _transfer(address sender, address recipient, uint amount) 
        internal
        virtual 
        override 
    {
        require(
            recipient != BURN_ADDRESS,
            "T: !burn"
        );
        require(
            sender != recipient,
            "T: !self"
        );
        
        INoBotsTech iNoBotsTech = INoBotsTech(utilsContracts[NOBOTS_TECH_CONTRACT_ID]);
        TaxAmountsOutput memory taxAmountsOutput = iNoBotsTech.prepareTaxAmounts(
            TaxAmountsInput(
                sender,
                recipient,
                amount,
                _RealBalances[sender],
                _RealBalances[recipient]
            )
        );
        
        _RealBalances[sender] = taxAmountsOutput.senderRealBalance;
        _RealBalances[recipient] = taxAmountsOutput.recipientRealBalance;
        
        emit Transfer(sender, recipient, taxAmountsOutput.recipientGetsAmount);
        if (taxAmountsOutput.burnAndRewardAmount > 0)
        {
            emit Transfer(sender, BURN_ADDRESS, taxAmountsOutput.burnAndRewardAmount);
        }
    }
    
    function transferFromTeamVestingContract(address recipient, uint256 amount)
        external
        notPausedContract
    {
        address vestingContract = utilsContracts[TEAM_VESTING_CONTRACT_ID];
        require(vestingContract == _msgSender(), "T: !VESTING_CONTRACT");
        
        INoBotsTech iNoBotsTech = INoBotsTech(utilsContracts[NOBOTS_TECH_CONTRACT_ID]);
        _RealBalances[vestingContract] -= amount;
        _RealBalances[recipient] += 
            iNoBotsTech.getRealBalanceTeamVestingContract(amount);
        
        iNoBotsTech.publicForcedUpdateCacheMultiplier();
        
        emit Transfer(vestingContract, recipient, amount);
        emit VestedAmountClaimed(recipient, amount);
    }
    
    function chargeCustomTax(address from, uint amount)
        external
        notPausedContract
        onlyRole(ROLE_TAXER)
    {
        uint balanceBefore = _RealBalances[from];
        
        INoBotsTech iNoBotsTech = INoBotsTech(utilsContracts[NOBOTS_TECH_CONTRACT_ID]);
        _RealBalances[from] = iNoBotsTech.chargeCustomTax(amount, balanceBefore);
        
        uint taxAmount = iNoBotsTech.getBalance(from, balanceBefore - _RealBalances[from]);
        emit Transfer(from, address(0), taxAmount);
    }
    
    function updateUtilsContracts(AccessSettings[] calldata accessSettings)
        external
        onlyRole(ROLE_ADMIN)
    {
        for(uint i = 0; i < utilsContracts.length; i++)
        {
            revokeRole(ROLE_MINTER, utilsContracts[i]);
            revokeRole(ROLE_BURNER, utilsContracts[i]);
            revokeRole(ROLE_TRANSFERER, utilsContracts[i]);
            revokeRole(ROLE_MODERATOR, utilsContracts[i]);
            revokeRole(ROLE_TAXER, utilsContracts[i]);
        }
        delete utilsContracts;
        
        for(uint i = 0; i < accessSettings.length; i++)
        {
            if (accessSettings[i].isMinter) grantRole(ROLE_MINTER, accessSettings[i].addr);
            if (accessSettings[i].isBurner) grantRole(ROLE_BURNER, accessSettings[i].addr);
            if (accessSettings[i].isTransferer) grantRole(ROLE_TRANSFERER, accessSettings[i].addr);
            if (accessSettings[i].isModerator) grantRole(ROLE_MODERATOR, accessSettings[i].addr);
            if (accessSettings[i].isTaxer) grantRole(ROLE_TAXER, accessSettings[i].addr);
            
            utilsContracts.push(accessSettings[i].addr);
        }
        
        emit UpdatedUtilsContracts(accessSettings);
    }
    
    function getUtilsContractAtPos(uint pos)
        external
        view
        returns (address)
    {
        return utilsContracts[pos];
    }
    
    function getUtilsContractsCount()
        external
        view
        returns(uint)
    {
        return utilsContracts.length;
    }
    
    function mintByBridge(address to, uint desiredAmountToMint) 
        external
        notPausedContract
        onlyRole(ROLE_MINTER)
    {
        _mintHumanAddress(to, desiredAmountToMint);
        emit MintedByBridge(to, desiredAmountToMint);
    }
    
    function mintHumanAddress(address to, uint desiredAmountToMint) 
        external
        notPausedContract
        onlyRole(ROLE_MINTER)
    {
        _mintHumanAddress(to, desiredAmountToMint);
        emit MintHumanAddress(to, desiredAmountToMint);
    }
    
    function _mintHumanAddress(address to, uint desiredAmountToMint) 
        private
    {
        INoBotsTech iNoBotsTech = INoBotsTech(utilsContracts[NOBOTS_TECH_CONTRACT_ID]);
        uint realAmountToMint = 
            iNoBotsTech.
                prepareHumanAddressMintOrBurnRewardsAmounts(
                    true,
                    to,
                    desiredAmountToMint
                );
        
        _RealBalances[to] += realAmountToMint;
        iNoBotsTech.publicForcedUpdateCacheMultiplier();
        
        emit Transfer(address(0), to, desiredAmountToMint);
    }

    function burnByBridge(address from, uint desiredAmountToBurn)
        external
        notPausedContract
        onlyRole(ROLE_BURNER)
    {
        _burnHumanAddress(from, desiredAmountToBurn);
        emit BurnedByBridge(from, desiredAmountToBurn);
    }

    function burnHumanAddress(address from, uint desiredAmountToBurn)
        external
        notPausedContract
        onlyRole(ROLE_BURNER)
    {
        _burnHumanAddress(from, desiredAmountToBurn);
        emit BurnHumanAddress(from, desiredAmountToBurn);
    }

    function _burnHumanAddress(address from, uint desiredAmountToBurn)
        private
    {
        INoBotsTech iNoBotsTech = INoBotsTech(utilsContracts[NOBOTS_TECH_CONTRACT_ID]);
        uint realAmountToBurn = 
            INoBotsTech(utilsContracts[NOBOTS_TECH_CONTRACT_ID]).
                prepareHumanAddressMintOrBurnRewardsAmounts(
                    false,
                    from,
                    desiredAmountToBurn
                );
        
        _RealBalances[from] -= realAmountToBurn;
        iNoBotsTech.publicForcedUpdateCacheMultiplier();
        
        emit Transfer(from, address(0), desiredAmountToBurn);
    }
    
    function getChainId() 
        external 
        view 
        returns (uint) 
    {
        return block.chainid;
    }
}