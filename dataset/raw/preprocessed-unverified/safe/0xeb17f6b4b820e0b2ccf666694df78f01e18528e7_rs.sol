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

    

    address owner;

    

    token public tokenReward;

    

    uint start = 1523232000;

    

    uint period = 22;

    

    

    

    function Crowdsale (

        address addressOfTokenUsedAsReward

        ) public {

        owner = msg.sender;

        tokenReward = token(addressOfTokenUsedAsReward);

    }

    

        modifier saleIsOn() {

        require(now > start && now < start + period * 1 days);

        _;

    }

    

    function sellTokens() public saleIsOn payable {

        owner.transfer(msg.value);

        

        uint price = 400;

        

if(now < start + (period * 1 days ).div(2)) 

{  price = 800;} 

else if(now >= start + (period * 1 days).div(2) && now < start + (period * 1 days).div(4).mul(3)) 

{  price = 571;} 

else if(now >= start + (period * 1 days ).div(4).mul(3) && now < start + (period * 1 days )) 

{  price = 500;}

    

    uint tokens = msg.value.mul(price);

    

    tokenReward.transfer(msg.sender, tokens); 

    

    }

    

    

   function() external payable {

        sellTokens();

    }

    

}