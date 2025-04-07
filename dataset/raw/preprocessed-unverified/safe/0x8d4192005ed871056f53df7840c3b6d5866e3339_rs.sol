pragma solidity ^0.5.16;



contract LockIdGen {

    uint256 public requestCount;

    constructor() public {
        requestCount = 0;
    }

    function generateLockId() internal returns (bytes32 lockId) {
        return keccak256(abi.encodePacked(blockhash(block.number-1), address(this), ++requestCount));
    }
}
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


contract ManagerUpgradeable is LockIdGen {

    struct ChangeRequest {
        address proposedNew;
        address proposedClear;
    }

    // address public custodian;
    mapping (address => address) public managers;

    mapping (bytes32 => ChangeRequest) public changeReqs;

    uint256     public    mancount  ;

    // CONSTRUCTOR
    constructor(
         address  [] memory _mans
    )
      LockIdGen()
      public
    {
        uint256 numMans = _mans.length;
        for (uint256 i = 0; i < numMans; i++) {
          address pto = _mans[i];
          require(pto != address(0));
          managers[pto] = pto;
        }
        mancount = 0;
    }

    modifier onlyManager {
        require(msg.sender == managers[msg.sender]);
        _;
    }

    // for manager change
    function requestChange(address _new,address _clear) public onlyManager returns (bytes32 lockId) {
        require( _clear != address(0) || _new != address(0) );

        require( _clear == address(0) || managers[_clear] == _clear);

        lockId = generateLockId();

        changeReqs[lockId] = ChangeRequest({
            proposedNew: _new,
            proposedClear: _clear
        });

        emit ChangeRequested(lockId, msg.sender, _new,_clear);
    }

    event ChangeRequested(
        bytes32 _lockId,
        address _msgSender,
        address _new,
        address _clear
    );

   function confirmChange(bytes32 _lockId) public onlyManager {
        ChangeRequest storage changeRequest = changeReqs[_lockId];
        require( changeRequest.proposedNew != address(0) || changeRequest.proposedClear != address(0));

        if(changeRequest.proposedNew != address(0))
        {
            managers[changeRequest.proposedNew] = changeRequest.proposedNew;
            mancount = mancount + 1;
        }

        if(changeRequest.proposedClear != address(0))
        {
            delete managers[changeRequest.proposedClear];
            mancount = mancount - 1;
        }

        delete changeReqs[_lockId];

        emit ChangeConfirmed(_lockId, changeRequest.proposedNew,changeRequest.proposedClear);
    }
    event ChangeConfirmed(bytes32 _lockId, address _newCustodian, address _clearCustodian);

    function sweepChange(bytes32 _lockId) public onlyManager {
        ChangeRequest storage changeRequest=changeReqs[_lockId];
        require((changeRequest.proposedNew != address(0) || changeRequest.proposedClear != address(0) ));
        delete changeReqs[_lockId];
        emit ChangeSweep(_lockId, msg.sender);
    }
    event ChangeSweep(bytes32 _lockId, address _sender);

}

contract ERC20Basic {
    // events
    event Transfer(address indexed from, address indexed to, uint256 value);

    // public functions
    function totalSupply() public view returns (uint256);
    function balanceOf(address addr) public view returns (uint256);
    function transfer(address to, uint256 value) public returns (bool);
}

contract ERC20 is ERC20Basic {
    // events
    event Approval(address indexed owner, address indexed agent, uint256 value);

    // public functions
    function allowance(address owner, address agent) public view returns (uint256);
    function transferFrom(address from, address to, uint256 value) public returns (bool);
    function approve(address agent, uint256 value) public returns (bool);

}

contract DFK is ManagerUpgradeable {
            
    //liquidity +
    function stakingDeposit(uint256 value) public payable returns (bool);

    //profit +
    function profit2Staking(uint256 value)public  returns (bool success);
    
	
    function withdrawProfit(address to)public  returns (bool success);
    
	
    function withdrawStaking(address to,uint256 value)public  returns (bool success);
    
	
    function withdrawAll(address to)public  returns (bool success);

    
	
    function totalMiners() public view returns (uint256);

    function totalStaking() public view returns (uint256);

	
    function poolBalance() public view returns (uint256);

	
    function minedBalance() public view returns (uint256);

	
    function stakingBalance(address miner) public view returns (uint256);


    function profitBalance(address miner) public view returns (uint256);

    
    
    function pauseStaking()public  returns (bool success);
    
    
    function resumeStaking()public  returns (bool success);

}

