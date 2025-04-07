/**
 *Submitted for verification at Etherscan.io on 2019-06-13
*/

pragma solidity ^0.5.3;





contract WhitelistTransferPolicy is ITransferPolicy, Ownable {
    mapping (address => bool) private whitelist;

    event AddressWhitelisted(address address_);
    event AddressUnwhitelisted(address address_);

    constructor() Ownable() public {}

    function isTransferPossible(address from, address to, uint256) public view returns (bool) {
        return (whitelist[from] && whitelist[to]);
    }

    function isBehalfTransferPossible(address sender, address from, address to, uint256) public view returns (bool) {
        return (whitelist[from] && whitelist[to] && whitelist[sender]);
    }

    function isWhitelisted(address address_) public view returns (bool) {
        return whitelist[address_];
    }

    function unwhitelistAddress(address address_) public onlyOwner returns (bool) {
        removeFromWhitelist(address_);
        return true;
    }

    function whitelistAddress(address address_) public onlyOwner returns (bool) {
        addToWhitelist(address_);
        return true;
    }

    function whitelistAddresses(address[] memory addresses) public onlyOwner returns (bool) {
        uint256 len = addresses.length;
        for (uint256 i; i < len; i++) {
            addToWhitelist(addresses[i]);
        }
        return true;
    }

    function unwhitelistAddresses(address[] memory addresses) public onlyOwner returns (bool) {
        uint256 len = addresses.length;
        for (uint256 i; i < len; i++) {
            removeFromWhitelist(addresses[i]);
        }
        return true;
    }

    function addToWhitelist(address address_) internal {
        whitelist[address_] = true;
        emit AddressWhitelisted(address_);
    }


    function removeFromWhitelist(address address_) internal {
        whitelist[address_] = false;
        emit AddressUnwhitelisted(address_);
    }
}