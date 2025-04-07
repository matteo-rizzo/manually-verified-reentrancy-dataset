pragma solidity ^0.4.24;



contract ERC20Basic {
  function totalSupply() public view returns (uint256);
  function balanceOf(address who) public view returns (uint256);
  function transfer(address to, uint256 value) public returns (bool);
  event Transfer(address indexed from, address indexed to, uint256 value);
}

contract ERC20 is ERC20Basic {
  function allowance(address owner, address spender) public view returns (uint256);
  function transferFrom(address from, address to, uint256 value) public returns (bool);
  function approve(address spender, uint256 value) public returns (bool);
  event Approval(address indexed owner, address indexed spender, uint256 value);
}



/**
 * @title JunketLockup
 * @dev JunketLockup is a token holder contract that will allow a
 * beneficiary to extract the tokens after a given release time
 */
contract CambodieJunket{
  using SafeERC20 for ERC20Basic;
  using SafeMath for uint256;

  // ERC20 basic token contract being held
  ERC20Basic public token;

  // beneficiary of tokens after they are released
  address public beneficiary;

  // timestamp when token release is enabled
  uint256 public releaseTime;

  uint256 public unlocked = 0;
  
  bool public withdrawalsInitiated = false;
  
  uint256 public year = 365 days; // equivalent to one year

  constructor() public {
    token = ERC20Basic(0x814F67fA286f7572B041D041b1D99b432c9155Ee);
    
    beneficiary = address(0xdFEfd080AE6887AC4221c7479b59677b017c9996);
    
    releaseTime = now + year;
  }

  /**
   * @notice Transfers tokens held by timelock to beneficiary.
   */
  function release(uint256 _amount) public {
    
    uint256 balance = token.balanceOf(address(this));
    require(balance > 0);
    
    if(!withdrawalsInitiated){
        // unlock 50% of existing balance
        unlocked = balance.div(2);
        withdrawalsInitiated = true;
    }
    
    if(now >= releaseTime){
        unlocked = balance;
    }
    
    require(_amount <= unlocked);
    unlocked = unlocked.sub(_amount);
    
    token.safeTransfer(beneficiary, _amount);
    
  }
  
  function balanceOf() external view returns(uint256){
      return token.balanceOf(address(this));
  }
  
  function currentTime() external view returns(uint256){
      return now;
  }
}