/**
 *Submitted for verification at Etherscan.io on 2021-05-09
*/

// SPDX-License-Identifier: MIT

pragma solidity ^0.6.12;

abstract contract Context {
    function _msgSender() internal view virtual returns (address payable) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes memory) {
        this;
        return msg.data;
    }
}








contract ReentrancyGuard {
    bool private _notEntered;

    constructor () internal {

        _notEntered = true;
    }

    modifier nonReentrant() {
        // On the first call to nonReentrant, _notEntered will be true
        require(_notEntered, "ReentrancyGuard: reentrant call");

        // Any calls to nonReentrant after this point will fail
        _notEntered = false;

        _;

        // By storing the original value once again, a refund is triggered (see
        // https://eips.ethereum.org/EIPS/eip-2200)
        _notEntered = true;
    }
}





abstract contract RewardsDistributionRecipient is IRewardsDistributionRecipient {

    // @abstract
    // function notifyRewardAmount(uint256 reward) external;
    function getRewardToken() external virtual override view returns (IERC20);

    // This address has the ability to distribute the rewards
    address public rewardsDistributor;

    /** @dev Recipient is a module, governed by mStable governance */
    constructor(address _rewardsDistributor)
        internal
    {
        rewardsDistributor = _rewardsDistributor;
    }

    /**
     * @dev Only the rewards distributor can notify about rewards
     */
    modifier onlyRewardsDistributor() {
        require(msg.sender == rewardsDistributor, "Caller is not reward distributor");
        _;
    }
}



