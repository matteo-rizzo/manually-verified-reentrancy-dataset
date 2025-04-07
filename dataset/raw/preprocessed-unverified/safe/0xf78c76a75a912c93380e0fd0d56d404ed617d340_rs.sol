pragma solidity 0.6.4;










 
 
contract POWERGENERTORS{
    
    using SafeMath for uint256;
    
    //======================================EVENTS=========================================//
    event POPCORNEvent(address indexed executioner, address indexed pool, uint amount);
    event DITCHEvent(address indexed executioner, address indexed pool, uint amount);
    event PooppingRewardEvent(address indexed executioner, address indexed pool, uint amount);

   
     //======================================INTERRACTING MACHINE SECTIONS=========================================//
    address public popcornToken;
    address public fireball;
    address public operator;
    address public powerToken;
    
    bool public _machineReady;
    
    uint256 constant private FLOAT_SCALAR = 2**64;
    uint256 public MINIMUM_POP = 10000000000000000000;
	uint256 private MIN_POP_DUR = 10 days;
	uint256 public MIN_FIRE_TO_POP = 1000000000000000000;
	
	uint public infocheck;
	
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
	//mapping(address => bool) whitelisted;
	
	constructor() public {
       
	    info.admin = msg.sender;
		_machineReady = true;
		
	}
	
//======================================ADMINSTRATION=========================================//

	modifier onlyCreator() {
        require(msg.sender == info.admin, "Ownable: caller is not the administrator");
        _;
    }
    
    modifier onlypopcornTokenoroperators() {
        require(msg.sender == popcornToken || msg.sender == operator, "Authorization: only authorized contract can call");
        _;
    }
    
    
 
    
	 function machinery(address _popcornToken, address _powertoken, address _fire, address _operator) public onlyCreator returns (bool success) {
	    
	    popcornToken = _popcornToken;
        powerToken = _powertoken; //liquidity token
        fireball = _fire;
        operator = _operator;
        
        return true;
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
    
  

	function popCorns(uint256 _tokens) external {
		_popcorns(_tokens);
	}
    
    function DitchCorns(uint256 _tokens) external {
		_ditchcorns(_tokens);
	}
	


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
	    
		require(IERC20(powerToken).balanceOf(msg.sender) >= _amount, "Insufficient power token balance");
		require(popslotOf(msg.sender) + _amount >= MINIMUM_POP, "Your amount is lower than the minimum amount allowed to pop");
		require(IERC20(powerToken).allowance(msg.sender, address(this)) >= _amount, "Not enough allowance given to contract yet to spend by user");
		
		info.users[msg.sender].poptime = now;
		info.totalPopping += _amount;
		info.users[msg.sender].popslot += _amount;
		
		info.users[msg.sender].scaledPayout += int256(_amount * info.scaledPayoutPerToken); 
		IERC20(powerToken).transferFrom(msg.sender, address(this), _amount);      // Transfer liquidity tokens from the sender to this contract
		
        emit POPCORNEvent(msg.sender, address(this), _amount);
	}
	
	    
	
	function _ditchcorns(uint256 _amount) internal {
	    
		require(popslotOf(msg.sender) >= _amount, "You currently do not have up to that amount popping");
		
		info.totalPopping -= _amount;
		info.users[msg.sender].popslot -= _amount;
		info.users[msg.sender].scaledPayout -= int256(_amount * info.scaledPayoutPerToken);
		
		require(IERC20(powerToken).transfer(msg.sender, _amount), "Transaction failed");
        emit DITCHEvent(address(this), msg.sender, _amount);
		
	}
		
		
	function Takecorns() external returns (uint256) {
		    
		uint256 _dividends = cornsOf(msg.sender);
		require(_dividends >= 0, "you do not have any corn yet");
		info.users[msg.sender].scaledPayout += int256(_dividends * FLOAT_SCALAR);
		
		require(IERC20(popcornToken).transfer(msg.sender, _dividends), "Transaction Failed");    // Transfer dividends to msg.sender
		emit PooppingRewardEvent(msg.sender, address(this), _dividends);
		
		return _dividends;
	    
		    
	}
		
		
 
    function scaledPower(uint _amount) external onlypopcornTokenoroperators returns(bool){
            
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