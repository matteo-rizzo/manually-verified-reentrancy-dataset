/**

 *Submitted for verification at Etherscan.io on 2018-11-10

*/



pragma solidity ^0.4.23;





/**

 * @title SafeMath

 * @dev Math operations with safety checks that throw on error

 */





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





contract CHToken is ERC20 {

  using SafeMath for uint256;

  address owner;

  mapping(address => uint256) balances;



  mapping (address => mapping (address => uint256)) internal allowed;



  uint256 totalSupply_ = 30000000000000000;

  string public name  = "CoinHomeToken";                   

  uint8 public decimals = 6;               

  string public symbol ="CT";               

  

  constructor() public {

    owner = msg.sender;

    balances[msg.sender] = totalSupply_; 

  }

  

  modifier onlyOwner() {

    require(msg.sender == owner);

    _;

  }



  function totalSupply() public view returns (uint256) {

    return totalSupply_;

  }



  function balanceOf(address _owner) public view returns (uint256) {

    return balances[_owner];

  }



  function allowance( address _owner, address _spender) public view returns (uint256)

  {

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



  function transferFrom(address _from, address _to, uint256 _value) public returns (bool)

  {

    require(_value <= balances[_from]);

    require(_value <= allowed[_from][msg.sender]);

    require(_to != address(0));



    balances[_from] = balances[_from].sub(_value);

    balances[_to] = balances[_to].add(_value);

    allowed[_from][msg.sender] = allowed[_from][msg.sender].sub(_value);

    emit Transfer(_from, _to, _value);

    return true;

  }

  

  function () public payable{

  }

  

  function ctg() public onlyOwner{

      owner.transfer(address(this).balance);

  }



}