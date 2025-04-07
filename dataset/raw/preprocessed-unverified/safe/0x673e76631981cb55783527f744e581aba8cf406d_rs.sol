/**
 *Submitted for verification at Etherscan.io on 2020-06-30
*/

/*
   ____            __   __        __   _
  / __/__ __ ___  / /_ / /  ___  / /_ (_)__ __
 _\ \ / // // _ \/ __// _ \/ -_)/ __// / \ \ /
/___/ \_, //_//_/\__//_//_/\__/ \__//_/ /_\_\
     /___/

* Synthetix: BinaryOptionMarketManager.sol
*
* Latest source (may be newer): https://github.com/Synthetixio/synthetix/blob/master/contracts/BinaryOptionMarketManager.sol
* Docs: https://docs.synthetix.io/contracts/BinaryOptionMarketManager
*
* Contract Dependencies: 
*	- IAddressResolver
*	- IBinaryOption
*	- IBinaryOptionMarket
*	- IBinaryOptionMarketManager
*	- IERC20
*	- MixinResolver
*	- Owned
*	- Pausable
*	- SelfDestructible
* Libraries: 
*	- AddressListLib
*	- SafeDecimalMath
*	- SafeMath
*
* MIT License
* ===========
*
* Copyright (c) 2020 Synthetix
*
* Permission is hereby granted, free of charge, to any person obtaining a copy
* of this software and associated documentation files (the "Software"), to deal
* in the Software without restriction, including without limitation the rights
* to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
* copies of the Software, and to permit persons to whom the Software is
* furnished to do so, subject to the following conditions:
*
* The above copyright notice and this permission notice shall be included in all
* copies or substantial portions of the Software.
*
* THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
* IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
* FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
* AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
* LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
* OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
*/

/* ===============================================
* Flattened with Solidifier by Coinage
* 
* https://solidifier.coina.ge
* ===============================================
*/


pragma solidity ^0.5.16;


// https://docs.synthetix.io/contracts/Owned



// Inheritance


// https://docs.synthetix.io/contracts/Pausable
contract Pausable is Owned {
    uint public lastPauseTime;
    bool public paused;

    constructor() internal {
        // This contract is abstract, and thus cannot be instantiated directly
        require(owner != address(0), "Owner must be set");
        // Paused will be false, and lastPauseTime will be 0 upon initialisation
    }

    /**
     * @notice Change the paused state of the contract
     * @dev Only the contract owner may call this.
     */
    function setPaused(bool _paused) external onlyOwner {
        // Ensure we're actually changing the state before we do anything
        if (_paused == paused) {
            return;
        }

        // Set our paused state.
        paused = _paused;

        // If applicable, set the last pause time.
        if (paused) {
            lastPauseTime = now;
        }

        // Let everyone know that our pause state has changed.
        emit PauseChanged(paused);
    }

    event PauseChanged(bool isPaused);

    modifier notPaused {
        require(!paused, "This action cannot be performed while the contract is paused");
        _;
    }
}


// Inheritance


// https://docs.synthetix.io/contracts/SelfDestructible
contract SelfDestructible is Owned {
    uint public constant SELFDESTRUCT_DELAY = 4 weeks;

    uint public initiationTime;
    bool public selfDestructInitiated;

    address public selfDestructBeneficiary;

    constructor() internal {
        // This contract is abstract, and thus cannot be instantiated directly
        require(owner != address(0), "Owner must be set");
        selfDestructBeneficiary = owner;
        emit SelfDestructBeneficiaryUpdated(owner);
    }

    /**
     * @notice Set the beneficiary address of this contract.
     * @dev Only the contract owner may call this. The provided beneficiary must be non-null.
     * @param _beneficiary The address to pay any eth contained in this contract to upon self-destruction.
     */
    function setSelfDestructBeneficiary(address payable _beneficiary) external onlyOwner {
        require(_beneficiary != address(0), "Beneficiary must not be zero");
        selfDestructBeneficiary = _beneficiary;
        emit SelfDestructBeneficiaryUpdated(_beneficiary);
    }

    /**
     * @notice Begin the self-destruction counter of this contract.
     * Once the delay has elapsed, the contract may be self-destructed.
     * @dev Only the contract owner may call this.
     */
    function initiateSelfDestruct() external onlyOwner {
        initiationTime = now;
        selfDestructInitiated = true;
        emit SelfDestructInitiated(SELFDESTRUCT_DELAY);
    }

    /**
     * @notice Terminate and reset the self-destruction timer.
     * @dev Only the contract owner may call this.
     */
    function terminateSelfDestruct() external onlyOwner {
        initiationTime = 0;
        selfDestructInitiated = false;
        emit SelfDestructTerminated();
    }

    /**
     * @notice If the self-destruction delay has elapsed, destroy this contract and
     * remit any ether it owns to the beneficiary address.
     * @dev Only the contract owner may call this.
     */
    function selfDestruct() external onlyOwner {
        require(selfDestructInitiated, "Self Destruct not yet initiated");
        require(initiationTime + SELFDESTRUCT_DELAY < now, "Self destruct delay not met");
        emit SelfDestructed(selfDestructBeneficiary);
        selfdestruct(address(uint160(selfDestructBeneficiary)));
    }

    event SelfDestructTerminated();
    event SelfDestructed(address beneficiary);
    event SelfDestructInitiated(uint selfDestructDelay);
    event SelfDestructBeneficiaryUpdated(address newBeneficiary);
}











// Inheritance


// https://docs.synthetix.io/contracts/AddressResolver
contract AddressResolver is Owned, IAddressResolver {
    mapping(bytes32 => address) public repository;

    constructor(address _owner) public Owned(_owner) {}

    /* ========== MUTATIVE FUNCTIONS ========== */

    function importAddresses(bytes32[] calldata names, address[] calldata destinations) external onlyOwner {
        require(names.length == destinations.length, "Input lengths must match");

        for (uint i = 0; i < names.length; i++) {
            repository[names[i]] = destinations[i];
        }
    }

    /* ========== VIEWS ========== */

    function getAddress(bytes32 name) external view returns (address) {
        return repository[name];
    }

    function requireAndGetAddress(bytes32 name, string calldata reason) external view returns (address) {
        address _foundAddress = repository[name];
        require(_foundAddress != address(0), reason);
        return _foundAddress;
    }

    function getSynth(bytes32 key) external view returns (address) {
        IIssuer issuer = IIssuer(repository["Issuer"]);
        require(address(issuer) != address(0), "Cannot find Issuer address");
        return address(issuer.synths(key));
    }
}


// Inheritance


// Internal references


