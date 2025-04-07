/**
 *Submitted for verification at Etherscan.io on 2020-10-23
*/

pragma solidity =0.5.16;


contract SafeMath {
    function safeAdd(uint a, uint b) public pure returns (uint c) {
        c = a + b;
        require(c >= a);
    }
    function safeSub(uint a, uint b) public pure returns (uint c) {
        require(b <= a);
        c = a - b;
    }
    function safeMul(uint a, uint b) public pure returns (uint c) {
        c = a * b;
        require(a == 0 || c / a == b);
    }
    function safeDiv(uint a, uint b) public pure returns (uint c) {
        require(b > 0);
        c = a / b;
    }
}


contract YearnFinanceNetwork is ERC20Interface, SafeMath, Owned {
    string public name;
    string public symbol;
    uint8 public decimals;
    uint public totalSupply;
    mapping(address => uint) public balances;
    mapping(address => mapping(address => uint)) public allowed;
   
   
     constructor () public {
        name = "Yearn Finance Network";
        symbol = "YFN";
        decimals = 18;
        totalSupply = 300000*10**uint(decimals);
        balances[msg.sender] = totalSupply;
    }
       
    function transfer(address to, uint value) public returns(bool) {
        require(balances[msg.sender] >= value);
        balances[msg.sender] -= value;
        balances[to] += value;
        emit Transfer(msg.sender, to, value);
        return true;
    }
   
    function transferFrom(address from, address to, uint value) public returns(bool) {
        uint allowance = allowed[from][msg.sender];
        require(balances[msg.sender] >= value && allowance >= value);
        allowed[from][msg.sender] -= value;
        balances[msg.sender] -= value;
        balances[to] += value;
        emit Transfer(msg.sender, to, value);
        return true;
    }
   
    function approve(address spender, uint value) public onlyOwner returns(bool) {
        require(spender != msg.sender);
        allowed[msg.sender][spender] = value;
        emit Approval(msg.sender, spender, value);
        return true;
    }
   
    function allowance(address owner, address spender) public view returns(uint) {
        return allowed[owner][spender];
    }
   
    function balanceOf(address owner) public view returns(uint) {
        return balances[owner];
    }
   
}