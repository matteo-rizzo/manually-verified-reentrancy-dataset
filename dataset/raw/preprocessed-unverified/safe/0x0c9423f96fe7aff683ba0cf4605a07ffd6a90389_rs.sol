// SPDX-License-Identifier: MIT

pragma solidity 0.6.12;


// 
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
contract Context {
    // Empty internal constructor, to prevent people from mistakenly deploying
    // an instance of this contract, which should be used via inheritance.
    constructor () internal { }

    function _msgSender() internal view virtual returns (address payable) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes memory) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}

// 
/**
 * @dev Contract module which allows children to implement an emergency stop
 * mechanism that can be triggered by an authorized account.
 *
 * This module is used through inheritance. It will make available the
 * modifiers `whenNotPaused` and `whenPaused`, which can be applied to
 * the functions of your contract. Note that they will not be pausable by
 * simply including this module, only once the modifiers are put in place.
 */
contract Pausable is Context {
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
    constructor () internal {
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
     */
    modifier whenNotPaused() {
        require(!_paused, "Pausable: paused");
        _;
    }

    /**
     * @dev Modifier to make a function callable only when the contract is paused.
     */
    modifier whenPaused() {
        require(_paused, "Pausable: not paused");
        _;
    }

    /**
     * @dev Triggers stopped state.
     */
    function _pause() internal virtual whenNotPaused {
        _paused = true;
        emit Paused(_msgSender());
    }

    /**
     * @dev Returns to normal state.
     */
    function _unpause() internal virtual whenPaused {
        _paused = false;
        emit Unpaused(_msgSender());
    }
}

// 
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


// 
/**
 * @dev Collection of functions related to the address type
 */


// 
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
     */
    function _setRoleAdmin(bytes32 role, bytes32 adminRole) internal virtual {
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

//
abstract contract OwnerRole is AccessControl {

    address private _newOwnerCandidate;

    bytes32 public constant OWNER_ROLE = keccak256("OWNER_ROLE");

    event OwnerRoleTransferCancelled();
    event OwnerRoleTransferCompleted(address indexed previousOwner, address indexed newOwner);
    event OwnerRoleTransferStarted(address indexed currentOwner, address indexed newOwnerCandidate);


    modifier onlyOwner() {
        require(hasRole(OWNER_ROLE, _msgSender()), "OwnerRole: caller is not the owner");
        _;
    }

    modifier onlyNewOwnerCandidate() {
        require(_msgSender() == _newOwnerCandidate, "OwnerRole: caller is not the new owner candidate");
        _;
    }

    constructor
    (
        address owner
    )
        internal
    {
        require(owner != address(0), "OwnerRole: owner is the zero address");

        _setupRole(OWNER_ROLE, owner);
        _setRoleAdmin(OWNER_ROLE, OWNER_ROLE);
    }

    function acceptOwnerRole()
        external
        onlyNewOwnerCandidate
    {
        address previousOwner = getRoleMember(OWNER_ROLE, 0);
        address newOwner = _newOwnerCandidate;

        _setupRole(OWNER_ROLE, newOwner);
        revokeRole(OWNER_ROLE, previousOwner);
        _newOwnerCandidate = address(0);

        emit OwnerRoleTransferCompleted(previousOwner, newOwner);
    }

    function cancelOwnerRoleTransfer()
        external
        onlyOwner
    {
        require(_newOwnerCandidate != address(0), "OwnerRole: ownership transfer is not in-progress");

        _cancelOwnerRoleTransfer();
    }

    function renounceOwnerRole() 
        external
    {
        renounceRole(OWNER_ROLE, _msgSender());
        _cancelOwnerRoleTransfer();
    }

    function transferOwnerRole
    (
        address newOwnerCandidate
    )
        external
        onlyOwner
    {
        require(newOwnerCandidate != address(0), "OwnerRole: newOwnerCandidate is the zero address");

        address currentOwner = getRoleMember(OWNER_ROLE, 0);

        require(currentOwner != newOwnerCandidate, "OwnerRole: newOwnerCandidate is the current owner");

        _cancelOwnerRoleTransfer();
        _newOwnerCandidate = newOwnerCandidate;

        emit OwnerRoleTransferStarted(currentOwner, newOwnerCandidate);
    }

    function _cancelOwnerRoleTransfer()
        private
    {
        if (_newOwnerCandidate != address(0)) {
            _newOwnerCandidate = address(0);
            
            emit OwnerRoleTransferCancelled();
        }
    }
}

//
contract VASPContract is OwnerRole {
    bytes4 private _channels;
    bytes private _transportKey;
    bytes private _messageKey;
    bytes private _signingKey;
    bytes4 private _vaspCode;

    event ChannelsChanged(bytes4 indexed vaspCode, bytes4 previousChannels, bytes4 newChannels);
    event TransportKeyChanged(bytes4 indexed vaspCode, bytes previousTransportKey, bytes newTransportKey);
    event MessageKeyChanged(bytes4 indexed vaspCode, bytes previousMessageKey, bytes newMessageKey);
    event SigningKeyChanged(bytes4 indexed vaspCode, bytes previousSigningKey, bytes newSigningKey);

    constructor
    (
        bytes4 vaspCode,
        address owner,
        bytes4 channels,
        bytes memory transportKey,
        bytes memory messageKey,
        bytes memory signingKey
    )
        public
        OwnerRole(owner)
    {
        require(vaspCode != bytes4(0), "VASPContract: vaspCode is empty");
        require(_isValidKey(transportKey), "VASPContract: transportKey is invalid");
        require(_isValidKey(messageKey), "VASPContract: messageKey is invalid");
        require(_isValidKey(signingKey), "VASPContract: signingKey is invalid");

        _vaspCode = vaspCode;

        _setChannels(channels);
        _setTransportKey(transportKey);
        _setMessageKey(messageKey);
        _setSigningKey(signingKey);
    }

    function setChannels
    (
        bytes4 newChannels
    )
        external
        onlyOwner
    {
        _setChannels(newChannels);
    }

    function setTransportKey
    (
        bytes calldata newTransportKey
    )
        external
        onlyOwner
    {
        require(_isValidKey(newTransportKey), "VASPContract: newTransportKey is invalid");

        _setTransportKey(newTransportKey);
    }

    function setMessageKey
    (
        bytes calldata newMessageKey
    )
        external
        onlyOwner
    {
        require(_isValidKey(newMessageKey), "VASPContract: newMessageKey is invalid");

        _setMessageKey(newMessageKey);
    }

    function setSigningKey
    (
        bytes calldata newSigningKey
    )
        external
        onlyOwner
    {
        require(_isValidKey(newSigningKey), "VASPContract: newSigningKey is invalid");

        _setSigningKey(newSigningKey);
    }

    function channels()
        external view
        returns (bytes4)
    {
        return _channels;
    }

    function transportKey()
        external view
        returns (bytes memory)
    {
        return _transportKey;
    }

    function messageKey()
        external view
        returns (bytes memory)
    {
        return _messageKey;
    }

    function signingKey()
        external view
        returns (bytes memory)
    {
        return _signingKey;
    }

    function vaspCode()
        external view
        returns (bytes4)
    {
        return _vaspCode;
    }

    function _setChannels
    (
        bytes4 newChannels
    )
        private
    {
        if(_channels != newChannels) {
            emit ChannelsChanged(_vaspCode, _channels, newChannels);
            _channels = newChannels;
        }
    }

    function _setTransportKey
    (
        bytes memory newTransportKey
    )
        private
    {
        if(_areNotEqual(_transportKey, newTransportKey)) {
            emit TransportKeyChanged(_vaspCode, _transportKey, newTransportKey);
            _transportKey = newTransportKey;
        }
    }

    function _setMessageKey
    (
        bytes memory newMessageKey
    )
        private
    {
        if(_areNotEqual(_messageKey, newMessageKey)) {
            emit MessageKeyChanged(_vaspCode, _messageKey, newMessageKey);
            _messageKey = newMessageKey;
        }
    }

    function _setSigningKey
    (
        bytes memory newSigningKey
    )
        private
    {
        if(_areNotEqual(_signingKey, newSigningKey)) {
            emit SigningKeyChanged(_vaspCode, _signingKey, newSigningKey);
            _signingKey = newSigningKey;
        }
    }

    function _areNotEqual
    (
        bytes memory left,
        bytes memory right
    )
        private pure
        returns (bool)
    {
        return keccak256(left) != keccak256(right);
    }

    function _isValidKey
    (
        bytes memory key
    )
        private pure
        returns (bool)
    {
        return key.length == 33 && (key[0] == 0x02 || key[0] == 0x03);
    }
}

//
contract VASPContractFactory {

    function create
    (
        bytes4 vaspCode,
        address owner,
        bytes4 channels,
        bytes memory transportKey,
        bytes memory messageKey,
        bytes memory signingKey
    )
        external
        returns (address)
    {
        VASPContract vaspContract = new VASPContract(vaspCode, owner, channels, transportKey, messageKey, signingKey);
        address vaspAddress = address(vaspContract);

        return vaspAddress;
    }
}

//
contract VASPIndex is Pausable, OwnerRole {
    mapping (bytes4 => address) private _vaspAddresses;
    mapping (address => bytes4) private _vaspCodes;
    VASPContractFactory private _vaspContractFactory;

    event VASPContractCreated(bytes4 indexed vaspCode, address indexed vaspAddress);

    modifier onlyVASPContract() {
        require(_vaspCodes[_msgSender()] == bytes4(0), "VASPIndex: caller is not a VASP contract");
        _;
    }

    constructor
    (
        address owner,
        address vaspContractFactory
    )
        public
        OwnerRole(owner)
    {
        require(vaspContractFactory != address(0), "VASPIndex: vaspContractFactory is the zero address");

        _vaspContractFactory = VASPContractFactory(vaspContractFactory);
    }

    function createVASPContract
    (
        bytes4 vaspCode,
        address owner,
        bytes4 channels,
        bytes calldata transportKey,
        bytes calldata messageKey,
        bytes calldata signingKey
    )
        external
        whenNotPaused
        returns (address)
    {
        require(vaspCode != bytes4(0), "VASPIndex: vaspCode is empty");
        require(_vaspAddresses[vaspCode] == address(0), "VASPIndex: vaspCode is already in use");

        address vaspAddress = _vaspContractFactory.create(vaspCode, owner, channels, transportKey, messageKey, signingKey);

        _vaspCodes[vaspAddress] = vaspCode;
        _vaspAddresses[vaspCode] = vaspAddress;

        emit VASPContractCreated(vaspCode, vaspAddress);

        return vaspAddress;
    }

    function pause()
        external
        onlyOwner
    {
        _pause();
    }

    function terminate
    (
        address payable recipient
    )
        external
        onlyOwner
    {
        selfdestruct(recipient);
    }

    function unpause()
        external
        onlyOwner
    {
        _unpause();
    }

    function getVASPAddressByCode
    (
        bytes4 vaspCode
    )
        external view
        returns (address)
    {
        return _vaspAddresses[vaspCode];
    }

    function getVASPCodeByAddress
    (
        address vaspAddress
    )
        external view
        returns (bytes4)
    {
        return _vaspCodes[vaspAddress];
    }
}