/**
 *Submitted for verification at Etherscan.io on 2021-01-20
*/

// SPDX-License-Identifier: SEE LICENSE IN LICENSE

pragma solidity >=0.7.6;
pragma abicoder v2;











// helper methods for interacting with ERC20 tokens and sending ETH that do not consistently return true/false




// a library for performing overflow-safe math, courtesy of DappHub (https://github.com/dapphub/ds-math)


contract TimeLock {
    using SafeMath for uint256;
    event NewAdmin(address indexed newAdmin);
    event NewPendingAdmin(address indexed newPendingAdmin);
    event NewDelay(uint256 indexed newDelay);
    event CancelTransaction(bytes32 indexed txHash, address indexed target, uint256 value, string signature, bytes data, uint256 eta);
    event ExecuteTransaction(bytes32 indexed txHash, address indexed target, uint256 value, string signature, bytes data, uint256 eta);
    event QueueTransaction(bytes32 indexed txHash, address indexed target, uint256 value, string signature, bytes data, uint256 eta);

    uint256 public constant GRACE_PERIOD = 14 days;
    uint256 public constant MINIMUM_DELAY = 2 days;
    uint256 public constant MAXIMUM_DELAY = 30 days;
    bool private _initialized;
    address public admin;
    address public pendingAdmin;
    uint256 public delay;
    bool public admin_initialized;
    mapping(bytes32 => bool) public queuedTransactions;

    constructor() {
        admin_initialized = false;
        _initialized = false;
    }

    function initialize(address _admin, uint256 _delay) public {
        require(_initialized == false, "Timelock::constructor: Initialized must be false.");
        require(_delay >= MINIMUM_DELAY, "Timelock::setDelay: Delay must exceed minimum delay.");
        require(_delay <= MAXIMUM_DELAY, "Timelock::setDelay: Delay must not exceed maximum delay.");
        delay = _delay;
        admin = _admin;
        _initialized = true;
        emit NewAdmin(admin);
        emit NewDelay(delay);
    }

    receive() external payable {}

    function setDelay(uint256 _delay) public {
        require(msg.sender == address(this), "Timelock::setDelay: Call must come from Timelock.");
        require(_delay >= MINIMUM_DELAY, "Timelock::setDelay: Delay must exceed minimum delay.");
        require(_delay <= MAXIMUM_DELAY, "Timelock::setDelay: Delay must not exceed maximum delay.");
        delay = _delay;
        emit NewDelay(delay);
    }

    function acceptAdmin() public {
        require(msg.sender == pendingAdmin, "Timelock::acceptAdmin: Call must come from pendingAdmin.");
        admin = msg.sender;
        pendingAdmin = address(0);
        emit NewAdmin(admin);
    }

    function setPendingAdmin(address _pendingAdmin) public {
        // allows one time setting of admin for deployment purposes
        if (admin_initialized) {
            require(msg.sender == address(this), "Timelock::setPendingAdmin: Call must come from Timelock.");
        } else {
            require(msg.sender == admin, "Timelock::setPendingAdmin: First call must come from admin.");
            admin_initialized = true;
        }
        pendingAdmin = _pendingAdmin;

        emit NewPendingAdmin(pendingAdmin);
    }

    function queueTransaction(
        address target,
        uint256 value,
        string memory signature,
        bytes memory data,
        uint256 eta
    ) public returns (bytes32) {
        require(msg.sender == admin, "Timelock::queueTransaction: Call must come from admin.");
        require(eta >= getBlockTimestamp().add(delay), "Timelock::queueTransaction: Estimated execution block must satisfy delay.");

        bytes32 txHash = keccak256(abi.encode(target, value, signature, data, eta));
        queuedTransactions[txHash] = true;

        emit QueueTransaction(txHash, target, value, signature, data, eta);
        return txHash;
    }

    function cancelTransaction(
        address target,
        uint256 value,
        string memory signature,
        bytes memory data,
        uint256 eta
    ) public {
        require(msg.sender == admin, "Timelock::cancelTransaction: Call must come from admin.");

        bytes32 txHash = keccak256(abi.encode(target, value, signature, data, eta));
        queuedTransactions[txHash] = false;

        emit CancelTransaction(txHash, target, value, signature, data, eta);
    }

    function executeTransaction(
        address target,
        uint256 value,
        string memory signature,
        bytes memory data,
        uint256 eta
    ) public payable returns (bytes memory) {
        require(msg.sender == admin, "Timelock::executeTransaction: Call must come from admin.");

        bytes32 txHash = keccak256(abi.encode(target, value, signature, data, eta));
        require(queuedTransactions[txHash], "Timelock::executeTransaction: Transaction hasn't been queued.");
        require(getBlockTimestamp() >= eta, "Timelock::executeTransaction: Transaction hasn't surpassed time lock.");
        require(getBlockTimestamp() <= eta.add(GRACE_PERIOD), "Timelock::executeTransaction: Transaction is stale.");

        queuedTransactions[txHash] = false;

        bytes memory callData;

        if (bytes(signature).length == 0) {
            callData = data;
        } else {
            callData = abi.encodePacked(bytes4(keccak256(bytes(signature))), data);
        }

        // solium-disable-next-line security/no-call-value
        (bool success, bytes memory returnData) = target.call{value: value}(callData);
        require(success, "Timelock::executeTransaction: Transaction execution reverted.");

        emit ExecuteTransaction(txHash, target, value, signature, data, eta);

        return returnData;
    }

    function getBlockTimestamp() internal view returns (uint256) {
        return block.timestamp;
    }
}









