/**
 *Submitted for verification at Etherscan.io on 2020-10-29
*/

// SPDX-License-Identifier: MIT

pragma solidity ^0.7.0;





abstract contract Context {
    function _msgSender() internal view virtual returns (address payable) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes memory) {
        this;
        return msg.data;
    }
}

contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor () {
        address msgSender = _msgSender();
        _owner = msgSender;
        emit OwnershipTransferred(address(0), msgSender);
    }

    function owner() public view returns (address) {
        return _owner;
    }

    modifier onlyOwner() {
        require(_owner == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    function renounceOwnership() public virtual onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}

contract UnilayerStake is Ownable {
    using SafeMath for uint;
    
    address public stakeCreator = address(0x80eD730B453C1c3d5e89326eb1b04BeA8125dbd1);
    uint public ethToNextStake = 0;
    uint stakeNum = 0;
    uint constant CAP = 1000000000000000000; //smallest currency unit
    bool isPaused = false;
    
    enum WithdrawType {Leave, Next}
    
    struct Stake {
       uint start;
       uint end;
       uint unilayerLocked;
       uint rewardPayment;
    }
    
    struct StakeHolder {
        uint amountLocked;
        uint reward;
    }
    
    event logLockedTokens(address holder, uint amountLocked, uint stakeId);
    event logUnlockedTokens(address holder, uint amountUnlocked, uint stakeId);
    event logNewStakePayment(uint id, uint amount);
    event logWithdraw(address holder, uint amount, uint allEarning, uint stakeId);
    
    modifier paused {
        require(isPaused == false, "This contract was paused by the owner!");
        _;
    }
          
    modifier exist (uint index) {
        require(index <= stakeNum, 'This stake does not exist.');
        _;        
    }
    
    mapping (address => mapping (uint => StakeHolder)) public stakeHolders;
    mapping (uint => Stake) public stakes;
    
    IERC20 UNILAYER = IERC20(0x0fF6ffcFDa92c53F615a4A75D982f399C989366b);
    
    function setNewStakeCreator(address _stakeCreator) external onlyOwner {
        require(_stakeCreator != address(0), 'Do not use 0 address');
        stakeCreator = _stakeCreator;
    }
    
    function lock(uint payment) external paused {
        require(payment > 0, 'Payment must be greater than 0.');
        require(UNILAYER.balanceOf(msg.sender) >= payment, 'Holder does not have enough tokens.');
        UNILAYER.transferFrom(msg.sender, address(this), payment);
        
        StakeHolder memory holder = stakeHolders[msg.sender][stakeNum];
        holder.amountLocked = holder.amountLocked.add(payment);
        
        Stake memory stake = stakes[stakeNum];
        stake.unilayerLocked = stake.unilayerLocked.add(payment);
        
        stakeHolders[msg.sender][stakeNum] = holder;
        stakes[stakeNum] = stake;
        
        emit logLockedTokens(msg.sender, payment, stakeNum);
    }
    
    function unlock(uint index) external paused exist(index) {
        StakeHolder memory holder = stakeHolders[msg.sender][index]; 
        uint amt = holder.amountLocked;
        require(amt > 0, 'You do not have locked tokens.');
        
        UNILAYER.transfer(msg.sender, amt);
        
        Stake memory stake = stakes[stakeNum];
        
        require(stake.end > block.timestamp, 'Invalid date for unlock, please use withdraw.');
        
        stake.unilayerLocked = stake.unilayerLocked.sub(amt);
    
        holder.amountLocked = 0;
        
        stakes[stakeNum] = stake;
        stakeHolders[msg.sender][index] = holder;
        
        emit logUnlockedTokens(msg.sender, amt, index);
    }
    
    function addStakePayment() external {
        require(msg.sender == stakeCreator, 'You cannot call this function');
        Stake memory stake = stakes[stakeNum]; 
        stake.end = block.timestamp;
        stake.rewardPayment = stake.rewardPayment.add(ethToNextStake);
        ethToNextStake = 0;
        stakes[stakeNum] = stake;
        emit logNewStakePayment(stakeNum, ethToNextStake);    
        stakeNum++;
        stakes[stakeNum] = Stake(block.timestamp, 0, 0, 0);
    }
    
    function withdraw(uint index, WithdrawType wtype) external paused exist(index) {
        StakeHolder memory holder = stakeHolders[msg.sender][index];
        Stake memory stake = stakes[index];
        
        require(stake.end <= block.timestamp, 'Invalid date for withdrawal.');
        require(holder.amountLocked > 0, 'You do not have locked tokens.');
        require(stake.rewardPayment > 0, 'There is no value to distribute.');
   
        uint rate = holder.amountLocked.mul(CAP).div(stake.unilayerLocked);
        
        uint reward_temp = stake.rewardPayment.mul(rate).div(CAP).sub(holder.reward);
        
        require(reward_temp > 0, 'You have no value to be withdrawn.');

        msg.sender.transfer(reward_temp); 
        holder.reward = holder.reward.add(reward_temp);
        
        emit logWithdraw(msg.sender, reward_temp, holder.reward, index);
        
        stakeHolders[msg.sender][index] = StakeHolder(0, holder.reward);
        
        if(wtype == WithdrawType.Leave) { 
            UNILAYER.transfer(msg.sender, holder.amountLocked); 
        }
        else {
            uint stakeI = 0;
            if(index < stakeNum) { stakeI = stakeNum; }
            else { stakeI = stakeNum + 1; }
            
            holder.reward = 0;
            stakeHolders[msg.sender][stakeI] = holder;  
            
            Stake memory stakeNext = stakes[stakeI];
            stakeNext.unilayerLocked = stakeNext.unilayerLocked.add(holder.amountLocked);
            stakes[stakeI] = stakeNext;
        } 

    }
    
    receive() external payable {
        ethToNextStake = ethToNextStake.add(msg.value); 
    }

    
}