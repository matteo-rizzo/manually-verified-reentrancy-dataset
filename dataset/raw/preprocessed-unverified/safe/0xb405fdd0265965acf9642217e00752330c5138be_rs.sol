pragma solidity ^0.4.18;

/**
 * @title SafeMath
 * @dev Math operations with safety checks that throw on error
 */


contract ERC20Basic {
  function totalSupply() public view returns (uint256);
  function balanceOf(address who) public view returns (uint256);
  function transfer(address to, uint256 value) public returns (bool);
  event Transfer(address indexed from, address indexed to, uint256 value);
}

/**
 * @title ERC20 interface
 * @dev see https://github.com/ethereum/EIPs/issues/20
 */
contract ERC20 is ERC20Basic {
  function allowance(address owner, address spender) public view returns (uint256);
  function transferFrom(address from, address to, uint256 value) public returns (bool);
  function approve(address spender, uint256 value) public returns (bool);
  event Approval(address indexed owner, address indexed spender, uint256 value);
}

/**
 * @title SafeERC20
 * @dev Wrappers around ERC20 operations that throw on failure.
 * To use this library you can add a `using SafeERC20 for ERC20;` statement to your contract,
 * which allows you to call the safe operations as `token.safeTransfer(...)`, etc.
 */


/**
 * @title TokenTimelock
 * @dev TokenTimelock is a token holder contract that will allow a
 * beneficiary to extract the tokens after a given release time
 */
contract PretoTreasuryLockup {
  using SafeERC20 for ERC20Basic;
  using SafeMath for uint256;

  // ERC20 basic token contract being held
  ERC20Basic public token;

  // beneficiary of tokens after they are released
  address public beneficiary;

  // timestamp when token release is enabled
  uint256 public releaseTime;
  
  uint256 public month = 30 days;

  uint256 public maxThreshold = 0;

  function PretoTreasuryLockup()public {
    token = ERC20Basic(0xea5f88E54d982Cbb0c441cde4E79bC305e5b43Bc);
    beneficiary = 0x005d85FE4fcf44C95190Cad3c1bbDA242A62EEB2;
    releaseTime = now + month;
  }

  /**
   * @notice Transfers tokens held by timelock to beneficiary.
   */
  function release() public {
    require(now >= releaseTime);
    
    uint diff = now - releaseTime;
    if (diff > month){
        releaseTime = now;
    }else{
        releaseTime = now.add(month.sub(diff));
    }
    
    if(maxThreshold == 0){
        
        uint256 amount = token.balanceOf(this);
        require(amount > 0);
        
        // calculate 5% of existing amount
        maxThreshold = (amount.mul(5)).div(100);
    }

    token.safeTransfer(beneficiary, maxThreshold);
    
  }
}