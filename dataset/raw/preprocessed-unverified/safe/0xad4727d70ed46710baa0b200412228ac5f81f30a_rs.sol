/**
 *Submitted for verification at Etherscan.io on 2020-11-22
*/

pragma solidity ^0.6.12;


// ----------------------------------------------------------------------------
// Buffalo Finance NEXT GENERATION DEFLATIONARY DEFI PLATFORM
// Buffalo Finance is a useful, deflationary, next generation DeFi platform where users can easily stake, farm, lend/borrow, and swap crypto assets. Buffalo Finance Platform offers you a variety of facilities for keeping securely and managing your crypto assets, as well as high returns with advantageous rates for your assets.
// Symbol       : BUFF
// Name         : Buffalo Finance
// Total supply : 100,000
// www.buffalodefi.com
// www.twitter.com/buffalo_finance
// https://t.me/buffalofinanceann
// https://t.me/buffalofinance
// www.medium.com/@buffalofinance
// ----------------------------------------------------------------------------


abstract contract Context {
    function _msgSender() internal view virtual returns (address payable) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes memory) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}











contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    constructor () internal {
        address msgSender = _msgSender();
        _owner = msgSender;
        emit OwnershipTransferred(address(0), msgSender);
    }

    /**
     * @dev Returns the address of the current owner.
     */
    function owner() public view returns (address) {
        return _owner;
    }

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        require(_owner == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    /**
     * @dev Leaves the contract without owner. It will not be possible to call
     * `onlyOwner` functions anymore. Can only be called by the current owner.
     *
     * NOTE: Renouncing ownership will leave the contract without an owner,
     * thereby removing any functionality that is only available to the owner.
     */
    function renounceOwnership() public virtual onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}

contract Whitelist is Ownable {
    mapping(address => bool) whitelist;
    event AddedToWhitelist(address indexed account);
    event RemovedFromWhitelist(address indexed account);

    modifier onlyWhitelisted() {
        require(isWhitelisted(msg.sender));
        _;
    }

    function addToWhitelist(address _address) public onlyOwner {
        whitelist[_address] = true;
        emit AddedToWhitelist(_address);
    }

    function removeFromWhitelist(address _address) public onlyOwner {
        whitelist[_address] = false;
        emit RemovedFromWhitelist(_address);
    }

    function isWhitelisted(address _address) public view returns(bool) {
        return whitelist[_address];
    }
}


contract ERC20 is IERC20, Whitelist {
    using SafeMath for uint256;
    using Address for address;

    mapping (address => uint256) _balances;

    mapping (address => mapping (address => uint256)) _allowances;

    uint256 _totalSupply;
    uint256 INITIAL_SUPPLY = 100000e18; //available supply
    uint256 BURN_RATE = 1; //burn every per txn
	uint256 SUPPLY_FLOOR = 50; // % of supply
	uint256 DEFLATION_START_TIME = now + 30 days;

    string  _name;
    string  _symbol;
    uint8 _decimals;


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

        _beforeTokenTransfer(sender, recipient, amount);
        
		_balances[sender] = _balances[sender].sub(amount, "ERC20: transfer amount exceeds balance");
		
		if(now >= DEFLATION_START_TIME){
		    uint256 _burnedAmount = amount * BURN_RATE / 100;
    		if (_totalSupply - _burnedAmount < INITIAL_SUPPLY * SUPPLY_FLOOR / 100 || isWhitelisted(sender)) {
    			_burnedAmount = 0;
    		}
    		if (_burnedAmount > 0) {
    			_totalSupply = _totalSupply.sub(_burnedAmount);
    		}
    		amount = amount.sub(_burnedAmount);
		}
		
		_balances[recipient] = _balances[recipient].add(amount);
		
        emit Transfer(sender, recipient, amount);
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

    
    function _beforeTokenTransfer(address from, address to, uint256 amount) internal virtual { }
}


contract Token is ERC20{

// ----------------------------------------------------------------------------
// Buffalo Finance NEXT GENERATION DEFLATIONARY DEFI PLATFORM
// Buffalo Finance is a useful, deflationary, next generation DeFi platform where users can easily stake, farm, lend/borrow, and swap crypto assets. Buffalo Finance Platform offers you a variety of facilities for keeping securely and managing your crypto assets, as well as high returns with advantageous rates for your assets.
// Symbol       : BUFF
// Name         : Buffalo Finance
// Total supply : 100,000
// www.buffalodefi.com
// www.twitter.com/buffalo_finance
// https://t.me/buffalofinanceann
// https://t.me/buffalofinance
// www.medium.com/@buffalofinance
// ----------------------------------------------------------------------------

	constructor (string memory name, string memory symbol) public {
        _name = "Buffalo Finance";
        _symbol = "BUFF";
        _decimals = 18;
        _totalSupply = INITIAL_SUPPLY;
        _balances[msg.sender] = _balances[msg.sender].add(INITIAL_SUPPLY);
    }

	
}