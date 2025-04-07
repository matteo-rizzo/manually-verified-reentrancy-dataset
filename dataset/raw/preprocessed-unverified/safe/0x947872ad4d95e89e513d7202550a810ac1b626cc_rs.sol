/**
 *Submitted for verification at Etherscan.io on 2021-03-28
*/

// SPDX-License-Identifier: Apache-2.0

pragma solidity 0.7.6;



// Part: Address

/**
 * @dev Collection of functions related to the address type
 */


// Part: Context

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

// Part: EnumerableSet

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


// Part: IBridgeCommon

/**
 * @title Events for Bi-directional bridge transferring FET tokens between Ethereum and Fetch Mainnet-v2
 */


// Part: IERC20

/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
 */


// Part: IERC20MintFacility



// Part: SafeMath

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


// Part: AccessControl

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

// Part: IBridgeMonitor

/**
 * @title *Monitor* interface of Bi-directional bridge for transfer of FET tokens between Ethereum
 *        and Fetch Mainnet-v2.
 *
 * @notice By design, all methods of this monitor-level interface can be called monitor and admin roles of
 *         the Bridge contract.
 *
 */
interface IBridgeMonitor is IBridgeCommon {
    /**
     * @notice Pauses Public API since the specified block number
     * @param blockNumber block number since which non-admin interaction will be paused (for all
     *        block.number >= blockNumber).
     * @dev Delegate only
     *      If `blocknumber < block.number`, then contract will be paused immediately = from `block.number`.
     */
    function pausePublicApiSince(uint256 blockNumber) external;

    /**
     * @notice Pauses Relayer API since the specified block number
     * @param blockNumber block number since which non-admin interaction will be paused (for all
     *        block.number >= blockNumber).
     * @dev Delegate only
     *      If `blocknumber < block.number`, then contract will be paused immediately = from `block.number`.
     */
    function pauseRelayerApiSince(uint256 blockNumber) external;
}

// Part: IBridgePublic

/**
 * @title Public interface of the Bridge for transferring FET tokens between Ethereum and Fetch Mainnet-v2
 *
 * @notice Methods of this public interface is allow users to interact with Bridge contract.
 */
interface IBridgePublic is IBridgeCommon {

    /**
      * @notice Initiates swap, which will be relayed to the other blockchain.
      *         Swap might fail, if `destinationAddress` value is invalid (see bellow), in which case the swap will be
      *         refunded back to user. Swap fee will be *WITHDRAWN* from `amount` in that case - please see details
      *         in desc. for `refund(...)` call.
      *
      * @dev Swap call will create unique identifier (swap id), which is, by design, sequentially growing by 1 per each
      *      new swap created, and so uniquely identifies each swap. This identifier is referred to as "reverse swap id"
      *      on the other blockchain.
      *      Callable by anyone.
      *
      * @param destinationAddress - address on **OTHER** blockchain where the swap effective amount will be transferred
      *                             in to.
      *                             User is **RESPONSIBLE** for providing the **CORRECT** and valid value.
      *                             The **CORRECT** means, in this context, that address is valid *AND* user really
      *                             intended this particular address value as destination = that address is NOT lets say
      *                             copy-paste mistake made by user. Reason being that when user provided valid address
      *                             value, but made mistake = address is of someone else (e.g. copy-paste mistake), then
      *                             there is **NOTHING** what can be done to recover funds back to user (= refund) once
      *                             the swap will be relayed to the other blockchain!
      *                             The **VALID** means that provided value successfully passes consistency checks of
      *                             valid address of **OTHER** blockchain. In the case when user provides invalid
      *                             address value, relayer will execute refund - please see desc. for `refund()` call
      *                             for more details.
      */
    function swap(uint256 amount, string calldata destinationAddress) external;
}

// Part: IBridgeRelayer

/**
 * @title *Relayer* interface of Bi-directional bridge for transfer of FET tokens between Ethereum
 *        and Fetch Mainnet-v2.
 *
 * @notice By design, all methods of this relayer-level interface can be called exclusively by relayer(s) of
 *         the Bridge contract.
 *         It is offers set of methods to perform relaying functionality of the Bridge = transferring swaps
 *         across chains.
 *
 * @notice This bridge allows to transfer [ERC20-FET] tokens from Ethereum Mainnet to [Native FET] tokens on Fetch
 *         Native Mainnet-v2 and **other way around** (= it is bi-directional).
 *         User will be *charged* swap fee defined in counterpart contract deployed on Fetch Native Mainnet-v2.
 *         In the case of a refund, user will be charged a swap fee configured in this contract.
 *
 *         Swap Fees for `swap(...)` operations (direction from this contract to Native Fetch Mainnet-v2 are handled by
 *         the counterpart contract on Fetch Native Mainnet-v2, **except** for refunds, for
 *         which user is charged swap fee defined by this contract (since relayer needs to send refund transaction back
 *         to this contract.
 */
interface IBridgeRelayer is IBridgeCommon {

    /**
      * @notice Starts the new relay eon.
      * @dev Relay eon concept is part of the design in order to ensure safe management of hand-over between two
      *      relayer services. It provides clean isolation of potentially still pending transactions from previous
      *      relayer svc and the current one.
      */
    function newRelayEon() external;


    /**
      * @notice Refunds swap previously created by `swap(...)` call to this contract. The `swapFee` is *NOT* refunded
      *         back to the user (this is by-design).
      *
      * @dev Callable exclusively by `relayer` role
      *
      * @param id - swap id to refund - must be swap id of swap originally created by `swap(...)` call to this contract,
      *             **NOT** *reverse* swap id!
      * @param to - address where the refund will be transferred in to(IDENTICAL to address used in associated `swap`
      *             call)
      * @param amount - original amount specified in associated `swap` call = it INCLUDES swap fee, which will be
      *                 withdrawn
      * @param relayEon_ - current relay eon, ensures safe management of relaying process
      */
    function refund(uint64 id, address to, uint256 amount, uint64 relayEon_) external;


