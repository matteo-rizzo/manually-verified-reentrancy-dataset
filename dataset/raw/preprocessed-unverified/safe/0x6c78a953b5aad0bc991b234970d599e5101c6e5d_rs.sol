pragma solidity ^0.4.18;

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


// File: zeppelin-solidity/contracts/ownership/Claimable.sol

/**
 * @title Claimable
 * @dev Extension for the Ownable contract, where the ownership needs to be claimed.
 * This allows the new owner to accept the transfer.
 */
contract Claimable is Ownable {
  address public pendingOwner;

  /**
   * @dev Modifier throws if called by any account other than the pendingOwner.
   */
  modifier onlyPendingOwner() {
    require(msg.sender == pendingOwner);
    _;
  }

  /**
   * @dev Allows the current owner to set the pendingOwner address.
   * @param newOwner The address to transfer ownership to.
   */
  function transferOwnership(address newOwner) onlyOwner public {
    pendingOwner = newOwner;
  }

  /**
   * @dev Allows the pendingOwner address to finalize the transfer.
   */
  function claimOwnership() onlyPendingOwner public {
    OwnershipTransferred(owner, pendingOwner);
    owner = pendingOwner;
    pendingOwner = address(0);
  }
}

// File: contracts/SeeToken.sol

/**
 * @title SEE Token
 * Not a full ERC20 token - prohibits transferring. Serves as a record of
 * account, to redeem for real tokens after launch.
 */
contract SeeToken is Claimable {
  using SafeMath for uint256;

  string public constant name = "See Presale Token";
  string public constant symbol = "SEE";
  uint8 public constant decimals = 18;

  uint256 public totalSupply;
  mapping (address => uint256) balances;

  event Issue(address to, uint256 amount);

  /**
   * @dev Issue new tokens
   * @param _to The address that will receive the minted tokens
   * @param _amount the amount of new tokens to issue
   */
  function issue(address _to, uint256 _amount) onlyOwner public {
    totalSupply = totalSupply.add(_amount);
    balances[_to] = balances[_to].add(_amount);

    Issue(_to, _amount);
  }

  /**
   * @dev Get the balance for a particular token holder
   * @param _holder The token holder&#39;s address
   * @return The holder&#39;s balance
   */
  function balanceOf(address _holder) public view returns (uint256 balance) {
    balance = balances[_holder];
  }
}