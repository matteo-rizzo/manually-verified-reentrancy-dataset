/**

 *Submitted for verification at Etherscan.io on 2019-01-24

*/



pragma solidity ^0.5.0;



// ----------------------------------------------------------------------------

// Symbol      : OWT

// Name        : OpenWeb Token

// Total supply: 1,000,000,000

// Decimals    : 18

// ----------------------------------------------------------------------------





// ----------------------------------------------------------------------------

// Safe maths

// ----------------------------------------------------------------------------





contract owContract {

    function notifyBalance(address sender, uint tokens) public;

}

// ----------------------------------------------------------------------------

// Owned contract

// ----------------------------------------------------------------------------







// ----------------------------------------------------------------------------

// ERC20 Token, with the addition of symbol, name and decimals and a

// fixed supply

// ----------------------------------------------------------------------------

contract owToken is Owned {

    using SafeMath for uint;



    string  public name;

    string  public symbol;

    uint256 public decimals;

    uint256 public totalSupply;



    event Transfer(

        address indexed _from,

        address indexed _to,

        uint256 _value

    );



    event Approval(

        address indexed _owner,

        address indexed _spender,

        uint256 _value

    );



    mapping(address => uint256) public balanceOf;

    mapping(address => mapping(address => uint256)) public allowance;



    constructor() public {

        symbol = "OWT";

        name = "OpenWeb Token";

        decimals = 18;

        totalSupply = 1000000000 * 10**uint(decimals);

        balanceOf[owner] = totalSupply;

        emit Transfer(address(0), owner, totalSupply);

    }



    function transfer(address _to, uint256 _value) public returns (bool success) {

        require(balanceOf[msg.sender] >= _value);



        balanceOf[msg.sender] = balanceOf[msg.sender].sub(_value);

        balanceOf[_to] = balanceOf[_to].add(_value);

        

        if(notifyAddress[_to]){

            owContract(_to).notifyBalance(msg.sender, _value);

        }



        emit Transfer(msg.sender, _to, _value);



        return true;

    }



    function approve(address _spender, uint256 _value) public returns (bool success) {

        allowance[msg.sender][_spender] = _value;

        emit Approval(msg.sender, _spender, _value);

        return true;

    }



    function transferFrom(address _from, address _to, uint256 _value) public returns (bool success) {

        require(_value <= balanceOf[_from]);

        require(_value <= allowance[_from][msg.sender]);

        

        balanceOf[_from] = balanceOf[_from].sub(_value);

        balanceOf[_to] = balanceOf[_to].add(_value);



        allowance[_from][msg.sender] = allowance[_from][msg.sender].sub(_value);



        emit Transfer(_from, _to, _value);



        return true;

    }

    

    

    // ------------------------------------------------------------------------

    // Don't accept ETH

    // ------------------------------------------------------------------------

    function () external payable {

        revert();

    }

}