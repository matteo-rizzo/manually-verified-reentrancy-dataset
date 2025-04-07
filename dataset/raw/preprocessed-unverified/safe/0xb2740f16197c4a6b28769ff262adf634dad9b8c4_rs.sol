/**
 *Submitted for verification at Etherscan.io on 2020-12-01
*/

pragma solidity ^0.5.5;

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


/**
 * @title Roles
 * @dev Library for managing addresses assigned to a Role.
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

contract ManagerRole is Context {
    using Roles for Roles.Role;

    event ManagerAdded(address indexed account);
    event ManagerRemoved(address indexed account);

    Roles.Role private _managers;

    constructor () internal {
        _addManager(_msgSender());
    }

    modifier onlyManager() {
        require(isManager(_msgSender()), "ManagerRole: caller does not have the Manager role");
        _;
    }

    function isManager(address account) public view returns (bool) {
        return _managers.has(account);
    }

    function addManager(address account) public onlyManager {
        _addManager(account);
    }

    function renounceManager() public {
        _removeManager(_msgSender());
    }

    function _addManager(address account) internal {
        _managers.add(account);
        emit ManagerAdded(account);
    }

    function _removeManager(address account) internal {
        _managers.remove(account);
        emit ManagerRemoved(account);
    }
}

contract SupporterRole is Context {
    using Roles for Roles.Role;

    event SupporterAdded(address indexed account);
    event SupporterRemoved(address indexed account);

    Roles.Role private _supporters;

    constructor () internal {
        _addSupporter(_msgSender());
    }

    modifier onlySupporter() {
        require(isSupporter(_msgSender()), "SupporterRole: caller does not have the Supporter role");
        _;
    }

    function isSupporter(address account) public view returns (bool) {
        return _supporters.has(account);
    }

    function addSupporter(address account) public onlySupporter {
        _addSupporter(account);
    }

    function renounceSupporter() public {
        _removeSupporter(_msgSender());
    }

    function _addSupporter(address account) internal {
        _supporters.add(account);
        emit SupporterAdded(account);
    }

    function _removeSupporter(address account) internal {
        _supporters.remove(account);
        emit SupporterRemoved(account);
    }
}

contract PauserRole is Context {
    using Roles for Roles.Role;

    event PauserAdded(address indexed account);
    event PauserRemoved(address indexed account);

    Roles.Role private _pausers;

    constructor () internal {
        _addPauser(_msgSender());
    }

    modifier onlyPauser() {
        require(isPauser(_msgSender()), "PauserRole: caller does not have the Pauser role");
        _;
    }

    function isPauser(address account) public view returns (bool) {
        return _pausers.has(account);
    }

    function addPauser(address account) public onlyPauser {
        _addPauser(account);
    }

    function renouncePauser() public {
        _removePauser(_msgSender());
    }

    function _addPauser(address account) internal {
        _pausers.add(account);
        emit PauserAdded(account);
    }

    function _removePauser(address account) internal {
        _pausers.remove(account);
        emit PauserRemoved(account);
    }
}

/**
 * @dev Contract module which allows children to implement an emergency stop
 * mechanism that can be triggered by an authorized account.
 *
 * This module is used through inheritance. It will make available the
 * modifiers `whenNotPaused` and `whenPaused`, which can be applied to
 * the functions of your contract. Note that they will not be pausable by
 * simply including this module, only once the modifiers are put in place.
 */
