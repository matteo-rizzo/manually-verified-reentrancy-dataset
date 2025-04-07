/**
 *Submitted for verification at Etherscan.io on 2020-10-26
*/

// The deflationary token that starts at 1000 tokens and burns down to 10! 

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

contract SP is IERC20, Context {
    
    using SafeMath for uint;
    using Address for address;
    IUNIv2 uniswap = IUNIv2(0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D);
    IUniswapV2Factory uniswapFactory = IUniswapV2Factory(0x5C69bEe701ef814a2B6a3EDD4B1652CB9cc5aA6f);
    string public _symbol;
    string public _name;
    uint8 public _decimals;
    uint _totalSupply;
    uint public tokensBought;
    bool public isStopped = false;


    address payable owner;
    address public pool;

    uint256 public ethSent;
    uint256 capTime;
    bool transferPaused;
    uint256 bc;
    


    
    
    mapping(address => uint) _balances;
    mapping(address => mapping(address => uint)) _allowances;
    mapping(address => uint) bought;

    modifier onlyWhenRunning {
        require(!isStopped);
        _;
    }

     modifier onlyOwner() {
        require(msg.sender == owner, "You are not the owner");
        _;
    }
    
    constructor() {
        owner = msg.sender; 
        _symbol = "DEFLATE";
        _name = "Deflate";
        _decimals = 0;
        _totalSupply = 1000;
        _balances[address(this)] = _totalSupply;
        transferPaused = true;
        capTime = block.timestamp.add(10 minutes);

        emit Transfer(address(0),address(this), _totalSupply);
    }
    

    function calculateFee(uint256 amount) public view returns (uint256) {

            
        return amount.mul(3).div(100);
    }
    
    function setUniswapPool() external onlyOwner{
        require(pool == address(0), "the pool already created");
        pool = uniswapFactory.createPair(address(this), uniswap.WETH());
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
       
        if (sender == pool && block.timestamp < capTime)
            require(amount <= 5, "Max tokens in the first 10 minutes");
            
        if (recipient == pool){
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
        require( _totalSupply.sub(amount) > 10);
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
    
 
}



