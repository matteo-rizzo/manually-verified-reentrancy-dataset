/**

 *Submitted for verification at Etherscan.io on 2019-06-08

*/



pragma solidity ^0.5.4;





/**

 * @dev Interface of the ERC20 standard as defined in the EIP. Does not include

 * the optional functions; to access them see `ERC20Detailed`.

 */





/**

 * @dev Wrappers over Solidity's arithmetic operations with added overflow

 * checks.

 *

 * Arithmetic operations in Solidity wrap on overflow. This can easily result

 * in bugs, because programmers usually assume that an overflow raises an

 * error, which is the standard behavior in high level programming languages.

 * `SafeMath` restores this intuition by reverting the transaction when an

 * operation overflows.

 *

 * Using this library instead of the unchecked operations eliminates an entire

 * class of bugs, so it's recommended to use it always.

 */





/**

 * @dev Collection of functions related to the address type,

 */





/**

 * @title SafeERC20

 * @dev Wrappers around ERC20 operations that throw on failure (when the token

 * contract returns false). Tokens that return no value (and instead revert or

 * throw on failure) are also supported, non-reverting calls are assumed to be

 * successful.

 * To use this library you can add a `using SafeERC20 for ERC20;` statement to your contract,

 * which allows you to call the safe operations as `token.safeTransfer(...)`, etc.

 */





/**

 * @title Ownable

 * @dev The Ownable contract has an owner address, and provides basic authorization control

 * functions, this simplifies the implementation of "user permissions".

 */







contract TrustlessOTC is Ownable {

    using SafeMath for uint256;

    using SafeERC20 for IERC20;



    mapping(address => uint256) public balanceTracker;

    mapping(address => uint256) public feeTracker;

    mapping(address => uint[]) public tradeTracker;



    event OfferCreated(uint indexed tradeID);

    event OfferCancelled(uint indexed tradeID);

    event OfferTaken(uint indexed tradeID);



    uint256 public feeBasisPoints;



    constructor (uint256 _feeBasisPoints) public {

      feeBasisPoints = _feeBasisPoints;

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

                IERC20(_tokenFrom).safeTransferFrom(msg.sender, address(this), _amountFrom);

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

        require(o.active == true);

        o.active = false;

        if (o.tokenFrom == address(0)) {

          msg.sender.transfer(o.amountFrom);

        } else {

          IERC20(o.tokenFrom).safeTransfer(o.creator, o.amountFrom);

        }

        balanceTracker[o.tokenFrom] -= o.amountFrom;

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

          IERC20(o.tokenFrom).safeTransfer(msg.sender, o.amountFrom.sub(fee));

        }



        if (o.tokenTo == address(0)) {

            require(msg.value == o.amountTo);

            o.creator.transfer(msg.value);

        } else {

            require(msg.value == 0);

            IERC20(o.tokenTo).safeTransferFrom(msg.sender, o.creator, o.amountTo);

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



    function reclaimToken(IERC20 _token) external onlyOwner {

        uint256 balance = _token.balanceOf(address(this));

        uint256 excess = balance.sub(balanceTracker[address(_token)]);

        require(excess > 0);

        if (address(_token) == address(0)) {

            msg.sender.transfer(excess);

        } else {

            _token.safeTransfer(owner(), excess);

        }

    }



    function claimFees(IERC20 _token) external onlyOwner {

        uint256 feesToClaim = feeTracker[address(_token)];

        feeTracker[address(_token)] = 0;

        require(feesToClaim > 0);

        if (address(_token) == address(0)) {

            msg.sender.transfer(feesToClaim);

        } else {

            _token.safeTransfer(owner(), feesToClaim);

        }

    }



}