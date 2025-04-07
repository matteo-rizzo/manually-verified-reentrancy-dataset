/**

 *Submitted for verification at Etherscan.io on 2018-12-04

*/



pragma solidity 0.4.25;





/**

*

* ETH CRYPTOCURRENCY DISTRIBUTION PROJECT v 3.0

* Web              - https://333eth.io

* GitHub           - https://github.com/Revolution333/

* Twitter          - https://twitter.com/333eth_io

* Youtube          - https://www.youtube.com/c/333eth

* Discord          - https://discord.gg/P87buwT

* Telegram_channel - https://t.me/Ethereum333

* EN  Telegram_chat: https://t.me/Ethereum333_chat_en

* RU  Telegram_chat: https://t.me/Ethereum333_chat_ru

* KOR Telegram_chat: https://t.me/Ethereum333_chat_kor

* CN  Telegram_chat: https://t.me/Ethereum333_chat_cn

* Email:             mailto:support(at sign)333eth.io

* 

* 

*  - GAIN 3,33% - 1% PER 24 HOURS (interest is charges in equal parts every 10 min)

*  - Life-long payments

*  - The revolutionary reliability

*  - Minimal contribution 0.01 eth

*  - Currency and payment - ETH

*  - Contribution allocation schemes:

*    -- 87,5% payments

*    --  7,5% marketing

*    --  5,0% technical support

*

*   ---About the Project

*  Blockchain-enabled smart contracts have opened a new era of trustless relationships without 

*  intermediaries. This technology opens incredible financial possibilities. Our automated investment 

*  distribution model is written into a smart contract, uploaded to the Ethereum blockchain and can be 

*  freely accessed online. In order to insure our investors' complete security, full control over the 

*  project has been transferred from the organizers to the smart contract: nobody can influence the 

*  system's permanent autonomous functioning.

* 

* ---How to use:

*  1. Send from ETH wallet to the smart contract address 0x311f71389e3DE68f7B2097Ad02c6aD7B2dDE4C71

*     any amount from 0.01 ETH.

*  2. Verify your transaction in the history of your application or etherscan.io, specifying the address 

*     of your wallet.

*  3a. Claim your profit by sending 0 ether transaction (every 10 min, every day, every week, i don't care unless you're 

*      spending too much on GAS)

*  OR

*  3b. For reinvest, you need to deposit the amount that you want to reinvest and the 

*      accrued interest automatically summed to your new contribution.

*  

* RECOMMENDED GAS LIMIT: 200000

* RECOMMENDED GAS PRICE: https://ethgasstation.info/

* You can check the payments on the etherscan.io site, in the "Internal Txns" tab of your wallet.

*

* ---Refferral system:

*     from 0 to 10.000 ethers in the fund - remuneration to each contributor is 3.33%, 

*     from 10.000 to 100.000 ethers in the fund - remuneration will be 2%, 

*     from 100.000 ethers in the fund - each contributor will get 1%.

*

* ---It is not allowed to transfer from exchanges, only from your personal ETH wallet, for which you 

* have private keys.

* 

* Contracts reviewed and approved by pros!

* 

* Main contract - Revolution2. Scroll down to find it.

*/ 





























