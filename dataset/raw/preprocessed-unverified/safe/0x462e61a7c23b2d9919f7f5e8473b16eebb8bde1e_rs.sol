pragma solidity ^0.6.6;





abstract contract Context
{
    function _msgSender() internal view virtual returns (address payable)
    { return msg.sender; }

    function _msgData() internal view virtual returns (bytes memory)
    {
        this;
        return msg.data;
    }
}



contract ERC20 is Context, IERC20
{
    using SafeMath for uint256;
    using Address for address;

    mapping (address => uint256) private _balances;
    mapping (address => mapping (address => uint256)) private _allowances;

    string private _name;
    string private _symbol;
    uint8 private _decimals;
    uint256 private _totalSupply;

    constructor () public
    {
        _name = "Spider.Exchange";
        _symbol = "SPDR";
        _decimals = 18;
        _totalSupply = 50000000000000000000000; // 
        _balances[msg.sender] = _totalSupply;
        emit Transfer(address(0), msg.sender, _totalSupply);
    }
    
    function name() public view returns (string memory)
    { return _name; }

    function symbol() public view returns (string memory)
    { return _symbol; }

    function decimals() public view returns (uint8)
    { return _decimals; }

    function totalSupply() public view override returns (uint256)
    { return _totalSupply; }

    function balanceOf(address account) public view override returns (uint256)
    { return _balances[account]; }

    function allowance(address owner, address spender) public view virtual override returns (uint256)
    {  return _allowances[owner][spender]; }

    function transfer(address recipient, uint256 amount) public virtual override returns (bool)
    {
        _transfer(_msgSender(), recipient, amount);
        return true;
    }

    function transferFrom(address sender, address recipient, uint256 amount) public virtual override returns (bool)
    {
        _transfer(sender, recipient, amount);
        _approve(sender, _msgSender(), _allowances[sender][_msgSender()].sub(amount, "Transfer amount exceeds allowance"));
        return true;
    }

    function approve(address spender, uint256 amount) public virtual override returns (bool)
    {
        _approve(_msgSender(), spender, amount);
        return true;
    }

    function increaseAllowance(address spender, uint256 addedValue) public virtual returns (bool)
    {
        _approve(_msgSender(), spender, _allowances[_msgSender()][spender].add(addedValue));
        return true;
    }

    function decreaseAllowance(address spender, uint256 subtractedValue) public virtual returns (bool)
    {
        _approve(_msgSender(), spender, _allowances[_msgSender()][spender].sub(subtractedValue, "Decreased allowance below zero"));
        return true;
    }

    function _transfer(address sender, address recipient, uint256 amount) internal virtual
    {
        require(sender != address(0), "Transfer from the zero address");
        require(recipient != address(0), "Transfer to the zero address");

        _balances[sender] = _balances[sender].sub(amount, "Transfer amount exceeds balance");
        _balances[recipient] = _balances[recipient].add(amount);
        emit Transfer(sender, recipient, amount);
    }

    function _approve(address owner, address spender, uint256 amount) internal virtual
    {
        require(owner != address(0), "Approve from the zero address");
        require(spender != address(0), "Approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }
}