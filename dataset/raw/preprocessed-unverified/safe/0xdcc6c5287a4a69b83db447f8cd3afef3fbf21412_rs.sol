/**

 *Submitted for verification at Etherscan.io on 2018-11-01

*/



// Copyright (c) 2018, Jack Parkinson. All rights reserved.

// Use of this source code is governed by the BSD 3-Clause

// license that can be found in the LICENSE file at

// github.com/parkinsonj/exchangeth/blob/master/LICENSE



pragma solidity ^0.4.24;







contract Exchangeth {

    using Orders for Orders.Orderbook;

    

    Orders.Orderbook private orderbook;

    uint256 private constant UINT256_MAX = ~uint256(0);



    event OpenedOrder(uint256 indexed id, address indexed by);

	event ClosedOrder(uint256 indexed id, address indexed by);

	event CancelledOrder(uint256 indexed id, address indexed by);

    event UpdatedOrder(uint256 indexed id, address indexed by);

    

    modifier onlyMaker(uint256 _id) {

        require(msg.sender == orderbook.makers[_id], "");

        _;

    }    



	function make(

        address _tokenOffered,

        uint256 _valueOffered,

        address _tokenWanted,

        uint256 _valueWanted,

        uint256 _expiry

    )

        external

        returns (uint256)

    {

        uint256 id = orderbook.createOrder(msg.sender, _tokenOffered, _valueOffered, _tokenWanted, _valueWanted, _expiry);

        emit OpenedOrder(id, msg.sender);

        return id;

	}

    

	function take(uint256 _id) external {

        (Orders.Order memory o, address maker) = orderbook.getOrderAndMaker(_id);



        if (o.expiry > 0) { require(o.expiry > block.timestamp); }



        orderbook.removeOrder(_id);

        transferFrom(o.tokenWanted, msg.sender, maker, o.valueWanted);

        transferFrom(o.tokenOffered, maker, msg.sender, o.valueOffered);



		emit ClosedOrder(_id, msg.sender);

	}



	function cancel(uint256 _id) external onlyMaker(_id) {

        orderbook.removeOrder(_id);

		emit CancelledOrder(_id, msg.sender);

	}



    function update(

        uint256 _id,

        address _tokenOffered,

        uint256 _valueOffered,

        address _tokenWanted,

        uint256 _valueWanted,

        uint256 _expiry

    )

        external

        onlyMaker(_id)

    {

        orderbook.updateOrder(_id, _tokenOffered, _valueOffered, _tokenWanted, _valueWanted, _expiry);

        emit UpdatedOrder(_id, msg.sender);

    }



    function ids() external view returns (uint256[] memory) {

        return orderbook.ids;

    }



    function order(uint256 _id) external view returns (address, address, uint256, address, uint256, uint256) {

        (Orders.Order memory o, address maker) = orderbook.getOrderAndMaker(_id);

        return (maker, o.tokenOffered, o.valueOffered, o.tokenWanted, o.valueWanted, o.expiry);

    }



    function transferFrom(address _token, address _from, address _to, uint256 _val) private {

        bytes memory encoded = abi.encodeWithSignature("transferFrom(address,address,uint256)", _from, _to, _val);

        bool success;

        bool result;

        assembly {

            let data := add(0x20, encoded)

            let size := mload(encoded)

            success := call(

                gas,

                _token,

                0,

                data,

                size,

                data,

                0x20

            )

            result := mload(data)

        }

        require(success && result, "Token transfer failed.");

    }    

}