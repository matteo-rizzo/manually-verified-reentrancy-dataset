/**
 *Submitted for verification at Etherscan.io on 2020-07-27
*/

// SPDX-License-Identifier: MIT
pragma solidity 0.6.10;



// Tokenizer storage
contract MultiRelease {
    function release(ITokenVesting[] memory tokenVestings, address token) external {
        require(tokenVestings.length > 0);
        for (uint256 i = 0; i < tokenVestings.length; i++) {
            tokenVestings[i].release(token);
        }
    }
}