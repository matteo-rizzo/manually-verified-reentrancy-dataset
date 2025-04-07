/**
 *Submitted for verification at Etherscan.io on 2021-03-15
*/

// SPDX-License-Identifier: AGPL-3.0-or-later

pragma solidity 0.8.0;
pragma abicoder v2;




abstract contract IInvariantValidator is MassetStructs {
    // Mint
    function computeMint(
        BassetData[] calldata _bAssets,
        uint8 _i,
        uint256 _rawInput,
        InvariantConfig memory _config
    ) external view virtual returns (uint256);

    function computeMintMulti(
        BassetData[] calldata _bAssets,
        uint8[] calldata _indices,
        uint256[] calldata _rawInputs,
        InvariantConfig memory _config
    ) external view virtual returns (uint256);

    // Swap
    function computeSwap(
        BassetData[] calldata _bAssets,
        uint8 _i,
        uint8 _o,
        uint256 _rawInput,
        uint256 _feeRate,
        InvariantConfig memory _config
    ) external view virtual returns (uint256, uint256);

    // Redeem
    function computeRedeem(
        BassetData[] calldata _bAssets,
        uint8 _i,
        uint256 _mAssetQuantity,
        InvariantConfig memory _config
    ) external view virtual returns (uint256);

    function computeRedeemExact(
        BassetData[] calldata _bAssets,
        uint8[] calldata _indices,
        uint256[] calldata _rawOutputs,
        InvariantConfig memory _config
    ) external view virtual returns (uint256);
}

