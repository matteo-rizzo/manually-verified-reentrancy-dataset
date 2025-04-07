/**

 *Submitted for verification at Etherscan.io on 2018-10-29

*/



pragma solidity ^0.4.25;



/**

 * @title IERC20

 * @dev Simpler version of ERC20 interface

 * @dev see https://github.com/ethereum/EIPs/issues/20

 */







/**

 * @title Ownable

 * @dev The Ownable contract has an owner address, and provides basic authorization control

 * functions, this simplifies the implementation of "user permissions".

 */





contract Airdropper is Ownable {



    function multisend(address _tokenAddr, address[] dests, uint256[] values)

    onlyOwner public

    returns (uint256) {

        uint256 i = 0;

        while (i < dests.length) {

           if (IERC20(_tokenAddr).transfer(dests[i], values[i])) {

               i += 1;

           }

        }

        return(i);

    }

}