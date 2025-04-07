/**
 *Submitted for verification at Etherscan.io on 2019-10-21
*/

pragma solidity ^0.5.0;






contract SWMPriceOracle is IPriceUSD, Ownable {

    event UpdatedSWMPriceUSD(uint256 oldPriceNumerator, uint256 oldPriceDenominator, 
                             uint256 newPriceNumerator, uint256 newPriceDenominator);

    uint256 public _priceNumerator;
    uint256 public _priceDenominator;

    constructor(uint256 priceNumerator, uint256 priceDenominator) 
    public {
        require(priceNumerator > 0, "numerator must not be zero");
        require(priceDenominator > 0, "denominator must not be zero");

        _priceNumerator = priceNumerator;
        _priceDenominator = priceDenominator;

        emit UpdatedSWMPriceUSD(0, 0, priceNumerator, priceNumerator);
    }

    
    function getPrice() external view returns (uint256 priceNumerator, uint256 priceDenominator) {
        return (_priceNumerator, _priceDenominator);
    }

    
    function updatePrice(uint256 priceNumerator, uint256 priceDenominator) external onlyOwner returns (bool) {
        require(priceNumerator > 0, "numerator must not be zero");
        require(priceDenominator > 0, "denominator must not be zero");

        emit UpdatedSWMPriceUSD(_priceNumerator, _priceDenominator, priceNumerator, priceDenominator);

        _priceNumerator = priceNumerator;
        _priceDenominator = priceDenominator;

        return true;
    }
}