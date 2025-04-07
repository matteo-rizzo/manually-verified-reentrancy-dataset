/**
 *Submitted for verification at Etherscan.io on 2019-10-28
*/

pragma solidity ^0.5.0;



contract IERC20 {
    function balanceOf(address who) public view returns (uint);
    function decimals() public view returns (uint);
    function transfer(address to, uint value) public returns (bool);
    function transferFrom( address from, address to, uint value) public returns (bool);
    function approve(address spender, uint value) public returns (bool);
}



contract GIAToken is Ownable {
    using SafeMath for uint256;

    string public constant name = "Global Insurance Alliance";
    string public constant symbol = "GIA";
    uint256 public constant decimals = 18;
    uint256 public totalSupply = 2000000000 * 1e18;  // 2 Billion
    uint256 public transferableStartTime = now + 150 days;

    mapping (address => uint256) public balances;
    mapping (address => mapping (address => uint256)) public allowed;
    mapping (address => bool) whitelist;    

    event Transfer(address indexed _from, address indexed _to, uint256 _value);
    event Approval(address indexed _owner, address indexed _spender, uint256 _value);
    event Burn(address indexed _burner, uint256 _value);

    modifier onlyWhenTransferEnabled() {
        require(now >= transferableStartTime || inWhitelist(msg.sender));
        _;
    }

    function inWhitelist(address _account) public view returns (bool) {
        return whitelist[_account];
    }

    function addToWhitelist(address _account) public onlyOwner {
        whitelist[_account] = true;
    }

    function removeFromWhitelist(address _account) public onlyOwner {
        delete whitelist[_account];
    }

    constructor () public {
        balances[msg.sender] = totalSupply;
        whitelist[msg.sender] = true;
        emit Transfer(address(0), msg.sender, totalSupply);
    }

    function transfer(address _to, uint256 _value) public onlyWhenTransferEnabled returns (bool success) {
        require(balances[msg.sender] >= _value);
        balances[msg.sender] = balances[msg.sender].sub(_value);
        balances[_to] = balances[_to].add(_value);
        emit Transfer(msg.sender, _to, _value);
        return true;
    }

    function transferFrom(address _from, address _to, uint256 _value) public onlyWhenTransferEnabled returns (bool success) {
        uint256 allowance = allowed[_from][msg.sender];
        require(balances[_from] >= _value && allowance >= _value);
        balances[_to] = balances[_to].add(_value);
        balances[_from] = balances[_from].sub(_value);
        if (allowance != uint256(-1)) {
            allowed[_from][msg.sender] = allowed[_from][msg.sender].sub(_value);
        }
        emit Transfer(_from, _to, _value);
        return true;
    }

    function balanceOf(address _owner) public view returns (uint256 balance) {
        return balances[_owner];
    }

    function approve(address _spender, uint256 _value) public returns (bool success) {
        allowed[msg.sender][_spender] = _value;
        emit Approval(msg.sender, _spender, _value);
        return true;
    }

    function allowance(address _owner, address _spender) public view returns (uint256 remaining) {
        return allowed[_owner][_spender];
    }
    
    function burn(uint256 _value) public onlyWhenTransferEnabled returns (bool) {
        balances[msg.sender] = balances[msg.sender].sub(_value);
        totalSupply = totalSupply.sub(_value);
        emit Burn(msg.sender, _value);
        emit Transfer(msg.sender, address(0), _value);
        return true;
    }
    
    // Owner can extract tokens sent to this contract, thank you ;)
    function saveTokens(address _token, address payable _to) external onlyOwner {
        if (_token == address(0)) {
            _to.transfer(address(this).balance);
            return;
        }

        IERC20 token = IERC20(_token);
        uint balance = token.balanceOf(address(this));
        token.transfer(_to, balance);
    }
}