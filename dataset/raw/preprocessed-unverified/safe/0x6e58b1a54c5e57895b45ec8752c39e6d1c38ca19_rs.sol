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
    
    // Set total supply cap
    mapping (address=>uint256) clap;

    constructor (address owner, address token, uint256 supply) public {
        managers.pushAddress(owner);
        clap[token] = supply;
        emit addManager(owner);
    }

    modifier ownerOnly() {
        require(managers.exists(msg.sender));
        _;
    }

    function createManager(address manager) external ownerOnly {
        managers.pushAddress(manager);
        emit addManager(manager);
    }

    function rmManager(address manager) external ownerOnly {
        managers.removeAddress(manager);
        emit delManager(manager);
    }

    function mint(address token, address to, uint256 amount) external ownerOnly returns(bool) {
        if (clap[token]>0) {
            require(clap[token]>Minter(token).totalSupply());
        }
        Minter(token).mint(to, amount);
        return true;
    }

    function migrate(address token, address to, bool minter) external ownerOnly {
        if (minter) {
            Minter(token).changeMinter(to);
        } else {
            Minter(token).changeOwner(to);
        }
    }
    
    function addClap(address token, uint256 supply) external ownerOnly {
        clap[token] = supply;
    }

    function listManagers() public view returns(address[] memory) {
        return managers.getAllAddresses();
    }
}