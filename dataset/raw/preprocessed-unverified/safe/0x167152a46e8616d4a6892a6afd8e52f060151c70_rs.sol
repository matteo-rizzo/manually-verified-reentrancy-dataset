/**
 *Submitted for verification at Etherscan.io on 2021-04-15
*/

pragma solidity ^0.8.0;


/*

 ⛏️ Miners Guild ⛏️

 DAO for community-based donations 
 
 Donate to depositors of this contract by sending ERC20 tokens directly to the contract address. 

*/
                                                                                 
  
 






 
 
 
   



 
 
abstract contract ApproveAndCallFallBack {
       function receiveApproval(address from, uint256 tokens, address token, bytes memory data) public virtual;
  }
  
  
  
  
/**
 * 
 * 
 *  Staking contract that supports community-extractable donations 
 *
 */
contract MinersGuild is 
  ApproveAndCallFallBack
{
 
  
  address public _stakeableCurrency; 
  address public _reservePoolToken; 
   
  event Donation(address from, uint256 amount);
   
  constructor(  address stakeableCurrency, address reservePoolToken  ) 
  { 
    
   _stakeableCurrency = stakeableCurrency;
   _reservePoolToken = reservePoolToken;
  }
  
  function donateCurrency(address from, uint256 currencyAmount) public returns (bool){

     require( IERC20(_stakeableCurrency).transferFrom(from, address(this), currencyAmount ), 'transfer failed'  );
     
     emit Donation(from,currencyAmount);

     return true; 
  }
 
  
  function stakeCurrency( address from,  uint256 currencyAmount ) public returns (bool){
       
      uint256 reserveTokensMinted = _reserveTokensMinted(  currencyAmount) ;
     
      require( IERC20(_stakeableCurrency).transferFrom(from, address(this), currencyAmount ), 'transfer failed'  );
          
      MintableERC20(_reservePoolToken).mint(from,  reserveTokensMinted) ;
      
     return true; 
  }
  
   
  function unstakeCurrency( uint256 reserveTokenAmount, address currencyToClaim) public returns (bool){
        
     
      uint256 vaultOutputAmount =  _vaultOutputAmount( reserveTokenAmount, currencyToClaim );
        
        
      MintableERC20(_reservePoolToken).burn(msg.sender,  reserveTokenAmount ); 
      
       
      IERC20(currencyToClaim).transfer( msg.sender, vaultOutputAmount );
       
      
      
     return true; 
  }
  

    //amount of reserve tokens to give to staker 
  function _reserveTokensMinted(  uint256 currencyAmount ) public view returns (uint){

      uint256 totalReserveTokens = IERC20(_reservePoolToken).totalSupply();


      uint256 internalVaultBalance =  IERC20(_stakeableCurrency).balanceOf(address(this)); 
      
     
      if(totalReserveTokens == 0 || internalVaultBalance == 0 ){
        return currencyAmount;
      }
      
      
      uint256 incomingTokenRatio = (currencyAmount*100000000) / internalVaultBalance;
       
       
      return ( ( totalReserveTokens)  * incomingTokenRatio) / 100000000;
  }
  
  
    //amount of output tokens to give to redeemer
  function _vaultOutputAmount(   uint256 reserveTokenAmount, address currencyToClaim ) public view returns (uint){

      uint256 internalVaultBalance = IERC20(currencyToClaim ).balanceOf(address(this));
      

      uint256 totalReserveTokens = IERC20(_reservePoolToken).totalSupply();
 
       
      uint256 burnedTokenRatio = (reserveTokenAmount*100000000) / totalReserveTokens  ;
      
       
      return (internalVaultBalance * burnedTokenRatio) / 100000000;
  }

 
  
  
    function receiveApproval(address from, uint256 tokens, address token, bytes memory data) public override{
      require(token == _stakeableCurrency);
      
       stakeCurrency(from, tokens);  
    }
    
   
     // ------------------------------------------------------------------------

    // Don't accept ETH

    // ------------------------------------------------------------------------
 
    fallback() external payable { revert(); }
    receive() external payable { revert(); }
   

}