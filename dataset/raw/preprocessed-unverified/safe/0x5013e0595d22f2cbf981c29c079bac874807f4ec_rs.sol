/**
 *Submitted for verification at Etherscan.io on 2020-07-14
*/

pragma solidity ^0.4.24;





contract gameContract {
    function game(uint betMask, uint8 modulo, bytes32 entropy, uint betAmount) public pure returns(uint winAmount, uint256[10] result);
    function getMaxWin(uint betMask, uint8 modulo, uint betAmount) public pure returns(uint maxWin);
}

contract CoinAndRoulette is gameContract {
    uint constant POPCNT_MULT = 0x0000000000002000000000100000000008000000000400000000020000000001;
    uint constant POPCNT_MASK = 0x0001041041041041041041041041041041041041041041041041041041041041;
    uint constant POPCNT_MODULO = 0x3F;

    using SafeMath for uint256;
    using SafeMath8 for uint8;

    function game(uint betMask, uint8 modulo, bytes32 entropy, uint betAmount) public pure returns(uint winAmount, uint256[10] result) {
        uint dice = uint(entropy).mod(modulo);
        result[0] = dice;

        uint rollUnder;
        uint expectWin;
        rollUnder = getRollUnder(betMask, modulo);
        expectWin = betAmount.mul(uint(modulo)).div(rollUnder);

        if ((2 ** dice) & betMask != 0) {
            winAmount = expectWin;
        }

    }

    function getMaxWin(uint betMask, uint8 modulo, uint betAmount) public pure returns(uint maxWin) {
        uint rollUnder;
        rollUnder = ((betMask.mul(POPCNT_MULT)) & POPCNT_MASK) % POPCNT_MODULO;
        maxWin = betAmount * modulo / rollUnder;
    }
    function getRollUnder(uint betMask, uint8 modulo) public pure returns(uint rollUnder) {
        rollUnder = ((betMask * POPCNT_MULT) & POPCNT_MASK) % POPCNT_MODULO;
    }

}