/**
 *Submitted for verification at Etherscan.io on 2021-04-24
*/

// SPDX-License-Identifier: UNLICENSED

// Copyright (c) 2021 0xdev0 - All rights reserved
// https://twitter.com/0xdev0

pragma solidity ^0.8.0;











contract ReentrancyGuard {
  uint256 private constant _NOT_ENTERED = 1;
  uint256 private constant _ENTERED = 2;

  uint256 private _status;

  constructor () {
    _status = _NOT_ENTERED;
  }

  modifier nonReentrant() {
    require(_status != _ENTERED, "ReentrancyGuard: reentrant call");
    _status = _ENTERED;
    _;
    _status = _NOT_ENTERED;
  }
}







contract ERC20 is Ownable {

  event Transfer(address indexed from, address indexed to, uint value);
  event Approval(address indexed owner, address indexed spender, uint value);

  mapping (address => uint) public balanceOf;
  mapping (address => mapping (address => uint)) public allowance;

  string public name;
  string public symbol;
  uint8 public decimals;
  uint public totalSupply;

  constructor(
    string memory _name,
    string memory _symbol,
    uint8 _decimals
  ) {
    name = _name;
    symbol = _symbol;
    decimals = _decimals;
    require(decimals > 0, "decimals");
  }

  function transfer(address _recipient, uint _amount) public returns (bool) {
    _transfer(msg.sender, _recipient, _amount);
    return true;
  }

  function approve(address _spender, uint _amount) public returns (bool) {
    _approve(msg.sender, _spender, _amount);
    return true;
  }

  function transferFrom(address _sender, address _recipient, uint _amount) public returns (bool) {
    require(allowance[_sender][msg.sender] >= _amount, "ERC20: insufficient approval");
    _transfer(_sender, _recipient, _amount);
    _approve(_sender, msg.sender, allowance[_sender][msg.sender] - _amount);
    return true;
  }

  function _transfer(address _sender, address _recipient, uint _amount) internal {
    require(_sender != address(0), "ERC20: transfer from the zero address");
    require(_recipient != address(0), "ERC20: transfer to the zero address");
    require(balanceOf[_sender] >= _amount, "ERC20: insufficient funds");

    balanceOf[_sender] -= _amount;
    balanceOf[_recipient] += _amount;
    emit Transfer(_sender, _recipient, _amount);
  }

  function mint(address _account, uint _amount) public onlyOwner {
    _mint(_account, _amount);
  }

  function burn(address _account, uint _amount) public onlyOwner {
    _burn(_account, _amount);
  }

  function _mint(address _account, uint _amount) internal {
    require(_account != address(0), "ERC20: mint to the zero address");

    totalSupply += _amount;
    balanceOf[_account] += _amount;
    emit Transfer(address(0), _account, _amount);
  }

  function _burn(address _account, uint _amount) internal {
    require(_account != address(0), "ERC20: burn from the zero address");

    balanceOf[_account] -= _amount;
    totalSupply -= _amount;
    emit Transfer(_account, address(0), _amount);
  }

  function _approve(address _owner, address _spender, uint _amount) internal {
    require(_owner != address(0), "ERC20: approve from the zero address");
    require(_spender != address(0), "ERC20: approve to the zero address");

    allowance[_owner][_spender] = _amount;
    emit Approval(_owner, _spender, _amount);
  }
}



contract TransferHelper {

  // Mainnet
  IWETH internal constant WETH = IWETH(0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2);

  // Ropsten
  // IWETH internal constant WETH = IWETH(0xc778417E063141139Fce010982780140Aa0cD5Ab);

  function _safeTransferFrom(address _token, address _sender, uint _amount) internal returns(uint) {
    IERC20(_token).transferFrom(_sender, address(this), _amount);
    require(_amount > 0, "TransferHelper: amount must be > 0");
  }

  function _wethWithdrawTo(address _to, uint _amount) internal {
    require(_amount > 0, "TransferHelper: amount must be > 0");
    WETH.withdraw(_amount);
    (bool success, ) = _to.call { value: _amount }(new bytes(0));
    require(success, 'TransferHelper: ETH transfer failed');
  }
}

