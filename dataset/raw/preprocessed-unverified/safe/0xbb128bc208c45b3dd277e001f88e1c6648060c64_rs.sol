/**
 *Submitted for verification at Etherscan.io on 2021-03-31
*/

// SPDX-License-Identifier: AGPL-3.0-or-later
pragma solidity 0.8.2;


struct BassetPersonal {
    // Address of the bAsset
    address addr;
    // Address of the bAsset
    address integrator;
    // An ERC20 can charge transfer fee, for example USDT, DGX tokens.
    bool hasTxFee; // takes a byte in storage
    // Status of the bAsset
    BassetStatus status;
}

struct BassetData {
    // 1 Basset * ratio / ratioScale == x Masset (relative value)
    // If ratio == 10e8 then 1 bAsset = 10 mAssets
    // A ratio is divised as 10^(18-tokenDecimals) * measurementMultiple(relative value of 1 base unit)
    uint128 ratio;
    // Amount of the Basset that is held in Collateral
    uint128 vaultBalance;
}

abstract contract IMasset {
    // Mint
    function mint(
        address _input,
        uint256 _inputQuantity,
        uint256 _minOutputQuantity,
        address _recipient
    ) external virtual returns (uint256 mintOutput);

    function mintMulti(
        address[] calldata _inputs,
        uint256[] calldata _inputQuantities,
        uint256 _minOutputQuantity,
        address _recipient
    ) external virtual returns (uint256 mintOutput);

    function getMintOutput(address _input, uint256 _inputQuantity)
        external
        view
        virtual
        returns (uint256 mintOutput);

    function getMintMultiOutput(address[] calldata _inputs, uint256[] calldata _inputQuantities)
        external
        view
        virtual
        returns (uint256 mintOutput);

    // Swaps
    function swap(
        address _input,
        address _output,
        uint256 _inputQuantity,
        uint256 _minOutputQuantity,
        address _recipient
    ) external virtual returns (uint256 swapOutput);

    function getSwapOutput(
        address _input,
        address _output,
        uint256 _inputQuantity
    ) external view virtual returns (uint256 swapOutput);

    // Redemption
    function redeem(
        address _output,
        uint256 _mAssetQuantity,
        uint256 _minOutputQuantity,
        address _recipient
    ) external virtual returns (uint256 outputQuantity);

    function redeemMasset(
        uint256 _mAssetQuantity,
        uint256[] calldata _minOutputQuantities,
        address _recipient
    ) external virtual returns (uint256[] memory outputQuantities);

    function redeemExactBassets(
        address[] calldata _outputs,
        uint256[] calldata _outputQuantities,
        uint256 _maxMassetQuantity,
        address _recipient
    ) external virtual returns (uint256 mAssetRedeemed);

    function getRedeemOutput(address _output, uint256 _mAssetQuantity)
        external
        view
        virtual
        returns (uint256 bAssetOutput);

    function getRedeemExactBassetsOutput(
        address[] calldata _outputs,
        uint256[] calldata _outputQuantities
    ) external view virtual returns (uint256 mAssetAmount);

    // Views
    function getBasket() external view virtual returns (bool, bool);

    function getBasset(address _token)
        external
        view
        virtual
        returns (BassetPersonal memory personal, BassetData memory data);

    function getBassets()
        external
        view
        virtual
        returns (BassetPersonal[] memory personal, BassetData[] memory data);

    function bAssetIndexes(address) external view virtual returns (uint8);

    // SavingsManager
    function collectInterest() external virtual returns (uint256 swapFeesGained, uint256 newSupply);

    function collectPlatformInterest()
        external
        virtual
        returns (uint256 mintAmount, uint256 newSupply);

    // Admin
    function setCacheSize(uint256 _cacheSize) external virtual;

    function upgradeForgeValidator(address _newForgeValidator) external virtual;

    function setFees(uint256 _swapFee, uint256 _redemptionFee) external virtual;

    function setTransferFeesFlag(address _bAsset, bool _flag) external virtual;

    function migrateBassets(address[] calldata _bAssets, address _newIntegration) external virtual;
}


// Status of the Basset - has it broken its peg?
enum BassetStatus {
    Default,
    Normal,
    BrokenBelowPeg,
    BrokenAbovePeg,
    Blacklisted,
    Liquidating,
    Liquidated,
    Failed
}

struct BasketState {
    bool undergoingRecol;
    bool failed;
}

struct InvariantConfig {
    uint256 a;
    WeightLimits limits;
}

struct WeightLimits {
    uint128 min;
    uint128 max;
}

struct FeederConfig {
    uint256 supply;
    uint256 a;
    WeightLimits limits;
}

struct AmpData {
    uint64 initialA;
    uint64 targetA;
    uint64 rampStartTime;
    uint64 rampEndTime;
}

struct FeederData {
    uint256 swapFee;
    uint256 redemptionFee;
    uint256 govFee;
    uint256 pendingFees;
    uint256 cacheSize;
    BassetPersonal[] bAssetPersonal;
    BassetData[] bAssetData;
    AmpData ampData;
    WeightLimits weightLimits;
}

struct AssetData {
    uint8 idx;
    uint256 amt;
    BassetPersonal personal;
}

struct Asset {
    uint8 idx;
    address addr;
    bool exists;
}

