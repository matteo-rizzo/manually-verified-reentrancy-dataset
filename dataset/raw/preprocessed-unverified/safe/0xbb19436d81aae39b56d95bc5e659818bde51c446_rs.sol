pragma solidity ^0.6.12;









contract ERC20 is IERC20 {
    using SafeMath for uint256;
    using Address for address;

    mapping (address => uint256) private _balances;

    mapping (address => mapping (address => uint256)) private _allowances;

    uint256 internal _totalSupply;

    string private _name;
    string private _symbol;
    uint8 private _decimals;
    
    address internal _governor;
    mapping (address => bool) internal _minters;

    modifier onlyGovernor() {
        require(msg.sender==_governor);
        _;
    }
  
    modifier onlyMinter() {
        require(_minters[msg.sender]==true);
        _;
    }
    
    constructor (string memory name, string memory symbol, uint8 decimals) public {
        _name = name;
        _symbol = symbol;
        _decimals = decimals;
    }

    function name() public view returns (string memory) {
        return _name;
    }

    function symbol() public view returns (string memory) {
        return _symbol;
    }

    function decimals() public view returns (uint8) {
        return _decimals;
    }

    function totalSupply() public view override returns (uint256) {
        return _totalSupply;
    }

    function balanceOf(address account) public view override returns (uint256) {
        return _balances[account];
    }
    
    function setGovernance(address governor) public onlyGovernor {
        _governor = governor;
    }
  
    function addMinter(address minter) public onlyGovernor {
        _minters[minter] = true;
    }
  
    function removeMinter(address minter) public onlyGovernor {
        _minters[minter] = false;
    }
    
    function mint(address account, uint amount) public onlyMinter {
        _mint(account, amount, amount);
    }
    
    function burn(address account, uint amount) public onlyMinter {
        _burn(account, amount);
    }

    function transfer(address recipient, uint256 amount) public virtual override returns (bool) {
        require(recipient != address(0), "ERC20: transfer to the zero address");
        require(amount > 0, "amount should be greater than 0");
        
        uint256 amountToBurn = _calculateTransferBurn(amount);
        uint256 amountToTransfer = amount.sub(amountToBurn);

        _balances[msg.sender] = _balances[msg.sender].sub(amount, "ERC20: transfer amount exceeds balance");
        _balances[recipient] = _balances[recipient].add(amountToTransfer);
        _totalSupply = _totalSupply.sub(amountToBurn);
        
        emit Transfer(msg.sender, recipient, amountToTransfer);
        emit Transfer(msg.sender, address(0), amountToBurn);

        return true;
    }

    function allowance(address owner, address spender) public view virtual override returns (uint256) {
        return _allowances[owner][spender];
    }

    function approve(address spender, uint256 amount) public virtual override returns (bool) {
        _approve(msg.sender, spender, amount);
        return true;
    }

    function _calculateTransferBurn(uint256 amount) pure internal returns (uint)  {
        uint256 roundValue = amount.ceil(100);
        uint256 onePercent = roundValue.mul(100).div(10000);
        return onePercent;
    }
  
    function transferFrom(address sender, address recipient, uint256 amount) public virtual override returns (bool) {
        require(sender != address(0), "ERC20: transfer from the zero address");
        require(recipient != address(0), "ERC20: transfer to the zero address");
        require(amount > 0, "amount should be greater than 0");
        
        uint256 amountToBurn = _calculateTransferBurn(amount);
        uint256 amountToTransfer = amount.sub(amountToBurn);

        _balances[sender] = _balances[sender].sub(amount, "ERC20: transfer amount exceeds balance");
        _balances[recipient] = _balances[recipient].add(amountToTransfer);
        _totalSupply = _totalSupply.sub(amountToBurn);
        _approve(sender, msg.sender, _allowances[sender][msg.sender].sub(amount, "ERC20: transfer amount exceeds allowance"));
        
        emit Transfer(sender, recipient, amountToTransfer);
        emit Transfer(sender, address(0), amountToBurn);

        return true;
    }

    function _mint(address account, uint256 amount, uint256 supply) internal virtual {
        require(account != address(0), "ERC20: mint to the zero address");
        require(amount > 0, "amount should be greater than 0");

        _totalSupply = _totalSupply.add(supply);
        _balances[account] = _balances[account].add(amount);
        emit Transfer(address(0), account, amount);
    }

    function _burn(address account, uint256 amount) internal virtual {
        require(account != address(0), "ERC20: burn from the zero address");
        require(amount > 0, "amount should be greater than 0");

        _balances[account] = _balances[account].sub(amount, "ERC20: burn amount exceeds balance");
        _totalSupply = _totalSupply.sub(amount);
        emit Transfer(account, address(0), amount);
    }

    function _approve(address owner, address spender, uint256 amount) internal virtual {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }
}

contract FLR is ERC20 {
    using SafeERC20 for IERC20;
    using Address for address;
    using SafeMath for uint;

    constructor () public ERC20("Flare Finance", "FLR", 18) {
        _governor = msg.sender;
        _minters[msg.sender] = true;
        _totalSupply = 100000 * 1000000000000000000; //100k
        _mint(msg.sender, _totalSupply, 0);
    }
}