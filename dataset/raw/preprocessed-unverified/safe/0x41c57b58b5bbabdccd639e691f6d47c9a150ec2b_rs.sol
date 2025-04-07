/**
 *Submitted for verification at Etherscan.io on 2019-12-03
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
        vk.alfa1 = Pairing.G1Point(10519048622368258424895498853139921949896471113866039036593239249280242578029,1635084963809858622037481197982632221832988310046884910852080715957429990522);
        vk.beta2 = Pairing.G2Point([2322377404391335264712603108100379460068907403969653730055413918383333488673,10998286159879078645689974793311159065327598956587264568064554753179042128247], [18451229751398283855061694760835058748890074031747746008536692606703009258784,9034724433095522296873253800046822580121484322623732544788804975709706205163]);
        vk.gamma2 = Pairing.G2Point([20696877210206746414130002697056553483249455487193091022959492686239039112193,1134765205075091189255512736068932072372502372819325110332058682042094314208], [7522997253972315497688966854761804370398893983054355032515212646679242115299,565685645391673327802907152207707507048525578149597803371141005417447613682]);
        vk.delta2 = Pairing.G2Point([3555634506817940698434668763515802420537385007346915292745178557472272770346,17249114331771570909330797841812693485091714745867029697571981707368518507007], [5717160108152552642559573099240681570696248731152931493542748358063752607377,8712585705612622939268242305136392960429444044802698749387236093466677740606]);
        vk.IC = new Pairing.G1Point[](5);
        vk.IC[0] = Pairing.G1Point(11356146383133880759564175454677592491764020134257067479513640504668790518422,92263657232490479914019473150343080012105209471583177196870408856743611105);
        vk.IC[1] = Pairing.G1Point(20559100794976076839485688488070070902999581272403093730254736024861541364828,2174313474261100982420434189510476058648419006258176283518254491284861816028);
        vk.IC[2] = Pairing.G1Point(13414405199646899488156433417597128349890379478865304936661100759111682751907,4719150073330442974097807779358597162430104501527885790079302098977334556887);
        vk.IC[3] = Pairing.G1Point(11702231159264815705182105255745803706415386594651541152286392643062087724964,9236801536905333027418391626359517371016962705969663366877587240073346988914);
        vk.IC[4] = Pairing.G1Point(21053680298052567259787326961721433943956968739657421451471280697697991721742,4174058922361176141070030311634329619996903346880816833178144780210316837338);

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