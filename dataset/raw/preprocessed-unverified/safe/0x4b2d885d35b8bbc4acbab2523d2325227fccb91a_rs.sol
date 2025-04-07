/**
 *Submitted for verification at Etherscan.io on 2019-10-24
*/

pragma solidity 0.5.11;

// ----------------------------------------------------------------------------
// Owned contract
// ----------------------------------------------------------------------------


contract Random is Owned {

    uint256 public winner;
    uint nonce = 0;
    event generatedRandomNumber(uint256 randomNumber);
    
    constructor(address _owner) public {
        owner = _owner;
    }
    
    function random(uint256 minimum, uint256 maximum) public onlyOwner returns (uint) {
       require(maximum > 0);
       nonce += 1;
       uint range = maximum - minimum;
       uint randomNumber = 1;
       if(maximum > 1)
            randomNumber = (uint(keccak256(abi.encodePacked(nonce, msg.sender, blockhash(block.number - 1)))) % range);
       winner = randomNumber + minimum;
       emit generatedRandomNumber(winner);
       return winner;
    }
    
}