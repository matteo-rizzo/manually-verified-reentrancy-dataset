/**

 *Submitted for verification at Etherscan.io on 2018-09-27

*/



pragma solidity ^0.4.23;



/**

 * @title SafeMath

 * @dev Math operations with safety checks that revert on error

 */





contract MultiEthSender {

    using SafeMath for uint256;

    address public owner;



    event Send(uint256 _amount, address indexed _receiver);



    modifier onlyOwner () {

        if (msg.sender == owner) _;

    }



    constructor () public {

        owner = msg.sender;

    }



    function multiSendEth(uint256 amount, address[] list) public payable onlyOwner returns (bool) {

        uint256 balance = address(this).balance;

        uint256 total = amount.mul(uint256(list.length));

        if (total > balance) {

            return false;

        }

        for (uint i = 0; i < list.length; i++) {

            list[i].transfer(amount);

            // emit Send(amount, list[i]);

            // another way to write log

            bytes32 _id = 0x5ce4017cdf5be6a02f39ba5d91777cf13a304b9e024d038bca26189d148feeb9;

            log2(

                bytes32(amount),

                _id,

                bytes32(list[i])

            );

        }

        return true;

    }



    function () public payable {}

}