/**
 *Submitted for verification at Etherscan.io on 2021-07-30
*/

// SPDX-License-Identifier: MIT
pragma solidity 0.8.0;



contract TokenTimelock {
    using SafeERC20 for IERC20;

    // ERC20 basic token contract being held
    IERC20 immutable private _token;

    // beneficiary of tokens after they are released
    address immutable private _beneficiary;

    // timestamp when token release is enabled
    uint256 immutable private _releaseTime;

    constructor (IERC20 token_, address beneficiary_, uint256 releaseTime_) {
        // solhint-disable-next-line not-rely-on-time
        require(releaseTime_ > block.timestamp, "TokenTimelock: release time is before current time");
        _token = token_;
        _beneficiary = beneficiary_;
        _releaseTime = releaseTime_;
    }

    /**
     * @return the token being held.
     */
    function token() public view virtual returns (IERC20) {
        return _token;
    }

    /**
     * @return the beneficiary of the tokens.
     */
    function beneficiary() public view virtual returns (address) {
        return _beneficiary;
    }

    /**
     * @return the time when the tokens are released.
     */
    function releaseTime() public view virtual returns (uint256) {
        return _releaseTime;
    }

    /**
     * @notice Transfers tokens held by timelock to beneficiary.
     */
    function release() public virtual {
        // solhint-disable-next-line not-rely-on-time
        require(block.timestamp >= releaseTime(), "TokenTimelock: current time is before release time");

        uint256 amount = token().balanceOf(address(this));
        require(amount > 0, "TokenTimelock: no tokens to release");

        token().safeTransfer(beneficiary(), amount);
    }
}
contract ArtemisTimeLock is TokenTimelock {
    using SafeERC20 for IERC20;

    // The number of tranches required for the contract to fully vest.
    uint256 immutable internal maxTranches;

    // The number of weeks comprising each tranche cycle.
    uint256 immutable internal trancheWeeks;

    // The percent of tokens to release for each tranche.
    uint256 immutable internal tranchePercent;

    // The Starting date/time for the vesting schedule.
    uint256 immutable internal startTime;

    // Track how many tranches have been released
    uint256 internal tranchesReleased;

    // The number of tokens that will be dispersed for each tranche cycle
    uint256 internal disperseAmount;

    /**
     * @dev Constructs the Artemis Time Lock contract.
     * @param token_ is the address of the ERC20 token being stored.
     * @param beneficiary_ is the address where tokens will be distributed to.
     * @param releaseTime_ is the initial date/time when the release
     * function will be available to call.
     * @param _startTime is the date/time the vesting schedule starts at.
     * @param _trancheWeeks is the number of weeks in each tranche cycle.
     * @param _maxTranches is the total number of tranches that represent
     * the full vesting time for the contract.
     * @param _tranchePercent is the percentage of tokens that will be released
     * during each tranche period.
     */
    constructor(
        IERC20 token_,
        address beneficiary_,
        uint256 releaseTime_,
        uint256 _startTime,
        uint256 _trancheWeeks,
        uint256 _maxTranches,
        uint256 _tranchePercent
    )
    TokenTimelock(
        token_,
        beneficiary_,
        releaseTime_
    )
    {
        // Ensure the beneficiary has a valid address.
        require(beneficiary_ != address(0), "ArtemisTimeLockFactory: beneficiary has zero address");

        // Ensure that the tranches & percentages distributed add up to 100%.
        require(_maxTranches * _tranchePercent == 10000, "TokenTimeLock: percents and tranches do not = 100%");

        trancheWeeks = _trancheWeeks;
        maxTranches = _maxTranches;
        tranchePercent = _tranchePercent;
        startTime = _startTime;
    }

    /**
     * @dev This is the core functionality of this smart contract.  This function
     * reverts if the release time has not been reached yet.  If it has been
     * reached, it then checks to ensure that the contract is still in possession
     * of the beneficiaries tokens.  If no tokens are available, it reverts.  If
     * tokens are available, it then it checks to see if the disperseAmount value
     * has been set.  If not, it will calculate the value and assign it.
     *
     * Next, it uses the current block.timstamp to determine which tranche the
     * contract is currently in.  The first evaluation looks to see if the
     * contract is fully vested.  If the current tranche is greater than the
     * max number of tranches, the contract is fully vested - release all tokens.
     *
     * Next, the contract evaluates whether the currentTranche is greater than the
     * tranchesReleased value.  If true, this indicates that tokens are available
     * for release.  At this point the contract increments the tranchesReleased value
     * and transfers the disperseAmount of tokens to the beneficiary.
     *
     * If none of the above conditions apply, this indicates that an early release
     * call was made.  In this case, the contract reverts and provides an error
     * message.
     */
    function release() public override {
        // Requires that the releaseTime has arrived or the whole block fails.
        require(block.timestamp >= releaseTime(), "TokenTimelock: current time is before release time");

        // Sets the amount of tokens currently held by this contract for beneficiary.
        uint256 _remaining_balance = token().balanceOf(address(this));

        // Revert with error if remaining balance is not greater than 0.
        require(_remaining_balance > 0, "TokenTimelock: no tokens to release");

        /*
         * @dev The first time the release() function successfully executes, the contract
         * needs to determine how many tokens should be released for each tranche cycle.
         * This value is set once and does not change over the life of the contract.
         */
        if (disperseAmount == 0) {

            // Calculate and set the number of tokens needing to be dispersed for each tranche
            // based on the number of tokens in the contract, and the tranchePercent specified.
            disperseAmount = uint256(token().balanceOf(address(this))) * tranchePercent / 10000;
        }

        // Determine which tranche cycle we are currently in.
        uint256 currentTranche = uint256(block.timestamp - startTime) / (trancheWeeks * 1 weeks);

        // Disperse everything if the full vesting period is up.
        if (currentTranche >= maxTranches) {

            // increment the number of tranches released, even after fully vested.
            tranchesReleased++;

            // transfer ALL remaining tokens from the contract to the beneficiary.
            token().safeTransfer(beneficiary(), token().balanceOf(address(this)));

        // Transfer tokens if a tranche release is available.
        } else if (currentTranche > tranchesReleased) {

            // increment the number of tranches released
            // also prevents secondary release call from executing
            tranchesReleased++;

            // transfer the disperseAmount to the beneficiary.
            token().safeTransfer(beneficiary(), disperseAmount);
        } else {

            // If none of the above conditions apply, early release was requested.  Revert w/error.
            revert("TokenTimelock: tranche unavailable, release requested too early.");
        }
    }
}