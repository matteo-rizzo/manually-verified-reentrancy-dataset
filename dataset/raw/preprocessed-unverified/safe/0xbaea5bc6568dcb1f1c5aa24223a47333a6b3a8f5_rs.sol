/**

 *Submitted for verification at Etherscan.io on 2019-06-03

*/



pragma solidity ^0.5.5;



/*

    This contract is open source under the MIT license

    Ethfinex Inc - 2019



/*



/**

 * @title SafeMath

 * @dev Unsigned math operations with safety checks that revert on error.

 */





/**

 * @title Ownable

 * @dev The Ownable contract has an owner address, and provides basic authorization control

 * functions, this simplifies the implementation of "user permissions".

 */















contract TrustlessOTC is Ownable {

    using SafeMath for uint256;



    mapping(address => uint256) public balanceTracker;

    mapping(address => uint256) public feeTracker;

    mapping(address => uint[]) public tradeTracker;



    mapping(address => bool) public noERC20Return;



    event OfferCreated(uint indexed tradeID);

    event OfferCancelled(uint indexed tradeID);

    event OfferTaken(uint indexed tradeID);



    uint256 public feeBasisPoints;



    constructor (uint256 _feeBasisPoints) public {

      feeBasisPoints = _feeBasisPoints;

      noERC20Return[0xdAC17F958D2ee523a2206206994597C13D831ec7] = true;

      noERC20Return[0xB97048628DB6B661D4C2aA833e95Dbe1A905B280] = true;

      noERC20Return[0x4470BB87d77b963A013DB939BE332f927f2b992e] = true;

      noERC20Return[0xd26114cd6EE289AccF82350c8d8487fedB8A0C07] = true;

      noERC20Return[0xB8c77482e45F1F44dE1745F52C74426C631bDD52] = true;

      noERC20Return[0xF433089366899D83a9f26A773D59ec7eCF30355e] = true;

      noERC20Return[0xe3818504c1B32bF1557b16C238B2E01Fd3149C17] = true;

      noERC20Return[0x81c9151de0C8bafCd325a57E3dB5a5dF1CEBf79c] = true;

    }



    struct TradeOffer {

        address tokenFrom;

        address tokenTo;

        uint256 amountFrom;

        uint256 amountTo;

        address payable creator;

        address optionalTaker;

        bool active;

        bool completed;

        uint tradeID;

    }



    TradeOffer[] public offers;



    function initiateTrade(

        address _tokenFrom,

        address _tokenTo,

        uint256 _amountFrom,

        uint256 _amountTo,

        address _optionalTaker

        ) public payable returns (uint newTradeID) {

            if (_tokenFrom == address(0)) {

                require(msg.value == _amountFrom);

            } else {

                require(msg.value == 0);

                if(noERC20Return[_tokenFrom]) {

                  TokenNoReturn(_tokenFrom).transferFrom(msg.sender, address(this), _amountFrom);

                } else {

                  Token(_tokenFrom).transferFrom(msg.sender, address(this), _amountFrom);

                }

            }

            newTradeID = offers.length;

            offers.length++;

            TradeOffer storage o = offers[newTradeID];

            balanceTracker[_tokenFrom] = balanceTracker[_tokenFrom].add(_amountFrom);

            o.tokenFrom = _tokenFrom;

            o.tokenTo = _tokenTo;

            o.amountFrom = _amountFrom;

            o.amountTo = _amountTo;

            o.creator = msg.sender;

            o.optionalTaker = _optionalTaker;

            o.active = true;

            o.tradeID = newTradeID;

            tradeTracker[msg.sender].push(newTradeID);

            emit OfferCreated(newTradeID);

    }



    function cancelTrade(uint tradeID) public returns (bool) {

        TradeOffer storage o = offers[tradeID];

        require(msg.sender == o.creator);

        if (o.tokenFrom == address(0)) {

          msg.sender.transfer(o.amountFrom);

        } else {

          if(noERC20Return[o.tokenFrom]) {

            TokenNoReturn(o.tokenFrom).transfer(o.creator, o.amountFrom);

          } else {

            Token(o.tokenFrom).transfer(o.creator, o.amountFrom);

          }

        }

        balanceTracker[o.tokenFrom] -= o.amountFrom;

        o.active = false;

        emit OfferCancelled(tradeID);

        return true;

    }



    function take(uint tradeID) public payable returns (bool) {

        TradeOffer storage o = offers[tradeID];

        require(o.optionalTaker == msg.sender || o.optionalTaker == address(0));

        require(o.active == true);

        o.active = false;

        balanceTracker[o.tokenFrom] = balanceTracker[o.tokenFrom].sub(o.amountFrom);

        uint256 fee = o.amountFrom.mul(feeBasisPoints).div(10000);

        feeTracker[o.tokenFrom] = feeTracker[o.tokenFrom].add(fee);

        tradeTracker[msg.sender].push(tradeID);



        if (o.tokenFrom == address(0)) {

            msg.sender.transfer(o.amountFrom.sub(fee));

        } else {

          if(noERC20Return[o.tokenFrom]) {

            TokenNoReturn(o.tokenFrom).transfer(msg.sender, o.amountFrom.sub(fee));

          } else {

            Token(o.tokenFrom).transfer(msg.sender, o.amountFrom.sub(fee));

          }

        }



        if (o.tokenTo == address(0)) {

            require(msg.value == o.amountTo);

            o.creator.transfer(msg.value);

        } else {

            require(msg.value == 0);

            if(noERC20Return[o.tokenTo]) {

              TokenNoReturn(o.tokenTo).transferFrom(msg.sender, o.creator, o.amountTo);

            } else {

              Token(o.tokenTo).transferFrom(msg.sender, o.creator, o.amountTo);

            }

        }

        o.completed = true;

        emit OfferTaken(tradeID);

        return true;

    }



    function getOfferDetails(uint tradeID) external view returns (

        address _tokenFrom,

        address _tokenTo,

        uint256 _amountFrom,

        uint256 _amountTo,

        address _creator,

        uint256 _fee,

        bool _active,

        bool _completed

    ) {

        TradeOffer storage o = offers[tradeID];

        _tokenFrom = o.tokenFrom;

        _tokenTo = o.tokenTo;

        _amountFrom = o.amountFrom;

        _amountTo = o.amountTo;

        _creator = o.creator;

        _fee = o.amountFrom.mul(feeBasisPoints).div(10000);

        _active = o.active;

        _completed = o.completed;

    }



    function getUserTrades(address user) external view returns (uint[] memory){

      return tradeTracker[user];

    }



    function reclaimToken(Token _token) external onlyOwner {

        uint256 balance = _token.balanceOf(address(this));

        uint256 excess = balance.sub(balanceTracker[address(_token)]);

        require(excess > 0);

        if (address(_token) == address(0)) {

            msg.sender.transfer(excess);

        } else {

            _token.transfer(owner(), excess);

        }

    }



    function reclaimTokenNoReturn(TokenNoReturn _token) external onlyOwner {

        uint256 balance = _token.balanceOf(address(this));

        uint256 excess = balance.sub(balanceTracker[address(_token)]);

        require(excess > 0);

        if (address(_token) == address(0)) {

            msg.sender.transfer(excess);

        } else {

            _token.transfer(owner(), excess);

        }

    }



    function claimFees(Token _token) external onlyOwner {

        uint256 feesToClaim = feeTracker[address(_token)];

        feeTracker[address(_token)] = 0;

        require(feesToClaim > 0);

        if (address(_token) == address(0)) {

            msg.sender.transfer(feesToClaim);

        } else {

            _token.transfer(owner(), feesToClaim);

        }

    }



}