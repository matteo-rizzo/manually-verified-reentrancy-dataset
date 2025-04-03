pragma solidity ^0.4.18;

/**
 * @title SafeMath
 * @dev Math operations with safety checks that throw on error
 */


contract token {

  function balanceOf(address _owner) public constant returns (uint256 balance);
  function transfer(address _to, uint256 _value) public returns (bool success);

}



contract lockEtherPay is Ownable {
	using SafeMath for uint256;

  token token_reward;
  address public beneficiary;
  bool public isLocked = false;
  bool public isReleased = false;
  uint256 public start_time;
  uint256 public end_time;
  uint256 public fifty_two_weeks = 30499200;

  event TokenReleased(address beneficiary, uint256 token_amount);

  constructor() public{
    token_reward = token(0xAa1ae5e57dc05981D83eC7FcA0b3c7ee2565B7D6);
    beneficiary =  0xd09C1DEaFDAFA0df4912b3d4567f52d50A6727e0;
  }

  function tokenBalance() constant public returns (uint256){
    return token_reward.balanceOf(this);
  }

  function lock() public onlyOwner returns (bool){
  	require(!isLocked);
  	require(tokenBalance() > 0);
  	start_time = now;
  	end_time = start_time.add(fifty_two_weeks);
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