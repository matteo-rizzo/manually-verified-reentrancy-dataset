/**
 *Submitted for verification at Etherscan.io on 2021-09-17
*/

pragma solidity 0.5.12;


/**
 * @dev Interface of the ERC20 standard as defined in the EIP. Does not include
 * the optional functions; to access them see {ERC20Detailed}.
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


//import "@openzeppelin/contracts/math/Safemath.sol";
contract DPRLock {
    using SafeMath for uint256;
    using SafeERC20 for IERC20;
    address public claim_contract;
    IERC20 public dpr; 
    uint256 public release_period = 30 days;
    uint256 public total_lock_time = 180 days;
    address public owner;
    mapping(address => bool) public pause_address;
    mapping(address => uint256) public user_released;
    mapping(address => uint256) public user_released_time;
    mapping(address => uint256) public total_user_lock;
    mapping(address => uint256) public user_release_per_period;
    


    //==events
    event Lock(address _user, uint256 amount);

    constructor(address _claim_contract, IERC20 _dpr) public {
        claim_contract = _claim_contract;
        dpr = _dpr;
        owner = msg.sender;
    }

    modifier onlyClaimContract(){
        require(msg.sender == claim_contract, "Lock: Not claim contract");
        _;
    }

    modifier NotPauseAddress(address _user){
        require(pause_address[_user] == false, "Lock: Pause");
        _;
    }
    modifier onlyOwner(){
        require(msg.sender == owner, "Lock: Not Owner");
        _;
    }

    function transferOwnerShip(address _newOwner) external onlyOwner{
        require(_newOwner != address(0), "Lock: 0 address");
        owner = _newOwner;
    }
    function lock(address _user, uint256 _amount) external onlyClaimContract{
        dpr.safeTransferFrom(msg.sender, address(this), _amount);
        uint256 new_lock_amount = get_total_lock_amount(_amount);
        total_user_lock[_user] = new_lock_amount;
        user_released_time[_user] = block.timestamp.add(total_lock_time);
        user_release_per_period[_user] = new_lock_amount.div(3); // in 3 months
        emit Lock(_user, _amount);
    }

    function get_total_lock_amount(uint256 amount) private returns(uint256){
        return amount.add(amount.mul(5).div(100));
    }

    function lock_manually(address _user, uint256 _amount) external onlyOwner{
        uint256 new_lock_amount = get_total_lock_amount(_amount);
        user_released_time[_user] = block.timestamp.add(total_lock_time);
        user_release_per_period[_user] = new_lock_amount.div(3); // in 3 months
        emit Lock(_user, _amount);
    }

    function claim() external NotPauseAddress(msg.sender){
        require(total_user_lock[msg.sender] > 0, "Lock: No balance");
        require(block.timestamp >= user_released_time[msg.sender], "Lock: Too early");
        require(user_released[msg.sender] < total_user_lock[msg.sender], "Lock: claim over");
        uint256 time_passed = block.timestamp.sub(user_released_time[msg.sender]);
        uint256 period_passed = time_passed.div(release_period);
        uint256 total_released_amount = period_passed * user_release_per_period[msg.sender];
        if(total_released_amount >= total_user_lock[msg.sender]){
            total_released_amount = total_user_lock[msg.sender];
        }
        uint256 release_this_time = total_released_amount.sub(user_released[msg.sender]);
        require(dpr.balanceOf(address(this))>=release_this_time, "Lock: Not enough");
        user_released[msg.sender] = total_released_amount;
        dpr.safeTransfer(msg.sender, release_this_time);
    }

    function PauseClaim(address _user, bool is_pause) external onlyOwner {
        pause_address[_user] = is_pause;
    }

    function withdrawTokens(address _token, uint256 _amount) external onlyOwner{
        IERC20(_token).safeTransfer(owner, _amount);
    }

    function pullTokens(uint256 _amount) external {
        require(dpr.transferFrom(msg.sender, address(this), _amount), "MerkleClaim: TransferFrom failed");
    }
}