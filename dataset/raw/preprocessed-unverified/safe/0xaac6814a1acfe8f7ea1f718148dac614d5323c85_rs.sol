/**
 *Submitted for verification at Etherscan.io on 2021-04-28
*/

// SPDX-License-Identifier: BSD-3-Clause

pragma solidity 0.6.11;

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


/**
 * @dev Collection of functions related to the address type
 */


/**
 * @dev Library for managing
 * https://en.wikipedia.org/wiki/Set_(abstract_data_type)[sets] of primitive
 * types.
 *
 * Sets have the following properties:
 *
 * - Elements are added, removed, and checked for existence in constant time
 * (O(1)).
 * - Elements are enumerated in O(n). No guarantees are made on the ordering.
 *
 * ```
 * contract Example {
 *     // Add the library methods
 *     using EnumerableSet for EnumerableSet.AddressSet;
 *
 *     // Declare a set state variable
 *     EnumerableSet.AddressSet private mySet;
 * }
 * ```
 *
 * As of v3.0.0, only sets of type `address` (`AddressSet`) and `uint256`
 * (`UintSet`) are supported.
 */


/**
 * @title SafeERC20
 * @dev Wrappers around ERC20 operations that throw on failure (when the token
 * contract returns false). Tokens that return no value (and instead revert or
 * throw on failure) are also supported, non-reverting calls are assumed to be
 * successful.
 * To use this library you can add a `using SafeERC20 for IERC20;` statement to your contract,
 * which allows you to call the safe operations as `token.safeTransfer(...)`, etc.
 */


/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
 */


/**
 * @dev Contract module that helps prevent reentrant calls to a function.
 *
 * Inheriting from `ReentrancyGuard` will make the {nonReentrant} modifier
 * available, which can be applied to functions to make sure there are no nested
 * (reentrant) calls to them.
 *
 * Note that because there is a single `nonReentrant` guard, functions marked as
 * `nonReentrant` may not call one another. This can be worked around by making
 * those functions `private`, and then adding `external` `nonReentrant` entry
 * points to them.
 *
 * TIP: If you would like to learn more about reentrancy and alternative ways
 * to protect against it, check out our blog post
 * https://blog.openzeppelin.com/reentrancy-after-istanbul/[Reentrancy After Istanbul].
 */
contract ReentrancyGuard {
    // Booleans are more expensive than uint256 or any type that takes up a full
    // word because each write operation emits an extra SLOAD to first read the
    // slot's contents, replace the bits taken up by the boolean, and then write
    // back. This is the compiler's defense against contract upgrades and
    // pointer aliasing, and it cannot be disabled.

    // The values being non-zero value makes deployment a bit more expensive,
    // but in exchange the refund on every call to nonReentrant will be lower in
    // amount. Since refunds are capped to a percentage of the total
    // transaction's gas, it is best to keep them low in cases like this one, to
    // increase the likelihood of the full refund coming into effect.
    uint256 private constant _NOT_ENTERED = 1;
    uint256 private constant _ENTERED = 2;

    uint256 private _status;

    constructor () internal {
        _status = _NOT_ENTERED;
    }

    /**
     * @dev Prevents a contract from calling itself, directly or indirectly.
     * Calling a `nonReentrant` function from another `nonReentrant`
     * function is not supported. It is possible to prevent this from happening
     * by making the `nonReentrant` function external, and make it call a
     * `private` function that does the actual work.
     */
    modifier nonReentrant() {
        // On the first call to nonReentrant, _notEntered will be true
        require(_status != _ENTERED, "ReentrancyGuard: reentrant call");

        // Any calls to nonReentrant after this point will fail
        _status = _ENTERED;

        _;

        // By storing the original value once again, a refund is triggered (see
        // https://eips.ethereum.org/EIPS/eip-2200)
        _status = _NOT_ENTERED;
    }
}

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