abstract contract IFeederPool {
    // Mint
    function mint(
        address _input,
        uint256 _inputQuantity,
        uint256 _minOutputQuantity,
        address _recipient
    ) external virtual returns (uint256 mintOutput);

    function mintMulti(
        address[] calldata _inputs,
        uint256[] calldata _inputQuantities,
        uint256 _minOutputQuantity,
        address _recipient
    ) external virtual returns (uint256 mintOutput);

    function getMintOutput(address _input, uint256 _inputQuantity)
        external
        view
        virtual
        returns (uint256 mintOutput);

    function getMintMultiOutput(address[] calldata _inputs, uint256[] calldata _inputQuantities)
        external
        view
        virtual
        returns (uint256 mintOutput);

    // Swaps
    function swap(
        address _input,
        address _output,
        uint256 _inputQuantity,
        uint256 _minOutputQuantity,
        address _recipient
    ) external virtual returns (uint256 swapOutput);

    function getSwapOutput(
        address _input,
        address _output,
        uint256 _inputQuantity
    ) external view virtual returns (uint256 swapOutput);

    // Redemption
    function redeem(
        address _output,
        uint256 _mAssetQuantity,
        uint256 _minOutputQuantity,
        address _recipient
    ) external virtual returns (uint256 outputQuantity);

    function redeemProportionately(
        uint256 _mAssetQuantity,
        uint256[] calldata _minOutputQuantities,
        address _recipient
    ) external virtual returns (uint256[] memory outputQuantities);

    function redeemExactBassets(
        address[] calldata _outputs,
        uint256[] calldata _outputQuantities,
        uint256 _maxMassetQuantity,
        address _recipient
    ) external virtual returns (uint256 mAssetRedeemed);

    function getRedeemOutput(address _output, uint256 _mAssetQuantity)
        external
        view
        virtual
        returns (uint256 bAssetOutput);

    function getRedeemExactBassetsOutput(
        address[] calldata _outputs,
        uint256[] calldata _outputQuantities
    ) external view virtual returns (uint256 mAssetAmount);

    // Views
    function getPrice() public view virtual returns (uint256 price, uint256 k);

    function getConfig() external view virtual returns (FeederConfig memory config);

    function getBasset(address _token)
        external
        view
        virtual
        returns (BassetPersonal memory personal, BassetData memory data);

    function getBassets()
        external
        view
        virtual
        returns (BassetPersonal[] memory personal, BassetData[] memory data);

    // SavingsManager
    function collectPlatformInterest()
        external
        virtual
        returns (uint256 mintAmount, uint256 newSupply);
}

/**
 * @dev Collection of functions related to the address type
 */


abstract contract Initializable {

    /**
     * @dev Indicates that the contract has been initialized.
     */
    bool private _initialized;

    /**
     * @dev Indicates that the contract is in the process of being initialized.
     */
    bool private _initializing;

    /**
     * @dev Modifier to protect an initializer function from being invoked twice.
     */
    modifier initializer() {
        require(_initializing || !_initialized, "Initializable: contract is already initialized");

        bool isTopLevelCall = !_initializing;
        if (isTopLevelCall) {
            _initializing = true;
            _initialized = true;
        }

        _;

        if (isTopLevelCall) {
            _initializing = false;
        }
    }
}


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
    // Empty internal constructor, to prevent people from mistakenly deploying
    // an instance of this contract, which should be used via inheritance.
    // constructor () internal { }
    // solhint-disable-previous-line no-empty-blocks

    function _msgSender() internal view returns (address payable) {
        return payable(msg.sender);
    }

    function _msgData() internal view returns (bytes memory) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}



