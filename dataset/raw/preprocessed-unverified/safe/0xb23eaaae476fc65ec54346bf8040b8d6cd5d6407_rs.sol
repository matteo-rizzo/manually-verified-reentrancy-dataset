/**

 *Submitted for verification at Etherscan.io on 2018-10-13

*/



pragma solidity ^0.4.18;



// ----------------------------------------------------------------------------

// Symbol      : PT

// Name        : Spinach Coin

// Total supply: 5000000000.000000

// Decimals    : 6

// ----------------------------------------------------------------------------





// ----------------------------------------------------------------------------

// Safe maths

// ----------------------------------------------------------------------------





contract ERC20Interface {

    function totalSupply() public constant returns (uint);

    function balanceOf(address tokenOwner) public constant returns (uint balance);

    function allowance(address tokenOwner, address spender) public constant returns (uint remaining);

    function transfer(address to, uint tokens) public returns (bool success);

    function approve(address spender, uint tokens) public returns (bool success);

    function transferFrom(address from, address to, uint tokens) public returns (bool success);



    event Transfer(address indexed from, address indexed to, uint tokens);

    event Approval(address indexed tokenOwner, address indexed spender, uint tokens);

}





contract ApproveAndCallFallBack {

    function receiveApproval(address from, uint256 tokens, address token, bytes data) public;

}





// ----------------------------------------------------------------------------

// Owned contract

// ----------------------------------------------------------------------------







contract Token is ERC20Interface, Owned {

    using SafeMath for uint;



    string public symbol;

    string public  name;

    uint8 public decimals;

    uint public _totalSupply;



    mapping(address => uint) balances;

    mapping(address => mapping(address => uint)) allowed;





    function Token() public {

        symbol = "PT";

        name = "Spinach Coin";

        decimals = 6;

        _totalSupply = 5000000000 * 10**uint(decimals);

        balances[owner] = _totalSupply;

        Transfer(address(0), owner, _totalSupply);

    }





    function totalSupply() public constant returns (uint) {

        return _totalSupply  - balances[address(0)];

    }



    function balanceOf(address tokenOwner) public constant returns (uint balance) {

        return balances[tokenOwner];

    }





    function transfer(address to, uint tokens) public returns (bool success) {

        balances[msg.sender] = balances[msg.sender].sub(tokens);

        balances[to] = balances[to].add(tokens);

        Transfer(msg.sender, to, tokens);

        return true;

    }





    function approve(address spender, uint tokens) public returns (bool success) {

        allowed[msg.sender][spender] = tokens;

        Approval(msg.sender, spender, tokens);

        return true;

    }





    function transferFrom(address from, address to, uint tokens) public returns (bool success) {

        balances[from] = balances[from].sub(tokens);

        allowed[from][msg.sender] = allowed[from][msg.sender].sub(tokens);

        balances[to] = balances[to].add(tokens);

        Transfer(from, to, tokens);

        return true;

    }





    function allowance(address tokenOwner, address spender) public constant returns (uint remaining) {

        return allowed[tokenOwner][spender];

    }





    function approveAndCall(address spender, uint tokens, bytes data) public returns (bool success) {

        allowed[msg.sender][spender] = tokens;

        Approval(msg.sender, spender, tokens);

        ApproveAndCallFallBack(spender).receiveApproval(msg.sender, tokens, this, data);

        return true;

    }





    function () public payable {

        revert();

    }





    function transferAnyERC20Token(address tokenAddress, uint tokens) public onlyOwner returns (bool success) {

        return ERC20Interface(tokenAddress).transfer(owner, tokens);

    }

}