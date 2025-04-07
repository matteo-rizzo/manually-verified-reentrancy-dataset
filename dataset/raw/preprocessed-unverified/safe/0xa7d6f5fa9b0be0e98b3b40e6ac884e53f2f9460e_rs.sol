/**
 *Submitted for verification at Etherscan.io on 2020-12-16
*/

pragma solidity 0.6.11;

// SPDX-License-Identifier: BSD-3-Clause

/**
 * @title SafeMath
 * @dev Math operations with safety checks that throw on error
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
 * @dev Collection of functions related to the address type
 */


/**
 * @title Ownable
 * @dev The Ownable contract has an owner address, and provides basic authorization control
 * functions, this simplifies the implementation of "user permissions".
 */








interface IUniswapV2Router02 is IUniswapV2Router01 {
    function removeLiquidityETHSupportingFeeOnTransferTokens(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline
    ) external returns (uint amountETH);
    function removeLiquidityETHWithPermitSupportingFeeOnTransferTokens(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline,
        bool approveMax, uint8 v, bytes32 r, bytes32 s
    ) external returns (uint amountETH);

    function swapExactTokensForTokensSupportingFeeOnTransferTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external;
    function swapExactETHForTokensSupportingFeeOnTransferTokens(
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external payable;
    function swapExactTokensForETHSupportingFeeOnTransferTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external;
}



/**
 * @dev Staking Smart Contract
 * 
 *  - Users stake Uniswap LP Tokens to receive WETH and DYP Tokens as Rewards
 * 
 *  - Reward Tokens (DYP) are added to contract balance upon deployment by deployer
 * 
 *  - After Adding the DYP rewards, admin is supposed to transfer ownership to Governance contract
 * 
 *  - Users deposit Set (Predecided) Uniswap LP Tokens and get a share of the farm
 * 
 *  - The smart contract disburses `disburseAmount` DYP as rewards over `disburseDuration`
 * 
 *  - A swap is attempted periodically at atleast a set delay from last swap
 * 
 *  - The swap is attempted according to SWAP_PATH for difference deployments of this contract
 * 
 *  - For 4 different deployments of this contract, the SWAP_PATH will be:
 *      - DYP-WETH
 *      - DYP-WBTC-WETH (assumes appropriate liquidity is available in WBTC-WETH pair)
 *      - DYP-USDT-WETH (assumes appropriate liquidity is available in USDT-WETH pair)
 *      - DYP-USDC-WETH (assumes appropriate liquidity is available in USDC-WETH pair)
 * 
 *  - Any swap may not have a price impact on DYP price of more than approx ~2.49% for the related DYP pair
 *      DYP-WETH swap may not have a price impact of more than ~2.49% on DYP price in DYP-WETH pair
 *      DYP-WBTC-WETH swap may not have a price impact of more than ~2.49% on DYP price in DYP-WBTC pair
 *      DYP-USDT-WETH swap may not have a price impact of more than ~2.49% on DYP price in DYP-USDT pair
 *      DYP-USDC-WETH swap may not have a price impact of more than ~2.49% on DYP price in DYP-USDC pair
 * 
 *  - After the swap,converted WETH is distributed to stakers at pro-rata basis, according to their share of the staking pool
 *    on the moment when the WETH distribution is done. And remaining DYP is added to the amount to be distributed or burnt.
 *    The remaining DYP are also attempted to be swapped to WETH in the next swap if the price impact is ~2.49% or less
 * 
 *  - At a set delay from last execution, Governance contract (owner) may execute disburse or burn features
 * 
 *  - Burn feature should send the DYP tokens to set BURN_ADDRESS
 * 
 *  - Disburse feature should disburse the DYP 
 *    (which would have a max price impact ~2.49% if it were to be swapped, at disburse time 
 *    - remaining DYP are sent to BURN_ADDRESS) 
 *    to stakers at pro-rata basis according to their share of
 *    the staking pool at the moment the disburse is done
 * 
 *  - Users may claim their pending WETH and DYP anytime
 * 
 *  - Pending rewards are auto-claimed on any deposit or withdraw
 * 
 *  - Users need to wait `cliffTime` duration since their last deposit before withdrawing any LP Tokens
 * 
 *  - Owner may not transfer out LP Tokens from this contract anytime
 * 
 *  - Owner may transfer out WETH and DYP Tokens from this contract once `adminClaimableTime` is reached
 * 
 *  - CONTRACT VARIABLES must be changed to appropriate values before live deployment
 */
contract FarmProRata is Ownable {
    using SafeMath for uint;
    using EnumerableSet for EnumerableSet.AddressSet;
    using Address for address;
    
    // Contracts are not allowed to deposit, claim or withdraw
    modifier noContractsAllowed() {
        require(!(address(msg.sender).isContract()) && tx.origin == msg.sender, "No Contracts Allowed!");
        _;
    }

    event RewardsTransferred(address holder, uint amount);
    event EthRewardsTransferred(address holder, uint amount);
    
    event RewardsDisbursed(uint amount);
    event EthRewardsDisbursed(uint amount);
    
    // ============ START CONTRACT VARIABLES ==========================

    // deposit token contract address and reward token contract address
    // these contracts (and uniswap pair & router) are "trusted" 
    // and checked to not contain re-entrancy pattern
    // to safely avoid checks-effects-interactions where needed to simplify logic
    address public constant trustedDepositTokenAddress = 0xBa7872534a6C9097d805d8BEE97e030f4e372e54;
    address public constant trustedRewardTokenAddress = 0x961C8c0B1aaD0c0b10a51FeF6a867E3091BCef17; 
    
    // Make sure to double-check BURN_ADDRESS
    address public constant BURN_ADDRESS = 0x000000000000000000000000000000000000dEaD;
    
    // cliffTime - withdraw is not possible within cliffTime of deposit
    uint public constant cliffTime = 3 days;

    // Amount of tokens
    uint public constant disburseAmount = 360000e18;
    // To be disbursed continuously over this duration
    uint public constant disburseDuration = 365 days;
    
    // If there are any undistributed or unclaimed tokens left in contract after this time
    // Admin can claim them
    uint public constant adminCanClaimAfter = 395 days;
    
    // delays between attempted swaps
    uint public constant swapAttemptPeriod = 1 days;
    // delays between attempted burns or token disbursement
    uint public constant burnOrDisburseTokensPeriod = 7 days;

    

    // do not change this => disburse 100% rewards over `disburseDuration`
    uint public constant disbursePercentX100 = 100e2;
    
    uint public constant MAGIC_NUMBER = 6289308176100628;
    
    // slippage tolerance
    uint public constant SLIPPAGE_TOLERANCE_X_100 = 100;
    
    //  ============ END CONTRACT VARIABLES ==========================

    uint public contractDeployTime;
    uint public adminClaimableTime;
    uint public lastDisburseTime;
    uint public lastSwapExecutionTime;
    uint public lastBurnOrTokenDistributeTime;
    
    IUniswapV2Router02 public uniswapRouterV2;
    IUniswapV2Pair public uniswapV2Pair;
    address[] public SWAP_PATH;
    
    constructor(address[] memory swapPath) public {
        contractDeployTime = now;
        adminClaimableTime = contractDeployTime.add(adminCanClaimAfter);
        lastDisburseTime = contractDeployTime;
        lastSwapExecutionTime = lastDisburseTime;
        lastBurnOrTokenDistributeTime = lastDisburseTime;
        
        uniswapRouterV2 = IUniswapV2Router02(0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D);
        uniswapV2Pair = IUniswapV2Pair(trustedDepositTokenAddress);
        SWAP_PATH = swapPath;
    }

    uint public totalClaimedRewards = 0;
    uint public totalClaimedRewardsEth = 0;

    EnumerableSet.AddressSet private holders;

    mapping (address => uint) public depositedTokens;
    mapping (address => uint) public depositTime;
    mapping (address => uint) public lastClaimedTime;
    mapping (address => uint) public totalEarnedTokens;
    mapping (address => uint) public totalEarnedEth;
    mapping (address => uint) public lastDivPoints;
    mapping (address => uint) public lastEthDivPoints;

    uint public contractBalance = 0;

    uint public totalDivPoints = 0;
    uint public totalEthDivPoints = 0;
    uint public totalTokens = 0;
    
    uint public tokensToBeDisbursedOrBurnt = 0;
    uint public tokensToBeSwapped = 0;

    uint internal constant pointMultiplier = 1e18;

    // To be executed by admin after deployment to add DYP to contract
    function addContractBalance(uint amount) public onlyOwner {
        require(Token(trustedRewardTokenAddress).transferFrom(msg.sender, address(this), amount), "Cannot add balance!");
        contractBalance = contractBalance.add(amount);
    }

    
    // Private function to update account information and auto-claim pending rewards
    function updateAccount(address account) private {
        disburseTokens();
        attemptSwap();
        uint pendingDivs = getPendingDivs(account);
        if (pendingDivs > 0) {
            require(Token(trustedRewardTokenAddress).transfer(account, pendingDivs), "Could not transfer tokens.");
            totalEarnedTokens[account] = totalEarnedTokens[account].add(pendingDivs);
            totalClaimedRewards = totalClaimedRewards.add(pendingDivs);
            emit RewardsTransferred(account, pendingDivs);
        }
        
        uint pendingDivsEth = getPendingDivsEth(account);
        if (pendingDivsEth > 0) {
            require(Token(uniswapRouterV2.WETH()).transfer(account, pendingDivsEth), "Could not transfer WETH!");
            totalEarnedEth[account] = totalEarnedEth[account].add(pendingDivsEth);
            totalClaimedRewardsEth = totalClaimedRewardsEth.add(pendingDivsEth);
            emit EthRewardsTransferred(account, pendingDivsEth);
        }
        
        lastClaimedTime[account] = now;
        lastDivPoints[account] = totalDivPoints;
        lastEthDivPoints[account] = totalEthDivPoints;
    }

    // view function to check last updated DYP pending rewards
    function getPendingDivs(address _holder) public view returns (uint) {
        if (!holders.contains(_holder)) return 0;
        if (depositedTokens[_holder] == 0) return 0;

        uint newDivPoints = totalDivPoints.sub(lastDivPoints[_holder]);

        uint depositedAmount = depositedTokens[_holder];

        uint pendingDivs = depositedAmount.mul(newDivPoints).div(pointMultiplier);

        return pendingDivs;
    }
    
    // view function to check last updated WETH pending rewards
    function getPendingDivsEth(address _holder) public view returns (uint) {
        if (!holders.contains(_holder)) return 0;
        if (depositedTokens[_holder] == 0) return 0;

        uint newDivPoints = totalEthDivPoints.sub(lastEthDivPoints[_holder]);

        uint depositedAmount = depositedTokens[_holder];

        uint pendingDivs = depositedAmount.mul(newDivPoints).div(pointMultiplier);

        return pendingDivs;
    }

    
    // view functon to get number of stakers
    function getNumberOfHolders() public view returns (uint) {
        return holders.length();
    }


    // deposit function to stake LP Tokens
    function deposit(uint amountToDeposit) public noContractsAllowed {
        require(amountToDeposit > 0, "Cannot deposit 0 Tokens");

        updateAccount(msg.sender);

        require(Token(trustedDepositTokenAddress).transferFrom(msg.sender, address(this), amountToDeposit), "Insufficient Token Allowance");

        depositedTokens[msg.sender] = depositedTokens[msg.sender].add(amountToDeposit);
        totalTokens = totalTokens.add(amountToDeposit);

        if (!holders.contains(msg.sender)) {
            holders.add(msg.sender);
        }
        depositTime[msg.sender] = now;
    }

    // withdraw function to unstake LP Tokens
    function withdraw(uint amountToWithdraw) public noContractsAllowed {
        require(amountToWithdraw > 0, "Cannot withdraw 0 Tokens!");

        require(depositedTokens[msg.sender] >= amountToWithdraw, "Invalid amount to withdraw");
        require(now.sub(depositTime[msg.sender]) > cliffTime, "You recently deposited, please wait before withdrawing.");
        
        updateAccount(msg.sender);

        require(Token(trustedDepositTokenAddress).transfer(msg.sender, amountToWithdraw), "Could not transfer tokens.");

        depositedTokens[msg.sender] = depositedTokens[msg.sender].sub(amountToWithdraw);
        totalTokens = totalTokens.sub(amountToWithdraw);

        if (holders.contains(msg.sender) && depositedTokens[msg.sender] == 0) {
            holders.remove(msg.sender);
        }
    }

    // withdraw without caring about Rewards
    function emergencyWithdraw(uint amountToWithdraw) public noContractsAllowed {
        require(amountToWithdraw > 0, "Cannot withdraw 0 Tokens!");

        require(depositedTokens[msg.sender] >= amountToWithdraw, "Invalid amount to withdraw");
        require(now.sub(depositTime[msg.sender]) > cliffTime, "You recently deposited, please wait before withdrawing.");
        
        // manual update account here without withdrawing pending rewards
        disburseTokens();
        // do not attempt swap here
        lastClaimedTime[msg.sender] = now;
        lastDivPoints[msg.sender] = totalDivPoints;
        lastEthDivPoints[msg.sender] = totalEthDivPoints;

        require(Token(trustedDepositTokenAddress).transfer(msg.sender, amountToWithdraw), "Could not transfer tokens.");

        depositedTokens[msg.sender] = depositedTokens[msg.sender].sub(amountToWithdraw);
        totalTokens = totalTokens.sub(amountToWithdraw);

        if (holders.contains(msg.sender) && depositedTokens[msg.sender] == 0) {
            holders.remove(msg.sender);
        }
    }
    
    // claim function to claim pending rewards
    function claim() public noContractsAllowed {
        updateAccount(msg.sender);
    }
    
    // private function to distribute DYP rewards
    function distributeDivs(uint amount) private {
        require(amount > 0 && totalTokens > 0, "distributeDivs failed!");
        totalDivPoints = totalDivPoints.add(amount.mul(pointMultiplier).div(totalTokens));
        emit RewardsDisbursed(amount);
    }
    
    // private function to distribute WETH rewards
    function distributeDivsEth(uint amount) private {
        require(amount > 0 && totalTokens > 0, "distributeDivsEth failed!");
        totalEthDivPoints = totalEthDivPoints.add(amount.mul(pointMultiplier).div(totalTokens));
        emit EthRewardsDisbursed(amount);
    }

    // private function to allocate DYP to be disbursed calculated according to time passed
    function disburseTokens() private {
        uint amount = getPendingDisbursement();

        if (contractBalance < amount) {
            amount = contractBalance;
        }
        if (amount == 0 || totalTokens == 0) return;

        tokensToBeSwapped = tokensToBeSwapped.add(amount);        

        contractBalance = contractBalance.sub(amount);
        lastDisburseTime = now;
    }
    
    function attemptSwap() private {
        doSwap();
    }
    
    function doSwap() private {
        // do not attemptSwap if no one has staked
        if (totalTokens == 0) {
            return;
        }
        
        // Cannot execute swap so quickly
        if (now.sub(lastSwapExecutionTime) < swapAttemptPeriod) {
            return;
        }
    
        // force reserves to match balances
        uniswapV2Pair.sync();
    
        uint _tokensToBeSwapped = tokensToBeSwapped.add(tokensToBeDisbursedOrBurnt);
        
        uint maxSwappableAmount = getMaxSwappableAmount();
        
        // don't proceed if no liquidity
        if (maxSwappableAmount == 0) return;
    
        if (maxSwappableAmount < tokensToBeSwapped) {
            
            uint diff = tokensToBeSwapped.sub(maxSwappableAmount);
            _tokensToBeSwapped = tokensToBeSwapped.sub(diff);
            tokensToBeDisbursedOrBurnt = tokensToBeDisbursedOrBurnt.add(diff);
            tokensToBeSwapped = 0;
    
        } else if (maxSwappableAmount < _tokensToBeSwapped) {
    
            uint diff = _tokensToBeSwapped.sub(maxSwappableAmount);
            _tokensToBeSwapped = _tokensToBeSwapped.sub(diff);
            tokensToBeDisbursedOrBurnt = diff;
            tokensToBeSwapped = 0;
    
        } else {
            tokensToBeSwapped = 0;
            tokensToBeDisbursedOrBurnt = 0;
        }
    
        // don't execute 0 swap tokens
        if (_tokensToBeSwapped == 0) {
            return;
        }
    
        // cannot execute swap at insufficient balance
        if (Token(trustedRewardTokenAddress).balanceOf(address(this)) < _tokensToBeSwapped) {
            return;
        }
    
        require(Token(trustedRewardTokenAddress).approve(address(uniswapRouterV2), _tokensToBeSwapped), 'approve failed!');
    
        uint oldWethBalance = Token(uniswapRouterV2.WETH()).balanceOf(address(this));
                
        uint amountOutMin;
        
        uint estimatedAmountOut = uniswapRouterV2.getAmountsOut(_tokensToBeSwapped, SWAP_PATH)[SWAP_PATH.length.sub(1)];
        amountOutMin = estimatedAmountOut.mul(uint(100e2).sub(SLIPPAGE_TOLERANCE_X_100)).div(100e2);
        
        uniswapRouterV2.swapExactTokensForTokens(_tokensToBeSwapped, amountOutMin, SWAP_PATH, address(this), block.timestamp);
    
        uint newWethBalance = Token(uniswapRouterV2.WETH()).balanceOf(address(this));
        uint wethReceived = newWethBalance.sub(oldWethBalance);
        require(wethReceived >= amountOutMin, "Invalid SWAP!");
        
        if (wethReceived > 0) {
            distributeDivsEth(wethReceived);    
        }

        lastSwapExecutionTime = now;
    }
    
    // Owner is supposed to be a Governance Contract
    function disburseRewardTokens() public onlyOwner {
        require(now.sub(lastBurnOrTokenDistributeTime) > burnOrDisburseTokensPeriod, "Recently executed, Please wait!");
        
        // force reserves to match balances
        uniswapV2Pair.sync();
        
        uint maxSwappableAmount = getMaxSwappableAmount();
        
        uint _tokensToBeDisbursed = tokensToBeDisbursedOrBurnt;
        uint _tokensToBeBurnt;
        
        if (maxSwappableAmount < _tokensToBeDisbursed) {
            _tokensToBeBurnt = _tokensToBeDisbursed.sub(maxSwappableAmount);
            _tokensToBeDisbursed = maxSwappableAmount;
        }
        
        distributeDivs(_tokensToBeDisbursed);
        if (_tokensToBeBurnt > 0) {
            require(Token(trustedRewardTokenAddress).transfer(BURN_ADDRESS, _tokensToBeBurnt), "disburseRewardTokens: burn failed!");
        }
        tokensToBeDisbursedOrBurnt = 0;
        lastBurnOrTokenDistributeTime = now;
    }
    
    
    // Owner is suposed to be a Governance Contract
    function burnRewardTokens() public onlyOwner {
        require(now.sub(lastBurnOrTokenDistributeTime) > burnOrDisburseTokensPeriod, "Recently executed, Please wait!");
        require(Token(trustedRewardTokenAddress).transfer(BURN_ADDRESS, tokensToBeDisbursedOrBurnt), "burnRewardTokens failed!");
        tokensToBeDisbursedOrBurnt = 0;
        lastBurnOrTokenDistributeTime = now;
    }
    
    
    // get token amount which has a max price impact of 2.5% for sells
    // !!IMPORTANT!! => Any functions using return value from this
    // MUST call `sync` on the pair before calling this function!
    function getMaxSwappableAmount() public view returns (uint) {
        uint tokensAvailable = Token(trustedRewardTokenAddress).balanceOf(trustedDepositTokenAddress);
        uint maxSwappableAmount = tokensAvailable.mul(MAGIC_NUMBER).div(1e18);
        return maxSwappableAmount;
    }

    // view function to calculate amount of DYP pending to be allocated since `lastDisburseTime` 
    function getPendingDisbursement() public view returns (uint) {
        uint timeDiff;
        uint _now = now;
        uint _stakingEndTime = contractDeployTime.add(disburseDuration);
        if (_now > _stakingEndTime) {
            _now = _stakingEndTime;
        }
        if (lastDisburseTime >= _now) {
            timeDiff = 0;
        } else {
            timeDiff = _now.sub(lastDisburseTime);
        }

        uint pendingDisburse = disburseAmount
                                    .mul(disbursePercentX100)
                                    .mul(timeDiff)
                                    .div(disburseDuration)
                                    .div(10000);
        return pendingDisburse;
    }

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
            _stakedTokens[listIndex] = depositedTokens[staker];
        }

