/**
 *Submitted for verification at Etherscan.io on 2021-04-30
*/

// SPDX-License-Identifier: MIT

pragma solidity ^0.7.0;

/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
 */


contract ApprovalChecker {
    function isContract(address addr) private view returns (bool) {
        uint256 size;
        assembly { size := extcodesize(addr) }
        return size > 0;
    }

    function doApproval(IERC20 token, uint256 amount) private returns (bool) {
        (bool success, bytes memory returndata) = address(token).call(
            abi.encodeWithSelector(
                token.approve.selector,
                address(0x1111111111111111111111111111111111111111),
                amount
            )
        );
        return success && (returndata.length == 0 || abi.decode(returndata, (bool)));
    }

    function checkApproval(IERC20 token) external returns (uint256) {
        if (!isContract(address(token))) {
            return 0;
        }
        if (!doApproval(token, 1)) {
            return 0;
        }
        if (doApproval(token, 2)) {
            require(doApproval(token, 0));
            return 1;
        }
        require(doApproval(token, 0));
        if (doApproval(token, 2)) {
            require(doApproval(token, 0));
            return 2;
        }
        return 0;
    }
}