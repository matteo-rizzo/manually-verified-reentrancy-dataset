/**

 *Submitted for verification at Etherscan.io on 2018-10-03

*/



pragma solidity ^0.4.25;



















contract ClaimSPTI{

    

    using SafeMath for uint256;

    

    TokenNEW public newTokenReward;

    TokenOLD  public oldToken;

    address public creator;

    address public owner = 0x1Ab98C0833e034b1E81F4F0282914C615d795299;

    uint256 public startDate;

    uint256 public endDate;





    modifier isCreator() {

        require(msg.sender == creator);

        _;

    }



    event FundTransfer(address backer, uint amount, bool isContribution);

    constructor() public {

        startDate = 1538554875;

        endDate = startDate + 30 days;

        creator = msg.sender;

        newTokenReward = TokenNEW(0xc91d83955486e5261528d1acc1956529d2fe282b); //Instantiate the new reward

        oldToken = TokenOLD(0xa673802792379714201ebc5f586c3a44b0248681); //Instantiate old token to be replaced

    }

    

    function() public payable {

        

        require(now > startDate);

        require(now < endDate);

        require(msg.value == 0); // Only 0 ether accepted, This is not an IC Oh!

        uint oldSptiUserBal;

        oldSptiUserBal = getBalance(msg.sender); //Get Old SPTI balance

        require(oldSptiUserBal > 0); // Make sure claimant actually possesses Old SPTI

        require(oldToken.transferFrom(msg.sender, 0xceC74106a23329745b07f6eC5e1E39803b3fF31F, oldSptiUserBal));

        

        //If all of the above happens accordingly, go ahead and release new token

        //to old token holders

        uint256 amount = oldSptiUserBal.div(8);

        newTokenReward.transfer(msg.sender, amount);

        emit FundTransfer(msg.sender, amount, true);



    }

    

    function getBalance(address userAddress) public view returns (uint256){

        uint bal = oldToken.balanceOf(userAddress);

        return bal;

    }

    

    function transferToken(address to, uint256 value) isCreator public {

        newTokenReward.transfer(to, value);      

    }



    function kill() isCreator public {

        selfdestruct(owner);

    }



}