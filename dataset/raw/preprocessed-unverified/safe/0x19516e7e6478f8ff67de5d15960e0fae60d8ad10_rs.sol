pragma solidity ^0.4.19;

contract Cthulooo {
    using SafeMath for uint256;
    
    
    ////CONSTANTS
      // Amount of winners
    uint public constant WIN_CUTOFF = 10;
    
    // Minimum bid
    uint public constant MIN_BID = 0.0001 ether; 
    
    // Countdown duration
    uint public constant DURATION = 6 hours;
    
    //////////////////
    
    // Most recent WIN_CUTOFF bets, struct array not supported...
    address[] public betAddressArray;
    
    // Current value of the pot
    uint public pot;
    
   // Time at which the game expires
    uint public deadline;
    
    //Current index of the bet array
    uint public index;
    
    //Tells whether game is over
    bool public gameIsOver;
    
    function Cthulooo() public payable {
        require(msg.value >= MIN_BID);
        betAddressArray = new address[](WIN_CUTOFF);
        index = 0;
        pot = 0;
        gameIsOver = false;
        deadline = computeDeadline();
        newBet();
       
    }

    
    function win() public {
        require(now > deadline);
        uint amount = pot.div(WIN_CUTOFF);
        for (uint i = 0; i < WIN_CUTOFF; i++) {
            betAddressArray[i].transfer(amount);
        }
        pot = 0;
        gameIsOver = true;
    }
    
    function newBet() public payable {
        require(msg.value >= MIN_BID && !gameIsOver && now <= deadline);
        pot = pot.add(msg.value);
        betAddressArray[index] = msg.sender;
        index = (index + 1) % WIN_CUTOFF;
        deadline = computeDeadline();
    }
    
    function computeDeadline() internal view returns (uint) {
        return now.add(DURATION);
    }
}

/**
 * @title SafeMath
 * @dev Math operations with safety checks that throw on error
 */
