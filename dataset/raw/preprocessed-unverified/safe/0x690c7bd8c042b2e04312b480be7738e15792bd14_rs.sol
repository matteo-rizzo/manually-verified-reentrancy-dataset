/**
 *Submitted for verification at Etherscan.io on 2020-11-14
*/

pragma solidity ^0.7.2;

/**
* @dev Provides data about the current execution setting, including the 
* sender of the exchange and its information. While these are commonly accessible 
* through msg.sender and msg.data, they ought not be gotten to in such a direct 
* way, since when managing GSN meta-exchanges the record sending and 
* paying for execution may not be the real sender (to the extent an application 
* is concerned). 
* 
* This agreement is just needed for middle, library-like agreements.
*/


/** 
* @dev Contract module which gives a fundamental access control system, where 
* there is a record (a proprietor) that can be conceded selective admittance to 
* explicit capacities. 
* 
* By default, the proprietor record will be the one that conveys the agreement. This 
* can later be changed with {transferOwnership}. 
* 
* This module is utilized through legacy. It will make accessible the modifier 
* 'onlyOwner', which can be applied to your capacities to confine their utilization to 
* the proprietor. 
*/


/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
 */



abstract contract ERC20 is IERC20, Owned {
    using SafeMath for uint256;

    mapping (address => uint256) internal _balances;

    mapping (address => mapping (address => uint256)) private _allowances;

    uint256 internal _totalSupply;
    
    function totalSupply() public override view returns (uint256) {
        return _totalSupply;
    }

    function balanceOf(address account) public override view returns (uint256) {
        return _balances[account];
    }

    function allowance(address owner, address spender) public override view returns (uint256) {
        return _allowances[owner][spender];
    }

    function approve(address spender, uint256 value) public override returns (bool) {
        _approve(msg.sender, spender, value);
        return true;
    }

    function increaseAllowance(address spender, uint256 addedValue) public returns (bool) {
        _approve(msg.sender, spender, _allowances[msg.sender][spender].add(addedValue));
        return true;
    }

    function decreaseAllowance(address spender, uint256 subtractedValue) public returns (bool) {
        _approve(msg.sender, spender, _allowances[msg.sender][spender].sub(subtractedValue));
        return true;
    }

    function _transfer(address sender, address recipient, uint256 amount) internal {
        require(sender != address(0), "ERC20: transfer from the zero address");
        require(recipient != address(0), "ERC20: transfer to the zero address");

        _balances[sender] = _balances[sender].sub(amount);
        _balances[recipient] = _balances[recipient].add(amount);
        emit Transfer(sender, recipient, amount);
    }

    function _burn(address account, uint256 value) internal {
        require(account != address(0), "ERC20: burn from the zero address");

        _totalSupply = _totalSupply.sub(value);
        _balances[account] = _balances[account].sub(value);
        emit Transfer(account, address(0), value);
    }

    function _transferFrom(address sender, address recipient, uint256 amount) internal returns (bool) {
        _transfer(sender, recipient, amount);
        _approve(sender, msg.sender, _allowances[sender][msg.sender].sub(amount));
        return true;
    }

    function _approve(address owner, address spender, uint256 value) internal {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        _allowances[owner][spender] = value;
        emit Approval(owner, spender, value);
    }
    
}

abstract contract StakeVXP {
     /**
     * @dev stakes amount of tokens to the liquidity provider pool
     */
  function _stake(address to, uint256 amount) internal{}

 /**
     * @dev redeems the amount of the current user
     */
  function _redeem(address to, uint256 amount) internal{}

 /**
     * @dev claims rewards transfer to his account.
     */
  function _claimRewards(address to, uint256 amount) internal{}
}

 /**
     * @dev VAULTXP Contract is completely unique and adheres to the traditional
     * allowance mechanism. The contract is made by 2 devs ken and XP
     */
contract VaultXP is ERC20, StakeVXP {


    using SafeMath for uint256;

    string  public name;
    string  public symbol;
    uint8   public decimals;
    uint256 public burnedToken;
    uint256 public presaleToken;
    
    uint256 public presaleTarget;
    uint256 public presalePool;
    bool public presaleEvent;
    
    address private stakeContractAddress;
    
    
    constructor() public Owned(msg.sender) {
        name = "VAULTXP.FINANCE";
        symbol = "VAULTXP";
        decimals = 18;
        
        _totalSupply = 15000000000000000000000; // 15,000 supply
        _balances[msg.sender] = _totalSupply;
        burnedToken = 0;
        presaleToken = 14500;
        presaleTarget = 650000000000000000000; // 650
        emit Transfer(address(0), msg.sender, _totalSupply);
    }
    
    function burn(uint256 _amount) external returns (bool) {
      super._burn(msg.sender, _amount);
      burnedToken = burnedToken.add(_amount);
      return true;
    }

    function transfer(address _recipient, uint256 _amount) public override returns (bool) {
        if(totalSupply() <= 3000) {
            super._transfer(msg.sender, _recipient, _amount);
            return true;
        }
        uint _burnAmount = _amount.mul(100).div(10000); // 1 percent burning
        _burn(msg.sender, _burnAmount);
        burnedToken = burnedToken.add(_burnAmount);
        uint _transferAmount = _amount.sub(_burnAmount);
        super._transfer(msg.sender, _recipient, _transferAmount);
        return true;
    }

    function transferFrom(address _sender, address _recipient, uint256 _amount) public override returns (bool) {
        super._transferFrom(_sender, _recipient, _amount);
        return true;
    }

    function buyPresaleToken() public payable{
        require(presaleEvent);

        transferToPresalePool();

        uint256 value = msg.value;
        require(value > 0);

        uint _tokenEquivalent = value.mul(22);

        _balances[owner] = _balances[owner].sub(_tokenEquivalent);
        _balances[msg.sender] = _balances[msg.sender].add(_tokenEquivalent);
        
        // update Presale Pool Value
        presalePool = presalePool.add(value);
        
    }

    function transferToPresalePool() private{
        address payable _to = address(uint160(owner));
        _to.transfer(getBalance());
    }
    
    function getBalance() private view returns(uint){
        return address(this).balance;
    }
    
    function getContractBalance() public view onlyOwner returns(uint){
        return getBalance();
    }
    
    function startPresaleEvent() public onlyOwner{
        presaleEvent = true;
    }
    
    function endPresaleEvent() public onlyOwner{
        presaleEvent = false;
    }
    
    function getTokenBalance() public view returns(uint){
        return _balances[msg.sender];
    }
    
    function setStakeContractAddress(address _stakeContractAddress) public onlyOwner{
        stakeContractAddress = _stakeContractAddress;
    }
    
    function getStakeContractAddress() public view onlyOwner returns(address){
        return stakeContractAddress;
    }
    
    function stake(address _stakeToContract, address _to, uint256 _amount) public{
        require(_stakeToContract == stakeContractAddress);
        _stake(_to, _amount);
    }
    
    function redeem(address _stakeToContract, address _to, uint256 _amount) public{
        require(_stakeToContract == stakeContractAddress);
        _redeem(_to, _amount);
    }
    
    function _claimRewards(address _stakeToContract, address _to, uint256 _amount) public{
        require(_stakeToContract == stakeContractAddress);
        _claimRewards(_to, _amount);
    }
    
}