/**
 *Submitted for verification at Etherscan.io on 2021-09-06
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
    IERC20 public dpr;
    uint256 public staking_time = 270 days; // lock for 9 months
    uint256 private total_release_time; // linear release in 3 months
    // uint256 private reward_time = 0;
    uint256 private total_level;
    address public owner; 
    IMigrate public migrate_address;
    bool public pause;

    mapping (address => uint256) private user_staking_amount;
    mapping (address => uint256) private user_release_time;
    mapping (address => uint256) private user_claimed_map;
    mapping (address => string) private dpr_address_mapping;
    mapping (string => address) private address_dpr_mapping;
    mapping (address => bool) private user_start_claim;
    mapping (address => uint256) private user_staking_time;

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
    event Migrate(address indexed migrate_address, uint256 indexed migrate_amount);
    event MigrateAddressSet(address indexed migrate_address);
    event ExtendStakingTime(address indexed addr);
    event AdminWithdrawUserFund(address indexed addr);


    constructor(IERC20 _dpr) public {
        dpr = _dpr;
        total_release_time = 90 days; // for initialize
        owner = msg.sender;
    }

    function stake(string calldata DPRAddress, uint256 amount) external whenNotPaused returns(bool){
       require(user_staking_amount[msg.sender] == 0, "DPRStaking: Already stake, use addStaking instead");
       checkDPRAddress(msg.sender, DPRAddress);
       uint256 staking_amount = amount;
       dpr.safeTransferFrom(msg.sender, address(this), staking_amount);
       user_staking_amount[msg.sender] = staking_amount;
       user_staking_time[msg.sender] = block.timestamp;
       user_release_time[msg.sender] = block.timestamp + staking_time; 
       //user_staking_level[msg.sender] = level;
       dpr_address_mapping[msg.sender] = DPRAddress;
       address_dpr_mapping[DPRAddress] = msg.sender;
       emit Stake(msg.sender, DPRAddress, staking_amount);
       return true;
    }

    function addAndExtendStaking(uint256 amount) external  whenNotPaused returns(bool) {
        require(!canUserClaim(msg.sender), "DPRStaking: Can only claim");
        uint256 oldStakingAmount = user_staking_amount[msg.sender];
        require(oldStakingAmount > 0, "DPRStaking: Please Stake first");
        dpr.safeTransferFrom(msg.sender, address(this), amount);
        //update user staking amount
        user_staking_amount[msg.sender] = user_staking_amount[msg.sender].add(amount);
        user_staking_time[msg.sender] = block.timestamp;
        user_release_time[msg.sender] = block.timestamp + staking_time;
        emit StakeChange(msg.sender, oldStakingAmount, user_staking_amount[msg.sender]);
        return true;
    }

    function claim() external whenNotPaused returns(bool){
        require(canUserClaim(msg.sender), "DPRStaking: Not reach the release time");
        require(block.timestamp >= user_release_time[msg.sender], "DPRStaking: Not release period");
        if(!user_start_claim[msg.sender]){
            user_start_claim[msg.sender] == true;
        }
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
    function withdrawAllFund(address token,uint256 amount) external onlyOwner returns(bool){
        IERC20(token).safeTransfer(owner,amount);
        emit WithdrawAllFunds(owner);
        return true;
    }
	

    function setPause(bool is_pause) external onlyOwner returns(bool){
        pause = is_pause;
        return true;
    }

    function adminWithdrawUserFund(address user) external onlyOwner returns(bool){
        require(user_staking_amount[user] >0, "DPRStaking: No staking");
        dpr.safeTransfer(user, user_staking_amount[user]);
        clearAccount(user, true);
        emit AdminWithdrawUserFund(user);
        return true;
    }
	
    function clearAccount(address user, bool is_clear_address) private{
        delete user_staking_amount[user];
        delete user_release_time[user];
        delete user_claimed_map[user];
		// delete user_staking_period_index[user];
		// delete user_staking_periods[user];
        delete user_staking_time[user];
        if(is_clear_address){
			delete address_dpr_mapping[dpr_address_mapping[user]];
		}
		delete dpr_address_mapping[user];
    }
	

    function extendStaking() external returns(bool){
        require(user_staking_amount[msg.sender] > 0, "DPRStaking: User does not stake");
        require(!isUserClaim(msg.sender), "DPRStaking: User start claim");
        // Can be extended up to 12 hours before the staking end
        //require(block.timestamp  >= user_release_time[msg.sender].sub(43200) && block.timestamp <=user_release_time[msg.sender], "DPRStaking: Too early");
        user_release_time[msg.sender] = user_release_time[msg.sender] + staking_time;
        emit ExtendStakingTime(msg.sender);
        return true;
    }

    function migrate() external returns(bool){
        uint256 staking_amount = user_staking_amount[msg.sender];
        require(staking_amount >0, "DPRStaking: User does not stake");
        require(address(migrate_address) != address(0), "DPRStaking: Staking not start");
        clearAccount(msg.sender, true);
        dpr.approve(address(migrate_address), uint256(-1));
        migrate_address.migrate(msg.sender, staking_amount);
        emit Migrate(address(migrate_address), staking_amount);
        return true;
    }



    function setMigrateAddress(address _migrate_address) external onlyOwner returns(bool){
        migrate_address = IMigrate(_migrate_address);
        emit MigrateAddressSet(_migrate_address);
        return true;
    }


    function checkDPRAddress(address _address, string memory _dprAddress) private{
        require(keccak256(abi.encodePacked(dpr_address_mapping[_address])) == bytes32(hex"c5d2460186f7233c927e7db2dcc703c0e500b653ca82273b7bfad8045d85a470"), "DPRStaking: DPRAddress already set");
        require(address_dpr_mapping[_dprAddress] == address(0), "DPRStaking: ETH address already bind an DPRAddress");
    }
	

    // function isUserStartRelease(address _user) external view returns(bool){
    //     return user_start_release[msg.sender];
    // }

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


    function getUserStakingTime(address user) external view returns(uint256){
        return user_staking_time[user];
    }

    function canUserClaim(address user) public  view returns(bool){
        return block.timestamp >= (user_staking_time[user] + staking_time);
    }

    function isUserClaim(address user) public view returns(bool){
        return user_start_claim[user];
    }
}