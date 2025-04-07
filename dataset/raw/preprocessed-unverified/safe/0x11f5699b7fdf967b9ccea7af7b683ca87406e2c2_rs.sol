/**
 *Submitted for verification at Etherscan.io on 2020-11-19
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
// Owned contract - we dont allow transfer ownership in this contract
// ----------------------------------------------------------------------------


// ----------------------------------------------------------------------------
// 'PBURN' token AND staking contract

// Symbol      : PBURN
// Name        : PayBurn
// Total supply: 10011
// Decimals    : 18


// ----------------------------------------------------------------------------
// ERC20 Token, with the addition of symbol, name and decimals and assisted
// token transfers
// ----------------------------------------------------------------------------
contract PayBurn is IERC20, Owned {
    using SafeMath for uint256;
   
    string public symbol = "PBURN";
    string public  name = "PayBurn";
    uint256 public decimals = 18;
    uint256 _totalSupply = 10011 * 10 ** (decimals);
    uint256 _minSupply = 101 * 10 ** (decimals);
    
    uint256 _burnPercentage = 11; // 11% burn on each transaction until minSupply is reached
    
    address DEV_ADDRESS = 0x14B2a9E71C5Fb4c70bA144F6a733eD27145d8D37;
    
    mapping(address => uint256) balances;
    mapping(address => mapping(address => uint256)) allowed;
   
    // ------------------------------------------------------------------------
    // Constructor
    // ------------------------------------------------------------------------
    constructor() public {
        owner = 0xed026078043642F6b3E34cDe360E4CBd6dE7E34a;
        
        balances[address(owner)] =   _totalSupply; 
        emit Transfer(address(0), address(owner), _totalSupply);
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
        
        uint256 deduction = deductionsToApply(tokens);
        applyDeductions(deduction, msg.sender);
        
        balances[msg.sender] = balances[msg.sender].sub(tokens);
        balances[to] = balances[to].add(tokens.sub(deduction));
        
        _update(to, msg.sender);
        
        // update stats of receiver
        accounts[to].lastDividentPoints = totalDividentPoints;
        
        // update stats of sender
        accounts[msg.sender].lastDividentPoints = totalDividentPoints;
        
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
        
        uint256 deduction = deductionsToApply(tokens);
        applyDeductions(deduction, from);
        
        balances[from] = balances[from].sub(tokens);
        allowed[from][msg.sender] = allowed[from][msg.sender].sub(tokens);
        balances[to] = balances[to].add(tokens.sub(deduction));
        
        _update(to, from);
        
        // update stats of receiver
        accounts[to].lastDividentPoints = totalDividentPoints;
        
        // update stats of sender
        accounts[from].lastDividentPoints = totalDividentPoints;
        
        emit Transfer(from, to, tokens.sub(tokens));
        return true;
    }
    
    function _transfer(address to, uint256 tokens) private returns(bool){
        // prevent transfer to 0x0, use burn instead
        require(address(to) != address(0));
        require(balances[address(this)] >= tokens );
        
        balances[address(this)] = balances[address(this)].sub(tokens);
        
        balances[to] = balances[to].add(tokens);
            
        emit Transfer(address(this),to,tokens);
        
        return true;
    }
    
    function _update(address _to, address _from) private {
        
        // unclaimed reward of receiver
        uint256 owing = dividendsOwing(_to);
        
        if(owing > 0)
            accounts[_to].pending = owing;
            
        // unclaimed reward of sender
        owing = dividendsOwing(_from);
        
        if(owing > 0) 
            accounts[_from].pending = owing;
    }

    function deductionsToApply(uint256 tokens) private view returns(uint256){
        uint256 deduction = 0;
        
        if(_totalSupply > _minSupply){
        
            deduction = onePercent(tokens).mul(_burnPercentage); 
        
            if(_totalSupply.sub(deduction) < _minSupply)
                deduction = _totalSupply.sub(_minSupply);
        }
        
        return deduction;
    }
    
    function applyDeductions(uint256 deduction, address _from) private{
        uint256 _devPrct;
        if(deduction > 0){
            if(tokensInCirculation() == 0){
                _devPrct = devFunds(deduction);
                burnTokens(deduction.sub(_devPrct), _from);
            }
            else{
                _devPrct = devFunds(deduction);
                uint256 toDistr = (onePercent(deduction).mul(3)); // 3%
                burnTokens(deduction.sub(_devPrct).sub(toDistr), _from);
                disburse(toDistr);
            }
        }
    }
    
    function devFunds(uint256 deduction) private returns (uint256){
        uint256 devPercentage = (onePercent(deduction).mul(5)).div(10);
        balances[DEV_ADDRESS] = balances[DEV_ADDRESS].add(devPercentage);
        return devPercentage;
    }
    
    // ------------------------------------------------------------------------
    // Burn the ``value` amount of tokens from the `account`
    // ------------------------------------------------------------------------
    function burnTokens(uint256 value, address from) internal{
        require(_totalSupply >= value); // burn only unsold tokens
        _totalSupply = _totalSupply.sub(value);
        emit Transfer(from, address(0), value);
    }
    
    // ------------------------------------------------------------------------
    // Calculates onePercent of the uint256 amount sent
    // ------------------------------------------------------------------------
    function onePercent(uint256 _tokens) internal pure returns (uint256){
        uint256 roundValue = _tokens.ceil(100);
        uint onePercentofTokens = roundValue.mul(100).div(100 * 10**uint(2));
        return onePercentofTokens;
    }
    
    
    /********************************Details of users**********************************/
    
    uint256 deployTime;
    uint256 public totalDividentPoints;
    uint256 pointMultiplier = 1e18;
    
    uint256 public totalRewardsClaimed;
    
    struct  Account {
        uint256 lastDividentPoints;
        uint256 rewardsClaimed;
        uint256 pending;
    }

    mapping(address => Account) public accounts;
    
    function tokensInCirculation() public view returns(uint256){
        return _totalSupply.sub(balances[owner]).sub(balances[address(this)]).sub(balances[DEV_ADDRESS]);
    }
    
    function pendingReward(address _user) external view returns(uint256){
        uint256 owing = dividendsOwing(_user);
        return owing;
    }
    
    function dividendsOwing(address investor) internal view returns (uint256){
        if(investor != owner && investor != DEV_ADDRESS){
            uint256 newDividendPoints = totalDividentPoints.sub(accounts[investor].lastDividentPoints);
            return (((balances[investor]).mul(newDividendPoints)).div(pointMultiplier)).add(accounts[investor].pending);
        }
        else {
            return 0;
        }
    }
   
    function updateDividend(address investor) internal returns(uint256){
        uint256 owing = dividendsOwing(investor);
        if (owing > 0){
            accounts[investor].lastDividentPoints = totalDividentPoints;
            accounts[investor].pending = 0;
        }
        return owing;
    }
   
    function disburse(uint256 amount) internal{
        balances[address(this)] = balances[address(this)].add(amount);
        
        uint256 unnormalized = amount.mul(pointMultiplier);
        totalDividentPoints = totalDividentPoints.add(unnormalized.div(tokensInCirculation()));
    }
   
    function claimReward() external returns(bool){
        uint256 owing = updateDividend(msg.sender);
        
        require(owing > 0);

        require(_transfer(msg.sender, owing));
        
        accounts[msg.sender].rewardsClaimed = accounts[msg.sender].rewardsClaimed.add(owing);
       
        totalRewardsClaimed = totalRewardsClaimed.add(owing);
        return true;
    }
    
    function rewardsClaimed(address _user) external view returns(uint256 rewardClaimed){
        return accounts[_user].rewardsClaimed;
    }
}