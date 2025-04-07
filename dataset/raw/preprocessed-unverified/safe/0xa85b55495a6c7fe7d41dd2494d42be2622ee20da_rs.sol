pragma solidity ^0.4.13;





contract Crowdsale {
    address public beneficiary;
    uint public tokenBalance;
    uint public amountRaised;
    uint public deadline;
    uint dollar_exchange;
    uint test_factor;
    uint start_time;
    token public tokenReward;
    mapping(address => uint256) public balanceOf;
    event FundTransfer(address backer, uint amount, bool isContribution);

    /**
     * Constrctor function
     *
     * Setup the owner
     */
    function Crowdsale() {
        tokenBalance = 49893;
        beneficiary = 0x6519C9A1BF6d69a35C7C87435940B05e9915Ccb3;
        start_time = now;
        deadline = start_time + 30 * 1 days;
        dollar_exchange = 475;

        tokenReward = token(0xb957B54c347342893b7d79abE2AaF543F7598531);  //vegan coin address
    }

    /**
     * Fallback function
    **/

    function () payable beforeDeadline {

        uint amount = msg.value;
        uint price;
        balanceOf[msg.sender] += amount;
        amountRaised += amount;
        if (now <= start_time + 7 days) { price = SafeMath.div(2 * 1 ether, dollar_exchange);}
        else {price = SafeMath.div(3 * 1 ether, dollar_exchange);}
        tokenBalance = SafeMath.sub(tokenBalance, SafeMath.div(amount, price));
        if (tokenBalance < 0 ) { revert(); }
        tokenReward.transfer(msg.sender, SafeMath.div(amount * 1 ether, price));
        FundTransfer(msg.sender, amount, true);
        
    }

    modifier afterDeadline() { if (now >= deadline) _; }
    modifier beforeDeadline() { if (now <= deadline) _; }

    /**
     * Check if goal was reached
     *
     * Checks if the goal or time limit has been reached and ends the campaign
     */

    function safeWithdrawal() afterDeadline {

        if (beneficiary.send(amountRaised)) {
            FundTransfer(beneficiary, amountRaised, false);
            tokenReward.transfer(beneficiary, tokenReward.balanceOf(this));
            tokenBalance = 0;
        }
    }
}