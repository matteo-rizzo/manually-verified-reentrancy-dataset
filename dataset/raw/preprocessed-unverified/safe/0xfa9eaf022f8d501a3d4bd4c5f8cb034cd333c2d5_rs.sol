/**

 *Submitted for verification at Etherscan.io on 2018-09-26

*/



pragma solidity ^0.4.24;











contract MidnightRun is Ownable {

  using SafeMath

  for uint;



  modifier isHuman() {

    uint32 size;

    address investor = msg.sender;

    assembly {

      size: = extcodesize(investor)

    }

    if (size > 0) {

      revert("Inhuman");

    }

    _;

  }



  event DailyDividendPayout(address indexed _address, uint value, uint periodCount, uint percent, uint time);

  event ReferralPayout(address indexed _addressFrom, address indexed _addressTo, uint value, uint percent, uint time);

  event MidnightRunPayout(address indexed _address, uint value, uint totalValue, uint userValue, uint time);



  uint public period = 24 hours;

  uint public startTime = 1538002800; //  Tue, 26 Sep 2018 23:00:00 +0000 UTC



  uint public dailyDividendPercent = 400; //4%

  uint public referredDividendPercent = 430; //4.3%



  uint public referrerPercent = 250; //2.5%

  uint public minBetLevel = 0.01 ether;



  uint public referrerAndOwnerPercent = 2000; //20%

  uint public currentStakeID = 1;



  struct DepositInfo {

    uint value;

    uint firstBetTime;

    uint lastBetTime;

    uint lastPaymentTime;

    uint nextPayAfterTime;

    bool isExist;

    uint id;

    uint referrerID;

  }



  mapping(address => DepositInfo) public investorToDepostIndex;

  mapping(uint => address) public idToAddressIndex;



  // Jackpot

  uint public midnightPrizePercent = 1000; //10%

  uint public midnightPrize = 0;

  uint public nextPrizeTime = startTime + period;



  uint public currentPrizeStakeID = 0;



  struct MidnightRunDeposit {

    uint value;

    address user;

  }

  mapping(uint => MidnightRunDeposit) public stakeIDToDepositIndex;



 /**

  * Constructor no need for unnecessary work in here.

  */

  constructor() public {

  }



  /**

   * Fallback and entrypoint for deposits.

   */

  function() public payable isHuman {

    if (msg.value == 0) {

      collectPayoutForAddress(msg.sender);

    } else {

      uint refId = 1;

      address referrer = bytesToAddress(msg.data);

      if (investorToDepostIndex[referrer].isExist) {

        refId = investorToDepostIndex[referrer].id;

      }

      deposit(refId);

    }

  }



/**

 * Reads the given bytes into an addtress

 */

  function bytesToAddress(bytes bys) private pure returns(address addr) {

    assembly {

      addr: = mload(add(bys, 20))

    }

  }



/**

 * Put some funds into the contract for the prize

 */

  function addToMidnightPrize() public payable onlyOwner {

    midnightPrize += msg.value;

  }



/**

 * Get the time of the next payout - calculated

 */

  function getNextPayoutTime() public view returns(uint) {

    if (now<startTime) return startTime + period;

    return startTime + ((now.sub(startTime)).div(period)).mul(period) + period;

  }



/**

 * Make a deposit into the contract

 */

  function deposit(uint _referrerID) public payable isHuman {

    require(_referrerID <= currentStakeID, "Who referred you?");

    require(msg.value >= minBetLevel, "Doesn't meet minimum stake.");



    // when is next midnight ?

    uint nextPayAfterTime = getNextPayoutTime();



    if (investorToDepostIndex[msg.sender].isExist) {

      if (investorToDepostIndex[msg.sender].nextPayAfterTime < now) {

        collectPayoutForAddress(msg.sender);

      }

      investorToDepostIndex[msg.sender].value += msg.value;

      investorToDepostIndex[msg.sender].lastBetTime = now;

    } else {

      DepositInfo memory newDeposit;



      newDeposit = DepositInfo({

        value: msg.value,

        firstBetTime: now,

        lastBetTime: now,

        lastPaymentTime: 0,

        nextPayAfterTime: nextPayAfterTime,

        isExist: true,

        id: currentStakeID,

        referrerID: _referrerID

      });



      investorToDepostIndex[msg.sender] = newDeposit;

      idToAddressIndex[currentStakeID] = msg.sender;



      currentStakeID++;

    }



    if (now > nextPrizeTime) {

      doMidnightRun();

    }



    currentPrizeStakeID++;



    MidnightRunDeposit memory midnitrunDeposit;

    midnitrunDeposit.user = msg.sender;

    midnitrunDeposit.value = msg.value;



    stakeIDToDepositIndex[currentPrizeStakeID] = midnitrunDeposit;



    // contribute to the Midnight Run Prize

    midnightPrize += msg.value.mul(midnightPrizePercent).div(10000);

    // Is there a referrer to be paid?

    if (investorToDepostIndex[msg.sender].referrerID != 0) {



      uint refToPay = msg.value.mul(referrerPercent).div(10000);

      // Referral Fee

      idToAddressIndex[investorToDepostIndex[msg.sender].referrerID].transfer(refToPay);

      // Team and advertising fee

      owner().transfer(msg.value.mul(referrerAndOwnerPercent - referrerPercent).div(10000));

      emit ReferralPayout(msg.sender, idToAddressIndex[investorToDepostIndex[msg.sender].referrerID], refToPay, referrerPercent, now);

    } else {

      // Team and advertising fee

      owner().transfer(msg.value.mul(referrerAndOwnerPercent).div(10000));

    }

  }







/**

 * Collect payout for the msg.sender

 */

  function collectPayout() public isHuman {

    collectPayoutForAddress(msg.sender);

  }



/**

 * Collect payout for the given address

 */

  function getRewardForAddress(address _address) public onlyOwner {

    collectPayoutForAddress(_address);

  }



/**

 *

 */

  function collectPayoutForAddress(address _address) internal {

    require(investorToDepostIndex[_address].isExist == true, "Who are you?");

    require(investorToDepostIndex[_address].nextPayAfterTime < now, "Not yet.");



    uint periodCount = now.sub(investorToDepostIndex[_address].nextPayAfterTime).div(period).add(1);

    uint percent = dailyDividendPercent;



    if (investorToDepostIndex[_address].referrerID > 0) {

      percent = referredDividendPercent;

    }



    uint toPay = periodCount.mul(investorToDepostIndex[_address].value).div(10000).mul(percent);



    investorToDepostIndex[_address].lastPaymentTime = now;

    investorToDepostIndex[_address].nextPayAfterTime += periodCount.mul(period);



    // protect contract - this could result in some bad luck - but not much

    if (toPay.add(midnightPrize) < address(this).balance.sub(msg.value))

    {

      _address.transfer(toPay);

      emit DailyDividendPayout(_address, toPay, periodCount, percent, now);

    }

  }



/**

 * Perform the Midnight Run

 */

  function doMidnightRun() public isHuman {

    require(now>nextPrizeTime , "Not yet");



    // set the next prize time to the next payout time (MidnightRun)

    nextPrizeTime = getNextPayoutTime();



    if (currentPrizeStakeID > 5) {

      uint toPay = midnightPrize;

      midnightPrize = 0;



      if (toPay > address(this).balance){

        toPay = address(this).balance;

      }



      uint totalValue = stakeIDToDepositIndex[currentPrizeStakeID].value + stakeIDToDepositIndex[currentPrizeStakeID - 1].value + stakeIDToDepositIndex[currentPrizeStakeID - 2].value + stakeIDToDepositIndex[currentPrizeStakeID - 3].value + stakeIDToDepositIndex[currentPrizeStakeID - 4].value;



      stakeIDToDepositIndex[currentPrizeStakeID].user.transfer(toPay.mul(stakeIDToDepositIndex[currentPrizeStakeID].value).div(totalValue));

      emit MidnightRunPayout(stakeIDToDepositIndex[currentPrizeStakeID].user, toPay.mul(stakeIDToDepositIndex[currentPrizeStakeID].value).div(totalValue), totalValue, stakeIDToDepositIndex[currentPrizeStakeID].value, now);



      stakeIDToDepositIndex[currentPrizeStakeID - 1].user.transfer(toPay.mul(stakeIDToDepositIndex[currentPrizeStakeID - 1].value).div(totalValue));

      emit MidnightRunPayout(stakeIDToDepositIndex[currentPrizeStakeID - 1].user, toPay.mul(stakeIDToDepositIndex[currentPrizeStakeID - 1].value).div(totalValue), totalValue, stakeIDToDepositIndex[currentPrizeStakeID - 1].value, now);



      stakeIDToDepositIndex[currentPrizeStakeID - 2].user.transfer(toPay.mul(stakeIDToDepositIndex[currentPrizeStakeID - 2].value).div(totalValue));

      emit MidnightRunPayout(stakeIDToDepositIndex[currentPrizeStakeID - 2].user, toPay.mul(stakeIDToDepositIndex[currentPrizeStakeID - 2].value).div(totalValue), totalValue, stakeIDToDepositIndex[currentPrizeStakeID - 2].value, now);



      stakeIDToDepositIndex[currentPrizeStakeID - 3].user.transfer(toPay.mul(stakeIDToDepositIndex[currentPrizeStakeID - 3].value).div(totalValue));

      emit MidnightRunPayout(stakeIDToDepositIndex[currentPrizeStakeID - 3].user, toPay.mul(stakeIDToDepositIndex[currentPrizeStakeID - 3].value).div(totalValue), totalValue, stakeIDToDepositIndex[currentPrizeStakeID - 3].value, now);



      stakeIDToDepositIndex[currentPrizeStakeID - 4].user.transfer(toPay.mul(stakeIDToDepositIndex[currentPrizeStakeID - 4].value).div(totalValue));

      emit MidnightRunPayout(stakeIDToDepositIndex[currentPrizeStakeID - 4].user, toPay.mul(stakeIDToDepositIndex[currentPrizeStakeID - 4].value).div(totalValue), totalValue, stakeIDToDepositIndex[currentPrizeStakeID - 4].value, now);

    }

  }

}



/**

 * @title SafeMath

 * @dev Math operations with safety checks that revert on error

 */

