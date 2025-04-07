/**

 *Submitted for verification at Etherscan.io on 2018-12-22

*/



pragma solidity ^0.5.2;















contract BXIT is IERC20, Owned {

    using SafeMath for uint256;

    

    // Constructor - Sets the token Owner

    constructor() public {

        owner = 0xaDdFB942659bDD72b389b50A8BEb3Dbb75C43780;

    }

    

    // Token Setup

    string public constant name = "Boxroi Ticket";

    string public constant symbol = "BXIT";

    uint256 public constant decimals = 2;

    uint256 public supply = 0;

    uint256 private nonce;

    address public BXI = 0xd1766Cc0a81e40d488d16357B590A0D009E0d927;

    

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

        require(to != BXI || to != address(this));

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

        require(value <= balanceOf(from));

        require(value <= allowance(from, to));

        require(to != BXI || to != address(this));

        _balances[from] = _balances[from].sub(value);

        _balances[to] = _balances[to].add(value);

        _allowed[from][to] = _allowed[from][to].sub(value);

        emit Transfer(from, to, value);

        return true;

    }

    

    // Revert when sent Ether

    function () external payable {

        revert();

    }

    

    // Owner can mint new tokens, but supply cannot exceed 89 Million

    function mint(uint256 amount) public onlyOwner {

        _balances[msg.sender] = _balances[msg.sender].add(amount);

        supply = supply.add(amount);

        emit Transfer(address(0), msg.sender, amount);

    }

    

    // Owner should initially set the BXI contract address

    function setBXIAddress(address _address) public onlyOwner {

        BXI = _address;

    }

}