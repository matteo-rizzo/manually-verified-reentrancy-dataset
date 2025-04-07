/**
 *Submitted for verification at Etherscan.io on 2021-09-14
*/

/*
   ___             _            _       ______            ______
  / _ )___ ___    (_)__ ___ _  (_)__   /_  __/__  ___    / __/ /____ _____
 / _  / -_) _ \  / / _ `/  ' \/ / _ \   / / / _ \/ _ \  _\ \/ __/ _ `/ __/
/____/\__/_//_/_/ /\_,_/_/_/_/_/_//_/  /_/  \___/ .__/ /___/\__/\_,_/_/
             |___/                              /_/

BTS : Benjamin Top Star
SPDX-License-Identifier: MIT
*/

pragma solidity ^0.8.0;





abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}

abstract contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor() {
        _setOwner(_msgSender());
    }

    function owner() public view virtual returns (address) {
        return _owner;
    }

    modifier onlyOwner() {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    function renounceOwnership() public virtual onlyOwner {
        _setOwner(address(0));
    }

    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        _setOwner(newOwner);
    }

    function _setOwner(address newOwner) private {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
}

abstract contract Pausable is Context {
    event Paused(address account);

    event Unpaused(address account);

    bool private _paused;

    constructor() {
        _paused = false;
    }

    function paused() public view virtual returns (bool) {
        return _paused;
    }

    modifier whenNotPaused() {
        require(!paused(), "Pausable: paused");
        _;
    }

    modifier whenPaused() {
        require(paused(), "Pausable: not paused");
        _;
    }

    function _pause() internal virtual whenNotPaused {
        _paused = true;
        emit Paused(_msgSender());
    }

    function _unpause() internal virtual whenPaused {
        _paused = false;
        emit Unpaused(_msgSender());
    }
}



interface IERC20Metadata is IERC20 {
    function name() external view returns (string memory);

    function symbol() external view returns (string memory);

    function decimals() external view returns (uint8);
}

