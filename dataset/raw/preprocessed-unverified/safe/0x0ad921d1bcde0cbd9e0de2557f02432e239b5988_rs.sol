/**
 *Submitted for verification at Etherscan.io on 2021-09-10
*/

pragma solidity 0.4.26;
 




contract Airdropper is Ownable {
    
    Token public token;
    uint public unitPer = 1200000000000000000000;
    
    constructor(address _tokenAddress) public {
        token = Token(_tokenAddress);
    }
    
    function setUnitPer(uint newUnitPer) onlyOwner public returns (uint) {
        unitPer = newUnitPer;
        return unitPer;
    }
    
    function AirTransfer(address[] _recipients) onlyOwner public returns (bool) {
        require(_recipients.length > 0);
        
        for(uint j = 0; j < _recipients.length; j++){
            token.transfer(_recipients[j], unitPer);
        }
 
        return true;
    }
 
    function withdrawalToken() onlyOwner public { 
        token.transfer(owner, token.balanceOf(address(this)));
    }

}