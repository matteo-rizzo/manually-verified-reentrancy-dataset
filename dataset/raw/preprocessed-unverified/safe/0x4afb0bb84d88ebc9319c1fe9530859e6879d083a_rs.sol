/**
 *Submitted for verification at Etherscan.io on 2020-11-29
*/

pragma solidity 0.6.7;











interface IUniswapV2Router02 is IUniswapV2Router01 {
  function removeLiquidityETHSupportingFeeOnTransferTokens(
    address token,
    uint256 liquidity,
    uint256 amountTokenMin,
    uint256 amountETHMin,
    address to,
    uint256 deadline
  ) external returns (uint256 amountETH);

  function removeLiquidityETHWithPermitSupportingFeeOnTransferTokens(
    address token,
    uint256 liquidity,
    uint256 amountTokenMin,
    uint256 amountETHMin,
    address to,
    uint256 deadline,
    bool approveMax,
    uint8 v,
    bytes32 r,
    bytes32 s
  ) external returns (uint256 amountETH);

  function swapExactTokensForTokensSupportingFeeOnTransferTokens(
    uint256 amountIn,
    uint256 amountOutMin,
    address[] calldata path,
    address to,
    uint256 deadline
  ) external;

  function swapExactETHForTokensSupportingFeeOnTransferTokens(
    uint256 amountOutMin,
    address[] calldata path,
    address to,
    uint256 deadline
  ) external payable;

  function swapExactTokensForETHSupportingFeeOnTransferTokens(
    uint256 amountIn,
    uint256 amountOutMin,
    address[] calldata path,
    address to,
    uint256 deadline
  ) external;
}


abstract contract Context {
    function _msgSender() internal view virtual returns (address payable) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes memory) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}


