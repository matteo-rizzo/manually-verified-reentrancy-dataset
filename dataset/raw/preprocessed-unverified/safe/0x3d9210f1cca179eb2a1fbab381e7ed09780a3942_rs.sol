pragma solidity ^0.4.13;


/// @title Math operations with safety checks


contract BasicToken {
    using SafeMath for uint;

    uint public totalTokenSupply;

    mapping(address => uint) balances;

    event Approval(address indexed owner, address indexed spender, uint value);
    event Transfer(address indexed from, address indexed to, uint value);

    /*****
        * @dev Tranfer the token balance to a specified address
        * @param _to The address to transfer to
        * @param _value The value to be transferred
        */
    function transfer(address _to, uint _value) returns (bool success) {
        require(_value > 0);

        balances[msg.sender] = balances[msg.sender].sub(_value);
        balances[_to] = balances[_to].add(_value);
        Transfer(msg.sender, _to, _value);
        return true;
    }

    /*****
        * @dev Gets the balances of the specified address
        * @param _owner The address to query the balance of
        * @return An uint representing the amount owned by the passed address
        */
    function balanceOf(address _owner) constant returns (uint balance){
        return balances[_owner];
    }

    /*****
        * @dev Gets the totalSupply of the tokens.
        */
    function totalSupply() constant returns (uint totalSupply) {
        totalSupply = totalTokenSupply;
    }
}

contract Token is BasicToken {
    using SafeMath for uint256;

    string public tokenName; // Defines the name of the token.
    string public tokenSymbol; // Defines the symbol of the token.
    uint256 public decimals; // Number of decimal places for the token.

    /*****
        * @dev Sets the variables related to the Token
        * @param _name              string      The name of the Token
        * @param _symbol            string      Defines the Token Symbol
        * @param _initialSupply     uint256     The total number of the tokens available
        * @param _decimals          uint256     Defines the number of decimals places of the token
        */
    function Token(string _name, string _symbol, uint256 _initialSupply, uint256 _decimals){
        require(_initialSupply > 0);
        tokenName = _name;
        tokenSymbol = _symbol;
        decimals = _decimals;
      
    }
    /*****
        * @dev Transfer the amount of money invested by the investor to his balance
        * Also, keeps track of at what rate did they buy the token, keeps track of
        * different rates of tokens at PreSale and ICO
        * @param _recipient     address     The address of the investor
        * @param _value         uint256     The number of the tokens bought
        * @param _ratePerETH    uint256     The rate at which it was bought, different for Pre Sale/ICO
        * @return               bool        Returns true, if all goes as expected
        */
    function transferTokens(address _recipient, uint256 _value, uint256 _ratePerETH) returns (bool) {
        uint256 finalAmount = _value.mul(_ratePerETH);
        return transfer(_recipient, finalAmount);
    }
    /*****
        * @dev Used to remove the balance, when asking for refund
        * @param _recipient address The beneficiary of the refund
        * @return           bool    Returns true, if successful
        */
    function refundedAmount(address _recipient) returns (bool) {
        require(balances[_recipient] != 0);
        balances[_recipient] = 0;
        return true;
    }
}