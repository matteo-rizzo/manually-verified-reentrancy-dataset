/**
 *Submitted for verification at Etherscan.io on 2021-08-18
*/

pragma solidity ^0.5.17;








contract ERC20 is IERC20 {
  using SafeMath for uint256;

  uint256 public totalSupply;
  mapping (address => uint256) public balanceOf;
  mapping (address => mapping (address => uint256)) public allowance;

  function approve(address _spender, uint256 _value) public returns (bool) {
    _approve(msg.sender, _spender, _value);
    return true;
  }

  function increaseAllowance(address _spender, uint256 _value) public returns (bool) {
    _approve(msg.sender, _spender, allowance[msg.sender][_spender].add(_value));
    return true;
  }

  function decreaseAllowance(address _spender, uint256 _value) public returns (bool) {
    _approve(msg.sender, _spender, allowance[msg.sender][_spender].sub(_value));
    return true;
  }

  function transfer(address _to, uint256 _value) public returns (bool _success) {
    _transfer(msg.sender, _to, _value);
    return true;
  }

  function transferFrom(address _from, address _to, uint256 _value) public returns (bool _success) {
    _transfer(_from, _to, _value);
    _approve(_from, msg.sender, allowance[_from][msg.sender].sub(_value));
    return true;
  }

  function _approve(address _owner, address _spender, uint256 _amount) internal {
    require(_owner != address(0), "ERC20: approve from the zero address");
    require(_spender != address(0), "ERC20: approve to the zero address");

    allowance[_owner][_spender] = _amount;
    emit Approval(_owner, _spender, _amount);
  }

  function _transfer(address _from, address _to, uint256 _value) internal {
    require(_from != address(0), "ERC20: transfer from the zero address");
    require(_to != address(0), "ERC20: transfer to the zero address");
    require(_to != address(this), "ERC20: transfer to this contract address");

    balanceOf[_from] = balanceOf[_from].sub(_value);
    balanceOf[_to] = balanceOf[_to].add(_value);
    emit Transfer(msg.sender, _to, _value);
  }
}





contract ERC20Detailed is ERC20, IERC20Detailed {
  string public name;
  string public symbol;
  uint8 public decimals;

  constructor(string memory _name, string memory _symbol, uint8 _decimals) public {
    name = _name;
    symbol = _symbol;
    decimals = _decimals;
  }
}


contract OXI is ERC20Detailed {
  constructor()
    public
    ERC20Detailed("Oxie", "OXI", 18)
  {
    totalSupply = uint256(770000000).mul(uint256(10)**18);
    balanceOf[msg.sender] = totalSupply;
    emit Transfer(address(0), msg.sender, totalSupply);
  }
}