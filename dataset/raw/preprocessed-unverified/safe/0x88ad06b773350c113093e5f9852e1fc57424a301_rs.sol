/**
 *Submitted for verification at Etherscan.io on 2021-04-22
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
    
    address public fBNB   = 0x87b1AccE6a1958E522233A737313C086551a5c76;
   // address public dev   = 0x94D4Ac11689C6EbbA91cDC1430fc7dfa9a858753;
    bool public perform = false;

    stakeContract stakingContract; //FEG staking contract address
    
    fallback() external payable {
        owner.transfer(msg.value);
    }
    
    receive() external payable{  owner.transfer(msg.value); }

    constructor(stakeContract _stakingContract) {
        owner = msg.sender;
        stakingContract     = _stakingContract;
        
    }
    
    function changeStakingContract(stakeContract _stakingContract) external onlyOwner{
        require(address(_stakingContract) != address(0), "setting 0 to contract");
        stakingContract = _stakingContract;
    }

    function changePerform(bool _bool) external onlyOwner{
        perform = _bool;
    }

    function distributeAll() public{
        
        uint256 amount = IERC20(fBNB).balanceOf(address(this)).mul(uint256(998)).div(1000);
        uint256 amountForToken  = (onePercent(amount).mul(uint256(998))).div(10); 
        require(IERC20(fBNB).transfer( address(stakingContract), amountForToken), "Tokens cannot be transferred from funder account");
        stakingContract.ADDFUNDS(amountForToken);
        
        
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