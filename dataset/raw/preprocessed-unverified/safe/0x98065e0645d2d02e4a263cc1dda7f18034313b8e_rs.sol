/**
 *Submitted for verification at Etherscan.io on 2020-10-04
*/

pragma solidity ^0.6.12;

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


contract CritFee {
    using SafeERC20 for IERC20;
    using SafeMath for uint;

    address public governance;
    address public constant treasuryFund = 0x8c7A440962D783A234DA45682dDd809515a7459F;
    address public constant devFund = 0xE0B6f711f0C015b3111f3c124C80f3Aa7cE3A502;

    uint256 public devFundShare;
    uint256 public constant MAX_SHARE = 10000;

    modifier onlyGovernance {
        require(msg.sender == governance, "governance");
        _;
    }

    constructor() public {
        governance = msg.sender;
        devFundShare = 2000;
    }

    function distribute(address _token) external {
        IERC20 token = IERC20(_token);
        uint256 balance = token.balanceOf(address(this));
        uint256 amountDevFund = balance.mul(devFundShare).div(MAX_SHARE);
        token.safeTransfer(devFund, amountDevFund);
        token.safeTransfer(treasuryFund, balance.sub(amountDevFund));
    }

    function setGovernance(address _governance) onlyGovernance external {
        governance = _governance;
    }

    function setDevFundShare(uint256 _devFundShare) onlyGovernance external {
        require(_devFundShare < MAX_SHARE, 'invalid share');
        devFundShare = _devFundShare;
    }
}