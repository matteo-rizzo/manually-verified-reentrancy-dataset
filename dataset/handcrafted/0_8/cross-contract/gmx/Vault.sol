// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

contract ToyVault {
    mapping(address => uint256) public globalShortSizesE18; // notionals in 1e18 USD
    address public positionManager;
    bool public leverageEnabled;

    modifier onlyPM() { require(msg.sender == positionManager, "!pm"); _; }

    function setPositionManager(address pm) external {
        require(positionManager == address(0), "set");
        positionManager = pm;
    }
    function setLeverageEnabled(bool v) external onlyPM { leverageEnabled = v; }

    // Called directly by the attacker during reentrancy.
    function increasePosition(address indexToken, uint256 sizeDeltaE18, bool isLong) external {
        require(leverageEnabled, "leverage disabled");
        if (!isLong) {
            globalShortSizesE18[indexToken] += sizeDeltaE18; // ✅ size updated
            // ❌ avg price NOT touched here → split-brain with ShortsTracker
        }
    }
}