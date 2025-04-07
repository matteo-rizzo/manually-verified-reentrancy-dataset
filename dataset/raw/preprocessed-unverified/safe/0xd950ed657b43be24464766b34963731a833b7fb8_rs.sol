/**
 *Submitted for verification at Etherscan.io on 2021-03-01
*/

pragma solidity ^0.6.6;


// SPDX-License-Identifier: MIT
/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
 */


// SPDX-License-Identifier: MIT
/**
 * @dev Wrappers over Solidity's arithmetic operations with added overflow
 * checks.
 *
 * Arithmetic operations in Solidity wrap on overflow. This can easily result
 * in bugs, because programmers usually assume that an overflow raises an
 * error, which is the standard behavior in high level programming languages.
 * `SafeMath` restores this intuition by reverting the transaction when an
 * operation overflows.
 *
 * Using this library instead of the unchecked operations eliminates an entire
 * class of bugs, so it's recommended to use it always.
 */


// SPDX-License-Identifier: MIT
/**
 * @dev Collection of functions related to the address type
 */


// SPDX-License-Identifier: MIT
/**
 * @title SafeERC20
 * @dev Wrappers around ERC20 operations that throw on failure (when the token
 * contract returns false). Tokens that return no value (and instead revert or
 * throw on failure) are also supported, non-reverting calls are assumed to be
 * successful.
 * To use this library you can add a `using SafeERC20 for IERC20;` statement to your contract,
 * which allows you to call the safe operations as `token.safeTransfer(...)`, etc.
 */










