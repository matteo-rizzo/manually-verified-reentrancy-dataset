pragma solidity ^0.4.11;



contract ownable {

    address public owner;

    modifier onlyOwner {
        if (!isOwner(msg.sender)) throw;
        _;
    }

    function ownable() {
        owner = msg.sender;
    }

    function transferOwnership(address _newOwner) onlyOwner {
        owner = _newOwner;
    }

    function isOwner(address _address) returns (bool) {
        return owner == _address;
    }
}


contract Burnable {

    event Burn(address indexed owner, uint amount);
    function burn(address _owner, uint _amount) public;

}


contract ERC20 {
    uint public totalSupply;
    
    function totalSupply() constant returns (uint);
    function balanceOf(address _owner) constant returns (uint);
    function allowance(address _owner, address _spender) constant returns (uint);
    function transfer(address _to, uint _value) returns (bool);
    function transferFrom(address _from, address _to, uint _value) returns (bool);
    function approve(address _spender, uint _value) returns (bool);
    
    event Approval(address indexed owner, address indexed spender, uint value);
    event Transfer(address indexed from, address indexed to, uint value);
}


contract Mintable {

    event Mint(address indexed to, uint value);
    function mint(address _to, uint _amount) public;
}

contract Token is ERC20, Mintable, Burnable, ownable {
    using SafeMath for uint;

    string public name;
    string public symbol;

    uint public decimals = 18;
    uint public maxSupply;
    uint public totalSupply;
    uint public freezeMintUntil;

    mapping (address => mapping (address => uint)) allowed;
    mapping (address => uint) balances;

    modifier canMint {
        require(totalSupply < maxSupply);
        _;
    }

    modifier mintIsNotFrozen {
        require(freezeMintUntil < now);
        _;
    }

    function Token(string _name, string _symbol, uint _maxSupply) {
        name = _name;
        symbol = _symbol;
        maxSupply = _maxSupply;
        totalSupply = 0;
        freezeMintUntil = 0;
    }

    function totalSupply() constant returns (uint) {
        return totalSupply;
    }

    function balanceOf(address _owner) constant returns (uint) {
        return balances[_owner];
    }

    function allowance(address _owner, address _spender) constant returns (uint) {
        return allowed[_owner][_spender];
    }

    function transfer(address _to, uint _value) returns (bool) {
        if (_value <= 0) {
            return false;
        }

        balances[msg.sender] = balances[msg.sender].sub(_value);
        balances[_to] = balances[_to].add(_value);

        Transfer(msg.sender, _to, _value);
        return true;
    }

    function transferFrom(address _from, address _to, uint _value) returns (bool) {
        if (_value <= 0) {
            return false;
        }

        balances[_from] = balances[_from].sub(_value);
        balances[_to] = balances[_to].add(_value);

        allowed[_from][msg.sender] = allowed[_from][msg.sender].sub(_value);
        Transfer(_from, _to, _value);
        return true;
    }

    function approve(address _spender, uint _value) returns (bool) {
        allowed[msg.sender][_spender] = _value;
        Approval(msg.sender, _spender, _value);
        return true;
    }

    function mint(address _to, uint _amount) public canMint mintIsNotFrozen onlyOwner {
        if (maxSupply < totalSupply.add(_amount)) throw;

        totalSupply = totalSupply.add(_amount);
        balances[_to] = balances[_to].add(_amount);

        Mint(_to, _amount);
    }

    function burn(address _owner, uint _amount) public onlyOwner {
        totalSupply = totalSupply.sub(_amount);
        balances[_owner] = balances[_owner].sub(_amount);

        Burn(_owner, _amount);
    }

    function freezeMintingFor(uint _weeks) public onlyOwner {
        freezeMintUntil = now + _weeks * 1 weeks;
    }
}