/**
 *Submitted for verification at Etherscan.io on 2020-12-10
*/

// SPDX-License-Identifier: MIT
// File: @openzeppelin/contracts/token/ERC20/IERC20.sol

pragma solidity ^0.6.0;

/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
 */


// File: @openzeppelin/contracts/math/SafeMath.sol

pragma solidity ^0.6.0;

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


// File: @openzeppelin/contracts/utils/Address.sol

pragma solidity ^0.6.2;

/**
 * @dev Collection of functions related to the address type
 */


// File: @openzeppelin/contracts/token/ERC20/SafeERC20.sol

pragma solidity ^0.6.0;

/**
 * @title SafeERC20
 * @dev Wrappers around ERC20 operations that throw on failure (when the token
 * contract returns false). Tokens that return no value (and instead revert or
 * throw on failure) are also supported, non-reverting calls are assumed to be
 * successful.
 * To use this library you can add a `using SafeERC20 for IERC20;` statement to your contract,
 * which allows you to call the safe operations as `token.safeTransfer(...)`, etc.
 */


// File: @openzeppelin/contracts/GSN/Context.sol

pragma solidity ^0.6.0;

/*
 * @dev Provides information about the current execution context, including the
 * sender of the transaction and its data. While these are generally available
 * via msg.sender and msg.data, they should not be accessed in such a direct
 * manner, since when dealing with GSN meta-transactions the account sending and
 * paying for execution may not be the actual sender (as far as an application
 * is concerned).
 *
 * This contract is only required for intermediate, library-like contracts.
 */
abstract contract Context {
    function _msgSender() internal view virtual returns (address payable) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes memory) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}

// File: @openzeppelin/contracts/access/Ownable.sol

pragma solidity ^0.6.0;

/**
 * @dev Contract module which provides a basic access control mechanism, where
 * there is an account (an owner) that can be granted exclusive access to
 * specific functions.
 *
 * By default, the owner account will be the one that deploys the contract. This
 * can later be changed with {transferOwnership}.
 *
 * This module is used through inheritance. It will make available the modifier
 * `onlyOwner`, which can be applied to your functions to restrict their use to
 * the owner.
 */
