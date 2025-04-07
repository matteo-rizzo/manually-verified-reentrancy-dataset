pragma solidity ^0.4.18;



/**
 * @title SafeMath
 * @dev Math operations with safety checks that throw on error
 */


contract Nickelcoin is IERC20 {
    
    using SafeMath for uint256;
    
    string public constant name = "Nickelcoin";  
    string public constant symbol = "NKL"; 
    uint8 public constant decimals = 8;  
    uint public  _totalSupply = 4000000000000000; 
    
   
    mapping (address => uint256) public funds; 
    mapping(address => mapping(address => uint256)) allowed;
    
    event Transfer(address indexed from, address indexed to, uint256 value);  
    
    function Nickelcoin() public {
    funds[0xa33c5838B8169A488344a9ba656420de1db3dc51] = _totalSupply; 
    }
     
    function totalSupply() public constant returns (uint256 totalsupply) {
        return _totalSupply;
    }
    
    function balanceOf(address _owner) public constant returns (uint256 balance) {
        return funds[_owner];  
    }
        
    function transfer(address _to, uint256 _value) public returns (bool success) {
   
    require(funds[msg.sender] >= _value && funds[_to].add(_value) >= funds[_to]);

    
    funds[msg.sender] = funds[msg.sender].sub(_value); 
    funds[_to] = funds[_to].add(_value);       
  
    Transfer(msg.sender, _to, _value); 
    return true;
    }
	
    function transferFrom(address _from, address _to, uint _value) public returns (bool success) {
        require (allowed[_from][msg.sender] >= _value);   
        require (_to != 0x0);                            
        require (funds[_from] >= _value);               
        require (funds[_to].add(_value) > funds[_to]); 
        funds[_from] = funds[_from].sub(_value);   
        funds[_to] = funds[_to].add(_value);        
        allowed[_from][msg.sender] = allowed[_from][msg.sender].sub(_value);
        Transfer(_from, _to, _value);                 
        return true;                                      
    }
    
    function approve(address _spender, uint256 _value) public returns (bool success) {
         allowed[msg.sender][_spender] = _value;    
         Approval (msg.sender, _spender, _value);   
         return true;                               
     }
    
    function allowance(address _owner, address _spender) public constant returns (uint256 remaining) {
      return allowed[_owner][_spender];   
    } 
    

}