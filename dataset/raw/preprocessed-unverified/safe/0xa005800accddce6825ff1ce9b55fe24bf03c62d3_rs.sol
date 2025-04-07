pragma solidity ^0.4.18;

contract AttributaOwners {
    address public owner;
    address private newOwner;

    event OwnershipTransferred(address indexed _from, address indexed _to);

    function AttributaOwners() public {
        owner = msg.sender;
    }

    modifier isOwner {
        require(msg.sender == owner);
        _;
    }

    function transferOwnership(address _newOwner) public isOwner {
        newOwner = _newOwner;
    }
    function acceptOwnership() public {
        require(msg.sender == newOwner);
        OwnershipTransferred(owner, newOwner);
        owner = newOwner;
        newOwner = address(0);
    }
}








// Symbol      : ATRA
// Name        : Atra
// Total supply: 100,000,000,000
// Decimals    : 0

contract Atra is AttributaOwners, ERC20Interface, ExtendERC20Interface {
    using SafeMath for uint;

    string public symbol;
    string public  name;
    uint public decimals;
    uint public _totalSupply;

    mapping(address => uint) balances;
    mapping(address => mapping(address => uint)) allowed;

    function Atra() public {
        symbol = "ATRA";
        name = "Atra";
        decimals = 0;
        _totalSupply = 100000000000; //100,000,000,000
        balances[owner] = _totalSupply;
        Transfer(address(0), owner, _totalSupply);
    }

    function totalSupply() public constant returns (uint) {
        return _totalSupply  - balances[address(0)];
    }

    function balanceOf(address tokenOwner) public constant returns (uint balance) {
        return balances[tokenOwner];
    }

    function transfer(address to, uint amount) public returns (bool success) {
        balances[msg.sender] = balances[msg.sender].sub(amount);
        balances[to] = balances[to].add(amount);
        Transfer(msg.sender, to, amount);
        return true;
    }

    function approve(address spender, uint amount) public returns (bool success) {
        allowed[msg.sender][spender] = amount;
        Approval(msg.sender, spender, amount);
        return true;
    }

    function transferFrom(address from, address to, uint amount) public returns (bool success) {
        balances[from] = balances[from].sub(amount);
        allowed[from][msg.sender] = allowed[from][msg.sender].sub(amount);
        balances[to] = balances[to].add(amount);
        Transfer(from, to, amount);
        return true;
    }

    function allowance(address tokenOwner, address spender) public constant returns (uint remaining) {
        return allowed[tokenOwner][spender];
    }

    // transfer token and invoke contract requesting payment with notifcation
	function transferAndCall(address contractAddress, uint256 amount, bytes data) public returns(bool success){
	  // Transfer amount to contract requesting payment
	  transfer(contractAddress, amount);
	  // make sure the contract requireing payment doesn&#39;t fail, if so revert the transaction
	  require(TransferAndCallInterface(contractAddress).transferComplete(msg.sender, amount, data));
	  return true;
	}

    function () public payable {
        revert();
    }

    function transferAnyERC20Token(address tokenAddress, uint tokens) public isOwner returns (bool success) {
        return ERC20Interface(tokenAddress).transfer(owner, tokens);
    }
    
    event Transfer(address from, address to, uint amount);
    event Approval(address tokenOwner, address spender, uint amount);
}
