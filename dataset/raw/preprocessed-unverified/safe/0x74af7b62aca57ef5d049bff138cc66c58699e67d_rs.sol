/**
 *Submitted for verification at Etherscan.io on 2020-12-11
*/

// SPDX-License-Identifier: UNLICENSED

pragma solidity ^0.6.12;


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
contract Crowdsale is Context, Ownable {
    using SafeMath for uint256;
    using SafeERC20 for IERC20;

    // The token being sold
    IERC20 public _token;
    mapping(address => uint256) public _balances;
    mapping(address => uint256) public _balancesPurchased;

    // Address where funds are collected
    address payable private _wallet;
    uint256 private _maxCapETH = 300e18;
    uint256 public _currentSaleToken = 0;
    uint256 public _capTokenSale = 400000e18;
    uint256 private _individualMaxCap = 10e18;
    uint256 private _individualMinCap = 5e17;

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
        require(rate > 0, "Crowdsale: rate is 0");
        require(wallet != address(0), "Crowdsale: wallet is the zero address");
        require(
            address(token) != address(0),
            "Crowdsale: token is the zero address"
        );

        _rate = rate;
        _wallet = wallet;
        _token = token;
    }

    receive() external payable {
        buyTokens();
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

    function remainingTokenSale() public view returns (uint256) {
        return _capTokenSale.sub(_currentSaleToken);
    }

    /**
     * @dev low level token purchase ***DO NOT OVERRIDE***
     * This function has a non-reentrancy guard, so it shouldn't be called by
     * another `nonReentrant` function.
     */
    function buyTokens() public payable {
        uint256 weiAmount = msg.value;
        _preValidatePurchase(_msgSender(), weiAmount);

        // calculate token amount to be created
        uint256 tokens = _getTokenAmount(weiAmount);

        // update state
        require(_weiRaised <= _maxCapETH);
        _weiRaised = _weiRaised.add(weiAmount);

        emit TokensPurchased(_msgSender(), _msgSender(), weiAmount, tokens);

        _forwardFunds();
        _currentSaleToken = _currentSaleToken.add(tokens);
        require(_capTokenSale >= _currentSaleToken);
        _balances[_msgSender()] = _balances[_msgSender()].add(tokens);
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
    function _preValidatePurchase(address beneficiary, uint256 weiAmount)
        internal
        virtual
    {
        require(
            beneficiary != address(0),
            "Crowdsale: beneficiary is the zero address"
        );
        require(weiAmount != 0, "Crowdsale: weiAmount is 0");
        require(
            weiAmount >= _individualMinCap,
            "Crowdsale: Min individual cap"
        );
        _balancesPurchased[beneficiary] = _balancesPurchased[beneficiary].add(
            weiAmount
        );
        require(
            _balancesPurchased[beneficiary] <= _individualMaxCap,
            "Crowdsale: Max individual cap"
        );
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

    /**
     * @dev Determines how ETH is stored/forwarded on purchases.
     */
    function _forwardFunds() internal {
        uint256 weiAmount = msg.value;
        _wallet.transfer(weiAmount);
    }
}

/**
 * @title TimedCrowdsale
 * @dev Crowdsale accepting contributions only within a time frame.
 */
abstract contract TimedCrowdsale is Crowdsale {
    using SafeMath for uint256;

    uint256 private _openingTime;
    uint256 private _closingTime;
    uint256 public _finalizedTime;
    bool public _isStopped = false;
    bool public isDepositedTokenSale = false;

    function start() public onlyOwner {
        require(!isOpen(), "TimedCrowdsale: opened");
        require(isDepositedTokenSale, "TimedCrowdsale: no token sale");
        _openingTime = block.timestamp;
    }

    function stop() public onlyOwner {
        require(isOpen(), "TimedCrowdsale: closed");
        _isStopped = true;
    }

    /**
     * @dev Reverts if not in crowdsale time range.
     */
    modifier onlyWhileOpen {
        require(isOpen() && !_isStopped, "TimedCrowdsale: not open");
        _;
    }

    modifier withdrawable {
        require(
            _finalizedTime > 0 &&
                block.timestamp > _finalizedTime.add(30 minutes)
        );
        _;
    }

    /**
     * @return the crowdsale opening time.
     */
    function openingTime() public view returns (uint256) {
        return _openingTime;
    }

    /**
     * @return true if the crowdsale is open, false otherwise.
     */
    function isOpen() public view returns (bool) {
        return _openingTime > 0 && block.timestamp >= _openingTime;
    }

    /**
     * @dev Checks whether the period in which the crowdsale is open has already elapsed.
     * @return Whether crowdsale period has elapsed
     */
    function hasClosed() public view returns (bool) {
        return _openingTime > 0 && _isStopped;
    }
}

/**
 * @title PostDeliveryCrowdsale
 * @dev Crowdsale that locks tokens from withdrawal until it ends.
 */
abstract contract PostDeliveryCrowdsale is TimedCrowdsale {
    using SafeMath for uint256;

    IERC20 private _tokenSale;
    mapping(address => bool) public withdrawableTokens;

    constructor(IERC20 _token) public {
        _tokenSale = _token;
    }

    /**
     * @dev Withdraw tokens only after crowdsale ends.
     */
    function withdrawTokens() public withdrawable {
        require(!withdrawableTokens[_msgSender()]);
        uint256 amount = _balances[_msgSender()];
        require(
            amount > 0,
            "PostDeliveryCrowdsale: beneficiary is not due any tokens"
        );

        _deliverTokens(_msgSender(), amount);
        withdrawableTokens[_msgSender()] = true;
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
 * @title FinalizableCrowdsale
 * @dev Extension of TimedCrowdsale with a one-off finalization action, where one
 * can do extra work after finishing.
 */
abstract contract FinalizableCrowdsale is PostDeliveryCrowdsale {
    using SafeMath for uint256;

    bool private _finalized;

    event CrowdsaleFinalized();

    constructor() internal {
        _finalized = false;
    }

    /**
     * @return true if the crowdsale is finalized, false otherwise.
     */
    function finalized() public view returns (bool) {
        return _finalized;
    }

    /**
     * @dev Must be called after crowdsale ends, to do some extra finalization
     * work. Calls the contract's finalization function.
     */
    function finalize() public {
        require(!_finalized, "FinalizableCrowdsale: already finalized");
        require(hasClosed(), "FinalizableCrowdsale: not closed");

        _finalized = true;

        _finalization();
        emit CrowdsaleFinalized();
    }

    /**
     * @dev Can be overridden to add finalization logic. The overriding function
     * should call super._finalization() to ensure the chain of finalization is
     * executed entirely.
     */
    function _finalization() internal {
        _finalizedTime = block.timestamp;
        if (_currentSaleToken < _capTokenSale) {
            _token.transfer(address(0), _capTokenSale.sub(_currentSaleToken));
        }
    }
}

contract IBaseTokenPresale is FinalizableCrowdsale {
    uint256 private _finalRate = 1333;

    constructor(address payable crowdsaleWallet, IERC20 token)
        public
        PostDeliveryCrowdsale(token)
        TimedCrowdsale()
        Crowdsale(_finalRate, crowdsaleWallet, token)
        FinalizableCrowdsale()
    {}
}