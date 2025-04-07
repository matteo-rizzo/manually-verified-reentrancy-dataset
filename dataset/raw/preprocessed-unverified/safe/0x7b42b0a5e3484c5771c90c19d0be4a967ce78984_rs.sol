/**

 *Submitted for verification at Etherscan.io on 2018-11-29

*/



pragma solidity ^0.4.24;

// ----------------------------------------------------------------------------

// Safe maths

// ----------------------------------------------------------------------------





// ----------------------------------------------------------------------------

// Owned contract

// ----------------------------------------------------------------------------





contract Crowdfund is Owned {

     using SafeMath for uint;

     

    //mapping

    mapping(address => uint256) public Holdings;

    mapping(uint256 => address) public ContributorsList;

    uint256 listPointer;

    mapping(address => bool) public isInList;

    bool crowdSaleOpen;

    bool crowdSaleFail;

    uint256 CFTsToSend;

    

    constructor() public{

        crowdSaleOpen = true;

    }

    

    modifier onlyWhenOpen() {

        require(crowdSaleOpen == true);

        _;

    }

    function amountOfCFTtoSend(address Holder)

        view

        public

        returns(uint256)

    {

        uint256 amount = CFTsToSend.mul( Holdings[Holder]).div(1 ether).div(CFTsToSend);

        return ( amount)  ;

    }

    function setAmountCFTsBought(uint256 amount) onlyOwner public{

        CFTsToSend = amount;

    }

    function() external payable onlyWhenOpen {

        require(msg.value > 0);

        Holdings[msg.sender].add(msg.value);

        if(isInList[msg.sender] == false){

            ContributorsList[listPointer] = msg.sender;

            listPointer++;

            isInList[msg.sender] = true;

        }

    }

    function balanceToOwner() onlyOwner public{

        require(crowdSaleOpen == false);

        owner.transfer(address(this).balance);

    }

    function CloseCrowdfund() onlyOwner public{

        crowdSaleOpen = false;

    }

    function failCrowdfund() onlyOwner public{

        crowdSaleFail = true;

    }

    function retreiveEthuponFail () public {

        require(crowdSaleFail == true);

        require(Holdings[msg.sender] > 0);

        uint256 getEthback = Holdings[msg.sender];

        Holdings[msg.sender] = 0;

        msg.sender.transfer(getEthback);

    }

}