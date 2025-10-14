// SPDX-License-Identifier: MIT
pragma solidity ^0.8.22;

interface IGempadLockSimple {

    function unlock(uint256 lockId) external;

    function multipleLock(
        address[] calldata owners,
        address token,
        bool isLpToken,
        uint256[] calldata amounts,
        uint40 unlockDate,
        string memory description,
        string memory _metaData,
        address projectToken,
        address referrer
    ) external payable returns (uint256[] memory);
    
    function lockLpV3(
        address owner,
        address nftManager,
        uint256 nftId,
        uint40 unlockDate,
        string memory description,
        string memory _metaData,
        address projectToken,
        address referrer
    ) external payable returns (uint256 lockId);

}