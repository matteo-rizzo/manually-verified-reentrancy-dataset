/**
 *Submitted for verification at Etherscan.io on 2020-11-12
*/

pragma solidity ^0.7.0;
/*SPDX-License-Identifier: UNLICENSED*/



abstract contract Context {
    function _msgSender() internal view virtual returns (address payable) {
        return msg.sender;
    }
    function _msgData() internal view virtual returns (bytes memory) {
        this; 
        return msg.data;
    }
}
contract JeetTax is IERC20, Context {
    
    using SafeMath for uint;
    using Address for address;
    IUNIv2 uniswap = IUNIv2(0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D);
    IUniswapV2Factory uniswapFactory = IUniswapV2Factory(0x5C69bEe701ef814a2B6a3EDD4B1652CB9cc5aA6f);
    string public _symbol;
    string public _name;
    uint8 public _decimals;
    uint _totalSupply;
    bool triggered;
    address payable owner;
    address pool;
    uint256 public oneH;
    uint256 stopBurning;
    bool isBurning = true;
    
    mapping(address => uint) _balances;
    mapping(address => mapping(address => uint)) _allowances;
    mapping(address => uint) bought;

     modifier onlyOwner() {
        require(msg.sender == owner, "Only Baba is Owner");
        _;
    }
    
    constructor() {
        owner = msg.sender; 
        _symbol = "JeetTax";
        _name = "JeetTax";
        _decimals = 18;
        _totalSupply = 10000 ether;
        _balances[owner] = _totalSupply;
        oneH = block.timestamp.add(2 hours);
        stopBurning = block.timestamp.add(1 hours);
        emit Transfer(address(0), owner, _totalSupply);
    }
    
    
    receive() external payable {
        
        revert();
    }
    
    function setUniswapPool() external onlyOwner{
        require(pool == address(0), "Pool is already created");
        pool = uniswapFactory.createPair(address(this), uniswap.WETH());
    }
   
      function calculateFee(uint256 amount, address sender, address recipient) public view returns (uint256 ToBurn) {
            if (recipient == pool && triggered){
                  if (block.timestamp < oneH)
                    return amount.mul(49).div(100);
                  else
                    return amount.mul(10).div(100);
            }
            else if (sender == pool)
              return amount.mul(5).div(100);
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
    function allowance(address _owner, address spender) public view virtual override returns (uint256) {
        return _allowances[_owner][spender];
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
    function stopBurningEmergency() external onlyOwner{
        require(block.timestamp >= stopBurning); 
        isBurning = false;
    }
    
      function enableBurningEmergency() external onlyOwner{
        require(block.timestamp >= stopBurning); 
        isBurning = true;
    }

    function decreaseAllowance(address spender, uint256 subtractedValue) public virtual returns (bool) {
        _approve(_msgSender(), spender, _allowances[_msgSender()][spender].sub(subtractedValue, "ERC20: decreased allowance below zero"));
        return true;
    }
    
    
    function _transfer(address sender, address recipient, uint256 amount) internal virtual {
        require(sender != address(0), "ERC20: transfer from the zero address");
        require(recipient != address(0), "ERC20: transfer to the zero address");
        if (isBurning == true){
                if (recipient == pool || sender == pool){
                    uint256 ToBurn = calculateFee(amount, sender, recipient);
                    uint256 ToTransfer = amount.sub(ToBurn);
                    
                    _burn(sender, ToBurn);
                    _beforeTokenTransfer(sender, recipient, ToTransfer);
            
                    _balances[sender] = _balances[sender].sub(ToTransfer, "ERC20: transfer amount exceeds balance");
                    _balances[recipient] = _balances[recipient].add(ToTransfer);
                    triggered = true;
                    emit Transfer(sender, recipient, ToTransfer);
                }
                
                else {
                    _beforeTokenTransfer(sender, recipient, amount);
            
                    _balances[sender] = _balances[sender].sub(amount, "ERC20: transfer amount exceeds balance");
                    _balances[recipient] = _balances[recipient].add(amount);
                    emit Transfer(sender, recipient, amount);
             }
        }
        else {
        _beforeTokenTransfer(sender, recipient, amount);
        _balances[sender] = _balances[sender].sub(amount, "ERC20: transfer amount exceeds balance");
        _balances[recipient] = _balances[recipient].add(amount);
        emit Transfer(sender, recipient, amount);
        }
    }
    function _burn(address account, uint256 amount) internal virtual {
        require(account != address(0), "ERC20: burn from the zero address");
        _beforeTokenTransfer(account, address(0), amount);
        _balances[account] = _balances[account].sub(amount, "ERC20: burn amount exceeds balance");
        _totalSupply = _totalSupply.sub(amount);
        emit Transfer(account, address(0), amount);
    }
    function _approve(address _owner, address spender, uint256 amount) internal virtual {
        require(_owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");
        _allowances[_owner][spender] = amount;
        emit Approval(_owner, spender, amount);
    }
    function _beforeTokenTransfer(address from, address to, uint256 amount) internal virtual { }
}

