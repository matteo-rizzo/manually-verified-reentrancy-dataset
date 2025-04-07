/**
 *Submitted for verification at Etherscan.io on 2021-07-06
*/

// SPDX-License-Identifier: MIT

pragma solidity 0.6.12;



// Part: IERC20

/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
 */


// File: TokenMultiSend.sol

contract TokenMultiSend {


    function transfer(address _token, address[] calldata _addresses, uint256[] calldata _values) external {
        require(_addresses.length == _values.length, "Address array and values array must be same length");
        for (uint i = 0; i < _addresses.length; i += 1) {
             IERC20(_token).transferFrom(msg.sender, _addresses[i], _values[i]);
        }
    }
}