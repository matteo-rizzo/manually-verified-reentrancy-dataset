/**
 *Submitted for verification at Etherscan.io on 2021-04-30
*/

pragma solidity 0.6.12;

// SPDX-License-Identifier: No License


 


 






contract TokenLock is Ownable {
    using SafeMath for uint256;
    using EnumerableSet for EnumerableSet.AddressSet;
 
  
    
    address public constant tokenAddress = 0xE63d7A762eF855114dc45c94e66365D163B3E5F6;
    address public constant ben = 0xF5Cd56eef13f6De0A4201385eA04bE3ED6572dfc;
    uint public constant tokenQuantity = 11847*1e18;
    uint public  remainingToken = 11847*1e18;
    uint public  releasePercentage = 500;
    uint public  nextClaim = 1638316800;
    uint public  constant frequency = 30 days;
    uint public  currentCycle = 1;
 
  
      
        function releaseAmount() public view returns (uint){
               uint amt = releasePercentage.mul(tokenQuantity).div(1e4) ;
                 if(amt > remainingToken){
                    amt = remainingToken ;
                }
                return amt ;
        }
       

        function claim()  public {               
           require(nextClaim < now, "Wait For next Cycle");
           require(remainingToken > 0, "Pool Ended");
           uint amt = releasePercentage.mul(tokenQuantity).div(1e4) ;

           if(amt > remainingToken){
               amt = remainingToken ;
           }
            nextClaim = now + frequency ;
            currentCycle = currentCycle + 1 ;
            remainingToken = remainingToken.sub(amt) ;
            Token(tokenAddress).transfer(ben, amt);
        }
         
        function withdraw() public onlyOwner{
                msg.sender.transfer(address(this).balance);
        }
        
        
 
    
    
    
         

}