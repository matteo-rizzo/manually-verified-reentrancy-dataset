/**
 *Submitted for verification at Etherscan.io on 2020-01-10
*/

/**
 *  https://contributing.kleros.io/smart-contract-workflow
 *  @reviewers: [unknownunknown1, marsrobertson]
 *  @auditors: []
 *  @bounties: []
 *  @deployments: []
 */
/* solium-disable error-reason */
/* solium-disable security/no-block-members */
pragma solidity ^0.5.8;

/**
 * @dev Interface of the ERC20 standard as defined in the EIP. Does not include
 * the optional functions; to access them see {ERC20Detailed}.
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
 *  @title ERC20Seller
 *  @author Clément Lesaege - <clement@kleros.io>
 *  @dev A contract to allow the sale of tokens against ETH at a price decided by the seller.
 *  Note that this contract is kept as simple as possible.
 *  It is not optimized for handling a high amount of orders by the seller but to support 1-10 orders on average.
 *  If you intend to use a lot more simultaneous orders, we would suggest developing a heap-based version of this contract.
 *  Note that:
 *      - Orders are not automatically removed when they are completely fulfilled in order to avoid changing the orderID without intervention of the seller.
 *      - Tokens amounts and prices are supposed to be reasonable such that multiplying them does not overflow.
 *      - A few wei or basic token units may be lost in the process. Only use this contract to sell a token whose basic unit price is insignificant.
 *      - The token contract is trusted not to reenter during a call to this contract.
 */
