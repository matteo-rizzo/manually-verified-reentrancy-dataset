/**

 *Submitted for verification at Etherscan.io on 2019-01-11

*/



pragma solidity 0.4.24;











contract UniqueCDP {



    address public deployer;

    address public cdpAddr;



    constructor(address saiTub) public {

        deployer = msg.sender;

        cdpAddr = saiTub;

    }



    function registerCDP(uint maxCup) public {

        MakerCDP loanMaster = MakerCDP(cdpAddr);

        for (uint i = 0; i < maxCup; i++) {

            loanMaster.open();

        }

    }



    function transferCDP(address nextOwner, uint cdpNum) public {

        require(msg.sender == deployer, "Invalid Address.");

        MakerCDP loanMaster = MakerCDP(cdpAddr);

        loanMaster.give(bytes32(cdpNum), nextOwner);

    }



}