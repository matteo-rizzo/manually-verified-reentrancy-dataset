pragma solidity ^0.4.15;


 


contract HONIGToken  {
    using SafeMath for uint256;
    
    string public constant symbol = "HONEY";
    string public constant name = "HONIGToken";
    uint8 public constant decimals = 1;
	address public owner;
	uint256 _totalSupply = 1000000;
	
	// Ledger of the balance of the account
	mapping (address => uint256) balances;
	// Owner of account approves transfer of an account to another account
    mapping (address => mapping (address => uint256)) allowed;
    
    // Events can be trigger when certain actions happens
    // Triggered when tokens are transferred
    event Transfer(address indexed _from, address indexed _to, uint256 _value);
    
    // Triggered whenever approve(address _spender, uint256 _value) is called.
    event Approval(address indexed _owner, address indexed _spender, uint256 _value);
    
    // Constructor
    function HONIGToken() {
         owner = msg.sender;
         balances[owner] = _totalSupply;
     }


     /* Send coins */
    function transfer(address _to, uint256 _value) {
        require(balances[msg.sender] >= _value);           // Check if the sender has enough
        require(balances[_to] + _value >= balances[_to]); // Check for overflows
        balances[msg.sender] -= _value;                    // Subtract from the sender
        balances[_to] += _value;                           // Add the same to the recipient
    }
}