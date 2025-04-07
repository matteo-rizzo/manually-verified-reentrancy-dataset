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


contract withdrawVerifier {
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
            16954158942519728638790634699427502617277811890854188736964569712256402108874,
            4853887341475411689162752814686977828753659238758624904436464399911233181789
        );
        vk.beta2 = Pairing.G2Point(
            [
                3553796587147707868221401440330653878464553447974048256338484083403880871279,
                10881436069977331413254194381426315885919138028604310586524088533501358955109
            ],
            [
                554219737543102952744483611874143077462185705309891806989145488801073306271,
                9409363920473337588801036819699444134753219954517443484334340645716975900537
            ]
        );
        vk.gamma2 = Pairing.G2Point(
            [
                15835396745809302047857962237408016564677757264735411961895464204275479520101,
                4816274361064561217008158949208603992562463552030076130951138882879237876002
            ],
            [
                2657349449553812953795906111583580858867466816674108494349782884813347200025,
                10043126501350062935275553474943176726930010914443447816353590070970104772515
            ]
        );
        vk.delta2 = Pairing.G2Point(
            [
                7283580813474622247301806821610231208877772213155618212591703595233267096250,
                11707105533135571906914329788444133953060232994662578417597467150398664744282
            ],
            [
                11385749369626680203331401051634580287991672919300551086583617479169513319496,
                9611313099024018606232043820986775911468148051140788277551879224697364709191
            ]
        );
        vk.IC = new Pairing.G1Point[](8);
        vk.IC[0] = Pairing.G1Point(
            12912565231570889910296955037854848460681054044597840719031679724966236302695,
            1618290591174934914130771757973446200900756859557159243491129510642659761181
        );
        vk.IC[1] = Pairing.G1Point(
            14778611837533504514462554570414181360183580929421850888807508102557719724615,
            18010365132546690092942406451855070395143860207861052154579931039970828688716
        );
        vk.IC[2] = Pairing.G1Point(
            21842787128839192035269608458300323973858943522443094029988883807219296675218,
            12504530341877947596737738199189848566124046550837184854102649615969596397710
        );
        vk.IC[3] = Pairing.G1Point(
            6702350553342235510040006320179244922766468286016493815181054142373284636503,
            486510446745553771235793685582506026986002715740751589906965686550863923665
        );
        vk.IC[4] = Pairing.G1Point(
            18295456844681697070812504315172403847139068061461697796154812408892341354744,
            8586956606144774575262691355503600322190462693290841310821014264086165739962
        );
        vk.IC[5] = Pairing.G1Point(
            583165178558506337090803701407321068723888683963870553226798646114777438216,
            16564448870558779800710568686173987093691200356730792766741354916477305724325
        );
        vk.IC[6] = Pairing.G1Point(
            16894163527567693999351074375562429490067504929935444794046770610649488194723,
            6179936640197458957487209685456022255962630517225960304292326023613578579249
        );
        vk.IC[7] = Pairing.G1Point(
            2216753407676926432149475364826467911082264085961142066747165279038767234108,
            5023177841759340865723216108966485654591090628700583521267084598058245799942
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
        uint256[7] memory input
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

    function verifyProof(bytes calldata proof, uint256[7] calldata inputs)
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