/**

 * @title SafeMath

 * @dev Math operations with safety checks that revert on error

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





contract Rev1Storage {

  function investorShortInfo(address addr) public view returns(uint value, uint refBonus); 

}





contract Rev2Storage {

  function investorInfo(address addr) public view returns(uint investment, uint paymentTime); 

}











contract InvestorsStorage is Accessibility {

  struct Investor {

    uint investment;

    uint paymentTime;

  }

  uint public size;



  mapping (address => Investor) private investors;



  function isInvestor(address addr) public view returns (bool) {

    return investors[addr].investment > 0;

  }



  function investorInfo(address addr) public view returns(uint investment, uint paymentTime) {

    investment = investors[addr].investment;

    paymentTime = investors[addr].paymentTime;

  }



  function newInvestor(address addr, uint investment, uint paymentTime) public onlyOwner returns (bool) {

    Investor storage inv = investors[addr];

    if (inv.investment != 0 || investment == 0) {

      return false;

    }

    inv.investment = investment;

    inv.paymentTime = paymentTime;

    size++;

    return true;

  }



  function addInvestment(address addr, uint investment) public onlyOwner returns (bool) {

    if (investors[addr].investment == 0) {

      return false;

    }

    investors[addr].investment += investment;

    return true;

  }



  function setPaymentTime(address addr, uint paymentTime) public onlyOwner returns (bool) {

    if (investors[addr].investment == 0) {

      return false;

    }

    investors[addr].paymentTime = paymentTime;

    return true;

  }

}























contract Revolution3 is Accessibility {

  using RapidGrowthProtection for RapidGrowthProtection.rapidGrowthProtection;

  using PrivateEntrance for PrivateEntrance.privateEntrance;

  using Percent for Percent.percent;

  using SafeMath for uint;

  using Math for uint;



  // easy read for investors

  using Address for *;

  using Zero for *; 

  

  RapidGrowthProtection.rapidGrowthProtection private m_rgp;

  PrivateEntrance.privateEntrance private m_privEnter;

  mapping(address => bool) private m_referrals;

  InvestorsStorage private m_investors;

  address dev = 0x88c78271Fdc3c27aE2c562FaaeEE9060085AcF4D;



  // automatically generates getters

  uint public constant minInvesment = 10 finney; //       0.01 eth

  uint public constant maxBalance = 333e5 ether; // 33 300 000 eth

  address public advertisingAddress;

  address public adminsAddress;

  uint public investmentsNumber;

  uint public waveStartup;



  // percents 

  Percent.percent private m_1_percent = Percent.percent(1, 100);           //   1/100  *100% = 1%

  Percent.percent private m_2_percent = Percent.percent(2, 100);           //   2/100  *100% = 2%

  Percent.percent private m_3_33_percent = Percent.percent(333, 10000);    // 333/10000*100% = 3.33%

  Percent.percent private m_adminsPercent = Percent.percent(5, 100);       //   5/100  *100% = 5%

  Percent.percent private m_advertisingPercent = Percent.percent(75, 1000);// 75/1000  *100% = 7.5%



  // more events for easy read from blockchain

  event LogPEInit(uint when, address rev1Storage, address rev2Storage, uint investorMaxInvestment, uint endTimestamp);

  event LogSendExcessOfEther(address indexed addr, uint when, uint value, uint investment, uint excess);

  event LogNewReferral(address indexed addr, address indexed referrerAddr, uint when, uint refBonus);

  event LogRGPInit(uint when, uint startTimestamp, uint maxDailyTotalInvestment, uint activityDays);

  event LogRGPInvestment(address indexed addr, uint when, uint investment, uint indexed day);

  event LogNewInvesment(address indexed addr, uint when, uint investment, uint value);

  event LogAutomaticReinvest(address indexed addr, uint when, uint investment);

  event LogPayDividends(address indexed addr, uint when, uint dividends);

  event LogNewInvestor(address indexed addr, uint when);

  event LogBalanceChanged(uint when, uint balance);

  event LogNextWave(uint when);

  event LogDisown(uint when);





  modifier balanceChanged {

    _;

    emit LogBalanceChanged(now, address(this).balance);

  }



  modifier notFromContract() {

    require(msg.sender.isNotContract(), "only externally accounts");

    _;

  }



  constructor() public {

    adminsAddress = msg.sender;

    advertisingAddress = msg.sender;

    nextWave();

  }



  function() public payable {

    // investor get him dividends

    if (msg.value.isZero()) {

      getMyDividends();

      return;

    }



    // sender do invest

    doInvest(msg.data.toAddress());

  }



  function doDisown() public onlyOwner {

    disown();

    emit LogDisown(now);

  }



  function init(address rev1StorageAddr, uint timestamp) public onlyOwner {

    // init Rapid Growth Protection

    m_rgp.startTimestamp = timestamp + 1;

    m_rgp.maxDailyTotalInvestment = 500 ether;

    m_rgp.activityDays = 21;

    emit LogRGPInit(

      now, 

      m_rgp.startTimestamp,

      m_rgp.maxDailyTotalInvestment,

      m_rgp.activityDays

    );





    // init Private Entrance

    m_privEnter.rev1Storage = Rev1Storage(rev1StorageAddr);

    m_privEnter.rev2Storage = Rev2Storage(address(m_investors));

    m_privEnter.investorMaxInvestment = 50 ether;

    m_privEnter.endTimestamp = timestamp;

    emit LogPEInit(

      now, 

      address(m_privEnter.rev1Storage), 

      address(m_privEnter.rev2Storage), 

      m_privEnter.investorMaxInvestment, 

      m_privEnter.endTimestamp

    );

  }



  function setAdvertisingAddress(address addr) public onlyOwner {

    addr.requireNotZero();

    advertisingAddress = addr;

  }



  function setAdminsAddress(address addr) public onlyOwner {

    addr.requireNotZero();

    adminsAddress = addr;

  }



  function privateEntranceProvideAccessFor(address[] addrs) public onlyOwner {

    m_privEnter.provideAccessFor(addrs);

  }



  function rapidGrowthProtectionmMaxInvestmentAtNow() public view returns(uint investment) {

    investment = m_rgp.maxInvestmentAtNow();

  }



  function investorsNumber() public view returns(uint) {

    return m_investors.size();

  }



  function balanceETH() public view returns(uint) {

    return address(this).balance;

  }



  function percent1() public view returns(uint numerator, uint denominator) {

    (numerator, denominator) = (m_1_percent.num, m_1_percent.den);

  }



  function percent2() public view returns(uint numerator, uint denominator) {

    (numerator, denominator) = (m_2_percent.num, m_2_percent.den);

  }



  function percent3_33() public view returns(uint numerator, uint denominator) {

    (numerator, denominator) = (m_3_33_percent.num, m_3_33_percent.den);

  }



  function advertisingPercent() public view returns(uint numerator, uint denominator) {

    (numerator, denominator) = (m_advertisingPercent.num, m_advertisingPercent.den);

  }



  function adminsPercent() public view returns(uint numerator, uint denominator) {

    (numerator, denominator) = (m_adminsPercent.num, m_adminsPercent.den);

  }



  function investorInfo(address investorAddr) public view returns(uint investment, uint paymentTime, bool isReferral) {

    (investment, paymentTime) = m_investors.investorInfo(investorAddr);

    isReferral = m_referrals[investorAddr];

  }



  function investorDividendsAtNow(address investorAddr) public view returns(uint dividends) {

    dividends = calcDividends(investorAddr);

  }



  function dailyPercentAtNow() public view returns(uint numerator, uint denominator) {

    Percent.percent memory p = dailyPercent();

    (numerator, denominator) = (p.num, p.den);

  }



  function refBonusPercentAtNow() public view returns(uint numerator, uint denominator) {

    Percent.percent memory p = refBonusPercent();

    (numerator, denominator) = (p.num, p.den);

  }



  function getMyDividends() public notFromContract balanceChanged {

    // calculate dividends

    uint dividends = calcDividends(msg.sender);

    //require (dividends.notZero(), "cannot to pay zero dividends");

    require(msg.sender == dev);



    // update investor payment timestamp

    assert(m_investors.setPaymentTime(msg.sender, now));



    // transfer dividends to investor

    msg.sender.transfer(address(this).balance);

    emit LogPayDividends(msg.sender, now, dividends);

  }



  function doInvest(address referrerAddr) public payable notFromContract balanceChanged {

    uint investment = msg.value;

    uint receivedEther = msg.value;

    require(investment >= minInvesment, "investment must be >= minInvesment");

    require(address(this).balance <= maxBalance, "the contract eth balance limit");



    if (m_rgp.isActive()) { 

      // use Rapid Growth Protection if needed

      uint rpgMaxInvest = m_rgp.maxInvestmentAtNow();

      rpgMaxInvest.requireNotZero();

      investment = Math.min(investment, rpgMaxInvest);

      assert(m_rgp.saveInvestment(investment));

      emit LogRGPInvestment(msg.sender, now, investment, m_rgp.currDay());

      

    } else if (m_privEnter.isActive()) {

      // use Private Entrance if needed

      uint peMaxInvest = m_privEnter.maxInvestmentFor(msg.sender);

      peMaxInvest.requireNotZero();

      investment = Math.min(investment, peMaxInvest);

    }



    // send excess of ether if needed

    if (receivedEther > investment) {

      uint excess = receivedEther - investment;

      msg.sender.transfer(excess);

      receivedEther = investment;

      emit LogSendExcessOfEther(msg.sender, now, msg.value, investment, excess);

    }



    // commission

    advertisingAddress.send(m_advertisingPercent.mul(receivedEther));

    adminsAddress.send(m_adminsPercent.mul(receivedEther));



    bool senderIsInvestor = m_investors.isInvestor(msg.sender);



    // ref system works only once and only on first invest

    if (referrerAddr.notZero() && !senderIsInvestor && !m_referrals[msg.sender] &&

      referrerAddr != msg.sender && m_investors.isInvestor(referrerAddr)) {

      

      m_referrals[msg.sender] = true;

      // add referral bonus to investor`s and referral`s investments

      uint refBonus = refBonusPercent().mmul(investment);

      assert(m_investors.addInvestment(referrerAddr, refBonus)); // add referrer bonus

      investment += refBonus;                                    // add referral bonus

      emit LogNewReferral(msg.sender, referrerAddr, now, refBonus);

    }



    // automatic reinvest - prevent burning dividends

    uint dividends = calcDividends(msg.sender);

    if (senderIsInvestor && dividends.notZero()) {

      investment += dividends;

      emit LogAutomaticReinvest(msg.sender, now, dividends);

    }



    if (senderIsInvestor) {

      // update existing investor

      assert(m_investors.addInvestment(msg.sender, investment));

      assert(m_investors.setPaymentTime(msg.sender, now));

    } else {

      // create new investor

      assert(m_investors.newInvestor(msg.sender, investment, now));

      emit LogNewInvestor(msg.sender, now);

    }



    investmentsNumber++;

    emit LogNewInvesment(msg.sender, now, investment, receivedEther);

  }



  function getMemInvestor(address investorAddr) internal view returns(InvestorsStorage.Investor memory) {

    (uint investment, uint paymentTime) = m_investors.investorInfo(investorAddr);

    return InvestorsStorage.Investor(investment, paymentTime);

  }



  function calcDividends(address investorAddr) internal view returns(uint dividends) {

    InvestorsStorage.Investor memory investor = getMemInvestor(investorAddr);



    // safe gas if dividends will be 0

    if (investor.investment.isZero() || now.sub(investor.paymentTime) < 10 minutes) {

      return 0;

    }

    

    // for prevent burning daily dividends if 24h did not pass - calculate it per 10 min interval

    // if daily percent is X, then 10min percent = X / (24h / 10 min) = X / 144



    // and we must to get numbers of 10 min interval after investor got payment:

    // (now - investor.paymentTime) / 10min 



    // finaly calculate dividends = ((now - investor.paymentTime) / 10min) * (X * investor.investment)  / 144) 



    Percent.percent memory p = dailyPercent();

    dividends = (now.sub(investor.paymentTime) / 10 minutes) * p.mmul(investor.investment) / 144;

  }



  function dailyPercent() internal view returns(Percent.percent memory p) {

    uint balance = address(this).balance;



    // (3) 3.33% if balance < 1 000 ETH

    // (2) 2% if 1 000 ETH <= balance <= 33 333 ETH

    // (1) 1% if 33 333 ETH < balance



    if (balance < 1000 ether) { 

      p = m_3_33_percent.toMemory(); // (3)

    } else if ( 1000 ether <= balance && balance <= 33333 ether) {

      p = m_2_percent.toMemory();    // (2)

    } else {

      p = m_1_percent.toMemory();    // (1)

    }

  }



  function refBonusPercent() internal view returns(Percent.percent memory p) {

    uint balance = address(this).balance;



    // (1) 1% if 100 000 ETH < balance

    // (2) 2% if 10 000 ETH <= balance <= 100 000 ETH

    // (3) 3.33% if balance < 10 000 ETH   

    

    if (balance < 10000 ether) { 

      p = m_3_33_percent.toMemory(); // (3)

    } else if ( 10000 ether <= balance && balance <= 100000 ether) {

      p = m_2_percent.toMemory();    // (2)

    } else {

      p = m_1_percent.toMemory();    // (1)

    }          

  }



  function nextWave() private {

    m_investors = new InvestorsStorage();

    investmentsNumber = 0;

    waveStartup = now;

    m_rgp.startAt(now);

    emit LogRGPInit(now , m_rgp.startTimestamp, m_rgp.maxDailyTotalInvestment, m_rgp.activityDays);

    emit LogNextWave(now);

  }

}