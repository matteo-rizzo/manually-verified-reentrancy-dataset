/**
 *Submitted for verification at Etherscan.io on 2021-04-13
*/

// SPDX-License-Identifier: MIT

pragma solidity ^0.6.12;

/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
 */


/**
 * @dev A token holder contract that will allow a beneficiary to extract the
 * tokens after a given release time.
 *
 * Useful for simple vesting schedules like "advisors get all of their tokens
 * after 1 year".
 */
contract TokenTimelock {
    // ERC20 basic token contract being held
    IERC20 public _token;

    // beneficiary of tokens after they are released
    address public _beneficiary;

    // timestamp when token release is enabled
    uint256 public _cyclePeriod;
    uint256 public _amountPerCycle;
    uint256 public _lastUnstakeTime;

    constructor(
        IERC20 token,
        uint256 cyclePeriod,
        uint256 amountPerCycle,
        address beneficiary
    ) public {
        // solhint-disable-next-line not-rely-on-time
        require(amountPerCycle > 0, "TokenTimelock: amount per cycle > 0");
        require(cyclePeriod > 0, "TokenTimelock: cycle period > 0");

        _token = token;
        _beneficiary = beneficiary;
        _cyclePeriod = cyclePeriod;
        _amountPerCycle = amountPerCycle;
    }

    /**
     * @return the token being held.
     */
    function token() public view returns (IERC20) {
        return _token;
    }

    /**
     * @return the beneficiary of the tokens.
     */
    function beneficiary() public view returns (address) {
        return _beneficiary;
    }

    function pending() public view returns (uint256) {
        uint256 diffTime = block.timestamp - _lastUnstakeTime;
        uint256 pendingAmount = (diffTime / _cyclePeriod) * _amountPerCycle;
        uint256 tokenAmount = _token.balanceOf(address(this));
        if (tokenAmount > pendingAmount) {
            return pendingAmount;
        }
        return tokenAmount;
    }

    /**
     * @notice Transfers tokens held by timelock to beneficiary.
     */
    function release() public {
        // solhint-disable-next-line not-rely-on-time
        require(msg.sender == _beneficiary, "Only beneficiary can approve");

        uint256 pendingAmount = pending();
        require(pendingAmount > 0, "TokenTimelock: no tokens to release");

        _lastUnstakeTime = block.timestamp;
        _token.transfer(_beneficiary, pendingAmount);
    }
}