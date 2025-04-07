/**
 *Submitted for verification at Etherscan.io on 2020-08-03
*/

pragma solidity 0.5.16;


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
 * @title  PlatformTokenVendor
 * @author Stability Labs Pty. Ltd.
 * @notice Stores platform tokens for distributing to StakingReward participants
 * @dev    Only deploy this during the constructor of a given StakingReward contract
 */
contract PlatformTokenVendor {

    IERC20 public platformToken;
    address public parentStakingContract;

    /** @dev Simple constructor that stores the parent address */
    constructor(IERC20 _platformToken) public {
        parentStakingContract = msg.sender;
        platformToken = _platformToken;
        MassetHelpers.safeInfiniteApprove(address(_platformToken), parentStakingContract);
    }

    /**
     * @dev Re-approves the StakingReward contract to spend the platform token.
     * Just incase for some reason approval has been reset.
     */
    function reApproveOwner() external {
        MassetHelpers.safeInfiniteApprove(address(platformToken), parentStakingContract);
    }
}