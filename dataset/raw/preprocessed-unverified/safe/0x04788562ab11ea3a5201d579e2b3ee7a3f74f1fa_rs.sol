/**
 *Submitted for verification at Etherscan.io on 2021-04-08
*/

// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.7.5;


// ----------------------------------------------------------------------------
// SafeMath library
// ----------------------------------------------------------------------------




// ----------------------------------------------------------------------------
// Owned contract
// ----------------------------------------------------------------------------


// ----------------------------------------------------------------------------
// ERC Token Standard #20 Interface
// ----------------------------------------------------------------------------





contract FeeDistributor is Owned {
    using SafeMath for uint256;
    
    address public fETH   = 0xf786c34106762Ab4Eeb45a51B42a62470E9D5332;
    address public dev   = 0x94D4Ac11689C6EbbA91cDC1430fc7dfa9a858753;
    bool public perform = false;

    stakeContract stakingContract; //FEG staking contract address
    stakeContract LPstakingContract; //FEG LP staking contract address
    
    fallback() external payable {
        owner.transfer(msg.value);
    }
    
    receive() external payable{  owner.transfer(msg.value); }

    constructor(stakeContract _stakingContract, stakeContract _lpStakingContract) {
        owner = msg.sender;
        stakingContract     = _stakingContract;
        LPstakingContract   = _lpStakingContract;
    }
    
    function changeStakingContract(stakeContract _stakingContract) external onlyOwner{
        require(address(_stakingContract) != address(0), "setting 0 to contract");
        stakingContract = _stakingContract;
    }
    
    function changeLPStakingContract(stakeContract _lpStakingContract) external onlyOwner{
        require(address(_lpStakingContract) != address(0), "setting 0 to contract");
        LPstakingContract = _lpStakingContract;
    }

    function changedev(address _DEV) external onlyOwner{
        dev = _DEV;
    }
    
    function changePerform(bool _bool) external onlyOwner{
        perform = _bool;
    }


    function distributeAll() public{
        
        uint256 amount = IERC20(fETH).balanceOf(address(this)).mul(uint256(999)).div(1000);
        uint256 amountForToken  = (onePercent(amount).mul(uint256(480))).div(10); 
        require(IERC20(fETH).transfer( address(stakingContract), amountForToken), "Tokens cannot be transferred from funder account");
        stakingContract.ADDFUNDS(amountForToken);
        
         uint256 amountForLP     = (onePercent(amount).mul(uint256(320))).div(10);
        require(IERC20(fETH).transfer( address(LPstakingContract), amountForLP), "Tokens cannot be transferred from funder account");
        if(perform==true) {
        LPstakingContract.ADDFUNDS(amountForLP);}        
        
         uint256 amountFinal     = amount.sub(amountForToken.add(amountForLP));
        require(IERC20(fETH).transfer( address(dev), amountFinal), "Tokens cannot be transferred from funder account");
    }

    
    // ------------------------------------------------------------------------
    // Private function to calculate 1% percentage
    // ------------------------------------------------------------------------
    function onePercent(uint256 _tokens) private pure returns (uint256){
        uint256 roundValue = _tokens.ceil(100);
        uint onePercentofTokens = roundValue.mul(100).div(100 * 10**uint(2));
        return onePercentofTokens;
    }
    
    
    
}