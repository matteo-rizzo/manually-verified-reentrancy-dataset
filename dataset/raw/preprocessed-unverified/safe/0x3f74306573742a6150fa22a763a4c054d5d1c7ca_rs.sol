/**
 *Submitted for verification at Etherscan.io on 2020-10-08
*/

/**
 *Submitted for verification at Etherscan.io on 2020-10-07
*/

pragma solidity 0.7.1;
pragma experimental ABIEncoderV2;

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
 * As of v3.0.0, only sets of type `address` (`AddressSet`) and `uint256`
 * (`UintSet`) are supported.
 */


/**
 * @dev Collection of functions related to the address type
 */


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


/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
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
contract ReentrancyGuard {
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

contract ExchangeSwapV4 is AccessControl, ReentrancyGuard {
    using SafeERC20 for IERC20;
    using SafeMath for uint;

    bytes32 public constant EXECUTOR_ROLE = bytes32('Executor');

    address payable public feeCollector;
    mapping(address => uint) public coverFees;
    uint public totalFees;

    struct Request {
        address user;
        IERC20 tokenFrom;
        uint amountFrom;
        IERC20 tokenTo;
        uint minAmountTo;
        uint txGasLimit;
        address target;
        bytes callData;
    }

    struct RequestETHForTokens {
        address user;
        uint amountFrom;
        IERC20 tokenTo;
        uint minAmountTo;
        uint txGasLimit;
        address payable target;
        bytes callData;
    }

    struct RequestTokensForETH {
        address payable user;
        IERC20 tokenFrom;
        uint amountFrom;
        uint minAmountTo;
        uint txGasLimit;
        address target;
        bytes callData;
    }

    modifier onlyOwner() {
        require(hasRole(DEFAULT_ADMIN_ROLE, _msgSender()), 'Only owner');
        _;
    }

    constructor() {
        _setupRole(DEFAULT_ADMIN_ROLE, _msgSender());
        _setupRole(EXECUTOR_ROLE, _msgSender());
        feeCollector = payable(_msgSender());
    }

    function updateFeeCollector(address payable _address) external nonReentrant() onlyOwner() {
        require(_address != address(0), 'Not zero address required');
        feeCollector = _address;
    }

    receive() payable external {}

    function depositETH() payable external {
        address sender = _msgSender();
        coverFees[sender] = coverFees[sender].add(msg.value);
        totalFees = totalFees.add(msg.value);
    }

    function withdraw() external {
        address payable sender = _msgSender();
        uint amount = coverFees[sender];
        require(amount > 0, 'Nothing to withdraw');
        coverFees[sender] = 0;
        totalFees = totalFees.sub(amount);
        sender.transfer(amount);
    }

    function makeSwap(Request memory _request) external nonReentrant() returns(bool) {
        require(hasRole(EXECUTOR_ROLE, _msgSender()), 'Only Executor');
        require(coverFees[_request.user] >= ((_request.txGasLimit + 5000) * tx.gasprice),
            'Cover fees deposit required');

        bool _result = true;
        try this._execute{gas: gasleft().sub(20000)}(_request) {} catch {
            _result = false;
        }
        _chargeFee(_request.user, _request.txGasLimit);
        return _result;
    }

    function makeSwapETHForTokens(RequestETHForTokens memory _request) external nonReentrant() returns(bool) {
        require(hasRole(EXECUTOR_ROLE, _msgSender()), 'Only Executor');
        require(coverFees[_request.user] >=
            (((_request.txGasLimit + 5000) * tx.gasprice + _request.amountFrom)),
            'Cover fees deposit required');

        bool _result = true;
        try this._executeETHForTokens{gas: gasleft().sub(20000)}(_request) {} catch {
            _result = false;
        }
        _chargeFee(_request.user, _request.txGasLimit);
        return _result;
    }

    function makeSwapTokensForETH(RequestTokensForETH memory _request) external nonReentrant() returns(bool) {
        require(hasRole(EXECUTOR_ROLE, _msgSender()), 'Only Executor');
        require(coverFees[_request.user] >= ((_request.txGasLimit + 5000) * tx.gasprice),
            'Cover fees deposit required');

        bool _result = true;
        try this._executeTokensForETH{gas: gasleft().sub(20000)}(_request) {} catch {
            _result = false;
        }
        _chargeFee(_request.user, _request.txGasLimit);
        return _result;
    }

    function _execute(Request memory _request) external {
        require(_msgSender() == address(this), 'Only this contract');
        _request.tokenFrom.safeTransferFrom(_request.user, address(this), _request.amountFrom);
        _request.tokenFrom.safeApprove(_request.target, _request.amountFrom);

        uint _balanceBefore = _request.tokenTo.balanceOf(_request.user);
        (bool _success, ) = _request.target.call(_request.callData);
        require(_success, 'Call failed');
        uint _balanceThis = _request.tokenTo.balanceOf(address(this));
        if (_balanceThis > 0) {
            _request.tokenTo.safeTransfer(_request.user, _balanceThis);
        }
        uint _balanceAfter = _request.tokenTo.balanceOf(_request.user);

        require(_balanceAfter.sub(_balanceBefore) >= _request.minAmountTo, 'Less than minimum received');
    }

    function _executeETHForTokens(RequestETHForTokens memory _request) external {
        require(_msgSender() == address(this), 'Only this contract');
        uint _balance = coverFees[_request.user];
        require(_balance >= _request.amountFrom, 'Insufficient funds');
        coverFees[_request.user] = coverFees[_request.user].sub(_request.amountFrom);
        totalFees = totalFees.sub(_request.amountFrom);

        uint _balanceBefore = _request.tokenTo.balanceOf(_request.user);
        (bool _success, ) = _request.target.call{value: _request.amountFrom}(_request.callData);
        require(_success, 'Call failed');
        uint _balanceThis = _request.tokenTo.balanceOf(address(this));
        if (_balanceThis > 0) {
            _request.tokenTo.safeTransfer(_request.user, _balanceThis);
        }
        uint _balanceAfter = _request.tokenTo.balanceOf(_request.user);

        require(_balanceAfter.sub(_balanceBefore) >= _request.minAmountTo, 'Less than minimum received');
    }

    function _executeTokensForETH(RequestTokensForETH memory _request) external {
        require(_msgSender() == address(this), 'Only this contract');
        _request.tokenFrom.safeTransferFrom(_request.user, address(this), _request.amountFrom);
        _request.tokenFrom.safeApprove(_request.target, _request.amountFrom);

        uint _balanceBefore = _request.user.balance;
        (bool _success, ) = _request.target.call(_request.callData);
        require(_success, 'Call failed');
        uint _balanceThis = address(this).balance;
        if (_balanceThis > totalFees) {
            _request.user.transfer(_balanceThis.sub(totalFees));
        }
        uint _balanceAfter = _request.user.balance;

        require(_balanceAfter.sub(_balanceBefore) >= _request.minAmountTo, 'Less than minimum received');
    }

    function _chargeFee(address _user, uint _txGasLimit) internal {
        uint _txCost = (_txGasLimit - gasleft() + 15000) * tx.gasprice;
        coverFees[_user] = coverFees[_user].sub(_txCost);
        totalFees = totalFees.sub(_txCost);
        feeCollector.transfer(_txCost);
    }

    function collectTokens(IERC20 _token, uint _amount, address _to)
    external nonReentrant() onlyOwner() {
        _token.transfer(_to, _amount);
    }

    function collectETH(uint _amount, address payable _to)
    external nonReentrant() onlyOwner() {
        require(address(this).balance.sub(totalFees) >= _amount, 'Insufficient extra ETH');
        _to.transfer(_amount);
    }
}