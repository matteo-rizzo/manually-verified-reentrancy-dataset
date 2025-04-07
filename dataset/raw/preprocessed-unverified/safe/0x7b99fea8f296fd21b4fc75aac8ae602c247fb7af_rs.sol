/**
 *Submitted for verification at Etherscan.io on 2021-09-20
*/

pragma solidity 0.8.4;


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
 * By default, the admin role for all roles is `DEFAULT_ADMIN_ROLE`, which means
 * that only accounts with this role will be able to grant or revoke other
 * roles. More complex role relationships can be created by using
 * {_setRoleAdmin}.
 *
 * WARNING: The `DEFAULT_ADMIN_ROLE` is also its own admin: it has permission to
 * grant and revoke this role. Extra precautions should be taken to secure
 * accounts that have been granted it.
 */
abstract contract AccessControl is Context, IAccessControl, ERC165 {
    struct RoleData {
        mapping (address => bool) members;
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
 * @dev Interface of the ERC20 standard as defined in the EIP.
 */


/**
 * @dev Interface of the ERC20 Permit extension allowing approvals to be made via signatures, as defined in
 * https://eips.ethereum.org/EIPS/eip-2612[EIP-2612].
 *
 * Adds the {permit} method, which can be used to change an account's ERC20 allowance (see {IERC20-allowance}) by
 * presenting a message signed by the account. By not relying on {IERC20-approve}, the token holder account doesn't
 * need to send a transaction, and thus is not required to hold Ether at all.
 */


/**
 * @dev Contract module which allows children to implement an emergency stop
 * mechanism that can be triggered by an authorized account.
 *
 * This module is used through inheritance. It will make available the
 * modifiers `whenNotPaused` and `whenPaused`, which can be applied to
 * the functions of your contract. Note that they will not be pausable by
 * simply including this module, only once the modifiers are put in place.
 */
abstract contract Pausable is Context {
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
    constructor () {
        _paused = false;
    }

    /**
     * @dev Returns true if the contract is paused, and false otherwise.
     */
    function paused() public view virtual returns (bool) {
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
        require(!paused(), "Pausable: paused");
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
        require(paused(), "Pausable: not paused");
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
}

/**
 * @dev Collection of functions related to the address type
 */


/**
 * @title SafeERC20
 * @dev Wrappers around ERC20 operations that throw on failure (when the token
 * contract returns false). Tokens that return no value (and instead revert or
 * throw on failure) are also supported, non-reverting calls are assumed to be
 * successful.
 * To use this library you can add a `using SafeERC20 for IERC20;` statement to your contract,
 * which allows you to call the safe operations as `token.safeTransfer(...)`, etc.
 */


/**
 * @dev Contract module that helps prevent reentrant calls to a function.
 *
 * Inheriting from `ReentrancyGuard` will make the {nonReentrant} modifier
 * available, which can be applied to functions to make sure there are no nested
 * (reentrant) calls to them.
 *
 * Note that because there is a single `nonReentrant` guard, functions marked as
 * `nonReentrant` may not call one another. This can be worked around by making
 * those functions `private`, and then adding `external` `nonReentrant` entry
 * points to them.
 *
 * TIP: If you would like to learn more about reentrancy and alternative ways
 * to protect against it, check out our blog post
 * https://blog.openzeppelin.com/reentrancy-after-istanbul/[Reentrancy After Istanbul].
 */
abstract contract ReentrancyGuard {
    // Booleans are more expensive than uint256 or any type that takes up a full
    // word because each write operation emits an extra SLOAD to first read the
    // slot's contents, replace the bits taken up by the boolean, and then write
    // back. This is the compiler's defense against contract upgrades and
    // pointer aliasing, and it cannot be disabled.

    // The values being non-zero value makes deployment a bit more expensive,
    // but in exchange the refund on every call to nonReentrant will be lower in
    // amount. Since refunds are capped to a percentage of the total
    // transaction's gas, it is best to keep them low in cases like this one, to
    // increase the likelihood of the full refund coming into effect.
    uint256 private constant _NOT_ENTERED = 1;
    uint256 private constant _ENTERED = 2;

    uint256 private _status;

    constructor () {
        _status = _NOT_ENTERED;
    }

    /**
     * @dev Prevents a contract from calling itself, directly or indirectly.
     * Calling a `nonReentrant` function from another `nonReentrant`
     * function is not supported. It is possible to prevent this from happening
     * by making the `nonReentrant` function external, and make it call a
     * `private` function that does the actual work.
     */
    modifier nonReentrant() {
        // On the first call to nonReentrant, _notEntered will be true
        require(_status != _ENTERED, "ReentrancyGuard: reentrant call");

        // Any calls to nonReentrant after this point will fail
        _status = _ENTERED;

        _;

        // By storing the original value once again, a refund is triggered (see
        // https://eips.ethereum.org/EIPS/eip-2200)
        _status = _NOT_ENTERED;
    }
}

// SPDX-License-Identifier: MIT
/**
 * Users can purchase tokens after sale started and claim after sale ended
 */
contract IDOSale is AccessControl, Pausable, ReentrancyGuard {
    using SafeERC20 for IERC20;

    bytes32 public constant OPERATOR_ROLE = keccak256("OPERATOR_ROLE");
    // Contract owner address
    address public owner;
    // Proposed new contract owner address
    address public newOwner;
    // user address => whitelisted status
    mapping(address => bool) public whitelist;
    // user address => purchased token amount
    mapping(address => uint256) public purchasedAmounts;
    // user address => claimed token amount
    mapping(address => uint256) public claimedAmounts;
    // Once-whitelisted user address array, even removed users still remain
    address[] private _whitelistedUsers;
    // IDO token price
    uint256 public idoPrice;
    // IDO token address
    IERC20 public ido;
    // USDT address
    IERC20 public purchaseToken;
    // The cap amount each user can purchase IDO up to
    uint256 public purchaseCap;
    // The total purchased amount
    uint256 public totalPurchasedAmount;

    // Date timestamp when token sale start
    uint256 public startTime;
    // Date timestamp when token sale ends
    uint256 public endTime;

    // Used for returning purchase history
    struct Purchase {
        address account;
        uint256 amount;
    }
    // ERC20Permit
    struct PermitRequest {
        uint256 nonce;
        uint256 deadline;
        uint8 v;
        bytes32 r;
        bytes32 s;
    }

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
    event IdoPriceChanged(uint256 idoPrice);
    event PurchaseCapChanged(uint256 purchaseCap);
    event WhitelistAdded(address indexed account);
    event WhitelistRemoved(address indexed account);
    event Deposited(address indexed sender, uint256 amount);
    event Purchased(address indexed sender, uint256 amount);
    event Claimed(address indexed sender, uint256 amount);
    event Swept(address indexed sender, uint256 amount);

    constructor(
        IERC20 _ido,
        IERC20 _purchaseToken,
        uint256 _idoPrice,
        uint256 _purchaseCap,
        uint256 _startTime,
        uint256 _endTime
    ) {
        require(address(_ido) != address(0), "IDOSale: IDO_ADDRESS_INVALID");
        require(address(_purchaseToken) != address(0), "IDOSale: PURCHASE_TOKEN_ADDRESS_INVALID");
        require(_idoPrice > 0, "IDOSale: TOKEN_PRICE_INVALID");
        require(_purchaseCap > 0, "IDOSale: PURCHASE_CAP_INVALID");
        require(block.timestamp <= _startTime && _startTime < _endTime, "IDOSale: TIMESTAMP_INVALID");

        _setupRole(DEFAULT_ADMIN_ROLE, _msgSender());
        _setupRole(OPERATOR_ROLE, _msgSender());

        ido = _ido;
        purchaseToken = _purchaseToken;
        owner = _msgSender();
        idoPrice = _idoPrice;
        purchaseCap = _purchaseCap;
        startTime = _startTime;
        endTime = _endTime;

        emit OwnershipTransferred(address(0), _msgSender());
    }

    /**************************|
    |          Setters         |
    |_________________________*/

    /**
     * @dev Set ido token price in purchaseToken
     */
    function setIdoPrice(uint256 _idoPrice) external onlyOwner {
        idoPrice = _idoPrice;

        emit IdoPriceChanged(_idoPrice);
    }

    /**
     * @dev Set purchase cap for each user
     */
    function setPurchaseCap(uint256 _purchaseCap) external onlyOwner {
        purchaseCap = _purchaseCap;

        emit PurchaseCapChanged(_purchaseCap);
    }

    /****************************|
    |          Ownership         |
    |___________________________*/

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        require(owner == _msgSender(), "IDOSale: CALLER_NO_OWNER");
        _;
    }

    /**
     * @dev Leaves the contract without owner. It will not be possible to call
     * `onlyOwner` functions anymore. Can only be called by the current owner.
     *
     * NOTE: Renouncing ownership will leave the contract without an owner,
     * thereby removing any functionality that is only available to the owner.
     */
    function renounceOwnership() external onlyOwner {
        emit OwnershipTransferred(owner, address(0));
        owner = address(0);
    }

    /**
     * @dev Transfer the contract ownership.
     * The new owner still needs to accept the transfer.
     * can only be called by the contract owner.
     *
     * @param _newOwner new contract owner.
     */
    function transferOwnership(address _newOwner) external onlyOwner {
        require(_newOwner != address(0), "IDOSale: INVALID_ADDRESS");
        require(_newOwner != owner, "IDOSale: OWNERSHIP_SELF_TRANSFER");
        newOwner = _newOwner;
    }

    /**
     * @dev The new owner accept an ownership transfer.
     */
    function acceptOwnership() external {
        require(_msgSender() == newOwner, "IDOSale: CALLER_NO_NEW_OWNER");
        emit OwnershipTransferred(owner, newOwner);
        owner = newOwner;
        newOwner = address(0);
    }

    /***********************|
    |          Role         |
    |______________________*/

    /**
     * @dev Restricted to members of the operator role.
     */
    modifier onlyOperator() {
        require(hasRole(OPERATOR_ROLE, _msgSender()), "IDOSale: CALLER_NO_OPERATOR_ROLE");
        _;
    }

    /**
     * @dev Add an account to the operator role.
     * @param account address
     */
    function addOperator(address account) public onlyOwner {
        require(!hasRole(OPERATOR_ROLE, account), "IDOSale: ALREADY_OERATOR_ROLE");
        grantRole(OPERATOR_ROLE, account);
    }

    /**
     * @dev Remove an account from the operator role.
     * @param account address
     */
    function removeOperator(address account) public onlyOwner {
        require(hasRole(OPERATOR_ROLE, account), "IDOSale: NO_OPERATOR_ROLE");
        revokeRole(OPERATOR_ROLE, account);
    }

    /**
     * @dev Check if an account is operator.
     * @param account address
     */
    function checkOperator(address account) public view returns (bool) {
        return hasRole(OPERATOR_ROLE, account);
    }

    /***************************|
    |          Pausable         |
    |__________________________*/

    /**
     * @dev Pause the sale
     */
    function pause() external onlyOperator {
        super._pause();
    }

    /**
     * @dev Unpause the sale
     */
    function unpause() external onlyOperator {
        super._unpause();
    }


    /****************************|
    |          Whitelist         |
    |___________________________*/

    /**
     * @dev Return whitelisted users
     * The result array can include zero address
     */
    function whitelistedUsers() external view returns (address[] memory) {
        address[] memory __whitelistedUsers = new address[](_whitelistedUsers.length);
        for (uint256 i = 0; i < _whitelistedUsers.length; i++) {
            if (!whitelist[_whitelistedUsers[i]]) {
                continue;
            }
            __whitelistedUsers[i] = _whitelistedUsers[i];
        }

        return __whitelistedUsers;
    }

    /**
     * @dev Add wallet to whitelist
     * If wallet is added, removed and added to whitelist, the account is repeated
     */
    function addWhitelist(address[] memory accounts) external onlyOperator whenNotPaused {
        for (uint256 i = 0; i < accounts.length; i++) {
            require(accounts[i] != address(0), "IDOSale: ZERO_ADDRESS");
            if (!whitelist[accounts[i]]) {
                whitelist[accounts[i]] = true;
                _whitelistedUsers.push(accounts[i]);

                emit WhitelistAdded(accounts[i]);
            }
        }
    }

    /**
     * @dev Remove wallet from whitelist
     * Removed wallets still remain in `_whitelistedUsers` array
     */
    function removeWhitelist(address[] memory accounts) external onlyOperator whenNotPaused {
        for (uint256 i = 0; i < accounts.length; i++) {
            require(accounts[i] != address(0), "IDOSale: ZERO_ADDRESS");
            if (whitelist[accounts[i]]) {
                whitelist[accounts[i]] = false;

                emit WhitelistRemoved(accounts[i]);
            }
        }
    }

    /***************************|
    |          Purchase         |
    |__________________________*/

    /**
     * @dev Return purchase history (wallet address, amount)
     * The result array can include zero amount item
     */
    function purchaseHistory() external view returns (Purchase[] memory) {
        Purchase[] memory purchases = new Purchase[](_whitelistedUsers.length);
        for (uint256 i = 0; i < _whitelistedUsers.length; i++) {
            purchases[i].account = _whitelistedUsers[i];
            purchases[i].amount = purchasedAmounts[_whitelistedUsers[i]];
        }

        return purchases;
    }

    /**
     * @dev Deposit IDO token to the sale contract
     */
    function depositTokens(uint256 amount) external onlyOperator whenNotPaused {
        require(amount > 0, "IDOSale: DEPOSIT_AMOUNT_INVALID");
        ido.safeTransferFrom(_msgSender(), address(this), amount);

        emit Deposited(_msgSender(), amount);
    }

    /**
     * @dev Permit and deposit IDO token to the sale contract
     * If token does not have `permit` function, this function does not work
     */
    function permitAndDepositTokens(
        uint256 amount,
        PermitRequest calldata permitOptions
    ) external onlyOperator whenNotPaused {
        require(amount > 0, "IDOSale: DEPOSIT_AMOUNT_INVALID");

        // Permit
        IERC20Permit(address(ido)).permit(_msgSender(), address(this), amount, permitOptions.deadline, permitOptions.v, permitOptions.r, permitOptions.s);
        ido.safeTransferFrom(_msgSender(), address(this), amount);

        emit Deposited(_msgSender(), amount);
    }

    /**
     * @dev Purchase IDO token
     * Only whitelisted users can purchase within `purchcaseCap` amount
     */
    function purchase(uint256 amount) external nonReentrant whenNotPaused {
        require(startTime <= block.timestamp, "IDOSale: SALE_NOT_STARTED");
        require(block.timestamp < endTime, "IDOSale: SALE_ALREADY_ENDED");
        require(amount > 0, "IDOSale: PURCHASE_AMOUNT_INVALID");
        require(whitelist[_msgSender()], "IDOSale: CALLER_NO_WHITELIST");
        require(purchasedAmounts[_msgSender()] + amount <= purchaseCap, "IDOSale: PURCHASE_CAP_EXCEEDED");
        uint256 idoBalance = ido.balanceOf(address(this));
        require(totalPurchasedAmount + amount <= idoBalance, "IDOSale: INSUFFICIENT_SELL_BALANCE");
        uint256 purchaseTokenAmount = amount * idoPrice / (10 ** 18);
        require(purchaseTokenAmount <= purchaseToken.balanceOf(_msgSender()), "IDOSale: INSUFFICIENT_FUNDS");

        purchasedAmounts[_msgSender()] += amount;
        totalPurchasedAmount += amount;
        purchaseToken.safeTransferFrom(_msgSender(), address(this), purchaseTokenAmount);

        emit Purchased(_msgSender(), amount);
    }

    /**
     * @dev Purchase IDO token
     * Only whitelisted users can purchase within `purchcaseCap` amount
     * If `purchaseToken` does not have `permit` function, this function does not work
     */
    function permitAndPurchase(
        uint256 amount,
        PermitRequest calldata permitOptions
    ) external nonReentrant whenNotPaused {
        require(startTime <= block.timestamp, "IDOSale: SALE_NOT_STARTED");
        require(block.timestamp < endTime, "IDOSale: SALE_ALREADY_ENDED");
        require(amount > 0, "IDOSale: PURCHASE_AMOUNT_INVALID");
        require(whitelist[_msgSender()], "IDOSale: CALLER_NO_WHITELIST");
        require(purchasedAmounts[_msgSender()] + amount <= purchaseCap, "IDOSale: PURCHASE_CAP_EXCEEDED");
        uint256 idoBalance = ido.balanceOf(address(this));
        require(totalPurchasedAmount + amount <= idoBalance, "IDOSale: INSUFFICIENT_SELL_BALANCE");
        uint256 purchaseTokenAmount = amount * idoPrice / (10 ** 18);
        require(purchaseTokenAmount <= purchaseToken.balanceOf(_msgSender()), "IDOSale: INSUFFICIENT_FUNDS");

        purchasedAmounts[_msgSender()] += amount;
        totalPurchasedAmount += amount;
        IERC20Permit(address(purchaseToken)).permit(_msgSender(), address(this), amount, permitOptions.deadline, permitOptions.v, permitOptions.r, permitOptions.s);
        purchaseToken.safeTransferFrom(_msgSender(), address(this), purchaseTokenAmount);

        emit Purchased(_msgSender(), amount);
    }

    /************************|
    |          Claim         |
    |_______________________*/

    /**
     * @dev Users claim purchased tokens after token sale ended
     */
    function claim(uint256 amount) external nonReentrant whenNotPaused {
        require(endTime <= block.timestamp, "IDOSale: SALE_NOT_ENDED");
        require(amount > 0, "IDOSale: CLAIM_AMOUNT_INVALID");
        require(claimedAmounts[_msgSender()] + amount <= purchasedAmounts[_msgSender()], "IDOSale: CLAIM_AMOUNT_EXCEEDED");

        claimedAmounts[_msgSender()] += amount;
        ido.safeTransfer(_msgSender(), amount);

        emit Claimed(_msgSender(), amount);
    }

    /**
     * @dev `Operator` sweeps `purchaseToken` from the sale contract to `to` address
     */
    function sweep(address to) external onlyOwner {
        require(to != address(0), "IDOSale: ADDRESS_INVALID");
        require(endTime <= block.timestamp, "IDOSale: SALE_NOT_ENDED");
        uint256 bal = purchaseToken.balanceOf(address(this));
        purchaseToken.transfer(to, bal);

        emit Swept(to, bal);
    }
}