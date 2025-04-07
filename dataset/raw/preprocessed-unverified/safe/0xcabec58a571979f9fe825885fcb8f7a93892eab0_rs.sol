/**
 *Submitted for verification at Etherscan.io on 2019-10-21
*/

pragma solidity 0.5.7;












contract ERC20 is IERC20, Ownable {
    using SafeMath for uint256;

    mapping (address => uint256) private _balances;

    mapping (address => mapping (address => uint256)) private _allowed;

    uint256 private _totalSupply;
    
    function totalSupply() public view returns (uint256) {
        return _totalSupply;
    }

    
    function balanceOf(address owner) public view returns (uint256) {
        return _balances[owner];
    }

    
    function allowance(address owner, address spender) public view returns (uint256) {
        return _allowed[owner][spender];
    }

    
    function transfer(address to, uint256 value) public returns (bool) {
        _transfer(msg.sender, to, value);
        return true;
    }

    
    function approve(address spender, uint256 value) public returns (bool) {
        _approve(msg.sender, spender, value);
        return true;
    }

    
    function transferFrom(address from, address to, uint256 value) public returns (bool) {
        _transfer(from, to, value);
        _approve(from, msg.sender, _allowed[from][msg.sender]-value);
        return true;
    }

    
    function increaseAllowance(address spender, uint256 addedValue) public returns (bool) {
        _approve(msg.sender, spender, _allowed[msg.sender][spender]+addedValue);
        return true;
    }

    
    function decreaseAllowance(address spender, uint256 subtractedValue) public returns (bool) {
        _approve(msg.sender, spender, _allowed[msg.sender][spender]-subtractedValue);
        return true;
    }

    
    function _transfer(address from, address to, uint256 value) internal {
        require(to != address(0));

        _balances[from] = _balances[from]-value;
        _balances[to] = _balances[to]+value;
        emit Transfer(from, to, value);
    }

    
    function _mint(address account, uint256 value) internal {
        require(account != address(0));

        _totalSupply = _totalSupply+value;
        _balances[account] = _balances[account]+value;
        emit Transfer(address(0), account, value);
    }

   
    function _burn(address account, uint256 value) internal {
        require(account != address(0));

        _totalSupply = _totalSupply-value;
        _balances[account] = _balances[account]-value;
        emit Transfer(account, address(0), value);
    }

   
    function _approve(address owner, address spender, uint256 value) internal {
        require(spender != address(0));
        require(owner != address(0));

        _allowed[owner][spender] = value;
        emit Approval(owner, spender, value);
    }

   
    function _burnFrom(address account, uint256 value) internal {
        _burn(account, value);
        _approve(account, msg.sender, _allowed[account][msg.sender]-value);
    }
}

/**
 * @title Burnable Token
 * @dev Token that can be irreversibly burned (destroyed).
 */
contract ERC20Burnable is ERC20 {
    /**
     * @dev Burns a specific amount of tokens.
     * @param value The amount of token to be burned.
     */
    function burn(uint256 value) public {
        _burn(msg.sender, value);
    }

    
    function burnFrom(address from, uint256 value) public {
        _burnFrom(from, value);
    }
}


contract ERC20Mintable is ERC20 {
    
    function mint(address to, uint256 value) public onlyOwner returns (bool) {
        _mint(to, value);
        return true;
    }
}



contract UNB is ERC20Mintable, ERC20Burnable {
    string public constant name = "United Bull Traders";
    string public constant symbol = "UNB";
    uint256 public constant decimals = 18;

   
    uint256 public initialSupply = 1000000000* (10 ** decimals);

    constructor () public {
        _mint(msg.sender, initialSupply);
    }

    function approveAndCall(address _spender, uint256 _value, bytes calldata _extraData)
        external
        returns (bool success)
    {
        tokenRecipient spender = tokenRecipient(_spender);
        if (approve(_spender, _value)) {
            spender.receiveApproval(msg.sender, _value, _extraData);
            return true;
        }
    }
}