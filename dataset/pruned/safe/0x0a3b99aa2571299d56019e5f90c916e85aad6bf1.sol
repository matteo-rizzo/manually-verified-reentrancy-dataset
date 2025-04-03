pragma solidity ^0.4.20;

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

/**
 * @title ERC20Basic
 * @dev Simpler version of ERC20 interface
 * @dev see https://github.com/ethereum/EIPs/issues/179
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
contract TokenTimelock is Claimable {
  using SafeERC20 for ERC20Basic;
  using SafeMath for uint256;
  // ERC20 basic token contract being held
  ERC20Basic public token;
  
  // tokens deposited.
  uint256 public tokenBalance;
  // beneficiary of tokens after they are released
  mapping (address => uint256) public beneficiaryMap;
  // timestamp when token release is enabled
  uint256 public releaseTime;

  function TokenTimelock(ERC20Basic _token, uint256 _releaseTime) public {
    require(_releaseTime > now);
    token = _token;
    releaseTime = _releaseTime;
  }

  function isAvailable() public view returns (bool){
    if(now >= releaseTime){
      return true;
    } else { 
      return false; 
    }
  }

  /**
     * @param _beneficiary address to lock tokens
     * @param _amount number of tokens
     */
  function depositTokens(address _beneficiary, uint256 _amount)
      public
      onlyOwner
  {
      // Confirm tokens transfered
      require(tokenBalance.add(_amount) == token.balanceOf(this));
      tokenBalance = tokenBalance.add(_amount);

      // Increment total tokens owed.
      beneficiaryMap[_beneficiary] = beneficiaryMap[_beneficiary].add(_amount);
  }

  /**
   * @notice Transfers tokens held by timelock to beneficiary.
   */
  function release() public {
    require(now >= releaseTime);

    // Get tokens owed, then set to 0 before proceeding.
    uint256 amount = beneficiaryMap[msg.sender];
    beneficiaryMap[msg.sender] = 0;

    // Proceed only of there are tokens to send.
    require(amount > 0 && token.balanceOf(this) > 0);

    token.safeTransfer(msg.sender, amount);
  }
}