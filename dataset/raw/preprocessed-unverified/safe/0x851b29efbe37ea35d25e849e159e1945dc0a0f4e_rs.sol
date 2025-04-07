pragma solidity ^0.4.23;

/**
 * @title Ownable
 * @dev The Ownable contract has an owner address, and provides basic authorization control
 * functions, this simplifies the implementation of "user permissions".
 */


/**
 * @title WhiteListRegistry
 * @dev A whitelist registry contract that holds the list of addreses that can participate in the crowdsale.
 * Owner can add and remove addresses to whitelist.
 */
contract WhiteListRegistry is Ownable {

    mapping (address => WhiteListInfo) public whitelist;

    struct WhiteListInfo {
        bool whiteListed;
        uint minCap;
    }

    event AddedToWhiteList(address contributor, uint minCap);

    event RemovedFromWhiteList(address _contributor);

    function addToWhiteList(address _contributor, uint _minCap) public onlyOwner {
        require(_contributor != address(0));
        whitelist[_contributor] = WhiteListInfo(true, _minCap);
        emit AddedToWhiteList(_contributor, _minCap);
    }

    function removeFromWhiteList(address _contributor) public onlyOwner {
        require(_contributor != address(0));
        delete whitelist[_contributor];
        emit RemovedFromWhiteList(_contributor);
    }

    function isWhiteListed(address _contributor) public view returns(bool) {
        return whitelist[_contributor].whiteListed;
    }

    function isAmountAllowed(address _contributor, uint _amount) public view returns(bool) {
        return whitelist[_contributor].minCap <= _amount && isWhiteListed(_contributor);
    }
}