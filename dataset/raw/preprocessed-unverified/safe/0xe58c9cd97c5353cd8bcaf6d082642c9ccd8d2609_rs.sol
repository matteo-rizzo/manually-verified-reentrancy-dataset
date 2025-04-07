/**
 *Submitted for verification at Etherscan.io on 2021-04-28
*/

/*
    Copyright 2020 DODO ZOO.
    SPDX-License-Identifier: Apache-2.0
*/

pragma solidity 0.6.9;
pragma experimental ABIEncoderV2;

/**
 * @title Ownable
 * @author DODO Breeder
 *
 * @notice Ownership related functions
 */



contract UserQuota is Ownable {

    mapping(address => int) public userQuota;
    int constant quota = 150 * 10**6; // 150u on eth

    function setUserQuota(address[] memory users) external onlyOwner {
        for(uint256 i = 0; i< users.length; i++) {
            require(users[i] != address(0), "USER_INVALID");
            userQuota[users[i]] = quota;
        }
    }

    function getUserQuota(address user) external view returns (int) {
        return userQuota[user];
    }
}