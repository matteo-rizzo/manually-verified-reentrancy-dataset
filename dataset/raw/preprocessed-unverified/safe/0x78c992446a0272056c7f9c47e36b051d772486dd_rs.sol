/**
 *Submitted for verification at Etherscan.io on 2020-10-29
*/

/**
 *Submitted for verification at Etherscan.io on 2020-10-28
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.6.12;


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
 * To use this library you can add a `using SafeERC20 for ERC20;` statement to your contract,
 * which allows you to call the safe operations as `token.safeTransfer(...)`, etc.
 */

 




contract AaveLiquidate {
    using SafeERC20 for IERC20;
    
    IAave constant public AAVE = IAave(0x398eC7346DcD622eDc5ae82352F02bE94C62d119);
    address constant public CORE = address(0x3dfd23A6c5E8BbcFc9581d2E864a68feb6a076d3);
    
    function getUserReserveBalance(address _reserve, address _user) public view returns (uint256) {
        (,uint currentBorrowBalance,,,,,,,,) = AAVE.getUserReserveData(_reserve, _user);
        return currentBorrowBalance;
    }
    
    modifier upkeep() {
        require(KP3R.isKeeper(msg.sender), "::isKeeper: keeper is not registered");
        _;
        KP3R.worked(msg.sender);
    }
    
    IKeep3rV1 public constant KP3R = IKeep3rV1(0x1cEB5cB57C4D4E2b2433641b95Dd330A33185A44);
    
    function liquidate(address _collateral, address _reserve, address _user) external upkeep {
        uint256 _repay = getUserReserveBalance(_reserve, _user);
        require(_repay > 0, "No debt");
        
        IERC20(_reserve).safeTransferFrom(msg.sender, address(this), _repay);
        IERC20(_reserve).safeApprove(CORE, _repay);
        AAVE.liquidationCall(_collateral, _reserve, _user, _repay, false);
        IERC20(_reserve).safeApprove(CORE, 0);
        
        uint256 _liquidated = IERC20(_collateral).balanceOf(address(this));
        require(_liquidated > 0, "Failed to liquidate");
        
        IERC20(_reserve).safeTransfer(msg.sender, IERC20(_reserve).balanceOf(address(this)));
        IERC20(_collateral).safeTransfer(msg.sender, IERC20(_collateral).balanceOf(address(this)));
    }
}