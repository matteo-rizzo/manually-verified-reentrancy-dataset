pragma solidity ^0.4.18;

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
 * @title Pausable
 * @dev Base contract which allows children to implement an emergency stop mechanism.
 */
contract Pausable is Ownable {
  event Pause();
  event Unpause();

  bool public paused = false;


  /**
   * @dev Modifier to make a function callable only when the contract is not paused.
   */
  modifier whenNotPaused() {
    require(!paused);
    _;
  }

  /**
   * @dev Modifier to make a function callable only when the contract is paused.
   */
  modifier whenPaused() {
    require(paused);
    _;
  }

  /**
   * @dev called by the owner to pause, triggers stopped state
   */
  function pause() onlyOwner whenNotPaused public {
    paused = true;
    Pause();
  }

  /**
   * @dev called by the owner to unpause, returns to normal state
   */
  function unpause() onlyOwner whenPaused public {
    paused = false;
    Unpause();
  }
}


contract PrivateSaleTimToken is Pausable {
    using SafeMath for uint;

    string public constant name = "Private Sale Tim Token";
    uint public fiatValueMultiplier = 10 ** 6;
    uint public tokenDecimals = 10 ** 18;
    uint public ethUsdRate;

    mapping(address => uint) investors;
    mapping(address => uint) public tokenHolders;

    address beneficiary;

    modifier allowedToPay(){
        require(investors[msg.sender] > 0);
        _;
    }

    function setRate(uint rate) external onlyOwner {
        require(rate > 0);
        ethUsdRate = rate;
    }

    function setInvestorStatus(address investor, uint bonus) external onlyOwner {
        require(investor != 0x0);
        investors[investor] = bonus;
    }

    function setBeneficiary(address investor) external onlyOwner {
        beneficiary = investor;
    }

    function() payable public whenNotPaused allowedToPay{
        uint tokens = msg.value.mul(ethUsdRate).div(fiatValueMultiplier);
        uint bonus = tokens.div(100).mul(investors[msg.sender]);
        tokenHolders[msg.sender] = tokens.add(bonus);
        beneficiary.transfer(msg.value);
    }
}