/**
 *Submitted for verification at Etherscan.io on 2019-12-25
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
        vk.alfa1 = Pairing.G1Point(14083060544450230494753274689662527554173093259052677053963403611543108812248,4706358536309759497515629700429717613728395864036029914779603000183617648928);
        vk.beta2 = Pairing.G2Point([16219376067261068540504773162427353135531573767414264044630641576986412148841,11226478626154379929692040045672180496625001440073645894895473453499733630608], [8662043286651336594833933468521973267084981586202736778519782026658563113819,5942204661444759280424140647067377540347290706910798648472025938632189112985]);
        vk.gamma2 = Pairing.G2Point([5626774539960215411062721749577193079747643943552704413404404262438418256316,9019372327661379039595737818991664049719738650451402651660959581913338994854], [21092692879600416126570996361460322936290640865421745471798870901476359011654,9562621902064186952244630067028615031672773927765582067796589601830914136863]);
        vk.delta2 = Pairing.G2Point([15895226675259918394214944850094992600763639881245050921639726020135193652688,8066794343152224768444030087741836548721200404739800154831732767644473461476], [2091512572979570673813987427579756573526730039480975604103592522881026646949,15957537187230612698014796603169934934345666788241949100809795704331873734963]);
        vk.IC = new Pairing.G1Point[](7);
        vk.IC[0] = Pairing.G1Point(14112255618296752664987088318060807163751325065279686739401083407169811107624,12125289624680902628733420759546824791467428117812768926606015515391099666551);
        vk.IC[1] = Pairing.G1Point(9950061763761971651364890451617100497514634553916860166198204152844612131077,21535612280842336626995215571028050552370291719642409660905444643494169974931);
        vk.IC[2] = Pairing.G1Point(13629729267373883091784437554800598646370914526466282534161591457204234303940,20428953590301985331608379836857790556503633933796007036040402171229917977521);
        vk.IC[3] = Pairing.G1Point(3785379534194287071601933141657029654649536871130067525982297509612327206924,20441720781313152301739076910621905177933653643381029091599841534154495485733);
        vk.IC[4] = Pairing.G1Point(8174876566887573867022571764285261688265531058998171958730684499818568021399,15364158076213537047194249827614090601580933367596700053241089406052131015891);
        vk.IC[5] = Pairing.G1Point(9663480153820773462766642876957017446277546738016922976831320957266750385069,11455348672789641736424763421225888127466400796123190592860299461638477062914);
        vk.IC[6] = Pairing.G1Point(9997392752408677018847679602311243591939016081244612283626393457143697191318,1284349834049952760295840793422778426148802044355256369588105110406727218438);

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
            uint[6] memory input
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
    function verifyProof(bytes calldata proof, uint[6] calldata inputs) external view returns (bool r) {
        // solidity does not support decoding uint[2][2] yet
        (uint[2] memory a, uint[2] memory b1, uint[2] memory b2, uint[2] memory c) = abi.decode(proof, (uint[2], uint[2], uint[2], uint[2]));
        return verifyProof(a, [b1, b2], c, inputs);
    }
}