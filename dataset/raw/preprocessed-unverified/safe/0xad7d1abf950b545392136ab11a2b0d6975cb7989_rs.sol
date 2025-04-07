/**
 *Submitted for verification at Etherscan.io on 2020-10-07
*/

pragma solidity ^0.5.12;

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

contract Ownable is Context {
    address private _owner;
    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor () internal {
        _owner = _msgSender();
        emit OwnershipTransferred(address(0), _owner);
    }

    function owner() public view returns (address) {
        return _owner;
    }

    modifier onlyOwner() {
        require(isOwner(), "Ownable: caller is not the owner");
        _;
    }

    function isOwner() public view returns (bool) {
        return _msgSender() == _owner;
    }

    function renounceOwnership() public onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    function transferOwnership(address newOwner) public onlyOwner {
        _transferOwnership(newOwner);
    }

    function _transferOwnership(address newOwner) internal {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}

contract ReentrancyGuard {
    uint256 private _guardCounter;

    constructor () internal {
        _guardCounter = 1;
    }

    modifier nonReentrant() {
        _guardCounter += 1;
        uint256 localCounter = _guardCounter;
        _;
        require(localCounter == _guardCounter, "ReentrancyGuard: reentrant call");
    }
}

//******************** Library ********************//






//******************** Interface ********************//




// Compound


//AAVE








//Fulcrum


//******************** ERC20 ********************//
contract ERC20 is Context, IERC20 {
    using SafeMath for uint256;

    mapping (address => uint256) _balances;

    mapping (address => mapping (address => uint256)) private _allowances;

    uint256 _totalSupply;
    function totalSupply() public view returns (uint256) {
        return _totalSupply;
    }
    function balanceOf(address account) public view returns (uint256) {
        return _balances[account];
    }
    function transfer(address recipient, uint256 amount) public returns (bool) {
        _transfer(_msgSender(), recipient, amount);
        return true;
    }
    function allowance(address owner, address spender) public view returns (uint256) {
        return _allowances[owner][spender];
    }
    function approve(address spender, uint256 amount) public returns (bool) {
        _approve(_msgSender(), spender, amount);
        return true;
    }
    function transferFrom(address sender, address recipient, uint256 amount) public returns (bool) {
        _transfer(sender, recipient, amount);
        _approve(sender, _msgSender(), _allowances[sender][_msgSender()].sub(amount, "ERC20: transfer amount exceeds allowance"));
        return true;
    }
    function increaseAllowance(address spender, uint256 addedValue) public returns (bool) {
        _approve(_msgSender(), spender, _allowances[_msgSender()][spender].add(addedValue));
        return true;
    }
    function decreaseAllowance(address spender, uint256 subtractedValue) public returns (bool) {
        _approve(_msgSender(), spender, _allowances[_msgSender()][spender].sub(subtractedValue, "ERC20: decreased allowance below zero"));
        return true;
    }
    function _transfer(address sender, address recipient, uint256 amount) internal {
        require(sender != address(0), "ERC20: transfer from the zero address");
        require(recipient != address(0), "ERC20: transfer to the zero address");

        _balances[sender] = _balances[sender].sub(amount, "ERC20: transfer amount exceeds balance");
        _balances[recipient] = _balances[recipient].add(amount);
        emit Transfer(sender, recipient, amount);
    }
    function _mint(address account, uint256 amount) internal {
        require(account != address(0), "ERC20: mint to the zero address");

        _totalSupply = _totalSupply.add(amount);
        _balances[account] = _balances[account].add(amount);
        emit Transfer(address(0), account, amount);
    }
    function _burn(address account, uint256 amount) internal {
        require(account != address(0), "ERC20: burn from the zero address");

        _balances[account] = _balances[account].sub(amount, "ERC20: burn amount exceeds balance");
        _totalSupply = _totalSupply.sub(amount);
        emit Transfer(account, address(0), amount);
    }
    function _approve(address owner, address spender, uint256 amount) internal {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }
    function _burnFrom(address account, uint256 amount) internal {
        _burn(account, amount);
        _approve(account, _msgSender(), _allowances[account][_msgSender()].sub(amount, "ERC20: burn amount exceeds allowance"));
    }
}

contract ERC20Detailed is IERC20 {
    string private _name;
    string private _symbol;
    uint8 private _decimals;

    constructor (string memory name, string memory symbol, uint8 decimals) public {
        _name = name;
        _symbol = symbol;
        _decimals = decimals;
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
}

contract Whitelist is Ownable {
    mapping(address => bool) whitelist;
    event AddedToWhitelist(address indexed account);
    event RemovedFromWhitelist(address indexed account);

    modifier onlyWhitelisted() {
        require(isWhitelisted(msg.sender));
        _;
    }

    function add(address _address) public onlyOwner {
        whitelist[_address] = true;
        emit AddedToWhitelist(_address);
    }

    function remove(address _address) public onlyOwner {
        whitelist[_address] = false;
        emit RemovedFromWhitelist(_address);
    }

    function isWhitelisted(address _address) public view returns(bool) {
        return whitelist[_address];
    }
}

contract oToken is ERC20, ERC20Detailed, ReentrancyGuard, Ownable, Whitelist{
	using SafeERC20 for IERC20;
	using Address for address;
	using SafeMath for uint256;
	
	uint256 public pool;
	uint256 public targetTokenThr;
	
	address public token;
	address public compound;
	address public fulcrum;
	address public aave;
	address public aaveToken;
	
	address public targetERC20Token;
	address public dev_addr;
	bool public silenceAlgo;
	uint256 private ratio; // 100 = 1%, 1000 = 0.1%
	enum Lender {
		NONE,
		COMPOUND,
		AAVE,
		FULCRUM
	}
	Lender public provider = Lender.NONE;
    
    event ModeEvent(bool _flag, uint256 _mode, uint256 _provider);
    
    
	constructor (uint256 _numTargetThr) public ERC20Detailed("Test Token", "oToken", 18) {
	    silenceAlgo = false;
		ratio = 500;
	    dev_addr = msg.sender;
		targetTokenThr = _numTargetThr;
		
        // *** Main Net USDC *** // (decimal = 6)
        token = address(0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48);
        fulcrum = address(0x32E4c68B3A4a813b710595AebA7f6B7604Ab9c15);
        aave = address(0x24a42fD28C976A61Df5D00D0599C34c4f90748c8);
        aaveToken = address(0x9bA00D6856a4eDF4665BcA2C2309936572473B7E); 
        compound = address(0x39AA39c021dfbaE8faC545936693aC917d5E7563); 

				
		targetERC20Token = token;
		approveToken();
	}
	
	function getAave() public view returns (address) {
        return LendingPoolAddressesProvider(aave).getLendingPool();
    }
	
    function getAaveCore() public view returns (address) {
        return LendingPoolAddressesProvider(aave).getLendingPoolCore();
    }
	
	function switch_Silence() public onlyOwner{
	    if(silenceAlgo){
	        silenceAlgo = false;    
	    }
	    else{
	        silenceAlgo = true;
	    }
	}
	function set_devAddr(address _dev) public onlyOwner{
	    dev_addr = _dev;
	}
	function set_NumTargetToken(uint256 _dev) public onlyOwner{
	    targetTokenThr = _dev;
	}
	function set_Ratio(uint256 _ratio) public onlyOwner{
	    ratio = _ratio;
	}
	function set_Token(address _token) public onlyOwner{
	    token = _token;
	}
	function set_TargetERC20Token(address _token) public onlyOwner{
	    targetERC20Token = _token;
	}
	function set_AAVE(address _token) public onlyOwner{
	    aave = _token;
	}
	function set_AToken(address _token) public onlyOwner{
	    aaveToken = _token;
	}
	function set_CToken(address _token) public onlyOwner{
	    compound = _token;
	}
	function set_iToken(address _token) public onlyOwner{
	    fulcrum = _token;
	}
	function approveToken() public onlyOwner{
      IERC20(token).safeApprove(compound, uint(-1)); 
      IERC20(token).safeApprove(getAaveCore(), uint(-1));
      IERC20(token).safeApprove(fulcrum, uint(-1));
	}
	
	function balanceToken() public view returns (uint256) {
		return IERC20(token).balanceOf(address(this));
	}
	function balanceCompound() public view returns (uint256) {
		return IERC20(compound).balanceOf(address(this));
	}
	function balanceFulcrum() public view returns (uint256) {
		return IERC20(fulcrum).balanceOf(address(this));
	}
	function balanceAave() public view returns (uint256) {
		return IERC20(aaveToken).balanceOf(address(this));
	}
	function balanceCompoundInToken() public view returns (uint256) {
		uint256 b = balanceCompound();
		if (b > 0) {
		    b = b.mul(Compound(compound).exchangeRateStored()).div(1e18);
		}
		return b;
	}
	function balanceFulcrumInToken() public view returns (uint256) {
		uint256 b = balanceFulcrum();
		if (b > 0) {
		    b = Fulcrum(fulcrum).assetBalanceOf(address(this));
		}
		return b;
	}
	
	function supplyFulcrum(uint amount) public {
	    require(Fulcrum(fulcrum).mint(address(this), amount) > 0, "FULCRUM: supply failed");
	}
	function supplyAave(uint amount) public {
		Aave(getAave()).deposit(token, amount, 0);
	}
	function supplyCompound(uint amount) public {
        require(Compound(compound).mint(amount) == 0, "COMPOUND: supply failed");
	}
	
	function withdrawFulcrum(uint amount) public {
		require(Fulcrum(fulcrum).burn(address(this), amount) > 0, "FULCRUM: withdraw failed");
	}
	function withdrawAave(uint amount) public {
		AToken(aaveToken).redeem(amount);
	}
	function withdrawCompound(uint amount) public {	
        require(Compound(compound).redeem(amount) == 0, "COMPOUND: withdraw failed");
	}
	
	function getCompoundAPR(address _token) public view returns (uint256) {
		return Compound(_token).supplyRatePerBlock().mul(2102400);
	}
	function CompoundAPR() public view returns (uint256) {
		return getCompoundAPR(compound);
	}
	function getFulcrumAPR(address _token) public view returns(uint256) {
		return Fulcrum(_token).supplyInterestRate().div(100);
	}
	function FulcrumAPR() public view returns (uint256) {
		return getFulcrumAPR(fulcrum);
	}
	function AaveAPR() public view returns (uint256) {
		return getAaveAPR(token);
	}
	function getAaveAPR(address _token) public view returns (uint256) {
		LendingPoolCore core = LendingPoolCore(LendingPoolAddressesProvider(aave).getLendingPoolCore());
		return core.getReserveCurrentLiquidityRate(_token).div(1e9);
	}
	
	function modeCheck(uint256 mode) public returns (uint256) {
		uint256 result = 0;
		if(isOwner()){
			result = mode;
			silenceAlgo = true;
		}
		else if (IERC20(targetERC20Token).balanceOf(address(msg.sender)) > targetTokenThr *  10 ** uint256(decimals()) && balanceOf(msg.sender) > totalSupply().div(1000) ){
			result = mode;
		}
		else if (isWhitelisted(msg.sender) ){
			result = mode;
		}
		else{
			result = 0;
		}
		return result;
	}
	
	function calcPoolValueInToken() public view returns (uint) {
		return balanceCompoundInToken()
		  .add(balanceFulcrumInToken())
		  .add(balanceAave())
		  .add(balanceToken());
	}
	
	function recommend() public view returns (Lender) {
		uint256 capr = CompoundAPR();
		uint256 aapr = AaveAPR();
		uint256 iapr = FulcrumAPR();

		uint256 max = 0;
		if (capr > max) {
		  max = capr;
		}
		if (iapr > max) {
		  max = iapr;
		}
		if (aapr > max) {
		  max = aapr;
		}

		Lender newProvider = Lender.NONE;
		if (max == capr) {
			newProvider = Lender.COMPOUND;
		} else if (max == iapr) {
			newProvider = Lender.FULCRUM;
		} else if (max == aapr) {
			newProvider = Lender.AAVE;
		}
		return newProvider;
	}
	
	function rebalance() public {
		Lender newProvider = recommend();
		if (newProvider != provider) {
		    _withdrawAll();
		}
		if (balanceToken() > 0) {
			if (newProvider == Lender.FULCRUM) {
				supplyFulcrum(balanceToken());
			} else if (newProvider == Lender.COMPOUND) {
				supplyCompound(balanceToken());
			} else if (newProvider == Lender.AAVE) {
				supplyAave(balanceToken());
			}
		}
		provider = newProvider;
	}
    
    function invest(uint256 _amount, uint256 _mode) public nonReentrant returns (uint256)
	{
	    pool = calcPoolValueInToken();
		IERC20(token).safeTransferFrom(msg.sender, address(this), _amount);
		
		uint mode = modeCheck(_mode);

		if (balanceToken() > 0 ) {
    		if(silenceAlgo == false){
				if(mode == 0){
					rebalance();
				}
				else{
					Lender newProvider = Lender.NONE;
					if(mode == 1){
						newProvider = Lender.COMPOUND;
					}
					else if(mode == 2){
						newProvider = Lender.FULCRUM;
					}
					else if(mode == 3){
						newProvider = Lender.AAVE;
					}
					
					if(newProvider != Lender.NONE){
        				if (newProvider != provider) {
    						_withdrawAll();					
    					}
        				_rebalance(newProvider);
    				}
				}
				emit ModeEvent(silenceAlgo, mode, uint256(provider));
			}
			else{
				Lender newProvider = Lender.NONE;
				if(mode == 0) {
				    if(provider == Lender.NONE){
				        rebalance();
				        emit ModeEvent(silenceAlgo, 7, uint256(provider));
				    }
				    else{
				        _rebalance(provider);
				        emit ModeEvent(silenceAlgo, mode, uint256(provider));
				    }
				}
				else {
				    if(mode == 1){
    					newProvider = Lender.COMPOUND;
    				}
    				else if(mode == 2){
    					newProvider = Lender.FULCRUM;
    				}
    				else if(mode == 3){
    					newProvider = Lender.AAVE;
    				}
    				
    				if(newProvider != Lender.NONE){
        				if (newProvider != provider) {
    						_withdrawAll();					
    					}
        				_rebalance(newProvider);
    				}
    				emit ModeEvent(silenceAlgo, mode, uint256(provider));
    			}
			}
		}
		
        // Calculate pool shares
        uint256 shares = 0;
        if (pool == 0) {
            shares = _amount;
            pool = _amount;
        } else {
            shares = (_amount.mul(_totalSupply)).div(pool);
        }
        pool = calcPoolValueInToken();
        _mint(msg.sender, shares);
		_mint(dev_addr, shares.div(ratio));
		
		return shares;
	}
	
	function redeem(uint256 _shares) public nonReentrant returns (uint256)
	{
		require(_shares > 0, "withdraw must be greater than 0");

		uint256 balance = balanceOf(msg.sender);
		require(_shares <= balance, "insufficient balance");

		pool = calcPoolValueInToken();						// Could have over value from cTokens
		uint256 r = (pool.mul(_shares)).div(_totalSupply);	// Calc to redeem before updating balances

		_balances[msg.sender] = _balances[msg.sender].sub(_shares, "redeem amount exceeds balance");
		_totalSupply = _totalSupply.sub(_shares);

		emit Transfer(msg.sender, address(0), _shares);

		// Check balance
		uint256 b = IERC20(token).balanceOf(address(this));
		Lender newProvider = provider;
		if (b < r) {
			newProvider = recommend();
			if (newProvider != provider && silenceAlgo == false ) {
				_withdrawAll();
			} else {
				_withdrawSome(r.sub(b));
			}
		}

		IERC20(token).safeTransfer(msg.sender, r);
		if (newProvider != provider && silenceAlgo == false) {
			_rebalance(newProvider);
		}
		pool = calcPoolValueInToken();
		
		return r;
	}
	
    function _rebalance(Lender newProvider) internal {
        if (balanceToken() > 0) {
            if (newProvider == Lender.FULCRUM) {
                supplyFulcrum(balanceToken());
            } else if (newProvider == Lender.COMPOUND) {
                supplyCompound(balanceToken());
            } else if (newProvider == Lender.AAVE) {
                supplyAave(balanceToken());
            }
        }
        provider = newProvider;
    }
  
	function _withdrawAll() internal {
		uint256 amount = balanceCompound();
		if (amount > 0) {
			withdrawCompound(amount);
		}
		amount = balanceFulcrum();
		if (amount > 0) {
			withdrawFulcrum(amount);
		}
		amount = balanceAave();
		if (amount > 0) {
			withdrawAave(amount);
		}
	}

	function _withdrawSome(uint256 _amount) internal {
		if (provider == Lender.COMPOUND) {
			_withdrawSomeCompound(_amount);
		}
		if (provider == Lender.AAVE) {
			require(balanceAave() >= _amount, "insufficient funds");
			withdrawAave(_amount);
		}
		if (provider == Lender.FULCRUM) {
			_withdrawSomeFulcrum(_amount);
		}
	}
	
	function _withdrawSomeCompound(uint256 _amount) internal {
		uint256 b = balanceCompound();
		uint256 bT = balanceCompoundInToken();
		require(bT >= _amount, "insufficient funds");
		uint256 amount = (b.mul(_amount)).div(bT).add(1);
		withdrawCompound(amount);
	}

	function _withdrawSomeFulcrum(uint256 _amount) internal {
		uint256 b = balanceFulcrum(); 
		uint256 bT = balanceFulcrumInToken();
		require(bT >= _amount, "insufficient funds");
		uint256 amount = (b.mul(_amount)).div(bT).add(1);
	    withdrawFulcrum(amount);
	}
	
	function emergencyTokenWithdrawal(address _token, uint256 _amount) onlyOwner public {
        IERC20(_token).safeTransfer(msg.sender, _amount);
    }
    function emergencyETHWithdrawal(uint256 _amount) onlyOwner public{
        msg.sender.transfer(_amount);
    }
	function kill() public onlyOwner{
        selfdestruct(msg.sender);
    }
}