contract Initializable {

  /**
   * @dev Indicates that the contract has been initialized.
   */
  bool private initialized;

  /**
   * @dev Indicates that the contract is in the process of being initialized.
   */
  bool private initializing;

  /**
   * @dev Modifier to use in the initializer function of a contract.
   */
  modifier initializer() {
    require(initializing || isConstructor() || !initialized, "Contract instance has already been initialized");

    bool isTopLevelCall = !initializing;
    if (isTopLevelCall) {
      initializing = true;
      initialized = true;
    }

    _;

    if (isTopLevelCall) {
      initializing = false;
    }
  }

  /// @dev Returns true if and only if the function is running in the constructor
  function isConstructor() private view returns (bool) {
    // extcodesize checks the size of the code stored in an address, and
    // address returns the current address. Since the code is still not
    // deployed when running a constructor, any checks on its code size will
    // yield zero, making it an effective way to detect if a contract is
    // under construction or not.
    address self = address(this);
    uint256 cs;
    assembly { cs := extcodesize(self) }
    return cs == 0;
  }

  // Reserved storage space to allow for layout changes in the future.
  uint256[50] private ______gap;
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

abstract contract IMasset is MassetStructs {
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

abstract contract Deprecated_BasketManager is MassetStructs {}









/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
 */

/**
 * @dev Collection of functions related to the address type
 */








struct Basket {
    Basset[] bassets;
    uint8 maxBassets;
    bool undergoingRecol;
    bool failed;
    uint256 collateralisationRatio;

}



struct Basset {
    address addr;
    BassetStatus status;
    bool isTransferFeeCharged;
    uint256 ratio;
    uint256 maxWeight;
    uint256 vaultBalance;

}



/**
 * @notice  Is the Masset V2.0 structs used in the upgrade of mUSD from V2.0 to V3.0.
 * @author  mStable
 * @dev     VERSION: 2.0
 *          DATE:    2021-02-23
 */
/** @dev Stores high level basket info */
/** @dev Stores bAsset info. The struct takes 5 storage slots per Basset */
/** @dev Status of the Basset - has it broken its peg? */
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

/** @dev Internal details on Basset */
struct BassetDetails {
    Basset bAsset;
    address integrator;
    uint8 index;
}

contract InitializableModuleKeysV2 {
    // Governance                             // Phases
    bytes32 private KEY_GOVERNANCE_DEPRICATED;          // 2.x
    bytes32 private KEY_STAKING_DEPRICATED;             // 1.2
    bytes32 private KEY_PROXY_ADMIN_DEPRICATED;         // 1.0

    // mStable
    bytes32 private KEY_ORACLE_HUB_DEPRICATED;          // 1.2
    bytes32 private KEY_MANAGER_DEPRICATED;             // 1.2
    bytes32 private KEY_RECOLLATERALISER_DEPRICATED;    // 2.x
    bytes32 private KEY_META_TOKEN_DEPRICATED;          // 1.1
    bytes32 private KEY_SAVINGS_MANAGER_DEPRICATED;     // 1.0
}

contract InitializableModuleV2 is InitializableModuleKeysV2 {
    address private nexus_depricated;
}

// External
// Internal
// Libs
// Legacy
/**
 * @title   Masset used to migrate mUSD from V2.0 to V3.0
 * @author  mStable
 * @notice  An incentivised constant sum market maker with hard limits at max region. This supports
 *          low slippage swaps and applies penalties towards min and max regions. AMM produces a
 *          stablecoin (mAsset) and redirects lending market interest and swap fees to the savings
 *          contract, producing a second yield bearing asset.
 * @dev     VERSION: 3.0
 *          DATE:    2021-01-22
 */
contract MusdV3 is
    IMasset,
    Initializable,
    InitializableToken,
    InitializableModuleV2,
    InitializableReentrancyGuard,
    ImmutableModule
{
    using StableMath for uint256;

    // Forging Events
    event Minted(
        address indexed minter,
        address recipient,
        uint256 mAssetQuantity,
        address input,
        uint256 inputQuantity
    );
    event MintedMulti(
        address indexed minter,
        address recipient,
        uint256 mAssetQuantity,
        address[] inputs,
        uint256[] inputQuantities
    );
    event Swapped(
        address indexed swapper,
        address input,
        address output,
        uint256 outputAmount,
        uint256 scaledFee,
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
    event FeesChanged(uint256 swapFee, uint256 redemptionFee);
    event WeightLimitsChanged(uint128 min, uint128 max);
    event ForgeValidatorChanged(address forgeValidator);

    // Release 1.0 VARS
    IInvariantValidator public forgeValidator;
    bool private forgeValidatorLocked;
    // Deprecated - maintain for storage layout in mUSD
    address private deprecated_basketManager;

    // Basic redemption fee information
    uint256 public swapFee;
    uint256 private MAX_FEE;

    // Release 1.1 VARS
    uint256 public redemptionFee;

    // Release 2.0 VARS
    uint256 public cacheSize;
    uint256 public surplus;

    // Release 3.0 VARS
    // Struct holding Basket details
    BassetPersonal[] public bAssetPersonal;
    BassetData[] public bAssetData;
    mapping(address => uint8) public override bAssetIndexes;
    uint8 public maxBassets;
    BasketState public basket;
    // Amplification Data
    uint256 private constant A_PRECISION = 100;
    AmpData public ampData;
    WeightLimits public weightLimits;

    /**
     * @dev Constructor to set immutable bytecode
     * @param _nexus   Nexus address
     */
    constructor(address _nexus) ImmutableModule(_nexus) {}

    /**
     * @dev Upgrades mUSD from v2.0 to v3.0.
     *      This function should be called via Proxy just after the proxy has been updated.
     * @param _forgeValidator  Address of the AMM implementation
     * @param _config          Configutation for the invariant validator including the
     *                         amplification coefficient (A) and weight limits
     */
    function upgrade(
        address _forgeValidator,
        InvariantConfig memory _config
    ) public {
        // prevent upgrade being run again by checking the old basket manager
        require(deprecated_basketManager != address(0), "already upgraded");
        // Read the Basket Manager details from the mUSD proxy's storage into memory
        IBasketManager basketManager = IBasketManager(deprecated_basketManager);
        // Update the storage of the Basket Manager in the mUSD Proxy
        deprecated_basketManager = address(0);
        // Set the state to be undergoingRecol in order to pause after upgrade
        basket.undergoingRecol = true;

        forgeValidator = IInvariantValidator(_forgeValidator);

        Migrator.upgrade(basketManager, bAssetPersonal, bAssetData, bAssetIndexes);

        // Set new V3.0 storage variables
        maxBassets = 10;
        uint64 startA = SafeCast.toUint64(_config.a * A_PRECISION);
        ampData = AmpData(startA, startA, 0, 0);
        weightLimits = _config.limits;
    }

    /**
     * @dev Verifies that the caller is the Savings Manager contract
     */
    modifier onlySavingsManager() {
        _isSavingsManager();
        _;
    }

    // Internal fn for modifier to reduce deployment size
    function _isSavingsManager() internal view {
        require(_savingsManager() == msg.sender, "Must be savings manager");
    }

    /**
     * @dev Requires the overall basket composition to be healthy
     */
    modifier whenHealthy() {
        _isHealthy();
        _;
    }

    // Internal fn for modifier to reduce deployment size
    function _isHealthy() internal view {
        BasketState memory basket_ = basket;
        require(!basket_.undergoingRecol && !basket_.failed, "Unhealthy");
    }

    /**
     * @dev Requires the basket not to be undergoing recollateralisation
     */
    modifier whenNoRecol() {
        _noRecol();
        _;
    }

    // Internal fn for modifier to reduce deployment size
    function _noRecol() internal view {
        BasketState memory basket_ = basket;
        require(!basket_.undergoingRecol, "In recol");
    }

    /***************************************
                MINTING (PUBLIC)
    ****************************************/

    /**
     * @dev Mint a single bAsset, at a 1:1 ratio with the bAsset. This contract
     *      must have approval to spend the senders bAsset
     * @param _input             Address of the bAsset to deposit for the minted mAsset.
     * @param _inputQuantity     Quantity in bAsset units
     * @param _minOutputQuantity Minimum mAsset quanity to be minted. This protects against slippage.
     * @param _recipient         Receipient of the newly minted mAsset tokens
     * @return mintOutput        Quantity of newly minted mAssets for the deposited bAsset.
     */
    function mint(
        address _input,
        uint256 _inputQuantity,
        uint256 _minOutputQuantity,
        address _recipient
    ) external override nonReentrant whenHealthy returns (uint256 mintOutput) {
        mintOutput = _mintTo(_input, _inputQuantity, _minOutputQuantity, _recipient);
    }

    /**
     * @dev Mint with multiple bAssets, at a 1:1 ratio to mAsset. This contract
     *      must have approval to spend the senders bAssets
     * @param _inputs            Non-duplicate address array of bASset addresses to deposit for the minted mAsset tokens.
     * @param _inputQuantities   Quantity of each bAsset to deposit for the minted mAsset.
     *                           Order of array should mirror the above bAsset addresses.
     * @param _minOutputQuantity Minimum mAsset quanity to be minted. This protects against slippage.
     * @param _recipient         Address to receive the newly minted mAsset tokens
     * @return mintOutput    Quantity of newly minted mAssets for the deposited bAssets.
     */
    function mintMulti(
        address[] calldata _inputs,
        uint256[] calldata _inputQuantities,
        uint256 _minOutputQuantity,
        address _recipient
    ) external override nonReentrant whenHealthy returns (uint256 mintOutput) {
        mintOutput = _mintMulti(_inputs, _inputQuantities, _minOutputQuantity, _recipient);
    }

    /**
     * @dev Get the projected output of a given mint
     * @param _input             Address of the bAsset to deposit for the minted mAsset
     * @param _inputQuantity     Quantity in bAsset units
     * @return mintOutput        Estimated mint output in mAsset terms
     */
    function getMintOutput(address _input, uint256 _inputQuantity)
        external
        view
        override
        returns (uint256 mintOutput)
    {
        require(_inputQuantity > 0, "Qty==0");

        (uint8 idx, ) = _getAsset(_input);

        mintOutput = forgeValidator.computeMint(bAssetData, idx, _inputQuantity, _getConfig());
    }

    /**
     * @dev Get the projected output of a given mint
     * @param _inputs            Non-duplicate address array of addresses to bAssets to deposit for the minted mAsset tokens.
     * @param _inputQuantities  Quantity of each bAsset to deposit for the minted mAsset.
     * @return mintOutput        Estimated mint output in mAsset terms
     */
    function getMintMultiOutput(address[] calldata _inputs, uint256[] calldata _inputQuantities)
        external
        view
        override
        returns (uint256 mintOutput)
    {
        uint256 len = _inputQuantities.length;
        require(len > 0 && len == _inputs.length, "Input array mismatch");
        (uint8[] memory indexes, ) = _getBassets(_inputs);
        return forgeValidator.computeMintMulti(bAssetData, indexes, _inputQuantities, _getConfig());
    }

    /***************************************
              MINTING (INTERNAL)
    ****************************************/

    /** @dev Mint Single */
    function _mintTo(
        address _input,
        uint256 _inputQuantity,
        uint256 _minMassetQuantity,
        address _recipient
    ) internal returns (uint256 mAssetMinted) {
        require(_recipient != address(0), "Invalid recipient");
        require(_inputQuantity > 0, "Qty==0");
        BassetData[] memory allBassets = bAssetData;
        (uint8 bAssetIndex, BassetPersonal memory personal) = _getAsset(_input);
        Cache memory cache = _getCacheDetails();
        // Transfer collateral to the platform integration address and call deposit
        uint256 quantityDeposited =
            Manager.depositTokens(
                personal,
                allBassets[bAssetIndex].ratio,
                _inputQuantity,
                cache.maxCache
            );
        // Validation should be after token transfer, as bAssetQty is unknown before
        mAssetMinted = forgeValidator.computeMint(
            allBassets,
            bAssetIndex,
            quantityDeposited,
            _getConfig()
        );
        require(mAssetMinted >= _minMassetQuantity, "Mint quantity < min qty");
        // Log the Vault increase - can only be done when basket is healthy
        bAssetData[bAssetIndex].vaultBalance =
            allBassets[bAssetIndex].vaultBalance +
            SafeCast.toUint128(quantityDeposited);
        // Mint the Masset
        _mint(_recipient, mAssetMinted);
        emit Minted(msg.sender, _recipient, mAssetMinted, _input, quantityDeposited);
    }

    /** @dev Mint Multi */
    function _mintMulti(
        address[] memory _inputs,
        uint256[] memory _inputQuantities,
        uint256 _minMassetQuantity,
        address _recipient
    ) internal returns (uint256 mAssetMinted) {
        require(_recipient != address(0), "Invalid recipient");
        uint256 len = _inputQuantities.length;
        require(len > 0 && len == _inputs.length, "Input array mismatch");
        // Load bAssets from storage into memory
        (uint8[] memory indexes, BassetPersonal[] memory personals) = _getBassets(_inputs);
        BassetData[] memory allBassets = bAssetData;
        Cache memory cache = _getCacheDetails();
        uint256[] memory quantitiesDeposited = new uint256[](len);
        // Transfer the Bassets to the integrator, update storage and calc MassetQ
        for (uint256 i = 0; i < len; i++) {
            uint256 bAssetQuantity = _inputQuantities[i];
            if (bAssetQuantity > 0) {
                uint8 idx = indexes[i];
                BassetData memory data = allBassets[idx];
                BassetPersonal memory personal = personals[i];
                uint256 quantityDeposited =
                    Manager.depositTokens(personal, data.ratio, bAssetQuantity, cache.maxCache);
                quantitiesDeposited[i] = quantityDeposited;
                bAssetData[idx].vaultBalance =
                    data.vaultBalance +
                    SafeCast.toUint128(quantityDeposited);
            }
        }
        // Validate the proposed mint, after token transfer
        mAssetMinted = forgeValidator.computeMintMulti(
            allBassets,
            indexes,
            quantitiesDeposited,
            _getConfig()
        );
        require(mAssetMinted >= _minMassetQuantity, "Mint quantity < min qty");
        require(mAssetMinted > 0, "Zero mAsset quantity");

        // Mint the Masset
        _mint(_recipient, mAssetMinted);
        emit MintedMulti(msg.sender, _recipient, mAssetMinted, _inputs, _inputQuantities);
    }

    /***************************************
                SWAP (PUBLIC)
    ****************************************/

    /**
     * @dev Swaps one bAsset for another bAsset using the bAsset addresses.
     * bAsset <> bAsset swaps will incur a small fee (swapFee()).
     * @param _input             Address of bAsset to deposit
     * @param _output            Address of bAsset to receive
     * @param _inputQuantity     Units of input bAsset to swap
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
    ) external override nonReentrant whenHealthy returns (uint256 swapOutput) {
        swapOutput = _swap(_input, _output, _inputQuantity, _minOutputQuantity, _recipient);
    }

    /**
     * @dev Determines both if a trade is valid, and the expected fee or output.
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
        require(_inputQuantity > 0, "Invalid swap quantity");

        // 1. Load the bAssets from storage into memory
        BassetData[] memory allBassets = bAssetData;
        (uint8 inputIdx, ) = _getAsset(_input);
        (uint8 outputIdx, ) = _getAsset(_output);

        // 2. If a bAsset swap, calculate the validity, output and fee
        (swapOutput, ) = forgeValidator.computeSwap(
            allBassets,
            inputIdx,
            outputIdx,
            _inputQuantity,
            swapFee,
            _getConfig()
        );
    }

    /***************************************
              SWAP (INTERNAL)
    ****************************************/

    /** @dev Swap single */
    function _swap(
        address _input,
        address _output,
        uint256 _inputQuantity,
        uint256 _minOutputQuantity,
        address _recipient
    ) internal returns (uint256 swapOutput) {
        require(_recipient != address(0), "Invalid recipient");
        require(_input != _output, "Invalid pair");
        require(_inputQuantity > 0, "Invalid swap quantity");

        // 1. Load the bAssets from storage into memory
        BassetData[] memory allBassets = bAssetData;
        (uint8 inputIdx, BassetPersonal memory inputPersonal) = _getAsset(_input);
        (uint8 outputIdx, BassetPersonal memory outputPersonal) = _getAsset(_output);
        // 2. Load cache
        Cache memory cache = _getCacheDetails();
        // 3. Deposit the input tokens
        uint256 quantityDeposited =
            Manager.depositTokens(
                inputPersonal,
                allBassets[inputIdx].ratio,
                _inputQuantity,
                cache.maxCache
            );
        // 3.1. Update the input balance
        bAssetData[inputIdx].vaultBalance =
            allBassets[inputIdx].vaultBalance +
            SafeCast.toUint128(quantityDeposited);

        // 3. Validate the swap
        uint256 scaledFee;
        (swapOutput, scaledFee) = forgeValidator.computeSwap(
            allBassets,
            inputIdx,
            outputIdx,
            quantityDeposited,
            swapFee,
            _getConfig()
        );
        require(swapOutput >= _minOutputQuantity, "Output qty < minimum qty");
        require(swapOutput > 0, "Zero output quantity");
        //4. Settle the swap
        //4.1. Decrease output bal
        Manager.withdrawTokens(
            swapOutput,
            outputPersonal,
            allBassets[outputIdx],
            _recipient,
            cache.maxCache
        );
        bAssetData[outputIdx].vaultBalance =
            allBassets[outputIdx].vaultBalance -
            SafeCast.toUint128(swapOutput);
        // Save new surplus to storage
        surplus = cache.surplus + scaledFee;
        emit Swapped(
            msg.sender,
            inputPersonal.addr,
            outputPersonal.addr,
            swapOutput,
            scaledFee,
            _recipient
        );
    }

    /***************************************
                REDEMPTION (PUBLIC)
    ****************************************/

    /**
     * @notice Redeems a specified quantity of mAsset in return for a bAsset specified by bAsset address.
     * The bAsset is sent to the specified recipient.
     * The bAsset quantity is relative to current vault balance levels and desired mAsset quantity.
     * The quantity of mAsset is burnt as payment.
     * A minimum quantity of bAsset is specified to protect against price slippage between the mAsset and bAsset.
     * @param _output            Address of the bAsset to receive
     * @param _mAssetQuantity    Quantity of mAsset to redeem
     * @param _minOutputQuantity Minimum bAsset quantity to receive for the burnt mAssets. This protects against slippage.
     * @param _recipient         Address to transfer the withdrawn bAssets to.
     * @return outputQuantity    Quanity of bAsset units received for the burnt mAssets
     */
    function redeem(
        address _output,
        uint256 _mAssetQuantity,
        uint256 _minOutputQuantity,
        address _recipient
    ) external override nonReentrant whenNoRecol returns (uint256 outputQuantity) {
        outputQuantity = _redeem(_output, _mAssetQuantity, _minOutputQuantity, _recipient);
    }

    /**
     * @dev Credits a recipient with a proportionate amount of bAssets, relative to current vault
     * balance levels and desired mAsset quantity. Burns the mAsset as payment.
     * @param _mAssetQuantity       Quantity of mAsset to redeem
     * @param _minOutputQuantities  Min units of output to receive
     * @param _recipient            Address to credit the withdrawn bAssets
     */
    function redeemMasset(
        uint256 _mAssetQuantity,
        uint256[] calldata _minOutputQuantities,
        address _recipient
    ) external override nonReentrant whenNoRecol returns (uint256[] memory outputQuantities) {
        outputQuantities = _redeemMasset(_mAssetQuantity, _minOutputQuantities, _recipient);
    }

    /**
     * @dev Credits a recipient with a certain quantity of selected bAssets, in exchange for burning the
     *      relative Masset quantity from the sender. Sender also incurs a small fee on the outgoing asset.
     * @param _outputs           Addresses of the bAssets to receive
     * @param _outputQuantities  Units of the bAssets to redeem
     * @param _maxMassetQuantity Maximum mAsset quantity to burn for the received bAssets. This protects against slippage.
     * @param _recipient         Address to receive the withdrawn bAssets
     * @return mAssetQuantity    Quantity of mAsset units burned plus the swap fee to pay for the redeemed bAssets
     */
    function redeemExactBassets(
        address[] calldata _outputs,
        uint256[] calldata _outputQuantities,
        uint256 _maxMassetQuantity,
        address _recipient
    ) external override nonReentrant whenNoRecol returns (uint256 mAssetQuantity) {
        mAssetQuantity = _redeemExactBassets(
            _outputs,
            _outputQuantities,
            _maxMassetQuantity,
            _recipient
        );
    }

    /**
     * @notice Gets the estimated output from a given redeem
     * @param _output            Address of the bAsset to receive
     * @param _mAssetQuantity    Quantity of mAsset to redeem
     * @return bAssetOutput      Estimated quantity of bAsset units received for the burnt mAssets
     */
    function getRedeemOutput(address _output, uint256 _mAssetQuantity)
        external
        view
        override
        returns (uint256 bAssetOutput)
    {
        require(_mAssetQuantity > 0, "Qty==0");

        (uint8 idx, ) = _getAsset(_output);

        uint256 scaledFee = _mAssetQuantity.mulTruncate(swapFee);
        bAssetOutput = forgeValidator.computeRedeem(
            bAssetData,
            idx,
            _mAssetQuantity - scaledFee,
            _getConfig()
        );
    }

    /**
     * @notice Gets the estimated output from a given redeem
     * @param _outputs           Addresses of the bAsset to receive
     * @param _outputQuantities  Quantities of bAsset to redeem
     * @return mAssetQuantity    Estimated quantity of mAsset units needed to burn to receive output
     */
    function getRedeemExactBassetsOutput(
        address[] calldata _outputs,
        uint256[] calldata _outputQuantities
    ) external view override returns (uint256 mAssetQuantity) {
        uint256 len = _outputQuantities.length;
        require(len > 0 && len == _outputs.length, "Invalid array input");

        (uint8[] memory indexes, ) = _getBassets(_outputs);

        // calculate the value of mAssets need to cover the value of bAssets being redeemed
        uint256 mAssetRedeemed =
            forgeValidator.computeRedeemExact(bAssetData, indexes, _outputQuantities, _getConfig());
        mAssetQuantity = mAssetRedeemed.divPrecisely(1e18 - swapFee) + 1;
    }

    /***************************************
                REDEMPTION (INTERNAL)
    ****************************************/

    /**
     * @dev Redeem mAsset for a single bAsset
     */
    function _redeem(
        address _output,
        uint256 _inputQuantity,
        uint256 _minOutputQuantity,
        address _recipient
    ) internal returns (uint256 bAssetQuantity) {
        require(_recipient != address(0), "Invalid recipient");
        require(_inputQuantity > 0, "Qty==0");

        // Load the bAsset data from storage into memory
        BassetData[] memory allBassets = bAssetData;
        (uint8 bAssetIndex, BassetPersonal memory personal) = _getAsset(_output);
        // Calculate redemption quantities
        uint256 scaledFee = _inputQuantity.mulTruncate(swapFee);
        bAssetQuantity = forgeValidator.computeRedeem(
            allBassets,
            bAssetIndex,
            _inputQuantity - scaledFee,
            _getConfig()
        );
        require(bAssetQuantity >= _minOutputQuantity, "bAsset qty < min qty");
        require(bAssetQuantity > 0, "Output == 0");
        // Apply fees, burn mAsset and return bAsset to recipient
        // 1.0. Burn the full amount of Masset
        _burn(msg.sender, _inputQuantity);
        surplus += scaledFee;
        Cache memory cache = _getCacheDetails();
        // 2.0. Transfer the Bassets to the recipient
        Manager.withdrawTokens(
            bAssetQuantity,
            personal,
            allBassets[bAssetIndex],
            _recipient,
            cache.maxCache
        );
        // 3.0. Set vault balance
        bAssetData[bAssetIndex].vaultBalance =
            allBassets[bAssetIndex].vaultBalance -
            SafeCast.toUint128(bAssetQuantity);

        emit Redeemed(
            msg.sender,
            _recipient,
            _inputQuantity,
            personal.addr,
            bAssetQuantity,
            scaledFee
        );
    }

    /**
     * @dev Redeem mAsset for proportional amount of bAssets
     */
    function _redeemMasset(
        uint256 _inputQuantity,
        uint256[] calldata _minOutputQuantities,
        address _recipient
    ) internal returns (uint256[] memory outputQuantities) {
        require(_recipient != address(0), "Invalid recipient");
        require(_inputQuantity > 0, "Qty==0");

        // Calculate mAsset redemption quantities
        uint256 scaledFee = _inputQuantity.mulTruncate(redemptionFee);
        uint256 mAssetRedemptionAmount = _inputQuantity - scaledFee;

        // Burn mAsset quantity
        _burn(msg.sender, _inputQuantity);
        surplus += scaledFee;

        // Calc cache and total mAsset circulating
        Cache memory cache = _getCacheDetails();
        // Total mAsset = (totalSupply + _inputQuantity - scaledFee) + surplus
        uint256 totalMasset = cache.vaultBalanceSum + mAssetRedemptionAmount;

        // Load the bAsset data from storage into memory
        BassetData[] memory allBassets = bAssetData;

        uint256 len = allBassets.length;
        address[] memory outputs = new address[](len);
        outputQuantities = new uint256[](len);
        for (uint256 i = 0; i < len; i++) {
            // Get amount out, proportionate to redemption quantity
            // Use `cache.sum` here as the total mAsset supply is actually totalSupply + surplus
            uint256 amountOut = (allBassets[i].vaultBalance * mAssetRedemptionAmount) / totalMasset;
            require(amountOut > 1, "Output == 0");
            amountOut -= 1;
            require(amountOut >= _minOutputQuantities[i], "bAsset qty < min qty");
            // Set output in array
            (outputQuantities[i], outputs[i]) = (amountOut, bAssetPersonal[i].addr);
            // Transfer the bAsset to the recipient
            Manager.withdrawTokens(
                amountOut,
                bAssetPersonal[i],
                allBassets[i],
                _recipient,
                cache.maxCache
            );
            // reduce vaultBalance
            bAssetData[i].vaultBalance = allBassets[i].vaultBalance - SafeCast.toUint128(amountOut);
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

    /** @dev Redeem mAsset for one or more bAssets */
    function _redeemExactBassets(
        address[] memory _outputs,
        uint256[] memory _outputQuantities,
        uint256 _maxMassetQuantity,
        address _recipient
    ) internal returns (uint256 mAssetQuantity) {
        require(_recipient != address(0), "Invalid recipient");
        uint256 len = _outputQuantities.length;
        require(len > 0 && len == _outputs.length, "Invalid array input");
        require(_maxMassetQuantity > 0, "Qty==0");

        (uint8[] memory indexes, BassetPersonal[] memory personal) = _getBassets(_outputs);
        // Load bAsset data from storage to memory
        BassetData[] memory allBassets = bAssetData;
        // Validate redemption
        uint256 mAssetRequired =
            forgeValidator.computeRedeemExact(allBassets, indexes, _outputQuantities, _getConfig());
        mAssetQuantity = mAssetRequired.divPrecisely(1e18 - swapFee);
        uint256 fee = mAssetQuantity - mAssetRequired;
        require(mAssetQuantity > 0, "Must redeem some mAssets");
        mAssetQuantity += 1;
        require(mAssetQuantity <= _maxMassetQuantity, "Redeem mAsset qty > max quantity");
        // Apply fees, burn mAsset and return bAsset to recipient
        // 1.0. Burn the full amount of Masset
        _burn(msg.sender, mAssetQuantity);
        surplus += fee;
        Cache memory cache = _getCacheDetails();
        // 2.0. Transfer the Bassets to the recipient and count fees
        for (uint256 i = 0; i < len; i++) {
            uint8 idx = indexes[i];
            Manager.withdrawTokens(
                _outputQuantities[i],
                personal[i],
                allBassets[idx],
                _recipient,
                cache.maxCache
            );
            bAssetData[idx].vaultBalance =
                allBassets[idx].vaultBalance -
                SafeCast.toUint128(_outputQuantities[i]);
        }
        emit RedeemedMulti(
            msg.sender,
            _recipient,
            mAssetQuantity,
            _outputs,
            _outputQuantities,
            fee
        );
    }

    /***************************************
                    GETTERS
    ****************************************/

    /**
     * @dev Get basket details for `Masset_MassetStructs.Basket`
     * @return b   Basket struct
     */
    function getBasket() external view override returns (bool, bool) {
        return (basket.undergoingRecol, basket.failed);
    }

    /**
     * @dev Get data for a all bAssets in basket
     * @return personal  Struct[] with full bAsset data
     * @return data      Number of bAssets in the Basket
     */
    function getBassets()
        external
        view
        override
        returns (BassetPersonal[] memory personal, BassetData[] memory data)
    {
        return (bAssetPersonal, bAssetData);
    }

    /**
     * @dev Get data for a specific bAsset, if it exists
     * @param _bAsset   Address of bAsset
     * @return personal  Struct with full bAsset data
     * @return data  Struct with full bAsset data
     */
    function getBasset(address _bAsset)
        external
        view
        override
        returns (BassetPersonal memory personal, BassetData memory data)
    {
        uint8 idx = bAssetIndexes[_bAsset];
        personal = bAssetPersonal[idx];
        require(personal.addr == _bAsset, "Invalid asset");
        data = bAssetData[idx];
    }

    /**
     * @dev Gets all config needed for general InvariantValidator calls
     */
    function getConfig() external view returns (InvariantConfig memory config) {
        return _getConfig();
    }

    /***************************************
                GETTERS - INTERNAL
    ****************************************/

    /**
     * vaultBalanceSum = totalSupply + 'surplus'
     * maxCache = vaultBalanceSum * (cacheSize / 1e18)
     * surplus is simply surplus, to reduce SLOADs
     */
    struct Cache {
        uint256 vaultBalanceSum;
        uint256 maxCache;
        uint256 surplus;
    }

    /**
     * @dev Gets the supply and cache details for the mAsset, taking into account the surplus
     * @return Cache containing (tracked) sum of vault balances, ideal cache size and surplus
     */
    function _getCacheDetails() internal view returns (Cache memory) {
        // read surplus from storage into memory
        uint256 _surplus = surplus;
        uint256 sum = totalSupply() + _surplus;
        return Cache(sum, sum.mulTruncate(cacheSize), _surplus);
    }

    /**
     * @dev Gets a bAsset from storage
     * @param _asset        Address of the asset
     * @return idx        Index of the asset
     * @return personal   Personal details for the asset
     */
    function _getAsset(address _asset)
        internal
        view
        returns (uint8 idx, BassetPersonal memory personal)
    {
        idx = bAssetIndexes[_asset];
        personal = bAssetPersonal[idx];
        require(personal.addr == _asset, "Invalid asset");
    }

    /**
     * @dev Gets a an array of bAssets from storage and protects against duplicates
     * @param _bAssets    Addresses of the assets
     * @return indexes    Indexes of the assets
     * @return personal   Personal details for the assets
     */
    function _getBassets(address[] memory _bAssets)
        internal
        view
        returns (uint8[] memory indexes, BassetPersonal[] memory personal)
    {
        uint256 len = _bAssets.length;

        indexes = new uint8[](len);
        personal = new BassetPersonal[](len);

        for (uint256 i = 0; i < len; i++) {
            (indexes[i], personal[i]) = _getAsset(_bAssets[i]);

            for (uint256 j = i + 1; j < len; j++) {
                require(_bAssets[i] != _bAssets[j], "Duplicate asset");
            }
        }
    }

    /**
     * @dev Gets all config needed for general InvariantValidator calls
     */
    function _getConfig() internal view returns (InvariantConfig memory) {
        return InvariantConfig(_getA(), weightLimits);
    }

    /**
     * @dev Gets current amplification var A
     */
    function _getA() internal view returns (uint256) {
        AmpData memory ampData_ = ampData;

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
     * @dev Converts recently accrued swap and redeem fees into mAsset
     * @return mintAmount   mAsset units generated from swap and redeem fees
     * @return newSupply    mAsset total supply after mint
     */
    function collectInterest()
        external
        override
        onlySavingsManager
        returns (uint256 mintAmount, uint256 newSupply)
    {
        // Set the surplus variable to 1 to optimise for SSTORE costs.
        // If setting to 0 here, it would save 5k per savings deposit, but cost 20k for the
        // first surplus call (a SWAP or REDEEM).
        uint256 surplusFees = surplus;
        if (surplusFees > 1) {
            mintAmount = surplusFees - 1;
            surplus = 1;

            // mint new mAsset to savings manager
            _mint(msg.sender, mintAmount);
            emit MintedMulti(
                address(this),
                msg.sender,
                mintAmount,
                new address[](0),
                new uint256[](0)
            );
        }
        newSupply = totalSupply();
    }

    /**
     * @dev Collects the interest generated from the Basket, minting a relative
     *      amount of mAsset and sends it over to the SavingsManager.
     * @return mintAmount   mAsset units generated from interest collected from lending markets
     * @return newSupply    mAsset total supply after mint
     */
    function collectPlatformInterest()
        external
        override
        onlySavingsManager
        whenHealthy
        nonReentrant
        returns (uint256 mintAmount, uint256 newSupply)
    {
        uint256[] memory gains;
        (mintAmount, gains) = Manager.collectPlatformInterest(
            bAssetPersonal,
            bAssetData,
            forgeValidator,
            _getConfig()
        );

        require(mintAmount > 0, "Must collect something");

        _mint(msg.sender, mintAmount);
        emit MintedMulti(address(this), msg.sender, mintAmount, new address[](0), gains);

        newSupply = totalSupply();
    }

    /***************************************
                    STATE
    ****************************************/

    /**
     * @dev Sets the MAX cache size for each bAsset. The cache will actually revolve around
     *      _cacheSize * totalSupply / 2 under normal circumstances.
     * @param _cacheSize Maximum percent of total mAsset supply to hold for each bAsset
     */
    function setCacheSize(uint256 _cacheSize) external override onlyGovernor {
        require(_cacheSize <= 2e17, "Must be <= 20%");

        cacheSize = _cacheSize;

        emit CacheSizeChanged(_cacheSize);
    }

    /**
     * @dev Upgrades the version of ForgeValidator protocol. Governor can do this
     *      only while ForgeValidator is unlocked.
     * @param _newForgeValidator Address of the new ForgeValidator
     */
    function upgradeForgeValidator(address _newForgeValidator) external override onlyGovernor {
        require(!forgeValidatorLocked, "ForgeVal locked");
        require(_newForgeValidator != address(0), "Null address");

        forgeValidator = IInvariantValidator(_newForgeValidator);

        emit ForgeValidatorChanged(_newForgeValidator);
    }

    /**
     * @dev Set the ecosystem fee for sewapping bAssets or redeeming specific bAssets
     * @param _swapFee Fee calculated in (%/100 * 1e18)
     */
    function setFees(uint256 _swapFee, uint256 _redemptionFee) external override onlyGovernor {
        require(_swapFee <= MAX_FEE, "Swap rate oob");
        require(_redemptionFee <= MAX_FEE, "Redemption rate oob");

        swapFee = _swapFee;
        redemptionFee = _redemptionFee;

        emit FeesChanged(_swapFee, _redemptionFee);
    }

    /**
     * @dev Set the maximum weight for a given bAsset
     * @param _min Weight where 100% = 1e18
     * @param _max Weight where 100% = 1e18
     */
    function setWeightLimits(uint128 _min, uint128 _max) external onlyGovernor {
        require(_min <= 1e18 / (bAssetData.length * 2), "Min weight oob");
        require(_max >= 1e18 / (bAssetData.length - 1), "Max weight oob");

        weightLimits = WeightLimits(_min, _max);

        emit WeightLimitsChanged(_min, _max);
    }

    /**
     * @dev Update transfer fee flag for a given bAsset, should it change its fee practice
     * @param _bAsset   bAsset address
     * @param _flag         Charge transfer fee when its set to 'true', otherwise 'false'
     */
    function setTransferFeesFlag(address _bAsset, bool _flag) external override onlyGovernor {
        Manager.setTransferFeesFlag(bAssetPersonal, bAssetIndexes, _bAsset, _flag);
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
        override
        onlyGovernor
    {
        Manager.migrateBassets(bAssetPersonal, bAssetIndexes, _bAssets, _newIntegration);
    }

    /**
     * @dev Executes the Auto Redistribution event by isolating the bAsset from the Basket
     * @param _bAsset          Address of the ERC20 token to isolate
     * @param _belowPeg        Bool to describe whether the bAsset deviated below peg (t)
     *                         or above (f)
     */
    function handlePegLoss(address _bAsset, bool _belowPeg) external onlyGovernor {
        Manager.handlePegLoss(basket, bAssetPersonal, bAssetIndexes, _bAsset, _belowPeg);
    }

    /**
     * @dev Negates the isolation of a given bAsset
     * @param _bAsset Address of the bAsset
     */
    function negateIsolation(address _bAsset) external onlyGovernor {
        Manager.negateIsolation(basket, bAssetPersonal, bAssetIndexes, _bAsset);
    }

    /**
     * @dev Starts changing of the amplification var A
     * @param _targetA      Target A value
     * @param _rampEndTime  Time at which A will arrive at _targetA
     */
    function startRampA(uint256 _targetA, uint256 _rampEndTime) external onlyGovernor {
        Manager.startRampA(ampData, _targetA, _rampEndTime, _getA(), A_PRECISION);
    }

    /**
     * @dev Stops the changing of the amplification var A, setting
     * it to whatever the current value is.
     */
    function stopRampA() external onlyGovernor {
        Manager.stopRampA(ampData, _getA());
    }
}