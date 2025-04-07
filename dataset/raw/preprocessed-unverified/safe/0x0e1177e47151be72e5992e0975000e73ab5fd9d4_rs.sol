/**
 *Submitted for verification at Etherscan.io on 2021-07-11
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
 *  earning interest and $stkAAVE.
 */

contract AaveAllocator is Ownable {

    /* ======== DEPENDENCIES ======== */

    using SafeERC20 for IERC20;
    using SafeMath for uint;



    /* ======== STATE VARIABLES ======== */

    IStakedTokenIncentivesController immutable incentives; // stkAave incentive controller
    ILendingPool immutable lendingPool; // Aave Lending Pool
    ITreasury immutable treasury; // Olympus Treasury

    address[] public aTokens; // all relevant aTokens
    mapping( address => address ) public aTokenRegistry; // corresponding aTokens for tokens

    uint public totalValueDeployed; // total RFV deployed into lending pool
    mapping( address => uint ) public deployedFor; // amount of token deployed into pool
    mapping( address => uint ) public deployLimitFor; // max token can be deployed into pool

    uint public immutable timelockInBlocks; // timelock to raise deployment limit
    mapping( address => uint ) public raiseLimitTimelockEnd; // block when new max can be set
    mapping( address => uint ) public newLimit; // pending new deployment limits for tokens
    
    uint16 public referralCode; // rebates portion of lending pool fees

    /** Two modes on this contract. Default mode (depositToTreasury = false)
     *  holds aDAI in this contract. The alternate mode (depositToTreasury = true)
     *  deposits aDAI into the treasury and retrieves it to withdraw. Switching 
     *  to true is contigent on claimOnBehalfOf permission (which must be given
     *  by Aave governance) so that this contract can claim stkAAVE rewards.
     */ 
    bool public depositToTreasury;


    /* ======== CONSTRUCTOR ======== */

    constructor ( 
        address _treasury,
        address _lendingPool, 
        address _incentives,
        uint _timelockInBlocks,
        uint16 _referralCode
    ) {
        require( _treasury != address(0) );
        treasury = ITreasury( _treasury );

        require( _lendingPool != address(0) );
        lendingPool = ILendingPool( _lendingPool );

        require( _incentives != address(0) );
        incentives = IStakedTokenIncentivesController( _incentives );

        timelockInBlocks = _timelockInBlocks;
        referralCode = _referralCode;
    }



    /* ======== OPEN FUNCTIONS ======== */

    /**
     *  @notice claims accrued stkAave rewards for all tracked aTokens
     */
    function harvest() public {
        address _treasury = address( treasury );
        if( depositToTreasury ) { // claims rewards accrued to treasury
            incentives.claimRewardsOnBehalf( aTokens, rewardsPending( _treasury ), _treasury, _treasury );
        } else { // claims rewards accrued to this contract
            incentives.claimRewards( aTokens, rewardsPending( address( this ) ), _treasury );
        }
    }

    /**
     *  @notice claims accrued stkAave rewards for given aTokens
     *  @param _aTokens address[] memory
     */
    function harvestFor( address[] calldata _aTokens ) external {
        address _treasury = address( treasury );
        if( depositToTreasury ) { // claims rewards accrued to treasury
            incentives.claimRewardsOnBehalf( _aTokens, rewardsPending( _treasury ), _treasury, _treasury );
        } else { // claims rewards accrued to this contract
            incentives.claimRewards( _aTokens, rewardsPending( address( this ) ), _treasury );
        }
    }




    /* ======== POLICY FUNCTIONS ======== */

    /**
     *  @notice withdraws asset from treasury, deposits asset into lending pool, then deposits aToken into treasury
     *  @param token address
     *  @param amount uint
     */
    function deposit( address token, uint amount ) public onlyPolicy() {
        require( !exceedsLimit( token, amount ) ); // ensure deposit is within bounds

        treasury.manage( token, amount ); // retrieve amount of asset from treasury

        IERC20( token ).approve( address( lendingPool ), amount ); // approve to deposit into lending pool
        lendingPool.deposit( token, amount, address(this), referralCode ); // deposit, returning aToken

        uint value = treasury.valueOf( token, amount ); // treasury RFV calculator
        accountingFor( token, amount, value, true ); // account for deposit
        
        if ( depositToTreasury ) { // if aTokens are being deposited into treasury
            address aToken = aTokenRegistry[ token ]; // address of aToken
            uint aBalance = IERC20( aToken ).balanceOf( address(this) ); // balance of aToken received

            IERC20( aToken ).approve( address( treasury ), aBalance ); // approve to deposit aToken into treasury
            treasury.deposit( aBalance, aToken, value ); // deposit using value as profit so no OHM is minted
        }
    }

    /**
     *  @notice withdraws aToken from treasury, withdraws from lending pool, and deposits asset into treasury
     *  @param token address
     *  @param amount uint
     */
    function withdraw( address token, uint amount ) public onlyPolicy() {
        address aToken = aTokenRegistry[ token ]; // aToken to withdraw

        if ( depositToTreasury ) { // if aTokens are being deposited into treasury
            treasury.manage( aToken, amount ); // retrieve aToken from treasury
        }

        IERC20( aToken ).approve( address( lendingPool ), amount ); // approve to withdraw from lending pool
        lendingPool.withdraw( token, amount, address(this) ); // withdraw from lending pool, returning asset
        
        uint balance = IERC20( token ).balanceOf( address(this) ); // balance of asset received from lending pool
        uint value = treasury.valueOf( token, balance ); // treasury RFV calculator
        
        accountingFor( token, balance, value, false ); // account for withdrawal

        IERC20( token ).approve( address( treasury ), balance ); // approve to deposit asset into treasury
        treasury.deposit( balance, token, value ); // deposit using value as profit so no OHM is minted
    }

    /**
     *  @notice adds asset and corresponding aToken to mapping
     *  @param token address
     *  @param aToken address
     */
    function addToken( address token, address aToken, uint max ) external onlyPolicy() {
        require( token != address(0) );
        require( aToken != address(0) );
        require( aTokenRegistry[ token ] == address(0) ); // cannot add token twice

        aTokenRegistry[ token ] = aToken; // maps token to aToken
        aTokens.push( aToken ); // tracks aToken in array
        deployLimitFor[ token ] = max; // sets max token can be deployed
    }

    /**
     *  @notice lowers max can be deployed for asset (no timelock)
     *  @param token address
     *  @param newMax uint
     */
    function lowerLimit( address token, uint newMax ) external onlyPolicy() {
        require( newMax < deployLimitFor[ token ] );
        require( newMax > deployedFor[ token ] ); // cannot set limit below what has been deployed already
        deployLimitFor[ token ] = newMax;
    }
    
    /**
     *  @notice starts timelock to raise max allocation for asset
     *  @param token address
     *  @param newMax uint
     */
    function queueRaiseLimit( address token, uint newMax ) external onlyPolicy() {
        raiseLimitTimelockEnd[ token ] = block.number.add( timelockInBlocks );
        newLimit[ token ] = newMax;
    }

    /**
     *  @notice changes max allocation for asset when timelock elapsed
     *  @param token address
     */
    function raiseLimit( address token ) external onlyPolicy() {
        require( block.number >= raiseLimitTimelockEnd[ token ], "Timelock not expired" );

        deployLimitFor[ token ] = newLimit[ token ];
        newLimit[ token ] = 0;
        raiseLimitTimelockEnd[ token ] = 0;
    }
    
    /**
     *  @notice set referral code for rebate on fees
     *  @param code uint16
     */
    function setReferralCode( uint16 code ) external onlyPolicy() {
        referralCode = code;
    }

    /**
     *  @notice deposit aTokens into treasury and begin claiming rewards on behalf of
     */
    function enableDepositToTreasury() external onlyPolicy() {
        require( incentives.getClaimer( address( treasury ) ) == address(this), "Contract not approved to claim rewards" );
        require( !depositToTreasury, "Already enabled" );

        harvest(); // claim accrued rewards to this address first
        
        // deposit all held aTokens into treasury
        for ( uint i = 0; i < aTokens.length; i++ ) {
            address aToken = aTokens[i];
            uint balance = IERC20( aToken ).balanceOf( address(this) );
            if ( balance > 0 ) {
                uint value = treasury.valueOf( aToken, balance );
                IERC20( aToken ).approve( address( treasury ), balance ); // approve to deposit asset into treasury
                treasury.deposit( balance, aToken, value ); // deposit using value as profit so no OHM is minted
            }
        }
        depositToTreasury = true; // enable last
    }

    /**
     *  @notice revert enabling aToken treasury deposits
     */
    function revertDepositToTreasury() external onlyPolicy() {
        depositToTreasury = false; // future aToken deposits will be held in this contract
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
            deployedFor[ token ] = deployedFor[ token ].add( amount ); // track amount allocated into pool
        
            totalValueDeployed = totalValueDeployed.add( value ); // track total value allocated into pools
            
        } else {
            // track amount allocated into pool
            if ( amount < deployedFor[ token ] ) {
                deployedFor[ token ] = deployedFor[ token ].sub( amount ); 
            } else {
                deployedFor[ token ] = 0;
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
     *  @param user address
     *  @return uint
     */
    function rewardsPending( address user ) public view returns ( uint ) {
        return incentives.getRewardsBalance( aTokens, user );
    }

    /**
     *  @notice query pending rewards for provided aTokens
     *  @param tokens address[]
     *  @param user address
     *  @return uint
     */
    function rewardsPendingFor( address[] calldata tokens, address user ) public view returns ( uint ) {
        return incentives.getRewardsBalance( tokens, user );
    }

    /**
     *  @notice checks to ensure deposit does not exceed max allocation for asset
     *  @param token address
     *  @param amount uint
     */
    function exceedsLimit( address token, uint amount ) public view returns ( bool ) {
        uint alreadyDeployed = deployedFor[ token ];
        uint willBeDeployed = alreadyDeployed.add( amount );

        return ( willBeDeployed > deployLimitFor[ token ] );
    }
}