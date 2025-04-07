pragma solidity 0.6.4;










 
 
contract OPERATORS{
    
    using SafeMath for uint256;
    
    //======================================EVENTS=========================================//
    event POPCORNEvent(address indexed executioner, address indexed pool, uint amount);
    event DITCHEvent(address indexed executioner, address indexed pool, uint amount);
    event PooppingRewardEvent(address indexed executioner, address indexed pool, uint amount);

   
     //======================================OPERATORS VARS=========================================//
    address public popcornToken;
    address public power;
    address public fireball;
    
    bool public _machineReady;
    
    uint256 constant private FLOAT_SCALAR = 2**64;
    uint256 public MINIMUM_POP = 10000000000000000000;
	uint256 private MIN_POP_DUR = 10 days;
	uint256 public MIN_FIRE_TO_POP = 1000000000000000000;
	uint256 private  DITCH_FEE = 30; 
	uint public infocheck;
	uint _burnedAmount;
	uint actualValue;
    
    struct User {
        
		uint256 popslot;
		int256 scaledPayout;  
		uint256 poptime;
	}

	struct Info {
	    
		uint256 totalPopping;
		mapping(address => User) users;
		uint256 scaledPayoutPerToken; //pool balance 
		address admin;
	}
	
	Info private info;
	mapping(address => bool) whitelisted;
	
	constructor() public {
       
	    info.admin = msg.sender;
		_machineReady = true;
		
	}
	
//======================================ADMINSTRATION=========================================//

	modifier onlyCreator() {
        require(msg.sender == info.admin, "Ownable: caller is not the administrator");
        _;
    }
    
    modifier onlypopcornToken() {
        require(msg.sender == popcornToken, "Authorization: only token contract can call");
        _;
    }
    
    
    
	 function machinery(address _popcorn, address _power, address _fire) public onlyCreator returns (bool success) {
        popcornToken = _popcorn;
        power = _power;
        fireball = _fire;
        return true;
    }
    
  
    
    function _whitelist(address _address) onlyCreator public {
		
		whitelisted[_address] = true;
		
	}
	
	
	function _minPopAmount(uint256 _number) onlyCreator public {
		
		MINIMUM_POP = _number*1000000000000000000;
		
	}
	
	function _minFIRE_TO_POP(uint256 _number) onlyCreator public {
		
		MIN_FIRE_TO_POP = _number*1000000000000000000;
		
	}
    
    function machineReady(bool _status) public onlyCreator {
	_machineReady = _status;
    }
    
    function ditchFee(uint _rate) public onlyCreator returns (bool success) {
        DITCH_FEE = _rate;
        return true;
    }
    
//======================================USER WRITE=========================================//

	function popCorns(uint256 _tokens) external {
		_popcorns(_tokens);
	}
    
    function DitchCorns(uint256 _tokens) external {
		_ditchcorns(_tokens);
	}
	
//======================================USER READ=========================================//

	function totalPopping() public view returns (uint256) {
		return info.totalPopping;
	}
	
    function popslotOf(address _user) public view returns (uint256) {
		return info.users[_user].popslot;
	}

	function cornsOf(address _user) public view returns (uint256) {
	    
	   return uint256(int256(info.scaledPayoutPerToken * info.users[_user].popslot) - info.users[_user].scaledPayout) / FLOAT_SCALAR;   
	    
	}
	

	function userData(address _user) public view 
	returns (uint256 totalCornsPopping, uint256 userpopslot, 
	uint256 usercorns, uint256 userpoptime, int256 scaledPayout) {
	    
		return (totalPopping(), popslotOf(_user), cornsOf(_user), info.users[_user].poptime, info.users[_user].scaledPayout);
	
	    
	}
	

//======================================ACTION CALLS=========================================//	
	
	function _popcorns(uint256 _amount) internal {
	    
	    require(_machineReady, "Staking not yet initialized");
	    require(FIRE(fireball).balanceOf(msg.sender) > MIN_FIRE_TO_POP, "You do not have sufficient fire to pop this corn");
	    
		require(IERC20(popcornToken).balanceOf(msg.sender) >= _amount, "Insufficient corn balance");
		require(popslotOf(msg.sender) + _amount >= MINIMUM_POP, "Your amount is lower than the minimum amount allowed to stake");
		require(IERC20(popcornToken).allowance(msg.sender, address(this)) >= _amount, "Not enough allowance given to contract yet to spend by user");
		
		info.users[msg.sender].poptime = now;
		info.totalPopping += _amount;
		info.users[msg.sender].popslot += _amount;
		
		info.users[msg.sender].scaledPayout += int256(_amount * info.scaledPayoutPerToken); 
		IERC20(popcornToken).transferFrom(msg.sender, address(this), _amount);      // Transfer liquidity tokens from the sender to this contract
		
        emit POPCORNEvent(msg.sender, address(this), _amount);
	}
	
	    
	
	function _ditchcorns(uint256 _amount) internal {
	    
		require(popslotOf(msg.sender) >= _amount, "You currently do not have up to that amount popping");
		
		info.totalPopping -= _amount;
		info.users[msg.sender].popslot -= _amount;
		info.users[msg.sender].scaledPayout -= int256(_amount * info.scaledPayoutPerToken);
		
		
		
    		if(whitelisted[msg.sender] == true){
    		   
    		   require(IERC20(popcornToken).transfer(msg.sender, _amount), "Transaction failed");
                        emit DITCHEvent(address(this), msg.sender, _amount);
    		    
    		    
    	 	}else{
    		        uint256 interval =  now - info.users[msg.sender].poptime;
    		        if(interval < MIN_POP_DUR){
            		    
            		_burnedAmount = mulDiv(_amount, DITCH_FEE, 100);
            		actualValue = _amount.sub(_burnedAmount);
            		
            		require(IERC20(popcornToken).transfer(msg.sender, actualValue), "Transaction failed");
                    emit DITCHEvent(address(this), msg.sender, actualValue);
            		
            		_burnedAmount /=2;
            		require(IERC20(popcornToken).transfer(address(this), _burnedAmount), "Transaction failed");
            		scaledOperatorSelf(_burnedAmount);
            		
            		
            		
             	    require(IERC20(popcornToken).transfer(power, _burnedAmount), "Transaction failed");
             		POWER(power).scaledPower(_burnedAmount);
             		
            		
            		
            		 
            		}else{
            		    
            		require(IERC20(popcornToken).transfer(msg.sender, _amount), "Transaction failed");
                    emit DITCHEvent(address(this), msg.sender, _amount);
            		
            		}
    		    
    		    
    		}
            		
		
	}
		
		
	function Takecorns() external returns (uint256) {
		    
		uint256 _dividends = cornsOf(msg.sender);
		require(_dividends >= 0, "you do not have any corn yet");
		info.users[msg.sender].scaledPayout += int256(_dividends * FLOAT_SCALAR);
		
		require(IERC20(popcornToken).transfer(msg.sender, _dividends), "Transaction Failed");    // Transfer dividends to msg.sender
		emit PooppingRewardEvent(msg.sender, address(this), _dividends);
		
		return _dividends;
	    
		    
	}
		
		
 
    function scaledOperators(uint _amount) external onlypopcornToken returns(bool){
            
    		info.scaledPayoutPerToken += _amount * FLOAT_SCALAR / info.totalPopping;
    		infocheck = info.scaledPayoutPerToken;
    		return true;
            
    }
    
    function scaledOperatorSelf(uint _amount) private  returns(bool){
            
    		info.scaledPayoutPerToken += _amount * FLOAT_SCALAR / info.totalPopping;
    		infocheck = info.scaledPayoutPerToken;
    		return true;
            
    }
        
    function mulDiv (uint x, uint y, uint z) public pure returns (uint) {
              (uint l, uint h) = fullMul (x, y);
              assert (h < z);
              uint mm = mulmod (x, y, z);
              if (mm > l) h -= 1;
              l -= mm;
              uint pow2 = z & -z;
              z /= pow2;
              l /= pow2;
              l += h * ((-pow2) / pow2 + 1);
              uint r = 1;
              r *= 2 - z * r;
              r *= 2 - z * r;
              r *= 2 - z * r;
              r *= 2 - z * r;
              r *= 2 - z * r;
              r *= 2 - z * r;
              r *= 2 - z * r;
              r *= 2 - z * r;
              return l * r;
    }
        
    function fullMul (uint x, uint y) private pure returns (uint l, uint h) {
              uint mm = mulmod (x, y, uint (-1));
              l = x * y;
              h = mm - l;
              if (mm < l) h -= 1;
    }
 
    
}