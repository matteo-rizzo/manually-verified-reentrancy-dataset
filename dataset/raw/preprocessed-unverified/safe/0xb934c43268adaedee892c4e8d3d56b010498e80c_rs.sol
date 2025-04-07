/**
 *Submitted for verification at Etherscan.io on 2021-03-24
*/

pragma solidity ^0.5.0;



contract clashPay {
    using SafeMath for uint256;
    string  public name = "Clash Pay";
    string  public symbol = "SCP";
    uint8   public decimals = 18;
    uint256 public totalSupply = 10*(10**18);
    uint256 public MaxSupply = 10*(10**(29));
    address public owner;
    address public Tokenfarm;

    event Transfer(
        address indexed _from,
        address indexed _to,
        uint256 _value
    );

    event Burn(
        address indexed burner,
        uint256 value
    );

    event Approval(
        address indexed _owner,
        address indexed _spender,
        uint256 _value
    );

    mapping(address => uint256) public balanceOf;
    mapping(address => mapping(address => uint256)) public allowance;

    constructor() public {
        balanceOf[msg.sender] = totalSupply;
        owner= msg.sender;
    }
    function setContract(address _contract) external{
        require(msg.sender==owner,"must be owner");
        Tokenfarm=_contract;
    }

    function transfer(address _to, uint256 _value) external returns (bool success) {
        require(address(0)!= _to,"to burn tokens use the burn function");
        balanceOf[msg.sender] =balanceOf[msg.sender].sub( _value);
        balanceOf[_to] = balanceOf[_to].add( _value);
        emit Transfer(msg.sender, _to, _value);
        return true;
    }

    function approve(address _spender, uint256 _value) external returns (bool success) {
        allowance[msg.sender][_spender] = _value;
        emit Approval(msg.sender, _spender, _value);
        return true;
    }

    function transferFrom(address _from, address _to, uint256 _value) external returns (bool success) {
        require(address(0)!= _to,"to burn tokens use the burn function");
        balanceOf[_from] = balanceOf[_from].sub( _value);
        balanceOf[_to] = balanceOf[_to].add( _value);
        allowance[_from][msg.sender] =allowance[_from][msg.sender].sub(_value);
        emit Transfer(_from, _to, _value);
        return true;
    }
    function mint(address _to,uint256 _value) public {
        require(msg.sender==Tokenfarm,"only Tokenfarm contract can mint tokens");
        if(totalSupply.add(_value)>=MaxSupply){
            _value = MaxSupply.sub(totalSupply);
        }
        totalSupply= totalSupply.add( _value);
        balanceOf[_to]=balanceOf[_to].add(_value);
        emit Transfer(address(0),_to,_value);
    }
    function burn(uint256 _value) public{
        balanceOf[msg.sender] =balanceOf[msg.sender].sub( _value);
        totalSupply = totalSupply.sub(_value);
        emit Burn(msg.sender,_value);
        emit Transfer(msg.sender,address(0),_value);
    }
    function transferOwnership(address _newOwner) external{
        require(msg.sender==owner,"only the owner an call this function");
        owner=_newOwner;

    }

}