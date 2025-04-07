/**

 *Submitted for verification at Etherscan.io on 2019-06-10

*/



/**

 *Submitted for verification at Etherscan.io on 2019-06-10

*/



pragma solidity ^0.5.0;



/**

 * Math operations with safety checks

 */





contract DroneToken {

    using SafeMath for uint256;

    string public name;

    string public symbol;

    uint8 public decimals;

    uint256 public totalSupply;

	address public owner;



    /* This creates an array with all balances */

    mapping (address => uint256) public balanceOf;

	mapping (address => uint256) public freezeOf;

    mapping (address => mapping (address => uint256)) public allowance;



    /* This generates a public event on the blockchain that will notify clients */

    event Transfer(address indexed from, address indexed to, uint256 value);



    /* This notifies clients about the amount burnt */

    event Burn(address indexed from, uint256 value);



	/* This notifies clients about the amount frozen */

    event Freeze(address indexed from, uint256 value);



	/* This notifies clients about the amount unfrozen */

    event Unfreeze(address indexed from, uint256 value);



    /* Initializes contract with initial supply tokens to the creator of the contract */

    constructor(

        uint256 initialSupply,

        string memory tokenName,

        uint8 decimalUnits,

        string memory tokenSymbol

        ) public {

        balanceOf[msg.sender] = initialSupply;              // Give the creator all initial tokens

        totalSupply = initialSupply;                        // Update total supply

        name = tokenName;                                   // Set the name for display purposes

        symbol = tokenSymbol;                               // Set the symbol for display purposes

        decimals = decimalUnits;                            // Amount of decimals for display purposes

		owner = msg.sender;

    }



    /* Send coins */

    function transfer(address _to, uint256 _value) public {

        require(_to != address(0), "Cannot use zero address");

        require(_value > 0, "Cannot use zero value");



        require (balanceOf[msg.sender] >= _value, "Balance not enough");           // Check if the sender has enough

        require (balanceOf[_to] + _value >= balanceOf[_to], "Overflow" ); // Check for overflows

        balanceOf[msg.sender] = SafeMath.safeSub(balanceOf[msg.sender], _value);                     // Subtract from the sender

        balanceOf[_to] = SafeMath.safeAdd(balanceOf[_to], _value);                            // Add the same to the recipient

        emit Transfer(msg.sender, _to, _value);                   // Notify anyone listening that this transfer took place

    }



    /* Allow another contract to spend some tokens in your behalf */

    function approve(address _spender, uint256 _value) public

        returns (bool success) {

		require (_value > 0, "Cannot use zero");

        allowance[msg.sender][_spender] = _value;

        return true;

    }





    /* A contract attempts to get the coins */

    function transferFrom(address _from, address _to, uint256 _value) public returns (bool success) {

        require(_to != address(0), "Cannot use zero address");

		require(_value > 0, "Cannot use zero value");

		require( balanceOf[_from] >= _value, "Balance not enough" );

        require( balanceOf[_to] + _value > balanceOf[_to], "Cannot overflows" );

        require( _value <= allowance[_from][msg.sender], "Cannot over allowance" );

        balanceOf[_from] = SafeMath.safeSub(balanceOf[_from], _value);                           // Subtract from the sender

        balanceOf[_to] = SafeMath.safeAdd(balanceOf[_to], _value);                             // Add the same to the recipient

        allowance[_from][msg.sender] = SafeMath.safeSub(allowance[_from][msg.sender], _value);

        emit Transfer(_from, _to, _value);

        return true;

    }



}