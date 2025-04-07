/**
 *Submitted for verification at Etherscan.io on 2021-03-24
*/

// File: localhost/abstract/OracleSimple.sol

// SPDX-License-Identifier: bsl-1.1

/*
  Copyright 2020 Unit Protocol: Artem Zakharov ([email protected]).
*/
pragma solidity 0.7.6;


/**
 * @title OracleSimple
 **/
abstract contract OracleSimple {
    // returns Q112-encoded value
    function assetToUsd(address asset, uint amount) public virtual view returns (uint) {}
}


/**
 * @title OracleSimplePoolToken
 **/
abstract contract OracleSimplePoolToken is OracleSimple {
    ChainlinkedOracleSimple public oracleMainAsset;
}


/**
 * @title ChainlinkedOracleSimple
 **/
abstract contract ChainlinkedOracleSimple is OracleSimple {
    address public WETH;
    // returns ordinary value
    function ethToUsd(uint ethAmount) public virtual view returns (uint) {}

    // returns Q112-encoded value
    function assetToEth(address asset, uint amount) public virtual view returns (uint) {}
}

// File: localhost/helpers/IUniswapV2Pair.sol

/*
  Copyright 2020 Unit Protocol: Artem Zakharov ([email protected]).
*/



// File: localhost/helpers/SafeMath.sol

/*
  Copyright 2020 Unit Protocol: Artem Zakharov ([email protected]).
*/


/**
 * @title SafeMath
 * @dev Math operations with safety checks that throw on error
 */


// File: localhost/impl/ChainlinkedKeep3rV1OraclePoolToken.sol

/*
  Copyright 2020 Unit Protocol: Artem Zakharov ([email protected]).
*/





/**
 * @title ChainlinkedKeep3rV1OraclePoolToken
 * @dev Calculates the USD price of Uniswap LP tokens
 **/
contract ChainlinkedKeep3rV1OraclePoolToken is OracleSimplePoolToken {
    using SafeMath for uint;

    uint public immutable Q112 = 2 ** 112;

    constructor(address _chainlinkOracleWrapperMainAsset) {
        oracleMainAsset = ChainlinkedOracleSimple(_chainlinkOracleWrapperMainAsset);
    }

    /**
     * @notice This function implements flashloan-resistant logic to determine USD price of Uniswap LP tokens
     * @notice Pair must be registered at Chainlink
     * @param asset The LP token address
     * @param amount Amount of asset
     * @return Q112 encoded price of asset in USD
     **/
    function assetToUsd(
        address asset,
        uint amount
    )
        public
        override
        view
        returns (uint)
    {
        IUniswapV2Pair pair = IUniswapV2Pair(asset);
        address underlyingAsset;
        if (pair.token0() == oracleMainAsset.WETH()) {
            underlyingAsset = pair.token1();
        } else if (pair.token1() == oracleMainAsset.WETH()) {
            underlyingAsset = pair.token0();
        } else {
            revert("Unit Protocol: NOT_REGISTERED_PAIR");
        }

        // average price of 1 token in ETH
        uint eAvg = oracleMainAsset.assetToEth(underlyingAsset, 1);

        (uint112 _reserve0, uint112 _reserve1,) = pair.getReserves();
        uint aPool; // current asset pool
        uint ePool; // current WETH pool
        if (pair.token0() == underlyingAsset) {
            aPool = uint(_reserve0);
            ePool = uint(_reserve1);
        } else {
            aPool = uint(_reserve1);
            ePool = uint(_reserve0);
        }

        uint eCurr = ePool.mul(Q112).div(aPool); // current price of 1 token in WETH
        uint ePoolCalc; // calculated WETH pool

        if (eCurr < eAvg) {
            // flashloan buying WETH
            uint sqrtd = ePool.mul((ePool).mul(9).add(
                aPool.mul(3988000).mul(eAvg).div(Q112)
            ));
            uint eChange = sqrt(sqrtd).sub(ePool.mul(1997)).div(2000);
            ePoolCalc = ePool.add(eChange);
        } else {
            // flashloan selling WETH
            uint a = aPool.mul(eAvg);
            uint b = a.mul(9).div(Q112);
            uint c = ePool.mul(3988000);
            uint sqRoot = sqrt(a.div(Q112).mul(b.add(c)));
            uint d = a.mul(3).div(Q112);
            uint eChange = ePool.sub(d.add(sqRoot).div(2000));
            ePoolCalc = ePool.sub(eChange);
        }

        uint num = ePoolCalc.mul(2).mul(amount);
        uint priceInEth;
        if (num > Q112) {
            priceInEth = num.div(pair.totalSupply()).mul(Q112);
        } else {
            priceInEth = num.mul(Q112).div(pair.totalSupply());
        }

        return oracleMainAsset.ethToUsd(priceInEth);
    }

    function sqrt(uint x) internal pure returns (uint y) {
        if (x > 3) {
            uint z = x / 2 + 1;
            y = x;
            while (z < y) {
                y = z;
                z = (x / z + z) / 2;
            }
        } else if (x != 0) {
            y = 1;
        }
    }
}