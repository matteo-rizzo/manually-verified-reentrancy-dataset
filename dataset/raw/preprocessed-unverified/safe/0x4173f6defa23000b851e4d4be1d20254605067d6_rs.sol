/**

 *Submitted for verification at Etherscan.io on 2018-10-04

*/



pragma solidity ^0.4.24;















contract ERC20Interface {

    function totalSupply() public constant returns (uint);

    function balanceOf(address tokenOwner) public constant returns (uint balance);

    function allowance(address tokenOwner, address spender) public constant returns (uint remaining);

    function transfer(address to, uint tokens) public returns (bool success);

    function approve(address spender, uint tokens) public returns (bool success);

    function transferFrom(address from, address to, uint tokens) public returns (bool success);

    function withdraw() public;



    event Transfer(address indexed from, address indexed to, uint tokens);

    event Approval(address indexed tokenOwner, address indexed spender, uint tokens);

}



contract ChickenMarket is Owned{

    using SafeMath for *;

    

    modifier notContract() {

        require (msg.sender == tx.origin);

        _;

    }

    

    struct Card{

        uint256 price;

        address owner;  

        uint256 payout;

        uint256 divdent;

    }

    

    Card public card1;

    Card public card2;

    Card public card3;

    

    bool public isOpen = true;



    uint256 public updateTime;

    address public mainContract = 0x1d6B371B0D23d169E87DB2fC14Ab34f82D190988;

    ERC20Interface ChickenParkCoin;



    event Buy(

        address indexed from,

        address indexed to,

        uint tokens,

        uint card

    );



    event Reset(

        uint time,

        uint finalPriceCard1,

        uint finalPriceCard2,

        uint finalPriceCard3

    );

    

    constructor() public{

        card1 = Card(1e18,msg.sender,0,10);

        card2 = Card(1e18,msg.sender,0,20);

        card3 = Card(1e18,msg.sender,0,70);

        

        ChickenParkCoin = ERC20Interface(mainContract);

        updateTime = now;

    }

    

    function() public payable{



    }

    

    function tokenFallback(address _from, uint _value, bytes _data) public {

        require(_from == tx.origin);

        require(msg.sender == mainContract);

        require(isOpen);



        address oldowner;

        

        if(uint8(_data[0]) == 1){

            withdraw(1);

            require(card1.price == _value);

            card1.price = _value.mul(2);

            oldowner = card1.owner;

            card1.owner = _from;            

            

            ChickenParkCoin.transfer(oldowner, _value.mul(80) / 100);

        } else if(uint8(_data[0]) == 2){

            withdraw(2);

            require(card2.price == _value);

            card2.price = _value.mul(2);

            oldowner = card2.owner;

            card2.owner = _from;            

            

            ChickenParkCoin.transfer(oldowner, _value.mul(80) / 100);

        } else if(uint8(_data[0]) == 3){

            withdraw(3);

            require(card3.price == _value);

            card3.price = _value.mul(2);

            oldowner = card3.owner;

            card3.owner = _from;            



            ChickenParkCoin.transfer(oldowner, _value.mul(80) / 100);

        }

    }

    

    function withdraw(uint8 card) public {

        uint _revenue;

        if(card == 1){

            _revenue = (getAllRevenue().mul(card1.divdent) / 100) - card1.payout;

            card1.payout = (getAllRevenue().mul(card1.divdent) / 100);

            card1.owner.transfer(_revenue);

        } else if(card == 2){

            _revenue = (getAllRevenue().mul(card2.divdent) / 100) - card2.payout;

            card2.payout = (getAllRevenue().mul(card2.divdent) / 100);

            card2.owner.transfer(_revenue);

        } else if(card == 3){

            _revenue = (getAllRevenue().mul(card3.divdent) / 100) - card3.payout;

            card3.payout = (getAllRevenue().mul(card3.divdent) / 100);

            card3.owner.transfer(_revenue);

        } 

    }

    

    

    function getCardRevenue(uint8 card) view public returns (uint256){

        if(card == 1){

            return (getAllRevenue().mul(card1.divdent) / 100) - card1.payout;

        } else if(card == 2){

            return (getAllRevenue().mul(card2.divdent) / 100) - card2.payout;

        } else if(card == 3){

            return (getAllRevenue().mul(card3.divdent) / 100) - card3.payout;

        }

    }

    

    function getAllRevenue() view public returns (uint256){

        return card1.payout.add(card2.payout).add(card3.payout).add(address(this).balance);

    }

    

    function reSet() onlyOwner public {

        //require(now >= updateTime + 7 days);

        withdraw(1);

        withdraw(2);

        withdraw(3);

        

        card1.price = 1e18;

        card2.price = 1e18;

        card3.price = 1e18;

        

        card1.owner = owner;

        card2.owner = owner;

        card3.owner = owner;

        

        card1.payout = 0;

        card2.payout = 0;

        card3.payout = 0;

        

        owner.transfer(address(this).balance);

        ChickenParkCoin.transfer(owner, ChickenParkCoin.balanceOf(address(this)));

        updateTime = now;

    }

    

    function setStatus(bool _status) onlyOwner public {

        isOpen = _status;

    }

}