/**
 *Submitted for verification at Etherscan.io on 2020-07-07
*/

pragma solidity ^0.4.26;
    


contract ERC20Basic {
    uint public decimals;
    string public    name;
    string public   symbol;
    mapping(address => uint) public balances;
    mapping (address => mapping (address => uint)) public allowed;
    
    
    uint public _totalSupply;
    function totalSupply() public constant returns (uint);
    function balanceOf(address who) public constant returns (uint);
    function transfer(address to, uint value) public;
    event Transfer(address indexed from, address indexed to, uint value);
}

contract ERC20 is ERC20Basic {
    function allowance(address owner, address spender) public constant returns (uint);
    function transferFrom(address from, address to, uint value) public;
    function approve(address spender, uint value) public;
    event Approval(address indexed owner, address indexed spender, uint value);
}
 


contract ERCToken is ERC20{
    using SafeMath for uint;
    

    address public platformAdmin;
    

    mapping(address => bool) public lockUsers;    
    
    modifier onlyOwner() {
        require(msg.sender == platformAdmin);
        _;
    }
    
    

    constructor(string _tokenName, string _tokenSymbol,uint256 _decimals,uint _initialSupply) public {
        platformAdmin = msg.sender;
        _totalSupply = _initialSupply * 10 ** uint256(_decimals); 
        decimals=_decimals;
        name = _tokenName;
        symbol = _tokenSymbol;
        balances[msg.sender]=_totalSupply;
    }
    

  
    
    
     function totalSupply() public constant returns (uint){
         return _totalSupply;
     }
     
      function balanceOf(address _owner) constant returns (uint256 balance) {
            return balances[_owner];
          }
  
        function approve(address _spender, uint _value) {
            allowed[msg.sender][_spender] = _value;
            Approval(msg.sender, _spender, _value);
        }
        
      
        function allowance(address _owner, address _spender) constant returns (uint256 remaining) {
          return allowed[_owner][_spender];
        }
        
        
       function transfer(address _to, uint _value) public {
            require(lockUsers[msg.sender]==false);
            require(balances[msg.sender] >= _value);
            require(balances[_to].add(_value) > balances[_to]);
            balances[msg.sender]=balances[msg.sender].sub(_value);
            balances[_to]=balances[_to].add(_value);
            Transfer(msg.sender, _to, _value);
        }
   
        function transferFrom(address _from, address _to, uint256 _value) public  {
            require(lockUsers[_from]==false);
            require(balances[_from] >= _value);
            require(allowed[_from][msg.sender] >= _value);
            require(balances[_to] + _value > balances[_to]);
            balances[_to]=balances[_to].add(_value);
            balances[_from]=balances[_from].sub(_value);
            allowed[_from][msg.sender]=allowed[_from][msg.sender].sub(_value);
            Transfer(_from, _to, _value);
        }
        
 
       function lockAddr(address _user,bool _islock) onlyOwner returns (bool success) {
            if (msg.sender != _user) revert();
            lockUsers[_user]=_islock;
            return true;
       }
        
         function lockAddrs(address[] _targets,bool _islock) onlyOwner returns (bool success) {
            for (uint i = 0; i < _targets.length; i++) {
                address _target = _targets[i];
                lockUsers[_target] = _islock;
            }
            return true;
        } 
    
    
}