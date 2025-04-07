/**
 *Submitted for verification at Etherscan.io on 2019-09-04
*/

pragma solidity ^0.5.0;




contract Administratable is Ownable {
    mapping (address => bool) public _admins;

    
    modifier onlyOwnerOrAdmin() {
        require(msg.sender == owner() || _admins[msg.sender], "Sender is neither owner, nor an admin.");
        _;
    }

    
    function setAdmin(address _admin, bool _isAdmin) public onlyOwner {
        _admins[_admin] = _isAdmin;
    }

    
    function isAdmin() public view returns (bool) {
        return _admins[msg.sender];
    }
}





contract ERC20 is IERC20 {
    using SafeMath for uint256;

    mapping (address => uint256) private _balances;

    mapping (address => mapping (address => uint256)) private _allowances;

    uint256 private _totalSupply;

    
    function totalSupply() public view returns (uint256) {
        return _totalSupply;
    }

    
    function balanceOf(address account) public view returns (uint256) {
        return _balances[account];
    }

    
    function transfer(address recipient, uint256 amount) public returns (bool) {
        _transfer(msg.sender, recipient, amount);
        return true;
    }

    
    function allowance(address owner, address spender) public view returns (uint256) {
        return _allowances[owner][spender];
    }

    
    function approve(address spender, uint256 value) public returns (bool) {
        _approve(msg.sender, spender, value);
        return true;
    }

    
    function transferFrom(address sender, address recipient, uint256 amount) public returns (bool) {
        _transfer(sender, recipient, amount);
        _approve(sender, msg.sender, _allowances[sender][msg.sender].sub(amount, "ERC20: transfer amount exceeds allowance"));
        return true;
    }

    
    function increaseAllowance(address spender, uint256 addedValue) public returns (bool) {
        _approve(msg.sender, spender, _allowances[msg.sender][spender].add(addedValue));
        return true;
    }

    
    function decreaseAllowance(address spender, uint256 subtractedValue) public returns (bool) {
        _approve(msg.sender, spender, _allowances[msg.sender][spender].sub(subtractedValue, "ERC20: decreased allowance below zero"));
        return true;
    }

    
    function _transfer(address sender, address recipient, uint256 amount) internal {
        require(sender != address(0), "ERC20: transfer from the zero address");
        require(recipient != address(0), "ERC20: transfer to the zero address");

        _balances[sender] = _balances[sender].sub(amount, "ERC20: transfer amount exceeds balance");
        _balances[recipient] = _balances[recipient].add(amount);
        emit Transfer(sender, recipient, amount);
    }

    
    function _mint(address account, uint256 amount) internal {
        require(account != address(0), "ERC20: mint to the zero address");

        _totalSupply = _totalSupply.add(amount);
        _balances[account] = _balances[account].add(amount);
        emit Transfer(address(0), account, amount);
    }

     
    function _burn(address account, uint256 value) internal {
        require(account != address(0), "ERC20: burn from the zero address");

        _balances[account] = _balances[account].sub(value, "ERC20: burn amount exceeds balance");
        _totalSupply = _totalSupply.sub(value);
        emit Transfer(account, address(0), value);
    }

    
    function _approve(address owner, address spender, uint256 value) internal {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        _allowances[owner][spender] = value;
        emit Approval(owner, spender, value);
    }

    
    function _burnFrom(address account, uint256 amount) internal {
        _burn(account, amount);
        _approve(account, msg.sender, _allowances[account][msg.sender].sub(amount, "ERC20: burn amount exceeds allowance"));
    }
}

contract ERC20Detailed is IERC20 {
    string private _name;
    string private _symbol;
    uint8 private _decimals;

    
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
}

contract EBKToken is ERC20, ERC20Detailed, Ownable {
    uint256 public _freezeTimestamp = 1577836800; 
    bool public _freezeTokenTransfers = false;

    
    constructor (uint256 _totalSupply) public ERC20Detailed("Ebakus", "EBK", 18) {
        uint256 totalSupply = _totalSupply * (10 ** uint256(decimals()));
        _mint(msg.sender, totalSupply);
    }

    
    modifier whenNotFreezed() {
        require(!_freezeTokenTransfers, "Token transfers has been freezed");
        _;
    }

    
    function freeze() public onlyOwner {
        require(now >= _freezeTimestamp);
        _freezeTokenTransfers = true;
    }

    function transfer(address to, uint256 value) public whenNotFreezed returns (bool) {
        return super.transfer(to, value);
    }

    function transferFrom(address from, address to, uint256 value) public whenNotFreezed returns (bool) {
        return super.transferFrom(from, to, value);
    }

    function approve(address spender, uint256 value) public whenNotFreezed returns (bool) {
        return super.approve(spender, value);
    }

    function increaseAllowance(address spender, uint256 addedValue) public whenNotFreezed returns (bool) {
        return super.increaseAllowance(spender, addedValue);
    }

    function decreaseAllowance(address spender, uint256 subtractedValue) public whenNotFreezed returns (bool) {
        return super.decreaseAllowance(spender, subtractedValue);
    }
}

contract EbakusDistribution is Administratable {
    EBKToken public EBK;

    
    constructor() public {
        
        uint256 totalSupply = 100000000;
        EBK = new EBKToken(totalSupply);
    }

    
    function freeze() public onlyOwnerOrAdmin {
        EBK.freeze();
    }

    
    function setAirdropAdmin(address _admin, bool _isAdmin) public onlyOwner {
        setAdmin(_admin, _isAdmin);
    }

    
    function airdropTokens(address[] memory _recipients, uint256[] memory _amounts) public onlyOwnerOrAdmin {
        require(_recipients.length == _amounts.length, "Recipients and amounts lengths are not equals.");

        for(uint256 i = 0; i < _recipients.length; i++) {
            require(EBK.transfer(_recipients[i], _amounts[i]));
        }
    }
}