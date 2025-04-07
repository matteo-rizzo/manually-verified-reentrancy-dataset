/**

 *Submitted for verification at Etherscan.io on 2018-09-09

*/



pragma solidity ^0.4.24;

// Game by spielley

// If you want a cut of the 1% dev share on P3D divs

// buy shares at => 0xfaAe60F2CE6491886C9f7C9356bd92F688cA66a1

// P3D masternode rewards for the UI builder

// multisigcontractgame v 1.01

// spielley is not liable for any known or unknown bugs contained by contract



// hack at least half the signatures in the contract to gain acceptOwnership

// hack the P3D divs to the contract

// if you can manage to be the last hacker with majority in the contract

// for at least 5000 blocks, you can hack the P3D divs eth at contract

// Have fun, these games are purely intended for fun.





// ----------------------------------------------------------------------------

// Safe maths

// ----------------------------------------------------------------------------







contract DivMultisigHackable is Owned {

    using SafeMath for uint;

HourglassInterface constant P3Dcontract_ = HourglassInterface(0xB3775fB83F7D12A36E0475aBdD1FCA35c091efBe);

SPASMInterface constant SPASM_ = SPASMInterface(0xfaAe60F2CE6491886C9f7C9356bd92F688cA66a1);

function buyp3d(uint256 amt) internal{

P3Dcontract_.buy.value(amt)(this);

}

function claimdivs() internal{

P3Dcontract_.withdraw();

}

// amount of divs available



struct HackableSignature {

    address owner;

    uint256 hackingcost;

    uint256 encryption;

}

uint256 public ethtosend;//eth contract pot



uint256 public totalsigs;

mapping(uint256 => HackableSignature) public Multisigs;  

mapping(address => uint256) public lasthack;

mapping(address => uint256) public ETHtoP3Dbymasternode;

mapping(address => string) public Vanity;

address public last50plushacker;

uint256 public last50plusblocknr;



address public contrp3d = 0xB3775fB83F7D12A36E0475aBdD1FCA35c091efBe;



constructor(uint256 amtsigs) public{

    uint256 nexId;

    for(nexId = 0; nexId < amtsigs;nexId++){

    Multisigs[nexId].owner = msg.sender;

    Multisigs[nexId].hackingcost = 1;

    Multisigs[nexId].encryption = 1;

}

totalsigs = amtsigs;

}

event onHarvest(

        address customerAddress,

        uint256 amount

    );

function harvestabledivs()

        view

        public

        returns(uint256)

    {

        return ( P3Dcontract_.dividendsOf(address(this)))  ;

    }

function getMultisigOwner(uint256 sigId) view public returns(address)

    {

        return Multisigs[sigId].owner;

    }

function getMultisigcost(uint256 sigId) view public returns(uint256)

    {

        return Multisigs[sigId].hackingcost;

    }

function getMultisigencryotion(uint256 sigId) view public returns(uint256)

    {

        return Multisigs[sigId].encryption;

    }

function ethtobuyp3d(address masternode) view public returns(uint256)

    {

        return ETHtoP3Dbymasternode[masternode];

    }

function HackableETH() view public returns(uint256)

    {

        return ethtosend;

    }  

function FetchVanity(address player) view public returns(string)

    {

        return Vanity[player];

    }

function FetchlastHacker() view public returns(address)

    {

        return last50plushacker;

    }  

function blockstillcontracthackable() view public returns(uint256)

    {

        uint256 test  = 5000 - last50plusblocknr ;

        return test;

    } 

function last50plusblokhack() view public returns(uint256)

    {

        return last50plusblocknr;

    }      

function amountofp3d() external view returns(uint256){

    return ( P3Dcontract_.balanceOf(address(this)))  ;

}

function Hacksig(uint256 nmbr , address masternode) public payable{

    require(lasthack[msg.sender] < block.number);

    require(nmbr < totalsigs);

    require(Multisigs[nmbr].owner != msg.sender);

    require(msg.value >= Multisigs[nmbr].hackingcost + Multisigs[nmbr].encryption);

    Multisigs[nmbr].owner = msg.sender;

    Multisigs[nmbr].hackingcost ++;

    Multisigs[nmbr].encryption = 0;

    lasthack[msg.sender] = block.number;

    ETHtoP3Dbymasternode[masternode] = ETHtoP3Dbymasternode[masternode].add(msg.value);

}

function Encrypt(uint256 nmbr, address masternode) public payable{

    require(Multisigs[nmbr].owner == msg.sender);//prevent encryption of hacked sig

    Multisigs[nmbr].encryption += msg.value;

    ETHtoP3Dbymasternode[masternode] = ETHtoP3Dbymasternode[masternode].add(msg.value);

    }



function HackDivs() public payable{

    uint256 divs = harvestabledivs();

    require(msg.value >= 1 finney);

    require(divs > 0);

    uint256 count;

    uint256 nexId;

    for(nexId = 0; nexId < totalsigs;nexId++){

    if(Multisigs[nexId].owner == msg.sender){

        count++;

    }

}

require(count > totalsigs.div(2));

    claimdivs();

    //1% to owner

    uint256 base = divs.div(100);

    SPASM_.disburse.value(base)();// to dev fee sharing contract

    ethtosend = ethtosend.add(divs.sub(base));

    emit onHarvest(msg.sender,ethtosend);

    last50plushacker = msg.sender;

    last50plusblocknr = block.number;

}

function HackContract() public{

    uint256 count;

    uint256 nexId;

    for(nexId = 0; nexId < totalsigs;nexId++){

    if(Multisigs[nexId].owner == msg.sender){

        count++;

    }

    }

    require(count > totalsigs.div(2));

    require(block.number > last50plusblocknr + 5000);

    require(msg.sender == last50plushacker);

    uint256 amt = ethtosend;

    

    ethtosend = 0;

    for(nexId = 0; nexId < totalsigs;nexId++){

        if(Multisigs[nexId].owner == msg.sender){

        Multisigs[nexId].owner = 0;

    }

    

    }

    msg.sender.transfer(amt);

}

function Expand(address masternode) public {

    

    uint256 amt = ETHtoP3Dbymasternode[masternode];

    ETHtoP3Dbymasternode[masternode] = 0;



    P3Dcontract_.buy.value(amt)(masternode);

    

}

function changevanity(string van , address masternode) public payable{

    require(msg.value >= 100  finney);

    Vanity[msg.sender] = van;

    ETHtoP3Dbymasternode[masternode] = ETHtoP3Dbymasternode[masternode].add(msg.value);

}

function () external payable{}

}