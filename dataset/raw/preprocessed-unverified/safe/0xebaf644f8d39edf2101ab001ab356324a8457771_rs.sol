/**

 *Submitted for verification at Etherscan.io on 2018-08-28

*/



pragma solidity ^0.4.24;



// File: contracts/ReceivingContractCallback.sol



contract ReceivingContractCallback {



  function tokenFallback(address _from, uint _value) public;



}



// File: contracts/ownership/Ownable.sol



/**

 * @title Ownable

 * @dev The Ownable contract has an owner address, and provides basic authorization control

 * functions, this simplifies the implementation of "user permissions".

 */





// File: contracts/token/ERC20Basic.sol



/**

 * @title ERC20Basic

 * @dev Simpler version of ERC20 interface

 * See https://github.com/ethereum/EIPs/issues/179

 */

contract ERC20Basic {

  function totalSupply() public view returns (uint256);

  function balanceOf(address who) public view returns (uint256);

  function transfer(address to, uint256 value) public returns (bool);

  event Transfer(address indexed from, address indexed to, uint256 value);

}



// File: contracts/IntermediateWallet.sol



contract IntermediateWallet is ReceivingContractCallback, Ownable {

    

  address public token = 0xB36F13C4e2df1b5201e3D64cd79b1897e0E80D39;  



  address public wallet =0xf45aaB548368edfD37997bD6a8Ab74c413dfa48B;



  struct TokenTx {

    address from;

    uint amount;

    uint date;

  }



  TokenTx[] public txs;

  

  constructor() public {



  }



  function setToken(address newTokenAddr) public onlyOwner {

    token = newTokenAddr;

  }

  

  function setWallet(address newWallet) public onlyOwner {

    wallet = newWallet;

  }



  function retrieveTokens(address to, address anotherToken) public onlyOwner {

    ERC20Basic alienToken = ERC20Basic(anotherToken);

    alienToken.transfer(to, alienToken.balanceOf(this));

  }



  function () payable public {

    wallet.transfer(msg.value);

  }



  function tokenFallback(address _from, uint _value) public {

    require(msg.sender == token);

    txs.push(TokenTx(_from, _value, now));

    ERC20Basic(token).transfer(wallet, _value);

  }



}