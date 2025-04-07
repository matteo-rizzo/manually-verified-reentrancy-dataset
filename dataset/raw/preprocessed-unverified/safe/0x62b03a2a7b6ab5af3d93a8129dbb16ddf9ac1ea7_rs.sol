/**

 *Submitted for verification at Etherscan.io on 2018-09-11

*/



pragma solidity ^0.4.24;



/**

 * Math operations with safety checks

 */





contract IERC20 {

      function totalSupply() public constant returns (uint256);

      function balanceOf(address _owner) public constant returns (uint balance);

      function transfer(address _to, uint _value) public returns (bool success);

      function transferFrom(address _from, address _to, uint _value) public returns (bool success);

      function approve(address _spender, uint _value) public returns (bool success);

      function allowance(address _owner, address _spender) public constant returns (uint remaining);

     event Transfer(address indexed _from, address indexed _to, uint256 _value);

     event Approval(address indexed _owner, address indexed _spender, uint256 _value);

 }

 

contract Brightwood is IERC20 {

    

       using SafeMath for uint256;

       

       uint public _totalSupply = 0;

       

       bool public executed = false;

       

       address public owner;

       string public symbol;

       string public name;

       uint8 public decimals;

       uint256 public RATE;

       

       mapping(address => uint256) balances;

       mapping(address => mapping(address => uint256)) allowed;

       

       function () public payable {

           createTokens();

       }

       

       constructor (string _symbol, string _name, uint8 _decimals, uint256 _RATE) public {

           owner = msg.sender;

           symbol = _symbol;

           name = _name;

           decimals = _decimals;

           RATE = _RATE;

       }

       

       function createTokens() public payable {

           require(msg.value > 0);

           uint256 tokens = msg.value.mul(RATE);

           _totalSupply = _totalSupply.add(tokens);

           balances[msg.sender] = balances[msg.sender].add(tokens);

           owner.transfer(msg.value);

		   executed = true;

       }

       

       function totalSupply() public constant returns (uint256) {

           return _totalSupply;

       }

       

       function balanceOf (address _owner) public constant returns (uint256) {

           return balances[_owner];

       }

       

       function transfer(address _to, uint256 _value) public returns (bool) {

           require(balances[msg.sender] >= _value && _value > 0);

           balances[msg.sender] = balances[msg.sender].sub(_value);

           balances[_to] = balances[_to].add(_value);

           emit Transfer(msg.sender, _to, _value);

           return true;

       }

       

       function transferFrom(address _from, address _to, uint256 _value) public returns (bool) {

           require (allowed[_from][msg.sender] >= _value && balances[_from] >= _value && _value > 0);

           balances[_from] = balances[_from].sub(_value);

           balances[_to] = balances[_to].add(_value);

           allowed[_from][msg.sender] = allowed[_from][msg.sender].sub(_value);

           emit Transfer(_from, _to, _value);

           return true;

       }

       

       function approve (address _spender, uint256 _value) public returns (bool) {

           allowed[msg.sender][_spender] = _value;

           emit Approval(msg.sender, _spender, _value);

           return true;

       }

       

       function allowance(address _owner, address _spender) public constant returns (uint256) {

           return allowed[_owner][_spender];

       }

       

       event Transfer(address indexed _from, address indexed _to, uint256 _value);

       event Approval(address indexed _owner, address indexed _spender, uint256 _value);



}