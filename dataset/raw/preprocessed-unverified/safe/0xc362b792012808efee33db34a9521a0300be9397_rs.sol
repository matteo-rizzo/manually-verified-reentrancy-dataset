/**
 *Submitted for verification at Etherscan.io on 2021-03-20
*/

// SPDX-License-Identifier: GPL-v3-or-later
pragma solidity 0.8.1;

// computes square roots using the babylonian method
// https://en.wikipedia.org/wiki/Methods_of_computing_square_roots#Babylonian_method


// for sushi masterchef
struct UserInfo {
    uint256 amount;     // How many LP tokens the user has provided.
    uint256 rewardDebt; // Reward debt. See explanation below.
}







contract MPHVotingWeightWrapper {
    address public constant mph = 0x8888801aF4d980682e47f1A9036e589479e835C5;
    StakingPool public constant mphStaking = StakingPool(0x98df8D9E56b51e4Ea8AA9b57F8A5Df7A044234e1);
    StakingPool public constant uniLPStaking = StakingPool(0xd48Df82a6371A9e0083FbfC0DF3AF641b8E21E44);
    StakingPool public constant yflLPStaking = StakingPool(0x0E6FA9f95a428F185752b60D38c62184854bB9e1);
    MasterChef public constant masterChef = MasterChef(0xc2EdaD668740f1aA35E4D8f227fB8E17dcA888Cd);
    uint256 public constant onsenID = 92;
    Pair public constant uniPair = Pair(0x4D96369002fc5b9687ee924d458A7E5bAa5df34E);
    Pair public constant sushiPair = Pair(0xB2C29e311916a346304f83AA44527092D5bd4f0F);
    Pair public constant yflPair = Pair(0x40F1068495Ba9921d6C18cF1aC25f718dF8cE69D);
    
    string public constant symbol = "vMPH";
    uint8 public constant decimals = 9; // sqrt(10**18) = 10**9

    function balanceOf(address account) external view returns (uint256 votes) {
        // MPH in staking pool
        votes += mphStaking.balanceOf(account);
        
        // MPH in LP staking pools
        votes += _getMPHInPair(uniPair, uniLPStaking.balanceOf(account));
        votes += _getMPHInPair(sushiPair, masterChef.userInfo(onsenID, account).amount);
        votes += _getMPHInPair(yflPair, yflLPStaking.balanceOf(account));
        
        // take square root as voting weight
        votes = Babylonian.sqrt(votes);
    }
    
    function _getMPHInPair(Pair pair, uint256 balance) internal view returns (uint256) {
        uint256 totalSupply = pair.totalSupply();
        if (totalSupply == 0) {
            return 0;
        }
        (uint reserve0, uint reserve1,) = pair.getReserves();
        address token0 = pair.token0();
        address token1 = pair.token1();
        if (token0 == mph) {
            // MPH is token0
            return balance * reserve0 / totalSupply;
        } else if (token1 == mph) {
            // MPH is token1
            return balance * reserve1 / totalSupply;
        } else {
            // wrong LP token?
            return 0;
        }
    }
}