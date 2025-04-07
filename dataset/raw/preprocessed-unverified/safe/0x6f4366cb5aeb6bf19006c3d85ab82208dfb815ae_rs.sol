/**
 *Submitted for verification at Etherscan.io on 2021-07-28
*/

// SPDX-License-Identifier: AGPL-3.0-or-later
pragma solidity 0.7.5;

/**
 * @dev Collection of functions related to the address type
 */






/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
 */




contract Ownable is IOwnable {

    address internal _owner;
    address internal _newOwner;

    event OwnershipPushed(address indexed previousOwner, address indexed newOwner);
    event OwnershipPulled(address indexed previousOwner, address indexed newOwner);

    constructor () {
        _owner = msg.sender;
        emit OwnershipPushed( address(0), _owner );
    }

    function policy() public view override returns (address) {
        return _owner;
    }

    modifier onlyPolicy() {
        require( _owner == msg.sender, "Ownable: caller is not the owner" );
        _;
    }

    function renounceManagement() public virtual override onlyPolicy() {
        emit OwnershipPushed( _owner, address(0) );
        _owner = address(0);
    }

    function pushManagement( address newOwner_ ) public virtual override onlyPolicy() {
        require( newOwner_ != address(0), "Ownable: new owner is the zero address");
        emit OwnershipPushed( _owner, newOwner_ );
        _newOwner = newOwner_;
    }
    
    function pullManagement() public virtual override {
        require( msg.sender == _newOwner, "Ownable: must be new owner to pull");
        emit OwnershipPulled( _owner, _newOwner );
        _owner = _newOwner;
    }
}





//main Convex contract(booster.sol) basic interface


//sample convex reward contracts interface


/**
 *  Contract deploys reserves from treasury into the Convex lending pool,
 *  earning interest and $CVX.
 */

