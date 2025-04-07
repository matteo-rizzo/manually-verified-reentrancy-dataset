/**
 *Submitted for verification at Etherscan.io on 2021-09-30
*/

pragma solidity ^0.5.0;



contract ERC20Base is ERC20Interface {

    mapping (address => uint256) public _balances;
    mapping (address => mapping (address => uint256)) public _allowances;
    uint256 public _totalSupply;

    function transfer(address _to, uint256 _value) public returns (bool success) {

        if (_balances[msg.sender] >= _value && _value > 0) {
            _balances[msg.sender] -= _value;
            _balances[_to] += _value;
            emit Transfer(msg.sender, _to, _value);
            return true;
        } else { 
            return false;
        }
    }

    function transferFrom(address _from, address _to, uint256 _value) public returns (bool success) {

        if (_balances[_from] >= _value && _allowances[_from][msg.sender] >= _value && _value > 0) {
            _balances[_to] += _value;
            _balances[_from] -= _value;
            _allowances[_from][msg.sender] -= _value;
            emit Transfer(_from, _to, _value);
            return true;
        } else {
            return false;
        }
    }

    function balanceOf(address _owner) public view returns (uint256 balance) {
        return _balances[_owner];
    }

    function approve(address _spender, uint256 _value) public returns (bool success) {
        _allowances[msg.sender][_spender] = _value;
        emit Approval(msg.sender, _spender, _value);
        return true;
    }

    function allowance(address _owner, address _spender) public view returns (uint256 remaining) {
      return _allowances[_owner][_spender];
    }
    
    function totalSupply() public view returns (uint256 total) {
        return _totalSupply;
    }
}

contract SYSP is ERC20Base {

    string private _name;
    string private _symbol;
    uint8 private _decimals;
    
    constructor (string memory name, string memory symbol, uint8 decimals, uint256 initialSupply) public payable {
        _name = name;
        _symbol = symbol;
        _decimals = decimals;
        _totalSupply = initialSupply;
        _balances[msg.sender] = initialSupply;
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

}