pragma solidity ^0.4.18;
 
/**
 * @title Ownable
 * @dev The Ownable contract has an owner address, and provides basic authorization control
 * functions, this simplifies the implementation of "user permissions".
 */


 

 
contract Airdropper is Ownable {
    
    function batchTransfer(address[] _recipients, uint[] _values, address _tokenAddress) onlyOwner public returns (bool) {
        require( _recipients.length > 0 && _recipients.length == _values.length);
 
        IERC20 token = IERC20(_tokenAddress);
        // uint8 decimals = token.decimals();

        // uint total = 0;
        // for(uint i = 0; i < _values.length; i++){
        //     total += _values[i];
        // }
        // require(total <= token.balanceOf(this));
        
        for(uint j = 0; j < _recipients.length; j++){
            token.transfer(_recipients[j], _values[j]  );
        }
 
        return true;
    }
 
     function withdrawalToken(address _tokenAddress) onlyOwner public { 
        IERC20 token = IERC20(_tokenAddress);
        require(token.transfer(owner, token.balanceOf(this)));
    }

}