contract LendingPair is ReentrancyGuard, TransferHelper {

  // Prevents division by zero and other nasty stuff
  uint public constant MIN_RESERVE = 1000;

  using Address for address;
  using Clones for address;

  mapping (address => mapping (address => uint)) public debtOf;
  mapping (address => mapping (address => uint)) public accountInterestSnapshot;
  mapping (address => uint) public cumulativeInterestRate; // 1e18 = 1%
  mapping (address => uint) public totalDebt;
  mapping (address => uint) public storedSwapReserve;
  mapping (address => uint) public swapTime;
  mapping (address => uint) public storedLendingReserve;
  mapping (address => uint) public lendingTime;
  mapping (address => IERC20) public lpToken;

  IController public controller;
  address public tokenA;
  address public tokenB;
  uint public lastTimeAccrued;

  event Swap(
    address indexed fromToken,
    address indexed toToken,
    address indexed recipient,
    uint inputAmount,
    uint outputAmount
  );

  event FlashSwap(
    address indexed recipient,
    uint amountA,
    uint amountB
  );

  event Liquidation(
    address indexed account,
    uint supplyBurnA,
    uint supplyBurnB,
    uint borrowBurnA,
    uint borrowBurnB
  );

  event Deposit(address indexed token, uint amount);
  event Withdraw(address indexed token, uint amount);
  event Borrow(address indexed token, uint amount);
  event Repay(address indexed token, uint amount);

  receive() external payable {}

  function initialize(
    address _lpTokenMaster,
    address _controller,
    IERC20 _tokenA,
    IERC20 _tokenB
  ) public {
    require(address(tokenA) == address(0), "LendingPair: already initialized");
    require(address(_tokenA) != address(0) && address(_tokenB) != address(0), "LendingPair: cannot be ZERO address");

    controller = IController(_controller);
    tokenA = address(_tokenA);
    tokenB = address(_tokenB);
    lastTimeAccrued = block.timestamp;
    cumulativeInterestRate[tokenA] = 1e18;
    cumulativeInterestRate[tokenB] = 1e18;

    lpToken[tokenA] = _createLpToken(_lpTokenMaster);
    lpToken[tokenB] = _createLpToken(_lpTokenMaster);
  }

  function depositRepay(address _token, uint _amount) public {
    _depositRepay(_token, _amount);
    IERC20(_token).transferFrom(msg.sender, address(this), _amount);
  }

  function depositRepayETH() public payable {
    _depositRepay(address(WETH), msg.value);
    WETH.deposit { value: msg.value }();
  }

  function withdrawBorrow(address _token, uint _amount) public {
    _withdrawBorrow(_token, _amount);
    _safeTransfer(IERC20(_token), msg.sender, _amount);
  }

  function withdrawBorrowETH(uint _amount) public {
    _withdrawBorrow(address(WETH), _amount);
    _wethWithdrawTo(msg.sender, _amount);
    _checkMinReserve(IERC20(address(WETH)));
  }

  function deposit(address _token, uint _amount) public {
    accrueAccount(msg.sender);
    _deposit(_token, _amount);
    _safeTransferFrom(_token, msg.sender, _amount);
  }

  function withdrawAll(address _token) public {
    accrueAccount(msg.sender);
    uint amount = lpToken[address(_token)].balanceOf(msg.sender);
    _withdraw(_token, amount);
    _safeTransfer(IERC20(_token), msg.sender, amount);
  }

  function withdraw(address _token, uint _amount) public {
    accrueAccount(msg.sender);
    _withdraw(_token, _amount);
    _safeTransfer(IERC20(_token), msg.sender, _amount);
  }

  function borrow(address _token, uint _amount) public {
    accrueAccount(msg.sender);
    _borrow(_token, _amount);
    _safeTransfer(IERC20(_token), msg.sender, _amount);
  }

  function repayAll(address _token) public {
    accrueAccount(msg.sender);
    uint amount = debtOf[_token][msg.sender];
    _repay(_token, amount);
    _safeTransferFrom(_token, msg.sender, amount);
  }

  function repay(address _token, uint _amount) public {
    accrueAccount(msg.sender);
    _repay(_token, _amount);
    _safeTransferFrom(_token, msg.sender, _amount);
  }

  function flashSwap(
    address _recipient,
    uint _amountA,
    uint _amountB,
    bytes calldata _data
  ) public nonReentrant {

    _delayLendingPrice(tokenA);
    _delayLendingPrice(tokenB);

    require(_amountA > 0 || _amountB > 0, 'LendingPair: insufficient input amounts');

    uint balanceA = IERC20(tokenA).balanceOf(address(this));
    uint balanceB = IERC20(tokenB).balanceOf(address(this));

    if (_amountA > 0) _safeTransfer(IERC20(tokenA), _recipient, _amountA);
    if (_amountB > 0) _safeTransfer(IERC20(tokenB), _recipient, _amountB);
    ILendingPairCallee(_recipient).flashSwapCall(msg.sender, _amountA, _amountB, _data);

    uint adjustedBalanceA = balanceA + _amountA * 3 / 1000;
    uint adjustedBalanceB = balanceB + _amountB * 3 / 1000;
    uint expectedK = adjustedBalanceA * adjustedBalanceB;

    _earnSwapInterest(tokenA, _amountA);
    _earnSwapInterest(tokenB, _amountB);

    require(_k() >= expectedK, "LendingPair: insufficient return amount");

    emit FlashSwap(_recipient, _amountA, _amountB);
  }

  function swapETHToToken(
    address  _toToken,
    address  _recipient,
    uint     _minOutput,
    uint     _deadline
  ) public payable nonReentrant returns(uint) {

    uint outputAmount = _swap(address(WETH), _toToken, _recipient, msg.value, _minOutput, _deadline);
    WETH.deposit { value: msg.value }();
    _safeTransfer(IERC20(_toToken), _recipient, outputAmount);

    return outputAmount;
  }

  function swapTokenToETH(
    address  _fromToken,
    address  _recipient,
    uint     _inputAmount,
    uint     _minOutput,
    uint     _deadline
  ) public nonReentrant returns(uint) {

    uint outputAmount = _swap(_fromToken, address(WETH), _recipient, _inputAmount, _minOutput, _deadline);
    _safeTransferFrom(_fromToken, msg.sender, _inputAmount);
    _wethWithdrawTo(_recipient, outputAmount);
    _checkMinReserve(IERC20(address(WETH)));

    return outputAmount;
  }

  function swapTokenToToken(
    address  _fromToken,
    address  _toToken,
    address  _recipient,
    uint     _inputAmount,
    uint     _minOutput,
    uint     _deadline
  ) public nonReentrant returns(uint) {

    uint outputAmount = _swap(_fromToken, _toToken, _recipient, _inputAmount, _minOutput, _deadline);
    _safeTransferFrom(_fromToken, msg.sender, _inputAmount);
    _safeTransfer(IERC20(_toToken), _recipient, outputAmount);

    return outputAmount;
  }

  function accrue() public {
    _accrueInterest(tokenA);
    _accrueInterest(tokenB);
    lastTimeAccrued = block.timestamp;
  }

  function accrueAccount(address _account) public {
    accrue();
    _accrueAccount(_account);
  }

  function accountHealth(address _account) public view returns(uint) {
    uint totalAccountSupply  = supplyBalance(_account, tokenA, tokenA) + supplyBalance(_account, tokenB, tokenA);
    uint totalAccountBorrrow = borrowBalance(_account, tokenA, tokenA) + borrowBalance(_account, tokenB, tokenA);

    if (totalAccountBorrrow == 0) {
      return controller.liqMinHealth();
    } else {
      return totalAccountSupply * 1e18 / totalAccountBorrrow;
    }
  }

  // Get borow balance converted to the units of _returnToken
  function borrowBalance(
    address _account,
    address _borrowedToken,
    address _returnToken
  ) public view returns(uint) {
    return convertTokenValues(_borrowedToken, _returnToken, debtOf[_borrowedToken][_account]);
  }

  // Get supply balance converted to the units of _returnToken
  function supplyBalance(
    address _account,
    address _suppliedToken,
    address _returnToken
  ) public view returns(uint) {
    return convertTokenValues(_suppliedToken, _returnToken, lpToken[_suppliedToken].balanceOf(_account));
  }

  // Get the value of _fromToken in the units of _toToken without slippage or fees
  function convertTokenValues(
    address _fromToken,
    address _toToken,
    uint    _inputAmount
  ) public view returns(uint) {

    uint inputReserve  = lendingReserve(_fromToken);
    uint outputReserve = lendingReserve(_toToken);
    require(inputReserve > 0 && outputReserve > 0, "LendingPair: invalid reserve balances");

    return _inputAmount * 1e18 * outputReserve / inputReserve / 1e18;
  }

  function getExpectedOutput(
    address  _fromToken,
    address  _toToken,
    uint     _inputAmount
  ) public view returns(uint) {

    uint inputReserve  = swapReserve(_fromToken);
    uint outputReserve = swapReserve(_toToken);

    require(inputReserve > 0 && outputReserve > 0, "LendingPair: invalid reserve balances");

    uint inputAmountWithFee = _inputAmount * 997;
    uint numerator = inputAmountWithFee * outputReserve;
    uint denominator = inputReserve * 1000 + inputAmountWithFee;
    uint output = numerator / denominator;
    uint maxOutput = IERC20(_toToken).balanceOf(address(this)) - MIN_RESERVE;

    return output > maxOutput ? maxOutput : output;
  }

  function supplyRate(address _token) public view returns(uint) {
    return controller.interestRateModel().supplyRate(ILendingPair(address(this)), _token);
  }

  function borrowRate(address _token) public view returns(uint) {
    return controller.interestRateModel().borrowRate(ILendingPair(address(this)), _token);
  }

  // Sell collateral to reduce debt and increase accountHealth
  function liquidateAccount(address _account) public {
    uint health = accountHealth(_account);
    require(health < controller.liqMinHealth(), "LendingPair: account health > liqMinHealth");

    (uint supplyBurnA, uint borrowBurnA) = _liquidateToken(_account, tokenA, tokenB);
    (uint supplyBurnB, uint borrowBurnB) = _liquidateToken(_account, tokenB, tokenA);

    emit Liquidation(_account, supplyBurnA, supplyBurnB, borrowBurnA, borrowBurnB);
  }

  function pendingSupplyInterest(address _token, address _account) public view returns(uint) {
    return _newInterest(lpToken[_token].balanceOf(_account), _token, _account);
  }

  function pendingBorrowInterest(address _token, address _account) public view returns(uint) {
    return _newInterest(debtOf[_token][_account], _token, _account);
  }

  // Used to calculate swap price
  function swapReserve(address _token) public view returns(uint) {
    return _reserve(_token, storedSwapReserve[_token], swapTime[_token]);
  }

  // Used to calculate liquidation price
  function lendingReserve(address _token) public view returns(uint) {
    return _reserve(_token, storedLendingReserve[_token], lendingTime[_token]);
  }

  function feeRecipient() public view returns(address) {
    return controller.feeRecipient();
  }

  function checkAccountHealth(address _account) public view  {
    uint health = accountHealth(_account);
    require(health >= controller.liqMinHealth(), "LendingPair: insufficient accountHealth");
  }

  function _reserve(address _token, uint _storedReserve, uint _vTime) internal view returns(uint) {
    uint realReserve = IERC20(_token).balanceOf(address(this));
    if (block.timestamp > (_vTime + controller.priceDelay())) { return realReserve; }

    uint timeElapsed = block.timestamp - _vTime;
    int diffAmount = (int(realReserve) - int(_storedReserve)) * int(_timeShare(timeElapsed)) / int(1e18);

    return uint(int(_storedReserve) + diffAmount);
  }

  function _swap(
    address  _fromToken,
    address  _toToken,
    address  _recipient,
    uint     _inputAmount,
    uint     _minOutput,
    uint     _deadline
  ) internal returns(uint) {

    _validateToken(_fromToken);
    _validateToken(_toToken);

    _delayLendingPrice(_fromToken);
    _delayLendingPrice(_toToken);

    uint outputReserve = IERC20(_toToken).balanceOf(address(this));
    uint outputAmount = getExpectedOutput(_fromToken, _toToken, _inputAmount);

    require(_deadline >= block.timestamp,  "LendingPair: _deadline <= block.timestamp");
    require(outputAmount >= _minOutput,    "LendingPair: outputAmount >= _minOutput");
    require(outputAmount <= outputReserve, "LendingPair: insufficient reserves");

    _earnSwapInterest(_toToken, outputAmount);

    emit Swap(_fromToken, _toToken, _recipient, _inputAmount, outputAmount);

    return outputAmount;
  }

  function _depositRepay(address _token, uint _amount) internal {

    accrueAccount(msg.sender);

    uint debt = debtOf[_token][msg.sender];
    uint repayAmount = debt > _amount ? _amount : debt;

    if (repayAmount > 0) {
      _repay(_token, repayAmount);
    }

    uint depositAmount = _amount - repayAmount;

    if (depositAmount > 0) {
      _deposit(_token, depositAmount);
    }
  }

  function _withdrawBorrow(address _token, uint _amount) internal {

    accrueAccount(msg.sender);
    uint supplyAmount = lpToken[_token].balanceOf(msg.sender);
    uint withdrawAmount = supplyAmount > _amount ? _amount : supplyAmount;

    if (withdrawAmount > 0) {
      _withdraw(_token, withdrawAmount);
    }

    uint borrowAmount = _amount - withdrawAmount;

    if (borrowAmount > 0) {
      _borrow(_token, borrowAmount);
    }
  }

  function _earnSwapInterest(address _token, uint _amount) internal {
    uint earnedAmount = _amount * 3 / 1000;
    uint newInterest = earnedAmount * 1e18 / lpToken[_token].totalSupply();
    cumulativeInterestRate[_token] += newInterest;
  }

  function _mintDebt(address _token, address _account, uint _amount) internal {
    debtOf[_token][_account] += _amount;
    totalDebt[_token] += _amount;
  }

  function _burnDebt(address _token, address _account, uint _amount) internal {
    debtOf[_token][_account] -= _amount;
    totalDebt[_token] -= _amount;
  }

  function _delaySwapPrice(address _token) internal {
    storedSwapReserve[_token] = swapReserve(_token);
    swapTime[_token] = block.timestamp;
  }

  function _delayLendingPrice(address _token) internal {
    storedLendingReserve[_token] = lendingReserve(_token);
    lendingTime[_token] = block.timestamp;
  }

  function _liquidateToken(
    address _account,
    address _supplyToken,
    address _borrowToken
  ) internal returns(uint, uint) {

    uint accountSupply  = lpToken[_supplyToken].balanceOf(_account);
    uint accountDebt    = debtOf[_borrowToken][_account];
    uint supplyDebt     = convertTokenValues(_borrowToken, _supplyToken, accountDebt);
    uint supplyRequired = supplyDebt + supplyDebt * controller.liqFeesTotal() / 100e18;

    uint supplyBurn = supplyRequired > accountSupply ? accountSupply : supplyRequired;

    uint supplyBurnMinusFees = (supplyBurn * 100e18 / (100e18 + controller.liqFeesTotal()));
    uint systemFee = supplyBurnMinusFees * controller.liqFeeSystem() / 100e18;
    uint callerFee = supplyBurnMinusFees * controller.liqFeeCaller() / 100e18;

    lpToken[_supplyToken].burn(_account, supplyBurn);
    lpToken[_supplyToken].mint(feeRecipient(), systemFee);
    lpToken[_supplyToken].mint(msg.sender, callerFee);

    uint debtBurn = convertTokenValues(_supplyToken, _borrowToken, supplyBurnMinusFees);

    // Remove dust debt to allow full debt wipe
    if (debtBurn < accountDebt) {
      debtBurn = (accountDebt - debtBurn) < accountDebt / 10000 ? accountDebt : debtBurn;
    }

    _burnDebt(_borrowToken, _account, debtBurn);

    return (supplyBurn, debtBurn);
  }

  function _accrueAccount(address _account) internal {
    _accrueAccountSupply(tokenA, _account);
    _accrueAccountSupply(tokenB, _account);
    _accrueAccountDebt(tokenA, _account);
    _accrueAccountDebt(tokenB, _account);

    accountInterestSnapshot[tokenA][_account] = cumulativeInterestRate[tokenA];
    accountInterestSnapshot[tokenB][_account] = cumulativeInterestRate[tokenB];

    _accrueSystem(tokenA);
    _accrueSystem(tokenB);
  }

  // Accrue system interest from the total debt
  // Cannot use total supply since nobody may be supplying to that side (borrowing sold assets from another side)
  function _accrueSystem(address _token) internal {
    _ensureAccountInterestSnapshot(feeRecipient());
    uint systemInterest = _newInterest(totalDebt[_token], _token, feeRecipient());
    uint newSupply = systemInterest * _systemRate() / 100e18;
    lpToken[_token].mint(feeRecipient(), newSupply);
  }

  function _ensureAccountInterestSnapshot(address _account) internal {
    if (accountInterestSnapshot[tokenA][_account] == 0) {
      accountInterestSnapshot[tokenA][_account] = cumulativeInterestRate[tokenA];
    }

    if (accountInterestSnapshot[tokenB][_account] == 0) {
      accountInterestSnapshot[tokenB][_account] = cumulativeInterestRate[tokenB];
    }
  }

  function _accrueAccountSupply(address _token, address _account) internal {
    uint supplyInterest = pendingSupplyInterest(_token, _account);
    uint newSupply = supplyInterest * _systemRate() / 100e18;

    lpToken[_token].mint(_account, newSupply);
  }

  function _accrueAccountDebt(address _token, address _account) internal {
    uint newDebt = pendingBorrowInterest(_token, _account);
    _mintDebt(_token, _account, newDebt);
  }

  function _withdraw(address _token, uint _amount) internal {
    _validateToken(_token);

    _delaySwapPrice(_token);
    _delayLendingPrice(_token);

    lpToken[address(_token)].burn(msg.sender, _amount);

    checkAccountHealth(msg.sender);

    emit Withdraw(_token, _amount);
  }

  function _borrow(address _token, uint _amount) internal {
    _validateToken(_token);

    _delaySwapPrice(_token);
    _delayLendingPrice(_token);

    require(lpToken[address(_token)].balanceOf(msg.sender) == 0, "LendingPair: cannot borrow supplied token");

    _mintDebt(_token, msg.sender, _amount);

    checkAccountHealth(msg.sender);

    emit Borrow(_token, _amount);
  }

  function _repay(address _token, uint _amount) internal {
    _validateToken(_token);

    _delaySwapPrice(_token);
    _delayLendingPrice(_token);
    _burnDebt(_token, msg.sender, _amount);

    emit Repay(_token, _amount);
  }

  function _deposit(address _token, uint _amount) internal {
    _checkDepositLimit(_token, _amount);

    // Initialize on first deposit (pair creation).
    _initOrDelaySwapPrice(_token, _amount);
    _initOrDelayLendingPrice(_token, _amount);

    // Deposit is required to withdraw, borrow & repay so we only need to check this here.
    _ensureAccountInterestSnapshot(msg.sender);

    _validateToken(_token);
    require(debtOf[_token][msg.sender] == 0, "LendingPair: cannot deposit borrowed token");

    lpToken[address(_token)].mint(msg.sender, _amount);

    emit Deposit(_token, _amount);
  }

  function _accrueInterest(address _token) internal {
    uint timeElapsed = block.timestamp - lastTimeAccrued;
    uint newInterest = borrowRate(_token) / 365 days * timeElapsed;
    cumulativeInterestRate[_token] += newInterest;
  }

  function _initOrDelaySwapPrice(address _token, uint _amount) internal {
    if (storedSwapReserve[_token] == 0) {
      storedSwapReserve[_token] = _amount;
      swapTime[_token] = block.timestamp - controller.priceDelay();
    } else {
      _delaySwapPrice(_token);
    }
  }

  function _initOrDelayLendingPrice(address _token, uint _amount) internal {
    if (storedLendingReserve[_token] == 0) {
      storedLendingReserve[_token] = _amount;
      lendingTime[_token] = block.timestamp - controller.priceDelay();
    } else {
      _delayLendingPrice(_token);
    }
  }

  function _createLpToken(address _lpTokenMaster) internal returns(IERC20) {
    IERC20 newLPToken = IERC20(_lpTokenMaster.clone());
    newLPToken.initialize();
    return newLPToken;
  }

  function _timeShare(uint _timeElapsed) internal view returns(uint) {
    if (_timeElapsed > controller.slowPricePeriod()) {
      return _timeElapsed * 1e18 / controller.priceDelay();
    } else {
      return _timeElapsed * 1e18 / controller.slowPricePeriod() * controller.slowPriceRange() / 100e18;
    }
  }

  function _validateToken(address _token) internal view {
    require(_token == tokenA || _token == tokenB, "LendingPair: invalid token");
  }

  function _safeTransfer(IERC20 _token, address _recipient, uint _amount) internal {
    _token.transfer(_recipient, _amount);
    _checkMinReserve(_token);
  }

  function _checkMinReserve(IERC20 _token) internal view {
    require(_token.balanceOf(address(this)) >= MIN_RESERVE, "LendingPair: below MIN_RESERVE");
  }

  function _k() internal view returns(uint) {
    uint balanceA = IERC20(tokenA).balanceOf(address(this));
    uint balanceB = IERC20(tokenB).balanceOf(address(this));

    return balanceA * balanceB;
  }

  function _checkDepositLimit(address _token, uint _amount) internal view {
    uint depositLimit = controller.depositLimit(address(this), _token);

    if (depositLimit > 0) {
      require((lpToken[_token].totalSupply() + _amount) <= depositLimit, "LendingPair: deposit limit reached");
    }
  }

  function _systemRate() internal view returns(uint) {
    return controller.interestRateModel().systemRate(ILendingPair(address(this)));
  }

  function _newInterest(uint _balance, address _token, address _account) internal view returns(uint) {
    return _balance * (cumulativeInterestRate[_token] - accountInterestSnapshot[_token][_account]) / 1e18;
  }
}