contract Ownable is Context {
    address private _governance;

    event GovernanceTransferred(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    constructor () internal {
        address msgSender = _msgSender();
        _governance = msgSender;
        emit GovernanceTransferred(address(0), msgSender);
    }

    /**
     * @dev Returns the address of the current owner.
     */
    function governance() public view returns (address) {
        return _governance;
    }

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyGovernance() {
        require(_governance == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferGovernance(address newOwner) internal virtual onlyGovernance {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        emit GovernanceTransferred(_governance, newOwner);
        _governance = newOwner;
    }
}

// File: contracts/strategies/StabilizeStrategyStablecoinArb.sol

pragma solidity ^0.6.6;

// This is a strategy that takes advantage of arb opportunities for multiple btc proxies
// Users deposit various tokens into the strategy and the strategy will sell into the lowest priced token
// Selling will occur via Curve and buying WETH via Uniswap
// Half the profit earned from the sell will be used to buy WETH and split it between the treasury
// Half will remain as btc proxies
// It will sell on deposits and withdrawals only when a non-contract calls it
// It will use 2 curve pools, one solely for wbtc and renbtc and another for those 2 plus sbtc

// This strategy uses optimizations to reduce gas fees such as trading only every 6 hours (modifiable)
// or on large entries and exits (greater than 10% pool - modifiable)







contract StabilizeStrategyBTCArb is Ownable {
    using SafeMath for uint256;
    using SafeERC20 for IERC20;
    using Address for address;
    
    address public treasuryAddress; // Address of the treasury
    address public stakingAddress; // Address to the STBZ staking pool
    address public zsTokenAddress; // The address of the controlling zs-Token
    
    uint256 constant divisionFactor = 100000;
    uint256 public secondsBeforeTrade = 21600; // 6 hours wait before trade triggered
    uint256 public lastTradeTime = 0; // The strategy will only sell once every 24 hours normally
    uint256 public lastActionBalance = 0; // Balance before last deposit or withdraw
    uint256 public percentTradeTrigger = 10000; // 10% change in value will trigger a trade
    uint256 public percentSell = 50000; // 50% of the tokens are sold to the cheapest token
    uint256 public percentDepositor = 50000; // 1000 = 1%, depositors earn 50% of all gains
    uint256 public percentStakers = 50000; // 50% of non-depositors WETH goes to stakers, can be changed
    uint256 constant minGain = 1e13; // Minimum amount of btc gain (0.00001 BTC) before buying WETH and splitting it
    
    // Token information
    // This strategy accepts multiple btc proxies
    // renBTC, wBTC, sBTC
    struct TokenInfo {
        IERC20 token; // Reference of token
        uint256 decimals; // Decimals of token
        int128 curveID; // ID in the curve Pool
    }
    
    TokenInfo[] private tokenList; // An array of tokens accepted as deposits

    // Strategy specific variables
    address constant curve2PoolAddress = address(0x93054188d876f558f4a66B2EF1d97d16eDf0895B); // Curve pool for 2 tokens renBTC, wBTC
    address constant curve3PoolAddress = address(0x7fC77b5c7614E1533320Ea6DDc2Eb61fa00A9714); // Curve pool for 3 tokens renBTC, wBTC, sBTC
    address constant uniswapRouterAddress = address(0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D); //Address of Uniswap

    constructor(
        address _treasury,
        address _staking,
        address _zsToken
    ) public {
        treasuryAddress = _treasury;
        stakingAddress = _staking;
        zsTokenAddress = _zsToken;
        setupWithdrawTokens();
    }

    // Initialization functions
    
    function setupWithdrawTokens() internal {
        // Start with renBTC
        IERC20 _token = IERC20(address(0xEB4C2781e4ebA804CE9a9803C67d0893436bB27D));
        tokenList.push(
            TokenInfo({
                token: _token,
                decimals: _token.decimals(),
                curveID: 0
            })
        );   
        
        // wBTC
        _token = IERC20(address(0x2260FAC5E5542a773Aa44fBCfeDf7C193bc2C599));
        tokenList.push(
            TokenInfo({
                token: _token,
                decimals: _token.decimals(),
                curveID: 1
            })
        );
        
        // sBTC
        _token = IERC20(address(0xfE18be6b3Bd88A2D2A7f928d00292E7a9963CfC6));
        tokenList.push(
            TokenInfo({
                token: _token,
                decimals: _token.decimals(),
                curveID: 2
            })
        );
    }
    
    // Modifier
    modifier onlyZSToken() {
        require(zsTokenAddress == _msgSender(), "Call not sent from the zs-Token");
        _;
    }
    
    // Read functions
    
    function rewardTokensCount() external view returns (uint256) {
        return tokenList.length;
    }
    
    function rewardTokenAddress(uint256 _pos) external view returns (address) {
        require(_pos < tokenList.length,"No token at that position");
        return address(tokenList[_pos].token);
    }
    
    function balance() public view returns (uint256) {
        return getNormalizedTotalBalance(address(this));
    }
    
    function getNormalizedTotalBalance(address _address) public view returns (uint256) {
        uint256 _balance = 0;
        for(uint256 i = 0; i < tokenList.length; i++){
            uint256 _bal = tokenList[i].token.balanceOf(_address);
            _bal = _bal.mul(1e18).div(10**tokenList[i].decimals);
            _balance = _balance.add(_bal); // This has been normalized to 1e18 decimals
        }
        return _balance;
    }
    
    function withdrawTokenReserves() public view returns (address, uint256) {
        // This function will return the address and amount of the token with the highest balance
        uint256 length = tokenList.length;
        uint256 targetID = 0;
        uint256 targetNormBalance = 0;
        for(uint256 i = 0; i < length; i++){
            uint256 _normBal = tokenList[i].token.balanceOf(address(this)).mul(1e18).div(10**tokenList[i].decimals);
            if(_normBal > 0){
                if(targetNormBalance == 0 || _normBal >= targetNormBalance){
                    targetNormBalance = _normBal;
                    targetID = i;
                }
            }
        }
        if(targetNormBalance > 0){
            return (address(tokenList[targetID].token), tokenList[targetID].token.balanceOf(address(this)));
        }else{
            return (address(0), 0); // No balance
        }
    }
    
    // Write functions
    
    function enter() external onlyZSToken {
        deposit(false);
    }
    
    function exit() external onlyZSToken {
        // The ZS token vault is removing all tokens from this strategy
        withdraw(_msgSender(),1,1, false);
    }
    
    function deposit(bool nonContract) public onlyZSToken {
        // Only the ZS token can call the function
        
        if(nonContract == true){
            // Only when depositing via a non-contract will this be called
            uint256 diff = balance().sub(lastActionBalance);
            // Trade if long time since last trade or deposited a large amount of tokens
            if(now.sub(lastTradeTime) > secondsBeforeTrade || diff > lastActionBalance.mul(percentTradeTrigger).div(divisionFactor)){
                checkAndSwapTokens();
            }
            lastActionBalance = balance();
        }
    }
    
    function getCheapestCurveToken() internal view returns (uint256) {
        // This will give us the ID of the cheapest token in the pool
        // We will estimate the return for trading 1 BTC
        // The higher the return, the lower the price of the other token
        uint256 targetID = 0; // Our target ID is renBTC first
        CurvePool pool1 = CurvePool(curve2PoolAddress);
        CurvePool pool2 = CurvePool(curve3PoolAddress);
        uint256 renBTCAmount = uint256(1).mul(10**tokenList[0].decimals);
        uint256 highAmount = renBTCAmount;
        for(uint256 i = 1; i < tokenList.length; i++){
            uint256 estimate = 0;
            if(i == 2){
                // sBTC uses pool2
                estimate = pool2.get_dy_underlying(tokenList[0].curveID, tokenList[i].curveID, renBTCAmount);
            }else{
                estimate = pool1.get_dy_underlying(tokenList[0].curveID, tokenList[i].curveID, renBTCAmount);
            }
            
            // Normalize the estimate into renBTC decimals
            estimate = estimate.mul(10**tokenList[0].decimals).div(10**tokenList[i].decimals);
            if(estimate > highAmount){
                // This token is worth less than the renBTC
                highAmount = estimate;
                targetID = i;
            }
        }
        return targetID;
    }
    
    function checkAndSwapTokens() internal {

        CurvePool pool1 = CurvePool(curve2PoolAddress);
        CurvePool pool2 = CurvePool(curve3PoolAddress);
        
        // Now find our target token to sell into
        uint256 targetID = getCheapestCurveToken();
        uint256 length = tokenList.length;

        // Now sell all the other tokens into this token
        uint256 _totalBalance = balance(); // Get the token balance at this contract, should increase
        bool _expectIncrease = false;
        for(uint256 i = 0; i < length; i++){
            if(i != targetID){
                uint256 localTarget = targetID;
                CurvePool targetPool = pool1;
                if(localTarget == 2 || i == 2){
                    targetPool = pool2; // Must use the 3 pool since we are buying sBTC or selling BTC
                }

                uint256 sellBalance = tokenList[i].token.balanceOf(address(this)).mul(percentSell).div(divisionFactor);
                uint256 minReceiveBalance = sellBalance.mul(10**tokenList[localTarget].decimals).div(10**tokenList[i].decimals); // Change to match decimals of destination
                if(sellBalance > 0){
                    uint256 estimate = targetPool.get_dy_underlying(tokenList[i].curveID, tokenList[localTarget].curveID, sellBalance);
                    if(estimate > minReceiveBalance){
                        _expectIncrease = true;
                        // We are getting a greater number of tokens, complete the exchange
                        tokenList[i].token.safeApprove(address(targetPool), sellBalance);
                        targetPool.exchange_underlying(tokenList[i].curveID, tokenList[localTarget].curveID, sellBalance, minReceiveBalance);
                    }                        
                }
            }
        }
        uint256 _newBalance = balance();
        if(_expectIncrease == true){
            // There may be rare scenarios where we don't gain any by calling this function
            require(_newBalance > _totalBalance, "Failed to gain in balance from selling tokens");
            lastTradeTime = now;
        }
        uint256 gain = _newBalance.sub(_totalBalance);
        if(gain >= minGain){
            // Minimum gain required to buy WETH is about 0.00001 BTC
            // Buy WETH from Uniswap with stablecoin
            uint256 sellBalance = gain.mul(10**tokenList[targetID].decimals).div(1e18); // Convert to target decimals
            uint256 holdBalance = sellBalance.mul(percentDepositor).div(divisionFactor);
            sellBalance = sellBalance.sub(holdBalance); // We will buy WETH with this amount
            if(sellBalance <= tokenList[targetID].token.balanceOf(address(this))){
                UniswapRouter router = UniswapRouter(uniswapRouterAddress);
                IERC20 weth = IERC20(router.WETH());
                // Sell some of our gained token for WETH
                swapUniswap(address(tokenList[targetID].token), address(weth), sellBalance);
                uint256 _wethBalance = weth.balanceOf(address(this));
                if(_wethBalance > 0){
                    // Split the amount sent to the treasury and stakers
                    uint256 stakersAmount = _wethBalance.mul(percentStakers).div(divisionFactor);
                    uint256 treasuryAmount = _wethBalance.sub(stakersAmount);
                    if(treasuryAmount > 0){
                        weth.safeTransfer(treasuryAddress, treasuryAmount);
                    }
                    if(stakersAmount > 0){
                        if(stakingAddress != address(0)){
                            weth.safeTransfer(stakingAddress, stakersAmount);
                            StabilizeStakingPool(stakingAddress).notifyRewardAmount(stakersAmount);                                
                        }else{
                            // No staking pool selected, just send to the treasury
                            weth.safeTransfer(treasuryAddress, stakersAmount);
                        }
                    }
                }
            }
        }
    }
    
    function swapUniswap(address _from, address _to, uint256 _sellAmount) internal {
        require(_to != address(0));

        address[] memory path;
        UniswapRouter router = UniswapRouter(uniswapRouterAddress);
        address weth = router.WETH();

        if (_from == weth || _to == weth) {
            path = new address[](2);
            path[0] = _from;
            path[1] = _to;
        } else {
            path = new address[](3);
            path[0] = _from;
            path[1] = weth;
            path[2] = _to;
        }

        IERC20(_from).safeApprove(address(router), 0); // Some tokens require this to be set to 0 first
        IERC20(_from).safeApprove(address(router), _sellAmount);
        router.swapExactTokensForTokens(_sellAmount, 1, path, address(this), now.add(60));
    }
    
    function expectedProfit() external view returns (uint256) {
        // This view will return the amount of gain a forced swap will make on next call
        CurvePool pool1 = CurvePool(curve2PoolAddress);
        CurvePool pool2 = CurvePool(curve3PoolAddress);
        
        // Now find our target token to sell into
        uint256 targetID = getCheapestCurveToken();
        uint256 length = tokenList.length;

        // Now simulate sell all the other tokens into this token
        uint256 _normalizedGain = 0;
        for(uint256 i = 0; i < length; i++){
            if(i != targetID){
                uint256 localTarget = targetID;
                CurvePool targetPool = pool1;
                if(localTarget == 2 || i == 2){
                    targetPool = pool2; // Must use the 3 pool since we are buying sBTC or selling sBTC
                }

                uint256 sellBalance = tokenList[i].token.balanceOf(address(this)).mul(percentSell).div(divisionFactor);
                uint256 minReceiveBalance = sellBalance.mul(10**tokenList[localTarget].decimals).div(10**tokenList[i].decimals); // Change to match decimals of destination
                if(sellBalance > 0){
                    uint256 estimate = targetPool.get_dy_underlying(tokenList[i].curveID, tokenList[localTarget].curveID, sellBalance);
                    if(estimate > minReceiveBalance){
                        uint256 _gain = estimate.sub(minReceiveBalance).mul(1e18).div(10**tokenList[localTarget].decimals); // Normalized gain
                        _normalizedGain = _normalizedGain.add(_gain);
                    }                        
                }
            }
        }
        return _normalizedGain;   
    }
    
    function withdraw(address _depositor, uint256 _share, uint256 _total, bool nonContract) public onlyZSToken returns (uint256) {
        require(balance() > 0, "There are no tokens in this strategy");
        if(nonContract == true){
            if(now.sub(lastTradeTime) > secondsBeforeTrade || _share > _total.mul(percentTradeTrigger).div(divisionFactor)){
                checkAndSwapTokens();
            }
        }
        
        uint256 withdrawAmount = 0;
        uint256 _balance = balance();
        if(_share < _total){
            uint256 _myBalance = _balance.mul(_share).div(_total);
            withdrawPerBalance(_depositor, _myBalance, false); // This will withdraw based on token price
            withdrawAmount = _myBalance;
        }else{
            // We are all shares, transfer all
            withdrawPerBalance(_depositor, _balance, true);
            withdrawAmount = _balance;
        }       
        lastActionBalance = balance();
        
        return withdrawAmount;
    }
    
    // This will withdraw the tokens from the contract based on their balance, from highest balance to lowest
    function withdrawPerBalance(address _receiver, uint256 _withdrawAmount, bool _takeAll) internal {
        uint256 length = tokenList.length;
        if(_takeAll == true){
            // Send the entire balance
            for(uint256 i = 0; i < length; i++){
                uint256 _bal = tokenList[i].token.balanceOf(address(this));
                if(_bal > 0){
                    tokenList[i].token.safeTransfer(_receiver, _bal);
                }
            }
            return;
        }
        bool[4] memory done;
        uint256 targetID = 0;
        uint256 targetNormBalance = 0;
        for(uint256 i = 0; i < length; i++){
            
            targetNormBalance = 0; // Reset the target balance
            // Find the highest balanced token to withdraw
            for(uint256 i2 = 0; i2 < length; i2++){
                if(done[i2] == false){
                    uint256 _normBal = tokenList[i2].token.balanceOf(address(this)).mul(1e18).div(10**tokenList[i2].decimals);
                    if(targetNormBalance == 0 || _normBal >= targetNormBalance){
                        targetNormBalance = _normBal;
                        targetID = i2;
                    }
                }
            }
            done[targetID] = true;
            
            // Determine the balance left
            uint256 _normalizedBalance = tokenList[targetID].token.balanceOf(address(this)).mul(1e18).div(10**tokenList[targetID].decimals);
            if(_normalizedBalance <= _withdrawAmount){
                // Withdraw the entire balance of this token
                if(_normalizedBalance > 0){
                    _withdrawAmount = _withdrawAmount.sub(_normalizedBalance);
                    tokenList[targetID].token.safeTransfer(_receiver, tokenList[targetID].token.balanceOf(address(this)));                    
                }
            }else{
                // Withdraw a partial amount of this token
                if(_withdrawAmount > 0){
                    // Convert the withdraw amount to the token's decimal amount
                    uint256 _balance = _withdrawAmount.mul(10**tokenList[targetID].decimals).div(1e18);
                    _withdrawAmount = 0;
                    tokenList[targetID].token.safeTransfer(_receiver, _balance);
                }
                break; // Nothing more to withdraw
            }
        }
    }
    
    // Governance functions
    function forceSwapTokens() external onlyGovernance {
        // This is function that force trade tokens at anytime. It can only be called by governance
        checkAndSwapTokens();
    }
    
    // Timelock variables
    
    uint256 private _timelockStart; // The start of the timelock to change governance variables
    uint256 private _timelockType; // The function that needs to be changed
    uint256 constant _timelockDuration = 86400; // Timelock is 24 hours
    
    // Reusable timelock variables
    address private _timelock_address;
    uint256 private _timelock_data_1;
    
    modifier timelockConditionsMet(uint256 _type) {
        require(_timelockType == _type, "Timelock not acquired for this function");
        _timelockType = 0; // Reset the type once the timelock is used
        if(balance() > 0){ // Timelock only applies when balance exists
            require(now >= _timelockStart + _timelockDuration, "Timelock time not met");
        }
        _;
    }
    
    // Change the owner of the token contract
    // --------------------
    function startGovernanceChange(address _address) external onlyGovernance {
        _timelockStart = now;
        _timelockType = 1;
        _timelock_address = _address;       
    }
    
    function finishGovernanceChange() external onlyGovernance timelockConditionsMet(1) {
        transferGovernance(_timelock_address);
    }
    // --------------------
    
    // Change the treasury address
    // --------------------
    function startChangeTreasury(address _address) external onlyGovernance {
        _timelockStart = now;
        _timelockType = 2;
        _timelock_address = _address;
    }
    
    function finishChangeTreasury() external onlyGovernance timelockConditionsMet(2) {
        treasuryAddress = _timelock_address;
    }
    // --------------------
    
    // Change the percent going to depositors for WETH
    // --------------------
    function startChangeDepositorPercent(uint256 _percent) external onlyGovernance {
        require(_percent <= 100000,"Percent cannot be greater than 100%");
        _timelockStart = now;
        _timelockType = 3;
        _timelock_data_1 = _percent;
    }
    
    function finishChangeDepositorPercent() external onlyGovernance timelockConditionsMet(3) {
        percentDepositor = _timelock_data_1;
    }
    // --------------------
    
    // Change the staking address
    // --------------------
    function startChangeStakingPool(address _address) external onlyGovernance {
        _timelockStart = now;
        _timelockType = 4;
        _timelock_address = _address;
    }
    
    function finishChangeStakingPool() external onlyGovernance timelockConditionsMet(4) {
        stakingAddress = _timelock_address;
    }
    // --------------------
    
    // Change the zsToken address
    // --------------------
    function startChangeZSToken(address _address) external onlyGovernance {
        _timelockStart = now;
        _timelockType = 5;
        _timelock_address = _address;
    }
    
    function finishChangeZSToken() external onlyGovernance timelockConditionsMet(5) {
        zsTokenAddress = _timelock_address;
    }
    // --------------------
    
    // Change the percent going to stakers for WETH
    // --------------------
    function startChangeStakersPercent(uint256 _percent) external onlyGovernance {
        require(_percent <= 100000,"Percent cannot be greater than 100%");
        _timelockStart = now;
        _timelockType = 6;
        _timelock_data_1 = _percent;
    }
    
    function finishChangeStakersPercent() external onlyGovernance timelockConditionsMet(6) {
        percentStakers = _timelock_data_1;
    }
    // --------------------
    
    // Change the percent sold of each token
    // --------------------
    function startChangePercentSold(uint256 _percent) external onlyGovernance {
        require(_percent <= 100000,"Percent cannot be greater than 100%");
        _timelockStart = now;
        _timelockType = 7;
        _timelock_data_1 = _percent;
    }
    
    function finishChangePercentSold() external onlyGovernance timelockConditionsMet(7) {
        percentSell = _timelock_data_1;
    }
    // --------------------
    
    // Change the amount of seconds before trading
    // --------------------
    function startTradeWaitTime(uint256 _seconds) external onlyGovernance {
        _timelockStart = now;
        _timelockType = 8;
        _timelock_data_1 = _seconds;
    }
    
    function finishTradeWaitTime() external onlyGovernance timelockConditionsMet(8) {
        secondsBeforeTrade = _timelock_data_1;
    }
    // --------------------
    
    // Change percent of balance to trigger trade
    // --------------------
    function startChangePercentTradeTrigger(uint256 _percent) external onlyGovernance {
        require(_percent <= 100000,"Percent cannot be greater than 100%");
        _timelockStart = now;
        _timelockType = 9;
        _timelock_data_1 = _percent;
    }
    
    function finishChangePercentTradeTrigger() external onlyGovernance timelockConditionsMet(9) {
        percentTradeTrigger = _timelock_data_1;
    }
    // --------------------
    

}