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











contract NewExercisePOLY {
    using SafeMath for uint;
    using SafeERC20 for IERC20;

    // in hundreths i.e. 50 = 0.5%
    mapping( address => uint ) public percentCanVest;
    mapping( address => uint ) public amountClaimed;
    mapping( address => uint ) public maxAllowedToClaim;

    bool public isInitialized;
    bool public hasMigrated;
    bool public usingNewVault;
 
    address public pOLY;
    address public OHM;
    address public DAI;
    address public owner;

    address public treasury;
    address public newTreasury;
    address public previousClaimContract;
    address public circulatingOHMContract;

    constructor( address _owner ) {        
        owner = _owner;
    }

    function initialize( address _pOLY, address _ohm, address _dai, address _treasury, address _previousClaimContract, address _circulatingOHMContract ) external returns ( bool ) {
        require( msg.sender == owner, "caller is not owner" );
        require( isInitialized == false );

        pOLY = _pOLY;
        OHM = _ohm;
        DAI = _dai;
        treasury = _treasury;
        previousClaimContract = _previousClaimContract;
        circulatingOHMContract = _circulatingOHMContract;

        isInitialized = true;

        return true;
    }

    // Migrates terms from old redemption contract
    function migrate( address[] calldata _addresses ) external returns ( bool ) {
        require( msg.sender == owner, "Sender is not owner" );
        require( !hasMigrated, "Already migrated" );

        for( uint i = 0; i < _addresses.length; i++ ) {
            percentCanVest[ _addresses[i] ] = IOldClaimContract( previousClaimContract ).percentCanVest( _addresses[i] );
            amountClaimed[ _addresses[i] ] = IOldClaimContract( previousClaimContract ).amountClaimed( _addresses[i] );
            maxAllowedToClaim[ _addresses[i] ] = IOldClaimContract( previousClaimContract ).maxAllowedToClaim( _addresses[i] );
        }
        
        hasMigrated = true;

        return true;
    }
    
    // Sets terms for a new wallet
    function setTerms(address _vester, uint _amountCanClaim, uint _rate ) external returns ( bool ) {
        require( msg.sender == owner, "Sender is not owner" );
        require( _amountCanClaim >= maxAllowedToClaim[ _vester ], "cannot lower amount claimable" );
        require( _rate >= percentCanVest[ _vester ], "cannot lower vesting rate" );

        if( maxAllowedToClaim[ _vester ] == 0 ) {
            amountClaimed[ _vester ] = IOldClaimContract( previousClaimContract ).amountClaimed( _vester );
        } 

        maxAllowedToClaim[ _vester ] = _amountCanClaim;
        percentCanVest[ _vester ] = _rate;

        return true;
    }

    // Allows wallet to exercise pOLY to claim OHM
    function exercisePOLY( uint _amountToExercise ) external returns ( bool ) {
        require( getPOLYAbleToClaim( msg.sender ).sub( _amountToExercise ) >= 0, 'Not enough OHM vested' );
        require( maxAllowedToClaim[ msg.sender ].sub( amountClaimed[ msg.sender ] ).sub( _amountToExercise ) >= 0, 'Claimed over max' );

        IERC20( DAI ).safeTransferFrom( msg.sender, address( this ), _amountToExercise );
        IERC20( DAI ).approve( treasury, _amountToExercise );

        if( !usingNewVault ) {
            IVaultOld( treasury ).depositReserves( _amountToExercise );
        } else {
            IVaultNew( newTreasury ).depositReserves( _amountToExercise, DAI );
        }

        IPOLY( pOLY ).burnFrom( msg.sender, _amountToExercise );

        amountClaimed[ msg.sender ] = amountClaimed[ msg.sender ].add( _amountToExercise );

        uint _amountOHMToSend = _amountToExercise.div( 1e9 );

        IERC20( OHM ).safeTransfer( msg.sender, _amountOHMToSend );

        return true;
    }
    
    // Allows wallet owner to transfer rights to a new address
    function changeWallets( address _oldWallet, address _newWallet ) external returns ( bool ) {
        require( msg.sender == _oldWallet, "Only the wallet owner can change wallets" );
        
        maxAllowedToClaim[ _newWallet ] = maxAllowedToClaim[ _oldWallet ];
        maxAllowedToClaim[ _oldWallet ] = 0;
        
        amountClaimed[ _newWallet ] = amountClaimed[ _oldWallet ];
        amountClaimed[ _oldWallet ] = 0;
        
        percentCanVest[ _newWallet ] = percentCanVest[ _oldWallet ];
        percentCanVest[ _oldWallet ] = 0;
        
        return true;
    }

    function getPOLYAbleToClaim( address _vester ) public view returns (uint) {
        return ( ICirculatingOHM( circulatingOHMContract ).OHMCirculatingSupply().mul( percentCanVest[ _vester ] ).mul( 1e9 ).div( 10000 ) ).sub( amountClaimed[ _vester ] );
    }

    // For single use after migration
    function setNewVault( address _newVault ) external returns ( bool ) {
        require( msg.sender == owner, "Sender is not owner" );
        require( !usingNewVault, "New vault already set" );

        newTreasury = _newVault;
        usingNewVault = true;

        return true;
    }

    function transferOwnership( address _owner ) external returns ( bool ) {
        require( msg.sender == owner, "Sender is not owner" );

        owner = _owner;

        return true;
    }
}