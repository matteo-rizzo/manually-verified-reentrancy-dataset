/**

 *Submitted for verification at Etherscan.io on 2018-12-03

*/



pragma solidity 0.4.25;





/**

* ETH CRYPTOCURRENCY DISTRIBUTION PROJECT

* 

* Web              - https://333eth.io

* 

* Twitter          - https://twitter.com/333eth_io

* 

* Telegram_channel - https://t.me/Ethereum333

* 

* EN  Telegram_chat: https://t.me/Ethereum333_chat_en

* 

* RU  Telegram_chat: https://t.me/Ethereum333_chat_ru

* 

* KOR Telegram_chat: https://t.me/Ethereum333_chat_kor

* 

* Email:             mailto:support(at sign)333eth.io

* 

* 

* 

* When the timer reaches zero then latest bettor takes the bank. Each bet restart a timer again.

* 

* Bet 0.01 ETH - if balance < 100 ETH

* Bet 0.02 ETH - if 100 ETH <= balance <= 200 ETH

* Bet 0.03 ETH - if 200 ETH < balance

* 

* The timer turns on for 5 minutes always. 

*    

* You need to send such bet`s amounts. If more was sent, then contract will return the difference to the wallet. For example, sending 0.03 ETH system will perceive as a contribution to 0.01 ETH and difference 0.02

* 

* The game does not have a fraudulent Ponzi scheme. No fraudulent referral programs.

* 

* In the contract of the game realized the refusal of ownership. It is impossible to stop the flow of bets. Bet from smart contracts is prohibited.

* 

* Eth distribution:

* 50% paid to the winner.

* 33% is transferred to the next level of the game with the same rules and so on.

* 17% commission.

* 

* RECOMMENDED GAS LIMIT: 150000

* 

* RECOMMENDED GAS PRICE: https://ethgasstation.info/

*/













contract Accessibility {

  enum AccessRank { None, PayIn, Manager, Full }

  mapping(address => AccessRank) public admins;

  modifier onlyAdmin(AccessRank  r) {

    require(

      admins[msg.sender] == r || admins[msg.sender] == AccessRank.Full,

      "access denied"

    );

    _;

  }

  event LogProvideAccess(address indexed whom, AccessRank rank, uint when);



  constructor() public {

    admins[msg.sender] = AccessRank.Full;

    emit LogProvideAccess(msg.sender, AccessRank.Full, now);

  }



  function provideAccess(address addr, AccessRank rank) public onlyAdmin(AccessRank.Manager) {

    require(rank <= AccessRank.Manager, "cannot to give full access rank");

    if (admins[addr] != rank) {

      admins[addr] = rank;

      emit LogProvideAccess(addr, rank, now);

    }

  }

}



/**

 * @title SafeMath

 * @dev Math operations with safety checks that revert on error

 */



















contract LastHero is Accessibility {

  using Percent for Percent.percent;

  using Timer for Timer.timer;

  

  Percent.percent public bankPercent = Percent.percent(50, 100);

  Percent.percent public nextLevelPercent = Percent.percent(33, 100);

  Percent.percent public adminsPercent = Percent.percent(17, 100);



  bool public isActive;

  uint public nextLevelBankAmount;

  uint private m_bankAmount;

  uint public jackpot;

  uint public level;

  uint public constant betDuration = 5 minutes;

  address public adminsAddress;

  address public bettor;

  Timer.timer public timer;



  modifier notFromContract() {

    require(msg.sender == tx.origin, "only externally accounts");

    _;



    // we can use 'transfer' for all bettors with it - no thx

  }



  event LogSendExcessOfEther(address indexed addr, uint excess, uint when);

  event LogNewWinner(address indexed addr, uint indexed level, uint amount, uint when);

  event LogNewLevel(uint indexed level, uint bankAmount, uint when);

  event LogNewBet(address indexed addr, uint indexed amount, uint duration, uint indexed level, uint when);





  constructor() public {

    adminsAddress = msg.sender;

    timer.duration = uint(-1); // 2^256 - 1

    nextLevel();

  }



  function() external payable {

    if (admins[msg.sender] == AccessRank.PayIn) {

      if (level <= 3) {

        increaseJackpot();

      } else {

        increaseBank();

      }

      return ;

    }



    bet();

  }



  function timeLeft() external view returns(uint duration) {

    duration = timer.timeLeft();

  }



  function setAdminsAddress(address addr) external onlyAdmin(AccessRank.Full) {

    require(addr != address(0), "require not zero address");

    adminsAddress = addr;

  }



  function activate() external onlyAdmin(AccessRank.Full) {

    isActive = true;

  }



  function betAmountAtNow() public view returns(uint amount) {

    uint balance = address(this).balance;



    // (1) 0.01 ETH - if balance < 100 ETH

    // (2) 0.02 ETH - if 100 ETH <= balance <= 200 ETH

    // (3) 0.03 ETH - if 200 ETH < balance



    if (balance < 100 ether) {

      amount = 0.01 ether;

    } else if (100 ether <= balance && balance <= 200 ether) {

      amount = 0.02 ether;

    } else {

      amount = 0.03 ether;

    }

  }

  

  function bankAmount() public view returns(uint) {

    if (level <= 3) {

      return jackpot;

    }

    return m_bankAmount;

  }



  function bet() public payable notFromContract {

    require(isActive, "game is not active");



    if (timer.timeLeft() == 0) {

      uint win = bankAmount();

      if (bettor.send(win)) {

        emit LogNewWinner(bettor, level, win, now);

      }



      if (level > 3) {

        m_bankAmount = nextLevelBankAmount;

        nextLevelBankAmount = 0;

      }



      nextLevel();

    }



    uint betAmount = betAmountAtNow();

    require(msg.value >= betAmount, "too low msg value");

    timer.start(betDuration);

    bettor = msg.sender;



    uint excess = msg.value - betAmount;

    if (excess > 0) {

      if (bettor.send(excess)) {

        emit LogSendExcessOfEther(bettor, excess, now);

      }

    }

 

    nextLevelBankAmount += nextLevelPercent.mul(betAmount);

    m_bankAmount += bankPercent.mul(betAmount);

    adminsAddress.send(adminsPercent.mul(betAmount));



    emit LogNewBet(bettor, betAmount, betDuration, level, now);

  }



  function increaseJackpot() public payable onlyAdmin(AccessRank.PayIn) {

    require(level <= 3, "jackpots only on first three levels");

    jackpot += msg.value / (4 - level); // add for remained levels

  }



  function increaseBank() public payable onlyAdmin(AccessRank.PayIn) {

    require(level > 3, "bank amount only above three level");

    m_bankAmount += msg.value;

    if (jackpot > 0) {

      m_bankAmount += jackpot;

      jackpot = 0;

    }

  }



  function nextLevel() private {

    level++;

    emit LogNewLevel(level, m_bankAmount, now);

  }

}