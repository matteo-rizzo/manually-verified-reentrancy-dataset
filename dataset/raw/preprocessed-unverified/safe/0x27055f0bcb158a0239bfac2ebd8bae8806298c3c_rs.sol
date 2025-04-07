pragma solidity ^0.4.18;
 
/* 
    NJES COIN
  
 */
 
contract ERC20Basic {
  uint256 public totalSupply;
  function balanceOf(address who) constant returns (uint256);
  function transfer(address to, uint256 value) returns (bool);
  event Transfer(address indexed from, address indexed to, uint256 value);
}

contract ERC20 is ERC20Basic {
  function allowance(address owner, address spender) constant returns (uint256);
  function transferFrom(address from, address to, uint256 value) returns (bool);
  function approve(address spender, uint256 value) returns (bool);
  event Approval(address indexed owner, address indexed spender, uint256 value);
}


 
contract BasicToken is ERC20Basic {
  using SafeMath for uint256;
  mapping(address => uint256) balances;
 
 function transfer(address _to, uint256 _value) returns (bool) {
    balances[msg.sender] = balances[msg.sender].sub(_value);
    balances[_to] = balances[_to].add(_value);
    Transfer(msg.sender, _to, _value);
    return true;
  }
 
  function balanceOf(address _owner) constant returns (uint256 balance) {
    return balances[_owner];
  }
}

contract StandardToken is ERC20, BasicToken {
  mapping (address => mapping (address => uint256)) allowed;
  function transferFrom(address _from, address _to, uint256 _value) returns (bool) {
    var _allowance = allowed[_from][msg.sender];
    balances[_to] = balances[_to].add(_value);
    balances[_from] = balances[_from].sub(_value);
    allowed[_from][msg.sender] = _allowance.sub(_value);
    Transfer(_from, _to, _value);
    return true;
  }
 
  function approve(address _spender, uint256 _value) returns (bool) {
   require((_value == 0) || (allowed[msg.sender][_spender] == 0));
    allowed[msg.sender][_spender] = _value;
    Approval(msg.sender, _spender, _value);
    return true;
  }
 
  /*
  Function to check the amount of tokens that an owner allowed to a spender.
  param _owner address The address which owns the funds.
  param _spender address The address which will spend the funds.
  return A uint256 specifing the amount of tokens still available for the spender.
   */
  function allowance(address _owner, address _spender) constant returns (uint256 remaining) {
    return allowed[_owner][_spender];
}
}
 
/*
The Ownable contract has an owner address, and provides basic authorization control
 functions, this simplifies the implementation of "user permissions".
 */

 
contract TheLiquidToken is StandardToken, Ownable {
    // mint can be finished and token become fixed for forever
  event Mint(address indexed to, uint256 amount);
  event MintFinished();
  bool mintingFinished = false;
  modifier canMint() {
    require(!mintingFinished);
    _;
  }
 
 function mint(address _to, uint256 _amount) onlyOwner canMint returns (bool) {
    totalSupply = totalSupply.add(_amount);
    balances[_to] = balances[_to].add(_amount);
    Mint(_to, _amount);
    return true;
  }
 
  /*
  Function to stop minting new tokens.
  return True if the operation was successful.
   */
  function finishMinting() onlyOwner returns (bool) {}
  
  function burn(uint _value)
        public
    {
        require(_value > 0);

        address burner = msg.sender;
        balances[burner] = balances[burner].sub(_value);
        totalSupply = totalSupply.sub(_value);
        Burn(burner, _value);
    }

    event Burn(address indexed burner, uint indexed value);
  
}
    
contract NJES is TheLiquidToken {
  string public constant name = "NJES COIN";
  string public constant symbol = "NJES";
  uint public constant decimals = 3;
  uint256 public initialSupply;
    
  function NJES () { 
     totalSupply = 2000000 * 10 ** decimals;
      balances[msg.sender] = totalSupply;
      initialSupply = totalSupply; 
        Transfer(0, this, totalSupply);
        Transfer(this, msg.sender, totalSupply);
  }
}