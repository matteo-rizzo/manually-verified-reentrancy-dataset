/**
 *Submitted for verification at Etherscan.io on 2021-03-24
*/

/**
 *Submitted for verification at Etherscan.io on 2021-03-24
*/

// SPDX-License-Identifier: AGPL-3.0-or-later\
pragma solidity 0.7.4;

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






contract ExercisePOLY {
    using SafeMath for uint;
    using SafeERC20 for IERC20;

    // in hundreths i.e. 50 = 0.5%
    mapping( address => uint ) public percentCanVest;
    mapping( address => uint ) public amountClaimed;
    mapping( address => uint ) public maxAllowedToClaim;
 
    address public pOLY;
    address public OHM;
    address public DAI;
    address public owner;

    address public treasury;

    constructor( address _owner, address _pOLY, address _ohm, address _dai, address _treasury) {
        pOLY = _pOLY;
        owner = _owner;
        OHM = _ohm;
        DAI = _dai;
        treasury = _treasury;
    }

    function setTerms(address _vester, uint _amountCanClaim, uint _rate ) external returns ( bool ) {
        require( msg.sender == owner, "Sender is not owner" );
        require( _amountCanClaim >= maxAllowedToClaim[ _vester ], "cannot lower amount claimable" );
        require( _rate >= percentCanVest[ _vester ], "cannot lower vesting rate" );

        maxAllowedToClaim[ _vester ] = _amountCanClaim;
        percentCanVest[ _vester ] = _rate;

        return true;
    }

    function exercisePOLY( uint _amountToExercise ) external returns ( bool ) {
        require( getPOLYAbleToClaim( msg.sender ).sub( _amountToExercise ) >= 0, 'Not enough OHM vested' );
        require( maxAllowedToClaim[ msg.sender ].sub( amountClaimed[ msg.sender ] ).sub( _amountToExercise ) >= 0, 'Claimed over max' );

        IERC20( DAI ).safeTransferFrom( msg.sender, address( this ), _amountToExercise );
        IERC20( DAI ).approve( treasury, _amountToExercise );

        IVault( treasury ).depositReserves( _amountToExercise );
        IPOLY( pOLY ).burnFrom( msg.sender, _amountToExercise );

        amountClaimed[ msg.sender ] = amountClaimed[ msg.sender ].add( _amountToExercise );

        uint _amountOHMToSend = _amountToExercise.div( 1e9 );

        IERC20( OHM ).safeTransfer( msg.sender, _amountOHMToSend );

        return true;
    }

    function getPOLYAbleToClaim( address _vester ) public view returns (uint) {
        return ( IERC20( OHM ).totalSupply().mul( percentCanVest[ _vester ] ).mul( 1e9 ).div( 10000 ) ).sub( amountClaimed[ _vester ] );
    }
}