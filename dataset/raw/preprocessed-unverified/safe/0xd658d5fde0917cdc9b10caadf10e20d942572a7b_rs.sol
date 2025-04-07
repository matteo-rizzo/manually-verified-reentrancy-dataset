/**
 *Submitted for verification at Etherscan.io on 2021-07-12
*/

pragma solidity 0.8.2;






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

    /**
     * @dev Return Recollateraliser Module address from the Nexus
     * @return  Address of the Recollateraliser Module contract (Phase 2)
     */
    function _liquidator() internal view returns (address) {
        return nexus.getModule(KEY_LIQUIDATOR);
    }

    /**
     * @dev Return ProxyAdmin Module address from the Nexus
     * @return Address of the ProxyAdmin Module contract
     */
    function _proxyAdmin() internal view returns (address) {
        return nexus.getModule(KEY_PROXY_ADMIN);
    }
}

/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
 */


/**
 * @dev Collection of functions related to the address type
 */






abstract contract ReentrancyGuard {
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

// SPDX-License-Identifier: AGPL-3.0-or-later
/**
 * @title   AlchemixIntegration
 * @author  mStable
 * @notice  A simple connection to farm ALCX rewards with the Alchemix alUSD pool
 * @dev     VERSION: 1.0
 *          DATE:    2021-07-02
 */
contract AlchemixIntegration is
    IPlatformIntegration,
    Initializable,
    ImmutableModule,
    ReentrancyGuard
{
    using SafeERC20 for IERC20;

    event Deposit(address indexed _bAsset, address _pToken, uint256 _amount);
    event Withdrawal(address indexed _bAsset, address _pToken, uint256 _amount);
    event PlatformWithdrawal(
        address indexed bAsset,
        address pToken,
        uint256 totalAmount,
        uint256 userAmount
    );
    event RewardsClaimed();

    /// @notice mAsset or Feeder Pool using the integration. eg fPmUSD/alUSD
    /// @dev LP has write access
    address public immutable lpAddress;
    /// @notice token the staking rewards are accrued and claimed in.
    address public immutable rewardToken;
    /// @notice Alchemix's StakingPools contract
    IAlchemixStakingPools public immutable stakingPools;
    /// @notice base asset that is integrated to Alchemix staking pool. eg alUSD
    address public immutable bAsset;
    /// @notice Alchemix pool identifier for bAsset deposits. eg pool id 0 for alUSD
    uint256 public immutable poolId;

    /**
     * @dev Modifier to allow function calls only from the Governor.
     */
    modifier onlyLP() {
        require(msg.sender == lpAddress, "Only the LP can execute");
        _;
    }

    /**
     * @param _nexus            Address of the Nexus
     * @param _lp               Address of liquidity provider. eg mAsset or feeder pool
     * @param _rewardToken      Reward token, if any. eg ALCX
     * @param _stakingPools     Alchemix StakingPools contract address
     * @param _bAsset           base asset to be deposited to Alchemix's staking pool. eg alUSD
     */
    constructor(
        address _nexus,
        address _lp,
        address _rewardToken,
        address _stakingPools,
        address _bAsset
    ) ImmutableModule(_nexus) {
        require(_lp != address(0), "Invalid LP address");
        require(_rewardToken != address(0), "Invalid reward token");
        require(_stakingPools != address(0), "Invalid staking pools");
        require(_bAsset != address(0), "Invalid bAsset address");

        lpAddress = _lp;
        rewardToken = _rewardToken;
        stakingPools = IAlchemixStakingPools(_stakingPools);
        bAsset = _bAsset;

        uint256 offsetPoolId = IAlchemixStakingPools(_stakingPools).tokenPoolIds(_bAsset);
        require(offsetPoolId >= 1, "bAsset can not be farmed");
        // Take one off the poolId
        poolId = offsetPoolId - 1;
    }

    /**
     * @dev Approve the spending of the bAsset by Alchemix's StakingPools contract,
     *      and the spending of the reward token by mStable's Liquidator contract
     */
    function initialize() public initializer {
        _approveContracts();
    }

    /***************************************
                    ADMIN
    ****************************************/

    /**
     * @dev Re-approve the spending of the bAsset by Alchemix's StakingPools contract,
     *      and the spending of the reward token by mStable's Liquidator contract
     *      if for some reason is it necessary. Only callable through Governance.
     */
    function reapproveContracts() external onlyGovernor {
        _approveContracts();
    }

    function _approveContracts() internal {
        // Approve Alchemix staking pools contract to transfer bAssets for deposits.
        MassetHelpers.safeInfiniteApprove(bAsset, address(stakingPools));

        // Approve Liquidator to transfer reward token when claiming rewards.
        address liquidator = nexus.getModule(keccak256("Liquidator"));
        require(liquidator != address(0), "Liquidator address is zero");

        MassetHelpers.safeInfiniteApprove(rewardToken, liquidator);
    }

    /***************************************
                    CORE
    ****************************************/

    /**
     * @notice Deposit a quantity of bAsset into the platform. Credited cTokens
     *      remain here in the vault. Can only be called by whitelisted addresses
     *      (mAsset and corresponding BasketManager)
     * @param _bAsset              Address for the bAsset
     * @param _amount              Units of bAsset to deposit
     * @param isTokenFeeCharged    Flag that signals if an xfer fee is charged on bAsset
     * @return quantityDeposited   Quantity of bAsset that entered the platform
     */
    function deposit(
        address _bAsset,
        uint256 _amount,
        bool isTokenFeeCharged
    ) external override onlyLP nonReentrant returns (uint256 quantityDeposited) {
        require(_amount > 0, "Must deposit something");
        require(_bAsset == bAsset, "Invalid bAsset");

        quantityDeposited = _amount;

        if (isTokenFeeCharged) {
            // If we charge a fee, account for it
            uint256 prevBal = this.checkBalance(_bAsset);
            stakingPools.deposit(poolId, _amount);
            uint256 newBal = this.checkBalance(_bAsset);
            quantityDeposited = _min(quantityDeposited, newBal - prevBal);
        } else {
            // Else just deposit the amount
            stakingPools.deposit(poolId, _amount);
        }

        emit Deposit(_bAsset, address(stakingPools), quantityDeposited);
    }

    /**
     * @notice Withdraw a quantity of bAsset from Alchemix
     * @param _receiver     Address to which the withdrawn bAsset should be sent
     * @param _bAsset       Address of the bAsset
     * @param _amount       Units of bAsset to withdraw
     * @param _hasTxFee     Is the bAsset known to have a tx fee?
     */
    function withdraw(
        address _receiver,
        address _bAsset,
        uint256 _amount,
        bool _hasTxFee
    ) external override onlyLP nonReentrant {
        _withdraw(_receiver, _bAsset, _amount, _amount, _hasTxFee);
    }

    /**
     * @notice Withdraw a quantity of bAsset from Alchemix
     * @param _receiver     Address to which the withdrawn bAsset should be sent
     * @param _bAsset       Address of the bAsset
     * @param _amount       Units of bAsset to withdraw
     * @param _totalAmount  Total units to pull from lending platform
     * @param _hasTxFee     Is the bAsset known to have a tx fee?
     */
    function withdraw(
        address _receiver,
        address _bAsset,
        uint256 _amount,
        uint256 _totalAmount,
        bool _hasTxFee
    ) external override onlyLP nonReentrant {
        _withdraw(_receiver, _bAsset, _amount, _totalAmount, _hasTxFee);
    }

    function _withdraw(
        address _receiver,
        address _bAsset,
        uint256 _amount,
        uint256 _totalAmount,
        bool _hasTxFee
    ) internal {
        require(_receiver != address(0), "Must specify recipient");
        require(_bAsset == bAsset, "Invalid bAsset");
        require(_totalAmount > 0, "Must withdraw something");

        uint256 userWithdrawal = _amount;

        if (_hasTxFee) {
            require(_amount == _totalAmount, "Cache inactive with tx fee");
            IERC20 b = IERC20(_bAsset);
            uint256 prevBal = b.balanceOf(address(this));
            stakingPools.withdraw(poolId, _amount);
            uint256 newBal = b.balanceOf(address(this));
            userWithdrawal = _min(userWithdrawal, newBal - prevBal);
        } else {
            // Redeem Underlying bAsset amount
            stakingPools.withdraw(poolId, _totalAmount);
        }

        // Send redeemed bAsset to the receiver
        IERC20(_bAsset).safeTransfer(_receiver, userWithdrawal);

        emit PlatformWithdrawal(_bAsset, address(stakingPools), _totalAmount, _amount);
    }

    /**
     * @notice Withdraw a quantity of bAsset from the cache.
     * @param _receiver     Address to which the bAsset should be sent
     * @param _bAsset       Address of the bAsset
     * @param _amount       Units of bAsset to withdraw
     */
    function withdrawRaw(
        address _receiver,
        address _bAsset,
        uint256 _amount
    ) external override onlyLP nonReentrant {
        require(_receiver != address(0), "Must specify recipient");
        require(_bAsset == bAsset, "Invalid bAsset");
        require(_amount > 0, "Must withdraw something");

        IERC20(_bAsset).safeTransfer(_receiver, _amount);

        emit Withdrawal(_bAsset, address(0), _amount);
    }

    /**
     * @notice Get the total bAsset value held in the platform
     * @param _bAsset     Address of the bAsset
     * @return balance    Total value of the bAsset in the platform
     */
    function checkBalance(address _bAsset) external view override returns (uint256 balance) {
        require(_bAsset == bAsset, "Invalid bAsset");
        balance = stakingPools.getStakeTotalDeposited(address(this), poolId);
    }

    /***************************************
                    Liquidation
    ****************************************/

    /**
     *  @notice Claims any accrued reward tokens from the Alchemix staking pool.
     *          eg ALCX tokens from the alUSD deposits.
     *          Claimed rewards are sent to this integration contract.
     *  @dev    The Alchemix StakingPools will emit event
     *          TokensClaimed(user, poolId, amount)
     */
    function claimRewards() external {
        stakingPools.claim(poolId);
    }

    /***************************************
                    HELPERS
    ****************************************/

    /**
     * @dev Simple helper func to get the min of two values
     */
    function _min(uint256 x, uint256 y) internal pure returns (uint256) {
        return x > y ? y : x;
    }
}