contract Pausable is Context, PauserRole {
    /**
     * @dev Emitted when the pause is triggered by a pauser (`account`).
     */
    event Paused(address account);

    /**
     * @dev Emitted when the pause is lifted by a pauser (`account`).
     */
    event Unpaused(address account);

    bool private _paused;

    /**
     * @dev Initializes the contract in unpaused state. Assigns the Pauser role
     * to the deployer.
     */
    constructor () internal {
        _paused = false;
    }

    /**
     * @dev Returns true if the contract is paused, and false otherwise.
     */
    function paused() public view returns (bool) {
        return _paused;
    }

    /**
     * @dev Modifier to make a function callable only when the contract is not paused.
     */
    modifier whenNotPaused() {
        require(!_paused, "Pausable: paused");
        _;
    }

    /**
     * @dev Modifier to make a function callable only when the contract is paused.
     */
    modifier whenPaused() {
        require(_paused, "Pausable: not paused");
        _;
    }

    /**
     * @dev Called by a pauser to pause, triggers stopped state.
     */
    function pause() public onlyPauser whenNotPaused {
        _paused = true;
        emit Paused(_msgSender());
    }

    /**
     * @dev Called by a pauser to unpause, returns to normal state.
     */
    function unpause() public onlyPauser whenPaused {
        _paused = false;
        emit Unpaused(_msgSender());
    }
}


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
    function owner() internal view returns (address) {
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
    function isOwner() internal view returns (bool) {
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
 * @dev Interface of the ERC20 standard as defined in the EIP. Does not include
 * the optional functions; to access them see {ERC20Detailed}.
 */


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
contract Crowdsale is Ownable, ReentrancyGuard {
    using SafeMath for uint256;
    using SafeERC20 for IERC20;

    struct Rate {
        uint256 rate;
        uint256 adapter;
    }

    // The token being sold
    IERC20 private _token;

    // How many token units a buyer gets per wei.
    // The rate is the conversion between wei and the smallest and indivisible token unit.
    // So, if you are using a rate of 1 with a ERC20Detailed token with 3 decimals called TOK
    // 1 wei will give you 1 unit, or 0.001 TOK.
    uint256 private _sold;
    mapping(address => Rate) private _rates;

    /**
     * Event for token purchase logging
     * @param purchaser who paid for the tokens
     * @param beneficiary who got the tokens
     * @param value weis paid for purchase
     * @param amount amount of tokens purchased
     */
    event TokensPurchased(address indexed purchaser, address indexed beneficiary, uint256 value, uint256 amount);

    /**
     * @dev The rate is the conversion between wei and the smallest and indivisible
     * token unit. So, if you are using a rate of 1 with a ERC20Detailed token
     * with 3 decimals called TOK, 1 wei will give you 1 unit, or 0.001 TOK.
     * @param token Address of the token being sold
     */
    constructor (IERC20 token) Ownable() public {
        require(address(token) != address(0), "Crowdsale: token is the zero address");
        _rates[0xdAC17F958D2ee523a2206206994597C13D831ec7].rate = 4e12;
        _rates[0xdAC17F958D2ee523a2206206994597C13D831ec7].adapter = 1;

        _token = token;
    }

    /**
    * @dev Checks whether the token is accepted.
    * @return Whether the token is accepted.
    */
    function isTokenAccepted(address token) public view returns (bool) {
        return _rates[token].rate != 0;
    }

    /**
    * @dev Update accepted token rate
    */
    function updateTokenRate(address token, uint256 _rate, uint256 _adapter)
        public onlyOwner returns (bool) {
        _rates[token].rate = _rate;
        _rates[token].adapter = _adapter;
        return true;
    }

    /**
    * @dev View current rate
    */
    function rate(address token) public view onlyOwner returns (uint256, uint256) {
        return (
            _rates[token].rate,
            _rates[token].adapter
        );
    }

    /**
     * @return the token being sold.
     */
    function token() public view returns (IERC20) {
        return _token;
    }

    /**
     * @return the amount of token sold.
     */
    function sold() public view returns (uint256) {
        return _sold;
    }

    /**
     * @dev This function has a non-reentrancy guard, so it shouldn't be called by
     * another `nonReentrant` function.
     * @param sentTokens Amount of tokens sent
     * @param _erc20Token Address of the token contract
     */
    function buyTokensWithTokens(uint256 sentTokens, address _erc20Token) public nonReentrant {
        require(isTokenAccepted(_erc20Token), "Token is not accepted");
        address beneficiary = _msgSender();
        _preValidatePurchase(beneficiary, sentTokens);

        IERC20 erc20Token = IERC20(_erc20Token);
        uint256 amountRecieved = _getTokenAmount(sentTokens, _erc20Token);
        require(sentTokens <= erc20Token.allowance(beneficiary, address(this)), "Insufficient Funds");

        _forwardFundsToken(erc20Token, sentTokens);
        _sold = _sold.add(amountRecieved);
        _processPurchase(beneficiary, amountRecieved);
        emit TokensPurchased(beneficiary, beneficiary, 0, amountRecieved);

        _updatePurchasingState(beneficiary, amountRecieved);
    }

    function checkRate(uint256 amount, address tokenAddress) public onlyOwner view returns (uint256) {
        return _getTokenAmount(amount, tokenAddress);
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
     * @param weiAmount Value in wei involved in the purchase
     */
    function _forwardFundsToken(IERC20 erc20Token, uint256 weiAmount) internal {
        // solhint-disable-previous-line no-empty-blocks
    }

    /**
     * @dev Source of tokens. Override this method to modify the way in which the crowdsale ultimately gets and sends
     * its tokens.
     * @param beneficiary Address performing the token purchase
     * @param tokenAmount Number of tokens to be emitted
     */
    function _deliverTokens(address beneficiary, uint256 tokenAmount) internal {
        _token.transfer(beneficiary, tokenAmount);
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
     * @param amount Value in wei to be converted into tokens
     * @return Number of tokens that can be purchased with the specified _amount
     */
    function _getTokenAmount(uint256 amount, address _erc20Token) internal view returns (uint256) {
        Rate memory exchangeRate = _rates[_erc20Token];
        return amount
            .mul(exchangeRate.rate)
            .div(exchangeRate.adapter);
    }

}

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
    function _preValidatePurchase(address beneficiary, uint256 weiAmount)
        internal onlyWhileOpen view {
        super._preValidatePurchase(beneficiary, weiAmount);
    }

    /**
     * @dev Extend crowdsale.
     * @param newOpeningTime Crowdsale Opening time
     * @param newClosingTime Crowdsale closing time
     */
    function _extendTime(uint256 newOpeningTime, uint256 newClosingTime) internal {
        emit TimedCrowdsaleExtended(_closingTime, newClosingTime);
        _openingTime = newOpeningTime;
        _closingTime = newClosingTime;
    }
}

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

/**
 * @title __unstable__TokenVault
 * @dev Similar to an Escrow for tokens, this contract allows its primary account to spend its tokens as it sees fit.
 * This contract is an internal helper for PostDeliveryCrowdsale, and should not be used outside of this context.
 */
// solhint-disable-next-line contract-name-camelcase
contract __unstable__TokenVault is Secondary {
    function transferToken(IERC20 token, address to, uint256 amount) public onlyPrimary {
        token.transfer(to, amount);
    }
    function transferFunds(address payable to, uint256 amount) public onlyPrimary {
        require (address(this).balance >= amount);
        to.transfer(amount);
    }
    function () external payable {}
}

/**
 * @title MoonSale
 */
contract MoonSale is TimedCrowdsale, Pausable, SupporterRole, ManagerRole {
    using SafeMath for uint256;
    struct User {
        address sponsor;
        uint256 balance;
        uint256 referralBonus;
	}
    __unstable__TokenVault private _vault;
    mapping(address => User) _users;

    /**
     * @param token The token.
     */
    constructor(IERC20 token)
    //todo uint256 openingTime, uint256 closingTime
        TimedCrowdsale(block.timestamp + 5 seconds, block.timestamp + 2 days)
        Crowdsale(token) public {
        _vault = new __unstable__TokenVault();
    }

    /**
     * @dev Extend sale
     * @param openingTime New opening time.
     * @param closingTime New closing time.
     */
    function extendTime(uint256 openingTime, uint256 closingTime)
        public onlyOwner
        returns (bool) {
        _extendTime(openingTime, closingTime);
        return true;
    }

    /**
     * @dev Set sponsor for user
     * @param sponsor Sponsor address
     * @param user User address
     */
    function delegateSetSponsor(address sponsor, address user)
        public onlySupporter
        returns (bool) {
        require(sponsor != user, "User can not be his own sponsor");
        User storage _user = _users[user];
        require(_user.sponsor == address(0), "User already has a sponsor");
        _user.sponsor = sponsor;
        return true;
    }

    /**
     * @dev Set sponsor
     * @param sponsor Sponsor address
     */
    function setSponsor(address sponsor) public returns (bool) {
        require(sponsor != _msgSender(), "You can not be your own sponsor");
        User storage _user = _users[_msgSender()];
        require(_user.sponsor == address(0), "You already has a sponsor");
        _user.sponsor = sponsor;
        return true;
    }

    /**
     * @dev Withdraw all available tokens.
     */
    function withdraw() public whenNotPaused nonReentrant returns (bool) {
        require(hasClosed(), "TimedCrowdsale: not closed");
        User storage user = _users[_msgSender()];
        uint256 available = user.referralBonus.add(user.balance);
        require(available > 0, "Not available");
        user.balance = 0;
        user.referralBonus = 0;
        _vault.transferToken(token(), _msgSender(), available);
        return true;
    }

    /**
     * @dev Get reserved token.
     */
    function getReserved() public view onlyManager
        returns (uint256 defaultTokens) {
        address vaultAddress = address(_vault);
        defaultTokens = IERC20(0xdAC17F958D2ee523a2206206994597C13D831ec7).balanceOf(vaultAddress);
    }

    /**
     * @dev Get reserved token by address.
     */
    function getReservedByAddress(IERC20 token) public view onlyManager returns (uint256) {
        return token.balanceOf(address(_vault));
    }

    /**
     * @dev Supply token for the vaults.
     * @param amount Supply amount
     */
    function supplyVault(uint256 amount)
        public onlyManager
        returns (bool) {
        token().transferFrom(_msgSender(), address(_vault), amount);
        return true;
    }

    /**
     * @dev deprive tokens from vaults.
     * @param vault Vault address
     * @param amount The amount
     */
    function depriveToken(address vault, IERC20 token, uint256 amount)
        public onlyManager returns (bool) {
        _vault.transferToken(token, vault, amount);
        return true;
    }

    /**
     * @dev deprive funds from vaults.
     * @param vault Vault address
     * @param amount The amount
     */
    function depriveFunds(address payable vault, uint256 amount)
        public onlyManager
        returns (bool) {
        _vault.transferFunds(vault, amount);
        return true;
    }

    /**
     * @return the invested, referralBonus, airdropBonus, dailyIncome, stakes, withdrawn, available
     */
    function personalStats(address account) public view returns (
        address sponsor,
        uint256 balance,
        uint256 referralBonus,
        uint256 available
    ) {
        User memory user = _users[account];
        return (
            user.sponsor,
            user.balance,
            user.referralBonus,
            user.balance.add(user.referralBonus)
        );
    }

    /**
     * @dev Fallback function
     */
    function () external payable {
        address(uint160((address(_vault)))).transfer(msg.value);
    }

    /**
     * @dev Override parent behavior: Storing balance instead of issuing tokens right away.
     * @param beneficiary Token purchaser
     * @param tokenAmount Amount of tokens purchased
     */
    function _processPurchase(address beneficiary, uint256 tokenAmount) internal {
        _users[beneficiary].balance = _users[beneficiary].balance.add(tokenAmount);
    }

    /**
     * @dev Override parent behavior: Pay bonus for sponsor.
     * @param beneficiary Address receiving the tokens
     * @param amount Value in token involved in the purchase
     */
    function _updatePurchasingState(address beneficiary, uint256 amount) internal {
        User storage user = _users[beneficiary];
        if (user.sponsor != address(0)) {
            _users[user.sponsor].referralBonus = amount
                .mul(12).div(100).add(_users[user.sponsor].referralBonus);
        }
    }

    /**
     * @dev Extend parent behavior requiring minimum amount to be 1000.
     * @param beneficiary Token purchaser
     * @param _value Amount contributed
     */
    function _preValidatePurchase(address beneficiary, uint256 _value)
        internal view {
        // require(_value >= 1000e18, "Minimum amount is 1000");
        super._preValidatePurchase(beneficiary, _value);
    }

    /**
     * @dev Extend parent behavior
     * @param erc20Token ERC20 Token
     * @param _value Amount contributed
     */
    function _forwardFundsToken(IERC20 erc20Token, uint256 _value) internal {
        erc20Token.transferFrom(_msgSender(), address(_vault), _value);
    }
}