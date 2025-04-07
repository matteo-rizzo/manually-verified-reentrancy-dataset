/**
 *Submitted for verification at Etherscan.io on 2021-08-17
*/

// SPDX-License-Identifier: UNLICENSED

pragma solidity 0.8.6;







contract ERC20 {

  event Transfer(address indexed from, address indexed to, uint value);
  event Approval(address indexed owner, address indexed spender, uint value);

  mapping (address => uint) public balanceOf;
  mapping (address => mapping (address => uint)) public allowance;

  string public name;
  string public symbol;
  uint8  public decimals;
  uint   public totalSupply;

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

  function _transfer(address _sender, address _recipient, uint _amount) internal virtual {
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


// Vault holds all the funds
// Rebalancer transforms the funds and can be replaced

contract Vault is TransferHelper, ReentrancyGuard, ERC20("X", "X", 18) {

  uint private constant DISTRIBUTION_PERIOD = 45_800; // ~ 7 days

  address public vaultController;
  address public underlying;

  bool private initialized;
  uint private rewardPerToken;
  uint private lastAccrualBlock;
  uint private lastIncomeBlock;
  uint private rewardRateStored;

  mapping (address => uint) private rewardSnapshot;

  event Claim(address indexed account, uint amount);
  event NewIncome(uint addAmount, uint rewardRate);
  event NewRebalancer(address indexed rebalancer);
  event Deposit(uint amount);
  event Withdraw(uint amount);

  modifier onlyRebalancer() {
    require(msg.sender == address(rebalancer()), "Vault: caller is not the rebalancer");
    _;
  }

  receive() external payable {}

  function initialize(
    address       _vaultController,
    address       _underlying,
    string memory _name
  ) external {

    require(initialized != true, "Vault: already intialized");
    initialized = true;

    vaultController = _vaultController;
    underlying      = _underlying;

    name     = _name;
    symbol   = _name;
  }

  function depositETH(address _account) external payable nonReentrant {
    _checkEthVault();
    _depositWeth();
    _deposit(_account, msg.value);
  }

  function deposit(
    address _account,
    uint    _amount
  ) external nonReentrant {
    _safeTransferFrom(underlying, msg.sender, _amount);
    _deposit(_account, _amount);
  }

  // Withdraw from the buffer
  function withdraw(uint _amount) external nonReentrant {
    _withdraw(msg.sender, _amount);
    _safeTransfer(underlying, msg.sender, _amount);
  }

  function withdrawAll() external nonReentrant {
    uint amount = _withdrawAll(msg.sender);
    _safeTransfer(underlying, msg.sender, amount);
  }

  function withdrawAllETH() external nonReentrant {
    _checkEthVault();
    uint amount = _withdrawAll(msg.sender);
    _wethWithdrawTo(msg.sender, amount);
  }

  function withdrawETH(uint _amount) external nonReentrant {
    _checkEthVault();
    _withdraw(msg.sender, _amount);
    _wethWithdrawTo(msg.sender, _amount);
  }

  // Withdraw from a specific source
  // Call this only if the vault doesn't have enough funds in the buffer
  function withdrawFrom(
    address _source,
    uint    _amount
  ) external nonReentrant {
    _withdrawFrom(_source, _amount);
    _safeTransfer(underlying, msg.sender, _amount);
  }

  function withdrawFromETH(
    address _source,
    uint    _amount
  ) external nonReentrant {
    _checkEthVault();
    _withdrawFrom(_source, _amount);
    _wethWithdrawTo(msg.sender, _amount);
  }

  function claim(address _account) public {
    _accrue();
    uint pendingReward = pendingAccountReward(_account);

    if(pendingReward > 0) {
      _mint(_account, pendingReward);
      emit Claim(_account, pendingReward);
    }

    rewardSnapshot[_account] = rewardPerToken;
  }

  // Update rewardRateStored to distribute previous unvested income + new income
  // over te next DISTRIBUTION_PERIOD blocks
  function addIncome(uint _addAmount) external onlyRebalancer {
    _accrue();
    _safeTransferFrom(underlying, msg.sender, _addAmount);

    uint blocksElapsed  = Math.min(DISTRIBUTION_PERIOD, block.number - lastIncomeBlock);
    uint unvestedIncome = rewardRateStored * (DISTRIBUTION_PERIOD - blocksElapsed);

    rewardRateStored = (unvestedIncome + _addAmount) / DISTRIBUTION_PERIOD;
    lastIncomeBlock  = block.number;

    emit NewIncome(_addAmount, rewardRateStored);
  }

  // Push any ERC20 token to Rebalancer which will transform it and send back the LP tokens
  function pushToken(
    address _token,
    uint    _amount
  ) external onlyRebalancer {
    _safeTransfer(_token, address(rebalancer()), _amount);
  }

  function pendingAccountReward(address _account) public view returns(uint) {
    uint pedingRewardPerToken = rewardPerToken + _pendingRewardPerToken();
    uint rewardPerTokenDelta  = pedingRewardPerToken - rewardSnapshot[_account];
    return rewardPerTokenDelta * balanceOf[_account] / 1e18;
  }

  // If no new income is added for more than DISTRIBUTION_PERIOD blocks,
  // then do not distribute any more rewards
  function rewardRate() public view returns(uint) {
    uint blocksElapsed = block.number - lastIncomeBlock;

    if (blocksElapsed < DISTRIBUTION_PERIOD) {
      return rewardRateStored;
    } else {
      return 0;
    }
  }

  function rebalancer() public view returns(IVaultRebalancer) {
    return IVaultRebalancer(IVaultController(vaultController).rebalancer());
  }

  function _accrue() internal {
    rewardPerToken  += _pendingRewardPerToken();
    lastAccrualBlock = block.number;
  }

  function _deposit(address _account, uint _amount) internal {
    claim(_account);
    _mint(_account, _amount);
    _checkDepositLimit();
    emit Deposit(_amount);
  }

  function _withdraw(address _account, uint _amount) internal {
    claim(_account);
    _burn(msg.sender, _amount);
    emit Withdraw(_amount);
  }

  function _withdrawAll(address _account) internal returns(uint) {
    claim(_account);
    uint amount = balanceOf[_account];
    _burn(_account, amount);
    emit Withdraw(amount);

    return amount;
  }

  function _withdrawFrom(address _source, uint _amount) internal {
    uint selfBalance = IERC20(underlying).balanceOf(address(this));
    require(selfBalance < _amount, "Vault: unload not required");
    rebalancer().unload(address(this), _source, _amount - selfBalance);
    _withdraw(msg.sender, _amount);
  }

  function _transfer(
    address _sender,
    address _recipient,
    uint    _amount
  ) internal override {
    claim(_sender);
    claim(_recipient);
    super._transfer(_sender, _recipient, _amount);
  }

  function _pendingRewardPerToken() internal view returns(uint) {
    if (lastAccrualBlock == 0 || totalSupply == 0) {
      return 0;
    }

    uint blocksElapsed = block.number - lastAccrualBlock;
    return blocksElapsed * rewardRate() * 1e18 / totalSupply;
  }

  function _checkEthVault() internal view {
    require(
      underlying == address(WETH),
      "Vault: not ETH vault"
    );
  }

  function _checkDepositLimit() internal view {

    IVaultController vController = IVaultController(vaultController);
    uint depositLimit = vController.depositLimit(address(this));

    require(vController.depositsEnabled(), "Vault: deposits disabled");

    if (depositLimit > 0) {
      require(totalSupply <= depositLimit, "Vault: deposit limit reached");
    }
  }
}