/**
 *Submitted for verification at Etherscan.io on 2020-11-18
*/

pragma solidity ^0.6.2;

/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
 */


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


/**
 * @dev Collection of functions related to the address type
 */


/**
 * @title SafeERC20
 * @dev Wrappers around ERC20 operations that throw on failure (when the token
 * contract returns false). Tokens that return no value (and instead revert or
 * throw on failure) are also supported, non-reverting calls are assumed to be
 * successful.
 * To use this library you can add a `using SafeERC20 for IERC20;` statement to your contract,
 * which allows you to call the safe operations as `token.safeTransfer(...)`, etc.
 */


/**
 * @title Vesting
 * @dev A token holder contract that can release its token balance gradually like a
 * typical vesting scheme, with a cliff and vesting period.
 */
contract Vesting {
    using SafeMath for uint256;
    using SafeERC20 for IERC20;

    // beneficiary of tokens after they are released
    address payable private _beneficiary;

    // PEAKDEFI token interface
    IERC20 private constant _token = IERC20(0x630d98424eFe0Ea27fB1b3Ab7741907DFFEaAd78);

    // Durations and timestamps are expressed in UNIX time, the same units as block.timestamp.
    uint256 private _start;
    uint256 private _finish;
    uint256 private _cliff;
    uint256 private _releasePeriod;
    uint256 private _releaseCount;
    uint256 private _released;

    event TokensReleased(uint256 amount);

	// -----------------------------------------------------------------------
	// CONSTRUCTOR
	// -----------------------------------------------------------------------

    /**
     * @dev Creates a vesting contract that vests its balance of any ERC20 token to the
     * beneficiary, gradually in a linear fashion until start + duration. By then all
     * of the balance will have vested.
     * @param beneficiary address to whom vested tokens are transferred
     * @param start the time (as Unix time) at which point vesting starts
     * @param cliff (in seconds) until which vesting should be paused
     * @param releasePeriod (in seconds) it should represent the periods (ex: release should be once per 1 month, 3 month and etc)
     * @param releaseCount the count of periods, during which beneficiary can release tokens (ex: "12" if 1 year and only once per month)
     */
    constructor (
        address payable beneficiary,
        uint256 start,
        uint256 cliff,
        uint256 releasePeriod,
        uint256 releaseCount
    ) public {
        require(beneficiary != address(0), "Vesting: beneficiary is the zero address");
        require(start > block.timestamp, "Vesting: vesting should be start in future");
        require(releaseCount != 0, "Vesting: the vesting contract should have minimum one release");
        require(releaseCount != 0, "Vesting: release duration should be bigger than 0");

        _beneficiary = beneficiary;
        _start = start;
        _finish = start.add(cliff).add(releaseCount.mul(releasePeriod));
        _cliff = cliff;
        _releasePeriod = releasePeriod;
        _releaseCount = releaseCount;
    }

    fallback () external payable {}
    receive () external payable {}

	// -----------------------------------------------------------------------
	// SETTERS
	// -----------------------------------------------------------------------

    /**
     * @notice Transfers vested tokens to beneficiary.
     */
    function release() external {
        uint256 unreleased = _releasableAmount();
        require(unreleased > 0, "release: no tokens are due");
        require(msg.sender == _beneficiary, "release: only beneficiary can release tokens");

        _released = _released.add(unreleased);
        _token.safeTransfer(_beneficiary, unreleased);

        emit TokensReleased(unreleased);
    }

	// -----------------------------------------------------------------------
	// GETTERS
	// -----------------------------------------------------------------------

    /**
     * @return the beneficiary of the tokens.
     */
    function beneficiary() external view returns (address) {
        return _beneficiary;
    }

    /**
     * @return the PEAKDEFI token address
     */
    function token() external pure returns (address) {
        return address(_token);
    }

    /**
     * @return the PEAKDEFI tokens amount being locked here
     */
    function tokenBalance() external view returns (uint256) {
        return _token.balanceOf(address(this));
    }

    /**
     * @return the start time of the token vesting.
     */
    function start() external view returns (uint256) {
        return _start;
    }

    /**
     * @return the amount of the token released.
     */
    function released() external view returns (uint256) {
        return _released;
    }

    /**
     * @return the cliff, until which releases is paused
     */
    function cliff() external view returns (uint256) {
        return _cliff;
    }

    /**
     * @return the count of planned releases
     */
    function releaseCount() external view returns (uint256) {
        return _releaseCount;
    }

    /**
     * @return the period for vesting
     */
    function releasePeriod() external view returns (uint256) {
        return _releasePeriod;
    }

	// -----------------------------------------------------------------------
	// INTERNAL
	// -----------------------------------------------------------------------

    /**
     * @dev Calculates the amount that has already vested but hasn't been released yet.
     */
    function _releasableAmount() private view returns (uint256) {
        return _vestedAmount().sub(_released);
    }

    /**
     * @dev Calculates the amount that has already vested.
     */
    function _vestedAmount() private view returns (uint256) {
        uint256 currentBalance = _token.balanceOf(address(this));
        uint256 totalBalance = currentBalance.add(_released);

        if (block.timestamp < _start.add(_cliff)) {
            return 0;
        } else if (block.timestamp >= _finish) {
            return totalBalance;
        } else {
            uint256 vestingStartTime = _start.add(_cliff);
            uint256 timeLeftAfterStart = block.timestamp.sub(vestingStartTime);
            uint256 availableReleases = timeLeftAfterStart.div(_releasePeriod);
            uint256 tokensPerRelease = totalBalance.div(_releaseCount);

            return availableReleases.mul(tokensPerRelease);
        }
    }
}