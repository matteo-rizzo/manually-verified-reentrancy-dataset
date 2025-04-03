/**
 *Submitted for verification at Etherscan.io on 2020-12-09
*/

// File @openzeppelin/contracts/math/SafeMath.sol@v3.2.0



pragma solidity ^0.6.0;

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



// File @openzeppelin/contracts/utils/EnumerableSet.sol@v3.2.0



pragma solidity ^0.6.0;

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



// File @openzeppelin/contracts/utils/Address.sol@v3.2.0



pragma solidity ^0.6.2;

/**
 * @dev Collection of functions related to the address type
 */



// File @openzeppelin/contracts/GSN/Context.sol@v3.2.0



pragma solidity ^0.6.0;

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


// File @openzeppelin/contracts/access/AccessControl.sol@v3.2.0



pragma solidity ^0.6.0;



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


// File contracts/DigitalaxAccessControls.sol

pragma solidity 0.6.12;

/**
 * @notice Access Controls contract for the Digitalax Platform
 * @author BlockRocket.tech
 */
contract DigitalaxAccessControls is AccessControl {
    /// @notice Role definitions
    bytes32 public constant MINTER_ROLE = keccak256("MINTER_ROLE");
    bytes32 public constant SMART_CONTRACT_ROLE = keccak256("SMART_CONTRACT_ROLE");

    /// @notice Events for adding and removing various roles
    event AdminRoleGranted(
        address indexed beneficiary,
        address indexed caller
    );

    event AdminRoleRemoved(
        address indexed beneficiary,
        address indexed caller
    );

    event MinterRoleGranted(
        address indexed beneficiary,
        address indexed caller
    );

    event MinterRoleRemoved(
        address indexed beneficiary,
        address indexed caller
    );

    event SmartContractRoleGranted(
        address indexed beneficiary,
        address indexed caller
    );

    event SmartContractRoleRemoved(
        address indexed beneficiary,
        address indexed caller
    );

    /**
     * @notice The deployer is automatically given the admin role which will allow them to then grant roles to other addresses
     */
    constructor() public {
        _setupRole(DEFAULT_ADMIN_ROLE, _msgSender());
    }

    /////////////
    // Lookups //
    /////////////

    /**
     * @notice Used to check whether an address has the admin role
     * @param _address EOA or contract being checked
     * @return bool True if the account has the role or false if it does not
     */
    function hasAdminRole(address _address) external view returns (bool) {
        return hasRole(DEFAULT_ADMIN_ROLE, _address);
    }

    /**
     * @notice Used to check whether an address has the minter role
     * @param _address EOA or contract being checked
     * @return bool True if the account has the role or false if it does not
     */
    function hasMinterRole(address _address) external view returns (bool) {
        return hasRole(MINTER_ROLE, _address);
    }

    /**
     * @notice Used to check whether an address has the smart contract role
     * @param _address EOA or contract being checked
     * @return bool True if the account has the role or false if it does not
     */
    function hasSmartContractRole(address _address) external view returns (bool) {
        return hasRole(SMART_CONTRACT_ROLE, _address);
    }

    ///////////////
    // Modifiers //
    ///////////////

    /**
     * @notice Grants the admin role to an address
     * @dev The sender must have the admin role
     * @param _address EOA or contract receiving the new role
     */
    function addAdminRole(address _address) external {
        grantRole(DEFAULT_ADMIN_ROLE, _address);
        emit AdminRoleGranted(_address, _msgSender());
    }

    /**
     * @notice Removes the admin role from an address
     * @dev The sender must have the admin role
     * @param _address EOA or contract affected
     */
    function removeAdminRole(address _address) external {
        revokeRole(DEFAULT_ADMIN_ROLE, _address);
        emit AdminRoleRemoved(_address, _msgSender());
    }

    /**
     * @notice Grants the minter role to an address
     * @dev The sender must have the admin role
     * @param _address EOA or contract receiving the new role
     */
    function addMinterRole(address _address) external {
        grantRole(MINTER_ROLE, _address);
        emit MinterRoleGranted(_address, _msgSender());
    }

    /**
     * @notice Removes the minter role from an address
     * @dev The sender must have the admin role
     * @param _address EOA or contract affected
     */
    function removeMinterRole(address _address) external {
        revokeRole(MINTER_ROLE, _address);
        emit MinterRoleRemoved(_address, _msgSender());
    }

    /**
     * @notice Grants the smart contract role to an address
     * @dev The sender must have the admin role
     * @param _address EOA or contract receiving the new role
     */
    function addSmartContractRole(address _address) external {
        grantRole(SMART_CONTRACT_ROLE, _address);
        emit SmartContractRoleGranted(_address, _msgSender());
    }

    /**
     * @notice Removes the smart contract role from an address
     * @dev The sender must have the admin role
     * @param _address EOA or contract affected
     */
    function removeSmartContractRole(address _address) external {
        revokeRole(SMART_CONTRACT_ROLE, _address);
        emit SmartContractRoleRemoved(_address, _msgSender());
    }
}


// File @openzeppelin/contracts/introspection/IERC165.sol@v3.2.0



pragma solidity ^0.6.0;

/**
 * @dev Interface of the ERC165 standard, as defined in the
 * https://eips.ethereum.org/EIPS/eip-165[EIP].
 *
 * Implementers can declare support of contract interfaces, which can then be
 * queried by others ({ERC165Checker}).
 *
 * For an implementation, see {ERC165}.
 */



// File @openzeppelin/contracts/token/ERC721/IERC721.sol@v3.2.0



pragma solidity ^0.6.2;

/**
 * @dev Required interface of an ERC721 compliant contract.
 */
interface IERC721 is IERC165 {
    /**
     * @dev Emitted when `tokenId` token is transferred from `from` to `to`.
     */
    event Transfer(address indexed from, address indexed to, uint256 indexed tokenId);

    /**
     * @dev Emitted when `owner` enables `approved` to manage the `tokenId` token.
     */
    event Approval(address indexed owner, address indexed approved, uint256 indexed tokenId);

    /**
     * @dev Emitted when `owner` enables or disables (`approved`) `operator` to manage all of its assets.
     */
    event ApprovalForAll(address indexed owner, address indexed operator, bool approved);

    /**
     * @dev Returns the number of tokens in ``owner``'s account.
     */
    function balanceOf(address owner) external view returns (uint256 balance);

    /**
     * @dev Returns the owner of the `tokenId` token.
     *
     * Requirements:
     *
     * - `tokenId` must exist.
     */
    function ownerOf(uint256 tokenId) external view returns (address owner);

    /**
     * @dev Safely transfers `tokenId` token from `from` to `to`, checking first that contract recipients
     * are aware of the ERC721 protocol to prevent tokens from being forever locked.
     *
     * Requirements:
     *
     * - `from` cannot be the zero address.
     * - `to` cannot be the zero address.
     * - `tokenId` token must exist and be owned by `from`.
     * - If the caller is not `from`, it must be have been allowed to move this token by either {approve} or {setApprovalForAll}.
     * - If `to` refers to a smart contract, it must implement {IERC721Receiver-onERC721Received}, which is called upon a safe transfer.
     *
     * Emits a {Transfer} event.
     */
    function safeTransferFrom(address from, address to, uint256 tokenId) external;

    /**
     * @dev Transfers `tokenId` token from `from` to `to`.
     *
     * WARNING: Usage of this method is discouraged, use {safeTransferFrom} whenever possible.
     *
     * Requirements:
     *
     * - `from` cannot be the zero address.
     * - `to` cannot be the zero address.
     * - `tokenId` token must be owned by `from`.
     * - If the caller is not `from`, it must be approved to move this token by either {approve} or {setApprovalForAll}.
     *
     * Emits a {Transfer} event.
     */
    function transferFrom(address from, address to, uint256 tokenId) external;

    /**
     * @dev Gives permission to `to` to transfer `tokenId` token to another account.
     * The approval is cleared when the token is transferred.
     *
     * Only a single account can be approved at a time, so approving the zero address clears previous approvals.
     *
     * Requirements:
     *
     * - The caller must own the token or be an approved operator.
     * - `tokenId` must exist.
     *
     * Emits an {Approval} event.
     */
    function approve(address to, uint256 tokenId) external;

