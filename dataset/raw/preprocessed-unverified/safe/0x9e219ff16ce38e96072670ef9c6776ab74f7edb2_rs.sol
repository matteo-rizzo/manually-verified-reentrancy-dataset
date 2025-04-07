/**

 *Submitted for verification at Etherscan.io on 2018-09-20

*/



pragma solidity ^0.4.24;



// File: ../node_modules/openzeppelin-solidity/contracts/math/SafeMath.sol



/**

 * @title SafeMath

 * @dev Math operations with safety checks that throw on error

 */





// File: contracts/ETHReceiver.sol



contract ETHReceiver {

    using SafeMath for *;



    uint public balance_;

    address public owner_;



    event ReceivedValue(address indexed from, uint value);

    event Withdraw(address indexed from, uint amount);

    event ChangeOwner(address indexed from, address indexed to);



    constructor ()

        public

    {

        balance_ = 0;

        owner_ = msg.sender;

    }



    modifier onlyOwner

    {

        require(msg.sender == owner_, "msg sender is not contract owner");

        _;

    }



    function ()

        public

        payable

    {

        balance_ = (balance_).add(msg.value);

        emit ReceivedValue(msg.sender, msg.value);

    }



    function transferTo (address _to, uint _amount)

        public

        onlyOwner()

    {

        _to.transfer(_amount);

        balance_ = (balance_).sub(_amount);

        emit Withdraw(_to, _amount);

    }



    function changeOwner (address _to)

        public

        onlyOwner()

    {

        assert(_to != address(0));

        owner_ = _to;

        emit ChangeOwner(msg.sender, _to);

    }

}