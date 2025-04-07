/**

 *Submitted for verification at Etherscan.io on 2019-01-29

*/



pragma solidity ^0.5.0;



contract ERC20Basic {

    

  function totalSupply() public view returns (uint256);

  function balanceOf(address any) public view returns (uint256);

  function transfer(address to, uint256 value) public returns (bool);

  event Transfer(address indexed from, address indexed to, uint256 value);

  

}







contract BasicToken is ERC20Basic {

  using SafeMath for uint256;



  mapping(address => uint256) balances;



  uint256 totalSupply_;





  function totalSupply() public view returns (uint256) {

    return totalSupply_;

  }





  function transfer(address _to, uint256 _value) public returns (bool) {

    require(_to != address(0));

    require(_value <= balances[msg.sender]);



    balances[msg.sender] = balances[msg.sender].sub(_value);

    balances[_to] = balances[_to].add(_value);

    emit Transfer(msg.sender, _to, _value);

    return true;

  }



  function balanceOf(address _owner) public view returns (uint256) {

    return balances[_owner];

  }

}





contract StandardToken is BasicToken {

}







contract MintableToken is StandardToken, Ownable {

  event Mint(address indexed to, uint256 amount);

  event MintFinished();

  event Burn(address indexed _from, uint256 amount);



  bool public mintingFinished = false;





  modifier canMint() {

    require(!mintingFinished);

    _;

  }

  

  modifier canBurn() {

    require(!mintingFinished);

    _;

  }



  modifier hasMintPermission() {

    require(msg.sender == owner);

    _;

  }

  

   modifier hasBurnPermission() {

    require(msg.sender == owner);

    _;

  }

 



  function mint(address _to, uint256 _amount) hasMintPermission canMint public returns (bool) {

    totalSupply_ = totalSupply_.add(_amount);

    balances[_to] = balances[_to].add(_amount);

    emit Mint(_to, _amount);

    emit Transfer(address(0), _to, _amount);

    return true;

  }

  

  function finishMinting() onlyOwner canMint public returns (bool) {

    mintingFinished = true;

    emit MintFinished();

    return true;

  }



  function burn(uint256 _amount) hasBurnPermission canBurn public returns (bool) {

    totalSupply_ = totalSupply_.sub(_amount);

    balances[msg.sender] = balances[msg.sender].sub(_amount);

    emit Burn(msg.sender, _amount);

    return true;

  }

}



contract Pausable is Ownable {

  event Pause();

  event Unpause();



  bool public paused = false;



  modifier whenNotPaused() {

    require(!paused);

    _;

  }



  modifier whenPaused() {

    require(paused);

    _;

  }



  function pause() onlyOwner whenNotPaused public {

    paused = true;

    emit Pause();

  }



  function unpause() onlyOwner whenPaused public {

    paused = false;

    emit Unpause();

  }

}



contract PausableToken is StandardToken, Pausable {



  function transfer(

    address _to,

    uint256 _value

  )

    public

    whenNotPaused

    returns (bool)

  {

    return super.transfer(_to, _value);

    

  }



}



contract TEST365 is MintableToken, PausableToken {



  string  public name;

  string  public symbol;

  uint256 public decimals;



  constructor() public {

    name = " Test365 Token";

    symbol = "TEST365";

    decimals = 0;

    

    

  }

}