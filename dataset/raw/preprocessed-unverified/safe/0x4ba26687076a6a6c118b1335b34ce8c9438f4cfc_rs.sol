/**
 *Submitted for verification at Etherscan.io on 2020-03-28
*/

pragma solidity ^0.5.0;

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
 * @dev Interface of the ERC20 standard as defined in the EIP. Does not include
 * the optional functions; to access them see {ERC20Detailed}.
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
 * To use this library you can add a `using SafeERC20 for ERC20;` statement to your contract,
 * which allows you to call the safe operations as `token.safeTransfer(...)`, etc.
 */


/**
 * @dev A token holder contract that will allow a beneficiary to extract the
 * tokens after a given release time.
 *
 * Useful for simple vesting schedules like "advisors get all of their tokens
 * after 1 year".
 *
 * For a more complete vesting schedule, see {TokenVesting}.
 */
contract TokenTimelock {
    using SafeMath for uint256;
    using SafeERC20 for IERC20;

    // ERC20 basic token contract being held
    IERC20 private _token;

    // The count of upcoming releases
    uint256 private _releasesCount;

    // Delay between releases is constant value
    uint256 private constant _delay = 365 days;

    // beneficiary of tokens after they are released
    address private _beneficiary;

    struct Release {
        uint256 amount;
        uint256 releaseTime;
        bool released;
    }

    // Information of releases
    mapping (uint8 => Release) private _releases;

    constructor (
        IERC20 token,
        address beneficiary,
        uint256 firstReleaseTimestamp,
        uint256 [] memory tokensPerRelease
    ) public {
        require(address(token) != address(0), "TokenTimelock: invalid token address");
        require(beneficiary != address(0), "TokenTimelock: invalid beneficiary address");
        require(firstReleaseTimestamp > block.timestamp, "TokenTimelock: invalid first release timestamp");
        require(tokensPerRelease.length > 0 && tokensPerRelease.length < 20, "TokenTimelock: invalid release tokens amount");

        _token = token;
        _beneficiary = beneficiary;
        _releasesCount = tokensPerRelease.length;

        for (uint8 i = 0; i < _releasesCount; i++) {
            require(tokensPerRelease[i] > 0, "TokenTimelock: invalid tokens amount inside array");

            uint256 tokensAmount = tokensPerRelease[i] * 1 ether;
            uint256 releaseDate = firstReleaseTimestamp.add(_delay.mul(i));
            _releases[i] = Release(tokensAmount, releaseDate, false);
        }
    }

    function () external payable {
        // empty fallback method
    }

    /**
     * @notice Transfers tokens held by TokenTimelock to beneficiary.
     */
    function release() public {
        uint256 amount = _token.balanceOf(address(this));
        require(amount > 0, "release: no tokens to release");

        // Get current release id
        (uint8 releaseId, uint256 tokensAmount) = _getCurrentReleaseIdAndTokens();
        require(tokensAmount > 0, "release: tokens is not available for release");

        // Set as released
        _releases[releaseId].released = true;

        // Transfer tokens to beneficiary address
        _token.safeTransfer(_beneficiary, tokensAmount);
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

	/**
     * @return the delay for release
     */
	function delay() public pure returns (uint256) {
		return _delay;
	}

	/**
     * @return the total releases count
     */
	function releasesCount() public view returns (uint256) {
		return _releasesCount;
	}

    /**
     * @return details of provided release id
     */
    function getReleaseInfo(uint8 releaseId) public view returns (uint256, uint256, bool) {
        Release memory r = _releases[releaseId];
        return (
            r.amount,
            r.releaseTime,
            r.released
        );
    }

    /**
     * @return the it of current release.
     */
    function _getCurrentReleaseIdAndTokens() private view returns (uint8, uint256) {
        uint8 releaseId = 0;
        uint256 tokensAmount = 0;

        for (uint8 i = 0; i < _releasesCount; i++) {
            if (!_releases[i].released && block.timestamp >= _releases[i].releaseTime) {
                releaseId = i;
                tokensAmount = _releases[i].amount;
                break;
            }
        }

        return (
            releaseId,
            tokensAmount
        );
    }
}