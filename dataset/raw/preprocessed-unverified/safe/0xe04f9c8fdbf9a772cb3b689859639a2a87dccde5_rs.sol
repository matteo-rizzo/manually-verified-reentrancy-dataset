/**

 *Submitted for verification at Etherscan.io on 2018-11-30

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

* Bet in 1 ETH - the timer turns on for 3 minutes 33 seconds.

* 

* Bet 0.1ETH - the timer turns on for 6 minutes 33 seconds.

* 

* Bet 0.01 ETH - the timer turns on for 9 minutes 33 seconds.

* You need to send such bet`s amounts. If more was sent, then contract will return the difference to the wallet. For example, sending 0.99 ETH system will perceive as a contribution to 0.1 ETH and difference 0.89

* 

* The game does not have a fraudulent Ponzi scheme. No fraudulent referral programs.

* 

* In the contract of the game realized the refusal of ownership. It is impossible to stop the flow of bets. Bet from smart contracts is prohibited.

* 

* Eth distribution:

* 50% paid to the winner.

* 40% is transferred to the next level of the game with the same rules and so on.

* 10% commission (7.5% of them to shareholders, 2.5% of the administration).

* 

* RECOMMENDED GAS LIMIT: 100000

* 

* RECOMMENDED GAS PRICE: https://ethgasstation.info/

*/





















contract Accessibility {

  address private owner;

  modifier onlyOwner() {

    require(msg.sender == owner, "access denied");

    _;

  }



  constructor() public {

    owner = msg.sender;

  }



  function disown() internal {

    delete owner;

  }

}



/**

 * @title SafeMath

 * @dev Math operations with safety checks that revert on error

 */





















contract LastHero is Accessibility {

  using Percent for Percent.percent;

  using Timer for Timer.timer;

  using Address for address;

  using Bet for Bet.bet;

  using Zero for *;

  

  Percent.percent private m_bankPercent = Percent.percent(50,100);

  Percent.percent private m_nextLevelPercent = Percent.percent(40,100);

  Percent.percent private m_adminsPercent = Percent.percent(10,100);

  

  uint public nextLevelBankAmount;

  uint public bankAmount;

  uint public level;

  address public bettor;

  address public adminsAddress;

  Timer.timer private m_timer;



  modifier notFromContract() {

    require(msg.sender.isNotContract(), "only externally accounts");

    _;

  }



  event LogSendExcessOfEther(address indexed addr, uint excess, uint when);

  event LogNewWinner(address indexed addr, uint indexed level, uint amount, uint when);

  event LogNewLevel(uint indexed level, uint bankAmount, uint when);

  event LogNewBet(address indexed addr, uint indexed amount, uint duration, uint indexed level, uint when);

  event LogDisown(uint when);





  constructor() public {

    level = 1;

    emit LogNewLevel(level, address(this).balance, now);

    adminsAddress = msg.sender;

    m_timer.duration = uint(-1);

  }



  function() public payable {

    doBet();

  }



  function doDisown() public onlyOwner {

    disown();

    emit LogDisown(now);

  }



  function setAdminsAddress(address addr) public onlyOwner {

    addr.requireNotZero();

    adminsAddress = addr;

  }



  function bankPercent() public view returns(uint numerator, uint denominator) {

    (numerator, denominator) = (m_bankPercent.num, m_bankPercent.den);

  }



  function nextLevelPercent() public view returns(uint numerator, uint denominator) {

    (numerator, denominator) = (m_nextLevelPercent.num, m_nextLevelPercent.den);

  }



  function adminsPercent() public view returns(uint numerator, uint denominator) {

    (numerator, denominator) = (m_adminsPercent.num, m_adminsPercent.den);

  }



  function timeLeft() public view returns(uint duration) {

    duration = m_timer.timeLeft();

  }



  function timerInfo() public view returns(uint startup, uint duration) {

    (startup, duration) = (m_timer.startup, m_timer.duration);

  }



  function durationForBetAmount(uint betAmount) public view returns(uint duration) {

    Bet.bet memory bet = Bet.New(msg.sender, betAmount);

    duration = bet.duration;

  }



  function availableBets() public view returns(uint[3] memory vals, uint[3] memory durs) {

    (vals, durs) = Bet.bets();

  }



  function doBet() public payable notFromContract {



    // send ether to bettor if needed

    if (m_timer.timeLeft().isZero()) {

      bettor.transfer(bankAmount);

      emit LogNewWinner(bettor, level, bankAmount, now);



      bankAmount = nextLevelBankAmount;

      nextLevelBankAmount = 0;

      level++;

      emit LogNewLevel(level, bankAmount, now);

    }



    Bet.bet memory bet = Bet.New(msg.sender, msg.value);

    bet.amount.requireNotZero();



    // send bet`s excess of ether if needed

    if (bet.excess.notZero()) {

      bet.transferExcess();

      emit LogSendExcessOfEther(bet.bettor, bet.excess, now);

    }



    // commision

    nextLevelBankAmount += m_nextLevelPercent.mul(bet.amount);

    bankAmount += m_bankPercent.mul(bet.amount);

    adminsAddress.send(m_adminsPercent.mul(bet.amount));

  

    m_timer.start(bet.duration);

    bettor = bet.bettor;



    emit LogNewBet(bet.bettor, bet.amount, bet.duration, level, now);

  }

}