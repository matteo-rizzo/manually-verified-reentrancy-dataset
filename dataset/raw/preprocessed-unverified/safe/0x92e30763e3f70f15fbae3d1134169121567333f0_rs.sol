/**
 *Submitted for verification at Etherscan.io on 2020-11-22
*/

pragma solidity 0.6.12;


// File: @openzeppelin/contracts/math/SafeMath.sol



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


// File: @openzeppelin/contracts/token/ERC20/IERC20.sol



/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
 */


// File: @openzeppelin/contracts/utils/Address.sol



/**
 * @dev Collection of functions related to the address type
 */


// File: @openzeppelin/contracts/token/ERC20/SafeERC20.sol






/**
 * @title SafeERC20
 * @dev Wrappers around ERC20 operations that throw on failure (when the token
 * contract returns false). Tokens that return no value (and instead revert or
 * throw on failure) are also supported, non-reverting calls are assumed to be
 * successful.
 * To use this library you can add a `using SafeERC20 for IERC20;` statement to your contract,
 * which allows you to call the safe operations as `token.safeTransfer(...)`, etc.
 */


// File: contracts/TimelockV2.sol




contract TimelockV2 {
    using SafeMath for uint;
    using SafeERC20 for IERC20;

    event NewAdmin(address indexed newAdmin);
    event NewPendingAdmin(address indexed newPendingAdmin);
    event NewDelay(uint indexed newDelay);
    event NewVetoQuorum(uint vetoQuorum);
    event CancelTransaction(bytes32 indexed txHash, address indexed target, uint value, string signature,  bytes data, uint eta);
    event ExecuteTransaction(bytes32 indexed txHash, address indexed target, uint value, string signature,  bytes data, uint eta);
    event QueueTransaction(bytes32 indexed txHash, address indexed target, uint value, string signature, bytes data, uint eta);
    event VetoTransaction(bytes32 indexed txHash, address indexed target, uint value, string signature,  bytes data, uint eta, uint vetoPower);
    event Deposit(address indexed account, uint vetoPower);
    event Withdraw(address indexed account, uint vetoPower);

    uint public constant GRACE_PERIOD = 14 days;
    uint public constant MINIMUM_DELAY = 3 days;
    uint public constant MAXIMUM_DELAY = 30 days;
    uint public constant EXECUTABLE_PERIOD = 1 days;
    uint public constant MAXIMUM_VETO_QUORUM = 50;

    address public admin;
    address public pendingAdmin;
    uint public delay;
    bool public admin_initialized;
    IERC20 public vetoToken;
    uint public vetoQuorum;

    mapping (address => uint) public vetoPowerForAccount;
    mapping (address => bytes32[]) internal _vetoedTxHashesForAccount;

    mapping (bytes32 => bool) public queuedTransactions;
    mapping (bytes32 => uint) public accVetoPowerForTransaction;
    mapping (bytes32 => mapping(address => uint)) public vetoPowerForTransaction;


    constructor(address admin_, uint delay_, IERC20 vetoToken_, uint vetoQuorum_) public {
        require(delay_ >= MINIMUM_DELAY, "Timelock::constructor: Delay must exceed minimum delay.");
        require(delay_ <= MAXIMUM_DELAY, "Timelock::constructor: Delay must not exceed maximum delay.");
        require(vetoQuorum_ <= MAXIMUM_VETO_QUORUM, "Timelock::constructor: Quorum must not exceed maximum quorum.");

        admin = admin_;
        delay = delay_;
        vetoToken = vetoToken_;
        vetoQuorum = vetoQuorum_;
        admin_initialized = false;
    }

    receive() external payable { }

    function setDelay(uint delay_) public {
        require(msg.sender == address(this), "Timelock::setDelay: Call must come from Timelock.");
        require(delay_ >= MINIMUM_DELAY, "Timelock::setDelay: Delay must exceed minimum delay.");
        require(delay_ <= MAXIMUM_DELAY, "Timelock::setDelay: Delay must not exceed maximum delay.");
        delay = delay_;

        emit NewDelay(delay);
    }

    function acceptAdmin() public {
        require(msg.sender == pendingAdmin, "Timelock::acceptAdmin: Call must come from pendingAdmin.");
        admin = msg.sender;
        pendingAdmin = address(0);

        emit NewAdmin(admin);
    }

    function setPendingAdmin(address pendingAdmin_) public {
        // allows one time setting of admin for deployment purposes
        if (admin_initialized) {
            require(msg.sender == address(this), "Timelock::setPendingAdmin: Call must come from Timelock.");
        } else {
            require(msg.sender == admin, "Timelock::setPendingAdmin: First call must come from admin.");
            admin_initialized = true;
        }
        pendingAdmin = pendingAdmin_;

        emit NewPendingAdmin(pendingAdmin);
    }

    function setVetoQuorum(uint vetoQuorum_) public {
        require(msg.sender == address(this), "Timelock::setVetoQuorum: Call must come from Timelock.");
        require(vetoQuorum_ <= MAXIMUM_VETO_QUORUM, "Timelock::setVetoQuorum: Quorum must not exceed maximum quorum.");
        vetoQuorum = vetoQuorum_;

        emit NewVetoQuorum(vetoQuorum);
    }

    function queueTransaction(address target, uint value, string memory signature, bytes memory data, uint eta) public returns (bytes32) {
        require(msg.sender == admin, "Timelock::queueTransaction: Call must come from admin.");
        require(eta >= getBlockTimestamp().add(delay), "Timelock::queueTransaction: Estimated execution block must satisfy delay.");

        bytes32 txHash = keccak256(abi.encode(target, value, signature, data, eta));
        queuedTransactions[txHash] = true;

        emit QueueTransaction(txHash, target, value, signature, data, eta);
        return txHash;
    }

    function cancelTransaction(address target, uint value, string memory signature, bytes memory data, uint eta) public {
        require(msg.sender == admin, "Timelock::cancelTransaction: Call must come from admin.");

        bytes32 txHash = keccak256(abi.encode(target, value, signature, data, eta));
        queuedTransactions[txHash] = false;

        emit CancelTransaction(txHash, target, value, signature, data, eta);
    }

    function executeTransaction(address target, uint value, string memory signature, bytes memory data, uint eta) public payable returns (bytes memory) {
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

    function depositAndVetoTransaction(address target, uint value, string memory signature, bytes memory data, uint eta, uint vetoPower) public {
        deposit(vetoPower);
        vetoTransaction(target, value, signature, data, eta, vetoPower);
    }

    function vetoTransaction(address target, uint value, string memory signature, bytes memory data, uint eta, uint vetoPower) public {
        require(msg.sender == tx.origin, "Timelock::vetoTransaction: Not EOA.");
        require(vetoPower > 0, "Timelock:vetoTransaction: vetoPower too small.");

        bytes32 txHash = keccak256(abi.encode(target, value, signature, data, eta));
        require(queuedTransactions[txHash], "Timelock::vetoTransaction: Transaction hasn't been queued.");
        require(getBlockTimestamp() < eta, "Timelock::vetoTransaction: Transaction has surpassed time lock.");
        require(vetoPowerForAccount[msg.sender] >= vetoPower, "Timelock::vetoTransaction: Not sufficient veto power.");
        require(vetoPowerForTransaction[txHash][msg.sender] == 0, "Timelock::vetoTransaction: Already vetoed.");

        _vetoedTxHashesForAccount[msg.sender].push(txHash);
        vetoPowerForTransaction[txHash][msg.sender] = vetoPower;
        accVetoPowerForTransaction[txHash] = accVetoPowerForTransaction[txHash].add(vetoPower);

        emit VetoTransaction(txHash, target, value, signature, data, eta, vetoPower);

        cancelTransactionIfInvalidated(target, value, signature, data, eta);
    }

    function cancelTransactionIfInvalidated(address target, uint value, string memory signature, bytes memory data, uint eta) public {
        bytes32 txHash = keccak256(abi.encode(target, value, signature, data, eta));
        require(queuedTransactions[txHash], "Timelock::cancelTransactionIfInvalidated: Transaction hasn't been queued.");

        if (getBlockTimestamp() >= eta + EXECUTABLE_PERIOD || accVetoPowerForTransaction[txHash].mul(100) >= vetoToken.totalSupply().mul(vetoQuorum)) {
            queuedTransactions[txHash] = false;

            emit CancelTransaction(txHash, target, value, signature, data, eta);
        }
    }

    function deposit(uint vetoPower) public {
        require(msg.sender == tx.origin, "Timelock::deposit: Not EOA.");
        require(vetoPower > 0, "Timelock:deposit: vetoPower too small.");

        vetoToken.safeTransferFrom(msg.sender, address(this), vetoPower);
        vetoPowerForAccount[msg.sender] = vetoPowerForAccount[msg.sender].add(vetoPower);

        emit Deposit(msg.sender, vetoPower);
    }

    function withdraw() public {
        require(msg.sender == tx.origin, "Timelock::withdraw: Not EOA.");

        uint vetoPower = vetoPowerForAccount[msg.sender];
        require(vetoPower > 0, "Timelock:withdraw: vetoPower too small.");

        bytes32[] storage txHashes = _vetoedTxHashesForAccount[msg.sender];
        for (uint i = 0; i < txHashes.length; i++) {
            require(!queuedTransactions[txHashes[i]], "Timelock::withdraw: You have a pending transaction.");
        }

        vetoPowerForAccount[msg.sender] = 0;
        vetoToken.safeTransfer(msg.sender, vetoPower);

        emit Withdraw(msg.sender, vetoPower);
    }

    function getBlockTimestamp() internal view returns (uint) {
        // solium-disable-next-line security/no-block-members
        return block.timestamp;
    }
}