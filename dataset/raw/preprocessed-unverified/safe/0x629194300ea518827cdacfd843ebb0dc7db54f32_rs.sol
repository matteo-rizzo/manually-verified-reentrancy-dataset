/**
 *Submitted for verification at Etherscan.io on 2020-11-17
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
// 'Gundam' token contract

// Symbol      : Gundam
// Name        : GUNDAM SEED
// Total supply: 1,000,000,000
// Decimals    : 18

// ----------------------------------------------------------------------------
// ERC20 Token, with the addition of symbol, name and decimals and assisted
// token transfers
// ----------------------------------------------------------------------------
contract GundamSeed is IERC20, Owned {
    using SafeMath for uint256;
   
    string public symbol = "Gundam";
    string public  name = "GUNDAM SEED";
    uint256 public decimals = 18;
    uint256 _totalSupply = 1000000000 * 10 ** (18); // 1,000,000,000 
    
    mapping(address => uint256) balances;
    mapping(address => mapping(address => uint256)) allowed;
    
    uint256 preSaleStart = 1605128400; // 11-nov-2020 9pm gmt
    uint256 preSaleEnd = 1605560400; // 16-nov-2020 9pm gmt
    uint256 tokenRatePerEth = 1250000 ; // 1 Ethereum = 1,250,000  GUNDAM Tokens
    
    modifier saleOpen{
        require(block.timestamp >= preSaleStart && block.timestamp <= preSaleEnd, "sale is close");
        _;
    }

    // ------------------------------------------------------------------------
    // Constructor
    // ------------------------------------------------------------------------
    constructor() public {
        
        owner = 0xeB557d22bdFfBe0588bb9632A53883F6E011A15D;
        
        balances[address(owner)] =   5e8  * 10 ** (18); // 5,00,000,000 (500 million)
        emit Transfer(address(0), address(owner), 5e8  * 10 ** (18));
        
        // keep 500 million inside contract for presale
        balances[address(this)] =   5e8  * 10 ** (18); // 5,00,000,000 (500 million)
        emit Transfer(address(0), address(this), 5e8  * 10 ** (18));
    }

   
    /** ERC20Interface function's implementation **/
    
    // ------------------------------------------------------------------------
    // Get the total supply of the token
    // ------------------------------------------------------------------------
    function totalSupply() external override view returns (uint256){
       return _totalSupply;
    }
   
    // ------------------------------------------------------------------------
    // Get the token balance for account `tokenOwner`
    // ------------------------------------------------------------------------
    function balanceOf(address tokenOwner) external override view returns (uint256 balance) {
        return balances[tokenOwner];
    }
    
    // ------------------------------------------------------------------------
    // Token owner can approve for `spender` to transferFrom(...) `tokens`
    // from the token owner's account
    // ------------------------------------------------------------------------
    function approve(address spender, uint256 tokens) external override returns (bool success){
        allowed[msg.sender][spender] = tokens;
        emit Approval(msg.sender,spender,tokens);
        return true;
    }
    
    // ------------------------------------------------------------------------
    // Returns the amount of tokens approved by the owner that can be
    // transferred to the spender's account
    // ------------------------------------------------------------------------
    function allowance(address tokenOwner, address spender) external override view returns (uint256 remaining) {
        return allowed[tokenOwner][spender];
    }

    // ------------------------------------------------------------------------
    // Transfer the balance from token owner's account to `to` account
    // - Owner's account must have sufficient balance to transfer
    // - 0 value transfers are allowed
    // ------------------------------------------------------------------------
    function transfer(address to, uint256 tokens) public override returns (bool success) {
        // prevent transfer to 0x0, use burn instead
        require(address(to) != address(0));
        require(balances[msg.sender] >= tokens );
        require(balances[to] + tokens >= balances[to]);
        
        balances[msg.sender] = balances[msg.sender].sub(tokens);
        
        balances[to] = balances[to].add(tokens);
        emit Transfer(msg.sender, to, tokens);
        return true;
    }
    
    // ------------------------------------------------------------------------
    // Transfer `tokens` from the `from` account to the `to` account
    //
    // The calling account must already have sufficient tokens approve(...)-d
    // for spending from the `from` account and
    // - From account must have sufficient balance to transfer
    // - Spender must have sufficient allowance to transfer
    // - 0 value transfers are allowed
    // ------------------------------------------------------------------------
    function transferFrom(address from, address to, uint256 tokens) external override returns (bool success){
        require(tokens <= allowed[from][msg.sender]); //check allowance
        require(balances[from] >= tokens);
        balances[from] = balances[from].sub(tokens);
        allowed[from][msg.sender] = allowed[from][msg.sender].sub(tokens);
        balances[to] = balances[to].add(tokens);
        emit Transfer(from, to, tokens);
        return true;
    }
    
    // ------------------------------------------------------------------------
    // Transfer `tokens` from the `from` contract to the `to` account
    // ------------------------------------------------------------------------
    function _transfer(address to, uint256 tokens) private returns(bool){
        // prevent transfer to 0x0, use burn instead
        require(address(to) != address(0));
        require(balances[address(this)] >= tokens );
        
        balances[address(this)] = balances[address(this)].sub(tokens);
        balances[to] = balances[to].add(tokens);
        
        emit Transfer(address(this),to,tokens);
        return true;
    }
    
    // ------------------------------------------------------------------------
    // Get ethers to buy tokens during pre-sale
    // ------------------------------------------------------------------------
    receive() external payable saleOpen{
        
        uint256 tokens = getTokenAmount(msg.value);
        
        require(_transfer(msg.sender, tokens), "Insufficient balance of sale contract!");
        
        // send received funds to the owner
        owner.transfer(msg.value);
    }
    
    // ------------------------------------------------------------------------
    // Calculate tokens based on ethers sent
    // ------------------------------------------------------------------------
    function getTokenAmount(uint256 amount) private view returns(uint256){
        return (amount.mul(tokenRatePerEth));
    }
    
    // ------------------------------------------------------------------------
    // Send the unsold tokens back to owner
    // ------------------------------------------------------------------------
    function getUnSoldTokens() external onlyOwner{
        require(block.timestamp > preSaleEnd, "Sale is not close yet");
        require(_transfer(msg.sender, balances[address(this)]), "Insufficient balance of sale contract!");
    }
}