/**

 *Submitted for verification at Etherscan.io on 2019-06-13

*/



pragma solidity ^0.5.0;

pragma experimental ABIEncoderV2;



/**

 * @title ERC20 interface

 * @dev see https://github.com/ethereum/EIPs/issues/20

 */





/**

 * @title Ownable

 * @dev The Ownable contract has an owner address, and provides basic authorization control

 * functions, this simplifies the implementation of "user permissions".

 */

















contract AirDrop is Ownable {

    IERC20 private token;



    struct AirDropItem {

        address beneficiary;

        uint amount;

    }



    constructor(IERC20 _token) public {

        token = _token;

    }



    function distribute(AirDropItem[] memory items) public {

        for (uint i = 0; i < items.length; i++) {

            AirDropItem memory item = items[i];

            require(token.transfer(item.beneficiary, item.amount));

        }

    }

}