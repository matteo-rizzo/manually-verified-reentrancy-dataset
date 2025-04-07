/**

 *Submitted for verification at Etherscan.io on 2019-04-22

*/



pragma solidity ^0.4.24;



//Created by SVOVY



contract ERC20Simple {

  function totalSupply() public view returns (uint256);

  function balanceOf(address _who) public view returns (uint256);

  function transfer(address _to, uint256 _value) public returns (bool);

  event Transfer(address indexed from, address indexed to, uint256 value);

}









contract CRNToken is  ERC20Simple {

  using SafeMath for uint256;



  mapping(address => uint256) internal balances;



  uint256 internal totalSupply_;





  function totalSupply() public view returns (uint256) {

    return totalSupply_;

  }





  function transfer(address _to, uint256 _value) public returns (bool) {

    require(_value <= balances[msg.sender]);

    require(_to != address(0));

    

    balances[msg.sender] = balances[msg.sender].sub(_value);

    balances[_to] = balances[_to].add(_value);

    emit Transfer(msg.sender, _to, _value);

    return true;

  }

  





  function balanceOf(address _owner) public view returns (uint256) {

    return balances[_owner];

  }



}





contract FLXCoin is CRNToken {



  event Burn(address indexed burner, uint256 value);



	string public name = "FLX Coin";

	string public symbol = "FLX";

	uint8 public decimals = 2;

	uint public INITIAL_SUPPLY = 1000000000000;

	

    function burn(uint256 _value) public {

        _burn(msg.sender, _value);

    }



	constructor() public {

	  totalSupply_ = INITIAL_SUPPLY;

	  balances[msg.sender] = INITIAL_SUPPLY;

	}

	

  function _burn(address _who, uint256 _value) internal {

    require(_value <= balances[_who]);



    balances[_who] = balances[_who].sub(_value);

    totalSupply_ = totalSupply_.sub(_value);

    emit Burn(_who, _value);

    emit Transfer(_who, address(0), _value);

  }

}