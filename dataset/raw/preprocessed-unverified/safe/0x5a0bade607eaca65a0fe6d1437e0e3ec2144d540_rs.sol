/**
 *Submitted for verification at Etherscan.io on 2021-02-24
*/

// SPDX-License-Identifier: AGPL-3.0

pragma solidity 0.6.12;



// Part: OpenZeppelin/[email protected]/Address

/**
 * @dev Collection of functions related to the address type
 */


// Part: OpenZeppelin/[email protected]/IERC20

/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
 */


// Part: OpenZeppelin/[email protected]/SafeMath

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


// Part: WETH



// Part: IVaultAPI

interface IVaultAPI is IERC20 {
    function deposit(uint256 _amount, address recipient)
        external
        returns (uint256 shares);

    function withdraw(uint256 _shares) external;

    function token() external view returns (address);

    function permit(
        address owner,
        address spender,
        uint256 value,
        uint256 deadline,
        bytes calldata signature
    ) external returns (bool);
}

// Part: OpenZeppelin/[email protected]/SafeERC20

/**
 * @title SafeERC20
 * @dev Wrappers around ERC20 operations that throw on failure (when the token
 * contract returns false). Tokens that return no value (and instead revert or
 * throw on failure) are also supported, non-reverting calls are assumed to be
 * successful.
 * To use this library you can add a `using SafeERC20 for IERC20;` statement to your contract,
 * which allows you to call the safe operations as `token.safeTransfer(...)`, etc.
 */


// File: ZapYvWETH.sol

contract ZapYvWETH {
    using SafeMath for uint256;
    using SafeERC20 for IERC20;

    address public constant weth =
        address(0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2);
    address public constant yvWETH =
        address(0xa9fE4601811213c340e850ea305481afF02f5b28);

    constructor() public {
        // Setup approvals
        IERC20(weth).safeApprove(yvWETH, uint256(-1));
    }

    receive() external payable {
        depositETH();
    }

    function depositETH() public payable {
        WETH(weth).deposit{value: msg.value}();
        uint256 _amount = IERC20(weth).balanceOf(address(this));
        IVaultAPI vault = IVaultAPI(yvWETH);

        IVaultAPI(vault).deposit(_amount, msg.sender);
    }
}