/**
 *Submitted for verification at Etherscan.io on 2021-09-23
*/

// SPDX-License-Identifier: MIT

pragma solidity 0.8.7;



// Part: OpenZeppelin/[email protected]/Context

/**
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
        return msg.data;
    }
}

// Part: OpenZeppelin/[email protected]/ECDSA

/**
 * @dev Elliptic Curve Digital Signature Algorithm (ECDSA) operations.
 *
 * These functions can be used to verify that a message was signed by the holder
 * of the private keys of a given address.
 */


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
 * As of v3.3.0, sets of type `bytes32` (`Bytes32Set`), `address` (`AddressSet`)
 * and `uint256` (`UintSet`) are supported.
 */


// Part: OpenZeppelin/[email protected]/IAccessControl

/**
 * @dev External interface of AccessControl declared to support ERC165 detection.
 */


// Part: OpenZeppelin/[email protected]/IERC165

/**
 * @dev Interface of the ERC165 standard, as defined in the
 * https://eips.ethereum.org/EIPS/eip-165[EIP].
 *
 * Implementers can declare support of contract interfaces, which can then be
 * queried by others ({ERC165Checker}).
 *
 * For an implementation, see {ERC165}.
 */


// Part: OpenZeppelin/[email protected]/IERC20

/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
 */


// Part: OpenZeppelin/[email protected]/Strings

/**
 * @dev String operations.
 */


// Part: uniswap/[email protected]/TransferHelper

// helper methods for interacting with ERC20 tokens and sending ETH that do not consistently return true/false


// Part: OpenZeppelin/[email protected]/ERC165

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

// Part: OpenZeppelin/[email protected]/IAccessControlEnumerable

/**
 * @dev External interface of AccessControlEnumerable declared to support ERC165 detection.
 */
interface IAccessControlEnumerable is IAccessControl {
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
    function getRoleMember(bytes32 role, uint256 index) external view returns (address);

    /**
     * @dev Returns the number of accounts that have `role`. Can be used
     * together with {getRoleMember} to enumerate all bearers of a role.
     */
    function getRoleMemberCount(bytes32 role) external view returns (uint256);
}