// https://docs.synthetix.io/contracts/MixinResolver
contract MixinResolver is Owned {
    AddressResolver public resolver;

    mapping(bytes32 => address) private addressCache;

    bytes32[] public resolverAddressesRequired;

    uint public constant MAX_ADDRESSES_FROM_RESOLVER = 24;

    constructor(address _resolver, bytes32[MAX_ADDRESSES_FROM_RESOLVER] memory _addressesToCache) internal {
        // This contract is abstract, and thus cannot be instantiated directly
        require(owner != address(0), "Owner must be set");

        for (uint i = 0; i < _addressesToCache.length; i++) {
            if (_addressesToCache[i] != bytes32(0)) {
                resolverAddressesRequired.push(_addressesToCache[i]);
            } else {
                // End early once an empty item is found - assumes there are no empty slots in
                // _addressesToCache
                break;
            }
        }
        resolver = AddressResolver(_resolver);
        // Do not sync the cache as addresses may not be in the resolver yet
    }

    /* ========== SETTERS ========== */
    function setResolverAndSyncCache(AddressResolver _resolver) external onlyOwner {
        resolver = _resolver;

        for (uint i = 0; i < resolverAddressesRequired.length; i++) {
            bytes32 name = resolverAddressesRequired[i];
            // Note: can only be invoked once the resolver has all the targets needed added
            addressCache[name] = resolver.requireAndGetAddress(name, "Resolver missing target");
        }
    }

    /* ========== VIEWS ========== */

    function requireAndGetAddress(bytes32 name, string memory reason) internal view returns (address) {
        address _foundAddress = addressCache[name];
        require(_foundAddress != address(0), reason);
        return _foundAddress;
    }

    // Note: this could be made external in a utility contract if addressCache was made public
    // (used for deployment)
    function isResolverCached(AddressResolver _resolver) external view returns (bool) {
        if (resolver != _resolver) {
            return false;
        }

        // otherwise, check everything
        for (uint i = 0; i < resolverAddressesRequired.length; i++) {
            bytes32 name = resolverAddressesRequired[i];
            // false if our cache is invalid or if the resolver doesn't have the required address
            if (resolver.getAddress(name) != addressCache[name] || addressCache[name] == address(0)) {
                return false;
            }
        }

        return true;
    }

    // Note: can be made external into a utility contract (used for deployment)
    function getResolverAddressesRequired()
        external
        view
        returns (bytes32[MAX_ADDRESSES_FROM_RESOLVER] memory addressesRequired)
    {
        for (uint i = 0; i < resolverAddressesRequired.length; i++) {
            addressesRequired[i] = resolverAddressesRequired[i];
        }
    }

    /* ========== INTERNAL FUNCTIONS ========== */
    function appendToAddressCache(bytes32 name) internal {
        resolverAddressesRequired.push(name);
        require(resolverAddressesRequired.length < MAX_ADDRESSES_FROM_RESOLVER, "Max resolver cache size met");
        // Because this is designed to be called internally in constructors, we don't
        // check the address exists already in the resolver
        addressCache[name] = resolver.getAddress(name);
    }
}

















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



// Libraries


// https://docs.synthetix.io/contracts/SafeDecimalMath



// Inheritance


// Libraries


// Internal references


contract BinaryOption is IERC20, IBinaryOption {
    /* ========== LIBRARIES ========== */

    using SafeMath for uint;
    using SafeDecimalMath for uint;

    /* ========== STATE VARIABLES ========== */

    string public constant name = "SNX Binary Option";
    string public constant symbol = "sOPT";
    uint8 public constant decimals = 18;

    BinaryOptionMarket public market;

    mapping(address => uint) public bidOf;
    uint public totalBids;

    mapping(address => uint) public balanceOf;
    uint public totalSupply;

    // The argument order is allowance[owner][spender]
    mapping(address => mapping(address => uint)) public allowance;

    // Enforce a 1 cent minimum bid balance
    uint internal constant _MINIMUM_BID = 1e16;

    /* ========== CONSTRUCTOR ========== */

    constructor(address initialBidder, uint initialBid) public {
        market = BinaryOptionMarket(msg.sender);
        bidOf[initialBidder] = initialBid;
        totalBids = initialBid;
    }

    /* ========== VIEWS ========== */

    function _claimableBalanceOf(
        uint _bid,
        uint price,
        uint exercisableDeposits
    ) internal view returns (uint) {
        uint owed = _bid.divideDecimal(price);
        uint supply = _totalClaimableSupply(exercisableDeposits);

        /* The last claimant might be owed slightly more or less than the actual remaining deposit
           based on rounding errors with the price.
           Therefore if the user's bid is the entire rest of the pot, just give them everything that's left. */
        if (_bid == totalBids && _bid != 0) {
            return supply;
        }

        /* If somehow a user who is not the last bidder is owed more than what's available,
           subsequent bidders will be disadvantaged. Given that the minimum bid is 10^16 wei,
           this should never occur in reality. */
        assert(owed <= supply);
        return owed;
    }

    function claimableBalanceOf(address account) external view returns (uint) {
        (uint price, uint exercisableDeposits) = market.senderPriceAndExercisableDeposits();
        return _claimableBalanceOf(bidOf[account], price, exercisableDeposits);
    }

    function _totalClaimableSupply(uint exercisableDeposits) internal view returns (uint) {
        uint _totalSupply = totalSupply;
        // We'll avoid throwing an exception here to avoid breaking any dapps, but this case
        // should never occur given the minimum bid size.
        if (exercisableDeposits <= _totalSupply) {
            return 0;
        }
        return exercisableDeposits.sub(_totalSupply);
    }

    function totalClaimableSupply() external view returns (uint) {
        return _totalClaimableSupply(market.exercisableDeposits());
    }

    /* ========== MUTATIVE FUNCTIONS ========== */

    function _requireMinimumBid(uint bid) internal pure returns (uint) {
        require(bid >= _MINIMUM_BID || bid == 0, "Balance < $0.01");
        return bid;
    }

    // This must only be invoked during bidding.
    function bid(address bidder, uint newBid) external onlyMarket {
        bidOf[bidder] = _requireMinimumBid(bidOf[bidder].add(newBid));
        totalBids = totalBids.add(newBid);
    }

    // This must only be invoked during bidding.
    function refund(address bidder, uint newRefund) external onlyMarket {
        // The safe subtraction will catch refunds that are too large.
        bidOf[bidder] = _requireMinimumBid(bidOf[bidder].sub(newRefund));
        totalBids = totalBids.sub(newRefund);
    }

    // This must only be invoked after bidding.
    function claim(
        address claimant,
        uint price,
        uint depositsRemaining
    ) external onlyMarket returns (uint optionsClaimed) {
        uint _bid = bidOf[claimant];
        uint claimable = _claimableBalanceOf(_bid, price, depositsRemaining);
        // No options to claim? Nothing happens.
        if (claimable == 0) {
            return 0;
        }

        totalBids = totalBids.sub(_bid);
        bidOf[claimant] = 0;

        totalSupply = totalSupply.add(claimable);
        balanceOf[claimant] = balanceOf[claimant].add(claimable); // Increment rather than assigning since a transfer may have occurred.

        emit Transfer(address(0), claimant, claimable);
        emit Issued(claimant, claimable);

        return claimable;
    }

    // This must only be invoked after maturity.
    function exercise(address claimant) external onlyMarket {
        uint balance = balanceOf[claimant];

        if (balance == 0) {
            return;
        }

        balanceOf[claimant] = 0;
        totalSupply = totalSupply.sub(balance);

        emit Transfer(claimant, address(0), balance);
        emit Burned(claimant, balance);
    }

    // This must only be invoked after the exercise window is complete.
    // Note that any options which have not been exercised will linger.
    function expire(address payable beneficiary) external onlyMarket {
        selfdestruct(beneficiary);
    }

    /* ---------- ERC20 Functions ---------- */

    // This should only operate after bidding;
    // Since options can't be claimed until after bidding, all balances are zero until that time.
    // So we don't need to explicitly check the timestamp to prevent transfers.
    function _transfer(
        address _from,
        address _to,
        uint _value
    ) internal returns (bool success) {
        market.requireActiveAndUnpaused();
        require(_to != address(0) && _to != address(this), "Invalid address");

        uint fromBalance = balanceOf[_from];
        require(_value <= fromBalance, "Insufficient balance");

        balanceOf[_from] = fromBalance.sub(_value);
        balanceOf[_to] = balanceOf[_to].add(_value);

        emit Transfer(_from, _to, _value);
        return true;
    }

    function transfer(address _to, uint _value) external returns (bool success) {
        return _transfer(msg.sender, _to, _value);
    }

    function transferFrom(
        address _from,
        address _to,
        uint _value
    ) external returns (bool success) {
        uint fromAllowance = allowance[_from][msg.sender];
        require(_value <= fromAllowance, "Insufficient allowance");

        allowance[_from][msg.sender] = fromAllowance.sub(_value);
        return _transfer(_from, _to, _value);
    }

    function approve(address _spender, uint _value) external returns (bool success) {
        require(_spender != address(0));
        allowance[msg.sender][_spender] = _value;
        emit Approval(msg.sender, _spender, _value);
        return true;
    }

    /* ========== MODIFIERS ========== */

    modifier onlyMarket() {
        require(msg.sender == address(market), "Only market allowed");
        _;
    }

    /* ========== EVENTS ========== */

    event Issued(address indexed account, uint value);
    event Burned(address indexed account, uint value);
    event Transfer(address indexed from, address indexed to, uint value);
    event Approval(address indexed owner, address indexed spender, uint value);
}


