/**
 *Submitted for verification at Etherscan.io on 2021-05-31
*/

/**
 *Submitted for verification at BscScan.com on 2021-05-27
*/

pragma solidity 0.6.12;


// 
/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
 */


// 
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


// 
/**
 * @dev Collection of functions related to the address type
 */


// 
/**
 * @title SafeERC20
 * @dev Wrappers around ERC20 operations that throw on failure (when the token
 * contract returns false). Tokens that return no value (and instead revert or
 * throw on failure) are also supported, non-reverting calls are assumed to be
 * successful.
 * To use this library you can add a `using SafeERC20 for IERC20;` statement to your contract,
 * which allows you to call the safe operations as `token.safeTransfer(...)`, etc.
 */


// 
contract GovStake {
    using SafeERC20 for IERC20;
    using SafeMath for uint256;

    event Deposited(address indexed account, uint256 stakeAmount, uint256 totalStakeAmount);
    event Withdrawn(address indexed account, uint256 stakeAmount, uint256 totalStakeAmount);

    mapping(address=>uint256) public stake;
    address public govToken;

    constructor(address _govToken) public {
        govToken = _govToken;
    }

    function deposit(uint256 amount) public {
        stake[msg.sender] = stake[msg.sender].add(amount);
        IERC20(govToken).transferFrom(msg.sender, address(this), amount);
        emit Deposited(msg.sender, amount, stake[msg.sender]);
    }

    function withdraw(uint256 amount) public {
        require(stake[msg.sender] >= amount, "insufficient stake amount");
        stake[msg.sender] = stake[msg.sender].sub(amount);
        IERC20(govToken).safeTransfer(msg.sender, amount);
        emit Withdrawn(msg.sender, amount, stake[msg.sender]);
    }

    function withdraw() public {
        withdraw(stake[msg.sender]);
    }
}