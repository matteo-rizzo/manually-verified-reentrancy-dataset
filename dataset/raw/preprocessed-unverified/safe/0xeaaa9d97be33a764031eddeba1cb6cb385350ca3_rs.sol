/**
 *Submitted for verification at Etherscan.io on 2021-08-12
*/

/**
 *Submitted for verification at Etherscan.io on 2021-08-09
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
 *  This contract allows Olympus genesis contributors to claim OHM. It has been
 *  revised to consider 2/3 tokens as staked at the time of claim; previously,
 *  no claims were treated as staked. This change keeps network ownership in check. 
 *  100% can be treated as staked, if the DAO sees fit to do so.
 */
contract GenesisClaim {

    /* ========== DEPENDENCIES ========== */

    using SafeMath for uint;
    using SafeERC20 for IERC20;



    /* ========== STRUCTS ========== */

    struct Term {
        uint percent; // 4 decimals ( 5000 = 0.5% )
        uint claimed; // static number
        uint wClaimed; // rebase-tracking number
        uint max; // maximum nominal OHM amount can claim
    }



    /* ========== STATE VARIABLES ========== */
    
    address owner; // can set terms
    address newOwner; // push/pull model for changing ownership
    
    IERC20 immutable OHM; // claim token
    IERC20 immutable DAI; // payment token

    ITreasury immutable treasury; // mints claim token
    IStaking immutable staking; // stake OHM for sOHM

    address immutable DAO; // holds non-circulating supply
    IwOHM immutable wOHM; // tracks rebase-agnostic balance

    bool public useStatic; // track 1/3 as static. governance can disable if desired.
    
    mapping( address => Term ) public terms; // tracks address info
    
    mapping( address => address ) public walletChange; // facilitates address change

    uint public totalAllocated; // as percent of supply (4 decimals: 10000 = 1%)
    uint public maximumAllocated; // maximum portion of supply can allocate



    /* ========== CONSTRUCTOR ========== */
    
    constructor( 
        address _ohm, 
        address _dai, 
        address _treasury, 
        address _DAO, 
        address _wOHM, 
        address _staking,
        uint _maximumAllocated
    ) {
        owner = msg.sender;

        require( _ohm != address(0) );
        OHM = IERC20( _ohm );

        require( _dai != address(0) );
        DAI = IERC20( _dai );

        require( _treasury != address(0) );
        treasury = ITreasury( _treasury );

        require( _DAO != address(0) );
        DAO = _DAO;

        require( _wOHM != address(0) );
        wOHM = IwOHM( _wOHM );
        
        require( _staking != address(0) );
        staking = IStaking( _staking );

        maximumAllocated = _maximumAllocated;
        useStatic = true;
    }



    /* ========== USER FUNCTIONS ========== */
    
    /**
     *  @notice allows wallet to claim OHM
     *  @param _amount uint
     */
    function claim( uint _amount ) external {
        OHM.safeTransfer( msg.sender, _claim( _amount ) );
    }

    /**
     *  @notice allows wallet to claim OHM and stake. set _claim = true if warmup is 0.
     *  @param _amount uint
     *  @param _claimsOHM bool
     */
    function stake( uint _amount, bool _claimsOHM ) external {
        uint toStake = _claim( _amount );

        OHM.approve( address( staking ), toStake );
        staking.stake( toStake, msg.sender );
        
        if ( _claimsOHM ) {
            staking.claim( msg.sender );
        }
    }

    /**
     *  @notice logic for claiming OHM
     *  @param _amount uint
     *  @return ToSend_ uint
     */
    function _claim( uint _amount ) internal returns ( uint ToSend_ ) {
        Term memory info = terms[ msg.sender ];

        DAI.safeTransferFrom( msg.sender, address( this ), _amount );
        
        DAI.approve( address( treasury ), _amount );
        ToSend_ = treasury.deposit( _amount, address( DAI ), 0 );

        require( redeemableFor( msg.sender ).div( 1e9 ) >= ToSend_, 'Not enough vested' );
        require( info.max.sub( claimed( msg.sender ) ) >= ToSend_, 'Claimed over max' );

        if( useStatic ) {
            terms[ msg.sender ].wClaimed = info.wClaimed.add( wOHM.sOHMTowOHM( ToSend_.mul( 2 ).div( 3 ) ) );
            terms[ msg.sender ].claimed = info.claimed.add( ToSend_.div( 3 ) );
        } else {
            terms[ msg.sender ].wClaimed = info.wClaimed.add( wOHM.sOHMTowOHM( ToSend_ ) );
        }
    }

    /**
     *  @notice allows address to push terms to new address
     *  @param _newAddress address
     */
    function pushWalletChange( address _newAddress ) external {
        require( terms[ msg.sender ].percent != 0 );
        walletChange[ msg.sender ] = _newAddress;
    }
    
    /**
     *  @notice allows new address to pull terms
     *  @param _oldAddress address
     */
    function pullWalletChange( address _oldAddress ) external {
        require( walletChange[ _oldAddress ] == msg.sender, "wallet did not push" );
        
        walletChange[ _oldAddress ] = address(0);
        terms[ msg.sender ] = terms[ _oldAddress ];
        delete terms[ _oldAddress ];
    }



    /* ========== VIEW FUNCTIONS ========== */

    /**
     *  @notice view OHM claimable for address. DAI decimals (18).
     *  @param _address address
     *  @return uint
     */
    function redeemableFor( address _address ) public view returns (uint) {
        uint max = circulatingSupply().mul( terms[ _address ].percent ).mul( 1e3 );
        return max.sub( claimed( _address ).mul( 1e9 ) );
    }

    /**
     *  @notice view OHM claimed by address. OHM decimals (9).
     *  @param _address address
     *  @return uint
     */
    function claimed( address _address ) public view returns ( uint ) {
        return wOHM.wOHMTosOHM( terms[ _address ].wClaimed ).add( terms[ _address ].claimed );
    }

    /**
     *  @notice view circulating supply of OHM
     *  @notice calculated as total supply minus DAO holdings
     *  @return uint
     */
    function circulatingSupply() public view returns ( uint ) {
        return OHM.totalSupply().sub( OHM.balanceOf( DAO ) );
    }



    /* ========== OWNER FUNCTIONS ========== */

    /**
     *  @notice set terms for new address
     *  @notice cannot lower for address or exceed maximum total allocation
     *  @param _address address
     *  @param _amountCanClaim uint
     *  @param _rate uint
     *  @param _hasClaimed uint
     */
    function setTerms(address _address, uint _amountCanClaim, uint _rate, uint _hasClaimed ) external {
        require( msg.sender == owner, "Sender is not owner" );
        require( _amountCanClaim >= terms[ _address ].max, "cannot lower amount claimable" );
        require( _rate >= terms[ _address ].percent, "cannot lower vesting rate" );
        require( totalAllocated.add( _rate ) <= maximumAllocated, "Cannot allocate more" );

        if( terms[ _address ].max == 0 ) {
            terms[ _address ].wClaimed = wOHM.sOHMTowOHM( _hasClaimed );
        } 

        terms[ _address ].max = _amountCanClaim;
        terms[ _address ].percent = _rate;

        totalAllocated = totalAllocated.add( _rate );
    }

    /**
     *  @notice push ownership of contract
     *  @param _newOwner address
     */
    function pushOwnership( address _newOwner ) external {
        require( msg.sender == owner, "Sender is not owner" );
        require( _newOwner != address(0) );
        newOwner = _newOwner;
    }
    
    /**
     *  @notice pull ownership of contract
     */
    function pullOwnership() external {
        require( msg.sender == newOwner );
        owner = newOwner;
        newOwner = address(0);
    }

    /**
     *  @notice renounce ownership of contract (no owner)
     */
     function renounceOwnership() external {
         require( msg.sender == owner, "Sender is not owner" );
         owner = address(0);
         newOwner = address(0);
     }

     /* ========== DAO FUNCTIONS ========== */

    /**
     *  @notice all claims tracked under wClaimed (and track rebase)
     */
     function treatAllAsStaked() external {
        require( msg.sender == DAO, "Sender is not DAO" );
        useStatic = false;
     }
}