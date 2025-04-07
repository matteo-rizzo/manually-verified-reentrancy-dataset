/**
 *Submitted for verification at Etherscan.io on 2020-11-03
*/

pragma solidity 0.5.15;
pragma experimental ABIEncoderV2;

// YAM rebaser V2 - Uses sushiswap for rebase sales, purchases ETH, uses two hop oracle pricing

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



/**
 * @title SafeERC20
 * @dev Wrappers around ERC20 operations that throw on failure (when the token
 * contract returns false). Tokens that return no value (and instead revert or
 * throw on failure) are also supported, non-reverting calls are assumed to be
 * successful.
 * To use this library you can add a `using SafeERC20 for IERC20;` statement to your contract,
 * which allows you to call the safe operations as `token.safeTransfer(...)`, etc.
 */




// computes square roots using the babylonian method
// https://en.wikipedia.org/wiki/Methods_of_computing_square_roots#Babylonian_method


// a library for handling binary fixed point numbers (https://en.wikipedia.org/wiki/Q_(number_format))


// library with helper methods for oracles that are concerned with computing average prices


// Storage for a YAM token
contract YAMTokenStorage {

    using SafeMath for uint256;

    /**
     * @dev Guard variable for re-entrancy checks. Not currently used
     */
    bool internal _notEntered;

    /**
     * @notice EIP-20 token name for this token
     */
    string public name;

    /**
     * @notice EIP-20 token symbol for this token
     */
    string public symbol;

    /**
     * @notice EIP-20 token decimals for this token
     */
    uint8 public decimals;

    /**
     * @notice Governor for this contract
     */
    address public gov;

    /**
     * @notice Pending governance for this contract
     */
    address public pendingGov;

    /**
     * @notice Approved rebaser for this contract
     */
    address public rebaser;

    /**
     * @notice Approved migrator for this contract
     */
    address public migrator;

    /**
     * @notice Incentivizer address of YAM protocol
     */
    address public incentivizer;

    /**
     * @notice Total supply of YAMs
     */
    uint256 public totalSupply;

    /**
     * @notice Internal decimals used to handle scaling factor
     */
    uint256 public constant internalDecimals = 10**24;

    /**
     * @notice Used for percentage maths
     */
    uint256 public constant BASE = 10**18;

    /**
     * @notice Scaling factor that adjusts everyone's balances
     */
    uint256 public yamsScalingFactor;

    mapping (address => uint256) internal _yamBalances;

    mapping (address => mapping (address => uint256)) internal _allowedFragments;

    uint256 public initSupply;


    // keccak256("Permit(address owner,address spender,uint256 value,uint256 nonce,uint256 deadline)");
    bytes32 public constant PERMIT_TYPEHASH = 0x6e71edae12b1b97f4d1f60370fef10105fa2faae0126114a169c64845d6126c9;
    bytes32 public DOMAIN_SEPARATOR;
}

/* Copyright 2020 Compound Labs, Inc.

Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:

1. Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.

2. Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following disclaimer in the documentation and/or other materials provided with the distribution.

3. Neither the name of the copyright holder nor the names of its contributors may be used to endorse or promote products derived from this software without specific prior written permission.

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE. */


contract YAMGovernanceStorage {
    /// @notice A record of each accounts delegate
    mapping (address => address) internal _delegates;

    /// @notice A checkpoint for marking number of votes from a given block
    struct Checkpoint {
        uint32 fromBlock;
        uint256 votes;
    }

    /// @notice A record of votes checkpoints for each account, by index
    mapping (address => mapping (uint32 => Checkpoint)) public checkpoints;

    /// @notice The number of checkpoints for each account
    mapping (address => uint32) public numCheckpoints;

    /// @notice The EIP-712 typehash for the contract's domain
    bytes32 public constant DOMAIN_TYPEHASH = keccak256("EIP712Domain(string name,uint256 chainId,address verifyingContract)");

    /// @notice The EIP-712 typehash for the delegation struct used by the contract
    bytes32 public constant DELEGATION_TYPEHASH = keccak256("Delegation(address delegatee,uint256 nonce,uint256 expiry)");

    /// @notice A record of states for signing / validating signatures
    mapping (address => uint) public nonces;
}


