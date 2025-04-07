/**

 *Submitted for verification at Etherscan.io on 2018-09-17

*/



pragma solidity ^0.4.24;



/**

* @title SafeMath

* @dev Math operations with safety checks that throw on error

*/





contract token {



  function balanceOf(address _owner) public constant returns (uint256 balance);

  function transfer(address _to, uint256 _value) public returns (bool success);



}







contract LockToken is Ownable {

    using SafeMath for uint256;



  token token_reward;

  address public beneficiary;

  bool public isLocked = false;

  bool public isReleased = false;

  uint256 public start_time;

  uint256 public end_time;

  

  event TokenReleased(address beneficiary, uint256 token_amount);



  constructor(address tokenContractAddress, address _beneficiary) public{

    token_reward = token(tokenContractAddress);

    beneficiary = _beneficiary;

  }



  function tokenBalance() constant public returns (uint256){

    return token_reward.balanceOf(this);

  }



  function lock(uint256 lockTime) public onlyOwner returns (bool){

      require(!isLocked);

      require(tokenBalance() > 0);

      start_time = now;

      end_time = lockTime;

      isLocked = true;

  }



  function lockOver() constant public returns (bool){

      uint256 current_time = now;

    return current_time > end_time;

  }



    function release() onlyOwner public{

    require(isLocked);

    require(!isReleased);

    require(lockOver());

    uint256 token_amount = tokenBalance();

    token_reward.transfer( beneficiary, token_amount);

    emit TokenReleased(beneficiary, token_amount);

    isReleased = true;

  }

}