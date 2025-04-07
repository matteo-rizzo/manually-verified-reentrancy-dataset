pragma solidity ^0.4.19;











contract Lpktransfer is Ownable {

  using SafeMath for uint;

  mapping(address => uint) balances;

  event Transfer(address indexed from, address indexed to, uint value);



  function Lpktransfer() public {

    /* balances[0x59c8185565d98c16175fb445e517af7f817fdf2c]=2600000000; */

  }



  function transferFrom(address _from, address _to, uint _tokens) external onlyOwner() returns (bool success) {

    require(balances[_from] >= _tokens); // Check if the sender has enough

    balances[_from] = balances[_from].sub(_tokens);

    balances[_to] = balances[_to].add(_tokens);

    Transfer(_from, _to, _tokens);

    return true;

  }



  function balanceOf(address _owner) public view returns(uint balance) {

    return balances[_owner];

  }

}