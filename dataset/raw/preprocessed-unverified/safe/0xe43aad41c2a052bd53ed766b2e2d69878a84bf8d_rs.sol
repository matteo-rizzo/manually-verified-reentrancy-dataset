/**
 *Submitted for verification at Etherscan.io on 2020-07-14
*/

pragma solidity ^0.4.24;




contract gameContract {
    function game(uint betMask, uint8 modulo, bytes32 entropy, uint betAmount) public pure returns(uint winAmount, uint256[10] result);
    function getMaxWin(uint betMask, uint8 modulo, uint betAmount) public pure returns(uint maxWin);
}

contract DoubleChanceDice is gameContract {
    uint constant POPCNT_MULT = 0x0000000000002000000000100000000008000000000400000000020000000001;
    uint constant POPCNT_MASK = 0x0001041041041041041041041041041041041041041041041041041041041041;
    uint constant POPCNT_MODULO = 0x3F;

    using SafeMath for uint256;
    using SafeMath8 for uint8;

    function getMaxWin(uint betMask, uint8 modulo, uint betAmount) public pure returns(uint maxWin) {
        require(getBitCount(betMask) == 1);

        maxWin = betAmount * 18;
    }

    function game(uint betMask, uint8 modulo, bytes32 entropy, uint betAmount) public pure returns (uint winAmount, uint256[10] result) {

        require(getBitCount(betMask) == 1);

        uint256[2] memory dice;
        dice[0] = uint256(entropy).mod(6);
        dice[1] = uint256(keccak256(abi.encodePacked(entropy))).mod(6);


        uint8 hit = 0;
        for (uint8 i = 0; i < 2; i++){
            if((2 ** dice[i]) & betMask !=0) {
                hit++;
            }
        }

        if (hit == 2) {
            winAmount = betAmount.mul(18);
        } else if(hit == 1) {
            winAmount = betAmount.div(10).mul(18);
        } else {
            winAmount = 0;
        }

        result[0] = dice[0];
        result[1] = dice[1];
    }
    function getBitCount(uint betMask) public pure returns(uint bitCount) {
        bitCount = (betMask.mul(POPCNT_MULT) & POPCNT_MASK).mod(POPCNT_MODULO);
    }
}