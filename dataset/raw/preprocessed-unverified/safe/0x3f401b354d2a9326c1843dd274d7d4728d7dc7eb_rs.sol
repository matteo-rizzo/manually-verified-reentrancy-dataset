/**
 *Submitted for verification at Etherscan.io on 2020-12-10
*/

/**
 *Submitted for verification at Etherscan.io on 2020-12-10
*/

pragma solidity 0.6.12;

// SPDX-License-Identifier: No License

/**
 * @title SafeMath
 * @dev Math operations with safety checks that throw on error
 */


/**
 * @dev Library for managing
 * https://en.wikipedia.org/wiki/Set_(abstract_data_type)[sets] of primitive
 * types.
 *
 * Sets have the following properties:
 *
 * - Elements are added, removed, and checked for existence in constant time
 * (O(1)).
 * - Elements are enumerated in O(n). No guarantees are made on the ordering.
 *
 * ```
 * contract Example {
 *     // Add the library methods
 *     using EnumerableSet for EnumerableSet.AddressSet;
 *
 *     // Declare a set state variable
 *     EnumerableSet.AddressSet private mySet;
 * }
 * ```
 *
 * As of v3.0.0, only sets of type `address` (`AddressSet`) and `uint256`
 * (`UintSet`) are supported.
 */


/**
 * @title Ownable
 * @dev The Ownable contract has an owner address, and provides basic authorization control
 * functions, this simplifies the implementation of "user permissions".
 */





