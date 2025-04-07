/**
 *Submitted for verification at Etherscan.io on 2021-07-07
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
 *  Contract deploys reserves from treasury into the Aave lending pool,
 *  earning interest and $stkAAVE for the treasury.
 */

contract AaveAllocator is Ownable {

    /* ======== DEPENDENCIES ======== */

    using SafeERC20 for IERC20;
    using SafeMath for uint;



    /* ======== STATE VARIABLES ======== */

    address immutable lendingPool; // Aave Lending Pool
    address immutable stkAave; // staked Aave ( rewards token )
    address treasury; // Olympus Treasury

    mapping( address => address ) public aTokens; // Corresponding aTokens for tokens

    uint public totalValueAllocated;
    mapping( address => uint ) public deployed; // amount allocated into pool for token
    mapping( address => uint ) public maxAllocation; // max allocated into pool for token

    uint public changeMaxAllocationTimelock; // timelock in blocks to change max allocation
    mapping( address => uint ) public changeMaxAllocationBlock; // block when new max can be set
    mapping( address => uint ) public newMaxAllocation; // pending new max allocations for tokens
    
    uint16 public referralCode; // Rebates portion of lending pool fees


    /* ======== CONSTRUCTOR ======== */

    constructor ( 
        address _treasury, 
        address _lendingPool, 
        address _stkAave,
        uint _changeMaxAllocationTimelock 
    ) {
        require( _treasury != address(0) );
        treasury = _treasury;
        require( _lendingPool != address(0) );
        lendingPool = _lendingPool;
        require( _stkAave != address(0) );
        stkAave = _stkAave;
        changeMaxAllocationTimelock = _changeMaxAllocationTimelock;
        referralCode = 0;
    }



    /* ======== OPEN FUNCTIONS ======== */

    /**
     *  @notice claims accrued stkAave rewards
     */
    function harvest() external {
        IStakedAave( stkAave ).claimRewards( treasury, rewardsPending() );
    }




    /* ======== POLICY FUNCTIONS ======== */

    /**
     *  @notice deposits asset from treasury into lending pool and returns aToken
     *  @param asset address
     *  @param amount uint
     */
    function deposit( address asset, uint amount ) external onlyPolicy() {
        require( !exceedsMaxAllocation( asset, amount ) ); // ensure deposit is within bounds

        ITreasury( treasury ).manage( asset, amount ); // retrieve amount of asset from treasury

        IERC20( asset ).approve( lendingPool, amount ); // deposit into lending pool
        ILendingPool( lendingPool ).deposit( asset, amount, address(this), referralCode ); // returns aToken

        uint value = ITreasury( treasury ).valueOf( asset, amount );
        
        trackAllocations( asset, amount, value, true );
        
        address aToken = aTokens[ asset ];
        uint aBalance = IERC20( aToken ).balanceOf( address(this) );

        // approve and deposit asset into treasury
        IERC20( aToken ).approve( treasury, aBalance );
        // use value as profit so no new OHM is minted
        ITreasury( treasury ).deposit( aBalance, aToken, value ); 
    }

    /**
     *  @notice withdraws aToken from lending pool and asset to treasury
     *  @param asset address
     *  @param amount uint
     */
    function withdraw( address asset, uint amount ) external onlyPolicy() {
        address aToken = aTokens[ asset ];
        ITreasury( treasury ).manage( aToken, amount ); // retrieve amount of aToken from treasury

        IERC20( aToken ).approve( lendingPool, amount ); // withdraw from lending pool
        ILendingPool( lendingPool ).withdraw( aToken, amount, address(this) ); // returns asset
        
        uint balance = IERC20( asset ).balanceOf( address(this) );
        uint value = ITreasury( treasury ).valueOf( asset, balance );
        
        trackAllocations( asset, balance, value, false );

        // approve and deposit asset into treasury
        IERC20( asset ).approve( treasury, balance );
        // use value as profit so no new OHM is minted
        ITreasury( treasury ).deposit( balance, asset, value ); 
    }

    /**
     *  @notice adds asset and corresponding aToken to mapping
     *  @param token address
     *  @param aToken address
     */
    function addToken( address token, address aToken, uint max ) external onlyPolicy() {
        require( token != address(0) );
        require( aToken != address(0) );
        require( maxAllocation[ token ] == 0 || max <= maxAllocation[ token ] );
        aTokens[ token ] = aToken;
        maxAllocation[ token ] = max;
    }

    /**
     *  @notice starts timelock to change max allocation for asset
     *  @param asset address
     *  @param newMax uint
     */
    function queueNewMaxAllocation( address asset, uint newMax ) external onlyPolicy() {
        changeMaxAllocationBlock[ asset ] = block.number.add( changeMaxAllocationTimelock );
        newMaxAllocation[ asset ] = newMax;
    }

    /**
     *  @notice changes max allocation for asset when timelock elapsed
     *  @param asset address
     */
    function setNewMaxAllocation( address asset ) external onlyPolicy() {
        require( block.number >= changeMaxAllocationBlock[ asset ], "Timelock not expired" );
        maxAllocation[ asset ] = newMaxAllocation[ asset ];
        newMaxAllocation[ asset ] = 0;
    }
    
    /**
     *  @notice initialize for production
     *  @param _treasury address
     *  @param _timelock uint
     */
    function setForProduction( address _treasury, uint _timelock, uint16 _ref ) external onlyPolicy() {
        require( changeMaxAllocationTimelock == 1 );
        require( _timelock != 1, "Function only callable once" );
        treasury = _treasury;
        changeMaxAllocationTimelock = _timelock;
        referralCode = _ref;
    }
    
    /**
     *  @notice set referral code to earn rebate on fees
     *  @param _ref uint16
     */
    function setReferralCode( uint16 _ref ) external onlyPolicy() {
        referralCode = _ref;
    }



    /* ======== INTERNAL FUNCTIONS ======== */

    /**
     *  @notice accounting of deposits/withdrawals of assets and in total
     *  @param asset address
     *  @param amount uint
     *  @param value uint
     *  @param add bool
     */
    function trackAllocations( address asset, uint amount, uint value, bool add ) internal {
        if( add ) {
            // track amount allocated into pool
            deployed[ asset ] = deployed[ asset ].add( amount ); 
        
            // track total value allocated into pools
            totalValueAllocated = totalValueAllocated.add( value );
        } else {
            // track amount allocated into pool
            if ( amount < deployed[ asset ] ) {
                deployed[ asset ] = deployed[ asset ].sub( amount ); 
            } else {
                deployed[ asset ] = 0;
            }
            
            // track total value allocated into pools
            if ( value < totalValueAllocated ) {
                totalValueAllocated = totalValueAllocated.sub( value );
            } else {
                totalValueAllocated = 0;
            }
        }
    }


    /* ======== VIEW FUNCTIONS ======== */

    function rewardsPending() public view returns ( uint ) {
        return IStakedAave( stkAave ).getTotalRewardsBalance( address(this) );
    }

    /**
     *  @notice checks to ensure deposit does not exceed max allocation for asset
     *  @param asset address
     *  @param amount uint
     */
    function exceedsMaxAllocation( address asset, uint amount ) public view returns ( bool ) {
        uint alreadyDeployed = deployed[ asset ];
        uint willBeDeployed = alreadyDeployed.add( amount );

        return ( willBeDeployed > maxAllocation[ asset ] );
    }
}