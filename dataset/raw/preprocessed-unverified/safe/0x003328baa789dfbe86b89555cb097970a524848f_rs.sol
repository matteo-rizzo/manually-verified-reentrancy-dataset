/**
 *Submitted for verification at Etherscan.io on 2019-12-24
*/

pragma solidity ^0.5.8;
pragma experimental ABIEncoderV2;




contract SoloMarginContract {

    struct Info {
        address owner;  // The address that owns the account
        uint256 number; // A nonce that allows a single address to control many accounts
    }


    struct Wei {
        bool sign; // true if positive
        uint256 value;
    }

    struct Price {
        uint256 value;
    }

    struct TotalPar {
        uint128 borrow;
        uint128 supply;
    }

    struct Index {
        uint96 borrow;
        uint96 supply;
        uint32 lastUpdate;
    }

    function getMarketPrice(uint256 marketId) public view returns (Price memory);
    function getAccountWei(Info memory account, uint256 marketId) public view returns (Wei memory);
    function getMarketTotalPar(uint256 marketId) public view returns (TotalPar memory);
    function getMarketCurrentIndex(uint256 marketId) public view returns (Index memory);
}




contract Helpers {

    /**
     * @dev get Dydx Solo Address
    */
    function getSoloAddress() public pure returns (address addr) {
        addr = 0x1E0447b19BB6EcFdAe1e4AE1694b0C3659614e4e;
    }

    function getInstaRegistry() public pure returns (address addr) {
        addr = 0x498b3BfaBE9F73db90D252bCD4Fa9548Cd0Fd981;
    }

    /**
    * @dev getting acccount arg
    */
    function getAccountArgs(address owner) internal pure returns (SoloMarginContract.Info[] memory) {
        SoloMarginContract.Info[] memory accounts = new SoloMarginContract.Info[](1);
        accounts[0] = (SoloMarginContract.Info(owner, 0));
        return accounts;
    }

    struct DydxData {
        SoloMarginContract.Price tokenPrice;
        SoloMarginContract.Wei balanceOfUser;
        SoloMarginContract.Wei balanceOfWallet;
        SoloMarginContract.TotalPar marketTotalPar;
        SoloMarginContract.Index marketCurrentIndex;
    }
}


contract InstaDydxRead is Helpers {
    function getDydxUserData(address owner, uint[] memory marketId) public view returns(DydxData[] memory) {
        SoloMarginContract solo = SoloMarginContract(getSoloAddress());
        address userWallet = RegistryInterface(getInstaRegistry()).proxies(owner);
        DydxData[] memory tokensData = new DydxData[](marketId.length);
        for (uint i = 0; i < marketId.length; i++) {
            uint id = marketId[i];
            tokensData[i] = DydxData(
                solo.getMarketPrice(id),
                solo.getAccountWei(getAccountArgs(owner)[0], id),
                solo.getAccountWei(getAccountArgs(userWallet)[0], id),
                solo.getMarketTotalPar(id),
                solo.getMarketCurrentIndex(id)
            );
        }
        return tokensData;
    }
}