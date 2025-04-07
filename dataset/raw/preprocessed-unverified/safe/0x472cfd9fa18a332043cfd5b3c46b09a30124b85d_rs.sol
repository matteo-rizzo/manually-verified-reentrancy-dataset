/**
 *Submitted for verification at Etherscan.io on 2021-06-07
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





contract Distributor is Policy {
    using SafeMath for uint;
    using SafeERC20 for IERC20;

    address public immutable OHM;
    address public immutable treasury;
    uint public immutable epochLength;
    uint public nextEpochBlock;
        
    struct Info {
        uint rate; // in ten-thousandths ( 5000 = 0.5% )
        address recipient;
    }
    Info[] public info;
    
    struct Adjust {
        bool add;
        uint rate;
        uint target;
    }
    mapping( uint => Adjust ) public adjustments;

    constructor( address _treasury, address _ohm, uint _epochLength, uint _nextEpochBlock ) {        
        require( _treasury != address(0) );
        treasury = _treasury;
        require( _ohm != address(0) );
        OHM = _ohm;
        epochLength = _epochLength;
        nextEpochBlock = _nextEpochBlock;
    }
    
    /**
        @notice send epoch reward to staking contract
     */
    function distribute() external {
        require( nextEpochBlock <= block.number, "Not new epoch" );
        nextEpochBlock = nextEpochBlock.add( epochLength ); // set next epoch block
        // distribute rewards to each recipient
        for ( uint i = 0; i < info.length; i++ ) {
            if ( info[ i ].rate > 0 ) {
                ITreasury( treasury ).mintRewards( // mint and send from treasury
                    info[ i ].recipient, 
                    nextReward( info[ i ].rate ) 
                );
                adjust( i ); // check for adjustment
            }
        }
    }

    /**
        @notice increment reward rate for collector
     */
    function adjust( uint _index ) internal {
        Adjust memory adjustment = adjustments[ _index ];
        if ( adjustment.rate != 0 ) {
            if ( adjustment.add ) { // if rate should increase
                info[ _index ].rate = info[ _index ].rate.add( adjustment.rate ); // raise rate
                if ( info[ _index ].rate >= adjustment.target ) { // if target met
                    adjustments[ _index ].rate = 0; // turn off adjustment
                }
            } else { // if rate should decrease
                info[ _index ].rate = info[ _index ].rate.sub( adjustment.rate ); // lower rate
                if ( info[ _index ].rate <= adjustment.target ) { // if target met
                    adjustments[ _index ].rate = 0; // turn off adjustment
                }
            }
        }
    }

    /**
        @notice view function for next reward at given rate
        @param _rate uint
        @return uint
     */
    function nextReward( uint _rate ) public view returns ( uint ) {
        return IERC20( OHM ).totalSupply().mul( _rate ).div( 1000000 );
    }

    /**
        @notice view function for next reward for specified address
        @param _recipient address
        @return uint
     */
    function nextRewardFor( address _recipient ) public view returns ( uint ) {
        uint reward;
        for ( uint i = 0; i < info.length; i++ ) {
            if ( info[ i ].recipient == _recipient ) {
                reward = nextReward( info[ i ].rate );
            }
        }
        return reward;
    }

    /**
        @notice adds recipient for distributions
        @param _recipient address
        @param _rewardRate uint
     */
    function addRecipient( address _recipient, uint _rewardRate ) external onlyPolicy() {
        require( _recipient != address(0) );
        info.push( Info({
            recipient: _recipient,
            rate: _rewardRate
        }));
    }

    /**
        @notice removes recipient for distributions
        @param _index uint
        @param _recipient address
     */
    function removeRecipient( uint _index, address _recipient ) external onlyPolicy() {
        require( _recipient == info[ _index ].recipient );
        info[ _index ].recipient = address(0);
        info[ _index ].rate = 0;
    }

    /**
        @notice set adjustment info for a collector's reward rate
        @param _index uint
        @param _add bool
        @param _rate uint
        @param _target uint
     */
    function setAdjustment( uint _index, bool _add, uint _rate, uint _target ) external onlyPolicy() {
        adjustments[ _index ] = Adjust({
            add: _add,
            rate: _rate,
            target: _target
        });
    }
}