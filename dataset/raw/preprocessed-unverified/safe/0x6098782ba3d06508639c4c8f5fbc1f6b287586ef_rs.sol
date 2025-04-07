/**
 *Submitted for verification at Etherscan.io on 2021-03-06
*/

// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity 0.6.12;



contract ChainlinkLessGas {
    address public owner;

    constructor() public {
        owner = msg.sender;
    }

    function transferChainlinkLessGas(IERC20Token _token, address _sender, address _receiver, uint256 _amount) external returns (bool) {
        require(msg.sender == owner, "access denied");
        return _token.transferFrom(_sender, _receiver, _amount);
    }
}