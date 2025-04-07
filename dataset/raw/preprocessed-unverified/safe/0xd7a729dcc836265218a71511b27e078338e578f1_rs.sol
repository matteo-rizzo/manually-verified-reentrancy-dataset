/**

 *Submitted for verification at Etherscan.io on 2018-08-30

*/



pragma solidity ^0.4.16;







contract EtheremonTradingVerifier {

    address public tradingData;

    

    function EtheremonTradingVerifier(address _tradingData) public {

        tradingData = _tradingData;

    }

    

    function isOnTrading(uint64 _objId) constant external returns(bool) {

        EtheremonTradeData monTradeData = EtheremonTradeData(tradingData);

        return monTradeData.isOnTrade(_objId);

    }

}