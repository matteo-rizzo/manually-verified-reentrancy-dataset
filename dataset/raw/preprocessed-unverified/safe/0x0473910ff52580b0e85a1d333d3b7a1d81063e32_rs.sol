/**
 *Submitted for verification at Etherscan.io on 2021-08-28
*/

// SPDX-License-Identifier: UNLICENSED

pragma solidity 0.8.6;



interface IVault is IERC20 {
  function deposit(address _account, uint _amount) external;
  function depositETH(address _account) external payable;
  function withdraw(uint _amount) external;
  function withdrawETH(uint _amount) external;
  function withdrawFrom(address _source, uint _amount) external;
  function withdrawFromETH(address _source, uint _amount) external;
  function withdrawAll() external;
  function withdrawAllETH() external;
  function pushToken(address _token, uint _amount) external;
  function setDepositsEnabled(bool _value) external;
  function addIncome(uint _addAmount) external;
  function rewardRate() external view returns(uint);
  function underlying() external view returns(address);
  function pendingAccountReward(address _account) external view returns(uint);
  function claim(address _account) external;
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

contract Constants {

  IWETH internal constant WETH = IWETH(0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2);
}



contract VaultRebalancer is IVaultRebalancer, Ownable, ReentrancyGuard, Constants {

  using Address for address;

  uint private constant DISTRIBUTION_PERIOD = 45_800; // 7 days - 3600 * 24 * 7 / 13.2
  uint private constant MAX_INCENTIVE = 1e17;

  uint public callIncentive;

  address public immutable vaultController;
  address public immutable vaultFactory;
  address public immutable pairFactory;

  /**
   * pairDeposits value is lost when we redeploy rebalancer.
   * The impact is limited to the loss of unclaimed income.
   * It's recommended to call accrue()
   * on all vaults/pairs before replacing the rebalancer.
  **/
  mapping (address => uint) public override pairDeposits;

  event InitiateRebalancerMigration(address indexed newOwner);
  event Rebalance(address indexed fromPair, address indexed toPair, uint amount);
  event FeeDistribution(uint amount);
  event NewCallIncentive(uint value);

  modifier onlyVault() {
    require(IVaultFactory(vaultFactory).isVault(msg.sender), "VaultRebalancer: caller is not the vault");
    _;
  }

  modifier vaultOrOwner() {
    require(
      IVaultFactory(vaultFactory).isVault(msg.sender) ||
      msg.sender == owner,
      "VaultRebalancer: unauthorized");
    _;
  }

  receive() external payable {}

  constructor(
    address _vaultController,
    address _vaultFactory,
    address _pairFactory,
    uint    _callIncentive
  ) {

    _requireContract(_vaultController);
    _requireContract(_vaultFactory);
    _requireContract(_pairFactory);

    vaultController = _vaultController;
    vaultFactory    = _vaultFactory;
    pairFactory     = _pairFactory;
    callIncentive   = _callIncentive;
  }

  function rebalance(
    address _vault,
    address _fromPair,
    address _toPair,
    uint    _withdrawAmount
  ) external onlyOwner nonReentrant {

    _validatePair(_fromPair);
    _validatePair(_toPair);

    uint income          = _pairWithdrawWithIncome(_vault, _fromPair, _withdrawAmount);
    address underlying   = _vaultUnderlying(_vault);

    _pairDeposit(_vault, underlying, _toPair, _withdrawAmount);
    _sendIncentiveWithLimit(underlying, income);

    emit Rebalance(address(_fromPair), address(_toPair), _withdrawAmount);
  }

  // Deploy assets from the vault
  function enterPair(
    address _vault,
    address _toPair,
    uint    _depositAmount
  ) external onlyOwner nonReentrant {

    _validatePair(_toPair);

    // Since there is no earned income yet
    // we calculate caller incentive as (_depositAmount / 1000)
    // and cap it to at most 0.1 ETH

    address underlying = address(_vaultUnderlying(_vault));

    IVault(_vault).pushToken(underlying, _depositAmount);
    uint callerIncentive = _sendIncentiveWithLimit(underlying, _depositAmount);
    _pairDeposit(_vault, underlying, _toPair, _depositAmount - callerIncentive);

    emit Rebalance(address(0), address(_toPair), _depositAmount);
  }

  // Pull in income without rebalancing
  function accrue(address _vault, address _pair) external nonReentrant {
    uint income = _pairWithdrawWithIncome(_vault, _pair, 0);
    _sendIncentiveWithLimit(_vaultUnderlying(_vault), income);
  }

  // Increase the vault buffer
  function unload(
    address _vault,
    address _pair,
    uint    _amount
  ) external override vaultOrOwner {

    _validatePair(_pair);
    _pairWithdrawWithIncome(_vault, _pair, _amount);
    TransferHelper.safeTransfer(_vaultUnderlying(_vault), _vault, _amount);
    distributeIncome(_vault);
  }

  function distributeIncome(address _vault) public override {

    IERC20 underlying = IERC20(_vaultUnderlying(_vault));
    uint income       = underlying.balanceOf(address(this));

    if (income > 0) {
      underlying.approve(_vault, income);
      IVault(_vault).addIncome(income);

      emit FeeDistribution(income);
    }
  }

  function setCallIncentive(uint _value) external onlyOwner {
    callIncentive = _value;
    emit NewCallIncentive(_value);
  }

  // In case anything goes wrong
  function rescueToken(address _token, uint _amount) external onlyOwner {
    TransferHelper.safeTransfer(_token, msg.sender, _amount);
  }

  // Call after rebalancer redeployment to start recording interest income
  function snapshotDeposit(address _vault, address _pair) external onlyOwner {
    _ensureDepositRecord(_vault, _vaultUnderlying(_vault), _pair);
  }

  function _pairWithdrawWithIncome(
    address _vault,
    address _pair,
    uint    _amount
  ) internal returns(uint) {

    address underlying = _vaultUnderlying(_vault);
    ILendingPair pair = ILendingPair(_pair);

    _ensureDepositRecord(_vault, underlying, _pair);
    uint income = _balanceWithPendingInterest(_vault, underlying, _pair) - pairDeposits[_pair];
    uint transferAmount = _amount + income;

    if (transferAmount > 0) {

      // Accrue pending income to the pair first to make it transferrable
      pair.accrueAccount(_vault);

      IVault(_vault).pushToken(address(pair.lpToken(underlying)), transferAmount);
      pair.withdraw(underlying, transferAmount);
      pairDeposits[_pair] = _balanceWithPendingInterest(_vault, underlying, _pair);
    }

    return income;
  }

  function _ensureDepositRecord(
    address _vault,
    address _underlying,
    address _pair
  ) internal {

    if (pairDeposits[_pair] == 0) {
      pairDeposits[_pair] = _balanceWithPendingInterest(_vault, _underlying, _pair);
    }
  }

  function _sendIncentiveWithLimit(address _underlying, uint _fromAmount) internal returns(uint) {
    uint callerIncentive = Math.min(_fromAmount * callIncentive / 100e18, MAX_INCENTIVE);
    IERC20(_underlying).transfer(msg.sender, callerIncentive);
    return callerIncentive;
  }

  function _pairDeposit(
    address _vault,
    address _underlying,
    address _pair,
    uint    _amount
  ) internal {

    IERC20(_underlying).approve(_pair, _amount);
    ILendingPair(_pair).deposit(_vault, _underlying, _amount);
    pairDeposits[_pair] = _balanceWithPendingInterest(_vault, _underlying, _pair);
  }

  function _balanceWithPendingInterest(
    address _vault,
    address _underlying,
    address _pair
  ) internal view returns(uint) {

    ILendingPair pair = ILendingPair(_pair);
    uint balance = pair.supplyBalance(_vault, _underlying, _underlying);
    uint pending = pair.pendingSupplyInterest(_underlying, _vault);
    return balance + pending;
  }

  function _lpBalance(
    address _pair,
    address _underlying
  ) internal view returns(uint) {
    return IERC20(ILendingPair(_pair).lpToken(_underlying)).balanceOf(address(this));
  }

  function _validatePair(address _pair) internal view {
    ILendingPair pair = ILendingPair(_pair);

    require(
      _pair == IPairFactory(pairFactory).pairByTokens(pair.tokenA(), pair.tokenB()),
      "VaultRebalancer: invalid lending pair"
    );
  }

  function _requireContract(address _value) internal view {
    require(_value.isContract(), "VaultRebalancer: must be a contract");
  }

  function _vaultUnderlying(address _vault) internal view returns(address) {
    return IVault(_vault).underlying();
  }
}