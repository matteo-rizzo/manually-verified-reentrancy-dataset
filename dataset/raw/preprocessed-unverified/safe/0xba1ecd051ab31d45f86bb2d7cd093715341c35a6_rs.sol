/**

 *Submitted for verification at Etherscan.io on 2018-12-03

*/



pragma solidity ^0.4.24;



/**

 * @title SafeMath

 * @dev Math operations with safety checks that revert on error

 */





contract Raffle {

    using SafeMath for uint256;

    

    mapping (address => uint256) public balances;



    address public owner;

    address public winner;

  

    address[] public entrants;

    uint256 public numEntrants;

    uint256 public entryPrice;

    uint256 public deadline;

    uint256 public threshold;

    uint256 public percentageTaken;

    

    event PlayerEntered(address participant,uint256 amount,uint256 totalParticipants);

    event Winner(address winner,uint256 amount);

    

    // @param _entryPrice - entry price for each participant in wei i.e. 10^-18 eth.

    // @param _deadline - block number at which you want the crowdsale to end

    // @param _percentageToken - for example, to take 33% of the total use 3, only use integers

    constructor(uint256 _entryPrice, uint256 _deadline, uint256 _percentageTaken,uint256 _thresold) public {

        entryPrice = _entryPrice;

        deadline = _deadline;

        percentageTaken = _percentageTaken;

        threshold = _thresold;

        owner = msg.sender;

    }    



    modifier thresholdReached() {

        require(numEntrants >= threshold, "Below Thresold participant");

        _;

    }



    modifier belowThreshold() {

        require(numEntrants <= threshold, "Above Thresold participant");

        _;

    }



    modifier deadlinePassed() {

        require(now >= deadline, "Deadline is not Passed");

        _;

    }



    modifier deadlineNotPassed() {

        require(now <= deadline,"Deadline is Passed");

        _;

    }



    modifier onlyOwner() {

        require(msg.sender == owner, "You are not Owner");

        _;

    }

    

    modifier pickingWinner() {

        require(winner == 0x0, "Winner is already picked");

        _;

    }

    

    function() public payable {

        enterRaffle();

    }



    function enterRaffle() public payable deadlineNotPassed {

        require(msg.value == entryPrice);

        balances[msg.sender] = balances[msg.sender].add(msg.value);

        numEntrants = numEntrants.add(1);

        entrants.push(msg.sender);

        emit PlayerEntered(msg.sender, msg.value, numEntrants);

    }



    function withdrawFunds(uint amount) public deadlinePassed belowThreshold {

        require(balances[msg.sender] >= amount, "You do not have enough balance");

        balances[msg.sender] = balances[msg.sender].sub(amount);

        (msg.sender).transfer(amount);

    }



    function determineWinner() public onlyOwner deadlinePassed thresholdReached pickingWinner {

        

        uint256 blockSeed = uint256(blockhash(block.number - 1)).div(2);

        uint256 coinbaseSeed = uint256(block.coinbase).div(2);

        uint256 winnerIndex = blockSeed.add(coinbaseSeed).mod(numEntrants);

        winner = entrants[winnerIndex];

        uint256 payout = address(this).balance;

        payout = payout.div(percentageTaken);

        winner.transfer(payout);

        owner.transfer(address(this).balance);

        emit Winner(winner, payout);

    }

}