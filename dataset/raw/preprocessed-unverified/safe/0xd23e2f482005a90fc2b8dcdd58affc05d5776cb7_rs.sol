/**

 *Submitted for verification at Etherscan.io on 2019-04-10

*/



pragma solidity ^0.5.3;







contract RelayRegistry is Ownable {

    

    event AddedRelay(address relay);

    event RemovedRelay(address relay);

    

    mapping (address => bool) public relays;

    

    constructor(address initialRelay) public {

        relays[initialRelay] = true;

    }

    

    function triggerRelay(address relay, bool value) onlyOwner public returns (bool) {

        relays[relay] = value;

        if(value) {

            emit AddedRelay(relay);

        } else {

            emit RemovedRelay(relay);

        }

        return true;

    }

    

}