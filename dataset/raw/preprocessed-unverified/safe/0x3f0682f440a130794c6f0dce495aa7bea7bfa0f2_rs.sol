/**

 *Submitted for verification at Etherscan.io on 2018-11-26

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



    using SafeMath for uint;

    using SafeMath for uint256;



    event KyberTrade(

        address src,

        uint srcAmt,

        address dest,

        uint destAmt,

        address beneficiary,

        uint minConversionRate,

        address affiliate

    );



    function getExpectedPrice(

        address src,

        address dest,

        uint srcAmt

    ) public view returns (uint, uint) 

    {

        Kyber kyberFunctions = Kyber(getAddress("kyber"));

        return kyberFunctions.getExpectedRate(

            src,

            dest,

            srcAmt

        );

    }



    function approveKyber(address[] tokenArr) public {

        address kyberProxy = getAddress("kyber");

        for (uint i = 0; i < tokenArr.length; i++) {

            IERC20 tokenFunctions = IERC20(tokenArr[i]);

            tokenFunctions.approve(kyberProxy, 2**256 - 1);

        }

    }



    function executeTrade(

        address src, // token to sell

        address dest, // token to buy

        uint srcAmt, // amount of token for sell

        uint minConversionRate, // minimum slippage rate

        uint maxDestAmt // max amount of dest token

    ) public payable returns (uint destAmt)

    {



        address eth = getAddress("eth");

        uint ethQty = getToken(

            msg.sender,

            src,

            srcAmt,

            eth

        );

        

        // Interacting with Kyber Proxy Contract

        Kyber kyberFunctions = Kyber(getAddress("kyber"));

        destAmt = kyberFunctions.trade.value(ethQty)(

            src,

            srcAmt,

            dest,

            msg.sender,

            maxDestAmt,

            minConversionRate,

            getAddress("admin")

        );



        // maxDestAmt usecase implementated

        if (src == eth && address(this).balance > 0) {

            msg.sender.transfer(address(this).balance);

        } else if (src != eth) { // as there is no balanceOf of eth

            IERC20 srcTkn = IERC20(src);

            uint srcBal = srcTkn.balanceOf(address(this));

            if (srcBal > 0) {

                srcTkn.transfer(msg.sender, srcBal);

            }

        }



        emit KyberTrade(

            src,

            srcAmt,

            dest,

            destAmt,

            msg.sender,

            minConversionRate,

            getAddress("admin")

        );



    }



    function getToken(

        address trader,

        address src,

        uint srcAmt,

        address eth

    ) internal returns (uint ethQty)

    {

        if (src == eth) {

            require(msg.value == srcAmt, "Invalid Operation");

            ethQty = srcAmt;

        } else {

            IERC20 tokenFunctions = IERC20(src);

            tokenFunctions.transferFrom(trader, address(this), srcAmt);

            ethQty = 0;

        }

    }



}





contract InstaKyber is Trade {



    constructor(address rAddr) public {

        addressRegistry = rAddr;

    }



    function () public payable {}



}