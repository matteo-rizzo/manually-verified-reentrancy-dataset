pragma solidity ^0.4.11;



contract ERC20Basic {
  uint public totalSupply;
  function balanceOf(address who) constant returns (uint);
  function transfer(address to, uint value);
  event Transfer(address indexed from, address indexed to, uint value);
}

contract ERC20 is ERC20Basic {
  function allowance(address owner, address spender) constant returns (uint);
  function transferFrom(address from, address to, uint value);
  function approve(address spender, uint value);
  event Approval(address indexed owner, address indexed spender, uint value);
}

contract BasicToken is ERC20Basic {
  using SafeMath for uint;

  mapping(address => uint) balances;

  modifier onlyPayloadSize(uint size) {
     if(msg.data.length < size + 4) {
       throw;
     }
     _;
  }

  function transfer(address _to, uint _value) onlyPayloadSize(2 * 32) {
    balances[msg.sender] = balances[msg.sender].sub(_value);
    balances[_to] = balances[_to].add(_value);
    Transfer(msg.sender, _to, _value);
  }

  function balanceOf(address _owner) constant returns (uint balance) {
    return balances[_owner];
  }

}

contract StandardToken is BasicToken, ERC20 {

  mapping (address => mapping (address => uint)) allowed;

  function transferFrom(address _from, address _to, uint _value) onlyPayloadSize(3 * 32) {
    var _allowance = allowed[_from][msg.sender];
    balances[_to] = balances[_to].add(_value);
    balances[_from] = balances[_from].sub(_value);
    allowed[_from][msg.sender] = _allowance.sub(_value);
    Transfer(_from, _to, _value);
  }


  function approve(address _spender, uint _value) {
    if ((_value != 0) && (allowed[msg.sender][_spender] != 0)) throw;
    allowed[msg.sender][_spender] = _value;
    Approval(msg.sender, _spender, _value);
  }

  function allowance(address _owner, address _spender) constant returns (uint remaining) {
    return allowed[_owner][_spender];
  }
}

contract ALT is StandardToken{
    string public constant name = "atlmart";
    string public constant symbol = "ALT";
    uint public constant decimals = 18;
    string public constant version = "1.0";
    uint public constant price =20000;
    uint public issuedNum = 0; 
    uint public issueIndex = 0;
    address public target;
    address public owner;
    
    event Issue(uint issueIndex, address addr, uint ethAmount, uint tokenAmount);
    
    modifier onlyOwner{
      if(msg.sender != owner) throw;
      _;
    }
    
    function ALT(address _target){
        owner = msg.sender;
        totalSupply = 8*(10**7)*(10**decimals); //init planed totalnumber
        target = _target; //init target address for receiving eth
    }

    function changeOwner(address newOwner) onlyOwner{
      owner = newOwner;
    }
    
    //get alt by eth
    function () payable{
        //compute alt number
        if(msg.value > 0)
        {
            uint  amount = price.mul(msg.value);
            if(totalSupply >= issuedNum+amount){
                balances[msg.sender] = balances[msg.sender].add(amount);
                issuedNum = issuedNum.add(amount);
                if (!target.send(msg.value)) {
                    throw;
                }
                Issue(issueIndex++, msg.sender,msg.value, amount);
            }else{
                throw;
            }
        }else{
            throw;
        }
    }
    
    //change target
    function changeTarget(address _target) onlyOwner{
        target = _target;
    }
    
    function kill() onlyOwner{
        suicide(owner);
    }
}