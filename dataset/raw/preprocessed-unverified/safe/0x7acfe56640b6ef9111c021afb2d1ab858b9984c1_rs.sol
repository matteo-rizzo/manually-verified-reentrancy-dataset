/**
 *Submitted for verification at Etherscan.io on 2019-11-03
*/

/**
 * Copyright (c) 2019 Token Factory Switzerland Ltd
 * license@tokenfactory.global
 * All rights reserved.
 */

pragma solidity ^0.5.4;



contract PauserRole {
    using Roles for Roles.Role;

    event PauserAdded(address indexed account);
    event PauserRemoved(address indexed account);

    Roles.Role private _pausers;

    constructor () internal {
        _addPauser(msg.sender);
    }

    modifier onlyPauser() {
        require(isPauser(msg.sender));
        _;
    }

    function isPauser(address account) public view returns (bool) {
        return _pausers.has(account);
    }

    function addPauser(address account) public onlyPauser {
        _addPauser(account);
    }

    function renouncePauser() public {
        _removePauser(msg.sender);
    }

    function _addPauser(address account) internal {
        _pausers.add(account);
        emit PauserAdded(account);
    }

    function _removePauser(address account) internal {
        _pausers.remove(account);
        emit PauserRemoved(account);
    }
}

contract Pausable is PauserRole {
    event Paused(address account);
    event Unpaused(address account);

    bool private _paused;

    constructor () internal {
        _paused = false;
    }

    /**
     * @return true if the contract is paused, false otherwise.
     */
    function paused() public view returns (bool) {
        return _paused;
    }

    /**
     * @dev Modifier to make a function callable only when the contract is not paused.
     */
    modifier whenNotPaused() {
        require(!_paused);
        _;
    }

    /**
     * @dev Modifier to make a function callable only when the contract is paused.
     */
    modifier whenPaused() {
        require(_paused);
        _;
    }

    /**
     * @dev called by the owner to pause, triggers stopped state
     */
    function pause() public onlyPauser whenNotPaused {
        _paused = true;
        emit Paused(msg.sender);
    }

    /**
     * @dev called by the owner to unpause, returns to normal state
     */
    function unpause() public onlyPauser whenPaused {
        _paused = false;
        emit Unpaused(msg.sender);
    }
}







