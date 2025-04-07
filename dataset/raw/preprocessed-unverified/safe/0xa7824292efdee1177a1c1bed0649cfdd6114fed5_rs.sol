/**
 *Submitted for verification at Etherscan.io on 2021-04-07
*/

// SPDX-License-Identifier: AGPL-3.0-or-later
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



/**
 * @dev Collection of functions related to the address type
 */




/**
 * @title   RevenueRecipient
 * @author  mStable
 * @notice  Simply receives mAssets and then deposits to a pre-defined Balancer
 *          Bpool.
 * @dev     VERSION: 2.0
 *          DATE:    2021-04-06
 */
contract RevenueRecipient is IRevenueRecipient, ImmutableModule {
    using SafeERC20 for IERC20;

    event RevenueReceived(address indexed mAsset, uint256 amountIn);
    event RevenueDeposited(address indexed mAsset, uint256 amountIn, uint256 amountOut);

    // BPT To which all revenue should be deposited
    IBPool public immutable mBPT;
    IERC20 public immutable BAL;

    // Minimum output units per 1e18 input units
    mapping(address => uint256) public minOut;

    /**
     * @dev Creates the RevenueRecipient contract
     * @param _nexus      mStable system Nexus address
     * @param _targetPool Balancer pool to which all revenue should be deposited
     * @param _balToken   Address of $BAL
     * @param _assets     Initial list of supported mAssets
     * @param _minOut     Minimum BPT out per mAsset unit
     */
    constructor(
        address _nexus,
        address _targetPool,
        address _balToken,
        address[] memory _assets,
        uint256[] memory _minOut
    ) ImmutableModule(_nexus) {
        mBPT = IBPool(_targetPool);
        BAL = IERC20(_balToken);
        uint256 len = _assets.length;
        for (uint256 i = 0; i < len; i++) {
            minOut[_assets[i]] = _minOut[i];
            IERC20(_assets[i]).safeApprove(_targetPool, 2**256 - 1);
        }
    }

    /**
     * @dev Simply transfers the mAsset from the sender to here
     * @param _mAsset Address of mAsset
     * @param _amount Units of mAsset collected
     */
    function notifyRedistributionAmount(address _mAsset, uint256 _amount) external override {
        // Transfer from sender to here
        IERC20(_mAsset).safeTransferFrom(msg.sender, address(this), _amount);

        emit RevenueReceived(_mAsset, _amount);
    }

    /**
     * @dev Called by anyone to deposit to the balancer pool
     * @param _mAssets Addresses of assets to deposit
     * @param _percentages 1e18 scaled percentages of the current balance to deposit
     */
    function depositToPool(address[] calldata _mAssets, uint256[] calldata _percentages)
        external
        override
    {
        uint256 len = _mAssets.length;
        require(len > 0 && len == _percentages.length, "Invalid args");

        for (uint256 i = 0; i < len; i++) {
            uint256 pct = _percentages[i];
            require(pct > 1e15 && pct <= 1e18, "Invalid pct");
            address mAsset = _mAssets[i];
            uint256 bal = IERC20(mAsset).balanceOf(address(this));
            // e.g. 1 * 5e17 / 1e18 = 5e17
            uint256 deposit = (bal * pct) / 1e18;
            require(minOut[mAsset] > 0, "Invalid minout");
            uint256 minBPT = (deposit * minOut[mAsset]) / 1e18;
            uint256 poolAmountOut = mBPT.joinswapExternAmountIn(mAsset, deposit, minBPT);

            emit RevenueDeposited(mAsset, deposit, poolAmountOut);
        }
    }

    /**
     * @dev Simply approves spending of a given asset by BPT
     * @param asset Address of asset to approve
     */
    function approveAsset(address asset) external onlyGovernor {
        IERC20(asset).safeApprove(address(mBPT), 0);
        IERC20(asset).safeApprove(address(mBPT), 2**256 - 1);
    }

    /**
     * @dev Sets the minimum amount of BPT to receive for a given asset
     * @param _asset Address of mAsset
     * @param _minOut Scaled amount to receive per 1e18 mAsset units
     */
    function updateAmountOut(address _asset, uint256 _minOut) external onlyGovernor {
        minOut[_asset] = _minOut;
    }

    /**
     * @dev Migrates BPT and BAL to a new revenue recipient
     * @param _recipient Address of recipient
     */
    function migrate(address _recipient) external onlyGovernor {
        IERC20 mBPT_ = IERC20(address(mBPT));
        mBPT_.safeTransfer(_recipient, mBPT_.balanceOf(address(this)));
        BAL.safeTransfer(_recipient, BAL.balanceOf(address(this)));
    }

    /**
     * @dev Reinvests any accrued $BAL tokens back into the pool
     * @param _pool         Address of the bPool to swap into
     * @param _output       Token to receive out of the swap (must be in mBPT)
     * @param _minAmountOut TOTAL amount out for the $BAL -> _output swap
     * @param _maxPrice     MaxPrice for the output (req by bPool)
     * @param _pct          Percentage of all BAL held here to liquidate
     */
    function reinvestBAL(
        address _pool,
        address _output,
        uint256 _minAmountOut,
        uint256 _maxPrice,
        uint256 _pct
    ) external onlyGovernor {
        require(minOut[_output] > 0, "Invalid output");
        require(_pct > 1e15 && _pct <= 1e18, "Invalid pct");
        uint256 balance = BAL.balanceOf(address(this));
        uint256 balDeposit = (balance * _pct) / 1e18;
        // 1. Convert BAL to ETH
        BAL.approve(_pool, balDeposit);
        (uint256 tokenAmountOut, ) =
            IBPool(_pool).swapExactAmountIn(
                address(BAL),
                balDeposit,
                _output,
                _minAmountOut,
                _maxPrice
            );
        // 2. Deposit ETH to mBPT
        uint256 poolAmountOut =
            mBPT.joinswapExternAmountIn(
                _output,
                tokenAmountOut,
                (tokenAmountOut * minOut[_output]) / 1e18
            );

        emit RevenueDeposited(_output, tokenAmountOut, poolAmountOut);
    }
}