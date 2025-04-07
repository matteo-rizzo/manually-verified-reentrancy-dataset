pragma solidity ^0.4.15;



contract TokenEIP20 {

    function balanceOf(address _owner) constant returns (uint256 balance);
    function transfer(address _to, uint256 _value) returns (bool success);
    function transferFrom(address _from, address _to, uint256 _value) returns (bool success);
    function approve(address _spender, uint256 _value) returns (bool success);
    function allowance(address _owner, address _spender) constant returns (uint256 remaining);

    event Transfer(address indexed _from, address indexed _to, uint256 _value);
    event Approval(address indexed _owner, address indexed _spender, uint256 _value);
    
}

contract TokenNotifier {

    function receiveApproval(address from, uint256 _amount, address _token, bytes _data);
}



contract BattleToken is Owned, TokenEIP20 {
    using SafeMathLib for uint256;
    
    mapping (address => uint256) balances;
    mapping (address => mapping (address => uint256)) allowed;
    
    string  public constant name        = "Battle";
    string  public constant symbol      = "BTL";
    uint256 public constant decimals    = 18;
    uint256 public constant totalSupply = 1000000 * (10 ** decimals);

    function BattleToken(address _battleAddress) {
        balances[owner] = totalSupply;
        require(approve(_battleAddress, totalSupply));
    }

    function transfer(address _to, uint256 _value) returns (bool success) {
        if (balances[msg.sender] < _value) {
            return false;
        }
        balances[msg.sender] = balances[msg.sender].sub(_value);
        assert(balances[msg.sender] >= 0);
        balances[_to] = balances[_to].add(_value);
        assert(balances[_to] <= totalSupply);
        Transfer(msg.sender, _to, _value);
        return true;
    }

    function transferFrom(address _from, address _to, uint256 _value) returns (bool success) {
        if (balances[_from] < _value || allowed[_from][msg.sender] < _value) {
            return false;
        }
        balances[_from] = balances[_from].sub(_value);
        assert(balances[_from] >= 0);
        allowed[_from][msg.sender] = allowed[_from][msg.sender].sub(_value);
        balances[_to] = balances[_to].add(_value);
        assert(balances[_to] <= totalSupply);        
        Transfer(_from, _to, _value);
        return true;
    }

    function approve(address _spender, uint256 _value) returns (bool success) {
        allowed[msg.sender][_spender] = _value;
        Approval(msg.sender, _spender, _value);
        return true;
    }

    function approveAndCall(address _spender, uint256 _value, bytes _extraData) returns (bool success) {
        if (!approve(_spender, _value)) {
            return false;
        }
        TokenNotifier(_spender).receiveApproval(msg.sender, _value, this, _extraData);
        return true;
    }

    function balanceOf(address _owner) constant returns (uint256 balance) {
        return balances[_owner];
    }

    function allowance(address _owner, address _spender) constant returns (uint256 remaining) {
        return allowed[_owner][_spender];
    }
}