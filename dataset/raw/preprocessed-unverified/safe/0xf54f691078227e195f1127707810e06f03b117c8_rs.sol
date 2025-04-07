/**
 *Submitted for verification at Etherscan.io on 2020-12-10
*/

pragma solidity 0.6.3;



abstract contract Context {
    function _msgSender() internal view virtual returns (address payable) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes memory) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}








contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    constructor () internal {
        address msgSender = _msgSender();
        _owner = msgSender;
        emit OwnershipTransferred(address(0), msgSender);
    }

    /**
     * @dev Returns the address of the current owner.
     */
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
















contract MasterChef is Ownable {
    using SafeMath for uint256;
    using SafeERC20 for IERC20;

    // Info of each user.
    struct UserInfo {
		uint256 pid;
        uint256 amount;     // How many LP tokens the user has provided.
		uint256 reward;
        uint256 rewardPaid; 
		uint256 userRewardPerTokenPaid;
		uint256 start;
    }
	// Info of each user that stakes LP tokens.
    mapping (uint256 => mapping (address => UserInfo)) public userInfo;
	

	
    // Info of each pool.
    struct PoolInfo {
        IERC20 lpToken;           // Address of LP token contract.
        uint256 allocPoint;       // How many allocation points assigned to this pool. Pizzas to distribute per block.
        uint256 lastRewardTime;  // Last block number that Pizzas distribution occurs.
        uint256 accPizzaPerShare; // Accumulated Pizzas per share, times 1e18. See below.
		uint256 totalPool;
    }
    // Info of each pool.
    PoolInfo[] public poolInfo;
	



    
	struct User {
        uint id; 
        address referrer; 

		uint256[] referAmount;

		uint256 referReward;
		
		uint256[] referCount;
	
		uint256 referRewardPerTokenPaid;

    }	
	mapping(address => User) public users;
	

	uint public lastUserId = 2;
	mapping(uint256 => address) public regisUser;



	
	
	

	bool initialized = false;

    //uint256 public initreward = 1250*1e18;

    uint256 public starttime;

    uint256 public periodFinish = 0;

    uint256 public rewardRate = 0;

    uint256 public totalMinted = 0;
    
    uint256 constant public PERCENTS_DIVIDER = 1000;
    
    uint256 constant public TIME_STEP = 1 days;



    IERC20 public pizza ;



	address public defaultReferAddr;
	
	address public projectAddress;
	

    // Total allocation poitns. Must be the sum of all allocation points in all pools.
    uint256 public totalAllocPoint = 0;
    // Bonus muliplier for early pizza makers.
    uint256 public constant BONUS_MULTIPLIER = 1;

    uint256[2] public referrRewardPercent = [15,5];


    event RewardPaid(address indexed user, uint256 reward);
    event Deposit(address indexed user, uint256 indexed pid, uint256 amount);
    event Withdraw(address indexed user, uint256 indexed pid, uint256 amount);
    event Registration(address indexed user, address indexed referrer, uint indexed userId, uint referrerId);

 //constructor
   // function initContract 
	 constructor (IERC20 _pizza,uint256 _rewardRate,uint256 _starttime,uint256 _periodFinish,address _defaultReferAddr,address _projectAddress) public onlyOwner{	
		require(initialized == false,"has initialized");
        pizza = _pizza;
		rewardRate = _rewardRate;
		starttime = _starttime;
		periodFinish = _periodFinish;
		defaultReferAddr =  _defaultReferAddr;
		projectAddress = _projectAddress;
	
		User memory user = User({
            id: 1,
            referrer: address(0),
            referAmount:new uint256[](2),
			referReward:0,
			referCount:new uint256[](2),
			referRewardPerTokenPaid:0		
        });		
		users[defaultReferAddr] = user;	
		
		regisUser[1] = 	defaultReferAddr;
		initialized = true;	
    }

    function poolLength() external view returns (uint256) {
        return poolInfo.length;
    }
	

    function isUserExists(address user) public view returns (bool) {
		return (users[user].id != 0);
    }
	

	
	function registrationExt(address referrerAddress) external {
        registration(msg.sender, referrerAddress);
    }

    function registration(address userAddress, address referrerAddress) private {
       //require(msg.value == 0.05 ether, "registration cost 0.05");
        require(!isUserExists(userAddress), "user exists");
        require(isUserExists(referrerAddress), "referrer not exists");
        
       // uint32 size;
        //assembly {
        //    size := extcodesize(userAddress)
       // }
		//require(size == 0, "cannot be a contract");
		require(!Address.isContract(userAddress), "cannot be a contract");
        
 
        User memory user = User({
            id: lastUserId,
            referrer: referrerAddress,
			referAmount:new uint256[](2),
			referReward:0,
			referCount:new uint256[](2),
			referRewardPerTokenPaid:0		
        });
		

		
		regisUser[lastUserId] = userAddress;
        
        users[userAddress] = user;
		
		users[referrerAddress].referCount[0] = users[referrerAddress].referCount[0].add(1);
		
		address _refer = users[referrerAddress].referrer;
		if(_refer != address(0)){
			users[_refer].referCount[1] = users[_refer].referCount[1].add(1);
		}
		
        lastUserId++;
        
        emit  Registration(userAddress, referrerAddress, users[userAddress].id, users[referrerAddress].id);
    }
	



    // Add a new lp to the pool. Can only be called by the owner.
    // XXX DO NOT add the same LP token more than once. Rewards will be messed up if you do.
    function addLp(uint256 _allocPoint, IERC20 _lpToken) public onlyOwner {   
        uint256 lastRewardTime = block.timestamp > starttime ? block.timestamp : starttime;
        totalAllocPoint = totalAllocPoint.add(_allocPoint);
        poolInfo.push(PoolInfo({
            lpToken: _lpToken,
            allocPoint: _allocPoint,
            lastRewardTime: lastRewardTime,
            accPizzaPerShare: 0,
			totalPool:0
        }));		
    }
	
	


    // Update the given pool's Pizza allocation point. Can only be called by the owner.
    function set(uint256 _pid, uint256 _allocPoint) public onlyOwner {

        totalAllocPoint = totalAllocPoint.sub(poolInfo[_pid].allocPoint).add(_allocPoint);
        poolInfo[_pid].allocPoint = _allocPoint;
    }
	
	function setTotalAllocPoint(uint256 _totalAllocPoint) public onlyOwner{
		totalAllocPoint = _totalAllocPoint;
	}
	
	function setRewardRate(uint256 _rewardRate) public onlyOwner {
		rewardRate = _rewardRate;	
	} 

	
  

    // Return reward multiplier over the given _from to _to block.
    function getMultiplier(uint256 _from, uint256 _to) public view returns (uint256) {
        if (_to <= periodFinish) {
            return _to.sub(_from).mul(BONUS_MULTIPLIER);
        } else if (_from >= periodFinish) {
            return _to.sub(_from);
        } else {
            return periodFinish.sub(_from).mul(BONUS_MULTIPLIER).add(
                _to.sub(periodFinish)
            );
        }
    }

	function getRewardRate() public view returns(uint256){
		
		return rewardRate;
		
	}

    function pendingPizza(uint256 _pid, address _user) public view returns (uint256) {
        // PoolInfo storage pool = poolInfo[_pid];
        UserInfo storage user = userInfo[_pid][_user];
//         uint256 accPizzaPerShare = pool.accPizzaPerShare;
//         uint256 lpSupply = pool.totalPool;
		uint256 result = user.reward;
//         if (block.timestamp > pool.lastRewardTime && lpSupply != 0) {
//             uint256 multiplier =  getMultiplier(pool.lastRewardTime, block.timestamp);
//             uint256 pizzaReward = multiplier.mul(getRewardRate()).mul(pool.allocPoint).div(totalAllocPoint);
//             accPizzaPerShare = pool.accPizzaPerShare.add(pizzaReward.mul(1e18).div(lpSupply));
//         }

		result = (user.amount.mul(getRewardRate()).div(PERCENTS_DIVIDER)).mul(block.timestamp.sub(user.start)).div(TIME_STEP);
	
	    if(result >= user.amount) {
	        result  = user.amount;
	    }
        
		return result;
    }
	

	function pendingAllPizza(address _user) public view returns (uint256) {
		uint256  result = 0;
		for(uint256 i = 0;i< poolInfo.length;i++ ){
			result = result.add(pendingPizza(i,_user));
		}
        return result;
    }
	

	function allPizzaAmount(address _user) public view returns (uint256) {
		uint256 result = 0;
		for(uint256 i = 0;i< poolInfo.length;i++ ){
			UserInfo storage user = userInfo[i][_user];
			result = result.add(pendingPizza(i,_user).add(user.rewardPaid));
		}
        return result;
    }
	

	function getAllDeposit(address _user) public view returns (uint256) {
		uint256 result = 0;
		for(uint256 i = 0;i< poolInfo.length;i++ ){
			UserInfo storage user = userInfo[i][_user];		
			result = result.add(user.amount);
		}
        return result;
    }



	function getReferCount(address userAddress) public view returns(uint256[] memory){
	
		if(isUserExists(userAddress)){
			return	users[userAddress].referCount;
		}
		return new uint256[](2);
	}
	


	function getReferAmount(address _user,uint256 _index) public view returns(uint256){
		if(isUserExists(_user)){
			return	users[_user].referAmount[_index];
		}
		return 0;
	}
	
    // Update reward variables of the given pool to be up-to-date.
    function updatePool(uint256 _pid,address _user) internal {
        PoolInfo storage pool = poolInfo[_pid];
        if (block.timestamp <= pool.lastRewardTime) {
            return;
        }
        uint256 lpSupply = pool.totalPool;
        if (lpSupply == 0) {
            pool.lastRewardTime = block.timestamp;
            return;
        }
		UserInfo storage user = userInfo[_pid][_user];
		
        uint256 multiplier = getMultiplier(pool.lastRewardTime, block.timestamp);
        uint256 pizzaReward = multiplier.mul(getRewardRate()).mul(pool.allocPoint).div(totalAllocPoint);
        totalMinted = totalMinted.add(pizzaReward);


		//pizza.mint(address(this), pizzaReward);
        pool.accPizzaPerShare = pool.accPizzaPerShare.add(pizzaReward.mul(1e18).div(lpSupply));
		
		user.reward = user.amount.mul((pool.accPizzaPerShare).sub(user.userRewardPerTokenPaid)).div(1e18).add(user.reward);
		
		
		user.userRewardPerTokenPaid = pool.accPizzaPerShare;
        pool.lastRewardTime = block.timestamp;
    }


    // Deposit LP tokens to MasterChef for pizza allocation.
    function deposit(uint256 _pid, uint256 _amount) public checkStart {

		require(isUserExists(msg.sender), "user don't exists");	
		
        PoolInfo storage pool = poolInfo[_pid];
        UserInfo storage user = userInfo[_pid][msg.sender];
        
        require(user.amount == 0, "user deposited");	
        
        // updatePool(_pid,msg.sender);	
		
        if(_amount > 0) {
            pool.lpToken.safeTransferFrom(address(msg.sender), address(this), _amount);
            user.amount = user.amount.add(_amount);
			user.pid = _pid;
			user.start = block.timestamp;
			
			pool.totalPool = pool.totalPool.add(_amount);   		
	
			address _referrer = users[msg.sender].referrer;
			for(uint256 i = 0;i<2;i++){				
				if(_referrer!= address(0) && isUserExists(_referrer)){
					users[_referrer].referAmount[i] = _amount.add(users[_referrer].referAmount[i]);					
					_referrer = users[_referrer].referrer;
				}else break;
			}				
        }
        emit Deposit(msg.sender, _pid, _amount);
    }
	

    function getReward(uint256 _pid) public  {

// 		PoolInfo storage pool = poolInfo[_pid];
//         UserInfo storage user = userInfo[_pid][msg.sender];
//         uint256 accPizzaPerShare = pool.accPizzaPerShare;
//         uint256 lpSupply = pool.totalPool;
//         if (block.timestamp > pool.lastRewardTime && lpSupply != 0) {
//             uint256 multiplier =  getMultiplier(pool.lastRewardTime, block.timestamp);
//             uint256 pizzaReward = multiplier.mul(getRewardRate()).mul(pool.allocPoint).div(totalAllocPoint);
//             accPizzaPerShare = pool.accPizzaPerShare.add(pizzaReward.mul(1e18).div(lpSupply));
//         }
//         uint256 reward = user.amount.mul((accPizzaPerShare).sub(user.userRewardPerTokenPaid)).div(1e18).add(user.reward);
	
//         if (reward > 0) {
// 			safePizzaTransfer(msg.sender, reward);
// 			user.rewardPaid = user.rewardPaid.add(reward);
// 			user.reward = 0;
//             emit RewardPaid(msg.sender, reward);
//         }		
// 		user.userRewardPerTokenPaid = accPizzaPerShare;
    }
	


    // Withdraw LP tokens from MasterChef.
    function withdraw(uint256 _pid, uint256 _amount) public{		
		UserInfo storage user = userInfo[_pid][msg.sender];
		
		
        PoolInfo storage pool = poolInfo[_pid];
        
        require(user.amount >= _amount, "withdraw: not good");
        
        
        // updatePool(_pid,msg.sender);
        
        user.reward = (user.amount.mul(getRewardRate()).div(PERCENTS_DIVIDER)).mul(block.timestamp.sub(user.start)).div(TIME_STEP);
               
        require(user.reward >= _amount, "withdraw: not 2 amount");
        
        if(user.reward >= _amount) {
            user.reward = _amount;
        }
		safePizzaTransfer(msg.sender, _amount);
		
// 		safePizzaTransfer(projectAddress, user.reward.mul(10).div(100));
		
		user.rewardPaid = user.rewardPaid.add(user.reward);
		emit RewardPaid(msg.sender, user.rewardPaid);
		
		
		
        if(_amount > 0) {
            user.amount = user.amount.sub(_amount);
            pool.lpToken.safeTransfer(address(msg.sender), _amount);			
			pool.totalPool = pool.totalPool.sub(_amount);   	
			address _referrer = users[msg.sender].referrer;
			for(uint256 i = 0;i<2;i++){
				if(_referrer!= address(0) && isUserExists(_referrer)){
					users[_referrer].referAmount[i] = users[_referrer].referAmount[i].sub(_amount);	
					users[_referrer].referReward = 	users[_referrer].referReward.add(user.reward.mul(referrRewardPercent[i]).div(100));				
					safePizzaTransfer(_referrer, user.reward.mul(referrRewardPercent[i]).div(100));
					_referrer = users[_referrer].referrer;
				}else break;
			}	
        }
		user.reward = 0;
		user.amount = 0;
		
        emit Withdraw(msg.sender, _pid, _amount);
    }



    // Safe pizza transfer function, just in case if rounding error causes pool to not have enough pizzas.
    function safePizzaTransfer(address _to, uint256 _amount) internal {
        uint256 pizzaBal = pizza.balanceOf(address(this));
        if (_amount > pizzaBal) {
            pizza.transfer(_to, pizzaBal);
        } else {
            pizza.transfer(_to, _amount);
        }
    }   

	
	modifier checkStart(){
       require(block.timestamp  > starttime,"not start");
       _;
    }


}