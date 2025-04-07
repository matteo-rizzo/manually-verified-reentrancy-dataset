pragma solidity ^0.4.15;


/**
 * @title Ownable
 * @dev The Ownable contract has an owner address, and provides basic authorization control
 * functions, this simplifies the implementation of "user permissions".
 */


contract IRateOracle {
    function converted(uint256 weis) external constant returns (uint256);
}

contract RateOracle is IRateOracle, Ownable {

    uint32 public constant delimiter = 100;
    uint32 public rate;

    event RateUpdated(uint32 indexed newRate);

    function setRate(uint32 _rate) external onlyOwner {
        rate = _rate;
        RateUpdated(rate);
    }

    function converted(uint256 weis) external constant returns (uint256)  {
        return weis * rate / delimiter;
    }
}