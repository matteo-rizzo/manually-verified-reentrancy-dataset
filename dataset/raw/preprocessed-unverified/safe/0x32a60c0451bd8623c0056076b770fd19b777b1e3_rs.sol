/**

 *Submitted for verification at Etherscan.io on 2019-01-24

*/



pragma solidity 0.5.2;



// File: openzeppelin-solidity/contracts/math/SafeMath.sol



/**

 * @title SafeMath

 * @dev Unsigned math operations with safety checks that revert on error

 */





// File: contracts/Dividend.sol



contract Dividend {

    using SafeMath for uint;



    address payable public addr1 = 0x2b339Ebdd12d6f79aA18ed2A032ebFE1FA4Faf45;

    address payable public addr2 = 0x4BB515b7443969f7eb519d175e209aE8Af3601C1;



    event LogPayment(

        address indexed from,

        address indexed to,

        uint amount,

        uint total

    );



    // NOTE: Transfer of block reward (coinbase) does not invoke this function

    function () external payable {

        // 80 % to address 1, remaining to address 2

        uint amount1 = msg.value.mul(8).div(10);

        uint amount2 = msg.value.sub(amount1);



        // WARNING: transfer will fail if it uses more than 2300 gas

        addr1.transfer(amount1);

        addr2.transfer(amount2);



        emit LogPayment(msg.sender, addr1, amount1, msg.value);

        emit LogPayment(msg.sender, addr2, amount2, msg.value);

    }

}