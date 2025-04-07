/**

 *Submitted for verification at Etherscan.io on 2019-06-02

*/



pragma solidity ^0.5.0;







contract ERC20Basic is Ownable {

  uint256 public totalSupply;

  function balanceOf(address who) public view returns (uint256);

  function transfer(address to, uint256 value) public returns (bool);

  event Transfer(address indexed from, address indexed to, uint256 value);

}



contract ERC20 is ERC20Basic {

  function allowance(address owner, address spender) public view returns (uint256);

  function transferFrom(address from, address to, uint256 value) public returns (bool);

  function approve(address spender, uint256 value) public returns (bool);

  event Approval(address indexed owner, address indexed spender, uint256 value);

}







contract BasicToken is ERC20Basic {



  using SafeMath for uint256;



  mapping(address => uint256) balances;



  function transfer(address _to, uint256 _value) public returns (bool) {

    balances[msg.sender] = balances[msg.sender].sub(_value);

    balances[_to] = balances[_to].add(_value);

    emit Transfer(msg.sender, _to, _value);

    return true;

  }



  function balanceOf(address _owner) public view returns  (uint256 balance) {

    return balances[_owner];

  }



}



contract StandardToken is ERC20, BasicToken {



  mapping (address => mapping (address => uint256)) allowed;



  function transferFrom(address _from, address _to, uint256 _value) public returns (bool) {

    uint256 _allowance = allowed[_from][msg.sender];



    balances[_to] = balances[_to].add(_value);

    balances[_from] = balances[_from].sub(_value);

    allowed[_from][msg.sender] = _allowance.sub(_value);

    emit Transfer(_from, _to, _value);

    return true;

  }



  function approve(address _spender, uint256 _value) public returns (bool) {



    require((_value == 0) || (allowed[msg.sender][_spender] == 0), "value=0");



    allowed[msg.sender][_spender] = _value;

    emit Approval(msg.sender, _spender, _value);

    return true;

  }



  function allowance(address _owner, address _spender) public view returns (uint256 remaining) {

    return allowed[_owner][_spender];

  }



  function increaseAllowance(address spender, uint256 addedValue) public returns (bool) {

      require(spender != address(0), "address is empty");



      allowed[msg.sender][spender] = allowed[msg.sender][spender].add(addedValue);

      emit Approval(msg.sender, spender, allowed[msg.sender][spender]);



      return true;

  }



  function decreaseAllowance(address spender, uint256 subtractedValue) public returns (bool) {



      require(spender != address(0), "address is empty");



      allowed[msg.sender][spender] = allowed[msg.sender][spender].sub(subtractedValue);

      emit Approval(msg.sender, spender, allowed[msg.sender][spender]);



      return true;



  }



}



contract GoldSmartProduction is StandardToken {



  string public constant name     = "Gold Smart Production";

  string public constant symbol   = "GSPR";

  uint32 public constant decimals = 18;

  uint256 public INITIAL_SUPPLY   = 2000000000 * (10 ** uint256(decimals));



  constructor() public {

    totalSupply = INITIAL_SUPPLY;

    balances[msg.sender] = INITIAL_SUPPLY;

  }



}