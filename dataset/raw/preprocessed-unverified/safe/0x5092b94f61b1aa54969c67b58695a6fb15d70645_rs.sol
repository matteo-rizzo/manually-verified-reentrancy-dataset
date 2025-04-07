/**
 *Submitted for verification at Etherscan.io on 2019-11-18
*/

pragma solidity ^0.5.8;
pragma experimental ABIEncoderV2;




















contract DSMath {

    function add(uint x, uint y) internal pure returns (uint z) {
        require((z = x + y) >= x, "math-not-safe");
    }

    function sub(uint x, uint y) internal pure returns (uint z) {
        z = x - y <= x ? x - y : 0;
    }

    function mul(uint x, uint y) internal pure returns (uint z) {
        require(y == 0 || (z = x * y) / y == x, "math-not-safe");
    }

    uint constant WAD = 10 ** 18;
    uint constant RAY = 10 ** 27;

    function rmul(uint x, uint y) internal pure returns (uint z) {
        z = add(mul(x, y), RAY / 2) / RAY;
    }

    function wmul(uint x, uint y) internal pure returns (uint z) {
        z = add(mul(x, y), WAD / 2) / WAD;
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
     * @dev get MakerDAO MCD Address contract
     */
    function getMcdAddresses() public pure returns (address mcd) {
        mcd = 0xF23196DF1C440345DE07feFbe556a5eF0dcD29F0; 
    }

    /**
     * @dev get OTC Address
     */
    function getOtcAddress() public pure returns (address otcAddr) {
        otcAddr = 0x39755357759cE0d7f32dC8dC45414CCa409AE24e; // main
    }

    address public mkrAddr = 0x39755357759cE0d7f32dC8dC45414CCa409AE24e; 

    struct CdpData {
        uint id;
        address owner;
        bytes32 ilk;
        uint ink;
        uint art;
        uint debt;
        uint stabiltyRate;
        uint price;
        uint liqRatio;
        address urn;
    }

}


contract McdResolver is Helpers {
    function getDsr() external view returns (uint dsr) {
        address pot = InstaMcdAddress(getMcdAddresses()).pot();
        dsr = PotLike(pot).dsr();
    }

    function getDaiDeposited(address owner) external view returns (uint amt) {
        address pot = InstaMcdAddress(getMcdAddresses()).pot();
        uint chi = PotLike(pot).chi();
        uint pie = PotLike(pot).pie(owner);
        amt = rmul(pie,chi);
    }

    function getCdpsByAddress(address owner) external view returns (CdpData[] memory) {
        (uint[] memory ids, address[] memory urns, bytes32[] memory ilks) = CdpsLike(InstaMcdAddress(getMcdAddresses()).getCdps()).getCdpsAsc(InstaMcdAddress(getMcdAddresses()).manager(), owner);
        CdpData[] memory cdps = new CdpData[](ids.length);

        for (uint i = 0; i < ids.length; i++) {
            (uint ink, uint art) = VatLike(ManagerLike(InstaMcdAddress(getMcdAddresses()).manager()).vat()).urns(ilks[i], urns[i]);
            (,uint rate, uint priceMargin,,) = VatLike(ManagerLike(InstaMcdAddress(getMcdAddresses()).manager()).vat()).ilks(ilks[i]);
            uint mat = getIlkRatio(ilks[i]);
            uint debt = rmul(art,rate);
            uint price = rmul(priceMargin, mat);

            cdps[i] = CdpData(
                ids[i],
                owner,
                ilks[i],
                ink,
                art,
                debt,
                getFee(ilks[i]),
                price,
                mat,
                urns[i]
            );
        }
        return cdps;
    }

    function getCdpsById(uint id) external view returns (CdpData memory) {
        address urn = ManagerLike(InstaMcdAddress(getMcdAddresses()).manager()).urns(id);
        bytes32 ilk = ManagerLike(InstaMcdAddress(getMcdAddresses()).manager()).ilks(id);
        address owner = ManagerLike(InstaMcdAddress(getMcdAddresses()).manager()).owns(id);

        (uint ink, uint art) = VatLike(ManagerLike(InstaMcdAddress(getMcdAddresses()).manager()).vat()).urns(ilk, urn);
        (,uint rate, uint priceMargin,,) = VatLike(ManagerLike(InstaMcdAddress(getMcdAddresses()).manager()).vat()).ilks(ilk);
        uint debt = rmul(art,rate);

        uint mat = getIlkRatio(ilk);
        uint price = rmul(priceMargin, mat);

        uint feeRate = getFee(ilk);
        CdpData memory cdp = CdpData(
            id,
            owner,
            ilk,
            ink,
            art,
            debt,
            feeRate,
            price,
            mat,
            urn
        );
        return cdp;
    }

    function getFee(bytes32 ilk) public view returns (uint fee) {
        address jug = InstaMcdAddress(getMcdAddresses()).jug();
        (uint duty,) = JugLike(jug).ilks(ilk);
        uint base = JugLike(jug).base();
        fee = add(duty, base);
    }

    function getIlkPrice(bytes32 ilk) public view returns (uint price) {
        address spot = InstaMcdAddress(getMcdAddresses()).spot();
        address vat = InstaMcdAddress(getMcdAddresses()).vat();
        (, uint mat) = SpotLike(spot).ilks(ilk);
        (,,uint spotPrice,,) = VatLike(vat).ilks(ilk);
        price = rmul(mat, spotPrice);
    }

    function getIlkRatio(bytes32 ilk) public view returns (uint ratio) {
        address spot = InstaMcdAddress(getMcdAddresses()).spot();
        (, ratio) = SpotLike(spot).ilks(ilk);
    }

    function getMkrToTknAmt(address tokenAddr, uint mkrAmt) public view returns (uint tknAmt) {
        tknAmt = OtcInterface(getOtcAddress()).getPayAmount(tokenAddr, address(mkrAddr), mkrAmt);
    }
}