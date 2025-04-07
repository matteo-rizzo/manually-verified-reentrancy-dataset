/**
 *Submitted for verification at Etherscan.io on 2021-04-26
*/

pragma solidity 0.7.0;






contract AlphaPerpetualStaking {
    IERC20 public constant alphaToken = IERC20(0xa1faa113cbE53436Df28FF0aEe54275c13B40975);
    IAlphaStaking public constant alphaStakingContract = IAlphaStaking(0x2aA297c3208bD98a9a477514d3C80ace570A6deE);
    
    mapping(address => uint256) stakedAmount;
    
    constructor() {
        alphaToken.approve(address(alphaStakingContract), uint256(-1));
    }

    function stakeForever(uint256 amount) external{
        alphaToken.transferFrom(msg.sender,address(this),amount);
        alphaStakingContract.stake(amount);
        stakedAmount[msg.sender] += amount;
    }
    
    function getStakedAmount(address user) external view returns(uint256) {
        return stakedAmount[user];
    }
}