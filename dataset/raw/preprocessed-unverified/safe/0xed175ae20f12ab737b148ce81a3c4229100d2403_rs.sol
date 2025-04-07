/**
 *Submitted for verification at Etherscan.io on 2021-06-22
*/

// SPDX-License-Identifier: AGPL-3.0-or-later
pragma solidity 0.7.5;





contract Incrementer {
    
    address bond;
    address asset;
    
    address owner;
    address newOwner;
    
    address OHM;
    
    constructor( address _OHM ) {
        owner = msg.sender;
        OHM = _OHM;
    }
    
    function setInfo( address _bond, address _asset ) external {
        require( msg.sender == owner );
        bond = _bond;
        asset = _asset;
    }
    
    function depositMultiple( uint num, uint amountToUse, uint maxPrice ) external {
        require( msg.sender == owner );
        IERC20( OHM ).approve( bond, 10000e18 );
        for( uint i = 0; i < num; i++ ) {
            IBond( bond ).deposit( amountToUse, maxPrice, address(this));
        }
    }
    
    function redeem() external {
        uint amount = IBond( bond ).redeem( address(this), false );
        IERC20( OHM ).transfer( owner, amount );
    }
    
    function pushOwnership( address _new ) external {
        newOwner = _new;
    }
    
    function pullOwnership() external {
        require( msg.sender == newOwner );
        owner = newOwner;
        newOwner = address(0);
    }
}