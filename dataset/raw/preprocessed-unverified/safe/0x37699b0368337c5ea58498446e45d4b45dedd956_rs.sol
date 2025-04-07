/**
 *Submitted for verification at Etherscan.io on 2021-02-11
*/

pragma solidity 0.5.16;
pragma experimental ABIEncoderV2;


/*
 * @dev Provides information about the current execution context, including the
 * sender of the transaction and its data. While these are generally available
 * via msg.sender and msg.data, they should not be accessed in such a direct
 * manner, since when dealing with GSN meta-transactions the account sending and
 * paying for execution may not be the actual sender (as far as an application
 * is concerned).
 *
 * This contract is only required for intermediate, library-like contracts.
 */
contract Context {
    // Empty internal constructor, to prevent people from mistakenly deploying
    // an instance of this contract, which should be used via inheritance.
    constructor () internal { }
    // solhint-disable-previous-line no-empty-blocks

    function _msgSender() internal view returns (address payable) {
        return msg.sender;
    }

    function _msgData() internal view returns (bytes memory) {
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

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        require(isOwner(), "Ownable: caller is not the owner");
        _;
    }

    /**
     * @dev Returns true if the caller is the current owner.
     */
    function isOwner() public view returns (bool) {
        return _msgSender() == _owner;
    }

    /**
     * @dev Leaves the contract without owner. It will not be possible to call
     * `onlyOwner` functions anymore. Can only be called by the current owner.
     *
     * NOTE: Renouncing ownership will leave the contract without an owner,
     * thereby removing any functionality that is only available to the owner.
     */
    function renounceOwnership() public onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) public onlyOwner {
        _transferOwnership(newOwner);
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     */
    function _transferOwnership(address newOwner) internal {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}



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




contract WanFarmErrorReporter {
    enum Error {
        NO_ERROR,
        UNAUTHORIZED
    }

    enum FailureInfo {
        ACCEPT_ADMIN_PENDING_ADMIN_CHECK,
        ACCEPT_PENDING_IMPLEMENTATION_ADDRESS_CHECK,
        SET_PENDING_ADMIN_OWNER_CHECK,
        SET_PENDING_IMPLEMENTATION_OWNER_CHECK
    }

    /**
      * @dev `error` corresponds to enum Error; `info` corresponds to enum FailureInfo, and `detail` is an arbitrary
      * contract-specific code that enables us to report opaque error codes from upgradeable contracts.
      **/
    event Failure(uint error, uint info, uint detail);

    /**
      * @dev use this when reporting a known error from the money market or a non-upgradeable collaborator
      */
    function fail(Error err, FailureInfo info) internal returns (uint) {
        emit Failure(uint(err), uint(info), 0);

        return uint(err);
    }

    /**
      * @dev use this when reporting an opaque error from an upgradeable collaborator contract
      */
    function failOpaque(Error err, FailureInfo info, uint opaqueError) internal returns (uint) {
        emit Failure(uint(err), uint(info), opaqueError);

        return uint(err);
    }
}

contract UniFarmAdminStorage {
    /**
    * @notice Administrator for this contract
    */
    address public admin;

    /**
    * @notice Pending administrator for this contract
    */
    address public pendingAdmin;

    /**
    * @notice Active brains of WanFarm
    */
    address public wanFarmImplementation;

    /**
    * @notice Pending brains of WanFarm
    */
    address public pendingWanFarmImplementation;
}

contract WanFarmV1Storage is UniFarmAdminStorage {
    // Info of each user.
    struct UserInfo {
        uint256 amount;     // How many LP tokens the user has provided.
        uint256 rewardDebt; // Reward debt. See explanation below.
        uint256 extRewardDebt; 
    }

    struct ExtFarmInfo{
        address extFarmAddr;  
        bool extEnableDeposit;
        uint256 extPid;
        uint256 extRewardPerShare;
        uint256 extTotalDebtReward;  //
        bool extEnableClaim;
    }
    // Info of each pool.
    struct PoolInfo {
        IERC20  lpToken;          // Address of LP token contract.
        uint256 currentSupply;    //
        uint256 bonusStartBlock;  //
        uint256 newStartBlock;    //
        uint256 bonusEndBlock;    // Block number when bonus wanWan period ends.

        uint256 lastRewardBlock;  // Last block number that wanWans distribution occurs.
        uint256 accwanWanPerShare;// Accumulated wanWans per share, times 1e12. See below.
        uint256 wanWanPerBlock;   // wanWan tokens created per block.
        uint256 totalDebtReward;  //

        ExtFarmInfo extFarmInfo;
    }

    PoolInfo[] public poolInfo;   // Info of each pool.
    mapping (uint256 => mapping (address => UserInfo)) public userInfo;// Info of each user that stakes LP tokens.

}

contract WanFarmInterface {
    event Deposit(address indexed user, uint256 indexed pid, uint256 amount);
    event Withdraw(address indexed user, uint256 indexed pid, uint256 amount);

    function pendingwanWan(uint256 _pid, address _user) public view returns (uint256,uint256);
    function allPendingReward(uint256 _pid,address _user) public view returns(uint256,uint256,uint256);
    function pendingExtReward(uint256 _pid, address _user) public view returns(uint256);

    function deposit(uint256 _pid, uint256 _amount) public;
    function withdraw(uint256 _pid, uint256 _amount) public;
    function emergencyWithdraw(uint256 _pid) public;
}

/**
 * @title ComptrollerCore
 * @dev Storage for the comptroller is at this address, while execution is delegated to the `wanFarmImplementation`.
 * CTokens should reference this contract as their comptroller.
 */
contract UniFarm is UniFarmAdminStorage, WanFarmErrorReporter {

    /**
      * @notice Emitted when pendingWanFarmImplementation is changed
      */
    event NewPendingImplementation(address oldPendingImplementation, address newPendingImplementation);

    /**
      * @notice Emitted when pendingWanFarmImplementation is accepted, which means comptroller implementation is updated
      */
    event NewImplementation(address oldImplementation, address newImplementation);

    /**
      * @notice Emitted when pendingAdmin is changed
      */
    event NewPendingAdmin(address oldPendingAdmin, address newPendingAdmin);

    /**
      * @notice Emitted when pendingAdmin is accepted, which means admin is updated
      */
    event NewAdmin(address oldAdmin, address newAdmin);

    constructor() public {
        // Set admin to caller
        admin = msg.sender;
    }

    /*** Admin Functions ***/
    function _setPendingImplementation(address newPendingImplementation) public returns (uint) {

        if (msg.sender != admin) {
            return fail(Error.UNAUTHORIZED, FailureInfo.SET_PENDING_IMPLEMENTATION_OWNER_CHECK);
        }

        address oldPendingImplementation = pendingWanFarmImplementation;

        pendingWanFarmImplementation = newPendingImplementation;

        emit NewPendingImplementation(oldPendingImplementation, pendingWanFarmImplementation);

        return uint(Error.NO_ERROR);
    }

    /**
    * @notice Accepts new implementation of comptroller. msg.sender must be pendingImplementation
    * @dev Admin function for new implementation to accept it's role as implementation
    * @return uint 0=success, otherwise a failure (see ErrorReporter.sol for details)
    */
    function _acceptImplementation() public returns (uint) {
        // Check caller is pendingImplementation and pendingImplementation ≠ address(0)
        if (msg.sender != pendingWanFarmImplementation || pendingWanFarmImplementation == address(0)) {
            return fail(Error.UNAUTHORIZED, FailureInfo.ACCEPT_PENDING_IMPLEMENTATION_ADDRESS_CHECK);
        }

        // Save current values for inclusion in log
        address oldImplementation = wanFarmImplementation;
        address oldPendingImplementation = pendingWanFarmImplementation;

        wanFarmImplementation = pendingWanFarmImplementation;

        pendingWanFarmImplementation = address(0);

        emit NewImplementation(oldImplementation, wanFarmImplementation);
        emit NewPendingImplementation(oldPendingImplementation, pendingWanFarmImplementation);

        return uint(Error.NO_ERROR);
    }


    /**
      * @notice Begins transfer of admin rights. The newPendingAdmin must call `_acceptAdmin` to finalize the transfer.
      * @dev Admin function to begin change of admin. The newPendingAdmin must call `_acceptAdmin` to finalize the transfer.
      * @param newPendingAdmin New pending admin.
      * @return uint 0=success, otherwise a failure (see ErrorReporter.sol for details)
      */
    function _setPendingAdmin(address newPendingAdmin) public returns (uint) {
        // Check caller = admin
        if (msg.sender != admin) {
            return fail(Error.UNAUTHORIZED, FailureInfo.SET_PENDING_ADMIN_OWNER_CHECK);
        }

        // Save current value, if any, for inclusion in log
        address oldPendingAdmin = pendingAdmin;

        // Store pendingAdmin with value newPendingAdmin
        pendingAdmin = newPendingAdmin;

        // Emit NewPendingAdmin(oldPendingAdmin, newPendingAdmin)
        emit NewPendingAdmin(oldPendingAdmin, newPendingAdmin);

        return uint(Error.NO_ERROR);
    }

    /**
      * @notice Accepts transfer of admin rights. msg.sender must be pendingAdmin
      * @dev Admin function for pending admin to accept role and update admin
      * @return uint 0=success, otherwise a failure (see ErrorReporter.sol for details)
      */
    function _acceptAdmin() public returns (uint) {
        // Check caller is pendingAdmin and pendingAdmin ≠ address(0)
        if (msg.sender != pendingAdmin || msg.sender == address(0)) {
            return fail(Error.UNAUTHORIZED, FailureInfo.ACCEPT_ADMIN_PENDING_ADMIN_CHECK);
        }

        // Save current values for inclusion in log
        address oldAdmin = admin;
        address oldPendingAdmin = pendingAdmin;

        // Store admin with value pendingAdmin
        admin = pendingAdmin;

        // Clear the pending value
        pendingAdmin = address(0);

        emit NewAdmin(oldAdmin, admin);
        emit NewPendingAdmin(oldPendingAdmin, pendingAdmin);

        return uint(Error.NO_ERROR);
    }

    /**
     * @dev Delegates execution to an implementation contract.
     * It returns to the external caller whatever the implementation returns
     * or forwards reverts.
     */
    function () payable external {
        // delegate all other functions to current implementation
        (bool success, ) = wanFarmImplementation.delegatecall(msg.data);

        assembly {
              let free_mem_ptr := mload(0x40)
              returndatacopy(free_mem_ptr, 0, returndatasize)

              switch success
              case 0 { revert(free_mem_ptr, returndatasize) }
              default { return(free_mem_ptr, returndatasize) }
        }
    }
}



contract WanFarm is WanFarmV1Storage, WanFarmInterface{
    using SafeMath for uint256;
    using SafeERC20 for IERC20;

    IERC20 public constant wanWan = IERC20(0x135B810e48e4307AB2a59ea294A6f1724781bD3C);

    event QuitWanwan(address to, uint256 amount);
    event QuitExtReward(address extFarmAddr, address rewardToken, address to, uint256 amount);
    event UpdatePoolInfo(uint256 pid, uint256 bonusEndBlock, uint256 wanWanPerBlock);
    event WithdrawwanWan(address to, uint256 amount);
    event DoubleFarmingEnable(uint256 pid, bool flag);
    event SetExtFarm(uint256 pid, address extFarmAddr, uint256 extPid );
    event EmergencyWithdraw(uint256 indexed pid);


    constructor() public {
        admin = msg.sender;
    }

    modifier onlyOwner() {
        require(msg.sender == admin, "Ownable: caller is not the owner");
        _;
    }

    function _poolInfo(uint256 _pid) external view returns (
        address lpToken,         // Address of LP token contract.
        uint256 currentSupply,    //
        uint256 bonusStartBlock,  //
        uint256 newStartBlock,    //
        uint256 bonusEndBlock,    // Block number when bonus wanWan period ends.

        uint256 lastRewardBlock,  // Last block number that wanWans distribution occurs.
        uint256 accwanWanPerShare,// Accumulated wanWans per share, times 1e12. See below.
        uint256 wanWanPerBlock,   // wanWan tokens created per block.
        uint256 totalDebtReward){

            require(_pid < poolInfo.length,"pid >= poolInfo.length");
            PoolInfo storage pool = poolInfo[_pid]; 

            return (
                address(pool.lpToken),
                pool.currentSupply,
                pool.bonusStartBlock,
                pool.newStartBlock,
                pool.bonusEndBlock,

                pool.lastRewardBlock,
                pool.accwanWanPerShare,
                pool.wanWanPerBlock,
                pool.totalDebtReward
                );
        }
    
    function _extFarmInfo(uint256 _pid) external view returns (
		address extFarmAddr,  
        bool extEnableDeposit,
        uint256 extPid,
        uint256 extRewardPerShare,
        uint256 extTotalDebtReward,  //
        bool extEnableClaim){

            require(_pid < poolInfo.length,"pid >= poolInfo.length");
            PoolInfo storage pool = poolInfo[_pid]; 

            return (
                pool.extFarmInfo.extFarmAddr,
                pool.extFarmInfo.extEnableDeposit,
                pool.extFarmInfo.extPid,
                pool.extFarmInfo.extRewardPerShare,
                pool.extFarmInfo.extTotalDebtReward,
                pool.extFarmInfo.extEnableClaim);
        }

    function poolLength() external view returns (uint256) {
        return poolInfo.length;
    }

    // Add a new lp to the pool. Can only be called by the owner.
    // XXX DO NOT add the same LP token more than once. Rewards will be messed up if you do.
    function add(IERC20 _lpToken,
                 uint256 _bonusStartBlock,
                 uint256 _bonusEndBlock,
                 uint256 _wanWanPerBlock
                 ) public onlyOwner {
        require(block.number < _bonusEndBlock, "block.number >= bonusEndBlock");
        require(_bonusStartBlock < _bonusEndBlock, "_bonusStartBlock >= _bonusEndBlock");
        require(address(_lpToken) != address(0), "_lpToken == 0");
        uint256 lastRewardBlock = block.number > _bonusStartBlock ? block.number : _bonusStartBlock;

        ExtFarmInfo memory extFarmInfo = ExtFarmInfo({
                extFarmAddr:address(0x0),
                extEnableDeposit:false,
                extPid: 0,
                extRewardPerShare: 0,
                extTotalDebtReward:0,
                extEnableClaim:false
                });


        poolInfo.push(PoolInfo({
            lpToken: _lpToken,
            currentSupply: 0,
            bonusStartBlock: _bonusStartBlock,
            newStartBlock: _bonusStartBlock,
            bonusEndBlock: _bonusEndBlock,
            lastRewardBlock: lastRewardBlock,
            accwanWanPerShare: 0,
            wanWanPerBlock: _wanWanPerBlock,
            totalDebtReward: 0,
            extFarmInfo:extFarmInfo
        }));
        
    }

    function updatePoolInfo(uint256 _pid, uint256 _bonusEndBlock, uint256 _wanWanPerBlock) public onlyOwner {
        require(_pid < poolInfo.length,"pid >= poolInfo.length");
        require(_bonusEndBlock > block.number, "_bonusEndBlock <= block.number");
        updatePool(_pid);
        PoolInfo storage pool = poolInfo[_pid];
        if(pool.bonusEndBlock <= block.number){
            pool.newStartBlock = block.number;
        }

        pool.bonusEndBlock = _bonusEndBlock;
        pool.wanWanPerBlock = _wanWanPerBlock;
        emit UpdatePoolInfo(_pid, _bonusEndBlock, _wanWanPerBlock);
    }

    function getMultiplier(uint256 _pid) internal view returns (uint256) {
        PoolInfo storage pool = poolInfo[_pid];
        if(block.number <= pool.bonusStartBlock){
            return 0;// no begin
        }

        if(pool.lastRewardBlock >= pool.bonusEndBlock){
            return 0;// ended
        }

        if(block.number >= pool.bonusEndBlock){
            // ended, but no update, lastRewardBlock < bonusEndBlock
            return pool.bonusEndBlock.sub(pool.lastRewardBlock);
        }

        return block.number.sub(pool.lastRewardBlock);
    }

    // View function to see pending wanWans on frontend.
    function pendingwanWan(uint256 _pid, address _user) public view returns (uint256,uint256) {
        require(_pid < poolInfo.length,"pid >= poolInfo.length");
        PoolInfo storage pool = poolInfo[_pid];
        UserInfo storage user = userInfo[_pid][_user];
        uint256 accwanWanPerShare = pool.accwanWanPerShare;
        if (block.number > pool.lastRewardBlock && pool.currentSupply != 0) {
            uint256 multiplier = getMultiplier(_pid);
            uint256 wanWanReward = multiplier.mul(pool.wanWanPerBlock);
            accwanWanPerShare = accwanWanPerShare.add(wanWanReward.mul(1e12).div(pool.currentSupply));
        }
        return (user.amount, user.amount.mul(accwanWanPerShare).div(1e12).sub(user.rewardDebt));
    }

    /////////////////////////////////////////////////////////////////////////////////////////
    function totalUnclaimedExtFarmReward(address extFarmAddr) public view returns(uint256){
        
        uint256 allTotalUnclaimed = 0; 
        
        for (uint256 index = 0; index < poolInfo.length; index++) {
            PoolInfo storage pool = poolInfo[index];

            if(pool.extFarmInfo.extFarmAddr == address(0x0) || pool.extFarmInfo.extFarmAddr != extFarmAddr) continue;

            allTotalUnclaimed = pool.currentSupply.mul(pool.extFarmInfo.extRewardPerShare).div(1e12).sub(pool.extFarmInfo.extTotalDebtReward).add(allTotalUnclaimed);
            
        }

        return allTotalUnclaimed;
    }

    function distributeFinalExtReward(uint256 _pid, uint256 _amount) public onlyOwner{

        require(_pid < poolInfo.length,"pid >= poolInfo.length");
        PoolInfo storage pool = poolInfo[_pid];
        require(pool.extFarmInfo.extFarmAddr != address(0x0),"pool not supports double farming");

        uint256 allUnClaimedExtReward = totalUnclaimedExtFarmReward(pool.extFarmInfo.extFarmAddr);

        uint256 extRewardCurrentBalance = IERC20(ISushiChef(pool.extFarmInfo.extFarmAddr).sushi()).balanceOf(address(this));

        uint256 maxDistribute = extRewardCurrentBalance.sub(allUnClaimedExtReward);

        require(_amount <= maxDistribute,"distibute too much external rewards");

        pool.extFarmInfo.extRewardPerShare = _amount.mul(1e12).div(pool.currentSupply).add(pool.extFarmInfo.extRewardPerShare);
    }

    function getExtFarmRewardRate(ISushiChef sushiChef,IERC20 lpToken, uint256 extPid) internal view returns(uint256 rate){

        uint256 multiplier = sushiChef.getMultiplier(block.number-1, block.number);
        uint256 sushiPerBlock = sushiChef.sushiPerBlock();
        (,uint256 allocPoint,,) = sushiChef.poolInfo(extPid);
        uint256 totalAllocPoint = sushiChef.totalAllocPoint();
        uint256 totalSupply = lpToken.balanceOf(address(sushiChef));

        rate = multiplier.mul(sushiPerBlock).mul(allocPoint).mul(1e12).div(totalAllocPoint).div(totalSupply);
    }
    function extRewardPerBlock(uint256 _pid) public view returns(uint256){
        require(_pid < poolInfo.length,"pid >= poolInfo.length");
        PoolInfo storage pool = poolInfo[_pid];

        if(!pool.extFarmInfo.extEnableDeposit) return 0;

        ISushiChef sushiChef = ISushiChef(pool.extFarmInfo.extFarmAddr);
        uint256 rate = getExtFarmRewardRate(sushiChef, pool.lpToken,pool.extFarmInfo.extPid);
        (uint256 amount,) = sushiChef.userInfo(_pid,address(this));
        uint256 extReward = rate.mul(amount).div(1e12);

        return extReward;
    }
    
    function allPendingReward(uint256 _pid,address _user) public view returns(uint256,uint256,uint256){
        uint256 depositAmount;
        uint256 wanWanReward;
        uint256 sushiReward;
        
        (depositAmount,wanWanReward) = pendingwanWan(_pid,_user);
        sushiReward = pendingExtReward(_pid,_user);
        
        return (depositAmount,wanWanReward,sushiReward);
    }

    function enableDoubleFarming(uint256 _pid, bool enable)public onlyOwner{
        require(_pid < poolInfo.length,"pid >= poolInfo.length");
        PoolInfo storage pool = poolInfo[_pid];
        require(pool.extFarmInfo.extFarmAddr != address(0x0),"pool not supports double farming yet");

        if(pool.extFarmInfo.extEnableDeposit != enable){

            uint256 oldSuShiRewarad = IERC20(ISushiChef(pool.extFarmInfo.extFarmAddr).sushi()).balanceOf(address(this));
            
            if(enable){
                pool.lpToken.approve(pool.extFarmInfo.extFarmAddr,0xffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff);
                if(pool.currentSupply > 0) {
                    ISushiChef(pool.extFarmInfo.extFarmAddr).deposit(pool.extFarmInfo.extPid,pool.currentSupply);
                }

                pool.extFarmInfo.extEnableClaim = true;
                
            }else{
                pool.lpToken.approve(pool.extFarmInfo.extFarmAddr,0);
                (uint256 amount,) = ISushiChef(pool.extFarmInfo.extFarmAddr).userInfo(pool.extFarmInfo.extPid,address(this));
                if(amount > 0){
                    ISushiChef(pool.extFarmInfo.extFarmAddr).withdraw(pool.extFarmInfo.extPid,amount);
                }
            }

            if(pool.currentSupply > 0){
                uint256 deltaSuShiReward = IERC20(ISushiChef(pool.extFarmInfo.extFarmAddr).sushi()).balanceOf(address(this)).sub(oldSuShiRewarad);

                pool.extFarmInfo.extRewardPerShare = deltaSuShiReward.mul(1e12).div(pool.currentSupply).add(pool.extFarmInfo.extRewardPerShare);
            }
        
            pool.extFarmInfo.extEnableDeposit = enable;

            emit DoubleFarmingEnable(_pid,enable);
        }
    }

    function setDoubleFarming(uint256 _pid,address extFarmAddr,uint256 _extPid) public onlyOwner{
        require(_pid < poolInfo.length,"pid >= poolInfo.length");
        require(extFarmAddr != address(0x0),"extFarmAddr == 0x0");
        PoolInfo storage pool = poolInfo[_pid];

        require(pool.extFarmInfo.extFarmAddr == address(0x0),"cannot set extFramAddr again");

        uint256 extPoolLength = ISushiChef(extFarmAddr).poolLength();
        require(_extPid < extPoolLength,"bad _extPid");

        (address lpToken,,,) = ISushiChef(extFarmAddr).poolInfo(_extPid);
        require(lpToken == address(pool.lpToken),"pool mismatch between WanFarm and extFarm");

        pool.extFarmInfo.extFarmAddr = extFarmAddr;
        pool.extFarmInfo.extPid = _extPid;

        emit SetExtFarm(_pid, extFarmAddr, _extPid);
        
    }

    function disableExtEnableClaim(uint256 _pid)public onlyOwner{
        require(_pid < poolInfo.length,"pid >= poolInfo.length");
        PoolInfo storage pool = poolInfo[_pid];

        require(pool.extFarmInfo.extEnableDeposit == false, "can only disable extEnableClaim when extEnableDeposit is disabled");

        pool.extFarmInfo.extEnableClaim = false;
    }

    function pendingExtReward(uint256 _pid, address _user) public view returns(uint256){
        require(_pid < poolInfo.length,"pid >= poolInfo.length");

        PoolInfo storage pool = poolInfo[_pid];
        if(pool.extFarmInfo.extFarmAddr == address(0x0)){
            return 0;
        }

        if(pool.currentSupply <= 0) return 0;

        UserInfo storage user = userInfo[_pid][_user];
        if(user.amount <= 0) return 0;
        
        uint256 extRewardPerShare = pool.extFarmInfo.extRewardPerShare;

        if(pool.extFarmInfo.extEnableDeposit){
            uint256 totalPendingSushi = ISushiChef(pool.extFarmInfo.extFarmAddr).pendingSushi(pool.extFarmInfo.extPid,address(this));
            extRewardPerShare = totalPendingSushi.mul(1e12).div(pool.currentSupply).add(extRewardPerShare);
        }

        uint256 userPendingSuShi = user.amount.mul(extRewardPerShare).div(1e12).sub(user.extRewardDebt);

        return userPendingSuShi;
    }

    function depositLPToSuShiChef(uint256 _pid,uint256 _amount) internal {
        require(_pid < poolInfo.length,"pid >= poolInfo.length");
        PoolInfo storage pool = poolInfo[_pid];

        if(pool.extFarmInfo.extFarmAddr == address(0x0)) return;
        
        UserInfo storage user =  userInfo[_pid][msg.sender];

        if(pool.extFarmInfo.extEnableDeposit){
            
            uint256 oldSuShiRewarad = IERC20(ISushiChef(pool.extFarmInfo.extFarmAddr).sushi()).balanceOf(address(this));
            uint256 oldTotalDeposit = pool.currentSupply.sub(_amount);
            
            ISushiChef(pool.extFarmInfo.extFarmAddr).deposit(pool.extFarmInfo.extPid, _amount);

            uint256 deltaSuShiReward = IERC20(ISushiChef(pool.extFarmInfo.extFarmAddr).sushi()).balanceOf(address(this));
            deltaSuShiReward = deltaSuShiReward.sub(oldSuShiRewarad);

            if(oldTotalDeposit > 0 && deltaSuShiReward > 0){
                pool.extFarmInfo.extRewardPerShare = deltaSuShiReward.mul(1e12).div(oldTotalDeposit).add(pool.extFarmInfo.extRewardPerShare);
            }

        }

        if(pool.extFarmInfo.extEnableClaim) {
            uint256 transferSuShiAmount = user.amount.sub(_amount).mul(pool.extFarmInfo.extRewardPerShare).div(1e12).sub(user.extRewardDebt);
            
            if(transferSuShiAmount > 0){
                address sushiToken = ISushiChef(pool.extFarmInfo.extFarmAddr).sushi();
                IERC20(sushiToken).safeTransfer(msg.sender,transferSuShiAmount);
            }
        }

        pool.extFarmInfo.extTotalDebtReward = pool.extFarmInfo.extTotalDebtReward.sub(user.extRewardDebt);
        user.extRewardDebt = user.amount.mul(pool.extFarmInfo.extRewardPerShare).div(1e12);
        pool.extFarmInfo.extTotalDebtReward = pool.extFarmInfo.extTotalDebtReward.add(user.extRewardDebt);
        
    }

    function withDrawLPFromSuShi(uint256 _pid,uint256 _amount) internal{
        require(_pid < poolInfo.length,"pid >= poolInfo.length");
        PoolInfo storage pool = poolInfo[_pid];
        UserInfo storage user =  userInfo[_pid][msg.sender];

        if(pool.extFarmInfo.extFarmAddr == address(0x0)) return;

        if(pool.extFarmInfo.extEnableDeposit){
            
            require(user.amount >= _amount,"withdraw too much lpToken");

            uint256 oldSuShiRewarad = IERC20(ISushiChef(pool.extFarmInfo.extFarmAddr).sushi()).balanceOf(address(this));
            uint256 oldTotalDeposit = pool.currentSupply;
            
            ISushiChef(pool.extFarmInfo.extFarmAddr).withdraw(pool.extFarmInfo.extPid, _amount);

            uint256 deltaSuShiReward = IERC20(ISushiChef(pool.extFarmInfo.extFarmAddr).sushi()).balanceOf(address(this)).sub(oldSuShiRewarad);
            if(oldTotalDeposit > 0 && deltaSuShiReward > 0) pool.extFarmInfo.extRewardPerShare = deltaSuShiReward.mul(1e12).div(oldTotalDeposit).add(pool.extFarmInfo.extRewardPerShare);
            
        }

        if(pool.extFarmInfo.extEnableClaim) {
            uint256 transferSuShiAmount = user.amount.mul(pool.extFarmInfo.extRewardPerShare).div(1e12).sub(user.extRewardDebt);

            if(transferSuShiAmount > 0){
                address sushiToken = ISushiChef(pool.extFarmInfo.extFarmAddr).sushi();
                IERC20(sushiToken).safeTransfer(msg.sender,transferSuShiAmount);
            }
        }
        
        pool.extFarmInfo.extTotalDebtReward = pool.extFarmInfo.extTotalDebtReward.sub(user.extRewardDebt);
        user.extRewardDebt = user.amount.sub(_amount).mul(pool.extFarmInfo.extRewardPerShare).div(1e12);
        pool.extFarmInfo.extTotalDebtReward = pool.extFarmInfo.extTotalDebtReward.add(user.extRewardDebt);
    }

    //////////////////////////////////////////////////////////////////////////////////////////////

    // Update reward variables of the given pool to be up-to-date.
    function updatePool(uint256 _pid) internal {
        PoolInfo storage pool = poolInfo[_pid];
        if (block.number <= pool.lastRewardBlock) {
            return;
        }
        if (pool.currentSupply == 0) {
            pool.lastRewardBlock = block.number;
            return;
        }

        uint256 multiplier = getMultiplier(_pid);
        uint256 wanWanReward = multiplier.mul(pool.wanWanPerBlock);
        pool.accwanWanPerShare = pool.accwanWanPerShare.add(wanWanReward.mul(1e12).div(pool.currentSupply));
        pool.lastRewardBlock = block.number;

    }

    // Deposit LP tokens to MasterChef for wanWan allocation.
    function deposit(uint256 _pid, uint256 _amount) public  {
        require(_pid < poolInfo.length, "pid >= poolInfo.length");

        PoolInfo storage pool = poolInfo[_pid];
        updatePool(_pid);

        UserInfo storage user = userInfo[_pid][msg.sender];
        if (user.amount > 0) {
            uint256 pending = user.amount.mul(pool.accwanWanPerShare).div(1e12).sub(user.rewardDebt);
            if(pending > 0) {
                wanWan.transfer(msg.sender, pending);
            }
        }

        if(_amount > 0) {
            pool.lpToken.safeTransferFrom(address(msg.sender), address(this), _amount);
            user.amount = user.amount.add(_amount);
            pool.currentSupply = pool.currentSupply.add(_amount);
        }
        
        // must excute after lpToken has beem transfered from user to this contract and the amount of user depoisted is updated.
        depositLPToSuShiChef(_pid,_amount); 
            
        pool.totalDebtReward = pool.totalDebtReward.sub(user.rewardDebt);
        user.rewardDebt = user.amount.mul(pool.accwanWanPerShare).div(1e12);
        pool.totalDebtReward = pool.totalDebtReward.add(user.rewardDebt);

        emit Deposit(msg.sender, _pid, _amount);
    }

    // Withdraw LP tokens from MasterChef.
    function withdraw(uint256 _pid, uint256 _amount) public  {
        require(_pid < poolInfo.length, "pid >= poolInfo.length");
        PoolInfo storage pool = poolInfo[_pid];
        UserInfo storage user = userInfo[_pid][msg.sender];
        require(user.amount >= _amount, "withdraw: not good");

        withDrawLPFromSuShi(_pid,_amount);
        updatePool(_pid);
        uint256 pending = user.amount.mul(pool.accwanWanPerShare).div(1e12).sub(user.rewardDebt);
        if(pending > 0) {
            wanWan.transfer(msg.sender, pending);
        }
        if(_amount > 0) {
            user.amount = user.amount.sub(_amount);
            pool.currentSupply = pool.currentSupply.sub(_amount);
            pool.lpToken.safeTransfer(address(msg.sender), _amount);
        }

        pool.totalDebtReward = pool.totalDebtReward.sub(user.rewardDebt);
        user.rewardDebt = user.amount.mul(pool.accwanWanPerShare).div(1e12);
        pool.totalDebtReward = pool.totalDebtReward.add(user.rewardDebt);
        emit Withdraw(msg.sender, _pid, _amount);
    }


    function emergencyWithdraw(uint256 _pid) public onlyOwner  {
        require(_pid < poolInfo.length, "pid >= poolInfo.length");
        PoolInfo storage pool = poolInfo[_pid];

        if(pool.extFarmInfo.extFarmAddr == address(0x0)) return;

        ISushiChef(pool.extFarmInfo.extFarmAddr).emergencyWithdraw(pool.extFarmInfo.extPid);

        pool.extFarmInfo.extEnableDeposit = false;            

        emit EmergencyWithdraw(_pid);
    }

    // Safe wanWan transfer function, just in case if rounding error causes pool to not have enough wanWan.
    function safewanWanTransfer(address _to, uint256 _amount) internal {
        uint256 wanWanBal = wanWan.balanceOf(address(this));
        if (_amount > wanWanBal) {
            wanWan.transfer(_to, wanWanBal);
        } else {
            wanWan.transfer(_to, _amount);
        }
    }

    function quitwanWan(address _to) public onlyOwner {
        require(_to != address(0), "_to == 0");
        uint256 wanWanBal = wanWan.balanceOf(address(this));
        uint256 length = poolInfo.length;
        for (uint256 pid = 0; pid < length; ++pid) {
            PoolInfo storage pool = poolInfo[pid];
            require(block.number > pool.bonusEndBlock, "quitWanwan block.number <= pid.bonusEndBlock");
            updatePool(pid);
            uint256 wanWanReward = pool.currentSupply.mul(pool.accwanWanPerShare).div(1e12).sub(pool.totalDebtReward);
            wanWanBal = wanWanBal.sub(wanWanReward);
        }
        safewanWanTransfer(_to, wanWanBal);
        emit QuitWanwan(_to, wanWanBal);
    }

    function quitExtFarm(address extFarmAddr, address _to) public onlyOwner{
        require(_to != address(0), "_to == 0");
        require(extFarmAddr != address(0), "extFarmAddr == 0");

        IERC20 sushiToken = IERC20(ISushiChef(extFarmAddr).sushi());

        uint256 sushiBalance = sushiToken.balanceOf(address(this));

        uint256 totalUnclaimedReward = totalUnclaimedExtFarmReward(extFarmAddr);

        require(totalUnclaimedReward <= sushiBalance, "extreward shortage");

        uint256 quitBalance = sushiBalance.sub(totalUnclaimedReward);

        sushiToken.safeTransfer(_to, quitBalance);
        emit QuitExtReward(extFarmAddr,address(sushiToken),_to, quitBalance);
    }

    function _become(UniFarm uniFarm) public {
        require(msg.sender == uniFarm.admin(), "only uniFarm admin can change brains");
        require(uniFarm._acceptImplementation() == 0, "change not authorized");
    }

}