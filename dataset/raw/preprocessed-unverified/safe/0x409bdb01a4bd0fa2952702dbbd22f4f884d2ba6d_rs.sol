/**
 *Submitted for verification at Etherscan.io on 2020-11-10
*/

pragma solidity ^0.5.0;


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


contract rewardVerifier {
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
        vk.alfa1 = Pairing.G1Point(
            68632700465519242806434824326998282154898130999354898804707205126246937931,
            14415633203687681050138030819125191557291346451461864477247868213624033353506
        );
        vk.beta2 = Pairing.G2Point(
            [
                9582782916832493405029496430805494196429007873126133667332222556735472593255,
                113262689627246533055141228862038316003345504223770627135164829439422839380
            ],
            [
                13101008430689199430894044278007882832515638199070297442240618589894177919146,
                19030113695857705668206028094089446509865945320939401766518040907735157268766
            ]
        );
        vk.gamma2 = Pairing.G2Point(
            [
                15702159893173489654023054719758910644861931939317497436221166944331558040018,
                15503234520828538162733382038517002224971664979755323305633733382110162749694
            ],
            [
                2543490440287064464941471869235841959019226980144100409229151436748790131313,
                19735526109615593098841326299181660326584703437028068618032205724040359011400
            ]
        );
        vk.delta2 = Pairing.G2Point(
            [
                19243489625781169062772919232934981772664222256451541906992641900020206537673,
                13130118861248150609564776008636058375938154393066872762984746811347444958171
            ],
            [
                18437899602829773137525597627338850480573781618175444850544117161849778057490,
                9837531241175433960485503519615037603296454047122930953888811144900486061185
            ]
        );
        vk.IC = new Pairing.G1Point[](7);
        vk.IC[0] = Pairing.G1Point(
            10670587790590346525127391846973786329526165870924292678846602408905760840269,
            122859096472474758479984201184315301868954655027394500890844715706581594545
        );
        vk.IC[1] = Pairing.G1Point(
            12112940933904364756389079584999363989349946812684478058670583132005167940213,
            1733848439401071429769041212730334415406150130844296438957059340295845613403
        );
        vk.IC[2] = Pairing.G1Point(
            21690654580990621803234088344960618431380176287123844416003622103247797790097,
            9882899777285884844789935684863938580754885421782381592893859503871788383972
        );
        vk.IC[3] = Pairing.G1Point(
            5158862071679849339710064950220804149265546984039351708119945847694658154144,
            8446707335000054979707676392553685105452961283143689738208050593533348740559
        );
        vk.IC[4] = Pairing.G1Point(
            11806154318151945440229975656982668832229863659245705929982690338468784071511,
            14614069147587954181122988027040567623695859397099514071943815644392776141034
        );
        vk.IC[5] = Pairing.G1Point(
            8331417399454857195730575954558814711724015216036563956639088255452144440090,
            21646399403479850409671428848340671568720281280760064140041522316258982586306
        );
        vk.IC[6] = Pairing.G1Point(
            21657852814868133125534722972189561908227414260101018799267108078630725648323,
            6456011501109961136108065196397199712188396592177657099753980356564499311282
        );
    }

    function verify(uint256[] memory input, Proof memory proof)
        internal
        view
        returns (uint256)
    {

            uint256 snark_scalar_field
         = 21888242871839275222246405745257275088548364400416034343698204186575808495617;
        VerifyingKey memory vk = verifyingKey();
        require(input.length + 1 == vk.IC.length, "verifier-bad-input");
        // Compute the linear combination vk_x
        Pairing.G1Point memory vk_x = Pairing.G1Point(0, 0);
        for (uint256 i = 0; i < input.length; i++) {
            require(
                input[i] < snark_scalar_field,
                "verifier-gte-snark-scalar-field"
            );
            vk_x = Pairing.addition(
                vk_x,
                Pairing.scalar_mul(vk.IC[i + 1], input[i])
            );
        }
        vk_x = Pairing.addition(vk_x, vk.IC[0]);
        if (
            !Pairing.pairingProd4(
                Pairing.negate(proof.A),
                proof.B,
                vk.alfa1,
                vk.beta2,
                vk_x,
                vk.gamma2,
                proof.C,
                vk.delta2
            )
        ) return 1;
        return 0;
    }

    function verifyProof(
        uint256[2] memory a,
        uint256[2][2] memory b,
        uint256[2] memory c,
        uint256[6] memory input
    ) public view returns (bool r) {
        Proof memory proof;
        proof.A = Pairing.G1Point(a[0], a[1]);
        proof.B = Pairing.G2Point([b[0][0], b[0][1]], [b[1][0], b[1][1]]);
        proof.C = Pairing.G1Point(c[0], c[1]);
        uint256[] memory inputValues = new uint256[](input.length);
        for (uint256 i = 0; i < input.length; i++) {
            inputValues[i] = input[i];
        }
        if (verify(inputValues, proof) == 0) {
            return true;
        } else {
            return false;
        }
    }

    function verifyProof(bytes calldata proof, uint256[6] calldata inputs)
        external
        view
        returns (bool r)
    {
        // solidity does not support decoding uint[2][2] yet
        (
            uint256[2] memory a,
            uint256[2] memory b1,
            uint256[2] memory b2,
            uint256[2] memory c
        ) = abi.decode(proof, (uint256[2], uint256[2], uint256[2], uint256[2]));
        return verifyProof(a, [b1, b2], c, inputs);
    }
}