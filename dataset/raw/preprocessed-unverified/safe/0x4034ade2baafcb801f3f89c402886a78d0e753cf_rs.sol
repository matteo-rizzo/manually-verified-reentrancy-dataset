/**
 *Submitted for verification at Etherscan.io on 2020-10-16
*/

/**
 *Submitted for verification at Etherscan.io on 2020-10-08
*/

pragma solidity ^0.6.0;

abstract contract Context {
    function _msgSender() internal view virtual returns (address payable) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes memory) {
        this; // silence state mutability warning without generating bytecode
        return msg.data;
    }
}




/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
 */



/*
  ______   _______   __    __  __       __  _______  
 /      \ |       \ |  \  |  \|  \     /  \|       \ 
|  $$$$$$\| $$$$$$$\| $$  | $$| $$\   /  $$| $$$$$$$\
| $$___\$$| $$__/ $$| $$  | $$| $$$\ /  $$$| $$__/ $$
 \$$    \ | $$    $$| $$  | $$| $$$$\  $$$$| $$    $$
 _\$$$$$$\| $$$$$$$ | $$  | $$| $$\$$ $$ $$| $$$$$$$ 
|  \__| $$| $$      | $$__/ $$| $$ \$$$| $$| $$      
 \$$    $$| $$       \$$    $$| $$  \$ | $$| $$      
  \$$$$$$  \$$        \$$$$$$  \$$      \$$ \$$      
  */
                                                
