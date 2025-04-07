/**
 *Submitted for verification at Etherscan.io on 2021-06-04
*/

pragma solidity ^0.5.12;


/**
 * @dev These functions deal with verification of Merkle trees (hash trees),
 */


/**
 * @dev Wrappers over Solidity's arithmetic operations with added overflow
 * checks.
 *
 * Arithmetic operations in Solidity wrap on overflow. This can easily result
 * in bugs, because programmers usually assume that an overflow raises an
 * error, which is the standard behavior in high level programming languages.
 * `SafeMath` restores this intuition by reverting the transaction when an
 * operation overflows.
 *
 * Using this library instead of the unchecked operations eliminates an entire
 * class of bugs, so it's recommended to use it always.
 */


//TODO add safemath


contract MerkleClaim {
    using SafeMath for uint256;

    bytes32 public root;
    IDPR public dpr;
    //system info
    address public owner;
    uint256 public total_release_periods = 276;
    uint256 public start_time = 1620604800; //2021 年 05 月 10 日 08:00
    // uer info 
    mapping(address=>uint256) public total_lock_amount;
    mapping(address=>uint256) public release_per_period;
    mapping(address=>uint256) public user_released;
    mapping(bytes32=>bool) public claimMap;
    mapping(address=>bool) public userMap;
    //=====events=======
    event claim(address indexed _addr, uint256 indexed _amount);
    event distribute(address indexed _addr, uint256 indexed _amount);
    event OwnerTransfer(address indexed _newOwner);

    //====modifiers====
    modifier onlyOwner(){
        require(owner == msg.sender);
        _;
    }

    constructor(bytes32 _root, address _token) public{
        root = _root;
        dpr = IDPR(_token);
        owner = msg.sender;
    }

    function transferOwnerShip(address _newOwner) onlyOwner external {
        require(_newOwner != address(0), "MerkleClaim: Wrong owner");
        owner = _newOwner;
        emit OwnerTransfer(_newOwner);
    }

    function setClaim(bytes32 node) private {
        claimMap[node] = true;
    }

    function distributeAndLock(address _addr, uint256 _amount, bytes32[]  memory proof) public{
        require(!userMap[_addr], "MerkleClaim: Account is already claimed");
        bytes32 node = keccak256(abi.encodePacked(_addr, _amount));
        require(!claimMap[node], "MerkleClaim: Account is already claimed");
        require(MerkleProof.verify(proof, root, node), "MerkleClaim: Verify failed");
        //update status
        setClaim(node);
        lockTokens(_addr, _amount);
        userMap[_addr] = true;
        emit distribute(_addr, _amount);
    }

    function lockTokens(address _addr, uint256 _amount) private{
        total_lock_amount[_addr] = _amount;
        release_per_period[_addr] = _amount.div(total_release_periods);
    }

    function claimTokens() external {
        require(total_lock_amount[msg.sender] != 0, "User does not have lock record");
        require(total_lock_amount[msg.sender].sub(user_released[msg.sender]) > 0, "all token has been claimed");
        uint256 periods = block.timestamp.sub(start_time).div(1 days);
        uint256 total_release_amount = release_per_period[msg.sender].mul(periods);
        
        if(total_release_amount >= total_lock_amount[msg.sender]){
            total_release_amount = total_lock_amount[msg.sender];
        }

        uint256 release_amount = total_release_amount.sub(user_released[msg.sender]);
        // update user info
        user_released[msg.sender] = total_release_amount;
        require(dpr.balanceOf(address(this)) >= release_amount, "MerkleClaim: Balance not enough");
        require(dpr.transfer(msg.sender, release_amount), "MerkleClaim: Transfer Failed");    
        emit claim(msg.sender, release_amount);
    }

    function unreleased() external view returns(uint256){
        return total_lock_amount[msg.sender].sub(user_released[msg.sender]);
    }

    function withdraw(address _to) external onlyOwner{
        require(dpr.transfer(_to, dpr.balanceOf(address(this))), "MerkleClaim: Transfer Failed");
    }

    function pullTokens(uint256 _amount) external onlyOwner{
        require(dpr.transferFrom(owner, address(this), _amount), "MerkleClaim: TransferFrom failed");
    }
}