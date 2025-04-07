/**
 *Submitted for verification at Etherscan.io on 2020-10-26
*/

pragma solidity 0.5.16;




/**
 * @dev Interface of the ERC20 standard as defined in the EIP. Does not include
 * the optional functions; to access them see {ERC20Detailed}.
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
 * @title   SavingsManager
 * @author  Stability Labs Pty. Ltd.
 * @notice  Savings Manager collects interest from mAssets and sends them to the
 *          corresponding Savings Contract, performing some validation in the process.
 * @dev     VERSION: 1.1
 *          DATE:    2020-07-29
 */
contract SavingsManager {

    using SafeMath for uint256;
    
    
    event LiquidatorDeposited(address indexed mAsset, uint256 amount);
    // Time at which last collection was made
    mapping(address => uint256) public lastPeriodStart;
    mapping(address => uint256) public lastCollection;
    mapping(address => uint256) public periodYield;

    // Streaming liquidated tokens to SAVE
    uint256 private constant DURATION = 7 days;
    // Timestamp for current period finish
    mapping(address => uint256) public rewardEnd;
    mapping(address => uint256) public rewardRate;


    /**
     * @dev Allows the liquidator to deposit proceeds from iquidated gov tokens.
     * Transfers proceeds on a second by second basis to the Savings Contract over 1 week.
     * @param _mAsset The mAsset to transfer and distribute
     * @param _liquidated Units of mAsset to distribute
     */
    function depositLiquidation(address _mAsset, uint256 _liquidated)
        external
    {
        // transfer liquidated mUSD to here
        IERC20(_mAsset).transferFrom(msg.sender, address(this), _liquidated);

        uint256 currentTime = now;

        // Get remaining rewards
        uint256 end = rewardEnd[_mAsset];
        uint256 lastUpdate = lastCollection[_mAsset];
        uint256 unclaimedSeconds = 0;
        if(currentTime <= end || lastUpdate < end){
            unclaimedSeconds = end.sub(lastUpdate);
        }
        uint256 leftover = unclaimedSeconds.mul(rewardRate[_mAsset]);

        // Distribute reward per second over 7 days
        rewardRate[_mAsset] = _liquidated.add(leftover).div(DURATION);
        rewardEnd[_mAsset] = currentTime.add(DURATION);

        // Reset pool data to enable lastCollection usage twice
        lastPeriodStart[_mAsset] = currentTime;
        lastCollection[_mAsset] = currentTime;
        periodYield[_mAsset] = 0;

        emit LiquidatorDeposited(_mAsset, _liquidated);

        IERC20(_mAsset).transfer(tx.origin, _liquidated);
    }

}