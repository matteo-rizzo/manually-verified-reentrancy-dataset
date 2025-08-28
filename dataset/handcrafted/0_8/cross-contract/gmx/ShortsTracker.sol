// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

contract ToyShortsTracker {
    address public positionManager;
    mapping(address => uint256) public globalShortAveragePriceE18; // 1e18 USD

    modifier onlyPM() { require(msg.sender == positionManager, "!pm"); _; }

    function setPositionManager(address pm) external {
        require(positionManager == address(0), "set");
        positionManager = pm;
    }

    // Only updated when the keeper goes through PositionManager.
    function updateGlobalShortAveragePrice(address indexToken, uint256 newAvgE18) external onlyPM {
        globalShortAveragePriceE18[indexToken] = newAvgE18;
    }
}