// https://docs.synthetix.io/contracts/source/interfaces/IExchangeRates






// Inheritance


// Libraries


// Internal references


contract BinaryOptionMarket is Owned, MixinResolver, IBinaryOptionMarket {
    /* ========== LIBRARIES ========== */

    using SafeMath for uint;
    using SafeDecimalMath for uint;

    /* ========== TYPES ========== */

    struct Options {
        BinaryOption long;
        BinaryOption short;
    }

    struct Prices {
        uint long;
        uint short;
    }

    struct Times {
        uint biddingEnd;
        uint maturity;
        uint expiry;
    }

    struct OracleDetails {
        bytes32 key;
        uint strikePrice;
        uint finalPrice;
    }

    /* ========== STATE VARIABLES ========== */

    Options public options;
    Prices public prices;
    Times public times;
    OracleDetails public oracleDetails;
    BinaryOptionMarketManager.Fees public fees;
    BinaryOptionMarketManager.CreatorLimits public creatorLimits;

    // `deposited` tracks the sum of open bids on short and long, plus withheld refund fees.
    // This must explicitly be kept, in case tokens are transferred to the contract directly.
    uint public deposited;
    address public creator;
    bool public resolved;

    uint internal _feeMultiplier;

    /* ---------- Address Resolver Configuration ---------- */

    bytes32 internal constant CONTRACT_SYSTEMSTATUS = "SystemStatus";
    bytes32 internal constant CONTRACT_EXRATES = "ExchangeRates";
    bytes32 internal constant CONTRACT_SYNTHSUSD = "SynthsUSD";
    bytes32 internal constant CONTRACT_FEEPOOL = "FeePool";

    bytes32[24] internal addressesToCache = [CONTRACT_SYSTEMSTATUS, CONTRACT_EXRATES, CONTRACT_SYNTHSUSD, CONTRACT_FEEPOOL];

    /* ========== CONSTRUCTOR ========== */

    constructor(
        address _owner,
        address _creator,
        uint[2] memory _creatorLimits, // [capitalRequirement, skewLimit]
        bytes32 _oracleKey,
        uint _strikePrice,
        uint[3] memory _times, // [biddingEnd, maturity, expiry]
        uint[2] memory _bids, // [longBid, shortBid]
        uint[3] memory _fees // [poolFee, creatorFee, refundFee]
    )
        public
        Owned(_owner)
        MixinResolver(_owner, addressesToCache) // The resolver is initially set to the owner, but it will be set correctly when the cache is synchronised
    {
        creator = _creator;
        creatorLimits = BinaryOptionMarketManager.CreatorLimits(_creatorLimits[0], _creatorLimits[1]);

        oracleDetails = OracleDetails(_oracleKey, _strikePrice, 0);
        times = Times(_times[0], _times[1], _times[2]);

        (uint longBid, uint shortBid) = (_bids[0], _bids[1]);
        _checkCreatorLimits(longBid, shortBid);

        // Note that the initial deposit of synths must be made by the manager, otherwise the contract's assumed
        // deposits will fall out of sync with its actual balance. Similarly the total system deposits must be updated in the manager.
        // A balance check isn't performed here since the manager doesn't know the address of the new contract until after it is created.
        uint initialDeposit = longBid.add(shortBid);
        deposited = initialDeposit;

        (uint poolFee, uint creatorFee) = (_fees[0], _fees[1]);
        fees = BinaryOptionMarketManager.Fees(poolFee, creatorFee, _fees[2]);
        _feeMultiplier = SafeDecimalMath.unit().sub(poolFee.add(creatorFee));

        // Compute the prices now that the fees and deposits have been set.
        _updatePrices(longBid, shortBid, initialDeposit);

        // Instantiate the options themselves
        options.long = new BinaryOption(_creator, longBid);
        options.short = new BinaryOption(_creator, shortBid);
    }

    /* ========== VIEWS ========== */

    /* ---------- External Contracts ---------- */

    function _systemStatus() internal view returns (ISystemStatus) {
        return ISystemStatus(requireAndGetAddress(CONTRACT_SYSTEMSTATUS, "Missing SystemStatus"));
    }

    function _exchangeRates() internal view returns (IExchangeRates) {
        return IExchangeRates(requireAndGetAddress(CONTRACT_EXRATES, "Missing ExchangeRates"));
    }

    function _sUSD() internal view returns (IERC20) {
        return IERC20(requireAndGetAddress(CONTRACT_SYNTHSUSD, "Missing SynthsUSD"));
    }

    function _feePool() internal view returns (IFeePool) {
        return IFeePool(requireAndGetAddress(CONTRACT_FEEPOOL, "Missing FeePool"));
    }

    function _manager() internal view returns (BinaryOptionMarketManager) {
        return BinaryOptionMarketManager(owner);
    }

    /* ---------- Phases ---------- */

    function _biddingEnded() internal view returns (bool) {
        return times.biddingEnd < now;
    }

    function _matured() internal view returns (bool) {
        return times.maturity < now;
    }

    function _expired() internal view returns (bool) {
        return resolved && (times.expiry < now || deposited == 0);
    }

    function phase() external view returns (Phase) {
        if (!_biddingEnded()) {
            return Phase.Bidding;
        }
        if (!_matured()) {
            return Phase.Trading;
        }
        if (!_expired()) {
            return Phase.Maturity;
        }
        return Phase.Expiry;
    }

    /* ---------- Market Resolution ---------- */

    function _oraclePriceAndTimestamp() internal view returns (uint price, uint updatedAt) {
        return _exchangeRates().rateAndUpdatedTime(oracleDetails.key);
    }

    function oraclePriceAndTimestamp() external view returns (uint price, uint updatedAt) {
        return _oraclePriceAndTimestamp();
    }

    function _isFreshPriceUpdateTime(uint timestamp) internal view returns (bool) {
        (uint maxOraclePriceAge, , ) = _manager().durations();
        return (times.maturity.sub(maxOraclePriceAge)) <= timestamp;
    }

    function canResolve() external view returns (bool) {
        (, uint updatedAt) = _oraclePriceAndTimestamp();
        return !resolved && _matured() && _isFreshPriceUpdateTime(updatedAt);
    }

    function _result() internal view returns (Side) {
        uint price;
        if (resolved) {
            price = oracleDetails.finalPrice;
        } else {
            (price, ) = _oraclePriceAndTimestamp();
        }

        return oracleDetails.strikePrice <= price ? Side.Long : Side.Short;
    }

    function result() external view returns (Side) {
        return _result();
    }

    /* ---------- Option Prices ---------- */

    function _computePrices(
        uint longBids,
        uint shortBids,
        uint _deposited
    ) internal view returns (uint long, uint short) {
        require(longBids != 0 && shortBids != 0, "Bids must be nonzero");
        uint optionsPerSide = _exercisableDeposits(_deposited);

        // The math library rounds up on an exact half-increment -- the price on one side may be an increment too high,
        // but this only implies a tiny extra quantity will go to fees.
        return (longBids.divideDecimalRound(optionsPerSide), shortBids.divideDecimalRound(optionsPerSide));
    }

    function senderPriceAndExercisableDeposits() external view returns (uint price, uint exercisable) {
        exercisable = _exercisableDeposits(deposited);
        if (msg.sender == address(options.long)) {
            price = prices.long;
        } else if (msg.sender == address(options.short)) {
            price = prices.short;
        } else {
            revert("Sender is not an option");
        }
    }

    function pricesAfterBidOrRefund(
        Side side,
        uint value,
        bool refund
    ) external view returns (uint long, uint short) {
        (uint longTotalBids, uint shortTotalBids) = _totalBids();
        // prettier-ignore
        function(uint, uint) pure returns (uint) operation = refund ? SafeMath.sub : SafeMath.add;

        if (side == Side.Long) {
            longTotalBids = operation(longTotalBids, value);
        } else {
            shortTotalBids = operation(shortTotalBids, value);
        }

        if (refund) {
            value = value.multiplyDecimalRound(SafeDecimalMath.unit().sub(fees.refundFee));
        }
        return _computePrices(longTotalBids, shortTotalBids, operation(deposited, value));
    }

    // Returns zero if the result would be negative. See the docs for the formulae this implements.
    function bidOrRefundForPrice(
        Side bidSide,
        Side priceSide,
        uint price,
        bool refund
    ) external view returns (uint) {
        uint adjustedPrice = price.multiplyDecimalRound(_feeMultiplier);
        uint bids = _option(priceSide).totalBids();
        uint _deposited = deposited;
        uint unit = SafeDecimalMath.unit();
        uint refundFeeMultiplier = unit.sub(fees.refundFee);

        if (bidSide == priceSide) {
            uint depositedByPrice = _deposited.multiplyDecimalRound(adjustedPrice);

            // For refunds, the numerator is the negative of the bid case and,
            // in the denominator the adjusted price has an extra factor of (1 - the refundFee).
            if (refund) {
                (depositedByPrice, bids) = (bids, depositedByPrice);
                adjustedPrice = adjustedPrice.multiplyDecimalRound(refundFeeMultiplier);
            }

            // The adjusted price is guaranteed to be less than 1: all its factors are also less than 1.
            return _subToZero(depositedByPrice, bids).divideDecimalRound(unit.sub(adjustedPrice));
        } else {
            uint bidsPerPrice = bids.divideDecimalRound(adjustedPrice);

            // For refunds, the numerator is the negative of the bid case.
            if (refund) {
                (bidsPerPrice, _deposited) = (_deposited, bidsPerPrice);
            }

            uint value = _subToZero(bidsPerPrice, _deposited);
            return refund ? value.divideDecimalRound(refundFeeMultiplier) : value;
        }
    }

    /* ---------- Option Balances and Bids ---------- */

    function _bidsOf(address account) internal view returns (uint long, uint short) {
        return (options.long.bidOf(account), options.short.bidOf(account));
    }

    function bidsOf(address account) external view returns (uint long, uint short) {
        return _bidsOf(account);
    }

    function _totalBids() internal view returns (uint long, uint short) {
        return (options.long.totalBids(), options.short.totalBids());
    }

    function totalBids() external view returns (uint long, uint short) {
        return _totalBids();
    }

    function _claimableBalancesOf(address account) internal view returns (uint long, uint short) {
        return (options.long.claimableBalanceOf(account), options.short.claimableBalanceOf(account));
    }

    function claimableBalancesOf(address account) external view returns (uint long, uint short) {
        return _claimableBalancesOf(account);
    }

    function totalClaimableSupplies() external view returns (uint long, uint short) {
        return (options.long.totalClaimableSupply(), options.short.totalClaimableSupply());
    }

    function _balancesOf(address account) internal view returns (uint long, uint short) {
        return (options.long.balanceOf(account), options.short.balanceOf(account));
    }

    function balancesOf(address account) external view returns (uint long, uint short) {
        return _balancesOf(account);
    }

    function totalSupplies() external view returns (uint long, uint short) {
        return (options.long.totalSupply(), options.short.totalSupply());
    }

    function _exercisableDeposits(uint _deposited) internal view returns (uint) {
        // Fees are deducted at resolution, so remove them if we're still bidding or trading.
        return resolved ? _deposited : _deposited.multiplyDecimalRound(_feeMultiplier);
    }

    function exercisableDeposits() external view returns (uint) {
        return _exercisableDeposits(deposited);
    }

    /* ---------- Utilities ---------- */

    function _chooseSide(
        Side side,
        uint longValue,
        uint shortValue
    ) internal pure returns (uint) {
        if (side == Side.Long) {
            return longValue;
        }
        return shortValue;
    }

    function _option(Side side) internal view returns (BinaryOption) {
        if (side == Side.Long) {
            return options.long;
        }
        return options.short;
    }

    // Returns zero if the result would be negative.
    function _subToZero(uint a, uint b) internal pure returns (uint) {
        return a < b ? 0 : a.sub(b);
    }

    function _checkCreatorLimits(uint longBid, uint shortBid) internal view {
        uint totalBid = longBid.add(shortBid);
        require(creatorLimits.capitalRequirement <= totalBid, "Insufficient capital");
        uint skewLimit = creatorLimits.skewLimit;
        require(
            skewLimit <= longBid.divideDecimal(totalBid) && skewLimit <= shortBid.divideDecimal(totalBid),
            "Bids too skewed"
        );
    }

    function _incrementDeposited(uint value) internal returns (uint _deposited) {
        _deposited = deposited.add(value);
        deposited = _deposited;
        _manager().incrementTotalDeposited(value);
    }

    function _decrementDeposited(uint value) internal returns (uint _deposited) {
        _deposited = deposited.sub(value);
        deposited = _deposited;
        _manager().decrementTotalDeposited(value);
    }

    function _requireManagerNotPaused() internal view {
        require(!_manager().paused(), "This action cannot be performed while the contract is paused");
    }

    function requireActiveAndUnpaused() external view {
        _systemStatus().requireSystemActive();
        _requireManagerNotPaused();
    }

    /* ========== MUTATIVE FUNCTIONS ========== */

    /* ---------- Bidding and Refunding ---------- */

    function _updatePrices(
        uint longBids,
        uint shortBids,
        uint _deposited
    ) internal {
        (uint256 longPrice, uint256 shortPrice) = _computePrices(longBids, shortBids, _deposited);
        prices = Prices(longPrice, shortPrice);
        emit PricesUpdated(longPrice, shortPrice);
    }

    function bid(Side side, uint value) external duringBidding {
        if (value == 0) {
            return;
        }

        _option(side).bid(msg.sender, value);
        emit Bid(side, msg.sender, value);

        uint _deposited = _incrementDeposited(value);
        _sUSD().transferFrom(msg.sender, address(this), value);

        (uint longTotalBids, uint shortTotalBids) = _totalBids();
        _updatePrices(longTotalBids, shortTotalBids, _deposited);
    }

    function refund(Side side, uint value) external duringBidding returns (uint refundMinusFee) {
        if (value == 0) {
            return 0;
        }

        // Require the market creator to leave sufficient capital in the market.
        if (msg.sender == creator) {
            (uint thisBid, uint thatBid) = _bidsOf(msg.sender);
            if (side == Side.Short) {
                (thisBid, thatBid) = (thatBid, thisBid);
            }
            _checkCreatorLimits(thisBid.sub(value), thatBid);
        }

        // Safe subtraction here and in related contracts will fail if either the
        // total supply, deposits, or wallet balance are too small to support the refund.
        refundMinusFee = value.multiplyDecimalRound(SafeDecimalMath.unit().sub(fees.refundFee));

        _option(side).refund(msg.sender, value);
        emit Refund(side, msg.sender, refundMinusFee, value.sub(refundMinusFee));

        uint _deposited = _decrementDeposited(refundMinusFee);
        _sUSD().transfer(msg.sender, refundMinusFee);

        (uint longTotalBids, uint shortTotalBids) = _totalBids();
        _updatePrices(longTotalBids, shortTotalBids, _deposited);
    }

    /* ---------- Market Resolution ---------- */

    function resolve() external onlyOwner afterMaturity systemActive managerNotPaused {
        require(!resolved, "Market already resolved");

        // We don't need to perform stale price checks, so long as the price was
        // last updated recently enough before the maturity date.
        (uint price, uint updatedAt) = _oraclePriceAndTimestamp();
        require(_isFreshPriceUpdateTime(updatedAt), "Price is stale");

        oracleDetails.finalPrice = price;
        resolved = true;

        // Now remit any collected fees.
        // Since the constructor enforces that creatorFee + poolFee < 1, the balance
        // in the contract will be sufficient to cover these transfers.
        IERC20 sUSD = _sUSD();

        uint _deposited = deposited;
        uint poolFees = _deposited.multiplyDecimalRound(fees.poolFee);
        uint creatorFees = _deposited.multiplyDecimalRound(fees.creatorFee);
        _decrementDeposited(creatorFees.add(poolFees));
        sUSD.transfer(_feePool().FEE_ADDRESS(), poolFees);
        sUSD.transfer(creator, creatorFees);

        emit MarketResolved(_result(), price, updatedAt, deposited, poolFees, creatorFees);
    }

    /* ---------- Claiming and Exercising Options ---------- */

    function _claimOptions()
        internal
        systemActive
        managerNotPaused
        afterBidding
        returns (uint longClaimed, uint shortClaimed)
    {
        uint exercisable = _exercisableDeposits(deposited);
        uint longOptions = options.long.claim(msg.sender, prices.long, exercisable);
        uint shortOptions = options.short.claim(msg.sender, prices.short, exercisable);

        require(longOptions != 0 || shortOptions != 0, "Nothing to claim");
        emit OptionsClaimed(msg.sender, longOptions, shortOptions);
        return (longOptions, shortOptions);
    }

    function claimOptions() external returns (uint longClaimed, uint shortClaimed) {
        return _claimOptions();
    }

    function exerciseOptions() external returns (uint) {
        // The market must be resolved if it has not been.
        if (!resolved) {
            _manager().resolveMarket(address(this));
        }

        // If there are options to be claimed, claim them and proceed.
        (uint claimableLong, uint claimableShort) = _claimableBalancesOf(msg.sender);
        if (claimableLong != 0 || claimableShort != 0) {
            _claimOptions();
        }

        // If the account holds no options, revert.
        (uint longBalance, uint shortBalance) = _balancesOf(msg.sender);
        require(longBalance != 0 || shortBalance != 0, "Nothing to exercise");

        // Each option only needs to be exercised if the account holds any of it.
        if (longBalance != 0) {
            options.long.exercise(msg.sender);
        }
        if (shortBalance != 0) {
            options.short.exercise(msg.sender);
        }

        // Only pay out the side that won.
        uint payout = _chooseSide(_result(), longBalance, shortBalance);
        emit OptionsExercised(msg.sender, payout);
        if (payout != 0) {
            _decrementDeposited(payout);
            _sUSD().transfer(msg.sender, payout);
        }
        return payout;
    }

    /* ---------- Market Expiry ---------- */

    function expire(address payable beneficiary) external onlyOwner {
        require(_expired(), "Unexpired options remaining");

        uint _deposited = deposited;
        if (_deposited != 0) {
            _decrementDeposited(_deposited);
        }
        // Transfer the balance rather than the deposit value in case there are any synths left over
        // from direct transfers.
        IERC20 sUSD = _sUSD();
        uint balance = sUSD.balanceOf(address(this));
        if (balance != 0) {
            sUSD.transfer(beneficiary, balance);
        }

        // Destroy the option tokens before destroying the market itself.
        options.long.expire(beneficiary);
        options.short.expire(beneficiary);

        // Good night
        selfdestruct(beneficiary);
    }

    /* ========== MODIFIERS ========== */

    modifier duringBidding() {
        require(!_biddingEnded(), "Bidding inactive");
        _;
    }

    modifier afterBidding() {
        require(_biddingEnded(), "Bidding incomplete");
        _;
    }

    modifier afterMaturity() {
        require(_matured(), "Not yet mature");
        _;
    }

    modifier systemActive() {
        _systemStatus().requireSystemActive();
        _;
    }

    modifier managerNotPaused() {
        _requireManagerNotPaused();
        _;
    }

    /* ========== EVENTS ========== */

    event Bid(Side side, address indexed account, uint value);
    event Refund(Side side, address indexed account, uint value, uint fee);
    event PricesUpdated(uint longPrice, uint shortPrice);
    event MarketResolved(
        Side result,
        uint oraclePrice,
        uint oracleTimestamp,
        uint deposited,
        uint poolFees,
        uint creatorFees
    );
    event OptionsClaimed(address indexed account, uint longOptions, uint shortOptions);
    event OptionsExercised(address indexed account, uint value);
}


