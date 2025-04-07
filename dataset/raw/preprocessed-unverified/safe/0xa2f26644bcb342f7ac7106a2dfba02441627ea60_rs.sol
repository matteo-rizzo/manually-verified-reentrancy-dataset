/**
 *Submitted for verification at Etherscan.io on 2020-06-09
*/

pragma solidity ^0.4.25;








contract PowerDoubler is ApproveAndCallFallBack{
    using SafeMath for uint256;

    modifier afterGameStart() {
        require(now >= startTime,"game not started yet");
        _;
    }

    struct Participant {
        address etherAddress;
        uint PayAmount;
    }

    Participant[] public participants;

    uint public payoutIdx = 0;
    uint public collectedFees = 0;
    uint public balance = 0;

    address public owner;
    address[] public feeRecipients;
    ERC20 public powertoken;
    uint public MIN_BUY=1 ether;
    uint public MAX_BUY=1000 ether;
    uint public startTime;
    uint public delayToStart=5 days;//0 minutes;

    //view only
    uint public totalSpent=0;
    uint public totalPaid=0;
    mapping(address => uint) public queuePosition;

    // this function is executed at initialization and sets the owner of the contract
    constructor(address tokenaddr) public {
        owner = msg.sender;
        powertoken = ERC20(tokenaddr);
        feeRecipients.push(0xaEbbd80Fd7dAe979d965A3a5b09bBCD23eB40e5F);
        feeRecipients.push(0x3dF3766E64C2C85Ce1baa858d2A14F96916d5087);
        feeRecipients.push(0x8Cc62C4dCF129188ce4b43103eAefc0d6b71af6d);
        feeRecipients.push(0xE7F53CE9421670AC2f11C5035E6f6f13d9829aa6);
        startTime=now+delayToStart;
    }
    /*
      In case we decide to start the game with a trigger transaction. If so set delayToStart to something highish
    */
    function startEarly() public{
      require(msg.sender==owner);
      startTime=now;
    }
    function checkAndTransferPOWER(address from,uint256 _amount) private {
        require(powertoken.transferFrom(from, address(this), _amount) == true, "transfer must succeed");//msg.sender
    }
    /*
      allows playing without using approve
    */
    function receiveApproval(address from, uint256 tokens, address token, bytes data) public{
      require(msg.sender==address(powertoken));
      enter(tokens,from);
    }
    function enter(uint tokensSent,address from) afterGameStart private{
      checkAndTransferPOWER(from,tokensSent);
      totalSpent+=tokensSent;//view only
		  //send more than min and less than max
		  require(tokensSent >= MIN_BUY && tokensSent <= MAX_BUY,"token amount out of bounds");
      // collect fees and update contract balance
      collectedFees += tokensSent / 20;
      balance += tokensSent.sub(tokensSent / 20);

    	// add a new participant to array and calculate need balance to payout
      uint idx = participants.length;
      participants.length += 1;
      participants[idx].etherAddress = from;//msg.sender;
      participants[idx].PayAmount = (tokensSent.sub(tokensSent / 20)).mul(2);
      //view only
      queuePosition[from]=idx;//msg.sender

			uint NeedAmount = participants[payoutIdx].PayAmount;
			// if there are enough ether on the balance we can pay out to an earlier participant
		    if (balance >= NeedAmount) {
	            powertoken.transfer(participants[payoutIdx].etherAddress,NeedAmount);
	            balance = balance.sub(NeedAmount);
	            payoutIdx += 1;
              //view only:
              totalPaid+=NeedAmount;
	        }

    }

/*
   in case someone does a buy that can pay multiple
 */
	function NextPayout() afterGameStart public{
      uint NeedAmount = participants[payoutIdx].PayAmount;
	    require(balance >= NeedAmount,"insufficient contract balance for cashout");
      powertoken.transfer(participants[payoutIdx].etherAddress,NeedAmount);
      balance = balance.sub(NeedAmount);
      payoutIdx += 1;
      //view only:
      totalPaid+=NeedAmount;
    }

  function collectFees() public {
      require(collectedFees>0,"zero fees");
      for(uint8 i=0;i<feeRecipients.length;i+=1){
        powertoken.transfer(feeRecipients[i],collectedFees.div(feeRecipients.length));//delivers even shares
      }
      collectedFees = 0;
  }

  /*
    frontend view function
  */
  function placeInLine(address user) view returns(uint){
    if(queuePosition[user]>payoutIdx){
      return queuePosition[user]-payoutIdx;
    }
    else{
      return 0;
    }
  }
}