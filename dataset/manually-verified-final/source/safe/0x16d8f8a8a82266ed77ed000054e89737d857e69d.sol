library SafeMath {

    function mul(uint256 a, uint256 b) internal pure returns (uint256 c) {

        if (a == 0) {

            return 0;

    }

        c = a * b;

        assert(c / a == b);

        return c;

    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {

        return a / b;

    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {

        assert(b <= a);

        return a - b;

    }

    function add(uint256 a, uint256 b) internal pure returns (uint256 c) {

        c = a + b;

        assert(c >= a);

        return c;

    }

}

contract ERC20Basic {

    function totalSupply() public view returns (uint256);

    function balanceOf(address who) public view returns (uint256);

    function transfer(address to, uint256 value) public returns (bool);

    event Transfer(address indexed from, address indexed to, uint256 value);

}

contract ERC20 is ERC20Basic {

    function allowance(address owner, address spender) public view returns (uint256);

    function transferFrom(address from, address to, uint256 value) public returns (bool);

    function approve(address spender, uint256 value) public returns (bool);

    function burn(uint256 _value) public returns (bool);

    function burnFrom(address _from, uint256 _value) public returns (bool);

    event Approval(address indexed owner, address indexed spender, uint256 value);

    event Burn(address indexed from, uint256 value);

}

contract Pausable is Ownable {

    event Pause();

    event Unpause();

    bool public paused = false;

    modifier whenNotPaused() {

        require(!paused);

        _;

    }

    modifier whenPaused() {

        require(paused);

        _;

    }

    function pause() onlyOwner whenNotPaused public {

        paused = true;

        emit Pause();

    }

    function unpause() onlyOwner whenPaused public {

        paused = false;

        emit Unpause();

    }

}

contract BasicToken is ERC20Basic {

    using SafeMath for uint256;

    mapping(address => uint256) balances;

    uint256 totalSupply_;

    function totalSupply() public view returns (uint256) {

        return totalSupply_;

    }

    function transfer(address _to, uint256 _value) public returns (bool) {

        require(_to != address(0));

        require(_value <= balances[msg.sender]);

        balances[msg.sender] = balances[msg.sender].sub(_value);

        balances[_to] = balances[_to].add(_value);

        emit Transfer(msg.sender, _to, _value);

        return true;

    }

    function balanceOf(address _owner) public view returns (uint256) {

        return balances[_owner];

    }

}

contract StandardToken is ERC20, BasicToken {

    mapping (address => mapping (address => uint256)) internal allowed;

    function transferFrom(address _from, address _to, uint256 _value) public returns (bool) {

        require(_to != address(0));

        require(_value <= balances[_from]);

        require(_value <= allowed[_from][msg.sender]);

        balances[_from] = balances[_from].sub(_value);

        balances[_to] = balances[_to].add(_value);

        allowed[_from][msg.sender] = allowed[_from][msg.sender].sub(_value);

        emit Transfer(_from, _to, _value);

        return true;

    }

    function approve(address _spender, uint256 _value) public returns (bool) {

        allowed[msg.sender][_spender] = _value;

        emit Approval(msg.sender, _spender, _value);

        return true;

    }

    function allowance(address _owner, address _spender) public view returns (uint256) {

        return allowed[_owner][_spender];

    }

    function increaseApproval(address _spender, uint _addedValue) public returns (bool) {

        allowed[msg.sender][_spender] = allowed[msg.sender][_spender].add(_addedValue);

        emit Approval(msg.sender, _spender, allowed[msg.sender][_spender]);

        return true;

    }

    function decreaseApproval(address _spender, uint _subtractedValue) public returns (bool) {

        uint oldValue = allowed[msg.sender][_spender];

        if (_subtractedValue > oldValue) {

            allowed[msg.sender][_spender] = 0;

        } else {

            allowed[msg.sender][_spender] = oldValue.sub(_subtractedValue);

        }

        emit Approval(msg.sender, _spender, allowed[msg.sender][_spender]);

        return true;

    }

    function burn(uint256 _value) public returns (bool success){

        require(balances[msg.sender] >= _value, "Not enough sender balance"); 

        balances[msg.sender] -= _value; 

        totalSupply_ -= _value;

        emit Burn(msg.sender,_value);

        return true;

    }

    function burnFrom(address _from, uint256 _value) public returns (bool success) {

        require(balances[_from] >= _value, "Not enough balance"); 

        require(_value <= allowed[_from][msg.sender], "Not allowed"); 

        balances[_from] -= _value;  

        allowed[_from][msg.sender] -= _value; 

        totalSupply_ -= _value; 

        emit Burn(_from, _value);

        return true;

    }

}

contract MintableToken is StandardToken, Ownable {

    event Mint(address indexed to, uint256 amount);

    event MintFinished();

    bool public mintingFinished = false;

    modifier canMint() {

        require(!mintingFinished);

        _;

    }

    function mint(address _to, uint256 _amount) onlyOwner canMint public returns (bool) {

        totalSupply_ = totalSupply_.add(_amount);

        balances[_to] = balances[_to].add(_amount);

        emit Mint(_to, _amount);

        emit Transfer(address(0), _to, _amount);

        return true;

    }

    function finishMinting() onlyOwner canMint public returns (bool) {

        mintingFinished = true;

        emit MintFinished();

        return true;

    }

}

contract PausableToken is StandardToken, Pausable {

    function transfer(address _to, uint256 _value) public whenNotPaused returns (bool) {

        return super.transfer(_to, _value);

    }

    function transferFrom(address _from, address _to, uint256 _value) public whenNotPaused returns (bool) {

        return super.transferFrom(_from, _to, _value);

    }

    function approve(address _spender, uint256 _value) public whenNotPaused returns (bool) {

        return super.approve(_spender, _value);

    }

    function increaseApproval(address _spender, uint _addedValue) public whenNotPaused returns (bool success) {

        return super.increaseApproval(_spender, _addedValue);

    }

    function decreaseApproval(address _spender, uint _subtractedValue) public whenNotPaused returns (bool success) {

        return super.decreaseApproval(_spender, _subtractedValue);

    }

}

contract WLYToken is PausableToken, MintableToken {

    string public name = "WHALEY TOKEN";

    string public symbol = "WLY";

    uint256 public decimals = 8;

    mapping (address => bool) public frozenAccount;

    event FrozenFunds(address target, bool frozen);

    constructor() public {

        mint(0xC771c34D5CF7D88d0b4eF85c5E53751F72865396, 5000000000000000000);

    }

    function freezeAccount(address target, bool freeze) onlyOwner public{

        frozenAccount[target] = freeze;

        emit FrozenFunds(target, freeze);

    }

        function transfer(address _to, uint256 _value) public whenNotPaused returns (bool) {

        require(!frozenAccount[_to],"Account is frozen");

        return super.transfer(_to, _value);

    }

    function transferFrom(address _from, address _to, uint256 _value) public whenNotPaused returns (bool) {

        require(!frozenAccount[_from],"From account is frozen");

        require(!frozenAccount[_to],"Target account is fronzen");

        return super.transferFrom(_from, _to, _value);

    }

}
