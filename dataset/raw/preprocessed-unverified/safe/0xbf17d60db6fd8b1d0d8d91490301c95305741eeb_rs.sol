/**
 *Submitted for verification at Etherscan.io on 2020-12-03
*/

pragma solidity ^0.5.17;

/*
`7MMF'     A     `7MF' db `7MMF'   `7MF'      
  `MA     ,MA     ,V  ;MM:  `MA     ,V        
   VM:   ,VVM:   ,V  ,V^MM.  VM:   ,V pd""b.  
    MM.  M' MM.  M' ,M  `MM   MM.  M'(O)  `8b 
    `MM A'  `MM A'  AbmmmqMA  `MM A'      ,89 
     :MM;    :MM;  A'     VML  :MM;     ""Yb. 
      VF      VF .AMA.   .AMMA. VF         88 
                                     (O)  .M' 
                                      bmmmd'  

* Similar to water molecules ¡ª WAV3 join to the highly volatile Cryptocurrency market, it is not affected by a special deflation mechanism, but is highly yield.
* Get inspired by projects: Sav3, ETHY, K3PR, BOND, ...
* Each Transfer/Sell transaction on Uniswap will be charged 6% as transaction fee (of which 90% will be sent directly to WStake as rewards
* 10% will be burned immediately, the total supply will go down continuously until reaching 30,000 WAV3)

*/

/*
 * @dev Provides information about the current execution context, including the
 * sender of the transaction and its data. While these are generally available
 * via msg.sender and msg.data, they should not be accessed in such a direct
 * manner, since when dealing with GSN meta-transactions the account sending and
 * paying for execution may not be the actual sender (as far as an application
 * is concerned).
 *
 * This contract is only required for intermediate, library-like contracts.
 */
contract Context {
    // Empty internal constructor, to prevent people from mistakenly deploying
    // an instance of this contract, which should be used via inheritance.
    constructor() internal {}

    // solhint-disable-previous-line no-empty-blocks

    function _msgSender() internal view returns (address payable) {
        return msg.sender;
    }

    function _msgData() internal view returns (bytes memory) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}

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
 * @dev Collection of functions related to the address type
 */


// File: @openzeppelin/contracts/token/ERC20/SafeERC20.sol

/**
 * @title SafeERC20
 * @dev Wrappers around ERC20 operations that throw on failure (when the token
 * contract returns false). Tokens that return no value (and instead revert or
 * throw on failure) are also supported, non-reverting calls are assumed to be
 * successful.
 * To use this library you can add a `using SafeERC20 for ERC20;` statement to your contract,
 * which allows you to call the safe operations as `token.safeTransfer(...)`, etc.
 */


/**
 * @dev Contract module that helps prevent reentrant calls to a function.
 *
 * Inheriting from `ReentrancyGuard` will make the {nonReentrant} modifier
 * available, which can be applied to functions to make sure there are no nested
 * (reentrant) calls to them.
 *
 * Note that because there is a single `nonReentrant` guard, functions marked as
 * `nonReentrant` may not call one another. This can be worked around by making
 * those functions `private`, and then adding `external` `nonReentrant` entry
 * points to them.
 *
 * TIP: If you would like to learn more about reentrancy and alternative ways
 * to protect against it, check out our blog post
 * https://blog.openzeppelin.com/reentrancy-after-istanbul/[Reentrancy After Istanbul].
 *
 * _Since v2.5.0:_ this module is now much more gas efficient, given net gas
 * metering changes introduced in the Istanbul hardfork.
 */
