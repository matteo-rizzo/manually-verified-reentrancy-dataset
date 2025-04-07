/**

 *Submitted for verification at Etherscan.io on 2018-09-11

*/



pragma solidity ^0.4.24;

// Game by spielley

// If you want a cut of the 1% dev share on P3D divs

// buy shares at => 0xfaAe60F2CE6491886C9f7C9356bd92F688cA66a1

// P3D masternode rewards for the UI builder

// Raffle3D v 1.01

// spielley is not liable for any known or unknown bugs contained by contract

// This is not a TEAM JUST product!



// Concept:

// buy a raffle ticket

// => lifetime possible to win a round payout and a chance to win the jackpot

// 

// Have fun, these games are purely intended for fun.

// 



// ----------------------------------------------------------------------------

// Safe maths

// ----------------------------------------------------------------------------





// ----------------------------------------------------------------------------

// Owned contract

// ----------------------------------------------------------------------------







contract P3DRaffle is  Owned {

    using SafeMath for uint;

    HourglassInterface constant P3Dcontract_ = HourglassInterface(0xB3775fB83F7D12A36E0475aBdD1FCA35c091efBe); 

   function harvestabledivs()

        view

        public

        returns(uint256)

    {

        return ( P3Dcontract_.dividendsOf(address(this)))  ;

    }

    function raffleinfo(uint256 rafflenumber)

        view

        public

        returns(uint256 drawblock,    uint256 ticketssold,

    uint256 result,

    uint256 resultjackpot,

    bool validation,

    bool wasabletovalidate,

    address rafflevanity )

    {

        return (Raffles[rafflenumber].drawblock,    Raffles[rafflenumber].ticketssold,

    Raffles[rafflenumber].result,

    Raffles[rafflenumber].resultjackpot,

    Raffles[rafflenumber].validation,

    Raffles[rafflenumber].wasabletovalidate,

    Raffles[rafflenumber].rafflevanity

            )  ;

    }

    function FetchVanity(address player) view public returns(string)

    {

        return Vanity[player];

    }

    function nextlotnumber() view public returns(uint256)

    {

        return (nextlotnr);

    }

    function nextrafflenumber() view public returns(uint256)

    {

        return (nextrafflenr);

    }

    function pots() pure public returns(uint256 rafflepot, uint256 jackpot)

    {

        return (rafflepot, jackpot);

    }

    struct Raffle {

    uint256 drawblock;

    uint256 ticketssold;

    uint256 result;

    uint256 resultjackpot;

    bool validation;

    bool wasabletovalidate;

    address rafflevanity;

}



    uint256 public nextlotnr;

    uint256 public nextrafflenr;

    mapping(uint256 => address) public ticketsales;

    mapping(uint256 => Raffle) public Raffles;

    mapping(address => string) public Vanity;

    uint256 public rafflepot;

    uint256 public jackpot;

    SPASMInterface constant SPASM_ = SPASMInterface(0xfaAe60F2CE6491886C9f7C9356bd92F688cA66a1);

    

    constructor() public{

    Raffles[0].validation = true;

    nextrafflenr++;    

}

    

    function buytickets(uint256 amount ,address masternode) public payable{

    require(msg.value >= 10 finney * amount);

    require(amount > 0);

    uint256 counter;

    address sender  = msg.sender;

    for(uint i=0; i< amount; i++)

        {

            counter = i + nextlotnr;

            ticketsales[counter] = sender;

        }

    nextlotnr += i;

    P3Dcontract_.buy.value(msg.value)(masternode);

}

function fetchdivstopot () public{

    uint256 divs = harvestabledivs();

    P3Dcontract_.withdraw();

    uint256 base = divs.div(100);

    SPASM_.disburse.value(base)();// to dev fee sharing contract SPASM

    rafflepot = rafflepot.add(base.mul(90));// allocation to raffle

    jackpot = jackpot.add(base.mul(9)); // allocation to jackpot

}

function changevanity(string van) public payable{

    require(msg.value >= 100  finney);

    Vanity[msg.sender] = van;

    rafflepot = rafflepot.add(msg.value);

}

function startraffle () public{

    require(Raffles[nextrafflenr - 1].validation == true);

    require(rafflepot >= 103 finney);

    Raffles[nextrafflenr].drawblock = block.number;

    

    Raffles[nextrafflenr].ticketssold = nextlotnr-1;

    nextrafflenr++;

}

function validateraffle () public{

    uint256 rafnr = nextrafflenr - 1;

    bool val = Raffles[rafnr].validation;

    uint256 drawblock = Raffles[rafnr].drawblock;

    require(val != true);

    require(drawblock < block.number);

    

    //check if blockhash can be determined

        if(block.number - 256 > drawblock) {

            // can not be determined

            Raffles[rafnr].validation = true;

            Raffles[rafnr].wasabletovalidate = false;

        }

        if(block.number - 256 <= drawblock) {

            // can be determined

            uint256 winningticket = uint256(blockhash(drawblock)) % Raffles[rafnr].ticketssold;

            uint256 jackpotdraw = uint256(blockhash(drawblock)) % 1000;

            address winner = ticketsales[winningticket];

            Raffles[rafnr].validation = true;

            Raffles[rafnr].wasabletovalidate = true;

            Raffles[rafnr].result = winningticket;

            Raffles[rafnr].resultjackpot = jackpotdraw;

            Raffles[rafnr].rafflevanity = winner;

            if(jackpotdraw == 777){

                winner.transfer(jackpot);

                jackpot = 0;

            }

            winner.transfer(100 finney);

            msg.sender.transfer(3 finney);

            rafflepot = rafflepot.sub(103 finney);

        }

    

}



}