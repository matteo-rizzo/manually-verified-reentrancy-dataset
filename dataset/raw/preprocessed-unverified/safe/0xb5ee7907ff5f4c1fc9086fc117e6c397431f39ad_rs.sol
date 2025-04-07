/**
 *Submitted for verification at Etherscan.io on 2019-12-23
*/

pragma solidity ^0.5.15;




contract PriceOracle {
    OneSplit split = OneSplit(0xAd13fE330B0aE312bC51d2E5B9Ca2ae3973957C7);
    
    function getPricesInETH(
        IERC20[] memory fromTokens,
        uint[] memory oneUnitAmounts
    ) public view returns(uint[] memory prices) {
        prices = new uint[](fromTokens.length);
        for (uint i = 0; i < fromTokens.length; i++) {
            (uint price,) = split.getExpectedReturn(
                fromTokens[i],
                IERC20(0xEeeeeEeeeEeEeeEeEeEeeEEEeeeeEeeeeeeeEEeE),
                oneUnitAmounts[i],
                1,
                0
            );
            prices[i] = price;
        }
    }
}