contract ReentrancyGuard {
    bool private _notEntered;

    constructor() internal {
        // Storing an initial non-zero value makes deployment a bit more
        // expensive, but in exchange the refund on every call to nonReentrant
        // will be lower in amount. Since refunds are capped to a percetange of
        // the total transaction's gas, it is best to keep them low in cases
        // like this one, to increase the likelihood of the full refund coming
        // into effect.
        _notEntered = true;
    }

    /**
     * @dev Prevents a contract from calling itself, directly or indirectly.
     * Calling a `nonReentrant` function from another `nonReentrant`
     * function is not supported. It is possible to prevent this from happening
     * by making the `nonReentrant` function external, and make it call a
     * `private` function that does the actual work.
     */
    modifier nonReentrant() {
        // On the first call to nonReentrant, _notEntered will be true
        require(_notEntered, "ReentrancyGuard: reentrant call");

        // Any calls to nonReentrant after this point will fail
        _notEntered = false;

        _;

        // By storing the original value once again, a refund is triggered (see
        // https://eips.ethereum.org/EIPS/eip-2200)
        _notEntered = true;
    }
}

/**
 * @dev Contract module which provides a basic access control mechanism, where
 * there is an account (an owner) that can be granted exclusive access to
 * specific functions.
 *
 * By default, the owner account will be the one that deploys the contract. This
 * can later be changed with {transferOwnership}.
 *
 * This module is used through inheritance. It will make available the modifier
 * `onlyOwner`, which can be applied to your functions to restrict their use to
 * the owner.
 */
contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(
        address indexed previousOwner,
        address indexed newOwner
    );

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    constructor() internal {
        address msgSender = _msgSender();
        _owner = msgSender;
        emit OwnershipTransferred(address(0), msgSender);
    }

    /**
     * @dev Returns the address of the current owner.
     */
    function owner() public view returns (address) {
        return _owner;
    }

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        require(_owner == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    /**
     * @dev Leaves the contract without owner. It will not be possible to call
     * `onlyOwner` functions anymore. Can only be called by the current owner.
     *
     * NOTE: Renouncing ownership will leave the contract without an owner,
     * thereby removing any functionality that is only available to the owner.
     */
    function renounceOwnership() public onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) public onlyOwner {
        require(
            newOwner != address(0),
            "Ownable: new owner is the zero address"
        );
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}

contract WhiteList is Ownable {
    mapping(address => bool) public whiteListReferrers;
    address private _owner;

    constructor() public {
        _owner = _msgSender();
    }

    function isWhiteList(address account) public view returns (bool) {
        return whiteListReferrers[account];
    }

    function addWhiteList(address[] memory addresses) public onlyOwner {
        for (uint256 i = 0; i < addresses.length; i++) {
            whiteListReferrers[addresses[i]] = true;
        }
    }
}

/**
 * @title Presale
 * @dev Presale is a base contract for managing a token presale,
 * allowing investors to purchase tokens with ether. This contract implements
 * such functionality in its most fundamental form and can be extended to provide additional
 * functionality and/or custom behavior.
 * The external interface represents the basic interface for purchasing tokens, and conforms
 * the base architecture for presales. It is *not* intended to be modified / overridden.
 * The internal interface conforms the extensible and modifiable surface of presales. Override
 * the methods to add functionality. Consider using 'super' where appropriate to concatenate
 * behavior.
 */
