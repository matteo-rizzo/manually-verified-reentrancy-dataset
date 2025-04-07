/**
 *Submitted for verification at Etherscan.io on 2020-12-09
*/

//
// Initial Crowdsale for TRACIO 
//
//    Crowdsale contract by openzeppelin
//
//    Rate:  1200 (TRACIO / 18) - per Wei
//    Rate 1200
//    Crowdsale Token Account: 0xFE5586954a4292b7C7e887a618693Cec5a2A631D
//    IERC20 Token: TRACIO
//    Cap: 5000000000000000000000000 - 5 Million TRACIO
//    Caps Per Account: 5 Million each round.
//    Start Round 1:   1606780800 = 12/1/2020
//    End Round 1:     1609459200 = 12/31/2020
//    End Round 2:     1612137600 = 1/31/2021
//    End Round 3:     1614556800 = 2/28/2021
//    Max Gas Limit:    300000000
//

// File: @openzeppelin/contracts/GSN/Context.sol

pragma solidity ^0.5.17;

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
    constructor () internal { }
    // solhint-disable-previous-line no-empty-blocks

    function _msgSender() internal view returns (address payable) {
        return msg.sender;
    }

    function _msgData() internal view returns (bytes memory) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}

// File: @openzeppelin/contracts/token/ERC20/IERC20.sol

/**
 * @dev Interface of the ERC20 standard as defined in the EIP. Does not include
 * the optional functions; to access them see {ERC20Detailed}.
 */


// File: @openzeppelin/contracts/math/SafeMath.sol

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


// File: @openzeppelin/contracts/utils/Address.sol

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


