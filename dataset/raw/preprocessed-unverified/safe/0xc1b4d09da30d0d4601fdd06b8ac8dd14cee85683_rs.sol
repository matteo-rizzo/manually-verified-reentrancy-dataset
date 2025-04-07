/**
 *Submitted for verification at Etherscan.io on 2021-06-11
*/

// Sources flattened with hardhat v2.3.0 https://hardhat.org

// File @openzeppelin/contracts/token/ERC20/[emailÂ protected]

// SPDX-License-Identifier: MIT

pragma solidity 0.6.12;

/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
 */



// File contracts/MultiTransfer.sol

contract MultiTransfer {
    uint256 private constant S_NOT_ENTERED = 1;
    uint256 private constant S_ENTERED = 2;
    uint256 private _status = S_NOT_ENTERED;

    function multiTransferERC20(address token, address[] calldata recipients, uint256[] calldata amounts) external {
        uint256 count = recipients.length;
        require(
               _status == S_NOT_ENTERED
            && count > 0
        , "Not authorized.");
        _status = S_ENTERED;

        bool failed;
        address recipient;
        uint256 amount;
        for (uint256 i; i < count; i ++) {
            recipient = recipients[i];
            amount = amounts[i];

            // Ignore bad parameters;
            if (recipient == address(0) || recipient == msg.sender || recipient == address(this) || amount == 0) {
                continue;
            }

            // Attempt the transfer.
            IERC20(token).transferFrom(msg.sender, recipient, amount);
        }

        require(!failed, "Transfer failed!");
        _status = S_NOT_ENTERED;
    }
}