contract Presale is Context, ReentrancyGuard, WhiteList {
    using SafeMath for uint256;
    using SafeERC20 for IERC20;

    // The token being sold
    IERC20 public _token;

    // Address where funds are collected
    address payable private _wallet;
    address payable private _defaultRef;
    uint256 private _maxCapETH = 600e18;
    uint256 public _currentSaleToken = 0;
    uint256 public _capTokenSale = 45000e18;

    // How many token units a buyer gets per wei.
    // The rate is the conversion between wei and the smallest and indivisible token unit.
    // So, if you are using a rate of 1 with a ERC20Detailed token with 3 decimals called TOK
    // 1 wei will give you 1 unit, or 0.001 TOK.
    uint256 private _rate;

    // Amount of wei raised
    uint256 private _weiRaised;

    /**
     * Event for token purchase logging
     * @param purchaser who paid for the tokens
     * @param beneficiary who got the tokens
     * @param value weis paid for purchase
     * @param amount amount of tokens purchased
     */
    event TokensPurchased(
        address indexed purchaser,
        address indexed beneficiary,
        uint256 value,
        uint256 amount
    );

    /**
     * @param rate Number of token units a buyer gets per wei
     * @dev The rate is the conversion between wei and the smallest and indivisible
     * token unit. So, if you are using a rate of 1 with a ERC20Detailed token
     * with 3 decimals called TOK, 1 wei will give you 1 unit, or 0.001 TOK.
     * @param wallet Address where collected funds will be forwarded to
     * @param token Address of the token being sold
     */
    constructor(
        uint256 rate,
        address payable wallet,
        IERC20 token
    ) public {
        require(rate > 0, "Presale: rate is 0");
        require(wallet != address(0), "Presale: wallet is the zero address");
        require(
            address(token) != address(0),
            "Presale: token is the zero address"
        );

        _rate = rate;
        _wallet = wallet;
        _defaultRef = _msgSender();
        _token = token;
    }

    /**
     * @dev fallback function ***DO NOT OVERRIDE***
     * Note that other contracts will transfer funds with a base gas stipend
     * of 2300, which is not enough to call buyTokens. Consider calling
     * buyTokens directly when purchasing tokens from a contract.
     */
    function() external payable {
        buyTokens(_msgSender(), _defaultRef);
    }

    /**
     * @return the token being sold.
     */
    function token() public view returns (IERC20) {
        return _token;
    }

    /**
     * @return the address where funds are collected.
     */
    function wallet() public view returns (address payable) {
        return _wallet;
    }

    /**
     * @return the number of token units a buyer gets per wei.
     */
    function rate() public view returns (uint256) {
        return _rate;
    }

    /**
     * @return the amount of wei raised.
     */
    function weiRaised() public view returns (uint256) {
        return _weiRaised;
    }

    function getRefReceiver(address payable _ref)
        private
        view
        returns (address payable)
    {
        return
            (_ref == address(0) ||
                _ref == address(1) ||
                _ref == _msgSender() ||
                !isWhiteList(_ref))
                ? _defaultRef
                : _ref;
    }

    function remainingTokenSale() public view returns (uint256) {
        return _capTokenSale.sub(_currentSaleToken);
    }

    /**
     * @dev low level token purchase ***DO NOT OVERRIDE***
     * This function has a non-reentrancy guard, so it shouldn't be called by
     * another `nonReentrant` function.
     * @param beneficiary Recipient of the token purchase
     */
    function buyTokens(address beneficiary, address payable _ref)
        public
        payable
        nonReentrant
    {
        uint256 weiAmount = msg.value;
        _preValidatePurchase(beneficiary, weiAmount);

        // calculate token amount to be created
        uint256 tokens = _getTokenAmount(weiAmount);

        // update state
        _weiRaised = _weiRaised.add(weiAmount);
        require(_weiRaised <= _maxCapETH);

        emit TokensPurchased(_msgSender(), beneficiary, weiAmount, tokens);

        _updatePurchasingState(beneficiary, weiAmount);

        _forwardFunds(_ref);
        _postValidatePurchase(beneficiary, weiAmount);
        _currentSaleToken = _currentSaleToken.add(tokens);
        require(_capTokenSale >= _currentSaleToken);
    }

    /**
     * @dev Validation of an incoming purchase. Use require statements to revert state when conditions are not met.
     * Use `super` in contracts that inherit from Presale to extend their validations.
     * Example from CappedPresale.sol's _preValidatePurchase method:
     *     super._preValidatePurchase(beneficiary, weiAmount);
     *     require(weiRaised().add(weiAmount) <= cap);
     * @param beneficiary Address performing the token purchase
     * @param weiAmount Value in wei involved in the purchase
     */
    function _preValidatePurchase(address beneficiary, uint256 weiAmount)
        internal
        view
    {
        require(
            beneficiary != address(0),
            "Presale: beneficiary is the zero address"
        );
        require(weiAmount != 0, "Presale: weiAmount is 0");
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
    }

    /**
     * @dev Validation of an executed purchase. Observe state and use revert statements to undo rollback when valid
     * conditions are not met.
     * @param beneficiary Address performing the token purchase
     * @param weiAmount Value in wei involved in the purchase
     */
    function _postValidatePurchase(address beneficiary, uint256 weiAmount)
        internal
        view
    {
        // solhint-disable-previous-line no-empty-blocks
    }

    /**
     * @dev Source of tokens. Override this method to modify the way in which the presale ultimately gets and sends
     * its tokens.
     * @param beneficiary Address performing the token purchase
     * @param tokenAmount Number of tokens to be emitted
     */
    function _deliverTokens(address beneficiary, uint256 tokenAmount) internal {
        _token.safeTransfer(beneficiary, tokenAmount);
    }

    /**
     * @dev Executed when a purchase has been validated and is ready to be executed. Doesn't necessarily emit/send
     * tokens.
     * @param beneficiary Address receiving the tokens
     * @param tokenAmount Number of tokens to be purchased
     */
    function _processPurchase(address beneficiary, uint256 tokenAmount)
        internal
    {
        _deliverTokens(beneficiary, tokenAmount);
    }

    /**
     * @dev Override for extensions that require an internal state to check for validity (current user contributions,
     * etc.)
     * @param beneficiary Address receiving the tokens
     * @param weiAmount Value in wei involved in the purchase
     */
    function _updatePurchasingState(address beneficiary, uint256 weiAmount)
        internal
    {
        // solhint-disable-previous-line no-empty-blocks
    }

    /**
     * @dev Override to extend the way in which ether is converted to tokens.
     * @param weiAmount Value in wei to be converted into tokens
     * @return Number of tokens that can be purchased with the specified _weiAmount
     */
    function _getTokenAmount(uint256 weiAmount)
        internal
        view
        returns (uint256)
    {
        return weiAmount.mul(_rate);
    }

    uint256 public refRate = 5;

    /**
     * @dev Determines how ETH is stored/forwarded on purchases.
     */
    function _forwardFunds(address payable _ref) internal {
        uint256 weiAmount = msg.value;
        uint256 refAmount = weiAmount.mul(5).div(100);
        getRefReceiver(_ref).transfer(refAmount);
        _wallet.transfer(weiAmount.sub(refAmount));
    }
}