    /**
     * @dev Returns the account approved for `tokenId` token.
     *
     * Requirements:
     *
     * - `tokenId` must exist.
     */
    function getApproved(uint256 tokenId) external view returns (address operator);

    /**
     * @dev Approve or remove `operator` as an operator for the caller.
     * Operators can call {transferFrom} or {safeTransferFrom} for any token owned by the caller.
     *
     * Requirements:
     *
     * - The `operator` cannot be the caller.
     *
     * Emits an {ApprovalForAll} event.
     */
    function setApprovalForAll(address operator, bool _approved) external;

    /**
     * @dev Returns if the `operator` is allowed to manage all of the assets of `owner`.
     *
     * See {setApprovalForAll}
     */
    function isApprovedForAll(address owner, address operator) external view returns (bool);

    /**
      * @dev Safely transfers `tokenId` token from `from` to `to`.
      *
      * Requirements:
      *
     * - `from` cannot be the zero address.
     * - `to` cannot be the zero address.
      * - `tokenId` token must exist and be owned by `from`.
      * - If the caller is not `from`, it must be approved to move this token by either {approve} or {setApprovalForAll}.
      * - If `to` refers to a smart contract, it must implement {IERC721Receiver-onERC721Received}, which is called upon a safe transfer.
      *
      * Emits a {Transfer} event.
      */
    function safeTransferFrom(address from, address to, uint256 tokenId, bytes calldata data) external;
}


// File @openzeppelin/contracts/token/ERC721/IERC721Metadata.sol@v3.2.0



pragma solidity ^0.6.2;

/**
 * @title ERC-721 Non-Fungible Token Standard, optional metadata extension
 * @dev See https://eips.ethereum.org/EIPS/eip-721
 */
interface IERC721Metadata is IERC721 {

    /**
     * @dev Returns the token collection name.
     */
    function name() external view returns (string memory);

    /**
     * @dev Returns the token collection symbol.
     */
    function symbol() external view returns (string memory);

    /**
     * @dev Returns the Uniform Resource Identifier (URI) for `tokenId` token.
     */
    function tokenURI(uint256 tokenId) external view returns (string memory);
}


// File @openzeppelin/contracts/token/ERC721/IERC721Enumerable.sol@v3.2.0



pragma solidity ^0.6.2;

/**
 * @title ERC-721 Non-Fungible Token Standard, optional enumeration extension
 * @dev See https://eips.ethereum.org/EIPS/eip-721
 */
interface IERC721Enumerable is IERC721 {

    /**
     * @dev Returns the total amount of tokens stored by the contract.
     */
    function totalSupply() external view returns (uint256);

    /**
     * @dev Returns a token ID owned by `owner` at a given `index` of its token list.
     * Use along with {balanceOf} to enumerate all of ``owner``'s tokens.
     */
    function tokenOfOwnerByIndex(address owner, uint256 index) external view returns (uint256 tokenId);

    /**
     * @dev Returns a token ID at a given `index` of all the tokens stored by the contract.
     * Use along with {totalSupply} to enumerate all tokens.
     */
    function tokenByIndex(uint256 index) external view returns (uint256);
}


// File @openzeppelin/contracts/token/ERC721/IERC721Receiver.sol@v3.2.0



pragma solidity ^0.6.0;

/**
 * @title ERC721 token receiver interface
 * @dev Interface for any contract that wants to support safeTransfers
 * from ERC721 asset contracts.
 */



// File @openzeppelin/contracts/introspection/ERC165.sol@v3.2.0



pragma solidity ^0.6.0;

/**
 * @dev Implementation of the {IERC165} interface.
 *
 * Contracts may inherit from this and call {_registerInterface} to declare
 * their support of an interface.
 */
contract ERC165 is IERC165 {
    /*
     * bytes4(keccak256('supportsInterface(bytes4)')) == 0x01ffc9a7
     */
    bytes4 private constant _INTERFACE_ID_ERC165 = 0x01ffc9a7;

    /**
     * @dev Mapping of interface ids to whether or not it's supported.
     */
    mapping(bytes4 => bool) private _supportedInterfaces;

    constructor () internal {
        // Derived contracts need only register support for their own interfaces,
        // we register support for ERC165 itself here
        _registerInterface(_INTERFACE_ID_ERC165);
    }

    /**
     * @dev See {IERC165-supportsInterface}.
     *
     * Time complexity O(1), guaranteed to always use less than 30 000 gas.
     */
    function supportsInterface(bytes4 interfaceId) public view override returns (bool) {
        return _supportedInterfaces[interfaceId];
    }

    /**
     * @dev Registers the contract as an implementer of the interface defined by
     * `interfaceId`. Support of the actual ERC165 interface is automatic and
     * registering its interface id is not required.
     *
     * See {IERC165-supportsInterface}.
     *
     * Requirements:
     *
     * - `interfaceId` cannot be the ERC165 invalid interface (`0xffffffff`).
     */
    function _registerInterface(bytes4 interfaceId) internal virtual {
        require(interfaceId != 0xffffffff, "ERC165: invalid interface id");
        _supportedInterfaces[interfaceId] = true;
    }
}


// File @openzeppelin/contracts/utils/EnumerableMap.sol@v3.2.0



pragma solidity ^0.6.0;

/**
 * @dev Library for managing an enumerable variant of Solidity's
 * https://solidity.readthedocs.io/en/latest/types.html#mapping-types[`mapping`]
 * type.
 *
 * Maps have the following properties:
 *
 * - Entries are added, removed, and checked for existence in constant time
 * (O(1)).
 * - Entries are enumerated in O(n). No guarantees are made on the ordering.
 *
 * ```
 * contract Example {
 *     // Add the library methods
 *     using EnumerableMap for EnumerableMap.UintToAddressMap;
 *
 *     // Declare a set state variable
 *     EnumerableMap.UintToAddressMap private myMap;
 * }
 * ```
 *
 * As of v3.0.0, only maps of type `uint256 -> address` (`UintToAddressMap`) are
 * supported.
 */



// File @openzeppelin/contracts/utils/Strings.sol@v3.2.0



pragma solidity ^0.6.0;

/**
 * @dev String operations.
 */



// File contracts/ERC721/ERC721WithSameTokenURIForAllTokens.sol



pragma solidity 0.6.12;










/**
 * @title ERC721 Non-Fungible Token Standard basic implementation
 * @dev see https://eips.ethereum.org/EIPS/eip-721
 * @dev This is a modified OZ ERC721 base contract with one change where all tokens have the same token URI
 */
