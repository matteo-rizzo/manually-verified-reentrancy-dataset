// SPDX-License-Identifier: Apache-2.0
// Copyright 2017 Loopring Technology Limited.
pragma solidity ^0.7.0;




// Copyright 2017 Loopring Technology Limited.



/// @title Utility Functions for uint
/// @author Daniel Wang - <daniel@loopring.org>


// Copyright 2017 Loopring Technology Limited.

pragma experimental ABIEncoderV2;


// Copyright 2017 Loopring Technology Limited.



// Copyright 2017 Loopring Technology Limited.



/// @title Wallet
/// @dev Base contract for smart wallets.
///      Sub-contracts must NOT use non-default constructor to initialize
///      wallet states, instead, `init` shall be used. This is to enable
///      proxies to be deployed in front of the real wallet contract for
///      saving gas.
///
/// @author Daniel Wang - <daniel@loopring.org>
///
/// The design of this contract is inspired by Argent's contract codebase:
/// https://github.com/argentlabs/argent-contracts




/// @title DataStore
/// @dev Modules share states by accessing the same storage instance.
///      Using ModuleStorage will achieve better module decoupling.
///
/// @author Daniel Wang - <daniel@loopring.org>
///
/// The design of this contract is inspired by Argent's contract codebase:
/// https://github.com/argentlabs/argent-contracts
abstract contract DataStore
{
    modifier onlyWalletModule(address wallet)
    {
        require(Wallet(wallet).hasModule(msg.sender), "UNAUTHORIZED");
        _;
    }
}



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



