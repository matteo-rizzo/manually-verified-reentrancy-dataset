/**
 *Submitted for verification at Etherscan.io on 2021-07-13
*/

// SPDX-License-Identifier: AGPL-3.0-or-later
pragma solidity 0.7.6;



















abstract contract Strategy {
    using SafeERC20 for IERC20;
    using SafeMath for uint;

    event SetNextTimeLock(address nextTimeLock);
    event AcceptTimeLock(address timeLock);
    event SetAdmin(address admin);
    event Authorize(address addr, bool authorized);
    event SetTreasury(address treasury);
    event SetFundManager(address fundManager);

    event Deposit(uint amount, uint borrowed);
    event Repay(uint amount, uint repaid);
    event Withdraw(uint amount, uint withdrawn, uint loss);
    event ClaimRewards(uint profit);
    event Skim(uint total, uint debt, uint profit);
    event Report(uint gain, uint loss, uint free, uint total, uint debt);

    // Privilege - time lock >= admin >= authorized addresses
    address public timeLock;
    address public nextTimeLock;
    address public admin;
    address public treasury; // Profit is sent to this address

    // authorization other than time lock and admin
    mapping(address => bool) public authorized;

    IERC20 public immutable token;
    IFundManager public fundManager;

    // Performance fee sent to treasury
    uint public perfFee = 1000;
    uint private constant PERF_FEE_CAP = 2000; // Upper limit to performance fee
    uint internal constant PERF_FEE_MAX = 10000;

    constructor(
        address _token,
        address _fundManager,
        address _treasury
    ) {
        // Don't allow accidentally sending perf fee to 0 address
        require(_treasury != address(0), "treasury = 0 address");

        timeLock = msg.sender;
        admin = msg.sender;
        treasury = _treasury;

        require(
            IFundManager(_fundManager).token() == _token,
            "fund manager token != token"
        );

        fundManager = IFundManager(_fundManager);
        token = IERC20(_token);

        IERC20(_token).safeApprove(_fundManager, type(uint).max);
    }

    modifier onlyTimeLock() {
        require(msg.sender == timeLock, "!time lock");
        _;
    }

    modifier onlyTimeLockOrAdmin() {
        require(msg.sender == timeLock || msg.sender == admin, "!auth");
        _;
    }

    modifier onlyAuthorized() {
        require(
            msg.sender == timeLock || msg.sender == admin || authorized[msg.sender],
            "!auth"
        );
        _;
    }

    modifier onlyFundManager() {
        require(msg.sender == address(fundManager), "!fund manager");
        _;
    }

    /*
    @notice Set next time lock
    @param _nextTimeLock Address of next time lock
    @dev nextTimeLock can become timeLock by calling acceptTimeLock()
    */
    function setNextTimeLock(address _nextTimeLock) external onlyTimeLock {
        // Allow next time lock to be zero address (cancel next time lock)
        nextTimeLock = _nextTimeLock;
        emit SetNextTimeLock(_nextTimeLock);
    }

    /*
    @notice Set timeLock to msg.sender
    @dev msg.sender must be nextTimeLock
    */
    function acceptTimeLock() external {
        require(msg.sender == nextTimeLock, "!next time lock");
        timeLock = msg.sender;
        emit AcceptTimeLock(msg.sender);
    }

    /*
    @notice Set admin
    @param _admin Address of admin
    */
    function setAdmin(address _admin) external onlyTimeLockOrAdmin {
        admin = _admin;
        emit SetAdmin(_admin);
    }

    /*
    @notice Set authorization
    @param _addr Address to authorize
    @param _authorized Boolean
    */
    function authorize(address _addr, bool _authorized) external onlyTimeLockOrAdmin {
        authorized[_addr] = _authorized;
        emit Authorize(_addr, _authorized);
    }

    /*
    @notice Set treasury
    @param _treasury Address of treasury
    */
    function setTreasury(address _treasury) external onlyTimeLockOrAdmin {
        // Don't allow accidentally sending perf fee to 0 address
        require(_treasury != address(0), "treasury = 0 address");
        treasury = _treasury;
        emit SetTreasury(_treasury);
    }

    /*
    @notice Set performance fee
    @param _fee Performance fee
    */
    function setPerfFee(uint _fee) external onlyTimeLockOrAdmin {
        require(_fee <= PERF_FEE_CAP, "fee > cap");
        perfFee = _fee;
    }

    function setFundManager(address _fundManager) external onlyTimeLock {
        if (address(fundManager) != address(0)) {
            token.safeApprove(address(fundManager), 0);
        }

        require(
            IFundManager(_fundManager).token() == address(token),
            "new fund manager token != token"
        );

        fundManager = IFundManager(_fundManager);
        token.safeApprove(_fundManager, type(uint).max);

        emit SetFundManager(_fundManager);
    }

    /*
    @notice Transfer funds from `_from` address. Used for migration.
    @param _from Address to transfer token from
    @param _amount Amount of token to transfer
    */
    function transferTokenFrom(address _from, uint _amount) external onlyAuthorized {
        token.safeTransferFrom(_from, address(this), _amount);
    }

    /*
    @notice Returns approximate amount of token locked in this contract
    @dev Output may vary depending on price pulled from external DeFi contracts
    */
    function totalAssets() external view virtual returns (uint);

    /*
    @notice Deposit into strategy
    @param _amount Amount of token to deposit from fund manager
    @param _min Minimum amount borrowed
    */
    function deposit(uint _amount, uint _min) external virtual;

    /*
    @notice Withdraw token from this contract
    @dev Only callable by fund manager
    @dev Returns current loss = debt to fund manager - total assets
    */
    function withdraw(uint _amount) external virtual returns (uint);

    /*
    @notice Repay fund manager
    @param _amount Amount of token to repay to fund manager
    @param _min Minimum amount repaid
    @dev Call report after this to report any loss
    */
    function repay(uint _amount, uint _min) external virtual;

    /*
    @notice Claim any reward tokens, sell for token
    @param _minProfit Minumum amount of token to gain from selling rewards
    */
    function claimRewards(uint _minProfit) external virtual;

    /*
    @notice Free up any profit over debt
    */
    function skim() external virtual;

    /*
    @notice Report gain or loss back to fund manager
    @param _minTotal Minimum value of total assets.
               Used to protect against price manipulation.
    @param _maxTotal Maximum value of total assets Used
               Used to protect against price manipulation.  
    */
    function report(uint _minTotal, uint _maxTotal) external virtual;

    /*
    @notice Claim rewards, skim and report
    @param _minProfit Minumum amount of token to gain from selling rewards
    @param _minTotal Minimum value of total assets.
               Used to protect against price manipulation.
    @param _maxTotal Maximum value of total assets Used
               Used to protect against price manipulation.  
    */
    function harvest(
        uint _minProfit,
        uint _minTotal,
        uint _maxTotal
    ) external virtual;

    /*
    @notice Migrate to new version of this strategy
    @param _strategy Address of new strategy
    @dev Only callable by fund manager
    */
    function migrate(address _strategy) external virtual;

    /*
    @notice Transfer token accidentally sent here back to admin
    @param _token Address of token to transfer
    */
    function sweep(address _token) external virtual;
}

