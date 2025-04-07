/**
 *Submitted for verification at Etherscan.io on 2021-05-04
*/

// SPDX-License-Identifier: AGPL-3.0-or-later
pragma solidity 0.7.5;













interface IUniswapV2Pair is IUniswapV2ERC20 {
    function getReserves() external view returns (uint112 reserve0, uint112 reserve1, uint32 blockTimestampLast);
}



contract OlympusBondingCalculator is IBondingCalculator {

    using FixedPoint for *;
    using SafeMath for uint;
    using SafeMath for uint112;

    function getKValue( address pair_ ) public view returns( uint k_ ) {
        (uint reserve0, uint reserve1, ) = IUniswapV2Pair( pair_ ).getReserves();
        k_ = reserve0.mul(reserve1).div( 1e9 );
    }

    function getTotalValue( address pair_ ) public view returns ( uint _value ) {
        uint k = getKValue( pair_ );
        _value = k.sqrrt().mul(2);
    }

    function valuation( address pair_, uint amount_ ) external view override returns ( uint _value ) {
        uint totalValue = getTotalValue( pair_ );
        uint totalSupply = IUniswapV2Pair( pair_ ).totalSupply();

        _value = totalValue.mul( FixedPoint.fraction( amount_, totalSupply ).decode112with18() ).div( 1e18 );
    }

    function markdown( address pair_ ) external view returns ( uint ) {
        ( , uint reserve1, ) = IUniswapV2Pair( pair_ ).getReserves();
        return reserve1.mul( 2e9 ).div( getTotalValue( pair_ ) );
    }
}