/**
 *Submitted for verification at Etherscan.io on 2021-07-01
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







/**
 *  Contract deploys liquidity from treasury into the Onsen program,
 *  earning $SUSHI that can be staked and/or deposited into the treasury.
 */

contract OnsenAllocator is Ownable {
    
    /* ========== DEPENDENCIES ========== */
    
    using SafeERC20 for IERC20;
    using SafeMath for uint;



    /* ========== STATE VARIABLES ========== */

    uint[] public pids; // Pool IDs
    mapping( uint => address ) public pools; // Pool Addresses index by PID

    address immutable sushi; // $SUSHI token
    address immutable xSushi; // $xSUSHI token
    
    address immutable masterChef; // Onsen contract

    address immutable treasury; // Olympus Treasury

    uint public totalValueDeployed; // Total RFV deployed



    /* ========== CONSTRUCTOR ========== */

    constructor( 
        address _chef, 
        address _treasury, 
        address _sushi, 
        address _xSushi 
    ) {
        require( _chef != address(0) );
        masterChef = _chef;
        require( _treasury != address(0) );
        treasury = _treasury;
        require( _sushi != address(0) );
        sushi = _sushi;
        require( _xSushi != address(0) );
        xSushi = _xSushi;
    }



    /* ========== OPEN FUNCTIONS ========== */

    /**
     * @notice harvest Onsen rewards from all pools
     * @param _stake bool
     */
    function harvest( bool _stake ) external {
        for( uint i = 0; i < pids.length; i++ ) {
            uint pid = pids[i];
            if ( pid != 0 ) { // pid of 0 is invalid
                IMasterChef( masterChef ).withdraw( pid, 0 ); // withdrawing 0 harvests rewards
            }
        }
        enterSushiBar( _stake );
    }



    /* ========== INTERNAL FUNCTIONS ========== */

    /**
     * @notice stake sushi rewards if enter is true. return funds to treasury.
     * @param _stake bool
     */
    function enterSushiBar( bool _stake ) internal {
        uint balance = IERC20( sushi ).balanceOf( address(this) );
        if ( balance > 0 ) {
            if ( !_stake ) {
                IERC20( sushi ).safeTransfer( treasury, balance ); // transfer sushi to treasury
            } else {
                IERC20( sushi ).approve( xSushi, balance );
                ISushiBar( xSushi ).enter( balance ); // stake sushi

                uint xBalance = IERC20( xSushi ).balanceOf( address(this) );
                IERC20( xSushi ).safeTransfer( treasury, xBalance ); // transfer xSushi to treasury
            }
        }
    }



    /* ========== VIEW FUNCTIONS ========== */

    /**
     *  @notice pending $SUSHI rewards
     *  @return uint
     */
    function pendingSushi() external view returns ( uint ) {
        uint pending;
        for ( uint i = 0; i < pids.length; i++ ) {
            uint pid = pids[i];
            if ( pid != 0 ) {
                pending = pending.add( IMasterChef( masterChef ).pendingSushi( pid, address(this) ) );
            }
        }
        return pending;
    }



    /* ========== POLICY FUNCTIONS ========== */

    /**
     * @notice deposit LP from treasury to Onsen and collect rewards
     * @param _amount uint
     * @param _stake bool
     */
    function deposit( uint _pid, uint _amount, bool _stake ) external onlyPolicy() {
        address LP = pools[ _pid ];
        require( LP != address(0) );

        ITreasury( treasury ).manage( LP, _amount ); // retrieve LP from treasury
        
        IERC20( LP ).approve( masterChef, _amount );
        IMasterChef( masterChef ).deposit( _pid, _amount ); // deposit into Onsen

        uint value = ITreasury( treasury ).valueOf( LP, _amount );
        totalValueDeployed = totalValueDeployed.add( value ); // add to deployed value tracker
        
        enterSushiBar( _stake ); // manage rewards 
    }

    /**
     * @notice collect rewards and withdraw LP from Onsen and return to treasury.
     * @param _amount uint
     * @param _stake bool
     */
    function withdraw( uint _pid, uint _amount, bool _stake ) external onlyPolicy() {
        address LP = pools[ _pid ];
        require( LP != address(0) );

        IMasterChef( masterChef ).withdraw( _pid, _amount ); // withdraw from Onsen

        uint value = ITreasury( treasury ).valueOf( LP, _amount );
        // remove from deployed value tracker
        if ( value < totalValueDeployed ) {
            totalValueDeployed = totalValueDeployed.sub( value ); 
        } else { // LP value grows from fees and may exceed total deployed
            totalValueDeployed = 0;
        }
        
        // approve and deposit LP into treasury
        IERC20( LP ).approve( treasury, _amount );
        // use value for profit so that no OHM is minted
        ITreasury( treasury ).deposit( _amount, LP, value );
        
        enterSushiBar( _stake ); // manage rewards
    }

    /**
     * @notice withdraw Sushi from treasury and stake to xSushi
     * @param _amount uint
     */
    function enterSushiBarFromTreasury( uint _amount ) external onlyPolicy() {
        ITreasury( treasury ).manage( sushi, _amount ); // retrieve $SUSHI from treasury
        
        enterSushiBar( true ); // stake $SUSHI
    }
    
    /**
     * @notice withdraw xSushi from treasury and unstake to sushi
     * @param _amount uint
     */
    function exitSushiBar( uint _amount ) external onlyPolicy() {
        ITreasury( treasury ).manage( xSushi, _amount ); // retrieve $xSUSHI from treasury
        
        ISushiBar( xSushi ).leave( _amount ); // unstake $xSUSHI
        
        IERC20( sushi ).safeTransfer( treasury, IERC20( sushi ).balanceOf( address(this) ) ); // return $SUSHI to treasury
    }

    /**
     *  @notice add new PID and corresponding liquidity pool
     *  @param _pool address
     *  @param _pid uint
     */
    function addPool( address _pool, uint _pid ) external onlyPolicy() {
        require( _pool != address(0) );
        require( pools[ _pid ] == address(0) );

        pids.push( _pid );
        pools[ _pid ] = _pool;
    }

    /**
     *  @notice remove liquidity pool and corresponding PID
     *  @param _pool address
     *  @param _index uint
     */
    function removePool( address _pool, uint _index ) external onlyPolicy() {
        uint pid = pids[_index];
        require( pools[ pid ] == _pool );

        pids[ _index ] = 0;
        pools[ pid ] = address(0);
    }

    /**
     *  @notice withdraw liquidity without regard for rewards
     *  @param _pid uint
     */
    function emergencyWithdraw( uint _pid ) external onlyPolicy() {
        address LP = pools[ _pid ];

        IMasterChef( masterChef ).emergencyWithdraw( _pid ); // withdraws LP without returning rewards

        uint balance = IERC20( LP ).balanceOf( address(this) );
        uint value = ITreasury( treasury ).valueOf( LP, balance );
        if ( value < totalValueDeployed ) {
            totalValueDeployed = totalValueDeployed.sub( value ); // remove from value deployed tracker
        } else { // value increases with fees and would otherwise cause underflow
            totalValueDeployed = 0;
        }

        // approve and deposit LP into treasury
        IERC20( LP ).approve( treasury, balance );
        // use value for profit so that no OHM is minted
        ITreasury( treasury ).deposit( balance, LP, value ); 
    }
}