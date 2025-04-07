/**
 *Submitted for verification at Etherscan.io on 2020-07-25
*/

pragma solidity ^0.5.13;





contract BDAONetwork {
    
    using SafeMath for uint256;
	uint256 constant private FLOAT_SCALAR = 2**64;
	uint256 constant private INITIAL_SUPPLY = 30000000e18;
	uint256 constant private XFER_FEE = 5; // 5% per tx
	uint256 constant private POOL_FEE = 4; // 4% to pool
	uint256 constant private DEV_FEE = 1;  // 1% to dev
	uint256 constant private SHARE_DIVIDENDS = 25;  // 25% every collect
	uint256 constant private MIN_STAKE_AMOUNT = 1e21; // 1,000 Tokens Needed

	string constant public name = "BDAO Network";
	string constant public symbol = "BDAO";
	uint8 constant public decimals = 18;

	struct User {
		
		uint256 balance;
		uint256 staked;
		mapping(address => uint256) allowance;
		uint collectTime;
		uint unstakeTime;
		int256 scaledPayout;
	}

	struct Info {
		uint256 totalSupply;
		uint256 totalStaked;
		uint256 totalStake;
		mapping(address => User) users;
		uint256 scaledPayoutPerToken;
		address admin;
	}
	Info private info;


	event Transfer(address indexed from, address indexed to, uint256 tokens);
	event Approval(address indexed owner, address indexed spender, uint256 tokens);
	
	event Stake(address indexed owner, uint256 tokens);
	event Unstake(address indexed owner, uint256 tokens);
	event Collect(address indexed owner, uint256 tokens);
	event Tax(uint256 tokens);


	constructor() public {
		info.admin = msg.sender;
		info.totalSupply = INITIAL_SUPPLY;
		info.users[msg.sender].balance = INITIAL_SUPPLY;
		emit Transfer(address(0x0), msg.sender, INITIAL_SUPPLY);
		
	}

	function stake(uint256 _tokens) external {
		_stake(_tokens);
	}

	function unstake(uint256 _tokens) external {
		_unstake(_tokens);
	}

	function collect() external returns (uint256) {
		uint256 _dividends = dividendsOf(msg.sender);
		require(_dividends >= 0);
		require(info.users[msg.sender].collectTime < now);
		info.users[msg.sender].scaledPayout += int256(_dividends.mul(FLOAT_SCALAR).mul(SHARE_DIVIDENDS).div(100));
		info.users[msg.sender].balance += _dividends.mul(SHARE_DIVIDENDS).div(100);
		info.users[msg.sender].collectTime = now + 86400;
		emit Transfer(address(this), msg.sender, _dividends);
		emit Collect(msg.sender, _dividends);
		return _dividends;
	}

	function distribute(uint256 _tokens) external {
		require(info.totalStaked > 0);
		require(balanceOf(msg.sender) >= _tokens);
		info.users[msg.sender].balance -= _tokens;
		info.scaledPayoutPerToken += _tokens.mul(FLOAT_SCALAR).div(info.totalStaked);
		emit Transfer(msg.sender, address(this), _tokens);
	}

	function transfer(address _to, uint256 _tokens) external returns (bool) {
		_transfer(msg.sender, _to, _tokens);
		return true;
	}

	function approve(address _spender, uint256 _tokens) external returns (bool) {
		info.users[msg.sender].allowance[_spender] = _tokens;
		emit Approval(msg.sender, _spender, _tokens);
		return true;
	}

	function transferFrom(address _from, address _to, uint256 _tokens) external returns (bool) {
		require(info.users[_from].allowance[msg.sender] >= _tokens);
		info.users[_from].allowance[msg.sender] -= _tokens;
		_transfer(_from, _to, _tokens);
		return true;
	}

	function transferAndCall(address _to, uint256 _tokens, bytes calldata _data) external returns (bool) {
		uint256 _transferred = _transfer(msg.sender, _to, _tokens);
		uint32 _size;
		assembly {
			_size := extcodesize(_to)
		}
		if (_size > 0) {
			require(Callable(_to).tokenCallback(msg.sender, _transferred, _data));
		}
		return true;
	}

	function bulkTransfer(address[] calldata _receivers, uint256[] calldata _amounts) external {
		require(_receivers.length == _amounts.length);
		for (uint256 i = 0; i < _receivers.length; i++) {
			_transfer(msg.sender, _receivers[i], _amounts[i]);
		}
	}


	function totalSupply() public view returns (uint256) {
		return info.totalSupply;
	}

	function totalStaked() public view returns (uint256) {
		return info.totalStaked;
	}

	function balanceOf(address _user) public view returns (uint256) {
		return info.users[_user].balance - stakedOf(_user);
	}

	function stakedOf(address _user) public view returns (uint256) {
		return info.users[_user].staked;
	}
	
	function collectTimeOf(address _user) public view returns (uint256) {
		return info.users[_user].collectTime;
	}

	function dividendsOf(address _user) public view returns (uint256) {
		return uint256(int256(info.scaledPayoutPerToken * info.users[_user].staked) - info.users[_user].scaledPayout) / FLOAT_SCALAR;
	}

	function allowance(address _user, address _spender) public view returns (uint256) {
		return info.users[_user].allowance[_spender];
	}

	function allInfoFor(address _user) public view returns (uint256 totalTokenSupply, uint256 totalTokensStaked, uint256 userBalance, uint256 userStaked, uint256 userDividends, uint usercollectTime) {
		return (totalSupply(), totalStaked(), balanceOf(_user), stakedOf(_user), dividendsOf(_user), collectTimeOf(_user));
	}


	function _transfer(address _from, address _to, uint256 _tokens) internal returns (uint256) {
		require(balanceOf(_from) >= _tokens);
		info.users[_from].balance -= _tokens;
		
		uint256 _taxAmount = _tokens.mul(XFER_FEE).div(100);
		uint256 _poolAmount = _tokens.mul(POOL_FEE).div(100);
		uint256 _devAmount = _tokens.mul(DEV_FEE).div(100);
		
		uint256 _transferred = _tokens - _taxAmount;
		
        if (info.totalStaked > 0) {
            info.users[_to].balance += _transferred;
            info.users[info.admin].balance += _devAmount;
            emit Transfer(_from, _to, _transferred);
            info.scaledPayoutPerToken += _poolAmount.mul(FLOAT_SCALAR).div(info.totalStaked);
            emit Transfer(_from, address(this), _poolAmount);
            emit Transfer(_from, info.admin, _devAmount);
            emit Tax(_taxAmount);
            return _transferred;
        } else {
            info.users[_to].balance += _tokens;
            emit Transfer(_from, _to, _tokens);
            return _tokens;
        }
    }

	function _stake(uint256 _amount) internal {
		require(balanceOf(msg.sender) >= _amount);
		require(stakedOf(msg.sender) + _amount >= MIN_STAKE_AMOUNT);
		info.users[msg.sender].unstakeTime = now + 86400;
		info.totalStaked += _amount;
		info.users[msg.sender].staked += _amount;
		info.users[msg.sender].scaledPayout += int256(_amount.mul(info.scaledPayoutPerToken));
		emit Transfer(msg.sender, address(this), _amount);
		emit Stake(msg.sender, _amount);
	}

	function _unstake(uint256 _amount) internal {
	    require(info.users[msg.sender].unstakeTime < now);
		require(stakedOf(msg.sender) >= _amount);
		uint256 _taxAmount = _amount.mul(XFER_FEE).div(100);
		info.scaledPayoutPerToken += _taxAmount.mul(FLOAT_SCALAR).div(info.totalStaked);
		info.totalStaked -= _amount;
		info.users[msg.sender].balance -= _taxAmount;
		info.users[msg.sender].staked -= _amount;
		info.users[msg.sender].scaledPayout -= int256(_amount.mul(info.scaledPayoutPerToken));
		emit Transfer(address(this), msg.sender, _amount.sub(_taxAmount));
		emit Unstake(msg.sender, _amount);
	}
}