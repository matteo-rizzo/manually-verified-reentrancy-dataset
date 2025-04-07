/**

 *Submitted for verification at Etherscan.io on 2018-11-18

*/



pragma solidity ^0.4.25;

//CONTRACT BUILD ALPHA_01











contract WhiteList is Ownable {



    mapping(address => address) whiteList;



    constructor() public {

        whiteList[msg.sender] = msg.sender;

    }



    function add(address who) public onlyOwner() {

        require(who != address(0), "Invalid address");

        whiteList[who] = who;

    }



    function remove(address who) public onlyOwner() {

        require(who != address(0), "Invalid address");

        delete whiteList[who];

    }



    function isWhiteListed(address who) public view returns (bool) {

        return whiteList[who] != address(0);

    }

}



// import "./Ownable.sol";

// import "./SafeMath.sol";

// import "./WhiteList.sol";



contract Sh8pe is Ownable, WhiteList {

    using SafeMath for uint;



    string public name;

    string public symbol;

    uint8 public decimals;

    uint256 public totalSupply;



    mapping (address => uint256) balances;

    mapping (address => mapping (address => uint256)) allowed;



    constructor () public {



        name = "Angel Token";

        symbol = "Angels";

        decimals = 18;

        totalSupply = 100000000;



        balances[msg.sender] = totalSupply;

        emit Transfer(this, msg.sender, totalSupply);

    }



    function balanceOf(address who) public view returns (uint256) {

        return balances[who];

    }



    //THIS IS A FUNCTION USED BE THE MASTER WALLET TO TRANSFER FUNDS BETWEEN ACCOUNTS ON THE NETWORK

    function transfer(address from, address to, uint256 value) public returns (bool) {

        require(isWhiteListed(msg.sender) == true, "Not white listed");

        require(balances[from] >= value, "Insufficient balance"); //CHECK IF FROM ADDRESS HAS ENOUGH BALANCE



        balances[from] = balances[from].sub(value); //SUB FROM SENDING ADDRESS

        balances[to] = balances[to].add(value); //ADD TO OTHER ADDRESS



        emit Transfer(msg.sender, to, value);

        return true;

    }



    event Approval(address indexed owner, address indexed spender, uint256 value);

    event Transfer(address indexed from, address indexed to, uint256 value);

}