/**

 *Submitted for verification at Etherscan.io on 2018-08-10

*/



pragma solidity ^0.4.24;







contract ERC20 {

  function totalSupply() public view returns (uint256);

  function balanceOf(address _who) public view returns (uint256);

  function allowance(address _owner, address _spender) public view returns (uint256);

  function transfer(address _to, uint256 _value) public returns (bool);

  function approve(address _spender, uint256 _value) public returns (bool);

  function transferFrom(address _from, address _to, uint256 _value) public returns (bool);

  event Transfer(address indexed from, address indexed to, uint256 value);

  event Approval(address indexed owner, address indexed spender, uint256 value);

}







contract AdjustableToken is ERC20, Ownable {

  using SafeMath for uint256;



  uint256 totalSupply_;

  bool public adjusted;

  mapping(address => uint256) balances;

  mapping (address => mapping (address => uint256)) internal allowed;



  event Adjusted(address indexed who, uint256 value);

  modifier onlyOnce() { require(!adjusted); _; }



  function totalSupply() public view returns (uint256) {

    return totalSupply_;

  }



  function balanceOf(address _owner) public view returns (uint256) {

    return balances[_owner];

  }



  function allowance(address _owner, address _spender) public view returns (uint256) {

    return allowed[_owner][_spender];

  }



  function transfer(address _to, uint256 _value) public returns (bool) {

    require(_value <= balances[msg.sender]);

    require(_to != address(0));



    balances[msg.sender] = balances[msg.sender].sub(_value);

    balances[_to] = balances[_to].add(_value);

    emit Transfer(msg.sender, _to, _value);

    return true;

  }



  function approve(address _spender, uint256 _value) public returns (bool) {

    allowed[msg.sender][_spender] = _value;

    emit Approval(msg.sender, _spender, _value);

    return true;

  }



  function transferFrom(address _from, address _to, uint256 _value) public returns (bool) {

    require(_value <= balances[_from]);

    require(_value <= allowed[_from][msg.sender]);

    require(_to != address(0));



    balances[_from] = balances[_from].sub(_value);

    balances[_to] = balances[_to].add(_value);

    allowed[_from][msg.sender] = allowed[_from][msg.sender].sub(_value);

    emit Transfer(_from, _to, _value);

    return true;

  }



  function increaseApproval(address _spender, uint256 _addedValue) public returns (bool) {

    allowed[msg.sender][_spender] = (allowed[msg.sender][_spender].add(_addedValue));

    emit Approval(msg.sender, _spender, allowed[msg.sender][_spender]);

    return true;

  }



  function decreaseApproval(address _spender, uint256 _subtractedValue) public returns (bool) {

    uint256 oldValue = allowed[msg.sender][_spender];

    if (_subtractedValue >= oldValue) {

      allowed[msg.sender][_spender] = 0;

    } else {

      allowed[msg.sender][_spender] = oldValue.sub(_subtractedValue);

    }

    emit Approval(msg.sender, _spender, allowed[msg.sender][_spender]);

    return true;

  }



  function adjustSupply(uint256 _value) external onlyOwner() onlyOnce() {

    adjusted = true;

    require(_value <= balances[msg.sender]);

    balances[msg.sender] = balances[msg.sender].sub(_value);

    totalSupply_ = totalSupply_.sub(_value);

    emit Adjusted(msg.sender, _value);

    emit Transfer(msg.sender, address(0), _value);

  }

}



contract BitSongToken is AdjustableToken {

  string public name;

  string public symbol;

  uint8 public decimals;



  constructor(string _name, string _symbol, uint8 _decimals, uint256 _initialSupply) public {

    name = _name;

    symbol = _symbol;

    decimals = _decimals;

    totalSupply_ = _initialSupply * 10**uint256(decimals);

    balances[msg.sender] = totalSupply_;

  }

}