/**
 *Submitted for verification at Etherscan.io on 2021-03-23
*/

// File: contracts/Utils/SafeMath.sol
// SPDX-License-Identifier: MIT
pragma solidity 0.6.12;

/**
 * @dev Wrappers over Solidity's arithmetic operations with added overflow
 * checks.
 *
 * Arithmetic operations in Solidity wrap on overflow. This can easily result
 * in bugs, because programmers usually assume that an overflow raises an
 * error, which is the standard behavior in high level programming languages.
 * `SafeMath` restores this intuition by reverting the transaction when an
 * operation overflows.
 *
 * Using this library instead of the unchecked operations eliminates an entire
 * class of bugs, so it's recommended to use it always.
 */


// File: contracts/vault/mutevault.sol

/**
 * @title A vault to hold and distribute tokens efficiently.
 */
contract MuteVault {
    using SafeMath for uint256;

    address public token;
    address public geyser;
    uint256 public rewarded;
    address public owner;

    constructor(address _token, address _geyser) public {
        token = _token;
        geyser = _geyser;
        IMute(token).approve(geyser, 0xffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff);
        owner = msg.sender;
    }

    function balance() public view returns (uint256) {
        return IMute(token).balanceOf(address(this));
    }

    function reward() external returns (bool) {
        require(balance() > 0, 'MuteVault::reward: Cannot reward 0 balance');
        require(msg.sender == token || msg.sender == owner, "MuteVault::reward: Can only be called by the token contract");

        rewarded = rewarded.add(balance());

        ITokenGeyser(geyser).addTokens(balance());
        return true;
    }
}