/**
 * @title TimedPresale
 * @dev Presale accepting contributions only within a time frame.
 */
contract TimedPresale is Presale {
    using SafeMath for uint256;

    uint256 private _duration_crowndsale;
    uint256 private _openingTime;
    uint256 private _closingTime;
    uint256 public _finalizedTime;
    bool public isDepositedTokenSale = false;

    function start() public onlyOwner {
        require(!isOpen(), "TimedPresale: opened");
        require(isDepositedTokenSale, "TimedPresale: no token sale");
        _openingTime = block.timestamp;
        _closingTime = _openingTime.add(_duration_crowndsale);
    }

    constructor(uint256 duration_crowndsale) internal {
        require(duration_crowndsale > 0);
        _duration_crowndsale = duration_crowndsale;
    }

    /**
     * @dev Reverts if not in presale time range.
     */
    modifier onlyWhileOpen {
        require(isOpen(), "TimedPresale: not open");
        _;
    }

    /**
     * @return the presale opening time.
     */
    function openingTime() public view returns (uint256) {
        return _openingTime;
    }

    /**
     * @return the presale closing time.
     */
    function closingTime() public view returns (uint256) {
        return _closingTime;
    }

    /**
     * @return true if the presale is open, false otherwise.
     */
    function isOpen() public view returns (bool) {
        // solhint-disable-next-line not-rely-on-time
        return
            _openingTime > 0 &&
            block.timestamp >= _openingTime &&
            block.timestamp <= _closingTime;
    }

    /**
     * @dev Checks whether the period in which the presale is open has already elapsed.
     * @return Whether presale period has elapsed
     */
    function hasClosed() public view returns (bool) {
        // solhint-disable-next-line not-rely-on-time
        return _closingTime > 0 && block.timestamp > _closingTime;
    }

    function withdrawable() public view returns (bool) {
        // solhint-disable-next-line not-rely-on-time
        return
            _finalizedTime > 0 &&
            block.timestamp > _finalizedTime.add(30 minutes);
    }

    /**
     * @dev Extend parent behavior requiring to be within contributing period.
     * @param beneficiary Token purchaser
     * @param weiAmount Amount of wei contributed
     */
    function _preValidatePurchase(address beneficiary, uint256 weiAmount)
        internal
        view
        onlyWhileOpen
    {
        super._preValidatePurchase(beneficiary, weiAmount);
    }
}

