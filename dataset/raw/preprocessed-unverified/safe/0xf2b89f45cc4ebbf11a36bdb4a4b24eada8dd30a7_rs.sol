pragma solidity ^0.4.19;



/**

 * @title Token

 * @dev Simpler version of ERC20 interface

 */

contract Token {

  function transfer(address to, uint256 value) public returns (bool);

  event Transfer(address indexed from, address indexed to, uint256 value);

}







contract AirDrop is Ownable {



  // This declares a state variable that would store the contract address

  Token public tokenInstance;



  /*

    constructor function to set token address

   */

  function AirDrop(address _tokenAddress){

    tokenInstance = Token(_tokenAddress);

  }



  /*

    Airdrop function which take up a array of address,token amount and eth amount and call the

    transfer function to send the token plus send eth to the address is balance is 0

   */

  function doAirDrop(address[] _address, uint256[] _amount, uint256 _ethAmount) onlyOwner public returns (bool) {

    uint256 count = _address.length;

    for (uint256 i = 0; i < count; i++)

    {

      /* calling transfer function from contract */

      tokenInstance.transfer(_address [i],_amount [i]);

      if((_address [i].balance == 0) && (this.balance >= _ethAmount))

      {

        require(_address [i].send(_ethAmount));

      }

    }

  }





  function transferEthToOnwer() onlyOwner public returns (bool) {

    require(owner.send(this.balance));

  }



  /*

    function to add eth to the contract

   */

  function() payable {



  }



  /*

    function to kill contract

  */



  function kill() onlyOwner {

    selfdestruct(owner);

  }

}