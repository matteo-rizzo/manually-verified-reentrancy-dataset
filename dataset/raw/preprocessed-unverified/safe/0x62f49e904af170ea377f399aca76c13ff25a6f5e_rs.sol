/**

 *Submitted for verification at Etherscan.io on 2019-04-01

*/



pragma solidity ^0.5.0;



// This contract is still in Beta, use at your own risk













contract TrustlessOTC is Ownable {

    

    mapping(address => uint256) public balanceTracker;

    

    event OfferCreated(uint indexed tradeID);

    event OfferCancelled(uint indexed tradeID);

    event OfferTaken(uint indexed tradeID);

    

    struct TradeOffer {

        address tokenFrom;

        address tokenTo;

        uint256 amountFrom;

        uint256 amountTo;

        address creator;

        bool active;

        uint tradeID;

    }

    

    TradeOffer[] public offers;

    

    function initiateTrade(

        address _tokenFrom,

        address _tokenTo, 

        uint256 _amountFrom,

        uint256 _amountTo

        ) public returns (uint newTradeID) {

            require(Token(_tokenFrom).transferFrom(msg.sender, address(this), _amountFrom));

            newTradeID = offers.length;

            offers.length++;

            TradeOffer storage o = offers[newTradeID];

            balanceTracker[_tokenFrom] += _amountFrom;

            o.tokenFrom = _tokenFrom;

            o.tokenTo = _tokenTo;

            o.amountFrom = _amountFrom;

            o.amountTo = _amountTo;

            o.creator = msg.sender;

            o.active = true;

            o.tradeID = newTradeID;

            emit OfferCreated(newTradeID);

    }

    

    function cancelTrade(uint tradeID) public returns (bool) {

        TradeOffer storage o = offers[tradeID];

        require(msg.sender == o.creator);

        require(Token(o.tokenFrom).transfer(o.creator, o.amountFrom));

        balanceTracker[o.tokenFrom] -= o.amountFrom;

        o.active = false;

        emit OfferCancelled(tradeID);

        return true;

    }

    

    function take(uint tradeID) public returns (bool) {

        TradeOffer storage o = offers[tradeID];

        require(o.active == true);

        require(Token(o.tokenFrom).transfer(msg.sender, o.amountFrom));

        balanceTracker[o.tokenFrom] -= o.amountFrom;

        require(Token(o.tokenTo).transferFrom(msg.sender, o.creator, o.amountTo));

        o.active = false;

        emit OfferTaken(tradeID);

        return true;

    }

    

    function getOfferDetails(uint tradeID) external view returns (

        address _tokenFrom,

        address _tokenTo, 

        uint256 _amountFrom,

        uint256 _amountTo,

        address _creator,

        bool _active

    ) {

        TradeOffer storage o = offers[tradeID];

        _tokenFrom = o.tokenFrom;

        _tokenTo = o.tokenTo;

        _amountFrom = o.amountFrom;

        _amountTo = o.amountTo;

        _creator = o.creator;

        _active = o.active;

    }



    

    function reclaimToken(Token _token) external onlyOwner {

        uint256 balance = _token.balanceOf(address(this));

        uint256 excess = balance - balanceTracker[address(_token)];

        require(excess > 0);

        _token.transfer(owner, excess);

    }

    

    

}