contract ERC205 is Context, IERC20 {
    mapping (address => uint256) private _balances;

    mapping (address => mapping (address => uint256)) private _allowances;

    uint256 private _totalSupply;

    /**
     * @dev See {IERC20-totalSupply}.
     */
    function totalSupply() public view virtual override returns (uint256) {
        return _totalSupply;
    }

    /**
     * @dev See {IERC20-balanceOf}.
     */
    function balanceOf(address account) public view virtual override returns (uint256) {
        return _balances[account];
    }

    /**
     * @dev See {IERC20-transfer}.
     *
     * Requirements:
     *
     * - `recipient` cannot be the zero address.
     * - the caller must have a balance of at least `amount`.
     */
    function transfer(address recipient, uint256 amount) public virtual override returns (bool) {
        _transfer(_msgSender(), recipient, amount);
        return true;
    }

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
    function transferFrom(address sender, address recipient, uint256 amount) public virtual override returns (bool) {
        _transfer(sender, recipient, amount);

        uint256 currentAllowance = _allowances[sender][_msgSender()];
        require(currentAllowance >= amount, "ERC20: transfer amount exceeds allowance");
        _approve(sender, _msgSender(), currentAllowance - amount);

        return true;
    }

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
    function _transfer(address sender, address recipient, uint256 amount) internal virtual {
        require(sender != address(0), "ERC20: transfer from the zero address");
        require(recipient != address(0), "ERC20: transfer to the zero address");

        uint256 senderBalance = _balances[sender];
        require(senderBalance >= amount, "ERC20: transfer amount exceeds balance");
        _balances[sender] = senderBalance - amount;
        _balances[recipient] += amount;

        emit Transfer(sender, recipient, amount);
    }

    /** @dev Creates `amount` tokens and assigns them to `account`, increasing
     * the total supply.
     *
     * Emits a {Transfer} event with `from` set to the zero address.
     *
     * Requirements:
     *
     * - `to` cannot be the zero address.
     */
    function _mint(address account, uint256 amount) internal virtual {
        require(account != address(0), "ERC20: mint to the zero address");

        _totalSupply += amount;
        _balances[account] += amount;
        emit Transfer(address(0), account, amount);
    }

    /**
     * @dev Destroys `amount` tokens from `account`, reducing the
     * total supply.
     *
     * Emits a {Transfer} event with `to` set to the zero address.
     *
     * Requirements:
     *
     * - `account` cannot be the zero address.
     * - `account` must have at least `amount` tokens.
     */
    function _burn(address account, uint256 amount) internal virtual {
        require(account != address(0), "ERC20: burn from the zero address");

        uint256 accountBalance = _balances[account];
        require(accountBalance >= amount, "ERC20: burn amount exceeds balance");
        _balances[account] = accountBalance - amount;
        _totalSupply -= amount;

        emit Transfer(account, address(0), amount);
    }

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

abstract contract InitializableERC20Detailed is IERC20 {
    string private _name;
    string private _symbol;
    uint8 private _decimals;

    /**
     * @dev Sets the values for `name`, `symbol`, and `decimals`. All three of
     * these values are immutable: they can only be set once during
     * construction.
     * @notice To avoid variable shadowing appended `Arg` after arguments name.
     */
    function _initialize(
        string memory nameArg,
        string memory symbolArg,
        uint8 decimalsArg
    ) internal {
        _name = nameArg;
        _symbol = symbolArg;
        _decimals = decimalsArg;
    }

    /**
     * @dev Returns the name of the token.
     */
    function name() public view returns (string memory) {
        return _name;
    }

    /**
     * @dev Returns the symbol of the token, usually a shorter version of the
     * name.
     */
    function symbol() public view returns (string memory) {
        return _symbol;
    }

    /**
     * @dev Returns the number of decimals used to get its user representation.
     * For example, if `decimals` equals `2`, a balance of `505` tokens should
     * be displayed to a user as `5,05` (`505 / 10 ** 2`).
     *
     * Tokens usually opt for a value of 18, imitating the relationship between
     * Ether and Wei.
     *
     * NOTE: This information is only used for _display_ purposes: it in
     * no way affects any of the arithmetic of the contract, including
     * {IERC20-balanceOf} and {IERC20-transfer}.
     */
    function decimals() public view returns (uint8) {
        return _decimals;
    }
}

abstract contract InitializableToken is ERC205, InitializableERC20Detailed {
    /**
     * @dev Initialization function for implementing contract
     * @notice To avoid variable shadowing appended `Arg` after arguments name.
     */
    function _initialize(string memory _nameArg, string memory _symbolArg) internal {
        InitializableERC20Detailed._initialize(_nameArg, _symbolArg, 18);
    }
}

contract ModuleKeys {
    // Governance
    // ===========
    // keccak256("Governance");
    bytes32 internal constant KEY_GOVERNANCE =
        0x9409903de1e6fd852dfc61c9dacb48196c48535b60e25abf92acc92dd689078d;
    //keccak256("Staking");
    bytes32 internal constant KEY_STAKING =
        0x1df41cd916959d1163dc8f0671a666ea8a3e434c13e40faef527133b5d167034;
    //keccak256("ProxyAdmin");
    bytes32 internal constant KEY_PROXY_ADMIN =
        0x96ed0203eb7e975a4cbcaa23951943fa35c5d8288117d50c12b3d48b0fab48d1;

    // mStable
    // =======
    // keccak256("OracleHub");
    bytes32 internal constant KEY_ORACLE_HUB =
        0x8ae3a082c61a7379e2280f3356a5131507d9829d222d853bfa7c9fe1200dd040;
    // keccak256("Manager");
    bytes32 internal constant KEY_MANAGER =
        0x6d439300980e333f0256d64be2c9f67e86f4493ce25f82498d6db7f4be3d9e6f;
    //keccak256("Recollateraliser");
    bytes32 internal constant KEY_RECOLLATERALISER =
        0x39e3ed1fc335ce346a8cbe3e64dd525cf22b37f1e2104a755e761c3c1eb4734f;
    //keccak256("MetaToken");
    bytes32 internal constant KEY_META_TOKEN =
        0xea7469b14936af748ee93c53b2fe510b9928edbdccac3963321efca7eb1a57a2;
    // keccak256("SavingsManager");
    bytes32 internal constant KEY_SAVINGS_MANAGER =
        0x12fe936c77a1e196473c4314f3bed8eeac1d757b319abb85bdda70df35511bf1;
    // keccak256("Liquidator");
    bytes32 internal constant KEY_LIQUIDATOR =
        0x1e9cb14d7560734a61fa5ff9273953e971ff3cd9283c03d8346e3264617933d4;
    // keccak256("InterestValidator");
    bytes32 internal constant KEY_INTEREST_VALIDATOR =
        0xc10a28f028c7f7282a03c90608e38a4a646e136e614e4b07d119280c5f7f839f;
}



abstract contract ImmutableModule is ModuleKeys {
    INexus public immutable nexus;

    /**
     * @dev Initialization function for upgradable proxy contracts
     * @param _nexus Nexus contract address
     */
    constructor(address _nexus) {
        require(_nexus != address(0), "Nexus address is zero");
        nexus = INexus(_nexus);
    }

    /**
     * @dev Modifier to allow function calls only from the Governor.
     */
    modifier onlyGovernor() {
        _onlyGovernor();
        _;
    }

    function _onlyGovernor() internal view {
        require(msg.sender == _governor(), "Only governor can execute");
    }

    /**
     * @dev Modifier to allow function calls only from the Governance.
     *      Governance is either Governor address or Governance address.
     */
    modifier onlyGovernance() {
        require(
            msg.sender == _governor() || msg.sender == _governance(),
            "Only governance can execute"
        );
        _;
    }

    /**
     * @dev Modifier to allow function calls only from the ProxyAdmin.
     */
    modifier onlyProxyAdmin() {
        require(msg.sender == _proxyAdmin(), "Only ProxyAdmin can execute");
        _;
    }

    /**
     * @dev Modifier to allow function calls only from the Manager.
     */
    modifier onlyManager() {
        require(msg.sender == _manager(), "Only manager can execute");
        _;
    }

    /**
     * @dev Returns Governor address from the Nexus
     * @return Address of Governor Contract
     */
    function _governor() internal view returns (address) {
        return nexus.governor();
    }

    /**
     * @dev Returns Governance Module address from the Nexus
     * @return Address of the Governance (Phase 2)
     */
    function _governance() internal view returns (address) {
        return nexus.getModule(KEY_GOVERNANCE);
    }

    /**
     * @dev Return Staking Module address from the Nexus
     * @return Address of the Staking Module contract
     */
    function _staking() internal view returns (address) {
        return nexus.getModule(KEY_STAKING);
    }

    /**
     * @dev Return ProxyAdmin Module address from the Nexus
     * @return Address of the ProxyAdmin Module contract
     */
    function _proxyAdmin() internal view returns (address) {
        return nexus.getModule(KEY_PROXY_ADMIN);
    }

    /**
     * @dev Return MetaToken Module address from the Nexus
     * @return Address of the MetaToken Module contract
     */
    function _metaToken() internal view returns (address) {
        return nexus.getModule(KEY_META_TOKEN);
    }

    /**
     * @dev Return OracleHub Module address from the Nexus
     * @return Address of the OracleHub Module contract
     */
    function _oracleHub() internal view returns (address) {
        return nexus.getModule(KEY_ORACLE_HUB);
    }

    /**
     * @dev Return Manager Module address from the Nexus
     * @return Address of the Manager Module contract
     */
    function _manager() internal view returns (address) {
        return nexus.getModule(KEY_MANAGER);
    }

    /**
     * @dev Return SavingsManager Module address from the Nexus
     * @return Address of the SavingsManager Module contract
     */
    function _savingsManager() internal view returns (address) {
        return nexus.getModule(KEY_SAVINGS_MANAGER);
    }

    /**
     * @dev Return Recollateraliser Module address from the Nexus
     * @return  Address of the Recollateraliser Module contract (Phase 2)
     */
    function _recollateraliser() internal view returns (address) {
        return nexus.getModule(KEY_RECOLLATERALISER);
    }
}

abstract contract PausableModule is ImmutableModule {
    /**
     * @dev Emitted when the pause is triggered by Governor
     */
    event Paused(address account);

    /**
     * @dev Emitted when the pause is lifted by Governor
     */
    event Unpaused(address account);

    bool internal _paused = false;

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
     * @dev Initializes the contract in unpaused state.
     * Hooks into the Module to give the Governor ability to pause
     * @param _nexus Nexus contract address
     */
    constructor(address _nexus) ImmutableModule(_nexus) {
        _paused = false;
    }

    /**
     * @dev Returns true if the contract is paused, and false otherwise.
     * @return Returns `true` when paused, otherwise `false`
     */
    function paused() external view returns (bool) {
        return _paused;
    }

    /**
     * @dev Called by the Governor to pause, triggers stopped state.
     */
    function pause() external onlyGovernor whenNotPaused {
        _paused = true;
        emit Paused(msg.sender);
    }

    /**
     * @dev Called by Governor to unpause, returns to normal state.
     */
    function unpause() external onlyGovernor whenPaused {
        _paused = false;
        emit Unpaused(msg.sender);
    }
}

contract InitializableReentrancyGuard {
    bool private _notEntered;

    function _initializeReentrancyGuard() internal {
        // Storing an initial non-zero value makes deployment a bit more
        // expensive, but in exchange the refund on every call to nonReentrant
        // will be lower in amount. Since refunds are capped to a percetange of
        // the total transaction's gas, it is best to keep them low in cases
        // like this one, to increase the likelihood of the full refund coming
        // into effect.
        _notEntered = true;
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
        require(_notEntered, "ReentrancyGuard: reentrant call");

        // Any calls to nonReentrant after this point will fail
        _notEntered = false;

        _;

        // By storing the original value once again, a refund is triggered (see
        // https://eips.ethereum.org/EIPS/eip-2200)
        _notEntered = true;
    }
}





/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
 */
















// External
// Internal
// Libs
/**
 * @title   FeederPool
 * @author  mStable
 * @notice  Base contract for Feeder Pools (fPools). Feeder Pools are combined of 50/50 fAsset and mAsset. This supports
 *          efficient swaps into and out of mAssets and the bAssets in the mAsset basket (a.k.a mpAssets). There is 0
 *          fee to trade from fAsset into mAsset, providing low cost on-ramps into mAssets.
 * @dev     VERSION: 1.0
 *          DATE:    2021-03-01
 */
contract FeederPool is
    IFeederPool,
    Initializable,
    InitializableToken,
    PausableModule,
    InitializableReentrancyGuard
{
    using SafeERC20 for IERC20;
    using StableMath for uint256;

    // Forging Events
    event Minted(
        address indexed minter,
        address recipient,
        uint256 output,
        address input,
        uint256 inputQuantity
    );
    event MintedMulti(
        address indexed minter,
        address recipient,
        uint256 output,
        address[] inputs,
        uint256[] inputQuantities
    );
    event Swapped(
        address indexed swapper,
        address input,
        address output,
        uint256 outputAmount,
        uint256 fee,
        address recipient
    );
    event Redeemed(
        address indexed redeemer,
        address recipient,
        uint256 mAssetQuantity,
        address output,
        uint256 outputQuantity,
        uint256 scaledFee
    );
    event RedeemedMulti(
        address indexed redeemer,
        address recipient,
        uint256 mAssetQuantity,
        address[] outputs,
        uint256[] outputQuantity,
        uint256 scaledFee
    );
    // State Events
    event CacheSizeChanged(uint256 cacheSize);
    event FeesChanged(uint256 swapFee, uint256 redemptionFee, uint256 govFee);
    event WeightLimitsChanged(uint128 min, uint128 max);

    // FeederManager Events
    event BassetsMigrated(address[] bAssets, address newIntegrator);
    event StartRampA(uint256 currentA, uint256 targetA, uint256 startTime, uint256 rampEndTime);
    event StopRampA(uint256 currentA, uint256 time);

    // Constants
    uint256 private constant MAX_FEE = 1e16;
    uint256 private constant A_PRECISION = 100;
    address public immutable mAsset;

    // Core data storage
    FeederData public data;

    /**
     * @dev Constructor to set immutable bytecode
     * @param _nexus   Nexus address
     * @param _mAsset  Immutable mAsset address
     */
    constructor(address _nexus, address _mAsset) PausableModule(_nexus) {
        mAsset = _mAsset;
    }

    /**
     * @dev Basic initializer. Sets up core state and importantly provides infinite approvals to the mAsset pool
     * to support the cross pool swaps. bAssetData and bAssetPersonal are always ordered [mAsset, fAsset].
     * @param _nameArg     Name of the fPool token (a.k.a. fpToken)
     * @param _symbolArg   Symbol of the fPool token
     * @param _mAsset      Details on the base mAsset
     * @param _fAsset      Details on the attached fAsset
     * @param _mpAssets    Array of bAssets from the mAsset (to approve)
     * @param _config      Starting invariant config
     */
    function initialize(
        string calldata _nameArg,
        string calldata _symbolArg,
        BassetPersonal calldata _mAsset,
        BassetPersonal calldata _fAsset,
        address[] calldata _mpAssets,
        InvariantConfig memory _config
    ) public initializer {
        InitializableToken._initialize(_nameArg, _symbolArg);

        _initializeReentrancyGuard();

        require(_mAsset.addr == mAsset, "mAsset incorrect");
        data.bAssetPersonal.push(
            BassetPersonal(_mAsset.addr, _mAsset.integrator, false, BassetStatus.Normal)
        );
        data.bAssetData.push(BassetData(1e8, 0));
        data.bAssetPersonal.push(
            BassetPersonal(_fAsset.addr, _fAsset.integrator, _fAsset.hasTxFee, BassetStatus.Normal)
        );
        data.bAssetData.push(
            BassetData(SafeCast.toUint128(10**(26 - IBasicToken(_fAsset.addr).decimals())), 0)
        );
        for (uint256 i = 0; i < _mpAssets.length; i++) {
            // Call will fail if bAsset does not exist
            IMasset(_mAsset.addr).getBasset(_mpAssets[i]);
            IERC20(_mpAssets[i]).safeApprove(_mAsset.addr, 2**255);
        }

        uint64 startA = SafeCast.toUint64(_config.a * A_PRECISION);
        data.ampData = AmpData(startA, startA, 0, 0);
        data.weightLimits = _config.limits;

        data.swapFee = 4e14;
        data.redemptionFee = 1e15;
        data.cacheSize = 1e17;
        data.govFee = 0;
    }

    /**
     * @dev System will be halted during a recollateralisation event
     */
    modifier whenInOperation() {
        _isOperational();
        _;
    }

    // Internal fn for modifier to reduce deployment size
    function _isOperational() internal view {
        require(!_paused || msg.sender == _recollateraliser(), "Unhealthy");
    }

    /**
     * @dev Verifies that the caller is the Interest Validator contract
     */
    modifier onlyInterestValidator() {
        require(nexus.getModule(KEY_INTEREST_VALIDATOR) == msg.sender, "Only validator");
        _;
    }

    /***************************************
                    MINTING
    ****************************************/

    /**
     * @notice Mint fpTokens with a single bAsset. This contract must have approval to spend the senders bAsset.
     * Supports either fAsset, mAsset or mpAsset as input - with mpAssets used to mint mAsset before depositing.
     * @param _input                Address of the bAsset to deposit.
     * @param _inputQuantity        Quantity in input token units.
     * @param _minOutputQuantity    Minimum fpToken quantity to be minted. This protects against slippage.
     * @param _recipient            Receipient of the newly minted fpTokens
     * @return mintOutput           Quantity of fpToken minted from the deposited bAsset.
     */
    function mint(
        address _input,
        uint256 _inputQuantity,
        uint256 _minOutputQuantity,
        address _recipient
    ) external override nonReentrant whenInOperation returns (uint256 mintOutput) {
        require(_recipient != address(0), "Invalid recipient");
        require(_inputQuantity > 0, "Qty==0");

        Asset memory input = _getAsset(_input);

        mintOutput = FeederLogic.mint(
            data,
            _getConfig(),
            input,
            _inputQuantity,
            _minOutputQuantity
        );

        // Mint the fpToken
        _mint(_recipient, mintOutput);
        emit Minted(msg.sender, _recipient, mintOutput, _input, _inputQuantity);
    }

    /**
     * @notice Mint fpTokens with multiple bAssets. This contract must have approval to spend the senders bAssets.
     * Supports only fAsset or mAsset as inputs.
     * @param _inputs               Address of the bAssets to deposit.
     * @param _inputQuantities      Quantity in input token units.
     * @param _minOutputQuantity    Minimum fpToken quantity to be minted. This protects against slippage.
     * @param _recipient            Receipient of the newly minted fpTokens
     * @return mintOutput           Quantity of fpToken minted from the deposited bAssets.
     */
    function mintMulti(
        address[] calldata _inputs,
        uint256[] calldata _inputQuantities,
        uint256 _minOutputQuantity,
        address _recipient
    ) external override nonReentrant whenInOperation returns (uint256 mintOutput) {
        require(_recipient != address(0), "Invalid recipient");
        uint256 len = _inputQuantities.length;
        require(len > 0 && len == _inputs.length, "Input array mismatch");

        uint8[] memory indexes = _getAssets(_inputs);
        mintOutput = FeederLogic.mintMulti(
            data,
            _getConfig(),
            indexes,
            _inputQuantities,
            _minOutputQuantity
        );
        // Mint the fpToken
        _mint(_recipient, mintOutput);
        emit MintedMulti(msg.sender, _recipient, mintOutput, _inputs, _inputQuantities);
    }

    /**
     * @notice Get the projected output of a given mint.
     * @param _input             Address of the bAsset to deposit
     * @param _inputQuantity     Quantity in bAsset units
     * @return mintOutput        Estimated mint output in fpToken terms
     */
    function getMintOutput(address _input, uint256 _inputQuantity)
        external
        view
        override
        returns (uint256 mintOutput)
    {
        require(_inputQuantity > 0, "Qty==0");

        Asset memory input = _getAsset(_input);

        if (input.exists) {
            mintOutput = FeederLogic.computeMint(
                data.bAssetData,
                input.idx,
                _inputQuantity,
                _getConfig()
            );
        } else {
            uint256 estimatedMasset = IMasset(mAsset).getMintOutput(_input, _inputQuantity);
            mintOutput = FeederLogic.computeMint(data.bAssetData, 0, estimatedMasset, _getConfig());
        }
    }

    /**
     * @notice Get the projected output of a given mint
     * @param _inputs            Non-duplicate address array of addresses to bAssets to deposit for the minted mAsset tokens.
     * @param _inputQuantities   Quantity of each bAsset to deposit for the minted fpToken.
     * @return mintOutput        Estimated mint output in fpToken terms
     */
    function getMintMultiOutput(address[] calldata _inputs, uint256[] calldata _inputQuantities)
        external
        view
        override
        returns (uint256 mintOutput)
    {
        uint256 len = _inputQuantities.length;
        require(len > 0 && len == _inputs.length, "Input array mismatch");
        uint8[] memory indexes = _getAssets(_inputs);
        return
            FeederLogic.computeMintMulti(data.bAssetData, indexes, _inputQuantities, _getConfig());
    }

    /***************************************
                    SWAPPING
    ****************************************/

    /**
     * @notice Swaps two assets - either internally between fAsset<>mAsset, or between fAsset<>mpAsset by
     * first routing through the mAsset pool.
     * @param _input             Address of bAsset to deposit
     * @param _output            Address of bAsset to withdraw
     * @param _inputQuantity     Units of input bAsset to swap in
     * @param _minOutputQuantity Minimum quantity of the swap output asset. This protects against slippage
     * @param _recipient         Address to transfer output asset to
     * @return swapOutput        Quantity of output asset returned from swap
     */
    function swap(
        address _input,
        address _output,
        uint256 _inputQuantity,
        uint256 _minOutputQuantity,
        address _recipient
    ) external override nonReentrant whenInOperation returns (uint256 swapOutput) {
        require(_recipient != address(0), "Invalid recipient");
        require(_input != _output, "Invalid pair");
        require(_inputQuantity > 0, "Qty==0");

        Asset memory input = _getAsset(_input);
        Asset memory output = _getAsset(_output);
        require(_pathIsValid(input, output), "Invalid pair");

        uint256 localFee;
        (swapOutput, localFee) = FeederLogic.swap(
            data,
            _getConfig(),
            input,
            output,
            _inputQuantity,
            _minOutputQuantity,
            _recipient
        );

        uint256 govFee = data.govFee;
        if (govFee > 0) {
            data.pendingFees += ((localFee * govFee) / 1e18);
        }

        emit Swapped(msg.sender, input.addr, output.addr, swapOutput, localFee, _recipient);
    }

    /**
     * @notice Determines both if a trade is valid, and the expected fee or output.
     * Swap is valid if it does not result in the input asset exceeding its maximum weight.
     * @param _input             Address of bAsset to deposit
     * @param _output            Address of bAsset to receive
     * @param _inputQuantity     Units of input bAsset to swap
     * @return swapOutput        Quantity of output asset returned from swap
     */
    function getSwapOutput(
        address _input,
        address _output,
        uint256 _inputQuantity
    ) external view override returns (uint256 swapOutput) {
        require(_input != _output, "Invalid pair");
        require(_inputQuantity > 0, "Qty==0");

        Asset memory input = _getAsset(_input);
        Asset memory output = _getAsset(_output);
        require(_pathIsValid(input, output), "Invalid pair");

        // Internal swap between fAsset and mAsset
        if (input.exists && output.exists) {
            (swapOutput, ) = FeederLogic.computeSwap(
                data.bAssetData,
                input.idx,
                output.idx,
                _inputQuantity,
                output.idx == 0 ? 0 : data.swapFee,
                _getConfig()
            );
            return swapOutput;
        }

        // Swapping out of fAsset
        if (input.exists) {
            // Swap into mAsset > Redeem into mpAsset
            (swapOutput, ) = FeederLogic.computeSwap(
                data.bAssetData,
                1,
                0,
                _inputQuantity,
                0,
                _getConfig()
            );
            swapOutput = IMasset(mAsset).getRedeemOutput(_output, swapOutput);
        }
        // Else we are swapping into fAsset
        else {
            // Mint mAsset from mp > Swap into fAsset here
            swapOutput = IMasset(mAsset).getMintOutput(_input, _inputQuantity);
            (swapOutput, ) = FeederLogic.computeSwap(
                data.bAssetData,
                0,
                1,
                swapOutput,
                data.swapFee,
                _getConfig()
            );
        }
    }

    /**
     * @dev Checks if a given swap path is valid. Only fAsset<>mAsset & fAsset<>mpAsset swaps are supported.
     */
    function _pathIsValid(Asset memory _in, Asset memory _out)
        internal
        pure
        returns (bool isValid)
    {
        // mpAsset -> mpAsset
        if (!_in.exists && !_out.exists) return false;
        // f/mAsset -> f/mAsset
        if (_in.exists && _out.exists) return true;
        // fAsset -> mpAsset
        if (_in.exists && _in.idx == 1) return true;
        // mpAsset -> fAsset
        if (_out.exists && _out.idx == 1) return true;
        // Path is into or out of mAsset - just use main pool for this
        return false;
    }

    /***************************************
                    REDEMPTION
    ****************************************/

    /**
     * @notice Burns a specified quantity of the senders fpToken in return for a bAsset. The output amount is derived
     * from the invariant. Supports redemption into either the fAsset, mAsset or assets in the mAsset basket.
     * @param _output            Address of the bAsset to withdraw
     * @param _fpTokenQuantity   Quantity of LP Token to burn
     * @param _minOutputQuantity Minimum bAsset quantity to receive for the burnt fpToken. This protects against slippage.
     * @param _recipient         Address to transfer the withdrawn bAssets to.
     * @return outputQuantity    Quanity of bAsset units received for the burnt fpToken
     */
    function redeem(
        address _output,
        uint256 _fpTokenQuantity,
        uint256 _minOutputQuantity,
        address _recipient
    ) external override nonReentrant whenInOperation returns (uint256 outputQuantity) {
        require(_recipient != address(0), "Invalid recipient");
        require(_fpTokenQuantity > 0, "Qty==0");

        Asset memory output = _getAsset(_output);

        // Get config before burning. Config > Burn > CacheSize
        FeederConfig memory config = _getConfig();
        _burn(msg.sender, _fpTokenQuantity);

        uint256 localFee;
        (outputQuantity, localFee) = FeederLogic.redeem(
            data,
            config,
            output,
            _fpTokenQuantity,
            _minOutputQuantity,
            _recipient
        );

        uint256 govFee = data.govFee;
        if (govFee > 0) {
            data.pendingFees += ((localFee * govFee) / 1e18);
        }

        emit Redeemed(
            msg.sender,
            _recipient,
            _fpTokenQuantity,
            output.addr,
            outputQuantity,
            localFee
        );
    }

    /**
     * @dev Credits a recipient with a proportionate amount of bAssets, relative to current vault
     * balance levels and desired fpToken quantity. Burns the fpToken as payment. Only fAsset & mAsset are supported in this path.
     * @param _inputQuantity        Quantity of fpToken to redeem
     * @param _minOutputQuantities  Min units of output to receive
     * @param _recipient            Address to credit the withdrawn bAssets
     * @return outputQuantities     Array of output asset quantities
     */
    function redeemProportionately(
        uint256 _inputQuantity,
        uint256[] calldata _minOutputQuantities,
        address _recipient
    ) external override nonReentrant whenInOperation returns (uint256[] memory outputQuantities) {
        require(_recipient != address(0), "Invalid recipient");
        require(_inputQuantity > 0, "Qty==0");

        // Get config before burning. Burn > CacheSize
        FeederConfig memory config = _getConfig();
        _burn(msg.sender, _inputQuantity);

        address[] memory outputs;
        uint256 scaledFee;
        (scaledFee, outputs, outputQuantities) = FeederLogic.redeemProportionately(
            data,
            config,
            _inputQuantity,
            _minOutputQuantities,
            _recipient
        );

        uint256 govFee = data.govFee;
        if (govFee > 0) {
            data.pendingFees += ((scaledFee * govFee) / 1e18);
        }

        emit RedeemedMulti(
            msg.sender,
            _recipient,
            _inputQuantity,
            outputs,
            outputQuantities,
            scaledFee
        );
    }

    /**
     * @dev Credits a recipient with a certain quantity of selected bAssets, in exchange for burning the
     *      relative fpToken quantity from the sender. Only fAsset & mAsset (0,1) are supported in this path.
     * @param _outputs              Addresses of the bAssets to receive
     * @param _outputQuantities     Units of the bAssets to receive
     * @param _maxInputQuantity     Maximum fpToken quantity to burn for the received bAssets. This protects against slippage.
     * @param _recipient            Address to receive the withdrawn bAssets
     * @return fpTokenQuantity      Quantity of fpToken units burned as payment
     */
    function redeemExactBassets(
        address[] calldata _outputs,
        uint256[] calldata _outputQuantities,
        uint256 _maxInputQuantity,
        address _recipient
    ) external override nonReentrant whenInOperation returns (uint256 fpTokenQuantity) {
        require(_recipient != address(0), "Invalid recipient");
        uint256 len = _outputQuantities.length;
        require(len > 0 && len == _outputs.length, "Invalid array input");
        require(_maxInputQuantity > 0, "Qty==0");

        uint8[] memory indexes = _getAssets(_outputs);

        uint256 localFee;
        (fpTokenQuantity, localFee) = FeederLogic.redeemExactBassets(
            data,
            _getConfig(),
            indexes,
            _outputQuantities,
            _maxInputQuantity,
            _recipient
        );

        _burn(msg.sender, fpTokenQuantity);
        uint256 govFee = data.govFee;
        if (govFee > 0) {
            data.pendingFees += ((localFee * govFee) / 1e18);
        }

        emit RedeemedMulti(
            msg.sender,
            _recipient,
            fpTokenQuantity,
            _outputs,
            _outputQuantities,
            localFee
        );
    }

    /**
     * @notice Gets the estimated output from a given redeem
     * @param _output            Address of the bAsset to receive
     * @param _fpTokenQuantity   Quantity of fpToken to redeem
     * @return bAssetOutput      Estimated quantity of bAsset units received for the burnt fpTokens
     */
    function getRedeemOutput(address _output, uint256 _fpTokenQuantity)
        external
        view
        override
        returns (uint256 bAssetOutput)
    {
        require(_fpTokenQuantity > 0, "Qty==0");

        Asset memory output = _getAsset(_output);
        uint256 scaledFee = _fpTokenQuantity.mulTruncate(data.redemptionFee);

        bAssetOutput = FeederLogic.computeRedeem(
            data.bAssetData,
            output.exists ? output.idx : 0,
            _fpTokenQuantity - scaledFee,
            _getConfig()
        );
        // Extra step for mpAsset redemption
        if (!output.exists) {
            bAssetOutput = IMasset(mAsset).getRedeemOutput(output.addr, bAssetOutput);
        }
    }

    /**
     * @notice Gets the estimated output from a given redeem
     * @param _outputs           Addresses of the bAsset to receive
     * @param _outputQuantities  Quantities of bAsset to redeem
     * @return fpTokenQuantity   Estimated quantity of fpToken units needed to burn to receive output
     */
    function getRedeemExactBassetsOutput(
        address[] calldata _outputs,
        uint256[] calldata _outputQuantities
    ) external view override returns (uint256 fpTokenQuantity) {
        uint256 len = _outputQuantities.length;
        require(len > 0 && len == _outputs.length, "Invalid array input");

        uint8[] memory indexes = _getAssets(_outputs);

        uint256 mAssetRedeemed =
            FeederLogic.computeRedeemExact(
                data.bAssetData,
                indexes,
                _outputQuantities,
                _getConfig()
            );
        fpTokenQuantity = mAssetRedeemed.divPrecisely(1e18 - data.redemptionFee);
        if (fpTokenQuantity > 0) fpTokenQuantity += 1;
    }

    /***************************************
                    GETTERS
    ****************************************/

    /**
     * @notice Gets the price of the fpToken, and invariant value k
     * @return price    Price of an fpToken
     * @return k        Total value of basket, k
     */
    function getPrice() public view override returns (uint256 price, uint256 k) {
        return FeederLogic.computePrice(data.bAssetData, _getConfig());
    }

    /**
     * @notice Gets all config needed for general InvariantValidator calls
     */
    function getConfig() external view override returns (FeederConfig memory config) {
        return _getConfig();
    }

    /**
     * @notice Get data for a specific bAsset, if it exists
     * @param _bAsset     Address of bAsset
     * @return personal   Struct with personal data
     * @return vaultData  Struct with full bAsset data
     */
    function getBasset(address _bAsset)
        external
        view
        override
        returns (BassetPersonal memory personal, BassetData memory vaultData)
    {
        Asset memory asset = _getAsset(_bAsset);
        require(asset.exists, "Invalid asset");
        personal = data.bAssetPersonal[asset.idx];
        vaultData = data.bAssetData[asset.idx];
    }

    /**
     * @notice Get data for a all bAssets in basket
     * @return personal    Struct[] with full bAsset data
     * @return vaultData   Number of bAssets in the Basket
     */
    function getBassets()
        external
        view
        override
        returns (BassetPersonal[] memory, BassetData[] memory vaultData)
    {
        return (data.bAssetPersonal, data.bAssetData);
    }

    /***************************************
                GETTERS - INTERNAL
    ****************************************/

    /**
     * @dev Checks if a given asset exists in basket and return the index.
     * @return status    Data containing address, index and whether it exists in basket
     */
    function _getAsset(address _asset) internal view returns (Asset memory status) {
        // if input is mAsset then we know the position
        if (_asset == mAsset) return Asset(0, _asset, true);

        // else it exists if the position 1 is _asset
        return Asset(1, _asset, data.bAssetPersonal[1].addr == _asset);
    }

    /**
     * @dev Validates an array of input assets and returns their indexes. Assets must exist
     * in order to be valid, as mintMulti and redeemMulti do not support external bAssets.
     */
    function _getAssets(address[] memory _assets) internal view returns (uint8[] memory indexes) {
        uint256 len = _assets.length;

        indexes = new uint8[](len);

        Asset memory input_;
        for (uint256 i = 0; i < len; i++) {
            input_ = _getAsset(_assets[i]);
            indexes[i] = input_.idx;
            require(input_.exists, "Invalid asset");

            for (uint256 j = i + 1; j < len; j++) {
                require(_assets[i] != _assets[j], "Duplicate asset");
            }
        }
    }

    /**
     * @dev Gets all config needed for general InvariantValidator calls
     */
    function _getConfig() internal view returns (FeederConfig memory) {
        return FeederConfig(totalSupply() + data.pendingFees, _getA(), data.weightLimits);
    }

    /**
     * @dev Gets current amplification var A
     */
    function _getA() internal view returns (uint256) {
        AmpData memory ampData_ = data.ampData;

        uint64 endA = ampData_.targetA;
        uint64 endTime = ampData_.rampEndTime;

        // If still changing, work out based on current timestmap
        if (block.timestamp < endTime) {
            uint64 startA = ampData_.initialA;
            uint64 startTime = ampData_.rampStartTime;

            (uint256 elapsed, uint256 total) = (block.timestamp - startTime, endTime - startTime);

            if (endA > startA) {
                return startA + (((endA - startA) * elapsed) / total);
            } else {
                return startA - (((startA - endA) * elapsed) / total);
            }
        }
        // Else return final value
        else {
            return endA;
        }
    }

    /***************************************
                    YIELD
    ****************************************/

    /**
     * @dev Collects the interest generated from the lending markets, performing a theoretical mint, which
     * is then validated by the interest validator to protect against accidental hyper inflation.
     * @return mintAmount   fpToken units generated from interest collected from lending markets
     * @return newSupply    fpToken total supply after mint
     */
    function collectPlatformInterest()
        external
        override
        onlyInterestValidator
        whenInOperation
        nonReentrant
        returns (uint256 mintAmount, uint256 newSupply)
    {
        (uint8[] memory idxs, uint256[] memory gains) =
            FeederManager.calculatePlatformInterest(data.bAssetPersonal, data.bAssetData);
        // Calculate potential mint amount. This will be validated by the interest validator
        mintAmount = FeederLogic.computeMintMulti(data.bAssetData, idxs, gains, _getConfig());
        newSupply = totalSupply() + data.pendingFees + mintAmount;

        uint256 govFee = data.govFee;
        if (govFee > 0) {
            data.pendingFees += ((mintAmount * govFee) / 1e18);
        }

        // Dummy mint event to catch the collections here
        emit MintedMulti(address(this), msg.sender, 0, new address[](0), gains);
    }

    /**
     * @dev Collects the pending gov fees extracted from swap, redeem and platform interest.
     */
    function collectPendingFees() external onlyInterestValidator {
        uint256 fees = data.pendingFees;
        if (fees > 1) {
            uint256 mintAmount = fees - 1;
            data.pendingFees = 1;

            _mint(msg.sender, mintAmount);
            emit MintedMulti(
                address(this),
                msg.sender,
                mintAmount,
                new address[](0),
                new uint256[](0)
            );
        }
    }

    /***************************************
                    STATE
    ****************************************/

    /**
     * @dev Sets the MAX cache size for each bAsset. The cache will actually revolve around
     *      _cacheSize * totalSupply / 2 under normal circumstances.
     * @param _cacheSize Maximum percent of total fpToken supply to hold for each bAsset
     */
    function setCacheSize(uint256 _cacheSize) external onlyGovernor {
        require(_cacheSize <= 2e17, "Must be <= 20%");

        data.cacheSize = _cacheSize;

        emit CacheSizeChanged(_cacheSize);
    }

    /**
     * @dev Set the ecosystem fee for sewapping bAssets or redeeming specific bAssets
     * @param _swapFee       Fee calculated in (%/100 * 1e18)
     * @param _redemptionFee Fee calculated in (%/100 * 1e18)
     * @param _govFee        Fee calculated in (%/100 * 1e18)
     */
    function setFees(
        uint256 _swapFee,
        uint256 _redemptionFee,
        uint256 _govFee
    ) external onlyGovernor {
        require(_swapFee <= MAX_FEE, "Swap rate oob");
        require(_redemptionFee <= MAX_FEE, "Redemption rate oob");
        require(_govFee <= 5e17, "Gov fee rate oob");

        data.swapFee = _swapFee;
        data.redemptionFee = _redemptionFee;
        data.govFee = _govFee;

        emit FeesChanged(_swapFee, _redemptionFee, _govFee);
    }

    /**
     * @dev Set the maximum weight across all bAssets
     * @param _min Weight where 100% = 1e18
     * @param _max Weight where 100% = 1e18
     */
    function setWeightLimits(uint128 _min, uint128 _max) external onlyGovernor {
        require(_min <= 3e17 && _max >= 7e17, "Weights oob");

        data.weightLimits = WeightLimits(_min, _max);

        emit WeightLimitsChanged(_min, _max);
    }

    /**
     * @dev Transfers all collateral from one lending market to another - used initially
     *      to handle the migration between Aave V1 and Aave V2. Note - only supports non
     *      tx fee enabled assets. Supports going from no integration to integration, but
     *      not the other way around.
     * @param _bAssets Array of basket assets to migrate
     * @param _newIntegration Address of the new platform integration
     */
    function migrateBassets(address[] calldata _bAssets, address _newIntegration)
        external
        onlyGovernor
    {
        FeederManager.migrateBassets(data.bAssetPersonal, _bAssets, _newIntegration);
    }

    /**
     * @dev Starts changing of the amplification var A
     * @param _targetA      Target A value
     * @param _rampEndTime  Time at which A will arrive at _targetA
     */
    function startRampA(uint256 _targetA, uint256 _rampEndTime) external onlyGovernor {
        FeederManager.startRampA(data.ampData, _targetA, _rampEndTime, _getA(), A_PRECISION);
    }

    /**
     * @dev Stops the changing of the amplification var A, setting
     * it to whatever the current value is.
     */
    function stopRampA() external onlyGovernor {
        FeederManager.stopRampA(data.ampData, _getA());
    }
}