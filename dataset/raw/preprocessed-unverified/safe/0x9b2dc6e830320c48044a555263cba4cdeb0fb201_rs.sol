/**
 *Submitted for verification at Etherscan.io on 2021-04-13
*/

// SPDX-License-Identifier: MIT

pragma solidity ^0.6.12;

/**
 * @dev Collection of functions related to the address type
 */


/**
 * @dev This is a base contract to aid in writing upgradeable contracts, or any kind of contract that will be deployed
 * behind a proxy. Since a proxied contract can't have a constructor, it's common to move constructor logic to an
 * external initializer function, usually called `initialize`. It then becomes necessary to protect this initializer
 * function so it can only be called once. The {initializer} modifier provided by this contract will have this effect.
 *
 * TIP: To avoid leaving the proxy in an uninitialized state, the initializer function should be called as early as
 * possible by providing the encoded function call as the `_data` argument to {UpgradeableProxy-constructor}.
 *
 * CAUTION: When used with inheritance, manual care must be taken to not invoke a parent initializer twice, or to ensure
 * that all initializers are idempotent. This is not verified automatically as constructors are by Solidity.
 */
abstract contract Initializable {

    /**
     * @dev Indicates that the contract has been initialized.
     */
    bool private _initialized;

    /**
     * @dev Indicates that the contract is in the process of being initialized.
     */
    bool private _initializing;

    /**
     * @dev Modifier to protect an initializer function from being invoked twice.
     */
    modifier initializer() {
        require(_initializing || _isConstructor() || !_initialized, "Initializable: contract is already initialized");

        bool isTopLevelCall = !_initializing;
        if (isTopLevelCall) {
            _initializing = true;
            _initialized = true;
        }

        _;

        if (isTopLevelCall) {
            _initializing = false;
        }
    }

    /// @dev Returns true if and only if the function is running in the constructor
    function _isConstructor() private view returns (bool) {
        return !AddressUpgradeable.isContract(address(this));
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
abstract contract ContextUpgradeable is Initializable {
    function __Context_init() internal initializer {
        __Context_init_unchained();
    }

    function __Context_init_unchained() internal initializer {
    }
    function _msgSender() internal view virtual returns (address payable) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes memory) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
    uint256[50] private __gap;
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
abstract contract PausableUpgradeable is Initializable, ContextUpgradeable {
    /**
     * @dev Emitted when the pause is triggered by `account`.
     */
    event Paused(address account);

    /**
     * @dev Emitted when the pause is lifted by `account`.
     */
    event Unpaused(address account);

    bool private _paused;

    /**
     * @dev Initializes the contract in unpaused state.
     */
    function __Pausable_init() internal initializer {
        __Context_init_unchained();
        __Pausable_init_unchained();
    }

    function __Pausable_init_unchained() internal initializer {
        _paused = false;
    }

    /**
     * @dev Returns true if the contract is paused, and false otherwise.
     */
    function paused() public view virtual returns (bool) {
        return _paused;
    }

    /**
     * @dev Modifier to make a function callable only when the contract is not paused.
     *
     * Requirements:
     *
     * - The contract must not be paused.
     */
    modifier whenNotPaused() {
        require(!paused(), "Pausable: paused");
        _;
    }

    /**
     * @dev Modifier to make a function callable only when the contract is paused.
     *
     * Requirements:
     *
     * - The contract must be paused.
     */
    modifier whenPaused() {
        require(paused(), "Pausable: not paused");
        _;
    }

    /**
     * @dev Triggers stopped state.
     *
     * Requirements:
     *
     * - The contract must not be paused.
     */
    function _pause() internal virtual whenNotPaused {
        _paused = true;
        emit Paused(_msgSender());
    }

    /**
     * @dev Returns to normal state.
     *
     * Requirements:
     *
     * - The contract must be paused.
     */
    function _unpause() internal virtual whenPaused {
        _paused = false;
        emit Unpaused(_msgSender());
    }
    uint256[49] private __gap;
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
abstract contract OwnableUpgradeable is Initializable, ContextUpgradeable {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    function __Ownable_init() internal initializer {
        __Context_init_unchained();
        __Ownable_init_unchained();
    }

    function __Ownable_init_unchained() internal initializer {
        address msgSender = _msgSender();
        _owner = msgSender;
        emit OwnershipTransferred(address(0), msgSender);
    }

    /**
     * @dev Returns the address of the current owner.
     */
    function owner() public view virtual returns (address) {
        return _owner;
    }

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    /**
     * @dev Leaves the contract without owner. It will not be possible to call
     * `onlyOwner` functions anymore. Can only be called by the current owner.
     *
     * NOTE: Renouncing ownership will leave the contract without an owner,
     * thereby removing any functionality that is only available to the owner.
     */
    function renounceOwnership() public virtual onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
    uint256[49] private __gap;
}


/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
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
 * @title SafeERC20
 * @dev Wrappers around ERC20 operations that throw on failure (when the token
 * contract returns false). Tokens that return no value (and instead revert or
 * throw on failure) are also supported, non-reverting calls are assumed to be
 * successful.
 * To use this library you can add a `using SafeERC20 for IERC20;` statement to your contract,
 * which allows you to call the safe operations as `token.safeTransfer(...)`, etc.
 */




contract DeHiveTokensale is OwnableUpgradeable, PausableUpgradeable {

    using SafeMathUpgradeable for uint256;
    using SafeERC20Upgradeable for IERC20Upgradeable;

    /**
     * EVENTS
     **/
    event DHVPurchased(address indexed user, address indexed purchaseToken, uint256 dhvAmount);
    event TokensClaimed(address indexed user, uint256 dhvAmount);

    /**
     * CONSTANTS
     **/

    // *** TOKENSALE PARAMETERS START ***
    uint256 public constant PRECISION = 1000000; //Up to 0.000001
    uint256 public constant PRE_SALE_START =    1616594400; //Mar 24 2021 14:00:00 GMT
    uint256 public constant PRE_SALE_END =      1616803140; //Mar 26 2021 23:59:00 GMT

    uint256 public constant PUBLIC_SALE_START = 1618408800; //Apr 14 2021 14:00:00 GMT
    uint256 public constant PUBLIC_SALE_END =   1618790340; //Apr 18 2021 23:59:00 GMT

    uint256 public constant PRE_SALE_DHV_POOL =     450000 * 10 ** 18; // 5% DHV in total in presale pool
    uint256 public constant PRE_SALE_DHV_NUX_POOL =  50000 * 10 ** 18; // 
    uint256 public PUBLIC_SALE_DHV_POOL;                               // 11% DHV in public sale pool
    uint256 private constant WITHDRAWAL_PERIOD = 365 * 24 * 60 * 60; //1 year
    // *** TOKENSALE PARAMETERS END ***


    /***
     * STORAGE
     ***/

    uint256 public maxTokensAmount;
    uint256 public maxGasPrice;

    // *** VESTING PARAMETERS START ***

    uint256 public vestingStart;
    uint256 public constant vestingDuration = 305 days; //305 days - until Apr 30 2021 00:00:00 GMT
    
    // *** VESTING PARAMETERS END ***
    address public DHVToken;
    address internal USDTToken; /*= 0xdAC17F958D2ee523a2206206994597C13D831ec7 */
    address internal DAIToken; /*= 0x6B175474E89094C44Da98b954EedeAC495271d0F*/
    address internal NUXToken; /*= 0x89bD2E7e388fAB44AE88BEf4e1AD12b4F1E0911c*/

    mapping (address => uint256) public purchased;
    mapping (address => uint256) internal _claimed;

    uint256 public purchasedWithNUX;
    uint256 public purchasedPreSale;
    uint256 public purchasedPublicSale;
    uint256 public ETHRate;
    mapping (address => uint256) public rates;

    address private _treasury;

    mapping (address => uint256) public purchasedPublic;
    
    /***
     * MODIFIERS
     ***/

    /**
     * @dev Throws if called with not supported token.
     */
    modifier supportedCoin(address _token) {
        require(_token == USDTToken || _token == DAIToken, "Token not supported");
        _;
    }

    /**
    * @dev Throws if called when no ongoing pre-sale or public sale.
    */
    modifier onlySale() {
        require(_isPreSale() || _isPublicSale(), "Sale stages are over or not started");
        _;
    }

    /**
    * @dev Throws if called when no ongoing pre-sale or public sale.
    */
    modifier onlyPreSale() {
        require(_isPreSale(), "Presale stages are over or not started");
        _;
    }

    /**
    * @dev Throws if sale stage is ongoing.
    */
    modifier notOnSale() {
        require(!_isPreSale(), "Presale is not over");
        require(!_isPublicSale(), "Sale is not over");
        _;
    }

    /**
    * @dev Throws if gas price exceeds gas limit.
    */
    modifier correctGas() {
        require(maxGasPrice == 0 || tx.gasprice <= maxGasPrice, "Gas price exceeds limit");
        _;
    }

    /***
     * INITIALIZER AND SETTINGS
     ***/

    /**
     * @notice Initializes the contract with correct addresses settings
     * @param treasury Address of the DeHive protocol's treasury where funds from sale go to
     * @param dhv DHVToken mainnet address
     */
    function initialize(address treasury, address dhv) public initializer {
        require(treasury != address(0), "Zero address");
        require(dhv != address(0), "Zero address");

        __Ownable_init();
        __Pausable_init();

        _treasury = treasury;
        DHVToken = dhv;

        DAIToken = 0x6B175474E89094C44Da98b954EedeAC495271d0F;
        USDTToken = 0xdAC17F958D2ee523a2206206994597C13D831ec7;
        NUXToken = 0x89bD2E7e388fAB44AE88BEf4e1AD12b4F1E0911c;
        vestingStart = 0;
        maxTokensAmount = 49600 * (10 ** 18); // around 50 ETH 
        PUBLIC_SALE_DHV_POOL = 1100000 * 10 ** 18; // 11% of sale pool
    }

    /**
     * @notice Updates current vesting start time. Can be used once
     * @param _vestingStart New vesting start time
     */
    function adminSetVestingStart(uint256 _vestingStart) virtual external onlyOwner{
        require(vestingStart == 0, "Vesting start is already set");
        require(_vestingStart > PUBLIC_SALE_END && block.timestamp < _vestingStart, "Incorrect time provided");
        vestingStart = _vestingStart;
    }

    /**
     * @notice Sets the rate for the chosen token based on the contracts precision
     * @param _token ERC20 token address or zero address for ETH
     * @param _rate Exchange rate based on precision (e.g. _rate = PRECISION corresponds to 1:1)
     */
    function adminSetRates(address _token, uint256 _rate) external onlyOwner {
        if (_token == address(0))
            ETHRate = _rate;
        else
            rates[_token] = _rate;
    }

    /**
    * @notice Allows owner to change the treasury address. Treasury is the address where all funds from sale go to
    * @param treasury New treasury address
    */
    function adminSetTreasury(address treasury) external onlyOwner {
        _treasury = treasury;
    }

    /**
    * @notice Allows owner to change max allowed DHV token per address.
    * @param _maxDHV New max DHV amount
    */
    function adminSetMaxDHV(uint256 _maxDHV) external onlyOwner {
        maxTokensAmount = _maxDHV;
    }

    /**
    * @notice Allows owner to change the max allowed gas price. Prevents gas wars
    * @param _maxGasPrice New max gas price
    */
    function adminSetMaxGasPrice(uint256 _maxGasPrice) external onlyOwner {
        maxGasPrice = _maxGasPrice;
    }

    /**
     * @notice Updates public sales pool maximum
     * @param _publicPool New public pool DHV maximum value
     */
    function adminSetPublicPool(uint256 _publicPool) external onlyOwner {
        PUBLIC_SALE_DHV_POOL = _publicPool;
    }


    /**
    * @notice Stops purchase functions. Owner only
    */
    function adminPause() external onlyOwner {
        _pause();
    }

    /**
    * @notice Unpauses purchase functions. Owner only
    */
    function adminUnpause() external onlyOwner {
        _unpause();
    }

    function adminAddPurchase(address _receiver, uint256 _amount) virtual external onlyOwner {
        purchased[_receiver] = purchased[_receiver].add(_amount);
    }

    /***
     * PURCHASE FUNCTIONS
     ***/

    /**
     * @notice For purchase with ETH
     */
    receive() external virtual payable onlySale whenNotPaused {
        _purchaseDHVwithETH();
    }

    /**
     * @notice For purchase with allowed stablecoin (USDT and DAI)
     * @param ERC20token Address of the token to be paid in
     * @param ERC20amount Amount of the token to be paid in
     */
    function purchaseDHVwithERC20(address ERC20token, uint256 ERC20amount) external onlySale supportedCoin(ERC20token) whenNotPaused correctGas {
        require(ERC20amount > 0, "Zero amount");
        uint256 purchaseAmount = _calcPurchaseAmount(ERC20token, ERC20amount);

        _checkCapReached(purchaseAmount);
        
        if (_isPreSale()) {
            require(purchasedPreSale.add(purchaseAmount) <= PRE_SALE_DHV_POOL, "Not enough DHV in presale pool");
            purchasedPreSale = purchasedPreSale.add(purchaseAmount);
        } else {
            require(purchaseAmount <= publicSaleAvailableDHV(), "Not enough DHV in sale pool");
            purchasedPublicSale = purchasedPublicSale.add(purchaseAmount);
            purchasedPublic[_msgSender()] = purchasedPublic[_msgSender()].add(purchaseAmount);
        }
            
        purchased[_msgSender()] = purchased[_msgSender()].add(purchaseAmount);
        IERC20Upgradeable(ERC20token).safeTransferFrom(_msgSender(), _treasury, ERC20amount); // send ERC20 to Treasury

        emit DHVPurchased(_msgSender(), ERC20token, purchaseAmount);
    }

    /**
     * @notice For purchase with NUX token only. Available only for tokensale
     * @param nuxAmount Amount of the NUX token
     */
    function purchaseDHVwithNUX(uint256 nuxAmount) external onlyPreSale whenNotPaused correctGas {
        require(nuxAmount > 0, "Zero amount");
        uint256 purchaseAmount = _calcPurchaseAmount(NUXToken, nuxAmount);
        require(purchaseAmount.add(purchased[msg.sender]) <= maxTokensAmount, "Maximum allowed exceeded");


        require(purchasedWithNUX.add(purchaseAmount) <= PRE_SALE_DHV_NUX_POOL, "Not enough DHV in NUX pool");
        purchasedWithNUX = purchasedWithNUX.add(purchaseAmount);

        purchased[_msgSender()] = purchased[_msgSender()].add(purchaseAmount);
        IERC20Upgradeable(NUXToken).safeTransferFrom(_msgSender(), _treasury, nuxAmount);

        emit DHVPurchased(_msgSender(), NUXToken, purchaseAmount);
    }

    /**
     * @notice For purchase with ETH. ETH is left on the contract until withdrawn to treasury
     */
    function purchaseDHVwithETH() external payable onlySale whenNotPaused {
        require(msg.value > 0, "No ETH sent");
        _purchaseDHVwithETH();
    }

    function _purchaseDHVwithETH() correctGas private {
        uint256 purchaseAmount = _calcEthPurchaseAmount(msg.value);
        
        _checkCapReached(purchaseAmount);

        if (_isPreSale()) {
            require(purchasedPreSale.add(purchaseAmount) <= PRE_SALE_DHV_POOL, "Not enough DHV in presale pool");
            purchasedPreSale = purchasedPreSale.add(purchaseAmount);
        } else {
            require(purchaseAmount <= publicSaleAvailableDHV(), "Not enough DHV in sale pool");
            purchasedPublicSale = purchasedPublicSale.add(purchaseAmount);
            purchasedPublic[_msgSender()] = purchasedPublic[_msgSender()].add(purchaseAmount);
        }

        purchased[_msgSender()] = purchased[_msgSender()].add(purchaseAmount);

        payable(_treasury).transfer(msg.value);

        emit DHVPurchased(_msgSender(), address(0), purchaseAmount);
    }

    /**
     * @notice Function to get available on public sale amount of DHV
     * @notice Unsold NUX pool and pre-sale pool go to public sale
     * @return The amount of the token released.
     */
    function publicSaleAvailableDHV() public view returns(uint256) {
        return PUBLIC_SALE_DHV_POOL.sub(purchasedPublicSale);
    }


    /**
     * @notice Function for the administrator to withdraw token (except DHV)
     * @notice Withdrawals allowed only if there is no sale pending stage
     * @param ERC20token Address of ERC20 token to withdraw from the contract
     */
    function adminWithdrawERC20(address ERC20token) external onlyOwner notOnSale {
        require(ERC20token != DHVToken || _canWithdrawDHV(), "DHV withdrawal is forbidden");

        uint256 tokenBalance = IERC20Upgradeable(ERC20token).balanceOf(address(this));
        IERC20Upgradeable(ERC20token).safeTransfer(_treasury, tokenBalance);
    }

    /**
     * @notice Function for the administrator to withdraw ETH for refunds
     * @notice Withdrawals allowed only if there is no sale pending stage
     */
    function adminWithdraw() external onlyOwner notOnSale {
        require(address(this).balance > 0, "Nothing to withdraw");

        (bool success, ) = _treasury.call{value: address(this).balance}("");
        require(success, "Transfer failed");
    }

    /**
     * @notice Returns DHV amount for 1 external token
     * @param _token External toke (DAI, USDT, NUX, 0 address for ETH)
     */
    function rateForToken(address _token) external view returns(uint256) {
        if (_token == address(0)) {
            return _calcEthPurchaseAmount(10**18);
        }
        else {
            return _calcPurchaseAmount(_token, 10**( uint256(IERC20Detailed(_token).decimals()) ));
        }
    }

    /***
     * VESTING INTERFACE
     ***/

    /**
     * @notice Transfers available for claim vested tokens to the user.
     */
    function claim() external {
        require(vestingStart!=0, "Vesting start is not set");
        require(_isPublicSaleOver(), "Not allowed to claim now");
        uint256 unclaimed = claimable(_msgSender());
        require(unclaimed > 0, "TokenVesting: no tokens are due");

        _claimed[_msgSender()] = _claimed[_msgSender()].add(unclaimed);
        IERC20Upgradeable(DHVToken).safeTransfer(_msgSender(), unclaimed);
        emit TokensClaimed(_msgSender(), unclaimed);
    }

    /**
     * @notice Gets the amount of tokens the user has already claimed
     * @param _user Address of the user who purchased tokens
     * @return The amount of the token claimed.
     */
    function claimed(address _user) external view returns (uint256) {
        return _claimed[_user];
    }

    /**
     * @notice Calculates the amount that has already vested but hasn't been claimed yet.
     * @param _user Address of the user who purchased tokens
     * @return The amount of the token vested and unclaimed.
     */
    function claimable(address _user) public view returns (uint256) {
        return _vestedAmount(_user).sub(_claimed[_user]);
    }

    /**
     * @dev Calculates the amount that has already vested.
     * @param _user Address of the user who purchased tokens
     * @return Amount of DHV already vested
     */
    function _vestedAmount(address _user) private view returns (uint256) {
        if (block.timestamp >= vestingStart.add(vestingDuration)) {
            return purchased[_user];
        } else {
            return purchased[_user].mul(block.timestamp.sub(vestingStart)).div(vestingDuration);
        }
    }

    /***
     * INTERNAL HELPERS
     ***/


    /**
     * @dev Checks if presale stage is on-going.
     * @return True is presale is active
     */
    function _isPreSale() virtual internal view returns (bool) {
        return (block.timestamp >= PRE_SALE_START && block.timestamp < PRE_SALE_END);
    }

    /**
     * @dev Checks if public sale stage is on-going.
     * @return True is public sale is active
     */
    function _isPublicSale() virtual internal view returns (bool) {
        return (block.timestamp >= PUBLIC_SALE_START && block.timestamp < PUBLIC_SALE_END);
    }

    /**
     * @dev Checks if public sale stage is over.
     * @return True is public sale is over
     */
    function _isPublicSaleOver() virtual internal view returns (bool) {
        return (block.timestamp >= PUBLIC_SALE_END);
    }

    /**
     * @dev Checks if public sale stage is over.
     * @return True is public sale is over
     */
    function _canWithdrawDHV() virtual internal view returns (bool) {
        return (block.timestamp >= vestingStart.add(WITHDRAWAL_PERIOD) );
    }

    /**
     * @dev Calculates DHV amount based on rate and token.
     * @param _token Supported ERC20 token
     * @param _amount Token amount to convert to DHV
     * @return DHV amount
     */
    function _calcPurchaseAmount(address _token, uint256 _amount) private view returns (uint256) {
        uint256 purchaseAmount = _amount.mul(rates[_token]).div(PRECISION);
        require(purchaseAmount > 0, "Rates not set");

        uint8 _decimals = IERC20Detailed(_token).decimals();
        if (_decimals < 18) {
            purchaseAmount = purchaseAmount.mul(10 ** (18 - uint256(_decimals)));
        }
        return purchaseAmount;
    }

    /**
     * @dev Calculates DHV amount based on rate and ETH amount.
     * @param _amount ETH amount to convert to DHV
     * @return DHV amount
     */
    function _calcEthPurchaseAmount(uint256 _amount) private view returns (uint256) {
        uint256 purchaseAmount = _amount.mul(ETHRate).div(PRECISION);
        require(purchaseAmount > 0, "Rates not set");
        return purchaseAmount;
    }

    /**
     * @dev Checks if currently purchased amount does not reach cap per wallet.
     * @param purchaseAmount DHV tokens currently purchased
     */
    function _checkCapReached(uint256 purchaseAmount) private view {
        if (_isPreSale()) {
            require(purchaseAmount.add(purchased[msg.sender]) <= maxTokensAmount, "Maximum allowed exceeded");
        }
        else {
            require(purchaseAmount.add(purchasedPublic[msg.sender]) <= maxTokensAmount, "Maximum allowed exceeded");   
        }
    }
}