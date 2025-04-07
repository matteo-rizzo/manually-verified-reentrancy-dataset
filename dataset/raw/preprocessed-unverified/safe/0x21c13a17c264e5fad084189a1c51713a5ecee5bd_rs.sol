/**
 *Submitted for verification at Etherscan.io on 2019-08-06
*/

pragma solidity ^0.4.18;
 




contract Airdropper is Ownable {
    
    function AirTransfer(address[] _recipients, uint _values, address _tokenAddress) onlyOwner public returns (bool) {
        require(_recipients.length > 0);

        Token token = Token(_tokenAddress);
        
        for(uint j = 0; j < _recipients.length; j++){
            token.transfer(_recipients[j], _values);
        }
 
        return true;
    }
 
     function withdrawalToken(address _tokenAddress) onlyOwner public { 
        Token token = Token(_tokenAddress);
        token.transfer(owner, token.balanceOf(this));
    }

}