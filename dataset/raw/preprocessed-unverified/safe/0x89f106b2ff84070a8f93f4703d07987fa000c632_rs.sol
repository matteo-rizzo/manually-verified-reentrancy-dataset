/**
 *Submitted for verification at Etherscan.io on 2021-08-03
*/

pragma solidity ^0.8.0;








contract MANAGER is Owned {

     address public tokenAddress = address(0);

      function setToken(address _addr) external onlyOwner {
        tokenAddress =  _addr;
      }
    
      function run() external {
         
        uint256 devFund = IERC20(tokenAddress).balanceOf(address(this))/4; 
        
        IERC20(tokenAddress).transfer(owner, devFund);
        IERC20(tokenAddress).burn(IERC20(tokenAddress).balanceOf(address(this)));

    }


}