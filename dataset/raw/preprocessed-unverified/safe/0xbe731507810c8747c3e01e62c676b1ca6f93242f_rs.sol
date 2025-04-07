/**
 *Submitted for verification at Etherscan.io on 2021-03-30
*/

// SPDX-License-Identifier: AGPL-3.0-or-later
pragma solidity 0.7.4;



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
 * @dev Interface of the ERC20 standard as defined in the EIP.
 */


/**
 * @dev Collection of functions related to the address type
 */






contract OlympusStakingDistributor {
    using SafeMath for uint;
    using SafeERC20 for IERC20;
    
    address public owner;
    address public vault;
    address public OHM;
    address public DAI;
    address public DAO;
    address public stakingContract;
    
    uint public nextEpochBlock;
    uint public blocksInEpoch;
    
    // reward rate is in hundreths i.e. 50 = 0.5%
    uint public rewardRate;
    
    bool public isInitialized;

    constructor() {
        owner = msg.sender;
    }
    
    function initialize( uint _nextEpochBlock, uint _blocksInEpoch, uint _rewardRate, address _vault, address _stakingContract, address _OHM, address _DAI, address _DAO ) external returns ( bool ) {
        require( msg.sender == owner );
        require( isInitialized == false );
        
        nextEpochBlock = _nextEpochBlock;
        blocksInEpoch = _blocksInEpoch;
        rewardRate = _rewardRate;
        vault = _vault;
        stakingContract = _stakingContract;
        OHM = _OHM; 
        DAI = _DAI;
        DAO = _DAO;
        
        isInitialized = true;
        
        return true;
    }
    
    function distribute() external returns ( bool ) {
        if ( block.number >= nextEpochBlock ) {
            nextEpochBlock = nextEpochBlock.add( blocksInEpoch );
            
            uint _ohmToDistribute = IERC20( OHM ).totalSupply().mul( rewardRate ).div( 10000 );

            IERC20( OHM ).safeTransfer( stakingContract, _ohmToDistribute );
            IStaking( stakingContract ).stakeOHM( 0 );
        }
        return true;
    }

    function convertDAIToOHM( uint _amountToConvert ) external returns ( bool ) {
        require( msg.sender == owner );

        IERC20( DAI ).approve( vault, _amountToConvert );
        IVault( vault ).depositReserves( _amountToConvert );

        return true;
    }
    
    function setBlocksInEpoch( uint _blocksInEpoch ) external returns ( bool ) {
        require( msg.sender == owner);
        blocksInEpoch = _blocksInEpoch;
        return true;
    }
    
    // reward rate is in hundreths i.e. 50 = 0.5%
    function setRewardRate( uint _rewardRate ) external returns ( bool ) {
        require( msg.sender == owner );
        rewardRate = _rewardRate;
        return true;
    }

    function setVault( address _vault ) external returns ( bool ) {
        require( msg.sender == owner );
        vault = _vault;
        return true;
    }

    function setStaking( address _staking ) external returns ( bool ) {
        require( msg.sender == owner );
        stakingContract = _staking;
        return true;

    }

    function transferOwnership( address _owner ) external returns ( bool ) {
        require( msg.sender == owner );
        owner = _owner;
        
        return true;
    }

    function transferDAIToDAO() external returns ( bool ) {
        require( msg.sender == owner );
        IERC20( DAI ).safeTransfer( DAO, IERC20( DAI ).balanceOf( address( this ) ) );
        return true;
    }

    function transferOHMToDAO() external returns ( bool ) {
        require( msg.sender == owner );
        IERC20( OHM ).safeTransfer( DAO, IERC20( OHM ).balanceOf( address( this ) ) );
        return true;
    }

    function getCurrentRewardForNextEpoch() external view returns ( uint ) {
        return IERC20( OHM ).totalSupply().mul( rewardRate ).div( 10000 );
    }
}