    /**
      * @notice Refunds swap previously created by `swap(...)` call to this contract, where `swapFee` *IS* refunded
      *         back to the user (= swap fee is waived = user will receive full `amount`).
      *         Purpose of this method is to enable full refund in the situations when it si not user's fault that
      *         swap needs to be refunded (e.g. when Fetch Native Mainnet-v2 will become unavailable for prolonged
      *         period of time, etc. ...).
      *
      * @dev Callable exclusively by `relayer` role
      *
      * @param id - swap id to refund - must be swap id of swap originally created by `swap(...)` call to this contract,
      *             **NOT** *reverse* swap id!
      * @param to - address where the refund will be transferred in to(IDENTICAL to address used in associated `swap`
      *             call)
      * @param amount - original amount specified in associated `swap` call = it INCLUDES swap fee, which will be
      *                 waived = user will receive whole `amount` value.
      *                 Pleas mind that `amount > 0`, otherways relayer will pay Tx fee for executing the transaction
      *                 which will have *NO* effect (= like this function `refundInFull(...)` would *not* have been
      *                 called at all!
      * @param relayEon_ - current relay eon, ensures safe management of relaying process
      */
    function refundInFull(uint64 id, address to, uint256 amount, uint64 relayEon_) external;


    /**
      * @notice Finalises swap initiated by counterpart contract on the other blockchain.
      *         This call sends swapped tokens to `to` address value user specified in original swap on the **OTHER**
      *         blockchain.
      *
      * @dev Callable exclusively by `relayer` role
      *
      * @param rid - reverse swap id - unique identifier of the swap initiated on the **OTHER** blockchain.
      *              This id is, by definition, sequentially growing number incremented by 1 for each new swap initiated
      *              the other blockchain. **However**, it is *NOT* ensured that *all* swaps from the other blockchain
      *              will be transferred to this (Ethereum) blockchain, since some of these swaps can be refunded back
      *              to users (on the other blockchain).
      * @param to - address where the refund will be transferred in to
      * @param from - source address from which user transferred tokens from on the other blockchain. Present primarily
      *               for purposes of quick querying of events on this blockchain.
      * @param originTxHash - transaction hash for swap initiated on the **OTHER** blockchain. Present in order to
      *                       create strong bond between this and other blockchain.
      * @param amount - original amount specified in associated swap initiated on the other blockchain.
      *                 Swap fee is *withdrawn* from the `amount` user specified in the swap on the other blockchain,
      *                 what means that user receives `amount - swapFee`, or *nothing* if `amount <= swapFee`.
      *                 Pleas mind that `amount > 0`, otherways relayer will pay Tx fee for executing the transaction
      *                 which will have *NO* effect (= like this function `refundInFull(...)` would *not* have been
      *                 called at all!
      * @param relayEon_ - current relay eon, ensures safe management of relaying process
      */
    function reverseSwap(
        uint64 rid,
        address to,
        string calldata from,
        bytes32 originTxHash,
        uint256 amount,
        uint64 relayEon_
        )
        external;
}

// Part: IERC20Token

interface IERC20Token is IERC20, IERC20MintFacility {}

// Part: IBridgeAdmin

/**
 * @title *Administrative* interface of Bi-directional bridge for transfer of FET tokens between Ethereum
 *        and Fetch Mainnet-v2.
 *
 * @notice By design, all methods of this administrative interface can be called exclusively by administrator(s) of
 *         the Bridge contract, since it allows to configure essential parameters of the the Bridge, and change
 *         supply transferred across the Bridge.
 */
interface IBridgeAdmin is IBridgeCommon, IBridgeMonitor {

    /**
     * @notice Returns amount of excess FET ERC20 tokens which were sent to address of this contract via direct ERC20
     *         transfer (by calling ERC20.transfer(...)), without interacting with API of this contract, what can happen
     *         only by mistake.
     *
     * @return targetAddress : address to send tokens to
     */
    function getFeesAccrued() external view returns(uint256);


    /**
     * @notice Mints provided amount of FET tokens.
     *         This is to reflect changes in minted Native FET token supply on the Fetch Native Mainnet-v2 blockchain.
     * @param amount - number of FET tokens to mint.
     */
    function mint(uint256 amount) external;


    /**
     * @notice Burns provided amount of FET tokens.
     *         This is to reflect changes in minted Native FET token supply on the Fetch Native Mainnet-v2 blockchain.
     * @param amount - number of FET tokens to burn.
     */
    function burn(uint256 amount) external;


    /**
     * @notice Sets cap (max) value of `supply` this contract can hold = the value of tokens transferred to the other
     *         blockchain.
     *         This cap affects(limits) all operations which *increase* contract's `supply` value = `swap(...)` and
     *         `mint(...)`.
     * @param value - new cap value.
     */
    function setCap(uint256 value) external;


    /**
     * @notice Sets value of `reverseAggregatedAllowance` state variable.
     *         This affects(limits) operations which *decrease* contract's `supply` value via **RELAYER** authored
     *         operations (= `reverseSwap(...)` and `refund(...)`). It does **NOT** affect **ADMINISTRATION** authored
     *         supply decrease operations (= `withdraw(...)` & `burn(...)`).
     * @param value - new cap value.
     */
    function setReverseAggregatedAllowance(uint256 value) external;

    /**
     * @notice Sets value of `reverseAggregatedAllowanceCap` state variable.
     *         This limits APPROVER_ROLE from top - value up to which can approver rise the allowance.
     * @param value - new cap value (absolute)
     */
    function setReverseAggregatedAllowanceApproverCap(uint256 value) external;


