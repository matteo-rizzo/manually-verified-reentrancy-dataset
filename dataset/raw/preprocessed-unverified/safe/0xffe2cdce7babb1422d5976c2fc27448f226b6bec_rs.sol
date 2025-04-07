/**
 *Submitted for verification at Etherscan.io on 2021-03-23
*/

// SPDX-License-Identifier: AGPL-3.0-or-later
pragma solidity 0.8.0;






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



/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
 */

/**
 * @dev Collection of functions related to the address type
 */




/**
 * @title   RevenueRecipient
 * @author  mStable
 * @notice  Simply receives mAssets and then deposits to a pre-defined Balancer
 *          ConfigurableRightsPool.
 * @dev     VERSION: 1.0
 *          DATE:    2021-03-08
 */
contract RevenueRecipient is IRevenueRecipient, ImmutableModule {
    using SafeERC20 for IERC20;

    event RevenueReceived(address indexed mAsset, uint256 amountIn, uint256 amountOut);

    // BPT To which all revenue should be deposited
    IConfigurableRightsPool public immutable mBPT;

    // Minimum output units per 1e18 input units
    mapping(address => uint256) public minOut;

    /**
     * @dev Creates the RevenueRecipient contract
     * @param _nexus      mStable system Nexus address
     * @param _targetPool Balancer pool to which all revenue should be deposited
     * @param _assets     Initial list of supported mAssets
     * @param _minOut     Minimum BPT out per mAsset unit
     */
    constructor(
        address _nexus,
        address _targetPool,
        address[] memory _assets,
        uint256[] memory _minOut
    ) ImmutableModule(_nexus) {
        mBPT = IConfigurableRightsPool(_targetPool);

        uint256 len = _assets.length;
        for (uint256 i = 0; i < len; i++) {
            minOut[_assets[i]] = _minOut[i];
            IERC20(_assets[i]).safeApprove(_targetPool, 2**256 - 1);
        }
    }

    /**
     * @dev Called by SavingsManager after revenue has accrued
     * @param _mAsset Address of mAsset
     * @param _amount Units of mAsset collected
     */
    function notifyRedistributionAmount(address _mAsset, uint256 _amount) external override {
        // Transfer from sender to here
        IERC20(_mAsset).safeTransferFrom(msg.sender, address(this), _amount);

        // Deposit into pool
        uint256 minBPT = (_amount * minOut[_mAsset]) / 1e18;
        uint256 poolAmountOut = mBPT.joinswapExternAmountIn(_mAsset, _amount, minBPT);

        emit RevenueReceived(_mAsset, _amount, poolAmountOut);
    }

    /**
     * @dev Simply approves spending of a given mAsset by BPT
     * @param _mAsset Address of mAsset to approve
     */
    function approveAsset(address _mAsset) external onlyGovernor {
        IERC20(_mAsset).safeApprove(address(mBPT), 0);
        IERC20(_mAsset).safeApprove(address(mBPT), 2**256 - 1);
    }

    /**
     * @dev Sets the minimum amount of BPT to receive for a given mAsset
     * @param _mAsset Address of mAsset
     * @param _minOut Scaled amount to receive per 1e18 mAsset units
     */
    function updateAmountOut(address _mAsset, uint256 _minOut) external onlyGovernor {
        minOut[_mAsset] = _minOut;
    }

    /**
     * @dev Migrates BPT to a new revenue recipient
     * @param _recipient Address of recipient
     */
    function migrateBPT(address _recipient) external onlyGovernor {
        IERC20 mBPT_ = IERC20(address(mBPT));
        mBPT_.safeTransfer(_recipient, mBPT_.balanceOf(address(this)));
    }
}