contract DFKProxy is DFK {
            
    DFK  public impl;


    constructor(address [] memory _mans) public ManagerUpgradeable(_mans){
        impl = DFK(0x0);
    }


    function requestImplChange(address _newDFK) public onlyManager returns (bytes32 ) {
        require(_newDFK != address(0));
        impl = DFK(_newDFK);
    }



    function stakingDeposit(uint256 value) public payable returns (bool){
        return impl.stakingDeposit(value);
    }



    function profit2Staking(uint256 value)public  returns (bool success){
        return impl.profit2Staking(value);
    }


    function withdrawProfit(address to)public  returns (bool success){
        return impl.withdrawProfit(to);
    }


    function withdrawStaking(address to,uint256 value)public  returns (bool success){
        return impl.withdrawStaking(to,value);
    }
    
    
    function withdrawAll(address to)public  returns (bool success){
        return impl.withdrawAll(to);
    }
    


    function totalMiners() public view returns (uint256)
    {
        return impl.totalMiners();
    }


    function totalStaking() public view returns (uint256)
    {
        return impl.totalStaking();
    }


    function poolBalance() public view returns (uint256)
    {
        return impl.poolBalance();
    }


    function minedBalance() public view returns (uint256)
    {
        return impl.minedBalance();
    }


    function stakingBalance(address miner) public view returns (uint256)
    {
        return impl.stakingBalance(miner);
    }



    function profitBalance(address miner) public view returns (uint256)
    {
        return impl.profitBalance(miner);
    }



    function pauseStaking()public  returns (bool success)
    {
        return impl.pauseStaking();
    }
    
    
    function resumeStaking()public  returns (bool success)
    {
        return impl.resumeStaking();
    }

}

contract DFKImplement is DFK {

    using SafeMath for uint256;
    using SafeERC20 for StandardToken;

    int public status; 

    struct StakingLog{
        uint256   staking_time;
        uint256   profit_time;
        uint256   staking_value;
        uint256   unstaking_value; 
    }
    mapping(address => StakingLog) public stakings;

    uint256  public cleanup_time;

    uint256  public profit_period;

    uint256  public period_bonus; 

    mapping(address => uint256) public balanceProfit;
    mapping(address => uint256) public balanceStaking;

    StandardToken    public     dfkToken;

    uint256 public  _totalMiners;
    uint256 public  _totalStaking; 
    uint256 public  totalProfit;

    uint256 public  minePoolBalance; 

    modifier onStaking {
        require(status == 1,"please start minner");
        _;
    }
    event ProfitLog(
        address indexed from,
        uint256 profit_time, 
        uint256 staking_value,
        uint256 unstaking_value,
        uint256 profit_times, 
        uint256 profit
    );

    constructor(address _dfkToken,int decimals,address  [] memory _mans) public ManagerUpgradeable(_mans){
        status = 0;
        cleanup_time = now;
        profit_period = 24*3600; 
        period_bonus = 100000*(10 ** uint256(decimals));
        cleanup_time = now;
        dfkToken = StandardToken(_dfkToken);
    }

     
    function addMinePool(uint256 stakevalue) public onStaking payable returns (uint256){
        require(stakevalue>0);

        // user must call prove first.
        dfkToken.safeTransferFrom(msg.sender,address(this),stakevalue);

        minePoolBalance = minePoolBalance.add(stakevalue);

        return minePoolBalance;
    }


      
    function stakingDeposit(uint256 stakevalue) public onStaking payable returns (bool){
        require(stakevalue>0,"stakevalue is gt zero");

        // user must call prove first.
        dfkToken.transferFrom(msg.sender,address(this),stakevalue);

        _totalStaking = _totalStaking.add(stakevalue);
         
        return addMinerStaking(msg.sender,stakevalue);
    }


    function addMinerStaking(address miner,uint256 stakevalue) internal  returns (bool){
        balanceStaking[miner] = balanceStaking[miner].add(stakevalue);
        
        StakingLog memory slog=stakings[miner];

        if(slog.profit_time < cleanup_time){ 
            stakings[miner] = StakingLog({
                staking_time:now,
                profit_time:now,
                staking_value:0,
                unstaking_value:stakevalue
            });
            _totalMiners = _totalMiners.add(1);
        }else if(now.sub(slog.profit_time) >= profit_period){ 
            uint256   profit_times = now.sub(slog.profit_time).div(profit_period); 
            
            stakings[miner] = StakingLog({
                staking_time:now,
                profit_time:now,
                staking_value:slog.staking_value.add(slog.unstaking_value),
                unstaking_value:stakevalue
            });
            
            
            uint256   profit =  period_bonus.mul(stakings[miner].staking_value).mul(profit_times).div(_totalStaking);
            emit ProfitLog(miner,stakings[miner].profit_time,stakings[miner].staking_value,stakings[miner].unstaking_value,profit_times,profit);
            require(minePoolBalance>=profit,"minePoolBalance lt profit");
            minePoolBalance = minePoolBalance.sub(profit);

             
            balanceProfit[miner]=balanceProfit[miner].add(profit);
            totalProfit = totalProfit.add(profit);

        }else { 
            stakings[miner] = StakingLog({
                staking_time:now,
                profit_time:slog.profit_time,
                staking_value:slog.staking_value,
                unstaking_value:slog.unstaking_value.add(stakevalue)
            });
        }
        return true;
    }


     
    function profit2Staking(uint256 value)public onStaking returns (bool success){
        
        require(balanceProfit[msg.sender]>=value);
        balanceProfit[msg.sender] = balanceProfit[msg.sender].sub(value);
        return addMinerStaking(msg.sender,value);

    }

     
    function withdrawProfit(address to)public  returns (bool success){
        
        require(to != address(0));

        addMinerStaking(msg.sender,0);

        uint256 profit = balanceProfit[msg.sender];
        balanceProfit[msg.sender] = 0;

        require(dfkToken.transfer(to,profit));

        return true;

    }

     
    function withdrawStaking(address to,uint256 value)public  returns (bool success){
        require(value>0);
        require(to != address(0));
        require(balanceStaking[msg.sender]>=value);
        require(_totalStaking>=value);
        
        _totalStaking=_totalStaking.sub(value);
        
        balanceStaking[msg.sender] = balanceStaking[msg.sender].sub(value);
        StakingLog memory slog=stakings[msg.sender];
        
         
        stakings[msg.sender] = StakingLog({
            staking_time:now,
            profit_time:slog.profit_time,
            staking_value:0,
            unstaking_value:balanceStaking[msg.sender]
        });
        
        require(dfkToken.transfer(to,value));
        
        return true;
    }

      
    function withdrawAll(address to)public  returns (bool success){
        require(to != address(0));
        
        addMinerStaking(msg.sender,0);
        
        _totalStaking=_totalStaking.sub(balanceStaking[msg.sender]);
        
        uint256 total=balanceStaking[msg.sender].add(balanceProfit[msg.sender]);

        balanceProfit[msg.sender]=0;
        balanceStaking[msg.sender] = 0;
         
        stakings[msg.sender] = StakingLog({
            staking_time:0,
            profit_time:0,
            staking_value:0,
            unstaking_value:0
        });
        // _totalMiners=_totalMiners.sub(1);
        require(dfkToken.transfer(to,total));
        
        return true;
    }
    
    
    function totalMiners() public view returns (uint256){
        return _totalMiners;
    }

     
    function totalStaking() public view returns (uint256){
        return _totalStaking;

    }
     
    function poolBalance() public view returns (uint256){
        return minePoolBalance;
    }

     
    function minedBalance() public view returns (uint256){
        return totalProfit;
    }

     
    function stakingBalance(address miner) public view returns (uint256){
        return balanceStaking[miner];
    }


     
    function profitBalance(address miner) public view returns (uint256){
        return balanceProfit[miner];
    }

     
    function pauseStaking()public onlyManager  returns (bool ){
        status = 0;
    }
    
     
    function resumeStaking()public onlyManager returns (bool ){
       status = 1;
    }
}

