/**

 *Submitted for verification at Etherscan.io on 2018-09-30

*/



pragma solidity ^0.4.24;



/**

 * @title SafeMath

 * @dev Math operations with safety checks that throw on error

 */







contract MultiEthSender {



    using SafeMath for uint256;



    event Send(uint256 _amount, address indexed _receiver);



    modifier enoughBalance(uint256 amount, address[] list) {

        uint256 totalAmount = amount.mul(list.length);

        require(address(this).balance >= totalAmount);

        _;

    }



    constructor() public {



    }



    function () public payable {

        require(msg.value >= 0);

    }



    function multiSendEth(uint256 amount, address[] list)

    enoughBalance(amount, list)

    public

    returns (bool) 

    {

        for (uint256 i = 0; i < list.length; i++) {

            address(list[i]).transfer(amount);

            emit Send(amount, address(list[i]));

        }

        return true;

    }

}