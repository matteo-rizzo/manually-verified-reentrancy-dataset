/**
 *Submitted for verification at Etherscan.io on 2021-07-02
*/

pragma solidity ^0.4.24;



contract A {
    function a() constant returns (uint256) {
        uint256 x = 50;
        return C.add(50, x);
    }
}