// SPDX-License-Identifier: MIT

pragma solidity 0.6.12;


// 
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


// 


// 
/**
 * @title WineTrade
 */
contract WineTrader {
    using SafeMath for uint256;
    // Wine token.
    IGRAPWine GRAPWine;
    address payable public dev;

    // Info of each order.
    struct WineOrderInfo {
        address payable owner; // owner
        uint256 price; // price 
        uint256 wineID; // wineID
        bool isOpen; // open order
    }

    // Info of each order list.
    WineOrderInfo[] public orderList;

    uint256 private _currentOrderID = 0;

    event Order(uint256 indexed orderID, address indexed user, uint256 indexed wid, uint256 price);
    event Cancel(uint256 indexed orderID, address indexed user, uint256 indexed wid);
    event Buy(uint256 indexed orderID, address indexed user, uint256 indexed wid);

    constructor(
        IGRAPWine _GRAPWine
    ) public {
        GRAPWine = _GRAPWine;
        dev = msg.sender;
        orderList.push(WineOrderInfo({
            owner: address(0),
            price: 0,
            wineID: 0,
            isOpen: false
        }));
    }

    function withdrawFee() external {
        require(msg.sender == dev, "only dev");
        dev.transfer(address(this).balance);
    }

    function orderWine(uint256 _wineID, uint256 _price) external {
        // transferFrom
        GRAPWine.safeTransferFrom(msg.sender, address(this), _wineID, 1, "");

        orderList.push(WineOrderInfo({
            owner: msg.sender,
            price: _price,
            wineID: _wineID,
            isOpen: true
        }));

        uint256 _id = _getNextOrderID();
        _incrementOrderId();

        emit Order(_id, msg.sender, _wineID, _price);

    }

    function cancel(uint256 orderID) external {
        WineOrderInfo storage orderInfo = orderList[orderID];
        require(orderInfo.owner == msg.sender, "not your order");
        require(orderInfo.isOpen == true, "only open order can be cancel");

        orderInfo.isOpen = false;

        // transferFrom
        GRAPWine.safeTransferFrom(address(this), msg.sender, orderInfo.wineID, 1, "");

        emit Cancel(orderID, msg.sender, orderInfo.wineID);

    }

    function buyWine(uint256 orderID) external payable {
        WineOrderInfo storage orderInfo = orderList[orderID];
        require(orderInfo.owner != address(0),"bad address");
        require(orderInfo.owner != msg.sender, "it is your order");
        require(orderInfo.isOpen == true, "only open order can buy");
        require(msg.value == orderInfo.price, "error price");

        // 3% fee
        uint256 sellerValue = msg.value.mul(97).div(100);
        orderInfo.isOpen = false;

        // transferFrom
        GRAPWine.safeTransferFrom(address(this), msg.sender, orderInfo.wineID, 1, "");
        orderInfo.owner.transfer(sellerValue);
        emit Buy(orderID, msg.sender, orderInfo.wineID);
    }

	function _getNextOrderID() private view returns (uint256) {
		return _currentOrderID.add(1);
	}
	function _incrementOrderId() private {
		_currentOrderID++;
	}

    function onERC1155Received(address _operator, address _from, uint256 _id, uint256 _value, bytes calldata _data) external returns(bytes4){
        return bytes4(keccak256("onERC1155Received(address,address,uint256,uint256,bytes)"));
    }
}