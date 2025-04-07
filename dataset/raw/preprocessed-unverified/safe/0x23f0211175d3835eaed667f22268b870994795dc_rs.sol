/**
 *Submitted for verification at Etherscan.io on 2021-06-14
*/

// Dependency file: D:\repos\VRM\VRM-BRIDGE\VRM-FLy-bridge\VRM.FlyBridge.Contracts\node_modules\@openzeppelin\contracts\token\ERC20\IERC20.sol

// SPDX-License-Identifier: MIT

// pragma solidity ^0.8.0;

/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
 */



// Dependency file: D:\repos\VRM\VRM-BRIDGE\VRM-FLy-bridge\VRM.FlyBridge.Contracts\node_modules\@openzeppelin\contracts\utils\Address.sol


// pragma solidity ^0.8.0;

/**
 * @dev Collection of functions related to the address type
 */



// Dependency file: D:\repos\VRM\VRM-BRIDGE\VRM-FLy-bridge\VRM.FlyBridge.Contracts\node_modules\@openzeppelin\contracts\token\ERC20\utils\SafeERC20.sol


// pragma solidity ^0.8.0;

// import "D:\repos\VRM\VRM-BRIDGE\VRM-FLy-bridge\VRM.FlyBridge.Contracts\node_modules\@openzeppelin\contracts\token\ERC20\IERC20.sol";
// import "D:\repos\VRM\VRM-BRIDGE\VRM-FLy-bridge\VRM.FlyBridge.Contracts\node_modules\@openzeppelin\contracts\utils\Address.sol";

/**
 * @title SafeERC20
 * @dev Wrappers around ERC20 operations that throw on failure (when the token
 * contract returns false). Tokens that return no value (and instead revert or
 * throw on failure) are also supported, non-reverting calls are assumed to be
 * successful.
 * To use this library you can add a `using SafeERC20 for IERC20;` statement to your contract,
 * which allows you to call the safe operations as `token.safeTransfer(...)`, etc.
 */



// Dependency file: D:\repos\VRM\VRM-BRIDGE\VRM-FLy-bridge\VRM.FlyBridge.Contracts\node_modules\@openzeppelin\contracts\token\ERC20\extensions\IERC20Metadata.sol


// pragma solidity ^0.8.0;

// import "D:\repos\VRM\VRM-BRIDGE\VRM-FLy-bridge\VRM.FlyBridge.Contracts\node_modules\@openzeppelin\contracts\token\ERC20\IERC20.sol";

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


// Dependency file: D:\repos\VRM\VRM-BRIDGE\VRM-FLy-bridge\VRM.FlyBridge.Contracts\node_modules\@openzeppelin\contracts\utils\Context.sol


// pragma solidity ^0.8.0;

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


// Dependency file: D:\repos\VRM\VRM-BRIDGE\VRM-FLy-bridge\VRM.FlyBridge.Contracts\node_modules\@openzeppelin\contracts\utils\Strings.sol


// pragma solidity ^0.8.0;

/**
 * @dev String operations.
 */



// Dependency file: D:\repos\VRM\VRM-BRIDGE\VRM-FLy-bridge\VRM.FlyBridge.Contracts\node_modules\@openzeppelin\contracts\utils\introspection\IERC165.sol


// pragma solidity ^0.8.0;

/**
 * @dev Interface of the ERC165 standard, as defined in the
 * https://eips.ethereum.org/EIPS/eip-165[EIP].
 *
 * Implementers can declare support of contract interfaces, which can then be
 * queried by others ({ERC165Checker}).
 *
 * For an implementation, see {ERC165}.
 */



// Dependency file: D:\repos\VRM\VRM-BRIDGE\VRM-FLy-bridge\VRM.FlyBridge.Contracts\node_modules\@openzeppelin\contracts\utils\introspection\ERC165.sol


// pragma solidity ^0.8.0;

// import "D:\repos\VRM\VRM-BRIDGE\VRM-FLy-bridge\VRM.FlyBridge.Contracts\node_modules\@openzeppelin\contracts\utils\introspection\IERC165.sol";

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


// Dependency file: D:\repos\VRM\VRM-BRIDGE\VRM-FLy-bridge\VRM.FlyBridge.Contracts\node_modules\@openzeppelin\contracts\access\AccessControl.sol


// pragma solidity ^0.8.0;

// import "D:\repos\VRM\VRM-BRIDGE\VRM-FLy-bridge\VRM.FlyBridge.Contracts\node_modules\@openzeppelin\contracts\utils\Context.sol";
// import "D:\repos\VRM\VRM-BRIDGE\VRM-FLy-bridge\VRM.FlyBridge.Contracts\node_modules\@openzeppelin\contracts\utils\Strings.sol";
// import "D:\repos\VRM\VRM-BRIDGE\VRM-FLy-bridge\VRM.FlyBridge.Contracts\node_modules\@openzeppelin\contracts\utils\introspection\ERC165.sol";

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


// Dependency file: D:\repos\VRM\VRM-BRIDGE\VRM-FLy-bridge\VRM.FlyBridge.Contracts\node_modules\@openzeppelin\contracts\access\Ownable.sol


// pragma solidity ^0.8.0;

