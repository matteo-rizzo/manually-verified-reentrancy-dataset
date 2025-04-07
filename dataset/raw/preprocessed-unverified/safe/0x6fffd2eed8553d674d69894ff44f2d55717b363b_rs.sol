/**
 *Submitted for verification at Etherscan.io on 2020-04-28
*/

/**
 *Submitted for verification at Etherscan.io on 2019-11-21
*/

pragma solidity >=0.5.3;





contract TRC20Interface {
    function totalSupply() public view returns (uint);
    function balanceOf(address tokenOwner) public view returns (uint balance);
    function allowance(address tokenOwner, address spender) public view returns (uint remaining);
    function transfer(address to, uint tokens) public returns (bool success);
    function approve(address spender, uint tokens) public returns (bool success);
    function transferFrom(address from, address to, uint tokens) public returns (bool success);

    event Transfer(address indexed from, address indexed to, uint tokens);
    event Approval(address indexed tokenOwner, address indexed spender, uint tokens);
}




contract BasicToken is TRC20Interface, Owned {
    using SafeMath for uint;

    string public symbol;
    string public  name;
    uint8 public decimals;
    uint256 internal total;

    mapping(address => uint) balances;
    mapping(address => mapping(address => uint)) allowed;

    constructor(string memory _symbol, string memory _name, uint8 _decimals, uint256 _total) public {
        symbol = _symbol;
        name = _name;
        decimals = _decimals;
        total = _total * 10**uint(decimals);
        balances[owner] = total;
        emit Transfer(address(0), owner, total);
    }

    function totalSupply() public view returns (uint) {
        return total.sub(balances[address(0)]);
    }

    function balanceOf(address tokenOwner) public view returns (uint balance) {
        return balances[tokenOwner];
    }

    function transfer(address to, uint tokens) public returns (bool success) {
        balances[msg.sender] = balances[msg.sender].sub(tokens);
        balances[to] = balances[to].add(tokens);
        emit Transfer(msg.sender, to, tokens);
        return true;
    }

    function approve(address spender, uint tokens) public returns (bool success) {
        allowed[msg.sender][spender] = tokens;
        emit Approval(msg.sender, spender, tokens);
        return true;
    }

    function transferFrom(address from, address to, uint tokens) public returns (bool success) {
        balances[from] = balances[from].sub(tokens);
        allowed[from][msg.sender] = allowed[from][msg.sender].sub(tokens);
        balances[to] = balances[to].add(tokens);
        emit Transfer(from, to, tokens);
        return true;
    }

    function allowance(address tokenOwner, address spender) public view returns (uint remaining) {
        return allowed[tokenOwner][spender];
    }

    function () external payable {
        revert("payable revert");
    }

}