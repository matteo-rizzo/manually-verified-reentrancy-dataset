pragma solidity ^0.4.24;

/**
* @title Ownable
* @dev The Ownable contract has an owner address, and provides basic authorization control
* functions, this simplifies the implementation of "user permissions".
*/


/**
 * @title SafeMath
 * @dev Math operations with safety checks that throw on error
 */




contract Gamblr is Ownable {
    using SafeMath for uint256;

    string public name = "Gamblr";
    uint8 public decimals = 3;
    string public symbol = "GMBL";
    uint public totalSupply = 10000000000;

    mapping (address => uint256) public balances;
    mapping (address => mapping (address => uint256)) public allowed;

    function Gamblr() public {
        balances[msg.sender] = 3000000000;
        balances[this] = 7000000000;
    }

    function transfer(address _to, uint256 _amount) public returns (bool success) {
        doTransfer(msg.sender, _to, _amount);
        return true;
    }

    function transferFrom(address _from, address _to, uint256 _amount) public returns (bool success) {
        require(allowed[_from][msg.sender] >= _amount);
        allowed[_from][msg.sender] -= _amount;
        doTransfer(_from, _to, _amount);
        return true;
    }

    function doTransfer(address _from, address _to, uint _amount) internal {
        require((_to != 0) && (_to != address(this)));
        require(_amount <= balances[_from]);
        balances[_from] = balances[_from].sub(_amount);
        balances[_to] = balances[_to].add(_amount);
        emit Transfer(_from, _to, _amount);
    }

    function balanceOf(address _owner) public constant returns (uint256 balance) {
        return balances[_owner];
    }

    function approve(address _spender, uint256 _amount) public returns (bool success) {
        require((_amount == 0) || (allowed[msg.sender][_spender] == 0));

        allowed[msg.sender][_spender] = _amount;
        emit Approval(msg.sender, _spender, _amount);
        return true;
    }

    function approveAndCall(address _spender, uint256 _value, bytes _extraData) public returns (bool success) {
        tokenRecipient spender = tokenRecipient(_spender);
        if (approve(_spender, _value)) {
            spender.receiveApproval(msg.sender, _value, this, _extraData);
            return true;
        }
    }

    function burn(uint256 _value) public onlyOwner {
        require(balances[msg.sender] >= _value);
        balances[msg.sender] = balances[msg.sender].sub(_value);
        totalSupply = totalSupply.sub(_value);
    }

    function allowance(address _owner, address _spender) public constant returns (uint256 remaining) {
        return allowed[_owner][_spender];
    }

    function totalSupply() public constant returns (uint) {
        return totalSupply;
    }
    
    event Transfer(
        address indexed _from,
        address indexed _to,
        uint256 _amount
        );

    event Approval(
        address indexed _owner,
        address indexed _spender,
        uint256 _amount
        );

    event Burn(
        address indexed _burner,
        uint256 _amount
        );
        
    mapping(address => bool) public joined;
        
    function receiveTokens() public returns(bool){
        require(balanceOf(this) > 0);
        require(!joined[msg.sender]);
        if (balanceOf(this) > 1000000) {
            doTransfer(this, msg.sender, 1000000);
            joined[msg.sender] = true;
            return joined[msg.sender];
        }
        doTransfer(this, msg.sender, balanceOf(this));
        joined[msg.sender] = true;
        return joined[msg.sender];
    }    
        
}