contract ConvexAllocator is Ownable {

    /* ======== DEPENDENCIES ======== */

    using SafeERC20 for IERC20;
    using SafeMath for uint;



    /* ======== STRUCTS ======== */

    struct tokenData {
        address underlying;
        address curveToken;
        uint deployed;
        uint limit;
        uint newLimit;
        uint limitChangeTimelockEnd;
    }



    /* ======== STATE VARIABLES ======== */

    IConvex immutable booster; // Convex deposit contract
    IConvexRewards immutable rewardPool; // Convex reward contract
    ITreasury immutable treasury; // Olympus Treasury
    ICurve3Pool immutable curve3Pool; // Curve 3Pool

    mapping( address => tokenData ) public tokenInfo; // info for deposited tokens
    mapping( address => uint ) public pidForReserve; // convex pid for token

    uint public totalValueDeployed; // total RFV deployed into lending pool

    uint public immutable timelockInBlocks; // timelock to raise deployment limit

    

    /* ======== CONSTRUCTOR ======== */

    constructor ( 
        address _treasury,
        address _booster, 
        address _rewardPool,
        address _curve3Pool,
        uint _timelockInBlocks
    ) {
        require( _treasury != address(0) );
        treasury = ITreasury( _treasury );

        require( _booster != address(0) );
        booster = IConvex( _booster );

        require( _rewardPool != address(0) );
        rewardPool = IConvexRewards( _rewardPool );

        require( _curve3Pool != address(0) );
        curve3Pool = ICurve3Pool( _curve3Pool );

        timelockInBlocks = _timelockInBlocks;
    }



    /* ======== OPEN FUNCTIONS ======== */

    /**
     *  @notice claims accrued CVX rewards for all tracked crvTokens
     */
    function harvest( address[] memory rewardTokens ) public {
        rewardPool.getReward();

        for( uint i = 0; i < rewardTokens.length; i++ ) {
            uint balance = IERC20( rewardTokens[i] ).balanceOf( address(this) );
            IERC20( rewardTokens[i] ).safeTransfer( address(treasury), balance );
        }
    }




    /* ======== POLICY FUNCTIONS ======== */

    /**
     *  @notice withdraws asset from treasury, deposits asset into lending pool, then deposits crvToken into treasury
     *  @param token address
     *  @param amount uint
     *  @param minAmount uint
     */
    function deposit( address token, uint amount, uint minAmount ) public onlyPolicy() {
        require( !exceedsLimit( token, amount ) ); // ensure deposit is within bounds
        address curveToken = tokenInfo[ token ].curveToken;

        treasury.manage( token, amount ); // retrieve amount of asset from treasury

        IERC20(token).approve(address(curve3Pool), amount); // approve curve pool to spend tokens
        uint curveAmount = curve3Pool.add_liquidity(curveToken, [amount, 0, 0, 0], minAmount); // deposit into curve

        IERC20( curveToken ).approve( address(booster), curveAmount ); // approve to deposit to convex
        booster.deposit( pidForReserve[ token ], curveAmount, true ); // deposit into convex

        //uint value = treasury.valueOf( token, amount ); // treasury RFV calculator

        uint value = treasury.valueOfToken( token, amount ); // treasury RFV calculator
        accountingFor( token, amount, value, true ); // account for deposit
    }

    /**
     *  @notice withdraws crvToken from treasury, withdraws from lending pool, and deposits asset into treasury
     *  @param token address
     *  @param amount uint
     *  @param minAmount uint
     */
    function withdraw( address token, uint amount, uint minAmount ) public onlyPolicy() {
        rewardPool.withdrawAndUnwrap( amount, false ); // withdraw to curve token

        address curveToken = tokenInfo[ token ].curveToken;

        IERC20(curveToken).approve(address(curve3Pool), amount); // approve 3Pool to spend curveToken
        curve3Pool.remove_liquidity_one_coin(curveToken, amount, 0, minAmount); // withdraw from curve

        uint balance = IERC20( token ).balanceOf( address(this) ); // balance of asset withdrawn

        // uint value = treasury.valueOf( token, balance ); // treasury RFV calculator

        uint value = treasury.valueOfToken( token, balance ); // treasury RFV calculator
        
        accountingFor( token, balance, value, false ); // account for withdrawal

        IERC20( token ).approve( address( treasury ), balance ); // approve to deposit asset into treasury
        treasury.deposit( balance, token, value ); // deposit using value as profit so no OHM is minted
    }

    /**
     *  @notice adds asset and corresponding crvToken to mapping
     *  @param token address
     *  @param curveToken address
     */
    function addToken( address token, address curveToken, uint max, uint pid ) external onlyPolicy() {
        require( token != address(0) );
        require( curveToken != address(0) );
        require( tokenInfo[ token ].deployed == 0 ); 

        tokenInfo[ token ] = tokenData({
            underlying: token,
            curveToken: curveToken,
            deployed: 0,
            limit: max,
            newLimit: 0,
            limitChangeTimelockEnd: 0
        });

        pidForReserve[ token ] = pid;
    }

    /**
     *  @notice lowers max can be deployed for asset (no timelock)
     *  @param token address
     *  @param newMax uint
     */
    function lowerLimit( address token, uint newMax ) external onlyPolicy() {
        require( newMax < tokenInfo[ token ].limit );
        require( newMax > tokenInfo[ token ].deployed ); // cannot set limit below what has been deployed already
        tokenInfo[ token ].limit = newMax;
    }
    
    /**
     *  @notice starts timelock to raise max allocation for asset
     *  @param token address
     *  @param newMax uint
     */
    function queueRaiseLimit( address token, uint newMax ) external onlyPolicy() {
        tokenInfo[ token ].limitChangeTimelockEnd = block.number.add( timelockInBlocks );
        tokenInfo[ token ].newLimit = newMax;
    }

    /**
     *  @notice changes max allocation for asset when timelock elapsed
     *  @param token address
     */
    function raiseLimit( address token ) external onlyPolicy() {
        require( block.number >= tokenInfo[ token ].limitChangeTimelockEnd, "Timelock not expired" );
        require( tokenInfo[ token ].limitChangeTimelockEnd != 0, "Timelock not started" );

        tokenInfo[ token ].limit = tokenInfo[ token ].newLimit;
        tokenInfo[ token ].newLimit = 0;
        tokenInfo[ token ].limitChangeTimelockEnd = 0;
    }



    /* ======== INTERNAL FUNCTIONS ======== */

    /**
     *  @notice accounting of deposits/withdrawals of assets
     *  @param token address
     *  @param amount uint
     *  @param value uint
     *  @param add bool
     */
    function accountingFor( address token, uint amount, uint value, bool add ) internal {
        if( add ) {
            tokenInfo[ token ].deployed = tokenInfo[ token ].deployed.add( amount ); // track amount allocated into pool
        
            totalValueDeployed = totalValueDeployed.add( value ); // track total value allocated into pools
            
        } else {
            // track amount allocated into pool
            if ( amount < tokenInfo[ token ].deployed ) {
                tokenInfo[ token ].deployed = tokenInfo[ token ].deployed.sub( amount ); 
            } else {
                tokenInfo[ token ].deployed = 0;
            }
            
            // track total value allocated into pools
            if ( value < totalValueDeployed ) {
                totalValueDeployed = totalValueDeployed.sub( value );
            } else {
                totalValueDeployed = 0;
            }
        }
    }


    /* ======== VIEW FUNCTIONS ======== */

    /**
     *  @notice query all pending rewards
     *  @return uint
     */
    function rewardsPending() public view returns ( uint ) {
        return rewardPool.earned(address(this));
    }

    /**
     *  @notice checks to ensure deposit does not exceed max allocation for asset
     *  @param token address
     *  @param amount uint
     */
    function exceedsLimit( address token, uint amount ) public view returns ( bool ) {
        uint willBeDeployed = tokenInfo[ token ].deployed.add( amount );

        return ( willBeDeployed > tokenInfo[ token ].limit );
    }
}