contract YAMTokenInterface is YAMTokenStorage, YAMGovernanceStorage {

    /// @notice An event thats emitted when an account changes its delegate
    event DelegateChanged(address indexed delegator, address indexed fromDelegate, address indexed toDelegate);

    /// @notice An event thats emitted when a delegate account's vote balance changes
    event DelegateVotesChanged(address indexed delegate, uint previousBalance, uint newBalance);

    /**
     * @notice Event emitted when tokens are rebased
     */
    event Rebase(uint256 epoch, uint256 prevYamsScalingFactor, uint256 newYamsScalingFactor);

    /*** Gov Events ***/

    /**
     * @notice Event emitted when pendingGov is changed
     */
    event NewPendingGov(address oldPendingGov, address newPendingGov);

    /**
     * @notice Event emitted when gov is changed
     */
    event NewGov(address oldGov, address newGov);

    /**
     * @notice Sets the rebaser contract
     */
    event NewRebaser(address oldRebaser, address newRebaser);

    /**
     * @notice Sets the migrator contract
     */
    event NewMigrator(address oldMigrator, address newMigrator);

    /**
     * @notice Sets the incentivizer contract
     */
    event NewIncentivizer(address oldIncentivizer, address newIncentivizer);

    /* - ERC20 Events - */

    /**
     * @notice EIP20 Transfer event
     */
    event Transfer(address indexed from, address indexed to, uint amount);

    /**
     * @notice EIP20 Approval event
     */
    event Approval(address indexed owner, address indexed spender, uint amount);

    /* - Extra Events - */
    /**
     * @notice Tokens minted event
     */
    event Mint(address to, uint256 amount);

    // Public functions
    function transfer(address to, uint256 value) external returns(bool);
    function transferFrom(address from, address to, uint256 value) external returns(bool);
    function balanceOf(address who) external view returns(uint256);
    function balanceOfUnderlying(address who) external view returns(uint256);
    function allowance(address owner_, address spender) external view returns(uint256);
    function approve(address spender, uint256 value) external returns (bool);
    function increaseAllowance(address spender, uint256 addedValue) external returns (bool);
    function decreaseAllowance(address spender, uint256 subtractedValue) external returns (bool);
    function maxScalingFactor() external view returns (uint256);
    function yamToFragment(uint256 yam) external view returns (uint256);
    function fragmentToYam(uint256 value) external view returns (uint256);

    /* - Governance Functions - */
    function getPriorVotes(address account, uint blockNumber) external view returns (uint256);
    function delegateBySig(address delegatee, uint nonce, uint expiry, uint8 v, bytes32 r, bytes32 s) external;
    function delegate(address delegatee) external;
    function delegates(address delegator) external view returns (address);
    function getCurrentVotes(address account) external view returns (uint256);

    /* - Permissioned/Governance functions - */
    function mint(address to, uint256 amount) external returns (bool);
    function rebase(uint256 epoch, uint256 indexDelta, bool positive) external returns (uint256);
    function _setRebaser(address rebaser_) external;
    function _setIncentivizer(address incentivizer_) external;
    function _setPendingGov(address pendingGov_) external;
    function _acceptGov() external;
}


