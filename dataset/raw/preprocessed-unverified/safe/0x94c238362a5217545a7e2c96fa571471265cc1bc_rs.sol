/**
 *Submitted for verification at Etherscan.io on 2021-02-21
*/

pragma solidity ^0.5.0;

/**
 * @dev Interface of the ERC20 standard as defined in the EIP. Does not include
 * the optional functions; to access them see {ERC20Detailed}.
 */



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


/**
 * @dev Collection of functions related to the address type
 */



/**
 * @title SafeERC20
 * @dev Wrappers around ERC20 operations that throw on failure (when the token
 * contract returns false). Tokens that return no value (and instead revert or
 * throw on failure) are also supported, non-reverting calls are assumed to be
 * successful.
 * To use this library you can add a `using SafeERC20 for ERC20;` statement to your contract,
 * which allows you to call the safe operations as `token.safeTransfer(...)`, etc.
 */




contract RoomLPProgram {

    using SafeMath for uint256;
    using SafeERC20 for IERC20;

    
    // TODO: Please do not forget to call the approve for this contract from the wallet.
    address public roomTokenRewardsReservoirAddress = 0x86181Ff88BDEC75d5f007cEfEE31087C8327dF77;
    address public owner;
    
    // This is ROOM/ETH LP ERC20 address.
    IERC20 public constant roomLPToken = IERC20(0xBE55c87dFf2a9f5c95cB5C07572C51fd91fe0732);

    // This is the correct CRC address of the ROOM token
    IERC20 public constant roomToken = IERC20(0xAd4f86a25bbc20FfB751f2FAC312A0B4d8F88c64);

    // total Room LP staked
    uint256 private _totalStaked;

    // last updated block number
    uint256 public lastUpdateBlock;

    uint256 private  _accRewardPerToken; // accumulative reward per token
    uint256 private  _rewardPerBlock;   // reward per block
    uint256 public  finishBlock; // finish rewarding block number
    uint256 public  endTime;

    mapping(address => uint256) private _rewards; // rewards balances
    mapping(address => uint256) private _prevAccRewardPerToken; // previous accumulative reward per token (for a user)
    mapping(address => uint256) private _balances; // balances per user
    
   
    event Staked(address indexed user, uint256 amount);
    event Unstaked(address indexed user, uint256 amount);
    event ClaimReward(address indexed user, uint256 reward);
    event FarmingParametersChanged(uint256 rewardPerBlock, uint256 rewardBlockCount, address indexed roomTokenRewardsReservoirAdd);
    event RewardTransferFailed(TransferRewardState failure);
    
    enum TransferRewardState {
        Succeeded,
        RewardWalletEmpty
    }
    
    constructor () public {

        owner = msg.sender;
       
        uint256 rewardBlockCount = 1036800;  // 5760 * 30 * 6; six months = 1,036,800 blocks
        uint256 totalRewards = 240000e18;  // total rewards 240,000 Room in six months
       
        _rewardPerBlock = totalRewards * (1e18) / rewardBlockCount; // *(1e18) for math precisio
        
        finishBlock = blockNumber() + rewardBlockCount;
        endTime = ((finishBlock-blockNumber()) * 15) + (block.timestamp);
        lastUpdateBlock = blockNumber();
    }

    function changeFarmingParameters(uint256 rewardPerBlock, uint256 rewardBlockCount, address roomTokenRewardsReservoirAdd) external {

        require(msg.sender == owner, "can be called by owner only");
        updateReward(address(0));
        _rewardPerBlock = rewardPerBlock.mul(1e18); // for math precision
        
        finishBlock = blockNumber().add(rewardBlockCount);
        endTime = finishBlock.sub(blockNumber()).mul(15).add(block.timestamp);
        roomTokenRewardsReservoirAddress = roomTokenRewardsReservoirAdd;

        emit FarmingParametersChanged(_rewardPerBlock, rewardBlockCount, roomTokenRewardsReservoirAddress);
    }

    function updateReward(address account) public {
        // reward algorithm
        // in general: rewards = (reward per token ber block) user balances
        uint256 cnBlock = blockNumber();

        // update accRewardPerToken, in case totalStaked is zero; do not increment accRewardPerToken
        if (totalStaked() > 0) {
            uint256 lastRewardBlock = cnBlock < finishBlock ? cnBlock : finishBlock;
            if (lastRewardBlock > lastUpdateBlock) {
                _accRewardPerToken = lastRewardBlock.sub(lastUpdateBlock)
                .mul(_rewardPerBlock)
                .div(totalStaked())
                .add(_accRewardPerToken);
            }
        }

        lastUpdateBlock = cnBlock;

        if (account != address(0)) {

            uint256 accRewardPerTokenForUser = _accRewardPerToken.sub(_prevAccRewardPerToken[account]);

            if (accRewardPerTokenForUser > 0) {
                _rewards[account] =
                _balances[account]
                .mul(accRewardPerTokenForUser)
                .div(1e18)
                .add(_rewards[account]);

                _prevAccRewardPerToken[account] = _accRewardPerToken;
            }
        }
    }

    function stake(uint256 amount) external {
        updateReward(msg.sender);

        _totalStaked = _totalStaked.add(amount);
        _balances[msg.sender] = _balances[msg.sender].add(amount);

        // Transfer from owner of Room Token to this address.
        roomLPToken.safeTransferFrom(msg.sender, address(this), amount);
        emit Staked(msg.sender, amount);
    }

    function unstake(uint256 amount, bool claim) external returns(uint256 reward, TransferRewardState reason) {
        updateReward(msg.sender);


        _totalStaked = _totalStaked.sub(amount);
        _balances[msg.sender] = _balances[msg.sender].sub(amount);
        // Send Room token staked to the original owner.
        roomLPToken.safeTransfer(msg.sender, amount);
       

        if (claim) {
          (reward, reason) = _executeRewardTransfer(msg.sender);
        }
        
         emit Unstaked(msg.sender, amount);
    }
    
    function claimReward() external returns (uint256 reward, TransferRewardState reason) {
        updateReward(msg.sender);

        return _executeRewardTransfer(msg.sender);
    }
    
    function _executeRewardTransfer(address account) internal returns(uint256 reward, TransferRewardState reason) {
        
        reward = _rewards[account];
        if (reward > 0) {
            uint256 walletBalanace = roomToken.balanceOf(roomTokenRewardsReservoirAddress);
            if (walletBalanace < reward) {
                // This fails, and we send reason 1 for the UI
                // to display a meaningful message for the user.
                // 1 means the wallet is empty.
                reason = TransferRewardState.RewardWalletEmpty;
                emit RewardTransferFailed(reason);
                
            } else {
                
                // We will transfer and then empty the rewards
                // for the sender.
                _rewards[msg.sender] = 0;
                roomToken.transferFrom(roomTokenRewardsReservoirAddress, msg.sender, reward);
                emit ClaimReward(msg.sender, reward);
            }
        }
    }

    function rewards(address account) external view returns (uint256 reward) {
        // read version of update
        uint256 cnBlock = blockNumber();
        uint256 accRewardPerToken = _accRewardPerToken;

        // update accRewardPerToken, in case totalStaked is zero; do not increment accRewardPerToken
        if (totalStaked() > 0) {
            uint256 lastRewardBlock = cnBlock < finishBlock ? cnBlock : finishBlock;
            if (lastRewardBlock > lastUpdateBlock) {
                accRewardPerToken = lastRewardBlock.sub(lastUpdateBlock)
                .mul(_rewardPerBlock).div(totalStaked())
                .add(accRewardPerToken);
            }
        }

        reward = _balances[account]
        .mul(accRewardPerToken.sub(_prevAccRewardPerToken[account]))
        .div(1e18)
        .add(_rewards[account]);
    }

    function info() external view returns (
                                uint256 cBlockNumber, 
                                uint256 rewardPerBlock,
                                uint256 rewardFinishBlock,
                                uint256 rewardEndTime,
                                uint256 walletBalance) {
        cBlockNumber = blockNumber();
        rewardFinishBlock = finishBlock;
        rewardPerBlock = _rewardPerBlock.div(1e18);
        rewardEndTime = endTime;
        walletBalance = roomToken.balanceOf(roomTokenRewardsReservoirAddress);
    }

    // expected reward,
    // please note this is only an estimation, because total balance may change during the program
    function expectedRewardsToday(uint256 amount) external view returns (uint256 reward) {

        uint256 cnBlock = blockNumber();
        uint256 prevAccRewardPerToken = _accRewardPerToken;

        uint256 accRewardPerToken = _accRewardPerToken;
        // update accRewardPerToken, in case totalStaked is zero do; not increment accRewardPerToken

        uint256 lastRewardBlock = cnBlock < finishBlock ? cnBlock : finishBlock;
        if (lastRewardBlock > lastUpdateBlock) {
            accRewardPerToken = lastRewardBlock.sub(lastUpdateBlock)
            .mul(_rewardPerBlock).div(totalStaked().add(amount))
            .add(accRewardPerToken);
        }

        uint256 rewardsPerBlock = amount
        .mul(accRewardPerToken.sub(prevAccRewardPerToken))
        .div(1e18);

        
        reward = rewardsPerBlock.mul(5760); // 5760 blocks per day
    }

    function balanceOf(address account) public view returns (uint256) {
        return _balances[account];
    }

    function totalStaked() public view returns (uint256) {
        return _totalStaked;
    }

    function blockNumber() public view returns (uint256) {
        return block.number;
    }
}