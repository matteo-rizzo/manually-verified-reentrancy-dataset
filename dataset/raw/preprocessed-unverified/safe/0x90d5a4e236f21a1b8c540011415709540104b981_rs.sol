/**
 *Submitted for verification at Etherscan.io on 2019-10-21
*/

pragma solidity ^0.5.0;








contract SetRateMinter is Ownable {
    IManager public _registry;

    constructor(address registry) public {
        _registry = IManager(registry);
    }

    
    function mintSupply(address src20, address swmAccount, uint256 swmValue, uint256 src20Value)
    external
    onlyOwner
    returns (bool)
    {
        require(_registry.mintSupply(src20, swmAccount, swmValue, src20Value), 'supply minting failed');

        return true;
    }
}