/**

 *Submitted for verification at Etherscan.io on 2018-08-25

*/



pragma solidity 0.4.24;



/**

 * @title SafeMath

 * @dev Math operations with safety checks that throw on error

 */





contract customToken{

    using SafeMath for uint256;



    /* Events */

    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approval(address indexed owner, address indexed spender, uint256 value);



    /* Storage */

    string public name;

    string public symbol;

    uint8 public decimals;



    mapping(address => uint256) balances;

    mapping (address => mapping (address => uint256)) internal allowed;



    uint256 totalSupply_;



    /* Getters */

    function totalSupply() public view returns (uint256) {

        return totalSupply_;

    }



    function balanceOf(address _owner) public view returns (uint256 balance) {

        return balances[_owner];

    }



    function allowance(address _owner, address _spender) public view returns (uint256) {

        return allowed[_owner][_spender];

    }



    /* Methods */

    function transferFrom(address _from, address _to, uint256 _value) public returns (bool) {

    require(_to != address(0));

    require(_value <= balances[_from]);

    require(_value <= allowed[_from][msg.sender]);



    balances[_from] = balances[_from].sub(_value);

    balances[_to] = balances[_to].add(_value);

    allowed[_from][msg.sender] = allowed[_from][msg.sender].sub(_value);

    emit Transfer(_from, _to, _value);

    return true;

    }



    function approve(address _spender, uint256 _value) public returns (bool) {

        allowed[msg.sender][_spender] = _value;

        emit Approval(msg.sender, _spender, _value);

        return true;

    }



    function increaseApproval(address _spender, uint _addedValue) public returns (bool) {

        allowed[msg.sender][_spender] = allowed[msg.sender][_spender].add(_addedValue);

        emit Approval(msg.sender, _spender, allowed[msg.sender][_spender]);

        return true;

    }



    function decreaseApproval(address _spender, uint _subtractedValue) public returns (bool) {

        uint oldValue = allowed[msg.sender][_spender];

        if (_subtractedValue > oldValue) {

            allowed[msg.sender][_spender] = 0;

        } else {

            allowed[msg.sender][_spender] = oldValue.sub(_subtractedValue);

        }

        emit Approval(msg.sender, _spender, allowed[msg.sender][_spender]);

        return true;

  }



    function transfer(address _to, uint256 _value) public returns (bool) {

    require(_to != address(0));

    require(_value <= balances[msg.sender]);



    // SafeMath.sub will throw if there is not enough balance.

    balances[msg.sender] = balances[msg.sender].sub(_value);

    balances[_to] = balances[_to].add(_value);

    emit Transfer(msg.sender, _to, _value);

    return true;

    }



    constructor (string _name, string _symbol, uint8 _decimals, uint _totalSupply, address _beneficiary) public {

    require(_beneficiary != address(0));

    name = _name;

    symbol = _symbol;

    decimals = _decimals;

    totalSupply_ = _totalSupply * 10 ** uint(_decimals);

    balances[_beneficiary] = totalSupply_;

  }



}