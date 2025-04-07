/**

 *Submitted for verification at Etherscan.io on 2019-01-04

*/



pragma solidity ^0.4.23;







contract SponsorHelper {

    TrueUSD public trueUSD = TrueUSD(0x0000000000085d4780B73119b644AE5ecd22b376);

    

    function sponsorGas() external {

        trueUSD.sponsorGas();

    }

}