contract ERC20 is IERC20 {
  using SafeMath for uint256;

  mapping(address => uint256) private _balances;

  mapping(address => mapping(address => uint256)) private _allowances;

  uint256 private _totalSupply;

  string private _name;
  string private _symbol;
  uint8 private _decimals;

  /**
   * @dev Sets the values for {name} and {symbol}, initializes {decimals} with
   * a default value of 18.
   *
   * To select a different value for {decimals}, use {_setupDecimals}.
   *
   * All three of these values are immutable: they can only be set once during
   * construction.
   */
  constructor(string memory name, string memory symbol) public {
    _name = name;
    _symbol = symbol;
    _decimals = 18;
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
  function totalSupply() public override view returns (uint256) {
    return _totalSupply;
  }

  /**
   * @dev See {IERC20-balanceOf}.
   */
  function balanceOf(address account) public override view returns (uint256) {
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
  function transfer(address recipient, uint256 amount)
    public
    override
    returns (bool)
  {
    _transfer(msg.sender, recipient, amount);
    return true;
  }

  /**
   * @dev See {IERC20-allowance}.
   */
  function allowance(address owner, address spender)
    public
    override
    view
    returns (uint256)
  {
    return _allowances[owner][spender];
  }

  /**
   * @dev See {IERC20-approve}.
   *
   * Requirements:
   *
   * - `spender` cannot be the zero address.
   */
  function approve(address spender, uint256 amount)
    public
    override
    returns (bool)
  {
    _approve(msg.sender, spender, amount);
    return true;
  }

  /**
   * @dev See {IERC20-transferFrom}.
   *
   * Emits an {Approval} event indicating the updated allowance. This is not
   * required by the EIP. See the note at the beginning of {ERC20};
   *
   * Requirements:
   * - `sender` and `recipient` cannot be the zero address.
   * - `sender` must have a balance of at least `amount`.
   * - the caller must have allowance for ``sender``'s tokens of at least
   * `amount`.
   */
  function transferFrom(
    address sender,
    address recipient,
    uint256 amount
  ) public virtual override returns (bool) {
    _transfer(sender, recipient, amount);
    _approve(
      sender,
      msg.sender,
      _allowances[sender][msg.sender].sub(
        amount,
        'ERC20: transfer amount exceeds allowance'
      )
    );
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
  function increaseAllowance(address spender, uint256 addedValue)
    public
    returns (bool)
  {
    _approve(
      msg.sender,
      spender,
      _allowances[msg.sender][spender].add(addedValue)
    );
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
  function decreaseAllowance(address spender, uint256 subtractedValue)
    public
    virtual
    returns (bool)
  {
    _approve(
      msg.sender,
      spender,
      _allowances[msg.sender][spender].sub(
        subtractedValue,
        'ERC20: decreased allowance below zero'
      )
    );
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
  function _transfer(
    address sender,
    address recipient,
    uint256 amount
  ) internal virtual {
    require(sender != address(0), 'ERC20: transfer from the zero address');
    require(recipient != address(0), 'ERC20: transfer to the zero address');
    _balances[sender] = _balances[sender].sub(
      amount,
      'ERC20: transfer amount exceeds balance'
    );
    _balances[recipient] = _balances[recipient].add(amount);
    emit Transfer(sender, recipient, amount);
  }

  /** @dev Creates `amount` tokens and assigns them to `account`, increasing
   * the total supply.
   *
   * Emits a {Transfer} event with `from` set to the zero address.
   *
   * Requirements
   *
   * - `to` cannot be the zero address.
   */
  function _mint(address account, uint256 amount) internal virtual {
    require(account != address(0), 'ERC20: mint to the zero address');
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
   * Requirements
   *
   * - `account` cannot be the zero address.
   * - `account` must have at least `amount` tokens.
   */
  function _burn(address account, uint256 amount) internal virtual {
    require(account != address(0), 'ERC20: burn from the zero address');
    _balances[account] = _balances[account].sub(
      amount,
      'ERC20: burn amount exceeds balance'
    );
    _totalSupply = _totalSupply.sub(amount);
    emit Transfer(account, address(0), amount);
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
  function _approve(
    address owner,
    address spender,
    uint256 amount
  ) internal virtual {
    require(owner != address(0), 'ERC20: approve from the zero address');
    require(spender != address(0), 'ERC20: approve to the zero address');

    _allowances[owner][spender] = amount;
    emit Approval(owner, spender, amount);
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


contract Token is IERC20, Ownable {
    using SafeMath for uint256;
    
    
    struct Challenger {
        uint256 acceptance;
        uint256 challenge;
    }
    
    uint256 private constant _BASE = 1 * _DECIMALFACTOR;
    uint32  private constant _TERM = 5 minutes;
    
    uint256 private _prizes;
    uint256 private _challenges;
    
    mapping (address => Challenger) private _challengers;
    
    string  private constant _NAME = "Gauntlet Finance";
    string  private constant _SYMBOL = "GFI";
    uint8   private constant _DECIMALS = 18;
    
    uint256 private constant _DECIMALFACTOR = 10 ** uint256(_DECIMALS);
    
    uint8   private constant _DENOMINATOR = 100;
    uint8   private constant _PRECISION   = 100;

    mapping (address => uint256) private _balances;
    mapping (address => mapping (address => uint256)) private _allowances;
    
    uint256 private _totalSupply; 

    uint256 private immutable _rate;
    uint8   private immutable _penalty;
    uint256 private immutable _requirement;
    
    uint256 private immutable _initialSupply;

    uint256 private _contributors;

    bool    private _paused;
    address private _TDE;
    

    event Penalized(
        address indexed account,
        uint256 amount);
    
    event Boosted(
        address indexed account,
        uint256 amount);
    
    event Deflated(
        uint256 supply,
        uint256 amount);
    
    event Recovered(
        uint256 supply,
        uint256 amount);
    
    event Added(
        address indexed account,
        uint256 time);
        
    event Removed(
        address indexed account,
        uint256 time);
    
    event Accepted(
        address indexed account,
        uint256 amount);

    event Rewarded(
        address indexed account,
        uint256 amount);
    
    event Forfeited(
        address indexed account,
        uint256 amount);
        
    event Unpaused(
        address indexed account,
        uint256 time); 
    
    
    constructor (
        uint256 rate, 
        uint8   penalty,
        uint256 requirement) 
        public {
            
        require(rate > 0, 
        "error: must be larger than zero");
        require(penalty > 0, 
        "error: must be larger than zero");
        require(requirement > 0, 
        "error: must be larger than zero");
            
        _rate = rate;
        _penalty = penalty;
        _requirement = requirement;
        
        uint256 prizes = 10000 * _DECIMALFACTOR;
        uint256 capacity = 25000 * _DECIMALFACTOR;
        uint256 operations = 65000 * _DECIMALFACTOR;

        _mint(_environment(), prizes.add(capacity));
        _mint(_msgSender(), operations);
        
        _prizes = prizes;
        _initialSupply = prizes.add(capacity).add(operations);
        
        _paused = true;
    }
    

    function setTokenDistributionEvent(address TDE) external onlyOwner returns (bool) {
        require(TDE != address(0), 
        "error: must not be the zero address");
        
        require(_TDE == address(0), 
        "error: must not be set already");
    
        _TDE = TDE;
        return true;
    }
    function unpause() external returns (bool) {
        address account = _msgSender();
        
        require(account == owner() || account == _TDE, 
        "error: must be owner or must be token distribution event");

        _paused = false;
        
        emit Unpaused(account, _time());
        return true;
    }
    
    function reward() external returns (bool) {
        uint256 prizes = getPrizesTotal();
        
        require(prizes > 0, 
        "error: must be prizes available");
        
        address account = _msgSender();
        
        require(getReward(account) > 0, 
        "error: must be worthy of a reward");
        
        uint256 amount = getReward(account);
        
        if (_isExcessive(amount, prizes)) {
            
            uint256 excess = amount.sub(prizes);
            amount = amount.sub(excess);
            
            _challengers[account].acceptance = _time();
            _prizes = _prizes.sub(amount);
            _mint(account, amount);
            emit Rewarded(account, amount);
            
        } else {
            _challengers[account].acceptance = _time();
            _prizes = _prizes.sub(amount);
            _mint(account, amount);
            emit Rewarded(account, amount);
        }
        return true;
    }
    function challenge(uint256 amount) external returns (bool) {
        address account = _msgSender();
        uint256 processed = amount.mul(_DECIMALFACTOR);
        
        require(_isEligible(account, processed), 
        "error: must have sufficient holdings");
        
        require(_isContributor(account), 
        "error: must be a contributor");
        
        require(_isAcceptable(processed), 
        "error: must comply with requirement");
        
        _challengers[account].acceptance = _time();
        _challengers[account].challenge = processed;
        
        _challenges = _challenges.add(processed);
        
        emit Accepted(account, processed);
        return true;
    }
    
    function getTerm() public pure returns (uint256) {
        return _TERM;
    }
    function getBase() public pure returns (uint256) {
        return _BASE;
    }
    
    function getAcceptance(address account) public view returns (uint256) {
        return _challengers[account].acceptance;
    }
    function getPeriod(address account) public view returns (uint256) {
        if (getAcceptance(account) > 0) {
            
            uint256 period = _time().sub(_challengers[account].acceptance);
            uint256 term = getTerm();
            
            if (period >= term) {
                return period.div(term);
            } else {
                return 0;
            }
            
        } else { 
            return 0;
        }
    }
    
    function getChallenge(address account) public view returns (uint256) {
        return _challengers[account].challenge;
    }
    function getFerocity(address account) public view returns (uint256) {
        return (getChallenge(account).mul(_PRECISION)).div(getRequirement());
    }
    function getReward(address account) public view returns (uint256) {
       return _getBlock(account).mul((_BASE.mul(getFerocity(account))).div(_PRECISION));
    } 
    
    function getPrizesTotal() public view returns (uint256) {
        return _prizes;
    }
    function getChallengesTotal() public view returns (uint256) {
        return _challenges;
    }   
    
    function getRate() public view returns (uint256) {
        return _rate;
    }
    function getPenalty() public view returns (uint8) {
        return _penalty;
    }
    function getRequirement() public view returns (uint256) {
        return _requirement;
    }

    function getCapacity() public view returns (uint256) {
        return balanceOf(_environment()).sub(getPrizesTotal());
    }
    
    function getContributorsTotal() public view returns (uint256) {
        return _contributors;
    }
    function getContributorsLimit() public view returns (uint256) {
        return getCapacity().div(getRate());
    }

    function name() public pure returns (string memory) {
        return _NAME;
    }
    function symbol() public pure returns (string memory) {
        return _SYMBOL;
    }
    function decimals() public pure returns (uint8) {
        return _DECIMALS;
    }

    function totalSupply() public view override returns (uint256) {
        return _totalSupply;
    }
    function initialSupply() public view returns (uint256) {
        return _initialSupply;
    }
    
    function balanceOf(address account) public view override returns (uint256) {
        return _balances[account];
    }

    function allowance(address owner, address spender) public view virtual override returns (uint256) {
        return _allowances[owner][spender];
    }
    function approve(address spender, uint256 amount) public virtual override returns (bool) {
        _approve(_msgSender(), spender, amount);
        return true;
    }

    function transfer(address recipient, uint256 amount) public virtual override returns (bool) {
        address sender = _msgSender();

        require(_isNotPaused() || recipient == _TDE || sender == _TDE, 
        "error: must not be paused else must be token distribution event recipient or sender");

        _checkReactiveness(sender, recipient, amount);
        _checkChallenger(sender, amount);
        
        _transfer(sender, recipient, amount);

        return true;
    }
    function transferFrom(address sender, address recipient, uint256 amount) public virtual override returns (bool) {
        require(_isNotPaused() || recipient == _TDE || sender == _TDE, 
        "error: must not be paused else must be token distribution event recipient or sender");
        
        _checkReactiveness(sender, recipient, amount);
        _checkChallenger(sender, amount);
        
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
        
        if (sender == owner() && recipient == _TDE || sender == _TDE) {
            _balances[sender] = _balances[sender].sub(amount, "ERC20: transfer amount exceeds balance");
            _balances[recipient] = _balances[recipient].add(amount);
            
            emit Transfer(sender, recipient, amount);
            
        } else {
            uint256 penalty = _computePenalty(amount);
            _penalize(penalty);
            
            uint256 boosted = penalty.div(4);
            _boost(boosted);
            
            uint256 prize = penalty.div(4);
            _prize(prize);
            
            uint256 processed = amount.sub(penalty);
            _balances[sender] = _balances[sender].sub(processed, "ERC20: transfer amount exceeds balance");
            _balances[recipient] = _balances[recipient].add(processed);
            
            emit Transfer(sender, recipient, processed);
        }
    }

    function _mint(address account, uint256 amount) internal virtual {
        require(account != address(0), "ERC20: mint to the zero address");

        _totalSupply = _totalSupply.add(amount);
        _balances[account] = _balances[account].add(amount);
        
        emit Transfer(address(0), account, amount);
    }
    function _burn(address account, uint256 amount) internal virtual {
        require(account != address(0), "ERC20: burn from the zero address");

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
    
    function _penalize(uint256 amount) private returns (bool) {
        address account = _msgSender();
        _burn(account, amount);
        emit Penalized(account, amount);
        return true;
    }
    function _boost(uint256 amount) private returns (bool) {
        _mint(_environment(), amount);
        emit Boosted(_environment(), amount);
        return true;
    }
    function _prize(uint256 amount) private returns (bool) {
        _mint(_environment(), amount);
        emit Rewarded(_environment(), amount);
        return true;
    }
    
    function _checkReactiveness(address sender, address recipient, uint256 amount) private {
        if (_isUnique(recipient)) {
            if (_isCompliant(recipient, amount)) {
                _addContributor(recipient);
                if(_isElastic()) {
                    _deflate();
                }
            }
        }
        if (_isNotUnique(sender)) {
            if (_isNotCompliant(sender, amount)) {
                _removeContributor(sender);
                if(_isElastic()) {
                    _recover();
                }
            }
        }
    }
    function _checkChallenger(address account, uint256 amount) private {
        if (_isChallenger(account)) {
            if (balanceOf(account).sub(amount) < getChallenge(account)) {
                
                uint256 challenged = getChallenge(account);
                _challenges = _challenges.sub(challenged);
                
                delete _challengers[account].acceptance;
                delete _challengers[account].challenge;
                
                emit Forfeited(account, challenged);
            }
        }
    }    
    
    function _deflate() private returns (bool) {
        uint256 amount = getRate();
        _burn(_environment(), amount);
        emit Deflated(totalSupply(), amount);
        return true;
        
    }
    function _recover() private returns (bool) {
        uint256 amount = getRate();
        _mint(_environment(), amount);
        emit Recovered(totalSupply(), amount);
        return true;
    }
    
    function _addContributor(address account) private returns (bool) {
        _contributors++;
        emit Added(account, _time());
        return true;
    } 
    function _removeContributor(address account) private returns (bool) {
        _contributors--;
        emit Removed(account, _time());
        return true;
    } 

    function _computePenalty(uint256 amount) private view returns (uint256) {
        return (amount.mul(getPenalty())).div(_DENOMINATOR);
    }
    function _isNotPaused() private view returns (bool) {
        if (_paused) { return false; } else { return true; }
    }

    function _isUnique(address account) private view returns (bool) {
        if (balanceOf(account) < getRequirement()) { return true; } else { return false; }
    }
    function _isNotUnique(address account) private view returns (bool) {
        if (balanceOf(account) > getRequirement()) { return true; } else { return false; }
    }    
    
    function _getAcceptance(address account) private view returns (uint256) {
        return _challengers[account].acceptance;
    }
    function _getEpoch(address account) private view returns (uint256) {
        if (_getAcceptance(account) > 0) { return _time().sub(_getAcceptance(account)); } else { return 0; }
    } 
    function _getBlock(address account) private view returns (uint256) {
        return _getEpoch(account).div(_TERM); 
    }
    
    function _isContributor(address account) private view returns (bool) {
        if (balanceOf(account) >= getRequirement()) { return true; } else { return false; }
    }
    function _isEligible(address account, uint256 amount) private view returns (bool) {
        if (balanceOf(account) >= amount) { return true; } else { return false; }
    }
    function _isAcceptable(uint256 amount) private view returns (bool) {
        if (amount >= getRequirement()) { return true; } else { return false; }
    }
    function _isChallenger(address account) private view returns (bool) {
        if (_getAcceptance(account) > 0) { return true; } else { return false; }
    }
    
    function _isExcessive(uint256 amount, uint256 ceiling) private pure returns (bool) {
        if (amount > ceiling) { return true; } else { return false; }
    }
    
    function _isCompliant(address account, uint256 amount) private view returns (bool) {
        if (balanceOf(account).add(amount) >= getRequirement()) { return true; } else { return false; }
    }
    function _isNotCompliant(address account, uint256 amount) private view returns (bool) {
        if (balanceOf(account).sub(amount) < getRequirement()) { return true; } else { return false; }
    }
    
    function _isElastic() private view returns (bool) {
        if (getContributorsTotal() <= getContributorsLimit() && getContributorsTotal() > 0) { return true; } else { return false; }
    }
    
    function _environment() private view returns (address) {
        return address(this);
    }
    function _time() private view returns (uint256) {
        return block.timestamp;
    }
    
}


contract TDE is Context {
    using SafeMath for uint256;
    
    Token private _token;
    IUniswapV2Router02 private _uniswapRouter = IUniswapV2Router02(0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D);
    
    uint256 private constant _TOKEN_ALLOCATION_SALE = 45000000000000000000000; 
    
    uint256 private constant _FIRST_CEILING = 500 ether;
    uint256 private constant _TOTAL_CEILING = 2500 ether;
    
    uint256 private constant _UNISWAP_PERCENT = 15;
    uint256 private constant _UNISWAP_RATE = 11;

    uint256 private constant _MIN_CONTRIBUTION = 1 ether;
    uint256 private constant _MAX_CONTRIBUTION = 2500 ether; 
    
    uint8   private constant _MULTIPLIER  = 150;
    uint8   private constant _DENOMINATOR = 100;
    uint8   private constant _PRECISION   = 100;
    
    uint32  private constant _DURATION = 7 days;
    
    uint256 private _launch;
    uint256 private _over;
    
    uint256 private _fr;
    uint256 private _rr;
    
    mapping(address => uint256) private _contributions;

    address payable private _wallet;
    uint256 private _funds;

    bool    private _locked;


    event Configured(
        uint256 rate1,
        uint256 rate2);

    event Contributed(
        address indexed account,
        uint256 amount);
        
    event LiquidityLocked(
        uint256 amountETH,
        uint256 amountToken);
        
    event Finalized(
        uint256 time);
        
    event Boosted(
        address indexed account,
        uint256 amount);
    
    
    constructor(address token, address payable wallet) public {
        require(token != address(0), 
        "error: must not be zero address");
        require(wallet != address(0), 
        "error: must not be zero address");
        
        _launch = _time();
        _over = _launch.add(_DURATION);
        
        _token = Token(token);
        _wallet = wallet; 
        
        _calculateRates();
    }
    
    receive() external payable {
        require(!_isOver(), 
        "error: must not be over");
        
        if (_token.balanceOf(_environment()) > 0) _contribute();
    }
    
    function lockLiquidity() external returns (bool) {
        require(_isOver(), 
        "error: must be over");
        require(!_isLocked(), 
        "error: must not be locked");

        _locked = true;
        
        uint256 amountETHForUniswap = (getFunds().mul(_UNISWAP_PERCENT)).div(_DENOMINATOR);
        uint256 amountGFIForUniswap = (amountETHForUniswap.mul((_UNISWAP_RATE.mul(_PRECISION)))).div(_PRECISION);
        
        _token.unpause();

        _token.approve(address(_uniswapRouter), amountGFIForUniswap);
        _uniswapRouter.addLiquidityETH
        { value: amountETHForUniswap }
        (
            address(_token),
            amountGFIForUniswap,
            0,
            0,
            address(0), 
            _time()
        );
        
        emit LiquidityLocked(amountETHForUniswap, amountGFIForUniswap);
        return true;
    }
    function finalize() external returns (bool) {
        require(_isOver(), 
        "error: must be over");
        
        require(_isLocked(), 
        "error: must be locked");
        
        _vault();
        _boost();
        
        emit Finalized(_time());
        return true;
    }
    
    function getLaunch() public view returns (uint256) {
        return _launch;
    }
    function getOver() public view returns (uint256) {
        return _over;
    }
    function getFunds() public view returns (uint256) {
        return _funds;
    }

    function _calculateRates() private returns (bool) {
        require(_isNotConfigured(), 
        "error: must not be configured");

        uint256 rawfr = _TOKEN_ALLOCATION_SALE.div(_TOTAL_CEILING);
        
        _fr = (rawfr.mul(_MULTIPLIER)).div(_DENOMINATOR);
        
        uint256 ftAvailable = _FIRST_CEILING.mul(_fr);
        uint256 rtAvailable = _TOKEN_ALLOCATION_SALE.sub(ftAvailable);
        
        _rr = (rtAvailable.mul(_PRECISION)).div(_TOTAL_CEILING.sub(_FIRST_CEILING));
        
        Configured(_fr, _rr);
        return true;
    }
    
    function _contribute() private returns (bool) {
        address contributor = _msgSender();
        uint256 contribution = msg.value;
        
        require(_checkContribution(contribution),
        "error: must comply with contribution requirements");
        
        uint256 processedContribution;
        uint256 excessContribution;
        
        uint256 tokens;
        
        if (_isFirstMover()) {
            processedContribution = _FIRST_CEILING.sub(getFunds());
            if (_isExcessive(contribution, processedContribution)) {
                excessContribution = contribution.sub(processedContribution);
            
                tokens = (processedContribution.mul(_fr)).add((excessContribution.mul(_rr)).div(_PRECISION));
                
                _token.transfer(contributor, tokens);
                _funds = _funds.add(contribution);
                
            } else {
                tokens = (contribution.mul(_fr));
                _token.transfer(contributor, tokens);
                _funds = _funds.add(contribution);
            }
            
        } else {
            processedContribution = _TOTAL_CEILING.sub(getFunds());
            if (_isExcessive(contribution, processedContribution)) {
                excessContribution = contribution.sub(processedContribution);
                
                tokens = (processedContribution.mul(_rr)).div(_PRECISION);
                
                _token.transfer(contributor, tokens);
                _msgSender().transfer(excessContribution);
                _funds = _funds.add(processedContribution);

                emit Contributed(contributor, processedContribution);
            }
            tokens = (contribution.mul(_rr)).div(_PRECISION);
            _token.transfer(contributor, tokens);
            _funds = _funds.add(contribution);

        }
        emit Contributed(contributor, contribution);
        return true;
    }
    
    function _vault() private returns (bool) {
        _wallet.transfer(_environment().balance);
        return true;
    }
    function _boost() private returns (bool) {
        uint256 amount = _token.balanceOf(_environment());
        address token = address(_token);
        
        _token.transfer(token, amount);
        
        emit Boosted(token, amount);
        return true;
    }
    
    function _checkContribution(uint256 amount) private view returns (bool) {
        require(_isLaunched(), 
        "error: must be launched");
        require(_isActive(), 
        "error: must be active");
        require(amount >= _MIN_CONTRIBUTION, 
        "error: must be more or equal to the minimum contribution");
        require(amount <= _MAX_CONTRIBUTION, 
        "error: must be less or equal to the maximum contribution");
        return true;
    }

    function _isLaunched() private view returns (bool) {
        if (getLaunch() > 0) { return true; } else { return false; } 
    }
    function _isNotConfigured() private view returns (bool) {
        if (_fr == 0 && _rr == 0) { return true; } else { return false; } 
    }

    function _isActive() private view returns (bool) {
        if (getOver() > _time() || getFunds() < _TOTAL_CEILING) { return true; } else { return false; }
    }
    function _isFirstMover() private view returns (bool) {
        if (getFunds() < _FIRST_CEILING) { return true; } else { return false; }
    }
    function _isExcessive(uint256 amount, uint256 ceiling) private pure returns (bool) {
        if (amount > ceiling) { return true; } else { return false; }
    }
    
    function _isOver() private view returns (bool) {
        if (getOver() <= _time() || getFunds() >= _TOTAL_CEILING) { return true; } else { return false; }
    }
    function _isLocked() private view returns (bool) {
        return _locked;
    }

    function _environment() private view returns (address) {
        return address(this);
    }
    function _time() private view returns (uint256) {
        return block.timestamp;
    }

}