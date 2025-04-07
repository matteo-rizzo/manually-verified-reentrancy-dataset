/**

 *Submitted for verification at Etherscan.io on 2019-02-22

*/



pragma solidity ^0.5.2;







contract eUULATokenCoin is Ownable {

    using SafeMath for uint256; // use SafeMath for uint256 variables



    string public constant name = "EUULA";

    string public constant symbol = "EUULA";

    uint32 public constant decimals = 2;

    uint public constant INITIAL_SUPPLY = 75000000000;

    uint public totalSupply = 0;

    mapping(address => uint256) balances;

    mapping(address => mapping(address => uint256)) allowed;



    constructor () public {

        totalSupply = INITIAL_SUPPLY;

        balances[msg.sender] = INITIAL_SUPPLY;

    }



    function balanceOf(address _owner) public view returns (uint256 balance) {

        return balances[_owner];

    }



    function transfer(address _to, uint256 _value) public returns (bool success) {

        if (balances[msg.sender] < _value || balances[msg.sender].add(_value) < balances[msg.sender]) {

            return false;

        }



        balances[msg.sender] = balances[msg.sender].sub(_value);

        balances[_to] = balances[_to].add(_value);

        emit Transfer(msg.sender, _to, _value);



        return true;

    }



    function transferFrom(address _from, address _to, uint256 _value) public returns (bool success) {

        if (allowed[_from][msg.sender] < _value || balances[_from] < _value && balances[_to].add(_value) >= balances[_to]) {

            return false;

        }



        allowed[_from][msg.sender] = allowed[_from][msg.sender].sub(_value);

        balances[_from] = balances[_from].sub(_value);

        balances[_to] = balances[_to].add(_value);

        emit Transfer(_from, _to, _value);



        return true;

    }



    function approve(address _spender, uint256 _value) public returns (bool success) {

        allowed[msg.sender][_spender] = _value;

        emit Approval(msg.sender, _spender, _value);



        return true;

    }



    function allowance(address _owner, address _spender) public view returns (uint remaining) {

        return allowed[_owner][_spender];

    }



    function transferWise(address[] memory recipients, uint256[] memory values) public {

        require(recipients.length == values.length);



        uint256 sum = 0;

        uint256 i = 0;



        for (i = 0; i < recipients.length; i++) {

            sum = sum.add(values[i]);

        }

        require(sum <= balances[msg.sender]);



        for (i = 0; i < recipients.length; i++) {

            transfer(recipients[i], values[i]);

        }

    }



    event Transfer(address indexed _from, address indexed _to, uint _value);

    event Approval(address indexed _owner, address indexed _spender, uint _value);

}



/**

 * @title SafeMath

 * @dev Unsigned math operations with safety checks that revert on error

 */

