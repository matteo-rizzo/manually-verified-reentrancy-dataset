/**

 *Submitted for verification at Etherscan.io on 2018-12-28

*/



pragma solidity ^0.4.11;



/**

 * @title SafeMath

 * @dev Math operations with safety checks that throw on error

 */







contract ERC20Basic {

  uint256 public totalSupply;

  function balanceOf(address who) constant returns (uint256);

  function transfer(address to, uint256 value) returns (bool);

  event Transfer(address indexed from, address indexed to, uint256 value);

}





contract BasicToken is ERC20Basic {

  using SafeMath for uint256;



  mapping(address => uint256) balances;





  function transfer(address _to, uint256 _value) returns (bool) {

    balances[msg.sender] = balances[msg.sender].sub(_value);

    balances[_to] = balances[_to].add(_value);

    Transfer(msg.sender, _to, _value);

    return true;

  }





  function balanceOf(address _owner) constant returns (uint256 balance) {

    return balances[_owner];

  }



}





contract ERC20 is ERC20Basic {

  function allowance(address owner, address spender) constant returns (uint256);

  function transferFrom(address from, address to, uint256 value) returns (bool);

  function approve(address spender, uint256 value) returns (bool);

  event Approval(address indexed owner, address indexed spender, uint256 value);

}





contract StandardToken is ERC20, BasicToken {



  mapping (address => mapping (address => uint256)) allowed;





  

  function transferFrom(address _from, address _to, uint256 _value) returns (bool) {

    var _allowance = allowed[_from][msg.sender];



    

    balances[_to] = balances[_to].add(_value);

    balances[_from] = balances[_from].sub(_value);

    allowed[_from][msg.sender] = _allowance.sub(_value);

    Transfer(_from, _to, _value);

    return true;

  }



 

  function approve(address _spender, uint256 _value) returns (bool) {



    require((_value == 0) || (allowed[msg.sender][_spender] == 0));



    allowed[msg.sender][_spender] = _value;

    Approval(msg.sender, _spender, _value);

    return true;

  }



  function allowance(address _owner, address _spender) constant returns (uint256 remaining) {

    return allowed[_owner][_spender];

  }



}





contract BGC is StandardToken {



  string public constant name = "Black Gold Colony";

  string public constant symbol = "BGC";

  uint256 public constant decimals = 18;

  address public owner;

  



  uint256 public constant INITIAL_SUPPLY =1000000000000000000000000000;



  

  function BGC() {

    totalSupply = INITIAL_SUPPLY;

    owner = 0xaEeB8Ee16dB22915A2Be7c5046dd5a8966206528;

    balances[owner] = INITIAL_SUPPLY;

  }

  



  

 modifier onlyOwner() {

        assert(msg.sender == owner);

        _;

    }

  function transferOwnership(address newOwner) external onlyOwner {

        if (newOwner != address(0)) {

            owner = newOwner;

        }

    }

 

}