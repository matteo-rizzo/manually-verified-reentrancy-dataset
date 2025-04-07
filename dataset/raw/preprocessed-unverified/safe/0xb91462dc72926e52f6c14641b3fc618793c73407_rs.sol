/**
 *Submitted for verification at Etherscan.io on 2020-11-09
*/

// SPDX-License-Identifier: MIT

pragma solidity ^0.6.12;



contract TokenLock {
    address public lockedToken;
    address public withdrawAddress = 0xBb85bc74ef98f26b4CaE164516cF25629f2641Eb;
    uint public releaseTime = 1605125871 + 5 minutes;
    
    constructor() public {
        lockedToken = 0xE1c94F1dF9f1A06252da006C623E07982787ceE4;
        
    }

    function lockedTokens() public view returns (uint256) {
        IERC20 token = IERC20(lockedToken);
        return token.balanceOf(address(this));
    }

    function withdrawTokens()  public  {
        require(block.timestamp>releaseTime);
        require(msg.sender == withdrawAddress);
        IERC20 token = IERC20(lockedToken);
        uint256 balancetransfer =  lockedTokens();
        
        token.transfer(address(msg.sender), balancetransfer);
    }
    
}