// File: @openzeppelin/contracts/utils/ReentrancyGuard.sol

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

    constructor () internal {
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

// File: @openzeppelin/contracts/crowdsale/Crowdsale.sol

/**
 * @title Crowdsale
 * @dev Crowdsale is a base contract for managing a token crowdsale,
 * allowing investors to purchase tokens with ether. This contract implements
 * such functionality in its most fundamental form and can be extended to provide additional
 * functionality and/or custom behavior.
 * The external interface represents the basic interface for purchasing tokens, and conforms
 * the base architecture for crowdsales. It is *not* intended to be modified / overridden.
 * The internal interface conforms the extensible and modifiable surface of crowdsales. Override
 * the methods to add functionality. Consider using 'super' where appropriate to concatenate
 * behavior.
 */
contract Crowdsale is Context, ReentrancyGuard {
    using SafeMath for uint256;
    using SafeERC20 for IERC20;

    // The token being sold
    IERC20 private _token;

    // Address where funds are collected
    address payable private _wallet;

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
    event TokensPurchased(address indexed purchaser, address indexed beneficiary, uint256 value, uint256 amount);

    /**
     * @param rate Number of token units a buyer gets per wei
     * @dev The rate is the conversion between wei and the smallest and indivisible
     * token unit. So, if you are using a rate of 1 with a ERC20Detailed token
     * with 3 decimals called TOK, 1 wei will give you 1 unit, or 0.001 TOK.
     * @param wallet Address where collected funds will be forwarded to
     * @param token Address of the token being sold
     */
    constructor (uint256 rate, address payable wallet, IERC20 token) public {
        require(rate > 0, "Crowdsale: rate is 0");
        require(wallet != address(0), "Crowdsale: wallet is the zero address");
        require(address(token) != address(0), "Crowdsale: token is the zero address");

        _rate = rate;
        _wallet = wallet;
        _token = token;
    }

    /**
     * @dev fallback function ***DO NOT OVERRIDE***
     * Note that other contracts will transfer funds with a base gas stipend
     * of 2300, which is not enough to call buyTokens. Consider calling
     * buyTokens directly when purchasing tokens from a contract.
     */
    function () external payable {
        buyTokens(_msgSender());
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

    /**
     * @dev low level token purchase ***DO NOT OVERRIDE***
     * This function has a non-reentrancy guard, so it shouldn't be called by
     * another `nonReentrant` function.
     * @param beneficiary Recipient of the token purchase
     */
    function buyTokens(address beneficiary) public nonReentrant payable {
        uint256 weiAmount = msg.value;
        _preValidatePurchase(beneficiary, weiAmount);

        // calculate token amount to be created
        uint256 tokens = _getTokenAmount(weiAmount);

        // update state
        _weiRaised = _weiRaised.add(weiAmount);

        _processPurchase(beneficiary, tokens);
        emit TokensPurchased(_msgSender(), beneficiary, weiAmount, tokens);

        _updatePurchasingState(beneficiary, weiAmount);

        _forwardFunds();
        _postValidatePurchase(beneficiary, weiAmount);
    }

    /**
     * @dev Validation of an incoming purchase. Use require statements to revert state when conditions are not met.
     * Use `super` in contracts that inherit from Crowdsale to extend their validations.
     * Example from CappedCrowdsale.sol's _preValidatePurchase method:
     *     super._preValidatePurchase(beneficiary, weiAmount);
     *     require(weiRaised().add(weiAmount) <= cap);
     * @param beneficiary Address performing the token purchase
     * @param weiAmount Value in wei involved in the purchase
     */
    function _preValidatePurchase(address beneficiary, uint256 weiAmount) internal view {
        require(beneficiary != address(0), "Crowdsale: beneficiary is the zero address");
        require(weiAmount != 0, "Crowdsale: weiAmount is 0");
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
    }

    /**
     * @dev Validation of an executed purchase. Observe state and use revert statements to undo rollback when valid
     * conditions are not met.
     * @param beneficiary Address performing the token purchase
     * @param weiAmount Value in wei involved in the purchase
     */
    function _postValidatePurchase(address beneficiary, uint256 weiAmount) internal view {
        // solhint-disable-previous-line no-empty-blocks
    }

    /**
     * @dev Source of tokens. Override this method to modify the way in which the crowdsale ultimately gets and sends
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
    function _processPurchase(address beneficiary, uint256 tokenAmount) internal {
        _deliverTokens(beneficiary, tokenAmount);
    }

    /**
     * @dev Override for extensions that require an internal state to check for validity (current user contributions,
     * etc.)
     * @param beneficiary Address receiving the tokens
     * @param weiAmount Value in wei involved in the purchase
     */
    function _updatePurchasingState(address beneficiary, uint256 weiAmount) internal {
        // solhint-disable-previous-line no-empty-blocks
    }

    /**
     * @dev Override to extend the way in which ether is converted to tokens.
     * @param weiAmount Value in wei to be converted into tokens
     * @return Number of tokens that can be purchased with the specified _weiAmount
     */
    function _getTokenAmount(uint256 weiAmount) internal view returns (uint256) {
        return weiAmount.mul(_rate);
    }

    /**
     * @dev Determines how ETH is stored/forwarded on purchases.
     */
    function _forwardFunds() internal {
        _wallet.transfer(msg.value);
    }
}

// File: @openzeppelin/contracts/math/Math.sol

/**
 * @dev Standard math utilities missing in the Solidity language.
 */


// File: @openzeppelin/contracts/crowdsale/emission/AllowanceCrowdsale.sol

/**
 * @title AllowanceCrowdsale
 * @dev Extension of Crowdsale where tokens are held by a wallet, which approves an allowance to the crowdsale.
 */
contract AllowanceCrowdsale is Crowdsale {
    using SafeMath for uint256;
    using SafeERC20 for IERC20;

    address private _tokenWallet;

    /**
     * @dev Constructor, takes token wallet address.
     * @param tokenWallet Address holding the tokens, which has approved allowance to the crowdsale.
     */
    constructor (address tokenWallet) public {
        require(tokenWallet != address(0), "AllowanceCrowdsale: token wallet is the zero address");
        _tokenWallet = tokenWallet;
    }

    /**
     * @return the address of the wallet that will hold the tokens.
     */
    function tokenWallet() public view returns (address) {
        return _tokenWallet;
    }

    /**
     * @dev Checks the amount of tokens left in the allowance.
     * @return Amount of tokens left in the allowance
     */
    function remainingTokens() public view returns (uint256) {
        return Math.min(token().balanceOf(_tokenWallet), token().allowance(_tokenWallet, address(this)));
    }

    /**
     * @dev Overrides parent behavior by transferring tokens from wallet.
     * @param beneficiary Token purchaser
     * @param tokenAmount Amount of tokens purchased
     */
    function _deliverTokens(address beneficiary, uint256 tokenAmount) internal {
        token().safeTransferFrom(_tokenWallet, beneficiary, tokenAmount);
    }
}

// File: @openzeppelin/contracts/crowdsale/validation/CappedCrowdsale.sol

/**
 * @title CappedCrowdsale
 * @dev Crowdsale with a limit for total contributions.
 */
contract CappedCrowdsale is Crowdsale {
    using SafeMath for uint256;

    uint256 private _cap;

    /**
     * @dev Constructor, takes maximum amount of wei accepted in the crowdsale.
     * @param cap Max amount of wei to be contributed
     */
    constructor (uint256 cap) public {
        require(cap > 0, "CappedCrowdsale: cap is 0");
        _cap = cap;
    }

    /**
     * @return the cap of the crowdsale.
     */
    function cap() public view returns (uint256) {
        return _cap;
    }

    /**
     * @dev Checks whether the cap has been reached.
     * @return Whether the cap was reached
     */
    function capReached() public view returns (bool) {
        return weiRaised() >= _cap;
    }

    /**
     * @dev Extend parent behavior requiring purchase to respect the funding cap.
     * @param beneficiary Token purchaser
     * @param weiAmount Amount of wei contributed
     */
    function _preValidatePurchase(address beneficiary, uint256 weiAmount) internal view {
        super._preValidatePurchase(beneficiary, weiAmount);
        require(weiRaised().add(weiAmount) <= _cap, "CappedCrowdsale: cap exceeded");
    }
}

// File: @openzeppelin/contracts/crowdsale/validation/TimedCrowdsale.sol

/**
 * @title TimedCrowdsale
 * @dev Crowdsale accepting contributions only within a time frame.
 */
contract TimedCrowdsale is Crowdsale {
    using SafeMath for uint256;

    uint256 private _openingTime;
    uint256 private _closingTime;

    /**
     * Event for crowdsale extending
     * @param newClosingTime new closing time
     * @param prevClosingTime old closing time
     */
    event TimedCrowdsaleExtended(uint256 prevClosingTime, uint256 newClosingTime);

    /**
     * @dev Reverts if not in crowdsale time range.
     */
    modifier onlyWhileOpen {
        require(isOpen(), "TimedCrowdsale: not open");
        _;
    }

    /**
     * @dev Constructor, takes crowdsale opening and closing times.
     * @param openingTime Crowdsale opening time
     * @param closingTime Crowdsale closing time
     */
    constructor (uint256 openingTime, uint256 closingTime) public {
        // solhint-disable-next-line not-rely-on-time
        require(openingTime >= block.timestamp, "TimedCrowdsale: opening time is before current time");
        // solhint-disable-next-line max-line-length
        require(closingTime > openingTime, "TimedCrowdsale: opening time is not before closing time");

        _openingTime = openingTime;
        _closingTime = closingTime;
    }

    /**
     * @return the crowdsale opening time.
     */
    function openingTime() public view returns (uint256) {
        return _openingTime;
    }

    /**
     * @return the crowdsale closing time.
     */
    function closingTime() public view returns (uint256) {
        return _closingTime;
    }

    /**
     * @return true if the crowdsale is open, false otherwise.
     */
    function isOpen() public view returns (bool) {
        // solhint-disable-next-line not-rely-on-time
        return block.timestamp >= _openingTime && block.timestamp <= _closingTime;
    }

    /**
     * @dev Checks whether the period in which the crowdsale is open has already elapsed.
     * @return Whether crowdsale period has elapsed
     */
    function hasClosed() public view returns (bool) {
        // solhint-disable-next-line not-rely-on-time
        return block.timestamp > _closingTime;
    }

    /**
     * @dev Extend parent behavior requiring to be within contributing period.
     * @param beneficiary Token purchaser
     * @param weiAmount Amount of wei contributed
     */
    function _preValidatePurchase(address beneficiary, uint256 weiAmount) internal onlyWhileOpen view {
        super._preValidatePurchase(beneficiary, weiAmount);
    }

    /**
     * @dev Extend crowdsale.
     * @param newClosingTime Crowdsale closing time
     */
    function _extendTime(uint256 newClosingTime) internal {
        require(!hasClosed(), "TimedCrowdsale: already closed");
        // solhint-disable-next-line max-line-length
        require(newClosingTime > _closingTime, "TimedCrowdsale: new closing time is before current closing time");

        emit TimedCrowdsaleExtended(_closingTime, newClosingTime);
        _closingTime = newClosingTime;
    }
}

// File: @openzeppelin/contracts/ownership/Ownable.sol

/**
 * @dev Contract module which provides a basic access control mechanism, where
 * there is an account (an owner) that can be granted exclusive access to
 * specific functions.
 *
 * This module is used through inheritance. It will make available the modifier
 * `onlyOwner`, which can be applied to your functions to restrict their use to
 * the owner.
 */
contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    constructor () internal {
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
        require(isOwner(), "Ownable: caller is not the owner");
        _;
    }

    /**
     * @dev Returns true if the caller is the current owner.
     */
    function isOwner() public view returns (bool) {
        return _msgSender() == _owner;
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
        _transferOwnership(newOwner);
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     */
    function _transferOwnership(address newOwner) internal {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}

// File: @openzeppelin/contracts/ownership/Secondary.sol

/**
 * @dev A Secondary contract can only be used by its primary account (the one that created it).
 */
contract Secondary is Context {
    address private _primary;

    /**
     * @dev Emitted when the primary contract changes.
     */
    event PrimaryTransferred(
        address recipient
    );

    /**
     * @dev Sets the primary account to the one that is creating the Secondary contract.
     */
    constructor () internal {
        address msgSender = _msgSender();
        _primary = msgSender;
        emit PrimaryTransferred(msgSender);
    }

    /**
     * @dev Reverts if called from any account other than the primary.
     */
    modifier onlyPrimary() {
        require(_msgSender() == _primary, "Secondary: caller is not the primary account");
        _;
    }

    /**
     * @return the address of the primary.
     */
    function primary() public view returns (address) {
        return _primary;
    }

    /**
     * @dev Transfers contract to a new primary.
     * @param recipient The address of new primary.
     */
    function transferPrimary(address recipient) public onlyPrimary {
        require(recipient != address(0), "Secondary: new primary is the zero address");
        _primary = recipient;
        emit PrimaryTransferred(recipient);
    }
}

// File: contracts/sale/TRACIOSale.sol

contract TRACIOSale is Ownable, AllowanceCrowdsale, CappedCrowdsale, TimedCrowdsale {
    using SafeMath for uint256;

    enum Phase { NotStarted, One, Two, Three, Closed }
    enum AllowStatus {
        Disallowed,
        Phase1Cap1,
        Phase1Cap2,
        Phase1Cap3,
        Phase1Cap4,
        Phase2Cap1,
        Phase2Cap2,
        Phase2Cap3,
        Phase2Cap4
    }

    uint256 private constant MAX_UINT = 2**256 - 1;

    // -- State --

    uint256 private _maxGasPriceWei;

    // Allow list
    mapping(address => AllowStatus) private _allowList;

    // Account capping
    uint256[4] private _capsPerAccount; // Contribution caps that are assigned to each account
    mapping(address => uint256) private _contributions; // Contributions from an account

    // Time conditions
    uint256 private _openingTimePhase2; // opening time (phase2) in unix epoch seconds
    uint256 private _openingTimePhase3; // opening time (phase3) in unix epoch seconds

    // Post delivery
    mapping(address => uint256) private _balances;
    __unstable__TokenVault private _vault;

    // -- Events --

    event AllowListUpdated(address indexed account, AllowStatus value);

    event TRACIOSaleDeployed(
        uint256 rate, // rate, in TKNbits
        address payable wallet, // wallet to send Ether
        address tokenWallet, // wallet to pull tokens
        IERC20 token, // the token
        uint256 cap, // total cap, in wei
        uint256 capPerAccount1, // limit for individual contribution, in wei
        uint256 capPerAccount2, // limit for individual contribution, in wei
        uint256 capPerAccount3, // limit for individual contribution, in wei
        uint256 capPerAccount4, // limit for individual contribution, in wei
        uint256 openingTimePhase1, // opening time (phase1) in unix epoch seconds
        uint256 openingTimePhase2, // opening time (phase2) in unix epoch seconds
        uint256 openingTimePhase3, // opening time (phase3) in unix epoch seconds
        uint256 closingTime, // closing time in unix epoch seconds
        uint256 maxGasPriceWei // max gas price allowed for purchase transacctions (in wei)
    );

    event MaxGasPriceUpdated(uint256 maxGasPriceWei);

    event CapsPerAccount(
        uint256 capPerAccount1,
        uint256 capPerAccount2,
        uint256 capPerAccount3,
        uint256 capPerAccount4
    );

    /**
     * @dev Constructor.
     */
    constructor(
        uint256 rate, // rate, in TKNbits
        address payable wallet, // wallet to send Ether
        address tokenWallet, // wallet to pull tokens
        IERC20 token, // the token
        uint256 cap, // total cap, in wei
        uint256[4] memory capsPerAccount,
        uint256 openingTimePhase1, // opening time (phase1) in unix epoch seconds
        uint256 openingTimePhase2, // opening time (phase2) in unix epoch seconds
        uint256 openingTimePhase3, // opening time (phase3) in unix epoch seconds
        uint256 closingTime, // closing time in unix epoch seconds
        uint256 maxGasPriceWei // max gas price allowed for transactions (wei)
    )
        public
        Crowdsale(rate, wallet, token)
        CappedCrowdsale(cap)
        TimedCrowdsale(openingTimePhase1, closingTime)
        AllowanceCrowdsale(tokenWallet)
    {
        require(
            openingTimePhase2 > openingTimePhase1,
            "PhasedCrowdsale: phase2 must be after phase1"
        );
        require(
            openingTimePhase3 > openingTimePhase2,
            "PhasedCrowdsale: phase3 must be after phase2"
        );
        require(
            closingTime > openingTimePhase3,
            "PhasedCrowdsale: closing time must be after phase3"
        );

        require(maxGasPriceWei > 0, "Gas price cannot be zero");

        _setCapsPerAccount(capsPerAccount);
        _setMaxGasPrice(maxGasPriceWei);

        _openingTimePhase2 = openingTimePhase2;
        _openingTimePhase3 = openingTimePhase3;
        _vault = new __unstable__TokenVault();

        emit TRACIOSaleDeployed(
            rate,
            wallet,
            tokenWallet,
            token,
            cap,
            _capsPerAccount[0],
            _capsPerAccount[1],
            _capsPerAccount[2],
            _capsPerAccount[3],
            openingTimePhase1,
            openingTimePhase2,
            openingTimePhase3,
            closingTime,
            maxGasPriceWei
        );
    }

    // -- Configuration --

    /**
     * @dev Set the max allowed gas price for purchase transactions.
     * @param maxGasPriceWei Amount of wei to be used as max gas price.
     */
    function setMaxGasPrice(uint256 maxGasPriceWei) external onlyOwner {
        _setMaxGasPrice(maxGasPriceWei);
    }

    /**
     * @dev Internal: Set the max allowed gas price for purchase transactions.
     * @param maxGasPriceWei Amount of wei to be used as max gas price.
     */
    function _setMaxGasPrice(uint256 maxGasPriceWei) internal {
        require(maxGasPriceWei > 0, "Gas price cannot be zero");
        _maxGasPriceWei = maxGasPriceWei;
        emit MaxGasPriceUpdated(_maxGasPriceWei);
    }

    /**
     * @dev Get the max allowed gas price for purchase transactions.
     * @return Maximum gas price allowed for purchase transactions.
     */
    function maxGasPrice() public view returns (uint256) {
        return _maxGasPriceWei;
    }

    // -- Phases --

    function openingTimePhase2() public view returns (uint256) {
        return _openingTimePhase2;
    }

    function openingTimePhase3() public view returns (uint256) {
        return _openingTimePhase3;
    }

    /**
     * @dev Returns the current sale phase.
     * @return Phase
     */
    function getCurrentPhase() public view returns (Phase) {
        uint256 current = block.timestamp;
        if (current >= openingTime() && current < _openingTimePhase2) {
            return Phase.One;
        }
        if (current >= _openingTimePhase2 && current < _openingTimePhase3) {
            return Phase.Two;
        }
        if (current >= _openingTimePhase3 && current < closingTime()) {
            return Phase.Three;
        }
        if (current >= closingTime()) {
            return Phase.Closed;
        }
        return Phase.NotStarted;
    }

    // -- Allowlist --

    /**
     * @dev Return the allow status of an account.
     * @param account Address to check.
     */
    function getAllowStatus(address account) public view returns (AllowStatus) {
        return _allowList[account];
    }

    /**
     * @dev Return true if the account is authorized to participate in the crowdsale.
     * @param account Address to check.
     */
    function isAllowed(address account) public view returns (bool) {
        return getAllowStatus(account) != AllowStatus.Disallowed;
    }

    /**
     * @dev Return true if the account is currently allowed to participate.
     * @param account Address to check.
     */
    function isCurrentPhaseAllowed(address account) public view returns (bool) {
        AllowStatus status = _allowList[account];
        Phase phase = getCurrentPhase();

        // Only priority accounts can participate in Phase1
        if (phase == Phase.One) {
            return
                status == AllowStatus.Phase1Cap1 ||
                status == AllowStatus.Phase1Cap2 ||
                status == AllowStatus.Phase1Cap3 ||
                status == AllowStatus.Phase1Cap4;
        }

        // After Phase1 anyone in the allowlist can participate
        if (phase == Phase.Two || phase == Phase.Three) {
            return status != AllowStatus.Disallowed;
        }

        return false;
    }

    /**
     * @dev Set multiple accounts to the allowlist.
     * @param accounts Addresses to load on the allowlist.
     */
    function setAllowListMany(address[] calldata accounts, AllowStatus status) external onlyOwner {
        for (uint256 i = 0; i < accounts.length; i++) {
            _allowList[accounts[i]] = status;
            emit AllowListUpdated(accounts[i], status);
        }
    }

    // -- Account Capping --

    /**
     * @dev Returns the cap of individual beneficiary at the current phase.
     * @return Current cap for individual beneficiary
     */
    function getCapPerAccount(address account) public view returns (uint256) {
        AllowStatus status = _allowList[account];

        // Return the cap only if allowed to participate in current phase
        if (isCurrentPhaseAllowed(account)) {
            // No cap on Phase 3 regardless of account
            if (getCurrentPhase() == Phase.Three) {
                return MAX_UINT;
            }

            // cap1
            if (status == AllowStatus.Phase1Cap1 || status == AllowStatus.Phase2Cap1) {
                return _capsPerAccount[0];
            }
            // cap2
            if (status == AllowStatus.Phase1Cap2 || status == AllowStatus.Phase2Cap2) {
                return _capsPerAccount[1];
            }
            // cap3
            if (status == AllowStatus.Phase1Cap3 || status == AllowStatus.Phase2Cap3) {
                return _capsPerAccount[2];
            }
            // cap4
            if (status == AllowStatus.Phase1Cap4 || status == AllowStatus.Phase2Cap4) {
                return _capsPerAccount[3];
            }
        }
        return 0;
    }

    /**
     * @dev Sets the maximum contribution of all the individual beneficiaries.
     * @param capsPerAccount Array of wei limit for individual contribution for each cap tier
     */
    function setCapsPerAccount(uint256[4] calldata capsPerAccount) external onlyOwner {
        _setCapsPerAccount(capsPerAccount);
    }

    /**
     * @dev Internal: Sets the maximum contribution of all the individual beneficiaries.
     * @param capsPerAccount Array of wei limit for individual contribution for each cap tier
     */
    function _setCapsPerAccount(uint256[4] memory capsPerAccount) private {
        require(block.timestamp < openingTime(), "Can only update before start");
        for (uint256 i = 0; i < capsPerAccount.length; i++) {
            require(capsPerAccount[i] > 0, "AccountCappedCrowdsale: capPerAccount is 0");
        }
    
        require(capsPerAccount[0] > capsPerAccount[1], "Must be cap1 > cap2");
        require(capsPerAccount[1] > capsPerAccount[2], "Must be cap2 > cap3");
        require(capsPerAccount[2] > capsPerAccount[3], "Must be cap3 > cap4");
        _capsPerAccount = capsPerAccount;
    
        _capsPerAccount[0]=5 * (10 ** 6) * (10 ** 18); 
        _capsPerAccount[1]=4 * (10 ** 6) * (10 ** 18); 
        _capsPerAccount[2]=3 * (10 ** 6) * (10 ** 18); 
        _capsPerAccount[3]=2 * (10 ** 6) * (10 ** 18); 
        
        emit CapsPerAccount(
            _capsPerAccount[0],
            _capsPerAccount[1],
            _capsPerAccount[2],
            _capsPerAccount[3]
        );
    }

    /**
     * @dev Returns the maximum contribution for each cap tier.
     * @return Maximum contribution per account tier
     */
    function getCapsPerAccount()
        external
        view
        returns (
            uint256,
            uint256,
            uint256,
            uint256
        )
    {
        return (_capsPerAccount[0], _capsPerAccount[1], _capsPerAccount[2], _capsPerAccount[3]);
    }

    /**
     * @dev Returns the amount contributed so far by a specific beneficiary.
     * @param beneficiary Address of contributor
     * @return Beneficiary contribution so far
     */
    function getContribution(address beneficiary) public view returns (uint256) {
        return _contributions[beneficiary];
    }

    // -- Post Delivery --

    /**
     * @return the balance of an account.
     */
    function balanceOf(address account) public view returns (uint256) {
        return _balances[account];
    }

    // -- Hooks --

    /**
     * @dev Extend parent behavior to update beneficiary contributions.
     * @param beneficiary Token purchaser
     * @param weiAmount Amount of wei contributed
     */
    function _updatePurchasingState(address beneficiary, uint256 weiAmount) internal {
        super._updatePurchasingState(beneficiary, weiAmount);
        _contributions[beneficiary] = _contributions[beneficiary].add(weiAmount);
    }

    /**
     * @dev Overrides parent by storing due balances, and delivering tokens to the vault instead of the end user. This
     * ensures that the tokens will be available by the time they are withdrawn (which may not be the case if
     * `_deliverTokens` was called later).
     * @param beneficiary Token purchaser
     * @param tokenAmount Amount of tokens purchased
     */
    function _processPurchase(address beneficiary, uint256 tokenAmount) internal {
        _balances[beneficiary] = _balances[beneficiary].add(tokenAmount);
        _deliverTokens(address(_vault), tokenAmount);
    }

    /**
     * @dev Extend parent behavior requiring purchase to respect the beneficiary's funding cap.
     * Extend parent behavior requiring beneficiary to be allowlisted.
     * @param beneficiary Token purchaser
     * @param weiAmount Amount of wei contributed
     */
    function _preValidatePurchase(address beneficiary, uint256 weiAmount) internal view {
        require(tx.gasprice <= _maxGasPriceWei, "Gas price over limit");

        super._preValidatePurchase(beneficiary, weiAmount);
        require(
            isCurrentPhaseAllowed(beneficiary),
            "AllowListCrowdsale: beneficiary is not allowed in this phase"
        );
        require(
            _contributions[beneficiary].add(weiAmount) <= getCapPerAccount(beneficiary),
            "AccountCappedCrowdsale: beneficiary's cap exceeded"
        );
    }
}

/**
 * @title __unstable__TokenVault
 * @dev Similar to an Escrow for tokens, this contract allows its primary account to spend its tokens as it sees fit.
 * This contract is an internal helper for PostDeliveryCrowdsale, and should not be used outside of this context.
 */
// solhint-disable-next-line contract-name-camelcase
contract __unstable__TokenVault is Secondary {
    function transfer(
        IERC20 token,
        address to,
        uint256 amount
    ) public onlyPrimary {
        token.transfer(to, amount);
    }
}