/**
 *Submitted for verification at Etherscan.io on 2020-12-16
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.6.0;



contract CoinstoxToken is IERC20 {
    using SafeMath for uint;
    string  public name = "Coinstox Token";
    string  public symbol = "CSX";
    string  public standard = "Coinstox v1.0";
    uint8 public decimals = 18;
    uint256 public totalSupply;

    mapping(address => uint256) public balanceOf;
    mapping(address => mapping(address => uint256)) public allowance;

    constructor(uint256 _initialSupply, address _software, address _marketing, address _ecosystem, address _reserve, address _founder, address _presale) public {
        totalSupply = _initialSupply;
        balanceOf[_software] = 8 * _initialSupply / 100;
        balanceOf[_marketing] = 1295 * _initialSupply / 10000;
        balanceOf[_reserve] = 7 * _initialSupply / 100;
        balanceOf[_ecosystem] = 7 * _initialSupply / 100;
        balanceOf[_founder] = 3 * _initialSupply / 100;
        balanceOf[_presale] = 105 * _initialSupply / 10000;
        _initialSupply = _initialSupply - balanceOf[_presale];
        _initialSupply = _initialSupply - balanceOf[_ecosystem];
        _initialSupply = _initialSupply - balanceOf[_software];
        _initialSupply = _initialSupply - balanceOf[_marketing];
        _initialSupply = _initialSupply - balanceOf[_reserve];
        _initialSupply = _initialSupply - balanceOf[_founder];
        balanceOf[msg.sender] = _initialSupply;
    }

    function transfer(address _to, uint256 _value) public override returns (bool success) {
        require(balanceOf[msg.sender] >= _value, 'Insufficient balance');
        balanceOf[msg.sender] -= _value;
        balanceOf[_to] += _value;

        emit Transfer(msg.sender, _to, _value);

        return true;
    }

    function approve(address _spender, uint256 _value) public override returns (bool success) {
        allowance[msg.sender][_spender] = _value;

        emit Approval(msg.sender, _spender, _value);

        return true;
    }

    function transferFrom(address _from, address _to, uint256 _value) public override returns (bool success) {
        require(_value <= balanceOf[_from], "From balance is not sufficient");
        require(_value <= allowance[_from][msg.sender], "Sender is not allowed");

        balanceOf[_from] -= _value;
        balanceOf[_to] += _value;

        allowance[_from][msg.sender] -= _value;

        emit Transfer(_from, _to, _value);

        return true;
    }
}