pragma solidity ^0.4.19;

contract EthereumHole {
    using SafeMath for uint256;


    event NewLeader(
        uint _timestamp,
        address _address,
        uint _newPot,
        uint _newDeadline
    );


    event Winner(
        uint _timestamp,
        address _address,
        uint _earnings,
        uint _deadline
    );


    // Initial countdown duration at the start of each round
    uint public constant BASE_DURATION = 10 minutes;

    // Amount by which the countdown duration decreases per ether in the pot
    uint public constant DURATION_DECREASE_PER_ETHER = 5 minutes;

    // Minimum countdown duration
    uint public constant MINIMUM_DURATION = 5 minutes;
    
     // Minimum fraction of the pot required by a bidder to become the new leader
    uint public constant min_bid = 10000000000000 wei;

    // Current value of the pot
    uint public pot;

    // Address of the current leader
    address public leader;

    // Time at which the current round expires
    uint public deadline;
    
    // Is the game over?
    bool public gameIsOver;

    function EthereumHole() public payable {
        require(msg.value > 0);
        gameIsOver = false;
        pot = msg.value;
        leader = msg.sender;
        deadline = computeDeadline();
        NewLeader(now, leader, pot, deadline);
    }

    function computeDeadline() internal view returns (uint) {
        uint _durationDecrease = DURATION_DECREASE_PER_ETHER.mul(pot.div(1 ether));
        uint _duration;
        if (MINIMUM_DURATION.add(_durationDecrease) > BASE_DURATION) {
            _duration = MINIMUM_DURATION;
        } else {
            _duration = BASE_DURATION.sub(_durationDecrease);
        }
        return now.add(_duration);
    }

    modifier endGameIfNeeded {
        if (now > deadline && !gameIsOver) {
            Winner(now, leader, pot, deadline);
            leader.transfer(pot);
            gameIsOver = true;
        }
        _;
    }

    function bid() public payable endGameIfNeeded {
        if (msg.value > 0 && !gameIsOver) {
            pot = pot.add(msg.value);
            if (msg.value >= min_bid) {
                leader = msg.sender;
                deadline = computeDeadline();
                NewLeader(now, leader, pot, deadline);
            }
        }
    }

}

/**
 * @title SafeMath
 * @dev Math operations with safety checks that throw on error
 */