contract ERC20 is IERC20 {
    using SafeMath for uint256;

    mapping (address => uint256) private _balances;

    mapping (address => mapping (address => uint256)) private _allowed;

    uint256 private _totalSupply;

    /**
     * @dev Total number of tokens in existence
     */
    function totalSupply() public view returns (uint256) {
        return _totalSupply;
    }

    /**
     * @dev Gets the balance of the specified address.
     * @param owner The address to query the balance of.
     * @return A uint256 representing the amount owned by the passed address.
     */
    function balanceOf(address owner) public view returns (uint256) {
        return _balances[owner];
    }

    /**
     * @dev Function to check the amount of tokens that an owner allowed to a spender.
     * @param owner address The address which owns the funds.
     * @param spender address The address which will spend the funds.
     * @return A uint256 specifying the amount of tokens still available for the spender.
     */
    function allowance(address owner, address spender) public view returns (uint256) {
        return _allowed[owner][spender];
    }

    /**
     * @dev Transfer token to a specified address
     * @param to The address to transfer to.
     * @param value The amount to be transferred.
     */
    function transfer(address to, uint256 value) public returns (bool) {
        _transfer(msg.sender, to, value);
        return true;
    }

    /**
     * @dev Approve the passed address to spend the specified amount of tokens on behalf of msg.sender.
     * Beware that changing an allowance with this method brings the risk that someone may use both the old
     * and the new allowance by unfortunate transaction ordering. One possible solution to mitigate this
     * race condition is to first reduce the spender's allowance to 0 and set the desired value afterwards:
     * https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729
     * @param spender The address which will spend the funds.
     * @param value The amount of tokens to be spent.
     */
    function approve(address spender, uint256 value) public returns (bool) {
        _approve(msg.sender, spender, value);
        return true;
    }

    /**
     * @dev Transfer tokens from one address to another.
     * Note that while this function emits an Approval event, this is not required as per the specification,
     * and other compliant implementations may not emit the event.
     * @param from address The address which you want to send tokens from
     * @param to address The address which you want to transfer to
     * @param value uint256 the amount of tokens to be transferred
     */
    function transferFrom(address from, address to, uint256 value) public returns (bool) {
        _transfer(from, to, value);
        _approve(from, msg.sender, _allowed[from][msg.sender].sub(value));
        return true;
    }

    /**
     * @dev Increase the amount of tokens that an owner allowed to a spender.
     * approve should be called when _allowed[msg.sender][spender] == 0. To increment
     * allowed value is better to use this function to avoid 2 calls (and wait until
     * the first transaction is mined)
     * From MonolithDAO Token.sol
     * Emits an Approval event.
     * @param spender The address which will spend the funds.
     * @param addedValue The amount of tokens to increase the allowance by.
     */
    function increaseAllowance(address spender, uint256 addedValue) public returns (bool) {
        _approve(msg.sender, spender, _allowed[msg.sender][spender].add(addedValue));
        return true;
    }

    /**
     * @dev Decrease the amount of tokens that an owner allowed to a spender.
     * approve should be called when _allowed[msg.sender][spender] == 0. To decrement
     * allowed value is better to use this function to avoid 2 calls (and wait until
     * the first transaction is mined)
     * From MonolithDAO Token.sol
     * Emits an Approval event.
     * @param spender The address which will spend the funds.
     * @param subtractedValue The amount of tokens to decrease the allowance by.
     */
    function decreaseAllowance(address spender, uint256 subtractedValue) public returns (bool) {
        _approve(msg.sender, spender, _allowed[msg.sender][spender].sub(subtractedValue));
        return true;
    }

    /**
     * @dev Transfer token for a specified addresses
     * @param from The address to transfer from.
     * @param to The address to transfer to.
     * @param value The amount to be transferred.
     */
    function _transfer(address from, address to, uint256 value) internal {
        require(to != address(0));

        _balances[from] = _balances[from].sub(value);
        _balances[to] = _balances[to].add(value);
        emit Transfer(from, to, value);
    }

    /**
     * @dev Internal function that mints an amount of the token and assigns it to
     * an account. This encapsulates the modification of balances such that the
     * proper events are emitted.
     * @param account The account that will receive the created tokens.
     * @param value The amount that will be created.
     */
    function _mint(address account, uint256 value) internal {
        require(account != address(0));

        _totalSupply = _totalSupply.add(value);
        _balances[account] = _balances[account].add(value);
        emit Transfer(address(0), account, value);
    }

    /**
     * @dev Internal function that burns an amount of the token of a given
     * account.
     * @param account The account whose tokens will be burnt.
     * @param value The amount that will be burnt.
     */
    function _burn(address account, uint256 value) internal {
        require(account != address(0));

        _totalSupply = _totalSupply.sub(value);
        _balances[account] = _balances[account].sub(value);
        emit Transfer(account, address(0), value);
    }

    /**
     * @dev Approve an address to spend another addresses' tokens.
     * @param owner The address that owns the tokens.
     * @param spender The address that will spend the tokens.
     * @param value The number of tokens that can be spent.
     */
    function _approve(address owner, address spender, uint256 value) internal {
        require(spender != address(0));
        require(owner != address(0));

        _allowed[owner][spender] = value;
        emit Approval(owner, spender, value);
    }

    /**
     * @dev Internal function that burns an amount of the token of a given
     * account, deducting from the sender's allowance for said account. Uses the
     * internal burn function.
     * Emits an Approval event (reflecting the reduced allowance).
     * @param account The account whose tokens will be burnt.
     * @param value The amount that will be burnt.
     */
    function _burnFrom(address account, uint256 value) internal {
        _burn(account, value);
        _approve(account, msg.sender, _allowed[account][msg.sender].sub(value));
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

    /**
     * @return the name of the token.
     */
    function name() public view returns (string memory) {
        return _name;
    }

    /**
     * @return the symbol of the token.
     */
    function symbol() public view returns (string memory) {
        return _symbol;
    }

    /**
     * @return the number of decimals of the token.
     */
    function decimals() public view returns (uint8) {
        return _decimals;
    }
}





contract MoneyMarketInterface {
  function getSupplyBalance(address account, address asset) public view returns (uint);
  function supply(address asset, uint amount) public returns (uint);
  function withdraw(address asset, uint requestedAmount) public returns (uint);
}

contract LoanEscrow is Pausable {
  using SafeERC20 for IERC20;
  using SafeMath for uint256;

  // configurable to any ERC20 (i.e. xCHF)
  IERC20 public dai = IERC20(0xB4272071eCAdd69d933AdcD19cA99fe80664fc08);  // 0x9Ad61E35f8309aF944136283157FABCc5AD371E5  // 0xB4272071eCAdd69d933AdcD19cA99fe80664fc08
  MoneyMarketInterface public moneyMarket = MoneyMarketInterface(0x3FDA67f7583380E67ef93072294a7fAc882FD7E7);  // 0x6732c278C58FC90542cce498981844A073D693d7

  event Deposited(address indexed from, uint256 daiAmount);
  event InterestWithdrawn(address indexed to, uint256 daiAmount);
  event Pulled(address indexed to, uint256 daiAmount);

  mapping(address => uint256) public deposits;
  mapping(address => uint256) public pulls;
  uint256 public deposited;
  uint256 public pulled;

  modifier onlyBlockimmo() {
    require(msg.sender == blockimmo(), "onlyBlockimmo");
    _;
  }

  function blockimmo() public view returns (address);

  function withdrawInterest() public onlyBlockimmo {
    uint256 amountInterest = moneyMarket.getSupplyBalance(address(this), address(dai)).add(dai.balanceOf(address(this))).add(pulled).sub(deposited);
    require(amountInterest > 0, "no interest");

    uint256 errorCode = (amountInterest > dai.balanceOf(address(this))) ? moneyMarket.withdraw(address(dai), amountInterest.sub(dai.balanceOf(address(this)))) : 0;
    require(errorCode == 0, "withdraw failed");

    dai.safeTransfer(msg.sender, amountInterest);
    emit InterestWithdrawn(msg.sender, amountInterest);
  }

  function withdrawMoneyMarket(uint256 _amountDai) public onlyBlockimmo {
    uint256 errorCode = moneyMarket.withdraw(address(dai), _amountDai);
    require(errorCode == 0, "withdraw failed");
  }

  function deposit(address _from, uint256 _amountDai) internal {
    require(_from != address(0) && _amountDai > 0, "invalid parameter(s)");

    dai.safeTransferFrom(msg.sender, address(this), _amountDai);

    if (!paused()) {
      dai.safeApprove(address(moneyMarket), _amountDai);

      uint256 errorCode = moneyMarket.supply(address(dai), _amountDai);
      require(errorCode == 0, "supply failed");
      require(dai.allowance(address(this), address(moneyMarket)) == 0, "allowance not fully consumed by moneyMarket");
    }

    deposits[_from] = deposits[_from].add(_amountDai);
    deposited = deposited.add(_amountDai);
    emit Deposited(_from, _amountDai);
  }

  function pull(address _to, uint256 _amountDai, bool _refund) internal {
    require(_to != address(0) && _amountDai > 0, "invalid parameter(s)");

    uint256 errorCode = (_amountDai > dai.balanceOf(address(this))) ? moneyMarket.withdraw(address(dai), _amountDai.sub(dai.balanceOf(address(this)))) : 0;
    require(errorCode == 0, "withdraw failed");

    if (_refund) {
      deposits[_to] = deposits[_to].sub(_amountDai);
      deposited = deposited.sub(_amountDai);
    } else {
      pulls[_to] = pulls[_to].add(_amountDai);
      pulled = pulled.add(_amountDai);
    }

    dai.safeTransfer(_to, _amountDai);
    emit Pulled(_to, _amountDai);
  }
}

contract DividendDistributingToken is ERC20, LoanEscrow {
  using SafeMath for uint256;

  uint256 public constant POINTS_PER_DAI = uint256(10) ** 32;

  uint256 public pointsPerToken = 0;
  mapping(address => uint256) public credits;
  mapping(address => uint256) public lastPointsPerToken;

  event DividendsCollected(address indexed collector, uint256 amount);
  event DividendsDeposited(address indexed depositor, uint256 amount);

  function collectOwedDividends(address _account) public {
    creditAccount(_account);

    uint256 _dai = credits[_account].div(POINTS_PER_DAI);
    credits[_account] = 0;

    pull(_account, _dai, false);
    emit DividendsCollected(_account, _dai);
  }

  function depositDividends() public {  // dividends
    uint256 amount = dai.allowance(msg.sender, address(this));

    uint256 fee = amount.div(100);
    dai.safeTransferFrom(msg.sender, blockimmo(), fee);

    deposit(msg.sender, amount.sub(fee));

    // partially tokenized properties store the "non-tokenized" part in `this` contract, dividends not disrupted
    uint256 issued = totalSupply().sub(unissued());
    pointsPerToken = pointsPerToken.add(amount.sub(fee).mul(POINTS_PER_DAI).div(issued));

    emit DividendsDeposited(msg.sender, amount);
  }

  function unissued() public view returns (uint256) {
    return balanceOf(address(this));
  }

  function creditAccount(address _account) internal {
    uint256 amount = balanceOf(_account).mul(pointsPerToken.sub(lastPointsPerToken[_account]));

    uint256 _credits = credits[_account].add(amount);
    if (credits[_account] != _credits)
      credits[_account] = _credits;

    if (lastPointsPerToken[_account] != pointsPerToken)
      lastPointsPerToken[_account] = pointsPerToken;
  }
}

contract LandRegistryInterface {
  function getProperty(string memory _eGrid) public view returns (address property);
}

contract LandRegistryProxyInterface {
  function owner() public view returns (address);
  function landRegistry() public view returns (LandRegistryInterface);
}

contract WhitelistInterface {
  function checkRole(address _operator, string memory _permission) public view;
}

contract WhitelistProxyInterface {
  function whitelist() public view returns (WhitelistInterface);
}

contract TokenizedProperty is DividendDistributingToken, ERC20Detailed, Ownable {
  LandRegistryProxyInterface public registryProxy = LandRegistryProxyInterface(0x28D80351de3B6caB6D6334B1863A564845Da5FD5);  // 0x0f5Ea0A652E851678Ebf77B69484bFcD31F9459B;
  WhitelistProxyInterface public whitelistProxy = WhitelistProxyInterface(0x06a2EB4ad1b55CFB76bc0EBFA3C9ec658C62C1fA);  // 0xEC8bE1A5630364292E56D01129E8ee8A9578d7D8;

  uint256 public constant NUM_TOKENS = 1000000;

  modifier isValid() {
    LandRegistryInterface registry = LandRegistryInterface(registryProxy.landRegistry());
    require(registry.getProperty(name()) == address(this), "invalid TokenizedProperty");
    _;
  }

  modifier onlyBlockimmo() {
    require(msg.sender == blockimmo(), "onlyBlockimmo");
    _;
  }

  constructor(string memory _eGrid, string memory _grundstuck) public ERC20Detailed(_eGrid, _grundstuck, 18) {
    uint256 totalSupply = NUM_TOKENS.mul(uint256(10) ** decimals());
    _mint(msg.sender, totalSupply);

    _approve(address(this), blockimmo(), ~uint256(0));  // enable blockimmo to issue `unissued` tokens in the future
  }

  function blockimmo() public view returns (address) {
    return registryProxy.owner();
  }

  function burn(uint256 _value) public isValid {  // buyback
    creditAccount(msg.sender);
    _burn(msg.sender, _value);
  }

  function mint(address _to, uint256 _value) public isValid onlyBlockimmo returns (bool) {  // equity dilution
    creditAccount(_to);
    _mint(_to, _value);
    return true;
  }

  function _transfer(address _from, address _to, uint256 _value) internal isValid {
    whitelistProxy.whitelist().checkRole(_to, "authorized");

    creditAccount(_from);  // required for dividends...
    creditAccount(_to);

    super._transfer(_from, _to, _value);
  }
}