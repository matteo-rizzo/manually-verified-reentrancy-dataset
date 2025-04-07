/**

 *Submitted for verification at Etherscan.io on 2018-08-24

*/



pragma solidity ^0.4.24;



// File: openzeppelin-solidity/contracts/math/SafeMath.sol



/**

 * @title SafeMath

 * @dev Math operations with safety checks that throw on error

 */





// File: contracts/Distribute.sol



contract Distribute {



    using SafeMath for SafeMath;



    address public netAddress = 0x88888888c84198BCc5CEb4160d13726F22c151Ab;



    address public otherAddress = 0x8e83D33aB48b110B7C3DF8C6F5D02191aF9b80FD;



    uint proportionA = 94;

    uint proportionB = 6;

    uint base = 100;



    constructor() public {



    }



    function() payable public {

        require(msg.value > 0);



        netAddress.transfer(SafeMath.div(SafeMath.mul(msg.value, proportionA), base));

        otherAddress.transfer(SafeMath.div(SafeMath.mul(msg.value, proportionB), base));



    }





}