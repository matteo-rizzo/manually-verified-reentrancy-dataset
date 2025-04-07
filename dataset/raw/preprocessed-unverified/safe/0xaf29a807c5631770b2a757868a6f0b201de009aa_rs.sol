/**
 *Submitted for verification at Etherscan.io on 2020-11-08
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.6.0;





contract Manager {
    using AddrArrayLib for AddrArrayLib.Addresses;
    AddrArrayLib.Addresses managers;
    
    event addManager(address manager);
    event delManager(address manager);

    constructor (address owner) public {
        managers.pushAddress(owner);
        emit addManager(owner);
    }

    modifier ownerOnly() {
        require(managers.exists(msg.sender));
        _;
    }

    function createManager(address manager) public ownerOnly {
        managers.pushAddress(manager);
        emit addManager(manager);
    }

    function rmManager(address manager) public ownerOnly {
        managers.removeAddress(manager);
        emit delManager(manager);
    }

    function mint(address token, address to, uint256 amount) public ownerOnly returns(bool) {
        Minter(token).mint(to, amount);
        return true;
    }

    function migrate(address token, address to, bool minter) public ownerOnly {
        if (minter) {
            Minter(token).changeMinter(to);
        } else {
            Minter(token).changeOwner(to);
        }
    }

    function listManagers() public view returns(address[] memory) {
        return managers.getAllAddresses();
    }
}