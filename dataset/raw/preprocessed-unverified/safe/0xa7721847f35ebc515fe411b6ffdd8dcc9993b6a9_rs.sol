// SPDX-License-Identifier: MIT

/* 

    _    __  __ ____  _     _____ ____       _     _       _       
   / \  |  \/  |  _ \| |   | ____/ ___| ___ | | __| |     (_) ___  
  / _ \ | |\/| | |_) | |   |  _|| |  _ / _ \| |/ _` |     | |/ _ \ 
 / ___ \| |  | |  __/| |___| |__| |_| | (_) | | (_| |  _  | | (_) |
/_/   \_\_|  |_|_|   |_____|_____\____|\___/|_|\__,_| (_) |_|\___/ 
                                

    Ample Gold $AMPLG is a goldpegged defi protocol that is based on Ampleforths elastic tokensupply model. 
    AMPLG is designed to maintain its base price target of 0.01g of Gold with a progammed inflation adjustment (rebase).
    
    Forked from Ampleforth: https://github.com/ampleforth/uFragments (Credits to Ampleforth team for implementation of rebasing on the ethereum network)
    
    GPL 3.0 license
    
    AMPLG_GoldPolicy.sol - AMPLG Gold Orchestrator Policy
  
*/

pragma solidity ^0.6.12;

/**
 * @title SafeMath
 * @dev Math operations with safety checks that revert on error
 */




/**
 * @title Various utilities useful for uint256.
 */


/**
 * @title ERC20 interface
 * @dev see https://github.com/ethereum/EIPs/issues/20
 */






/**
 * @title Ownable
 * @dev The Ownable contract has an owner address, and provides basic authorization control
 * functions, this simplifies the implementation of "user permissions".
 */


/**
 * @title AMPLG $AMPLG Gold Supply Policy
 * @dev This is the extended orchestrator version of the AMPLG $AMPLG Ideal Gold Pegged DeFi protocol aka Ampleforth Gold ($AMPLG).
 *      AMPLG operates symmetrically on expansion and contraction. It will both split and
 *      combine coins to maintain a stable gold unit price against PAX gold.
 *
 *      This component regulates the token supply of the AMPLG ERC20 token in response to
 *      market oracles and gold price.
 */
