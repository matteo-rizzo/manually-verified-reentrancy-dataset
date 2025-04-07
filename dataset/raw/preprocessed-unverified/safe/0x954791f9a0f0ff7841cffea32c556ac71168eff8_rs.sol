pragma solidity 0.4.23;

// Random lottery
// Smart contracts can't bet

// Pay 0.001 to get a random number
// If your random number is the highest so far you're in the lead
// If no one beats you in 1 day you can claim your winnnings - the entire balance.

contract RandoLotto {
    
    uint256 PrizePool;
    uint256 highScore;
    address currentWinner;
    uint256 lastTimestamp;
    
    constructor () public {
        highScore = 0;
        currentWinner = msg.sender;
        lastTimestamp = now;
    }
    
    function () public payable {
        require(msg.sender == tx.origin);
        require(msg.value >= 0.001 ether);
    
        uint256 randomNumber = uint256(keccak256(blockhash(block.number - 1)));
        
        if (randomNumber > highScore) {
            currentWinner = msg.sender;
            lastTimestamp = now;
        }
    }
    
    function claimWinnings() public {
        require(now > lastTimestamp + 1 days);
        require(msg.sender == currentWinner);
        
        msg.sender.transfer(address(this).balance);
    }
}

/**
 * @title SafeMath
 * @dev Math operations with safety checks that throw on error
 */