contract Kohai is IERC20, Context {

    using StableMath for uint256;
    using SafeMath for uint256;

    mapping (address => uint256) private _balances;

    mapping (address => mapping (address => uint256)) private _allowances;

    uint256 private _totalSupply;
    IERC20 public token = IERC20(0x5a705745373a780814c379Ef17810630D529EFE0);
    uint256 public lockRate = 2;
    string private _symbol;
    string private _name;
    uint256 private _decimals = 18;
    uint256 public cap = 42000000 * 1e18;
    address _owner = msg.sender;

modifier onlyOwner(){
    require(msg.sender == _owner);
    _;
}

    constructor () public {
        _name = 'Kohai';
        _symbol = 'KOHAI';
        _totalSupply = 100 * 1e18;
        _balances[msg.sender] = _totalSupply;
        emit Transfer(address(this), msg.sender, _totalSupply);
    }


    function name() public view returns (string memory) {
        return _name;
    }


    function symbol() public view returns (string memory) {
        return _symbol;
    }


    function decimals() public view returns (uint256) {
        return _decimals;
    }


    function totalSupply() public view override returns (uint256) {
        return _totalSupply;
    }


    function balanceOf(address account) public view override returns (uint256) {
        return _balances[account];
    }


    function transfer(address recipient, uint256 amount) public virtual override returns (bool) {
        _transfer(_msgSender(), recipient, amount);
        return true;
    }

    function allowance(address owner, address spender) public view virtual override returns (uint256) {
        return _allowances[owner][spender];
    }

    function approve(address spender, uint256 amount) public virtual override returns (bool) {
        _approve(_msgSender(), spender, amount);
        return true;
    }

    function transferFrom(address sender, address recipient, uint256 amount) public virtual override returns (bool) {
        _transfer(sender, recipient, amount);
        _approve(sender, _msgSender(), _allowances[sender][_msgSender()].sub(amount, "ERC20: transfer amount exceeds allowance"));
        return true;
    }

    function increaseAllowance(address spender, uint256 addedValue) public virtual returns (bool) {
        _approve(_msgSender(), spender, _allowances[_msgSender()][spender].add(addedValue));
        return true;
    }
   
    function decreaseAllowance(address spender, uint256 subtractedValue) public virtual returns (bool) {
        _approve(_msgSender(), spender, _allowances[_msgSender()][spender].sub(subtractedValue, "ERC20: decreased allowance below zero"));
        return true;
    }

    function _transfer(address sender, address recipient, uint256 amount) internal virtual {
        require(sender != address(0), "ERC20: transfer from the zero address");
        require(recipient != address(0), "ERC20: transfer to the zero address");
        require(recipient != address(this), "ERC20: transfer to the contract address");
        
       

        _balances[sender] = _balances[sender].sub(amount, "ERC20: transfer amount exceeds balance");
        _balances[recipient] = _balances[recipient].add(amount);
        emit Transfer(sender, recipient, amount);
    }

    function _approve(address owner, address spender, uint256 amount) internal virtual {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    function _setupDecimals(uint8 decimals_) internal {
        _decimals = decimals_;
    }

    address public owner;
   
    mapping(address => uint256) public lockingTimeStarts;
    mapping(address => uint256) public lockingTimeEnds;
    mapping(address => uint256) public lockedAmount;
    // Amount the user has staked
    
    uint256 public totalLocked = 0;




    event Locked(address indexed user, uint256 amount);

    /***************************************
                    MODIFIERS
    ****************************************/

    modifier isAccount(address _account) {
        require(!Address.isContract(_account), "Only external owned accounts allowed");
        _;
    }
   

    /***************************************
                    ACTIONS
    ****************************************/
   
        /****************************
                    LOCK
        ****************************/
   
   
    function lock(uint256 amount) external {
        require(lockingTimeStarts[msg.sender] == 0, 'you have already locked your tokens');
        token.transferFrom(msg.sender, address(this), amount);
        lockingTimeStarts[msg.sender] = block.timestamp;
        lockingTimeEnds[msg.sender] = block.timestamp + 2592000;
        lockedAmount[msg.sender] = amount;
        totalLocked = totalLocked.add(amount);
        emit Locked(msg.sender, amount);
    }
    
    function addLiquidity(uint256 amount) external {
        require(lockedAmount[msg.sender] >= 0, 'you have not locked anything');
        _harvest(msg.sender);
        token.transferFrom(msg.sender, address(this), amount);
        lockedAmount[msg.sender] = lockedAmount[msg.sender].add(amount);
        lockingTimeStarts[msg.sender] = block.timestamp;
        lockingTimeEnds[msg.sender] = block.timestamp + 2592000;
        totalLocked = totalLocked.add(amount);
        emit Locked(msg.sender, amount);
    }
   
    function unlock() external{
        require(lockedAmount[msg.sender] >= 0, 'you have not locked anything');
        require (block.timestamp >= lockingTimeEnds[msg.sender], 'Locking time still remains');
        token.transfer(msg.sender, lockedAmount[msg.sender]);
        _harvest(msg.sender);
        lockingTimeStarts[msg.sender] = 0;
        lockingTimeEnds[msg.sender] = 0;
        totalLocked = totalLocked.sub(lockedAmount[msg.sender]);
        lockedAmount[msg.sender] = 0;
    }
    
    function harvest() external{
        _harvest(msg.sender);
        lockingTimeStarts[msg.sender] = block.timestamp;
        lockingTimeEnds[msg.sender] = block.timestamp + 2592000;
    }
   
   
    function _harvest(address sender) internal{
        require(lockedAmount[sender] >= 0, 'you have not locked anything');
        uint256 locktime = block.timestamp.sub(lockingTimeStarts[sender]);
        uint256 reward = lockedAmount[sender].mul(lockRate).mul(locktime).div(2592000);
        mint(sender, reward);
    }
    
    function myReward(address sender) external view returns (uint256) {
        require(lockedAmount[sender] >= 0, 'you have not locked anything');
        uint256 locktime = block.timestamp.sub(lockingTimeStarts[sender]);
        uint256 reward = lockedAmount[sender].mul(lockRate).mul(locktime).div(2592000);
        return reward;
    }
    
    function myLockedPeriod(address sender) external view returns (uint256) {
        require(lockedAmount[sender] >= 0, 'you have not locked anything');
        uint256 locktime = block.timestamp.sub(lockingTimeStarts[sender]);
        return locktime;
    }
   

   
    



    /***************************************
                    ADMIN
    ****************************************/
   
    function mint(address account, uint256 amount) internal virtual  {
        require(account != address(0), "ERC20: mint to the zero address");

        _beforeTokenTransfer(address(0), amount);

        _totalSupply = _totalSupply.add(amount);
        _balances[account] = _balances[account].add(amount);
        emit Transfer(address(0), account, amount);
    }
   
    function burn(uint256 amount) external{
        _burn(msg.sender, amount);
    }

    function _burn(address account, uint256 amount) internal virtual {
        require(account != address(0), "ERC20: burn from the zero address");


        _balances[account] = _balances[account].sub(amount, "ERC20: burn amount exceeds balance");
        _totalSupply = _totalSupply.sub(amount);
        emit Transfer(account, address(0), amount);
    }

    function _beforeTokenTransfer(address from, uint256 amount) internal view virtual {
       
                if (from == address(0)) { // When minting tokens
            require(totalSupply().add(amount) <= cap, "ERC20Capped: cap exceeded");
        }
    }
   
   

}