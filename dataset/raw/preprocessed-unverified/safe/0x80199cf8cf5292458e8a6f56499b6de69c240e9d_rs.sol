pragma solidity ^0.4.18;

/// @title Ownable contract


/// @title Mortal contract - used to selfdestruct once we have no use of this contract
contract Mortal is Ownable {
    function executeSelfdestruct() onlyOwner {
        selfdestruct(owner);
    }
}

/// @title CCWhitelist contract
contract CCWhitelist is Mortal {
    
    mapping (address => bool) public whitelisted;

    /// @dev Whitelist a single address
    /// @param addr Address to be whitelisted
    function whitelist(address addr) public onlyOwner {
        require(!whitelisted[addr]);
        whitelisted[addr] = true;
    }

    /// @dev Remove an address from whitelist
    /// @param addr Address to be removed from whitelist
    function unwhitelist(address addr) public onlyOwner {
        require(whitelisted[addr]);
        whitelisted[addr] = false;
    }

    /// @dev Whitelist array of addresses
    /// @param arr Array of addresses to be whitelisted
    function bulkWhitelist(address[] arr) public onlyOwner {
        for (uint i = 0; i < arr.length; i++) {
            whitelisted[arr[i]] = true;
        }
    }

    /// @dev Check if address is whitelisted
    /// @param addr Address to be checked if it is whitelisted
    /// @return Is address whitelisted?
    function isWhitelisted(address addr) public constant returns (bool) {
        return whitelisted[addr];
    }   

}