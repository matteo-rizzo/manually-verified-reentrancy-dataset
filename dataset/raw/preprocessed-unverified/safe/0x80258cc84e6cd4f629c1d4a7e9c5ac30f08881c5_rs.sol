pragma solidity ^0.4.18;





contract ERC20Basic {
  uint256 public totalSupply;
  function balanceOf(address who) public view returns (uint256);
  function transfer(address to, uint256 value) public returns (bool);
  event Transfer(address indexed from, address indexed to, uint256 value);
}

contract BasicToken is ERC20Basic {
  using SafeMath for uint256;

  mapping(address => uint256) balances;

  function transfer(address _to, uint256 _value) public returns (bool) {
    require(_to != address(0));
    require(_value <= balances[msg.sender]);

    balances[msg.sender] = balances[msg.sender].sub(_value);
    balances[_to] = balances[_to].add(_value);
    Transfer(msg.sender, _to, _value);
    return true;
  }

  function balanceOf(address _owner) public view returns (uint256 balance) {
    return balances[_owner];
  }
}

// built upon OpenZeppelin

contract Base is BasicToken, Ownable {
  using SafeMath for uint256;
  string public constant url = "https://base.very.systems";

  string public constant name = "Base";
  string public constant symbol = "BASE";
  uint256 public constant decimals = 0;

  uint256 public constant price = 3906250000000000;

  function () external payable {
    require(msg.value != 0);

    uint256 value = msg.value;
    uint256 amount = value.div(price);

    totalSupply = totalSupply.add(amount);
    balances[msg.sender] = balances[msg.sender].add(amount);
    Transfer(address(0), msg.sender, amount);

    owner.transfer(msg.value);
  }

  uint256 public constant initialSupply = 32768;

  function Base() public {
    totalSupply = totalSupply.add(initialSupply);
    balances[owner] = balances[owner].add(initialSupply);
    Transfer(address(0), owner, initialSupply);
  }
}