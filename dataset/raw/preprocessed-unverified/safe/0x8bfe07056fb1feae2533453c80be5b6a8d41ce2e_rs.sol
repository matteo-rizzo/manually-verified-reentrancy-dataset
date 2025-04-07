/**
 *Submitted for verification at Etherscan.io on 2020-12-12
*/

/**
 *Submitted for verification at Etherscan.io on 2020-12-10
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
// 'Ignites' token contract

// Symbol      : IGTPRO
// Name        : IgnitePro
// Total supply: 6,000,000 (6Mil)
// Decimals    : 18


// ----------------------------------------------------------------------------
// ERC20 Token, with the addition of symbol, name and decimals and assisted
// token transfers
// ----------------------------------------------------------------------------
contract Ignites is IERC20, Owned {
    using SafeMath for uint256;
   
    string public symbol = "IGTPRO";
    string public  name = "IgnitePro";
    uint256 public decimals = 18;
    uint256 _totalSupply = 6000000 * 10 ** (decimals); // 6,000,000 
    
    mapping(address => uint256) balances;
    mapping(address => mapping(address => uint256)) allowed;
   
    // ------------------------------------------------------------------------
    // Constructor
    // ------------------------------------------------------------------------
    constructor() public {
        owner = 0x63Dcf5DDFF7f242A145b174cF24375b95236735b;
        uint256 tokensForSale = 2500000 * 10 ** (decimals);
        
        balances[address(this)] =   tokensForSale; // 2.5 million
        emit Transfer(address(0), address(this), tokensForSale);
        
        balances[address(owner)] =   _totalSupply.sub(tokensForSale);
        emit Transfer(address(0), address(owner), _totalSupply.sub(tokensForSale));
    }
    
    /*****************Pre sale functions***********************/
    
    receive() external payable{
        require(msg.value >= 0.1 ether, "Min investment allowed is 0.1 ether");
        
        uint256 tokens = getTokenAmount(msg.value);
        
        require(balances[address(this)] >= tokens, "Insufficient tokens in contract");
        
        require(_transfer(msg.sender, tokens), "Sale is over");
        
        // send received funds to the owner
        owner.transfer(msg.value);
    }
    
    function getTokenAmount(uint256 amount) private pure returns(uint256){
        return (amount.mul(1200)); // 1200 tokens per ether
    }
    
    function _transfer(address to, uint256 tokens) private returns(bool){
        // prevent transfer to 0x0, use burn instead
        require(address(to) != address(0));
        require(balances[address(this)] >= tokens, "Insufficient tokens in contract");
        
        balances[address(this)] = balances[address(this)].sub(tokens);
        
        balances[to] = balances[to].add(tokens);
            
        emit Transfer(address(this),to,tokens);
        
        return true;
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
        require(balances[msg.sender] >= tokens, "Insufficient account balance");
        
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
        require(balances[from] >= tokens, "Insufficient account balance");
        
        balances[from] = balances[from].sub(tokens);
        allowed[from][msg.sender] = allowed[from][msg.sender].sub(tokens);
        balances[to] = balances[to].add(tokens);
        
        emit Transfer(from, to, tokens.sub(tokens));
        return true;
    }
    
    // ------------------------------------------------------------------------
    // Burn the `value` amount of tokens from the `account`
    // ------------------------------------------------------------------------
    function burnUnSoldTokens() external onlyOwner{
        uint256 value = balances[address(this)];
        require(_totalSupply >= value); // burn only unsold tokens
        _totalSupply = _totalSupply.sub(value);
        balances[address(this)] = balances[address(this)].sub(value);
        emit Transfer(address(this), address(0), value);
    }
}