/**
 * Accounting:
 *      - the smart contract maintains a ledger of token balances which changes upon actions affecting 
 *          this smart contract's token balance.
 * 
 *      - it allows owner to withdraw any extra amount of any tokens that have not been recorded, 
 *          i.e, - any tokens that are accidentally transferred to this smart contract.
 * 
 *      - care must be taken in auditing that `claimExtraTokens` function does not allow withdrawals of 
 *          any tokens in this smart contract in more amounts than necessary. In simple terms, admin can 
 *          only transfer out tokens that are accidentally sent to this smart contract. Nothing more nothing less.
 */
contract Vault is Ownable, ReentrancyGuard {
    using SafeMath for uint;
    using Address for address;
    using EnumerableSet for EnumerableSet.AddressSet;
    using SafeERC20 for IERC20;
    
    //==================== Contract Variables =======================
    // Contract variables must be changed before live deployment
    
    uint public constant LOCKUP_DURATION = 30 days;
    uint public constant FEE_PERCENT_X_100 = 30;
    uint public constant FEE_PERCENT_TO_BUYBACK_X_100 = 2500;
    
    uint public constant REWARD_INTERVAL = 365 days;
    uint public constant ADMIN_CAN_CLAIM_AFTER = 395 days;
    uint public constant REWARD_RETURN_PERCENT_X_100 = 1250;
    
    // ETH fee equivalent predefined gas price
    uint public constant MIN_ETH_FEE_IN_WEI = 40000 * 1 * 10**9;
    
    address public constant TRUSTED_DEPOSIT_TOKEN_ADDRESS = 0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48;
    address public constant TRUSTED_CTOKEN_ADDRESS = 0x39AA39c021dfbaE8faC545936693aC917d5E7563;
    address public constant TRUSTED_PLATFORM_TOKEN_ADDRESS = 0x961C8c0B1aaD0c0b10a51FeF6a867E3091BCef17;
    
    address public constant BURN_ADDRESS = 0x000000000000000000000000000000000000dEaD;
    
    //================= End Contract Variables ======================
    
    uint public constant ONE_HUNDRED_X_100 = 10000;
    uint public immutable contractStartTime;
    
    constructor() public {
        contractStartTime = block.timestamp;
    }
    
    IUniswapV2Router public constant uniswapRouterV2 = IUniswapV2Router(0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D);
    
    modifier noContractsAllowed() {
        require(tx.origin == msg.sender, "No Contracts Allowed!");
        _;
    }
    
    // ------------------- event definitions -------------------
    
    event Deposit(address indexed account, uint amount);
    event Withdraw(address indexed account, uint amount);
    
    event EtherRewardDisbursed(uint amount);
    event TokenRewardDisbursed(uint amount);
    
    event PlatformTokenRewardClaimed(address indexed account, uint amount);
    event CompoundRewardClaimed(address indexed account, uint amount);
    event EtherRewardClaimed(address indexed account, uint amount);
    event TokenRewardClaimed(address indexed account, uint amount);
    
    event PlatformTokenAdded(uint amount);
    
    // ----------------- end event definitions -----------------
    
    EnumerableSet.AddressSet private holders;
    
    // view functon to get number of stakers
    function getNumberOfHolders() public view returns (uint) {
        return holders.length();
    }
    
    // token contract address => token balance of this contract
    mapping (address => uint) public tokenBalances;
    
    // user wallet => balance
    mapping (address => uint) public cTokenBalance;
    mapping (address => uint) public depositTokenBalance;
    
    mapping (address => uint) public totalTokensDepositedByUser;
    mapping (address => uint) public totalTokensWithdrawnByUser;
    
    mapping (address => uint) public totalEarnedCompoundDivs;
    mapping (address => uint) public totalEarnedEthDivs;
    mapping (address => uint) public totalEarnedTokenDivs;
    mapping (address => uint) public totalEarnedPlatformTokenDivs;
    
    mapping (address => uint) public depositTime;
    mapping (address => uint) public lastClaimedTime;
    
    uint public totalCTokens;
    uint public totalDepositedTokens;
    
    // -----------------
    
    uint public constant POINT_MULTIPLIER = 1e18;
    
    mapping (address => uint) public lastTokenDivPoints;
    mapping (address => uint) public tokenDivsBalance;
    uint public totalTokenDivPoints;
    
    mapping (address => uint) public lastEthDivPoints;
    mapping (address => uint) public ethDivsBalance;
    uint public totalEthDivPoints;
    
    mapping (address => uint) public platformTokenDivsBalance;
    
    uint public totalEthDisbursed;
    uint public totalTokensDisbursed;
   
    
    function tokenDivsOwing(address account) public view returns (uint) {
        uint newDivPoints = totalTokenDivPoints.sub(lastTokenDivPoints[account]);
        return depositTokenBalance[account].mul(newDivPoints).div(POINT_MULTIPLIER);
    }
    function ethDivsOwing(address account) public view returns (uint) {
        uint newDivPoints = totalEthDivPoints.sub(lastEthDivPoints[account]);
        return depositTokenBalance[account].mul(newDivPoints).div(POINT_MULTIPLIER);
    }
    
    function distributeEthDivs(uint amount) private {
        if (totalDepositedTokens == 0) return;
        totalEthDivPoints = totalEthDivPoints.add(amount.mul(POINT_MULTIPLIER).div(totalDepositedTokens));
        totalEthDisbursed = totalEthDisbursed.add(amount);
        increaseTokenBalance(address(0), amount);
        emit EtherRewardDisbursed(amount);
    }
    function distributeTokenDivs(uint amount) private {
        if (totalDepositedTokens == 0) return;
        totalTokenDivPoints = totalTokenDivPoints.add(amount.mul(POINT_MULTIPLIER).div(totalDepositedTokens));
        totalTokensDisbursed = totalTokensDisbursed.add(amount);
        increaseTokenBalance(TRUSTED_DEPOSIT_TOKEN_ADDRESS, amount);
        emit TokenRewardDisbursed(amount);
    }
    
    
    // -----------------
    
    // view function to get depositors list
    function getDepositorsList(uint startIndex, uint endIndex)
        public
        view
        returns (address[] memory stakers,
            uint[] memory stakingTimestamps,
            uint[] memory lastClaimedTimeStamps,
            uint[] memory stakedTokens) {
        require (startIndex < endIndex);

        uint length = endIndex.sub(startIndex);
        address[] memory _stakers = new address[](length);
        uint[] memory _stakingTimestamps = new uint[](length);
        uint[] memory _lastClaimedTimeStamps = new uint[](length);
        uint[] memory _stakedTokens = new uint[](length);

        for (uint i = startIndex; i < endIndex; i = i.add(1)) {
            address staker = holders.at(i);
            uint listIndex = i.sub(startIndex);
            _stakers[listIndex] = staker;
            _stakingTimestamps[listIndex] = depositTime[staker];
            _lastClaimedTimeStamps[listIndex] = lastClaimedTime[staker];
            _stakedTokens[listIndex] = depositTokenBalance[staker];
        }

        return (_stakers, _stakingTimestamps, _lastClaimedTimeStamps, _stakedTokens);
    }

    function updateAccount(address account) private {
        // update user account here
        uint tokensOwing = tokenDivsOwing(account);
        lastTokenDivPoints[account] = totalTokenDivPoints;
        if (tokensOwing > 0) {
            tokenDivsBalance[account] = tokenDivsBalance[account].add(tokensOwing);
        }
        
        uint weiOwing = ethDivsOwing(account);
        lastEthDivPoints[account] = totalEthDivPoints;
        if (weiOwing > 0) {
            ethDivsBalance[account] = ethDivsBalance[account].add(weiOwing);
        }
        
        uint platformTokensOwing = platformTokenDivsOwing(account);
        if (platformTokensOwing > 0) {
            platformTokenDivsBalance[account] = platformTokenDivsBalance[account].add(platformTokensOwing);
        }
        
        lastClaimedTime[account] = block.timestamp;
    }
    
    function platformTokenDivsOwing(address account) public view returns (uint) {
        if (!holders.contains(account)) return 0;
        if (depositTokenBalance[account] == 0) return 0;
        
        uint timeDiff;
        uint stakingEndTime = contractStartTime.add(REWARD_INTERVAL);
        uint _now = block.timestamp;
        if (_now > stakingEndTime) {
            _now = stakingEndTime;
        }
        
        if (lastClaimedTime[account] >= _now) {
            timeDiff = 0;
        } else {
            timeDiff = _now.sub(lastClaimedTime[account]);
        }
        
        uint pendingDivs = depositTokenBalance[account]
                                .mul(REWARD_RETURN_PERCENT_X_100)
                                .mul(timeDiff)
                                .div(REWARD_INTERVAL)
                                .div(ONE_HUNDRED_X_100);
        return pendingDivs;
    }
    
    function getEstimatedCompoundDivsOwing(address account) public view returns (uint) {
        uint convertedBalance = getConvertedBalance(cTokenBalance[account]);
        uint depositedBalance = depositTokenBalance[account];
        return (convertedBalance > depositedBalance ? convertedBalance.sub(depositedBalance) : 0);
    }
    
    function getConvertedBalance(uint _cTokenBalance) public view returns (uint) {
        uint exchangeRateStored = getExchangeRateStored();
        uint convertedBalance = _cTokenBalance.mul(exchangeRateStored).div(10**18);
        return convertedBalance;
    }
    
    function _claimEthDivs() private {
        updateAccount(msg.sender);
        uint amount = ethDivsBalance[msg.sender];
        ethDivsBalance[msg.sender] = 0;
        if (amount == 0) return;
        decreaseTokenBalance(address(0), amount);
        msg.sender.transfer(amount);
        totalEarnedEthDivs[msg.sender] = totalEarnedEthDivs[msg.sender].add(amount);
        
        emit EtherRewardClaimed(msg.sender, amount);
    }
    function _claimTokenDivs() private {
        updateAccount(msg.sender);
        uint amount = tokenDivsBalance[msg.sender];
        tokenDivsBalance[msg.sender] = 0;
        if (amount == 0) return;
        decreaseTokenBalance(TRUSTED_DEPOSIT_TOKEN_ADDRESS, amount);
        IERC20(TRUSTED_DEPOSIT_TOKEN_ADDRESS).safeTransfer(msg.sender, amount);
        totalEarnedTokenDivs[msg.sender] = totalEarnedTokenDivs[msg.sender].add(amount);
        
        emit TokenRewardClaimed(msg.sender, amount);
    }
    function _claimCompoundDivs() private {
        updateAccount(msg.sender);
        uint exchangeRateCurrent = getExchangeRateCurrent();
        
        uint convertedBalance = cTokenBalance[msg.sender].mul(exchangeRateCurrent).div(10**18);
        uint depositedBalance = depositTokenBalance[msg.sender];
        
        uint amount = convertedBalance > depositedBalance ? convertedBalance.sub(depositedBalance) : 0;
        
        if (amount == 0) return;
        
        uint oldCTokenBalance = IERC20(TRUSTED_CTOKEN_ADDRESS).balanceOf(address(this));
        uint oldDepositTokenBalance = IERC20(TRUSTED_DEPOSIT_TOKEN_ADDRESS).balanceOf(address(this));
        require(CErc20(TRUSTED_CTOKEN_ADDRESS).redeemUnderlying(amount) == 0, "redeemUnderlying failed!");
        uint newCTokenBalance = IERC20(TRUSTED_CTOKEN_ADDRESS).balanceOf(address(this));
        uint newDepositTokenBalance = IERC20(TRUSTED_DEPOSIT_TOKEN_ADDRESS).balanceOf(address(this));
        
        uint depositTokenReceived = newDepositTokenBalance.sub(oldDepositTokenBalance);
        uint cTokenRedeemed = oldCTokenBalance.sub(newCTokenBalance);
        
        require(cTokenRedeemed <= cTokenBalance[msg.sender], "redeem exceeds balance!");
        cTokenBalance[msg.sender] = cTokenBalance[msg.sender].sub(cTokenRedeemed);
        totalCTokens = totalCTokens.sub(cTokenRedeemed);
        decreaseTokenBalance(TRUSTED_CTOKEN_ADDRESS, cTokenRedeemed);
        
        totalTokensWithdrawnByUser[msg.sender] = totalTokensWithdrawnByUser[msg.sender].add(depositTokenReceived);
        IERC20(TRUSTED_DEPOSIT_TOKEN_ADDRESS).safeTransfer(msg.sender, depositTokenReceived);
        
        totalEarnedCompoundDivs[msg.sender] = totalEarnedCompoundDivs[msg.sender].add(depositTokenReceived);
        
        emit CompoundRewardClaimed(msg.sender, depositTokenReceived);
    }
    function _claimPlatformTokenDivs(uint _amountOutMin_platformTokens) private {
        updateAccount(msg.sender);
        uint amount = platformTokenDivsBalance[msg.sender];
        
        if (amount == 0) return;
        
        address[] memory path = new address[](3);
        path[0] = TRUSTED_DEPOSIT_TOKEN_ADDRESS;
        path[1] = uniswapRouterV2.WETH();
        path[2] = TRUSTED_PLATFORM_TOKEN_ADDRESS;
        
        uint estimatedAmountOut = uniswapRouterV2.getAmountsOut(amount, path)[2];
        require(estimatedAmountOut >= _amountOutMin_platformTokens, "_claimPlatformTokenDivs: slippage error!");
        
        if (IERC20(TRUSTED_PLATFORM_TOKEN_ADDRESS).balanceOf(address(this)) < estimatedAmountOut) {
            return;
        }
        
        platformTokenDivsBalance[msg.sender] = 0;
        
        
        decreaseTokenBalance(TRUSTED_PLATFORM_TOKEN_ADDRESS, estimatedAmountOut);
        IERC20(TRUSTED_PLATFORM_TOKEN_ADDRESS).safeTransfer(msg.sender, estimatedAmountOut);
        totalEarnedPlatformTokenDivs[msg.sender] = totalEarnedPlatformTokenDivs[msg.sender].add(estimatedAmountOut);
        
        emit PlatformTokenRewardClaimed(msg.sender, estimatedAmountOut);
    }
    
    function claimEthDivs() external noContractsAllowed nonReentrant {
        _claimEthDivs();
    }
    function claimTokenDivs() external noContractsAllowed nonReentrant {
        _claimTokenDivs();
    }
    function claimCompoundDivs() external noContractsAllowed nonReentrant {
        _claimCompoundDivs();
    }
    function claimPlatformTokenDivs(uint _amountOutMin_platformTokens) external noContractsAllowed nonReentrant {
        _claimPlatformTokenDivs(_amountOutMin_platformTokens);
    }
    
    function claim(uint _amountOutMin_platformTokens) external noContractsAllowed nonReentrant {
        _claimEthDivs();
        _claimTokenDivs();
        _claimCompoundDivs();
        _claimPlatformTokenDivs(_amountOutMin_platformTokens);
    }
    
    function getExchangeRateCurrent() public returns (uint) {
        uint exchangeRateCurrent = CErc20(TRUSTED_CTOKEN_ADDRESS).exchangeRateCurrent();
        return exchangeRateCurrent;
    }
    
    function getExchangeRateStored() public view returns (uint) {
        uint exchangeRateStored = CErc20(TRUSTED_CTOKEN_ADDRESS).exchangeRateStored();
        return exchangeRateStored;
    }
    
    function deposit(uint amount, uint _amountOutMin_ethFeeBuyBack, uint deadline) external noContractsAllowed nonReentrant payable {
        require(amount > 0, "invalid amount!");
        
        updateAccount(msg.sender);
        
        // increment token balance!
        IERC20(TRUSTED_DEPOSIT_TOKEN_ADDRESS).safeTransferFrom(msg.sender, address(this), amount);
        

        totalTokensDepositedByUser[msg.sender] = totalTokensDepositedByUser[msg.sender].add(amount);
        
        IERC20(TRUSTED_DEPOSIT_TOKEN_ADDRESS).safeApprove(TRUSTED_CTOKEN_ADDRESS, 0);
        IERC20(TRUSTED_DEPOSIT_TOKEN_ADDRESS).safeApprove(TRUSTED_CTOKEN_ADDRESS, amount);
        
        uint oldCTokenBalance = IERC20(TRUSTED_CTOKEN_ADDRESS).balanceOf(address(this));
        require(CErc20(TRUSTED_CTOKEN_ADDRESS).mint(amount) == 0, "mint failed!");
        uint newCTokenBalance = IERC20(TRUSTED_CTOKEN_ADDRESS).balanceOf(address(this));
        uint cTokenReceived = newCTokenBalance.sub(oldCTokenBalance);
        
        cTokenBalance[msg.sender] = cTokenBalance[msg.sender].add(cTokenReceived);
        totalCTokens = totalCTokens.add(cTokenReceived);    
        increaseTokenBalance(TRUSTED_CTOKEN_ADDRESS, cTokenReceived);
        
        depositTokenBalance[msg.sender] = depositTokenBalance[msg.sender].add(amount);
        totalDepositedTokens = totalDepositedTokens.add(amount);
        
        handleEthFee(msg.value, _amountOutMin_ethFeeBuyBack, deadline);
        
        holders.add(msg.sender);
        depositTime[msg.sender] = block.timestamp;
        
        emit Deposit(msg.sender, amount);
    }
    function withdraw(uint amount, uint _amountOutMin_ethFeeBuyBack, uint _amountOutMin_tokenFeeBuyBack, uint deadline) external noContractsAllowed nonReentrant payable {
        require(amount > 0, "invalid amount!");
        require(amount <= depositTokenBalance[msg.sender], "Cannot withdraw more than deposited!");
        require(block.timestamp.sub(depositTime[msg.sender]) > LOCKUP_DURATION, "You recently deposited, please wait before withdrawing.");
        
        updateAccount(msg.sender);
        
        depositTokenBalance[msg.sender] = depositTokenBalance[msg.sender].sub(amount);
        totalDepositedTokens = totalDepositedTokens.sub(amount);
        
        uint oldCTokenBalance = IERC20(TRUSTED_CTOKEN_ADDRESS).balanceOf(address(this));
        uint oldDepositTokenBalance = IERC20(TRUSTED_DEPOSIT_TOKEN_ADDRESS).balanceOf(address(this));
        require(CErc20(TRUSTED_CTOKEN_ADDRESS).redeemUnderlying(amount) == 0, "redeemUnderlying failed!");
        uint newCTokenBalance = IERC20(TRUSTED_CTOKEN_ADDRESS).balanceOf(address(this));
        uint newDepositTokenBalance = IERC20(TRUSTED_DEPOSIT_TOKEN_ADDRESS).balanceOf(address(this));
        
        uint depositTokenReceived = newDepositTokenBalance.sub(oldDepositTokenBalance);
        uint cTokenRedeemed = oldCTokenBalance.sub(newCTokenBalance);
        
        require(cTokenRedeemed <= cTokenBalance[msg.sender], "redeem exceeds balance!");
        cTokenBalance[msg.sender] = cTokenBalance[msg.sender].sub(cTokenRedeemed);
        totalCTokens = totalCTokens.sub(cTokenRedeemed);
        decreaseTokenBalance(TRUSTED_CTOKEN_ADDRESS, cTokenRedeemed);
        
        totalTokensWithdrawnByUser[msg.sender] = totalTokensWithdrawnByUser[msg.sender].add(depositTokenReceived);
        
        uint feeAmount = depositTokenReceived.mul(FEE_PERCENT_X_100).div(ONE_HUNDRED_X_100);
        uint depositTokenReceivedAfterFee = depositTokenReceived.sub(feeAmount);
        
        IERC20(TRUSTED_DEPOSIT_TOKEN_ADDRESS).safeTransfer(msg.sender, depositTokenReceivedAfterFee);
        
        handleFee(feeAmount, _amountOutMin_tokenFeeBuyBack, deadline);
        handleEthFee(msg.value, _amountOutMin_ethFeeBuyBack, deadline);
        
        if (depositTokenBalance[msg.sender] == 0) {
            holders.remove(msg.sender);
        }
        
        emit Withdraw(msg.sender, depositTokenReceived);
    }
    
    // emergency withdraw without interacting with uniswap
    function emergencyWithdraw(uint amount) external noContractsAllowed nonReentrant payable {
        require(amount > 0, "invalid amount!");
        require(amount <= depositTokenBalance[msg.sender], "Cannot withdraw more than deposited!");
        require(block.timestamp.sub(depositTime[msg.sender]) > LOCKUP_DURATION, "You recently deposited, please wait before withdrawing.");
        
        updateAccount(msg.sender);
        
        depositTokenBalance[msg.sender] = depositTokenBalance[msg.sender].sub(amount);
        totalDepositedTokens = totalDepositedTokens.sub(amount);
        
        uint oldCTokenBalance = IERC20(TRUSTED_CTOKEN_ADDRESS).balanceOf(address(this));
        uint oldDepositTokenBalance = IERC20(TRUSTED_DEPOSIT_TOKEN_ADDRESS).balanceOf(address(this));
        require(CErc20(TRUSTED_CTOKEN_ADDRESS).redeemUnderlying(amount) == 0, "redeemUnderlying failed!");
        uint newCTokenBalance = IERC20(TRUSTED_CTOKEN_ADDRESS).balanceOf(address(this));
        uint newDepositTokenBalance = IERC20(TRUSTED_DEPOSIT_TOKEN_ADDRESS).balanceOf(address(this));
        
        uint depositTokenReceived = newDepositTokenBalance.sub(oldDepositTokenBalance);
        uint cTokenRedeemed = oldCTokenBalance.sub(newCTokenBalance);
        
        require(cTokenRedeemed <= cTokenBalance[msg.sender], "redeem exceeds balance!");
        cTokenBalance[msg.sender] = cTokenBalance[msg.sender].sub(cTokenRedeemed);
        totalCTokens = totalCTokens.sub(cTokenRedeemed);
        decreaseTokenBalance(TRUSTED_CTOKEN_ADDRESS, cTokenRedeemed);
        
        totalTokensWithdrawnByUser[msg.sender] = totalTokensWithdrawnByUser[msg.sender].add(depositTokenReceived);
        
        uint feeAmount = depositTokenReceived.mul(FEE_PERCENT_X_100).div(ONE_HUNDRED_X_100);
        uint depositTokenReceivedAfterFee = depositTokenReceived.sub(feeAmount);
        
        IERC20(TRUSTED_DEPOSIT_TOKEN_ADDRESS).safeTransfer(msg.sender, depositTokenReceivedAfterFee);
        
        // no uniswap interaction
        // handleFee(feeAmount, _amountOutMin_tokenFeeBuyBack, deadline);
        // handleEthFee(msg.value, _amountOutMin_ethFeeBuyBack, deadline);
        
        if (depositTokenBalance[msg.sender] == 0) {
            holders.remove(msg.sender);
        }
        
        emit Withdraw(msg.sender, depositTokenReceived);
    }
    
    function handleFee(uint feeAmount, uint _amountOutMin_tokenFeeBuyBack, uint deadline) private {
        uint buyBackFeeAmount = feeAmount.mul(FEE_PERCENT_TO_BUYBACK_X_100).div(ONE_HUNDRED_X_100);
        uint remainingFeeAmount = feeAmount.sub(buyBackFeeAmount);
        
        // handle distribution
        distributeTokenDivs(remainingFeeAmount);
        
        
        // handle buyback
        // --- swap token to platform token here! ----
        IERC20(TRUSTED_DEPOSIT_TOKEN_ADDRESS).safeApprove(address(uniswapRouterV2), 0);
        IERC20(TRUSTED_DEPOSIT_TOKEN_ADDRESS).safeApprove(address(uniswapRouterV2), buyBackFeeAmount);
        
        uint oldPlatformTokenBalance = IERC20(TRUSTED_PLATFORM_TOKEN_ADDRESS).balanceOf(address(this));
        address[] memory path = new address[](3);
        path[0] = TRUSTED_DEPOSIT_TOKEN_ADDRESS;
        path[1] = uniswapRouterV2.WETH();
        path[2] = TRUSTED_PLATFORM_TOKEN_ADDRESS;
        
        uniswapRouterV2.swapExactTokensForTokens(buyBackFeeAmount, _amountOutMin_tokenFeeBuyBack, path, address(this), deadline);
        uint newPlatformTokenBalance = IERC20(TRUSTED_PLATFORM_TOKEN_ADDRESS).balanceOf(address(this));
        uint platformTokensReceived = newPlatformTokenBalance.sub(oldPlatformTokenBalance);
        IERC20(TRUSTED_PLATFORM_TOKEN_ADDRESS).safeTransfer(BURN_ADDRESS, platformTokensReceived);
        // ---- end swap token to plaform tokens -----
    }
    
    function handleEthFee(uint feeAmount, uint _amountOutMin_ethFeeBuyBack, uint deadline) private {
        require(feeAmount >= MIN_ETH_FEE_IN_WEI, "Insufficient ETH Fee!");
        uint buyBackFeeAmount = feeAmount.mul(FEE_PERCENT_TO_BUYBACK_X_100).div(ONE_HUNDRED_X_100);
        uint remainingFeeAmount = feeAmount.sub(buyBackFeeAmount);
        
        // handle distribution
        distributeEthDivs(remainingFeeAmount);
        
        
        // handle buyback
        
        // --- swap eth to platform token here! ----
        uint oldPlatformTokenBalance = IERC20(TRUSTED_PLATFORM_TOKEN_ADDRESS).balanceOf(address(this));
        address[] memory path = new address[](2);
        path[0] = uniswapRouterV2.WETH();
        path[1] = TRUSTED_PLATFORM_TOKEN_ADDRESS;
        
        uniswapRouterV2.swapExactETHForTokens{value: buyBackFeeAmount}(_amountOutMin_ethFeeBuyBack, path, address(this), deadline);
        uint newPlatformTokenBalance = IERC20(TRUSTED_PLATFORM_TOKEN_ADDRESS).balanceOf(address(this));
        uint platformTokensReceived = newPlatformTokenBalance.sub(oldPlatformTokenBalance);
        IERC20(TRUSTED_PLATFORM_TOKEN_ADDRESS).safeTransfer(BURN_ADDRESS, platformTokensReceived);
        // ---- end swap eth to plaform tokens -----
    }
    
    receive () external payable {
        // receive eth do nothing
    }
    
    function increaseTokenBalance(address token, uint amount) private {
        tokenBalances[token] = tokenBalances[token].add(amount);
    }
    function decreaseTokenBalance(address token, uint amount) private {
        tokenBalances[token] = tokenBalances[token].sub(amount);
    }
    
    function addPlatformTokenBalance(uint amount) external nonReentrant onlyOwner {
        increaseTokenBalance(TRUSTED_PLATFORM_TOKEN_ADDRESS, amount);
        IERC20(TRUSTED_PLATFORM_TOKEN_ADDRESS).safeTransferFrom(msg.sender, address(this), amount);
        
        emit PlatformTokenAdded(amount);
    }
    
    function claimExtraTokens(address token) external nonReentrant onlyOwner {
        if (token == address(0)) {
            uint ethDiff = address(this).balance.sub(tokenBalances[token]);
            msg.sender.transfer(ethDiff);
            return;
        }
        uint diff = IERC20(token).balanceOf(address(this)).sub(tokenBalances[token]);
        IERC20(token).safeTransfer(msg.sender, diff);
    }
    
    function claimAnyToken(address token, uint amount) external onlyOwner {
        require(now > contractStartTime.add(ADMIN_CAN_CLAIM_AFTER), "Contract not expired yet!");
        if (token == address(0)) {
            msg.sender.transfer(amount);
            return;
        }
        IERC20(token).safeTransfer(msg.sender, amount);
    }
}