contract StrategyConvexBbtc is Strategy {
    using SafeERC20 for IERC20;
    using SafeMath for uint;

    // Uniswap and Sushiswap //
    // UNISWAP = 0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D;
    // SUSHISWAP = 0xd9e1cE17f2641f24aE83637ab66a2cca9C378B9F;
    address private constant WETH = 0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2;
    // address of DEX (uniswap or sushiswap) to use for selling reward tokens
    // CRV, CVX
    address[2] public dex;

    address private constant CRV = 0xD533a949740bb3306d119CC777fa900bA034cd52;
    address private constant CVX = 0x4e3FBD56CD56c3e72c1403e103b45Db9da5B9D2B;

    // Solc 0.7 cannot create constant arrays
    address[2] private REWARDS = [CRV, CVX];

    // Convex //
    Booster private constant BOOSTER =
        Booster(0xF403C135812408BFbE8713b5A23a04b3D48AAE31);
    // pool id
    uint private constant PID = 19;
    BaseRewardPool private constant REWARD =
        BaseRewardPool(0x61D741045cCAA5a215cF4E5e55f20E1199B4B843);
    bool public shouldClaimExtras = true;

    // Curve //
    // Deposit
    DepositBbtc private constant ZAP =
        DepositBbtc(0xC45b2EEe6e09cA176Ca3bB5f7eEe7C47bF93c756);
    // StableSwap
    StableSwapBbtc private constant CURVE_POOL =
        StableSwapBbtc(0x42d7025938bEc20B69cBae5A77421082407f053A);
    // LP token for curve pool bBTC/sbtcCRV
    IERC20 private constant CURVE_LP =
        IERC20(0x410e3E86ef427e30B9235497143881f717d93c2A);

    // prevent slippage from deposit / withdraw
    uint public slip = 100;
    uint private constant SLIP_MAX = 10000;

    /*
    0 - BBTC
    1 - renBTC
    2 - WBTC
    3 - SBTC
    */
    // multipliers to normalize token decimals to 10 ** 18
    uint[4] private MULS = [1e10, 1e10, 1e10, 1];
    uint private immutable MUL; // multiplier of token
    uint private immutable INDEX; // index of token

    // WBTC = 0x2260FAC5E5542a773Aa44fBCfeDf7C193bc2C599

    constructor(
        address _token,
        address _fundManager,
        address _treasury,
        uint _index
    ) Strategy(_token, _fundManager, _treasury) {
        // only WBTC
        require(_index == 2, "index != 2");
        INDEX = _index;
        MUL = MULS[_index];

        (address lptoken, , , address crvRewards, , ) = BOOSTER.poolInfo(PID);
        require(address(CURVE_LP) == lptoken, "curve pool lp != pool info lp");
        require(address(REWARD) == crvRewards, "reward != pool info reward");

        IERC20(_token).safeApprove(address(ZAP), type(uint).max);
        // deposit into BOOSTER
        CURVE_LP.safeApprove(address(BOOSTER), type(uint).max);
        // withdraw from ZAP
        CURVE_LP.safeApprove(address(ZAP), type(uint).max);

        _setDex(0, 0xd9e1cE17f2641f24aE83637ab66a2cca9C378B9F); // CRV - sushiswap
        _setDex(1, 0xd9e1cE17f2641f24aE83637ab66a2cca9C378B9F); // CVX - sushiswap
    }

    function _setDex(uint _i, address _dex) private {
        IERC20 reward = IERC20(REWARDS[_i]);

        // disallow previous dex
        if (dex[_i] != address(0)) {
            reward.safeApprove(dex[_i], 0);
        }

        dex[_i] = _dex;

        // approve new dex
        reward.safeApprove(_dex, type(uint).max);
    }

    function setDex(uint _i, address _dex) external onlyTimeLockOrAdmin {
        require(_dex != address(0), "dex = 0 address");
        _setDex(_i, _dex);
    }

    /*
    @notice Set max slippage for deposit and withdraw from Curve pool
    @param _slip Max amount of slippage allowed
    */
    function setSlip(uint _slip) external onlyAuthorized {
        require(_slip <= SLIP_MAX, "slip > max");
        slip = _slip;
    }

    // @dev Claim extra rewards from Convex
    function setShouldClaimExtras(bool _shouldClaimExtras) external onlyAuthorized {
        shouldClaimExtras = _shouldClaimExtras;
    }

    function _totalAssets() private view returns (uint) {
        /*
        s0 = shares in curve pool
        p0 = price per share of curve pool
        a = amount of tokens

        a = s0 * p0
        */
        // amount of Curve LP tokens in Convex
        uint lpBal = REWARD.balanceOf(address(this));
        uint bal = lpBal.mul(CURVE_POOL.get_virtual_price()) / (MUL * 1e18);

        bal = bal.add(token.balanceOf(address(this)));

        return bal;
    }

    function totalAssets() external view override returns (uint) {
        return _totalAssets();
    }

    function _deposit() private {
        uint bal = token.balanceOf(address(this));
        if (bal > 0) {
            uint[4] memory amounts;
            amounts[INDEX] = bal;
            /*
            shares = token amount * multiplier * 1e18 / price per share
            */
            uint pricePerShare = CURVE_POOL.get_virtual_price();
            uint shares = bal.mul(MUL).mul(1e18).div(pricePerShare);
            uint min = shares.mul(SLIP_MAX - slip) / SLIP_MAX;

            ZAP.add_liquidity(amounts, min);
        }

        uint lpBal = CURVE_LP.balanceOf(address(this));
        if (lpBal > 0) {
            require(BOOSTER.deposit(PID, lpBal, true), "deposit failed");
        }
    }

    function deposit(uint _amount, uint _min) external override onlyAuthorized {
        require(_amount > 0, "deposit = 0");

        uint borrowed = fundManager.borrow(_amount);
        require(borrowed >= _min, "borrowed < min");

        _deposit();
        emit Deposit(_amount, borrowed);
    }

    function _calcSharesToWithdraw(
        uint _amount,
        uint _total,
        uint _totalShares
    ) private pure returns (uint) {
        /*
        calculate shares to withdraw

        a = amount of token to withdraw
        T = total amount of token locked in external liquidity pool
        s = shares to withdraw
        P = total shares deposited into external liquidity pool

        a / T = s / P
        s = a / T * P
        */
        if (_total > 0) {
            // avoid rounding errors and cap shares to be <= total shares
            if (_amount >= _total) {
                return _totalShares;
            }
            return _amount.mul(_totalShares) / _total;
        }
        return 0;
    }

    function _withdraw(uint _amount) private returns (uint) {
        uint bal = token.balanceOf(address(this));
        if (_amount <= bal) {
            return _amount;
        }

        uint total = _totalAssets();

        if (_amount >= total) {
            _amount = total;
        }

        uint need = _amount - bal;
        uint totalShares = REWARD.balanceOf(address(this));
        // total assets is always >= bal
        uint shares = _calcSharesToWithdraw(need, total - bal, totalShares);

        // withdraw from Convex
        if (shares > 0) {
            // true = claim CRV
            require(REWARD.withdrawAndUnwrap(shares, false), "reward withdraw failed");
        }

        // withdraw from Curve
        uint lpBal = CURVE_LP.balanceOf(address(this));
        if (shares > lpBal) {
            shares = lpBal;
        }

        if (shares > 0) {
            uint min = need.mul(SLIP_MAX - slip) / SLIP_MAX;
            ZAP.remove_liquidity_one_coin(shares, int128(INDEX), min);
        }

        uint balAfter = token.balanceOf(address(this));
        if (balAfter < _amount) {
            return balAfter;
        }
        // balAfter >= _amount >= total
        // requested to withdraw all so return balAfter
        if (_amount >= total) {
            return balAfter;
        }
        // requested withdraw < all
        return _amount;
    }

    function withdraw(uint _amount) external override onlyFundManager returns (uint) {
        require(_amount > 0, "withdraw = 0");

        // availabe <= _amount
        uint available = _withdraw(_amount);

        uint loss = 0;
        uint debt = fundManager.getDebt(address(this));
        uint total = _totalAssets();
        if (debt > total) {
            loss = debt - total;
        }

        if (available > 0) {
            token.safeTransfer(msg.sender, available);
        }

        emit Withdraw(_amount, available, loss);

        return loss;
    }

    function repay(uint _amount, uint _min) external override onlyAuthorized {
        require(_amount > 0, "repay = 0");
        // availabe <= _amount
        uint available = _withdraw(_amount);
        uint repaid = fundManager.repay(available);
        require(repaid >= _min, "repaid < min");

        emit Repay(_amount, repaid);
    }

    /*
    @dev Uniswap fails with zero address so no check is necessary here
    */
    function _swap(
        address _dex,
        address _tokenIn,
        address _tokenOut,
        uint _amount
    ) private {
        // create dynamic array with 3 elements
        address[] memory path = new address[](3);
        path[0] = _tokenIn;
        path[1] = WETH;
        path[2] = _tokenOut;

        UniswapV2Router(_dex).swapExactTokensForTokens(
            _amount,
            1,
            path,
            address(this),
            block.timestamp
        );
    }

    function _claimRewards(uint _minProfit) private {
        // calculate profit = balance of token after - balance of token before
        uint diff = token.balanceOf(address(this));

        require(
            REWARD.getReward(address(this), shouldClaimExtras),
            "get reward failed"
        );

        for (uint i = 0; i < REWARDS.length; i++) {
            uint rewardBal = IERC20(REWARDS[i]).balanceOf(address(this));
            if (rewardBal > 0) {
                // swap may fail if rewards are too small
                _swap(dex[i], REWARDS[i], address(token), rewardBal);
            }
        }

        diff = token.balanceOf(address(this)) - diff;
        require(diff >= _minProfit, "profit < min");

        // transfer performance fee to treasury
        if (diff > 0) {
            uint fee = diff.mul(perfFee) / PERF_FEE_MAX;
            if (fee > 0) {
                token.safeTransfer(treasury, fee);
                diff = diff.sub(fee);
            }
        }

        emit ClaimRewards(diff);
    }

    function claimRewards(uint _minProfit) external override onlyAuthorized {
        _claimRewards(_minProfit);
    }

    function _skim() private {
        uint total = _totalAssets();
        uint debt = fundManager.getDebt(address(this));
        require(total > debt, "total <= debt");

        uint profit = total - debt;
        // reassign to actual amount withdrawn
        profit = _withdraw(profit);

        emit Skim(total, debt, profit);
    }

    function skim() external override onlyAuthorized {
        _skim();
    }

    function _report(uint _minTotal, uint _maxTotal) private {
        uint total = _totalAssets();
        require(total >= _minTotal, "total < min");
        require(total <= _maxTotal, "total > max");

        uint gain = 0;
        uint loss = 0;
        uint free = 0; // balance of token
        uint debt = fundManager.getDebt(address(this));
        if (total > debt) {
            gain = total - debt;

            free = token.balanceOf(address(this));
            if (gain > free) {
                gain = free;
            }
        } else {
            loss = debt - total;
        }

        if (gain > 0 || loss > 0) {
            fundManager.report(gain, loss);
        }

        emit Report(gain, loss, free, total, debt);
    }

    function report(uint _minTotal, uint _maxTotal) external override onlyAuthorized {
        _report(_minTotal, _maxTotal);
    }

    function harvest(
        uint _minProfit,
        uint _minTotal,
        uint _maxTotal
    ) external override onlyAuthorized {
        _claimRewards(_minProfit);
        _skim();
        _report(_minTotal, _maxTotal);
    }

    function migrate(address _strategy) external override onlyFundManager {
        Strategy strat = Strategy(_strategy);
        require(address(strat.token()) == address(token), "strategy token != token");
        require(
            address(strat.fundManager()) == address(fundManager),
            "strategy fund manager != fund manager"
        );
        uint bal = _withdraw(type(uint).max);
        token.safeApprove(_strategy, bal);
        strat.transferTokenFrom(address(this), bal);
    }

    /*
    @notice Transfer token accidentally sent here to admin
    @param _token Address of token to transfer
    */
    function sweep(address _token) external override onlyAuthorized {
        require(_token != address(token), "protected token");
        for (uint i = 0; i < REWARDS.length; i++) {
            require(_token != REWARDS[i], "protected token");
        }
        IERC20(_token).safeTransfer(admin, IERC20(_token).balanceOf(address(this)));
    }
}



contract StrategyConvexBbtcWbtc is StrategyConvexBbtc {
    constructor(address _fundManager, address _treasury)
        StrategyConvexBbtc(
            0x2260FAC5E5542a773Aa44fBCfeDf7C193bc2C599,
            _fundManager,
            _treasury,
            2
        )
    {}
}