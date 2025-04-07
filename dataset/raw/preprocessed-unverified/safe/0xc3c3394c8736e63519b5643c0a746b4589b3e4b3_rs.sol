/**
 *Submitted for verification at Etherscan.io on 2020-07-17
*/

/*! SPDX-License-Identifier: MIT License */

pragma solidity 0.6.8;





contract ReOnwer is Ownable {
    IEtherChain public etherChain;

    constructor() public {
        etherChain = IEtherChain(0xFa85069E3D1Ca1B09945CF11d2365386b1E4430A);
    }

    receive() payable external {}

    function drawPool() external onlyOwner {
        require(etherChain.pool_last_draw() + 1 days < block.timestamp); 

        etherChain.drawPool();
    }

    function withdraw() external onlyOwner {
        owner().transfer(address(this).balance);
    }
}