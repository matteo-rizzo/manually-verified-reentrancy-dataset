/**
 *Submitted for verification at Etherscan.io on 2021-02-19
*/

/**
 *Submitted for verification at Etherscan.io on 2021-02-12
*/

pragma solidity 0.6.11;

// SPDX-License-Identifier: MIT

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

contract WETHandYFIIG is Ownable {
    using SafeMath for uint;
    using EnumerableSet for EnumerableSet.AddressSet;
    
    event RewardsTransferred(address holder, uint amount);
    
    address public constant uniswapV2router = 0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D;
    
    IUniswapV2Router02 router = IUniswapV2Router02(uniswapV2router);
    
    // trusted deposit token contract address (WETH)
    address public constant trustedDepositTokenAddress = 0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2;
    // trusted reward token contract address (YFIIG)
    address public constant trustedRewardTokenAddress  = 0xAC523EB684be6e3fC5EF20a8b2328256b27d36E4;
    // reward rate
    uint public rewardRatePercentX100 = 50e2;   // 50% Per Year
    uint public constant rewardInterval = 365 days;
    uint public cliffTime = 72 hours;
    uint public withdrawFeePercentX100 = 50;
    
    uint public totalClaimedRewards = 0;
    
    uint public vaultDuration = 365 days;
    
    // admin can transfer out reward tokens from this contract one month after vault has ended
    uint public adminCanClaimAfter = 395 days;
    
    uint public vaultDeployTime;
    uint public adminClaimableTime;
    uint public vaultEndTime;
    
    EnumerableSet.AddressSet private holders;
    
    mapping (address => uint) public depositedTokens;
    mapping (address => uint) public depositTime;
    mapping (address => uint) public lastClaimedTime;
    mapping (address => uint) public totalEarnedTokens;
    
    constructor () public {
        vaultDeployTime = now;
        vaultEndTime = vaultDeployTime.add(vaultDuration);
        adminClaimableTime = vaultDeployTime.add(adminCanClaimAfter);
    }
    
    function getTokenPerEther() public view returns (uint) {
        address[] memory _path = new address[](2);
        _path[0] = trustedDepositTokenAddress;
        _path[1] = trustedRewardTokenAddress;
        uint[] memory _amts = router.getAmountsOut(1e18, _path);
        return _amts[1];
    }
    
    function updateAccount(address account) private {
        uint pendingDivs = getPendingDivs(account);
        if (pendingDivs > 0) {
            require(Token(trustedRewardTokenAddress).transfer(account, pendingDivs.mul(getTokenPerEther()).div(1e18)), "Could not transfer tokens.");
            totalEarnedTokens[account] = totalEarnedTokens[account].add(pendingDivs);
            totalClaimedRewards = totalClaimedRewards.add(pendingDivs);
            emit RewardsTransferred(account, pendingDivs);
        }
        lastClaimedTime[account] = now;
    }
    
    
    function getPendingDivs(address _holder) public view returns (uint) {
        if (!holders.contains(_holder)) return 0;
        if (depositedTokens[_holder] == 0) return 0;
        
        uint timeDiff;
        uint _now = now;
        if (_now > vaultEndTime) {
            _now = vaultEndTime;
        }
        
        if (lastClaimedTime[_holder] >= _now) {
            timeDiff = 0;
        } else {
            timeDiff = _now.sub(lastClaimedTime[_holder]);
        }

        uint depositedAmount = depositedTokens[_holder];
        
        uint pendingDivs = depositedAmount
                            .mul(rewardRatePercentX100)
                            .mul(timeDiff)
                            .div(rewardInterval)
                            .div(1e4);
            
        return pendingDivs;
    }
    
    function getNumberOfHolders() public view returns (uint) {
        return holders.length();
    }
    
    
    function deposit(uint amountToDeposit) public {
        require(amountToDeposit > 0, "Cannot deposit 0 Tokens");
        require(Token(trustedDepositTokenAddress).transferFrom(msg.sender, address(this), amountToDeposit), "Insufficient Token Allowance");
        
        updateAccount(msg.sender);
        
        depositedTokens[msg.sender] = depositedTokens[msg.sender].add(amountToDeposit);
        
        if (!holders.contains(msg.sender)) {
            holders.add(msg.sender);
            depositTime[msg.sender] = now;
        }
    }
    
    function withdraw(uint amountToWithdraw) public {
        require(amountToWithdraw > 0, "Cannot withdraw 0 Tokens");
        require(depositedTokens[msg.sender] >= amountToWithdraw, "Invalid amount to withdraw");
        require(now.sub(depositTime[msg.sender]) > cliffTime, "You recently deposited!, please wait before withdrawing.");
                
        updateAccount(msg.sender);
        
        uint fee = amountToWithdraw.mul(withdrawFeePercentX100).div(1e4);
        uint amountAfterFee = amountToWithdraw.sub(fee);
    
        require(Token(trustedDepositTokenAddress).transfer(owner, fee), "Could not transfer fee!");
        require(Token(trustedDepositTokenAddress).transfer(msg.sender, amountAfterFee), "Could not transfer tokens.");
        
        depositedTokens[msg.sender] = depositedTokens[msg.sender].sub(amountToWithdraw);
        
        if (holders.contains(msg.sender) && depositedTokens[msg.sender] == 0) {
            holders.remove(msg.sender);
        }
    }
    
    // emergency withdraw without caring about pending earnings
    // pending earnings will be lost / set to 0 if used emergency withdraw
    function emergencyWithdraw(uint amountToWithdraw) public {
        require(amountToWithdraw > 0, "Cannot withdraw 0 Tokens");
        require(depositedTokens[msg.sender] >= amountToWithdraw, "Invalid amount to withdraw");
        require(now.sub(depositTime[msg.sender]) > cliffTime, "You recently deposited!, please wait before withdrawing.");

        // set pending earnings to 0 here
        lastClaimedTime[msg.sender] = now;
    
        uint fee = amountToWithdraw.mul(withdrawFeePercentX100).div(1e4);
        uint amountAfterFee = amountToWithdraw.sub(fee);
    
        require(Token(trustedDepositTokenAddress).transfer(owner, fee), "Could not transfer fee!");
        require(Token(trustedDepositTokenAddress).transfer(msg.sender, amountAfterFee), "Could not transfer tokens.");
        
        depositedTokens[msg.sender] = depositedTokens[msg.sender].sub(amountToWithdraw);
        
        if (holders.contains(msg.sender) && depositedTokens[msg.sender] == 0) {
            holders.remove(msg.sender);
        }
    }
    
    function claim() public {
        updateAccount(msg.sender);
    }
    
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

    // function to allow admin to claim *other* ERC20 tokens sent to this contract (by mistake)
    // Admin cannot transfer out deposit tokens from this smart contract
    // Admin can transfer out reward tokens from this address once adminClaimableTime has reached
    function transferAnyERC20Tokens(address _tokenAddr, address _to, uint _amount) public onlyOwner {
        require(_tokenAddr != trustedDepositTokenAddress, "Admin cannot transfer out Deposit Tokens from this contract!");
        
        require((_tokenAddr != trustedRewardTokenAddress) || (now > adminClaimableTime), "Admin cannot Transfer out Reward Tokens yet!");
        
        Token(_tokenAddr).transfer(_to, _amount);
    }
}