/**
 * @title PostDeliveryPresale
 * @dev Presale that locks tokens from withdrawal until it ends.
 */
contract PostDeliveryPresale is TimedPresale {
    using SafeMath for uint256;

    mapping(address => uint256) private _balances;
    IERC20 private _tokenSale;

    constructor(IERC20 _token) public {
        _tokenSale = _token;
    }

    /**
     * @dev Withdraw tokens only after presale ends.
     * @param beneficiary Whose tokens will be withdrawn.
     */
    function withdrawTokens(address beneficiary) public {
        require(withdrawable());
        uint256 amount = _balances[beneficiary];
        require(
            amount > 0,
            "PostDeliveryPresale: beneficiary is not due any tokens"
        );

        _balances[beneficiary] = 0;
        _tokenSale.transfer(beneficiary, amount);
    }

    function depositTokenSale() public onlyOwner {
        _tokenSale.transferFrom(_msgSender(), address(this), _capTokenSale);
        isDepositedTokenSale = true;
    }

    /**
     * @return the balance of an account.
     */
    function balanceOf(address account) public view returns (uint256) {
        return _balances[account];
    }
}

/**
 * @title IndividuallyCappedPresale
 * @dev Presale with per-beneficiary caps.
 */
contract IndividuallyCappedPresale is Presale {
    using SafeMath for uint256;

    mapping(address => uint256) private _contributions;
    // mapping(address => uint256) private _caps;
    uint256 public individualCap;

    constructor(uint256 _individualCap) public {
        individualCap = _individualCap;
    }

    /**
     * @dev Sets a specific beneficiary's maximum contribution.
     * @param beneficiary Address to be capped
     * @param cap Wei limit for individual contribution
     */
    // function setCap(address beneficiary, uint256 cap) external onlyCapper {
    //     _caps[beneficiary] = cap;
    // }

    /**
     * @dev Returns the cap of a specific beneficiary.
     * @param beneficiary Address whose cap is to be checked
     * @return Current cap for individual beneficiary
     */
    // function getCap(address beneficiary) public view returns (uint256) {
    // return _caps[beneficiary];
    // }

    /**
     * @dev Returns the amount contributed so far by a specific beneficiary.
     * @param beneficiary Address of contributor
     * @return Beneficiary contribution so far
     */
    function getContribution(address beneficiary)
        public
        view
        returns (uint256)
    {
        return _contributions[beneficiary];
    }

    /**
     * @dev Extend parent behavior requiring purchase to respect the beneficiary's funding cap.
     * @param beneficiary Token purchaser
     * @param weiAmount Amount of wei contributed
     */
    function _preValidatePurchase(address beneficiary, uint256 weiAmount)
        internal
        view
    {
        super._preValidatePurchase(beneficiary, weiAmount);
        // solhint-disable-next-line max-line-length
        // require(_contributions[beneficiary].add(weiAmount) <= _caps[beneficiary], "IndividuallyCappedPresale: beneficiary's cap exceeded");
        require(
            _contributions[beneficiary].add(weiAmount) <= individualCap,
            "IndividuallyCappedPresale: beneficiary's cap exceeded"
        );
    }

    /**
     * @dev Extend parent behavior to update beneficiary contributions.
     * @param beneficiary Token purchaser
     * @param weiAmount Amount of wei contributed
     */
    function _updatePurchasingState(address beneficiary, uint256 weiAmount)
        internal
    {
        super._updatePurchasingState(beneficiary, weiAmount);
        _contributions[beneficiary] = _contributions[beneficiary].add(
            weiAmount
        );
    }
}

