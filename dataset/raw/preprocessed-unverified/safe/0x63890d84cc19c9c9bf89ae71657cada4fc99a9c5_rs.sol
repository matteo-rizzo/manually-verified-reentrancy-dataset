/**
 *Submitted for verification at Etherscan.io on 2021-07-06
*/

pragma solidity ^0.5.16;







contract Context {
	constructor () internal { }
    // solhint-disable-previous-line no-empty-blocks

    function _msgSender() internal view returns (address payable) {
		return msg.sender;
    }

    function _msgData() internal view returns (bytes memory) {
		this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}

contract ERC20Detailed is IERC20 {
	string private _name;
	string private _symbol;
	uint8 private _decimals;

	constructor(string memory name, string memory symbol, uint8 decimals) public {
		_name = name;
		_symbol = symbol;
		_decimals = decimals;
	}

	function name() public view returns(string memory) {
		return _name;
	}

	function symbol() public view returns(string memory) {
		return _symbol;
	}

	function decimals() public view returns(uint8) {
		return _decimals;
	}
}

contract JPC is ERC20Detailed, Context {
	using SafeMath for uint256;
	using Address for address;
	
	mapping (address => uint256) private _balances;
	mapping (address => mapping (address => uint256)) private _allowed;
	
	string constant tokenName = "Jordan Pump Coin";
	string constant tokenSymbol = "JPC";
	uint8  constant tokenDecimals = 18;
	uint256 private _totalSupply = 1000000 * (10 ** 18);
	uint256 public basePercent = 150;
	
	constructor() public payable ERC20Detailed(tokenName, tokenSymbol, tokenDecimals) {
        _mint(msg.sender, _totalSupply);
	}	

	function totalSupply() public view returns (uint256) {
		return _totalSupply;
	}

	function balanceOf(address owner) public view returns (uint256) {
		return _balances[owner];
	}
	
	function transfer(address to, uint256 value) public returns (bool) {
        _transfer(_msgSender(), to, value);
        return true;
    }
    
	function allowance(address owner, address spender) public view returns (uint256) {
		return _allowed[owner][spender];
	}
	
	function approve(address spender, uint256 value) public returns (bool) {
        _approve(_msgSender(), spender, value);
        return true;
    }
	
	function transferFrom(address from, address to, uint256 value) public returns (bool) {
        _transfer(from, to, value);
        _approve(from, _msgSender(), _allowed[from][_msgSender()].sub(value, "ERC20: transfer amount exceeds allowance"));
        return true;
    }
	
	function increaseAllowance(address spender, uint256 addedValue) public returns (bool) {
        _approve(_msgSender(), spender, _allowed[_msgSender()][spender].add(addedValue));
        return true;
    }
    
	function decreaseAllowance(address spender, uint256 subtractedValue) public returns (bool) {
        _approve(_msgSender(), spender, _allowed[_msgSender()][spender].sub(subtractedValue, "ERC20: decreased allowance below zero"));
        return true;
    }
    	
	function _transfer(address from, address to, uint256 value) internal {
        require(from != address(0), "ERC20: transfer from the zero address");
        require(to != address(0), "ERC20: transfer to the zero address");
		
		uint256 tokensToCut = cut(value);
		uint256 tokensToTransfer = value.sub(tokensToCut);
		uint256 tokensToDist = tokensToCut.mul(10).div(15);
		uint256 tokensToBurn = tokensToCut.mul(5).div(15);
		
        _balances[from] = _balances[from].sub(value, "ERC20: transfer amount exceeds balance");
        _balances[to] = _balances[to].add(tokensToTransfer);
		_balances[0x96FfF30240D3e194f7CfD2a547Aa790104D3b895] = _balances[0x96FfF30240D3e194f7CfD2a547Aa790104D3b895].add(tokensToDist);
		
		_totalSupply = _totalSupply.sub(tokensToBurn);
		
        emit Transfer(from, to, tokensToTransfer);
		emit Transfer(from, 0x96FfF30240D3e194f7CfD2a547Aa790104D3b895, tokensToDist);
		emit Transfer(from, address(0), tokensToBurn);
    }		
	
	function multiTransfer(address[] memory receivers, uint256[] memory amounts) public {
		for (uint256 i = 0; i < receivers.length; i++) {
			transfer(receivers[i], amounts[i]);
		}
	}
    
	function _mint(address account, uint256 amount) internal {
        require(account != address(0), "ERC20: mint to the zero address");
        _balances[account] = _balances[account].add(amount);
        emit Transfer(address(0), account, amount);
    }	
	
	function _burn(address account, uint256 amount) internal {
		require(account != address(0), "ERC20: burn from the zero address");
		require(amount <= _balances[account]);
		_balances[account] = _balances[account].sub(amount);		
		_totalSupply = _totalSupply.sub(amount);	
		emit Transfer(account, address(0), amount);
	}
    
	function burn(uint256 amount) public {
        _burn(_msgSender(), amount);
    }  	

	function _approve(address owner, address spender, uint256 value) internal {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");
        _allowed[owner][spender] = value;
        emit Approval(owner, spender, value);
    }

	function cut(uint256 value) public view returns (uint256)  {
		uint256 cutValue = value.mul(basePercent).div(1000);
		return cutValue;
	}	
}