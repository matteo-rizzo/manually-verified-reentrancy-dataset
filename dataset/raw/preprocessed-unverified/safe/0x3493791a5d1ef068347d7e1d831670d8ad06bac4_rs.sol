/**
 *Submitted for verification at Etherscan.io on 2021-05-15
*/

// SPDX-License-Identifier: UNLICENSED

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

  IWETH internal constant WETH = IWETH(0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2);

  function _safeTransferFrom(address _token, address _sender, uint _amount) internal virtual {
    IERC20(_token).transferFrom(_sender, address(this), _amount);
    require(_amount > 0, "TransferHelper: amount must be > 0");
  }

  function _wethWithdrawTo(address _to, uint _amount) internal virtual {
    require(_amount > 0, "TransferHelper: amount must be > 0");
    WETH.withdraw(_amount);
    (bool success, ) = _to.call { value: _amount }(new bytes(0));
    require(success, 'TransferHelper: ETH transfer failed');
  }

  function _depositWeth() internal {
    require(msg.value > 0, "TransferHelper: amount must be > 0");
    WETH.deposit { value: msg.value }();
  }
}

contract LendingPair is ReentrancyGuard, TransferHelper {

  // Prevents division by zero and other undesirable behaviour
  uint public constant MIN_RESERVE = 1000;

  using Address for address;
  using Clones for address;

  mapping (address => mapping (address => uint)) public debtOf;
  mapping (address => mapping (address => uint)) public accountInterestSnapshot;
  mapping (address => uint) public cumulativeInterestRate; // 100e18 = 100%
  mapping (address => uint) public totalDebt;
  mapping (address => IERC20) public lpToken;

  IController public controller;
  address public tokenA;
  address public tokenB;
  uint public lastBlockAccrued;

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
    lastBlockAccrued = block.number;

    lpToken[tokenA] = _createLpToken(_lpTokenMaster);
    lpToken[tokenB] = _createLpToken(_lpTokenMaster);
  }

  function depositRepay(address _token, uint _amount) public {
    _validateToken(_token);
    accrueAccount(msg.sender);

    _depositRepay(_token, _amount);
    _safeTransferFrom(_token, msg.sender, _amount);
  }

  function depositRepayETH() public payable {
    accrueAccount(msg.sender);

    _depositRepay(address(WETH), msg.value);
    _depositWeth();
  }

  function deposit(address _token, uint _amount) public {
    _validateToken(_token);
    accrueAccount(msg.sender);

    _deposit(_token, _amount);
    _safeTransferFrom(_token, msg.sender, _amount);
  }

  function withdrawBorrow(address _token, uint _amount) public {
    _validateToken(_token);
    accrueAccount(msg.sender);

    _withdrawBorrow(_token, _amount);
    _safeTransfer(IERC20(_token), msg.sender, _amount);
  }

  function withdrawBorrowETH(uint _amount) public {
    accrueAccount(msg.sender);

    _withdrawBorrow(address(WETH), _amount);
    _wethWithdrawTo(msg.sender, _amount);
    _checkMinReserve(address(WETH));
  }

  function withdraw(address _token, uint _amount) public {
    _validateToken(_token);
    accrueAccount(msg.sender);

    _withdraw(_token, _amount);
    _safeTransfer(IERC20(_token), msg.sender, _amount);
  }

  function withdrawAll(address _token) public {
    _validateToken(_token);
    accrueAccount(msg.sender);

    uint amount = lpToken[address(_token)].balanceOf(msg.sender);
    _withdraw(_token, amount);
    _safeTransfer(IERC20(_token), msg.sender, amount);
  }

  function borrow(address _token, uint _amount) public {
    _validateToken(_token);
    accrueAccount(msg.sender);

    _borrow(_token, _amount);
    _safeTransfer(IERC20(_token), msg.sender, _amount);
  }

  function repayAll(address _token) public {
    _validateToken(_token);
    accrueAccount(msg.sender);

    uint amount = debtOf[_token][msg.sender];
    _repay(_token, amount);
    _safeTransferFrom(_token, msg.sender, amount);
  }

  function repay(address _token, uint _amount) public {
    _validateToken(_token);
    accrueAccount(msg.sender);

    _repay(_token, _amount);
    _safeTransferFrom(_token, msg.sender, _amount);
  }

  function accrue() public {
    if (lastBlockAccrued < block.number) {
      _accrueInterest(tokenA);
      _accrueInterest(tokenB);
      lastBlockAccrued = block.number;
    }
  }

  function accrueAccount(address _account) public {
    accrue();
    _accrueAccountInterest(feeRecipient());
    _accrueAccountInterest(_account);
  }

  function accountHealth(address _account) public view returns(uint) {
    uint totalAccountSupply  = _supplyBalance(_account, tokenA, tokenA) + _supplyBalance(_account, tokenB, tokenA);
    uint totalAccountBorrrow = _borrowBalance(_account, tokenA, tokenA) + _borrowBalance(_account, tokenB, tokenA);

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

    _validateToken(_borrowedToken);
    _validateToken(_returnToken);

    return _borrowBalance(_account, _borrowedToken, _returnToken);
  }

  function supplyBalance(
    address _account,
    address _suppliedToken,
    address _returnToken
  ) public view returns(uint) {

    _validateToken(_suppliedToken);
    _validateToken(_returnToken);

    return _supplyBalance(_account, _suppliedToken, _returnToken);
  }

  function supplyRatePerBlock(address _token) public view returns(uint) {
    _validateToken(_token);
    return controller.interestRateModel().supplyRatePerBlock(ILendingPair(address(this)), _token);
  }

  function borrowRatePerBlock(address _token) public view returns(uint) {
    _validateToken(_token);
    return _borrowRatePerBlock(_token);
  }

  // Sell collateral to reduce debt and increase accountHealth
  function liquidateAccount(address _account) public {

    _accrueAccountInterest(_account);
    _accrueAccountInterest(msg.sender);
    _accrueAccountInterest(feeRecipient());

    uint health = accountHealth(_account);
    require(health < controller.liqMinHealth(), "LendingPair: account health > liqMinHealth");

    (uint supplyBurnA, uint borrowBurnA) = _liquidateToken(_account, tokenA, tokenB);
    (uint supplyBurnB, uint borrowBurnB) = _liquidateToken(_account, tokenB, tokenA);

    emit Liquidation(_account, supplyBurnA, supplyBurnB, borrowBurnA, borrowBurnB);
  }

  function pendingSupplyInterest(address _token, address _account) public view returns(uint) {
    _validateToken(_token);
    uint newInterest = _newInterest(lpToken[_token].balanceOf(_account), _token, _account);
    return newInterest * _lpRate() / 100e18;
  }

  function pendingBorrowInterest(address _token, address _account) public view returns(uint) {
    _validateToken(_token);
    return _pendingBorrowInterest(_token, _account);
  }

  function feeRecipient() public view returns(address) {
    return controller.feeRecipient();
  }

  function checkAccountHealth(address _account) public view  {
    uint health = accountHealth(_account);
    require(health >= controller.liqMinHealth(), "LendingPair: insufficient accountHealth");
  }

  function convertTokenValues(
    address _fromToken,
    address _toToken,
    uint    _inputAmount
  ) public view returns(uint) {

    _validateToken(_fromToken);
    _validateToken(_toToken);

    return _convertTokenValues(_fromToken, _toToken, _inputAmount);
  }

  function _depositRepay(address _token, uint _amount) internal {

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

  function _mintDebt(address _token, address _account, uint _amount) internal {
    debtOf[_token][_account] += _amount;
    totalDebt[_token] += _amount;
  }

  function _burnDebt(address _token, address _account, uint _amount) internal {
    debtOf[_token][_account] -= _amount;
    totalDebt[_token] -= _amount;
  }

  function _liquidateToken(
    address _account,
    address _supplyToken,
    address _borrowToken
  ) internal returns(uint, uint) {

    uint accountSupply  = lpToken[_supplyToken].balanceOf(_account);
    uint accountDebt    = debtOf[_borrowToken][_account];
    uint supplyDebt     = _convertTokenValues(_borrowToken, _supplyToken, accountDebt);
    uint supplyRequired = supplyDebt + supplyDebt * controller.liqFeesTotal() / 100e18;

    uint supplyBurn = supplyRequired > accountSupply ? accountSupply : supplyRequired;

    uint supplyBurnMinusFees = supplyBurn * 100e18 / (100e18 + controller.liqFeesTotal());
    uint systemFee = supplyBurnMinusFees * controller.liqFeeSystem() / 100e18;
    uint callerFee = supplyBurnMinusFees * controller.liqFeeCaller() / 100e18;

    lpToken[_supplyToken].burn(_account, supplyBurn);
    lpToken[_supplyToken].mint(msg.sender, callerFee);
    lpToken[_supplyToken].mint(feeRecipient(), systemFee);

    _burnDebt(_borrowToken, _account, accountDebt);

    return (supplyBurn, accountDebt);
  }

  function _accrueAccountInterest(address _account) internal {
    uint lpBalanceA = lpToken[tokenA].balanceOf(_account);
    uint lpBalanceB = lpToken[tokenB].balanceOf(_account);

    _accrueAccountSupply(tokenA, lpBalanceA, _account);
    _accrueAccountSupply(tokenB, lpBalanceB, _account);
    _accrueAccountDebt(tokenA, _account);
    _accrueAccountDebt(tokenB, _account);

    accountInterestSnapshot[tokenA][_account] = cumulativeInterestRate[tokenA];
    accountInterestSnapshot[tokenB][_account] = cumulativeInterestRate[tokenB];
  }

  function _accrueAccountSupply(address _token, uint _amount, address _account) internal {
    uint supplyInterest   = _newInterest(_amount, _token, _account);
    uint newSupplyAccount = supplyInterest * _lpRate() / 100e18;
    uint newSupplySystem  = supplyInterest * _systemRate() / 100e18;

    lpToken[_token].mint(_account, newSupplyAccount);
    lpToken[_token].mint(feeRecipient(), newSupplySystem);
  }

  function _accrueAccountDebt(address _token, address _account) internal {
    uint newDebt = _pendingBorrowInterest(_token, _account);
    _mintDebt(_token, _account, newDebt);
  }

  function _withdraw(address _token, uint _amount) internal {

    lpToken[address(_token)].burn(msg.sender, _amount);

    checkAccountHealth(msg.sender);

    emit Withdraw(_token, _amount);
  }

  function _borrow(address _token, uint _amount) internal {

    require(lpToken[address(_token)].balanceOf(msg.sender) == 0, "LendingPair: cannot borrow supplied token");

    _mintDebt(_token, msg.sender, _amount);

    checkAccountHealth(msg.sender);

    emit Borrow(_token, _amount);
  }

  function _repay(address _token, uint _amount) internal {
    _burnDebt(_token, msg.sender, _amount);

    emit Repay(_token, _amount);
  }

  function _deposit(address _token, uint _amount) internal {
    _checkDepositLimit(_token, _amount);

    require(debtOf[_token][msg.sender] == 0, "LendingPair: cannot deposit borrowed token");

    lpToken[address(_token)].mint(msg.sender, _amount);

    emit Deposit(_token, _amount);
  }

  function _accrueInterest(address _token) internal {
    uint blocksElapsed = block.number - lastBlockAccrued;
    uint newInterest = _borrowRatePerBlock(_token) * blocksElapsed;
    cumulativeInterestRate[_token] += newInterest;
  }

  function _createLpToken(address _lpTokenMaster) internal returns(IERC20) {
    IERC20 newLPToken = IERC20(_lpTokenMaster.clone());
    newLPToken.initialize();
    return newLPToken;
  }

  function _safeTransfer(IERC20 _token, address _recipient, uint _amount) internal {
    _token.transfer(_recipient, _amount);
    _checkMinReserve(address(_token));
  }

  function _wethWithdrawTo(address _to, uint _amount) internal override {
    TransferHelper._wethWithdrawTo(_to, _amount);
    _checkMinReserve(address(WETH));
  }

  function _borrowRatePerBlock(address _token) internal view returns(uint) {
    return controller.interestRateModel().borrowRatePerBlock(ILendingPair(address(this)), _token);
  }

  function _pendingBorrowInterest(address _token, address _account) internal view returns(uint) {
    return _newInterest(debtOf[_token][_account], _token, _account);
  }

  function _borrowBalance(
    address _account,
    address _borrowedToken,
    address _returnToken
  ) internal view returns(uint) {

    return _convertTokenValues(_borrowedToken, _returnToken, debtOf[_borrowedToken][_account]);
  }

  // Get supply balance converted to the units of _returnToken
  function _supplyBalance(
    address _account,
    address _suppliedToken,
    address _returnToken
  ) internal view returns(uint) {

    return _convertTokenValues(_suppliedToken, _returnToken, lpToken[_suppliedToken].balanceOf(_account));
  }

  function _convertTokenValues(
    address _fromToken,
    address _toToken,
    uint    _inputAmount
  ) internal view returns(uint) {

    uint priceFrom = controller.tokenPrice(_fromToken) * 1e18 / 10 ** IERC20(_fromToken).decimals();
    uint priceTo   = controller.tokenPrice(_toToken)   * 1e18 / 10 ** IERC20(_toToken).decimals();

    return _inputAmount * priceFrom / priceTo;
  }

  function _validateToken(address _token) internal view {
    require(_token == tokenA || _token == tokenB, "LendingPair: invalid token");
  }

  function _checkMinReserve(address _token) internal view {
    require(IERC20(_token).balanceOf(address(this)) >= MIN_RESERVE, "LendingPair: below MIN_RESERVE");
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

  function _lpRate() internal view returns(uint) {
    return 100e18 - _systemRate();
  }

  function _newInterest(uint _balance, address _token, address _account) internal view returns(uint) {
    return _balance * (cumulativeInterestRate[_token] - accountInterestSnapshot[_token][_account]) / 100e18;
  }
}