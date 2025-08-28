// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "./PositionManager.sol";

contract Keeper {
    ToyPositionManager public immutable pm;
    constructor(address payable _pm) { pm = ToyPositionManager(_pm); }

    function exec(address account, address indexToken, uint256 newAvgPriceE18, uint256 feeWei) external payable {
        require(msg.value == feeWei, "fund fee");
        // forwards ether to PM; PM will refund to `account` (the attacker contract)
        pm.executeDecreaseOrder{value: feeWei}(account, indexToken, newAvgPriceE18, feeWei);
    }

    receive() external payable {}
}