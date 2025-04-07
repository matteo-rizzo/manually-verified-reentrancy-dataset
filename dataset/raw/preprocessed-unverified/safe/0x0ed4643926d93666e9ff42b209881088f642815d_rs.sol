/**
 *Submitted for verification at Etherscan.io on 2021-09-17
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




contract InstanceClaim {
    using SafeMath for uint256;

    bytes32 public root;
    IDPR public dpr;
    //system info
    address public owner;
    ILockingContract new_locking_contract;
    mapping(bytes32=>bool) public claimMap;
    mapping(address=>bool) public userMap;
    //=====events=======
    event distribute(address _addr, uint256 _amount);
    event OwnerTransfer(address _newOwner);

    //====modifiers====
    modifier onlyOwner(){
        require(owner == msg.sender);
        _;
    }

    constructor(address _token) public{
        dpr = IDPR(_token);
        owner = msg.sender;
    }

    function transferOwnerShip(address _newOwner) onlyOwner external {
        require(_newOwner != address(0), "MerkleClaim: Wrong owner");
        owner = _newOwner;
        emit OwnerTransfer(_newOwner);
    }

    function setRoot(bytes32 _root) external onlyOwner{
        root = _root;
    }

    function setClaim(bytes32 node) private {
        claimMap[node] = true;
    }


    function setLockContract(ILockingContract lockContract) external onlyOwner{
        require(address(lockContract) != address(0), "DPRBridge: Zero address");
        dpr.approve(address(lockContract), uint256(-1));
        new_locking_contract = lockContract;
    }
    function distributeAndLock(uint256 _amount, bytes32[]  memory proof, bool need_move) public{
        require(!userMap[msg.sender], "MerkleClaim: Account is already claimed");
        bytes32 node = keccak256(abi.encodePacked(msg.sender, _amount));
        require(!claimMap[node], "MerkleClaim: Account is already claimed");
        require(MerkleProof.verify(proof, root, node), "MerkleClaim: Verify failed");
        //update status
        setClaim(node);
        // uint256 half_amount = _amount.div(2);
        // choose the choice
        if(need_move){
            new_locking_contract.lock(msg.sender, _amount);
        }else{
            dpr.transfer(msg.sender, _amount);
        }
        //lockTokens(_addr, _amount.sub(half_amount));
        userMap[msg.sender] = true;
        emit distribute(msg.sender, _amount);
    }

    function withdraw(address _to) external onlyOwner{
        require(dpr.transfer(_to, dpr.balanceOf(address(this))), "MerkleClaim: Transfer Failed");
    }

    function pullTokens(uint256 _amount) external{
        require(dpr.transferFrom(msg.sender, address(this), _amount), "MerkleClaim: TransferFrom failed");
    }
}