contract ERC721WithSameTokenURIForAllTokens is Context, ERC165, IERC721, IERC721Metadata, IERC721Enumerable {
    using SafeMath for uint256;
    using Address for address;
    using EnumerableSet for EnumerableSet.UintSet;
    using EnumerableMap for EnumerableMap.UintToAddressMap;
    using Strings for uint256;

    // Equals to `bytes4(keccak256("onERC721Received(address,address,uint256,bytes)"))`
    // which can be also obtained as `IERC721Receiver(0).onERC721Received.selector`
    bytes4 private constant _ERC721_RECEIVED = 0x150b7a02;

    // Mapping from holder address to their (enumerable) set of owned tokens
    mapping (address => EnumerableSet.UintSet) private _holderTokens;

    // Enumerable mapping from token ids to their owners
    EnumerableMap.UintToAddressMap private _tokenOwners;

    // Mapping from token ID to approved address
    mapping (uint256 => address) private _tokenApprovals;

    // Mapping from owner to operator approvals
    mapping (address => mapping (address => bool)) private _operatorApprovals;

    // Token name
    string private _name;

    // Token symbol
    string private _symbol;

    // Single token URI for all tokens
    string public tokenURI_;

    /*
     *     bytes4(keccak256('balanceOf(address)')) == 0x70a08231
     *     bytes4(keccak256('ownerOf(uint256)')) == 0x6352211e
     *     bytes4(keccak256('approve(address,uint256)')) == 0x095ea7b3
     *     bytes4(keccak256('getApproved(uint256)')) == 0x081812fc
     *     bytes4(keccak256('setApprovalForAll(address,bool)')) == 0xa22cb465
     *     bytes4(keccak256('isApprovedForAll(address,address)')) == 0xe985e9c5
     *     bytes4(keccak256('transferFrom(address,address,uint256)')) == 0x23b872dd
     *     bytes4(keccak256('safeTransferFrom(address,address,uint256)')) == 0x42842e0e
     *     bytes4(keccak256('safeTransferFrom(address,address,uint256,bytes)')) == 0xb88d4fde
     *
     *     => 0x70a08231 ^ 0x6352211e ^ 0x095ea7b3 ^ 0x081812fc ^
     *        0xa22cb465 ^ 0xe985e9c5 ^ 0x23b872dd ^ 0x42842e0e ^ 0xb88d4fde == 0x80ac58cd
     */
    bytes4 private constant _INTERFACE_ID_ERC721 = 0x80ac58cd;

    /*
     *     bytes4(keccak256('name()')) == 0x06fdde03
     *     bytes4(keccak256('symbol()')) == 0x95d89b41
     *     bytes4(keccak256('tokenURI(uint256)')) == 0xc87b56dd
     *
     *     => 0x06fdde03 ^ 0x95d89b41 ^ 0xc87b56dd == 0x5b5e139f
     */
    bytes4 private constant _INTERFACE_ID_ERC721_METADATA = 0x5b5e139f;

    /*
     *     bytes4(keccak256('totalSupply()')) == 0x18160ddd
     *     bytes4(keccak256('tokenOfOwnerByIndex(address,uint256)')) == 0x2f745c59
     *     bytes4(keccak256('tokenByIndex(uint256)')) == 0x4f6ccce7
     *
     *     => 0x18160ddd ^ 0x2f745c59 ^ 0x4f6ccce7 == 0x780e9d63
     */
    bytes4 private constant _INTERFACE_ID_ERC721_ENUMERABLE = 0x780e9d63;

    /**
     * @dev Initializes the contract by setting a `name` and a `symbol` to the token collection.
     */
    constructor (string memory name, string memory symbol) public {
        _name = name;
        _symbol = symbol;

        // register the supported interfaces to conform to ERC721 via ERC165
        _registerInterface(_INTERFACE_ID_ERC721);
        _registerInterface(_INTERFACE_ID_ERC721_METADATA);
        _registerInterface(_INTERFACE_ID_ERC721_ENUMERABLE);
    }

    /**
     * @dev See {IERC721-balanceOf}.
     */
    function balanceOf(address owner) public view override returns (uint256) {
        require(owner != address(0), "ERC721: balance query for the zero address");

        return _holderTokens[owner].length();
    }

    /**
     * @dev See {IERC721-ownerOf}.
     */
    function ownerOf(uint256 tokenId) public view override returns (address) {
        return _tokenOwners.get(tokenId, "ERC721: owner query for nonexistent token");
    }

    /**
     * @dev See {IERC721Metadata-name}.
     */
    function name() public view override returns (string memory) {
        return _name;
    }

    /**
     * @dev See {IERC721Metadata-symbol}.
     */
    function symbol() public view override returns (string memory) {
        return _symbol;
    }

    /**
     * @dev See {IERC721Metadata-tokenURI}.
     */
    function tokenURI(uint256 tokenId) public view override returns (string memory) {
        require(_exists(tokenId), "ERC721Metadata: URI query for nonexistent token");

        return tokenURI_;
    }

    /**
     * @dev See {IERC721Enumerable-tokenOfOwnerByIndex}.
     */
    function tokenOfOwnerByIndex(address owner, uint256 index) public view override returns (uint256) {
        return _holderTokens[owner].at(index);
    }

    /**
     * @dev See {IERC721Enumerable-totalSupply}.
     */
    function totalSupply() public view override returns (uint256) {
        // _tokenOwners are indexed by tokenIds, so .length() returns the number of tokenIds
        return _tokenOwners.length();
    }

    /**
     * @dev See {IERC721Enumerable-tokenByIndex}.
     */
    function tokenByIndex(uint256 index) public view override returns (uint256) {
        (uint256 tokenId, ) = _tokenOwners.at(index);
        return tokenId;
    }

    /**
     * @dev See {IERC721-approve}.
     */
    function approve(address to, uint256 tokenId) public virtual override {
        address owner = ownerOf(tokenId);
        require(to != owner, "ERC721: approval to current owner");

        require(_msgSender() == owner || isApprovedForAll(owner, _msgSender()),
            "ERC721: approve caller is not owner nor approved for all"
        );

        _approve(to, tokenId);
    }

    /**
     * @dev See {IERC721-getApproved}.
     */
    function getApproved(uint256 tokenId) public view override returns (address) {
        require(_exists(tokenId), "ERC721: approved query for nonexistent token");

        return _tokenApprovals[tokenId];
    }

    /**
     * @dev See {IERC721-setApprovalForAll}.
     */
    function setApprovalForAll(address operator, bool approved) public virtual override {
        require(operator != _msgSender(), "ERC721: approve to caller");

        _operatorApprovals[_msgSender()][operator] = approved;
        emit ApprovalForAll(_msgSender(), operator, approved);
    }

    /**
     * @dev See {IERC721-isApprovedForAll}.
     */
    function isApprovedForAll(address owner, address operator) public view override returns (bool) {
        return _operatorApprovals[owner][operator];
    }

    /**
     * @dev See {IERC721-transferFrom}.
     */
    function transferFrom(address from, address to, uint256 tokenId) public virtual override {
        //solhint-disable-next-line max-line-length
        require(_isApprovedOrOwner(_msgSender(), tokenId), "ERC721: transfer caller is not owner nor approved");

        _transfer(from, to, tokenId);
    }

    /**
     * @dev See {IERC721-safeTransferFrom}.
     */
    function safeTransferFrom(address from, address to, uint256 tokenId) public virtual override {
        safeTransferFrom(from, to, tokenId, "");
    }

    /**
     * @dev See {IERC721-safeTransferFrom}.
     */
    function safeTransferFrom(address from, address to, uint256 tokenId, bytes memory _data) public virtual override {
        require(_isApprovedOrOwner(_msgSender(), tokenId), "ERC721: transfer caller is not owner nor approved");
        _safeTransfer(from, to, tokenId, _data);
    }

    /**
     * @dev Safely transfers `tokenId` token from `from` to `to`, checking first that contract recipients
     * are aware of the ERC721 protocol to prevent tokens from being forever locked.
     *
     * `_data` is additional data, it has no specified format and it is sent in call to `to`.
     *
     * This internal function is equivalent to {safeTransferFrom}, and can be used to e.g.
     * implement alternative mechanisms to perform token transfer, such as signature-based.
     *
     * Requirements:
     *
     * - `from` cannot be the zero address.
     * - `to` cannot be the zero address.
     * - `tokenId` token must exist and be owned by `from`.
     * - If `to` refers to a smart contract, it must implement {IERC721Receiver-onERC721Received}, which is called upon a safe transfer.
     *
     * Emits a {Transfer} event.
     */
    function _safeTransfer(address from, address to, uint256 tokenId, bytes memory _data) internal virtual {
        _transfer(from, to, tokenId);
        require(_checkOnERC721Received(from, to, tokenId, _data), "ERC721: transfer to non ERC721Receiver implementer");
    }

    /**
     * @dev Returns whether `tokenId` exists.
     *
     * Tokens can be managed by their owner or approved accounts via {approve} or {setApprovalForAll}.
     *
     * Tokens start existing when they are minted (`_mint`),
     * and stop existing when they are burned (`_burn`).
     */
    function _exists(uint256 tokenId) internal view returns (bool) {
        return _tokenOwners.contains(tokenId);
    }

    /**
     * @dev Returns whether `spender` is allowed to manage `tokenId`.
     *
     * Requirements:
     *
     * - `tokenId` must exist.
     */
    function _isApprovedOrOwner(address spender, uint256 tokenId) internal view returns (bool) {
        require(_exists(tokenId), "ERC721: operator query for nonexistent token");
        address owner = ownerOf(tokenId);
        return (spender == owner || getApproved(tokenId) == spender || isApprovedForAll(owner, spender));
    }

    /**
     * @dev Safely mints `tokenId` and transfers it to `to`.
     *
     * Requirements:
     d*
     * - `tokenId` must not exist.
     * - If `to` refers to a smart contract, it must implement {IERC721Receiver-onERC721Received}, which is called upon a safe transfer.
     *
     * Emits a {Transfer} event.
     */
    function _safeMint(address to, uint256 tokenId) internal virtual {
        _safeMint(to, tokenId, "");
    }

    /**
     * @dev Same as {xref-ERC721-_safeMint-address-uint256-}[`_safeMint`], with an additional `data` parameter which is
     * forwarded in {IERC721Receiver-onERC721Received} to contract recipients.
     */
    function _safeMint(address to, uint256 tokenId, bytes memory _data) internal virtual {
        _mint(to, tokenId);
        require(_checkOnERC721Received(address(0), to, tokenId, _data), "ERC721: transfer to non ERC721Receiver implementer");
    }

    /**
     * @dev Mints `tokenId` and transfers it to `to`.
     *
     * WARNING: Usage of this method is discouraged, use {_safeMint} whenever possible
     *
     * Requirements:
     *
     * - `tokenId` must not exist.
     * - `to` cannot be the zero address.
     *
     * Emits a {Transfer} event.
     */
    function _mint(address to, uint256 tokenId) internal virtual {
        require(to != address(0), "ERC721: mint to the zero address");
        require(!_exists(tokenId), "ERC721: token already minted");

        _beforeTokenTransfer(address(0), to, tokenId);

        _holderTokens[to].add(tokenId);

        _tokenOwners.set(tokenId, to);

        emit Transfer(address(0), to, tokenId);
    }

    /**
     * @dev Destroys `tokenId`.
     * The approval is cleared when the token is burned.
     *
     * Requirements:
     *
     * - `tokenId` must exist.
     *
     * Emits a {Transfer} event.
     */
    function _burn(uint256 tokenId) internal virtual {
        address owner = ownerOf(tokenId);

        _beforeTokenTransfer(owner, address(0), tokenId);

        // Clear approvals
        _approve(address(0), tokenId);

        _holderTokens[owner].remove(tokenId);

        _tokenOwners.remove(tokenId);

        emit Transfer(owner, address(0), tokenId);
    }

    /**
     * @dev Transfers `tokenId` from `from` to `to`.
     *  As opposed to {transferFrom}, this imposes no restrictions on msg.sender.
     *
     * Requirements:
     *
     * - `to` cannot be the zero address.
     * - `tokenId` token must be owned by `from`.
     *
     * Emits a {Transfer} event.
     */
    function _transfer(address from, address to, uint256 tokenId) internal virtual {
        require(ownerOf(tokenId) == from, "ERC721: transfer of token that is not own");
        require(to != address(0), "ERC721: transfer to the zero address");

        _beforeTokenTransfer(from, to, tokenId);

        // Clear approvals from the previous owner
        _approve(address(0), tokenId);

        _holderTokens[from].remove(tokenId);
        _holderTokens[to].add(tokenId);

        _tokenOwners.set(tokenId, to);

        emit Transfer(from, to, tokenId);
    }

    /**
     * @dev Internal function to invoke {IERC721Receiver-onERC721Received} on a target address.
     * The call is not executed if the target address is not a contract.
     *
     * @param from address representing the previous owner of the given token ID
     * @param to target address that will receive the tokens
     * @param tokenId uint256 ID of the token to be transferred
     * @param _data bytes optional data to send along with the call
     * @return bool whether the call correctly returned the expected magic value
     */
    function _checkOnERC721Received(address from, address to, uint256 tokenId, bytes memory _data)
    private returns (bool)
    {
        if (!to.isContract()) {
            return true;
        }
        bytes memory returndata = to.functionCall(abi.encodeWithSelector(
                IERC721Receiver(to).onERC721Received.selector,
                _msgSender(),
                from,
                tokenId,
                _data
            ), "ERC721: transfer to non ERC721Receiver implementer");
        bytes4 retval = abi.decode(returndata, (bytes4));
        return (retval == _ERC721_RECEIVED);
    }

    function _approve(address to, uint256 tokenId) private {
        _tokenApprovals[tokenId] = to;
        emit Approval(ownerOf(tokenId), to, tokenId);
    }

    /**
     * @dev Hook that is called before any token transfer. This includes minting
     * and burning.
     *
     * Calling conditions:
     *
     * - When `from` and `to` are both non-zero, ``from``'s `tokenId` will be
     * transferred to `to`.
     * - When `from` is zero, `tokenId` will be minted for `to`.
     * - When `to` is zero, ``from``'s `tokenId` will be burned.
     * - `from` cannot be the zero address.
     * - `to` cannot be the zero address.
     *
     * To learn more about hooks, head to xref:ROOT:extending-contracts.adoc#using-hooks[Using Hooks].
     */
    function _beforeTokenTransfer(address from, address to, uint256 tokenId) internal virtual { }
}