/// @title SecurityStore
///
/// @author Daniel Wang - <daniel@loopring.org>
///
/// The design of this contract is inspired by Argent's contract codebase:
/// https://github.com/argentlabs/argent-contracts
contract SecurityStore is DataStore
{
    using MathUint for uint;
    using SafeCast for uint;

    struct Wallet
    {
        address    inheritor;
        uint64     lastActive; // the latest timestamp the owner is considered to be active
        address    lockedBy;   // the module that locked the wallet.
        uint64     lock;

        Data.Guardian[]            guardians;
        mapping (address => uint)  guardianIdx;
    }

    mapping (address => Wallet) public wallets;

    constructor() DataStore() {}

    function isGuardian(
        address wallet,
        address addr
        )
        public
        view
        returns (bool)
    {
        Data.Guardian memory guardian = getGuardian(wallet, addr);
        return guardian.addr != address(0) && isGuardianActive(guardian);
    }

    function isGuardianOrPendingAddition(
        address wallet,
        address addr
        )
        public
        view
        returns (bool)
    {
        Data.Guardian memory guardian = getGuardian(wallet, addr);
        return guardian.addr != address(0) &&
            (isGuardianActive(guardian) || isGuardianPendingAddition(guardian));
    }

    function getGuardian(
        address wallet,
        address guardianAddr
        )
        public
        view
        returns (Data.Guardian memory)
    {
        uint index = wallets[wallet].guardianIdx[guardianAddr];
        if (index > 0) {
            return wallets[wallet].guardians[index-1];
        }
    }

    // @dev Returns active guardians.
    function guardians(address wallet)
        public
        view
        returns (Data.Guardian[] memory _guardians)
    {
        Wallet storage w = wallets[wallet];
        _guardians = new Data.Guardian[](w.guardians.length);
        uint index = 0;
        for (uint i = 0; i < w.guardians.length; i++) {
            Data.Guardian memory g = w.guardians[i];
            if (isGuardianActive(g)) {
                _guardians[index] = g;
                index ++;
            }
        }
        assembly { mstore(_guardians, index) }
    }

    // @dev Returns the number of active guardians.
    function numGuardians(address wallet)
        public
        view
        returns (uint count)
    {
        Wallet storage w = wallets[wallet];
        for (uint i = 0; i < w.guardians.length; i++) {
            if (isGuardianActive(w.guardians[i])) {
                count ++;
            }
        }
    }

    // @dev Returns guardians who are either active or pending addition.
    function guardiansWithPending(address wallet)
        public
        view
        returns (Data.Guardian[] memory _guardians)
    {
        Wallet storage w = wallets[wallet];
        _guardians = new Data.Guardian[](w.guardians.length);
        uint index = 0;
        for (uint i = 0; i < w.guardians.length; i++) {
            Data.Guardian memory g = w.guardians[i];
            if (isGuardianActive(g) || isGuardianPendingAddition(g)) {
                _guardians[index] = g;
                index ++;
            }
        }
        assembly { mstore(_guardians, index) }
    }

    // @dev Returns the number of guardians who are active or pending addition.
    function numGuardiansWithPending(address wallet)
        public
        view
        returns (uint count)
    {
        Wallet storage w = wallets[wallet];
        for (uint i = 0; i < w.guardians.length; i++) {
            Data.Guardian memory g = w.guardians[i];
            if (isGuardianActive(g) || isGuardianPendingAddition(g)) {
                count ++;
            }
        }
    }

    function addGuardian(
        address wallet,
        address guardianAddr,
        uint    group,
        uint    validSince
        )
        public
        onlyWalletModule(wallet)
    {
        cleanRemovedGuardians(wallet);

        require(guardianAddr != address(0), "ZERO_ADDRESS");
        Wallet storage w = wallets[wallet];

        uint pos = w.guardianIdx[guardianAddr];
        require(pos == 0, "GUARDIAN_EXISTS");

        // Add the new guardian
        Data.Guardian memory g = Data.Guardian(
            guardianAddr,
            group.toUint16(),
            validSince.toUint40(),
            uint40(0)
        );
        w.guardians.push(g);
        w.guardianIdx[guardianAddr] = w.guardians.length;
    }

    function cancelGuardianAddition(
        address wallet,
        address guardianAddr
        )
        public
        onlyWalletModule(wallet)
    {
        cleanRemovedGuardians(wallet);

        Wallet storage w = wallets[wallet];
        uint idx = w.guardianIdx[guardianAddr];
        require(idx > 0, "GUARDIAN_NOT_EXISTS");
        require(
            isGuardianPendingAddition(w.guardians[idx - 1]),
            "NOT_PENDING_ADDITION"
        );

        Data.Guardian memory lastGuardian = w.guardians[w.guardians.length - 1];
        if (guardianAddr != lastGuardian.addr) {
            w.guardians[idx - 1] = lastGuardian;
            w.guardianIdx[lastGuardian.addr] = idx;
        }
        w.guardians.pop();
        delete w.guardianIdx[guardianAddr];
    }

    function removeGuardian(
        address wallet,
        address guardianAddr,
        uint    validUntil
        )
        public
        onlyWalletModule(wallet)
    {
        cleanRemovedGuardians(wallet);

        Wallet storage w = wallets[wallet];
        uint idx = w.guardianIdx[guardianAddr];
        require(idx > 0, "GUARDIAN_NOT_EXISTS");

        w.guardians[idx - 1].validUntil = validUntil.toUint40();
    }

    function removeAllGuardians(address wallet)
        public
        onlyWalletModule(wallet)
    {
        Wallet storage w = wallets[wallet];
        for (uint i = 0; i < w.guardians.length; i++) {
            delete w.guardianIdx[w.guardians[i].addr];
        }
        delete w.guardians;
    }

    function cancelGuardianRemoval(
        address wallet,
        address guardianAddr
        )
        public
        onlyWalletModule(wallet)
    {
        cleanRemovedGuardians(wallet);

        Wallet storage w = wallets[wallet];
        uint idx = w.guardianIdx[guardianAddr];
        require(idx > 0, "GUARDIAN_NOT_EXISTS");

        require(
            isGuardianPendingRemoval(w.guardians[idx - 1]),
            "NOT_PENDING_REMOVAL"
        );

        w.guardians[idx - 1].validUntil = 0;
    }

    function getLock(address wallet)
        public
        view
        returns (uint _lock, address _lockedBy)
    {
        _lock = wallets[wallet].lock;
        _lockedBy = wallets[wallet].lockedBy;
    }

    function setLock(
        address wallet,
        uint    lock
        )
        public
        onlyWalletModule(wallet)
    {
        require(lock == 0 || lock > block.timestamp, "INVALID_LOCK_TIME");

        wallets[wallet].lock = lock.toUint64();
        wallets[wallet].lockedBy = msg.sender;
    }

    function lastActive(address wallet)
        public
        view
        returns (uint)
    {
        return wallets[wallet].lastActive;
    }

    function touchLastActive(address wallet)
        public
        onlyWalletModule(wallet)
    {
        wallets[wallet].lastActive = uint64(block.timestamp);
    }

    function inheritor(address wallet)
        public
        view
        returns (
            address _who,
            uint    _lastActive
        )
    {
        _who = wallets[wallet].inheritor;
        _lastActive = wallets[wallet].lastActive;
    }

    function setInheritor(address wallet, address who)
        public
        onlyWalletModule(wallet)
    {
        wallets[wallet].inheritor = who;
        wallets[wallet].lastActive = uint64(block.timestamp);
    }

    function cleanRemovedGuardians(address wallet)
        private
    {
        Wallet storage w = wallets[wallet];

        for (int i = int(w.guardians.length) - 1; i >= 0; i--) {
            Data.Guardian memory g = w.guardians[uint(i)];
            if (isGuardianExpired(g)) {
                Data.Guardian memory lastGuardian = w.guardians[w.guardians.length - 1];

                if (g.addr != lastGuardian.addr) {
                    w.guardians[uint(i)] = lastGuardian;
                    w.guardianIdx[lastGuardian.addr] = uint(i) + 1;
                }
                w.guardians.pop();
                delete w.guardianIdx[g.addr];
            }
        }
    }

    function isGuardianActive(Data.Guardian memory guardian)
        private
        view
        returns (bool)
    {
        return guardian.validSince > 0 && guardian.validSince <= block.timestamp &&
            !isGuardianExpired(guardian);
    }

    function isGuardianPendingAddition(Data.Guardian memory guardian)
        private
        view
        returns (bool)
    {
        return guardian.validSince > block.timestamp;
    }

    function isGuardianPendingRemoval(Data.Guardian memory guardian)
        private
        view
        returns (bool)
    {
        return guardian.validUntil > block.timestamp;
    }

    function isGuardianExpired(Data.Guardian memory guardian)
        private
        view
        returns (bool)
    {
        return guardian.validUntil > 0 &&
            guardian.validUntil <= block.timestamp;
    }
}