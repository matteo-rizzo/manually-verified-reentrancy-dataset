/**
 *Submitted for verification at Etherscan.io on 2021-04-14
*/

// SPDX-License-Identifier: AGPL-3.0-or-later\
pragma solidity 0.7.5;

/**
 * @dev Wrappers over Solidity's arithmetic operations with added overflow
 * checks.
 *
 * Arithmetic operations in Solidity wrap on overflow. This can easily result
 * in bugs, because programmers usually assume that an overflow raises an
 * error, which is the standard behavior in high level programming languages.
 * `SafeMath` restores this intuition by reverting the transaction when an
 * operation overflows.
 *
 * Using this library instead of the unchecked operations eliminates an entire
 * class of bugs, so it's recommended to use it always.
 */


/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
 */


contract OHMCirculatingSupplyConrtact {
    using SafeMath for uint;

    bool public isInitialized;

    address public OHM;
    address public owner;
    address[] public nonCirculatingOHMAddresses;

    constructor( address _owner ) {        
        owner = _owner;
    }

    function initialize( address _ohm ) external returns ( bool ) {
        require( msg.sender == owner, "caller is not owner" );
        require( isInitialized == false );

        OHM = _ohm;

        isInitialized = true;

        return true;
    }

    function OHMCirculatingSupply() external view returns ( uint ) {
        uint _totalSupply = IERC20( OHM ).totalSupply();

        uint _circulatingSupply = _totalSupply.sub( getNonCirculatingOHM() );

        return _circulatingSupply;
    }

    function getNonCirculatingOHM() public view returns ( uint ) {
        uint _nonCirculatingOHM;

        for( uint i=0; i < nonCirculatingOHMAddresses.length; i = i.add( 1 ) ) {
            _nonCirculatingOHM = _nonCirculatingOHM.add( IERC20( OHM ).balanceOf( nonCirculatingOHMAddresses[i] ) );
        }

        return _nonCirculatingOHM;
    }

    function setNonCirculatingOHMAddresses( address[] calldata _nonCirculatingAddresses ) external returns ( bool ) {
        require( msg.sender == owner, "Sender is not owner" );
        nonCirculatingOHMAddresses = _nonCirculatingAddresses;

        return true;
    }

    function transferOwnership( address _owner ) external returns ( bool ) {
        require( msg.sender == owner, "Sender is not owner" );

        owner = _owner;

        return true;
    }
}