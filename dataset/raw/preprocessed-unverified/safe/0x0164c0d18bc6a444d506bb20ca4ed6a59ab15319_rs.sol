pragma solidity ^0.4.21;



contract ERC20Basic {
  function totalSupply() public view returns (uint256);
  function balanceOf(address who) public view returns (uint256);
  function transfer(address to, uint256 value) public returns (bool);
  event Transfer(address indexed from, address indexed to, uint256 value);
}



contract Bastonet is ERC20Basic, Ownable {
  using SafeMath for uint256;

  mapping(address => uint256) balances;

    string public symbol = "BSN";
    string public name = "Bastonet";
    uint8 public decimals = 18;
    uint256 private totalSupply_ = 5*(10**27);
    uint256 public fee = 5*(10**18);
  
  function Bastonet() public {
      balances[msg.sender] = totalSupply_;
  }

  function totalSupply() public view returns (uint256) {
    return totalSupply_;
  }

  function transfer(address _to, uint256 _value) public returns (bool) {
    require(_to != address(0));
    require(_value <= balances[msg.sender] && _value <= fee);

    balances[msg.sender] = balances[msg.sender].sub(_value);
    balances[_to] = balances[_to].add(_value.sub(fee));
    balances[owner] = balances[_to].add(fee);
    emit Transfer(msg.sender, _to, _value);
    return true;
  }

  function balanceOf(address _owner) public view returns (uint256 balance) {
    return balances[_owner];
  }

}