contract StakePoolRewardFund is IStakePoolRewardFund {
    uint256 public constant BLOCKS_PER_DAY = 6528;
    address public stakePool;
    address public timelock;
    bool private _initialized;

    function initialize(address _stakePool, address _timelock) external override {
        require(_initialized == false, "StakePoolRewardFund: already initialized");
        stakePool = _stakePool;
        timelock = _timelock;
        _initialized = true;
    }

    function safeTransfer(
        address _token,
        address _to,
        uint256 _value
    ) external override {
        require(msg.sender == stakePool, "StakePoolRewardFund: !stakePool");
        TransferHelper.safeTransfer(_token, _to, _value);
    }

    function recoverRewardToken(
        address _token,
        uint256 _amount,
        address _to
    ) external {
        require(msg.sender == timelock, "StakePoolRewardFund: !timelock");
        uint256 length = IStakePool(stakePool).rewardPoolInfoLength();
        for (uint8 pid = 0; pid < length; ++pid) {
            (address rewardToken, uint256 endRewardBlock) = IStakePool(stakePool).getEndRewardBlock(pid);
            if (rewardToken == _token) {
                // do not allow to drain reward token if less than 2 months after pool ends
                require(block.number >= (endRewardBlock + (BLOCKS_PER_DAY * 30)), "StakePoolRewardFund: blockNumber < 30 days since endRewardBlock");
            }
        }
        TransferHelper.safeTransfer(_token, _to, _amount);
    }
}



