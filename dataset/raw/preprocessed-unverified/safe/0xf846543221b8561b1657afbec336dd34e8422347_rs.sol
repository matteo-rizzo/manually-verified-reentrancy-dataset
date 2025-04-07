/**
 *Submitted for verification at Etherscan.io on 2019-07-17
*/

pragma solidity >=0.5.10; 








contract KyberRateTrigger {

    uint public index;
    
    KyberNetworkInterface networkContract = KyberNetworkInterface(0x65897aDCBa42dcCA5DD162c647b1cC3E31238490);
    
    constructor(KyberNetworkInterface _networkContract) public {
        networkContract = _networkContract;
    }
    
    function callGetExpectedRate(ERC20 src, ERC20 dest, uint srcQty) public
        returns (uint expectedRate, uint slippageRate) 
    {
        ++index;
        return networkContract.getExpectedRate(src, dest, srcQty);            
    } 
    
    function callSearchBestRate(ERC20 src, ERC20 dest, uint srcQty, bool usePermissionless) public
        returns(address, uint)
    {
        ++index;
        return networkContract.searchBestRate(src, dest, srcQty, usePermissionless);            
    } 
}