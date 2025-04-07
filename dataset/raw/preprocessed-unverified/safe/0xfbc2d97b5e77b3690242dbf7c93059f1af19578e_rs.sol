/**
 *Submitted for verification at Etherscan.io on 2019-08-04
*/

// https://tornado.cash
/*
* d888888P                                           dP              a88888b.                   dP
*    88                                              88             d8'   `88                   88
*    88    .d8888b. 88d888b. 88d888b. .d8888b. .d888b88 .d8888b.    88        .d8888b. .d8888b. 88d888b.
*    88    88'  `88 88'  `88 88'  `88 88'  `88 88'  `88 88'  `88    88        88'  `88 Y8ooooo. 88'  `88
*    88    88.  .88 88       88    88 88.  .88 88.  .88 88.  .88 dP Y8.   .88 88.  .88       88 88    88
*    dP    `88888P' dP       dP    dP `88888P8 `88888P8 `88888P' 88  Y88888P' `88888P8 `88888P' dP    dP
* ooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooo
*/

//
// Copyright 2017 Christian Reitwiessner
// Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
// The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
//
// 2019 OKIMS
//      ported to solidity 0.5
//      fixed linter warnings
//      added requiere error messages
//
pragma solidity ^0.5.0;

contract Verifier {
    using Pairing for *;
    struct VerifyingKey {
        Pairing.G1Point alfa1;
        Pairing.G2Point beta2;
        Pairing.G2Point gamma2;
        Pairing.G2Point delta2;
        Pairing.G1Point[] IC;
    }
    struct Proof {
        Pairing.G1Point A;
        Pairing.G2Point B;
        Pairing.G1Point C;
    }
    function verifyingKey() internal pure returns (VerifyingKey memory vk) {
        vk.alfa1 = Pairing.G1Point(10697319494945080658820934619876978902526628918983433324485742953863059309826,8865335601752296562609769512685969430416597183628621468028843038906591372929);
        vk.beta2 = Pairing.G2Point([10897325502771211941251344379081397986568205664729778087964110883136847751483,14369474593803928641756502476192788474069382043893462862042139666583319796656], [16911338094525001741373210290333624210919704415682712432609199917755936075620,13846287392385938746431061076717340919382366428728698378888815699380430098597]);
        vk.gamma2 = Pairing.G2Point([16572480627857903652649134571846259240278489328289072087327885379085313310982,5684679655781059760393816990519846785036744122092770870278632364548395411260], [10878624161823327824201152956479310862041032220212173595047732055966236184880,8725255241933317873424759710579150820498494057609742989600878086264452446832]);
        vk.delta2 = Pairing.G2Point([10950063518036004550473973503180046259424537931665680570406358196263641403527,5822175195753958478087473710140289572051433221401222077817342693928481375932], [6174689756108975621873115335420030033707039732576585349957196441884785902188,11667507068154489072643109218691043652060619957135224111399900270133391852513]);
        vk.IC = new Pairing.G1Point[](5);
        vk.IC[0] = Pairing.G1Point(20088104823225105093406503701522790749646979399775136826381506770834107141608,17457714165477272337940772917717018301349687350123466265271266469229929837182);
        vk.IC[1] = Pairing.G1Point(11547154182029394986335988102631737777124102637997410316072760082794743637223,6971669241240256707017642282616031174808597680270694068776364887494574200360);
        vk.IC[2] = Pairing.G1Point(10152450038531946420500846768779469990510317848241306714427133206211212221317,12056951672485540553352750462265509936783451816327179101575078945505591992733);
        vk.IC[3] = Pairing.G1Point(21061859113002590569121041117749354769048443669830512646623559391635659051199,271407031246030096393241417035618327445865212511677292161699573021732647532);
        vk.IC[4] = Pairing.G1Point(3731025068928213368623324946001000529383331564142711652590971045456734735145,8043659756103952562764993453436749553805239660405427647618599787132803252564);

    }
    function verify(uint[] memory input, Proof memory proof) internal view returns (uint) {
        uint256 snark_scalar_field = 21888242871839275222246405745257275088548364400416034343698204186575808495617;
        VerifyingKey memory vk = verifyingKey();
        require(input.length + 1 == vk.IC.length,"verifier-bad-input");
        // Compute the linear combination vk_x
        Pairing.G1Point memory vk_x = Pairing.G1Point(0, 0);
        for (uint i = 0; i < input.length; i++) {
            require(input[i] < snark_scalar_field,"verifier-gte-snark-scalar-field");
            vk_x = Pairing.addition(vk_x, Pairing.scalar_mul(vk.IC[i + 1], input[i]));
        }
        vk_x = Pairing.addition(vk_x, vk.IC[0]);
        if (!Pairing.pairingProd4(
            Pairing.negate(proof.A), proof.B,
            vk.alfa1, vk.beta2,
            vk_x, vk.gamma2,
            proof.C, vk.delta2
        )) return 1;
        return 0;
    }
    function verifyProof(
            uint[2] memory a,
            uint[2][2] memory b,
            uint[2] memory c,
            uint[4] memory input
        ) public view returns (bool r) {
        Proof memory proof;
        proof.A = Pairing.G1Point(a[0], a[1]);
        proof.B = Pairing.G2Point([b[0][0], b[0][1]], [b[1][0], b[1][1]]);
        proof.C = Pairing.G1Point(c[0], c[1]);
        uint[] memory inputValues = new uint[](input.length);
        for(uint i = 0; i < input.length; i++){
            inputValues[i] = input[i];
        }
        if (verify(inputValues, proof) == 0) {
            return true;
        } else {
            return false;
        }
    }
}