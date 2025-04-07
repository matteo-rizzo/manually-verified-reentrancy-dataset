pragma solidity ^0.4.13;





contract Crowdsale {
    address public beneficiary;
    uint public tokenBalance;
    uint public amountRaised;
    uint public deadline;
    uint dollar_exchange;
    uint test_factor;
    uint start_time;
    uint price;
    token public tokenReward;
    mapping(address => uint256) public balanceOf;
    event FundTransfer(address backer, uint amount, bool isContribution);

    /**
     * Constrctor function
     *
     * Setup the owner
     */
    function Crowdsale() {
        beneficiary = 0xD83A4537f917feFf68088eAB619dC6C529A55ad4;
        start_time = now;
        deadline = start_time + 14 * 1 days;    
        dollar_exchange = 280;
        tokenReward = token(0x2ca8e1fbcde534c8c71d8f39864395c2ed76fb0e);  //chozun coin address
    }

    /**
     * Fallback function
    **/

    function () payable beforeDeadline {

        tokenBalance = 4943733;
        uint amount = msg.value;
        balanceOf[msg.sender] += amount;
        amountRaised += amount;
        price = SafeMath.div(0.35 * 1 ether, dollar_exchange);
        if (amount >= 37.5 ether && amount < 83 ether) {price = SafeMath.div(SafeMath.mul(100, price), 110);} 
        if (amount >= 87.5 ether && amount < 166 ether) {price = SafeMath.div(SafeMath.mul(100, price), 115);} 
        if (amount >= 175 ether) {price = SafeMath.div(SafeMath.mul(100, price), 120);}
        tokenBalance = SafeMath.sub(tokenBalance, SafeMath.div(amount, price));
        if (tokenBalance < 0 ) { revert(); }
        tokenReward.transfer(msg.sender, SafeMath.div(amount * 1 ether, price));
        FundTransfer(msg.sender, amount, true);
        
    }

    modifier afterDeadline() { if (now >= deadline) _; }
    modifier beforeDeadline() { if (now <= deadline) _; }

    function safeWithdrawal() afterDeadline {

        if (beneficiary.send(amountRaised)) {
            FundTransfer(beneficiary, amountRaised, false);
            tokenReward.transfer(beneficiary, tokenReward.balanceOf(this));
            tokenBalance = 0;
        }
    }
}