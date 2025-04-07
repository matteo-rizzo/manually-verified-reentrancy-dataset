pragma solidity ^0.4.24;

contract ERC20Basic {
  function totalSupply() public view returns (uint256);
  function balanceOf(address who) public view returns (uint256);
  function transfer(address to, uint256 value) public returns (bool);
  event Transfer(address indexed from, address indexed to, uint256 value);
}

/**
 * @title SafeERC20
 * @dev Wrappers around ERC20 operations that throw on failure.
 * To use this library you can add a `using SafeERC20 for ERC20;` statement to your contract,
 * which allows you to call the safe operations as `token.safeTransfer(...)`, etc.
 */


/**
 * @title SafeMath
 * @dev Math operations with safety checks that throw on error
 */


/**
 * @title Ownable
 * @dev The Ownable contract has an owner address, and provides basic authorization control
 * functions, this simplifies the implementation of "user permissions".
 */


/**
 * @title DragonAdvisors
 * @dev DragonAdvisors works like a tap and release tokens periodically
 * to advisors on the owners permission 
 */
contract DragonAdvisors is Ownable{
  using SafeERC20 for ERC20Basic;
  using SafeMath for uint256;

  // ERC20 basic token contract being held
  ERC20Basic public token;

  // advisor address
  address public advisor;

  // amount of tokens available for release
  uint256 public releasedTokens;
  
  event TokenTapAdjusted(uint256 released);

  constructor() public {
    token = ERC20Basic(0x814F67fA286f7572B041D041b1D99b432c9155Ee);
    owner = address(0xA5101498679Fa973c5cF4c391BfF991249934E73);      // overriding owner

    advisor = address(0x050bb8D9Fc423227A49AD8B4F14f844Db3E52f31);
    
    releasedTokens = 0;
  }

  /**
   * @notice release tokens held by the contract to advisor.
   */
  function release(uint256 _amount) public {
    require(_amount > 0);
    require(releasedTokens >= _amount);
    releasedTokens = releasedTokens.sub(_amount);
    
    uint256 balance = token.balanceOf(this);
    require(balance >= _amount);
    

    token.safeTransfer(advisor, _amount);
  }
  
  /**
   * @notice Owner can move tokens to any address
   */
  function transferTokens(address _to, uint256 _amount) external {
    require(_to != address(0x00));
    require(_amount > 0);

    uint256 balance = token.balanceOf(this);
    require(balance >= _amount);

    token.safeTransfer(_to, _amount);
  }
  
  function adjustTap(uint256 _amount) external onlyOwner{
      require(_amount > 0);
      uint256 balance = token.balanceOf(this);
      require(_amount <= balance);
      releasedTokens = _amount;
      emit TokenTapAdjusted(_amount);
  }
  
  function () public payable {
      revert();
  }
}