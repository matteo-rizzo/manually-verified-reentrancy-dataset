/**
 *Submitted for verification at Etherscan.io on 2021-07-13
*/

// SPDX-License-Identifier: MIT
pragma solidity 0.8.6;

// Sources flattened with hardhat v2.1.2 https://hardhat.org
// NOTE: manually removed extraneous licence identifies and pragmas to accommodate Etherscan Verify & Publish

// File @openzeppelin/contracts/token/ERC20/[emailÂ protected]




/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
 */



// File contracts/DataTokenMigrator.sol


contract DataTokenMigrator { // is UpgradeAgent, see Crowdsale.sol

    IERC20 public oldToken;
    IERC20 public newToken;

    constructor(IERC20 _oldToken, IERC20 _newToken) {
        oldToken = _oldToken;
        newToken = _newToken;
    }

    /**
     * Everything below this comment is the DATA token UpgradeAgent interface.
     * See https://etherscan.io/address/0x0cf0ee63788a0849fe5297f3407f701e122cc023#code
     */

    // See totalSupply at https://etherscan.io/address/0x0cf0ee63788a0849fe5297f3407f701e122cc023#readContract
    uint256 public originalSupply = 987154514 ether;

    /** UpgradeAgent Interface marker */
    function isUpgradeAgent() public pure returns (bool) {
        return true;
    }

    /**
     * @param _from token holder that called CrowdsaleToken.upgrade(_value)
     * @param _value amount of tokens to upgrade, checked by the CrowdsaleToken
     */
    function upgradeFrom(address _from, uint256 _value) external {
        require(
            msg.sender == address(oldToken),
            "Call not permitted, UpgradableToken only"
        );
        newToken.transfer(_from, _value);
    }
}