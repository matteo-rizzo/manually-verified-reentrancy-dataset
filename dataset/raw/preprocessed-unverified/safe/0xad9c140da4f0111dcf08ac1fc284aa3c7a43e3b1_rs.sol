/**
 *Submitted for verification at Etherscan.io on 2021-10-02
*/

/**
 *Submitted for verification at Etherscan.io on 2021-09-27
*/

// SPDX-License-Identifier: AGPL-3.0-or-later
pragma solidity 0.7.5;
pragma abicoder v2;











contract StablePool {

    using SafeMath for uint;
    using SafeERC20 for IERC20;



    /* ========== STRUCTS ========== */

    struct PoolToken {
        uint lowAP; // 5 decimals
        uint highAP; // 5 decimals
        bool accepting; // can send in (swap or add)
        bool pushed; // pushed to poolTokens
    }

    struct Fee {
        uint fee;
        uint collected;
        address collector;
    }



    /* ========== STATE VARIABLES ========== */

    IERC20 public immutable shareToken; // represents 1 token in the pool

    address[] public poolTokens; // tokens in pool
    mapping( address => PoolToken ) public tokenInfo; // info for tokens in pool

    uint public totalTokens; // total tokens in pool

    Fee public fees;
    
    
    
    /* ========== CONSTRUCTOR ========== */
    
    constructor( address token ) {
        require( token != address(0) );
        shareToken = IERC20( token );
    }



    /* ========== EXCHANGE FUNCTIONS ========== */

    // swap tokens and send outbound token to sender
    function swap( address firstToken, uint amount, address secondToken ) external {
        IERC20( firstToken ).safeTransferFrom( msg.sender, address(this), amount );

        IERC20( secondToken ).safeTransfer( msg.sender, _swap( firstToken, amount, secondToken ) );
    }

    // swap tokens, specifying sender and receiver
    // used by router for chain swaps
    function swapThrough( 
        address from, 
        address to, 
        address firstToken, 
        uint amount, 
        address secondToken
    ) external returns ( uint amount_ ) {
        IERC20( firstToken ).safeTransferFrom( from, address(this), amount );

        amount_ = _swap( firstToken, amount, secondToken );

        IERC20( secondToken ).approve( to, amount_ );
    }

    // add token to pool as liquidity, returning share token
    // rejects if token added will exit bounds
    function add( address token, uint amount ) external {
        totalTokens = totalTokens.add( amount ); // add amount to pool

        require( amount <= maxCanAdd( token ), "Exceeds limit in" );

        IERC20( token ).safeTransferFrom( msg.sender, address(this), amount ); // send token added

        shareToken.mint( msg.sender, amount ); // mint pool token
    }

    // remove token from liquidity, burning share token
    // rejects if token removed will exit bounds
    function remove( address token, uint amount ) external {
        shareToken.burn( msg.sender, amount ); // burn pool token

        uint fee = amount.mul( fees.fee ).div( 1e4 ); // trading fee collected

        require( amount.sub( fee ) <= maxCanRemove( token ), "Exceeds limit out" );

        fees.collected = fees.collected.add( fee ); // add to total fees
        totalTokens = totalTokens.sub( amount.sub( fee ) ); // remove amount from pool less fees

        IERC20( token ).safeTransfer( msg.sender, amount.sub( fee ) ); // send token removed
    }

    // remove liquidity evenly across all tokens 
    function removeAll( uint amount ) external {
        shareToken.burn( msg.sender, amount );

        uint fee = amount.mul( fees.fee ).div( 1e4 ); // trading fee collected
        fees.collected = fees.collected.add( fee ); // add to total fees

        amount = amount.sub( fee );

        for ( uint i = 0; i < poolTokens.length; i++ ) {
            IERC20 token = IERC20( poolTokens[ i ] );

            uint send = amount.mul( token.balanceOf( address(this) ) ).div( totalTokens );
            token.safeTransfer( msg.sender, send );
        }
        totalTokens = totalTokens.sub( amount ); // remove amount from pool less fees
    }

    // send collected fees to collector
    function collectFees( address token ) public {
        if ( fees.collected > 0 ) {
            totalTokens = totalTokens.sub( fees.collected );

            IERC20( token ).safeTransfer( fees.collector, fees.collected );

            fees.collected = 0;
        }
    }



    /* ========== INTERNAL FUNCTIONS ========== */

    // token swap logic
    function _swap( address firstToken, uint amount, address secondToken ) internal returns ( uint ) {
        require( amount <= maxCanAdd( firstToken ), "Exceeds limit in" );
        require( amount <= maxCanRemove( secondToken ), "Exceeds limit out" );

        uint fee = amount.mul( fees.fee ).div( 1e9 );

        fees.collected = fees.collected.add( fee );
        return amount.sub( fee );
    }



    /* ========== VIEW FUNCTIONS ========== */

    // maximum number of token that can be added to pool
    function maxCanAdd( address token ) public view returns ( uint ) {
        uint maximum = totalTokens.mul( tokenInfo[ token ].highAP ).div( 1e5 );
        uint balance = IERC20( token ).balanceOf( address(this) );
        return maximum.sub( balance );
    }

    // maximum number of token that can be removed from pool
    function maxCanRemove( address token ) public view returns ( uint ) {
        uint minimum = totalTokens.mul( tokenInfo[ token ].lowAP ).div( 1e5 );
        uint balance = IERC20( token ).balanceOf( address(this) );
        return balance.sub( minimum );
    }

    // maximum size of trade from first token to second token
    function maxSize( address firstToken, address secondToken ) public view returns ( uint ) {
        return maxCanAdd( firstToken ).add( maxCanRemove( secondToken ) );
    }



     /* ========== POLICY FUNCTIONS ========== */

    // change bounds of tokens in pool
    function changeBound( address token, uint newHigh, uint newLow ) external {
        tokenInfo[ token ].highAP = newHigh;
        tokenInfo[ token ].lowAP = newLow;
    }

    // add new token to pool
    // must call toggleAccept to activate token
    function addToken( address token, uint lowAP, uint highAP ) external {
        if ( !tokenInfo[ token ].pushed ) {
            poolTokens.push( token );
        }

        tokenInfo[ token ] = PoolToken({
            lowAP: lowAP,
            highAP: highAP,
            accepting: false,
            pushed: true
        });
    }

    // toggle whether to accept incoming token
    // setting token to false will not allow swaps as incoming token or adds
    function toggleAccept( address token ) external {
        tokenInfo[ token ].accepting = !tokenInfo[ token ].accepting;
    }
     
    // set fee taken on trades and fee collector
    function setFee( uint newFee, address collector, address collectToken ) external {
        require( collector != address(0) );

        collectFees( collectToken ); // clear cache before changes

        fees.fee = newFee;
        fees.collector = collector;
    }
}