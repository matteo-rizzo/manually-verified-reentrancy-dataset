/**

 *Submitted for verification at Etherscan.io on 2019-01-26

*/



pragma solidity ^0.4.24;

















contract Registry {

    address public addressRegistry;

    modifier onlyAdmin() {

        require(

            msg.sender == getAddress("admin"),

            "Permission Denied"

        );

        _;

    }

    function getAddress(string name) internal view returns(address) {

        AddressRegistry addrReg = AddressRegistry(addressRegistry);

        return addrReg.getAddr(name);

    }

}





contract Trade is Registry {



    event KyberTrade(

        address src,

        uint srcAmt,

        address dest,

        uint destAmt,

        address beneficiary,

        uint minConversionRate,

        address affiliate

    );



    function approveDAIKyber() public {

        IERC20 tokenFunctions = IERC20(getAddress("dai"));

        tokenFunctions.approve(getAddress("kyber"), 2**255);

    }



    function expectedETH(uint srcDAI) public view returns (uint, uint) {

        Kyber kyberFunctions = Kyber(getAddress("kyber"));

        return kyberFunctions.getExpectedRate(getAddress("dai"), getAddress("eth"), srcDAI);

    }



    function dai2eth(uint srcDAI) public payable returns (uint destAmt) {

        address src = getAddress("dai");

        address dest = getAddress("eth");

        uint minConversionRate;

        (, minConversionRate) = expectedETH(srcDAI);



        // Interacting with Kyber Proxy Contract

        Kyber kyberFunctions = Kyber(getAddress("kyber"));

        destAmt = kyberFunctions.trade.value(msg.value)(

            src,

            srcDAI,

            dest,

            msg.sender,

            2**255,

            minConversionRate,

            getAddress("admin")

        );



        emit KyberTrade(

            src, srcDAI, dest, destAmt, msg.sender, minConversionRate, getAddress("admin")

        );



    }



}





contract DAI2ETH is Trade {



    constructor(address rAddr) public {

        addressRegistry = rAddr;

        approveDAIKyber();

    }



    function () public payable {}



}