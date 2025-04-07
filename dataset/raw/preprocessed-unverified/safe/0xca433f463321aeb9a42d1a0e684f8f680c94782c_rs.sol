/**
 *Submitted for verification at Etherscan.io on 2021-02-19
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.6.12;


contract SwapAdmin {
    address public admin;
    address public candidate;

    constructor(address _admin) public {
        require(_admin != address(0), "admin address cannot be 0");
        admin = _admin;
        emit AdminChanged(address(0), _admin);
    }

    function setCandidate(address _candidate) external onlyAdmin {
        address old = candidate;
        candidate = _candidate;
        emit candidateChanged( old, candidate);
    }

    function becomeAdmin( ) external {
        require( msg.sender == candidate, "Only candidate can become admin");
        address old = admin;
        admin = candidate;
        emit AdminChanged( old, admin ); 
    }

    modifier onlyAdmin {
        require( (msg.sender == admin), "Only the contract admin can perform this action");
        _;
    }

    event candidateChanged(address oldCandidate, address newCandidate );
    event AdminChanged(address oldAdmin, address newAdmin);
}





contract SwapTokenLocker is SwapAdmin {
    using SafeMath for uint;
    struct LockInfo {
        uint128 amount;
        uint128 claimedAmount;
        uint64 lockTimestamp; 
        uint64 lastUpdated;
        uint32 lockHours;
    }
    address immutable token;
    mapping (address => LockInfo) public lockData;
    constructor(address _admin, address _token) public SwapAdmin(_admin) {
        token = _token;
    }
    function getToken() external view returns(address) {
        return token;
    }
    function emergencyWithdraw(address _tokenAddress) external onlyAdmin {
        require(_tokenAddress != address(0), "Token address is invalid");
        IERC20(_tokenAddress).transfer(msg.sender, IERC20(_tokenAddress).balanceOf(address(this)));
    }
	function getLockData(address _user) external view returns(uint128, uint128, uint64, uint64, uint32) {
        require(_user != address(0), "User address is invalid");
        LockInfo storage _lockInfo = lockData[_user];
		return (
		    _lockInfo.amount, 
		    _lockInfo.claimedAmount, 
		    _lockInfo.lockTimestamp, 
		    _lockInfo.lastUpdated, 
		    _lockInfo.lockHours);
	}
    function sendLockTokenMany(
        address[] calldata _users, 
        uint128[] calldata _amounts, 
        uint32[] calldata _lockHours,
        uint256 _sendAmount
    ) external onlyAdmin {
        require(_users.length == _amounts.length, "array length not eq");
        require(_users.length == _lockHours.length, "array length not eq");
        require(_sendAmount > 0 , "Amount is invalid");
        IERC20(token).transferFrom(msg.sender, address(this), _sendAmount);
        for (uint256 j = 0; j < _users.length; j++) {
            sendLockToken(_users[j], _amounts[j], uint64(block.timestamp), _lockHours[j]);
        }
    }
    function sendLockToken(
        address _user, 
        uint128 _amount, 
        uint64 _lockTimestamp, 
        uint32 _lockHours
    ) internal {
        require(_amount > 0, "amount can not zero");
        require(_lockHours > 0, "lock hours need more than zero");
        require(_lockTimestamp > 0, "lock timestamp need more than zero");
        require(lockData[_user].amount == 0, "this address has already locked");
        LockInfo memory lockinfo = LockInfo({
            amount: _amount,
            lockTimestamp: _lockTimestamp,
            lockHours: _lockHours,
            lastUpdated: uint64(block.timestamp),
            claimedAmount: 0
        });
        lockData[_user] = lockinfo;
    }
    function claimToken(uint128 _amount) external returns (uint256) {
        require(_amount > 0, "Invalid parameter amount");
        address _user = msg.sender;
        LockInfo storage _lockInfo = lockData[_user];
        require(_lockInfo.lockTimestamp <= block.timestamp, "Vesting time is not started");
        require(_lockInfo.amount > 0, "No lock token to claim");
        uint256 passhours = block.timestamp.sub(_lockInfo.lockTimestamp).div(1 hours);
        require(passhours > 0, "need wait for one hour at least");
        require((block.timestamp - _lockInfo.lastUpdated) > 1 hours, "You have to wait at least an hour to claim");
        uint256 available = 0;
        if (passhours >= _lockInfo.lockHours) {
            available = _lockInfo.amount;
        } else {
            available = uint256(_lockInfo.amount).div(_lockInfo.lockHours).mul(passhours);
        }
        available = available.sub(_lockInfo.claimedAmount);
        require(available > 0, "not available claim");
        uint256 claim = _amount;
        if (_amount > available) { // claim as much as possible
            claim = available;
        }
        _lockInfo.claimedAmount = uint128(uint256(_lockInfo.claimedAmount).add(claim));
        IERC20(token).transfer(_user, claim);
        _lockInfo.lastUpdated = uint64(block.timestamp);
        return claim;
    }
}

contract SwapTokenLockerFactory {
    event SwapTokenLockerCreated(address admin, address locker);
    mapping(address => address[]) private deployedContracts;
    address[] private allLockers;

    function getLastDeployed(address owner) external view returns(address locker) {
        uint256 length = deployedContracts[owner].length;
        return deployedContracts[owner][length - 1];
    }

    function getAllContracts() external view returns (address[] memory) {
        return allLockers;
    }

    function getDeployed(address owner) external view returns(address[] memory) {
        return deployedContracts[owner];
    }

    function createTokenLocker(address token) external returns (address locker) {
        SwapTokenLocker lockerContract = new SwapTokenLocker(msg.sender, token);
        locker = address(lockerContract);
        deployedContracts[msg.sender].push(locker);
        allLockers.push(locker);
        emit SwapTokenLockerCreated(msg.sender, locker);
    }
}