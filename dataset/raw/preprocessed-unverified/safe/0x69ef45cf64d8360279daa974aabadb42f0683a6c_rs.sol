/**
 *Submitted for verification at Etherscan.io on 2021-07-24
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.6;

/// @dev Common mathematical functions used in both PRBMathSD59x18 and PRBMathUD60x18. Note that this shared library
/// does not always assume the signed 59.18-decimal fixed-point or the unsigned 60.18-decimal fixed-point
// representation. When it does not, it is annonated in the function's NatSpec documentation.


/// @title PRBMathUD60x18
/// @author Paul Razvan Berg
/// @notice Smart contract library for advanced fixed-point math. It works with uint256 numbers considered to have 18
/// trailing decimals. We call this number representation unsigned 60.18-decimal fixed-point, since there can be up to 60
/// digits in the integer part and up to 18 decimals in the fractional part. The numbers are bound by the minimum and the
/// maximum values permitted by the Solidity type uint256.





contract LMAO {

	uint256 constant private UINT_MAX = type(uint256).max;
	uint256 constant private TOTAL_SUPPLY = 1e25; // 10M LMAO
	uint256 constant private STAKING_REWARDS = 35e23; // 3.5M LMAO

	string constant public name = "LMAO Token";
	string constant public symbol = "LMAO";
	uint8 constant public decimals = 18;

	struct User {
		uint256 balance;
		mapping(address => uint256) allowance;
	}

	struct Info {
		mapping(address => User) users;
		address staking;
	}
	Info private info;


	event Transfer(address indexed from, address indexed to, uint256 tokens);
	event Approval(address indexed owner, address indexed spender, uint256 tokens);


	constructor(address _owner) {
		uint256 _ownerTokens = TOTAL_SUPPLY - STAKING_REWARDS;
		info.users[_owner].balance = _ownerTokens;
		emit Transfer(address(0x0), _owner, _ownerTokens);
		info.staking = msg.sender;
		info.users[info.staking].balance = STAKING_REWARDS;
		emit Transfer(address(0x0), info.staking, STAKING_REWARDS);
	}

	function transfer(address _to, uint256 _tokens) external returns (bool) {
		return _transfer(msg.sender, _to, _tokens);
	}

	function approve(address _spender, uint256 _tokens) external returns (bool) {
		info.users[msg.sender].allowance[_spender] = _tokens;
		emit Approval(msg.sender, _spender, _tokens);
		return true;
	}

	function transferFrom(address _from, address _to, uint256 _tokens) external returns (bool) {
		uint256 _allowance = allowance(_from, msg.sender);
		require(_allowance >= _tokens);
		if (_allowance != UINT_MAX) {
			info.users[_from].allowance[msg.sender] -= _tokens;
		}
		return _transfer(_from, _to, _tokens);
	}

	function transferAndCall(address _to, uint256 _tokens, bytes calldata _data) external returns (bool) {
		_transfer(msg.sender, _to, _tokens);
		uint32 _size;
		assembly {
			_size := extcodesize(_to)
		}
		if (_size > 0) {
			require(Callable(_to).tokenCallback(msg.sender, _tokens, _data));
		}
		return true;
	}
	
	
	function stakingAddress() external view returns (address) {
		return info.staking;
	}
	
	function totalSupply() public pure returns (uint256) {
		return TOTAL_SUPPLY;
	}

	function balanceOf(address _user) public view returns (uint256) {
		return info.users[_user].balance;
	}

	function allowance(address _user, address _spender) public view returns (uint256) {
		return info.users[_user].allowance[_spender];
	}

	function allInfoFor(address _user) external view returns (uint256 totalTokens, uint256 userTOKENS, uint256 userBalance) {
		totalTokens = totalSupply();
		userTOKENS = _user.balance;
		userBalance = balanceOf(_user);
	}


	function _transfer(address _from, address _to, uint256 _tokens) internal returns (bool) {
		require(balanceOf(_from) >= _tokens);
		info.users[_from].balance -= _tokens;
		info.users[_to].balance += _tokens;
		emit Transfer(_from, _to, _tokens);
		return true;
	}
}


contract StakingRewards {

	using PRBMathUD60x18 for uint256;

	uint256 constant private FLOAT_SCALAR = 2**64;
	uint256 constant private PERCENT_FEE = 5;
	uint256 constant private X_TICK = 45 days;

	struct User {
		uint256 deposited;
		int256 scaledPayout;
	}

	struct Info {
		uint256 totalRewards;
		uint256 startTime;
		uint256 lastUpdated;
		uint256 pendingFee;
		uint256 scaledRewardsPerToken;
		uint256 totalDeposited;
		mapping(address => User) users;
		LMAO lmao;
	}
	Info private info;


	event Deposit(address indexed user, uint256 amount, uint256 fee);
	event Withdraw(address indexed user, uint256 amount, uint256 fee);
	event Claim(address indexed user, uint256 amount);
	event Reinvest(address indexed user, uint256 amount);
	event Reward(uint256 amount);


	constructor(uint256 _stakingRewardsStart) {
		info.startTime = block.timestamp < _stakingRewardsStart ? _stakingRewardsStart : block.timestamp;
		info.lastUpdated = info.startTime;
		info.lmao = new LMAO(msg.sender);
		info.totalRewards = info.lmao.balanceOf(address(this));
	}

	function update() public {
		uint256 _now = block.timestamp;
		if (_now > info.lastUpdated && info.totalDeposited > 0) {
			uint256 _reward = info.totalRewards.mul(_delta(_getX(info.lastUpdated), _getX(_now)));
			_disburse(_reward);
			info.lastUpdated = _now;
			if (info.pendingFee > 0) {
				_processFee(info.pendingFee);
				info.pendingFee = 0;
			}
		}
	}

	function deposit(uint256 _amount) external {
		depositFor(msg.sender, _amount);
	}

	function depositFor(address _user, uint256 _amount) public {
		require(_amount > 0);
		update();
		info.lmao.transferFrom(msg.sender, address(this), _amount);
		_deposit(_user, _amount);
	}

	function tokenCallback(address _from, uint256 _tokens, bytes calldata) external returns (bool) {
		require(msg.sender == address(info.lmao));
		require(_tokens > 0);
		_deposit(_from, _tokens);
		return true;
	}

	function disburse(uint256 _amount) public {
		require(_amount > 0);
		update();
		info.lmao.transferFrom(msg.sender, address(this), _amount);
		_disburse(_amount);
	}

	function withdrawAll() public {
		uint256 _deposited = depositedOf(msg.sender);
		if (_deposited > 0) {
			withdraw(_deposited);
		}
	}

	function withdraw(uint256 _amount) public {
		require(_amount > 0 && _amount <= depositedOf(msg.sender));
		update();
		info.totalDeposited -= _amount;
		info.users[msg.sender].deposited -= _amount;
		info.users[msg.sender].scaledPayout -= int256(_amount * info.scaledRewardsPerToken);
		uint256 _fee = _calculateFee(_amount);
		info.lmao.transfer(msg.sender, _amount - _fee);
		_processFee(_fee);
		emit Withdraw(msg.sender, _amount, _fee);
	}

	function claim() public {
		update();
		uint256 _rewards = rewardsOf(msg.sender);
		if (_rewards > 0) {
			info.users[msg.sender].scaledPayout += int256(_rewards * FLOAT_SCALAR);
			info.lmao.transfer(msg.sender, _rewards);
			emit Claim(msg.sender, _rewards);
		}
	}

	function reinvest() public {
		update();
		uint256 _rewards = rewardsOf(msg.sender);
		if (_rewards > 0) {
			info.users[msg.sender].scaledPayout += int256(_rewards * FLOAT_SCALAR);
			_deposit(msg.sender, _rewards);
			emit Reinvest(msg.sender, _rewards);
		}
	}

	
	function depositedOf(address _user) public view returns (uint256) {
		return info.users[_user].deposited;
	}
	
	function rewardsOf(address _user) public view returns (uint256) {
		return uint256(int256(info.scaledRewardsPerToken * depositedOf(_user)) - info.users[_user].scaledPayout) / FLOAT_SCALAR;
	}
	
	function currentRatePerDay() public view returns (uint256) {
		if (block.timestamp < info.startTime) {
			return 0;
		} else {
			return info.totalRewards.mul(_delta(_getX(block.timestamp), _getX(block.timestamp + 24 hours)));
		}
	}

	function totalDistributed() public view returns (uint256) {
		return info.totalRewards.mul(_sum(_getX(block.timestamp)));
	}

	function allInfoFor(address _user) external view returns (uint256 startTime, uint256 totalRewardsDistributed, uint256 rewardsRatePerDay, uint256 currentFeePercent, uint256 totalDeposited, uint256 virtualRewards, uint256 userTOKENS, uint256 userBalance, uint256 userAllowance, uint256 userDeposited, uint256 userRewards) {
		startTime = info.startTime;
		totalRewardsDistributed = totalDistributed();
		rewardsRatePerDay = currentRatePerDay();
		currentFeePercent = _calculateFee(1e20);
		totalDeposited = info.totalDeposited;
		virtualRewards = block.timestamp > info.lastUpdated ? info.totalRewards.mul(_delta(_getX(info.lastUpdated), _getX(block.timestamp))) : 0;
		userTOKENS = _user.balance;
		userBalance = info.lmao.balanceOf(_user);
		userAllowance = info.lmao.allowance(_user, address(this));
		userDeposited = depositedOf(_user);
		userRewards = rewardsOf(_user);
	}


	function _deposit(address _user, uint256 _amount) internal {
		uint256 _fee = _calculateFee(_amount);
		uint256 _deposited = _amount - _fee;
		info.totalDeposited += _deposited;
		info.users[_user].deposited += _deposited;
		info.users[_user].scaledPayout += int256(_deposited * info.scaledRewardsPerToken);
		_processFee(_fee);
		emit Deposit(_user, _amount, _fee);
	}
	
	function _processFee(uint256 _fee) internal {
		if (_fee > 0) {
			if (block.timestamp < info.startTime) {
				info.pendingFee += _fee;
			} else {
				_disburse(_fee);
			}
		}
	}

	function _disburse(uint256 _amount) internal {
		info.scaledRewardsPerToken += _amount * FLOAT_SCALAR / info.totalDeposited;
		emit Reward(_amount);
	}

	function _calculateFee(uint256 _amount) internal view returns (uint256) {
		return (_amount * PERCENT_FEE / 100).mul(1e18 - _sum(_getX(block.timestamp)));
	}
	
	function _getX(uint256 t) internal view returns (uint256) {
		uint256 _start = info.startTime;
		if (t < _start) {
			return 0;
		} else {
			return ((t - _start) * 1e18).div(X_TICK * 1e18);
		}
	}

	function _sum(uint256 x) internal pure returns (uint256) {
		uint256 _e2x = x.exp2();
		return (_e2x - 1e18).div(_e2x);
	}

	function _delta(uint256 x1, uint256 x2) internal pure returns (uint256) {
		require(x2 >= x1);
		return _sum(x2) - _sum(x1);
	}
}