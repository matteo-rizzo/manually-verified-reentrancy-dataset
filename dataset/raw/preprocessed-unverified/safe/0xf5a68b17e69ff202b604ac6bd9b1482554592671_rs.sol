/**
 *Submitted for verification at Etherscan.io on 2019-12-10
*/

pragma solidity ^0.5.11;







contract Token is IERC20, Owned {
    using SafeMath for uint256;

    // Constructor - Sets the token Owner
    constructor() public {
        owner = 0x08d19746Ee0c0833FC5EAF98181eB91DAEEb9abB;
        _balances[owner] = 10000000000000000000;
        emit Transfer(address(0), owner, 10000000000000000000);
    }

    // Token Setup
    string public constant name = "i Trade";
    string public constant symbol = "iTR";
    uint256 public constant decimals = 5;
    uint256 public supply = 10000000000000000000;

    // Burn event
    event Burn(address from, uint256 amount);
    event Mint(address to, uint256 amount);

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
        require(_balances[msg.sender] >= value, 'Sender does not have suffencient balance');
        require(to != address(this) || to != address(0), 'Cannot send to yourself or 0x0');
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
        require(value <= balanceOf(from), "Token Holder does not have enough balance");
        require(value <= allowance(from, msg.sender), "Transfer not approved by token holder");
        _balances[from] = _balances[from].sub(value);
        _balances[to] = _balances[to].add(value);
        _allowed[from][msg.sender] = _allowed[from][msg.sender].sub(value);
        emit Transfer(from, to, value);
        return true;
    }

    function burn(uint256 amount) public onlyOwner {
        require(_balances[msg.sender] >= amount, "Not enough balance");
        _balances[msg.sender] = _balances[msg.sender].sub(amount);
        supply = supply.sub(amount);
        emit Transfer(msg.sender, address(0), amount);
        emit Burn(msg.sender, amount);
    }
}