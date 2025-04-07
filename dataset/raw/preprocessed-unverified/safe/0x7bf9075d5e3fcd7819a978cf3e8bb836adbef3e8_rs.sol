/**
 *Submitted for verification at Etherscan.io on 2021-09-28
*/

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

    bool public claimRewardsOnMigrate = true;

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
        nextTimeLock = address(0);
        emit AcceptTimeLock(msg.sender);
    }

    /*
    @notice Set admin
    @param _admin Address of admin
    */
    function setAdmin(address _admin) external onlyTimeLockOrAdmin {
        require(_admin != address(0), "admin = 0 address");
        admin = _admin;
        emit SetAdmin(_admin);
    }

    /*
    @notice Set authorization
    @param _addr Address to authorize
    @param _authorized Boolean
    */
    function authorize(address _addr, bool _authorized) external onlyTimeLockOrAdmin {
        require(_addr != address(0), "addr = 0 address");
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
    @notice Set `claimRewardsOnMigrate`. If `false` skip call to `claimRewards`
            when `migrate` is called.
    @param _claimRewards Boolean to call or skip call to `claimRewards`
    */
    function setClaimRewardsOnMigrate(bool _claimRewards) external onlyTimeLockOrAdmin {
        claimRewardsOnMigrate = _claimRewards;
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

contract StrategyCompLev is Strategy {
    using SafeERC20 for IERC20;
    using SafeMath for uint;

    // Uniswap and Sushiswap //
    // UNISWAP = 0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D;
    // SUSHISWAP = 0xd9e1cE17f2641f24aE83637ab66a2cca9C378B9F;
    address private constant WETH = 0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2;
    address public dex;

    // Compound //
    Comptroller private constant comptroller =
        Comptroller(0x3d9819210A31b4961b30EF54bE2aeD79B9c9Cd3B);
    IERC20 private constant comp = IERC20(0xc00e94Cb662C3520282E6f5717214004A7f26888);
    CErc20 private immutable cToken;
    uint public buffer = 0.04 * 1e18;

    constructor(
        address _token,
        address _fundManager,
        address _treasury,
        address _cToken
    ) Strategy(_token, _fundManager, _treasury) {
        require(_cToken != address(0), "cToken = zero address");
        cToken = CErc20(_cToken);
        IERC20(_token).safeApprove(_cToken, type(uint).max);

        _setDex(0xd9e1cE17f2641f24aE83637ab66a2cca9C378B9F); // Sushiswap
    }

    function _setDex(address _dex) private {
        if (dex != address(0)) {
            comp.safeApprove(dex, 0);
        }

        dex = _dex;

        comp.safeApprove(_dex, type(uint).max);
    }

    function setDex(address _dex) external onlyTimeLock {
        require(_dex != address(0), "dex = 0 address");
        _setDex(_dex);
    }

    function _totalAssets() private view returns (uint total) {
        // WARNING: This returns balance last time someone transacted with cToken
        (uint error, uint cTokenBal, uint borrowed, uint exchangeRate) = cToken
        .getAccountSnapshot(address(this));

        if (error > 0) {
            // something is wrong, return 0
            return 0;
        }
        uint supplied = cTokenBal.mul(exchangeRate) / 1e18;
        if (supplied < borrowed) {
            // something is wrong, return 0
            return 0;
        }
        total = token.balanceOf(address(this)).add(supplied - borrowed);
    }

    /*
    @notice Returns amount of tokens locked in this contract
    */
    function totalAssets() external view override returns (uint) {
        return _totalAssets();
    }

    /*
    @dev buffer = 0 means safe collateral ratio = market collateral ratio
         buffer = 1e18 means safe collateral ratio = 0
    */
    function setBuffer(uint _buffer) external onlyAuthorized {
        require(_buffer > 0 && _buffer <= 1e18, "buffer");
        buffer = _buffer;
    }

    function _getMarketCollateralRatio() private view returns (uint) {
        /*
        This can be changed by Compound Governance, with a minimum waiting
        period of five days
        */
        (, uint col, ) = comptroller.markets(address(cToken));
        return col;
    }

    function _getSafeCollateralRatio(uint _marketCol) private view returns (uint) {
        if (_marketCol > buffer) {
            return _marketCol - buffer;
        }
        return 0;
    }

    // Not view function
    function _getSupplied() private returns (uint) {
        return cToken.balanceOfUnderlying(address(this));
    }

    // Not view function
    function _getBorrowed() private returns (uint) {
        return cToken.borrowBalanceCurrent(address(this));
    }

    // Not view function. Call using static call from web3
    function getLivePosition()
        external
        returns (
            uint supplied,
            uint borrowed,
            uint marketCol,
            uint safeCol
        )
    {
        supplied = _getSupplied();
        borrowed = _getBorrowed();
        marketCol = _getMarketCollateralRatio();
        safeCol = _getSafeCollateralRatio(marketCol);
    }

    // @dev This returns balance last time someone transacted with cToken
    function getCachedPosition()
        external
        view
        returns (
            uint supplied,
            uint borrowed,
            uint marketCol,
            uint safeCol
        )
    {
        // ignore first output, which is error code
        (, uint cTokenBal, uint _borrowed, uint exchangeRate) = cToken
        .getAccountSnapshot(address(this));
        supplied = cTokenBal.mul(exchangeRate) / 1e18;
        borrowed = _borrowed;
        marketCol = _getMarketCollateralRatio();
        safeCol = _getSafeCollateralRatio(marketCol);
    }

    // @dev This modifier checks collateral ratio after leverage or deleverage
    modifier checkCollateralRatio() {
        _;
        uint supplied = _getSupplied();
        uint borrowed = _getBorrowed();
        uint marketCol = _getMarketCollateralRatio();
        uint safeCol = _getSafeCollateralRatio(marketCol);
        // borrowed / supplied <= safe col
        // supplied can = 0 so we check borrowed <= supplied * safe col
        // max borrow
        uint max = supplied.mul(safeCol) / 1e18;
        require(borrowed <= max, "borrowed > max");
    }

    // @dev In case infinite approval is reduced so that strategy cannot function
    function approve(uint _amount) external onlyAuthorized {
        token.safeApprove(address(cToken), _amount);
    }

    function _supply(uint _amount) private {
        require(cToken.mint(_amount) == 0, "mint");
    }

    // @dev Execute manual recovery by admin
    // @dev `_amount` must be >= balance of token
    function supplyManual(uint _amount) external onlyAuthorized {
        _supply(_amount);
    }

    function _borrow(uint _amount) private {
        require(cToken.borrow(_amount) == 0, "borrow");
    }

    // @dev Execute manual recovery by admin
    function borrowManual(uint _amount) external onlyAuthorized {
        _borrow(_amount);
    }

    function _repay(uint _amount) private {
        require(cToken.repayBorrow(_amount) == 0, "repay");
    }

    // @dev Execute manual recovery by admin
    // @dev `_amount` must be >= balance of token
    function repayManual(uint _amount) external onlyAuthorized {
        _repay(_amount);
    }

    function _redeem(uint _amount) private {
        require(cToken.redeemUnderlying(_amount) == 0, "redeem");
    }

    // @dev Execute manual recovery by admin
    function redeemManual(uint _amount) external onlyAuthorized {
        _redeem(_amount);
    }

    function _getMaxLeverageRatio(uint _col) private pure returns (uint) {
        /*
        c = collateral ratio
        geometric series converges to
            1 / (1 - c)
        */
        // multiplied by 1e18
        return uint(1e36).div(uint(1e18).sub(_col));
    }

    function _getBorrowAmount(
        uint _supplied,
        uint _borrowed,
        uint _col
    ) private pure returns (uint) {
        /*
        c = collateral ratio
        s = supplied
        b = borrowed
        x = amount to borrow
        (b + x) / s <= c
        becomes
        x <= sc - b
        */
        // max borrow
        uint max = _supplied.mul(_col) / 1e18;
        if (_borrowed >= max) {
            return 0;
        }
        return max - _borrowed;
    }

    /*
    Find total supply S_n after n iterations starting with
    S_0 supplied and B_0 borrowed
    c = collateral ratio
    S_i = supplied after i iterations
    B_i = borrowed after i iterations
    S_0 = current supplied
    B_0 = current borrowed
    borrowed and supplied after n iterations
        B_n = cS_(n-1)
        S_n = S_(n-1) + (cS_(n-1) - B_(n-1))
    you can prove using algebra and induction that
        B_n / S_n <= c
        S_n - S_(n-1) = c^(n-1) * (cS_0 - B_0)
        S_n = S_0 + sum (c^i * (cS_0 - B_0)), 0 <= i <= n - 1
            = S_0 + (1 - c^n) / (1 - c)
        S_n <= S_0 + (cS_0 - B_0) / (1 - c)
    */
    function _leverage(uint _targetSupply) private checkCollateralRatio {
        // buffer = 1e18 means safe collateral ratio = 0
        if (buffer >= 1e18) {
            return;
        }
        uint supplied = _getSupplied();
        uint borrowed = _getBorrowed();
        uint unleveraged = supplied.sub(borrowed); // supply with 0 leverage
        require(_targetSupply >= supplied, "leverage");
        uint marketCol = _getMarketCollateralRatio();
        uint safeCol = _getSafeCollateralRatio(marketCol);
        uint lev = _getMaxLeverageRatio(safeCol);
        // 99% to be safe, and save gas
        uint max = (unleveraged.mul(lev) / 1e18).mul(9900) / 10000;
        if (_targetSupply >= max) {
            _targetSupply = max;
        }
        uint i;
        while (supplied < _targetSupply) {
            // target is usually reached in 9 iterations
            require(i < 25, "max iteration");
            // use market collateral to calculate borrow amount
            // this is done so that supplied can reach _targetSupply
            // 99.99% is borrowed to be safe
            uint borrowAmount = _getBorrowAmount(supplied, borrowed, marketCol).mul(
                9999
            ) / 10000;
            require(borrowAmount > 0, "borrow = 0");
            if (supplied.add(borrowAmount) > _targetSupply) {
                // borrow > 0 since supplied < _targetSupply
                borrowAmount = _targetSupply.sub(supplied);
            }
            _borrow(borrowAmount);
            // end loop with _supply, this ensures no borrowed amount is unutilized
            _supply(borrowAmount);
            // supplied > _getSupplied(), by about 3 * 1e12 %, but we use local variable to save gas
            supplied = supplied.add(borrowAmount);
            // _getBorrowed == borrowed
            borrowed = borrowed.add(borrowAmount);
            i++;
        }
    }

    function leverage(uint _targetSupply) external onlyAuthorized {
        _leverage(_targetSupply);
    }

    function _deposit() private {
        uint bal = token.balanceOf(address(this));
        if (bal > 0) {
            _supply(bal);
            // leverage to max
            _leverage(type(uint).max);
        }
    }

    /*
    @notice Deposit token into this strategy
    @param _amount Amount of token to deposit
    @param _min Minimum amount to borrow from fund manager
    */
    function deposit(uint _amount, uint _min) external override onlyAuthorized {
        require(_amount > 0, "deposit = 0");

        uint borrowed = fundManager.borrow(_amount);
        require(borrowed >= _min, "borrowed < min");

        _deposit();
        emit Deposit(_amount, borrowed);
    }

    function _getRedeemAmount(
        uint _supplied,
        uint _borrowed,
        uint _col
    ) private pure returns (uint) {
        /*
        c = collateral ratio
        s = supplied
        b = borrowed
        r = redeem
        b / (s - r) <= c
        becomes
        r <= s - b / c
        */
        // min supply
        // b / c = min supply needed to borrow b
        uint min = _borrowed.mul(1e18).div(_col);
        if (_supplied <= min) {
            return 0;
        }
        return _supplied - min;
    }

    /*
    Find S_0, amount of supply with 0 leverage, after n iterations starting with
    S_n supplied and B_n borrowed
    c = collateral ratio
    S_n = current supplied
    B_n = current borrowed
    S_(n-i) = supplied after i iterations
    B_(n-i) = borrowed after i iterations
    R_(n-i) = Redeemable after i iterations
        = S_(n-i) - B_(n-i) / c
        where B_(n-i) / c = min supply needed to borrow B_(n-i)
    For 0 <= k <= n - 1
        S_k = S_(k+1) - R_(k+1)
        B_k = B_(k+1) - R_(k+1)
    and
        S_k - B_k = S_(k+1) - B_(k+1)
    so
        S_0 - B_0 = S_1 - S_2 = ... = S_n - B_n
    S_0 has 0 leverage so B_0 = 0 and we get
        S_0 = S_0 - B_0 = S_n - B_n
    ------------------------------------------
    Find S_(n-k), amount of supply, after k iterations starting with
    S_n supplied and B_n borrowed
    with algebra and induction you can derive that
    R_(n-k) = R_n / c^k
    S_(n-k) = S_n - sum R_(n-i), 0 <= i <= k - 1
            = S_n - R_n * ((1 - 1/c^k) / (1 - 1/c))
    Equation above is valid for S_(n - k) k < n
    */
    function _deleverage(uint _targetSupply) private checkCollateralRatio {
        uint supplied = _getSupplied();
        uint borrowed = _getBorrowed();
        uint unleveraged = supplied.sub(borrowed);
        require(_targetSupply <= supplied, "deleverage");
        uint marketCol = _getMarketCollateralRatio();
        // min supply
        if (_targetSupply <= unleveraged) {
            _targetSupply = unleveraged;
        }
        uint i;
        while (supplied > _targetSupply) {
            // target is usually reached in 8 iterations
            require(i < 25, "max iteration");
            // 99.99% to be safe
            uint redeemAmount = (_getRedeemAmount(supplied, borrowed, marketCol)).mul(
                9999
            ) / 10000;
            require(redeemAmount > 0, "redeem = 0");
            if (supplied.sub(redeemAmount) < _targetSupply) {
                // redeem > 0 since supplied > _targetSupply
                redeemAmount = supplied.sub(_targetSupply);
            }
            _redeem(redeemAmount);
            _repay(redeemAmount);
            // supplied < _geSupplied(), by about 7 * 1e12 %
            supplied = supplied.sub(redeemAmount);
            // borrowed == _getBorrowed()
            borrowed = borrowed.sub(redeemAmount);
            i++;
        }
    }

    function deleverage(uint _targetSupply) external onlyAuthorized {
        _deleverage(_targetSupply);
    }

    // @dev Returns amount available for transfer
    function _withdraw(uint _amount) private returns (uint) {
        uint bal = token.balanceOf(address(this));
        if (_amount <= bal) {
            return _amount;
        }

        uint redeemAmount = _amount - bal;
        /*
        c = collateral ratio
        s = supplied
        b = borrowed
        r = amount to redeem
        x = amount to repay
        where
            r <= s - b (can't redeem more than unleveraged supply)
        and
            x <= b (can't repay more than borrowed)
        and
            (b - x) / (s - x - r) <= c (stay below c after redeem and repay)
        so pick x such that
            (b - cs + cr) / (1 - c) <= x <= b
        when b <= cs left side of equation above <= cr / (1 - c) so pick x such that
            cr / (1 - c) <= x <= b
        */
        uint supplied = _getSupplied();
        uint borrowed = _getBorrowed();
        uint marketCol = _getMarketCollateralRatio();
        uint safeCol = _getSafeCollateralRatio(marketCol);
        uint unleveraged = supplied.sub(borrowed);
        // r <= s - b
        if (redeemAmount > unleveraged) {
            redeemAmount = unleveraged;
        }
        // cr / (1 - c) <= x <= b
        uint repayAmount = redeemAmount.mul(safeCol).div(uint(1e18).sub(safeCol));
        if (repayAmount > borrowed) {
            repayAmount = borrowed;
        }

        _deleverage(supplied.sub(repayAmount));
        _redeem(redeemAmount);

        uint balAfter = token.balanceOf(address(this));
        if (balAfter < _amount) {
            return balAfter;
        }
        return _amount;
    }

    /*
    @notice Withdraw undelying token to erc20Vault
    @param _amount Amount of token to withdraw
    @dev Returns current loss = debt to fund manager - total assets
    @dev Caller should implement guard against slippage
    */
    function withdraw(uint _amount)
        external
        override
        onlyFundManager
        returns (uint loss)
    {
        require(_amount > 0, "withdraw = 0");

        // availabe <= _amount
        uint available = _withdraw(_amount);

        uint debt = fundManager.getDebt(address(this));
        uint total = _totalAssets();
        if (debt > total) {
            loss = debt - total;
        }

        if (available > 0) {
            token.safeTransfer(msg.sender, available);
        }

        emit Withdraw(_amount, available, loss);
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
        address _from,
        address _to,
        uint _amount
    ) private {
        // create dynamic array with 3 elements
        address[] memory path = new address[](3);
        path[0] = _from;
        path[1] = WETH;
        path[2] = _to;

        UniswapV2Router(dex).swapExactTokensForTokens(
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

        // claim COMP
        address[] memory cTokens = new address[](1);
        cTokens[0] = address(cToken);
        comptroller.claimComp(address(this), cTokens);

        uint compBal = comp.balanceOf(address(this));
        if (compBal > 0) {
            _swap(address(comp), address(token), compBal);
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
        uint free = 0;
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

        if (claimRewardsOnMigrate) {
            _claimRewards(1);
        }

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
        require(_token != address(cToken), "protected token");
        require(_token != address(comp), "protected token");
        IERC20(_token).safeTransfer(admin, IERC20(_token).balanceOf(address(this)));
    }
}



contract StrategyCompLevUsdc is StrategyCompLev {
    constructor(address _fundManager, address _treasury)
        StrategyCompLev(
            0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48,
            _fundManager,
            _treasury,
            0x39AA39c021dfbaE8faC545936693aC917d5E7563
        )
    {}
}