// import "D:\repos\VRM\VRM-BRIDGE\VRM-FLy-bridge\VRM.FlyBridge.Contracts\node_modules\@openzeppelin\contracts\utils\Context.sol";
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
    constructor () {
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


// Dependency file: contracts\BridgeBaseImpl.sol

// pragma solidity ^0.8.4;
// import 'D:\repos\VRM\VRM-BRIDGE\VRM-FLy-bridge\VRM.FlyBridge.Contracts\node_modules\@openzeppelin\contracts\token\ERC20\utils\SafeERC20.sol';
// import 'D:\repos\VRM\VRM-BRIDGE\VRM-FLy-bridge\VRM.FlyBridge.Contracts\node_modules\@openzeppelin\contracts\token\ERC20\extensions\IERC20Metadata.sol';
// import 'D:\repos\VRM\VRM-BRIDGE\VRM-FLy-bridge\VRM.FlyBridge.Contracts\node_modules\@openzeppelin\contracts\access\AccessControl.sol';
// import 'D:\repos\VRM\VRM-BRIDGE\VRM-FLy-bridge\VRM.FlyBridge.Contracts\node_modules\@openzeppelin\contracts\access\Ownable.sol';
// import 'D:\repos\VRM\VRM-BRIDGE\VRM-FLy-bridge\VRM.FlyBridge.Contracts\node_modules\@openzeppelin\contracts\utils\Address.sol';

contract BridgeBaseImpl is AccessControl, Ownable {
    using Address for address payable;
    bytes32 public constant ADMIN_ROLE = keccak256('ADMIN_ROLE');

    constructor() {
        _setupRole(DEFAULT_ADMIN_ROLE, _msgSender());
        _setupRole(ADMIN_ROLE, _msgSender());
    }

    modifier notContract() {
        require(!isContract(msg.sender), 'contract is not allowed to swap');
        require(msg.sender == tx.origin, 'no proxy contract is allowed');
        _;
    }

    function isContract(address addr) internal view returns (bool) {
        uint256 size;
        assembly {
            size := extcodesize(addr)
        }
        return size > 0;
    }

    function emergencyWithdraw(address _token) external onlyOwner {
        if (_token == address(0)) {
            Address.sendValue(payable(owner()), address(this).balance);
        } else {
            IERC20(_token).transfer(msg.sender, IERC20(_token).balanceOf(address(this)));
        }
    }

    receive() external payable {}
}


// Root file: contracts\ETHBridgeImpl.sol

pragma solidity ^0.8.4;
// import 'D:\repos\VRM\VRM-BRIDGE\VRM-FLy-bridge\VRM.FlyBridge.Contracts\node_modules\@openzeppelin\contracts\token\ERC20\utils\SafeERC20.sol';
// import 'D:\repos\VRM\VRM-BRIDGE\VRM-FLy-bridge\VRM.FlyBridge.Contracts\node_modules\@openzeppelin\contracts\token\ERC20\extensions\IERC20Metadata.sol';
// import 'D:\repos\VRM\VRM-BRIDGE\VRM-FLy-bridge\VRM.FlyBridge.Contracts\node_modules\@openzeppelin\contracts\utils\Address.sol';
// import 'contracts\BridgeBaseImpl.sol';

contract ETHBridgeImpl is BridgeBaseImpl {
    using SafeERC20 for IERC20;
    using Address for address payable;

    mapping(address => bool) public registeredERC20;
    mapping(bytes32 => bool) public filledBSCTx;

    event BridgePairRegistered(
        address indexed registrator,
        address indexed erc20Addr,
        string name,
        string symbol,
        uint8 decimals
    );
    event BridgeSwapStarted(
        address indexed erc20Addr,
        address indexed fromAddr,
        address indexed toAddr,
        uint256 amount,
        uint256 feeAmount,
        uint8 network
    );
    event BridgeSwapFilled(
        address indexed erc20Addr,
        bytes32 indexed bscTxHash,
        address indexed toAddress,
        uint256 amount,
        uint8 network
    );

    constructor() {}

    function registerBridgePairToBSC(address erc20Addr) external returns (bool) {
        require(hasRole(ADMIN_ROLE, _msgSender()), 'Caller is not an admin');
        require(!registeredERC20[erc20Addr], 'already registered');

        string memory name = IERC20Metadata(erc20Addr).name();
        string memory symbol = IERC20Metadata(erc20Addr).symbol();
        uint8 decimals = IERC20Metadata(erc20Addr).decimals();

        require(bytes(name).length > 0, 'empty name');
        require(bytes(symbol).length > 0, 'empty symbol');

        registeredERC20[erc20Addr] = true;

        emit BridgePairRegistered(_msgSender(), erc20Addr, name, symbol, decimals);
        return true;
    }

    function fillBSC2ETHSwap(
        bytes32 bscTxHash,
        address erc20Addr,
        address toAddress,
        uint256 amount,
        uint8 network
    ) external returns (bool) {
        require(hasRole(ADMIN_ROLE, _msgSender()), 'Caller is not an admin');
        require(!filledBSCTx[bscTxHash], 'bsc tx filled already');
        require(registeredERC20[erc20Addr], 'not registered token');

        filledBSCTx[bscTxHash] = true;
        IERC20(erc20Addr).safeTransfer(toAddress, amount);

        emit BridgeSwapFilled(erc20Addr, bscTxHash, toAddress, amount, network);
        return true;
    }

    function swapETH2BSC(
        address erc20Addr,
        address toAddr,
        uint256 amount,
        uint8 network
    ) external payable notContract returns (bool) {
        require(registeredERC20[erc20Addr], 'not registered token');
        require(msg.value != 0x0, "swap fee can't be zero");

        IERC20(erc20Addr).safeTransferFrom(_msgSender(), address(this), amount);
        Address.sendValue(payable(owner()), msg.value);

        emit BridgeSwapStarted(erc20Addr, msg.sender, toAddr, amount, msg.value, network);
        return true;
    }
}