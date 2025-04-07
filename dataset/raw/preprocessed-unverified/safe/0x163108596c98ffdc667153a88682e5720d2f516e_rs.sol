/*

     (       )    )    )
     )\ ) ( /( ( /( ( /(     (  (
    (()/( )\()))\()))\())  ( )\ )\
     /(_)|(_)\((_)\((_)\  ))((_|(_)
    (_))  _((_)_((_)_((_)/((_)  _
    | _ \| || \ \/ / || (_))| || |
    |  _/| __ |>  <| __ / -_) || |
    |_|  |_||_/_/\_\_||_\___|_||_|

    PHXHell - A game of timing and luck.
      made by ToCsIcK

    Inspired by EthAnte by TechnicalRise

*/
pragma solidity ^0.4.21;

// Contract must implement this interface in order to receive ERC223 tokens
contract ERC223ReceivingContract {
    function tokenFallback(address _from, uint _value, bytes _data) public;
}

// We only need the signature of the transfer method
contract ERC223Interface {
    function transfer(address _to, uint _value) public returns (bool);
}

// SafeMath is good


contract PhxHell is ERC223ReceivingContract {
    using SafeMath for uint;

    uint public balance;        // Current balance
    uint public lastFund;       // Time of last fund
    address public lastFunder;  // Address of the last person who funded
    address phxAddress;         // PHX main net address

    uint constant public stakingRequirement = 5e17;   // 0.5 PHX
    uint constant public period = 1 hours;

    // Event to record the end of a game so it can be added to a &#39;history&#39; page
    event GameOver(address indexed winner, uint timestamp, uint value);

    // Takes PHX address as a parameter so you can point at another contract during testing
    function PhxHell(address _phxAddress)
        public {
        phxAddress = _phxAddress;
    }

    // Called to force a payout without having to restake
    function payout()
        public {

        // If there&#39;s no pending winner, don&#39;t do anything
        if (lastFunder == 0)
            return;

        // If timer hasn&#39;t expire, don&#39;t do anything
        if (now.sub(lastFund) < period)
            return;

        uint amount = balance;
        balance = 0;

        // Send the total balance to the last funder
        ERC223Interface phx = ERC223Interface(phxAddress);
        phx.transfer(lastFunder, amount);

        // Fire event
        GameOver( lastFunder, now, amount );

        // Reset the winner
        lastFunder = address(0);
    }

    // Called by the ERC223 contract (PHX) when sending tokens to this address
    function tokenFallback(address _from, uint _value, bytes)
    public {

        // Make sure it is PHX we are receiving
        require(msg.sender == phxAddress);

        // Make sure it&#39;s enough PHX
        require(_value >= stakingRequirement);

        // Payout if someone won already
        payout();

        // Add to the balance and reset the timer
        balance = balance.add(_value);
        lastFund = now;
        lastFunder = _from;
    }
}