/**
 *Submitted for verification at Etherscan.io on 2020-06-12
*/

pragma solidity ^0.6.0;






/**
 * @title Crowdsale
 */
contract FakePlinc is IDistributable {

    address payable owner;
    constructor() public {
        owner = msg.sender;
    }
    /**
        @dev Called by contracts to distribute dividends
        Updates the bond value
    */
    function distribute() external payable override {
        owner.transfer(msg.value);
    }
}