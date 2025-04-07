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
 *  Contract deploys reserves from treasury into the Aave lending pool,
 *  earning interest and $stkAAVE for the treasury.
 */

contract AaveAllocator is Ownable {

    /* ======== DEPENDENCIES ======== */

    using SafeERC20 for IERC20;
    using SafeMath for uint;



    /* ======== STATE VARIABLES ======== */

    address immutable treasury; // Olympus Treasury
    address immutable lendingPool; // Aave Lending Pool
    address immutable stkAave; // staked Aave ( rewards token )

    mapping( address => address ) public aTokens; // Corresponding aTokens for tokens

    uint public totalAllocated;
    mapping( address => uint ) public allocated; // amount allocated into pool for token
    mapping( address => uint ) public maxAllocation; // max allocated into pool for token

    uint public immutable changeMaxAllocationTimelock; // timelock in blocks to change max allocation
    mapping( address => uint ) public changeMaxAllocationBlock; // block when new max can be set
    mapping( address => uint ) public newMaxAllocation; // pending new max allocations for tokens


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
        ILendingPool( lendingPool ).deposit( asset, amount, address(this), 0 ); // returns aToken

        allocated[ asset ] = allocated[ asset ].add( amount ); // track amount allocated into pool
        totalAllocated = totalAllocated.add( amount );
        
        address aToken = aTokens[ asset ];
        uint aBalance = IERC20( aToken ).balanceOf( address(this) );
        uint value = ITreasury( treasury ).valueOf( aToken, aBalance );

        // approve and deposit asset into treasury
        IERC20( aToken ).approve( aToken, aBalance );
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

        allocated[ asset ] = allocated[ asset ].sub( amount ); // track amount allocated into pool
        totalAllocated = totalAllocated.sub( amount );

        uint balance = IERC20( asset ).balanceOf( address(this) );
        uint value = ITreasury( treasury ).valueOf( asset, balance );

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
        uint alreadyAllocated = allocated[ asset ];
        uint willBeAllocated = alreadyAllocated.add( amount );

        return ( willBeAllocated > maxAllocation[ asset ] );
    }
}