contract StrategyDForceDAI {
  using SafeERC20 for IERC20;
  using Address for address;
  using SafeMath for uint256;

  address public want; //// = address(0x6B175474E89094C44Da98b954EedeAC495271d0F); // DAI
  address public constant d = address(0x02285AcaafEB533e03A7306C55EC031297df9224);
  address public constant pool = address(0xD2fA07cD6Cd4A5A96aa86BacfA6E50bB3aaDBA8B);
  address public constant df = address(0x431ad2ff6a9C365805eBaD47Ee021148d6f7DBe0);
  address public constant uni = address(0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D);
  address public constant weth = address(0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2); // used for df <> weth <> dai route

  uint256 public performanceFee = 5000;
  uint256 public constant performanceMax = 10000;

  uint256 public withdrawalFee = 50;
  uint256 public constant withdrawalMax = 10000;

  address public governance;
  address public controller;
  address public strategist;

  constructor(address _controller, address _want) public {
    governance = msg.sender;
    strategist = msg.sender;
    controller = _controller;
    want = _want;
  }

  function getName() external pure returns (string memory) {
    return "StrategyDForceDAI";
  }

  function setStrategist(address _strategist) external {
    require(msg.sender == governance, "!governance");
    strategist = _strategist;
  }

  function setWithdrawalFee(uint256 _withdrawalFee) external {
    require(msg.sender == governance, "!governance");
    withdrawalFee = _withdrawalFee;
  }

  function setPerformanceFee(uint256 _performanceFee) external {
    require(msg.sender == governance, "!governance");
    performanceFee = _performanceFee;
  }

  function deposit() public {
    uint256 _want = IERC20(want).balanceOf(address(this));
    if (_want > 0) {
      IERC20(want).safeApprove(d, 0);
      IERC20(want).safeApprove(d, _want);
      dERC20(d).mint(address(this), _want);
    }

    uint256 _d = IERC20(d).balanceOf(address(this));
    if (_d > 0) {
      IERC20(d).safeApprove(pool, 0);
      IERC20(d).safeApprove(pool, _d);
      dRewards(pool).stake(_d);
    }
  }

  // Controller only function for creating additional rewards from dust
  function withdraw(IERC20 _asset) external returns (uint256 balance) {
    require(msg.sender == controller, "!controller");
    require(want != address(_asset), "want");
    require(d != address(_asset), "d");
    balance = _asset.balanceOf(address(this));
    _asset.safeTransfer(controller, balance);
  }

  // Withdraw partial funds, normally used with a vault withdrawal
  function withdraw(uint256 _amount) external {
    require(msg.sender == controller, "!controller");
    uint256 _balance = IERC20(want).balanceOf(address(this));
    if (_balance < _amount) {
      _amount = _withdrawSome(_amount.sub(_balance));
      _amount = _amount.add(_balance);
    }

    uint256 _fee = _amount.mul(withdrawalFee).div(withdrawalMax);

    IERC20(want).safeTransfer(IController(controller).rewards(), _fee);
    address _vault = IController(controller).vaults(address(want));
    require(_vault != address(0), "!vault"); // additional protection so we don't burn the funds

    IERC20(want).safeTransfer(_vault, _amount.sub(_fee));
  }

  // Withdraw all funds, normally used when migrating strategies
  function withdrawAll() external returns (uint256 balance) {
    require(msg.sender == controller, "!controller");
    _withdrawAll();

    balance = IERC20(want).balanceOf(address(this));

    address _vault = IController(controller).vaults(address(want));
    require(_vault != address(0), "!vault"); // additional protection so we don't burn the funds
    IERC20(want).safeTransfer(_vault, balance);
  }

  function _withdrawAll() internal {
    dRewards(pool).exit();
    uint256 _d = IERC20(d).balanceOf(address(this));
    if (_d > 0) {
      dERC20(d).redeem(address(this), _d);
    }
  }

  function harvest() public {
    require(msg.sender == strategist || msg.sender == governance, "!authorized");
    dRewards(pool).getReward();
    uint256 _df = IERC20(df).balanceOf(address(this));
    if (_df > 0) {
      IERC20(df).safeApprove(uni, 0);
      IERC20(df).safeApprove(uni, _df);

      address[] memory path = new address[](3);
      path[0] = df;
      path[1] = weth;
      path[2] = want;

      UniswapRouter(uni).swapExactTokensForTokens(_df, uint256(0), path, address(this), now.add(1800));
    }
    uint256 _want = IERC20(want).balanceOf(address(this));
    if (_want > 0) {
      uint256 _fee = _want.mul(performanceFee).div(performanceMax);
      IERC20(want).safeTransfer(IController(controller).rewards(), _fee);
      deposit();
    }
  }

  function _withdrawSome(uint256 _amount) internal returns (uint256) {
    uint256 _d = _amount.mul(1e18).div(dERC20(d).getExchangeRate());
    uint256 _before = IERC20(d).balanceOf(address(this));
    dRewards(pool).withdraw(_d);
    uint256 _after = IERC20(d).balanceOf(address(this));
    uint256 _withdrew = _after.sub(_before);
    _before = IERC20(want).balanceOf(address(this));
    dERC20(d).redeem(address(this), _withdrew);
    _after = IERC20(want).balanceOf(address(this));
    _withdrew = _after.sub(_before);
    return _withdrew;
  }

  function balanceOfWant() public view returns (uint256) {
    return IERC20(want).balanceOf(address(this));
  }

  function balanceOfPool() public view returns (uint256) {
    return (dRewards(pool).balanceOf(address(this))).mul(dERC20(d).getExchangeRate()).div(1e18);
  }

  function getExchangeRate() public view returns (uint256) {
    return dERC20(d).getExchangeRate();
  }

  function balanceOfD() public view returns (uint256) {
    return dERC20(d).getTokenBalance(address(this));
  }

  function balanceOf() public view returns (uint256) {
    return balanceOfWant().add(balanceOfD()).add(balanceOfPool());
  }

  function setGovernance(address _governance) external {
    require(msg.sender == governance, "!governance");
    governance = _governance;
  }

  function setController(address _controller) external {
    require(msg.sender == governance, "!governance");
    controller = _controller;
  }
}