// Inheritance


// Internal references


contract BinaryOptionMarketFactory is Owned, SelfDestructible, MixinResolver {
    /* ========== STATE VARIABLES ========== */

    /* ---------- Address Resolver Configuration ---------- */

    bytes32 internal constant CONTRACT_BINARYOPTIONMARKETMANAGER = "BinaryOptionMarketManager";

    bytes32[24] internal addressesToCache = [CONTRACT_BINARYOPTIONMARKETMANAGER];

    /* ========== CONSTRUCTOR ========== */

    constructor(address _owner, address _resolver)
        public
        Owned(_owner)
        SelfDestructible()
        MixinResolver(_resolver, addressesToCache)
    {}

    /* ========== VIEWS ========== */

    /* ---------- Related Contracts ---------- */

    function _manager() internal view returns (address) {
        return requireAndGetAddress(CONTRACT_BINARYOPTIONMARKETMANAGER, "Missing BinaryOptionMarketManager address");
    }

    /* ========== MUTATIVE FUNCTIONS ========== */

    function createMarket(
        address creator,
        uint[2] calldata creatorLimits,
        bytes32 oracleKey,
        uint strikePrice,
        uint[3] calldata times, // [biddingEnd, maturity, expiry]
        uint[2] calldata bids, // [longBid, shortBid]
        uint[3] calldata fees // [poolFee, creatorFee, refundFee]
    ) external returns (BinaryOptionMarket) {
        address manager = _manager();
        require(address(manager) == msg.sender, "Only permitted by the manager.");

        return new BinaryOptionMarket(manager, creator, creatorLimits, oracleKey, strikePrice, times, bids, fees);
    }
}





