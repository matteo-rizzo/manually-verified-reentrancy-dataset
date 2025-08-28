// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "./Vault.sol";
import "./ShortsTracker.sol";

contract ToyPositionManager {
    ToyVault public immutable vault;
    ToyShortsTracker public immutable tracker;
    address public keeper; // who is allowed to execute orders

    constructor(address _vault, address _tracker) { vault = ToyVault(_vault); tracker = ToyShortsTracker(_tracker); }

    modifier onlyKeeper() { require(msg.sender == keeper, "not keeper"); _; }
    function setKeeper(address k) external { require(keeper == address(0), "set"); keeper = k; }

    // Mimics the problematic flow:
    // 1) enable leverage (relaxes a guard)
    // 2) do bookkeeping (avg price update)
    // 3) REFUND execution fee via .call(...)  ← Attacker's receive() fires here
    // 4) disable leverage
    function executeDecreaseOrder(
        address account,
        address indexToken,
        uint256 newAvgPriceE18,
        uint256 executionFeeWei
    ) external payable onlyKeeper {
        vault.setLeverageEnabled(true);                              // (1) loosen
        if (newAvgPriceE18 > 0) tracker.updateGlobalShortAveragePrice(indexToken, newAvgPriceE18); // (2)

        if (executionFeeWei > 0) {                                   // (3) reentrancy window
            (bool ok, ) = payable(account).call{value: executionFeeWei}("");
            require(ok, "refund failed");
        }

        vault.setLeverageEnabled(false);                             // (4) tighten back
    }

    receive() external payable {}
}