/**
 *Submitted for verification at Etherscan.io on 2021-02-21
*/

// SPDX-License-Identifier: MIT

pragma solidity 0.6.12;



// Part: IAddressResolver



// Part: IBoringDAO



// Part: IMintProposal



// Part: IOracle



// Part: IPaused



// Part: ITrusteeFeePool



// Part: ITunnel



// Part: ITunnelV2



// Part: OpenZeppelin/[email protected]/Address

/**
 * @dev Collection of functions related to the address type
 */


// Part: OpenZeppelin/[email protected]/Context

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


// Part: OpenZeppelin/[email protected]/IERC20

/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
 */


// Part: OpenZeppelin/[email protected]/SafeMath

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


// Part: OpenZeppelin/[email protected]/AccessControl

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

// Part: OpenZeppelin/[email protected]/Ownable

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
    constructor () internal {
        address msgSender = _msgSender();
        _owner = msgSender;
        emit OwnershipTransferred(address(0), msgSender);
    }

    /**
     * @dev Returns the address of the current owner.
     */
    function owner() public view returns (address) {
        return _owner;
    }

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        require(_owner == _msgSender(), "Ownable: caller is not the owner");
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

// Part: OpenZeppelin/[email protected]/Pausable

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
     *
     * Requirements:
     *
     * - The contract must not be paused.
     */
    modifier whenNotPaused() {
        require(!_paused, "Pausable: paused");
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
        require(_paused, "Pausable: not paused");
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

// Part: SafeDecimalMath

// https://docs.synthetix.io/contracts/SafeDecimalMath


// Part: ParamBook

contract ParamBook is Ownable {
    mapping(bytes32 => uint256) public params;
    mapping(bytes32 => mapping(bytes32 => uint256)) public params2;

    function setParams(bytes32 name, uint256 value) public onlyOwner {
        params[name] = value;
    }

    function setMultiParams(bytes32[] memory names, uint[] memory values) public onlyOwner {
        require(names.length == values.length, "ParamBook::setMultiParams:param length not match");
        for (uint i=0; i < names.length; i++ ) {
            params[names[i]] = values[i];
        }
    }

    function setParams2(
        bytes32 name1,
        bytes32 name2,
        uint256 value
    ) public onlyOwner {
        params2[name1][name2] = value;
    }

    function setMultiParams2(bytes32[] memory names1, bytes32[] memory names2, uint[] memory values) public onlyOwner {
        require(names1.length == names2.length, "ParamBook::setMultiParams2:param length not match");
        require(names1.length == values.length, "ParamBook::setMultiParams2:param length not match");
        for(uint i=0; i < names1.length; i++) {
            params2[names1[i]][names2[i]] = values[i];
        }
    }
}

// File: BoringDAOV2.sol

/**
@notice The BoringDAO contract is the entrance to the entire system, 
providing the functions of pledge BOR, redeem BOR, mint bBTC, and destroy bBTC
 */
contract BoringDAOV2 is AccessControl, IBoringDAO, Pausable {
    using SafeDecimalMath for uint256;
    using SafeMath for uint256;

    uint256 public amountByMint;

    bytes32 public constant MONITOR_ROLE = "MONITOR_ROLE ";
    bytes32 public constant GOV_ROLE = "GOV_ROLE";

    bytes32 public constant BOR = "BOR";
    bytes32 public constant PARAM_BOOK = "ParamBook";
    bytes32 public constant MINT_PROPOSAL = "MintProposal";
    bytes32 public constant ORACLE = "Oracle";
    bytes32 public constant TRUSTEE_FEE_POOL = "TrusteeFeePool";
    bytes32 public constant OTOKEN = "oToken";

    bytes32 public constant TUNNEL_MINT_FEE_RATE = "mint_fee";
    bytes32 public constant NETWORK_FEE = "network_fee";

    IAddressResolver public addrReso;

    // tunnels
    ITunnelV2[] public tunnels;

    uint256 public mintCap;

    address public mine;

    // The user may not provide the Ethereum address or the format of the Ethereum address is wrong when mint. 
    // this is for a transaction
    mapping(string=>bool) public approveFlag;

    uint public reductionAmount=1000e18;


    constructor(IAddressResolver _addrReso, uint _mintCap, address _mine) public {
        // set up resolver
        addrReso = _addrReso;
        mintCap = _mintCap;
        mine = _mine;
        _setupRole(DEFAULT_ADMIN_ROLE, msg.sender);
        _setupRole(MONITOR_ROLE, msg.sender);
    }


    function tunnel(bytes32 tunnelKey) internal view returns (ITunnel) {
        return ITunnel(addrReso.key2address(tunnelKey));
    }

    function otoken(bytes32 _tunnelKey) internal view returns (IERC20) {
        return IERC20(addrReso.requireKKAddrs(_tunnelKey, OTOKEN, "oToken not exist"));
    }

    function borERC20() internal view returns (IERC20) {
        return IERC20(addrReso.key2address(BOR));
    }

    function paramBook() internal view returns (ParamBook) {
        return ParamBook(addrReso.key2address(PARAM_BOOK));
    }

    function mintProposal() internal view returns (IMintProposal) {
        return IMintProposal(addrReso.key2address(MINT_PROPOSAL));
    }

    function oracle() internal view returns (IOracle) {
        return IOracle(addrReso.key2address(ORACLE));
    }

    // trustee fee pool key
    function trusteeFeePool(bytes32 _tunnelKey) internal view returns (ITrusteeFeePool) {
        return ITrusteeFeePool(addrReso.requireKKAddrs(_tunnelKey, TRUSTEE_FEE_POOL, "BoringDAO::TrusteeFeePool is address(0)"));
    }

    // trustee fee pool key => tfpk
    function addTrustee(address account, bytes32 _tunnelKey) public onlyAdmin {
        _setupRole(_tunnelKey, account);
        trusteeFeePool(_tunnelKey).enter(account);

    }

    function addTrustees(address[] memory accounts, bytes32 _tunnelKey) external onlyAdmin{
        for (uint256 i = 0; i < accounts.length; i++) {
            addTrustee(accounts[i], _tunnelKey);
        }
    }

    function removeTrustee(address account, bytes32 _tunnelKey) public onlyAdmin {
        revokeRole(_tunnelKey, account);
        trusteeFeePool(_tunnelKey).exit(account);
    }

    function setMine(address _mine) public onlyAdmin {
        mine = _mine;
    }

    function setMintCap(uint256 amount) public onlyAdmin {
        mintCap = amount;
    }

    /**
    @notice tunnelKey is byte32("symbol"), eg. bytes32("BTC")
     */
    function pledge(bytes32 _tunnelKey, uint256 _amount)
        public
        override
        whenNotPaused
        whenContractExist(_tunnelKey)
    {
        require(
            borERC20().allowance(msg.sender, address(this)) >= _amount,
            "not allow enough bor"
        );

        borERC20().transferFrom(
            msg.sender,
            address(tunnel(_tunnelKey)),
            _amount
        );
        tunnel(_tunnelKey).pledge(msg.sender, _amount);
    }

    /**
    @notice redeem bor from tunnel
     */
    function redeem(bytes32 _tunnelKey, uint256 _amount)
        public
        override
        whenNotPaused
        whenContractExist(_tunnelKey)
    {
        tunnel(_tunnelKey).redeem(msg.sender, _amount);
    }

    function burnBToken(bytes32 _tunnelKey, uint256 amount, string memory assetAddress)
        public
        override
        whenNotPaused
        whenContractExist(_tunnelKey)
        whenTunnelNotPause(_tunnelKey)
    {
        tunnel(_tunnelKey).burn(msg.sender, amount, assetAddress);
    }

    /**
    @notice trustee will call the function to approve mint bToken
    @param _txid the transaction id of bitcoin
    @param _amount the amount to mint, 1BTC = 1bBTC = 1*10**18 weibBTC
    @param to mint to the address
     */
    function approveMint(
        bytes32 _tunnelKey,
        string memory _txid,
        uint256 _amount,
        address to,
        string memory assetAddress
    ) public override whenNotPaused whenTunnelNotPause(_tunnelKey) onlyTrustee(_tunnelKey) {
        if(to == address(0)) {
            if (approveFlag[_txid] == false) {
                approveFlag[_txid] = true;
                emit ETHAddressNotExist(_tunnelKey, _txid, _amount, to, msg.sender, assetAddress);
            }
            return;
        }
        
        uint256 trusteeCount = getRoleMemberCount(_tunnelKey);
        bool shouldMint = mintProposal().approve(
            _tunnelKey,
            _txid,
            _amount,
            to,
            msg.sender,
            trusteeCount
        );
        if (!shouldMint) {
            return;
        }
        uint256 canIssueAmount = tunnel(_tunnelKey).canIssueAmount();
        if (_amount.add(otoken(_tunnelKey).totalSupply()) > canIssueAmount) {
            emit NotEnoughPledgeValue(
                _tunnelKey,
                _txid,
                _amount,
                to,
                msg.sender,
                assetAddress
            );
            return;
        }
        // fee calculate in tunnel
        tunnel(_tunnelKey).issue(to, _amount);

        uint borMintAmount = calculateMintBORAmount(_tunnelKey, _amount);
        if(borMintAmount != 0) {
            amountByMint = amountByMint.add(borMintAmount);
            borERC20().transferFrom(mine, to, borMintAmount);
        }
        emit ApproveMintSuccess(_tunnelKey, _txid, _amount, to, assetAddress);
    }

    function calculateMintBORAmount(bytes32 _tunnelKey, uint _amount) public view returns (uint) {
        if (amountByMint >= mintCap || _amount == 0) {
            return 0;
        }
        uint256 assetPrice = oracle().getPrice(_tunnelKey);
        uint256 borPrice = oracle().getPrice(BOR);
        //LTC for 1000
        uint256 reductionTimes = amountByMint.div(reductionAmount);
        uint256 mintFeeRate = paramBook().params2(
            _tunnelKey,
            TUNNEL_MINT_FEE_RATE
        );
        // for decimal calculation, so mul 1e18
        uint256 reductionFactor = (4**reductionTimes).mul(1e18).div(5**reductionTimes);
        uint networkFee = paramBook().params2(_tunnelKey, NETWORK_FEE);
        uint baseAmount = _amount.multiplyDecimalRound(mintFeeRate).mul(2).add(networkFee);
        uint borAmount = assetPrice.multiplyDecimalRound(baseAmount).multiplyDecimalRound(reductionFactor).divideDecimalRound(borPrice);
        if (amountByMint.add(borAmount) >= mintCap) {
            borAmount = mintCap.sub(amountByMint);
        }
        return borAmount;
    }

    function pause() public onlyMonitor{
        _pause();
    }

    function unpause() public onlyMonitor{
        _unpause();
    }

    modifier onlyTrustee(bytes32 _tunnelKey) {
        require(hasRole(_tunnelKey, msg.sender), "Caller is not trustee");
        _;
    }

    modifier onlyAdmin {
        require(hasRole(DEFAULT_ADMIN_ROLE, msg.sender), "BoringDAO::caller is not admin");
        _;
    }

    modifier onlyMonitor {
        require(
            hasRole(MONITOR_ROLE, msg.sender),
            "Caller is not monitor"
        );
        _;
    }

    modifier whenContractExist(bytes32 key) {
        require(
            addrReso.key2address(key) != address(0),
            "Contract not exist"
        );
        _;
    }

    modifier whenTunnelNotPause(bytes32 _tunnelKey) {
        address tunnelAddress = addrReso.requireAndKey2Address(_tunnelKey, "tunnel not exist");
        require(IPaused(tunnelAddress).paused() == false, "tunnel is paused");
        _;
    }

    event NotEnoughPledgeValue(
        bytes32 indexed _tunnelKey,
        string indexed _txid,
        uint256 _amount,
        address to,
        address trustee,
        string assetAddress
    );

    event ApproveMintSuccess(
        bytes32 _tunnelKey,
        string _txid,
        uint256 _amount,
        address to,
        string assetAddress
    );

    event ETHAddressNotExist(
        bytes32 _tunnelKey,
        string _txid,
        uint256 _amount,
        address to,
        address trustee,
        string assetAddress
    );

   
}