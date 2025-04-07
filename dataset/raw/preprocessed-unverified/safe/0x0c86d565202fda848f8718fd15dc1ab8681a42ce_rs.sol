pragma solidity ^0.4.15;

/**
 * @title SafeMath
 * @dev Math operations with safety checks that throw on error
 */




contract PricingStrategy2 {

    using SafeMath for uint;

    uint public rate;

    function PricingStrategy2(uint _rate) {
        require(_rate > 0);
        rate = _rate;
    }

    /** Interface declaration. */
    function isPricingStrategy() public constant returns (bool) {
        return true;
    }

    /** Calculate the current price for buy in amount. */
    function calculateTokenAmount(uint weiAmount) public constant returns (uint tokenAmount) {
        return weiAmount.mul(rate);
    }
}