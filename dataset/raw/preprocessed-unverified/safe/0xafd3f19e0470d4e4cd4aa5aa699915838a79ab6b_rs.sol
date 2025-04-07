/**
 *Submitted for verification at Etherscan.io on 2021-03-30
*/

// SPDX-License-Identifier: MIT
pragma solidity 0.6.12;

// solhint-disable avoid-low-level-calls
// solhint-disable not-rely-on-time

// File contracts/interfaces/IStrategy.sol
// License-Identifier: MIT



// File @boringcrypto/boring-solidity/contracts/[email protected]
// License-Identifier: MIT

// Audit on 5-Jan-2021 by Keno and BoringCrypto
// Source: https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/access/Ownable.sol + Claimable.sol
// Edited by BoringCrypto

contract BoringOwnableData {
    address public owner;
    address public pendingOwner;
}

contract BoringOwnable is BoringOwnableData {
    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /// @notice `owner` defaults to msg.sender on construction.
    constructor() public {
        owner = msg.sender;
        emit OwnershipTransferred(address(0), msg.sender);
    }

    /// @notice Transfers ownership to `newOwner`. Either directly or claimable by the new pending owner.
    /// Can only be invoked by the current `owner`.
    /// @param newOwner Address of the new owner.
    /// @param direct True if `newOwner` should be set immediately. False if `newOwner` needs to use `claimOwnership`.
    /// @param renounce Allows the `newOwner` to be `address(0)` if `direct` and `renounce` is True. Has no effect otherwise.
    function transferOwnership(
        address newOwner,
        bool direct,
        bool renounce
    ) public onlyOwner {
        if (direct) {
            // Checks
            require(newOwner != address(0) || renounce, "Ownable: zero address");

            // Effects
            emit OwnershipTransferred(owner, newOwner);
            owner = newOwner;
            pendingOwner = address(0);
        } else {
            // Effects
            pendingOwner = newOwner;
        }
    }

    /// @notice Needs to be called by `pendingOwner` to claim ownership.
    function claimOwnership() public {
        address _pendingOwner = pendingOwner;

        // Checks
        require(msg.sender == _pendingOwner, "Ownable: caller != pending owner");

        // Effects
        emit OwnershipTransferred(owner, _pendingOwner);
        owner = _pendingOwner;
        pendingOwner = address(0);
    }

    /// @notice Only allows the `owner` to execute the function.
    modifier onlyOwner() {
        require(msg.sender == owner, "Ownable: caller is not the owner");
        _;
    }
}

// File @boringcrypto/boring-solidity/contracts/libraries/[email protected]
// License-Identifier: MIT

/// @notice A library for performing overflow-/underflow-safe math,
/// updated with awesomeness from of DappHub (https://github.com/dapphub/ds-math).


/// @notice A library for performing overflow-/underflow-safe addition and subtraction on uint128.


/// @notice A library for performing overflow-/underflow-safe addition and subtraction on uint64.


/// @notice A library for performing overflow-/underflow-safe addition and subtraction on uint32.


// File @boringcrypto/boring-solidity/contracts/interfaces/[email protected]
// License-Identifier: MIT



// File @boringcrypto/boring-solidity/contracts/libraries/[email protected]
// License-Identifier: MIT



// File contracts/strategies/SushiStrategy.sol
// License-Identifier: MIT

interface ISushiBar is IERC20 {
    function enter(uint256 _amount) external;
    function leave(uint256 _share) external;
}

contract SushiStrategy is IStrategy, BoringOwnable {
    using BoringMath for uint256;
    using BoringERC20 for IERC20;

    IERC20 private immutable sushi;
    ISushiBar private immutable bar;

    constructor(ISushiBar bar_, IERC20 sushi_) public {
        bar = bar_;
        sushi = sushi_;
    }

    // Send the assets to the Strategy and call skim to invest them
    /// @inheritdoc IStrategy
    function skim(uint256 amount) external override {
        sushi.approve(address(bar), amount);
        bar.enter(amount);
    }

    // Harvest any profits made converted to the asset and pass them to the caller
    /// @inheritdoc IStrategy
    function harvest(uint256 balance, address) external override onlyOwner returns (int256 amountAdded) {
        uint256 share = bar.balanceOf(address(this));
        uint256 totalShares = bar.totalSupply();
        uint256 totalSushi = sushi.balanceOf(address(bar));
        uint256 keepShare = balance.mul(totalShares) / totalSushi;
        uint256 harvestShare = share.sub(keepShare);
        bar.leave(harvestShare);
        amountAdded = int256(sushi.balanceOf(address(this)));
        sushi.safeTransfer(owner, uint256(amountAdded)); // Add as profit
    }

    // Withdraw assets. The returned amount can differ from the requested amount due to rounding or if the request was more than there is.
    /// @inheritdoc IStrategy
    function withdraw(uint256 amount) external override onlyOwner returns (uint256 actualAmount) {
        uint256 totalShares = bar.totalSupply();
        uint256 totalSushi = sushi.balanceOf(address(bar));
        uint256 withdrawShare = amount.mul(totalShares) / totalSushi;
        uint256 share = bar.balanceOf(address(this));
        if (withdrawShare > share) {
            withdrawShare = share;
        }
        bar.leave(withdrawShare);
        actualAmount = sushi.balanceOf(address(this));
        sushi.safeTransfer(owner, actualAmount);
    }

    // Withdraw all assets in the safest way possible. This shouldn't fail.
    /// @inheritdoc IStrategy
    function exit(uint256 balance) external override onlyOwner returns (int256 amountAdded) {
        uint256 share = bar.balanceOf(address(this));
        bar.leave(share);
        uint256 amount = sushi.balanceOf(address(this));
        amountAdded = int256(amount - balance);
        sushi.safeTransfer(owner, amount);
    }
}