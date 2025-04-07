/**
 *Submitted for verification at Etherscan.io on 2021-02-09
*/

// SPDX-License-Identifier: agpl-3.0
pragma solidity 0.6.12;







contract XSushiPriceAdapter is IExtendedAggregator {
    using SafeMath for uint256;
    address public immutable SUSHI = 0x6B3595068778DD592e39A122f4f5a5cF09C90fE2;
    address public immutable xSUSHI = 0x8798249c2E607446EfB7Ad49eC89dD1865Ff4272;
    address public immutable SUSHI_ORACLE = 0xe572CeF69f43c2E488b33924AF04BDacE19079cf;
    
    enum ProxyType {Invalid, Simple, Complex}
    
    function getToken() external view override returns(address) {
        return xSUSHI;
    }
    function getTokenType() external view override returns (uint256) {
        return uint256(ProxyType.Complex);
    }
 
    function getSubTokens() external view override returns(address[] memory) {
        address[] memory _subtTokens = new address[](1);
        _subtTokens[0] = SUSHI;
        return _subtTokens;
    }
    function latestAnswer() external view override returns (int256) {
        uint256 exchangeRate = IERC2O(SUSHI).balanceOf(xSUSHI).div(IERC2O(xSUSHI).totalSupply());
        uint256 sushiPrice = uint256(IExtendedAggregator(SUSHI_ORACLE).latestAnswer());
        return int256(sushiPrice.mul(exchangeRate));
    }
}