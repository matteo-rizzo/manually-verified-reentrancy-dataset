/**

 *Submitted for verification at Etherscan.io on 2018-12-25

*/



pragma solidity ^0.5.2;















contract IWAY is IERC20, Owned {

    using SafeMath for uint256;

    

    // Constructor - Sets the token Owner

    constructor() public {

        owner = 0x95cc7e685De21Fd004778A241EcC3DEEE93321f7;

        _balances[0x95cc7e685De21Fd004778A241EcC3DEEE93321f7] = supply;

        emit Transfer(address(0), owner, supply);

    }

    

    // Token Setup

    string public constant name = "InfluWay";

    string public constant symbol = "IWAY";

    uint256 public constant decimals = 8;

    uint256 public supply = 1500000000 * 10 ** decimals;

    

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

        require(to != address(this));

        _balances[msg.sender] = _balances[msg.sender].sub(value);

        _balances[to] = _balances[to].add(value);

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

        require(to != address(this));

        require(value <= balanceOf(from));

        require(value <= allowance(from, to));

        _balances[from] = _balances[from].sub(value);

        _balances[to] = _balances[to].add(value);

        _allowed[from][to] = _allowed[from][to].sub(value);

        emit Transfer(from, to, value);

        return true;

    }

    

    // No acidental ETH transfers to the contract.

    function () external payable {

        revert();

    }

    

    // Mint

    function mint(address to, uint256 value) public onlyOwner {

        _balances[to] = _balances[to].add(value);

        supply = supply.add(value);

        emit Transfer(address(0), to, value);

    }

    

    // Burn

    function burn(address from, uint256 value) public onlyOwner {

        require(_balances[from] <= value);

        _balances[from] = _balances[from].sub(value);

        supply = supply.sub(value);

        emit Transfer(from, address(0), value);

    }

}