// SPDX-License-Identifier: Apache-2.0
// Copyright 2017 Loopring Technology Limited.
pragma solidity ^0.7.0;


/// @title Utility Functions for uint
/// @author Daniel Wang - <daniel@loopring.org>


// Copyright 2017 Loopring Technology Limited.



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



/// @title HashStore
/// @dev This store maintains all hashes for SignedRequest.
contract HashStore is DataStore
{
    // wallet => hash => consumed
    mapping(address => mapping(bytes32 => bool)) public hashes;

    constructor() {}

    function verifyAndUpdate(address wallet, bytes32 hash)
        public
        onlyWalletModule(wallet)
    {
        require(!hashes[wallet][hash], "HASH_EXIST");
        hashes[wallet][hash] = true;
    }
}