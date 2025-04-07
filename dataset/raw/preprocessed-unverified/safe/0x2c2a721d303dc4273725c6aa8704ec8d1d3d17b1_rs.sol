/**

 *Submitted for verification at Etherscan.io on 2018-11-30

*/



pragma solidity ^0.4.24;



// File: contracts/Ownable.sol



/**

 * @title Ownable

 * @dev The Ownable contract has an emitter and administrator addresses, and provides basic authorization control

 * functions, this simplifies the implementation of "user permissions".

 */





// File: contracts/GlitchGoonsProxy.sol



contract GlitchGoonsProxy is Ownable {



    constructor (address _emitter, address _administrator) public {

        setEmitter(_emitter);

        setAdministrator(_administrator);

    }



    function deposit() external payable {

        emitter.transfer(msg.value);

    }



    function transfer(address _to) external payable {

        _to.transfer(msg.value);

    }

}