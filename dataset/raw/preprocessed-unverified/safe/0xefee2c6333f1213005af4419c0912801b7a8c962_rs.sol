/**
 *Submitted for verification at Etherscan.io on 2021-03-23
*/

pragma solidity ^0.5.0;

// File: @openzeppelin/contracts/math/Math.sol

/**
 * @dev Standard math utilities missing in the Solidity language.
 */


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


contract OneOAKGovernance {
    using SafeMath for uint256;
    
    modifier onlyOwner() {
        require(msg.sender == owner, "Owner required");
        _;
    }
    
    modifier unlocked(uint256 index) {
        require(!isTimelockActivated || block.number > unlockTimes[index], "Locked");
        _;
    }    

    modifier timelockUnlocked() {
        require(!isTimelockActivated || block.number > timelockLengthUnlockTime, "Timelock variable Locked");
        _;
    }

    address public owner;

    uint256 constant DEFAULT_TIMELOCK_LENGTH = 44800; // length in blocks ~7 days;

    mapping(uint256 => address) public pendingValues;
    mapping(uint256 => uint256) public unlockTimes;

    uint256 public timelockLengthUnlockTime = 0;
    uint256 public timelockLength = DEFAULT_TIMELOCK_LENGTH;
    uint256 public nextTimelockLength = DEFAULT_TIMELOCK_LENGTH;

    bool public isTimelockActivated = false;

    mapping(uint256 => address) public governanceContracts;

    constructor () public {    
        owner = msg.sender;
    }

    function activateTimelock() external onlyOwner {
        isTimelockActivated = true;
    }

    function setPendingValue(uint256 index, address value) external onlyOwner {
        pendingValues[index] = value;
        unlockTimes[index] = timelockLength.add(block.number);
    }

    function certifyPendingValue(uint256 index) external onlyOwner unlocked(index) {
        governanceContracts[index] = pendingValues[index];
        unlockTimes[index] = 0;
    }

    function proposeNextTimelockLength(uint256 value) public onlyOwner {
        nextTimelockLength = value;
        timelockLengthUnlockTime = block.number.add(timelockLength);
    }

    function certifyNextTimelockLength() public onlyOwner timelockUnlocked() {
        timelockLength = nextTimelockLength;
        timelockLengthUnlockTime = 0;
    }

    function getGovernanceContract(uint _type) public view returns (address) {
        return governanceContracts[_type];
    }
}