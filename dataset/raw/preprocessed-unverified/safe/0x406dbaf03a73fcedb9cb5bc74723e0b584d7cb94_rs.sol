/**
 *Submitted for verification at Etherscan.io on 2021-08-10
*/

// SPDX-License-Identifier: UNLICENSED

// Copyright (c) 2021 0xdev0 - All rights reserved
// https://twitter.com/0xdev0

pragma solidity 0.8.6;



interface IVault is IERC20 {
  function deposit(address _account, uint _amount) external;
  function depositETH(address _account) external payable;
  function withdraw(uint _amount) external;
  function withdrawETH(uint _amount) external;
  function withdrawFrom(address _source, uint _amount) external;
  function withdrawFromETH(address _source, uint _amount) external;
  function pushToken(address _token, uint _amount) external;
  function setDepositsEnabled(bool _value) external;
  function addIncome(uint _addAmount) external;
  function rewardRate() external view returns(uint);
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

contract VaultRebalancer is IVaultRebalancer, TransferHelper, Ownable, ReentrancyGuard {

  using Address for address;

  uint private constant MAX_INT = 2**256 - 1;
  uint private constant DISTRIBUTION_PERIOD = 45_818; // 7 days - 3600 * 24 * 7 / 13.2

  uint public callIncentive;

  IVaultController public  immutable vaultController;
  IVaultFactory    public  immutable vaultFactory;
  IPairFactory     public  immutable pairFactory;

  mapping (address => uint) public pairDeposits;

  event InitiateRebalancerMigration(address indexed newOwner);
  event Rebalance(address indexed fromPair, address indexed toPair, uint amount);
  event FeeDistribution(uint amount);
  event NewCallIncentive(uint value);

  modifier onlyVault() {
    require(vaultFactory.isVault(msg.sender), "VaultRebalancer: caller is not the vault");
    _;
  }

  receive() external payable {}

  constructor(
    IVaultController _vaultController,
    IVaultFactory    _vaultFactory,
    IPairFactory     _pairFactory,
    uint             _callIncentive
  ) {
    _requireContract(address(_vaultController));
    _requireContract(address(_vaultFactory));
    _requireContract(address(_pairFactory));

    vaultController = _vaultController;
    vaultFactory    = _vaultFactory;
    pairFactory     = _pairFactory;
    callIncentive   = _callIncentive;
  }

  function rebalance(
    address      _vault,
    ILendingPair _fromPair,
    ILendingPair _toPair,
    uint         _withdrawAmount
  ) external onlyOwner nonReentrant {

    _validatePair(_fromPair);
    _validatePair(_toPair);

    uint income = _pairWithdrawWithIncome(_vault, _fromPair, _withdrawAmount);
    uint callerIncentive = income * callIncentive / 100e18;

    _pairDeposit(_vault, _toPair, _withdrawAmount);
    WETH.transfer(msg.sender, callerIncentive);

    emit Rebalance(address(_fromPair), address(_toPair), _withdrawAmount);
  }

  // Deploy new WETH from the vault
  function enterPair(
    IVault       _vault,
    ILendingPair _toPair,
    uint         _depositAmount
  ) external onlyOwner nonReentrant {

    _validatePair(_toPair);

    // Since there is no earned income yet
    // we calculate caller incentive as (_depositAmount / 1000)
    // and cap it to at most 0.1 ETH
    uint callerIncentive = Math.min(_depositAmount / 1000, 1e17);

    _vault.pushToken(address(WETH), _depositAmount);
    _pairDeposit(address(_vault), _toPair, _depositAmount - callerIncentive);
    WETH.transfer(msg.sender, callerIncentive);

    emit Rebalance(address(0), address(_toPair), _depositAmount);
  }

  // Allow direct withdrawals from a pair
  function unload(address _pair, uint _amount) external override onlyVault {
    ILendingPair pair = ILendingPair(_pair);
    _validatePair(pair);
    _pairWithdrawWithIncome(msg.sender, pair, _amount);
    _safeTransfer(address(WETH), msg.sender, _amount);
  }

  function distributeIncome(address _vault) external override nonReentrant {

    uint income          = WETH.balanceOf(address(this));
    uint callerReward    = income * callIncentive / 100e18;
    uint netIncome       = income - callerReward;

    WETH.approve(_vault, income);
    IVault(_vault).addIncome(netIncome);

    WETH.transfer(msg.sender, callerReward);

    emit FeeDistribution(netIncome);
  }

  function setCallIncentive(uint _value) external onlyOwner {
    callIncentive = _value;
    emit NewCallIncentive(_value);
  }

  // In case anything goes wrong
  function rescueToken(address _token, uint _amount) external onlyOwner {
    _safeTransfer(_token, msg.sender, _amount);
  }

  function _pairWithdrawWithIncome(address _vault, ILendingPair _pair, uint _amount) internal returns(uint) {

    uint income = _balanceWithPendingInterest(_vault, _pair) - pairDeposits[address(_pair)];

    IVault(_vault).pushToken(address(_pair.lpToken(address(WETH))), _amount);
    _pair.withdraw(address(WETH), _amount + income);

    pairDeposits[address(_pair)] = _balanceWithPendingInterest(_vault, _pair);

    return income;
  }

  function _pairDeposit(address _vault, ILendingPair _pair, uint _amount) internal {
    WETH.approve(address(_pair), _amount);
    _pair.deposit(address(this), address(WETH), _amount);
    _safeTransfer(address(_pair.lpToken(address(WETH))), _vault, _amount);

    pairDeposits[address(_pair)] = _balanceWithPendingInterest(_vault, _pair);
  }

  function _balanceWithPendingInterest(address _vault, ILendingPair _pair) internal view returns(uint) {
    uint balance = _pair.supplyBalance(_vault, address(WETH), address(WETH));
    uint pending = _pair.pendingSupplyInterest(address(WETH), _vault);
    return balance + pending;
  }

  function _lpBalance(ILendingPair _pair) internal view returns(uint) {
    return IERC20(_pair.lpToken(address(WETH))).balanceOf(address(this));
  }

  function _validatePair(ILendingPair _pair) internal view {
    require(
      address(_pair) == pairFactory.pairByTokens(_pair.tokenA(), _pair.tokenB()),
      "VaultRebalancer: invalid lending pair"
    );
  }

  function _requireContract(address _value) internal view {
    require(_value.isContract(), "VaultRebalancer: must be a contract");
  }
}