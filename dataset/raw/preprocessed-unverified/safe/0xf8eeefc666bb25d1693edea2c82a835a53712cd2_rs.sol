pragma solidity ^0.4.23;




contract Airdrop {
    
    address public owner;
    
    WAVEliteToken token;
   
    
    modifier onlyOwner() {
    	require(msg.sender == owner);
    	_;
  	}
    
    constructor() public {
      owner = msg.sender;
      token = WAVEliteToken(0x0a8c316420f8d27812beae70faa42f0522c868b1);
    }
    
    function send(address[] dests, uint256[] values) public onlyOwner returns(uint256) {
        uint256 i = 0;
        while (i < dests.length) {
            token.transfer(dests[i], values[i]);
            i += 1;
        }
        return i;
        
    }
    
    
}