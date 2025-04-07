/**
 *Submitted for verification at Etherscan.io on 2021-09-06
*/

pragma solidity ^0.5.16;



contract DolaFeed is IFeed {

    function decimals() public view returns(uint8) {
        return 18;
    }

    function latestAnswer() public view returns (uint) {
        return 1 ether;
    }

}