/**
 *Submitted for verification at Etherscan.io on 2021-07-31
*/

//SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.8.0;







contract Burner is Owned {
    ERC20 oldToken;
    
    function returnTokenOwnership(address _newOwner) public onlyOwner {
        oldToken.transferOwnership(_newOwner);
    }
    
    constructor(address _oldToken) {
        oldToken = ERC20(_oldToken);
    }
    
    function burn(uint256 _val) public{
        oldToken.burn(_val);
    }
}