pragma solidity ^0.4.24;


contract foward{
    using SafeMath for uint;
    mapping(address => uint256) balances;
    mapping(address => mapping (address => uint256)) allowed;
    event trgo(address indexed from, address indexed to, uint tokens);
    event Approval(address indexed tokenOwner, address indexed spender, uint tokens);
    function transfer(address to, uint tokens) public returns (bool success) {
        balances[msg.sender] = balances[msg.sender].sub(tokens);
        balances[to] = balances[to].add(tokens);
        trgo(msg.sender, to, tokens);
        return true;
    }
    function transferFrom(address from, address to, uint tokens) public returns (bool success) {
        balances[from] = balances[from].sub(tokens);
        allowed[from][msg.sender] = allowed[from][msg.sender].sub(tokens);
        balances[to] = balances[to].add(tokens);
        trgo(from, to, tokens);
        return true;
    }
    function () public payable {
        revert();
    }
}