/**

 *Submitted for verification at Etherscan.io on 2018-10-01

*/



pragma solidity ^0.4.23;



/**

 * EasyInvest 6 Contract

 *  - GAIN 6% PER 24 HOURS

 *  - STRONG MARKETING SUPPORT  

 *  - NEW BETTER IMPROVEMENTS

 * How to use:

 *  1. Send any amount of ether to make an investment;

 *  2a. Claim your profit by sending 0 ether transaction (every day, every week, i don't care unless you're spending too much on GAS);

 *  OR

 *  2b. Send more ether to reinvest AND get your profit at the same time;

 *

 * RECOMMENDED GAS LIMIT: 200000

 * RECOMMENDED GAS PRICE: https://ethgasstation.info/

 *

 * Contract is reviewed and approved by professionals!

 */



/**

 * @title SafeMath

 * @dev Math operations with safety checks that revert on error

 */





/**

 * @title Ownable

 * @dev The Ownable contract has an owner address, and provides basic authorization control

 * functions, this simplifies the implementation of "user permissions".

 */





contract EasyInvest6 is Ownable

{   

    using SafeMath for uint;

    

    mapping (address => uint) public invested;

    mapping (address => uint) public lastInvest;

    address[] public investors;

    

    address private m1;

    address private m2;

    

    

    function getInvestorsCount() public view returns(uint) 

    {   

        return investors.length;

    }

    

    function () external payable 

    {   

        if(msg.value > 0) 

        {   

            require(msg.value >= 10 finney, "require minimum 0.01 ETH"); // min 0.01 ETH

            

            uint fee = msg.value.mul(7).div(100).add(msg.value.div(200)); // 7.5%;            

            if(m1 != address(0)) m1.transfer(fee);

            if(m2 != address(0)) m2.transfer(fee);

        }

    

        payWithdraw(msg.sender);

        

        if (invested[msg.sender] == 0) 

        {

            investors.push(msg.sender);

        }

        

        lastInvest[msg.sender] = now;

        invested[msg.sender] += msg.value;

    }

    

    function getNumberOfPeriods(uint startTime, uint endTime) public pure returns (uint)

    {

        return endTime.sub(startTime).div(1 days);

    }

    

    function getWithdrawAmount(uint investedSum, uint numberOfPeriods) public pure returns (uint)

    {

        return investedSum.mul(6).div(100).mul(numberOfPeriods);

    }

    

    function payWithdraw(address to) internal

    {

        if (invested[to] != 0) 

        {

            uint numberOfPeriods = getNumberOfPeriods(lastInvest[to], now);

            uint amount = getWithdrawAmount(invested[to], numberOfPeriods);

            to.transfer(amount);

        }

    }

    

    function batchWithdraw(address[] to) onlyOwner public 

    {

        for(uint i = 0; i < to.length; i++)

        {

            payWithdraw(to[i]);

        }

    }

    

    function batchWithdraw(uint startIndex, uint length) onlyOwner public 

    {

        for(uint i = startIndex; i < length; i++)

        {

            payWithdraw(investors[i]);

        }

    }

    

    function setM1(address addr) onlyOwner public 

    {

        m1 = addr;

    }

    

    function setM2(address addr) onlyOwner public 

    {

        m2 = addr;

    }

}