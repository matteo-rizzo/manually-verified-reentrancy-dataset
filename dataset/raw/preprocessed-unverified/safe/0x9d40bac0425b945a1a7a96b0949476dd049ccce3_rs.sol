pragma solidity ^0.6.0;
// SPDX-License-Identifier: UNLICENSED

// ----------------------------------------------------------------------------
// 'FORMS' SALE 3 CONTRACT
// ----------------------------------------------------------------------------

// ----------------------------------------------------------------------------
// SafeMath library
// ----------------------------------------------------------------------------

/**
 * @dev Wrappers over Solidity's arithmetic operations with added overflow
 * checks.
 *
 * Arithmetic operations in Solidity wrap on overflow. This can easily result
 * in bugs, because programmers usually assume that an overflow raises an
 * error, which is the standard behavior in high level programming languages.
 * `SafeMath` restores this intuition by reverting the transaction when an
 * operation overflows.
 *
 * Using this library instead of the unchecked operations eliminates an entire
 * class of bugs, so it's recommended to use it always.
 */


// ----------------------------------------------------------------------------
// ERC Token Standard #20 Interface
// ----------------------------------------------------------------------------
abstract contract IFORMS {
    function transfer(address to, uint256 tokens) public virtual returns (bool success);
    function setTokenLock (uint256 lockedTokens, uint256 cliffTime, address purchaser) public virtual;
    function burnTokens(uint256 _amount) public virtual;
    function balanceOf(address tokenOwner) public virtual view returns (uint256 balance);
}

contract FORMS_SALE_3{
    
    using SafeMath for uint256;
    
    string public tokenPrice = '0.000256 ether';
    address public FORMS_TOKEN_ADDRESS;
    uint256 public saleEndDate = 0;
    address payable owner = 0xA6a3E445E613FF022a3001091C7bE274B6a409B0;
    
    modifier onlyOwner {
        require(owner == msg.sender, "UnAuthorized");
        _;
    }
    
    function setTokenAddress(address _tokenAddress) external onlyOwner{
        require(FORMS_TOKEN_ADDRESS == address(0), "TOKEN ADDRESS ALREADY CONFIGURED");
        FORMS_TOKEN_ADDRESS = _tokenAddress;
    }
    
    function startSale() external onlyOwner{
        require(saleEndDate == 0, "SALE ALREADY STARTED");
        saleEndDate = block.timestamp.add(2 days);
    }
    
    receive() external payable{
        // checks if sale is started or not
        require(saleEndDate > 0, "Sale has not started");
        
        // check minimum condition
        require(msg.value >= 0.1 ether, "Not enough investment");
        
        uint256 remainingSaleTokens = IFORMS(FORMS_TOKEN_ADDRESS).balanceOf(address(this));
        
        // check if burning is needed
        if(remainingSaleTokens > 0 && block.timestamp > saleEndDate)
            IFORMS(FORMS_TOKEN_ADDRESS).burnTokens(remainingSaleTokens);
            
        // checks if sale is finished
        require(IFORMS(FORMS_TOKEN_ADDRESS).balanceOf(address(this)) > 0, "Sale is finished");
        
        // receive ethers
        uint tokens = getTokenAmount(msg.value);
        
        // transfer tokens
        IFORMS(FORMS_TOKEN_ADDRESS).transfer(msg.sender, tokens);
        
        // send received funds to the owner
        owner.transfer(msg.value);
    }
    
    function getTokenAmount(uint256 amount) private pure returns(uint256){
        return amount.mul(3906); // 1 ether = 3906 tokens approx
    }
}