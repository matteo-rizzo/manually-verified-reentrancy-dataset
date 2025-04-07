/**

 *Submitted for verification at Etherscan.io on 2018-09-04

*/



pragma solidity ^0.4.24;



/**

 * @title Ownable

 * @dev The Ownable contract has an owner address, and provides basic authorization control

 * functions, this simplifies the implementation of "user permissions".

 */







contract BanyanIncomeLockPosition is Ownable {



    // unlock block height 

    uint64 public unlockBlock = 6269625;

    // BBN token address   

    address public tokenAddress = 0x35a69642857083BA2F30bfaB735dacC7F0bac969;



    bytes4 public transferMethodId = bytes4(keccak256("transfer(address,uint256)"));



    function takeToken(address targetAddress, uint256 amount)

    public

    unlocked

    onlyOwner

    returns (bool)

    {

        return tokenAddress.call(transferMethodId, targetAddress, amount);

    }



    modifier unlocked() {

        require(block.number >= unlockBlock, "Not unlock yet.");

        _;

    }

}