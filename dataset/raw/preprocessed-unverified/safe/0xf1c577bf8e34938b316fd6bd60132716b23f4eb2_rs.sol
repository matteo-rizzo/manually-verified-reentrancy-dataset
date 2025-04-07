pragma solidity 0.6.12;

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





contract Staking is Ownable {
    using SafeMath for uint;
    using EnumerableSet for EnumerableSet.AddressSet;
    
    event RewardsTransferred(address holder, uint amount);
    
    // staking token contract address
    address public constant tokenAddress = 0x640A94042CC184b693D5a535a6898C99200a1EC2;

    
    uint public totalClaimedRewards = 0;
    
    EnumerableSet.AddressSet private holders;
    
    mapping (address => uint) public depositedTokens;
    mapping (address => uint) public stakingTime;
    mapping (address => uint) public lastClaimedTime;
    mapping (address => uint) public totalEarnedTokens;
    mapping (address => uint) public lastDivPoints;
    uint public totalDivPoints = 0;
    uint public totalTokens = 0;
    uint internal pointMultiplier = 1e18;
    
    function updateAccount(address account) private {
        uint pendingDivs = getPendingDivs(account);
        if (pendingDivs > 0) {
            require(Token(tokenAddress).transfer(account, pendingDivs), "Could not transfer tokens.");
            totalEarnedTokens[account] = totalEarnedTokens[account].add(pendingDivs);
            totalClaimedRewards = totalClaimedRewards.add(pendingDivs);
            emit RewardsTransferred(account, pendingDivs);
        }
        lastClaimedTime[account] = now;
        lastDivPoints[account] = totalDivPoints;
    }
    
    function getPendingDivs(address _holder) public view returns (uint) {
        if (!holders.contains(_holder)) return 0;
        if (depositedTokens[_holder] == 0) return 0;
        
        uint newDivPoints = totalDivPoints.sub(lastDivPoints[_holder]);

        uint stakedAmount = depositedTokens[_holder];
        
        uint pendingDivs = stakedAmount.mul(newDivPoints).div(pointMultiplier);
            
        return pendingDivs;
    }
    
    function getNumberOfStakers() public view returns (uint) {
        return holders.length();
    }
    
    
    function stake(uint amountToStake) public {
        
        require(amountToStake > 0, "Cannot deposit 0 Tokens");
        
        updateAccount(msg.sender);
        
        require(Token(tokenAddress).transferFrom(msg.sender, address(this), amountToStake), "Insufficient Token Allowance");
        
        uint txFee1 = amountToStake.mul(400).div(10000);
        uint txFee2 = amountToStake.mul(400).div(10000);
        uint amountAfterFee = amountToStake.sub(txFee1).sub(txFee2);
        
        depositedTokens[msg.sender] = depositedTokens[msg.sender].add(amountAfterFee);
        totalTokens = totalTokens.add(amountAfterFee);
        
        if (!holders.contains(msg.sender)) {
            holders.add(msg.sender);
            stakingTime[msg.sender] = now;
        }
    }
    
    function unstake(uint amountToWithdraw) public {
        require(depositedTokens[msg.sender] >= amountToWithdraw, "Invalid amount to withdraw");

        updateAccount(msg.sender);

        require(Token(tokenAddress).transfer(msg.sender, amountToWithdraw), "Could not transfer tokens.");
        
        depositedTokens[msg.sender] = depositedTokens[msg.sender].sub(amountToWithdraw);
        totalTokens = totalTokens.sub(amountToWithdraw);
        
        if (holders.contains(msg.sender) && depositedTokens[msg.sender] == 0) {
            holders.remove(msg.sender);
        }
    }
    
    function claim() public {
        updateAccount(msg.sender);
    }
    
    function distributeDivs(uint amount) private {
        if (totalTokens == 0) return;
        totalDivPoints = totalDivPoints.add(amount.mul(pointMultiplier).div(totalTokens));
    }
    
    function receiveApproval(address _from, uint256 _value, bytes memory _extraData) public {
        require(msg.sender == tokenAddress);
        distributeDivs(_value);
    }
    

    // function to allow owner to claim *other* ERC20 tokens sent to this contract
    function transferAnyERC20Tokens(address _tokenAddr, address _to, uint _amount) public onlyOwner {
        if (_tokenAddr == tokenAddress) {
                revert();
        }
        Token(_tokenAddr).transfer(_to, _amount);
    }
}