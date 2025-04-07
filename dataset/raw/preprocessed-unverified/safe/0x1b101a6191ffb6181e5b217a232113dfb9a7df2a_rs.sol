/**

 *Submitted for verification at Etherscan.io on 2019-05-19

*/



pragma solidity ^0.5.3;



/**

 * @title Ownable

 * @dev The Ownable contract has an owner address, and provides basic authorization control

 * functions, this simplifies the implementation of "user permissions".

 */





// good enough for a hackathon right?

contract BirdFeeder is Ownable {



   mapping (address => uint) public contributors;

   address[8] public top8;



   uint public lowest; // index of loest entry sometimes

   uint public lowestAmount; // amount of lowest top8 entry



   constructor() public{

   }

   

   // fallback

   function() external payable {



      // bump the users contribution

      contributors[msg.sender] = contributors[msg.sender]+msg.value;

      bool insert = true;



      // pass #1

      for (uint i=0; i<8; i++) {

        

        // see if lowest needs updating

        if(contributors[top8[i]] <= lowestAmount) {

            

            lowestAmount = contributors[top8[i]];

            lowest = i;

        }    

        

        // if user is already in top 8, we're done

        if(top8[i]==msg.sender){

            insert=false;

        }

        

      }

      

      if(contributors[top8[lowest]] < contributors[msg.sender] && insert){

        top8[lowest] = msg.sender; // replace the lowest memeber with 

        lowestAmount = contributors[msg.sender];

      }

      // lets just say the most recent is the lowest now

      // we'll correct that assumption before doing anything with it.

   }

   

   function dispense(address payable dst, uint sum) external onlyOwner {

       dst.transfer(sum);

   }

   

   function getBalance() public view returns (uint){

       return address(this).balance;

   }



}