/**
 *Submitted for verification at Etherscan.io on 2021-03-25
*/

// SPDX-License-Identifier: AGPL-3.0-or-later
pragma solidity 0.7.4;











contract OlympusRewardDistributor {
    using SafeMath for uint;
    using SafeERC20 for IERC20;
    
    address public owner;
    address public vault;
    address public OHM;
    address public DAI;
    address public stakingContract;
    
    uint public nextEpochBlock;
    uint public blocksInEpoch;
    
    // reward rate is in hundreths i.e. 50 = 0.5%
    uint public rewardRate;
    
    bool public isInitialized;
    bool public notEnoughDAIToDistribute;

    constructor() {
        owner = msg.sender;
    }
    
    function initialize( uint _nextEpochBlock, uint _blocksInEpoch, uint _rewardRate, address _vault, address _stakingContract, address _OHM, address _DAI ) external returns ( bool ) {
        require( msg.sender == owner );
        require( isInitialized == false );
        
        nextEpochBlock = _nextEpochBlock;
        blocksInEpoch = _blocksInEpoch;
        rewardRate = _rewardRate;
        vault = _vault;
        stakingContract = _stakingContract;
        OHM = _OHM; 
        DAI = _DAI;
        
        isInitialized = true;
        
        return true;
    }
    
    function distribute() external returns ( bool ) {
        if ( block.number >= nextEpochBlock ) {
            nextEpochBlock = nextEpochBlock.add( blocksInEpoch );
            
            uint _amountDAI = IERC20( OHM ).totalSupply().mul( rewardRate ).mul( 1e9 ).div( 10000 );

            if ( _amountDAI <= IERC20( DAI ).balanceOf( address( this ) ) ) {
                notEnoughDAIToDistribute = false;
            } else {
                notEnoughDAIToDistribute = true;
            }

            if ( !notEnoughDAIToDistribute ) {
                IERC20( DAI ).approve( vault, _amountDAI );
                IVault( vault ).depositReserves( _amountDAI );
                IERC20( OHM ).safeTransfer( stakingContract, IERC20( OHM ).balanceOf( address( this ) ) );
            }
        }
        
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

    function transferOwnership( address _owner ) external returns ( bool ) {
        require( msg.sender == owner );
        owner = _owner;
        
        return true;
    }

    function transferRemainingDAIOutIfNotEnough() external returns ( bool ) {
        require( msg.sender == owner, "Not owner" );
        require( notEnoughDAIToDistribute, "Still enough DAI for next epoch" );

        IERC20( DAI ).safeTransfer( msg.sender, IERC20( DAI ).balanceOf( address( this ) ) );
        
        return true;
    }

    function getCurrentRewardForNextEpoch() external view returns ( uint ) {
        return IERC20( OHM ).totalSupply().mul( rewardRate ).div( 10000 );
    }
}