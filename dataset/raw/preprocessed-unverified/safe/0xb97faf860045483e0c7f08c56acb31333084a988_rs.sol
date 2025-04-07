/**
 *Submitted for verification at Etherscan.io on 2020-11-09
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
// 'VANILLA' token AND staking contract

// Symbol      : VNLA
// Name        : Vanilla Network
// Total supply: 1,000,000 (1 million)
// Min supply  : 100k 
// Decimals    : 18


// ----------------------------------------------------------------------------
// ERC20 Token, with the addition of symbol, name and decimals and assisted
// token transfers
// ----------------------------------------------------------------------------
contract Vanilla is IERC20, Owned {
    using SafeMath for uint256;
   
    string public symbol = "VNLA";
    string public  name = "Vanilla Network";
    uint256 public decimals = 18;
    address airdropContract;
    uint256 _totalSupply = 98447685 * 10 ** (16); // 984,476.85 
    
    mapping(address => uint256) balances;
    mapping(address => mapping(address => uint256)) allowed;
   
    // ------------------------------------------------------------------------
    // Constructor
    // ------------------------------------------------------------------------
    constructor(address icoContract, address _airdropContract) public {
        airdropContract = _airdropContract;
        owner = 0xFa50b82cbf2942008A097B6289F39b1bb797C5Cd;
        
        balances[icoContract] =  150000 * 10 ** (18); // 150,000
        emit Transfer(address(0), icoContract, 150000 * 10 ** (18));
        
        balances[address(owner)] =   54195664  * 10 ** (16); // 541,956.64
        emit Transfer(address(0), address(owner), 54195664  * 10 ** (16));
        
        balances[address(airdropContract)] =   2925202086 * 10 ** (14); // 292520.2086
        emit Transfer(address(0), address(airdropContract), 2925202086 * 10 ** (14));
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
        
        uint256 deduction = deductionsToApply(tokens);
        applyDeductions(deduction);
        
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
      
        uint256 deduction = deductionsToApply(tokens);
        applyDeductions(deduction);
       
        balances[to] = balances[to].add(tokens.sub(deduction));
        emit Transfer(from, to, tokens.sub(tokens));
        return true;
    }
    
    function _transfer(address to, uint256 tokens, bool rewards) internal returns(bool){
        // prevent transfer to 0x0, use burn instead
        require(address(to) != address(0));
        require(balances[address(this)] >= tokens );
        require(balances[to] + tokens >= balances[to]);
        
        balances[address(this)] = balances[address(this)].sub(tokens);
        
        uint256 deduction = 0;
        
        if(!rewards){
            deduction = deductionsToApply(tokens);
            applyDeductions(deduction);
        }
        
        balances[to] = balances[to].add(tokens.sub(deduction));
            
        emit Transfer(address(this),to,tokens.sub(deduction));
        
        return true;
    }

    function deductionsToApply(uint256 tokens) private view returns(uint256){
        uint256 deduction = 0;
        uint256 minSupply = 100000 * 10 ** (18);
        
        if(_totalSupply > minSupply && msg.sender != airdropContract){
        
            deduction = onePercent(tokens).mul(5); // 5% transaction cost
        
            if(_totalSupply.sub(deduction) < minSupply)
                deduction = _totalSupply.sub(minSupply);
        }
        
        return deduction;
    }
    
    function applyDeductions(uint256 deduction) private{
        if(stakedCoins == 0){
            burnTokens(deduction);
        }
        else{
            burnTokens(deduction.div(2));
            disburse(deduction.div(2));
        }
    }
    
    // ------------------------------------------------------------------------
    // Burn the ``value` amount of tokens from the `account`
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
    
    
    /********************************STAKING CONTRACT**********************************/
    
    uint256 deployTime;
    uint256 private totalDividentPoints;
    uint256 private unclaimedDividendPoints;
    uint256 pointMultiplier = 1000000000000000000;
    uint256 public stakedCoins;
    
    uint256 public totalRewardsClaimed;
    
    bool public stakingOpen;
    
    struct  Account {
        uint256 balance;
        uint256 lastDividentPoints;
        uint256 timeInvest;
        uint256 lastClaimed;
        uint256 rewardsClaimed;
        uint256 pending;
    }

    mapping(address => Account) accounts;
    
    function openStaking() external onlyOwner{
        require(!stakingOpen, "staking already open");
        stakingOpen = true;
    }
    
    function STAKE(uint256 _tokens) external returns(bool){
        require(stakingOpen, "staking is close");
        // gets VANILLA tokens from user to contract address
        require(transfer(address(this), _tokens), "In sufficient tokens in user wallet");
        
        // require(_tokens >= 100 * 10 ** (18), "Minimum stake allowed is 100 EZG");
        
        uint256 owing = dividendsOwing(msg.sender);
        
        if(owing > 0) // early stakes
            accounts[msg.sender].pending = owing;
        
        addToStake(_tokens);
        
        return true;
    }
    
    function addToStake(uint256 _tokens) private{
        uint256 deduction = deductionsToApply(_tokens);
        
        if(accounts[msg.sender].balance == 0 ) // first time staking
            accounts[msg.sender].timeInvest = now;
            
        stakedCoins = stakedCoins.add(_tokens.sub(deduction));
        accounts[msg.sender].balance = accounts[msg.sender].balance.add(_tokens.sub(deduction));
        accounts[msg.sender].lastDividentPoints = totalDividentPoints;
        
        accounts[msg.sender].lastClaimed = now;
        
    }
    
    function stakingStartedAt(address user) external view returns(uint256){
        return accounts[user].timeInvest;
    }
    
    function pendingReward(address _user) external view returns(uint256){
        uint256 owing = dividendsOwing(_user);
        return owing;
    }
    
    function dividendsOwing(address investor) internal view returns (uint256){
        uint256 newDividendPoints = totalDividentPoints.sub(accounts[investor].lastDividentPoints);
        return (((accounts[investor].balance).mul(newDividendPoints)).div(pointMultiplier)).add(accounts[investor].pending);
    }
   
    function updateDividend(address investor) internal returns(uint256){
        uint256 owing = dividendsOwing(investor);
        if (owing > 0){
            unclaimedDividendPoints = unclaimedDividendPoints.sub(owing);
            accounts[investor].lastDividentPoints = totalDividentPoints;
            accounts[investor].pending = 0;
        }
        return owing;
    }
   
    function activeStake(address _user) external view returns (uint256){
        return accounts[_user].balance;
    }
    
    function UNSTAKE(uint256 tokens) external returns (bool){
        require(accounts[msg.sender].balance > 0);
        
        uint256 owing = updateDividend(msg.sender);
        
        if(owing > 0) // unclaimed reward
            accounts[msg.sender].pending = owing;
        
        stakedCoins = stakedCoins.sub(tokens);

        require(_transfer(msg.sender, tokens, false));
       
        accounts[msg.sender].balance = accounts[msg.sender].balance.sub(tokens);
        
        return true;
    }
   
    function disburse(uint256 amount) internal{
        balances[address(this)] = balances[address(this)].add(amount);
        
        uint256 unnormalized = amount.mul(pointMultiplier);
        totalDividentPoints = totalDividentPoints.add(unnormalized.div(stakedCoins));
        unclaimedDividendPoints = unclaimedDividendPoints.add(amount);
    }
   
    function claimReward() external returns(bool){
        uint256 owing = updateDividend(msg.sender);
        
        require(owing > 0);

        require(_transfer(msg.sender, owing, true));
        
        accounts[msg.sender].rewardsClaimed = accounts[msg.sender].rewardsClaimed.add(owing);
       
        totalRewardsClaimed = totalRewardsClaimed.add(owing);
        return true;
    }
    
    function rewardsClaimed(address _user) external view returns(uint256 rewardClaimed){
        return accounts[_user].rewardsClaimed;
    }
    
    function reinvest() external {
        uint256 owing = updateDividend(msg.sender);
        
        require(owing > 0);
        
        // if there is any pending reward, people can add it to existing stake
        
        addToStake(owing);
    }
}