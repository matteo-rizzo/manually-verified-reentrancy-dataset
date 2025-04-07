pragma solidity ^0.4.18;

// File: contracts/IPricingStrategy.sol



// File: zeppelin-solidity/contracts/math/SafeMath.sol

/**
 * @title SafeMath
 * @dev Math operations with safety checks that throw on error
 */


// File: contracts/PricingStrategy.sol

contract PricingStrategy is IPricingStrategy {

    using SafeMath for uint;

    uint public rate;

    function PricingStrategy(
        uint _rate
    ) public 
    {
        require(_rate >= 0);
        rate = _rate;
    }

    /** Interface declaration. */
    function isPricingStrategy() public view returns (bool) {
        return true;
    }

    /** Calculate the current price for buy in amount. */
    function calculateTokenAmount(uint weiAmount, uint tokensSold) public view returns (uint tokenAmount) {
        return weiAmount.mul(rate);
    }

}