contract YAMRebaser2 {

    using SafeMath for uint256;

    modifier onlyGov() {
        require(msg.sender == gov);
        _;
    }

    struct Transaction {
        bool enabled;
        address destination;
        bytes data;
    }

    struct UniVars {
      uint256 yamsToUni;
      uint256 amountFromReserves;
      uint256 mintToReserves;
    }

    /// @notice an event emitted when a transaction fails
    event TransactionFailed(address indexed destination, uint index, bytes data);

    /// @notice an event emitted when maxSlippageFactor is changed
    event NewMaxSlippageFactor(uint256 oldSlippageFactor, uint256 newSlippageFactor);

    /// @notice an event emitted when deviationThreshold is changed
    event NewDeviationThreshold(uint256 oldDeviationThreshold, uint256 newDeviationThreshold);

    /// @notice an event emitted during rebase denoting how much is minted
    event MintAmount(uint256 mintAmount);

    /**
     * @notice Sets the treasury mint percentage of rebase
     */
    event NewRebaseMintPercent(uint256 oldRebaseMintPerc, uint256 newRebaseMintPerc);


    /**
     * @notice Sets the reserve contract
     */
    event NewReserveContract(address oldReserveContract, address newReserveContract);

    /**
     * @notice Sets the reserve contract
     */
    event TreasuryIncreased(uint256 reservesAdded, uint256 yamsSold, uint256 yamsFromReserves, uint256 yamsToReserves);


    /**
     * @notice Event emitted when pendingGov is changed
     */
    event NewPendingGov(address oldPendingGov, address newPendingGov);

    /**
     * @notice Event emitted when gov is changed
     */
    event NewGov(address oldGov, address newGov);

    // Stable ordering is not guaranteed.
    Transaction[] public transactions;


    /// @notice Governance address
    address public gov;

    /// @notice Pending Governance address
    address public pendingGov;

    /// @notice Spreads out getting to the target price
    uint256 public rebaseLag;

    /// @notice Peg target
    uint256 public targetRate;

    /// @notice Percent of rebase that goes to minting for treasury building
    uint256 public rebaseMintPerc;

    // If the current exchange rate is within this fractional distance from the target, no supply
    // update is performed. Fixed point number--same format as the rate.
    // (ie) abs(rate - targetRate) / targetRate < deviationThreshold, then no supply change.
    uint256 public deviationThreshold;

    /// @notice More than this much time must pass between rebase operations.
    uint256 public minRebaseTimeIntervalSec;

    /// @notice Block timestamp of last rebase operation
    uint256 public lastRebaseTimestampSec;

    /// @notice The rebase window begins this many seconds into the minRebaseTimeInterval period.
    // For example if minRebaseTimeInterval is 24hrs, it represents the time of day in seconds.
    uint256 public rebaseWindowOffsetSec;

    /// @notice The length of the time window where a rebase operation is allowed to execute, in seconds.
    uint256 public rebaseWindowLengthSec;

    /// @notice The number of rebase cycles since inception
    uint256 public epoch;

    // rebasing is not active initially. It can be activated at T+12 hours from
    // deployment time
    ///@notice boolean showing rebase activation status
    bool public rebasingActive;

    /// @notice delays rebasing activation to facilitate liquidity
    uint256 public constant rebaseDelay = 12 hours;

    /// @notice Time of TWAP initialization
    uint256 public timeOfTWAPInit;

    /// @notice YAM token address
    address public yamAddress;

    /// @notice reserve token
    address public reserveToken;

    /// @notice Reserves vault contract
    address public reservesContract;

    /// @notice pair for reserveToken <> YAM
    address public trade_pair;

    /// @notice pair for reserveToken <> YAM
    address public eth_usdc_pair;

    /// @notice list of uniswap pairs to sync
    address[] public uniSyncPairs;

    /// @notice list of balancer pairs to gulp
    address[] public balGulpPairs;

    /// @notice last TWAP update time
    uint32 public blockTimestampLast;

    /// @notice last TWAP cumulative price;
    uint256 public priceCumulativeLastYAMETH;

    /// @notice last TWAP cumulative price;
    uint256 public priceCumulativeLastETHUSDC;


    /// @notice address to send part of treasury to
    address public public_goods;

    /// @notice percentage of treasury to send to public goods address
    uint256 public public_goods_perc;

    // Max slippage factor when buying reserve token. Magic number based on
    // the fact that uniswap is a constant product. Therefore,
    // targeting a % max slippage can be achieved by using a single precomputed
    // number. i.e. 2.5% slippage is always equal to some f(maxSlippageFactor, reserves)
    /// @notice the maximum slippage factor when buying reserve token
    uint256 public maxSlippageFactor;

    /// @notice Whether or not this token is first in uniswap YAM<>Reserve pair
    bool public isToken0;


    uint256 public constant BASE = 10**18;

    uint256 public constant MAX_SLIPPAGE_PARAM = 1180339 * 10**11; // max ~20% market impact

    uint256 public constant MAX_MINT_PERC_PARAM = 25 * 10**16; // max 25% of rebase can go to treasury

    constructor(
        address yamAddress_,
        address reserveToken_,
        address factory,
        address reservesContract_,
        address public_goods_,
        uint256 public_goods_perc_
    )
        public
    {
          minRebaseTimeIntervalSec = 12 hours;
          rebaseWindowOffsetSec = 28800; // 8am/8pm UTC rebases

          (address token0, address token1) = sortTokens(yamAddress_, reserveToken_);

          // used for interacting with uniswap
          if (token0 == yamAddress_) {
              isToken0 = true;
          } else {
              isToken0 = false;
          }
          // uniswap YAM<>Reserve pair
          trade_pair = pairForSushi(factory, token0, token1);


          // get eth_usdc piar
          address USDC = address(0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48);

          // USDC < WETH address, so USDC is token0
          eth_usdc_pair = pairForSushi(factory, USDC, reserveToken_);

          // Reserves contract is mutable
          reservesContract = reservesContract_;

          // Reserve token is not mutable. Must deploy a new rebaser to update it
          reserveToken = reserveToken_;

          yamAddress = yamAddress_;

          public_goods = public_goods_;
          public_goods_perc = public_goods_perc_;

          // target 5% slippage
          // ~2.6%
          maxSlippageFactor = 2597836 * 10**10; //5409258 * 10**10;

          // $1
          targetRate = BASE;

          // twice daily rebase, with targeting reaching peg in 10 days
          rebaseLag = 20;

          // 10%
          rebaseMintPerc = 10**17;

          // 5%
          deviationThreshold = 5 * 10**16;

          // 60 minutes
          rebaseWindowLengthSec = 60 * 60;

          // Changed in deployment scripts to facilitate protocol initiation
          gov = msg.sender;

    }


    function removeUniPair(uint256 index) public onlyGov {
        if (index >= uniSyncPairs.length) return;

        for (uint i = index; i < uniSyncPairs.length-1; i++){
            uniSyncPairs[i] = uniSyncPairs[i+1];
        }
        uniSyncPairs.length--;
    }

    function removeBalPair(uint256 index) public onlyGov {
        if (index >= balGulpPairs.length) return;

        for (uint i = index; i < balGulpPairs.length-1; i++){
            balGulpPairs[i] = balGulpPairs[i+1];
        }
        balGulpPairs.length--;
    }

    /**
    @notice Adds pairs to sync
    *
    */
    function addSyncPairs(address[] memory uniSyncPairs_, address[] memory balGulpPairs_)
        public
        onlyGov
    {
        for (uint256 i = 0; i < uniSyncPairs_.length; i++) {
            uniSyncPairs.push(uniSyncPairs_[i]);
        }

        for (uint256 i = 0; i < balGulpPairs_.length; i++) {
            balGulpPairs.push(balGulpPairs_[i]);
        }
    }

    /**
    @notice Uniswap synced pairs
    *
    */
    function getUniSyncPairs()
        public
        view
        returns (address[] memory)
    {
        address[] memory pairs = uniSyncPairs;
        return pairs;
    }

    /**
    @notice Uniswap synced pairs
    *
    */
    function getBalGulpPairs()
        public
        view
        returns (address[] memory)
    {
        address[] memory pairs = balGulpPairs;
        return pairs;
    }



    /**
    @notice Updates slippage factor
    @param maxSlippageFactor_ the new slippage factor
    *
    */
    function setMaxSlippageFactor(uint256 maxSlippageFactor_)
        public
        onlyGov
    {
        require(maxSlippageFactor_ < MAX_SLIPPAGE_PARAM);
        uint256 oldSlippageFactor = maxSlippageFactor;
        maxSlippageFactor = maxSlippageFactor_;
        emit NewMaxSlippageFactor(oldSlippageFactor, maxSlippageFactor_);
    }

    /**
    @notice Updates rebase mint percentage
    @param rebaseMintPerc_ the new rebase mint percentage
    *
    */
    function setRebaseMintPerc(uint256 rebaseMintPerc_)
        public
        onlyGov
    {
        require(rebaseMintPerc_ < MAX_MINT_PERC_PARAM);
        uint256 oldPerc = rebaseMintPerc;
        rebaseMintPerc = rebaseMintPerc_;
        emit NewRebaseMintPercent(oldPerc, rebaseMintPerc_);
    }


    /**
    @notice Updates reserve contract
    @param reservesContract_ the new reserve contract
    *
    */
    function setReserveContract(address reservesContract_)
        public
        onlyGov
    {
        address oldReservesContract = reservesContract;
        reservesContract = reservesContract_;
        emit NewReserveContract(oldReservesContract, reservesContract_);
    }


    /** @notice sets the pendingGov
     * @param pendingGov_ The address of the rebaser contract to use for authentication.
     */
    function _setPendingGov(address pendingGov_)
        external
        onlyGov
    {
        address oldPendingGov = pendingGov;
        pendingGov = pendingGov_;
        emit NewPendingGov(oldPendingGov, pendingGov_);
    }

    /** @notice lets msg.sender accept governance
     *
     */
    function _acceptGov()
        external
    {
        require(msg.sender == pendingGov, "!pending");
        address oldGov = gov;
        gov = pendingGov;
        pendingGov = address(0);
        emit NewGov(oldGov, gov);
    }

    /** @notice Initializes TWAP start point, starts countdown to first rebase
    *
    */
    function init_twap()
        public
    {
        require(timeOfTWAPInit == 0, "already activated");
        (uint priceCumulative, uint32 blockTimestamp) =
           UniswapV2OracleLibrary.currentCumulativePrices(trade_pair, isToken0);

       (uint priceCumulativeUSDC, ) =
          UniswapV2OracleLibrary.currentCumulativePrices(eth_usdc_pair, false);

        require(blockTimestamp > 0, "no trades");
        blockTimestampLast = blockTimestamp;
        priceCumulativeLastYAMETH = priceCumulative;
        priceCumulativeLastETHUSDC = priceCumulativeUSDC;
        timeOfTWAPInit = blockTimestamp;
    }

    /** @notice Activates rebasing
    *   @dev One way function, cannot be undone, callable by anyone
    */
    function activate_rebasing()
        public
    {
        require(timeOfTWAPInit > 0, "twap wasnt intitiated, call init_twap()");
        // cannot enable prior to end of rebaseDelay
        require(now >= timeOfTWAPInit + rebaseDelay, "!end_delay");

        rebasingActive = true;
    }

    /**
     * @notice Initiates a new rebase operation, provided the minimum time period has elapsed.
     *
     * @dev The supply adjustment equals (_totalSupply * DeviationFromTargetRate) / rebaseLag
     *      Where DeviationFromTargetRate is (MarketOracleRate - targetRate) / targetRate
     *      and targetRate is 1e18
     */
    function rebase()
        public
    {
        // EOA only or gov
        require(msg.sender == tx.origin, "!EOA");
        // ensure rebasing at correct time
        _inRebaseWindow();

        // This comparison also ensures there is no reentrancy.
        require(lastRebaseTimestampSec.add(minRebaseTimeIntervalSec) < now);

        // Snap the rebase time to the start of this window.
        lastRebaseTimestampSec = now.sub(
            now.mod(minRebaseTimeIntervalSec)).add(rebaseWindowOffsetSec);

        epoch = epoch.add(1);

        // get twap from uniswap v2;
        uint256 exchangeRate = getTWAP();

        // calculates % change to supply
        (uint256 offPegPerc, bool positive) = computeOffPegPerc(exchangeRate);

        uint256 indexDelta = offPegPerc;

        // Apply the Dampening factor.
        indexDelta = indexDelta.div(rebaseLag);

        YAMTokenInterface yam = YAMTokenInterface(yamAddress);

        if (positive) {
            require(yam.yamsScalingFactor().mul(BASE.add(indexDelta)).div(BASE) < yam.maxScalingFactor(), "new scaling factor will be too big");
        }


        uint256 currSupply = yam.totalSupply();

        uint256 mintAmount;
        // reduce indexDelta to account for minting
        if (positive) {
            uint256 mintPerc = indexDelta.mul(rebaseMintPerc).div(BASE);
            indexDelta = indexDelta.sub(mintPerc);
            mintAmount = currSupply.mul(mintPerc).div(BASE);
        }

        // rebase
        // ignore returned var
        yam.rebase(epoch, indexDelta, positive);

        // perform actions after rebase
        emit MintAmount(mintAmount);
        afterRebase(mintAmount, offPegPerc);
    }


    function uniswapV2Call(
        address sender,
        uint256 amount0,
        uint256 amount1,
        bytes memory data
    )
        public
    {
        // enforce that it is coming from uniswap
        require(msg.sender == trade_pair, "bad msg.sender");
        // enforce that this contract called uniswap
        require(sender == address(this), "bad origin");
        (UniVars memory uniVars) = abi.decode(data, (UniVars));

        YAMTokenInterface yam = YAMTokenInterface(yamAddress);

        if (uniVars.amountFromReserves > 0) {
            // transfer from reserves and mint to uniswap
            yam.transferFrom(reservesContract, trade_pair, uniVars.amountFromReserves);
            if (uniVars.amountFromReserves < uniVars.yamsToUni) {
                // if the amount from reserves > yamsToUni, we have fully paid for the yCRV tokens
                // thus this number would be 0 so no need to mint
                yam.mint(trade_pair, uniVars.yamsToUni.sub(uniVars.amountFromReserves));
            }
        } else {
            // mint to uniswap
            yam.mint(trade_pair, uniVars.yamsToUni);
        }

        // mint unsold to mintAmount
        if (uniVars.mintToReserves > 0) {
            yam.mint(reservesContract, uniVars.mintToReserves);
        }

        // transfer reserve token to reserves
        if (isToken0) {
            if (public_goods != address(0) && public_goods_perc > 0) {
                uint256 amount_to_public_goods = amount1.mul(public_goods_perc).div(BASE);
                SafeERC20.safeTransfer(IERC20(reserveToken), reservesContract, amount1.sub(amount_to_public_goods));
                SafeERC20.safeTransfer(IERC20(reserveToken), public_goods, amount_to_public_goods);
                emit TreasuryIncreased(
                    amount1.sub(amount_to_public_goods),
                    uniVars.yamsToUni,
                    uniVars.amountFromReserves,
                    uniVars.mintToReserves
                );
            } else {
                SafeERC20.safeTransfer(IERC20(reserveToken), reservesContract, amount1);
                emit TreasuryIncreased(
                    amount1,
                    uniVars.yamsToUni,
                    uniVars.amountFromReserves,
                    uniVars.mintToReserves
                );
            }
        } else {
          if (public_goods != address(0) && public_goods_perc > 0) {
              uint256 amount_to_public_goods = amount0.mul(public_goods_perc).div(BASE);
              SafeERC20.safeTransfer(IERC20(reserveToken), reservesContract, amount0.sub(amount_to_public_goods));
              SafeERC20.safeTransfer(IERC20(reserveToken), public_goods, amount_to_public_goods);
              emit TreasuryIncreased(
                  amount0.sub(amount_to_public_goods),
                  uniVars.yamsToUni,
                  uniVars.amountFromReserves,
                  uniVars.mintToReserves
              );
          } else {
              SafeERC20.safeTransfer(IERC20(reserveToken), reservesContract, amount0);
              emit TreasuryIncreased(
                  amount0,
                  uniVars.yamsToUni,
                  uniVars.amountFromReserves,
                  uniVars.mintToReserves
              );
          }
        }
    }

    function buyReserveAndTransfer(
        uint256 mintAmount,
        uint256 offPegPerc
    )
        internal
    {
        UniswapPair pair = UniswapPair(trade_pair);

        YAMTokenInterface yam = YAMTokenInterface(yamAddress);

        // get reserves
        (uint256 token0Reserves, uint256 token1Reserves, ) = pair.getReserves();

        // check if protocol has excess yam in the reserve
        uint256 excess = yam.balanceOf(reservesContract);


        uint256 tokens_to_max_slippage = uniswapMaxSlippage(token0Reserves, token1Reserves, offPegPerc);

        UniVars memory uniVars = UniVars({
          yamsToUni: tokens_to_max_slippage, // how many yams uniswap needs
          amountFromReserves: excess, // how much of yamsToUni comes from reserves
          mintToReserves: 0 // how much yams protocol mints to reserves
        });

        // tries to sell all mint + excess
        // falls back to selling some of mint and all of excess
        // if all else fails, sells portion of excess
        // upon pair.swap, `uniswapV2Call` is called by the uniswap pair contract
        if (isToken0) {
            if (tokens_to_max_slippage > mintAmount.add(excess)) {
                // we already have performed a safemath check on mintAmount+excess
                // so we dont need to continue using it in this code path

                // can handle selling all of reserves and mint
                uint256 buyTokens = getAmountOut(mintAmount + excess, token0Reserves, token1Reserves);
                uniVars.yamsToUni = mintAmount + excess;
                uniVars.amountFromReserves = excess;
                // call swap using entire mint amount and excess; mint 0 to reserves
                pair.swap(0, buyTokens, address(this), abi.encode(uniVars));
            } else {
                if (tokens_to_max_slippage > excess) {
                    // uniswap can handle entire reserves
                    uint256 buyTokens = getAmountOut(tokens_to_max_slippage, token0Reserves, token1Reserves);

                    // swap up to slippage limit, taking entire yam reserves, and minting part of total
                    uniVars.mintToReserves = mintAmount.sub((tokens_to_max_slippage - excess));
                    pair.swap(0, buyTokens, address(this), abi.encode(uniVars));
                } else {
                    // uniswap cant handle all of excess
                    uint256 buyTokens = getAmountOut(tokens_to_max_slippage, token0Reserves, token1Reserves);
                    uniVars.amountFromReserves = tokens_to_max_slippage;
                    uniVars.mintToReserves = mintAmount;
                    // swap up to slippage limit, taking excess - remainingExcess from reserves, and minting full amount
                    // to reserves
                    pair.swap(0, buyTokens, address(this), abi.encode(uniVars));
                }
            }
        } else {
            if (tokens_to_max_slippage > mintAmount.add(excess)) {
                // can handle all of reserves and mint
                uint256 buyTokens = getAmountOut(mintAmount + excess, token1Reserves, token0Reserves);
                uniVars.yamsToUni = mintAmount + excess;
                uniVars.amountFromReserves = excess;
                // call swap using entire mint amount and excess; mint 0 to reserves
                pair.swap(buyTokens, 0, address(this), abi.encode(uniVars));
            } else {
                if (tokens_to_max_slippage > excess) {
                    // uniswap can handle entire reserves
                    uint256 buyTokens = getAmountOut(tokens_to_max_slippage, token1Reserves, token0Reserves);

                    // swap up to slippage limit, taking entire yam reserves, and minting part of total
                    uniVars.mintToReserves = mintAmount.sub( (tokens_to_max_slippage - excess) );
                    pair.swap(buyTokens, 0, address(this), abi.encode(uniVars));
                } else {
                    // uniswap cant handle all of excess
                    uint256 buyTokens = getAmountOut(tokens_to_max_slippage, token1Reserves, token0Reserves);
                    uniVars.amountFromReserves = tokens_to_max_slippage;
                    uniVars.mintToReserves = mintAmount;
                    // swap up to slippage limit, taking excess - remainingExcess from reserves, and minting full amount
                    // to reserves
                    pair.swap(buyTokens, 0, address(this), abi.encode(uniVars));
                }
            }
        }
    }

    function uniswapMaxSlippage(
        uint256 token0,
        uint256 token1,
        uint256 offPegPerc
    )
      internal
      view
      returns (uint256)
    {
        if (isToken0) {
          if (offPegPerc >= 10**17) {
              // cap slippage
              return token0.mul(maxSlippageFactor).div(BASE);
          } else {
              // in the 5-10% off peg range, slippage is essentially 2*x (where x is percentage of pool to buy).
              // all we care about is not pushing below the peg, so underestimate
              // the amount we can sell by dividing by 3. resulting price impact
              // should be ~= offPegPerc * 2 / 3, which will keep us above the peg
              //
              // this is a conservative heuristic
              return token0.mul(offPegPerc).div(3 * BASE);
          }
        } else {
            if (offPegPerc >= 10**17) {
                return token1.mul(maxSlippageFactor).div(BASE);
            } else {
                return token1.mul(offPegPerc).div(3 * BASE);
            }
        }
    }

    /**
     * @notice given an input amount of an asset and pair reserves, returns the maximum output amount of the other asset
     *
     * @param amountIn input amount of the asset
     * @param reserveIn reserves of the asset being sold
     * @param reserveOut reserves if the asset being purchased
     */

   function getAmountOut(
        uint amountIn,
        uint reserveIn,
        uint reserveOut
    )
        internal
        pure
        returns (uint amountOut)
    {
       require(amountIn > 0, 'UniswapV2Library: INSUFFICIENT_INPUT_AMOUNT');
       require(reserveIn > 0 && reserveOut > 0, 'UniswapV2Library: INSUFFICIENT_LIQUIDITY');
       uint amountInWithFee = amountIn.mul(997);
       uint numerator = amountInWithFee.mul(reserveOut);
       uint denominator = reserveIn.mul(1000).add(amountInWithFee);
       amountOut = numerator / denominator;
   }


    function afterRebase(
        uint256 mintAmount,
        uint256 offPegPerc
    )
        internal
    {
        // update uniswap pairs
        for (uint256 i = 0; i < uniSyncPairs.length; i++) {
            UniswapPair(uniSyncPairs[i]).sync();
        }

        // update balancer pairs
        for (uint256 i = 0; i < balGulpPairs.length; i++) {
            BAL(balGulpPairs[i]).gulp(yamAddress);
        }


        if (mintAmount > 0) {
            buyReserveAndTransfer(
                mintAmount,
                offPegPerc
            );
        }

        // call any extra functions
        for (uint i = 0; i < transactions.length; i++) {
            Transaction storage t = transactions[i];
            if (t.enabled) {
                bool result =
                    externalCall(t.destination, t.data);
                if (!result) {
                    emit TransactionFailed(t.destination, i, t.data);
                    revert("Transaction Failed");
                }
            }
        }
    }


    /**
     * @notice Calculates TWAP from uniswap
     *
     * @dev When liquidity is low, this can be manipulated by an end of block -> next block
     *      attack. We delay the activation of rebases 12 hours after liquidity incentives
     *      to reduce this attack vector. Additional there is very little supply
     *      to be able to manipulate this during that time period of highest vuln.
     */
    function getTWAP()
        internal
        returns (uint256)
    {
        (uint priceCumulative, uint32 blockTimestamp) =
            UniswapV2OracleLibrary.currentCumulativePrices(trade_pair, isToken0);
        (uint priceCumulativeETH, ) =
            UniswapV2OracleLibrary.currentCumulativePrices(eth_usdc_pair, false);
        uint32 timeElapsed = blockTimestamp - blockTimestampLast; // overflow is desired

        // no period check as is done in isRebaseWindow


        // overflow is desired
        uint256 priceAverageYAMETH = uint256(uint224((priceCumulative - priceCumulativeLastYAMETH) / timeElapsed));
        uint256 priceAverageETHUSDC = uint256(uint224((priceCumulativeETH - priceCumulativeLastETHUSDC) / timeElapsed));

        priceCumulativeLastYAMETH = priceCumulative;
        priceCumulativeLastETHUSDC = priceCumulativeETH;
        blockTimestampLast = blockTimestamp;

        // BASE is on order of 1e18, which takes 2^60 bits
        // multiplication will revert if priceAverage > 2^196
        // (which it can because it overflows intentially)
        uint256 YAMETHprice;
        uint256 ETHprice;
        if (priceAverageYAMETH > uint192(-1)) {
           // eat loss of precision
           // effectively: (x / 2**112) * 1e18
           YAMETHprice = (priceAverageYAMETH >> 112) * BASE;
        } else {
            // cant overflow
            // effectively: (x * 1e18 / 2**112)
            YAMETHprice = (priceAverageYAMETH * BASE) >> 112;
        }


        if (priceAverageETHUSDC > uint192(-1)) {
            ETHprice = (priceAverageETHUSDC >> 112) * BASE;
        } else {
            ETHprice = (priceAverageETHUSDC * BASE) >> 112;
        }


        return YAMETHprice.mul(ETHprice).div(10**6);
    }

    /**
     * @notice Calculates current TWAP from uniswap
     *
     */
    function getCurrentTWAP()
        public
        view
        returns (uint256)
    {
        (uint priceCumulative, uint32 blockTimestamp) =
           UniswapV2OracleLibrary.currentCumulativePrices(trade_pair, isToken0);
        (uint priceCumulativeETH, ) =
           UniswapV2OracleLibrary.currentCumulativePrices(eth_usdc_pair, false);

        uint32 timeElapsed = blockTimestamp - blockTimestampLast; // overflow is desired

       // no period check as is done in isRebaseWindow

       uint256 priceAverageYAMETH = uint256(uint224((priceCumulative - priceCumulativeLastYAMETH) / timeElapsed));
       uint256 priceAverageETHUSDC = uint256(uint224((priceCumulativeETH - priceCumulativeLastETHUSDC) / timeElapsed));

       // BASE is on order of 1e18, which takes 2^60 bits
       // multiplication will revert if priceAverage > 2^196
       // (which it can because it overflows intentially)
       uint256 YAMETHprice;
       uint256 ETHprice;
       if (priceAverageYAMETH > uint192(-1)) {
          // eat loss of precision
          // effectively: (x / 2**112) * 1e18
          YAMETHprice = (priceAverageYAMETH >> 112) * BASE;
       } else {
         // cant overflow
         // effectively: (x * 1e18 / 2**112)
         YAMETHprice = (priceAverageYAMETH * BASE) >> 112;
       }


       if (priceAverageETHUSDC > uint192(-1)) {
          ETHprice = (priceAverageETHUSDC >> 112) * BASE;
       } else {
          ETHprice = (priceAverageETHUSDC * BASE) >> 112;
       }


       return YAMETHprice.mul(ETHprice).div(10**6);
    }

    /**
     * @notice Sets the deviation threshold fraction. If the exchange rate given by the market
     *         oracle is within this fractional distance from the targetRate, then no supply
     *         modifications are made.
     * @param deviationThreshold_ The new exchange rate threshold fraction.
     */
    function setDeviationThreshold(uint256 deviationThreshold_)
        external
        onlyGov
    {
        require(deviationThreshold > 0);
        uint256 oldDeviationThreshold = deviationThreshold;
        deviationThreshold = deviationThreshold_;
        emit NewDeviationThreshold(oldDeviationThreshold, deviationThreshold_);
    }

    /**
     * @notice Sets the rebase lag parameter.
               It is used to dampen the applied supply adjustment by 1 / rebaseLag
               If the rebase lag R, equals 1, the smallest value for R, then the full supply
               correction is applied on each rebase cycle.
               If it is greater than 1, then a correction of 1/R of is applied on each rebase.
     * @param rebaseLag_ The new rebase lag parameter.
     */
    function setRebaseLag(uint256 rebaseLag_)
        external
        onlyGov
    {
        require(rebaseLag_ > 0);
        rebaseLag = rebaseLag_;
    }

    /**
     * @notice Sets the targetRate parameter.
     * @param targetRate_ The new target rate parameter.
     */
    function setTargetRate(uint256 targetRate_)
        external
        onlyGov
    {
        require(targetRate_ > 0);
        targetRate = targetRate_;
    }

    /**
     * @notice Sets the parameters which control the timing and frequency of
     *         rebase operations.
     *         a) the minimum time period that must elapse between rebase cycles.
     *         b) the rebase window offset parameter.
     *         c) the rebase window length parameter.
     * @param minRebaseTimeIntervalSec_ More than this much time must pass between rebase
     *        operations, in seconds.
     * @param rebaseWindowOffsetSec_ The number of seconds from the beginning of
              the rebase interval, where the rebase window begins.
     * @param rebaseWindowLengthSec_ The length of the rebase window in seconds.
     */
    function setRebaseTimingParameters(
        uint256 minRebaseTimeIntervalSec_,
        uint256 rebaseWindowOffsetSec_,
        uint256 rebaseWindowLengthSec_)
        external
        onlyGov
    {
        require(minRebaseTimeIntervalSec_ > 0);
        require(rebaseWindowOffsetSec_ < minRebaseTimeIntervalSec_);
        require(rebaseWindowOffsetSec_ + rebaseWindowLengthSec_ < minRebaseTimeIntervalSec_);
        minRebaseTimeIntervalSec = minRebaseTimeIntervalSec_;
        rebaseWindowOffsetSec = rebaseWindowOffsetSec_;
        rebaseWindowLengthSec = rebaseWindowLengthSec_;
    }

    /**
     * @return If the latest block timestamp is within the rebase time window it, returns true.
     *         Otherwise, returns false.
     */
    function inRebaseWindow() public view returns (bool) {

        // rebasing is delayed until there is a liquid market
        _inRebaseWindow();
        return true;
    }

    function _inRebaseWindow() internal view {

        // rebasing is delayed until there is a liquid market
        require(rebasingActive, "rebasing not active");

        require(now.mod(minRebaseTimeIntervalSec) >= rebaseWindowOffsetSec, "too early");
        require(now.mod(minRebaseTimeIntervalSec) < (rebaseWindowOffsetSec.add(rebaseWindowLengthSec)), "too late");
    }

    /**
     * @return Computes in % how far off market is from peg
     */
    function computeOffPegPerc(uint256 rate)
        private
        view
        returns (uint256, bool)
    {
        if (withinDeviationThreshold(rate)) {
            return (0, false);
        }

        // indexDelta =  (rate - targetRate) / targetRate
        if (rate > targetRate) {
            return (rate.sub(targetRate).mul(BASE).div(targetRate), true);
        } else {
            return (targetRate.sub(rate).mul(BASE).div(targetRate), false);
        }
    }

    /**
     * @param rate The current exchange rate, an 18 decimal fixed point number.
     * @return If the rate is within the deviation threshold from the target rate, returns true.
     *         Otherwise, returns false.
     */
    function withinDeviationThreshold(uint256 rate)
        private
        view
        returns (bool)
    {
        uint256 absoluteDeviationThreshold = targetRate.mul(deviationThreshold)
            .div(10 ** 18);

        return (rate >= targetRate && rate.sub(targetRate) < absoluteDeviationThreshold)
            || (rate < targetRate && targetRate.sub(rate) < absoluteDeviationThreshold);
    }

    /* - Constructor Helpers - */

    // calculates the CREATE2 address for a pair without making any external calls
    function pairFor(
        address factory,
        address token0,
        address token1
    )
        internal
        pure
        returns (address pair)
    {
        pair = address(uint(keccak256(abi.encodePacked(
                hex'ff',
                factory,
                keccak256(abi.encodePacked(token0, token1)),
                hex'96e8ac4277198ff8b6f785478aa9a39f403cb768dd02cbee326c3e7da348845f' // init code hash
            ))));
    }

    function pairForSushi(
        address factory,
        address tokenA,
        address tokenB
    )
        internal
        pure
        returns (address pair)
    {
        (address token0, address token1) = sortTokens(tokenA, tokenB);
        pair = address(uint(keccak256(abi.encodePacked(
                hex'ff',
                factory,
                keccak256(abi.encodePacked(token0, token1)),
                hex'e18a34eb0e04b04f7a0ac29a6e80748dca96319b42c54d679cb821dca90c6303' // init code hash
            ))));
    }

    // returns sorted token addresses, used to handle return values from pairs sorted in this order
    function sortTokens(
        address tokenA,
        address tokenB
    )
        internal
        pure
        returns (address token0, address token1)
    {
        require(tokenA != tokenB, 'UniswapV2Library: IDENTICAL_ADDRESSES');
        (token0, token1) = tokenA < tokenB ? (tokenA, tokenB) : (tokenB, tokenA);
        require(token0 != address(0), 'UniswapV2Library: ZERO_ADDRESS');
    }

    /* -- Rebase helpers -- */

    /**
     * @notice Adds a transaction that gets called for a downstream receiver of rebases
     * @param destination Address of contract destination
     * @param data Transaction data payload
     */
    function addTransaction(address destination, bytes calldata data)
        external
        onlyGov
    {
        transactions.push(Transaction({
            enabled: true,
            destination: destination,
            data: data
        }));
    }


    /**
     * @param index Index of transaction to remove.
     *              Transaction ordering may have changed since adding.
     */
    function removeTransaction(uint index)
        external
        onlyGov
    {
        require(index < transactions.length, "index out of bounds");

        if (index < transactions.length - 1) {
            transactions[index] = transactions[transactions.length - 1];
        }

        transactions.length--;
    }

    /**
     * @param index Index of transaction. Transaction ordering may have changed since adding.
     * @param enabled True for enabled, false for disabled.
     */
    function setTransactionEnabled(uint index, bool enabled)
        external
        onlyGov
    {
        require(index < transactions.length, "index must be in range of stored tx list");
        transactions[index].enabled = enabled;
    }

    /**
     * @dev wrapper to call the encoded transactions on downstream consumers.
     * @param destination Address of destination contract.
     * @param data The encoded data payload.
     * @return True on success
     */
    function externalCall(address destination, bytes memory data)
        internal
        returns (bool)
    {
        bool result;
        assembly {  // solhint-disable-line no-inline-assembly
            // "Allocate" memory for output
            // (0x40 is where "free memory" pointer is stored by convention)
            let outputAddress := mload(0x40)

            // First 32 bytes are the padded length of data, so exclude that
            let dataAddress := add(data, 32)

            result := call(
                // 34710 is the value that solidity is currently emitting
                // It includes callGas (700) + callVeryLow (3, to pay for SUB)
                // + callValueTransferGas (9000) + callNewAccountGas
                // (25000, in case the destination address does not exist and needs creating)
                sub(gas, 34710),


                destination,
                0, // transfer value in wei
                dataAddress,
                mload(data),  // Size of the input, in bytes. Stored in position 0 of the array.
                outputAddress,
                0  // Output is ignored, therefore the output size is zero
            )
        }
        return result;
    }


    // Rescue tokens
    function rescueTokens(
        address token,
        address to,
        uint256 amount
    )
        external
        onlyGov
        returns (bool)
    {
        // transfer to
        SafeERC20.safeTransfer(IERC20(token), to, amount);
    }
}