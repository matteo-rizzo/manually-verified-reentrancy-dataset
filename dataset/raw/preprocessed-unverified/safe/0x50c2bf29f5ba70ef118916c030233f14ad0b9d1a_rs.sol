/**
 *Submitted for verification at Etherscan.io on 2021-08-14
*/

pragma solidity 0.8.6;

// ----------------------------------------------------------------------------
// WYOC main contract (2021) 
//
// Symbol         : WYOC
// Name           : WYOC
// Initial supply : 10.000.000
// Decimals       : 18
// ----------------------------------------------------------------------------
// SPDX-License-Identifier: MIT
// ----------------------------------------------------------------------------









// ----------------------------------------------------------------------------
// WYOC ERC20 Token 
// ----------------------------------------------------------------------------
contract WYOC is Owned {
    using SafeMath for uint;

    bool public running = true;
    string public constant symbol = "WYOC";
    string public constant name = "Wrapped YoCoin";
    uint8 public constant decimals = 18;
    uint _totalSupply;

    mapping(address => uint) balances;
    mapping(address => mapping(address => uint)) allowed;
    
    event Transfer(address indexed from, address indexed to, uint tokens);
    event Approval(address indexed tokenOwner, address indexed spender, uint tokens);

    constructor() {
        _totalSupply = 10000000 * 10**uint(decimals);
        balances[owner] = _totalSupply;
        emit Transfer(address(0), owner, _totalSupply);
    }

    modifier isRunning {
        require(running);
        _;
    }

    function startStop () public onlyOwner returns (bool success) {
        if (running) { running = false; } else { running = true; }
        return true;
    }

    function totalSupply() public view returns (uint) {
        return _totalSupply;
    }

    function balanceOf(address tokenOwner) public view returns (uint balance) {
        return balances[tokenOwner];
    }

    function transfer(address to, uint tokens) public isRunning returns (bool success) {
        require(tokens <= balances[msg.sender]);
        require(to != address(0));
        _transfer(msg.sender, to, tokens);
        return true;
    }

    function _transfer(address from, address to, uint tokens) internal {
        balances[from] = balances[from].sub(tokens);
        balances[to] = balances[to].add(tokens);
        emit Transfer(from, to, tokens);
    }

    function approve(address spender, uint tokens) public isRunning returns (bool success) {
        _approve(msg.sender, spender, tokens);
        return true;
    }

    function increaseAllowance(address spender, uint addedTokens) public isRunning returns (bool success) {
        _approve(msg.sender, spender, allowed[msg.sender][spender].add(addedTokens));
        return true;
    }

    function decreaseAllowance(address spender, uint subtractedTokens) public isRunning returns (bool success) {
        _approve(msg.sender, spender, allowed[msg.sender][spender].sub(subtractedTokens));
        return true;
    }

    function approveAndCall(address spender, uint tokens, bytes memory data) public isRunning returns (bool success) {
        _approve(msg.sender, spender, tokens);
        ApproveAndCallFallBack(spender).receiveApproval(msg.sender, tokens, address(this), data);
        return true;
    }

    function _approve(address owner, address spender, uint value) internal {
        require(owner != address(0));
        require(spender != address(0));
        allowed[owner][spender] = value;
        emit Approval(owner, spender, value);
    }

    function transferFrom(address from, address to, uint tokens) public isRunning returns (bool success) {
        require(to != address(0));
        _approve(from, msg.sender, allowed[from][msg.sender].sub(tokens));
        _transfer(from, to, tokens);
        return true;
    }

    function allowance(address tokenOwner, address spender) public view returns (uint remaining) {
        return allowed[tokenOwner][spender];
    }

    function transferAnyERC20Token(address tokenAddress, uint tokens) public onlyOwner {
         ERC20Interface(tokenAddress).transfer(owner, tokens);
    }
    
    function burn(uint tokens) public returns (bool success) {
        require(tokens <= balances[msg.sender]);
        balances[msg.sender] = balances[msg.sender].sub(tokens);
        _totalSupply = _totalSupply.sub(tokens);
        emit Transfer(msg.sender, address(0), tokens);
        return true;
    }

    function mint(uint tokens) public onlyOwner returns (bool success) {
        balances[msg.sender] = balances[msg.sender].add(tokens);
        _totalSupply = _totalSupply.add(tokens);
        emit Transfer(address(0), msg.sender, tokens);
        return true;
    } 

    function multiTransfer(address[] memory to, uint[] memory values) public isRunning returns (uint) {
        require(to.length == values.length);
        require(to.length < 100);
        uint sum;
        for (uint j; j < values.length; j++) {
            sum += values[j];
        }
        require(sum <= balances[msg.sender]);
        balances[msg.sender] = balances[msg.sender].sub(sum);
        for (uint i; i < to.length; i++) {
            balances[to[i]] = balances[to[i]].add(values[i]);
            emit Transfer(msg.sender, to[i], values[i]);
        }
        return(to.length);
    }
}