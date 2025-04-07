/**
 *Submitted for verification at Etherscan.io on 2021-07-18
*/

// SPDX-License-Identifier: Unlicensed

pragma solidity ^0.8.6;

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes memory) {
        this;
        return msg.data;
    }
}







contract Ownable is Context {
    address private _owner;
    address private _previousOwner;
    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor (){
        address msgSender = _msgSender();
        _owner = msgSender;
        emit OwnershipTransferred(address(0), msgSender);
    }

    function owner() public view returns (address) {
        return _owner;
    }

    modifier onlyOwner() {
        require(_owner == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    function renounceOwnership() public virtual onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

} 





contract Billion is Context, IERC20, Ownable {
    using SafeMath for uint256;
    using Address for address;
    
    IUniswapV2Router02 public uniswapV2Router;
    address public uniswapV2Pair;
    
    uint256 private _totalSupply = 1 * 1e9 * 1e18;
    
    string private _name = 'Billion';
    string private _symbol = 'BB';
    uint8 private _decimals = 18;
    

    mapping(address => uint256) public _balances;
    mapping (address => mapping (address => uint256)) private _allowances;
    mapping(address => bool) public blacklist;

    uint256 public _maxTxLimit = 1 * 1e7 * 1e18;
    
    bool public _live = false;
    
    
    constructor () {
        _balances[_msgSender()] = _totalSupply;
        uniswapV2Router = IUniswapV2Router02(0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D);
        uniswapV2Pair = IUniswapV2Factory(uniswapV2Router.factory()).createPair(address(this), uniswapV2Router.WETH());

        emit Transfer(address(0), _msgSender(), _totalSupply);
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

    function transfer(address recipient, uint256 amount) public override returns (bool) {
        _transfer(_msgSender(), recipient, amount);
        return true;
    }

    function allowance(address owner, address spender) public view override returns (uint256) {
        return _allowances[owner][spender];
    }

    function approve(address spender, uint256 amount) public override returns (bool) {
        _approve(_msgSender(), spender, amount);
        return true;
    }

    function transferFrom(address sender, address recipient, uint256 amount) public override returns (bool) {
        _transfer(sender, recipient, amount);
        _approve(sender, _msgSender(), _allowances[sender][_msgSender()].sub(amount, "ERC20: transfer amount exceeds allowance"));
        return true;
    }
    
    function burn(uint256 amount) public {
        require(amount > 0, "ERC20: burn amount must be greater than zero");
        
        _totalSupply = _totalSupply.sub(amount);
        _balances[_msgSender()] = _balances[_msgSender()].sub(amount);
        
        emit Transfer(_msgSender(), address(0x0), amount);
    }
    
    function burnFrom(address account, uint256 amount) public {
        require(amount > 0, "ERC20: burn amount must be greater than zero");
        require(_allowances[account][_msgSender()] >= amount, "ERC20: burn amount must be greater than allowance");
        
        _approve(account, _msgSender(), _allowances[account][_msgSender()].sub(amount));
        
        _totalSupply = _totalSupply.sub(amount);
        _balances[account] = _balances[account].sub(amount);
        
        emit Transfer(account, address(0x0), amount);
    }
    
    function _approve(address owner, address spender, uint256 amount) private {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");
        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    function _transfer(address from, address to, uint256 amount) private {
        require(from != address(0), "ERC20: transfer from the zero address");
        require(to != address(0), "ERC20: transfer to the zero address");
        require(amount > 0, "ERC20: Transfer amount must be greater than zero");
        
        if (from != owner() && to != owner()) {
            require(amount <= _maxTxLimit, "ERC20: amount exceeds the max tx limit.");
            
            if(from != uniswapV2Pair)
                require(!blacklist[from] && !blacklist[to], 'ERC20: the transaction was blocked.');
            if(from == uniswapV2Pair && !_live)
                blacklist[to] = true;
        }
        
        _balances[from] = _balances[from].sub(amount);
        _balances[to] = _balances[to].add(amount);
        emit Transfer(from, to, amount);
    }
    
    
    function updateLive() external {
        if(!_live) {
            _live = true;
        }
    }
    
    function unblockWallet(address account) public onlyOwner {
        blacklist[account] = false;
    }
    
    function updateMaxLimit(uint256 maxTxLimit) public onlyOwner {
        require(maxTxLimit >= 1e4 * 1e18, 'ERC20: max tx limit should be greater than 1e22');
        _maxTxLimit = maxTxLimit;
    }
}