contract StakePoolController is IStakePoolController {
    IValueLiquidFactory public swapFactory;
    address public governance;

    address public feeCollector;
    address public feeToken;
    uint256 public feeAmount;

    mapping(address => bool) private _stakePools;
    mapping(address => bool) private _whitelistStakingFor;
    mapping(address => bool) private _whitelistRewardRebaser;
    mapping(address => bool) private _whitelistRewardMultiplier;
    mapping(address => int8) private _whitelistStakePools;
    mapping(address => bool) public _stakePoolVerifiers;
    mapping(uint256 => address) public stakePoolCreators;
    address[] public override allStakePools;
    bool private _initialized = false;

    IFreeFromUpTo public constant chi = IFreeFromUpTo(0x0000000000004946c0e9F43F4Dee607b0eF1fA1c);

    modifier discountCHI(uint8 flag) {
        uint256 gasStart = gasleft();
        _;
        if ((flag & 0x1) == 1) {
            uint256 gasSpent = 21000 + gasStart - gasleft() + 16 * msg.data.length;
            chi.freeFromUpTo(msg.sender, (gasSpent + 14154) / 41130);
        }
    }

    function initialize(address _swapFactory) public {
        require(_initialized == false, "StakePoolController: initialized");
        governance = msg.sender;
        swapFactory = IValueLiquidFactory(_swapFactory);
        _initialized = true;
    }

    function isStakePool(address b) external view override returns (bool) {
        return _stakePools[b];
    }

    modifier onlyGovernance() {
        require(msg.sender == governance, "StakePoolController: !governance");
        _;
    }

    function setFeeCollector(address _address) external override onlyGovernance {
        require(_address != address(0), "StakePoolController: invalid address");
        feeCollector = _address;
        emit SetFeeCollector(_address);
    }

    function setFeeToken(address _token) external override onlyGovernance {
        require(_token != address(0), "StakePoolController: invalid _token");
        feeToken = _token;
        emit SetFeeToken(_token);
    }

    function setFeeAmount(uint256 _feeAmount) external override onlyGovernance {
        feeAmount = _feeAmount;
        emit SetFeeAmount(_feeAmount);
    }

    function isWhitelistStakingFor(address _address) external view override returns (bool) {
        return _whitelistStakingFor[_address];
    }

    function isWhitelistStakePool(address _address) external view override returns (int8) {
        return _whitelistStakePools[_address];
    }

    function isStakePoolVerifier(address _address) external view override returns (bool) {
        return _stakePoolVerifiers[_address];
    }

    function setWhitelistStakingFor(address _address, bool state) external override onlyGovernance {
        require(_address != address(0), "StakePoolController: invalid address");
        _whitelistStakingFor[_address] = state;
        emit SetWhitelistStakingFor(_address, state);
    }

    function setStakePoolVerifier(address _address, bool state) external override onlyGovernance {
        require(_address != address(0), "StakePoolController: invalid address");
        _stakePoolVerifiers[_address] = state;
        emit SetStakePoolVerifier(_address, state);
    }

    function setWhitelistStakePool(address _address, int8 state) external override {
        require(_address != address(0), "StakePoolController: invalid address");
        require(_stakePoolVerifiers[msg.sender] == true, "StakePoolController: invalid stake pool verifier");
        _whitelistStakePools[_address] = state;
        emit SetWhitelistStakePool(_address, state);
    }

    function addStakePoolCreator(address _address) external override onlyGovernance {
        require(_address != address(0), "StakePoolController: invalid address");
        uint256 version = IStakePoolCreator(_address).version();
        require(version >= 1000, "Invalid stake pool creator version");
        stakePoolCreators[version] = _address;
        emit SetStakePoolCreator(_address, version);
    }

    function isWhitelistRewardRebaser(address _address) external view override returns (bool) {
        return _address == address(0) ? true : _whitelistRewardRebaser[_address];
    }

    function setWhitelistRewardRebaser(address _address, bool state) external override onlyGovernance {
        require(_address != address(0), "StakePoolController: invalid address");
        _whitelistRewardRebaser[_address] = state;
        emit SetWhitelistRewardRebaser(_address, state);
    }

    function isWhitelistRewardMultiplier(address _address) external view override returns (bool) {
        return _address == address(0) ? true : _whitelistRewardMultiplier[_address];
    }

    function setWhitelistRewardMultiplier(address _address, bool state) external override onlyGovernance {
        require(_address != address(0), "StakePoolController: invalid address");
        _whitelistRewardMultiplier[_address] = state;
        emit SetWhitelistRewardMultiplier(_address, state);
    }

    function setGovernance(address _governance) external override onlyGovernance {
        require(_governance != address(0), "StakePoolController: invalid governance");
        governance = _governance;
        emit ChangeGovernance(_governance);
    }

    function allStakePoolsLength() external view override returns (uint256) {
        return allStakePools.length;
    }

    function createPair(
        uint256 version,
        address tokenA,
        address tokenB,
        uint32 tokenWeightA,
        uint32 swapFee,
        uint256 delayTimeLock,
        PoolRewardInfo calldata poolRewardInfo,
        uint8 flag
    ) public override discountCHI(flag) returns (address) {
        address pair = swapFactory.getPair(tokenA, tokenB, tokenWeightA, swapFee);
        if (pair == address(0)) {
            pair = swapFactory.createPair(tokenA, tokenB, tokenWeightA, swapFee);
        }
        return create(version, pair, delayTimeLock, poolRewardInfo, 0);
    }

    function _addRewardPool(IStakePool pool, PoolRewardInfo calldata poolRewardInfo) internal {
        pool.addRewardPool(
            poolRewardInfo.rewardToken,
            poolRewardInfo.rewardRebaser,
            poolRewardInfo.rewardMultiplier,
            poolRewardInfo.startBlock,
            poolRewardInfo.endRewardBlock,
            poolRewardInfo.rewardPerBlock,
            poolRewardInfo.lockRewardPercent,
            poolRewardInfo.startVestingBlock,
            poolRewardInfo.endVestingBlock
        );
    }

    function create(
        uint256 version,
        address pair,
        uint256 delayTimeLock,
        PoolRewardInfo calldata poolRewardInfo,
        uint8 flag
    ) public override discountCHI(flag) returns (address) {
        require(swapFactory.isPair(pair), "StakePoolController: invalid pair");
        address stakePoolCreator = stakePoolCreators[version];
        require(stakePoolCreator != address(0), "StakePoolController: Invalid stake pool creator version");
        IStakePool pool = IStakePool(IStakePoolCreator(stakePoolCreator).create());

        if (feeCollector != address(0) && feeToken != address(0) && feeAmount > 0) {
            TransferHelper.safeTransferFrom(feeToken, msg.sender, feeCollector, feeAmount);
        }

        allStakePools.push(address(pool));
        _stakePools[address(pool)] = true;
        TimeLock timelock = new TimeLock();
        StakePoolRewardFund stakePoolRewardFund = new StakePoolRewardFund();
        emit MasterCreated(
            address(pool),
            pair,
            IStakePoolCreator(stakePoolCreator).version(),
            address(timelock),
            address(stakePoolRewardFund),
            allStakePools.length
        );
        timelock.initialize(msg.sender, delayTimeLock);
        stakePoolRewardFund.initialize(address(pool), address(timelock));
        require(
            IERC20(poolRewardInfo.rewardToken).balanceOf(msg.sender) >= poolRewardInfo.rewardFundAmount,
            "StakePoolController: Not enough rewardFundAmount"
        );
        TransferHelper.safeTransferFrom(poolRewardInfo.rewardToken, msg.sender, address(stakePoolRewardFund), poolRewardInfo.rewardFundAmount);
        _addRewardPool(pool, poolRewardInfo);
        pool.initialize(pair, poolRewardInfo.unstakingFrozenTime, address(stakePoolRewardFund), address(timelock));
        return address(pool);
    }
}