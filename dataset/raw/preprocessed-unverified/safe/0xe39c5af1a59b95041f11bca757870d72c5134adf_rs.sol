/**
 *Submitted for verification at Etherscan.io on 2020-10-15
*/

// SPDX-License-Identifier: MIT

pragma solidity ^0.6.12;


// 
/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
 */


// 
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


// 
/**
 * @dev Collection of functions related to the address type
 */


// 
/**
 * @title SafeERC20
 * @dev Wrappers around ERC20 operations that throw on failure (when the token
 * contract returns false). Tokens that return no value (and instead revert or
 * throw on failure) are also supported, non-reverting calls are assumed to be
 * successful.
 * To use this library you can add a `using SafeERC20 for IERC20;` statement to your contract,
 * which allows you to call the safe operations as `token.safeTransfer(...)`, etc.
 */


// 




// 


// 




// 


// 
contract StrategyCurve2TokenPool {
    using SafeERC20 for IERC20;
    using Address for address;
    using SafeMath for uint256;

    uint256 public constant N_COINS = 2;
    uint256 public immutable WANT_COIN_INDEX;
    address public immutable want;
    address public immutable crvLP;
    address public immutable curveDeposit;
    address public immutable gauge;

    address public immutable mintr;
    address public immutable crv;
    address public immutable uni;
    // used for crv <> weth <> dai route
    address public immutable weth;
    string private name;
    
    // renBTC, wBTC
    address[N_COINS] public coins;
    uint256[N_COINS] public ZEROS = [uint256(0),uint256(0)];

    uint256 public performanceFee = 500;
    uint256 public immutable performanceMax = 10000;

    uint256 public withdrawalFee = 0;
    uint256 public immutable withdrawalMax = 10000;

    address public governance;
    address public controller;
    address public timelock;

    constructor
    (
        address _controller,
        string memory _name,
        uint256 _wantCoinIndex,
        address[N_COINS] memory _coins,
        address _curveDeposit,
        address _gauge,
        address _crvLP,
        address _crv,
        address _uni,
        address _mintr,
        address _weth,
        address _timelock
    ) 
    public 
    {
        governance = msg.sender;
        controller = _controller;
        name = _name;
        WANT_COIN_INDEX = _wantCoinIndex;
        want = _coins[_wantCoinIndex];
        coins = _coins;
        curveDeposit = _curveDeposit;
        gauge = _gauge;
        crvLP = _crvLP;
        crv = _crv;
        uni = _uni;
        mintr = _mintr;
        weth = _weth;
        timelock = _timelock;
    }

    function getName() external view returns (string memory) {
        return name;
    }

    function setWithdrawalFee(uint256 _withdrawalFee) external {
        require(msg.sender == governance, "!governance");
        require(_withdrawalFee < withdrawalMax, "inappropriate withdraw fee");
        withdrawalFee = _withdrawalFee;
    }

    function setPerformanceFee(uint256 _performanceFee) external {
        require(msg.sender == governance, "!governance");
        require(_performanceFee < performanceMax, "inappropriate performance fee");
        performanceFee = _performanceFee;
    }

    function deposit() public {
        _deposit(WANT_COIN_INDEX);
    }

    function _deposit(uint256 _coinIndex) internal {
        require(_coinIndex < N_COINS, "index exceeded bound");
        address coinAddr = coins[_coinIndex];
        uint256 wantAmount = IERC20(coinAddr).balanceOf(address(this));
        if (wantAmount > 0) {
            IERC20(coinAddr).safeApprove(curveDeposit, 0);
            IERC20(coinAddr).safeApprove(curveDeposit, wantAmount);
            uint256[N_COINS] memory amounts = ZEROS;
            amounts[_coinIndex] = wantAmount;
            // TODO: add minimun mint amount if required
            ICurveDeposit(curveDeposit).add_liquidity(amounts, 0);
        }
        uint256 crvLPAmount = IERC20(crvLP).balanceOf(address(this));
        if (crvLPAmount > 0) {
            IERC20(crvLP).safeApprove(gauge, 0);
            IERC20(crvLP).safeApprove(gauge, crvLPAmount);
            Gauge(gauge).deposit(crvLPAmount);
        }
    }

    // Withdraw all funds, normally used when migrating strategies
    function withdrawAll() external returns (uint256 balance) {
        require(msg.sender == controller, "!controller");
        uint256 _amount = Gauge(gauge).balanceOf(address(this));
        Gauge(gauge).withdraw(_amount);
        IERC20(crvLP).safeApprove(curveDeposit, 0);
        IERC20(crvLP).safeApprove(curveDeposit, _amount);
        // TODO: add minimun mint amount if required
        ICurveDeposit(curveDeposit).remove_liquidity_one_coin(_amount, int128(WANT_COIN_INDEX), 0);
        
        balance = IERC20(want).balanceOf(address(this));

        address _vault = IController(controller).vaults(address(want));
        require(_vault != address(0), "!vault"); // additional protection so we don't burn the funds
        IERC20(want).safeTransfer(_vault, balance);
    }

    function withdraw(uint256 _amount) external {
        require(msg.sender == controller, "!controller");
        uint256 _balance = IERC20(want).balanceOf(address(this));
        if (_balance < _amount) {
            _withdrawSome(_amount.sub(_balance));
            _amount = IERC20(want).balanceOf(address(this));
        }
        uint256 _fee = _amount.mul(withdrawalFee).div(withdrawalMax);
        IERC20(want).safeTransfer(IController(controller).rewards(), _fee);
        address _vault = IController(controller).vaults(address(want));
        require(_vault != address(0), "!vault"); // additional protection so we don't burn the funds

        IERC20(want).safeTransfer(_vault, _amount.sub(_fee));
    }

    function _withdrawSome(uint256 _amount) internal {
        uint256 rate = ICurveDeposit(curveDeposit).calc_withdraw_one_coin(10**18, int128(WANT_COIN_INDEX));
        _amount = _amount.mul(10**18).div(rate);
        if(_amount > balanceOfGauge()) {
            _amount = balanceOfGauge();
        }
        Gauge(gauge).withdraw(_amount);
        IERC20(crvLP).safeApprove(curveDeposit, 0);
        IERC20(crvLP).safeApprove(curveDeposit, _amount);
        // TODO: add minimun mint amount if required
        ICurveDeposit(curveDeposit).remove_liquidity_one_coin(_amount, int128(WANT_COIN_INDEX), 0);
    }

    // Controller only function for creating additional rewards from dust
    function withdraw(IERC20 _asset) external returns (uint256 balance) {
        require(msg.sender == controller, "!controller");
        for(uint i = 0; i < N_COINS; ++i) {
            require(coins[i] != address(_asset), "internal token");
        }
        require(crv != address(_asset), "crv");
        require(crvLP != address(_asset), "crvLP");
        balance = _asset.balanceOf(address(this));
        _asset.safeTransfer(controller, balance);
    }

    function harvest(uint _coinIndex) public {
        require(_coinIndex < N_COINS, "index exceeded bound");
        Mintr(mintr).mint(gauge);
        address harvestingCoin = coins[_coinIndex];
        uint256 _crv = IERC20(crv).balanceOf(address(this));
        if (_crv > 0) {

            IERC20(crv).safeApprove(uni, 0);
            IERC20(crv).safeApprove(uni, _crv);

            address[] memory path = new address[](3);
            path[0] = crv;
            path[1] = weth;
            path[2] = harvestingCoin;
            // TODO: add minimun mint amount if required
            Uni(uni).swapExactTokensForTokens(_crv, uint256(0), path, address(this), now.add(1800));
        }
        uint256 harvestAmount = IERC20(harvestingCoin).balanceOf(address(this));
        if (harvestAmount > 0) {
            uint256 _fee = harvestAmount.mul(performanceFee).div(performanceMax);
            IERC20(harvestingCoin).safeTransfer(IController(controller).rewards(), _fee);
            _deposit(_coinIndex);
        }
    }

    function balanceOfWant() public view returns (uint256) {
        return IERC20(want).balanceOf(address(this));
    }

    function balanceOfGauge() public view returns (uint256) {
        return Gauge(gauge).balanceOf(address(this));
    }

    function balanceOfPool() public view returns (uint256) {
        uint256 gaugeBalance = balanceOfGauge();
        // NOTE: this is for curve ren pool only, since calc_withdraw_one_coin
        // would raise error when input 0 amount
        if(gaugeBalance == 0){
            return 0;
        }
        return ICurveDeposit(curveDeposit).calc_withdraw_one_coin(gaugeBalance, int128(WANT_COIN_INDEX));
    }

    function balanceOf() public view returns (uint256) {
        return balanceOfWant().add(balanceOfPool());
    }

    function setGovernance(address _governance) external {
        require(msg.sender == timelock, "!timelock");
        governance = _governance;
    }

    function setController(address _controller) external {
        require(msg.sender == timelock, "!timelock");
        controller = _controller;
    }

    function setTimelock(address _timelock) public {
        require(msg.sender == timelock, "!timelock");
        timelock = _timelock;
    }
}