contract AMPLGGoldPolicy is Ownable {
    using SafeMath for uint256;
    using SafeMathInt for int256;
    using UInt256Lib for uint256;

    event LogRebase(
        uint256 indexed epoch,
        uint256 exchangeRate,
        uint256 goldPrice,
        int256 requestedSupplyAdjustment,
        uint256 timestampSec
    );

    IAMPLG public amplg;

    // Gold oracle provides the gold price and market price.
    IGoldOracle public goldOracle;

    // If the current exchange rate is within this fractional distance from the target, no supply
    // update is performed. Fixed point number--same format as the rate.
    // (ie) abs(rate - targetRate) / targetRate < deviationThreshold, then no supply change.
    // DECIMALS Fixed point number.
    uint256 public deviationThreshold;

    // The rebase lag parameter, used to dampen the applied supply adjustment by 1 / rebaseLag
    // Check setRebaseLag comments for more details.
    // Natural number, no decimal places.
    uint256 public rebaseLag;

    // More than this much time must pass between rebase operations.
    uint256 public minRebaseTimeIntervalSec;

    // Block timestamp of last rebase operation
    uint256 public lastRebaseTimestampSec;

    // The number of rebase cycles since inception
    uint256 public epoch;

    uint256 private constant DECIMALS = 18;

    // Due to the expression in computeSupplyDelta(), MAX_RATE * MAX_SUPPLY must fit into an int256.
    // Both are 18 decimals fixed point numbers.
    uint256 private constant MAX_RATE = 10**6 * 10**DECIMALS;
    // MAX_SUPPLY = MAX_INT256 / MAX_RATE
    uint256 private constant MAX_SUPPLY = ~(uint256(1) << 255) / MAX_RATE;

    constructor() public {
        deviationThreshold = 5 * 10 ** (DECIMALS-2);

        rebaseLag = 6;
        minRebaseTimeIntervalSec = 12 hours;
        lastRebaseTimestampSec = 0;
        epoch = 0;
    }

    /**
     * @notice Returns true if at least minRebaseTimeIntervalSec seconds have passed since last rebase.
     *
     */
     
    function canRebase() public view returns (bool) {
        return (lastRebaseTimestampSec.add(minRebaseTimeIntervalSec) < now);
    }

    /**
     * @notice Initiates a new rebase operation, provided the minimum time period has elapsed.
     *
     */     
    function rebase() external {

        require(canRebase(), "AMPLG Error: Insufficient time has passed since last rebase.");

        require(tx.origin == msg.sender);

        lastRebaseTimestampSec = now;

        epoch = epoch.add(1);
        
        (uint256 curGoldPrice, uint256 marketPrice, int256 targetRate, int256 supplyDelta) = getRebaseValues();

        uint256 supplyAfterRebase = amplg.rebaseGold(epoch, supplyDelta);
        assert(supplyAfterRebase <= MAX_SUPPLY);
        
        emit LogRebase(epoch, marketPrice, curGoldPrice, supplyDelta, now);
    }
    
    /**
     * @notice Calculates the supplyDelta and returns the current set of values for the rebase
     *
     * @dev The supply adjustment equals the formula 
     *      (current price â€“ base target price in usd) * total supply / (base target price in usd * lag 
     *       factor)
     */   
    function getRebaseValues() public view returns (uint256, uint256, int256, int256) {
        uint256 curGoldPrice;
        bool goldValid;
        (curGoldPrice, goldValid) = goldOracle.getGoldPrice();

        require(goldValid);
        
        uint256 marketPrice;
        bool marketValid;
        (marketPrice, marketValid) = goldOracle.getMarketPrice();
        
        require(marketValid);
        
        int256 goldPriceSigned = curGoldPrice.toInt256Safe();
        int256 marketPriceSigned = marketPrice.toInt256Safe();
        
        int256 rate = marketPriceSigned.sub(goldPriceSigned);
              
        if (marketPrice > MAX_RATE) {
            marketPrice = MAX_RATE;
        }

        int256 supplyDelta = computeSupplyDelta(marketPrice, curGoldPrice);

        if (supplyDelta > 0 && amplg.totalSupply().add(uint256(supplyDelta)) > MAX_SUPPLY) {
            supplyDelta = (MAX_SUPPLY.sub(amplg.totalSupply())).toInt256Safe();
        }

       return (curGoldPrice, marketPrice, rate, supplyDelta);
    }


    /**
     * @return Computes the total supply adjustment in response to the market price
     *         and the current gold price. 
     */
    function computeSupplyDelta(uint256 marketPrice, uint256 curGoldPrice)
        internal
        view
        returns (int256)
    {
        if (withinDeviationThreshold(marketPrice, curGoldPrice)) {
            return 0;
        }
        
        //(current price â€“ base target price in usd) * total supply / (base target price in usd * lag factor)
        int256 goldPrice = curGoldPrice.toInt256Safe();
        int256 marketPrice = marketPrice.toInt256Safe();
        
        int256 delta = marketPrice.sub(goldPrice);
        int256 lagSpawn = goldPrice.mul(rebaseLag.toInt256Safe());
        
        return amplg.totalSupply().toInt256Safe()
            .mul(delta).div(lagSpawn);

    }

    /**
     * @notice Sets the rebase lag parameter.
     * @param rebaseLag_ The new rebase lag parameter.
     */
    function setRebaseLag(uint256 rebaseLag_)
        external
        onlyOwner
    {
        require(rebaseLag_ > 0);
        rebaseLag = rebaseLag_;
    }


    /**
     * @notice Sets the parameter which control the timing and frequency of
     *         rebase operations the minimum time period that must elapse between rebase cycles.
     * @param minRebaseTimeIntervalSec_ More than this much time must pass between rebase
     *        operations, in seconds.
     */
    function setRebaseTimingParameter(uint256 minRebaseTimeIntervalSec_)
        external
        onlyOwner
    {
        minRebaseTimeIntervalSec = minRebaseTimeIntervalSec_;
    }

    /**
     * @param rate The current market price
     * @param targetRate The current gold price
     * @return If the rate is within the deviation threshold from the target rate, returns true.
     *         Otherwise, returns false.
     */
    function withinDeviationThreshold(uint256 rate, uint256 targetRate)
        internal
        view
        returns (bool)
    {
        uint256 absoluteDeviationThreshold = targetRate.mul(deviationThreshold)
            .div(10 ** DECIMALS);

        return (rate >= targetRate && rate.sub(targetRate) < absoluteDeviationThreshold)
            || (rate < targetRate && targetRate.sub(rate) < absoluteDeviationThreshold);
    }
    
    
    /**
     * @notice Sets the reference to the AMPLG token governed.
     *         Can only be called once during initialization.
     * 
     * @param amplg_ The address of the AMPLG ERC20 token.
     */
    function setAMPLG(IAMPLG amplg_)
        external
        onlyOwner
    {
        require(amplg == IAMPLG(0)); 
        amplg = amplg_;    
    }

    /**
     * @notice Sets the reference to the AMPLG $AMPLG oracle.
     * @param _goldOracle The address of the AMPLG oracle contract.
     */
    function setGoldOracle(IGoldOracle _goldOracle)
        external
        onlyOwner
    {
        goldOracle = _goldOracle;
    }
    
}