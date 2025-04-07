/**
 *Submitted for verification at Etherscan.io on 2019-09-06
*/

/**
 *Submitted for verification at Etherscan.io on 2019-05-03
*/

pragma solidity ^0.5.7;



contract ERC223ReceivingContract { 
    function tokenFallback(address _from, uint _value, bytes32 _data) public;
}

/**
 * @title SafeMath
 * @dev Math operations with safety checks that throw on error
 */



contract YardToken is ERC223Interface {
    using SafeMath for uint;
     
    string internal _name;
    string internal _symbol;
    uint8 internal _decimals;
    uint256 internal _totalSupply;

    mapping (address => uint256) internal balances;
    mapping (address => mapping (address => uint256)) internal allowed;
    mapping (string => string) encryptedData;
    
    constructor () public {
        _name = 'Yard Coin';
        _symbol = 'YARD';
        _decimals = 4;
        _totalSupply = 100000000000000;
        balances[msg.sender] = _totalSupply;
  }
  
    function saveData(string memory uniqueNo,string memory encryptedKey) public {
        encryptedData[uniqueNo] = encryptedKey;
    }
    
    function getEncryptedKey(string memory uniqueNo) view public returns(string memory encryptedKey){
        return encryptedData[uniqueNo];
    }

    function name() public view returns (string memory) {
        return _name;
    }

    function symbol() public view returns (string memory) {
        return _symbol;
    }

    function decimals() public view returns (uint8) {
        return _decimals;
    }

    function totalSupply() public view returns (uint256) {
        return _totalSupply;
    }

   function balanceOf(address _owner) public view returns (uint256 balance) {
    return balances[_owner];
   }

  function approve(address _spender, uint256 _value) public returns (bool) {
     allowed[msg.sender][_spender] = _value;
     emit Approval(msg.sender, _spender, _value);
     return true;
   }

  function allowance(address _owner, address _spender) public view returns (uint256) {
     return allowed[_owner][_spender];
   }

   function increaseApproval(address _spender, uint _addedValue) public returns (bool) {
     allowed[msg.sender][_spender] = SafeMath.add(allowed[msg.sender][_spender], _addedValue);
     emit Approval(msg.sender, _spender, allowed[msg.sender][_spender]);
     return true;
   }

  function decreaseApproval(address _spender, uint _subtractedValue) public returns (bool) {
     uint oldValue = allowed[msg.sender][_spender];
     if (_subtractedValue > oldValue) {
       allowed[msg.sender][_spender] = 0;
     } else {
       allowed[msg.sender][_spender] = SafeMath.sub(oldValue, _subtractedValue);
    }
     emit Approval(msg.sender, _spender, allowed[msg.sender][_spender]);
     return true;
   }
   
   function isContract(address _addr) view private returns (bool is_contract) {
      uint length;
      assembly {
            //retrieve the size of the code on target address, this needs assembly
            length := extcodesize(_addr)
      }
      return (length>0);
    }
   
    function transfer(address _to, uint256 _value) public returns(bool){
        require(_value > 0 );
        bytes32 empty;

        if(isContract(_to)) {
            ERC223ReceivingContract receiver = ERC223ReceivingContract(_to);
            receiver.tokenFallback(msg.sender, _value, empty);
        }
        balances[msg.sender] = balances[msg.sender].sub(_value);
        balances[_to] = balances[_to].add(_value);
        emit Transfer(msg.sender, _to, _value);
        return true;
    } 
    
    function transferFrom(address _from, address _to, uint256 _value) public returns (bool) {
        require(_to != address(0));
        require(_value <= balances[_from]);
        require(_value <= allowed[_from][msg.sender]);
        
        require(_value > 0 );
        bytes32 empty;

        if(isContract(_to)) {
            ERC223ReceivingContract receiver = ERC223ReceivingContract(_to);
            receiver.tokenFallback(msg.sender, _value, empty);
        }

        balances[_from] = SafeMath.sub(balances[_from], _value);
        balances[_to] = SafeMath.add(balances[_to], _value);
        allowed[_from][msg.sender] = SafeMath.sub(allowed[_from][msg.sender], _value);
        emit Transfer(_from, _to, _value);
        return true;
   }
}