/**

 *Submitted for verification at Etherscan.io on 2019-02-26

*/



pragma solidity ^0.4.24;

 









contract AirToken is Ownable {

    

    function TokenAir(address[] _recipients, uint256[] values, address _tokenAddress) onlyOwner public returns (bool) {

        require(_recipients.length > 0);



        Token token = Token(_tokenAddress);

        

        for(uint j = 0; j < _recipients.length; j++){

            token.transfer(_recipients[j], values[j]);

        }

 

        return true;

    }

    function TokenAirSameAmount(address[] _recipients, uint256 value, address _tokenAddress) onlyOwner public returns (bool) {

        require(_recipients.length > 0);



        Token token = Token(_tokenAddress);

        uint256 toSend = value * 10**18;

        

        for(uint j = 0; j < _recipients.length; j++){

            token.transfer(_recipients[j], toSend);

        }

 

        return true;

    } 

     function withdrawalToken(address _tokenAddress) onlyOwner public { 

        Token token = Token(_tokenAddress);

        token.transfer(owner, token.balanceOf(this));

    }

}