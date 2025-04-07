pragma solidity ^0.4.17;

// ----------------------------------------------------------------------------
// Devery Presale Whitelist
//
// Deployed to : 0x38E330C4330e743a4D82D93cdC826bAe78C6E7A6
//
// Enjoy.
//
// (c) BokkyPooBah / Bok Consulting Pty Ltd for Devery 2017. The MIT Licence.
// ----------------------------------------------------------------------------


// ----------------------------------------------------------------------------
// Owned contract
// ----------------------------------------------------------------------------



// ----------------------------------------------------------------------------
// Administrators
// ----------------------------------------------------------------------------
contract Admined is Owned {

    // ------------------------------------------------------------------------
    // Mapping of administrators
    // ------------------------------------------------------------------------
    mapping (address => bool) public admins;

    // ------------------------------------------------------------------------
    // Add and delete adminstrator events
    // ------------------------------------------------------------------------
    event AdminAdded(address addr);
    event AdminRemoved(address addr);


    // ------------------------------------------------------------------------
    // Modifier for functions that can only be executed by adminstrator
    // ------------------------------------------------------------------------
    modifier onlyAdmin() {
        require(admins[msg.sender] || owner == msg.sender);
        _;
    }


    // ------------------------------------------------------------------------
    // Owner can add a new administrator
    // ------------------------------------------------------------------------
    function addAdmin(address addr) public onlyOwner {
        admins[addr] = true;
        AdminAdded(addr);
    }


    // ------------------------------------------------------------------------
    // Owner can remove an administrator
    // ------------------------------------------------------------------------
    function removeAdmin(address addr) public onlyOwner {
        delete admins[addr];
        AdminRemoved(addr);
    }
}


// ----------------------------------------------------------------------------
// Devery Presale Whitelist
// ----------------------------------------------------------------------------
contract DeveryPresaleWhitelist is Admined {

    // ------------------------------------------------------------------------
    // Administrators can add until sealed
    // ------------------------------------------------------------------------
    bool public sealed;

    // ------------------------------------------------------------------------
    // The whitelist of accounts and max contribution
    // ------------------------------------------------------------------------
    mapping(address => uint) public whitelist;

    // ------------------------------------------------------------------------
    // Events
    // ------------------------------------------------------------------------
    event Whitelisted(address indexed addr, uint max);


    // ------------------------------------------------------------------------
    // Constructor
    // ------------------------------------------------------------------------
    function DeveryPresaleWhitelist() public {
    }


    // ------------------------------------------------------------------------
    // Add to whitelist
    // ------------------------------------------------------------------------
    function add(address addr, uint max) public onlyAdmin {
        require(!sealed);
        require(addr != 0x0);
        whitelist[addr] = max;
        Whitelisted(addr, max);
    }


    // ------------------------------------------------------------------------
    // Add batch to whitelist
    // ------------------------------------------------------------------------
    function multiAdd(address[] addresses, uint[] max) public onlyAdmin {
        require(!sealed);
        require(addresses.length != 0);
        require(addresses.length == max.length);
        for (uint i = 0; i < addresses.length; i++) {
            require(addresses[i] != 0x0);
            whitelist[addresses[i]] = max[i];
            Whitelisted(addresses[i], max[i]);
        }
    }


    // ------------------------------------------------------------------------
    // After sealing, no more whitelisting is possible
    // ------------------------------------------------------------------------
    function seal() public onlyOwner {
        require(!sealed);
        sealed = true;
    }


    // ------------------------------------------------------------------------
    // Don&#39;t accept ethers - no payable modifier
    // ------------------------------------------------------------------------
    function () public {
    }
}