pragma solidity ^0.6.0;
// SPDX-License-Identifier: UNLICENSED

/**
 * @title SafeMath
 * @dev Math operations with safety checks that throw on error
 *
*/



// ----------------------------------------------------------------------------
// Owned contract
// ----------------------------------------------------------------------------



// ----------------------------------------------------------------------------
// ERC Token Standard #20 Interface
// ----------------------------------------------------------------------------



contract PreSale is Owned {
    using SafeMath for uint256;
    address public tokenAddress;
    bool public saleOpen;
    uint256 tokenRatePerEth = 160000; // 1 ether = 160000 tokens approx

    constructor() public {
        owner = msg.sender;
    }
    
    function setTokenAddress(address _tokenAddress) external onlyOwner{
        require(tokenAddress == address(0), "address already set");
        tokenAddress = _tokenAddress;
    }
    
    function startSale() external onlyOwner{
        require(!saleOpen, "Sale is already open");
        saleOpen = true;
    }
    
    function closeSale() external onlyOwner{
        require(saleOpen, "Sale is not open");
        saleOpen = false;
    }

    receive() external payable{
        
        require(saleOpen, "Sale is not open");
        require(msg.value >= 0.1 ether, "Min investment allowed is 0.1 ether");
        
        uint256 tokens = getTokenAmount(msg.value);
        
        require(IToken(tokenAddress).transfer(msg.sender, tokens), "Insufficient balance of sale contract!");
        
        // send received funds to the owner
        owner.transfer(msg.value);
    }
    
    function getTokenAmount(uint256 amount) internal view returns(uint256){
        return amount.mul(tokenRatePerEth);
    }
    
    function setTokenRate(uint256 ratePerEth) external onlyOwner{
        require(!saleOpen, "Sale is open, cannot change now");
        tokenRatePerEth = ratePerEth;
    }

}