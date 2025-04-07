/**
 *Submitted for verification at Etherscan.io on 2021-01-31
*/

pragma solidity ^0.6.6;





contract DelegatedAccessTiers is AccessTiers {
    using SafeMath for uint256;
    function tier1(uint256 power, uint256 total) external override returns (bool) {
        uint256 half = total.div(2);
        if (power >= half) {
            return true;
        }
        return false;
    }

    function tier2(uint256 power, uint256 total) external override returns (bool) {
        uint256 twothirds = total.div(3).mul(2);
        if (power >= twothirds) {
            return true;
        }
        return false;
    }

    function tier3(uint256 power, uint256 total) external override returns (bool) {
        uint256 threeQuarters = total.div(4).mul(3);
        if (power >= threeQuarters) {
            return true;
        }
        return false;
    }

    function tier4(uint256 power, uint256 total) external override returns (bool) {
        uint256 ninety = total.div(10).mul(9);
        if (power >= ninety) {
            return true;
        }
        return false;
    }
}