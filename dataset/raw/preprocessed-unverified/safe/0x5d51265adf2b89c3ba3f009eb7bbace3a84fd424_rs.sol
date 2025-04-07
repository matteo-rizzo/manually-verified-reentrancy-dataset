/**
 *Submitted for verification at Etherscan.io on 2021-04-11
*/

pragma solidity 0.6.12;


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
 * @dev Interface of the ERC20 standard as defined in the EIP.
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
 * To use this library you can add a `using SafeERC20 for IERC20;` statement to your contract,
 * which allows you to call the safe operations as `token.safeTransfer(...)`, etc.
 */


// A simple treasury that takes erc20 tokens and ETH
contract Treasury {

    /* ========== STATE VARIABLES ========== */

    address public governance;

    /* ========== CONSTRUCTOR ========== */

    constructor() public {
        governance = msg.sender;
    }

     // accepts ether
    receive() external payable{}
    fallback() external payable{}

    /* ========== MODIFIER ========== */

    modifier onlyGov() {
        require(msg.sender == governance, "!gov");
        _;
    }

    /* ========== VIEW FUNCTIONS ========== */

    function holdings(address _token)
        public
        view
        returns (uint256)
    {
        return IERC20(_token).balanceOf(address(this));
    }

    /* ========== RESTRICTED FUNCTIONS ========== */

    function takeOut(
        address _token,
        address _destination,
        uint256 _amount
    )
        public
        onlyGov
    {
        require(_amount <= holdings(_token), "!insufficient");
        SafeERC20.safeTransfer(IERC20(_token), _destination, _amount);
    }

    function takeOutETH(
        address payable _destination,
        uint256 _amount
    )
        public
        payable
        onlyGov
    {
        _destination.transfer(_amount);
    }

    function setGov(address _governance)
        public
        onlyGov
    {
        governance = _governance;
    }
}