contract PRDZstaking is Ownable {
    using SafeMath for uint;
    using EnumerableSet for EnumerableSet.AddressSet;
    
    event RewardsTransferred(address holder, uint amount);
    
    // PRDZ token contract address
    address public constant tokenAddress = 0x4e085036A1b732cBe4FfB1C12ddfDd87E7C3664d;
    
    // reward rate 80.00% per year
    uint public constant rewardRate = 8000;
    uint public constant scoreRate = 1000;
    
    uint public constant rewardInterval = 365 days;
    uint public constant scoreInterval = 3 days;
    
    uint public scoreEth = 11340;
    
      // unstaking fee 2.00 percent
    uint public constant unstakingFeeRate = 250;
    
    // unstaking possible after 72 hours
    uint public constant cliffTime = 72 hours;
    
    uint public totalClaimedRewards = 0;
    uint public totalStakedToken = 0;
    
    EnumerableSet.AddressSet private holders;
    
    mapping (address => uint) public depositedTokens;
    mapping (address => uint) public stakingTime;
    mapping (address => uint) public lastClaimedTime;
    mapping (address => uint) public totalEarnedTokens;
    mapping (address => uint) public totalScore;
    mapping (address => uint) public lastScoreTime;
    
    function updateAccount(address account) private {
        uint pendingDivs = getPendingDivs(account);
        if (pendingDivs > 0) {
            require(Token(tokenAddress).transfer(account, pendingDivs), "Could not transfer tokens.");
            totalEarnedTokens[account] = totalEarnedTokens[account].add(pendingDivs);
            totalClaimedRewards = totalClaimedRewards.add(pendingDivs);
            emit RewardsTransferred(account, pendingDivs);
        }
        lastClaimedTime[account] = now;
    }


    
    function updateScore(address _holder) private  {
       
        
        lastScoreTime[_holder] = now    ;

      
      
    
    }

   function getScoreEth(address _holder) public view returns (uint) {
           uint timeDiff = 0 ;
           if(lastScoreTime[_holder] > 0){
            timeDiff = now.sub(lastScoreTime[_holder]).div(2);            
           }

            uint stakedAmount = depositedTokens[_holder];
       
       
            uint score = stakedAmount
                            .mul(scoreRate)
                            .mul(timeDiff)
                            .div(scoreInterval)
                            .div(1e4);
       
        uint eth = score.div(scoreEth);
        
        return eth;
        

    }

       function getStakingScore(address _holder) public view returns (uint) {
           uint timeDiff = 0 ;
           if(lastScoreTime[_holder] > 0){
            timeDiff = now.sub(lastScoreTime[_holder]).div(2);            
           }

            uint stakedAmount = depositedTokens[_holder];
       
       
            uint score = stakedAmount
                            .mul(scoreRate)
                            .mul(timeDiff)
                            .div(scoreInterval)
                            .div(1e4);
        return score;
    }
    
    
    function getPendingDivs(address _holder) public view returns (uint) {
        if (!holders.contains(_holder)) return 0;
        if (depositedTokens[_holder] == 0) return 0;

        uint timeDiff = now.sub(lastClaimedTime[_holder]);
        uint stakedAmount = depositedTokens[_holder];
        
        uint pendingDivs = stakedAmount
                            .mul(rewardRate)
                            .mul(timeDiff)
                            .div(rewardInterval)
                            .div(1e4);
            
        return pendingDivs;
    }
    
    function getNumberOfHolders() public view returns (uint) {
        return holders.length();
    }

      function getTotalStaked() public view returns (uint) {
        return totalStakedToken;
    }
    
    
    function stake(uint amountToStake) public {
        require(amountToStake > 0, "Cannot deposit 0 Tokens");
        require(Token(tokenAddress).transferFrom(msg.sender, address(this), amountToStake), "Insufficient Token Allowance");
        
        updateAccount(msg.sender);
        updateScore(msg.sender);
        
        depositedTokens[msg.sender] = depositedTokens[msg.sender].add(amountToStake);
        totalStakedToken = totalStakedToken.add(amountToStake);
        if (!holders.contains(msg.sender)) {
            holders.add(msg.sender);
            stakingTime[msg.sender] = now;
        }
    }
    
     
    function OldStake(address _holder , uint amountToStake , uint stakeTime) public onlyOwner {
        require(amountToStake > 0, "Cannot deposit 0 Tokens");
        require(Token(tokenAddress).transferFrom(msg.sender, address(this), amountToStake), "Insufficient Token Allowance");
        
        lastClaimedTime[_holder] = stakeTime;
        lastScoreTime[_holder] = stakeTime    ;
        totalStakedToken = totalStakedToken.add(amountToStake);

        
        depositedTokens[_holder] = depositedTokens[_holder].add(amountToStake);
        
        if (!holders.contains(_holder)) {
            holders.add(_holder);
            stakingTime[_holder] = stakeTime;
        }
    }


    function unstake(uint amountToWithdraw) public {
        require(depositedTokens[msg.sender] >= amountToWithdraw, "Invalid amount to withdraw");
        
         
        updateAccount(msg.sender);


        
        uint fee = amountToWithdraw.mul(unstakingFeeRate).div(1e4);
        uint amountAfterFee = amountToWithdraw.sub(fee);
        
        require(Token(tokenAddress).transfer(owner, fee), "Could not transfer withdraw fee.");
        require(Token(tokenAddress).transfer(msg.sender, amountAfterFee), "Could not transfer tokens.");
        totalStakedToken = totalStakedToken.sub(amountAfterFee);
        
            uint timeDiff = 0 ;
           if(lastScoreTime[msg.sender] > 0){
            timeDiff = now.sub(lastScoreTime[msg.sender]).div(2);            
           }
      
            uint score = amountAfterFee
                            .mul(scoreRate)
                            .mul(timeDiff)
                            .div(scoreInterval)
                            .div(1e4);
            
        
         
             uint eth = score.div(scoreEth);     
             msg.sender.transfer(eth);
             lastScoreTime[msg.sender] = now;


        depositedTokens[msg.sender] = depositedTokens[msg.sender].sub(amountToWithdraw);
        
        if (holders.contains(msg.sender) && depositedTokens[msg.sender] == 0) {
            holders.remove(msg.sender);
        }
    }
    
    function claimReward() public {
        updateAccount(msg.sender);
    }


  function withdraw() public onlyOwner{
                msg.sender.transfer(address(this).balance);
    }
  
     function claimScoreEth() public {
         uint timeDiff = 0 ;
           if(lastScoreTime[msg.sender] > 0){
            timeDiff = now.sub(lastScoreTime[msg.sender]).div(2);            
           }

            uint stakedAmount = depositedTokens[msg.sender];
       
       
            uint score = stakedAmount
                            .mul(scoreRate)
                            .mul(timeDiff)
                            .div(scoreInterval)
                            .div(1e4);
            
        
         
             uint eth = score.div(scoreEth);     
             msg.sender.transfer(eth);
            lastScoreTime[msg.sender] = now;
    }
    
    uint private constant stakingAndDaoTokens = 84000000000000000000000;
    
    function getStakingAndDaoAmount() public view returns (uint) {
        if (totalClaimedRewards >= stakingAndDaoTokens) {
            return 0;
        }
        uint remaining = stakingAndDaoTokens.sub(totalClaimedRewards);
        return remaining;
    }

    function deposit() payable public {
        // nothing to do!
    }
    
    function updateScoreEth(uint _amount) public onlyOwner {
            scoreEth = _amount ;
    }
    
    
    // function to allow admin to claim *other* ERC20 tokens sent to this contract (by mistake)
    function transferAnyERC20Tokens(address _tokenAddr, address _to, uint _amount) public onlyOwner {
        if (_tokenAddr == tokenAddress) {
            if (_amount > getStakingAndDaoAmount()) {
                revert();
            }
            totalClaimedRewards = totalClaimedRewards.add(_amount);
        }
        Token(_tokenAddr).transfer(_to, _amount);
    }
}