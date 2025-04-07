/**
 *Submitted for verification at Etherscan.io on 2020-12-02
*/

pragma solidity = 0.7.0;




interface Minter is ERC20 {
    event Mint(address indexed to, uint256 value, uint indexed period, uint userEthLocked, uint totalEthLocked);

    function governanceRouter() external view returns (GovernanceRouter);
    function mint(address to, uint period, uint128 userEthLocked, uint totalEthLocked) external returns (uint amount);
    function userTokensToClaim(address user) external view returns (uint amount);
    function periodTokens(uint period) external pure returns (uint128);
    function periodDecayK() external pure returns (uint decayK);
    function initialPeriodTokens() external pure returns (uint128);
}



interface WETH is ERC20 {
    function deposit() external payable;
    function withdraw(uint) external;
}





// SPDX-License-Identifier: GPL-3.0
contract LiquifiGovernanceRouter is GovernanceRouter {
    uint private immutable timeZero;
    uint private immutable miningPeriod;

    address public immutable override creator;
    WETH public immutable override weth;
    
    // write once props
    PoolFactory public override poolFactory;
    ActivityMeter public override activityMeter;
    Minter public override minter;
    
    // props managed by governor
    address public override protocolFeeReceiver;

    address private governor;
    uint96 private defaultGovernancePacked;
    
    constructor(uint _miningPeriod, address _weth) public {
        defaultGovernancePacked = (
            /*instantSwapFee*/uint96(3) << 88 | // 0.3%
            /*fee*/uint96(3) << 80 | // 0.3%
            /*maxPeriod*/uint96(1 hours) << 40 |
            /*desiredMaxHistory*/uint96(100) << 24
        );

        creator = tx.origin;
        timeZero = block.timestamp;
        miningPeriod = _miningPeriod;
        weth = WETH(_weth);
    }

    function schedule() external override view returns(uint _timeZero, uint _miningPeriod) {
        _timeZero = timeZero;
        _miningPeriod = address(activityMeter) == address(0) ? 0 : miningPeriod;
    }

    function setActivityMeter(ActivityMeter _activityMeter) external override {
        require(address(activityMeter) == address(0) && tx.origin == creator, "LIQUIFI_GVR: INVALID INIT SENDER");
        activityMeter = _activityMeter;
    }

    function setMinter(Minter _minter) external override {
        require(address(minter) == address(0) && tx.origin == creator, "LIQUIFI_GVR: INVALID INIT SENDER");
        minter = _minter;
    }

    function setPoolFactory(PoolFactory _poolFactory) external override {
        require(msg.sender == governor || (address(poolFactory) == address(0) && tx.origin == creator), "LIQUIFI_GVR: INVALID INIT SENDER");
        poolFactory = _poolFactory;
        emit PoolFactoryChanged(address(_poolFactory));
    }

    function setGovernor(address _governor) external override {
        require(msg.sender == governor || (governor == address(0) && tx.origin == creator), "LIQUIFI_GVR: INVALID GOVERNANCE SENDER");
        governor = _governor;
        emit GovernorChanged(_governor);
    }

    function setProtocolFeeReceiver(address _protocolFeeReceiver) external override {
        require(msg.sender == governor, "LIQUIFI_GVR: INVALID GOVERNANCE SENDER");
        protocolFeeReceiver = _protocolFeeReceiver;
        emit ProtocolFeeReceiverChanged(_protocolFeeReceiver);
    }

    function applyGovernance(uint96 _defaultGovernancePacked) external override {
        require(msg.sender == governor, "LIQUIFI_GVR: INVALID GOVERNANCE SENDER");
        defaultGovernancePacked = _defaultGovernancePacked;
        emit GovernanceApplied(_defaultGovernancePacked);
    }

    // grouped read for gas saving
    function governance() external override view returns (address _governor, uint96 _defaultGovernancePacked) {
        _governor = governor;
        _defaultGovernancePacked = defaultGovernancePacked;
    }
}