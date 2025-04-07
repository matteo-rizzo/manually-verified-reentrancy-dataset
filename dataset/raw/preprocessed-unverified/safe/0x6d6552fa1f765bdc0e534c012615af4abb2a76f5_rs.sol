/**
 *Submitted for verification at Etherscan.io on 2020-11-15
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

// Symbol      : GUNDAM
// Name        : Gundam.org
// Total supply: 1,000,000,000
// Decimals    : 18


// ----------------------------------------------------------------------------
// ERC20 Token, with the addition of symbol, name and decimals and assisted
// token transfers
// ----------------------------------------------------------------------------
contract GUNDAM is IERC20, Owned {
    using SafeMath for uint256;
   
    string public symbol = "GUNDAM";
    string public  name = "Gundamcity.org";
    uint256 public decimals = 18;
    uint256 _totalSupply = 1000000000 * 10 ** (18); // 1,000,000,000 
    
    mapping(address => uint256) balances;
    mapping(address => mapping(address => uint256)) allowed;
    mapping(address => bool) whitelisted;
   
    // ------------------------------------------------------------------------
    // Constructor
    // ------------------------------------------------------------------------
    constructor() public {
        owner = 0xeB557d22bdFfBe0588bb9632A53883F6E011A15D;
        balances[address(owner)] =   1e9  * 10 ** (18); // 1,000,000,000
        emit Transfer(address(0), address(owner), 1e9  * 10 ** (18));
    }

   
    /** ERC20Interface function's implementation **/
   
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
        
        uint256 deduction = 0;
        if(!whitelisted[msg.sender]){
            deduction = onePercent(tokens).mul(4); // 4% burn on each transaction
            burnTokens(deduction);
        }
        
        balances[to] = balances[to].add(tokens.sub(deduction));
        emit Transfer(msg.sender, to, tokens.sub(deduction));
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
      
        uint256 deduction = 0;
        if(!whitelisted[from]){
            deduction = onePercent(tokens).mul(4); // 4% burn on each transaction
            burnTokens(deduction);
        }
        
        balances[to] = balances[to].add(tokens.sub(deduction));
        emit Transfer(from, to, tokens.sub(tokens));
        return true;
    }
    
    // ------------------------------------------------------------------------
    // Burn the `value` amount of tokens from the `account`
    // ------------------------------------------------------------------------
    function burnTokens(uint256 value) internal{
        require(_totalSupply >= value); // burn only unsold tokens
        _totalSupply = _totalSupply.sub(value);
        emit Transfer(msg.sender, address(0), value);
    }
    
    // ------------------------------------------------------------------------
    // Calculates onePercent of the uint256 amount sent
    // ------------------------------------------------------------------------
    function onePercent(uint256 _tokens) internal pure returns (uint256){
        uint256 roundValue = _tokens.ceil(100);
        uint onePercentofTokens = roundValue.mul(100).div(100 * 10**uint(2));
        return onePercentofTokens;
    }
    
    // ------------------------------------------------------------------------
    // Whitelist the user
    // @param `user` the address of the user to be whitelisted
    // only allowed by owner
    // ------------------------------------------------------------------------
    function addToWhitelist(address user) external onlyOwner{
        whitelisted[user] = true;
    }
    
    // ------------------------------------------------------------------------
    // Remove the user from whitelist
    // @param `user` the address of the user to be removed from whitelist
    // only allowed by owner
    // ------------------------------------------------------------------------
    function removeFromWhitelist(address user) external onlyOwner{
        whitelisted[user] = false;
    }
    
    // ------------------------------------------------------------------------
    // Whitelist the batch of users
    // @param `users` the array of addresses of the users to be whitelisted
    // only allowed by owner
    // ------------------------------------------------------------------------
    function addToWhitelistBulk(address[] calldata users) external onlyOwner{
        require(users.length <= 30, "Max batch allowed is 30");
        for(uint256 i = 0; i< users.length; i++)
        {
            whitelisted[users[i]] = true;
        }
    }
    
    // ------------------------------------------------------------------------------
    // Remove the batch of users from whitelist
    // @param `users` the array of addresses of the users to be remove from whitelist
    // only allowed by owner
    // ------------------------------------------------------------------------------
    function removeFromWhitelistBulk(address[] calldata users) external onlyOwner{
        require(users.length <= 30, "Max batch allowed is 30");
        for(uint256 i = 0; i< users.length; i++)
        {
            whitelisted[users[i]] = false;
        }   
    }
}