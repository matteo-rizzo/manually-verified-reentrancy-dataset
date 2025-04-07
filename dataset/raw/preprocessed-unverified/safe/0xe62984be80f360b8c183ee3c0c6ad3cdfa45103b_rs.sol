/**
 *Submitted for verification at Etherscan.io on 2021-03-01
*/

pragma solidity ^0.6.0;
pragma experimental ABIEncoderV2;













contract DSMath {

    function add(uint x, uint y) internal pure returns (uint z) {
        require((z = x + y) >= x, "math-not-safe");
    }

    function sub(uint x, uint y) internal pure returns (uint z) {
        z = x - y <= x ? x - y : 0;
    }

    function mul(uint x, uint y) internal pure returns (uint z) {
        require(y == 0 || (z = x * y) / y == x, "math-not-safe");
    }

    uint constant WAD = 10 ** 18;
    uint constant RAY = 10 ** 27;

    function rmul(uint x, uint y) internal pure returns (uint z) {
        z = add(mul(x, y), RAY / 2) / RAY;
    }

    function wmul(uint x, uint y) internal pure returns (uint z) {
        z = add(mul(x, y), WAD / 2) / WAD;
    }

    function rdiv(uint x, uint y) internal pure returns (uint z) {
        z = add(mul(x, RAY), y / 2) / y;
    }

    function wdiv(uint x, uint y) internal pure returns (uint z) {
        z = add(mul(x, WAD), y / 2) / y;
    }

}


contract Helpers is DSMath {

    struct AaveData {
        uint collateral;
        uint debt;
    }

    struct data {
        address user;
        AaveData[] tokensData;
    }
    
    struct datas {
        AaveData[] tokensData;
    }

    /**
     * @dev get Aave Provider Address
    */
    function getAaveProviderAddress() internal pure returns (address) {
        return 0x24a42fD28C976A61Df5D00D0599C34c4f90748c8; //mainnet
        // return 0x506B0B2CF20FAA8f38a4E2B524EE43e1f4458Cc5; //kovan
    }

    /**
     * @dev get Chainlink ETH price feed Address
    */
    function getChainlinkEthFeed() internal pure returns (address) {
        return 0x5f4eC3Df9cbd43714FE2740f5E3616155c5b8419; //mainnet
        // return 0x9326BFA02ADD2366b30bacB125260Af641031331; //kovan
    }


    struct TokenPrice {
        uint priceInEth;
        uint priceInUsd;
    }

}

contract InstaAaveV1PowerResolver is Helpers {
    function getEthPrice() public view returns (uint ethPrice) {
        ethPrice = uint(ChainLinkInterface(getChainlinkEthFeed()).latestAnswer());
    }

    function getTokensPrices(address[] memory tokens) 
    public view returns(TokenPrice[] memory tokenPrices, uint ethPrice) {
        AaveProviderInterface AaveProvider = AaveProviderInterface(getAaveProviderAddress());
        uint[] memory _tokenPrices = AavePriceInterface(AaveProvider.getPriceOracle()).getAssetsPrices(tokens);
        ethPrice = uint(ChainLinkInterface(getChainlinkEthFeed()).latestAnswer());
        tokenPrices = new TokenPrice[](_tokenPrices.length);
        for (uint i = 0; i < _tokenPrices.length; i++) {
            tokenPrices[i] = TokenPrice(
                _tokenPrices[i],
                wmul(_tokenPrices[i], uint(ethPrice) * 10 ** 10)
            );
        }
    }
    
    function getAaveDataByReserve(address[] memory owners, address reserve, address atoken, AaveCoreInterface aaveCore) public view returns (AaveData[] memory) {
        AaveData[] memory tokensData = new AaveData[](owners.length);
        ATokenInterface atokenContract = ATokenInterface(atoken);
        for (uint i = 0; i < owners.length; i++) {
            (,uint debt,) = aaveCore.getUserBorrowBalances(reserve, owners[i]);
            tokensData[i] = AaveData(
                atokenContract.balanceOf(owners[i]),
                debt
            );
        }

        return tokensData;
    }

    function getPositionByReserves(
        address[] calldata owners,
        address[] calldata reserves,
        address[] calldata atokens
    )
        external
        view
        returns (datas[] memory)
    {
        AaveProviderInterface AaveProvider = AaveProviderInterface(getAaveProviderAddress());
        AaveCoreInterface aaveCore = AaveCoreInterface(AaveProvider.getLendingPoolCore());
        // AaveInterface aave = AaveInterface(AaveProvider.getLendingPool());
        datas[] memory _data = new datas[](reserves.length);
        for (uint i = 0; i < reserves.length; i++) {
            _data[i] = datas(
                getAaveDataByReserve(owners, reserves[i], atokens[i], aaveCore)
            );
        }
        return _data;
    }

    function getPositionByAddress(
        address[] memory owners
    )
        public
        view
        returns (AaveData[] memory)
    {   
        AaveProviderInterface AaveProvider = AaveProviderInterface(getAaveProviderAddress());
        AaveInterface aave = AaveInterface(AaveProvider.getLendingPool());
        AaveData[] memory tokensData = new AaveData[](owners.length);

        for (uint i = 0; i < owners.length; i++) {
            (
            ,
            uint totalCollateralETH,
            uint totalBorrowsETH,
            ,,,,) = aave.getUserAccountData(owners[i]);

            tokensData[i] = AaveData(
                totalCollateralETH,
                totalBorrowsETH
            );
        }

        return tokensData;
    }

}