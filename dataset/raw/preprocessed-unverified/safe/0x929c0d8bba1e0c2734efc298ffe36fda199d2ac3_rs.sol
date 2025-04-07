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



    uint constant WAD = 10 ** 18;

    uint constant RAY = 10 ** 27;



    function rmul(uint x, uint y) internal pure returns (uint z) {

        z = add(mul(x, y), RAY / 2) / RAY;

    }



    function rdiv(uint x, uint y) internal pure returns (uint z) {

        z = add(mul(x, RAY), y / 2) / y;

    }



    function wdiv(uint x, uint y) internal pure returns (uint z) {

        z = add(mul(x, WAD), y / 2) / y;

    }



}





contract WipeProxy is DSMath {



    function wipeWithDai(

        address _tub,

        address _daiEx,

        address _mkrEx,

        uint cupid,

        uint wad

    ) public 

    {

        require(wad > 0, "no-wipe-no-dai");



        TubLike tub = TubLike(_tub);

        UniswapExchangeLike daiEx = UniswapExchangeLike(_daiEx);

        UniswapExchangeLike mkrEx = UniswapExchangeLike(_mkrEx);

        TokenLike dai = tub.sai();

        TokenLike mkr = tub.gov();

        PepLike pep = tub.pep();



        bytes32 cup = bytes32(cupid);



        setAllowance(dai, _tub);

        setAllowance(mkr, _tub);

        setAllowance(dai, _daiEx);



        (bytes32 val, bool ok) = pep.peek();



        // MKR required for wipe = Stability fees accrued in Dai / MKRUSD value

        uint mkrFee = wdiv(rmul(wad, rdiv(tub.rap(cup), tub.tab(cup))), uint(val));



        uint ethAmt = mkrEx.getEthToTokenOutputPrice(mkrFee);

        uint daiAmt = daiEx.getTokenToEthOutputPrice(ethAmt);



        daiAmt = add(wad, daiAmt);

        require(dai.transferFrom(msg.sender, address(this), daiAmt), "not-approved-yet");



        if (ok && val != 0) {

            daiEx.tokenToTokenSwapOutput(

                mkrFee,

                daiAmt,

                uint(999000000000000000000),

                uint(1645118771), // 17 feb

                address(mkr)

            );

        }



        tub.wipe(cup, wad);

    }



    function setAllowance(TokenLike token_, address spender_) private {

        if (token_.allowance(address(this), spender_) != uint(-1)) {

            token_.approve(spender_, uint(-1));

        }

    }



}