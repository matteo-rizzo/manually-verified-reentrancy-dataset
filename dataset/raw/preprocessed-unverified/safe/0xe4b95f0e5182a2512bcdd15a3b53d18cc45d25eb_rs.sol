/**
 *Submitted for verification at Etherscan.io on 2021-02-06
*/

pragma solidity ^0.6.0;

// SPDX-License-Identifier: UNLICENSED

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
// Owned contract
// ----------------------------------------------------------------------------


// ----------------------------------------------------------------------------
// ERC Token Standard #20 Interface
// https://github.com/ethereum/EIPs/blob/master/EIPS/eip-20-token-standard.md
// ----------------------------------------------------------------------------
/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
 */


contract PreSale is Owned {
    using SafeMath for uint256;
    
    address public tokenAddress;
    uint256 public constant startSale = 1613502000; // 16 Feb 2021, 7pm GMT
    uint256 public constant endSale =   1614106800; // 23 Feb 2021, 7pm GMT
    uint256 public constant claimDate = 1614110400; // 23 Feb 2021, 8pm GMT
    uint256 public purchasedTokens;
        
    mapping(address => uint256) public investor;
    
    constructor() public {
        owner = 0xa97F07bc8155f729bfF5B5312cf42b6bA7c4fCB9;
    }
    
    function SetTokenAddress(address _tokenAddress) external onlyOwner {
        tokenAddress = _tokenAddress;
    }
    
    receive() external payable{
        Invest();
    }
    
    function Invest() public payable{
        require( now > startSale && now < endSale , "Sale is closed");
        uint256 tokens = getTokenAmount(msg.value);
        investor[msg.sender] += tokens;
        purchasedTokens = purchasedTokens + tokens;
        owner.transfer(msg.value);
    }

    function getTokenAmount(uint256 amount) internal view returns(uint256){
        uint256 _tokens = 0;
        if (now <= startSale + 3 days){
            _tokens = amount * 100;
        }
        if (now > startSale + 3 days){
            _tokens = amount * 80;
        }
        return _tokens;
    }

    function ClaimTokens() external returns(bool){
        require(now >= claimDate, "Token claim date not reached");
        require(investor[msg.sender] > 0, "Not an investor");
        uint256 tokens = investor[msg.sender];
        investor[msg.sender] = 0;
        require(IERC20(tokenAddress).transfer(msg.sender, tokens));
        return true;
    }
    
    function getUnSoldTokens() onlyOwner external{
        require(block.timestamp > endSale, "sale is not closed");
        // check unsold tokens
        uint256 tokensInContract = IERC20(tokenAddress).balanceOf(address(this));
        require(tokensInContract > 0, "no unsold tokens in contract");
        require(IERC20(tokenAddress).transfer(owner, tokensInContract), "transfer of token failed");
    }
}