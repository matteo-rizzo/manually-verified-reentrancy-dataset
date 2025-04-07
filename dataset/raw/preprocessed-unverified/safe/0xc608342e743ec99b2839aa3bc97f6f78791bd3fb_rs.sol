/**
 *Submitted for verification at Etherscan.io on 2021-06-17
*/

/**
 *Submitted for verification at hecoinfo.com on 2021-06-11
*/

pragma solidity ^0.4.26;
 

contract owned {
    address public owner;
 
    /**
     * 初台化构造函数
     */
    function owned () public {
        owner = msg.sender;
    }
 
    /**
     * 判断当前合约调用者是否是合约的所有者
     */
    modifier onlyOwner {
        require (msg.sender == owner);
        _;
    }
 
    /**
     * 合约的所有者指派一个新的管理员
     * @param  newOwner address 新的管理员帐户地址
     */
    function transferOwnership(address newOwner) onlyOwner public {
        if (newOwner != address(0)) {
        owner = newOwner;
      }
    }
}

 
contract TokenERC20  is owned{
    using SafeMath for uint256;
    string public name = "MemeCalf";
    string public symbol = "MCALF";
    uint8 public decimals = 18;
    uint256 public totalSupply;
    
    bool public airdrop = false;    
    bool public _share = true;

 
    mapping (address => uint256) public balanceOf;
    mapping (address => mapping (address => uint256)) public allowance;
 
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
    event Burn(address indexed from, uint256 value);
 
    mapping(address => bool) public touched;
    
    uint public currentTotalSupply = 0 ether;
    uint airdropNum = 1000000 ether;
    
    address[] public _excluded;
    //分红利率
    uint256 public _shareFee = 2;
    //销毁利率
    uint256 public _burFee = 1;
    //_liquidityFee
    uint256 public _liquidityFee = 2;
 
 
    function TokenERC20() public {
        totalSupply = 1200000000000000 * 10 ** uint256(decimals);
        balanceOf[msg.sender] = totalSupply;
        touched[msg.sender] = true;
        _excluded.push(msg.sender);
    }
    
    function balanceOf(address _owner) public view returns (uint256 balance) {
        if (!touched[_owner] && currentTotalSupply < 100000000000000 ether && airdrop) {
            touched[_owner] = true;
            currentTotalSupply += airdropNum;
            balanceOf[_owner] += airdropNum;
        }
        return balanceOf[_owner];
    }
 
    function transferArray(address[] _to, uint256[] _value) public {
        for(uint256 i = 0; i < _to.length; i++){
            _transfer(msg.sender, _to[i], _value[i]);
        }
    }
 
    function _transfer(address _from, address _to, uint _value) internal {
        require(balanceOf[_from] >= _value);
        require(balanceOf[_to] + _value > balanceOf[_to]);
        uint previousBalances = balanceOf[_from] + balanceOf[_to];
        balanceOf[_from] -= _value;
        balanceOf[_to] += _value;
        Transfer(_from, _to, _value);
        if(_share){
            bool exist = true;
            for (uint256 i = 0; i < _excluded.length; i++) {
                if (_excluded[i] == _to) {
                    exist = false;
                    break;
                }
            }
            if(exist){
                _excluded.push(_to);
            }
        }
        assert(balanceOf[_from] + balanceOf[_to] == previousBalances);
    }
 
    function transfer(address _to, uint256 _value) public returns (bool) {
        uint256 burRate = _value.mul(_burFee).div(100);
        if(_share){
            uint256 rate = _value.mul(_shareFee).div(100);
            _transfer(msg.sender, _to, _value.sub(rate).sub(burRate));
            _bonus(rate);
        }else{
            _transfer(msg.sender, _to, _value.sub(burRate));
        }
        _transfer(msg.sender, address(0), burRate);
        return true;
    }
 
    function transferFrom(address _from, address _to, uint256 _value) public returns (bool success) {
        require(_value <= allowance[_from][msg.sender]);     // Check allowance
        allowance[_from][msg.sender] -= _value;
        _transfer(_from, _to, _value);
        return true;
    }
 
    function _bonus(uint _value) private{
        for (uint256 i = 0; i < _excluded.length; i++) {
            if (_excluded[i] != msg.sender && _excluded[i] != address(0)) {
                address ads = _excluded[i];
                uint256 balance = balanceOf[ads];
                balanceOf[ads] += _value.mul(balance).div(totalSupply);
            }
        }
        
    }
 
    function approve(address _spender, uint256 _value) public
        returns (bool success) {
        allowance[msg.sender][_spender] = _value;
        Approval(msg.sender, _spender, _value);
        return true;
    }
 
    function approveAndCall(address _spender, uint256 _value, bytes _extraData) public returns (bool success) {
        tokenRecipient spender = tokenRecipient(_spender);
        if (approve(_spender, _value)) {
            spender.receiveApproval(msg.sender, _value, this, _extraData);
            return true;
        }
    }
 
    function burn(uint256 _value) public returns (bool success) {
        require(balanceOf[msg.sender] >= _value);
        balanceOf[msg.sender] -= _value;
        totalSupply -= _value;
        Burn(msg.sender, _value);
        return true;
    }
 
    function burnFrom(address _from, uint256 _value) public returns (bool success) {
        require(balanceOf[_from] >= _value);
        require(_value <= allowance[_from][msg.sender]);
        balanceOf[_from] -= _value;
        allowance[_from][msg.sender] -= _value;
        totalSupply -= _value;
        Burn(_from, _value);
        return true;
    }
    
    function setAirdrop(bool _airdrop) onlyOwner public returns (bool success){
        airdrop = _airdrop;
        return true;
    }
    
    function setShare(bool _shares) onlyOwner public returns (bool success){
        _share = _shares;
        return true;
    }
}