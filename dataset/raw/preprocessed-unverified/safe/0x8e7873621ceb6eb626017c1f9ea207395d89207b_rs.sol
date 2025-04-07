/**
 *Submitted for verification at Etherscan.io on 2020-10-16
*/

pragma solidity ^0.5.8;



contract Context {
    // Empty internal constructor, to prevent people from mistakenly deploying
    // an instance of this contract, which should be used via inheritance.
    constructor () internal { }

    function _msgSender() internal view  returns (address payable) {
        return msg.sender;
    }

    function _msgData() internal view  returns (bytes memory) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}









contract ERC20 is Context, IERC20 {
    using SafeMath for uint256;

    mapping (address => uint256) private _balances;

    mapping (address => mapping (address => uint256)) private _allowances;

    uint256 private _totalSupply;

    /**
     * @dev See {IERC20-totalSupply}.
     */
    function totalSupply() public view  returns (uint256) {
        return _totalSupply;
    }

    /**
     * @dev See {IERC20-balanceOf}.
     */
    function balanceOf(address account) public view  returns (uint256) {
        return _balances[account];
    }

    /**
     * @dev See {IERC20-transfer}.
     *
     * Requirements:
     *
     * - `recipient` cannot be the zero address.
     * - the caller must have a balance of at least `amount`.
     */
    function transfer(address recipient, uint256 amount) public   returns (bool) {
        _transfer(_msgSender(), recipient, amount);
        return true;
    }

    /**
     * @dev See {IERC20-allowance}.
     */
    function allowance(address owner, address spender) public view   returns (uint256) {
        return _allowances[owner][spender];
    }

    /**
     * @dev See {IERC20-approve}.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     */
    function approve(address spender, uint256 amount) public   returns (bool) {
        _approve(_msgSender(), spender, amount);
        return true;
    }

    /**
     * @dev See {IERC20-transferFrom}.
     *
     * Emits an {Approval} event indicating the updated allowance. This is not
     * required by the EIP. See the note at the beginning of {ERC20};
     *
     * Requirements:
     * - `sender` and `recipient` cannot be the zero address.
     * - `sender` must have a balance of at least `amount`.
     * - the caller must have allowance for `sender`'s tokens of at least
     * `amount`.
     */
    function transferFrom(address sender, address recipient, uint256 amount) public   returns (bool) {
        _transfer(sender, recipient, amount);
        _approve(sender, _msgSender(), _allowances[sender][_msgSender()].sub(amount, "ERC20: transfer amount exceeds allowance"));
        return true;
    }

    /**
     * @dev Atomically increases the allowance granted to `spender` by the caller.
     *
     * This is an alternative to {approve} that can be used as a mitigation for
     * problems described in {IERC20-approve}.
     *
     * Emits an {Approval} event indicating the updated allowance.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     */
    function increaseAllowance(address spender, uint256 addedValue) public  returns (bool) {
        _approve(_msgSender(), spender, _allowances[_msgSender()][spender].add(addedValue));
        return true;
    }

    /**
     * @dev Atomically decreases the allowance granted to `spender` by the caller.
     *
     * This is an alternative to {approve} that can be used as a mitigation for
     * problems described in {IERC20-approve}.
     *
     * Emits an {Approval} event indicating the updated allowance.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     * - `spender` must have allowance for the caller of at least
     * `subtractedValue`.
     */
    function decreaseAllowance(address spender, uint256 subtractedValue) public  returns (bool) {
        _approve(_msgSender(), spender, _allowances[_msgSender()][spender].sub(subtractedValue, "ERC20: decreased allowance below zero"));
        return true;
    }

    /**
     * @dev Moves tokens `amount` from `sender` to `recipient`.
     *
     * This is internal function is equivalent to {transfer}, and can be used to
     * e.g. implement automatic token fees, slashing mechanisms, etc.
     *
     * Emits a {Transfer} event.
     *
     * Requirements:
     *
     * - `sender` cannot be the zero address.
     * - `recipient` cannot be the zero address.
     * - `sender` must have a balance of at least `amount`.
     */
    function _transfer(address sender, address recipient, uint256 amount) internal  {
        require(sender != address(0), "ERC20: transfer from the zero address");
        require(recipient != address(0), "ERC20: transfer to the zero address");


        _balances[sender] = _balances[sender].sub(amount, "ERC20: transfer amount exceeds balance");
        _balances[recipient] = _balances[recipient].add(amount);
        emit Transfer(sender, recipient, amount);
    }

    /** @dev Creates `amount` tokens and assigns them to `account`, increasing
     * the total supply.
     *
     * Emits a {Transfer} event with `from` set to the zero address.
     *
     * Requirements
     *
     * - `to` cannot be the zero address.
     */
    function _mint(address account, uint256 amount) internal  {
        require(account != address(0), "ERC20: mint to the zero address");


        _totalSupply = _totalSupply.add(amount);
        _balances[account] = _balances[account].add(amount);
        emit Transfer(address(0), account, amount);
    }

    /**
     * @dev Destroys `amount` tokens from `account`, reducing the
     * total supply.
     *
     * Emits a {Transfer} event with `to` set to the zero address.
     *
     * Requirements
     *
     * - `account` cannot be the zero address.
     * - `account` must have at least `amount` tokens.
     */
    function _burn(address account, uint256 amount) internal  {
        require(account != address(0), "ERC20: burn from the zero address");


        _balances[account] = _balances[account].sub(amount, "ERC20: burn amount exceeds balance");
        _totalSupply = _totalSupply.sub(amount);
        emit Transfer(account, address(0), amount);
    }

    /**
     * @dev Sets `amount` as the allowance of `spender` over the `owner`s tokens.
     *
     * This is internal function is equivalent to `approve`, and can be used to
     * e.g. set automatic allowances for certain subsystems, etc.
     *
     * Emits an {Approval} event.
     *
     * Requirements:
     *
     * - `owner` cannot be the zero address.
     * - `spender` cannot be the zero address.
     */
    function _approve(address owner, address spender, uint256 amount) internal  {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

   
}

contract HalvingGovernance
{   
    using SafeMath for uint256;
    using SafeERC20 for IERC20;
    
    address payable public owner;
    IERC20 internal halvToken;
    uint256 public governanceStartTime;     //Timestamp since when the Halving Token Governance started from , the APR would be changed based on this
    uint256 public totalTokenStaked;
    uint256 private yearDuration = 365 days;
    uint256 private firstYear;
    uint256 private secondYear;
        
    mapping(address => Details) public getUserDetails;
    
    struct Details{
        uint256 lastUpdateTime;
        uint256 totalAmountStaked;
        uint256 earnedRewards;
        uint256 rewardPerToken;
    }
    
    modifier onlyOwner() {
        require (msg.sender == owner,"Not Owner");
        _;
    }

    modifier updateReward(address account) {
        require(account != address(0),"Zero Address can't be user");
            getUserDetails[account].rewardPerToken = getRewardPerToken(account);
            getUserDetails[account].earnedRewards = earned(account);
            getUserDetails[account].lastUpdateTime = block.timestamp;
        _;
    }
    
    
    event Staked(address staker,uint256 amountStaked,uint256 stakedTime,uint256 stakerTotalStake);
    event Unstaked(address recipient,uint256 amountUnstaked,uint256 unstakedTime,uint256 stakerTotalStake);
    event RewardsClaimed(address recipient, uint256 reward,uint256 claimedRewardFees);
    
    constructor (address tokenAddress) public  {
        owner = msg.sender;
        halvToken = IERC20(tokenAddress);
        governanceStartTime=block.timestamp;
        firstYear = governanceStartTime.add(yearDuration);
        secondYear = firstYear.add(yearDuration);
    }
    
    function () external payable {  //fallback function to collect Ethereum sent to Contract
        
    }
    
    function tokenAddress() public view returns(address){
        return address(halvToken);
    }
    
    function poolReserve() public view returns(uint256){
        return halvToken.balanceOf(address(this));
    }
    
    function getCurrentAPR() public view returns(uint256){
        if(block.timestamp <= firstYear){       // For 1st Year
            return 24;
        }
        else if( (block.timestamp > firstYear) && (block.timestamp <= secondYear) ){  // For 2nd Year
            return 12;
        }
        else if (block.timestamp > secondYear){  // 3rd Year Onwards
            return 6;
        }
    }
    
    function getRewardPerToken(address account) private view returns (uint256) {
        uint256 lastUpdatedTime = getUserDetails[account].lastUpdateTime;
        uint256 durationStaked = block.timestamp.sub(lastUpdatedTime);
        uint256 durationStakedFractioned = durationStaked.mul(1e18).div(365 days);

        if (getUserDetails[account].totalAmountStaked == 0 || lastUpdatedTime == 0) {
            return 0;                    //users rewardPerToken becomes 0 when if there is no staked Amount or staking first time
        }
        
        return
            getUserDetails[account].rewardPerToken.add(
                getCurrentAPR()
                    .mul(1e16)
                    .mul(durationStakedFractioned)
                    .div(1e18)
            );
    }
    
    function _preValidateData(address _sender,uint256 _amount) internal view{
        require(_sender != address(0), "Beneficiary cannot be the zero address");
        require(_amount != 0, "Stake/Unstake Token Amount should be greater than 0");
        require(_amount < poolReserve(), "Cannot stake/unstake Amount greater than or equal to Pool Reserve");
    }
    
    function stake(uint256 tokenAmount) external updateReward(msg.sender){
        _preValidateData(msg.sender,tokenAmount);

        totalTokenStaked=totalTokenStaked.add(tokenAmount);
        getUserDetails[msg.sender].totalAmountStaked = getUserDetails[msg.sender].totalAmountStaked.add(tokenAmount);
        halvToken.safeTransferFrom(msg.sender,address(this),tokenAmount);
        
        emit Staked(msg.sender,tokenAmount,block.timestamp,getUserDetails[msg.sender].totalAmountStaked);
    }
    
    function unstake(uint256 tokenAmount) public  updateReward(msg.sender){
        _preValidateData(msg.sender,tokenAmount);
        require(getUserDetails[msg.sender].totalAmountStaked >=tokenAmount,"Insufficient Token at Stake");
        
        totalTokenStaked=totalTokenStaked.sub(tokenAmount);
        getUserDetails[msg.sender].totalAmountStaked = getUserDetails[msg.sender].totalAmountStaked.sub(tokenAmount);
        halvToken.safeTransfer(msg.sender, tokenAmount);
        
        emit Unstaked(msg.sender,tokenAmount,block.timestamp,getUserDetails[msg.sender].totalAmountStaked);
    }
    
    function earned(address account) public view returns (uint256) {
        uint256 userTotalAmountStaked = getUserDetails[account].totalAmountStaked;
        uint256 userEarnedRewards = userTotalAmountStaked
                                            .mul(getRewardPerToken(account))
                                            .div(1e18)
                                            .add(getUserDetails[account].earnedRewards);
            return userEarnedRewards;
    }
    
    function claimRewards() public updateReward(msg.sender){
        address account = msg.sender;
        uint256 reward = earned(account);
        require(reward > 0,"No Claimable rewards pending");
        
        getUserDetails[account].earnedRewards = 0;
        uint256 claimableReward = (reward.div(1000)).mul(980);    //getUserDetails can redeem 98% of there total earned Rewards 
        uint256 rewardFees = reward.sub(claimableReward);         // remaining 2% is treated as platform fees 
        require(claimableReward.add(rewardFees) == reward,"Unable to transfer full Reward's");
        halvToken.safeTransfer(account, claimableReward);
        halvToken.safeTransfer(owner,rewardFees);                 //fees transferred to owner
        emit RewardsClaimed(account, reward, rewardFees);
    }
    
    function exit() external {
        unstake(getUserDetails[msg.sender].totalAmountStaked);
        claimRewards();
    }
    
    function withdrawFallbackBalnce() external onlyOwner  {
        uint256 fallbackBalance=address(this).balance;
        require(fallbackBalance>0,"No Balance to be withdrawn");
        owner.transfer(fallbackBalance);
    }
    
    function withdrawPoolReserve(uint256 amount) external onlyOwner  {
        require(poolReserve()>0,"No Pool Reserve to be withdrawn");
        halvToken.safeTransfer(owner,amount);
    }
}