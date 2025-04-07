pragma solidity ^0.4.18;

/**
 * @title ERC20Basic
 * @dev Simpler version of ERC20 interface
 * @dev see https://github.com/ethereum/EIPs/issues/179
 */
contract ERC20Basic {
  uint256 public totalSupply;
  function balanceOf(address who) public constant returns (uint256);
  function transfer(address to, uint256 value) public returns (bool);
  event Transfer(address indexed from, address indexed to, uint256 value);
}

/**
 * @title ERC20 interface
 * @dev see https://github.com/ethereum/EIPs/issues/20
 */
contract ERC20 is ERC20Basic {
  function allowance(address owner, address spender) public constant returns (uint256);
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
 * @title Ownable
 * @dev The Ownable contract has an owner address, and provides basic authorization control
 * functions, this simplifies the implementation of "user permissions".
 */


/**
 * @title SafeMath
 * @dev Math operations with safety checks that throw on error
 */


/**
 * @title ModulumTokenHolder
 * @dev ModulumTokenHolder is a smart contract which purpose is to hold and lock
 * HTO&#39;s token supply for 1.5years following Modulum ICO
 * 
*/
contract ModulumTokenHolder is Ownable {
  using SafeMath for uint256;
  using SafeERC20 for ERC20Basic;

  event Released(uint256 amount);

  // beneficiary of tokens after they are released
  address public beneficiary;

  // Lock start date
  uint256 public start;
  // Lock period
  uint256 constant public DURATION = 547 days;

  /**
   * @dev Contructor
   */
  function ModulumTokenHolder(address _beneficiary, uint256 _start) {
    require(_beneficiary != address(0));

    beneficiary = _beneficiary;
    start = _start;
  }

  /**
   * @dev Release MDL tokens held by this smart contract only after the timelock period
   */
  function releaseHTOSupply(ERC20Basic token) onlyOwner public {
    require(now >= start.add(DURATION));
    require(token.balanceOf(this) > 0);
    uint256 releasable = token.balanceOf(this);

    token.safeTransfer(beneficiary, releasable);

    Released(releasable);
  }
}