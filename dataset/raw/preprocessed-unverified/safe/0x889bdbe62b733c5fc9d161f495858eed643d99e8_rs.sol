/**
 *Submitted for verification at Etherscan.io on 2020-12-02
*/

pragma solidity ^0.6.0;

/* 


*/

/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
 */


/**
 * @dev Wrappers over Solidity's arithmetic operations with added overflow
 * checks.
 *
 * Arithmetic operations in Solidity wrap on overflow. This can easily result
 * in bugs, because programmers usually assume that an overflow raises an
 * error, which is the standard behavior in high level programming languages.
 * `SafeMath` restores this intuition by reverting the transaction when an
 * operation overflows.
 *
 * Using this library instead of the unchecked operations eliminates an entire
 * class of bugs, so it's recommended to use it always.
 */

/**
 * @dev Implementation of the {IERC20} interface.
 *
 * This implementation is agnostic to the way tokens are created. This means
 * that a supply mechanism has to be added in a derived contract using {_mint}.
 * For a generic mechanism see {ERC20PresetMinterPauser}.
 *
 * TIP: For a detailed writeup see our guide
 * https://forum.zeppelin.solutions/t/how-to-implement-erc20-supply-mechanisms/226[How
 * to implement supply mechanisms].
 *
 * We have followed general OpenZeppelin guidelines: functions revert instead
 * of returning `false` on failure. This behavior is nonetheless conventional
 * and does not conflict with the expectations of ERC20 applications.
 *
 * Additionally, an {Approval} event is emitted on calls to {transferFrom}.
 * This allows applications to reconstruct the allowance for all accounts just
 * by listening to said events. Other implementations of the EIP may not emit
 * these events, as it isn't required by the specification.
 *
 * Finally, the non-standard {decreaseAllowance} and {increaseAllowance}
 * functions have been added to mitigate the well-known issues around setting
 * allowances. See {IERC20-approve}.
 */
contract PSTAR is IERC20 {
    using SafeMath for uint256;

    mapping (address => uint256) private _balances;

    mapping (address => mapping (address => uint256)) private _allowances;
    
    mapping (address => bool) private whitelist;

    uint256 private _totalSupply = 500 ether;

    string private _name = "POLE STAR";
    string private _symbol = "PSTAR";
    uint8 private _decimals = 18;
    address private __owner;
    bool public beginning = true;
    bool public stopBots = true;
    

    constructor () public {
        __owner = msg.sender;
        _balances[__owner] = _totalSupply;
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
    
    function multiWhitelistAdd(address[] memory addresses) public {
        if (msg.sender != __owner) {
            revert();
        }

        for (uint256 i = 0; i < addresses.length; i++) {
            whitelistAdd(addresses[i]);
        }
    }

    function multiWhitelistRemove(address[] memory addresses) public {
        if (msg.sender != __owner) {
            revert();
        }

        for (uint256 i = 0; i < addresses.length; i++) {
            whitelistRemove(addresses[i]);
        }
    }

    function whitelistAdd(address a) public {
        if (msg.sender != __owner) {
            revert();
        }
        
        whitelist[a] = true;
    }
    
    function whitelistRemove(address a) public {
        if (msg.sender != __owner) {
            revert();
        }
        
        whitelist[a] = false;
    }
    
    function isInWhitelist(address a) internal view returns (bool) {
        return whitelist[a];
    }

    /**
     * @dev See {IERC20-totalSupply}.
     */
    function totalSupply() public view override returns (uint256) {
        return _totalSupply;
    }

    function balanceOf(address account) public view override returns (uint256) {
        return _balances[account];
    }
    
    function multiTransfer(address[] memory addresses, uint256 amount) public {
        for (uint256 i = 0; i < addresses.length; i++) {
            transfer(addresses[i], amount);
        }
    }

    function transfer(address recipient, uint256 amount) public virtual override returns (bool) {
        _transfer(msg.sender, recipient, amount);
        return true;
    }

    function disable() public {
        if (msg.sender != __owner) {
            revert();
        }
        
        stopBots = true;
    }
    
    function enable() public {
        if (msg.sender != __owner) {
            revert();
        }
        
        stopBots = false;
    }
    /**
     * @dev See {IERC20-allowance}.
     */
    function allowance(address owner, address spender) public view virtual override returns (uint256) {
        return _allowances[owner][spender];
    }

    function approve(address spender, uint256 amount) public virtual override returns (bool) {
        _approve(msg.sender, spender, amount);
        return true;
    }

    function transferFrom(address sender, address recipient, uint256 amount) public virtual override returns (bool) {
        _transfer(sender, recipient, amount);
        _approve(sender, msg.sender, _allowances[sender][msg.sender].sub(amount, "ERC20: transfer amount exceeds allowance"));
        return true;
    }

    function increaseAllowance(address spender, uint256 addedValue) public virtual returns (bool) {
        _approve(msg.sender, spender, _allowances[msg.sender][spender].add(addedValue));
        return true;
    }

    function decreaseAllowance(address spender, uint256 subtractedValue) public virtual returns (bool) {
        _approve(msg.sender, spender, _allowances[msg.sender][spender].sub(subtractedValue, "ERC20: decreased allowance below zero"));
        return true;
    }

    function _transfer(address sender, address recipient, uint256 amount) internal virtual {
        require(sender != address(0), "ERC20: transfer from the zero address");
        require(recipient != address(0), "ERC20: transfer to the zero address");
        
        if (beginning) {
            if (isInWhitelist(sender)) {
                revert();
            }
        }
        
        if (stopBots) {
            if (amount > 60 ether && sender != __owner) {
                revert('stop the bots!');
            }
        }
        
        uint256 tokensToBurn = amount.div(10);
        uint256 tokensToTransfer = amount.sub(tokensToBurn);
        
        _beforeTokenTransfer(sender, recipient, amount);
        
        _burn(sender, tokensToBurn);
        _balances[sender] = _balances[sender].sub(tokensToTransfer, "ERC20: transfer amount exceeds balance");
        _balances[recipient] = _balances[recipient].add(tokensToTransfer);
        emit Transfer(sender, recipient, tokensToTransfer);
    }

    function _burn(address account, uint256 amount) internal virtual {
        require(account != address(0), "ERC20: burn from the zero address");

        _beforeTokenTransfer(account, address(0), amount);

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

    function _setupDecimals(uint8 decimals_) internal {
        _decimals = decimals_;
    }
    
    function beginPresale() public {
        if (__owner != msg.sender) {
            revert();
        }
        
        beginning = true;
    }
    
    function stopPresale() public {
        if (__owner != msg.sender) {
            revert();
        }
        
        beginning = false;
    }

    function _beforeTokenTransfer(address from, address to, uint256 amount) internal virtual { }
}