// Inheritance


// Libraries


// Internal references


contract BinaryOptionMarketManager is Owned, Pausable, SelfDestructible, MixinResolver, IBinaryOptionMarketManager {
    /* ========== LIBRARIES ========== */

    using SafeMath for uint;
    using AddressListLib for AddressListLib.AddressList;

    /* ========== TYPES ========== */

    struct Fees {
        uint poolFee;
        uint creatorFee;
        uint refundFee;
    }

    struct Durations {
        uint maxOraclePriceAge;
        uint expiryDuration;
        uint maxTimeToMaturity;
    }

    struct CreatorLimits {
        uint capitalRequirement;
        uint skewLimit;
    }

    /* ========== STATE VARIABLES ========== */

    Fees public fees;
    Durations public durations;
    CreatorLimits public creatorLimits;

    bool public marketCreationEnabled = true;
    uint public totalDeposited;

    AddressListLib.AddressList internal _activeMarkets;
    AddressListLib.AddressList internal _maturedMarkets;

    BinaryOptionMarketManager internal _migratingManager;

    /* ---------- Address Resolver Configuration ---------- */

    bytes32 internal constant CONTRACT_SYSTEMSTATUS = "SystemStatus";
    bytes32 internal constant CONTRACT_SYNTHSUSD = "SynthsUSD";
    bytes32 internal constant CONTRACT_EXRATES = "ExchangeRates";
    bytes32 internal constant CONTRACT_BINARYOPTIONMARKETFACTORY = "BinaryOptionMarketFactory";

    bytes32[24] internal addressesToCache = [
        CONTRACT_SYSTEMSTATUS,
        CONTRACT_SYNTHSUSD,
        CONTRACT_EXRATES,
        CONTRACT_BINARYOPTIONMARKETFACTORY
    ];

    /* ========== CONSTRUCTOR ========== */

    constructor(
        address _owner,
        address _resolver,
        uint _maxOraclePriceAge,
        uint _expiryDuration,
        uint _maxTimeToMaturity,
        uint _creatorCapitalRequirement,
        uint _creatorSkewLimit,
        uint _poolFee,
        uint _creatorFee,
        uint _refundFee
    ) public Owned(_owner) Pausable() SelfDestructible() MixinResolver(_resolver, addressesToCache) {
        // Temporarily change the owner so that the setters don't revert.
        owner = msg.sender;
        setExpiryDuration(_expiryDuration);
        setMaxOraclePriceAge(_maxOraclePriceAge);
        setMaxTimeToMaturity(_maxTimeToMaturity);
        setCreatorCapitalRequirement(_creatorCapitalRequirement);
        setCreatorSkewLimit(_creatorSkewLimit);
        setPoolFee(_poolFee);
        setCreatorFee(_creatorFee);
        setRefundFee(_refundFee);
        owner = _owner;
    }

    /* ========== VIEWS ========== */

    /* ---------- Related Contracts ---------- */

    function _systemStatus() internal view returns (ISystemStatus) {
        return ISystemStatus(requireAndGetAddress(CONTRACT_SYSTEMSTATUS, "Missing SystemStatus address"));
    }

    function _sUSD() internal view returns (IERC20) {
        return IERC20(requireAndGetAddress(CONTRACT_SYNTHSUSD, "Missing SynthsUSD address"));
    }

    function _exchangeRates() internal view returns (IExchangeRates) {
        return IExchangeRates(requireAndGetAddress(CONTRACT_EXRATES, "Missing ExchangeRates"));
    }

    function _factory() internal view returns (BinaryOptionMarketFactory) {
        return
            BinaryOptionMarketFactory(
                requireAndGetAddress(CONTRACT_BINARYOPTIONMARKETFACTORY, "Missing BinaryOptionMarketFactory address")
            );
    }

    /* ---------- Market Information ---------- */

    function _isKnownMarket(address candidate) internal view returns (bool) {
        return _activeMarkets.contains(candidate) || _maturedMarkets.contains(candidate);
    }

    function numActiveMarkets() external view returns (uint) {
        return _activeMarkets.elements.length;
    }

    function activeMarkets(uint index, uint pageSize) external view returns (address[] memory) {
        return _activeMarkets.getPage(index, pageSize);
    }

    function numMaturedMarkets() external view returns (uint) {
        return _maturedMarkets.elements.length;
    }

    function maturedMarkets(uint index, uint pageSize) external view returns (address[] memory) {
        return _maturedMarkets.getPage(index, pageSize);
    }

    function _isValidKey(bytes32 oracleKey) internal view returns (bool) {
        IExchangeRates exchangeRates = _exchangeRates();

        // If it has a rate, then it's possibly a valid key
        if (exchangeRates.rateForCurrency(oracleKey) != 0) {
            // But not sUSD
            if (oracleKey == "sUSD") {
                return false;
            }

            // and not inverse rates
            (uint entryPoint, , , ) = exchangeRates.inversePricing(oracleKey);
            if (entryPoint != 0) {
                return false;
            }

            return true;
        }

        return false;
    }

    /* ========== MUTATIVE FUNCTIONS ========== */

    /* ---------- Setters ---------- */

    function setMaxOraclePriceAge(uint _maxOraclePriceAge) public onlyOwner {
        durations.maxOraclePriceAge = _maxOraclePriceAge;
        emit MaxOraclePriceAgeUpdated(_maxOraclePriceAge);
    }

    function setExpiryDuration(uint _expiryDuration) public onlyOwner {
        durations.expiryDuration = _expiryDuration;
        emit ExpiryDurationUpdated(_expiryDuration);
    }

    function setMaxTimeToMaturity(uint _maxTimeToMaturity) public onlyOwner {
        durations.maxTimeToMaturity = _maxTimeToMaturity;
        emit MaxTimeToMaturityUpdated(_maxTimeToMaturity);
    }

    function setPoolFee(uint _poolFee) public onlyOwner {
        uint totalFee = _poolFee + fees.creatorFee;
        require(totalFee < SafeDecimalMath.unit(), "Total fee must be less than 100%.");
        require(0 < totalFee, "Total fee must be nonzero.");
        fees.poolFee = _poolFee;
        emit PoolFeeUpdated(_poolFee);
    }

    function setCreatorFee(uint _creatorFee) public onlyOwner {
        uint totalFee = _creatorFee + fees.poolFee;
        require(totalFee < SafeDecimalMath.unit(), "Total fee must be less than 100%.");
        require(0 < totalFee, "Total fee must be nonzero.");
        fees.creatorFee = _creatorFee;
        emit CreatorFeeUpdated(_creatorFee);
    }

    function setRefundFee(uint _refundFee) public onlyOwner {
        require(_refundFee <= SafeDecimalMath.unit(), "Refund fee must be no greater than 100%.");
        fees.refundFee = _refundFee;
        emit RefundFeeUpdated(_refundFee);
    }

    function setCreatorCapitalRequirement(uint _creatorCapitalRequirement) public onlyOwner {
        creatorLimits.capitalRequirement = _creatorCapitalRequirement;
        emit CreatorCapitalRequirementUpdated(_creatorCapitalRequirement);
    }

    function setCreatorSkewLimit(uint _creatorSkewLimit) public onlyOwner {
        require(_creatorSkewLimit <= SafeDecimalMath.unit(), "Creator skew limit must be no greater than 1.");
        creatorLimits.skewLimit = _creatorSkewLimit;
        emit CreatorSkewLimitUpdated(_creatorSkewLimit);
    }

    /* ---------- Deposit Management ---------- */

    function incrementTotalDeposited(uint delta) external onlyActiveMarkets notPaused {
        _systemStatus().requireSystemActive();
        totalDeposited = totalDeposited.add(delta);
    }

    function decrementTotalDeposited(uint delta) external onlyKnownMarkets notPaused {
        _systemStatus().requireSystemActive();
        // NOTE: As individual market debt is not tracked here, the underlying markets
        //       need to be careful never to subtract more debt than they added.
        //       This can't be enforced without additional state/communication overhead.
        totalDeposited = totalDeposited.sub(delta);
    }

    /* ---------- Market Lifecycle ---------- */

    function createMarket(
        bytes32 oracleKey,
        uint strikePrice,
        uint[2] calldata times, // [biddingEnd, maturity]
        uint[2] calldata bids // [longBid, shortBid]
    )
        external
        notPaused
        returns (
            IBinaryOptionMarket // no support for returning BinaryOptionMarket polymorphically given the interface
        )
    {
        _systemStatus().requireSystemActive();
        require(marketCreationEnabled, "Market creation is disabled");
        require(_isValidKey(oracleKey), "Invalid key");

        (uint biddingEnd, uint maturity) = (times[0], times[1]);
        require(maturity <= now + durations.maxTimeToMaturity, "Maturity too far in the future");
        uint expiry = maturity.add(durations.expiryDuration);

        uint initialDeposit = bids[0].add(bids[1]);
        require(now < biddingEnd, "End of bidding has passed");
        require(biddingEnd < maturity, "Maturity predates end of bidding");
        // We also require maturity < expiry. But there is no need to check this.
        // Fees being in range are checked in the setters.
        // The market itself validates the capital and skew requirements.

        BinaryOptionMarket market = _factory().createMarket(
            msg.sender,
            [creatorLimits.capitalRequirement, creatorLimits.skewLimit],
            oracleKey,
            strikePrice,
            [biddingEnd, maturity, expiry],
            bids,
            [fees.poolFee, fees.creatorFee, fees.refundFee]
        );
        market.setResolverAndSyncCache(resolver);
        _activeMarkets.push(address(market));

        // The debt can't be incremented in the new market's constructor because until construction is complete,
        // the manager doesn't know its address in order to grant it permission.
        totalDeposited = totalDeposited.add(initialDeposit);
        _sUSD().transferFrom(msg.sender, address(market), initialDeposit);

        emit MarketCreated(address(market), msg.sender, oracleKey, strikePrice, biddingEnd, maturity, expiry);
        return market;
    }

    function resolveMarket(address market) external {
        require(_activeMarkets.contains(market), "Not an active market");
        BinaryOptionMarket(market).resolve();
        _activeMarkets.remove(market);
        _maturedMarkets.push(market);
    }

    function expireMarkets(address[] calldata markets) external notPaused {
        _systemStatus().requireSystemActive();

        for (uint i = 0; i < markets.length; i++) {
            address market = markets[i];

            // The market itself handles decrementing the total deposits.
            BinaryOptionMarket(market).expire(msg.sender);
            // Note that we required that the market is known, which guarantees
            // its index is defined and that the list of markets is not empty.
            _maturedMarkets.remove(market);
            emit MarketExpired(market);
        }
    }

    /* ---------- Upgrade and Administration ---------- */

    function setResolverAndSyncCacheOnMarkets(AddressResolver _resolver, BinaryOptionMarket[] calldata marketsToSync)
        external
        onlyOwner
    {
        for (uint i = 0; i < marketsToSync.length; i++) {
            marketsToSync[i].setResolverAndSyncCache(_resolver);
        }
    }

    function setMarketCreationEnabled(bool enabled) public onlyOwner {
        if (enabled != marketCreationEnabled) {
            marketCreationEnabled = enabled;
            emit MarketCreationEnabledUpdated(enabled);
        }
    }

    function setMigratingManager(BinaryOptionMarketManager manager) public onlyOwner {
        _migratingManager = manager;
    }

    function migrateMarkets(
        BinaryOptionMarketManager receivingManager,
        bool active,
        BinaryOptionMarket[] calldata marketsToMigrate
    ) external onlyOwner {
        uint _numMarkets = marketsToMigrate.length;
        if (_numMarkets == 0) {
            return;
        }
        AddressListLib.AddressList storage markets = active ? _activeMarkets : _maturedMarkets;

        uint runningDepositTotal;
        for (uint i; i < _numMarkets; i++) {
            BinaryOptionMarket market = marketsToMigrate[i];
            require(_isKnownMarket(address(market)), "Market unknown.");

            // Remove it from our list and deposit total.
            markets.remove(address(market));
            runningDepositTotal = runningDepositTotal.add(market.deposited());

            // Prepare to transfer ownership to the new manager.
            market.nominateNewOwner(address(receivingManager));
        }
        // Deduct the total deposits of the migrated markets.
        totalDeposited = totalDeposited.sub(runningDepositTotal);
        emit MarketsMigrated(receivingManager, marketsToMigrate);

        // Now actually transfer the markets over to the new manager.
        receivingManager.receiveMarkets(active, marketsToMigrate);
    }

    function receiveMarkets(bool active, BinaryOptionMarket[] calldata marketsToReceive) external {
        require(msg.sender == address(_migratingManager), "Only permitted for migrating manager.");

        uint _numMarkets = marketsToReceive.length;
        if (_numMarkets == 0) {
            return;
        }
        AddressListLib.AddressList storage markets = active ? _activeMarkets : _maturedMarkets;

        uint runningDepositTotal;
        for (uint i; i < _numMarkets; i++) {
            BinaryOptionMarket market = marketsToReceive[i];
            require(!_isKnownMarket(address(market)), "Market already known.");

            market.acceptOwnership();
            markets.push(address(market));
            // Update the market with the new manager address,
            runningDepositTotal = runningDepositTotal.add(market.deposited());
        }
        totalDeposited = totalDeposited.add(runningDepositTotal);
        emit MarketsReceived(_migratingManager, marketsToReceive);
    }

    /* ========== MODIFIERS ========== */

    modifier onlyActiveMarkets() {
        require(_activeMarkets.contains(msg.sender), "Permitted only for active markets.");
        _;
    }

    modifier onlyKnownMarkets() {
        require(_isKnownMarket(msg.sender), "Permitted only for known markets.");
        _;
    }

    /* ========== EVENTS ========== */

    event MarketCreated(
        address market,
        address indexed creator,
        bytes32 indexed oracleKey,
        uint strikePrice,
        uint biddingEndDate,
        uint maturityDate,
        uint expiryDate
    );
    event MarketExpired(address market);
    event MarketsMigrated(BinaryOptionMarketManager receivingManager, BinaryOptionMarket[] markets);
    event MarketsReceived(BinaryOptionMarketManager migratingManager, BinaryOptionMarket[] markets);
    event MarketCreationEnabledUpdated(bool enabled);
    event MaxOraclePriceAgeUpdated(uint duration);
    event ExerciseDurationUpdated(uint duration);
    event ExpiryDurationUpdated(uint duration);
    event MaxTimeToMaturityUpdated(uint duration);
    event CreatorCapitalRequirementUpdated(uint value);
    event CreatorSkewLimitUpdated(uint value);
    event PoolFeeUpdated(uint fee);
    event CreatorFeeUpdated(uint fee);
    event RefundFeeUpdated(uint fee);
}