    /**
     * @notice Sets limits for swap amount
     *         FUnction will revert if following consitency check fails: `swapfee_ <= swapMin_ <= swapMax_`
     * @param swapMax_ : >= swap amount, applies for **OUTGOING** swap (= `swap(...)` call)
     * @param swapMin_ : <= swap amount, applies for **OUTGOING** swap (= `swap(...)` call)
     * @param swapFee_ : defines swap fee for **INCOMING** swap (= `reverseSwap(...)` call), and `refund(...)`
     */
    function setLimits(uint256 swapMax_, uint256 swapMin_, uint256 swapFee_) external;


    /**
     * @notice Withdraws amount from contract's supply, which is supposed to be done exclusively for relocating funds to
     *       another Bridge system, and **NO** other purpose.
     * @param targetAddress : address to send tokens to
     * @param amount : amount of tokens to withdraw
     */
    function withdraw(address targetAddress, uint256 amount) external;


    /**
     * @dev Deposits funds back in to the contract supply.
     *      Dedicated to increase contract's supply, usually(but not necessarily) after previous withdrawal from supply.
     *      NOTE: This call needs preexisting ERC20 allowance >= `amount` for address of this Bridge contract as
     *            recipient/beneficiary and Tx sender address as sender.
     *            This means that address passed in as the Tx sender, must have already crated allowance by calling the
     *            `ERC20.approve(from, ADDR_OF_BRIDGE_CONTRACT, amount)` *before* calling this(`deposit(...)`) call.
     * @param amount : deposit amount
     */
    function deposit(uint256 amount) external;


    /**
     * @notice Withdraw fees accrued so far.
     *         !IMPORTANT!: Current design of this contract does *NOT* allow to distinguish between *swap fees accrued*
     *                      and *excess funds* sent to the contract's address via *direct* `ERC20.transfer(...)`.
     *                      Implication is that excess funds **are treated** as swap fees.
     *                      The only way how to separate these two is off-chain, by replaying events from this and
     *                      Fet ERC20 contracts and do the reconciliation.
     *
     * @param targetAddress : address to send tokens to.
     */
    function withdrawFees(address targetAddress) external;


    /**
     * @notice Delete the contract, transfers the remaining token and ether balance to the specified
     *         payoutAddress
     * @param targetAddress address to transfer the balances to. Ensure that this is able to handle ERC20 tokens
     * @dev owner only + only on or after `earliestDelete` block
     */
    function deleteContract(address payable targetAddress) external;
}

// Part: IBridge

/**
 * @title Bi-directional bridge for transferring FET tokens between Ethereum and Fetch Mainnet-v2
 *
 * @notice This bridge allows to transfer [ERC20-FET] tokens from Ethereum Mainnet to [Native FET] tokens on Fetch
 *         Native Mainnet-v2 and **other way around** (= it is bi-directional).
 *         User will be *charged* swap fee defined in counterpart contract deployed on Fetch Native Mainnet-v2.
 *         In the case of a refund, user will be charged a swap fee configured in this contract.
 *
 * @dev There are three primary actions defining business logic of this contract:
 *       * `swap(...)`: initiates swap of tokens from Ethereum to Fetch Native Mainnet-v2, callable by anyone (= users)
 *       * `reverseSwap(...)`: finalises the swap of tokens in *opposite* direction = receives swap originally
 *                             initiated on Fetch Native Mainnet-v2, callable exclusively by `relayer` role
 *       * `refund(...)`: refunds swap originally initiated in this contract(by `swap(...)` call), callable exclusively
 *                        by `relayer` role
 *
 *      Swap Fees for `swap(...)` operations (direction from this contract to are handled by the counterpart contract on Fetch Native Mainnet-v2, **except** for refunds, for
 *      which user is charged swap fee defined by this contract (since relayer needs to send refund transaction back to
 *      this contract.
 *
 *      ! IMPORTANT !: Current design of this contract does *NOT* allow to distinguish between *swap fees accrued* and
 *      *excess funds* sent to the address of this contract via *direct* `ERC20.transfer(...)`.
 *      Implication is, that excess funds **are treated** as swap fees.
 *      The only way how to separate these two is to do it *off-chain*, by replaying events from this and FET ERC20
 *      contracts, and do the reconciliation.
 */
interface IBridge is IBridgePublic, IBridgeRelayer, IBridgeAdmin {}

// File: Bridge.sol

/**
 * @title Bi-directional bridge for transferring FET tokens between Ethereum and Fetch Mainnet-v2
 *
 * @notice This bridge allows to transfer [ERC20-FET] tokens from Ethereum Mainnet to [Native FET] tokens on Fetch
 *         Native Mainnet-v2 and **other way around** (= it is bi-directional).
 *         User will be *charged* swap fee defined in counterpart contract deployed on Fetch Native Mainnet-v2.
 *         In the case of a refund, user will be charged a swap fee configured in this contract.
 *
 * @dev There are three primary actions defining business logic of this contract:
 *       * `swap(...)`: initiates swap of tokens from Ethereum to Fetch Native Mainnet-v2, callable by anyone (= users)
 *       * `reverseSwap(...)`: finalises the swap of tokens in *opposite* direction = receives swap originally
 *                             initiated on Fetch Native Mainnet-v2, callable exclusively by `relayer` role
 *       * `refund(...)`: refunds swap originally initiated in this contract(by `swap(...)` call), callable exclusively
 *                        by `relayer` role
 *
 *      Swap Fees for `swap(...)` operations (direction from this contract to are handled by the counterpart contract on Fetch Native Mainnet-v2, **except** for refunds, for
 *      which user is charged swap fee defined by this contract (since relayer needs to send refund transaction back to
 *      this contract.
 *
 *      ! IMPORTANT !: Current design of this contract does *NOT* allow to distinguish between *swap fees accrued* and
 *      *excess funds* sent to the address of this contract via *direct* `ERC20.transfer(...)`.
 *      Implication is, that excess funds **are treated** as swap fees.
 *      The only way how to separate these two is to do it *off-chain*, by replaying events from this and FET ERC20
 *      contracts, and do the reconciliation.
 */
