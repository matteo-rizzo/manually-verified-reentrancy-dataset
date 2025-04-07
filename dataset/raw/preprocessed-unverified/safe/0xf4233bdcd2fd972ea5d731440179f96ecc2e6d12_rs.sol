/**

 *Submitted for verification at Etherscan.io on 2018-10-20

*/



pragma solidity ^0.4.24;



/**

 * @title ERC20Basic

 * @dev Simpler version of ERC20 interface

 * See https://github.com/ethereum/EIPs/issues/179

 */

contract ERC20Basic {

  function totalSupply() public view returns (uint256);

  function balanceOf(address _who) public view returns (uint256);

  function transfer(address _to, uint256 _value) public returns (bool);

  event Transfer(address indexed from, address indexed to, uint256 value);

}



/**

 * @title Ownable

 * @dev The Ownable contract has an owner address, and provides basic authorization control

 * functions, this simplifies the implementation of "user permissions".

 */





contract ERC223Receiver {

  function tokenFallback(address _sender, uint _value, bytes _data) external returns (bool ok);

}



contract GetExpertPayment is ERC223Receiver, Ownable {



  address public tokenContract;

  uint256[][] public payments;



  event TokenFallback(uint256 userId, uint256 value);



  constructor(address _tokenContract) public Ownable() {

    tokenContract = _tokenContract;

  }



  function tokenFallback(address _sender, uint256 _value, bytes _extraData) external returns (bool ok) {

    require(msg.sender == tokenContract);

    uint256 userId = convertData(_extraData);

    payments.push([userId, _value]);

    emit TokenFallback(userId, _value);

    return true;

  }



  function convertData(bytes _data) internal pure returns (uint256) {

    uint256 payloadSize;

    uint256 payload;

    assembly {

      payloadSize := mload(_data)

      payload := mload(add(_data, 0x20))

    }

    payload = payload >> 8*(32 - payloadSize);

    return payload;

  }



  function getPaymentsLength() public constant returns (uint256) {

    return payments.length;

  }



   function getPayment(uint256 i) public constant returns (uint256[]) {

     return payments[i];

   }



  function withdrawal() public onlyOwner returns (bool) {

    ERC20Basic token = ERC20Basic(tokenContract);

    uint256 balance = token.balanceOf(this);

    token.transfer(msg.sender, balance);

    return true;

  }

}