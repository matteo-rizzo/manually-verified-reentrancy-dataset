/**
 *Submitted for verification at Etherscan.io on 2021-05-04
*/

// SPDX-License-Identifier: AGPL-3.0-or-later

pragma solidity 0.7.5;












contract Policy is IPolicy {
    
    address internal _policy;
    address internal _newPolicy;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor () {
        _policy = msg.sender;
        emit OwnershipTransferred( address(0), _policy );
    }

    function policy() public view override returns (address) {
        return _policy;
    }

    modifier onlyPolicy() {
        require( _policy == msg.sender, "Ownable: caller is not the owner" );
        _;
    }

    function renouncePolicy() public virtual override onlyPolicy() {
        emit OwnershipTransferred( _policy, address(0) );
        _policy = address(0);
    }

    function pushPolicy( address newPolicy_ ) public virtual override onlyPolicy() {
        require( newPolicy_ != address(0), "Ownable: new owner is the zero address");
        _newPolicy = newPolicy_;
    }

    function pullPolicy() public virtual override {
        require( msg.sender == _newPolicy );
        emit OwnershipTransferred( _policy, _newPolicy );
        _policy = _newPolicy;
    }
}





contract OlympusDistributorContract is Policy {
    using SafeMath for uint;
    using SafeERC20 for IERC20;
    
    address public OHM;
    address public stakingContract;
    address public circulatingOHMContract;
    
    uint public nextEpochBlock;
    uint public blocksInEpoch;
    
    // reward rate is in ten-thousandths ( 5000 = 0.5% )
    uint public rewardRate;

    uint public blockMigrationCanOccur;
    uint public migrationTimelockInBlocks;

    address public DAO;
    
    constructor( 
        uint _nextEpochBlock, 
        uint _blocksInEpoch, 
        uint _rewardRate, 
        address _stakingContract, 
        address _circulatingOHMContract,
        address _OHM,
        uint _migrationTimelock,
        address _DAO
    ) {        
        nextEpochBlock = _nextEpochBlock;
        blocksInEpoch = _blocksInEpoch;
        rewardRate = _rewardRate;

        require( _stakingContract != address(0) );
        stakingContract = _stakingContract;
        require( _circulatingOHMContract != address(0) );
        circulatingOHMContract = _circulatingOHMContract;
        require( _OHM != address(0) );
        OHM = _OHM; 
        migrationTimelockInBlocks = _migrationTimelock;
        require( _DAO != address(0) );
        DAO = _DAO;
    }
    
    /**
        @notice send epoch reward to staking contract
        @return bool
     */
    function distribute() external returns ( bool ) {
        require( block.number >= nextEpochBlock, "Epoch not ended" );
        nextEpochBlock = nextEpochBlock.add( blocksInEpoch );

        IStaking( stakingContract ).stakeOHM( 0 );
        IERC20( OHM ).safeTransfer( stakingContract, getCurrentRewardForNextEpoch() );
        return true;
    }

    /**
        @notice set reward rate in ten-thousandths ( 5000 = 0.5% )
        @return bool
     */
    function setRewardRate( uint _rewardRate ) external onlyPolicy() returns ( bool ) {
        rewardRate = _rewardRate;
        return true;
    }

    /**
        @notice view function for next epoch reward
        @return uint
     */
    function getCurrentRewardForNextEpoch() public view returns ( uint ) {
        uint supply = ICirculatingOHM( circulatingOHMContract ).OHMCirculatingSupply();
        return supply.mul( rewardRate ).div( 1000000 );
    }

    /**
        @notice sets timelock for reward migration
        @return bool
     */
    function setTimelock() external onlyPolicy() returns ( bool ) {
        blockMigrationCanOccur = block.number.add( migrationTimelockInBlocks );
        return true;
    }

    /**
        @notice migrates rewards when timelock elapsed
        @return bool
     */
    function migrate() external onlyPolicy() returns ( bool ) {
        require( blockMigrationCanOccur != 0, "Must start timelock" );
        require( blockMigrationCanOccur <= block.number, "Timelock not complete" );
        IERC20( OHM ).safeTransfer( DAO, IERC20( OHM ).balanceOf( address(this) ) );
        blockMigrationCanOccur = 0;
        return true;
    }

    /**
        @notice allow anyone to send lost tokens (excluding OHM) to the DAO
        @return bool
     */
    function recoverLostToken( address token_ ) external returns ( bool ) {
        require( token_ != OHM );
        IERC20( token_ ).safeTransfer( DAO, IERC20( token_ ).balanceOf( address(this) ) );
        return true;
    }
}