// File contracts/DigitalaxGenesisNFT.sol



pragma solidity 0.6.12;



/**
 * @title Digitalax Genesis NFT
 * @dev To facilitate the genesis sale for the Digitialax platform
 */
contract DigitalaxGenesisNFT is ERC721WithSameTokenURIForAllTokens("DigitalaxGenesis", "DXG") {
    using SafeMath for uint256;

    // @notice event emitted upon construction of this contract, used to bootstrap external indexers
    event DigitalaxGenesisNFTContractDeployed();

    // @notice event emitted when a contributor buys a Genesis NFT
    event GenesisPurchased(
        address indexed buyer,
        uint256 indexed tokenId,
        uint256 contribution
    );

    // @notice event emitted when a admin mints a Genesis NFT
    event AdminGenesisMinted(
        address indexed beneficiary,
        address indexed admin,
        uint256 indexed tokenId
    );

    // @notice event emitted when a contributors amount is increased
    event ContributionIncreased(
        address indexed buyer,
        uint256 contribution
    );

    // @notice event emitted when end date is changed
    event GenesisEndUpdated(
        uint256 genesisEndTimestamp,
        address indexed admin
    );

    // @notice event emitted when DigitalaxAccessControls is updated
    event AccessControlsUpdated(
        address indexed newAdress
    );

    // @notice responsible for enforcing admin access
    DigitalaxAccessControls public accessControls;

    // @notice all funds will be sent to this address pon purchase of a Genesis NFT
    address payable public fundsMultisig;

    // @notice start date for them the Genesis sale is open to the public, before this data no purchases can be made
    uint256 public genesisStartTimestamp;

    // @notice end date for them the Genesis sale is closed, no more purchased can be made after this point
    uint256 public genesisEndTimestamp;

    // @notice set after end time has been changed once, prevents further changes to end timestamp
    bool public genesisEndTimestampLocked;

    // @notice the minimum amount a buyer can contribute in a single go
    uint256 public constant minimumContributionAmount = 0.1 ether;

    // @notice the maximum accumulative amount a user can contribute to the genesis sale
    uint256 public constant maximumContributionAmount = 2 ether;

    // @notice accumulative => contribution total
    mapping(address => uint256) public contribution;

    // @notice global accumulative contribution amount
    uint256 public totalContributions;

    // @notice max number of paid contributions to the genesis sale
    uint256 public constant maxGenesisContributionTokens = 460;

    uint256 public totalAdminMints;

    constructor(
        DigitalaxAccessControls _accessControls,
        address payable _fundsMultisig,
        uint256 _genesisStartTimestamp,
        uint256 _genesisEndTimestamp,
        string memory _tokenURI
    ) public {
        accessControls = _accessControls;
        fundsMultisig = _fundsMultisig;
        genesisStartTimestamp = _genesisStartTimestamp;
        genesisEndTimestamp = _genesisEndTimestamp;
        tokenURI_ = _tokenURI;
        emit DigitalaxGenesisNFTContractDeployed();
    }

    /**
     * @dev Proxy method for facilitating a single point of entry to either buy or contribute additional value to the Genesis sale
     * @dev Cannot contribute less than minimumContributionAmount
     * @dev Cannot contribute accumulative more than than maximumContributionAmount
     */
    function buyOrIncreaseContribution() external payable {
        if (contribution[_msgSender()] == 0) {
            buy();
        } else {
            increaseContribution();
        }
    }

    /**
     * @dev Facilitating the initial purchase of a Genesis NFT
     * @dev Cannot contribute less than minimumContributionAmount
     * @dev Cannot contribute accumulative more than than maximumContributionAmount
     * @dev Reverts if already owns an genesis token
     * @dev Buyer receives a NFT on success
     * @dev All funds move to fundsMultisig
     */
    function buy() public payable {
        require(contribution[_msgSender()] == 0, "DigitalaxGenesisNFT.buy: You already own a genesis NFT");
        require(
            _getNow() >= genesisStartTimestamp && _getNow() <= genesisEndTimestamp,
            "DigitalaxGenesisNFT.buy: No genesis are available outside of the genesis window"
        );

        uint256 _contributionAmount = msg.value;
        require(
            _contributionAmount >= minimumContributionAmount,
            "DigitalaxGenesisNFT.buy: Contribution does not meet minimum requirement"
        );

        require(
            _contributionAmount <= maximumContributionAmount,
            "DigitalaxGenesisNFT.buy: You cannot exceed the maximum contribution amount"
        );

        require(remainingGenesisTokens() > 0, "DigitalaxGenesisNFT.buy: Total number of genesis token holders reached");

        contribution[_msgSender()] = _contributionAmount;
        totalContributions = totalContributions.add(_contributionAmount);

        (bool fundsTransferSuccess,) = fundsMultisig.call{value : _contributionAmount}("");
        require(fundsTransferSuccess, "DigitalaxGenesisNFT.buy: Unable to send contribution to funds multisig");

        uint256 tokenId = totalSupply().add(1);
        _safeMint(_msgSender(), tokenId);

        emit GenesisPurchased(_msgSender(), tokenId, _contributionAmount);
    }

    /**
     * @dev Facilitates an owner to increase there contribution
     * @dev Cannot contribute less than minimumContributionAmount
     * @dev Cannot contribute accumulative more than than maximumContributionAmount
     * @dev Reverts if caller does not already owns an genesis token
     * @dev All funds move to fundsMultisig
     */
    function increaseContribution() public payable {
        require(
            _getNow() >= genesisStartTimestamp && _getNow() <= genesisEndTimestamp,
            "DigitalaxGenesisNFT.increaseContribution: No increases are possible outside of the genesis window"
        );

        require(
            contribution[_msgSender()] > 0,
            "DigitalaxGenesisNFT.increaseContribution: You do not own a genesis NFT"
        );

        uint256 _amountToIncrease = msg.value;
        contribution[_msgSender()] = contribution[_msgSender()].add(_amountToIncrease);

        require(
            contribution[_msgSender()] <= maximumContributionAmount,
            "DigitalaxGenesisNFT.increaseContribution: You cannot exceed the maximum contribution amount"
        );

        totalContributions = totalContributions.add(_amountToIncrease);

        (bool fundsTransferSuccess,) = fundsMultisig.call{value : _amountToIncrease}("");
        require(
            fundsTransferSuccess,
            "DigitalaxGenesisNFT.increaseContribution: Unable to send contribution to funds multisig"
        );

        emit ContributionIncreased(_msgSender(), _amountToIncrease);
    }

    // Admin

    /**
     * @dev Allows a whitelisted admin to mint a token and issue it to a beneficiary
     * @dev One token per holder
     * @dev All holders contribution as set o zero on creation
     */
    function adminBuy(address _beneficiary) external {
        require(
            accessControls.hasAdminRole(_msgSender()),
            "DigitalaxGenesisNFT.adminBuy: Sender must be admin"
        );
        require(_beneficiary != address(0), "DigitalaxGenesisNFT.adminBuy: Beneficiary cannot be ZERO");
        require(balanceOf(_beneficiary) == 0, "DigitalaxGenesisNFT.adminBuy: Beneficiary already owns a genesis NFT");

        uint256 tokenId = totalSupply().add(1);
        _safeMint(_beneficiary, tokenId);

        // Increase admin mint counts
        totalAdminMints = totalAdminMints.add(1);

        emit AdminGenesisMinted(_beneficiary, _msgSender(), tokenId);
    }

    /**
     * @dev Allows a whitelisted admin to update the end date of the genesis
     */
    function updateGenesisEnd(uint256 _end) external {
        require(
            accessControls.hasAdminRole(_msgSender()),
            "DigitalaxGenesisNFT.updateGenesisEnd: Sender must be admin"
        );
        // If already passed, dont allow opening again
        require(genesisEndTimestamp > _getNow(), "DigitalaxGenesisNFT.updateGenesisEnd: End time already passed");

        // Only allow setting this once
        require(!genesisEndTimestampLocked, "DigitalaxGenesisNFT.updateGenesisEnd: End time locked");

        genesisEndTimestamp = _end;

        // Lock future end time modifications
        genesisEndTimestampLocked = true;

        emit GenesisEndUpdated(genesisEndTimestamp, _msgSender());
    }

    /**
     * @dev Allows a whitelisted admin to update the start date of the genesis
     */
    function updateAccessControls(DigitalaxAccessControls _accessControls) external {
        require(
            accessControls.hasAdminRole(_msgSender()),
            "DigitalaxGenesisNFT.updateAccessControls: Sender must be admin"
        );
        require(address(_accessControls) != address(0), "DigitalaxGenesisNFT.updateAccessControls: Zero Address");
        accessControls = _accessControls;

        emit AccessControlsUpdated(address(_accessControls));
    }

    /**
    * @dev Returns total remaining number of tokens available in the Genesis sale
    */
    function remainingGenesisTokens() public view returns (uint256) {
        return _getMaxGenesisContributionTokens() - (totalSupply() - totalAdminMints);
    }

    // Internal

    function _getNow() internal virtual view returns (uint256) {
        return block.timestamp;
    }

    function _getMaxGenesisContributionTokens() internal virtual view returns (uint256) {
        return maxGenesisContributionTokens;
    }

    /**
     * @dev Before token transfer hook to enforce that no token can be moved to another address until the genesis sale has ended
     */
    function _beforeTokenTransfer(address from, address to, uint256 tokenId) internal override {
        if (from != address(0) && _getNow() <= genesisEndTimestamp) {
            revert("DigitalaxGenesisNFT._beforeTokenTransfer: Transfers are currently locked at this time");
        }
    }
}


