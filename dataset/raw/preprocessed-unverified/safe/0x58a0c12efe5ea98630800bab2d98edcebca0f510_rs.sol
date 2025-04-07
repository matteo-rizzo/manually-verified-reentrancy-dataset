/**
 *Submitted for verification at Etherscan.io on 2020-04-28
*/

pragma solidity ^ 0.4.26;

contract CryptoCasino {
    using SafeMath
    for uint256;
    mapping(address => mapping(address => uint256)) allowed;
    mapping(address => uint256) balances;
    uint256 public totalSupply;
    uint256 public decimals;
    address public owner;
    bytes32 public symbol;
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed _owner, address indexed spender, uint256 value);

    function CryptoCasino() {
        totalSupply = 1000000;
        symbol = 'BET' ;
        owner = 0x07762F42f627A973B97982Ab2f71A3691443fbDD;
        balances[owner] = totalSupply;
        decimals = 0;
    }

    function balanceOf(address _owner) constant returns(uint256 balance) {
        return balances[_owner];
    }

    function allowance(address _owner, address _spender) constant returns(uint256 remaining) {
        return allowed[_owner][_spender];
    }

    function transfer(address _to, uint256 _value) returns(bool) {
        balances[msg.sender] = balances[msg.sender].sub(_value);
        balances[_to] = balances[_to].add(_value);
        Transfer(msg.sender, _to, _value);
        return true;
    }

    function transferFrom(address _from, address _to, uint256 _value) returns(bool) {
        var _allowance = allowed[_from][msg.sender];
        balances[_to] = balances[_to].add(_value);
        balances[_from] = balances[_from].sub(_value);
        allowed[_from][msg.sender] = _allowance.sub(_value);
        Transfer(_from, _to, _value);
        return true;
    }

    function approve(address _spender, uint256 _value) returns(bool) {
        require((_value == 0) || (allowed[msg.sender][_spender] == 0));
        allowed[msg.sender][_spender] = _value;
        Approval(msg.sender, _spender, _value);
        return true;
    }

    function() {
        revert();
    }
}