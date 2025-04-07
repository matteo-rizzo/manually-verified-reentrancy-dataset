/**
 *Submitted for verification at Etherscan.io on 2021-02-27
*/

// Dependency file: /Users/starfish/code/badger-system/deps/@openzeppelin/contracts/token/ERC20/IERC20.sol

// SPDX-License-Identifier: MIT

// pragma solidity ^0.6.0;

/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
 */



// Dependency file: /Users/starfish/code/badger-system/deps/@openzeppelin/contracts/math/SafeMath.sol


// pragma solidity ^0.6.0;

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



// Dependency file: /Users/starfish/code/badger-system/deps/@openzeppelin/contracts/utils/Address.sol


// pragma solidity ^0.6.2;

/**
 * @dev Collection of functions related to the address type
 */



// Dependency file: /Users/starfish/code/badger-system/deps/@openzeppelin/contracts/token/ERC20/SafeERC20.sol


// pragma solidity ^0.6.0;

// import "/Users/starfish/code/badger-system/deps/@openzeppelin/contracts/token/ERC20/IERC20.sol";
// import "/Users/starfish/code/badger-system/deps/@openzeppelin/contracts/math/SafeMath.sol";
// import "/Users/starfish/code/badger-system/deps/@openzeppelin/contracts/utils/Address.sol";

/**
 * @title SafeERC20
 * @dev Wrappers around ERC20 operations that throw on failure (when the token
 * contract returns false). Tokens that return no value (and instead revert or
 * throw on failure) are also supported, non-reverting calls are assumed to be
 * successful.
 * To use this library you can add a `using SafeERC20 for IERC20;` statement to your contract,
 * which allows you to call the safe operations as `token.safeTransfer(...)`, etc.
 */



// Dependency file: /Users/starfish/code/badger-system/deps/@openzeppelin/contracts/token/ERC20/TokenTimelock.sol


// pragma solidity ^0.6.0;

// import "/Users/starfish/code/badger-system/deps/@openzeppelin/contracts/token/ERC20/SafeERC20.sol";

/**
 * @dev A token holder contract that will allow a beneficiary to extract the
 * tokens after a given release time.
 *
 * Useful for simple vesting schedules like "advisors get all of their tokens
 * after 1 year".
 */
contract TokenTimelock {
    using SafeERC20 for IERC20;

    // ERC20 basic token contract being held
    IERC20 private _token;

    // beneficiary of tokens after they are released
    address private _beneficiary;

    // timestamp when token release is enabled
    uint256 private _releaseTime;

    constructor (IERC20 token, address beneficiary, uint256 releaseTime) public {
        // solhint-disable-next-line not-rely-on-time
        require(releaseTime > block.timestamp, "TokenTimelock: release time is before current time");
        _token = token;
        _beneficiary = beneficiary;
        _releaseTime = releaseTime;
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
     * @return the time when the tokens are released.
     */
    function releaseTime() public view returns (uint256) {
        return _releaseTime;
    }

    /**
     * @notice Transfers tokens held by timelock to beneficiary.
     */
    function release() public virtual {
        // solhint-disable-next-line not-rely-on-time
        require(block.timestamp >= _releaseTime, "TokenTimelock: current time is before release time");

        uint256 amount = _token.balanceOf(address(this));
        require(amount > 0, "TokenTimelock: no tokens to release");

        _token.safeTransfer(_beneficiary, amount);
    }
}


// Root file: contracts/badger-timelock/OtcEscrow.sol

pragma solidity ^0.6.8;

// import "/Users/starfish/code/badger-system/deps/@openzeppelin/contracts/token/ERC20/IERC20.sol";
// import "/Users/starfish/code/badger-system/deps/@openzeppelin/contracts/token/ERC20/SafeERC20.sol";
// import "/Users/starfish/code/badger-system/deps/@openzeppelin/contracts/math/SafeMath.sol";
// import "/Users/starfish/code/badger-system/deps/@openzeppelin/contracts/token/ERC20/TokenTimelock.sol";

/*
    Simple OTC Escrow contract to transfer vested bBadger in exchange for specified USDC amount
*/
contract OtcEscrow {
    using SafeMath for uint256;
    using SafeERC20 for IERC20;

    address constant usdc = 0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48;
    address constant bBadger = 0x19D97D8fA813EE2f51aD4B4e04EA08bAf4DFfC28;
    address constant badgerGovernance = 0xB65cef03b9B89f99517643226d76e286ee999e77;

    event VestingDeployed(address vesting);

    address public beneficiary;
    uint256 public duration;
    uint256 public usdcAmount;
    uint256 public bBadgerAmount;

    constructor(
        address beneficiary_,
        uint256 duration_,
        uint256 usdcAmount_,
        uint256 bBadgerAmount_
    ) public {
        beneficiary = beneficiary_;
        duration = duration_;
        usdcAmount = usdcAmount_;
        bBadgerAmount = bBadgerAmount_;
    }

    modifier onlyApprovedParties() {
        require(msg.sender == badgerGovernance || msg.sender == beneficiary);
        _;
    }

    /// @dev Atomically trade specified amonut of USDC for control over bBadger in vesting contract
    /// @dev Either counterparty may execute swap if sufficient token approval is given by recipient
    function swap() public onlyApprovedParties {
        // Transfer expected USDC from beneficiary
        IERC20(usdc).safeTransferFrom(beneficiary, address(this), usdcAmount);

        // Create Vesting contract
        TokenTimelock vesting = new TokenTimelock(
            IERC20(bBadger),
            beneficiary,
            now + duration
        );

        // Transfer bBadger to vesting contract
        IERC20(bBadger).safeTransfer(address(vesting), bBadgerAmount);

        // Transfer USDC to badger governance 
        IERC20(usdc).safeTransfer(badgerGovernance, usdcAmount);

        emit VestingDeployed(address(vesting));
    }

    /// @dev Return bBadger to Badger Governance to revoke escrow deal
    function revoke() external {
        require(msg.sender == badgerGovernance, "onlyBadgerGovernance");
        uint256 bBadgerBalance = IERC20(bBadger).balanceOf(address(this));
        IERC20(bBadger).safeTransfer(badgerGovernance, bBadgerBalance);
    }

    function revokeUsdc() external onlyApprovedParties {
        uint256 usdcBalance = IERC20(usdc).balanceOf(address(this));
        IERC20(usdc).safeTransfer(beneficiary, usdcBalance);
    }
}