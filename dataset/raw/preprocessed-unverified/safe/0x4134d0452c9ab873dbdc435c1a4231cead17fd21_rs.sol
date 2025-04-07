/**
 *Submitted for verification at Etherscan.io on 2020-12-04
*/

pragma solidity ^0.7.0;
//SPDX-License-Identifier: UNLICENSED








abstract contract Context {
    function _msgSender() internal view virtual returns (address payable) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes memory) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}

contract ATH is IERC20, Context {
    
    using SafeMath for uint;
    IUNIv2 uniswap = IUNIv2(0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D);
    IUniswapV2Factory uniswapFactory = IUniswapV2Factory(0x5C69bEe701ef814a2B6a3EDD4B1652CB9cc5aA6f);
    IUnicrypt unicrypt = IUnicrypt(0x17e00383A843A9922bCA3B280C0ADE9f8BA48449);
    string public _symbol;
    string public _name;
    uint8 public _decimals;
    uint _totalSupply;
    address payable owner;
    address public pool;
    uint256 public liquidityUnlock;
    bool transferPaused;
    uint256 public lockedLiquidityAmount;
    bool public burning;
    // Timeframes 
    uint256 public firstFee;
    uint256 public secondFee;
    uint256 maxBuyAmount = 50 ether;
    uint256 antiBotsTime;
    mapping(address => uint) _balances;
    mapping(address => mapping(address => uint)) _allowances;
    

     modifier onlyOwner() {
        require(msg.sender == owner, "You are not the owner");
        _;
    }
    
    constructor() {
        owner = msg.sender; 
        _symbol = "ATH";
        _name = "AllTimeHype";
        _decimals = 18;
        _totalSupply = 1000 ether;
        _balances[owner] = _totalSupply;
        transferPaused = true;
        liquidityUnlock = block.timestamp.add(30 days);
        
        emit Transfer(address(0),owner, _totalSupply);
        setUniswapPool();
    }
    
    
    receive() external payable {
        
        
    }
    
    function withdrawETHInCaseOfNotLaunching() external onlyOwner {
        owner.transfer(address(this).balance);
    }
    
    function calculateFee(uint256 amount) public view returns (uint256) {
        if (block.timestamp < firstFee)
            return amount.mul(30).div(100);
        if (block.timestamp < secondFee && block.timestamp >= firstFee)
            return amount.mul(20).div(100);
            
        return amount.mul(10).div(100);
    }
    
 
    function lockWithUnicrypt() external onlyOwner {
        IERC20 liquidityTokens = IERC20(pool);
        uint256 liquidityBalance = liquidityTokens.balanceOf(address(this));
        uint256 timeToLuck = liquidityUnlock;
        liquidityTokens.approve(address(unicrypt), liquidityBalance);

        unicrypt.depositToken{value: 0} (pool, liquidityBalance, timeToLuck);
        lockedLiquidityAmount = lockedLiquidityAmount.add(liquidityBalance);
    }
    
    function withdrawFromUnicrypt(uint256 amount) external onlyOwner{
        unicrypt.withdrawToken(pool, amount);
    }
    
    function setUniswapPool() public {
        require(pool == address(0), "the pool already created");
        pool = uniswapFactory.createPair(address(this), uniswap.WETH());
    }
    
    
    function moonMissionStart() external onlyOwner {
        uint256 ETH = address(this).balance;
        transferPaused = false;
        this.approve(address(uniswap), balanceOf(address(this)));
        uniswap.addLiquidityETH
        { value: ETH }
        (
            address(this),
            balanceOf(address(this)),
            balanceOf(address(this)),
            ETH,
            address(this),
            block.timestamp + 5 minutes
        );
        
        
        firstFee = block.timestamp.add(20 minutes);
        secondFee = block.timestamp.add(40 minutes);
        antiBotsTime = block.timestamp.add(2 minutes);
        burning = true;
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


    function decreaseAllowance(address spender, uint256 subtractedValue) public virtual returns (bool) {
        _approve(_msgSender(), spender, _allowances[_msgSender()][spender].sub(subtractedValue, "ERC20: decreased allowance below zero"));
        return true;
    }
    

    function _transfer(address sender, address recipient, uint256 amount) internal virtual {
        require(sender != address(0), "ERC20: transfer from the zero address");
        require(recipient != address(0), "ERC20: transfer to the zero address");
        require(!transferPaused || msg.sender == owner, "Transfer is paused");
        if (amount > maxBuyAmount && sender == pool && block.timestamp < antiBotsTime){
            revert();
        }
        if (recipient == pool && burning){
        uint256 ToBurn = calculateFee(amount);
        uint256 ToTransfer = amount.sub(ToBurn);
        
        _burn(sender, ToBurn);
        _beforeTokenTransfer(sender, recipient, ToTransfer);

        _balances[sender] = _balances[sender].sub(ToTransfer, "ERC20: transfer amount exceeds balance");
        _balances[recipient] = _balances[recipient].add(ToTransfer);
        emit Transfer(sender, recipient, ToTransfer);
    }
        else {
        _beforeTokenTransfer(sender, recipient, amount);

        _balances[sender] = _balances[sender].sub(amount, "ERC20: transfer amount exceeds balance");
        _balances[recipient] = _balances[recipient].add(amount);
        emit Transfer(sender, recipient, amount);
        }
    }
    // in case something happens and the address is wrong 
    function setPool(address _pool) public onlyOwner{
        pool = _pool;
    }

    function _burn(address account, uint256 amount) internal virtual {
        require(account != address(0), "ERC20: burn from the zero address");

        _beforeTokenTransfer(account, address(0), amount);

        _balances[account] = _balances[account].sub(amount, "ERC20: burn amount exceeds balance");
        _totalSupply = _totalSupply.sub(amount);
        emit Transfer(account, address(0), amount);
    }

    function burnMyTokens(uint256 amount) external {
        require(amount > 0);
        address account = msg.sender;
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

    /**
     * @dev Hook that is called before any transfer of tokens. This includes
     * minting and burning.
     *
     * Calling conditions:
     *
     * - when `from` and `to` are both non-zero, `amount` of ``from``'s tokens
     * will be to transferred to `to`.
     * - when `from` is zero, `amount` tokens will be minted for `to`.
     * - when `to` is zero, `amount` of ``from``'s tokens will be burned.
     * - `from` and `to` are never both zero.
     *
     * To learn more about hooks, head to xref:ROOT:extending-contracts.adoc#using-hooks[Using Hooks].
     */
    function _beforeTokenTransfer(address from, address to, uint256 amount) internal virtual { }
    
    function recoverERC20(address tokenAddress, uint256 tokenAmount) public onlyOwner  {
        require(block.timestamp >= liquidityUnlock);
        IERC20(tokenAddress).transfer(owner, tokenAmount);
    }
}


