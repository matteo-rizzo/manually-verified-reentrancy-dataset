/**

 *Submitted for verification at Etherscan.io on 2018-10-18

*/



pragma solidity ^0.4.24;









  

contract ERC20 {



    function totalSupply() public returns (uint256);

    function balanceOf(address who) public returns (uint256);

    function transfer(address to, uint256 value) public returns (bool success);



    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approval(address indexed owner, address indexed spender, uint256 value);



}



contract BTNYToken is Ownable, ERC20 {



    using SafeMath for uint256;



    // Token properties

    string public name = "Bitney";                //Token name

    string public symbol = "BTNY";                  //Token symbol

    uint256 public decimals = 18;



    uint256 public _totalSupply = 1000000000e18;



    // Balances for each account

    mapping (address => uint256) balances;



    // Owner of account approves the transfer of an amount to another account

    mapping (address => mapping(address => uint256)) allowed;



    // Wallet Address of Token

    address public multisig;



    constructor () public payable {

        // Initial Owner Wallet Address

        multisig = msg.sender;



        balances[multisig] = _totalSupply;



        owner = msg.sender;

    }



    function withdraw(address to, uint256 value) public onlyOwner {

        require(to != 0x0);

        uint256 transferValue = value.mul(10e18);

        to.transfer(transferValue);

        emit Transfer(owner, to, transferValue);

    }



    function () external payable {

        tokensale(msg.sender);

    }



    function tokensale(address recipient) public payable {

        require(recipient != 0x0);

    }



    function totalSupply() public returns (uint256) {

        return _totalSupply;

    }



    function balanceOf(address who) public returns (uint256) {

        return balances[who];

    }



    function transfer(address to, uint256 value) public returns (bool success)  {

        uint256 transferValue = value.mul(1e18);

        require (balances[msg.sender] >= transferValue && transferValue > 0);



        balances[msg.sender] = balances[msg.sender].sub(transferValue);

        balances[to] = balances[to].add(transferValue);

        emit Transfer(msg.sender, to, transferValue);

        return true;

    }

}