// Part: OpenZeppelin/[email protected]/AccessControl

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
        mapping(address => bool) members;
        bytes32 adminRole;
    }

    mapping(bytes32 => RoleData) private _roles;

    bytes32 public constant DEFAULT_ADMIN_ROLE = 0x00;

    /**
     * @dev Modifier that checks that an account has a specific role. Reverts
     * with a standardized message including the required role.
     *
     * The format of the revert reason is given by the following regular expression:
     *
     *  /^AccessControl: account (0x[0-9a-f]{40}) is missing role (0x[0-9a-f]{64})$/
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
        return interfaceId == type(IAccessControl).interfaceId || super.supportsInterface(interfaceId);
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
     *  /^AccessControl: account (0x[0-9a-f]{40}) is missing role (0x[0-9a-f]{64})$/
     */
    function _checkRole(bytes32 role, address account) internal view {
        if (!hasRole(role, account)) {
            revert(
                string(
                    abi.encodePacked(
                        "AccessControl: account ",
                        Strings.toHexString(uint160(account), 20),
                        " is missing role ",
                        Strings.toHexString(uint256(role), 32)
                    )
                )
            );
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
        bytes32 previousAdminRole = getRoleAdmin(role);
        _roles[role].adminRole = adminRole;
        emit RoleAdminChanged(role, previousAdminRole, adminRole);
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

// Part: OpenZeppelin/[email protected]/AccessControlEnumerable

/**
 * @dev Extension of {AccessControl} that allows enumerating the members of each role.
 */
abstract contract AccessControlEnumerable is IAccessControlEnumerable, AccessControl {
    using EnumerableSet for EnumerableSet.AddressSet;

    mapping(bytes32 => EnumerableSet.AddressSet) private _roleMembers;

    /**
     * @dev See {IERC165-supportsInterface}.
     */
    function supportsInterface(bytes4 interfaceId) public view virtual override returns (bool) {
        return interfaceId == type(IAccessControlEnumerable).interfaceId || super.supportsInterface(interfaceId);
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
    function grantRole(bytes32 role, address account) public virtual override(AccessControl, IAccessControl) {
        super.grantRole(role, account);
        _roleMembers[role].add(account);
    }

    /**
     * @dev Overload {revokeRole} to track enumerable memberships
     */
    function revokeRole(bytes32 role, address account) public virtual override(AccessControl, IAccessControl) {
        super.revokeRole(role, account);
        _roleMembers[role].remove(account);
    }

    /**
     * @dev Overload {renounceRole} to track enumerable memberships
     */
    function renounceRole(bytes32 role, address account) public virtual override(AccessControl, IAccessControl) {
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

// File: swapContract.sol

contract SwapContract is AccessControlEnumerable
{
    bytes32 public constant VALIDATOR_ROLE = keccak256("VALIDATOR_ROLE");

    IERC20 public tokenAddress;
    uint256 public maxSwapAmountPerTx;
    uint256 public minSwapAmountPerTx;

    uint128 [3] public swapRatios;
    bool [3] public swapEnabled;

    mapping(address => bool) public swapLimitsSaved;
    mapping(address => uint256 [3]) swapLimits;

    event Deposit(address user, uint256 amount, uint256 amountToReceive, address newAddress);
    event TokensClaimed(address recipient, uint256 amount);

    /**
      * @dev throws if transaction sender is not in owner role
      */
    modifier onlyOwner() {
        require(
            hasRole(DEFAULT_ADMIN_ROLE, _msgSender()),
            "Caller is not in owner role"
        );
        _;
    }

    /**
      * @dev throws if transaction sender is not in owner or validator role
      */
    modifier onlyOwnerAndValidator() {
        require(
            hasRole(DEFAULT_ADMIN_ROLE, _msgSender()) || hasRole(VALIDATOR_ROLE, _msgSender()),
            "Caller is not in owner or validator role"
        );
        _;
    }

    /**
      * @dev Constructor of contract
      * @param _tokenAddress Token contract address
      * @param validatorAddress Swap limits validator address
      * @param _swapRatios Swap ratios array
      * @param _swapEnabled Array that represents if swap enabled for ratio
      * @param _minSwapAmountPerTx Minimum token amount for swap per transaction
      * @param _maxSwapAmountPerTx Maximum token amount for swap per transaction
      */
    constructor(
        IERC20 _tokenAddress,
        address validatorAddress,
        uint128 [3] memory _swapRatios,
        bool [3] memory _swapEnabled,
        uint256 _minSwapAmountPerTx,
        uint256 _maxSwapAmountPerTx
    )
    {
        swapRatios = _swapRatios;
        swapEnabled = _swapEnabled;
        maxSwapAmountPerTx = _maxSwapAmountPerTx;
        minSwapAmountPerTx = _minSwapAmountPerTx;
        tokenAddress = _tokenAddress;
        _setupRole(DEFAULT_ADMIN_ROLE, _msgSender());
        _setupRole(VALIDATOR_ROLE, validatorAddress);
    }

     /**
      * @dev Transfers tokens from sender to the contract.
      * User calls this function when he wants to deposit tokens for the first time.
      * @param amountToSend Maximum amount of tokens to send
      * @param newAddress Address in the blockchain where the user wants to get tokens
      * @param signedAddress Signed Address
      * @param signedSwapLimits Signed swap limits
      * @param signature Signed address + swapLimits keccak hash
      */
    function depositWithSignature(
        uint256 amountToSend,
        address newAddress,
        address signedAddress,
        uint256 [3] memory signedSwapLimits,
        bytes memory signature
    ) external
    {
        address sender = _msgSender();
        uint256 senderBalance = tokenAddress.balanceOf(sender);
        require(senderBalance >= amountToSend, "swapContract: Insufficient balance");
        require(amountToSend >= minSwapAmountPerTx, "swapContract: Less than required minimum of tokens requested");
        require(amountToSend <= maxSwapAmountPerTx, "swapContract: Swap limit per transaction exceeded");
        require(sender == signedAddress, "swapContract: Signed and sender address does not match");
        require(!swapLimitsSaved[sender], "swapContract: Swap limits already saved");

        bytes32 hashedParams = keccak256(abi.encodePacked(signedAddress, signedSwapLimits));
        address validatorAddress = ECDSA.recover(ECDSA.toEthSignedMessageHash(hashedParams), signature);
        require(isValidator(validatorAddress), "swapContract: Invalid swap limits validator");

        (uint256[3] memory swapLimitsNew, uint256 amountToPay, uint256 amountToReceive) = calculateAmountsAfterSwap(
            signedSwapLimits, amountToSend, true
        );
        require(amountToPay > 0, "swapContract: Swap limit reached");
        require(amountToReceive > 0, "swapContract: Amount to receive is zero");

        swapLimits[sender] = swapLimitsNew;
        swapLimitsSaved[sender] = true;

        TransferHelper.safeTransferFrom(address(tokenAddress), sender, address(this), amountToPay);
        emit Deposit(sender, amountToPay, amountToReceive, newAddress);
    }

    /**
      * @dev Transfers tokens from sender to the contract.
      * User calls this function when he wants to deposit tokens
      * if the swap limits have been already saved into the contract storage
      * @param amountToSend Maximum amount of tokens to send
      * @param newAddress Address in the blockchain where the user wants to get tokens
      */
     function deposit(
        uint256 amountToSend,
        address newAddress
    ) external
    {
        address sender = _msgSender();
        uint256 senderBalance = tokenAddress.balanceOf(sender);
        require(senderBalance >= amountToSend, "swapContract: Not enough balance");
        require(amountToSend >= minSwapAmountPerTx, "swapContract: Less than required minimum of tokens requested");
        require(amountToSend <= maxSwapAmountPerTx, "swapContract: Swap limit per transaction exceeded");
        require(swapLimitsSaved[sender], "swapContract: Swap limits not saved");

        (uint256[3] memory swapLimitsNew, uint256 amountToPay, uint256 amountToReceive) = calculateAmountsAfterSwap(
            swapLimits[sender], amountToSend, true
        );

        require(amountToPay > 0, "swapContract: Swap limit reached");
        require(amountToReceive > 0, "swapContract: Amount to receive is zero");

        swapLimits[sender] = swapLimitsNew;

        TransferHelper.safeTransferFrom(address(tokenAddress), sender, address(this), amountToPay);
        emit Deposit(sender, amountToPay, amountToReceive, newAddress);
    }

    /**
      * @dev Calculates actual amount to pay, amount to receive and new swap limits after swap
      * @param _swapLimits Swap limits array
      * @param amountToSend Maximum amount of tokens to send
      * @param checkIfSwapEnabled Check if swap enabled for a ratio
      * @return swapLimitsNew Swap limits after deposit is processed
      * @return amountToPay Actual amount of tokens to pay (amountToPay <= amountToSend)
      * @return amountToReceive Amount of tokens to receive after deposit is processed
      */
    function calculateAmountsAfterSwap(
        uint256[3] memory _swapLimits,
        uint256 amountToSend,
        bool checkIfSwapEnabled
    ) public view returns (
        uint256[3] memory swapLimitsNew, uint256 amountToPay, uint256 amountToReceive)
    {
        amountToReceive = 0;
        uint256 remainder = amountToSend;
        for (uint256 i = 0; i < _swapLimits.length; i++) {
            if (checkIfSwapEnabled && !swapEnabled[i] || swapRatios[i] == 0) {
                continue;
            }
            uint256 swapLimit = _swapLimits[i];

            if (remainder <= swapLimit) {
                amountToReceive += remainder / swapRatios[i];
                _swapLimits[i] -= remainder;
                remainder = 0;
                break;
            } else {
                amountToReceive += swapLimit / swapRatios[i];
                remainder -= swapLimit;
                _swapLimits[i] = 0;
            }
        }
        amountToPay = amountToSend - remainder;
        swapLimitsNew = _swapLimits;
    }

    /**
      * @dev Claims the deposited tokens
      * @param recipient Tokens recipient
      * @param amount Tokens amount
      */
    function claimTokens(address recipient, uint256 amount) external onlyOwner
    {
        uint256 balance = tokenAddress.balanceOf(address(this));
        require(balance > 0, "swapContract: Token balance is zero");
        require(balance >= amount, "swapContract: Not enough balance to claim");
        if (amount == 0) {
            amount = balance;
        }
        TransferHelper.safeTransfer(address(tokenAddress), recipient, amount);
        emit TokensClaimed(recipient, amount);
    }

    /**
      * @dev Changes requirement for minimal token amount to deposit
      * @param _minSwapAmountPerTx Amount of tokens
      */
    function setMinSwapAmountPerTx(uint256 _minSwapAmountPerTx) external onlyOwner {
        minSwapAmountPerTx = _minSwapAmountPerTx;
    }

    /**
      * @dev Changes requirement for maximum token amount to deposit
      * @param _maxSwapAmountPerTx Amount of tokens
      */
    function setMaxSwapAmountPerTx(uint256 _maxSwapAmountPerTx) external onlyOwner {
        maxSwapAmountPerTx = _maxSwapAmountPerTx;
    }

    /**
      * @dev Changes swap ratio
      * @param index Ratio index
      * @param ratio Ratio value
      */
    function setSwapRatio(uint128 index, uint128 ratio) external onlyOwner {
        swapRatios[index] = ratio;
    }

    /**
      * @dev Enables swap for a ratio
      * @param index Swap rate index
      */
    function enableSwap(uint128 index) external onlyOwner {
        swapEnabled[index] = true;
    }

    /**
      * @dev Disables swap for a ratio
      * @param index Swap rate index
      */
    function disableSwap(uint128 index) external onlyOwner {
        swapEnabled[index] = false;
    }

    /**
      * @dev Function to check if address is belongs to owner role
      * @param account Account address to check
      */
    function isOwner(address account) public view returns (bool) {
        return hasRole(DEFAULT_ADMIN_ROLE, account);
    }

    /**
      * @dev Function to check if address is belongs to validator role
      * @param account Account address to check
      */
    function isValidator(address account) public view returns (bool) {
        return hasRole(VALIDATOR_ROLE, account);
    }

    /**
      * @dev Returns account swap limits array
      * @param account Account address
      * @return Account swap limits array
      */
    function swapLimitsArray(address account) external view returns (uint256[3] memory)
    {
        return swapLimits[account];
    }

    /**
      * @dev Returns array that represents if swap enabled for ratio
      * @return Array that represents if swap enabled for ratio
      */
    function swapEnabledArray() external view returns (bool[3] memory)
    {
        return swapEnabled;
    }

    /**
      * @dev Updates swap limits for account
      * @param account Account address
      * @param _swapLimits Swap limits array
      */
    function updateSwapLimits(address account, uint256[3] memory _swapLimits) external onlyOwnerAndValidator {
        swapLimits[account] = _swapLimits;
        swapLimitsSaved[account] = true;
    }
}