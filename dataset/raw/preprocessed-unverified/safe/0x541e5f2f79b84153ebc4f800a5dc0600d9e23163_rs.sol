/**
 *Submitted for verification at Etherscan.io on 2020-11-12
*/

pragma solidity ^0.4.24;

contract IToken {
    uint256 public totalSupply;

    function balanceOf(address _owner) public constant returns (uint256 balance);

    function transfer(address _to, uint256 _value) public returns (bool success);

    function transferFrom(address _from, address _to, uint256 _value) public returns
    (bool success);

    function approve(address _spender, uint256 _value) public returns (bool success);

    function allowance(address _owner, address _spender) public constant returns
    (uint256 remaining);

    event Transfer(address indexed _from, address indexed _to, uint256 _value);
    event Approval(address indexed _owner, address indexed _spender, uint256
    _value);
    event TransferFrom(address indexed _from, address indexed _to, uint256 _value);
}




contract ERC20Token is IToken {
    using SafeMath for uint256;
    string public name;
    uint8 public decimals;
    string public symbol;

    mapping(address => uint256) balances;
    mapping(address => mapping(address => uint256)) allowed;


    address private owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    function CurrentOwner() public view returns (address){
        return owner;
    }

    // 只有智能合约的所有者才能调用的方法
    modifier onlyOwner(){
        require(msg.sender == owner, "Ownable: caller is not the owner");
        _;
    }
    /**
    * @dev Transfers ownership of the contract to a new account (`newOwner`).
    * Can only be called by the current owner.
    */
    function transferOwnership(address newOwner) public onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        emit OwnershipTransferred(owner, newOwner);
        owner = newOwner;
    }

    constructor(string _tokenName, string _tokenSymbol, uint8 _decimalUnits, uint256 _initialAmount) public {
        owner = msg.sender;
        totalSupply = _initialAmount * 10 ** uint256(_decimalUnits);
        balances[msg.sender] = totalSupply;
        name = _tokenName;
        decimals = _decimalUnits;
        symbol = _tokenSymbol;
        emit Transfer( address(0),owner, totalSupply);
    }

    function transfer(address _to, uint256 _value) public returns (bool success) {
        require(balances[msg.sender] >= _value && balances[_to] + _value > balances[_to]);
        require(_to != 0x0);
        balances[msg.sender] = balances[msg.sender].sub(_value);
        balances[_to] = balances[_to].add(_value);
        emit Transfer(msg.sender, _to, _value);
        return true;
    }


    function transferFrom(address _from, address _to, uint256 _value) public returns
    (bool success) {
        require(balances[_from] >= _value && allowed[_from][msg.sender] >= _value);
        balances[_to] = balances[_to].add(_value);
        balances[_from] = balances[_from].sub(_value);
        allowed[_from][msg.sender] = allowed[_from][msg.sender].sub(_value);
        emit Transfer(_from, _to, _value);
        return true;
    }

    function balanceOf(address _owner) public constant returns (uint256 balance) {
        return balances[_owner];
    }


    function approve(address _spender, uint256 _value) public returns (bool success)
    {
        allowed[msg.sender][_spender] = _value;
        emit Approval(msg.sender, _spender, _value);
        return true;
    }

    function allowance(address _owner, address _spender) public constant returns (uint256 remaining) {
        return allowed[_owner][_spender];
    }

    function mint(uint256 value) public onlyOwner {
        totalSupply = totalSupply.add(value);
        balances[msg.sender] = balances[msg.sender].add(value);
        emit Transfer(address(0), msg.sender, value);
    }

    function transferArray(address[] memory _to, uint256[] memory _value) public {
        require(_to.length == _value.length);
        uint256 sum = 0;
        for (uint256 i = 0; i < _value.length; i++) {
            sum = sum.add(_value[i]);
        }
        require(balanceOf(msg.sender) >= sum);
        for (uint256 k = 0; k < _to.length; k++) {
            transfer(_to[k], _value[k]);
        }
    }

}