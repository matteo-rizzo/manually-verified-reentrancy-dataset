// SPDX-License-Identifier: MIT
pragma solidity ^0.6.12;

abstract contract Context {
    function _msgSender() internal view virtual returns (address payable) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes memory) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}


contract Pausable is Context {
    /**
     * @dev Emitted when the pause is triggered by `account`.
     */
    event Paused(address account);

    /**
     * @dev Emitted when the pause is lifted by `account`.
     */
    event Unpaused(address account);

    bool private _paused;

    /**
     * @dev Initializes the contract in unpaused state.
     */
    constructor () internal {
        _paused = false;
    }

    /**
     * @dev Returns true if the contract is paused, and false otherwise.
     */
    function paused() public view returns (bool) {
        return _paused;
    }

    /**
     * @dev Modifier to make a function callable only when the contract is not paused.
     *
     * Requirements:
     *
     * - The contract must not be paused.
     */
    modifier whenNotPaused() {
        require(!_paused, "Pausable: paused");
        _;
    }

    /**
     * @dev Modifier to make a function callable only when the contract is paused.
     *
     * Requirements:
     *
     * - The contract must be paused.
     */
    modifier whenPaused() {
        require(_paused, "Pausable: not paused");
        _;
    }

    /**
     * @dev Triggers stopped state.
     *
     * Requirements:
     *
     * - The contract must not be paused.
     */
    function _pause() internal virtual whenNotPaused {
        _paused = true;
        emit Paused(_msgSender());
    }

    /**
     * @dev Returns to normal state.
     *
     * Requirements:
     *
     * - The contract must be paused.
     */
    function _unpause() internal virtual whenPaused {
        _paused = false;
        emit Unpaused(_msgSender());
    }
}











contract LnAdmin {
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



// approve
contract LnTokenLocker is LnAdmin, Pausable {
    using SafeMath for uint;

    IERC20 private token;
    struct LockInfo {
        uint256 amount;
        uint256 lockTimestamp; // lock time at block.timestamp
        uint256 lockDays;
        uint256 claimedAmount;
    }
    mapping (address => LockInfo) public lockData;
    
    constructor(address _token, address _admin) public LnAdmin(_admin) {
        token = IERC20(_token);
    }
    
    function sendLockTokenMany(address[] calldata _users, uint256[] calldata _amounts, uint256[] calldata _lockdays) external onlyAdmin {
        require(_users.length == _amounts.length, "array length not eq");
        require(_users.length == _lockdays.length, "array length not eq");
        for (uint256 i=0; i < _users.length; i++) {
            sendLockToken(_users[i], _amounts[i], _lockdays[i]);
        }
    }

    // 1. msg.sender/admin approve many token to this contract
    function sendLockToken(address _user, uint256 _amount, uint256 _lockdays) public onlyAdmin returns (bool) {
        require(_amount > 0, "amount can not zero");
        require(lockData[_user].amount == 0, "this address has locked");
        require(_lockdays > 0, "lock days need more than zero");
        
        LockInfo memory lockinfo = LockInfo({
            amount:_amount,
            lockTimestamp:block.timestamp,
            lockDays:_lockdays,
            claimedAmount:0
        });

        lockData[_user] = lockinfo;
        return true;
    }
    
    function claimToken(uint256 _amount) external returns (uint256) {
        require(_amount > 0, "Invalid parameter amount");
        address _user = msg.sender;
        require(lockData[_user].amount > 0, "No lock token to claim");

        uint256 passdays = block.timestamp.sub(lockData[_user].lockTimestamp).div(1 days);
        require(passdays > 0, "need wait for one day at least");

        uint256 available = 0;
        if (passdays >= lockData[_user].lockDays) {
            available = lockData[_user].amount;
        } else {
            available = lockData[_user].amount.div(lockData[_user].lockDays).mul(passdays);
        }
        available = available.sub(lockData[_user].claimedAmount);
        require(available > 0, "not available claim");
        //require(_amount <= available, "insufficient available");
        uint256 claim = _amount;
        if (_amount > available) { // claim as much as possible
            claim = available;
        }

        lockData[_user].claimedAmount = lockData[_user].claimedAmount.add(claim);

        token.transfer(_user, claim);

        return claim;
    }
}



contract LnTokenCliffLocker is LnAdmin, Pausable {
    using SafeMath for uint;

    IERC20 private token;
    struct LockInfo {
        uint256 amount;
        uint256 lockTimestamp; // lock time at block.timestamp
        uint256 claimedAmount;
    }
    mapping (address => LockInfo) public lockData;
    
    constructor(address _token, address _admin) public LnAdmin(_admin) {
        token = IERC20(_token);
    }
    
    function sendLockTokenMany(address[] calldata _users, uint256[] calldata _amounts, uint256[] calldata _locktimes) external onlyAdmin {
        require(_users.length == _amounts.length, "array length not eq");
        require(_users.length == _locktimes.length, "array length not eq");
        for (uint256 i=0; i < _users.length; i++) {
            sendLockToken(_users[i], _amounts[i], _locktimes[i]);
        }
    }

    function avaible(address _user ) external view returns( uint256 ){
        require(lockData[_user].amount > 0, "No lock token to claim");
        if( now < lockData[_user].lockTimestamp ){
            return 0;
        }

        uint256 available = 0;
        available = lockData[_user].amount;
        available = available.sub(lockData[_user].claimedAmount);
        return available;
    }

    // 1. msg.sender/admin approve many token to this contract
    function sendLockToken(address _user, uint256 _amount, uint256 _locktimes ) public onlyAdmin returns (bool) {
        require(_amount > 0, "amount can not zero");
        require(lockData[_user].amount == 0, "this address has locked");
        require(_locktimes > 0, "lock days need more than zero");
        
        LockInfo memory lockinfo = LockInfo({
            amount:_amount,
            lockTimestamp:_locktimes,
            claimedAmount:0
        });

        lockData[_user] = lockinfo;
        return true;
    }
    
    function claimToken(uint256 _amount) external returns (uint256) {
        require(_amount > 0, "Invalid parameter amount");
        address _user = msg.sender;
        require(lockData[_user].amount > 0, "No lock token to claim");
        require( now >= lockData[_user].lockTimestamp, "Not time to claim" );

        uint256 available = 0;
        available = lockData[_user].amount;
        available = available.sub(lockData[_user].claimedAmount);
        require(available > 0, "not available claim");

        uint256 claim = _amount;
        if (_amount > available) { // claim as much as possible
            claim = available;
        }

        lockData[_user].claimedAmount = lockData[_user].claimedAmount.add(claim);

        token.transfer(_user, claim);

        return claim;
    }
}