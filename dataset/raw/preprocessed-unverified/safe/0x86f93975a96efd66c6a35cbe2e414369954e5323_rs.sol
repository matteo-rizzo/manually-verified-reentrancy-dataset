/**
 *Submitted for verification at Etherscan.io on 2021-02-27
*/

// SPDX-License-Identifier: MIT


pragma solidity ^0.6.6;
pragma experimental ABIEncoderV2;






// to support backward compatible contract name -- so function signature remains same
abstract contract ERC20 is IERC20 {

}




// ERC20 Token Smart Contract
contract oracleInfo {

    address owner;
    OrFeedInterface orfeed = OrFeedInterface(0x8316B082621CFedAB95bf4a44a1d4B64a6ffc336);
    address kyberProxyAddress = 0x818E6FECD516Ecc3849DAf6845e3EC868087B755;
    IKyberNetworkProxy kyberProxy = IKyberNetworkProxy(kyberProxyAddress);

    constructor() public payable {
        owner = msg.sender;

    }
    
    function getTokenPrice(string memory fromParam, string memory toParam, string memory venue, uint256 amount) public view returns (uint256) {
         return orfeed.getExchangeRate(fromParam, toParam, venue, amount);

    }

    function getPriceFromOracle(string memory fromParam, string memory toParam, uint256 amount) public view returns (uint256){

        address sellToken = orfeed.getTokenAddress(fromParam);
        address buyToken = orfeed.getTokenAddress(toParam);

        ERC20 sellToken1 = ERC20(sellToken);
        ERC20 buyToken1 = ERC20(buyToken);

        uint sellDecim = sellToken1.decimals();
        uint buyDecim = buyToken1.decimals();

        // uint base = 1^sellDecim;
        // uint adding;
        (uint256 price,) = kyberProxy.getExpectedRate(sellToken1, buyToken1, amount);


        uint initResp = (((price * 1000000) / (10 ** 18)) * (amount)) / 1000000;
        uint256 diff;
        if (sellDecim > buyDecim) {
            diff = sellDecim - buyDecim;
            initResp = initResp / (10 ** diff);
            return initResp;
        }

        else if (sellDecim < buyDecim) {
            diff = buyDecim - sellDecim;
            initResp = initResp * (10 ** diff);
            return initResp;
        }
        else {
            return initResp;
        }


    }


}