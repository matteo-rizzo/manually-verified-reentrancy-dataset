pragma solidity ^0.4.18;



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



contract Destructible is Ownable {

  function Destructible() public payable { }

  /**
   * @dev Transfers the current balance to the owner and terminates the contract.
   */
  function destroy() onlyOwner public {
    selfdestruct(owner);
  }

  function destroyAndSend(address _recipient) onlyOwner public {
    selfdestruct(_recipient);
  }
}

contract ProfitSharing is Ownable, Destructible, Pausable {
    using SafeMath for uint256;

    struct Period {
        uint128 endTime;
        uint128 block;
        uint128 balance;
    }

    // public
    BalanceHistoryToken public token;
    uint256 public periodDuration;
    Period public currentPeriod;
    mapping(address => mapping(uint => bool)) public payments;

    // internal

    // events
    event PaymentCompleted(address indexed requester, uint indexed paymentPeriodBlock, uint amount);
    event PeriodReset(uint block, uint endTime, uint balance, uint totalSupply);

    /// @dev Constructor of the contract
    function ProfitSharing(address _tokenAddress) public {
        periodDuration = 4 weeks;
        resetPeriod();
        token = BalanceHistoryToken(_tokenAddress);
    }

    /// @dev Default payable fallback. 
    function () public payable {
    }

    /// @dev Withdraws the full amount shared with the sender.
    function withdraw() public whenNotPaused {
        withdrawFor(msg.sender);
    }

    /// @dev Allows someone to call withdraw on behalf of someone else. 
    /// Useful if we expose via web3 but metamask account is different than owner of tokens.
    function withdrawFor(address tokenOwner) public whenNotPaused {
        // Ensure that this address hasn&#39;t been previously paid out for this period.
        require(!payments[tokenOwner][currentPeriod.block]);
        
        // Check if it is time to calculate the next payout period.
        resetPeriod();

        // Calculate the amount of the current payout period
        uint payment = getPaymentTotal(tokenOwner);
        require(payment > 0);
        assert(this.balance >= payment);

        payments[tokenOwner][currentPeriod.block] = true;
        PaymentCompleted(tokenOwner, currentPeriod.block, payment);
        tokenOwner.transfer(payment);
    }

    /// @dev Resets the period given the duration of the current period
    function resetPeriod() internal {
        uint nowTime = getNow();
        if (currentPeriod.endTime < nowTime) {
            currentPeriod.endTime = uint128(nowTime.add(periodDuration)); 
            currentPeriod.block = uint128(block.number);
            currentPeriod.balance = uint128(this.balance);
            if (token != address(0x0)) {
                PeriodReset(block.number, nowTime.add(periodDuration), this.balance, token.totalSupply());
            }
        }
    }

    /// @dev Gets the total payment amount for the sender given the current period.
    function getPaymentTotal(address tokenOwner) public constant returns (uint256) {
        if (payments[tokenOwner][currentPeriod.block]) {
            return 0;
        }

        // Get the amount of balance at the beginning of the payment period
        uint tokenOwnerBalance = token.balanceOfAtBlock(tokenOwner, currentPeriod.block);

        // Calculate the amount of the current payout period
        return calculatePayment(tokenOwnerBalance);
    }

    /// @dev Updates the token address of the payment type.
    function updateToken(address tokenAddress) public onlyOwner {
        token = BalanceHistoryToken(tokenAddress);
    }

    /// @dev Calculates the payment given the sender balance for the current period.
    function calculatePayment(uint tokenOwnerBalance) public constant returns(uint) {
        return tokenOwnerBalance.mul(currentPeriod.balance).div(token.totalSupply());
    }

    /// @dev Internal function for mocking purposes
    function getNow() internal view returns (uint256) {
        return now;
    }

    /// @dev Updates the period duration
    function updatePeriodDuration(uint newPeriodDuration) public onlyOwner {
        require(newPeriodDuration > 0);
        periodDuration = newPeriodDuration;
    }

    /// @dev Forces a period reset
    function forceResetPeriod() public onlyOwner {
        uint nowTime = getNow();
        currentPeriod.endTime = uint128(nowTime.add(periodDuration)); 
        currentPeriod.block = uint128(block.number);
        currentPeriod.balance = uint128(this.balance);
        if (token != address(0x0)) {
            PeriodReset(block.number, nowTime.add(periodDuration), this.balance, token.totalSupply());
        }
    }
}



contract FullERC20 {
  event Transfer(address indexed from, address indexed to, uint256 value);
  event Approval(address indexed owner, address indexed spender, uint256 value);
  
  uint256 public totalSupply;
  uint8 public decimals;

  function balanceOf(address who) public view returns (uint256);
  function transfer(address to, uint256 value) public returns (bool);
  function allowance(address owner, address spender) public view returns (uint256);
  function transferFrom(address from, address to, uint256 value) public returns (bool);
  function approve(address spender, uint256 value) public returns (bool);
}

contract BalanceHistoryToken is FullERC20 {
  function balanceOfAtBlock(address who, uint256 blockNumber) public view returns (uint256);
}