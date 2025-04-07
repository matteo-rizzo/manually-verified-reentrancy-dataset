/**

 *Submitted for verification at Etherscan.io on 2018-11-29

*/



pragma solidity ^0.4.19;



/*

GECO TEMP

Version 1.01

Release date: 2018-11-29

*/



// File: zeppelin-solidity/contracts/math/SafeMath.sol



/**

 * @title SafeMath

 * @dev Math operations with safety checks that throw on error

 */





// File: zeppelin-solidity/contracts/ownership/Ownable.sol



/**

 * @title Ownable

 * @dev The Ownable contract has an owner address, and provides basic authorization control

 * functions, this simplifies the implementation of "user permissions".

 */





contract GECO is Ownable {

  using SafeMath for uint256;

  

  event IncomingTransfer(address indexed to, uint256 amount);

  event ContractFinished();

    

  address public wallet;

  uint256 public endTime;

  uint256 public totalSupply;

  mapping(address => uint256) balances;

  bool public contractFinished = false;

  

  function GECO(address _wallet, uint256 _endTime) public {

    require(_wallet != address(0));

    require(_endTime >= now);

    

    wallet = _wallet;

    endTime = _endTime;

  }

  

  function () external payable {

    require(!contractFinished);

    require(now <= endTime);

      

    totalSupply = totalSupply.add(msg.value);

    balances[msg.sender] = balances[msg.sender].add(msg.value);

    wallet.transfer(msg.value);

    IncomingTransfer(msg.sender, msg.value);

  }

  

  function finishContract() onlyOwner public returns (bool) {

    contractFinished = true;

    ContractFinished();

    return true;

  }

  

  function balanceOf(address _owner) public view returns (uint256 balance) {

    return balances[_owner];

  }

  

  function changeEndTime(uint256 _endTime) onlyOwner public {

    endTime = _endTime;

  }

}