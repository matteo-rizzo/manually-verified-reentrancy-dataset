/**
 *Submitted for verification at Etherscan.io on 2021-06-03
*/

//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

// ----------------------------------------------------------------------------
// Beeeef Registry
//
// https://github.com/bokkypoobah/BeeeefRegistry
//
// Deployed to 0xbEEeEfffE871CE4b6aEAc8717194913f2bc27577
//
// Enjoy.
//
// (c) BokkyPooBah / Bok Consulting Pty Ltd 2021. The MIT Licence.
// ----------------------------------------------------------------------------


contract Curated {
    address public curator;

    event CuratorTransferred(address indexed from, address indexed to);

    modifier onlyCurator {
        require(msg.sender == curator);
        _;
    }

    constructor() {
        curator = msg.sender;
    }
    function transferCurator(address _curator) public onlyCurator {
        emit CuratorTransferred(curator, _curator);
        curator = _curator;
    }
}


enum Permission { None, View, ComposeWith, Permission3, Permission4, Permission5, Permission6, Permission7 }
enum Curation { None, LoadByDefault, DisableView, DisableComposeWith, Curation4, Curation5, Curation6, Curation7 }





contract BeeeefRegistry is Curated {
    using Entries for Entries.Data;
    using Entries for Entries.Entry;

    Entries.Data private entries;

    event EntryAdded(bytes32 key, address account, address token, uint permission);
    event EntryRemoved(bytes32 key, address account, address token);
    event EntryUpdated(bytes32 key, address account, address token, uint permission);
    event EntryCurated(bytes32 key, address account, address token, Curation curation);

    constructor() {
        entries.init();
    }

    function addEntry(address token, Permission permission) public {
        entries.add(msg.sender, token, permission);
    }
    function removeEntry(address token) public {
        entries.remove(msg.sender, token);
    }
    function updateEntry(address token, Permission permission) public {
        entries.update(msg.sender, token, permission);
    }
    function curateEntry(address account, address token, Curation curation) public onlyCurator {
        entries.curate(account, token, curation);
    }

    function entriesLength() public view returns (uint) {
        return entries.length();
    }
    function getEntryByIndex(uint i) public view returns (address _account, address _token, Permission _permission) {
        require(i < entries.length(), "getEntryByIndex: Invalid index");
        Entries.Entry memory entry = entries.entries[entries.index[i]];
        return (entry.account, entry.token, entry.permission);
    }
    function getEntries() public view returns (address[] memory accounts, address[] memory tokens, Permission[] memory permissions, Curation[] memory curations) {
        uint length = entries.length();
        accounts = new address[](length);
        tokens = new address[](length);
        permissions = new Permission[](length);
        curations = new Curation[](length);
        for (uint i = 0; i < length; i++) {
            Entries.Entry memory entry = entries.entries[entries.index[i]];
            accounts[i] = entry.account;
            tokens[i] = entry.token;
            permissions[i] = entry.permission;
            curations[i] = entry.curation;
        }
    }
}