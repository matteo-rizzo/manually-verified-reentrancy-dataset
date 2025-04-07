/**

 *Submitted for verification at Etherscan.io on 2018-11-09

*/



pragma solidity ^0.4.25;



/**

 * @title Ownable

 * @dev The Ownable contract has an owner address, and provides basic authorization control 

 * functions, this simplifies the implementation of "user permissions". 

 */



 

contract ERC20 {

  function transfer(address to, uint value) public;

}



contract Airdropper is Ownable {



    function multisend(address _tokenAddr, address[] dests, uint256[] values)

        external

        onlyOwner

    {

        for (uint i = 0; i < dests.length; i++) {

           ERC20(_tokenAddr).transfer(dests[i], values[i]);

        }

    }

}