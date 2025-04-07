/**
 *Submitted for verification at Etherscan.io on 2019-10-27
*/

pragma solidity ^0.5.11;






contract Mortal is Ownable {
    /**
     * kills the contract 
     * */
    function kill() public onlyOwner{
        owner.transfer(address(this).balance);
        selfdestruct(owner);
    }
}



contract Cryptoman is Mortal{

    /**
     * deposit
     * */
    function deposit() public payable {
    }

    /**
     * withdraw 
     * */
    function withdraw(uint amount, address payable receiver) public onlyOwner {
      require(address(this).balance >= amount, "insufficient balance");
      receiver.transfer(amount);
    }
    
    /**
    * withdraw tokens
    * */
    function withdrawTokens(address tokenAddress, uint amount, address payable receiver) public payable onlyOwner {
      ERC20 token = ERC20(tokenAddress);
      require(token.balanceOf(address(this))>=amount,"insufficient funds");
      token.transfer(receiver, amount);
    }


}