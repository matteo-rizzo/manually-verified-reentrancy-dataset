// SPDX-License-Identifier: MIT

pragma solidity ^0.5.16;





contract SushiVoterProxy {
    
    IERC20 public constant votes = IERC20(0xCE84867c3c02B05dc570d0135103d3fB9CC19433);
    MasterChef public constant chef = MasterChef(0xc2EdaD668740f1aA35E4D8f227fB8E17dcA888Cd);
    uint public constant pool = uint(12);
    
    function decimals() external pure returns (uint8) {
        return uint8(18);
    }
    
    function name() external pure returns (string memory) {
        return "SUSHIPOWAH";
    }
    
    function symbol() external pure returns (string memory) {
        return "SUSHI";
    }
    
    function totalSupply() external view returns (uint) {
        return votes.totalSupply();
    }
    
    function balanceOf(address _voter) external view returns (uint) {
        (uint _votes,) = chef.userInfo(pool, _voter);
        return _votes;
    }
    
    constructor() public {}
}