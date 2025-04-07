/**
 *Submitted for verification at Etherscan.io on 2021-07-21
*/

// SPDX-License-Identifier: UNLICENSED

pragma solidity 0.8.6;

















interface ILPTokenMaster is IERC20 {
  function initialize() external;
  function transferOwnership(address newOwner) external;
  function underlying() external view returns(address);
  function owner() external view returns(address);
  function lendingPair() external view returns(address);
  function selfBurn(uint _amount) external;
}







contract ERC20 is Ownable {

  event Transfer(address indexed from, address indexed to, uint value);
  event Approval(address indexed owner, address indexed spender, uint value);

  mapping (address => uint) public balanceOf;
  mapping (address => mapping (address => uint)) public allowance;

  string public name;
  string public symbol;
  uint8 public immutable decimals;
  uint public totalSupply;

  constructor(
    string memory _name,
    string memory _symbol,
    uint8 _decimals
  ) {
    name = _name;
    symbol = _symbol;
    decimals = _decimals;
    require(_decimals > 0, "decimals");
  }

  function transfer(address _recipient, uint _amount) external returns (bool) {
    _transfer(msg.sender, _recipient, _amount);
    return true;
  }

  function approve(address _spender, uint _amount) external returns (bool) {
    _approve(msg.sender, _spender, _amount);
    return true;
  }

  function transferFrom(address _sender, address _recipient, uint _amount) external returns (bool) {
    require(allowance[_sender][msg.sender] >= _amount, "ERC20: insufficient approval");
    _transfer(_sender, _recipient, _amount);
    _approve(_sender, msg.sender, allowance[_sender][msg.sender] - _amount);
    return true;
  }

  function mint(address _account, uint _amount) external onlyOwner {
    _mint(_account, _amount);
  }

  function burn(address _account, uint _amount) external onlyOwner {
    _burn(_account, _amount);
  }

  function _transfer(address _sender, address _recipient, uint _amount) internal {
    require(_sender != address(0), "ERC20: transfer from the zero address");
    require(_recipient != address(0), "ERC20: transfer to the zero address");
    require(balanceOf[_sender] >= _amount, "ERC20: insufficient funds");

    balanceOf[_sender] -= _amount;
    balanceOf[_recipient] += _amount;
    emit Transfer(_sender, _recipient, _amount);
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

contract TransferHelper {

  using SafeERC20 for IERC20;

  // Mainnet
  IWETH internal constant WETH = IWETH(0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2);

  // Kovan
  // IWETH internal constant WETH = IWETH(0xd0A1E359811322d97991E03f863a0C30C2cF029C);

  function _safeTransferFrom(address _token, address _sender, uint _amount) internal virtual {
    require(_amount > 0, "TransferHelper: amount must be > 0");
    IERC20(_token).safeTransferFrom(_sender, address(this), _amount);
  }

  function _safeTransfer(address _token, address _recipient, uint _amount) internal virtual {
    require(_amount > 0, "TransferHelper: amount must be > 0");
    IERC20(_token).safeTransfer(_recipient, _amount);
  }

  function _wethWithdrawTo(address _to, uint _amount) internal virtual {
    require(_amount > 0, "TransferHelper: amount must be > 0");
    require(_to != address(0), "TransferHelper: invalid recipient");

    WETH.withdraw(_amount);
    (bool success, ) = _to.call { value: _amount }(new bytes(0));
    require(success, 'TransferHelper: ETH transfer failed');
  }

  function _depositWeth() internal {
    require(msg.value > 0, "TransferHelper: amount must be > 0");
    WETH.deposit { value: msg.value }();
  }
}

contract LendingPair is TransferHelper, ReentrancyGuard {

  // Prevents division by zero and other undesirable behaviour
  uint private constant MIN_RESERVE = 1000;

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
    address indexed repayToken,
    address indexed supplyToken,
    uint repayAmount,
    uint supplyAmount
  );

  event Deposit(address indexed account, address indexed token, uint amount);
  event Withdraw(address indexed token, uint amount);
  event Borrow(address indexed token, uint amount);
  event Repay(address indexed account, address indexed token, uint amount);

  receive() external payable {}

  function initialize(
    address _lpTokenMaster,
    address _controller,
    IERC20 _tokenA,
    IERC20 _tokenB
  ) external {
    require(address(tokenA) == address(0), "LendingPair: already initialized");
    require(address(_tokenA) != address(0) && address(_tokenB) != address(0), "LendingPair: cannot be ZERO address");

    controller = IController(_controller);
    tokenA = address(_tokenA);
    tokenB = address(_tokenB);
    lastBlockAccrued = block.number;

    lpToken[tokenA] = _createLpToken(_lpTokenMaster);
    lpToken[tokenB] = _createLpToken(_lpTokenMaster);
  }

  function depositRepay(address _account, address _token, uint _amount) external nonReentrant {
    _validateToken(_token);
    accrueAccount(_account);

    _depositRepay(_account, _token, _amount);
    _safeTransferFrom(_token, msg.sender, _amount);
  }

  function depositRepayETH(address _account) external payable nonReentrant {
    _validateToken(address(WETH));
    accrueAccount(_account);

    _depositRepay(_account, address(WETH), msg.value);
    _depositWeth();
  }

  function deposit(address _account, address _token, uint _amount) external nonReentrant {
    _validateToken(_token);
    accrueAccount(_account);

    _deposit(_account, _token, _amount);
    _safeTransferFrom(_token, msg.sender, _amount);
  }

  function withdrawBorrow(address _token, uint _amount) external nonReentrant {
    _validateToken(_token);
    accrueAccount(msg.sender);

    _withdrawBorrow(_token, _amount);
    _safeTransfer(_token, msg.sender, _amount);
  }

  function withdrawBorrowETH(uint _amount) external nonReentrant {
    _validateToken(address(WETH));
    accrueAccount(msg.sender);

    _withdrawBorrow(address(WETH), _amount);
    _wethWithdrawTo(msg.sender, _amount);
  }

  function withdraw(address _token, uint _amount) external nonReentrant {
    _validateToken(_token);
    accrueAccount(msg.sender);

    _withdraw(_token, _amount);
    _safeTransfer(_token, msg.sender, _amount);
  }

  function withdrawAll(address _token) external nonReentrant {
    _validateToken(_token);
    accrueAccount(msg.sender);

    uint amount = lpToken[_token].balanceOf(msg.sender);
    _withdraw(_token, amount);
    _safeTransfer(_token, msg.sender, amount);
  }

  function withdrawAllETH() external nonReentrant {
    _validateToken(address(WETH));
    accrueAccount(msg.sender);

    uint amount = lpToken[address(WETH)].balanceOf(msg.sender);
    _withdraw(address(WETH), amount);
    _wethWithdrawTo(msg.sender, amount);
  }

  function borrow(address _token, uint _amount) external nonReentrant {
    _validateToken(_token);
    accrueAccount(msg.sender);

    _borrow(_token, _amount);
    _safeTransfer(_token, msg.sender, _amount);
  }

  function repayAll(address _account, address _token) external nonReentrant {
    _validateToken(_token);
    _requireAccountNotAccrued(_token, _account);
    accrueAccount(_account);

    uint amount = debtOf[_token][_account];
    _repay(_account, _token, amount);
    _safeTransferFrom(_token, msg.sender, amount);
  }

  function repayAllETH(address _account) external payable nonReentrant {
    _validateToken(address(WETH));
    _requireAccountNotAccrued(address(WETH), _account);
    accrueAccount(_account);

    uint amount = debtOf[address(WETH)][_account];
    require(msg.value >= amount, "LendingPair: insufficient ETH deposit");

    _depositWeth();
    _repay(_account, address(WETH), amount);
    uint refundAmount = msg.value > amount ? (msg.value - amount) : 0;

    if (refundAmount > 0) {
      _wethWithdrawTo(msg.sender, refundAmount);
    }
  }

  function repay(address _account, address _token, uint _amount) external nonReentrant {
    _validateToken(_token);
    accrueAccount(_account);

    _repay(_account, _token, _amount);
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
    _distributeReward(_account);
    accrue();
    _accrueAccountInterest(_account);

    if (_account != feeRecipient()) {
      _accrueAccountInterest(feeRecipient());
    }
  }

  // Sell collateral to reduce debt and increase accountHealth
  // Set _repayAmount to uint(-1) to repay all debt, inc. pending interest
  function liquidateAccount(
    address _account,
    address _repayToken,
    uint    _repayAmount,
    uint    _minSupplyOutput
  ) external nonReentrant {

    // Input validation and adjustments

    _validateToken(_repayToken);
    address supplyToken = _repayToken == tokenA ? tokenB : tokenA;

    // Check account is underwater after interest

    accrueAccount(_account);
    uint health = accountHealth(_account);
    require(health < controller.LIQ_MIN_HEALTH(), "LendingPair: account health < LIQ_MIN_HEALTH");

    // Calculate balance adjustments

    _repayAmount = Math.min(_repayAmount, debtOf[_repayToken][_account]);

    uint supplyDebt   = _convertTokenValues(_repayToken, supplyToken, _repayAmount);
    uint callerFee    = supplyDebt * controller.liqFeeCaller(_repayToken) / 100e18;
    uint systemFee    = supplyDebt * controller.liqFeeSystem(_repayToken) / 100e18;
    uint supplyBurn   = supplyDebt + callerFee + systemFee;
    uint supplyOutput = supplyDebt + callerFee;

    require(supplyOutput >= _minSupplyOutput, "LendingPair: supplyOutput >= _minSupplyOutput");

    // Adjust balances

    _burnSupply(supplyToken, _account, supplyBurn);
    _mintSupply(supplyToken, feeRecipient(), systemFee);
    _burnDebt(_repayToken, _account, _repayAmount);

    // Settle token transfers

    _safeTransferFrom(_repayToken, msg.sender, _repayAmount);
    _mintSupply(supplyToken, msg.sender, supplyOutput);

    emit Liquidation(_account, _repayToken, supplyToken, _repayAmount, supplyOutput);
  }

  function accountHealth(address _account) public view returns(uint) {

    if (debtOf[tokenA][_account] == 0 && debtOf[tokenB][_account] == 0) {
      return controller.LIQ_MIN_HEALTH();
    }

    uint totalAccountSupply  = _supplyCredit(_account, tokenA, tokenA)  + _supplyCredit(_account, tokenB, tokenA);
    uint totalAccountBorrow = _borrowBalance(_account, tokenA, tokenA) + _borrowBalance(_account, tokenB, tokenA);

    return totalAccountSupply * 1e18 / totalAccountBorrow;
  }

  // Get borow balance converted to the units of _returnToken
  function borrowBalance(
    address _account,
    address _borrowedToken,
    address _returnToken
  ) external view returns(uint) {

    _validateToken(_borrowedToken);
    _validateToken(_returnToken);

    return _borrowBalance(_account, _borrowedToken, _returnToken);
  }

  function supplyBalance(
    address _account,
    address _suppliedToken,
    address _returnToken
  ) external view returns(uint) {

    _validateToken(_suppliedToken);
    _validateToken(_returnToken);

    return _supplyBalance(_account, _suppliedToken, _returnToken);
  }

  function supplyRatePerBlock(address _token) external view returns(uint) {
    _validateToken(_token);
    return controller.interestRateModel().supplyRatePerBlock(ILendingPair(address(this)), _token);
  }

  function borrowRatePerBlock(address _token) external view returns(uint) {
    _validateToken(_token);
    return _borrowRatePerBlock(_token);
  }

  function pendingSupplyInterest(address _token, address _account) external view returns(uint) {
    _validateToken(_token);
    uint newInterest = _newInterest(lpToken[_token].balanceOf(_account), _token, _account);
    return newInterest * _lpRate(_token) / 100e18;
  }

  function pendingBorrowInterest(address _token, address _account) external view returns(uint) {
    _validateToken(_token);
    return _pendingBorrowInterest(_token, _account);
  }

  function feeRecipient() public view returns(address) {
    return controller.feeRecipient();
  }

  function checkAccountHealth(address _account) public view  {
    uint health = accountHealth(_account);
    require(health >= controller.LIQ_MIN_HEALTH(), "LendingPair: insufficient accountHealth");
  }

  function convertTokenValues(
    address _fromToken,
    address _toToken,
    uint    _inputAmount
  ) external view returns(uint) {

    _validateToken(_fromToken);
    _validateToken(_toToken);

    return _convertTokenValues(_fromToken, _toToken, _inputAmount);
  }

  function _depositRepay(address _account, address _token, uint _amount) internal {

    uint debt = debtOf[_token][_account];
    uint repayAmount = debt > _amount ? _amount : debt;

    if (repayAmount > 0) {
      _repay(_account, _token, repayAmount);
    }

    uint depositAmount = _amount - repayAmount;

    if (depositAmount > 0) {
      _deposit(_account, _token, depositAmount);
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

  function _distributeReward(address _account) internal {
    IRewardDistribution rewardDistribution = controller.rewardDistribution();

    if (
      address(rewardDistribution) != address(0) &&
      _account != feeRecipient()
    ) {
      rewardDistribution.distributeReward(_account, tokenA);
      rewardDistribution.distributeReward(_account, tokenB);
    }
  }

  function _mintSupply(address _token, address _account, uint _amount) internal {
    if (_amount > 0) {
      lpToken[_token].mint(_account, _amount);
    }
  }

  function _burnSupply(address _token, address _account, uint _amount) internal {
    if (_amount > 0) {
      lpToken[_token].burn(_account, _amount);
    }
  }

  function _mintDebt(address _token, address _account, uint _amount) internal {
    debtOf[_token][_account] += _amount;
    totalDebt[_token] += _amount;
  }

  // Origination fee is earned entirely by the protocol and is not split with the LPs
  // The goal is to prevent free flash loans
  function _mintDebtWithOriginFee(address _token, address _account, uint _amount) internal {
    uint originFee = _originationFee(_token, _amount);
    _mintSupply(_token, feeRecipient(), originFee);
    _mintDebt(_token, _account, _amount + originFee);
  }

  function _burnDebt(address _token, address _account, uint _amount) internal {
    debtOf[_token][_account] -= _amount;
    totalDebt[_token] -= _amount;
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
    if (_amount > 0) {
      uint supplyInterest   = _newInterest(_amount, _token, _account);
      uint newSupplyAccount = supplyInterest * _lpRate(_token) / 100e18;
      uint newSupplySystem  = supplyInterest * _systemRate(_token) / 100e18;

      _mintSupply(_token, _account, newSupplyAccount);
      _mintSupply(_token, feeRecipient(), newSupplySystem);
    }
  }

  function _accrueAccountDebt(address _token, address _account) internal {
    if (debtOf[_token][_account] > 0) {
      uint newDebt = _pendingBorrowInterest(_token, _account);
      _mintDebt(_token, _account, newDebt);
    }
  }

  function _withdraw(address _token, uint _amount) internal {

    lpToken[_token].burn(msg.sender, _amount);

    checkAccountHealth(msg.sender);

    emit Withdraw(_token, _amount);
  }

  function _borrow(address _token, uint _amount) internal {

    require(lpToken[_token].balanceOf(msg.sender) == 0, "LendingPair: cannot borrow supplied token");

    _mintDebtWithOriginFee(_token, msg.sender, _amount);

    _checkBorrowLimits(_token, msg.sender);
    checkAccountHealth(msg.sender);

    emit Borrow(_token, _amount);
  }

  function _repay(address _account, address _token, uint _amount) internal {
    _burnDebt(_token, _account, _amount);
    emit Repay(_account, _token, _amount);
  }

  function _deposit(address _account, address _token, uint _amount) internal {

    _checkOracleSupport(tokenA);
    _checkOracleSupport(tokenB);

    require(debtOf[_token][_account] == 0, "LendingPair: cannot deposit borrowed token");

    _mintSupply(_token, _account, _amount);
    _checkDepositLimit(_token);

    emit Deposit(_account, _token, _amount);
  }

  function _accrueInterest(address _token) internal {
    cumulativeInterestRate[_token] += _pendingInterestRate(_token);
  }

  function _pendingInterestRate(address _token) internal view returns(uint) {
    uint blocksElapsed = block.number - lastBlockAccrued;
    return _borrowRatePerBlock(_token) * blocksElapsed;
  }

  function _createLpToken(address _lpTokenMaster) internal returns(IERC20) {
    ILPTokenMaster newLPToken = ILPTokenMaster(_lpTokenMaster.clone());
    newLPToken.initialize();
    return IERC20(newLPToken);
  }

  function _safeTransfer(address _token, address _recipient, uint _amount) internal override {
    TransferHelper._safeTransfer(_token, _recipient, _amount);
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

  function _supplyCredit(
    address _account,
    address _suppliedToken,
    address _returnToken
  ) internal view returns(uint) {

    return _supplyBalance(_account, _suppliedToken, _returnToken) * controller.colFactor(_suppliedToken) / 100e18;
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

  function _checkOracleSupport(address _token) internal view {
    require(controller.tokenSupported(_token), "LendingPair: token not supported");
  }

  function _checkMinReserve(address _token) internal view {
    require(IERC20(_token).balanceOf(address(this)) >= MIN_RESERVE, "LendingPair: below MIN_RESERVE");
  }

  function _checkDepositLimit(address _token) internal view {
    require(controller.depositsEnabled(), "LendingPair: deposits disabled");

    uint depositLimit = controller.depositLimit(address(this), _token);

    if (depositLimit > 0) {
      require((lpToken[_token].totalSupply()) <= depositLimit, "LendingPair: deposit limit reached");
    }
  }

  function _checkBorrowLimits(address _token, address _account) internal view {
    require(controller.borrowingEnabled(), "LendingPair: borrowing disabled");

    uint accountBorrowUSD = debtOf[_token][_account] * controller.tokenPrice(_token) / 1e18;
    require(accountBorrowUSD >= controller.minBorrowUSD(), "LendingPair: borrow amount below minimum");

    uint borrowLimit = controller.borrowLimit(address(this), _token);

    if (borrowLimit > 0) {
      require(totalDebt[_token] <= borrowLimit, "LendingPair: borrow limit reached");
    }
  }

  function _originationFee(address _token, uint _amount) internal view returns(uint) {
    return _amount * controller.originFee(_token) / 100e18;
  }

  function _systemRate(address _token) internal view returns(uint) {
    return controller.interestRateModel().systemRate(ILendingPair(address(this)), _token);
  }

  function _lpRate(address _token) internal view returns(uint) {
    return 100e18 - _systemRate(_token);
  }

  function _newInterest(uint _balance, address _token, address _account) internal view returns(uint) {
    uint currentCumulativeRate = cumulativeInterestRate[_token] + _pendingInterestRate(_token);
    return _balance * (currentCumulativeRate - accountInterestSnapshot[_token][_account]) / 100e18;
  }

  // Used in repayAll and repayAllETH to prevent front-running
  // Potential attack:
  // Recipient account watches the mempool and takes out a large loan just before someone calls repayAll.
  // As a result, paying account would end up paying much more than anticipated
  function _requireAccountNotAccrued(address _token, address _account) internal view {
    if (lastBlockAccrued == block.number && cumulativeInterestRate[_token] > 0) {
      require(
        cumulativeInterestRate[_token] > accountInterestSnapshot[_token][_account],
        "LendingPair: account already accrued"
      );
    }
  }
}

contract PairFactory is Ownable {

  uint private constant MAX_INT = 2**256 - 1;

  using Address for address;
  using Clones for address;

  address public lendingPairMaster;
  address public lpTokenMaster;
  IController public controller;

  mapping(address => mapping(address => address)) public pairByTokens;

  event PairCreated(address indexed pair, address indexed tokenA, address indexed tokenB);

  constructor(
    address _lendingPairMaster,
    address _lpTokenMaster,
    IController _controller
  ) {
    lendingPairMaster = _lendingPairMaster;
    lpTokenMaster = _lpTokenMaster;
    controller = _controller;
  }

  function createPair(
    address _tokenA,
    address _tokenB
  ) external returns(address) {

    require(_tokenA != _tokenB, 'PairFactory: duplicate tokens');
    require(_tokenA != address(0) && _tokenB != address(0), 'PairFactory: zero address');
    require(pairByTokens[_tokenA][_tokenB] == address(0), 'PairFactory: already exists');

    require(
      controller.tokenSupported(_tokenA) && controller.tokenSupported(_tokenB),
      "PairFactory: token not supported"
    );

    LendingPair lendingPair = LendingPair(payable(lendingPairMaster.clone()));
    lendingPair.initialize(lpTokenMaster, address(controller), IERC20(_tokenA), IERC20(_tokenB));
    pairByTokens[_tokenA][_tokenB] = address(lendingPair);
    pairByTokens[_tokenB][_tokenA] = address(lendingPair);

    emit PairCreated(address(lendingPair), _tokenA, _tokenB);

    return address(lendingPair);
  }
}