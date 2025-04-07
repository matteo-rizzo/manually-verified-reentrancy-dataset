/**
 *Submitted for verification at Etherscan.io on 2021-02-05
*/

pragma solidity ^0.6.6;





contract RateCalc is IRCD {
    using SafeMath for uint256;
     /**
     * @notice Calculates maximum option buyer profit
     * @param amount Option amount
     * @param maxAvailable the total pooled ETH unlocked and available to bet
     * @param newPrice the current price of the underlying
     * @param t time for the option
     * @param k true for call false for put
     * @return profit total possible profit amount
     */
    function rate(uint256 amount, uint256 maxAvailable, uint256 newPrice, uint256 t, bool k) external view override returns (uint256)  {
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
     * @param maxAvailable the total pooled ETH unlocked and available to bet
     * @param newPrice the price of the underlying at time rate is requested
     * @param t time for the option
     * @param k true for call false for put
     * @return profit total possible profit amount
     */
    function rate(uint256 amount, uint256 maxAvailable, uint256 newPrice, uint256 t, bool k) external view override returns (uint256)  {
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