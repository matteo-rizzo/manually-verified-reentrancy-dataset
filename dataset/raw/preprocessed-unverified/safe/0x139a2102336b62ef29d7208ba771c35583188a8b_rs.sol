/**
 *Submitted for verification at Etherscan.io on 2019-11-04
*/

//www.structuredeth.com/gift

pragma solidity ^0.4.26;





contract GiftOfCompoundRegistry {
    
    using SafeMath for uint256;
    
    uint256 totalGifted;
    mapping (address=>uint256) addresses;

   
    
    //if smeone sends eth to this contract, throw it because it will just end up getting locked forever
    function() payable {
        throw;
    }
    
    function addGift(address contractAddress, uint256 initialAmount){
        totalGifted = totalGifted.add(initialAmount);
        addresses[contractAddress] = initialAmount;
        
    }
    function totalGiftedAmount()  constant returns (uint256){
        return totalGifted;
    }
    function giftGiven(address theAddress)  constant returns (uint256){
        return addresses[theAddress];
    }
    
    
    
    

    constructor() public {
        
       
        
    }
    
   
}