/**
 *Submitted for verification at Etherscan.io on 2021-04-12
*/

pragma solidity >=0.7.0;

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





contract VOTX_Staking is Ownable {
    using SafeMath for uint;
    using EnumerableSet for EnumerableSet.AddressSet;
    
    event RewardsTransferred(address holder, uint amount);
    
    // YFD token contract address
    address public constant tokenDepositAddress = 0x4F4F0Ef7978737ce928BFF395529161b44e27ad9;
    // VOTX token contract address
    address public constant tokenRewardAddress = 0xF94D66fb399a98b33563D87447B41A6A75bfFDF0;
    
    // Reward rate 208.00% per year
    uint public rewardRate = 1040000;
    uint public constant rewardInterval = 365 days;
    
    // Staking fee 1 percent
    uint public constant stakingFeeRate = 100;
    
    // Unstaking fee 0.50 percent
    uint public constant unstakingFeeRate = 50;
    
    // Unstaking possible after 30 days
    uint public constant unstakeTime = 30 days;
    // Claiming possible after 30 days
    uint public constant claimTime = 30 days;
    
    // Pool size = 1000 YFD
    uint public constant maxPoolSize = 1000000000000000000000;
    uint public poolSize = 1000000000000000000000;
    // Total rewards = 10000 VOTX
    uint public constant rewardsAvailable = 10000000000000000000000;
    
    uint public totalClaimedRewards = 0;
    uint public totalDeposited = 0;
    bool public ended ;
    
    EnumerableSet.AddressSet private holders;
    
    mapping (address => uint) public depositedTokens;
    mapping (address => uint) public stakingTime; //used for the unstaking locktime
    mapping (address => uint) public lastClaimedTime; //used for the claiming locktime
    mapping (address => uint) public totalEarnedTokens;
    
    mapping (address => uint) public rewardEnded;
    
    //End the staking pool
    function end() public onlyOwner returns (bool){
        require(!ended, "Staking already ended");
        
        
        for(uint i = 0; i < holders.length(); i = i.add(1)){
            rewardEnded[holders.at(i)] = getPendingDivs(holders.at(i));
        }
        
        ended = true;
        return true;
    }
    
    function getRewardsLeft() public view returns (uint){
       
        uint _res;
        if(ended){
            _res = 0;
        }else{
            uint totalPending;
            for(uint i = 0; i < holders.length(); i = i.add(1)){
                totalPending = totalPending.add(getPendingDivs(holders.at(i)));
            }
            _res = rewardsAvailable.sub(totalClaimedRewards).sub(totalPending);
        }
        
        return _res;
    }
    
    
    
    function updateAccount(address account) private {
        uint pendingDivs = getPendingDivs(account);
        if (pendingDivs > 0) {
            require(Token(tokenRewardAddress).transfer(account, pendingDivs), "Could not transfer tokens.");
            rewardEnded[account] = 0;
            totalEarnedTokens[account] = totalEarnedTokens[account].add(pendingDivs);
            totalClaimedRewards = totalClaimedRewards.add(pendingDivs);
            emit RewardsTransferred(account, pendingDivs);
        }
        lastClaimedTime[account] = block.timestamp;
    }
    
    function getPendingDivs(address _holder) public view returns (uint) {
        if (!holders.contains(_holder)) return 0;
        if (depositedTokens[_holder] == 0) return 0;
        uint pendingDivs;
        if(!ended){
             uint timeDiff = block.timestamp.sub(lastClaimedTime[_holder]);
             uint stakedAmount = depositedTokens[_holder];
        
             pendingDivs = stakedAmount
                                .mul(rewardRate) 
                               .mul(timeDiff)
                                .div(rewardInterval)
                                .div(1e4);
            
        }else{
            pendingDivs = rewardEnded[_holder];
        }
       
        return pendingDivs;
    }
    
    function getNumberOfHolders() public view returns (uint) {
        return holders.length();
    }
    
    
    function deposit(uint amountToStake) public {
        require(!ended, "Staking has ended");
        require(amountToStake > 0, "Cannot deposit 0 Tokens");
        require(amountToStake <= poolSize, "No space available");
        require(Token(tokenDepositAddress).transferFrom(msg.sender, address(this), amountToStake), "Insufficient Token Allowance");
        
        
        updateAccount(msg.sender);
        
        uint fee = amountToStake.mul(stakingFeeRate).div(1e4);
        uint amountAfterFee = amountToStake.sub(fee);
        require(Token(tokenDepositAddress).transfer(owner, fee), "Could not transfer deposit fee.");
        
        depositedTokens[msg.sender] = depositedTokens[msg.sender].add(amountAfterFee);
        poolSize = poolSize.sub(amountAfterFee);
        
        if (!holders.contains(msg.sender)) {
            holders.add(msg.sender);
            
        }
        stakingTime[msg.sender] = block.timestamp;
    }
    
    function withdraw(uint amountToWithdraw) public {
        require(depositedTokens[msg.sender] >= amountToWithdraw, "Invalid amount to withdraw");
        if(!ended){
            require(block.timestamp.sub(stakingTime[msg.sender]) > unstakeTime, "You recently staked, please wait before withdrawing.");
        }
        updateAccount(msg.sender);
        
        uint fee = amountToWithdraw.mul(unstakingFeeRate).div(1e4);
        uint amountAfterFee = amountToWithdraw.sub(fee);
        
        require(Token(tokenDepositAddress).transfer(owner, fee), "Could not transfer withdraw fee.");
        require(Token(tokenDepositAddress).transfer(msg.sender, amountAfterFee), "Could not transfer tokens.");
        
        depositedTokens[msg.sender] = depositedTokens[msg.sender].sub(amountToWithdraw);
        poolSize = poolSize.add(amountToWithdraw);
        
        if (holders.contains(msg.sender) && depositedTokens[msg.sender] == 0) {
            holders.remove(msg.sender);
        }
    }
    
    function claimDivs() public {
        if(!ended){
            require(block.timestamp.sub(lastClaimedTime[msg.sender]) > claimTime, "Not yet");
        }
        
        updateAccount(msg.sender);
    }
    
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
            _stakingTimestamps[listIndex] = stakingTime[staker];
            _lastClaimedTimeStamps[listIndex] = lastClaimedTime[staker];
            _stakedTokens[listIndex] = depositedTokens[staker];
        }
        
        return (_stakers, _stakingTimestamps, _lastClaimedTimeStamps, _stakedTokens);
    }
    
    // function to allow admin to claim *other* ERC20 tokens sent to this contract (by mistake)
    function transferAnyERC20Tokens(address _tokenAddr, address _to, uint _amount) public onlyOwner {
        require (_tokenAddr != tokenDepositAddress && _tokenAddr != tokenRewardAddress, "Cannot Transfer Out this token");
        Token(_tokenAddr).transfer(_to, _amount);
    }
}