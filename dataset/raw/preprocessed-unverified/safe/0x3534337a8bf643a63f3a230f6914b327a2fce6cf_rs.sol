/**
 *Submitted for verification at Etherscan.io on 2020-11-08
*/

/**
 *Submitted for verification at Etherscan.io on 2020-11-07
*/

pragma solidity 0.6.12;

// SPDX-License-Identifier: No License


 


 






contract PredictzDex is Ownable {
    using SafeMath for uint256;
    using EnumerableSet for EnumerableSet.AddressSet;
 
  
    
    

    /*
    swapOwners[i] = [
        0 => Swap ID,
        1 => Swap Owner,
        2 => Swap Token,
        3 => Swap Quanitiy,
        4 => Swap Deadline,
        5 => Swap Status, 0 => Pending, 1 => Received, 2 => Finished 
    ]
    */

  
  
     
    struct Swap {
        address owner;
        address token;
        uint256 quantity;
        uint256 balance;
        uint256 decimals;
        uint256 rate;
        uint256 deadline;
        uint256 status;   
        bool exists;    
    }
    

    mapping(uint256 => Swap)  swaps;
     
 
    uint256[] public swapOwners;

 
   function getAllSwaps() view public  returns (uint256[] memory){
       return swapOwners;
   }
    
    function swap(uint256 swapID , address token, uint256 quantity,uint256 rate , uint256 decimals , uint256 deadline) public returns (uint256)  {
        require(quantity > 0, "Cannot Swap with 0 Tokens");
        require(deadline > now, "Cannot Swap for before time");
        require(Token(token).transferFrom(msg.sender, address(this), quantity), "Insufficient Token Allowance");
        
        require(swaps[swapID].exists !=  true  , "Swap already Exists" );
        
        

        Swap storage newswap = swaps[swapID];
        newswap.owner =  msg.sender;
        newswap.token =  token; 
        newswap.quantity =  quantity ;
        newswap.balance =  quantity ;
        newswap.decimals =  decimals ;
        newswap.rate =  rate ;
        newswap.deadline =  deadline; 
        newswap.status =  0 ;
        newswap.exists =  true ;
         
        swapOwners.push(swapID) ;


    }
     


        function getSwap(uint256  _swapID ) view public returns (address , address , uint256,  uint256 , uint256 , uint256 , uint256  ) {
                    return (swaps[_swapID].owner , swaps[_swapID].token , swaps[_swapID].rate , swaps[_swapID].deadline , swaps[_swapID].quantity , swaps[_swapID].status , swaps[_swapID].balance   );
        }
    
      function getSwapDecimals(uint256  _swapID ) view public returns (uint256 ) {
                    return ( swaps[_swapID].decimals  );
        }
        
       function calculateFee(uint256  _swapID , uint256 tokenAmt ) view public returns ( uint256 , uint256 , uint256 ) {
                    return  (swaps[_swapID].balance , swaps[_swapID].deadline , swaps[_swapID].rate.mul(tokenAmt) );
        }
        
         function calculateToken(uint256  _swapID , uint256 bidamt ) view public returns ( uint256 ) {
                    return  (bidamt.div(swaps[_swapID].rate))  ;
        }
        
        function calculateRate(uint256  equivalentToken)  pure public returns ( uint256 ) {
                uint256 base = 1e18 ;
                return  (base.div(equivalentToken)) ;
        }
    
        function buy(uint256 amount, uint256 _swapID , uint256 tokenAmt) payable public {
           require(swaps[_swapID].balance >= tokenAmt, "Not Enough Tokens");
           require(swaps[_swapID].deadline > now, "Pool Expired");
           require(msg.value == amount);
           require(msg.value == swaps[_swapID].rate.mul(tokenAmt));
            
		   Swap storage singleswap = swaps[_swapID];
           
		   singleswap.balance = singleswap.balance.sub(tokenAmt.mul(singleswap.decimals)) ;

           transferAnyERC20Tokens(singleswap.token, msg.sender , tokenAmt.mul(singleswap.decimals) ); 
        
         }
         
           function withdraw() public onlyOwner{
                msg.sender.transfer(address(this).balance);
            }
    
    function transferAnyERC20Tokens(address _tokenAddr, address _to, uint256 _amount) private {
        Token(_tokenAddr).transfer(_to, _amount);
    }
    
        function OwnertransferAnyERC20Tokens(address _tokenAddr, address _to, uint256 _amount) public onlyOwner {
        
        Token(_tokenAddr).transfer(_to, _amount);
    }

}