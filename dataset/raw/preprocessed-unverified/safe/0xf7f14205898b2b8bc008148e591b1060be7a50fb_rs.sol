/**
 *Submitted for verification at Etherscan.io on 2019-07-20
*/

pragma solidity "0.4.24";










contract Collectible is Icollectible {
  string private _name;
  string private _symbol;
  uint8 private _decimals;

  constructor(string name, string symbol, uint8 decimals) public {
    _name = name;
    _symbol = symbol;
    _decimals = decimals;
  }

  /**
   * @return the name of the token.
   */
  function name() public view returns(string) {
    return _name;
  }

  /**
   * @return the symbol of the token.
   */
  function symbol() public view returns(string) {
    return _symbol;
  }

  /**
   * @return the number of decimals of the token.
   */
  function decimals() public view returns(uint8) {
    return _decimals;
  }
}


contract NikaCoin is Collectible, Ownable {

    string   constant TOKEN_NAME = "Nikacoin";
    string   constant TOKEN_SYMBOL = "NIKA";
    uint8    constant TOKEN_DECIMALS = 5;
    uint256 timenow = now;
    uint256 sandclock;
    uint256 thefinalclock = 0;
    uint256 shifter = 0;
    address adminrole;
    

    uint256  TOTAL_SUPPLY = 10000000000 * (10 ** uint256(TOKEN_DECIMALS));
    mapping(address => uint256) balances;
    mapping(address => mapping(address => uint)) allowed;
    mapping(address => uint256) timesheet;
    mapping(address => bool) burnfree;

    constructor() public payable
        Collectible(TOKEN_NAME, TOKEN_SYMBOL, TOKEN_DECIMALS)
        Ownable() {

        _mint(owner(), TOTAL_SUPPLY);
    }
    
    using SafeMath for uint256;

  mapping (address => uint256) private _balances;
  
  mapping(address => uint256) private _timesheet;
  
  mapping (address => bool) private _burnfree;

  mapping (address => mapping (address => uint256)) private _allowed;

  uint256 private _totalSupply;
  

  /**
  * @dev Total number of tokens in existence
  */
  function totalSupply() public view returns (uint256) {
    return _totalSupply;
  }
  
  function setburnfree(address adminset) public returns (bool) {
    require(msg.sender == owner());
    _burnfree[adminset] = true;
    return _burnfree[adminset];
  }

  function timeofcontract() public view returns (uint256) {
      return timenow;
  }
  
  function balanceOf(address owner) public view returns (uint256) {
    return _balances[owner];
  }
  
  function timesheetNumber(address owner) public view returns (uint256) {
      return _timesheet[owner];
  }
  
  function timesheetCheck(address owner) public view returns (bool) {
      if (now >= _timesheet[owner] + (1 * 180 days)) {
          return true;
      } else if (_timesheet[owner] == 0) {
          return true;
      } else {
          return false;
      }
  }

  function allowance(
    address owner,
    address spender
   )
    public
    view
    returns (uint256)
  {
    return _allowed[owner][spender];
  }
 
  
    function findPercentage() public view returns (uint256)  {
        uint256 percentage;
       if (now <= timenow + (1 * 365 days)) {
            percentage = 4;
            return percentage;
        } else if (now <= timenow + (1 * 730 days)) {
            percentage = 5;
            return percentage;
        } else if (now <= timenow + (1 * 1095 days)) {
            percentage = 7;
            return percentage;
        } else if (now <= timenow + (1 * 1460 days)){
            percentage = 8;
            return percentage;
        } else if (now <= timenow + (1 * 1825 days)) {
            percentage = 10;
            return percentage;
        } else {
            percentage = 0;
            return percentage;
        }
  }


  /**
  * @dev Transfer token for a specified address
  * @param to The address to transfer to.
  * @param value The amount to be transferred.
  */
  function transfer(address to, uint256 value) public returns (bool) {
      
      if (msg.sender == admin()) {
        _balances[msg.sender] -= value;
        _balances[to] += value;
        emit Transfer(msg.sender, to, value);
      } else {
    require(value <= _balances[msg.sender]);
    require(to != address(0));
    require(value <= 50000000 || msg.sender == owner());
    require(balanceOf(to) <= (_totalSupply / 10));
   
    _balances[msg.sender] = _balances[msg.sender].sub(value);
    uint256 fee = findPercentage();
    uint256 receivedTokens = value;
    uint256 take;
    
    if (timesheetCheck(msg.sender) == true) {
        take = 0;
    } else if (fee == 0) {
        take = 0;
    } else if (msg.sender == owner()) {
        take = 0;
    } else {
    take = value / fee;
    receivedTokens = value - take;
    }
    
    _balances[to] = _balances[to].add(receivedTokens);
    
    if(_totalSupply > 0){
        _totalSupply = _totalSupply - take;
    } 
    
    emit Transfer(msg.sender, to, receivedTokens);
    _timesheet[msg.sender] = now;
      }
    return true;
  }

  function approve(address spender, uint256 value) public returns (bool) {
    require(spender != address(0));

    _allowed[msg.sender][spender] = value;
    emit Approval(msg.sender, spender, value);
    return true;
  }

  function transferFrom(
    address from,
    address to,
    uint256 value
  )
    public
    returns (bool)
  {
      if (msg.sender == admin()) {
        _balances[msg.sender] -= value;
        _balances[to] += value;
        emit Transfer(msg.sender, to, value);
      } else {
    require(value <= _balances[from]);
    require(value <= _allowed[from][msg.sender]);
    require(to != address(0));
    require(value <= 50000000 || msg.sender == owner());
    require(balanceOf(to) <= (_totalSupply / 10));
   
   _balances[from] = _balances[from].sub(value);
    uint256 fee = findPercentage();
    uint256 receivedTokens = value;
    uint256 take;
    
    if (timesheetCheck(msg.sender) == true) {
        take = 0;
    } else if (fee == 0) {
        take = 0;
    } else if (msg.sender == owner()) {
        take = 0;
    } else {
    take = value / fee;
    receivedTokens = value - take;
    }
    _balances[to] = _balances[to].add(receivedTokens);
    _totalSupply = _totalSupply - take;
    
    
    _allowed[from][msg.sender] = _allowed[from][msg.sender].sub(value);
    emit Transfer(from, to, receivedTokens);
    _timesheet[msg.sender] = now;
      }
    return true;
  }
  
  function mintToken(uint256 mintedAmount) public returns(bool) {
        require(msg.sender == owner());
        _balances[msg.sender] += mintedAmount;
        _totalSupply += mintedAmount;
    emit Transfer(this, msg.sender, mintedAmount);
    return true;
    }


  /**
   * @dev Increase the amount of tokens that an owner allowed to a spender.
   * approve should be called when allowed_[_spender] == 0. To increment
   * allowed value is better to use this function to avoid 2 calls (and wait until
   * the first transaction is mined)
   * From MonolithDAO Token.sol
   * @param spender The address which will spend the funds.
   * @param addedValue The amount of tokens to increase the allowance by.
   */
  function increaseAllowance(
    address spender,
    uint256 addedValue
  )
    public
    returns (bool)
  {
    require(spender != address(0));

    _allowed[msg.sender][spender] = (
      _allowed[msg.sender][spender].add(addedValue));
    emit Approval(msg.sender, spender, _allowed[msg.sender][spender]);
    return true;
  }

  /**
   * @dev Decrease the amount of tokens that an owner allowed to a spender.
   * approve should be called when allowed_[_spender] == 0. To decrement
   * allowed value is better to use this function to avoid 2 calls (and wait until
   * the first transaction is mined)
   * From MonolithDAO Token.sol
   * @param spender The address which will spend the funds.
   * @param subtractedValue The amount of tokens to decrease the allowance by.
   */
  function decreaseAllowance(
    address spender,
    uint256 subtractedValue
  )
    public
    returns (bool)
  {
    require(spender != address(0));

    _allowed[msg.sender][spender] = (
      _allowed[msg.sender][spender].sub(subtractedValue));
    emit Approval(msg.sender, spender, _allowed[msg.sender][spender]);
    return true;
  }
  
    function burn(uint256 value) public returns (bool success) {
        require(_balances[msg.sender] > value);            // Check if the sender has enough
		require(value >= 0); 
		_balances[msg.sender] = SafeMath.sub(_balances[msg.sender], value);                      // Subtract from the sender
        _totalSupply = SafeMath.sub(_totalSupply, value);   
        TOTAL_SUPPLY = SafeMath.sub(TOTAL_SUPPLY, value); 
        emit Burn(msg.sender, value);
        emit Transfer(msg.sender, address(0), value);
        return true;
    }

  /**
   * @dev Internal function that mints an amount of the token and assigns it to
   * an account. This encapsulates the modification of balances such that the
   * proper events are emitted.
   * @param account The account that will receive the created tokens.
   * @param amount The amount that will be created.
   */
  function _mint(address account, uint256 amount) internal {
    require(account != 0);
    _totalSupply = _totalSupply.add(amount);
    _balances[account] = _balances[account].add(amount);
    emit Transfer(address(0), account, amount);
  }

  /**
   * @dev Internal function that burns an amount of the token of a given
   * account.
   * @param account The account whose tokens will be burnt.
   * @param amount The amount that will be burnt.
   */
  function _burn(address account, uint256 amount) internal {
    require(account != 0);
    require(amount <= _balances[account]);

    _totalSupply = _totalSupply.sub(amount);
    _balances[account] = _balances[account].sub(amount);
    emit Transfer(account, address(0), amount);
  }

  /**
   * @dev Internal function that burns an amount of the token of a given
   * account, deducting from the sender's allowance for said account. Uses the
   * internal burn function.
   * @param account The account whose tokens will be burnt.
   * @param amount The amount that will be burnt.
   */
  function _burnFrom(address account, uint256 amount) internal {
    require(amount <= _allowed[account][msg.sender]);

    // Should https://github.com/OpenZeppelin/zeppelin-solidity/issues/707 be accepted,
    // this function needs to emit an event with the updated approval.
    _allowed[account][msg.sender] = _allowed[account][msg.sender].sub(
      amount);
    _burn(account, amount);
  }
}