/**
 * @title IncreasingPricePresale
 * @dev Extension of Presale contract that increases the price of tokens linearly in time.
 * Note that what should be provided to the constructor is the initial and final _rates_, that is,
 * the amount of tokens per wei contributed. Thus, the initial rate must be greater than the final rate.
 */
contract IncreasingPricePresale is TimedPresale {
    using SafeMath for uint256;

    // uint256 private _initialRate;
    uint256 private _finalRate;

    /**
     * @dev Constructor, takes initial and final rates of tokens received per wei contributed.
     * @param finalRate Number of tokens a buyer gets per wei at the end of the presale
     */
    constructor(uint256 finalRate) public {
        require(finalRate > 0, "IncreasingPricePresale: final rate is 0");
        // solhint-disable-next-line max-line-length
        _finalRate = finalRate;
    }

    /**
     * The base rate function is overridden to revert, since this presale doesn't use it, and
     * all calls to it are a mistake.
     */
    function rate() public view returns (uint256) {
        revert("IncreasingPricePresale: rate() called");
    }

    // function initialRate() public view returns (uint256) {
    //     return _initialRate;
    // }

    /**
     * @return the final rate of the presale.
     */
    function finalRate() public view returns (uint256) {
        return _finalRate;
    }

    /**
     * @dev Returns the rate of tokens per wei at the present time.
     * Note that, as price _increases_ with time, the rate _decreases_.
     * @return The number of tokens a buyer gets per wei at a given time
     */
    function getCurrentRate() public view returns (uint256) {
        if (!isOpen()) {
            return 0;
        }

        return _finalRate;
    }

    /**
     * @dev Overrides parent method taking into account variable rate.
     * @param weiAmount The value in wei to be converted into tokens
     * @return The number of tokens _weiAmount wei will buy at present time
     */
    function _getTokenAmount(uint256 weiAmount)
        internal
        view
        returns (uint256)
    {
        uint256 currentRate = getCurrentRate();
        return currentRate.mul(weiAmount);
    }
}

/**
 * @title FinalizablePresale
 * @dev Extension of TimedPresale with a one-off finalization action, where one
 * can do extra work after finishing.
 */
contract FinalizablePresale is TimedPresale {
    using SafeMath for uint256;

    bool private _finalized;

    event PresaleFinalized();

    constructor() internal {
        _finalized = false;
    }

    /**
     * @return true if the presale is finalized, false otherwise.
     */
    function finalized() public view returns (bool) {
        return _finalized;
    }

    /**
     * @dev Must be called after presale ends, to do some extra finalization
     * work. Calls the contract's finalization function.
     */
    function finalize() public {
        require(!_finalized, "FinalizablePresale: already finalized");
        require(hasClosed(), "FinalizablePresale: not closed");

        _finalized = true;

        _finalization();
        emit PresaleFinalized();
    }

    /**
     * @dev Can be overridden to add finalization logic. The overriding function
     * should call super._finalization() to ensure the chain of finalization is
     * executed entirely.
     */
    function _finalization() internal {
        _finalizedTime = block.timestamp;
        if (_currentSaleToken < _capTokenSale) {
            _token.burn(_capTokenSale.sub(_currentSaleToken));
        }
    }
}

contract Wav3TokenPresale is
    Presale,
    TimedPresale,
    PostDeliveryPresale,
    IndividuallyCappedPresale,
    IncreasingPricePresale,
    FinalizablePresale
{
    uint256 private _finalRate = 75;
    uint256 private _individualCap = 5e18;
    uint256 private DURATION_PRESALE = 2 days;

    constructor(address payable presaleWallet, IERC20 token)
        public
        IncreasingPricePresale(_finalRate)
        PostDeliveryPresale(token)
        TimedPresale(DURATION_PRESALE)
        IndividuallyCappedPresale(_individualCap)
        Presale(_finalRate, presaleWallet, token)
        FinalizablePresale()
    {}
}