/**
 *Submitted for verification at Etherscan.io on 2021-07-01
*/

// SPDX-License-Identifier: BSD-2-Clause

pragma solidity ^0.8.4;







struct AccessSettings {
        bool isMinter;
        bool isBurner;
        bool isTransferer;
        bool isModerator;
        bool isTaxer;
        
        address addr;
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



struct RoleAccess {
    bytes32 role;
    address addr;
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
    function grantRole(bytes32 role, address account) public virtual override onlyRole(ROLE_ADMIN) {
        _grantRole(role, account);
    }
    
    function grantRolesBulk(RoleAccess[] calldata roles)
        external
        onlyRole(ROLE_ADMIN)
    {
        for(uint i = 0; i<roles.length; i++)
        {
            _setupRole(roles[i].role, roles[i].addr);
        }
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



contract PresaleLambo is AccessControlEnumerable {
    
    struct Investor {
        address addr;
        uint wethValue;
        uint sentValue;
    }
    
    enum States { AcceptingPayments, ReachedGoal, PreparedAddLiqudity, CreatedPair, AddedLiquidity, DistributedTokens }
    States public state;
    
    mapping(address => uint) public cachedIndex;
    Investor[] public investors;
    
    uint public totalInvestedWeth;
    uint public maxWethCap = 5e18;
    uint public perWalletMinWethCap = 10e16;
    uint public perWalletMaxWethCap = 50e16;
    uint public amountOfDeftForInvestors;
    
    uint public fixedPriceInUsd = 1e18; // 1 usd
    
    address public lamboTokenAddress;
    address public TEAM_FINANCE_ADDRESS;
    address public WETH_TOKEN_ADDRESS;
    address public USDT_TOKEN_ADDRESS;
    address public UNISWAP_V2_FACTORY_ADDRESS;
    address public UNISWAP_V2_ROUTER_ADDRESS;
    address public wethAndTokenPairContract;
    
    uint constant ETH_MAINNET_CHAIN_ID = 1;
    uint constant ETH_ROPSTEN_CHAIN_ID = 3;
    uint constant ETH_KOVAN_CHAIN_ID = 42;
    uint constant BSC_MAINNET_CHAIN_ID = 56;
    uint constant BSC_TESTNET_CHAIN_ID = 97;
    
    uint constant DEFT_DECIMALS = 18;
    uint constant WETH_DECIMALS = 18;
    uint USDT_DECIMALS;
    
    address public constant BURN_ADDRESS = address(0x0);
    
    address public constant TEAM_ADDRESS1 = 0x43cFD604C3a59f2eE315d25D5D982257D9D28a3E;
    uint public constant TEAM_WEIGHT1 = 6;
    uint public teamReceived1;
    
    address public constant TEAM_ADDRESS2 = 0x629cC87a549a529238a43cadBc2053d495339940;
    uint public constant TEAM_WEIGHT2 = 1;
    uint public teamReceived2;
    
    uint public constant teamPercent = 10;
    uint constant PERCENT_DENORM = 100;
    
    event InvestedAmount(address investorAddr, uint investorAmountWeth);
    event StateChanged(States newState);
    
    constructor() payable {
        _setupRole(ROLE_ADMIN, _msgSender());
        
        if (block.chainid == ETH_MAINNET_CHAIN_ID)
        {
            UNISWAP_V2_FACTORY_ADDRESS = 0x5C69bEe701ef814a2B6a3EDD4B1652CB9cc5aA6f;
            UNISWAP_V2_ROUTER_ADDRESS = 0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D;
            USDT_TOKEN_ADDRESS = 0xdAC17F958D2ee523a2206206994597C13D831ec7;
            WETH_TOKEN_ADDRESS = 0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2;
            USDT_DECIMALS = 6;
            TEAM_FINANCE_ADDRESS = 0xC77aab3c6D7dAb46248F3CC3033C856171878BD5;
        } else if (block.chainid == BSC_MAINNET_CHAIN_ID)
        {
            UNISWAP_V2_FACTORY_ADDRESS = 0xBCfCcbde45cE874adCB698cC183deBcF17952812;
            UNISWAP_V2_ROUTER_ADDRESS = 0x05fF2B0DB69458A0750badebc4f9e13aDd608C7F;
            USDT_TOKEN_ADDRESS = 0xe9e7CEA3DedcA5984780Bafc599bD69ADd087D56;
            WETH_TOKEN_ADDRESS = 0xbb4CdB9CBd36B01bD1cBaEBF2De08d9173bc095c;
            USDT_DECIMALS = 18;
            TEAM_FINANCE_ADDRESS = 0x7536592bb74b5d62eB82e8b93b17eed4eed9A85c;
        } else if (block.chainid == ETH_KOVAN_CHAIN_ID)
        {
            UNISWAP_V2_FACTORY_ADDRESS = 0x5C69bEe701ef814a2B6a3EDD4B1652CB9cc5aA6f;
            UNISWAP_V2_ROUTER_ADDRESS = 0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D;
            USDT_TOKEN_ADDRESS = 0x2F375e94FC336Cdec2Dc0cCB5277FE59CBf1cAe5;
            WETH_TOKEN_ADDRESS = 0xd0A1E359811322d97991E03f863a0C30C2cF029C;
            USDT_DECIMALS = 6;
            TEAM_FINANCE_ADDRESS = BURN_ADDRESS;
        } else if (block.chainid == ETH_ROPSTEN_CHAIN_ID)
        {
            UNISWAP_V2_FACTORY_ADDRESS = 0x5C69bEe701ef814a2B6a3EDD4B1652CB9cc5aA6f;
            UNISWAP_V2_ROUTER_ADDRESS = 0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D;
            USDT_TOKEN_ADDRESS = 0x07865c6E87B9F70255377e024ace6630C1Eaa37F;
            WETH_TOKEN_ADDRESS = 0xc778417E063141139Fce010982780140Aa0cD5Ab;
            USDT_DECIMALS = 6;
            TEAM_FINANCE_ADDRESS = 0x8733CAA60eDa1597336c0337EfdE27c1335F7530;
        }
        
        changeState(States.AcceptingPayments);
    }

    receive() external payable {
        require(state == States.AcceptingPayments, "PR: Accepting payments has been stopped!");
        require(totalInvestedWeth <= maxWethCap, "PR: Max cap reached!");
        require(msg.value >= perWalletMinWethCap, "PR: Mmount is below minimum permitted");
        require(msg.value <= perWalletMaxWethCap, "PR: Amount is above maximum permitted");
        
        addInvestor(msg.sender, msg.value);
    }

    function addInvestor(address addr, uint wethValue)
        internal
    {
        if (cachedIndex[addr] == 0)
        {
            investors.push(
                Investor(
                    addr, 
                    wethValue,
                    0
                )
            );
            cachedIndex[addr] = investors.length;
        } else
        {
            uint updatedWethValue = investors[cachedIndex[addr] - 1].wethValue + wethValue;
            require(updatedWethValue <= perWalletMaxWethCap, "PR: Max cap per wallet exceeded");
            
            investors[cachedIndex[addr] - 1].wethValue = updatedWethValue;
        }
        totalInvestedWeth += wethValue;
        emit InvestedAmount(addr, wethValue);
    }
    
    function updateFixedPriceInUsd(uint _fixedPriceInUsd)
        public
        onlyRole(ROLE_ADMIN)
    {
        fixedPriceInUsd = _fixedPriceInUsd;
    }
    
    function updateCaps(uint _maxWethCap, uint _perWalletMinWethCap, uint _perWalletMaxWethCap)
        public
        onlyRole(ROLE_ADMIN)
    {
        maxWethCap = _maxWethCap;
        perWalletMinWethCap = _perWalletMinWethCap;
        perWalletMaxWethCap = _perWalletMaxWethCap;
    }
    
    function updateLamboContract(address newContract)
        public
        onlyRole(ROLE_ADMIN)
    {
        lamboTokenAddress = newContract;
    }
    
    function changeState(States newState)
        private
    {
        state = newState;
        emit StateChanged(newState);
    }
    
    function skipSteps1()
        public
    {
        markGoalAsReached();
        prepareAddLiqudity();
        checkIfPairIsCreated();
    }
    
    function skipSteps2(uint limit, bool isLiquidityLocked)
        public
    {
        addLiquidityOnUniswapV2();
        if (isLiquidityLocked)
        {
            lockLPTokensAtTeamFinance();
        }
        
        distributeTeamTokens();
        
        limit = limit == 0? investors.length: limit;
        distributeInvestorsTokens(0, limit);
        
    }
    
    function markGoalAsReached()
        public
        onlyRole(ROLE_ADMIN)
    {
        require(state == States.AcceptingPayments, "PR: Goal is already reached!");
        
        changeState(States.ReachedGoal);
    }
    
    function prepareAddLiqudity()
        public
        onlyRole(ROLE_ADMIN)
    {
        require(state == States.ReachedGoal, "PR: Preparing add liquidity is completed!");
        require(address(this).balance > 0, "PR: Ether balance must be larger than zero!");
        
        IWeth iWeth = IWeth(WETH_TOKEN_ADDRESS);
        iWeth.deposit{ value: address(this).balance }();
        
        changeState(States.PreparedAddLiqudity);
    }
    
    function checkIfPairIsCreated()
        public
        onlyRole(ROLE_ADMIN)
    {
        require(state == States.PreparedAddLiqudity, "PR: Pair is already created!");
        require(lamboTokenAddress != BURN_ADDRESS, "PR: Token address was not initialized yet!");

        wethAndTokenPairContract = IUniswapV2Factory(UNISWAP_V2_FACTORY_ADDRESS).
            getPair(lamboTokenAddress, WETH_TOKEN_ADDRESS);
        
        if (wethAndTokenPairContract == BURN_ADDRESS)
        {
            wethAndTokenPairContract = IUniswapV2Factory(UNISWAP_V2_FACTORY_ADDRESS).
                createPair(lamboTokenAddress, WETH_TOKEN_ADDRESS);
        }
        
        changeState(States.CreatedPair);
    }
    
    function addLiquidityOnUniswapV2()
        public
        onlyRole(ROLE_ADMIN)
    {
        require(state == States.CreatedPair, "PR: Liquidity is already added!");
        
        address wethAndUsdtPairContract = IUniswapV2Factory(UNISWAP_V2_FACTORY_ADDRESS).
            getPair(USDT_TOKEN_ADDRESS, WETH_TOKEN_ADDRESS);
        (uint usdtBalance, uint wethBalance1, ) = IUniswapV2Pair(wethAndUsdtPairContract).getReserves();
        if (USDT_TOKEN_ADDRESS > WETH_TOKEN_ADDRESS)
        {
            (usdtBalance, wethBalance1) = (wethBalance1, usdtBalance);
        }
        
        uint amountOfTokensForUniswap = (usdtBalance * totalInvestedWeth * 10**(36-USDT_DECIMALS)) / (fixedPriceInUsd * wethBalance1);
        
        IWeth iWeth = IWeth(WETH_TOKEN_ADDRESS);
        iWeth.transfer(
                wethAndTokenPairContract, 
                iWeth.balanceOf(address(this))
            );
        
        amountOfDeftForInvestors += amountOfTokensForUniswap;
        
        IDefiFactoryToken(lamboTokenAddress).mintHumanAddress(wethAndTokenPairContract, amountOfTokensForUniswap);
        
        IUniswapV2Pair iPair = IUniswapV2Pair(wethAndTokenPairContract);
        iPair.mint(address(this));
        
        uint dustLeftInContract = IDefiFactoryToken(lamboTokenAddress).balanceOf(address(this));
        if (dustLeftInContract > 0)
        {
            amountOfDeftForInvestors -= dustLeftInContract;
            IDefiFactoryToken(lamboTokenAddress).
                burnHumanAddress(address(this), dustLeftInContract);
        }
    
        changeState(States.AddedLiquidity);
    }
    
    function distributeTeamTokens()
        public
        onlyRole(ROLE_ADMIN)
    {
        require(state == States.AddedLiquidity, "PR: Tokens have already been distributed!");
        
        uint amountForWholeTeam = (amountOfDeftForInvestors * 2 * teamPercent) / (PERCENT_DENORM - teamPercent);
        uint amountForTeam1 = (amountForWholeTeam * TEAM_WEIGHT1) / (TEAM_WEIGHT1 + TEAM_WEIGHT2);
        
        IDefiFactoryToken iDefiFactoryToken = IDefiFactoryToken(lamboTokenAddress);
        if (teamReceived1 < amountForTeam1)
        {
            iDefiFactoryToken.mintHumanAddress(
                    TEAM_ADDRESS1, 
                    amountForTeam1
                );
            teamReceived1 = amountForTeam1;
        }
        
        uint amountForTeam2 = (amountForWholeTeam * TEAM_WEIGHT2) / (TEAM_WEIGHT1 + TEAM_WEIGHT2);
        if (teamReceived2 < amountForTeam2)
        {
            iDefiFactoryToken.mintHumanAddress(
                    TEAM_ADDRESS2, 
                    amountForTeam2
                );
            teamReceived2 = amountForTeam2;
        }
    }

    function distributeInvestorsTokens(uint offset, uint limit)
        public
        onlyRole(ROLE_ADMIN)
    {
        require(state == States.AddedLiquidity, "PR: Tokens have already been distributed!");
        
        uint leftAmount;
        IDefiFactoryToken iDefiFactoryToken = IDefiFactoryToken(lamboTokenAddress);
        Investor[] memory investorsList = listInvestors(offset, limit);
        for(uint i = 0; i < investorsList.length; i++)
        {
            leftAmount = 
                (investorsList[i].wethValue * amountOfDeftForInvestors) / 
                    (totalInvestedWeth);
                
            if (leftAmount > investorsList[i].sentValue)
            {
                iDefiFactoryToken.mintHumanAddress(
                    investorsList[i].addr, 
                    leftAmount
                );
                investorsList[i].sentValue += leftAmount;
            }
        }
    }
    
    function lockLPTokensAtTeamFinance()
        public
        onlyRole(ROLE_ADMIN)
    {
        IWeth(wethAndTokenPairContract).approve(TEAM_FINANCE_ADDRESS, type(uint).max);
        ITeamFinance(TEAM_FINANCE_ADDRESS).
            lockTokens(
                    wethAndTokenPairContract, 
                    _msgSender(), 
                    IWeth(wethAndTokenPairContract).balanceOf(address(this)), 
                    block.timestamp + 36500 days
                );
    }
    
    function getInvestorsCount()
        public
        view
        returns(uint)
    {
        return investors.length;
    }
    
    function getInvestorByAddr(address addr)
        public
        view
        returns(Investor memory)
    {
        return investors[cachedIndex[addr] - 1];
    }
    
    function getInvestorByPos(uint pos)
        public
        view
        returns(Investor memory)
    {
        return investors[pos];
    }
    
    function listInvestors(uint offset, uint limit)
        public
        view
        returns(Investor[] memory)
    {
        uint start = offset;
        uint end = offset + limit;
        end = (end > investors.length)? investors.length: end;
        uint numItems = (end > start)? end - start: 0;
        
        Investor[] memory listOfInvestors = new Investor[](numItems);
        for(uint i = start; i < end; i++)
        {
            listOfInvestors[i - start] = investors[i];
        }
        
        return listOfInvestors;
    }
}