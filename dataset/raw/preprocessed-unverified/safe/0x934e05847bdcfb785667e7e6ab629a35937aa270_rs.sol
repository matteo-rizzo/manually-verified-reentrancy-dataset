/**

 *Submitted for verification at Etherscan.io on 2019-03-31

*/



pragma solidity ^0.5.0;

















contract DSMath {



    function add(uint x, uint y) internal pure returns (uint z) {

        require((z = x + y) >= x, "math-not-safe");

    }



    function mul(uint x, uint y) internal pure returns (uint z) {

        require(y == 0 || (z = x * y) / y == x, "math-not-safe");

    }



    uint constant RAY = 10 ** 27;



    function rmul(uint x, uint y) internal pure returns (uint z) {

        z = add(mul(x, y), RAY / 2) / RAY;

    }



    function rdiv(uint x, uint y) internal pure returns (uint z) {

        z = add(mul(x, RAY), y / 2) / y;

    }



}









contract FreeProxy is DSMath {

    

    /**

     * @dev get MakerDAO CDP engine

     */

    function getSaiTubAddress() public pure returns (address sai) {

        sai = 0x448a5065aeBB8E423F0896E6c5D525C040f59af3;

    }



    /**

     * @dev transfer CDP ownership

     */

    function give(uint cdpNum, address nextOwner) public {

        TubInterface(getSaiTubAddress()).give(bytes32(cdpNum), nextOwner);

    }



    function free3(uint cdpNum) public {

        address tubAddr = getSaiTubAddress();

        TubInterface tub = TubInterface(tubAddr);



        uint freeJam = tub.gem().balanceOf(address(this)); // withdraw possible previous stuck WETH as well

        tub.gem().withdraw(freeJam);

        

        address(msg.sender).transfer(freeJam);



    }

    

    function free2(uint ink) public {

        address tubAddr = getSaiTubAddress();

        TubInterface tub = TubInterface(tubAddr);

        TokenInterface peth = tub.skr();



        setAllowance(peth, tubAddr);

            

        tub.exit(ink);



    }



    function free(uint cdpNum, uint jam) public {

        bytes32 cup = bytes32(cdpNum);

        address tubAddr = getSaiTubAddress();

        

        if (jam > 0) {

            

            TubInterface tub = TubInterface(tubAddr);



            uint ink = rdiv(jam, tub.per());

            ink = rmul(ink, tub.per()) <= jam ? ink : ink - 1;

            tub.free(cup, ink);



        }

    }



    function setAllowance(TokenInterface token_, address spender_) private {

        if (token_.allowance(address(this), spender_) != uint(-1)) {

            token_.approve(spender_, uint(-1));

        }

    }



}