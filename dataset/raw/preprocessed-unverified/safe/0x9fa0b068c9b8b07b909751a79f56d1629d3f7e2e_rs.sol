/**
 *Submitted for verification at Etherscan.io on 2021-08-30
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
// ERC Token Standard #20 Interface
// https://github.com/ethereum/EIPs/blob/master/EIPS/eip-20-token-standard.md
// ----------------------------------------------------------------------------
/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
 */


// ----------------------------------------------------------------------------
// Owned contract
// ----------------------------------------------------------------------------


// ----------------------------------------------------------------------------
// ERC20 Token, with the addition of symbol, name and decimals and assisted
// token transfers
// ----------------------------------------------------------------------------
contract KittycoinPresale is Owned {
    using SafeMath for uint256;
    uint256 public decimals = 18;
    address public TOKEN;
    
    uint256 minLimit = 10000000000000000; // min 0.01 ETH
    uint256 maxLimit = 10 ether; // max 10 ETH per account
    
    uint256 rate = 6000000; // 1 ETH = 6,000,000 KTY
    struct User{
        uint256 tokens;
        uint256 presale;
    }
    
    uint256 saleStart;
    uint256 saleEnd = 0;
    
    mapping(address => User) public users;
    uint256 public totalPresale;
    uint256 public presaleClaimed;
    
    event TokenPurchased(address by, uint256 _bnbSent, uint256 _tokensPurchased);
    
    // ------------------------------------------------------------------------
    // Constructor
    // ------------------------------------------------------------------------
    constructor(address payable _owner, address _tokenAddress) public {
        owner = _owner;
        TOKEN = _tokenAddress;
        saleStart = block.timestamp; // sale will be started once the contract is deployed
    }
    
    // the contract accepts ETH
    receive() external payable saleIsOpen {
        _preValidatePurchase();
        uint256 tokens = _calculateTokens(msg.value);
        purchaseToken(msg.value, tokens);
        totalPresale = totalPresale.add(msg.value);
    }
    
    function _preValidatePurchase() private {
        users[msg.sender].presale = users[msg.sender].presale.add(msg.value);
        require(users[msg.sender].presale >= minLimit, "Amount lower than min limit");
        require(users[msg.sender].presale <= maxLimit, "Amount exceeds max limit");
    } 
    
    // tokens purchased can be claimed after the release date
    function purchaseToken(uint256 _amount, uint256 _tokens) private {
        users[msg.sender].tokens = users[msg.sender].tokens.add(_tokens);
        emit TokenPurchased(msg.sender, _amount, _tokens);
    }
    
    function _calculateTokens(uint256 _amount) private view returns(uint256 _tokens) {
        return _amount.mul(rate);
    }
    
    function ClaimTokens() external {
        require(saleEnd > 0 && block.timestamp > saleEnd + 30 days, "Presale tokens are available to withdraw 30 days after presale ends");
        uint256 toClaim = users[msg.sender].tokens;
        require(toClaim > 0, "nothing to be claimed");
        users[msg.sender].tokens = 0;
        require(IERC20(TOKEN).transfer(msg.sender, toClaim), "Error sending tokens");
    }
    
    function endSale() external onlyOwner{
        require(saleEnd == 0, "Presale is already ended");
        saleEnd = block.timestamp;
    }
    
    function getUnSoldTokens(uint256 amount) external onlyOwner{
        require(block.timestamp > saleEnd, "Wait for Presale to end");
        require(IERC20(TOKEN).transfer(msg.sender, amount), "Error sending tokens");
    }
    
    function claimPresale(uint256 claimAmount) external onlyOwner{
        owner.transfer(claimAmount);
        presaleClaimed = presaleClaimed.add(claimAmount);
    }
    
    modifier saleIsOpen{
        require(block.timestamp > saleStart, "Presale has not started");
        require(saleEnd == 0, "Presale has ended");
        require(IERC20(TOKEN).balanceOf(address(this)) > 0, "Insufficient tokens for Presale");
        _;
    }
}