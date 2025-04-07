/**
 *Submitted for verification at Etherscan.io on 2021-07-31
*/

pragma solidity ^0.5.12;
pragma experimental ABIEncoderV2;


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
 * @dev Interface of the ERC20 standard as defined in the EIP. Does not include
 * the optional functions; to access them see {ERC20Detailed}.
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


/**
 * @dev These functions deal with verification of Merkle trees (hash trees),
 */


contract DPRStaking {
    using SafeMath for uint256;
    using SafeERC20 for IERC20;
    uint256 DPR_UNIT = 10 ** 18;
    struct Period{
		bytes32  withdraw_root;
        uint256 start_time;
        uint256 end_time;
    }
    Period[] private periods;
    IERC20 public dpr;
    uint256 public staking_time = 270 days; // lock for 9 months
    uint256 private total_release_time; // linear release in 3 months
    uint256 private reward_time = 0;
    address public owner; 
    address public migrate_address;
    bool public pause;

	mapping (address => uint256) private user_staking_period_index;
    mapping (address => uint256) private user_staking_amount;
    mapping (address => uint256) private user_release_time;
    mapping (address => uint256) private user_claimed_map;
    mapping (address => string) private dpr_address_mapping;
    mapping (string => address) private address_dpr_mapping;
    mapping (address => Period) private user_staking_periods;
    mapping (address => uint256) private user_staking_time;
    uint256[8] private staking_level = [
        20000 * DPR_UNIT, // 100 credit
        46800 * DPR_UNIT, // 200 credit
        76800 * DPR_UNIT, // 300 credit
        138000 * DPR_UNIT, // 400 credit
        218000 * DPR_UNIT, // 500 credit
        288000 * DPR_UNIT, // 600 credit
        368000 * DPR_UNIT, // 700 credit
        468000 * DPR_UNIT // 800 credit
    ];


    
    //modifiers
    modifier onlyOwner() {
        require(msg.sender==owner, "DPRStaking: Only owner can operate this function");
        _;
    }

    modifier whenNotPaused(){
        require(pause == false, "DPRStaking: Pause!");
        _;
    }
    
    //events
    event Stake(address indexed user, string DPRAddress, uint256 indexed amount);
    event StakeChange(address indexed user, uint256 indexed oldAmount, uint256 indexed newAmount);
    event OwnerShipTransfer(address indexed oldOwner, address indexed newOwner);
    event DPRAddressChange(bytes32 oldAddress, bytes32 newAddress);
    event UserInfoChange(address indexed oldUser, address indexed newUser);
    event WithdrawAllFunds(address indexed to);
    event LinearTimeChange(uint256 day);
    event WithdrawStaking(address indexed _address, uint256 indexed _amount);
    event UpdateRewardTime(uint256 indexed _new_reward_time);
    event EndTimeChanged(uint256 indexed _new_end_time);
    event NewPeriod(uint256 indexed _start_time, uint256 indexed _end_time);
    event Migrate(address indexed migrate_address, uint256 indexed migrate_amount);
    event MigrateAddressSet(address indexed migrate_address);
	event RootSet(bytes32 indexed root, uint256 indexed _index);
    event ModifyPeriodTime(uint256 indexed _index, uint256 _start_time, uint256 _end_time);

    constructor(IERC20 _dpr) public {
        dpr = _dpr;
        total_release_time = 90 days; // for initialize
        owner = msg.sender;
    }

    function stake(string calldata DPRAddress, uint256 level) external whenNotPaused returns(bool){
       //Check current lastest staking period
       require(periods.length > 0, "DPRStaking: No active staking period");
       Period memory lastest_period = periods[periods.length.sub(1)];
       require(isInCurrentPeriod(),"DPRStaking: Staking not start or already end");
       require(level <= staking_level.length.sub(1), "DPRStaking: Level does not exist");
       require(user_staking_amount[msg.sender] == 0, "DPRStaking: Already stake, use addStaking instead");
       //check if address already set DPRAddress and DPRAddress is not in use
       checkDPRAddress(msg.sender, DPRAddress);
       uint256 staking_amount = staking_level[level];
       dpr.safeTransferFrom(msg.sender, address(this), staking_amount);
       user_staking_amount[msg.sender] = staking_amount;
       user_staking_time[msg.sender] = block.timestamp;
       dpr_address_mapping[msg.sender] = DPRAddress;
       address_dpr_mapping[DPRAddress] = msg.sender;
       //update user staking period
       user_staking_periods[msg.sender] = lastest_period;
	   user_staking_period_index[msg.sender] = periods.length.sub(1);
       emit Stake(msg.sender, DPRAddress, staking_amount);
       return true;
    }

    function addStaking(uint256 level) external  whenNotPaused returns(bool) {
        // staking period checking
        require(periods.length >0, "DPRStaking: No active staking period");
        require(checkPeriod(msg.sender), "DRPStaking: Not current period, try to move to lastest period");
        require(isInCurrentPeriod(), "DPRStaking: Staking not start or already end");
        require(level <= staking_level.length.sub(1), "DPRStaking: Level does not exist");
        uint256 newStakingAmount = staking_level[level];
        uint256 oldStakingAmount = user_staking_amount[msg.sender];
        require(oldStakingAmount > 0, "DPRStaking: Please Stake first");
        require(oldStakingAmount < newStakingAmount, "DPRStaking: Can only upgrade your level");
        uint256 difference = newStakingAmount.sub(oldStakingAmount);
        dpr.safeTransferFrom(msg.sender, address(this), difference);
        //update user staking amount
        user_staking_amount[msg.sender] = staking_level[level];
        user_staking_time[msg.sender] = block.timestamp;
        emit StakeChange(msg.sender, oldStakingAmount, newStakingAmount);
        return true;
    }

    function claim() external whenNotPaused returns(bool){
        require(reward_time > 0, "DPRStaking: Reward time not set");
        require(block.timestamp >= reward_time.add(staking_time), "DPRStaking: Not reach the release time");
        if(user_release_time[msg.sender] == 0){
            user_release_time[msg.sender] = reward_time.add(staking_time);
        }
        // user staking end time checking
        require(block.timestamp >= user_release_time[msg.sender], "DPRStaking: Not release period");
        uint256 staking_amount = user_staking_amount[msg.sender];
        require(staking_amount > 0, "DPRStaking: Must stake first");
        uint256 user_claimed = user_claimed_map[msg.sender];
        uint256 claim_per_period = staking_amount.mul(1 days).div(total_release_time);
        uint256 time_pass = block.timestamp.sub(user_release_time[msg.sender]).div(1 days);
        uint256 total_claim_amount = claim_per_period * time_pass;
        if(total_claim_amount >= user_staking_amount[msg.sender]){
            total_claim_amount = user_staking_amount[msg.sender];
            user_staking_amount[msg.sender] = 0;
        }
        user_claimed_map[msg.sender] = total_claim_amount;
        uint256 claim_this_time = total_claim_amount.sub(user_claimed);
        dpr.safeTransfer(msg.sender, claim_this_time);
        return true;
    }

    function transferOwnership(address newOwner) onlyOwner external returns(bool){
        require(newOwner != address(0), "DPRStaking: Transfer Ownership to zero address");
        owner = newOwner;
        emit OwnerShipTransfer(msg.sender, newOwner);
    } 
    
    //for emergency case, Deeper Offical can help users to modify their staking info
    function modifyUserAddress(address user, string calldata DPRAddress) external onlyOwner returns(bool){
        require(user_staking_amount[user] > 0, "DPRStaking: User does not have any record");
        require(address_dpr_mapping[DPRAddress] == address(0), "DPRStaking: DPRAddress already in use");
        bytes32 oldDPRAddressHash = keccak256(abi.encodePacked(dpr_address_mapping[user]));
        bytes32 newDPRAddressHash = keccak256(abi.encodePacked(DPRAddress));
        require(oldDPRAddressHash != newDPRAddressHash, "DPRStaking: DPRAddress is same"); 
        dpr_address_mapping[user] = DPRAddress;
        delete address_dpr_mapping[dpr_address_mapping[user]];
        address_dpr_mapping[DPRAddress] = user;
        emit DPRAddressChange(oldDPRAddressHash, newDPRAddressHash);
        return true;

    }
    //for emergency case(User lost their control of their accounts), Deeper Offical can help users to transfer their staking info to a new address 
    function transferUserInfo(address oldUser, address newUser) external onlyOwner returns(bool){
        require(oldUser != newUser, "DPRStaking: Address are same");
        require(user_staking_amount[oldUser] > 0, "DPRStaking: Old user does not have any record");
        require(user_staking_amount[newUser] == 0, "DPRStaking: New user must a clean address");
        //Transfer Staking Info
        user_staking_amount[newUser] = user_staking_amount[oldUser];
		user_staking_period_index[newUser] = user_staking_period_index[oldUser];
		user_staking_periods[newUser] = user_staking_periods[oldUser];
        //Transfer release Info
        user_release_time[newUser] = user_release_time[oldUser];
        //Transfer claim Info
        user_claimed_map[newUser] = user_claimed_map[oldUser];
        //Transfer address mapping info
		address_dpr_mapping[dpr_address_mapping[oldUser]] = newUser;
        dpr_address_mapping[newUser] = dpr_address_mapping[oldUser];
        user_staking_time[msg.sender] = block.timestamp;
        //clear account
        clearAccount(oldUser,false);
        emit UserInfoChange(oldUser, newUser);
        return true;

    }
    //for emergency case, Deeper Offical have permission to withdraw all fund in the contract
    function withdrawAllFund(uint256 amount) external onlyOwner returns(bool){
        dpr.safeTransfer(owner,amount);
        emit WithdrawAllFunds(owner);
        return true;
    }
	
	function setRootForPeriod(bytes32 root, uint256 index) external onlyOwner returns(bool){
		require(index <= periods.length.sub(1), "DPRStaking: Not that period");
		Period storage period_to_modify = periods[index];
		period_to_modify.withdraw_root = root;
		emit RootSet(root, index);
		return true;
	}

    function modifyPeriodTime(uint256 index, uint256 start_time, uint256 end_time) external onlyOwner returns(bool){
        require(periods.length > 0, "DPRStaking: No period");
        require(index <= periods.length.sub(1), "DPRStaking: Wrong Period");
        Period storage period = periods[index];
        period.start_time = start_time;
        period.end_time = end_time;
        emit ModifyPeriodTime(index, start_time, end_time);
    }

    //Change the linear time before claim start
    //if reward_time is 0, means mainnet not lanuch, so there is no need to check the reward time
    function modifyLinearTime(uint256 newdays) onlyOwner external returns(bool){
        require(block.timestamp <= reward_time.add(staking_time), "DPRStaking: Claim period has started");
        total_release_time = newdays * 86400;
        emit LinearTimeChange(newdays);
        return true;
    }

    function setPause(bool is_pause) external onlyOwner returns(bool){
        pause = is_pause;
        return true;
    }
	
    function clearAccount(address user, bool is_clear_address) private{
        delete user_staking_amount[user];
        delete user_release_time[user];
        delete user_claimed_map[user];
		delete user_staking_period_index[user];
		delete user_staking_periods[user];
        delete user_staking_time[user];
        if(is_clear_address){
			delete address_dpr_mapping[dpr_address_mapping[user]];
		}
		delete dpr_address_mapping[user];
    }
	
	function generateUserHash(address user) private returns(bytes32){
		uint256 staking_amount = user_staking_amount[user];
		return keccak256(abi.encodePacked(user, staking_amount));
	}
	
	function moveToLastestPeriod() external returns(bool){
		uint256 staking_amount = user_staking_amount[msg.sender];
		require(staking_amount > 0, "DPRStaking: User does not stake");
		Period memory lastest_period = periods[periods.length.sub(1)];
		require(isInCurrentPeriod(), "DPRStaking: Not in current period");
		//if user's period is same as the current period, means there is no new period
		require(!checkPeriod(msg.sender), "DPRStaking: No new staking period");
		user_staking_periods[msg.sender] = lastest_period;
		user_staking_period_index[msg.sender] = periods.length.sub(1);
	}


    //only allow user withdraw his fund in one period
    //for user withdraw their fund before staking end
    function withdrawStaking(bytes32[] calldata path, address user) external returns(bool){
        require(periods.length >=0, "DPRStaking: No active staking period");
		uint256 index = user_staking_period_index[user];
		bytes32 root = periods[index].withdraw_root;
		bytes32 user_node = generateUserHash(user);
		require(MerkleProof.verify(path, root, user_node), "DPRStaking: User not allow to withdraw");
		uint256 withdraw_amount = user_staking_amount[user];
        require(withdraw_amount >0, "DPRStaking: User does not stake");
        require(withdraw_amount <= dpr.balanceOf(address(this)), "DPRStaking: Not enough balanbce");
		clearAccount(user, true);
        dpr.safeTransfer(user, withdraw_amount);
        emit WithdrawStaking(user, withdraw_amount);
        return true;
    }

    function addStakingPeriod(uint256 _start_time, uint256 _end_time) external onlyOwner returns(bool){
        require(_end_time >= _start_time, "DPRStaking: Time error");
        if(periods.length != 0){
            Period memory lastest_period = periods[periods.length.sub(1)];
            uint256 end_time = lastest_period.end_time;
            require(block.timestamp > end_time, "DPRStaking: last period was not end");
        }
        Period memory p;
        p.start_time = _start_time;
        p.end_time = _end_time;
        periods.push(p);
        emit NewPeriod(_start_time, _end_time);
        return true;
    }

    //modify reward time
    function setRewardTime(uint256 _new_reward_time) external onlyOwner returns(bool){
        require(reward_time == 0,  "DPRStaking: Reward time is already set");
        reward_time = _new_reward_time;
        emit UpdateRewardTime(_new_reward_time);
        return true;
    }
    //when staking end, user can choose to migrate their fund to new contract
    function migrate() external returns(bool){
        uint256 staking_amount = user_staking_amount[msg.sender];
        require(staking_amount >0, "DPRStaking: User does not stake");
        require(migrate_address != address(0), "DPRStaking: Staking not start");
        clearAccount(msg.sender, true);
        dpr.safeTransfer(migrate_address, staking_amount);
        emit Migrate(migrate_address, staking_amount);
        return true;
    }



    function setMigrateAddress(address _migrate_address) external onlyOwner returns(bool){
        migrate_address = _migrate_address;
        emit MigrateAddressSet(_migrate_address);
        return true;
    }

    function checkPeriod(address user) private returns(bool){
		Period memory lastest_period = periods[periods.length.sub(1)];
		Period memory user_period = user_staking_periods[user];
        return(lastest_period.start_time == user_period.start_time && lastest_period.end_time == user_period.end_time);
    }

    function checkDPRAddress(address _address, string memory _dprAddress) private{
        require(keccak256(abi.encodePacked(dpr_address_mapping[_address])) == bytes32(hex"c5d2460186f7233c927e7db2dcc703c0e500b653ca82273b7bfad8045d85a470"), "DPRStaking: DPRAddress already set");
        require(address_dpr_mapping[_dprAddress] == address(0), "DPRStaking: ETH address already bind an DPRAddress");
    }
	
	function isInCurrentPeriod() private returns(bool){
		Period memory lastest_period = periods[periods.length.sub(1)];
		uint256 start_time = lastest_period.start_time;
		uint256 end_time = lastest_period.end_time;
		return (block.timestamp >= start_time && end_time >= block.timestamp);
	}

    function getUserDPRAddress(address user) external view returns(string memory){
        return dpr_address_mapping[user];
    }
	
	function getUserAddressByDPRAddress(string calldata dpr_address) external view returns(address){
		return address_dpr_mapping[dpr_address];
	}

    function getReleaseTime(address user) external view returns(uint256){
        return user_release_time[user];
    }

    function getStaking(address user) external view returns(uint256){
        return user_staking_amount[user];
    }

    function getUserReleasePerDay(address user) external view returns(uint256){
        uint256 staking_amount = user_staking_amount[user];
        uint256 release_per_day = staking_amount.mul(1 days).div(total_release_time);
        return release_per_day;
    }

    function getUserClaimInfo(address user) external view returns(uint256){
        return user_claimed_map[user];
    }

    function getReleaseTimeInDays() external view returns(uint256){
        return total_release_time.div(1 days);
    }

    function getPeriodInfo(uint256 index) external view returns (Period memory){
		return periods[index];
    }

    function getRewardTime() external view returns(uint256){
        return reward_time;  
    }

    function getUserStakingPeriod(address user) external view returns(Period memory){
        return user_staking_periods[user];
    }
	
	function getUserStakingIndex(address user) external view returns(uint256){
		return user_staking_period_index[user];
	}

    function getUserStakingTime(address user) external view returns(uint256){
        return user_staking_time[user];
    }

}