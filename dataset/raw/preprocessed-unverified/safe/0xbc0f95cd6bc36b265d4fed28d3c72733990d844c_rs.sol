/**
 *Submitted for verification at Etherscan.io on 2021-01-31
*/

pragma solidity ^0.6.6;





contract RateCalc is IRCD {
    using SafeMath for uint256;
     /**
     * @notice Calculates maximum option buyer profit
     * @param amount Option amount
     * @param maxAvailable the total pooled ETH unlocked and available to bet
     * @param oldPrice the previous price of the underlying
     * @param newPrice the current price of the underlying
     * @return profit total possible profit amount
     */
    function rate(uint256 amount, uint256 maxAvailable, uint256 oldPrice, uint256 newPrice) external view override returns (uint256)  {
        require(amount <= maxAvailable, "greater then pool funds available");
        
        uint256 oneTenth = amount.div(10);
        uint256 halfMax = maxAvailable.div(2);
        if (amount > halfMax) {
            return amount.mul(2).add(oneTenth).add(oneTenth);
        } else {
            if(oneTenth > 0) {
                return amount.mul(2).sub(oneTenth);
            } else {
                uint256 oneThird = amount.div(4);
                require(oneThird > 0, "invalid bet amount");
                return amount.mul(2).sub(oneThird);
            }
        }
        
    }
}



contract RateCalc20Percent is IRCD {
    using SafeMath for uint256;
     /**
     * @notice Calculates maximum option buyer profit
     * @param amount Option amount
     * @return profit total possible profit amount
     */
    function rate(uint256 amount, uint256 maxAvailable, uint256 oldPrice, uint256 newPrice) external view override returns (uint256)  {
        uint256 twentyPercent = maxAvailable.div(5);
        require(amount <= twentyPercent, "greater then pool funds available");
        uint256 oneTenth = amount.div(10);
        uint256 halfMax = twentyPercent.div(2);
        if (amount > halfMax) {
            return amount.mul(2).add(oneTenth).add(oneTenth);
        } else {
            if(oneTenth > 0) {
                return amount.mul(2).sub(oneTenth);
            } else {
                uint256 oneThird = amount.div(4);
                require(oneThird > 0, "invalid bet amount");
                return amount.mul(2).sub(oneThird);
            }
        }
        
    }
}