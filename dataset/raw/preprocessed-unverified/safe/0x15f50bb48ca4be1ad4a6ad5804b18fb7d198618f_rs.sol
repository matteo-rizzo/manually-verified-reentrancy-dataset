/**
 *Submitted for verification at Etherscan.io on 2020-11-08
*/

// SPDX-License-Identifier: Apache-2.0
pragma solidity ^0.7.0;
pragma experimental ABIEncoderV2;
// File: contracts/iface/Wallet.sol

// Copyright 2017 Loopring Technology Limited.


/// @title Wallet
/// @dev Base contract for smart wallets.
///      Sub-contracts must NOT use non-default constructor to initialize
///      wallet states, instead, `init` shall be used. This is to enable
///      proxies to be deployed in front of the real wallet contract for
///      saving gas.
///
/// @author Daniel Wang - <daniel@loopring.org>


// File: contracts/base/DataStore.sol

// Copyright 2017 Loopring Technology Limited.



/// @title DataStore
/// @dev Modules share states by accessing the same storage instance.
///      Using ModuleStorage will achieve better module decoupling.
///
/// @author Daniel Wang - <daniel@loopring.org>
abstract contract DataStore
{
    modifier onlyWalletModule(address wallet)
    {
        requireWalletModule(wallet);
        _;
    }

    function requireWalletModule(address wallet) view internal
    {
        require(Wallet(wallet).hasModule(msg.sender), "UNAUTHORIZED");
    }
}

// File: contracts/iface/PriceOracle.sol

// Copyright 2017 Loopring Technology Limited.


/// @title PriceOracle


// File: contracts/lib/MathUint.sol

// Copyright 2017 Loopring Technology Limited.


/// @title Utility Functions for uint
/// @author Daniel Wang - <daniel@loopring.org>


// File: contracts/thirdparty/SafeCast.sol

// Taken from https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/utils/SafeCast.sol



/**
 * @dev Wrappers over Solidity's uintXX/intXX casting operators with added overflow
 * checks.
 *
 * Downcasting from uint256/int256 in Solidity does not revert on overflow. This can
 * easily result in undesired exploitation or bugs, since developers usually
 * assume that overflows raise errors. `SafeCast` restores this intuition by
 * reverting the transaction when such an operation overflows.
 *
 * Using this library instead of the unchecked operations eliminates an entire
 * class of bugs, so it's recommended to use it always.
 *
 * Can be combined with {SafeMath} and {SignedSafeMath} to extend it to smaller types, by performing
 * all math on `uint256` and `int256` and then downcasting.
 */


// File: contracts/stores/QuotaStore.sol

// Copyright 2017 Loopring Technology Limited.





/// @title QuotaStore
/// @dev This store maintains daily spending quota for each wallet.
///      A rolling daily limit is used.
contract QuotaStore is DataStore
{
    using MathUint for uint;
    using SafeCast for uint;

    uint128 public constant MAX_QUOTA = uint128(-1);

    // Optimized to fit into 64 bytes (2 slots)
    struct Quota
    {
        uint128 currentQuota;
        uint128 pendingQuota;
        uint128 spentAmount;
        uint64  spentTimestamp;
        uint64  pendingUntil;
    }

    mapping (address => Quota) public quotas;

    event QuotaScheduled(
        address wallet,
        uint    pendingQuota,
        uint64  pendingUntil
    );

    constructor()
        DataStore()
    {
    }

    // 0 for newQuota indicates unlimited quota, or daily quota is disabled.
    function changeQuota(
        address wallet,
        uint    newQuota,
        uint    effectiveTime
        )
        external
        onlyWalletModule(wallet)
    {
        require(newQuota <= MAX_QUOTA, "INVALID_VALUE");
        if (newQuota == MAX_QUOTA) {
            newQuota = 0;
        }

        quotas[wallet].currentQuota = currentQuota(wallet).toUint128();
        quotas[wallet].pendingQuota = newQuota.toUint128();
        quotas[wallet].pendingUntil = effectiveTime.toUint64();

        emit QuotaScheduled(
            wallet,
            newQuota,
            quotas[wallet].pendingUntil
        );
    }

    function checkAndAddToSpent(
        address     wallet,
        address     token,
        uint        amount,
        PriceOracle priceOracle
        )
        external
    {
        Quota memory q = quotas[wallet];
        uint available = _availableQuota(q);
        if (available != MAX_QUOTA) {
            uint value = (token == address(0)) ?
                amount :
                priceOracle.tokenValue(token, amount);
            if (value > 0) {
                require(available >= value, "QUOTA_EXCEEDED");
                requireWalletModule(wallet);
                _addToSpent(wallet, q, value);
            }
        }
    }

    function addToSpent(
        address wallet,
        uint    amount
        )
        external
        onlyWalletModule(wallet)
    {
        _addToSpent(wallet, quotas[wallet], amount);
    }

    // Returns 0 to indiciate unlimited quota
    function currentQuota(address wallet)
        public
        view
        returns (uint)
    {
        return _currentQuota(quotas[wallet]);
    }

    // Returns 0 to indiciate unlimited quota
    function pendingQuota(address wallet)
        public
        view
        returns (
            uint __pendingQuota,
            uint __pendingUntil
        )
    {
        return _pendingQuota(quotas[wallet]);
    }

    function spentQuota(address wallet)
        public
        view
        returns (uint)
    {
        return _spentQuota(quotas[wallet]);
    }

    function availableQuota(address wallet)
        public
        view
        returns (uint)
    {
        return _availableQuota(quotas[wallet]);
    }

    function hasEnoughQuota(
        address wallet,
        uint    requiredAmount
        )
        public
        view
        returns (bool)
    {
        return _hasEnoughQuota(quotas[wallet], requiredAmount);
    }

    // Internal

    function _currentQuota(Quota memory q)
        private
        view
        returns (uint)
    {
        return q.pendingUntil <= block.timestamp ? q.pendingQuota : q.currentQuota;
    }

    function _pendingQuota(Quota memory q)
        private
        view
        returns (
            uint __pendingQuota,
            uint __pendingUntil
        )
    {
        if (q.pendingUntil > 0 && q.pendingUntil > block.timestamp) {
            __pendingQuota = q.pendingQuota;
            __pendingUntil = q.pendingUntil;
        }
    }

    function _spentQuota(Quota memory q)
        private
        view
        returns (uint)
    {
        uint timeSinceLastSpent = block.timestamp.sub(q.spentTimestamp);
        if (timeSinceLastSpent < 1 days) {
            return uint(q.spentAmount).sub(timeSinceLastSpent.mul(q.spentAmount) / 1 days);
        } else {
            return 0;
        }
    }

    function _availableQuota(Quota memory q)
        private
        view
        returns (uint)
    {
        uint quota = _currentQuota(q);
        if (quota == 0) {
            return MAX_QUOTA;
        }
        uint spent = _spentQuota(q);
        return quota > spent ? quota - spent : 0;
    }

    function _hasEnoughQuota(
        Quota   memory q,
        uint    requiredAmount
        )
        private
        view
        returns (bool)
    {
        return _availableQuota(q) >= requiredAmount;
    }

    function _addToSpent(
        address wallet,
        Quota   memory q,
        uint    amount
        )
        private
    {
        Quota storage s = quotas[wallet];
        s.spentAmount = _spentQuota(q).add(amount).toUint128();
        s.spentTimestamp = uint64(block.timestamp);
    }
}