contract ERC20 is Context, IERC20, IERC20Metadata {
    mapping(address => uint256) private _balances;

    mapping(address => mapping(address => uint256)) private _allowances;

    uint256 private _totalSupply;

    string private _name;
    string private _symbol;

    constructor(string memory name_, string memory symbol_) {
        _name = name_;
        _symbol = symbol_;
    }

    function name() public view virtual override returns (string memory) {
        return _name;
    }

    function symbol() public view virtual override returns (string memory) {
        return _symbol;
    }

    function decimals() public view virtual override returns (uint8) {
        return 18;
    }

    function totalSupply() public view virtual override returns (uint256) {
        return _totalSupply;
    }

    function balanceOf(address account) public view virtual override returns (uint256) {
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

    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) public virtual override returns (bool) {
        _transfer(sender, recipient, amount);

        uint256 currentAllowance = _allowances[sender][_msgSender()];
        require(currentAllowance >= amount, "ERC20: transfer amount exceeds allowance");
        unchecked {
            _approve(sender, _msgSender(), currentAllowance - amount);
        }

        return true;
    }

    function increaseAllowance(address spender, uint256 addedValue) public virtual returns (bool) {
        _approve(_msgSender(), spender, _allowances[_msgSender()][spender] + addedValue);
        return true;
    }

    function decreaseAllowance(address spender, uint256 subtractedValue) public virtual returns (bool) {
        uint256 currentAllowance = _allowances[_msgSender()][spender];
        require(currentAllowance >= subtractedValue, "ERC20: decreased allowance below zero");
        unchecked {
            _approve(_msgSender(), spender, currentAllowance - subtractedValue);
        }

        return true;
    }

    function _transfer(
        address sender,
        address recipient,
        uint256 amount
    ) internal virtual {
        require(sender != address(0), "ERC20: transfer from the zero address");
        require(recipient != address(0), "ERC20: transfer to the zero address");

        _beforeTokenTransfer(sender, recipient, amount);

        uint256 senderBalance = _balances[sender];
        require(senderBalance >= amount, "ERC20: transfer amount exceeds balance");
        unchecked {
            _balances[sender] = senderBalance - amount;
        }
        _balances[recipient] += amount;

        emit Transfer(sender, recipient, amount);

        _afterTokenTransfer(sender, recipient, amount);
    }

    function _mint(address account, uint256 amount) internal virtual {
        require(account != address(0), "ERC20: mint to the zero address");

        _beforeTokenTransfer(address(0), account, amount);

        _totalSupply += amount;
        _balances[account] += amount;
        emit Transfer(address(0), account, amount);

        _afterTokenTransfer(address(0), account, amount);
    }

    function _burn(address account, uint256 amount) internal virtual {
        require(account != address(0), "ERC20: burn from the zero address");

        _beforeTokenTransfer(account, address(0), amount);

        uint256 accountBalance = _balances[account];
        require(accountBalance >= amount, "ERC20: burn amount exceeds balance");
        unchecked {
            _balances[account] = accountBalance - amount;
        }
        _totalSupply -= amount;

        emit Transfer(account, address(0), amount);

        _afterTokenTransfer(account, address(0), amount);
    }

    function _approve(
        address owner,
        address spender,
        uint256 amount
    ) internal virtual {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual {}

    function _afterTokenTransfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual {}
}

abstract contract ERC20Pausable is ERC20, Pausable {
    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual override {
        super._beforeTokenTransfer(from, to, amount);

        require(!paused(), "ERC20Pausable: token transfer while paused");
    }
}

contract BenjaminTopStar is ERC20Pausable, Ownable {
	uint8 private DECIMALS = 8;
	uint256 private MAX_TOKEN_COUNT = 10000000000;
	uint256 private INITIAL_SUPPLY = MAX_TOKEN_COUNT * (10 ** uint256(DECIMALS));
	
	mapping (address => uint256) public airDropHistory;
	event AirDrop(address _recipient, uint256 _amount);
	
	mapping (address => uint256) private lockedBalances;
	event TimeLock(address _recipient, uint256 _amount);
	uint256 private unlocktime;
	
	constructor()
	ERC20("BenjaminTopStar", "BTS")
	public {
		super._mint(msg.sender, INITIAL_SUPPLY);
		unlocktime = 1656633600;    // 2022/07/01 09:00:00 GMT+09:00
	}
	
	function decimals() public view virtual override returns (uint8) {
		return DECIMALS;
	}

	modifier timeLock(address from, uint256 amount) { 
		if(block.timestamp < unlocktime) {
			require(amount <= balanceOf(from) - lockedBalances[from]);
		} else {
			lockedBalances[from] = 0;
		}
		_;
	}
	
	function unLockTime() public view returns (uint256) {
		return unlocktime;
	}
	
	function setUnLockTime(uint256 _unlocktime) onlyOwner public {
		unlocktime = _unlocktime;
	}
	
	function transfer(address recipient, uint256 amount) timeLock(msg.sender, amount) whenNotPaused public virtual override returns (bool) {
		return super.transfer(recipient, amount);
	}
	
	function transfers(address[] memory recipients, uint256[] memory values) whenNotPaused public {
		require(recipients.length != 0);
		require(recipients.length == values.length);
		
		for(uint256 i = 0; i < recipients.length; i++) {
			address recipient = recipients[i];
			uint256 amount = values[i];
			
			transfer(recipient, amount);
		}
	}
	
	function transferToLockedBalance(address recipient, uint256 amount) whenNotPaused public returns (bool) {
		if(transfer(recipient, amount)) {
			lockedBalances[recipient] += amount;
			
			emit TimeLock(recipient, lockedBalances[recipient]);
			
			return true;
		}
	}
	
	function transferToLockedBalances(address[] memory recipients, uint256[] memory values) whenNotPaused public {
		require(recipients.length != 0);
		require(recipients.length == values.length);
		
		for(uint256 i = 0; i < recipients.length; i++) {
			address recipient = recipients[i];
			uint256 amount = values[i];
			
			transferToLockedBalance(recipient, amount);
		}
	}

	function transferFrom(address _from, address recipient, uint256 amount) timeLock(_from, amount) whenNotPaused public virtual override returns (bool) {
		return super.transferFrom(_from, recipient, amount);
	} 
	
	function lockedBalance(address recipient) public view returns (uint256) {
		return lockedBalances[recipient];
	}
	
	function setLockedBalance(address recipient, uint256 amount) onlyOwner public {
		require(amount >= 0);
		require(balanceOf(recipient) >= amount);

		lockedBalances[recipient] = amount;

		emit TimeLock(recipient, lockedBalances[recipient]);
	}

	function setLockedBalances(address[] memory recipients, uint256[] memory values) onlyOwner public {
		require(recipients.length != 0);
		require(recipients.length == values.length);

		for(uint256 i = 0; i < recipients.length; i++) {
			address recipient = recipients[i];
			uint256 amount = values[i];
			
			if(amount >= 0 && balanceOf(recipient) >= amount) {
				setLockedBalance(recipient, amount);
			}
		}
	}

	function airDropToLockedBalances(address[] memory recipients, uint256[] memory values) whenNotPaused public {
		require(recipients.length != 0);
		require(recipients.length == values.length);
		
		for(uint256 i = 0; i < recipients.length; i++) {
			address recipient = recipients[i];
			uint256 amount = values[i];
			
			transferToLockedBalance(recipient, amount);
			airDropHistory[recipient] += amount;
			
			emit AirDrop(recipient, amount);
		}
	}
	
	function pause() onlyOwner whenNotPaused public {
		super._pause();
	}
	
	function unpause() onlyOwner whenPaused public {
		super._unpause();
	}
}