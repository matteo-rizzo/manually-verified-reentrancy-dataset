/**
 *Submitted for verification at Etherscan.io on 2019-06-29
*/

pragma solidity ^0.5.0;

// ----------------------------------------------------------------------------
// Symbol      : BHT
// Name        : Bithance Token
// Total supply: 200,000,000
// Decimals    : 18
// ----------------------------------------------------------------------------


// ----------------------------------------------------------------------------
// Safe maths
// ----------------------------------------------------------------------------


// ----------------------------------------------------------------------------
// Owned contract
// ----------------------------------------------------------------------------



// ----------------------------------------------------------------------------
// ERC20 Token, with the addition of symbol, name and decimals and a
// fixed supply
// ----------------------------------------------------------------------------
contract bithanceToken is Owned {
    using SafeMath for uint;

    string  public name;
    string  public symbol;
    uint256 public decimals;
    uint256 public totalSupply;

    event Transfer(
        address indexed from,
        address indexed to,
        uint256 value
    );

    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 value
    );

    event Burn(
        address indexed from,
        uint256 value
    );

    mapping(address => uint256) public balanceOf;
    mapping(address => mapping(address => uint256)) public allowance;

    constructor() public {
        symbol = "BHT";
        name = "Bithance Token";
        decimals = 18;
        totalSupply = 200000000 * 10**uint(decimals);
        balanceOf[owner] = totalSupply;
        emit Transfer(address(0), owner, totalSupply);
    }

    function transfer(address _to, uint256 _value) public returns (bool success) {
        require(_value > 0);
        require(balanceOf[msg.sender] >= _value);

        balanceOf[msg.sender] = balanceOf[msg.sender].sub(_value);
        balanceOf[_to] = balanceOf[_to].add(_value);

        emit Transfer(msg.sender, _to, _value);

        return true;
    }

    function approve(address _spender, uint256 _value) public returns (bool success) {
        require(_value > 0);
        allowance[msg.sender][_spender] = _value;
        emit Approval(msg.sender, _spender, _value);
        return true;
    }

    function transferFrom(address _from, address _to, uint256 _value) public returns (bool success) {
        require(_value > 0);
        require(_value <= balanceOf[_from]);
        require(_value <= allowance[_from][msg.sender]);
        
        balanceOf[_from] = balanceOf[_from].sub(_value);
        balanceOf[_to] = balanceOf[_to].add(_value);

        allowance[_from][msg.sender] = allowance[_from][msg.sender].sub(_value);

        emit Transfer(_from, _to, _value);

        return true;
    }

    function burn(uint256 _value) public returns (bool success) {
        require(_value > 0);
        require(balanceOf[msg.sender] >= _value);
        
        balanceOf[msg.sender] = balanceOf[msg.sender].sub(_value);
        totalSupply = totalSupply.sub(_value);

        emit Burn(msg.sender, _value);

        return true;
    }
    
    
    // ------------------------------------------------------------------------
    // Don't accept ETH
    // ------------------------------------------------------------------------
    function () external payable {
        revert();
    }
}