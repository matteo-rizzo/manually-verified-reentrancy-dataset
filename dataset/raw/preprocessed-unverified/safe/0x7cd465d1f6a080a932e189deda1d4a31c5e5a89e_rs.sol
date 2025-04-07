/**

 *Submitted for verification at Etherscan.io on 2018-10-15

*/



pragma solidity ^0.4.25;



/**

 * @title SafeMath

 * @dev Math operations with safety checks that revert on error

 */









contract UBToken is IERC20{

    

    using SafeMath for uint256;

    

    uint public constant _totalSupply = 0;

    

    string public constant symbol = "UB";

    string public constant name = "UNIFIED BET";

    uint8 public constant decimals = 18;

    

    //1 ether = 1 UB

    uint256 public constant RATE = 1;

    

    address public owner;

    

    mapping (address => uint256) balances;

    mapping (address => mapping(address => uint256)) allowed;

    

    function () payable{

        createToken();

    }

    

    constructor (){

        owner = msg.sender;

        

    }

    

    function createToken() payable {

        require(msg.value > 0);

        

        uint256 tokens = msg.value;

        balances[msg.sender] = balances[msg.sender].add(tokens);

        

        owner.transfer(msg.value);

    }

    

    function totalSupply() constant returns (uint256 totalSupply){

        return _totalSupply;

    }

    

    function balanceOf(address _owner) constant returns (uint256 balance){

        return balances[_owner];

    }

    

    function transfer(address _to, uint256 _value) returns (bool success){

        require (

            balances[msg.sender] >= _value

            && _value > 0

            );

            balances[msg.sender] = balances[msg.sender].sub(_value);

            balances[_to] = balances[_to].add(_value);

            Transfer(msg.sender, _to, _value);

            return true;

            

    }

    

    function transferFrom(address _from, address _to, uint256 _value) returns (bool success){

        require(

            allowed[_from][msg.sender] >= _value

            && balances[_from] >= _value

            && _value > 0

            );

            

            balances[_from] = balances[_from].sub(_value);

            balances[_to] = balances[_to].add(_value);

            allowed[_from][msg.sender] = allowed[_from][msg.sender].add(_value);

            Transfer(_from, _to, _value);

            return true;

    }

    

    function approve(address _spender, uint256 _value) returns (bool success){

        allowed[msg.sender][_spender] = _value;

        Approval(msg.sender, _spender, _value);

        return true;

    }

    

    function allowance(address _owner, address _spender) constant returns (uint256 remaining) {

        return allowed[_owner][_spender];

    }

    

}