contract InterestRateModel {

  uint private constant MIN_RATE  = 1e17;   // 0.1%
  uint private constant LOW_RATE  = 20e18;  // 20%
  uint private constant HIGH_RATE = 1000e18; // 1,000%

  uint private constant TARGET_UTILIZATION = 80e18; // 80%
  uint public constant  SYSTEM_RATE        = 50e18; // 50% - share of borrowRate earned by the system

  function supplyRate(ILendingPair _pair, address _token) public view returns(uint) {
    return borrowRate(_pair, _token) * SYSTEM_RATE / 100e18;
  }

  function borrowRate(ILendingPair _pair, address _token) public view returns(uint) {
    uint debt = _pair.totalDebt(_token);
    uint supply = IERC20(_pair.lpToken(_token)).totalSupply();

    if (supply == 0 || debt == 0) { return MIN_RATE; }

    uint utilization = _max(debt * 100e18 / supply, 100e18);

    if (utilization < TARGET_UTILIZATION) {
      uint rate = LOW_RATE * utilization / 100e18;
      return (rate < MIN_RATE) ? MIN_RATE : rate;
    } else {
      // (999 - (1000 * 0.8)) / (1000 * 0.2)
      utilization = 100e18 * ( debt - (supply * TARGET_UTILIZATION / 100e18) ) / (supply * (100e18 - TARGET_UTILIZATION) / 100e18);
      utilization = _max(utilization, 100e18);
      return LOW_RATE + (HIGH_RATE - LOW_RATE) * utilization / 100e18;
    }
  }

  function utilizationRate(ILendingPair _pair, address _token) public view returns(uint) {
    uint debt = _pair.totalDebt(_token);
    uint supply = IERC20(_pair.lpToken(_token)).totalSupply();

    if (supply == 0 || debt == 0) { return 0; }

    return _max(debt * 100e18 / supply, 100e18);
  }

  // InterestRateModel can later be replaced for more granular fees per _lendingPair
  function systemRate(ILendingPair _pair) public pure returns(uint) {
    return SYSTEM_RATE;
  }

  function _max(uint _valueA, uint _valueB) internal pure returns(uint) {
    return _valueA > _valueB ? _valueB : _valueA;
  }
}