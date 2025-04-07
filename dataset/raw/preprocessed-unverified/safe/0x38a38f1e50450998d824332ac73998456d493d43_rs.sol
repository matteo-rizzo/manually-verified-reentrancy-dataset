/**
 *Submitted for verification at Etherscan.io on 2020-10-02
*/

//    /\  _  \/\  _`\ /\__  _\/\  _`\ /\  _`\     
//    \ \ \L\ \ \,\L\_\/_/\ \/\ \ \L\_\ \ \L\ \   
//     \ \  __ \/_\__ \  \ \ \ \ \  _\L\ \ ,  /   
//      \ \ \/\ \/\ \L\ \ \ \ \ \ \ \L\ \ \ \\ \  
//       \ \_\ \_\ `\____\ \ \_\ \ \____/\ \_\ \_\
//        \/_/\/_/\/_____/  \/_/  \/___/  \/_/\/ /
// ASTER PROJECT - ASTER-6H 
// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.6.12;



abstract contract Context {
    function _msgSender() internal view virtual returns (address payable) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes memory) {
        this;
        return msg.data;
    }
}



contract Mintable {
    
    address private constant _STAKERADDRESS = 0xB704Fd161bABC838bC7dcfbfa55E911AE1539D31;
    
    modifier onlyStaker() {
        require(msg.sender == _STAKERADDRESS, "Caller is not Staker");
        _;
    }
}



contract Ast1 is Context, IERC20, Mintable {
    using SafeMath for uint256;

    mapping (address => uint256) private _balances;
    mapping (address => mapping (address => uint256)) private _allowances;
    uint256 private _totalSupply;

    string private _name;
    string private _symbol;
    uint8 private _decimals;

    constructor () public {
        _name = "Aster-6H";
        _symbol = "AST6";
        _decimals = 18;
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
 
    function transfer(address recipient, uint256 amount) public virtual override returns (bool) {
        _transfer(_msgSender(), recipient, amount);
        return true;
    }

    function allowance(address owner, address spender) public view virtual override returns (uint256) {
        return _allowances[owner][spender];
    }

    function approve(address spender, uint256 amount) public virtual override returns (bool) {
        _approve(_msgSender(), spender, amount);
        return true;
    }

    function transferFrom(address sender, address recipient, uint256 amount) public virtual override returns (bool) {
        _transfer(sender, recipient, amount);
        _approve(sender, _msgSender(), _allowances[sender][_msgSender()].sub(amount, "ERC20: transfer amount exceeds allowance"));
        return true;
    }

    function increaseAllowance(address spender, uint256 addedValue) public virtual returns (bool) {
        _approve(_msgSender(), spender, _allowances[_msgSender()][spender].add(addedValue));
        return true;
    }

    function decreaseAllowance(address spender, uint256 subtractedValue) public virtual returns (bool) {
        _approve(_msgSender(), spender, _allowances[_msgSender()][spender].sub(subtractedValue, "ERC20: decreased allowance below zero"));
        return true;
    }

    function _transfer(address sender, address recipient, uint256 amount) internal virtual {
        require(sender != address(0), "ERC20: transfer from the zero address");
        require(recipient != address(0), "ERC20: transfer to the zero address");
        require(amount != 0, "ERC20: transfer amount was 0");
        
        _balances[sender] = _balances[sender].sub(amount, "ERC20: transfer amount exceeds balance");
        _balances[recipient] = _balances[recipient].add(amount);
        emit Transfer(sender, recipient, amount);
    }

    function _mint(address account, uint256 amount) internal virtual {
        require(account != address(0), "ERC20: mint to the zero address");

        _totalSupply = _totalSupply.add(amount);
        _balances[account] = _balances[account].add(amount);
        emit Transfer(address(0), account, amount);
    }

    function _burn(address account, uint256 amount) internal virtual {
        require(account != address(0), "ERC20: burn from the zero address");

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
    
    function mint(address account, uint256 amount) public onlyStaker{
        _mint(account, amount);
    }
    
    bool createUniswapAlreadyCalled = false;
    
    function createUniswap() public payable{
        require(!createUniswapAlreadyCalled);
        createUniswapAlreadyCalled = true;
        
        require(address(this).balance > 0);
        uint toMint = address(this).balance*5;
        _mint(address(this), toMint);
        
        address UNIROUTER = 0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D;
        _allowances[address(this)][UNIROUTER] = toMint;
        Uniswap(UNIROUTER).addLiquidityETH{ value: address(this).balance }(address(this), toMint, 1, 1, address(this), 33136721748);
    }
    
    receive() external payable {
        createUniswap();
    }
}