contract BasicToken is ERC20Basic {
  using SafeMath for uint256;

  // public variables
  string public name;
  string public symbol;
  uint8 public decimals = 18;

  // internal variables
  uint256 _totalSupply;
  mapping(address => uint256) _balances;

  // events

  // public functions
  function totalSupply() public view returns (uint256) {
    return _totalSupply;
  }

  function balanceOf(address addr) public view returns (uint256 balance) {
    return _balances[addr];
  }

  function transfer(address to, uint256 value) public returns (bool) {
    require(to != address(0));
    require(value <= _balances[msg.sender]);

    _balances[msg.sender] = _balances[msg.sender].sub(value);
    _balances[to] = _balances[to].add(value);
    emit Transfer(msg.sender, to, value);
    return true;
  }

  // internal functions

}

contract StandardToken is ERC20, BasicToken {
  // public variables

  // internal variables
  mapping (address => mapping (address => uint256)) _allowances;

  // events

  // public functions
  function transferFrom(address from, address to, uint256 value) public returns (bool) {
    require(to != address(0));
    require(value <= _balances[from],"value lt from");
    require(value <= _allowances[from][msg.sender],"value lt _allowances from ");

    _balances[from] = _balances[from].sub(value);
    _balances[to] = _balances[to].add(value);
    _allowances[from][msg.sender] = _allowances[from][msg.sender].sub(value);
    emit Transfer(from, to, value);
    return true;
  }

  function approve(address agent, uint256 value) public returns (bool) {
    _allowances[msg.sender][agent] = value;
    emit Approval(msg.sender, agent, value);
    return true;
  }

  function allowance(address owner, address agent) public view returns (uint256) {
    return _allowances[owner][agent];
  }

  function increaseApproval(address agent, uint value) public returns (bool) {
    _allowances[msg.sender][agent] = _allowances[msg.sender][agent].add(value);
    emit Approval(msg.sender, agent, _allowances[msg.sender][agent]);
    return true;
  }

  function decreaseApproval(address agent, uint value) public returns (bool) {
    uint allowanceValue = _allowances[msg.sender][agent];
    if (value > allowanceValue) {
      _allowances[msg.sender][agent] = 0;
    } else {
      _allowances[msg.sender][agent] = allowanceValue.sub(value);
    }
    emit Approval(msg.sender, agent, _allowances[msg.sender][agent]);
    return true;
  }
  // internal functions
}

contract DFKToken is StandardToken {
  // public variables
  string public name = "Defiking";
  string public symbol = "DFK";
  uint8 public decimals = 18;

  // internal variables
 
  // events

  // public functions
  constructor() public {
    //init _totalSupply
    _totalSupply = 1000000000 * (10 ** uint256(decimals));

    _balances[msg.sender] = _totalSupply;
    emit Transfer(address(0x0), msg.sender, _totalSupply);
  }

  // internal functions
}