pragma solidity ^0.4.18;




/**
 * @title SafeMath
 * @dev Math operations with safety checks that throw on error
 */


/**
 * @title Ownable
 * @dev The Ownable contract has an owner address, and provides basic authorization control
 * functions, this simplifies the implementation of "user permissions".
 */


contract Crowdsale is Ownable {
    
    using SafeMath for uint;
    
    address public escrow;
    
    token public tokenReward;
    
    uint start = 1525132800;
    
    uint period = 31;
    
    
    
    function Crowdsale (
        
        
        ) public {
        escrow = 0x8bB3E0e70Fa2944DBA0cf5a1AF6e230A9453c647;
        tokenReward = token(0xACE380244861698DBa241C4e0d6F8fFc588A6F73);
    }
    
        modifier saleIsOn() {
        require(now > start && now < start + period * 1 days);
        _;
    }
    
    function sellTokens() public saleIsOn payable {
        escrow.transfer(msg.value);
        
        uint price = 400;
        
    
    uint tokens = msg.value.mul(price);
    
    tokenReward.transfer(msg.sender, tokens); 
    
    }
    
    
   function() external payable {
        sellTokens();
    }
    
}