/**

 *Submitted for verification at Etherscan.io on 2018-10-26

*/



pragma solidity ^0.4.16;









contract ERC20Basic {

  uint public totalSupply;

  function balanceOf(address who) public constant returns (uint);

  function transfer(address to, uint value) public;

  event Transfer(address indexed from, address indexed to, uint value);

}



contract ERC20 is ERC20Basic {

  function allowance(address owner, address spender) public constant returns (uint);

  function transferFrom(address from, address to, uint value) public;

  function approve(address spender, uint value) public;

  event Approval(address indexed owner, address indexed spender, uint value);

}



contract BasicToken is ERC20Basic {

  

  using SafeMath for uint;

  

  mapping(address => uint) balances;



  function transfer(address _to, uint _value) public{

    balances[msg.sender] = balances[msg.sender].sub(_value);

    balances[_to] = balances[_to].add(_value);

    Transfer(msg.sender, _to, _value);

  }



  function balanceOf(address _owner) public constant returns (uint balance) {

    return balances[_owner];

  }

}





contract StandardToken is BasicToken, ERC20 {

  mapping (address => mapping (address => uint)) allowed;



  function transferFrom(address _from, address _to, uint _value) public {

    balances[_to] = balances[_to].add(_value);

    balances[_from] = balances[_from].sub(_value);

    allowed[_from][msg.sender] = allowed[_from][msg.sender].sub(_value);

    Transfer(_from, _to, _value);

  }



  function approve(address _spender, uint _value) public{

    require((_value == 0) || (allowed[msg.sender][_spender] == 0)) ;

    allowed[msg.sender][_spender] = _value;

    Approval(msg.sender, _spender, _value);

  }



  function allowance(address _owner, address _spender) public constant returns (uint remaining) {

    return allowed[_owner][_spender];

  }

}











contract IBMI is StandardToken, Ownable {

  string public constant name = "IBMI";

  string public constant symbol = "IBMI";

  uint public constant decimals = 18;





  function IBMI() public {

      totalSupply = 1000000000000000000000000000;

      balances[msg.sender] = totalSupply; // Send all tokens to owner

  }





  function burn(uint _value) onlyOwner public returns (bool) {

    balances[msg.sender] = balances[msg.sender].sub(_value);

    totalSupply = totalSupply.sub(_value);

    Transfer(msg.sender, 0x0, _value);

    return true;

  }



}