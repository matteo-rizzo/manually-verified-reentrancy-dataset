/**
 *Submitted for verification at Etherscan.io on 2021-05-18
*/

/**
 *Submitted for verification at Etherscan.io on 2020-09-16
 */

/**
 *Submitted for verification at Etherscan.io on 2020-09-14
 */

pragma solidity ^0.5.16;

// From https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/math/Math.sol
// Subject to the MIT license.

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


contract Timelock {
    using SafeMath for uint256;

    event NewAdmin(address indexed newAdmin);
    event NewPendingAdmin(address indexed newPendingAdmin);
    event NewDelay(uint256 indexed newDelay);
    event CancelTransaction(
        bytes32 indexed txHash,
        address indexed target,
        address lev,
        uint256 amount,
        uint256 eta
    );
    event ExecuteTransaction(
        bytes32 indexed txHash,
        address indexed target,
        address lev,
        uint256 amount,
        uint256 eta
    );
    event QueueTransaction(
        bytes32 indexed txHash,
        address indexed target,
        address lev,
        uint256 amount,
        uint256 eta
    );

    uint256 public constant GRACE_PERIOD = 14 days;
    uint256 public constant MINIMUM_DELAY = 2 days;
    uint256 public constant MAXIMUM_DELAY = 30 days;

    address public admin;
    uint256 public delay;

    mapping(bytes32 => bool) public queuedTransactions;

    constructor(address admin_, uint256 delay_) public {
        require(
            admin_ != address(0),
            "Timelock::constructor: Cannot set the admin to the zero address"
        );
        require(
            delay_ >= MINIMUM_DELAY,
            "Timelock::constructor: Delay must exceed minimum delay."
        );
        require(
            delay_ <= MAXIMUM_DELAY,
            "Timelock::setDelay: Delay must not exceed maximum delay."
        );

        admin = admin_;
        delay = delay_;
    }

    function setDelay(uint256 delay_) external {
        require(
            msg.sender == admin,
            "Timelock::setDelay: Call must come from admin."
        );
        require(
            delay_ >= MINIMUM_DELAY,
            "Timelock::setDelay: Delay must exceed minimum delay."
        );
        require(
            delay_ <= MAXIMUM_DELAY,
            "Timelock::setDelay: Delay must not exceed maximum delay."
        );
        delay = delay_;

        emit NewDelay(delay);
    }

    function acceptAdmin(address pendingAdmin_, uint256 eta) external {
        require(
            msg.sender == admin,
            "Timelock::queueTransaction: Call must come from admin."
        );
        require(
            getBlockTimestamp() >= eta,
            "Timelock::executeTransaction: Transaction hasn't surpassed time lock."
        );

        bytes32 txHash = keccak256(abi.encode(pendingAdmin_, eta));

        require(
            queuedTransactions[txHash],
            "Timelock::executeTransaction: Transaction hasn't been queued."
        );
        queuedTransactions[txHash] = false;
        admin = pendingAdmin_;

        emit NewAdmin(admin);
    }

    function setPendingAdmin(address pendingAdmin_, uint256 eta) external {
        require(
            msg.sender == admin,
            "Timelock::queueTransaction: Call must come from admin."
        );
        require(
            pendingAdmin_ != address(0),
            "Timelock::queueTransaction: Cannot change the admin to the zero address"
        );
        require(
            eta >= getBlockTimestamp().add(delay),
            "Timelock::queueTransaction: Estimated execution block must satisfy delay."
        );

        bytes32 txHash = keccak256(abi.encode(pendingAdmin_, eta));
        queuedTransactions[txHash] = true;

        emit NewPendingAdmin(pendingAdmin_);
    }

    function queueTransaction(
        address target,
        address lev,
        uint256 amount,
        uint256 eta
    ) external returns (bytes32) {
        require(
            msg.sender == admin,
            "Timelock::queueTransaction: Call must come from admin."
        );
        require(
            eta >= getBlockTimestamp().add(delay),
            "Timelock::queueTransaction: Estimated execution block must satisfy delay."
        );

        bytes32 txHash = keccak256(abi.encode(target, lev, amount, eta));
        queuedTransactions[txHash] = true;

        emit QueueTransaction(txHash, target, lev, amount, eta);
        return txHash;
    }

    function cancelTransaction(
        address target,
        address lev,
        uint256 amount,
        uint256 eta
    ) external {
        require(
            msg.sender == admin,
            "Timelock::cancelTransaction: Call must come from admin."
        );

        bytes32 txHash = keccak256(abi.encode(target, lev, amount, eta));
        queuedTransactions[txHash] = false;

        emit CancelTransaction(txHash, target, lev, amount, eta);
    }

    function executeTransaction(
        address target,
        address lev,
        uint256 amount,
        uint256 eta
    ) external {
        require(
            msg.sender == admin,
            "Timelock::executeTransaction: Call must come from admin."
        );

        bytes32 txHash = keccak256(abi.encode(target, lev, amount, eta));
        require(
            queuedTransactions[txHash],
            "Timelock::executeTransaction: Transaction hasn't been queued."
        );
        require(
            getBlockTimestamp() >= eta,
            "Timelock::executeTransaction: Transaction hasn't surpassed time lock."
        );
        require(
            getBlockTimestamp() <= eta.add(GRACE_PERIOD),
            "Timelock::executeTransaction: Transaction is stale."
        );

        queuedTransactions[txHash] = false;

        bool success = ILev(lev).transfer(target, amount);
        require(
            success,
            "Timelock::executeTransaction: Transaction execution reverted."
        );

        emit ExecuteTransaction(txHash, target, lev, amount, eta);
    }

    function getBlockTimestamp() internal view returns (uint256) {
        // solium-disable-next-line security/no-block-members
        return block.timestamp;
    }
}

