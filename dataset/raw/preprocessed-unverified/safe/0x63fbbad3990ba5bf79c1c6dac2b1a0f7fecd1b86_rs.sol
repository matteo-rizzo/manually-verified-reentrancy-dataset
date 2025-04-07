/**
 *Submitted for verification at Etherscan.io
*/

pragma solidity 0.6.0;





contract GaussCash is Ownable {
    using SafeMath for uint256;

    modifier validRecipient(address to) {
        require(to != address(0x0));
        require(to != address(this));
        _;
    }
    
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);

    string public constant name = "Gauss Cash";
    string public constant symbol = "GS";
    uint256 public constant decimals = 8;

    uint256 private constant MAX_UINT256 = ~uint256(0);
    uint256 private constant TOTAL_SUPPLY = 10**8 * 10**decimals;

    mapping(address => uint256) private _balances;
    mapping (address => mapping (address => uint256)) private _allowed;

    constructor() public override {
        _owner = msg.sender;
        _balances[_owner] = TOTAL_SUPPLY;

        emit Transfer(address(0x0), _owner, TOTAL_SUPPLY);
    }

    function balanceOf(address who)
        public
        view
        returns (uint256)
    {
        return _balances[who];
    }

    function transfer(address to, uint256 value)
        public
        validRecipient(to)
        returns (bool)
    {
        _balances[msg.sender] = _balances[msg.sender].sub(value);
        _balances[to] = _balances[to].add(value);
        emit Transfer(msg.sender, to, value);
        return true;
    }

    function allowance(address owner_, address spender)
        public
        view
        returns (uint256)
    {
        return _allowed[owner_][spender];
    }

    function transferFrom(address from, address to, uint256 value)
        public
        validRecipient(to)
        returns (bool)
    {
        _allowed[from][msg.sender] = _allowed[from][msg.sender].sub(value);
        _balances[from] = _balances[from].sub(value);
        _balances[to] = _balances[to].add(value);
        emit Transfer(from, to, value);

        return true;
    }

    function approve(address spender, uint256 value)
        public
        returns (bool)
    {
        _allowed[msg.sender][spender] = value;
        emit Approval(msg.sender, spender, value);
        return true;
    }

    function increaseAllowance(address spender, uint256 addedValue)
        public
        returns (bool)
    {
        _allowed[msg.sender][spender] =
            _allowed[msg.sender][spender].add(addedValue);
        emit Approval(msg.sender, spender, _allowed[msg.sender][spender]);
        return true;
    }

    function decreaseAllowance(address spender, uint256 subtractedValue)
        public
        returns (bool)
    {
        uint256 oldValue = _allowed[msg.sender][spender];
        
        if (subtractedValue >= oldValue) {
            _allowed[msg.sender][spender] = 0;
        } else {
            _allowed[msg.sender][spender] = oldValue.sub(subtractedValue);
        }
        
        emit Approval(msg.sender, spender, _allowed[msg.sender][spender]);
        return true;
    }
}