contract ERC20Seller {

    using SafeMath for uint256;

    /* Storage */

    address payable seller; // The party selling the tokens.
    IERC20 public token;    // The token to be sold.
    uint public divisor;    // The divisor of the token price. It is used to allow prices lower than 1 wei / basic_unit.

    // A sell order.
    struct Order {
        uint price;  // The selling price in wei * divisor / basic_unit.
        uint amount; // The amount of token to sell in base unit.
    }

    Order[] public orders; // A list of orders.

    /* Constant */

    uint public MAX_ORDERS = 100;   // The maximum amount of simultaneous orders. It is used to avoid having so much orders that the calls would run out of gas.
    uint NO_ORDER_FOUND = uint(-1); // Value returned by findCheapestOrder when no orders are found.
    uint MAX_VALUE = uint(-1);      // Maximum value, such that it is never exceeded.

    /* Events */

    /**
     *  @dev Emitted when a contributor makes a purchase.
     *  @param _contributor The account that made the purchase.
     *  @param _amount The amount of tokens in basic units.
     */
    event TokenPurchase(address _contributor, uint _amount);

    /* Constructor */

    /** @dev Constructs the seller contract.
     *  @param _token The token to sell.
     *  @param _divisor The divisor of the price.
     */
    constructor(IERC20 _token, uint _divisor) public {
        seller  = msg.sender;
        token   = _token;
        divisor = _divisor;
    }

    /* External */

    /** @dev Add a sell order.
     *  @param _price The selling price in wei * divisor / basic_unit.
     *  @param _amount The amount of tokens to sell in basic units.
     */
    function addOrder(uint _price, uint _amount) external {
        require(msg.sender == seller, "Only the seller can perform this action.");
        require(orders.length < MAX_ORDERS, "The maximum number of orders should not have already been reached.");
        require(token.transferFrom(msg.sender, address(this), _amount));
        orders.push(Order({price: _price, amount: _amount}));
    }

    /** @dev Increase the amount of an order.
     *  @param _orderID The ID of the order to increase the amount.
     *  @param _amount The amount of tokens to add to the total amount in basic units.
     */
    function increaseAmount(uint _orderID, uint _amount) external {
        require(msg.sender == seller, "Only the seller can perform this action.");
        require(token.transferFrom(msg.sender, address(this), _amount));
        orders[_orderID].amount = orders[_orderID].amount.add(_amount);
    }

    /** @dev Decrease the amount of an order.
     *  @param _orderID The ID of the order to decrease the amount.
     *  @param _amount The amount of tokens to remove from the total amount in base units. If it is higher than the amount, all the tokens will be removed.
     */
    function decreaseAmount(uint _orderID, uint _amount) external {
        require(msg.sender == seller, "Only the seller can perform this action.");
        uint amountToDecrease = orders[_orderID].amount < _amount ? orders[_orderID].amount : _amount;
        require(token.transfer(seller, amountToDecrease));
        orders[_orderID].amount = orders[_orderID].amount.sub(amountToDecrease);
    }

    /** @dev Remove an order.
     *  @param _orderID The ID of the order to remove.
     */
    function removeOrder(uint _orderID) external {
        require(msg.sender == seller, "Only the seller can perform this action.");
        require(token.transfer(seller, orders[_orderID].amount));
        orders[_orderID] = orders[orders.length - 1];
        --orders.length;
    }

    /** @dev Fallback function automatically buys all it can, no matter the price.
     */
    function () external payable {
        buy(MAX_VALUE);
    }

    /* Public */

    /** @dev Buy all the tokens possible at _maxPrice or lower.
     *  This function is in O(n²), where n is the amount of orders.
     *  @param _maxPrice Maximum price to pay.
     */
    function buy(uint _maxPrice) public payable {
        uint remainingETH  = msg.value;
        uint cheapestOrder = findCheapestOrder();
        uint tokensBought;

        while(remainingETH!=0 && cheapestOrder!=NO_ORDER_FOUND && orders[cheapestOrder].price<=_maxPrice) { // Check if there is an order to take. Note that this will never revert due to short-circuit evaluation rules.
            uint fullOrderValue = orders[cheapestOrder].price.mul(orders[cheapestOrder].amount).div(divisor);
            if (fullOrderValue <= remainingETH) { // Take the whole order.
                tokensBought = tokensBought.add(orders[cheapestOrder].amount);
                remainingETH = remainingETH.sub(fullOrderValue);
                orders[cheapestOrder].amount = 0;
                cheapestOrder = findCheapestOrder();
            } else { // Take the whole buy.
                uint amountBought = remainingETH.mul(divisor).div(orders[cheapestOrder].price);
                tokensBought = tokensBought.add(amountBought);
                orders[cheapestOrder].amount = orders[cheapestOrder].amount.sub(amountBought);
                remainingETH = 0;
            }

        }

        require(token.transfer(msg.sender, tokensBought));
        emit TokenPurchase(msg.sender, tokensBought);
        if (remainingETH != 0)
            msg.sender.transfer(remainingETH); // Send back the ETH not used.
        seller.transfer(address(this).balance); // Send the ETH to the seller.
    }


    /* Views */

    /** @dev Find the cheapest order. This function is in O(n), where n is the amount of orders.
     *  @return _orderID The ID of the cheapest order. NO_ORDER_FOUND if there are no orders.
     */
    function findCheapestOrder() public view returns (uint _orderID) {
        uint bestPrice = MAX_VALUE;
        _orderID = NO_ORDER_FOUND;

        for (uint i = 0; i < orders.length; ++i) {
            if (orders[i].price<bestPrice && orders[i].amount!=0) {
                bestPrice = orders[i].price;
                _orderID = i;
            }
        }
    }

    /** @dev Fetch all open order IDs. This function is O(n) where n is the amount of orders.
     *  @return _orderIDs The IDs of all open orders.
     */
    function getOpenOrders() external view returns (uint[] memory orderIDs) {
      uint orderCount = 0;
      for (uint i = 0; i < orders.length; i++) {
        if (orders[i].amount > 0)
          orderCount++;
      }

      orderIDs = new uint[](orderCount);
      uint counter = 0;
      for (uint j = 0; j < orders.length; j++) {
        if (orders[j].amount > 0) {
          orderIDs[counter] = j;
          counter++;
        }
      }
    }
}