contract Bridge is IBridge, AccessControl {
    using SafeMath for uint256;

    /// @notice **********    CONSTANTS    ***********
    bytes32 public constant APPROVER_ROLE = keccak256("APPROVER_ROLE");
    bytes32 public constant MONITOR_ROLE = keccak256("MONITOR_ROLE");
    bytes32 public constant RELAYER_ROLE = keccak256("RELAYER_ROLE");

    /// @notice *******    IMMUTABLE STATE    ********
    IERC20Token public immutable token;
    uint256 public immutable earliestDelete;
    /// @notice ********    MUTABLE STATE    *********
    uint256 public supply;
    uint64 public  nextSwapId;
    uint64 public  relayEon;
    mapping(uint64 => uint256) public refunds; // swapId -> original swap amount(= *includes* swapFee)
    uint256 public swapMax;
    uint256 public swapMin;
    uint256 public cap;
    uint256 public swapFee;
    uint256 public pausedSinceBlockPublicApi;
    uint256 public pausedSinceBlockRelayerApi;
    uint256 public reverseAggregatedAllowance;
    uint256 public reverseAggregatedAllowanceApproverCap;


    /* Only callable by owner */
    modifier onlyOwner() {
        require(_isOwner(), "Only admin role");
        _;
    }

    modifier onlyRelayer() {
        require(hasRole(RELAYER_ROLE, msg.sender), "Only relayer role");
        _;
    }

    modifier verifyTxRelayEon(uint64 relayEon_) {
        require(relayEon == relayEon_, "Tx doesn't belong to current relayEon");
        _;
    }

    modifier canPause(uint256 pauseSinceBlockNumber) {
        if (pauseSinceBlockNumber > block.number) // Checking UN-pausing (the most critical operation)
        {
            require(_isOwner(), "Only admin role");
        }
        else
        {
            require(hasRole(MONITOR_ROLE, msg.sender) || _isOwner(), "Only admin or monitor role");
        }
        _;
    }

    modifier canSetReverseAggregatedAllowance(uint256 allowance) {
        if (allowance > reverseAggregatedAllowanceApproverCap) // Check for going over the approver cap (the most critical operation)
        {
            require(_isOwner(), "Only admin role");
        }
        else
        {
            require(hasRole(APPROVER_ROLE, msg.sender) || _isOwner(), "Only admin or approver role");
        }
        _;
    }

    modifier verifyPublicAPINotPaused() {
        require(pausedSinceBlockPublicApi > block.number, "Contract has been paused");
        _verifyRelayerApiNotPaused();
        _;
    }

    modifier verifyRelayerApiNotPaused() {
        _verifyRelayerApiNotPaused();
        _;
    }

    modifier verifySwapAmount(uint256 amount) {
        // NOTE(pb): Commenting-out check against `swapFee` in order to spare gas for user's Tx, relying solely on check
        //  against `swapMin` only, which is ensured to be `>= swapFee` (by `_setLimits(...)` function).
        //require(amount > swapFee, "Amount must be higher than fee");
        require(amount >= swapMin, "Amount bellow lower limit");
        require(amount <= swapMax, "Amount exceeds upper limit");
        _;
    }

    modifier verifyReverseSwapAmount(uint256 amount) {
        require(amount <= swapMax, "Amount exceeds swap max limit");
        _;
    }

    modifier verifyRefundSwapId(uint64 id) {
        require(id < nextSwapId, "Invalid swap id");
        require(refunds[id] == 0, "Refund was already processed");
        _;
    }


    /*******************
    Contract start
    *******************/
    /**
     * @notice Contract constructor
     * @dev Input parameters offers full flexibility to configure the contract during deployment, with minimal need of
     *      further setup transactions necessary to open contract to the public.
     *
     * @param ERC20Address - address of FET ERC20 token contract
     * @param cap_ - limits contract `supply` value from top
     * @param reverseAggregatedAllowance_ - allowance value which limits how much can refund & reverseSwap transfer
     *                                      in aggregated form
     * @param reverseAggregatedAllowanceApproverCap_ - limits allowance value up to which can APPROVER_ROLE set
     *                                                 the allowance
     * @param swapMax_ - value representing UPPER limit which can be transferred (this value INCLUDES swapFee)
     * @param swapMin_ - value representing LOWER limit which can be transferred (this value INCLUDES swapFee)
     * @param swapFee_ - represents fee which user has to pay for swap execution,
     * @param pausedSinceBlockPublicApi_ - block number since which the Public API of the contract will be paused
     * @param pausedSinceBlockRelayerApi_ - block number since which the Relayer API of the contract will be paused
     * @param deleteProtectionPeriod_ - number of blocks(from contract deployment block) during which contract can
     *                                  NOT be deleted
     */
    constructor(
          address ERC20Address
        , uint256 cap_
        , uint256 reverseAggregatedAllowance_
        , uint256 reverseAggregatedAllowanceApproverCap_
        , uint256 swapMax_
        , uint256 swapMin_
        , uint256 swapFee_
        , uint256 pausedSinceBlockPublicApi_
        , uint256 pausedSinceBlockRelayerApi_
        , uint256 deleteProtectionPeriod_)
    {
        _setupRole(DEFAULT_ADMIN_ROLE, msg.sender);
        token = IERC20Token(ERC20Address);
        earliestDelete = block.number.add(deleteProtectionPeriod_);

        /// @dev Unnecessary initialisations, done implicitly by VM
        //supply = 0;
        //refundsFeesAccrued = 0;
        //nextSwapId = 0;

        // NOTE(pb): Initial value is by design set to MAX_LIMIT<uint64>, so that its NEXT increment(+1) will
        //           overflow to 0.
        relayEon = type(uint64).max;

        _setCap(cap_);
        _setReverseAggregatedAllowance(reverseAggregatedAllowance_);
        _setReverseAggregatedAllowanceApproverCap(reverseAggregatedAllowanceApproverCap_);
        _setLimits(swapMax_, swapMin_, swapFee_);
        _pausePublicApiSince(pausedSinceBlockPublicApi_);
        _pauseRelayerApiSince(pausedSinceBlockRelayerApi_);
    }


    // **********************************************************
    // ***********    USER-LEVEL ACCESS METHODS    **********


    /**
      * @notice Initiates swap, which will be relayed to the other blockchain.
      *         Swap might fail, if `destinationAddress` value is invalid (see bellow), in which case the swap will be
      *         refunded back to user. Swap fee will be *WITHDRAWN* from `amount` in that case - please see details
      *         in desc. for `refund(...)` call.
      *
      * @dev Swap call will create unique identifier (swap id), which is, by design, sequentially growing by 1 per each
      *      new swap created, and so uniquely identifies each swap. This identifier is referred to as "reverse swap id"
      *      on the other blockchain.
      *      Callable by anyone.
      *
      * @param destinationAddress - address on **OTHER** blockchain where the swap effective amount will be transferred
      *                             in to.
      *                             User is **RESPONSIBLE** for providing the **CORRECT** and valid value.
      *                             The **CORRECT** means, in this context, that address is valid *AND* user really
      *                             intended this particular address value as destination = that address is NOT lets say
      *                             copy-paste mistake made by user. Reason being that when user provided valid address
      *                             value, but made mistake = address is of someone else (e.g. copy-paste mistake), then
      *                             there is **NOTHING** what can be done to recover funds back to user (= refund) once
      *                             the swap will be relayed to the other blockchain!
      *                             The **VALID** means that provided value successfully passes consistency checks of
      *                             valid address of **OTHER** blockchain. In the case when user provides invalid
      *                             address value, relayer will execute refund - please see desc. for `refund()` call
      *                             for more details.
      */
    function swap(
        uint256 amount, // This is original amount (INCLUDES fee)
        string calldata destinationAddress
        )
        external
        override
        verifyPublicAPINotPaused
        verifySwapAmount(amount)
    {
        supply = supply.add(amount);
        require(cap >= supply, "Swap would exceed cap");
        token.transferFrom(msg.sender, address(this), amount);
        emit Swap(nextSwapId, msg.sender, destinationAddress, destinationAddress, amount);
        // NOTE(pb): No necessity to use SafeMath here:
        nextSwapId += 1;
    }


    /**
     * @notice Returns amount of excess FET ERC20 tokens which were sent to address of this contract via direct ERC20
     *         transfer (by calling ERC20.transfer(...)), without interacting with API of this contract, what can happen
     *         only by mistake.
     *
     * @return targetAddress : address to send tokens to
     */
    function getFeesAccrued() external view override returns(uint256) {
        // NOTE(pb): This subtraction shall NEVER fail:
        return token.balanceOf(address(this)).sub(supply, "Critical err: balance < supply");
    }

    function getApproverRole() external view override returns(bytes32) {return APPROVER_ROLE;}
    function getMonitorRole() external view override returns(bytes32) {return MONITOR_ROLE;}
    function getRelayerRole() external view override returns(bytes32) {return RELAYER_ROLE;}

    function getToken() external view override returns(address) {return address(token);}
    function getEarliestDelete() external view override returns(uint256) {return earliestDelete;}
    function getSupply() external view override returns(uint256) {return supply;}
    function getNextSwapId() external view override returns(uint64) {return nextSwapId;}
    function getRelayEon() external view override returns(uint64) {return relayEon;}
    function getRefund(uint64 swap_id) external view override returns(uint256) {return refunds[swap_id];}
    function getSwapMax() external view override returns(uint256) {return swapMax;}
    function getSwapMin() external view override returns(uint256) {return swapMin;}
    function getCap() external view override returns(uint256) {return cap;}
    function getSwapFee() external view override returns(uint256) {return swapFee;}
    function getPausedSinceBlockPublicApi() external view override returns(uint256) {return pausedSinceBlockPublicApi;}
    function getPausedSinceBlockRelayerApi() external view override returns(uint256) {return pausedSinceBlockRelayerApi;}
    function getReverseAggregatedAllowance() external view override returns(uint256) {return reverseAggregatedAllowance;}
    function getReverseAggregatedAllowanceApproverCap() external view override returns(uint256) {return reverseAggregatedAllowanceApproverCap;}


    // **********************************************************
    // ***********    RELAYER-LEVEL ACCESS METHODS    ***********


    /**
      * @notice Starts the new relay eon.
      * @dev Relay eon concept is part of the design in order to ensure safe management of hand-over between two
      *      relayer services. It provides clean isolation of potentially still pending transactions from previous
      *      relayer svc and the current one.
      */
    function newRelayEon()
        external
        override
        verifyRelayerApiNotPaused
        onlyRelayer
    {
        // NOTE(pb): No need for safe math for this increment, since the MAX_LIMIT<uint64> is huge number (~10^19),
        //  there is no way that +1 incrementing from initial 0 value can possibly cause overflow in real world - that
        //  would require to send more than 10^19 transactions to reach that point.
        //  The only case, where this increment operation will lead to overflow, by-design, is the **VERY 1st**
        //  increment = very 1st call of this contract method, when the `relayEon` is by-design & intentionally
        //  initialised to MAX_LIMIT<uint64> value, so the resulting value of the `relayEon` after increment will be `0`
        relayEon += 1;
        emit NewRelayEon(relayEon);
    }


    /**
      * @notice Refunds swap previously created by `swap(...)` call to this contract. The `swapFee` is *NOT* refunded
      *         back to the user (this is by-design).
      *
      * @dev Callable exclusively by `relayer` role
      *
      * @param id - swap id to refund - must be swap id of swap originally created by `swap(...)` call to this contract,
      *             **NOT** *reverse* swap id!
      * @param to - address where the refund will be transferred in to(IDENTICAL to address used in associated `swap`
      *             call)
      * @param amount - original amount specified in associated `swap` call = it INCLUDES swap fee, which will be
      *                 withdrawn
      * @param relayEon_ - current relay eon, ensures safe management of relaying process
      */
    function refund(
        uint64 id,
        address to,
        uint256 amount,
        uint64 relayEon_
        )
        external
        override
        verifyRelayerApiNotPaused
        verifyTxRelayEon(relayEon_)
        verifyReverseSwapAmount(amount)
        onlyRelayer
        verifyRefundSwapId(id)
    {
        // NOTE(pb): Fail as early as possible - withdrawal from aggregated allowance is most likely to fail comparing
        //  to rest of the operations bellow.
        _updateReverseAggregatedAllowance(amount);

        supply = supply.sub(amount, "Amount exceeds contract supply");

        // NOTE(pb): Same calls are repeated in both branches of the if-else in order to minimise gas impact, comparing
        //  to implementation, where these calls would be present in the code just once, after if-else block.
        if (amount > swapFee) {
            // NOTE(pb): No need to use safe math here, the overflow is prevented by `if` condition above.
            uint256 effectiveAmount = amount - swapFee;
            token.transfer(to, effectiveAmount);
            emit SwapRefund(id, to, effectiveAmount, swapFee);
        } else {
            // NOTE(pb): No transfer necessary in this case, since whole amount is taken as swap fee.
            emit SwapRefund(id, to, 0, amount);
        }

        // NOTE(pb): Here we need to record the original `amount` value (passed as input param) rather than
        //  `effectiveAmount` in order to make sure, that the value is **NOT** zero (so it is possible to detect
        //  existence of key-value record in the `refunds` mapping (this is done in the `verifyRefundSwapId(...)`
        //  modifier). This also means that relayer role shall call this `refund(...)` function only for `amount > 0`,
        //  otherways relayer will pay Tx fee for executing the transaction which will have *NO* effect.
        refunds[id] = amount;
    }


    /**
      * @notice Refunds swap previously created by `swap(...)` call to this contract, where `swapFee` *IS* refunded
      *         back to the user (= swap fee is waived = user will receive full `amount`).
      *         Purpose of this method is to enable full refund in the situations when it si not user's fault that
      *         swap needs to be refunded (e.g. when Fetch Native Mainnet-v2 will become unavailable for prolonged
      *         period of time, etc. ...).
      *
      * @dev Callable exclusively by `relayer` role
      *
      * @param id - swap id to refund - must be swap id of swap originally created by `swap(...)` call to this contract,
      *             **NOT** *reverse* swap id!
      * @param to - address where the refund will be transferred in to(IDENTICAL to address used in associated `swap`
      *             call)
      * @param amount - original amount specified in associated `swap` call = it INCLUDES swap fee, which will be
      *                 waived = user will receive whole `amount` value.
      *                 Pleas mind that `amount > 0`, otherways relayer will pay Tx fee for executing the transaction
      *                 which will have *NO* effect (= like this function `refundInFull(...)` would *not* have been
      *                 called at all!
      * @param relayEon_ - current relay eon, ensures safe management of relaying process
      */
    function refundInFull(
        uint64 id,
        address to,
        uint256 amount,
        uint64 relayEon_
        )
        external
        override
        verifyRelayerApiNotPaused
        verifyTxRelayEon(relayEon_)
        verifyReverseSwapAmount(amount)
        onlyRelayer
        verifyRefundSwapId(id)
    {
        // NOTE(pb): Fail as early as possible - withdrawal from aggregated allowance is most likely to fail comparing
        //  to rest of the operations bellow.
        _updateReverseAggregatedAllowance(amount);

        supply = supply.sub(amount, "Amount exceeds contract supply");

        token.transfer(to, amount);
        emit SwapRefund(id, to, amount, 0);

        // NOTE(pb): Here we need to record the original `amount` value (passed as input param) rather than
        //  `effectiveAmount` in order to make sure, that the value is **NOT** zero (so it is possible to detect
        //  existence of key-value record in the `refunds` mapping (this is done in the `verifyRefundSwapId(...)`
        //  modifier). This also means that relayer role shall call this function function only for `amount > 0`,
        //  otherways relayer will pay Tx fee for executing the transaction which will have *NO* effect.
        refunds[id] = amount;
    }


    /**
      * @notice Finalises swap initiated by counterpart contract on the other blockchain.
      *         This call sends swapped tokens to `to` address value user specified in original swap on the **OTHER**
      *         blockchain.
      *
      * @dev Callable exclusively by `relayer` role
      *
      * @param rid - reverse swap id - unique identifier of the swap initiated on the **OTHER** blockchain.
      *              This id is, by definition, sequentially growing number incremented by 1 for each new swap initiated
      *              the other blockchain. **However**, it is *NOT* ensured that *all* swaps from the other blockchain
      *              will be transferred to this (Ethereum) blockchain, since some of these swaps can be refunded back
      *              to users (on the other blockchain).
      * @param to - address where the refund will be transferred in to
      * @param from - source address from which user transferred tokens from on the other blockchain. Present primarily
      *               for purposes of quick querying of events on this blockchain.
      * @param originTxHash - transaction hash for swap initiated on the **OTHER** blockchain. Present in order to
      *                       create strong bond between this and other blockchain.
      * @param amount - original amount specified in associated swap initiated on the other blockchain.
      *                 Swap fee is *withdrawn* from the `amount` user specified in the swap on the other blockchain,
      *                 what means that user receives `amount - swapFee`, or *nothing* if `amount <= swapFee`.
      *                 Pleas mind that `amount > 0`, otherways relayer will pay Tx fee for executing the transaction
      *                 which will have *NO* effect (= like this function `refundInFull(...)` would *not* have been
      *                 called at all!
      * @param relayEon_ - current relay eon, ensures safe management of relaying process
      */
    function reverseSwap(
        uint64 rid, // Reverse swp id (from counterpart contract on other blockchain)
        address to,
        string calldata from,
        bytes32 originTxHash,
        uint256 amount, // This is original swap amount (= *includes* swapFee)
        uint64 relayEon_
        )
        external
        override
        verifyRelayerApiNotPaused
        verifyTxRelayEon(relayEon_)
        verifyReverseSwapAmount(amount)
        onlyRelayer
    {
        // NOTE(pb): Fail as early as possible - withdrawal from aggregated allowance is most likely to fail comparing
        //  to rest of the operations bellow.
        _updateReverseAggregatedAllowance(amount);

        supply = supply.sub(amount, "Amount exceeds contract supply");

        if (amount > swapFee) {
            // NOTE(pb): No need to use safe math here, the overflow is prevented by `if` condition above.
            uint256 effectiveAmount = amount - swapFee;
            token.transfer(to, effectiveAmount);
            emit ReverseSwap(rid, to, from, originTxHash, effectiveAmount, swapFee);
        } else {
            // NOTE(pb): No transfer, no contract supply change since whole amount is taken as swap fee.
            emit ReverseSwap(rid, to, from, originTxHash, 0, amount);
        }
    }


    // **********************************************************
    // ****   MONITOR/ADMIN-LEVEL ACCESS METHODS   *****


    /**
     * @notice Pauses Public API since the specified block number
     * @param blockNumber block number since which public interaction will be paused (for all
     *        block.number >= blockNumber).
     * @dev Delegate only
     *      If `blocknumber < block.number`, then contract will be paused immediately = from `block.number`.
     */
    function pausePublicApiSince(uint256 blockNumber)
        external
        override
        canPause(blockNumber)
    {
        _pausePublicApiSince(blockNumber);
    }


    /**
     * @notice Pauses Relayer API since the specified block number
     * @param blockNumber block number since which Relayer API interaction will be paused (for all
     *        block.number >= blockNumber).
     * @dev Delegate only
     *      If `blocknumber < block.number`, then contract will be paused immediately = from `block.number`.
     */
    function pauseRelayerApiSince(uint256 blockNumber)
        external
        override
        canPause(blockNumber)
    {
        _pauseRelayerApiSince(blockNumber);
    }


    // **********************************************************
    // ************    ADMIN-LEVEL ACCESS METHODS   *************


    /**
     * @notice Mints provided amount of FET tokens.
     *         This is to reflect changes in minted Native FET token supply on the Fetch Native Mainnet-v2 blockchain.
     * @param amount - number of FET tokens to mint.
     */
    function mint(uint256 amount)
        external
        override
        onlyOwner
    {
        // NOTE(pb): The `supply` shall be adjusted by minted amount.
        supply = supply.add(amount);
        require(cap >= supply, "Minting would exceed the cap");
        token.mint(address(this), amount);
    }

    /**
     * @notice Burns provided amount of FET tokens.
     *         This is to reflect changes in minted Native FET token supply on the Fetch Native Mainnet-v2 blockchain.
     * @param amount - number of FET tokens to burn.
     */
    function burn(uint256 amount)
        external
        override
        onlyOwner
    {
        // NOTE(pb): The `supply` shall be adjusted by burned amount.
        supply = supply.sub(amount, "Amount exceeds contract supply");
        token.burn(amount);
    }


    /**
     * @notice Sets cap (max) value of `supply` this contract can hold = the value of tokens transferred to the other
     *         blockchain.
     *         This cap affects(limits) all operations which *increase* contract's `supply` value = `swap(...)` and
     *         `mint(...)`.
     * @param value - new cap value.
     */
    function setCap(uint256 value)
        external
        override
        onlyOwner
    {
        _setCap(value);
    }


    /**
     * @notice Sets value of `reverseAggregatedAllowance` state variable.
     *         This affects(limits) operations which *decrease* contract's `supply` value via **RELAYER** authored
     *         operations (= `reverseSwap(...)` and `refund(...)`). It does **NOT** affect **ADMINISTRATION** authored
     *         supply decrease operations (= `withdraw(...)` & `burn(...)`).
     * @param value - new allowance value (absolute)
     */
    function setReverseAggregatedAllowance(uint256 value)
        external
        override
        canSetReverseAggregatedAllowance(value)
    {
        _setReverseAggregatedAllowance(value);
    }


    /**
     * @notice Sets value of `reverseAggregatedAllowanceApproverCap` state variable.
     *         This limits APPROVER_ROLE from top - value up to which can approver rise the allowance.
     * @param value - new cap value (absolute)
     */
    function setReverseAggregatedAllowanceApproverCap(uint256 value)
        external
        override
        onlyOwner
    {
        _setReverseAggregatedAllowanceApproverCap(value);
    }


    /**
     * @notice Sets limits for swap amount
     *         FUnction will revert if following consitency check fails: `swapfee_ <= swapMin_ <= swapMax_`
     * @param swapMax_ : >= swap amount, applies for **OUTGOING** swap (= `swap(...)` call)
     * @param swapMin_ : <= swap amount, applies for **OUTGOING** swap (= `swap(...)` call)
     * @param swapFee_ : defines swap fee for **INCOMING** swap (= `reverseSwap(...)` call), and `refund(...)`
     */
    function setLimits(
        uint256 swapMax_,
        uint256 swapMin_,
        uint256 swapFee_
        )
        external
        override
        onlyOwner
    {
        _setLimits(swapMax_, swapMin_, swapFee_);
    }


    /**
     * @notice Withdraws amount from contract's supply, which is supposed to be done exclusively for relocating funds to
     *       another Bridge system, and **NO** other purpose.
     * @param targetAddress : address to send tokens to
     * @param amount : amount of tokens to withdraw
     */
    function withdraw(
        address targetAddress,
        uint256 amount
        )
        external
        override
        onlyOwner
    {
        supply = supply.sub(amount, "Amount exceeds contract supply");
        token.transfer(targetAddress, amount);
        emit Withdraw(targetAddress, amount);
    }


    /**
     * @dev Deposits funds back in to the contract supply.
     *      Dedicated to increase contract's supply, usually(but not necessarily) after previous withdrawal from supply.
     *      NOTE: This call needs preexisting ERC20 allowance >= `amount` for address of this Bridge contract as
     *            recipient/beneficiary and Tx sender address as sender.
     *            This means that address passed in as the Tx sender, must have already crated allowance by calling the
     *            `ERC20.approve(from, ADDR_OF_BRIDGE_CONTRACT, amount)` *before* calling this(`deposit(...)`) call.
     * @param amount : deposit amount
     */
    function deposit(uint256 amount)
        external
        override
        onlyOwner
    {
        supply = supply.add(amount);
        require(cap >= supply, "Deposit would exceed the cap");
        token.transferFrom(msg.sender, address(this), amount);
        emit Deposit(msg.sender, amount);
    }


    /**
     * @notice Withdraw fees accrued so far.
     *         !IMPORTANT!: Current design of this contract does *NOT* allow to distinguish between *swap fees accrued*
     *                      and *excess funds* sent to the contract's address via *direct* `ERC20.transfer(...)`.
     *                      Implication is that excess funds **are treated** as swap fees.
     *                      The only way how to separate these two is off-chain, by replaying events from this and
     *                      Fet ERC20 contracts and do the reconciliation.
     *
     * @param targetAddress : address to send tokens to.
     */
    function withdrawFees(address targetAddress)
        external
        override
        onlyOwner
    {
        uint256 fees = this.getFeesAccrued();
        require(fees > 0, "No fees to withdraw");
        token.transfer(targetAddress, fees);
        emit FeesWithdrawal(targetAddress, fees);
    }


    /**
     * @notice Delete the contract, transfers the remaining token and ether balance to the specified
     *         payoutAddress
     * @param targetAddress address to transfer the balances to. Ensure that this is able to handle ERC20 tokens
     * @dev owner only + only on or after `earliestDelete` block
     */
    function deleteContract(address payable targetAddress)
        external
        override
        onlyOwner
    {
        require(earliestDelete <= block.number, "Earliest delete not reached");
        require(targetAddress != address(this), "pay addr == this contract addr");
        uint256 contractBalance = token.balanceOf(address(this));
        token.transfer(targetAddress, contractBalance);
        emit DeleteContract(targetAddress, contractBalance);
        selfdestruct(targetAddress);
    }


    // **********************************************************
    // ******************    INTERNAL METHODS   *****************


    function _isOwner() internal view returns(bool) {
        return hasRole(DEFAULT_ADMIN_ROLE, msg.sender);
    }

    function _verifyRelayerApiNotPaused() internal view {
        require(pausedSinceBlockRelayerApi > block.number, "Contract has been paused");
    }

    /**
     * @notice Pauses Public API since the specified block number
     * @param blockNumber - block number since which interaction with Public API will be paused (for all
     *                      block.number >= blockNumber)
     */
    function _pausePublicApiSince(uint256 blockNumber) internal
    {
        pausedSinceBlockPublicApi = blockNumber < block.number ? block.number : blockNumber;
        emit PausePublicApi(pausedSinceBlockPublicApi);
    }


    /**
     * @notice Pauses Relayer API since the specified block number
     * @param blockNumber - block number since which interaction with Relayer API will be paused (for all
     *                      block.number >= blockNumber)
     */
    function _pauseRelayerApiSince(uint256 blockNumber) internal
    {
        pausedSinceBlockRelayerApi = blockNumber < block.number ? block.number : blockNumber;
        emit PauseRelayerApi(pausedSinceBlockRelayerApi);
    }


    function _setLimits(
        uint256 swapMax_,
        uint256 swapMin_,
        uint256 swapFee_
        )
        internal
    {
        require((swapFee_ <= swapMin_) && (swapMin_ <= swapMax_), "fee<=lower<=upper violated");

        swapMax = swapMax_;
        swapMin = swapMin_;
        swapFee = swapFee_;

        emit LimitsUpdate(swapMax, swapMin, swapFee);
    }


    function _setCap(uint256 cap_) internal
    {
        cap = cap_;
        emit CapUpdate(cap);
    }


    function _setReverseAggregatedAllowance(uint256 allowance) internal
    {
        reverseAggregatedAllowance = allowance;
        emit ReverseAggregatedAllowanceUpdate(reverseAggregatedAllowance);
    }


    function _setReverseAggregatedAllowanceApproverCap(uint256 value) internal
    {
        reverseAggregatedAllowanceApproverCap = value;
        emit ReverseAggregatedAllowanceApproverCapUpdate(reverseAggregatedAllowanceApproverCap);
    }


    function _updateReverseAggregatedAllowance(uint256 amount) internal {
        reverseAggregatedAllowance = reverseAggregatedAllowance.sub(amount, "Operation exceeds reverse aggregated allowance");
    }
}