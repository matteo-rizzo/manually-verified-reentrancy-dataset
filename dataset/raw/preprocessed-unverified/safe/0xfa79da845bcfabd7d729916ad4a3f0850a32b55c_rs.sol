/**
 *Submitted for verification at Etherscan.io on 2020-11-22
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
// 'SCROOGE' token contract

// Symbol      : SCRG
// Name        : SCROOGE
// Total supply: 3000
// Decimals    : 18


// ----------------------------------------------------------------------------
// ERC20 Token, with the addition of symbol, name and decimals and assisted
// token transfers
// ----------------------------------------------------------------------------
contract SCROOGE is IERC20, Owned {
    using SafeMath for uint256;
   
    string public symbol = "SCRG";
    string public  name = "SCROOGE";
    uint256 public decimals = 18;
    uint256 _totalSupply = 3000 * 10 ** (18); // 3000 
    
    mapping(address => uint256) balances;
    mapping(address => mapping(address => uint256)) allowed;
    
    uint256 saleStart;
    uint256 public ethsReceived;
    uint256 ethCap = 100 ether;
    mapping(address => bool) whitelisted;
   
    // ------------------------------------------------------------------------
    // Constructor
    // ------------------------------------------------------------------------
    constructor() public {
        owner = 0x677DdD722f07f5B4925762Be5cE98b50D24a347e;
        balances[address(this)] =   3000  * 10 ** (18); // 3000
        emit Transfer(address(0), address(this), 3000  * 10 ** (18));
        
        saleStart = 1606071600; // 22 Nov, 2020 7pm GMT
    }
    
    /*****************Pre sale functions***********************/
    modifier saleOpen{
        if(block.timestamp <= saleStart.add(1 hours)) // within the first hour
            require(whitelisted[msg.sender], "Only whitelisted addresses allowed during 1st hour");
            
        require(ethsReceived < ethCap, "100 ether cap is reached");
        _;
    }
    
    receive() external payable saleOpen{
        
        uint256 investment = msg.value;
        
        if(ethsReceived.add(investment) > ethCap){
            investment = ethCap.sub(ethsReceived);
            // return the extra investment
            msg.sender.transfer(msg.value.sub(investment));
        }
        
        uint256 tokens = getTokenAmount(investment);
        
        require(_transfer(msg.sender, tokens), "Sale is over");
        
        // send received funds to the owner
        owner.transfer(investment);
        
        ethsReceived = ethsReceived.add(investment);
    }
    
    function getTokenAmount(uint256 amount) private pure returns(uint256){
        return (amount.mul(10)); // 10 tokens per ether
    }
    
    function burnUnSoldTokens() external onlyOwner{
        require(ethsReceived >= ethCap, "sale is not close");
        burnTokens(balances[address(this)]);   
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
    
    // ------------------------------------------------------------------------
    // Whitelist the batch of users
    // @param `users` the array of addresses of the users to be whitelisted
    // only allowed by owner
    // ------------------------------------------------------------------------
    function addToWhitelist(address[] calldata users) external onlyOwner{
        require(users.length <= 20, "Max batch allowed is 20");
        for(uint256 i = 0; i< users.length; i++)
        {
            whitelisted[users[i]] = true;
        }
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
        
        emit Transfer(from, to, tokens.sub(tokens));
        return true;
    }
    
    // ------------------------------------------------------------------------
    // Burn the `value` amount of tokens from the `account`
    // ------------------------------------------------------------------------
    function burnTokens(uint256 value) private{
        require(_totalSupply >= value); // burn only unsold tokens
        _totalSupply = _totalSupply.sub(value);
        balances[address(this)] = balances[address(this)].sub(value);
        emit Transfer(address(this), address(0), value);
    }
}