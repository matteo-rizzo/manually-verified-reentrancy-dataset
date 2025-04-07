/**

 *Submitted for verification at Etherscan.io on 2018-09-21

*/



pragma solidity ^0.4.25;











contract ERC20Interface {

    function name() public constant returns (string);

    function symbol() public constant returns (string);

    function decimals() public constant returns (uint8);

    function totalSupply() public constant returns (uint);

    function balanceOf(address tokenOwner) public constant returns (uint balance);

    function allowance(address tokenOwner, address spender) public constant returns (uint remaining);

    function transfer(address to, uint tokens) public returns (bool success);

    function approve(address spender, uint tokens) public returns (bool success);

    function transferFrom(address from, address to, uint tokens) public returns (bool success);



    event Transfer(address indexed from, address indexed to, uint tokens);

    event Approval(address indexed tokenOwner, address indexed spender, uint tokens);

}











contract ZygStop is Owned {



    bool public stopped = false;



    modifier stoppable {

        assert (!stopped);

        _;

    }

    function stop() public onlyOwner {

        stopped = true;

    }

    function start() public onlyOwner {

        stopped = false;

    }

}





contract Utils {

    function Utils() internal {

    }



    modifier validAddress(address _address) {

        require(_address != 0x0);

        _;

    }



    modifier notThis(address _address) {

        require(_address != address(this));

        _;

    }

}





contract BuyZygoma is Owned, ZygStop, Utils {

    using SafeMath for uint;

    ERC20Interface public zygomaAddress;



    function BuyZygoma(ERC20Interface _zygomaAddress) public{

        zygomaAddress = _zygomaAddress;

    }

        

    function withdrawTo(address to, uint amount)

        public onlyOwner

        notThis(to)

    {   

        require(amount <= this.balance);

        to.transfer(amount);

    }

    

    function withdrawERC20TokenTo(ERC20Interface token, address to, uint amount)

        public onlyOwner

        validAddress(token)

        validAddress(to)

        notThis(to)

    {

        assert(token.transfer(to, amount));



    }

    

    function buyToken() internal

    {

        require(!stopped && msg.value >= 0.001 ether);

        uint amount = msg.value * 350000;

        assert(zygomaAddress.transfer(msg.sender, amount));

    }



    function() public payable stoppable {

        buyToken();

    }

}