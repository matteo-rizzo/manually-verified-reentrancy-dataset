/**
 *Submitted for verification at Etherscan.io on 2021-03-02
*/

// SPDX-License-Identifier: MIT
pragma solidity=0.7.6;

/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
 */






contract NewsFlash is IERC3156FlashBorrower {
    address constant WETH10 = 0xf4BB2e28688e89fCcE3c0580D37d36A7672E8A9F;

    event BreakingNews(string headline, uint etherInSupport);

    function flash() external {
        IERC3156FlashLender(WETH10).flashLoan(
            IERC3156FlashBorrower(address(this)),
            WETH10,
            type(uint112).max,
            new bytes(0)
        );
    }

    function onFlashLoan(
        address initiator,
        address token,
        uint256 amount,
        uint256 fee,
        bytes calldata data
    ) external override returns (bytes32) {
        uint256 balance = IERC20(WETH10).balanceOf(address(this));
        emit BreakingNews("Flash minting is dumb", balance);
        IERC20(WETH10).approve(WETH10, balance);
        return keccak256("ERC3156FlashBorrower.onFlashLoan");
    }
}