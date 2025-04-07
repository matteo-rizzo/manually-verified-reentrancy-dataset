/**
 *Submitted for verification at Etherscan.io on 2020-10-26
*/

// SPDX-License-Identifier: MIT

pragma solidity 0.6.12;

/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
 */





contract LPStaker {
    
    struct StakeState {
        uint128 balance;
        uint64 lockedUntil;
        uint64 reward;
        uint128 bonusBalance;
    }
    
    uint128 constant initialDepositedTokens = 20000 * 1000000; // an offset
    uint128 constant initialAllocatedReward = 1930 * 1000000; // an offset
    uint128 constant maxAllocatedReward = 10000 * 1000000; 
    
    uint128 totalDepositedTokens = initialDepositedTokens; 
    uint128 totalAllocatedReward = initialAllocatedReward;
    uint128 public totalBonusDeposits = 0;
    
    function sumDepositedTokens() external view returns (uint128) { return totalDepositedTokens - initialDepositedTokens; }
    function sumAllocatedReward() external view returns (uint128) { return totalAllocatedReward - initialAllocatedReward; }
    
    event Deposit(address indexed from, uint128 balance, uint64 until, uint64 reward);
    
    mapping(address => StakeState) private _states;
    
    IERC20 private depositToken = IERC20(0x510C9b3FE162f463DAC2F8c6dDd3d8ED5F49e360); // HGET/CHR
    IERC20 private rewardToken1 = IERC20(0x7968bc6a03017eA2de509AAA816F163Db0f35148); // HGET
    IERC20 private rewardToken2 = IERC20(0x8A2279d4A90B6fe1C4B30fa660cC9f926797bAA2); // CHR
    
    Auction constant usdt_auction = Auction(0xf8E30096dD15Ce4F47310A20EdD505B42a633808);
    Auction constant chr_auction = Auction(0x12F41B4bb7D5e5a2148304caAfeb26d9edb7Ef4A);
    
    // note that depositedTokens must be in the same tokens as initialDepositedTokens
    // (i.e. 6 decimals, 1000M tokens represent 1000 HGET worth of liquidity)
    function calculateReward (uint128 depositedTokens) internal view returns (uint256) {
        // calculate amount of bought reward tokens (i.e. reward for deposit) using Bancor formula
        // Exact formula: boughtTokens = tokenSupply * ( (1 + x) ^ F - 1)
        //    where F is reserve ratio
        //      and x = depositedTokens/totalDepositedTokens
        // We have an approximation which is precise for 0 <= x <= 1.
        // So to handle values above totalDepositedTokens, we simulate
        // multi-step buy process. totalDepositedTokens doubles on each iteration.
        
        uint256 tDepositedTokens = totalDepositedTokens;
        uint256 tAllocatedReward = totalAllocatedReward;
        uint256 remainingDeposit = depositedTokens;
        uint256 totalBoughtTokens = 0;

        while (remainingDeposit >= tDepositedTokens) {
            // buy tDepositedTokens worth of tokens. in this case x = 1, thus we
            // have formula boughtTokens = tokenSupply * ( 2^F - 1)
            // 2^F - 1 = 0.741101126592248

            uint256 boughtTokens = (741101126592248 * tAllocatedReward) / (1000000000000000);

            totalBoughtTokens += boughtTokens;
            tAllocatedReward += boughtTokens;
            remainingDeposit -= tDepositedTokens;
            tDepositedTokens += tDepositedTokens;
        }
        if (remainingDeposit > 0) {
            // third degree polynomial which approximates the exact value
            // obtained using Lagrange interpolation
            // boughtTokens = TS*(0.017042*(x/ER)^3 - 0.075513*(x/ER)^2 + 0.799572*(x/ER))
            // (TS = tAllocatedReward, ER=tDepositedTokens)
            // coefficients are truncated to millionths

            // we assume that tAllocatedReward, remainingDeposit and tDepositedTokens do not exceed 80 bits, thus
            // we can multiply three of them within int256 without getting overflow
            int256 rd = int256(remainingDeposit);
            int256 tDepositedTokensSquared = int256(tDepositedTokens*tDepositedTokens);
            int256 temp1 = int256(tAllocatedReward) * rd;
            int256 x1 = (799572 * temp1)/int256(tDepositedTokens);
            int256 x2 = (75513 * temp1 * rd)/tDepositedTokensSquared;
            int256 x3 = (((17042 * temp1 * rd)/tDepositedTokensSquared) * rd)/int256(tDepositedTokens);
            int256 res = (x1 - x2 + x3)/1000000;
            if (res > 0)  totalBoughtTokens += uint256(res);
        }
        return totalBoughtTokens;
    }
    
    constructor () public {}

    function getStakeState(address account) external view returns (uint256, uint64, uint64) {
        StakeState storage ss = _states[account];
        return (ss.balance, ss.lockedUntil, ss.reward);
    }

    function depositWithBonus(uint128 amount, bool is_chr) external {
        deposit(amount);
        Auction a = (is_chr) ? chr_auction : usdt_auction;
        (,,,,,,,bool distributed) = a.getBid(msg.sender); 
        require(distributed, "need to win auction to get bonus");
        StakeState storage ss = _states[msg.sender];
        ss.bonusBalance += amount;
        totalBonusDeposits += amount;
    }

    function deposit(uint128 amount) public {
        require(block.timestamp < 1604707200, "deposits no longer accepted"); // 2020 November 07 00:00 UTC
        uint64 until = uint64(block.timestamp + 2 weeks); // TODO
        
        uint128 adjustedAmount = (1156 * amount) / (10000); // 0.1156 HGET atoms per 1 LP token atom, corresponds to ~75 CHR per HGET
        uint64 reward = uint64(calculateReward(adjustedAmount)); 
        totalAllocatedReward += reward;
        
        require(totalAllocatedReward <= initialAllocatedReward + maxAllocatedReward, "reward pool exhausted");
        
        totalDepositedTokens += adjustedAmount;
        
        StakeState storage ss = _states[msg.sender];
        ss.balance += amount;
        ss.reward += reward;
        ss.lockedUntil = until;
        
        emit Deposit(msg.sender, amount, until, reward);
        require(depositToken.transferFrom(msg.sender, address(this), amount), "transfer unsuccessful");
    }

    function withdraw(address to) external {
        StakeState storage ss = _states[msg.sender];
        require(ss.lockedUntil < block.timestamp, "still locked");
        require(ss.balance > 0, "must have tokens to withdraw");
        uint128 balance = ss.balance;
        uint64 reward = ss.reward;
        uint128 bonusBalance = ss.bonusBalance;
        ss.balance = 0;
        ss.lockedUntil = 0;
        ss.reward = 0;
        
        if (bonusBalance > 0) {
            ss.bonusBalance = 0;
            reward += uint64((2500 * 1000000 * bonusBalance) / totalBonusDeposits); // TODO
        }
        
        require(depositToken.transfer(to, balance), "transfer unsuccessful");
        require(rewardToken1.transfer(to, reward), "transfer unsuccessful");
        require(rewardToken2.transfer(to, reward * 75), "transfer unsuccessful");
    }
}