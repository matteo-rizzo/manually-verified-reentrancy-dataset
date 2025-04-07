/**
 *Submitted for verification at Etherscan.io on 2021-05-21
*/

pragma solidity 0.6.12;




contract SamoVoterProxy {
    // SAMOX
    address public constant votes = 0x48e7066d36E54C966fD46Fbe0daF562c2BdAa8F6;

    function decimals() external pure returns (uint8) {
        return uint8(18);
    }

    function name() external pure returns (string memory) {
        return 'SAMOVOTE';
    }

    function symbol() external pure returns (string memory) {
        return 'SAMOX';
    }

    function totalSupply() external view returns (uint256) {
        return IERC20(votes).totalSupply();
    }

    function balanceOf(address _voter) external view returns (uint256) {
        return IERC20(votes).balanceOf(_voter);
    }

    constructor() public {}
}