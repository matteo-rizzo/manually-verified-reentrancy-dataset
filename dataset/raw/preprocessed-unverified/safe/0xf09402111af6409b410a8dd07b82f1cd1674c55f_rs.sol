pragma solidity >=0.4.24;

//import '@uniswap/v2-periphery/contracts/libraries/SafeMath.sol';

// a library for performing overflow-safe math, courtesy of DappHub (https://github.com/dapphub/ds-math)






//import '@uniswap/v2-core/contracts/interfaces/IUniswapV2Pair.sol';




/** Calculates the Delta for a rebase based on the ratio
*** between the price of two different token pairs on 
*** Uniswap 
***
*** - minimalist design
*** - low gas design
*** - free for anyone to call. 
***
****/
contract RebaseDelta {

    using RB_SafeMath for uint256;
    using RB_UnsignedSafeMath for int256;
    
    uint256 private constant PRICE_PRECISION = 10**9;

    function getPrice(IUniswapV2Pair pair_, bool flip_) 
    public
    view
    returns (uint256) 
    {
        require(address(pair_) != address(0));

        (uint256 reserves0, uint256 reserves1, ) = pair_.getReserves();

        if (flip_) {
            (reserves0, reserves1) = (reserves1, reserves0);            
        }

        // reserves0 = base (probably ETH/WETH)
        // reserves1 = token of interest (maybe ampleforthgold or paxusgold etc)

        // multiply to equate decimals, multiply up to PRICE_PRECISION

        uint256 price = (reserves1.mul(PRICE_PRECISION)).div(reserves0);

        return price;
    }

    // calculates the supply delta for moving the price of token X to the price
    // of token Y (with the understanding that they are both priced in a common
    // tokens value, i.e. WETH).  
    function calculate(IUniswapV2Pair X_,
                      bool flipX_,
                      uint256 decimalsX_,
                      uint256 SupplyX_, 
                      IUniswapV2Pair Y_,
                      bool flipY_,
                      uint256 decimalsY_)
    public
    view
    returns (int256)
    {
        uint256 px = getPrice(X_, flipX_);
        require(px != uint256(0));
        uint256 py = getPrice(Y_, flipY_);
        require(py != uint256(0));

        uint256 targetSupply = (SupplyX_.mul(py)).div(px);

        // adust for decimals
        if (decimalsX_ == decimalsY_) {
            // do nothing
        }
        else if (decimalsX_ > decimalsY_) {
            uint256 ddg = (10**decimalsX_).div(10**decimalsY_);
            require (ddg != uint256(0));
            targetSupply = targetSupply.mul(ddg); 
        }
        else {
            uint256 ddl = (10**decimalsY_).div(10**decimalsX_);
            require (ddl != uint256(0));
            targetSupply = targetSupply.div(ddl);        
        }

        int256 delta = int256(SupplyX_).sub(int256(targetSupply));

        return delta;
    }
}