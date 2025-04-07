/**

 *Submitted for verification at Etherscan.io on 2019-05-12

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





contract Helpers is DSMath {



    /**

     * @dev get MakerDAO CDP engine

     */

    function getSaiTubAddress() public pure returns (address sai) {

        sai = 0x448a5065aeBB8E423F0896E6c5D525C040f59af3;

    }



    /**

     * @dev get uniswap MKR exchange

     */

    function getUniswapMKRExchange() public pure returns (address ume) {

        ume = 0x2C4Bd064b998838076fa341A83d007FC2FA50957;

    }



    /**

     * @dev get uniswap DAI exchange

     */

    function getUniswapDAIExchange() public pure returns (address ude) {

        ude = 0x09cabEC1eAd1c0Ba254B09efb3EE13841712bE14;

    }



    /**

     * @dev get CDP bytes by CDP ID

     */

    function getCDPBytes(uint cdpNum) public pure returns (bytes32 cup) {

        cup = bytes32(cdpNum);

    }



}





contract CDPResolver is Helpers {



    event LogOpen(uint cdpNum, address owner);

    event LogGive(uint cdpNum, address owner, address nextOwner);

    event LogLock(uint cdpNum, uint amtETH, uint amtPETH, address owner);

    event LogFree(uint cdpNum, uint amtETH, uint amtPETH, address owner);

    event LogDraw(uint cdpNum, uint amtDAI, address owner);

    event LogDrawSend(uint cdpNum, uint amtDAI, address to);

    event LogWipe(uint cdpNum, uint daiAmt, uint mkrFee, uint daiFee, address owner);

    event LogShut(uint cdpNum);



    function open() public returns (uint) {

        bytes32 cup = TubInterface(getSaiTubAddress()).open();

        emit LogOpen(uint(cup), address(this));

        return uint(cup);

    }



    /**

     * @dev transfer CDP ownership

     */

    function give(uint cdpNum, address nextOwner) public {

        TubInterface(getSaiTubAddress()).give(bytes32(cdpNum), nextOwner);

        emit LogGive(cdpNum, address(this), nextOwner);

    }



    function lock(uint cdpNum) public payable {

        if (msg.value > 0) {

            bytes32 cup = bytes32(cdpNum);

            address tubAddr = getSaiTubAddress();



            TubInterface tub = TubInterface(tubAddr);

            TokenInterface weth = tub.gem();

            TokenInterface peth = tub.skr();



            (address lad,,,) = tub.cups(cup);

            require(lad == address(this), "cup-not-owned");



            weth.deposit.value(msg.value)();



            uint ink = rdiv(msg.value, tub.per());

            ink = rmul(ink, tub.per()) <= msg.value ? ink : ink - 1;



            setAllowance(weth, tubAddr);

            tub.join(ink);



            setAllowance(peth, tubAddr);

            tub.lock(cup, ink);



            emit LogLock(

                cdpNum,

                msg.value,

                ink,

                address(this)

            );

        }

    }



    function free(uint cdpNum, uint jam) public {

        if (jam > 0) {

            bytes32 cup = bytes32(cdpNum);

            address tubAddr = getSaiTubAddress();



            TubInterface tub = TubInterface(tubAddr);

            TokenInterface peth = tub.skr();

            TokenInterface weth = tub.gem();



            uint ink = rdiv(jam, tub.per());

            ink = rmul(ink, tub.per()) <= jam ? ink : ink - 1;

            tub.free(cup, ink);



            setAllowance(peth, tubAddr);



            tub.exit(ink);

            uint freeJam = weth.balanceOf(address(this)); // withdraw possible previous stuck WETH as well

            weth.withdraw(freeJam);



            address(msg.sender).transfer(freeJam);



            emit LogFree(

                cdpNum,

                freeJam,

                ink,

                address(this)

            );

        }

    }



    function draw(uint cdpNum, uint _wad) public {

        bytes32 cup = bytes32(cdpNum);

        if (_wad > 0) {

            TubInterface tub = TubInterface(getSaiTubAddress());



            tub.draw(cup, _wad);

            tub.sai().transfer(msg.sender, _wad);



            emit LogDraw(cdpNum, _wad, address(this));

        }

    }



    function drawSend(uint cdpNum, uint _wad, address to) public {

        require(to != address(0x0), "address-not-valid");

        bytes32 cup = bytes32(cdpNum);

        if (_wad > 0) {

            TubInterface tub = TubInterface(getSaiTubAddress());



            tub.draw(cup, _wad);

            tub.sai().transfer(to, _wad);



            emit LogDraw(cdpNum, _wad, address(this));

            emit LogDrawSend(cdpNum, _wad, to);

        }

    }



    function wipe(uint cdpNum, uint _wad) public {

        if (_wad > 0) {

            TubInterface tub = TubInterface(getSaiTubAddress());

            UniswapExchange daiEx = UniswapExchange(getUniswapDAIExchange());

            UniswapExchange mkrEx = UniswapExchange(getUniswapMKRExchange());

            TokenInterface dai = tub.sai();

            TokenInterface mkr = tub.gov();



            bytes32 cup = bytes32(cdpNum);



            (address lad,,,) = tub.cups(cup);

            require(lad == address(this), "cup-not-owned");



            setAllowance(dai, getSaiTubAddress());

            setAllowance(mkr, getSaiTubAddress());

            setAllowance(dai, getUniswapDAIExchange());



            (bytes32 val, bool ok) = tub.pep().peek();



            // MKR required for wipe = Stability fees accrued in Dai / MKRUSD value

            uint mkrFee = wdiv(rmul(_wad, rdiv(tub.rap(cup), tub.tab(cup))), uint(val));



            uint daiFeeAmt = daiEx.getTokenToEthOutputPrice(mkrEx.getEthToTokenOutputPrice(mkrFee));

            uint daiAmt = add(_wad, daiFeeAmt);

            require(dai.transferFrom(msg.sender, address(this), daiAmt), "not-approved-yet");



            if (ok && val != 0) {

                daiEx.tokenToTokenSwapOutput(

                    mkrFee,

                    daiAmt,

                    uint(999000000000000000000),

                    uint(1899063809), // 6th March 2030 GMT // no logic

                    address(mkr)

                );

            }



            tub.wipe(cup, _wad);



            emit LogWipe(

                cdpNum,

                daiAmt,

                mkrFee,

                daiFeeAmt,

                address(this)

            );



        }

    }



    function setAllowance(TokenInterface _token, address _spender) private {

        if (_token.allowance(address(this), _spender) != uint(-1)) {

            _token.approve(_spender, uint(-1));

        }

    }



}





contract CDPCluster is CDPResolver {



    function wipeAndFree(uint cdpNum, uint jam, uint _wad) public payable {

        wipe(cdpNum, _wad);

        free(cdpNum, jam);

    }



    /**

     * @dev close CDP

     */

    function shut(uint cdpNum) public {

        bytes32 cup = bytes32(cdpNum);

        TubInterface tub = TubInterface(getSaiTubAddress());

        wipeAndFree(cdpNum, rmul(tub.ink(cup), tub.per()), tub.tab(cup));

        tub.shut(cup);

        emit LogShut(cdpNum); // fetch remaining data from WIPE & FREE events

    }



    /**

     * @dev open a new CDP and lock ETH

     */

    function openAndLock() public payable returns (uint cdpNum) {

        cdpNum = open();

        lock(cdpNum);

    }



}





contract InstaMaker is CDPCluster {



    uint public version;



    /**

     * @dev setting up variables on deployment

     * 1...2...3 versioning in each subsequent deployments

     */

    constructor(uint _version) public {

        version = _version;

    }



    function() external payable {}



}