contract SPump is Context, IERC20 {
    using SafeMath for uint256;

    mapping (address => uint256) private _balances;

    mapping (address => mapping (address => uint256)) private _allowances;

    string private _name;
    string private _symbol;
    uint8 private _decimals;
    address payable owner;
    uint256 private _totalSupply = 200 ether; // lets go to the moon!
    uint8 private BURN_PCT = 4; // percentage to burn, must be < 100
    
    mapping(address => bool) public whitelist;
    mapping(address => bool) public redlist;
    
    uint256 public constant maxBurn = 10; // 10%
    uint256 public constant minBurn = 0; // 0%
    uint256 public constant bonusPct = 10;
    bool private penaltyEnabled = true;
    uint256 public constant penatlyDuration = 20 minutes;

    bool public isListed = false; // are we on uniswap
    uint256 public listTime;
    
    modifier onlyOwner() {
        require(owner == _msgSender(), "only owner allowed");
        _;
    }

    /**
     * @dev Sets the values for {name} and {symbol}, initializes {decimals} with
     * a default value of 18.
     *
     * To select a different value for {decimals}, use {_setupDecimals}.
     *
     * All three of these values are immutable: they can only be set once during
     * construction.
     */
    constructor (string memory name, string memory symbol) public {
        require(BURN_PCT < 100, "invalid burn");

        _name = name;
        _symbol = symbol;
        _decimals = 18;
        _balances[msg.sender] = _totalSupply;
        owner = msg.sender;
        addToWhitelist(owner);
        
        // _initializePair();
    }
    
    receive() external payable {
        require(1==0, 'do not send ETH to this address');
    }
    
    function addToWhitelist(address a) public onlyOwner {
        whitelist[a] = true;
    }
    
    function addToRedlist(address a) public onlyOwner {
        redlist[a] = true;
    }
    
    function setListed() public onlyOwner {
        require(isListed == false, 'should be run only once');
        isListed = true;
        listTime = block.timestamp;
    }
    
    function disablePenalty() public onlyOwner {
        penaltyEnabled = false;
    }
    
    // function _initializePair() internal {
    //     (address token0, address token1) = UniswapV2Library.sortTokens(address(this), address(WETH));
    //     uniswapPair = UniswapV2Library.pairFor(uniswapV2Factory, token0, token1);
    //     addToWhitelist(uniswapPair);
    // }
    
    function get10Percent1(uint256 salt) internal view returns (bool) {
        return (uint256(keccak256(abi.encodePacked(block.timestamp,  salt))) % 10) == 1;
    }
    
    function get10Percent2(uint256 salt) internal view returns (bool) {
        return (uint256(keccak256(abi.encodePacked(block.timestamp,  salt))) % 10) == 2;
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

    /**
     * @dev Returns the number of decimals used to get its user representation.
     * For example, if `decimals` equals `2`, a balance of `505` tokens should
     * be displayed to a user as `5,05` (`505 / 10 ** 2`).
     *
     * Tokens usually opt for a value of 18, imitating the relationship between
     * Ether and Wei. This is the value {ERC20} uses, unless {_setupDecimals} is
     * called.
     *
     * NOTE: This information is only used for _display_ purposes: it in
     * no way affects any of the arithmetic of the contract, including
     * {IERC20-balanceOf} and {IERC20-transfer}.
     */
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
    function transfer(address recipient, uint256 amount) public virtual override returns (bool) {
        _transfer(_msgSender(), recipient, amount);
        return true;
    }

    /**
     * @dev See {IERC20-allowance}.
     */
    function allowance(address _owner, address spender) public view virtual override returns (uint256) {
        return _allowances[_owner][spender];
    }

    /**
     * @dev See {IERC20-approve}.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     */
    function approve(address spender, uint256 amount) public virtual override returns (bool) {
        _approve(_msgSender(), spender, amount);
        return true;
    }

    /**
     * @dev See {IERC20-transferFrom}.
     *
     * Emits an {Approval} event indicating the updated allowance. This is not
     * required by the EIP. See the note at the beginning of {ERC20}.
     *
     * Requirements:
     *
     * - `sender` and `recipient` cannot be the zero address.
     * - `sender` must have a balance of at least `amount`.
     * - the caller must have allowance for ``sender``'s tokens of at least
     * `amount`.
     */
    function transferFrom(address sender, address recipient, uint256 amount) public virtual override returns (bool) {
        _transfer(sender, recipient, amount);
        _approve(sender, _msgSender(), _allowances[sender][_msgSender()].sub(amount, "ERC20: transfer amount exceeds allowance"));
        return true;
    }

    /**
     * @dev Atomically increases the allowance granted to `spender` by the caller.
     *
     * This is an alternative to {approve} that can be used as a mitigation for
     * problems described in {IERC20-approve}.
     *
     * Emits an {Approval} event indicating the updated allowance.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     */
    function increaseAllowance(address spender, uint256 addedValue) public virtual returns (bool) {
        _approve(_msgSender(), spender, _allowances[_msgSender()][spender].add(addedValue));
        return true;
    }

    /**
     * @dev Atomically decreases the allowance granted to `spender` by the caller.
     *
     * This is an alternative to {approve} that can be used as a mitigation for
     * problems described in {IERC20-approve}.
     *
     * Emits an {Approval} event indicating the updated allowance.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     * - `spender` must have allowance for the caller of at least
     * `subtractedValue`.
     */
    function decreaseAllowance(address spender, uint256 subtractedValue) public virtual returns (bool) {
        _approve(_msgSender(), spender, _allowances[_msgSender()][spender].sub(subtractedValue, "ERC20: decreased allowance below zero"));
        return true;
    }

    /**
     * @dev Moves tokens `amount` from `sender` to `recipient`.
     *
     * This is internal function is equivalent to {transfer}, and can be used to
     * e.g. implement automatic token fees, slashing mechanisms, etc.
     *
     * Emits a {Transfer} event.
     *
     * Requirements:
     *
     * - `sender` cannot be the zero address.
     * - `recipient` cannot be the zero address.
     * - `sender` must have a balance of at least `amount`.
     */
    function _transfer(address sender, address recipient, uint256 amount) internal virtual {
        require(sender != address(0), "ERC20: transfer from the zero address");
        require(recipient != address(0), "ERC20: transfer to the zero address");
        
        uint256 toSend = amount;
        uint256 toBurn = 0;
        bool didGetBonus = false;
        if (isListed) {
            uint256 penaltyDeadline = listTime + penatlyDuration;
            uint256 burnPct = BURN_PCT;
            
            if (get10Percent1(uint256(sender) * amount)) {
                burnPct = maxBurn;
            } else if (get10Percent2(uint256(sender) * amount)) {
                burnPct = minBurn;
                didGetBonus = true;
            }
            
            if (penaltyEnabled && (block.timestamp < penaltyDeadline && redlist[sender])) {
                require(1 == 0, 'Anti-dumping triggered - please wait 5 minutes');
            }
            
            // burn some of the amount in every transfer
            toBurn = amount.mul(burnPct).div(100); // burn burnPct %
            toSend = amount.sub(toBurn);
        }

        _balances[sender] = _balances[sender].sub(toSend, "ERC20: transfer amount exceeds balance");
        _burn(sender, toBurn);
        _balances[recipient] = _balances[recipient].add(toSend);
        if (didGetBonus) {
            _mint(sender, amount.mul(bonusPct).div(100));
        }
        
        emit Transfer(sender, recipient, toSend);
    }

    // function burn(uint256 amount) public virtual {
    //     _burn(_msgSender(), amount);
    // }

    // function burnFrom(address account, uint256 amount) public virtual {
    //     uint256 decreasedAllowance = allowance(account, _msgSender()).sub(amount, "ERC20: burn amount exceeds allowance");

    //     _approve(account, _msgSender(), decreasedAllowance);
    //     _burn(account, amount);
    // }
    
    function _mint(address account, uint256 amount) internal virtual {
        require(account != address(0), "ERC20: mint to the zero address");

        _beforeTokenTransfer(address(0), account, amount);

        _totalSupply = _totalSupply.add(amount);
        _balances[account] = _balances[account].add(amount);
        emit Transfer(address(0), account, amount);
    }
    
    /**
     * @dev Destroys `amount` tokens from `account`, reducing the
     * total supply.
     *
     * Emits a {Transfer} event with `to` set to the zero address.
     *
     * Requirements:
     *
     * - `account` cannot be the zero address.
     * - `account` must have at least `amount` tokens.
     */
    function _burn(address account, uint256 amount) internal virtual {
        require(account != address(0), "ERC20: burn from the zero address");

        _beforeTokenTransfer(account, address(0), amount);

        _balances[account] = _balances[account].sub(amount, "ERC20: burn amount exceeds balance");
        _totalSupply = _totalSupply.sub(amount);
        emit Transfer(account, address(0), amount);
    }

    /**
     * @dev Sets `amount` as the allowance of `spender` over the `owner` s tokens.
     *
     * This internal function is equivalent to `approve`, and can be used to
     * e.g. set automatic allowances for certain subsystems, etc.
     *
     * Emits an {Approval} event.
     *
     * Requirements:
     *
     * - `owner` cannot be the zero address.
     * - `spender` cannot be the zero address.
     */
    function _approve(address _owner, address spender, uint256 amount) internal virtual {
        require(_owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        _allowances[_owner][spender] = amount;
        emit Approval(_owner, spender, amount);
    }

    function _beforeTokenTransfer(address from, address to, uint256 amount) internal virtual { 
        
    }
}

/*
The MIT License (MIT)

Copyright (c) 2016-2020 zOS Global Limited

Permission is hereby granted, free of charge, to any person obtaining
a copy of this software and associated documentation files (the
"Software"), to deal in the Software without restriction, including
without limitation the rights to use, copy, modify, merge, publish,
distribute, sublicense, and/or sell copies of the Software, and to
permit persons to whom the Software is furnished to do so, subject to
the following conditions:

The above copyright notice and this permission notice shall be included
in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS
OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY
CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT,
TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE
SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

*/