// File interfaces/IERC20.sol

pragma solidity ^0.6.2;





// File interfaces/IUniswapV2Pair.sol

pragma solidity >=0.5.0;




// File contracts/Utils/UniswapV2Library.sol

pragma solidity 0.6.12;





// File contracts/DigitalaxRewards.sol

// SPDX-License-Identifier: GPLv2

pragma solidity 0.6.12;







/**
 * @title Digitalax Rewards
 * @dev Calculates the rewards for staking on the Digitialax platform
 * @author Adrian Guerrera (deepyr)
 */



interface MONA is IERC20 {
    function mint(address tokenOwner, uint tokens) external returns (bool);
}

contract DigitalaxRewards {
    using SafeMath for uint256;

    /* ========== Variables ========== */

    MONA public rewardsToken;
    DigitalaxAccessControls public accessControls;
    DigialaxStaking public genesisStaking;
    DigialaxStaking public parentStaking;
    DigialaxStaking public lpStaking;

    uint256 constant pointMultiplier = 10e18;
    uint256 constant SECONDS_PER_DAY = 24 * 60 * 60;
    uint256 constant SECONDS_PER_WEEK = 7 * 24 * 60 * 60;
    
    // weekNumber => rewards
    mapping (uint256 => uint256) public weeklyRewardsPerSecond;
    mapping (address => mapping(uint256 => uint256)) public weeklyBonusPerSecond;

    uint256 public startTime;
    uint256 public lastRewardTime;

    uint256 public genesisRewardsPaid;
    uint256 public parentRewardsPaid;
    uint256 public lpRewardsPaid;

    /* ========== Structs ========== */

    struct Weights {
        uint256 genesisWtPoints;
        uint256 parentWtPoints;
        uint256 lpWeightPoints;
    }

    /// @notice mapping of a staker to its current properties
    mapping (uint256 => Weights) public weeklyWeightPoints;

    /* ========== Events ========== */

    event RewardAdded(address indexed addr, uint256 reward);
    event RewardDistributed(address indexed addr, uint256 reward);
    event Recovered(address indexed token, uint256 amount);

    
    /* ========== Admin Functions ========== */
    constructor(
        MONA _rewardsToken,
        DigitalaxAccessControls _accessControls,
        DigialaxStaking _genesisStaking,
        DigialaxStaking _parentStaking,
        DigialaxStaking _lpStaking,
        uint256 _startTime,
        uint256 _lastRewardTime,
        uint256 _genesisRewardsPaid,
        uint256 _parentRewardsPaid,
        uint256 _lpRewardsPaid

    )
        public
    {
        rewardsToken = _rewardsToken;
        accessControls = _accessControls;
        genesisStaking = _genesisStaking;
        parentStaking = _parentStaking;
        lpStaking = _lpStaking;
        startTime = _startTime;
        lastRewardTime = _lastRewardTime;
        genesisRewardsPaid = _genesisRewardsPaid;
        parentRewardsPaid = _parentRewardsPaid;
        lpRewardsPaid = _lpRewardsPaid;        
    }

    /// @dev Setter functions for contract config
    function setStartTime(
        uint256 _startTime,
        uint256 _lastRewardTime
    )
        external
    {
        require(
            accessControls.hasAdminRole(msg.sender),
            "DigitalaxRewards.setStartTime: Sender must be admin"
        );
        startTime = _startTime;
        lastRewardTime = _lastRewardTime;
    }

    /// @dev Setter functions for contract config
    function setInitialPoints(
        uint256 week,
        uint256 gW,
        uint256 pW,
        uint256 mW

    )
        external
    {
        require(
            accessControls.hasAdminRole(msg.sender),
            "DigitalaxRewards.setStartTime: Sender must be admin"
        );
        Weights storage weights = weeklyWeightPoints[week];
        weights.genesisWtPoints = gW;
        weights.parentWtPoints = pW;
        weights.lpWeightPoints = mW;

    }

    function setGenesisStaking(
        address _addr
    )
        external
    {
        require(
            accessControls.hasAdminRole(msg.sender),
            "DigitalaxRewards.setGenesisStaking: Sender must be admin"
        );
        require(_addr != address(parentStaking));
        require(_addr != address(lpStaking));
        genesisStaking = DigialaxStaking(_addr);
    }

    function setParentStaking(
        address _addr
    )
        external
    {
        require(
            accessControls.hasAdminRole(msg.sender),
            "DigitalaxRewards.setParentStaking: Sender must be admin"
        );
        require(_addr != address(genesisStaking));
        require(_addr != address(lpStaking));
        parentStaking = DigialaxStaking(_addr);
    }

    function setLPStaking(
        address _addr
    )
        external
    {
        require(
            accessControls.hasAdminRole(msg.sender),
            "DigitalaxRewards.setLPStaking: Sender must be admin"
        );
        require(_addr != address(parentStaking));
        require(_addr != address(genesisStaking));
        lpStaking = DigialaxStaking(_addr);
    } 

    /// @notice Set rewards distributed each week
    /// @dev this number is the total rewards that week with 18 decimals
    function setRewards(
        uint256[] memory rewardWeeks,
        uint256[] memory amounts
    )
        external
    {
        require(
            accessControls.hasAdminRole(msg.sender),
            "DigitalaxRewards.setRewards: Sender must be admin"
        );
        uint256 numRewards = rewardWeeks.length;
        for (uint256 i = 0; i < numRewards; i++) {
            uint256 week = rewardWeeks[i];
            uint256 amount = amounts[i].mul(pointMultiplier)
                                       .div(SECONDS_PER_WEEK)
                                       .div(pointMultiplier);
            weeklyRewardsPerSecond[week] = amount;
        }
    }
    /// @notice Set rewards distributed each week
    /// @dev this number is the total rewards that week with 18 decimals
    function bonusRewards(
        address pool,
        uint256[] memory rewardWeeks,
        uint256[] memory amounts
    )
        external
    {
        require(
            accessControls.hasAdminRole(msg.sender),
            "DigitalaxRewards.setRewards: Sender must be admin"
        );
        uint256 numRewards = rewardWeeks.length;
        for (uint256 i = 0; i < numRewards; i++) {
            uint256 week = rewardWeeks[i];
            uint256 amount = amounts[i].mul(pointMultiplier)
                                       .div(SECONDS_PER_WEEK)
                                       .div(pointMultiplier);
            weeklyBonusPerSecond[pool][week] = amount;
        }
    }

    // From BokkyPooBah's DateTime Library v1.01
    // https://github.com/bokkypoobah/BokkyPooBahsDateTimeLibrary
    function diffDays(uint fromTimestamp, uint toTimestamp) internal pure returns (uint _days) {
        require(fromTimestamp <= toTimestamp);
        _days = (toTimestamp - fromTimestamp) / SECONDS_PER_DAY;
    }


    /* ========== Mutative Functions ========== */

    /// @notice Calculate the current normalised weightings and update rewards
    /// @dev 
    function updateRewards() 
        external
        returns(bool)
    {
        if (block.timestamp <= lastRewardTime) {
            return false;
        }
        uint256 g_net = genesisStaking.stakedEthTotal();
        uint256 p_net = parentStaking.stakedEthTotal();
        uint256 m_net = lpStaking.stakedEthTotal();

        /// @dev check that the staking pools have contributions, and rewards have started
        if (g_net.add(p_net).add(m_net) == 0 || block.timestamp <= startTime) {
            lastRewardTime = block.timestamp;
            return false;
        }

        (uint256 gW, uint256 pW, uint256 mW) = _getReturnWeights(g_net, p_net, m_net);
        _updateWeightingAcc(gW,pW,mW);

        /// @dev This mints and sends rewards
        _updateGenesisRewards();
        _updateParentRewards();
        _updateLPRewards();

        /// @dev update accumulated reward
        lastRewardTime = block.timestamp;
        return true;
    }


    /* ========== View Functions ========== */

    /// @notice Gets the total rewards outstanding from last reward time
    function totalRewards() external view returns (uint256) {
        uint256 gRewards = genesisRewards(lastRewardTime, block.timestamp);
        uint256 pRewards = parentRewards(lastRewardTime, block.timestamp);
        uint256 lRewards = LPRewards(lastRewardTime, block.timestamp);
        return gRewards.add(pRewards).add(lRewards);     
    }


    /// @notice Gets the total contributions from the staked contracts
    function getTotalContributions()
        external
        view
        returns(uint256)
    {
        return genesisStaking.stakedEthTotal()
            .add(parentStaking.stakedEthTotal())
            .add(lpStaking.stakedEthTotal());
    }

    /// @dev Getter functions for Rewards contract
    function getCurrentRewardWeek()
        external 
        view 
        returns(uint256)
    {
        return diffDays(startTime, block.timestamp) / 7;
    }

    function totalRewardsPaid()
        external
        view
        returns(uint256)
    {
        return genesisRewardsPaid.add(parentRewardsPaid).add(lpRewardsPaid);
    } 

    /// @notice Return genesis rewards over the given _from to _to timestamp.
    /// @dev A fraction of the start, multiples of the middle weeks, fraction of the end
    function genesisRewards(uint256 _from, uint256 _to) public view returns (uint256 rewards) {
        if (_to <= startTime) {
            return 0;
        }
        if (_from < startTime) {
            _from = startTime;
        }
        uint256 fromWeek = diffDays(startTime, _from) / 7;
        uint256 toWeek = diffDays(startTime, _to) / 7;

       if (fromWeek == toWeek) {
            return _rewardsFromPoints(weeklyRewardsPerSecond[fromWeek],
                                    _to.sub(_from),
                                    weeklyWeightPoints[fromWeek].genesisWtPoints)
                        .add(weeklyBonusPerSecond[address(genesisStaking)][fromWeek].mul(_to.sub(_from)));
        }
        /// @dev First count remainer of first week 
        uint256 initialRemander = startTime.add((fromWeek+1).mul(SECONDS_PER_WEEK)).sub(_from);
        rewards = _rewardsFromPoints(weeklyRewardsPerSecond[fromWeek],
                                    initialRemander,
                                    weeklyWeightPoints[fromWeek].genesisWtPoints)
                        .add(weeklyBonusPerSecond[address(genesisStaking)][fromWeek].mul(initialRemander));

        /// @dev add multiples of the week
        for (uint256 i = fromWeek+1; i < toWeek; i++) {
            rewards = rewards.add(_rewardsFromPoints(weeklyRewardsPerSecond[i],
                                    SECONDS_PER_WEEK,
                                    weeklyWeightPoints[i].genesisWtPoints))
                             .add(weeklyBonusPerSecond[address(genesisStaking)][i].mul(SECONDS_PER_WEEK));
        }
        /// @dev Adds any remaining time in the most recent week till _to
        uint256 finalRemander = _to.sub(toWeek.mul(SECONDS_PER_WEEK).add(startTime));
        rewards = rewards.add(_rewardsFromPoints(weeklyRewardsPerSecond[toWeek],
                                    finalRemander,
                                    weeklyWeightPoints[toWeek].genesisWtPoints))
                          .add(weeklyBonusPerSecond[address(genesisStaking)][toWeek].mul(finalRemander));
        return rewards;
    }

    /// @notice Return parent rewards over the given _from to _to timestamp.
    /// @dev A fraction of the start, multiples of the middle weeks, fraction of the end
    function parentRewards(uint256 _from, uint256 _to) public view returns (uint256 rewards) {
        if (_to <= startTime) {
            return 0;
        }
        if (_from < startTime) {
            _from = startTime;
        }
        uint256 fromWeek = diffDays(startTime, _from) / 7;
        uint256 toWeek = diffDays(startTime, _to) / 7;
       
        if (fromWeek == toWeek) {
            return _rewardsFromPoints(weeklyRewardsPerSecond[fromWeek],
                                    _to.sub(_from),
                                    weeklyWeightPoints[fromWeek].parentWtPoints)
                        .add(weeklyBonusPerSecond[address(parentStaking)][fromWeek].mul(_to.sub(_from)));
        }
        // First count remainer of first week 
        uint256 initialRemander = startTime.add((fromWeek+1).mul(SECONDS_PER_WEEK)).sub(_from);
        rewards = _rewardsFromPoints(weeklyRewardsPerSecond[fromWeek],
                                    initialRemander,
                                    weeklyWeightPoints[fromWeek].parentWtPoints)
                        .add(weeklyBonusPerSecond[address(parentStaking)][fromWeek].mul(initialRemander));

        /// @dev add multiples of the week
        for (uint256 i = fromWeek+1; i < toWeek; i++) {
            rewards = rewards.add(_rewardsFromPoints(weeklyRewardsPerSecond[i],
                                    SECONDS_PER_WEEK,
                                    weeklyWeightPoints[i].parentWtPoints))
                             .add(weeklyBonusPerSecond[address(parentStaking)][i].mul(SECONDS_PER_WEEK));
        }
        /// @dev Adds any remaining time in the most recent week till _to
        uint256 finalRemander = _to.sub(toWeek.mul(SECONDS_PER_WEEK).add(startTime));
        rewards = rewards.add(_rewardsFromPoints(weeklyRewardsPerSecond[toWeek],
                                    finalRemander,
                                    weeklyWeightPoints[toWeek].parentWtPoints))
                          .add(weeklyBonusPerSecond[address(parentStaking)][toWeek].mul(finalRemander));
        return rewards;
    }

    /// @notice Return LP rewards over the given _from to _to timestamp.
    /// @dev A fraction of the start, multiples of the middle weeks, fraction of the end
    function LPRewards(uint256 _from, uint256 _to) public view returns (uint256 rewards) {
        if (_to <= startTime) {
            return 0;
        }
        if (_from < startTime) {
            _from = startTime;
        }
        uint256 fromWeek = diffDays(startTime, _from) / 7;                      
        uint256 toWeek = diffDays(startTime, _to) / 7;                          

        if (fromWeek == toWeek) {
            return _rewardsFromPoints(weeklyRewardsPerSecond[fromWeek],
                                    _to.sub(_from),
                                    weeklyWeightPoints[fromWeek].lpWeightPoints)
                        .add(weeklyBonusPerSecond[address(lpStaking)][fromWeek].mul(_to.sub(_from)));
        }
        /// @dev First count remainer of first week 
        uint256 initialRemander = startTime.add((fromWeek+1).mul(SECONDS_PER_WEEK)).sub(_from);
        rewards = _rewardsFromPoints(weeklyRewardsPerSecond[fromWeek],
                                    initialRemander,
                                    weeklyWeightPoints[fromWeek].lpWeightPoints)
                        .add(weeklyBonusPerSecond[address(lpStaking)][fromWeek].mul(initialRemander));

        /// @dev add multiples of the week
        for (uint256 i = fromWeek+1; i < toWeek; i++) {
            rewards = rewards.add(_rewardsFromPoints(weeklyRewardsPerSecond[i],
                                    SECONDS_PER_WEEK,
                                    weeklyWeightPoints[i].lpWeightPoints))
                             .add(weeklyBonusPerSecond[address(lpStaking)][i].mul(SECONDS_PER_WEEK));
        }
        /// @dev Adds any remaining time in the most recent week till _to
        uint256 finalRemander = _to.sub(toWeek.mul(SECONDS_PER_WEEK).add(startTime));
        rewards = rewards.add(_rewardsFromPoints(weeklyRewardsPerSecond[toWeek],
                                    finalRemander,
                                    weeklyWeightPoints[toWeek].lpWeightPoints))
                        .add(weeklyBonusPerSecond[address(lpStaking)][toWeek].mul(finalRemander));
        return rewards;
    }


    /* ========== Internal Functions ========== */

    function _updateGenesisRewards() 
        internal
        returns(uint256 rewards)
    {
        rewards = genesisRewards(lastRewardTime, block.timestamp);
        if ( rewards > 0 ) {
            genesisRewardsPaid = genesisRewardsPaid.add(rewards);
            require(rewardsToken.mint(address(genesisStaking), rewards));
        }
    }

    function _updateParentRewards() 
        internal
        returns(uint256 rewards)
    {
        rewards = parentRewards(lastRewardTime, block.timestamp);
        if ( rewards > 0 ) {
            parentRewardsPaid = parentRewardsPaid.add(rewards);
            require(rewardsToken.mint(address(parentStaking), rewards));
        }
    }

    function _updateLPRewards() 
        internal
        returns(uint256 rewards)
    {
        rewards = LPRewards(lastRewardTime, block.timestamp);
        if ( rewards > 0 ) {
            lpRewardsPaid = lpRewardsPaid.add(rewards);
            require(rewardsToken.mint(address(lpStaking), rewards));
        }
    }

    function _rewardsFromPoints(
        uint256 rate,
        uint256 duration, 
        uint256 weight
    ) 
        internal
        pure
        returns(uint256)
    {
        return rate.mul(duration)
            .mul(weight)
            .div(1e18)
            .div(pointMultiplier);
    }

    /// @dev Internal fuction to update the weightings 
    function _updateWeightingAcc(uint256 gW, uint256 pW, uint256 mW) internal {
        uint256 currentWeek = diffDays(startTime, block.timestamp) / 7;
        uint256 lastRewardWeek = diffDays(startTime, lastRewardTime) / 7;
        uint256 startCurrentWeek = startTime.add(currentWeek.mul(SECONDS_PER_WEEK)); 

        /// @dev Initialisation of new weightings and fill gaps
        if (weeklyWeightPoints[0].genesisWtPoints == 0 
                && weeklyWeightPoints[0].parentWtPoints == 0 
                && weeklyWeightPoints[0].lpWeightPoints == 0  ) {
            Weights storage weights = weeklyWeightPoints[0];
            weights.genesisWtPoints = gW;
            weights.parentWtPoints = pW;
            weights.lpWeightPoints = mW;
        }
        /// @dev Fill gaps in weightings
        if (lastRewardWeek < currentWeek ) {
            /// @dev Back fill missing weeks
            for (uint256 i = lastRewardWeek+1; i <= currentWeek; i++) {
                Weights storage weights = weeklyWeightPoints[i];
                weights.genesisWtPoints = gW;
                weights.parentWtPoints = pW;
                weights.lpWeightPoints = mW;
            }
            return;
        }      
        /// @dev Calc the time weighted averages
        Weights storage weights = weeklyWeightPoints[currentWeek];
        weights.genesisWtPoints = _calcWeightPoints(weights.genesisWtPoints,gW,startCurrentWeek);
        weights.parentWtPoints = _calcWeightPoints(weights.parentWtPoints,pW,startCurrentWeek);
        weights.lpWeightPoints = _calcWeightPoints(weights.lpWeightPoints,mW,startCurrentWeek);
    }

    /// @dev Time weighted average of the token weightings
    function _calcWeightPoints(
        uint256 prevWeight,
        uint256 newWeight,
        uint256 startCurrentWeek
    ) 
        internal 
        view 
        returns(uint256) 
    {
        uint256 previousWeighting = prevWeight.mul(lastRewardTime.sub(startCurrentWeek));
        uint256 currentWeighting = newWeight.mul(block.timestamp.sub(lastRewardTime));
        return previousWeighting.add(currentWeighting)
                                .div(block.timestamp.sub(startCurrentWeek));
    }

    function max(uint256 a, uint256 b) internal pure returns (uint256 c) {
        c = a >= b ? a : b;
    }
    
    /// @notice Normalised weightings of weights with point multiplier 
    function _getReturnWeights(
        uint256 _g,
        uint256 _p,
        uint256 _m
    )   
        internal
        view
        returns(uint256,uint256,uint256)
    {
        uint256 eg = _g.mul(_getSqrtWeight(_g,_p,_m));
        uint256 ep = _p.mul(_getSqrtWeight(_p,_m,_g));
        uint256 em = _m.mul(_getSqrtWeight(_m,_g,_p));

        uint256 norm = eg.add(ep).add(em);

        return (eg.mul(pointMultiplier).mul(1e18).div(norm), ep.mul(pointMultiplier).mul(1e18).div(norm), 
                em.mul(pointMultiplier).mul(1e18).div(norm));

    }


    /// @notice Normalised weightings  
    function _getSqrtWeight(
        uint256 _a,
        uint256 _b,
        uint256 _c
    )  
        internal
        view
        returns(
            uint256 wA
        )
    {
        if ( _a <= _b.add(_c) ||  _b.add(_c) == 0  ) {
            return 1e18;
        }
        /// @dev Normalised for each weighting
        uint256 A1 = max(_a.mul(1e18).div(max(_b,1e18)),1e18);
        uint256 A2 = max(_a.mul(1e18).div(max(_c,1e18)),1e18);
        uint256 A = A1.mul(A2).div(1e18);

        /// @dev sqrt needs to refactored by 1/2 decimals, ie 1e9
        wA = _sqrt(uint256(1e18).mul(1e18).div(A)).mul(1e9);
        
    }

    /// @dev babylonian method (https://en.wikipedia.org/wiki/Methods_of_computing_square_roots#Babylonian_method)
    function _sqrt(uint y) internal pure returns (uint z) {
        if (y > 3) {
            z = y;
            uint x = y / 2 + 1;
            while (x < z) {
                z = x;
                x = (y / x + x) / 2;
            }
        } else if (y != 0) {
            z = 1;
        }
    }

    /* ========== Recover ERC20 ========== */

    /// @notice allows for the recovery of incorrect ERC20 tokens sent to contract
    function recoverERC20(
        address tokenAddress,
        uint256 tokenAmount
    )
        external
    {
        // Cannot recover the staking token or the rewards token
        require(
            accessControls.hasAdminRole(msg.sender),
            "DigitalaxRewards.recoverERC20: Sender must be admin"
        );
        require(
            tokenAddress != address(rewardsToken),
            "Cannot withdraw the rewards token"
        );
        IERC20(tokenAddress).transfer(msg.sender, tokenAmount);
        emit Recovered(tokenAddress, tokenAmount);
    }


    /* ========== Getters ========== */

    function getCurrentWeek()
        external
        view
        returns(uint256)
    {
        return diffDays(startTime, block.timestamp) / 7;
    }


    function getCurrentGenesisWtPoints()
        external
        view
        returns(uint256)
    {
        uint256 currentWeek = diffDays(startTime, block.timestamp) / 7;
        return weeklyWeightPoints[currentWeek].genesisWtPoints;
    }

    function getCurrentParentWtPoints()
        external
        view
        returns(uint256)
    {
        uint256 currentWeek = diffDays(startTime, block.timestamp) / 7;
        return weeklyWeightPoints[currentWeek].parentWtPoints;
    }
    function getCurrentLpWeightPoints()
        external
        view
        returns(uint256)
    {
        uint256 currentWeek = diffDays(startTime, block.timestamp) / 7;
        return weeklyWeightPoints[currentWeek].lpWeightPoints;
    }

    function getGenesisStakedEthTotal()
        public
        view
        returns(uint256)
    {
        return genesisStaking.stakedEthTotal();
    }

    function getLpStakedEthTotal()
        public
        view
        returns(uint256)
    {
        return lpStaking.stakedEthTotal();
    }

    function getParentStakedEthTotal()
        public
        view
        returns(uint256)
    {
        return parentStaking.stakedEthTotal();
    }

    function getGenesisDailyAPY()
        external
        view 
        returns (uint256) 
    {
        uint256 stakedEth = getGenesisStakedEthTotal();
        if ( stakedEth == 0 ) {
            return 0;
        }
        uint256 rewards = genesisRewards(block.timestamp - 60, block.timestamp);
        uint256 rewardsInEth = rewards.mul(getEthPerMona()).div(1e18);
        return rewardsInEth.mul(52560000).mul(1e18).div(stakedEth);
    } 

    function getParentDailyAPY()
        external
        view 
        returns (uint256) 
    {
        uint256 stakedEth = getParentStakedEthTotal();
        if ( stakedEth == 0 ) {
            return 0;
        }
        uint256 rewards = parentRewards(block.timestamp - 60, block.timestamp);
        uint256 rewardsInEth = rewards.mul(getEthPerMona()).div(1e18);
        return rewardsInEth.mul(52560000).mul(1e18).div(stakedEth);
    } 

    function getLpDailyAPY()
        external
        view 
        returns (uint256) 
    {
        uint256 stakedEth = getLpStakedEthTotal();
        if ( stakedEth == 0 ) {
            return 0;
        }
        uint256 rewards = LPRewards(block.timestamp - 60, block.timestamp);
        uint256 rewardsInEth = rewards.mul(getEthPerMona()).div(1e18);
        /// @dev minutes per year x 100 = 52560000
        return rewardsInEth.mul(52560000).mul(1e18).div(stakedEth);
    } 

    function getMonaPerEth()
        public 
        view 
        returns (uint256)
    {
        (uint256 wethReserve, uint256 tokenReserve) = getPairReserves();
        return UniswapV2Library.quote(1e18, wethReserve, tokenReserve);
    }

    function getEthPerMona()
        public
        view
        returns (uint256)
    {
        (uint256 wethReserve, uint256 tokenReserve) = getPairReserves();
        return UniswapV2Library.quote(1e18, tokenReserve, wethReserve);
    }

    function getPairReserves() internal view returns (uint256 wethReserves, uint256 tokenReserves) {
        (address token0,) = UniswapV2Library.sortTokens(address(lpStaking.WETH()), address(rewardsToken));
        (uint256 reserve0, uint reserve1,) = IUniswapV2Pair(lpStaking.lpToken()).getReserves();
        (wethReserves, tokenReserves) = token0 == address(rewardsToken) ? (reserve1, reserve0) : (reserve0, reserve1);
    }

}