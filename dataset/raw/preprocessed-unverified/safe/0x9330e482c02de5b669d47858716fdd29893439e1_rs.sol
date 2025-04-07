/**
 *Submitted for verification at Etherscan.io on 2019-08-09
*/

/* Game Fanz Token */
/* Contract Developed by James Galbraith, https://decentralised.tech */

pragma solidity ^0.5.10;







contract GFNX is IERC20, Owned {
    using SafeMath for uint256;
    
    // Constructor - Sets the token Owner
    constructor() public {
        owner = 0x5cb7e87f0985BABd78629f40491d76eF84d06d9e;
        _balances[0x5cb7e87f0985BABd78629f40491d76eF84d06d9e] = supply;
        emit Transfer(address(0), 0x5cb7e87f0985BABd78629f40491d76eF84d06d9e, supply);
    }
    
    // Token Setup
    string public constant name = "Game Fanz";
    string public constant symbol = "GFNX";
    uint256 public constant decimals = 18;
    uint256 public supply = 500000000 * 10 ** decimals;
    
    // Burn event
    event Burn(address from, uint256 amount);
    
    // Balances for each account
    mapping(address => uint256) _balances;
 
    // Owner of account approves the transfer of an amount to another account
    mapping(address => mapping (address => uint256)) public _allowed;
 
    // Get the total supply of tokens
    function totalSupply() public view returns (uint) {
        return supply;
    }
 
    // Get the token balance for account `tokenOwner`
    function balanceOf(address tokenOwner) public view returns (uint balance) {
        return _balances[tokenOwner];
    }
 
    // Get the allowance of funds beteen a token holder and a spender
    function allowance(address tokenOwner, address spender) public view returns (uint remaining) {
        return _allowed[tokenOwner][spender];
    }
 
    // Transfer the balance from owner's account to another account
    function transfer(address to, uint value) public returns (bool success) {
        require(_balances[msg.sender] >= value);
        require(to != address(this) || to != address(0));
        _balances[msg.sender] = _balances[msg.sender].sub(value);
        if (to == address(0)) {
            supply = supply.sub(value);
            emit Burn(msg.sender, value);
        } else {
            _balances[to] = _balances[to].add(value);
        }
        emit Transfer(msg.sender, to, value);
        return true;
    }
    
    // Sets how much a sender is allowed to use of an owners funds
    function approve(address spender, uint value) public returns (bool success) {
        _allowed[msg.sender][spender] = value;
        emit Approval(msg.sender, spender, value);
        return true;
    }
    
    // Transfer from function, pulls from allowance
    function transferFrom(address from, address to, uint value) public returns (bool success) {
        require(value <= balanceOf(from));
        require(value <= allowance(from, to));
        _balances[from] = _balances[from].sub(value);
        _balances[to] = _balances[to].add(value);
        _allowed[from][to] = _allowed[from][to].sub(value);
        emit Transfer(from, to, value);
        return true;
    }
    
    function burn(uint256 amount) public {
        require(_balances[msg.sender] >= amount);
        _balances[msg.sender] = _balances[msg.sender].sub(amount);
        supply = supply.sub(amount);
        emit Transfer(msg.sender, address(0), amount);
        emit Burn(msg.sender, amount);
    }
}