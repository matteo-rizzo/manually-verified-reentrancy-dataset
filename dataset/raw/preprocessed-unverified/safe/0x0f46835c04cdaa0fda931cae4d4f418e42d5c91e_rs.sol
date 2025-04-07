/**

 *Submitted for verification at Etherscan.io on 2018-08-21

*/



pragma solidity ^0.4.13;











contract Crowdsale {

    address public beneficiary;

    address master;

    uint public tokenBalance;

    uint public amountRaised;

    uint start_time;

    uint public price;

    uint public offChainTokens;

    uint public minimumSpend;

    token public tokenReward;

    mapping(address => uint256) public balanceOf;

    event FundTransfer(address backer, uint amount, bool isContribution);

    bool public paused;



    address public contlength;  // Remove



    modifier isPaused() { if (paused == true) _; }

    modifier notPaused() { if (paused == false) _; }

    modifier isMaster() { if (msg.sender == master) _; }

    



    /**

     * Constrctor function

     *

     * Setup the owner

     */

    function Crowdsale() {



        offChainTokens = 0;

        amountRaised = 0;

        tokenBalance = 30000000;  //Change

        minimumSpend = 0.01 * 1 ether;

        beneficiary = 0x0677f6a5383b10dc4ac253b4d56d8f69df76f548;   

        start_time = now;

        tokenReward = token(0xfACfB7aaD014f30f06E67cBeE8d3308C69aeD37a);    

        master =  0x69F8C1604f27475AF9f872E07c2E6a56b485DAcf;

        paused = false;

        price = 953584813430000;

    }



    /**

     * Fallback function

    **/



    function () payable notPaused {



        uint amount = msg.value;

        amountRaised += amount;

        tokenBalance = SafeMath.sub(tokenBalance, SafeMath.div(amount, price));

        if (tokenBalance < offChainTokens ) { revert(); }

        if (amount <  minimumSpend) { revert(); }

        tokenReward.transfer(msg.sender, SafeMath.div(amount * 1 ether, price));

        FundTransfer(msg.sender, amount, true);

        balanceOf[msg.sender] += amount;

        

    }



    function safeWithdrawal() isMaster {



      if (beneficiary.send(amountRaised)) {

          FundTransfer(beneficiary, amountRaised, false);

          tokenReward.transfer(beneficiary, tokenReward.balanceOf(this));

          tokenBalance = 0;

      }

    }



    function pause() notPaused isMaster {

      paused = true;

    }



    function unPause() isPaused isMaster {

      paused = false;

    }



    function updatePrice(uint _price) isMaster {

      price = _price;

    }



    function updateMinSpend(uint _minimumSpend) isMaster {

      minimumSpend = _minimumSpend;

    }



    function updateOffChainTokens(uint _offChainTokens) isMaster {

        offChainTokens = _offChainTokens;

    }



}