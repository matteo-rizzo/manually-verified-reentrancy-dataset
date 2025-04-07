/**
 *Submitted for verification at Etherscan.io on 2021-04-30
*/

// File: contracts/lib/Ownable.sol

/*

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


// File: contracts/DODOFee/UserQuota.sol


contract UserQuota is Ownable {

    mapping(address => uint256) public userQuota;
    
    event SetQuota(address user, uint256 amount);

    function setUserQuota(address[] memory users, uint256[] memory quotas) external onlyOwner {
        require(users.length == quotas.length, "PARAMS_LENGTH_NOT_MATCH");
        for(uint256 i = 0; i< users.length; i++) {
            require(users[i] != address(0), "USER_INVALID");
            userQuota[users[i]] = quotas[i];
            emit SetQuota(users[i],quotas[i]);
        }
    }

    function getUserQuota(address user) external view returns (int) {
        return int(userQuota[user]);
    }
}