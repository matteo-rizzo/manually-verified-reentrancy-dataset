/**
 *Submitted for verification at Etherscan.io on 2021-04-09
*/

pragma solidity ^0.8.0;

/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
 */


abstract contract ApproveAndCallFallBack {
       function receiveApproval(address from, uint256 tokens, address token, bytes memory data) public virtual;
  }
  


contract Burnbook is ApproveAndCallFallBack{
        
    address _burn_address = address(0x0);
    
    mapping(address => mapping(address=>uint256)) burnedTokens;
    
    constructor(){
 
    }
    
    event tokensBurned(address from, address token, uint256 tokens);
    
    
    function burnTokens(address from, address token, uint256 tokens) public returns (bool){
        
        IERC20(token).transferFrom(from,_burn_address,tokens);
        
        burnedTokens[from][token] = burnedTokens[from][token] + tokens;
        
        emit tokensBurned(from,token,tokens);
        
        return true;
    }
    
    function getBurnedTokensAmount(address burner, address token) public view returns (uint) {
        
        return burnedTokens[burner][token];
    }
    
    
    function receiveApproval(address from, uint256 tokens, address token, bytes memory data) public override{
        burnTokens(from,token,tokens);
    }
    
    
    
    
    
}