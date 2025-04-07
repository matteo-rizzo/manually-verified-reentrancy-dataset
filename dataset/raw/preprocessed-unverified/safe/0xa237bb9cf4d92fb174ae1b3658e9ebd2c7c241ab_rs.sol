/**
 *Submitted for verification at Etherscan.io on 2021-06-07
*/

pragma solidity >=0.8.0;


// SPDX-License-Identifier: BSD-3-Clause

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





contract EU21_Netherlands is Ownable {
    using SafeMath for uint;
    using EnumerableSet for EnumerableSet.AddressSet;
    
    event RewardsTransferred(address holder, uint amount);
    
    // EU21 token contract address
    address public constant tokenAddress = 0x87ea1F06d7293161B9ff080662c1b0DF775122D3;
    
    // amount disbursed per victory
    uint public amountToDisburse = 1000000000000000000000;   // 1000 EU21 PER VICTORY
    
    // total games rewards for each pool    
    uint public totalReward = 7000000000000000000000; // 7000 EU21 TOTAL GAMES REWARDS (EXCLUDING THE GRAND PRIZE)
    
    // unstaking possible after ...
    uint public constant unstakeTime = 37 days;
    // claiming possible after ...
    uint public constant claimTime = 37 days;
    
    
    uint public totalClaimedRewards = 0;
    uint public totalDeposited = 0;
    uint public totalDisbursed = 0;
    bool public ended ;
    uint public startTime = block.timestamp;
    
    EnumerableSet.AddressSet private holders;
    
    mapping (address => uint) public depositedTokens;
    mapping (address => uint) public pending; 
    mapping (address => uint) public totalEarnedTokens;
    
    mapping (address => uint) public rewardEnded;
    
    function disburse () public onlyOwner returns (bool){
        require(!ended, "Staking already ended");
        
        
        address _hold;
        uint _add;
        for(uint i = 0; i < holders.length(); i = i.add(1)){
            _hold = holders.at(i);
            _add = depositedTokens[_hold].mul(amountToDisburse).div(totalDeposited);
            pending[_hold] = pending[_hold].add(_add);
        }
        totalDisbursed = totalDisbursed.add(amountToDisburse);
        return true;
        
    }
    //Disburse and End the staking pool
    function disburseAndEnd(uint _finalDisburseAmount) public onlyOwner returns (bool){
        require(!ended, "Staking already ended");
        require(_finalDisburseAmount > 0);
        
        address _hold;
        uint _add;
        for(uint i = 0; i < holders.length(); i = i.add(1)){
            _hold = holders.at(i);
            _add = depositedTokens[_hold].mul(_finalDisburseAmount).div(totalDeposited);
            pending[_hold] = pending[_hold].add(_add);
        }
        totalDisbursed = totalDisbursed.add(_finalDisburseAmount);
        
        ended = true;
        return true;
    }
    
    //End the staking pool
    function end() public onlyOwner returns (bool){
        require(!ended, "Staking already ended");
                ended = true;
        return true;
    }
    
    function updateAccount(address account) private {
        uint pendingDivs = getPendingDivs(account);
        if (pendingDivs > 0) {
            pending[account] = 0;
            depositedTokens[account] = depositedTokens[account].add(pendingDivs);
            totalDeposited = totalDeposited.add(pendingDivs);
            totalEarnedTokens[account] = totalEarnedTokens[account].add(pendingDivs);
            totalClaimedRewards = totalClaimedRewards.add(pendingDivs);
        }
        
    }
    
    function getPendingDivs(address _holder) public view returns (uint) {
        if (!holders.contains(_holder)) return 0;
        
        uint pendingDivs = pending[_holder];
       
        return pendingDivs;
    }
    
    function getNumberOfHolders() public view returns (uint) {
        return holders.length();
    }
    
    
    function deposit(uint amountToStake) public {
        require(!ended, "Staking has ended");
        require(amountToStake > 0, "Cannot deposit 0 Tokens");
    
        require(Token(tokenAddress).transferFrom(msg.sender, address(this), amountToStake), "Insufficient Token Allowance");
        
        
        updateAccount(msg.sender);
        
        
        depositedTokens[msg.sender] = depositedTokens[msg.sender].add(amountToStake);
        totalDeposited = totalDeposited.add(amountToStake);
        
        if (!holders.contains(msg.sender)) {
            holders.add(msg.sender);
            
        }
        
    }
    function claim() public{
        require(holders.contains(msg.sender));
        require(block.timestamp.sub(startTime) > claimTime || ended, "Not yet.");
        require(pending[msg.sender] > 0);
        
        
        uint _reward = pending[msg.sender];
        pending[msg.sender] = 0;
        require(Token(tokenAddress).transfer(msg.sender, _reward), "Could not transfer tokens.");
        totalClaimedRewards = totalClaimedRewards.add(_reward);
        totalEarnedTokens[msg.sender] = totalEarnedTokens[msg.sender].add(_reward);
        
        if(depositedTokens[msg.sender] == 0){
            holders.remove(msg.sender);    
        }
    }
    function withdraw(uint _amount) public{
        require(block.timestamp.sub(startTime) > unstakeTime || ended, "Not yet.");
        require(depositedTokens[msg.sender] >= _amount);
        require(_amount > 0);
        
        
        depositedTokens[msg.sender] = depositedTokens[msg.sender].sub(_amount);
        totalDeposited = totalDeposited.sub(_amount);
        require(Token(tokenAddress).transfer(msg.sender, _amount), "Could not transfer tokens.");
        
        if(depositedTokens[msg.sender] == 0 && pending[msg.sender] == 0){
            holders.remove(msg.sender);    
        }
        
    }
    /*
    function withdrawAllAfterEnd() public {
        require(ended, "Staking has not ended");
       
        uint _pend = pending[msg.sender];
        uint amountToWithdraw = _pend.add(depositedTokens[msg.sender]);
        
        require(amountToWithdraw >= 0, "Invalid amount to withdraw");
        pending[msg.sender] = 0;
        depositedTokens[msg.sender] = 0;
        totalDeposited = totalDeposited.sub(depositedTokens[msg.sender]);
        require(Token(tokenAddress).transfer(msg.sender, amountToWithdraw), "Could not transfer tokens.");
        
        totalClaimedRewards = totalClaimedRewards.add(_pend);
        totalEarnedTokens[msg.sender] = totalEarnedTokens[msg.sender].add(_pend);
         
        holders.remove(msg.sender);
        
    }*/

    
    function getStakersList(uint startIndex, uint endIndex) 
        public 
        view 
        returns (address[] memory stakers, 
            uint[] memory stakingTimestamps, 
            uint[] memory lastClaimedTimeStamps,
            uint[] memory stakedTokens) {
        require (startIndex < endIndex);
        
        uint length = endIndex.sub(startIndex);
        address[] memory _stakers = new address[](length);
        uint[] memory _stakingTimestamps = new uint[](length);
        uint[] memory _lastClaimedTimeStamps = new uint[](length);
        uint[] memory _stakedTokens = new uint[](length);
        
        for (uint i = startIndex; i < endIndex; i = i.add(1)) {
            address staker = holders.at(i);
            uint listIndex = i.sub(startIndex);
            _stakers[listIndex] = staker;
            _stakedTokens[listIndex] = depositedTokens[staker];
        }
        
        return (_stakers, _stakingTimestamps, _lastClaimedTimeStamps, _stakedTokens);
    }
    
    // function to allow admin to claim *other* ERC20 tokens sent to this contract (by mistake)
    function transferAnyERC20Tokens(address _tokenAddr, address _to, uint _amount) public onlyOwner {
        require (_tokenAddr != tokenAddress , "Cannot Transfer Out this token");
        Token(_tokenAddr).transfer(_to, _amount);
    }
}