        return (_stakers, _stakingTimestamps, _lastClaimedTimeStamps, _stakedTokens);
    }


    // function to allow owner to claim *other* modern ERC20 tokens sent to this contract
    function transferAnyERC20Token(address _tokenAddr, address _to, uint _amount) public onlyOwner {
        require(_tokenAddr != trustedDepositTokenAddress, "Admin cannot transfer out deposit tokens from this vault!");
        require((_tokenAddr != trustedRewardTokenAddress && _tokenAddr != uniswapRouterV2.WETH()) || (now > adminClaimableTime), "Admin cannot Transfer out Reward Tokens or WETH Yet!");
        require(Token(_tokenAddr).transfer(_to, _amount), "Could not transfer out tokens!");
    }

    // function to allow owner to claim *other* legacy ERC20 tokens sent to this contract
    function transferAnyOldERC20Token(address _tokenAddr, address _to, uint _amount) public onlyOwner {
       
        require(_tokenAddr != trustedDepositTokenAddress, "Admin cannot transfer out deposit tokens from this vault!");
        require((_tokenAddr != trustedRewardTokenAddress && _tokenAddr != uniswapRouterV2.WETH()) || (now > adminClaimableTime), "Admin cannot Transfer out Reward Tokens or WETH Yet!");

        OldIERC20(_tokenAddr).transfer(_to, _amount);
    }
}