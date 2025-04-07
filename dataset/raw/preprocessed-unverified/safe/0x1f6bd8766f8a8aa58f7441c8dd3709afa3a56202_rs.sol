pragma solidity =0.6.5;







contract ZyroToken is IERC20, Ownable {
    using SafeMath for uint256;

    string  public name;
    string  public symbol;
    uint8   public decimals;
    mapping (address => uint256) private _balances;
    mapping (address => mapping (address => uint256)) private _allowed;
    uint256 private _totalSupply;

    constructor() public {
        symbol = "ZYRO";
        name = "zyro";
        decimals = 8;
        uint _totalTokenAmount = (3*10 ** 8) * (10 ** 8); // 300million
        _totalSupply = _totalTokenAmount;
        _balances[owner()] = _totalTokenAmount;
        emit Transfer(address(0x0), owner(), _totalTokenAmount);
    }

    function totalSupply() override public view returns (uint256) {
        return _totalSupply;
    }

    function balanceOf(address owner) override public view returns (uint256) {
        return _balances[owner];
    }

    function allowance(address owner, address spender) override public view returns (uint256)
    {
        return _allowed[owner][spender];
    }

    function transfer(address to, uint256 value) override public returns (bool) {
        require(value <= _balances[msg.sender]);
        require(to != address(0));

        _balances[msg.sender] = _balances[msg.sender].sub(value);
        _balances[to] = _balances[to].add(value);
        emit Transfer(msg.sender, to, value);
        return true;
    }

    function approve(address spender, uint256 value) override public returns (bool)
    {
        require(spender != address(0));

        _allowed[msg.sender][spender] = value;
        emit Approval(msg.sender, spender, value);
        return true;
    }

    function transferFrom(address from, address to, uint256 value) override public returns (bool)
    {
        require(value <= _balances[from]);
        require(value <= _allowed[from][msg.sender]);
        require(to != address(0));

        _balances[from] = _balances[from].sub(value);
        _balances[to] = _balances[to].add(value);
        _allowed[from][msg.sender] = _allowed[from][msg.sender].sub(value);
        emit Transfer(from, to, value);
        return true;
    }

}