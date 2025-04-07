/**
 *Submitted for verification at Etherscan.io on 2021-06-29
*/

/**
 *Submitted for verification at Etherscan.io on 2021-06-03
*/

/**
 *Submitted for verification at Etherscan.io on 2021-04-14
*/

// SPDX-License-Identifier: AGPL-3.0-or-later\
pragma solidity 0.7.5;

/**
 * @title SafeERC20
 * @dev Wrappers around ERC20 operations that throw on failure (when the token
 * contract returns false). Tokens that return no value (and instead revert or
 * throw on failure) are also supported, non-reverting calls are assumed to be
 * successful.
 * To use this library you can add a `using SafeERC20 for IERC20;` statement to your contract,
 * which allows you to call the safe operations as `token.safeTransfer(...)`, etc.
 */


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
 * @dev Collection of functions related to the address type
 */


/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
 */








/**
 *  Exercise contract for unapproved sellers prior to migrating pOLY.
 *  It is not possible for a user to use both (no double dipping).
 */
contract AltExercisepOLY {
    using SafeMath for uint;
    using SafeERC20 for IERC20;
    
    address owner;
    address newOwner;
    
    address immutable pOLY;
    address immutable OHM;
    address immutable DAI;
    address immutable treasury;
    address immutable circulatingOHMContract;
    
    struct Term {
        uint percent; // 4 decimals ( 5000 = 0.5% )
        uint claimed;
        uint max;
    }
    mapping( address => Term ) public terms;
    
    mapping( address => address ) public walletChange;
    
    constructor( address _pOLY, address _ohm, address _dai, address _treasury, address _circulatingOHMContract ) {
        owner = msg.sender;
        require( _pOLY != address(0) );
        pOLY = _pOLY;
        require( _ohm != address(0) );
        OHM = _ohm;
        require( _dai != address(0) );
        DAI = _dai;
        require( _treasury != address(0) );
        treasury = _treasury;
        require( _circulatingOHMContract != address(0) );
        circulatingOHMContract = _circulatingOHMContract;
    }
    
    // Sets terms for a new wallet
    function setTerms(address _vester, uint _rate, uint _claimed, uint _max ) external {
        require( msg.sender == owner, "Sender is not owner" );
        require( _max >= terms[ _vester ].max, "cannot lower amount claimable" );
        require( _rate >= terms[ _vester ].percent, "cannot lower vesting rate" );
        require( _claimed >= terms[ _vester ].claimed, "cannot lower claimed" );
        require( !IPOLY( pOLY ).isApprovedSeller( _vester ) );

        terms[ _vester ] = Term({
            percent: _rate,
            claimed: _claimed,
            max: _max
        });
    }

    // Allows wallet to redeem pOLY for OHM
    function exercise( uint _amount ) external {
        Term memory info = terms[ msg.sender ];
        require( redeemable( info ) >= _amount, 'Not enough vested' );
        require( info.max.sub( info.claimed ) >= _amount, 'Claimed over max' );

        IERC20( DAI ).safeTransferFrom( msg.sender, address(this), _amount );
        IERC20( pOLY ).safeTransferFrom( msg.sender, address(this), _amount );
        
        IERC20( DAI ).approve( treasury, _amount );
        uint OHMToSend = ITreasury( treasury ).deposit( _amount, DAI, 0 );

        terms[ msg.sender ].claimed = info.claimed.add( _amount );

        IERC20( OHM ).safeTransfer( msg.sender, OHMToSend );
    }
    
    // Allows wallet owner to transfer rights to a new address
    function pushWalletChange( address _newWallet ) external {
        require( terms[ msg.sender ].percent != 0 );
        walletChange[ msg.sender ] = _newWallet;
    }
    
    // Allows wallet to pull rights from an old address
    function pullWalletChange( address _oldWallet ) external {
        require( walletChange[ _oldWallet ] == msg.sender, "wallet did not push" );
        
        walletChange[ _oldWallet ] = address(0);
        terms[ msg.sender ] = terms[ _oldWallet ];
        delete terms[ _oldWallet ];
    }

    // Amount a wallet can redeem based on current supply
    function redeemableFor( address _vester ) public view returns (uint) {
        return redeemable( terms[ _vester ]);
    }
    
    function redeemable( Term memory _info ) internal view returns ( uint ) {
        return ( ICirculatingOHM( circulatingOHMContract ).OHMCirculatingSupply().mul( _info.percent ).mul( 1000 ) ).sub( _info.claimed );
    }

    function pushOwnership( address _newOwner ) external returns ( bool ) {
        require( msg.sender == owner, "Sender is not owner" );
        require( _newOwner != address(0) );
        newOwner = _newOwner;
        return true;
    }
    
    function pullOwnership() external returns ( bool ) {
        require( msg.sender == newOwner );
        owner = newOwner;
        newOwner = address(0);
        return true;
    }
}