/**
 *Submitted for verification at Etherscan.io on 2021-02-24
*/

//"SPDX-License-Identifier: UNLICENSED"

pragma solidity ^0.6.6;







contract Multiplier{
    //instantiating SafeMath library
    using SafeMath for uint;
    
    //instance of utility token
    IERC20 private _token;
    
    //struct
    struct User {
        uint balance;
        uint release;
        address approved;
    }
    
    //address to User mapping
    mapping(address => User) private _users;
    
    //multiplier constance for multiplying rewards
    uint private constant _MULTIPLIER_CEILING = 2;
    
    //events
    event Deposited(address indexed user, uint amount);
    event Withdrawn(address indexed user, uint amount, uint time);
    event NewLockup(address indexed poolstake, address indexed user, uint lockup);
    event ContractApproved(address indexed user, address contractAddress);
    
    /* 
     * @dev instantiate the multiplier.
     * --------------------------------
     * @param token--> the token that will be locked up.
     */    
    constructor(address token) public {
        require(token != address(0), "token must not be the zero address");
        _token = IERC20(token);
    }

    /* 
     * @dev top up the available balance.
     * --------------------------------
     * @param _amount --> the amount to lock up.
     * -------------------------------
     * returns whether successfully topped up or not.
     */  
    function deposit(uint _amount) external returns(bool) {
        
        require(_amount > 0, "amount must be larger than zero");
        
        require(_token.transferFrom(msg.sender, address(this), _amount), "amount must be approved");
        _users[msg.sender].balance = balance(msg.sender).add(_amount);
        
        emit Deposited(msg.sender, _amount);
        return true;
    }
    
    /* 
     * @dev approve a contract to use Multiplier
     * -------------------------------------------
     * @param _traditional --> the contract address to approve
     * -------------------------------------------------------
     * returns whether successfully approved or not
     */ 
    function approveContract(address _traditional) external returns(bool) {
        
        require(_users[msg.sender].approved != _traditional, "already approved");
        require(Address.isContract(_traditional), "can only approve a contract");
        
        _users[msg.sender].approved = _traditional;
        
        emit ContractApproved(msg.sender, _traditional);
        return true;
    } 
    
    /* 
     * @dev withdraw released multiplier balance.
     * ----------------------------------------
     * @param _amount --> the amount to be withdrawn.
     * -------------------------------------------
     * returns whether successfully withdrawn or not.
     */
    function withdraw(uint _amount) external returns(bool) {
        
        require(now >= _users[msg.sender].release, "must wait for release");
        require(_amount > 0, "amount must be larger than zero");
        require(balance(msg.sender) >= _amount, "must have a sufficient balance");
        
        _users[msg.sender].balance = balance(msg.sender).sub(_amount);
        require(_token.transfer(msg.sender, _amount), "token transfer failed");
        
        emit Withdrawn(msg.sender, _amount, now);
        return true;
    }
    
    /* 
     * @dev updates the lockup period (called by pool contract)
     * ----------------------------------------------------------
     * IMPORTANT - can only be used to increase lockup
     * -----------------------------------------------
     * @param _lockup --> the vesting period
     * -------------------------------------------
     * returns whether successfully withdrawn or not.
     */
    function updateLockupPeriod(address _user, uint _lockup) external returns(bool) {
        
        require(Address.isContract(msg.sender), "only a smart contract can call");
        require(_users[_user].approved == msg.sender, "contract is not approved");
        require(now.add(_lockup) > _users[_user].release, "cannot reduce current lockup");
        
        _users[_user].release = now.add(_lockup);
        
        emit NewLockup(msg.sender, _user, _lockup);
        return true;
    }
    
    /* 
     * @dev get the multiplier ceiling for percentage calculations.
     * ----------------------------------------------------------
     * returns the multiplication factor.
     */     
    function getMultiplierCeiling() external pure returns(uint) {
        
        return _MULTIPLIER_CEILING;
    }

    /* 
     * @dev get the multiplier user balance.
     * -----------------------------------
     * @param _user --> the address of the user.
     * ---------------------------------------
     * returns the multiplier balance.
     */ 
    function balance(address _user) public view returns(uint) {
        
        return _users[_user].balance;
    }
    
    /* 
     * @dev get the approved Traditional contract address
     * --------------------------------------------------
     * @param _user --> the address of the user
     * ----------------------------------------
     * returns the approved contract address
     */ 
    function approvedContract(address _user) external view returns(address) {
        
        return _users[_user].approved;
    }
    
    /* 
     * @dev get the release of the multiplier balance.
     * ---------------------------------------------
     * @param user --> the address of the user.
     * ---------------------------------------
     * returns the release timestamp.
     */     
    function lockupPeriod(address _user) external view returns(uint) {
        
        uint release = _users[_user].release;
        if (release > now) return (release.sub(now));
        else return 0;
    }
}