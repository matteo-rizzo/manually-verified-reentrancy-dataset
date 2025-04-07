/**

 *Submitted for verification at Etherscan.io on 2019-01-18

*/



pragma solidity ^0.4.24;

// produced by the Solididy File Flattener (c) David Appleton 2018

// contact : [emailÂ protected]

// released under Apache 2.0 licence

// input  /home/zoom/prg/melon-token/contracts/Alchemist.sol

// flattened :  Friday, 18-Jan-19 18:31:02 UTC





contract Alchemist {

    address public LEAD;

    address public GOLD;



    constructor(address _lead, address _gold) {

        LEAD = _lead;

        GOLD = _gold;

    }



    function transmute(uint _mass) {

        require(

            IERC20(LEAD).transferFrom(msg.sender, address(this), _mass),

            "LEAD transfer failed"

        );

        require(

            IERC20(GOLD).transfer(msg.sender, _mass),

            "GOLD transfer failed"

        );

    }

}