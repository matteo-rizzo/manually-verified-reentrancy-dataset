/**
 *Submitted for verification at Etherscan.io on 2019-10-21
*/

pragma solidity ^0.5.0;












contract GetRateMinter {
    IManager public _registry;
    INetAssetValueUSD public _asset;
    IPriceUSD public _SWMPriceOracle;

    using SafeMath for uint256;

    constructor(address registry, address asset, address SWMRate) public {
        _registry = IManager(registry);
        _asset = INetAssetValueUSD(asset);
        _SWMPriceOracle = IPriceUSD(SWMRate);
    }

    modifier onlyTokenOwner(address src20) {
        require(msg.sender == Ownable(src20).owner(), "caller not token owner");
        _;
    }

    
    function calcStake(uint256 netAssetValueUSD) public view returns (uint256) {

        uint256 NAV = netAssetValueUSD; 
        uint256 stakeUSD;

        if(NAV > 0 && NAV <= 500000) 
            stakeUSD = 2500;

        if(NAV > 500000 && NAV <= 1000000) 
            stakeUSD = NAV.mul(5).div(1000);

        if(NAV > 1000000 && NAV <= 5000000) 
            stakeUSD = NAV.mul(45).div(10000);

        if(NAV > 5000000 && NAV <= 15000000) 
            stakeUSD = NAV.mul(4).div(1000);

        if(NAV > 15000000 && NAV <= 50000000) 
            stakeUSD = NAV.mul(25).div(10000);

        if(NAV > 50000000 && NAV <= 100000000) 
            stakeUSD = NAV.mul(2).div(1000);

        if(NAV > 100000000 && NAV <= 150000000) 
            stakeUSD = NAV.mul(15).div(10000);

        if(NAV > 150000000) 
            stakeUSD = NAV.mul(1).div(1000);

        (uint256 numerator, uint denominator) = _SWMPriceOracle.getPrice(); 

        return stakeUSD.mul(denominator).div(numerator).mul(10**18); 

    } 

    
    function stakeAndMint(address src20, uint256 numSRC20Tokens)
        external
        onlyTokenOwner(src20)
        returns (bool)
    {
        uint256 numSWMTokens = calcStake(_asset.getNetAssetValueUSD(src20));

        require(_registry.mintSupply(src20, msg.sender, numSWMTokens, numSRC20Tokens), 'supply minting failed');

        return true;
    }
}