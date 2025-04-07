pragma solidity ^0.4.16;



contract EtheremonTrade is EtheremonTradeInterface {
    function isOnTrading(uint64 _objId) constant external returns(bool) {
        return false;
    }
}