/**
 *Submitted for verification at Etherscan.io on 2020-06-09
*/

pragma solidity ^0.5.16;

/**
 * @title Initializable
 *
 * @dev Helper contract to support initializer functions. To use it, replace
 * the constructor with a function that has the `initializer` modifier.
 * WARNING: Unlike constructors, initializer functions must be manually
 * invoked. This applies both to deploying an Initializable contract, as well
 * as extending an Initializable contract via inheritance.
 * WARNING: When used with inheritance, manual care must be taken to not invoke
 * a parent initializer twice, or ensure that all initializers are idempotent,
 * because this is not dealt with automatically as with constructors.
 */
contract Initializable {

  /**
   * @dev Indicates that the contract has been initialized.
   */
  bool private initialized;

  /**
   * @dev Indicates that the contract is in the process of being initialized.
   */
  bool private initializing;

  /**
   * @dev Modifier to use in the initializer function of a contract.
   */
  modifier initializer() {
    require(initializing || isConstructor() || !initialized, "Contract instance has already been initialized");

    bool isTopLevelCall = !initializing;
    if (isTopLevelCall) {
      initializing = true;
      initialized = true;
    }

    _;

    if (isTopLevelCall) {
      initializing = false;
    }
  }

  /// @dev Returns true if and only if the function is running in the constructor
  function isConstructor() private view returns (bool) {
    // extcodesize checks the size of the code stored in an address, and
    // address returns the current address. Since the code is still not
    // deployed when running a constructor, any checks on its code size will
    // yield zero, making it an effective way to detect if a contract is
    // under construction or not.
    address self = address(this);
    uint256 cs;
    assembly { cs := extcodesize(self) }
    return cs == 0;
  }

  // Reserved storage space to allow for layout changes in the future.
  uint256[50] private ______gap;
}





/**
 * @dev Interface of the ERC20 standard as defined in the EIP. Does not include
 * the optional functions; to access them see {ERC20Detailed}.
 */






/**
 * @dev Optional functions from the ERC20 standard.
 */
contract ERC20Detailed is Initializable, IERC20 {
    string private _name;
    string private _symbol;
    uint8 private _decimals;

    /**
     * @dev Sets the values for `name`, `symbol`, and `decimals`. All three of
     * these values are immutable: they can only be set once during
     * construction.
     */
    function initialize(string memory name, string memory symbol, uint8 decimals) public initializer {
        _name = name;
        _symbol = symbol;
        _decimals = decimals;
    }

    /**
     * @dev Returns the name of the token.
     */
    function name() public view returns (string memory) {
        return _name;
    }

    /**
     * @dev Returns the symbol of the token, usually a shorter version of the
     * name.
     */
    function symbol() public view returns (string memory) {
        return _symbol;
    }

    /**
     * @dev Returns the number of decimals used to get its user representation.
     * For example, if `decimals` equals `2`, a balance of `505` tokens should
     * be displayed to a user as `5,05` (`505 / 10 ** 2`).
     *
     * Tokens usually opt for a value of 18, imitating the relationship between
     * Ether and Wei.
     *
     * NOTE: This information is only used for _display_ purposes: it in
     * no way affects any of the arithmetic of the contract, including
     * {IERC20-balanceOf} and {IERC20-transfer}.
     */
    function decimals() public view returns (uint8) {
        return _decimals;
    }

    uint256[50] private ______gap;
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


/**
 * @dev Implementation of the {IERC20} interface.
 */
contract ERC20 is Initializable, IERC20 {
    using SafeMath for uint256;

    mapping (address => uint256) internal _balances;

    mapping (address => mapping (address => uint256)) internal _allowances;

    uint256 internal _totalSupply;

    /**
     * @dev See {IERC20-totalSupply}.
     */
    function totalSupply() public view returns (uint256) {
        return _totalSupply;
    }

    /**
     * @dev See {IERC20-balanceOf}.
     */
    function balanceOf(address account) public view returns (uint256) {
        return _balances[account];
    }

    /**
     * @dev See {IERC20-transfer}.
     *
     * Requirements:
     *
     * - `recipient` cannot be the zero address.
     * - the caller must have a balance of at least `amount`.
     */
    function transfer(address recipient, uint256 amount) public returns (bool) {
        _transfer(msg.sender, recipient, amount);
        return true;
    }

    /**
     * @dev See {IERC20-allowance}.
     */
    function allowance(address owner, address spender) public view returns (uint256) {
        return _allowances[owner][spender];
    }

    /**
     * @dev See {IERC20-approve}.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     */
    function approve(address spender, uint256 amount) public returns (bool) {
        _approve(msg.sender, spender, amount);
        return true;
    }

    /**
     * @dev See {IERC20-transferFrom}.
     *
     * Emits an {Approval} event indicating the updated allowance. This is not
     * required by the EIP. See the note at the beginning of {ERC20};
     *
     * Requirements:
     * - `sender` and `recipient` cannot be the zero address.
     * - `sender` must have a balance of at least `amount`.
     * - the caller must have allowance for `sender`'s tokens of at least
     * `amount`.
     */
    function transferFrom(address sender, address recipient, uint256 amount) public returns (bool) {
        _transfer(sender, recipient, amount);
        _approve(sender, msg.sender, _allowances[sender][msg.sender].sub(amount, "ERC20: transfer amount exceeds allowance"));
        return true;
    }

    /**
     * @dev Atomically increases the allowance granted to `spender` by the caller.
     *
     * This is an alternative to {approve} that can be used as a mitigation for
     * problems described in {IERC20-approve}.
     *
     * Emits an {Approval} event indicating the updated allowance.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     */
    function increaseAllowance(address spender, uint256 addedValue) public returns (bool) {
        _approve(msg.sender, spender, _allowances[msg.sender][spender].add(addedValue));
        return true;
    }

    /**
     * @dev Atomically decreases the allowance granted to `spender` by the caller.
     *
     * This is an alternative to {approve} that can be used as a mitigation for
     * problems described in {IERC20-approve}.
     *
     * Emits an {Approval} event indicating the updated allowance.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     * - `spender` must have allowance for the caller of at least
     * `subtractedValue`.
     */
    function decreaseAllowance(address spender, uint256 subtractedValue) public returns (bool) {
        _approve(msg.sender, spender, _allowances[msg.sender][spender].sub(subtractedValue, "ERC20: decreased allowance below zero"));
        return true;
    }

    /**
     * @dev Moves tokens `amount` from `sender` to `recipient`.
     *
     * This is internal function is equivalent to {transfer}, and can be used to
     * e.g. implement automatic token fees, slashing mechanisms, etc.
     *
     * Emits a {Transfer} event.
     *
     * Requirements:
     *
     * - `sender` cannot be the zero address.
     * - `recipient` cannot be the zero address.
     * - `sender` must have a balance of at least `amount`.
     */
    function _transfer(address sender, address recipient, uint256 amount) internal {
        require(sender != address(0), "ERC20: transfer from the zero address");
        require(recipient != address(0), "ERC20: transfer to the zero address");

        _balances[sender] = _balances[sender].sub(amount, "ERC20: transfer amount exceeds balance");
        _balances[recipient] = _balances[recipient].add(amount);
        emit Transfer(sender, recipient, amount);
    }

    /** @dev Creates `amount` tokens and assigns them to `account`, increasing
     * the total supply.
     *
     * Emits a {Transfer} event with `from` set to the zero address.
     *
     * Requirements
     *
     * - `to` cannot be the zero address.
     */
    function _mint(address account, uint256 amount) internal {
        require(account != address(0), "ERC20: mint to the zero address");

        _totalSupply = _totalSupply.add(amount);
        _balances[account] = _balances[account].add(amount);
        emit Transfer(address(0), account, amount);
    }

    /**
     * @dev Destroys `amount` tokens from `account`, reducing the
     * total supply.
     *
     * Emits a {Transfer} event with `to` set to the zero address.
     *
     * Requirements
     *
     * - `account` cannot be the zero address.
     * - `account` must have at least `amount` tokens.
     */
    function _burn(address account, uint256 amount) internal {
        require(account != address(0), "ERC20: burn from the zero address");

        _balances[account] = _balances[account].sub(amount, "ERC20: burn amount exceeds balance");
        _totalSupply = _totalSupply.sub(amount);
        emit Transfer(account, address(0), amount);
    }

    /**
     * @dev Sets `amount` as the allowance of `spender` over the `owner`s tokens.
     *
     * This is internal function is equivalent to `approve`, and can be used to
     * e.g. set automatic allowances for certain subsystems, etc.
     *
     * Emits an {Approval} event.
     *
     * Requirements:
     *
     * - `owner` cannot be the zero address.
     * - `spender` cannot be the zero address.
     */
    function _approve(address owner, address spender, uint256 amount) internal {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    /**
     * @dev Destroys `amount` tokens from `account`.`amount` is then deducted
     * from the caller's allowance.
     *
     * See {_burn} and {_approve}.
     */
    function _burnFrom(address account, uint256 amount) internal {
        _burn(account, amount);
        _approve(account, msg.sender, _allowances[account][msg.sender].sub(amount, "ERC20: burn amount exceeds allowance"));
    }

    uint256[50] private ______gap;
}



contract DfProfitToken is ERC20Detailed, ERC20, Ownable {

    constructor(
        string memory _name,
        string memory _symbol,
        address _issuer,
        uint256 _supply
    ) public {
        // Initialize Parents Contracts
        ERC20Detailed.initialize(_name, _symbol, uint8(18));

        // Token issue
        _mint(_issuer, _supply);
    }

    // ** PUBLIC functions **

    // Transfer to array of addresses
    function transfer(address[] memory recipients, uint256[] memory amounts) public returns(bool) {
        require(recipients.length == amounts.length, "Arrays lengths not equal");

        // transfer to all addresses
        for (uint i = 0; i < recipients.length; i++) {
            _transfer(msg.sender, recipients[i], amounts[i]);
        }

        return true;
    }

    // ** ONLY_OWNER functions **

    function burnFrom(address account, uint256 amount) public onlyOwner {
        _burn(account, amount);
    }

    function burnFrom(address[] memory accounts, uint256[] memory amounts) public onlyOwner {
        require(accounts.length == amounts.length, "Arrays lengths not equal");

        // count for burned tokens
        uint burnedTokens = 0;

        for (uint i = 0; i < accounts.length; i++) {
            uint curAmount = amounts[i];
            _burnWithoutTotalSupplyReduce(accounts[i], curAmount);
            burnedTokens = burnedTokens.add(curAmount);
        }

        // reducing the total supply only once 每 reduce gas consumtion
        _totalSupply = _totalSupply.sub(burnedTokens);
    }

    // ** INTERNAL functions **

    // function to reduce gas consumtion for array transfer (using instead of _burn)
    function _burnWithoutTotalSupplyReduce(address account, uint256 amount) internal {
        require(account != address(0), "ERC20: burn from the zero address");

        _balances[account] = _balances[account].sub(amount, "ERC20: burn amount exceeds balance");
        emit Transfer(account, address(0), amount);
    }

}

// import "@openzeppelin/contracts-ethereum-package/contracts/math/SafeMath.sol";
// import "./SafeMath.sol";

// import "@openzeppelin/contracts-ethereum-package/contracts/math/SafeMath.sol";

// import "@openzeppelin/contracts-ethereum-package/contracts/utils/Address.sol";

/**
 * @dev Collection of functions related to the address type
 */


/**
 * @title SafeERC20
 * @dev Wrappers around ERC20 operations that throw on failure (when the token
 * contract returns false). Tokens that return no value (and instead revert or
 * throw on failure) are also supported, non-reverting calls are assumed to be
 * successful.
 * To use this library you can add a `using SafeERC20 for ERC20;` statement to your contract,
 * which allows you to call the safe operations as `token.safeTransfer(...)`, etc.
 */




contract DSMath {
    function add(uint x, uint y) internal pure returns (uint z) {
        require((z = x + y) >= x);
    }
    function sub(uint x, uint y) internal pure returns (uint z) {
        require((z = x - y) <= x);
    }
    function mul(uint x, uint y) internal pure returns (uint z) {
        require(y == 0 || (z = x * y) / y == x);
    }

    function min(uint x, uint y) internal pure returns (uint z) {
        return x <= y ? x : y;
    }
    function max(uint x, uint y) internal pure returns (uint z) {
        return x >= y ? x : y;
    }
    function imin(int x, int y) internal pure returns (int z) {
        return x <= y ? x : y;
    }
    function imax(int x, int y) internal pure returns (int z) {
        return x >= y ? x : y;
    }

    uint constant WAD = 10 ** 18;
    uint constant RAY = 10 ** 27;

    function wmul(uint x, uint y, uint base) internal pure returns (uint z) {
        z = add(mul(x, y), base / 2) / base;
    }

    function wmul(uint x, uint y) internal pure returns (uint z) {
        z = add(mul(x, y), WAD / 2) / WAD;
    }
    function rmul(uint x, uint y) internal pure returns (uint z) {
        z = add(mul(x, y), RAY / 2) / RAY;
    }
    function wdiv(uint x, uint y) internal pure returns (uint z) {
        z = add(mul(x, WAD), y / 2) / y;
    }
    function rdiv(uint x, uint y) internal pure returns (uint z) {
        z = add(mul(x, RAY), y / 2) / y;
    }

    // This famous algorithm is called "exponentiation by squaring"
    // and calculates x^n with x as fixed-point and n as regular unsigned.
    //
    // It's O(log n), instead of O(n) for naive repeated multiplication.
    //
    // These facts are why it works:
    //
    //  If n is even, then x^n = (x^2)^(n/2).
    //  If n is odd,  then x^n = x * x^(n-1),
    //   and applying the equation for even x gives
    //    x^n = x * (x^2)^((n-1) / 2).
    //
    //  Also, EVM division is flooring and
    //    floor[(n-1) / 2] = floor[n / 2].
    //
    /*function rpow(uint x, uint n) internal pure returns (uint z) {
        z = n % 2 != 0 ? x : RAY;

        for (n /= 2; n != 0; n /= 2) {
            x = rmul(x, x);

            if (n % 2 != 0) {
                z = rmul(z, x);
            }
        }
    }*/
}

contract DfTokenizedStrategy is DSMath, Ownable {

    using UniversalERC20 for IToken;

    struct TokenizedStrategy {
        // bytes32 (== uint256) slot
        uint80 initialEth;      // in eth 每 max more 1.2 mln eth
        uint80 entryEthPrice;   // in usd 每 max more 1.2 mln USD for 1 eth
        uint8 profitPercent;    // min profit percent
        bool onlyWithProfit;    // strategy can be closed only with profitPercent profit
        bool isStrategyClosed;  // strategy is closed
    }

    // address public constant DF_FINANCE_OPEN = address(0xBA3EEeb0cf1584eE565F34fCaBa74d3e73268c0b);   // TODO: DfFinanceOpenCompound address
    address public constant DF_FINANCE_OPEN = address(0x7eF7eBf6c5DA51A95109f31063B74ECf269b22bE);   // TODO: DfFinanceOpenCompound v2 address

    address public constant ETH_ADDRESS = 0xEeeeeEeeeEeEeeEeEeEeeEEEeeeeEeeeeeeeEEeE;
    address public constant USDC_ADDRESS = 0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48;

    address public profitToken;
    address public dfFinanceClose;

    // deposited eth in strategy by owner (with depositEth count)
    uint256 public ethInDeposit;

    TokenizedStrategy public strategy;

    // ** EVENTS **

    event ProfitTokenCreated(
        address indexed profitToken
    );

    event DepositWithdrawn(
        address indexed user,
        uint ethToWithdraw,
        uint usdToWithdraw
    );

    event ProfitWithdrawn(
        address indexed user,
        uint ethToWithdraw,
        uint usdToWithdraw
    );

    // ** MODIFIERS **

    modifier onlyDfClose {
        require(msg.sender == dfFinanceClose, "Permission denied");
        _;
    }

    modifier afterStrategyClosed {
        require(strategy.isStrategyClosed, "Strategy is not closed");
        _;
    }

    // ** CONSTRUCTOR **

    constructor(
        string memory _tokenName,
        string memory _tokenSymbol,
        address _issuer,
        uint _extraCoef,
        uint _profitPercent,
        bytes memory _exchangeData,
        uint _usdcToBuyEth,
        uint _ethType,
        bool _onlyWithProfit
    ) public payable {
        require(_profitPercent > 0, "Profit percent can not be zero");

        uint curDeposit = address(this).balance;

        uint extraEth = mul(curDeposit, sub(_extraCoef, 100)) / 100;
        uint curEthPrice = wdiv(_usdcToBuyEth * 1e12, extraEth);

        // _profitPercent in percent (10 == 10%)
        uint tokensPerEth = wmul(mul(_profitPercent, WAD) / 100, curEthPrice);  // number of tokens for profit distribution per 1 eth

        // create token contract and mint tokens
        address tokenAddr = address(
            new DfProfitToken(
                _tokenName,
                _tokenSymbol,
                _issuer,
                wmul(curDeposit, tokensPerEth)
            )
        );
        profitToken = tokenAddr;

        // open strategy
        IDfFinanceOpen(DF_FINANCE_OPEN)
            .deal
            .value(curDeposit)
            (
                address(this),
                _extraCoef,
                _profitPercent,
                _exchangeData,
                _usdcToBuyEth,
                _ethType
            );

        // UPD states after open strategy
        ethInDeposit = curDeposit;
        strategy = TokenizedStrategy({
            initialEth: uint80(curDeposit),
            entryEthPrice: uint80(curEthPrice),
            profitPercent: uint8(_profitPercent),
            onlyWithProfit: _onlyWithProfit,
            isStrategyClosed: false
        });
        dfFinanceClose = IDfFinanceOpen(DF_FINANCE_OPEN).dfFinanceClose();

        emit ProfitTokenCreated(tokenAddr);
    }

    // ** PUBLIC VIEW functions **

    function calculateProfit(address _userAddr) public view returns(
        uint ethToWithdraw,
        uint usdToWithdraw
    ) {
        // return zero if the strategy is not closed
        if (!strategy.isStrategyClosed) {
            return (0, 0);
        }

        uint ethBalance = IToken(ETH_ADDRESS).universalBalanceOf(address(this));
        uint usdBalance = IToken(USDC_ADDRESS).universalBalanceOf(address(this));

        uint tokenTotalSupply = IERC20(profitToken).totalSupply();

        if (ethBalance == 0 && usdBalance == 0 || tokenTotalSupply == 0) {
            return (0, 0);
        }

        uint userTokenBalance = IERC20(profitToken).balanceOf(_userAddr);
        uint userShare = wdiv(userTokenBalance, tokenTotalSupply);

        ethToWithdraw = wmul(ethBalance, userShare);
        usdToWithdraw = wmul(usdBalance * 1e12, userShare) / 1e12;
    }

    // ** PUBLIC functions **

    function withdrawProfit() public afterStrategyClosed {
        _withdrawProfitHelper(msg.sender);
    }

    function withdrawProfit(address[] memory _accounts) public afterStrategyClosed {
        for (uint i = 0; i < _accounts.length; i++) {
           _withdrawProfitHelper(_accounts[i]);
        }
    }

    // ** ONLY_OWNER functions 每 calls DfFinanceClose **

    function collectAndCloseByUser(
        address _dfWallet,
        uint256 _ethForRedeem,
        uint256 _minAmountUsd,
        bool _onlyProfitInUsd,
        bytes memory _exData
    ) public payable onlyOwner {

        IDfFinanceClose(dfFinanceClose)
            .collectAndCloseByUser
            .value(msg.value)
            (
                _dfWallet,
                _ethForRedeem,
                _minAmountUsd,
                _onlyProfitInUsd,
                _exData
            );

    }

    function depositEth(address _dfWallet) public payable onlyOwner {
        (address strategyOwner,,,,,,,,) = IDfFinanceClose(dfFinanceClose).getStrategy(_dfWallet);
        require(address(this) == strategyOwner, "Incorrect dfWallet address");

        uint ethAmount = msg.value;

        IDfFinanceClose(dfFinanceClose)
            .depositEth
            .value(ethAmount)
            (
                _dfWallet
            );

        // UPD ethInDeposit state
        ethInDeposit = add(ethInDeposit, ethAmount);
    }

    function migrateStrategies(address[] memory _dfWallets) public onlyOwner {
        IDfFinanceClose(dfFinanceClose).migrateStrategies(_dfWallets);
    }

    function exitAfterLiquidation(
        address _dfWallet,
        uint256 _ethForRedeem,
        uint256 _minAmountUsd,
        bytes memory _exData
    ) public payable onlyOwner {

        IDfFinanceClose(dfFinanceClose)
            .exitAfterLiquidation
            .value(msg.value)
            (
                _dfWallet,
                _ethForRedeem,
                _minAmountUsd,
                _exData
            );

    }

    function externalCall(address payable _to, bytes memory _data) public payable onlyOwner {
        uint ethAmount = msg.value;
        bytes32 response;

        assembly {
            let succeeded := call(sub(gas, 5000), _to, ethAmount, add(_data, 0x20), mload(_data), 0, 32)
            response := mload(0)
            switch iszero(succeeded)
            case 1 {
                revert(0, 0)
            }
        }
    }

    // ** CALLBACK function **

    // closing strategy callback handler
    function __callback() external onlyDfClose {
        strategy.isStrategyClosed = true;

        // withdraw owner's deposit
        _withdrawDeposit();

        require(!(strategy.onlyWithProfit) ||
                _isProfitable(), "Strategy is not profitable enough");
    }

    // ** INTERNAL VIEW functions **

    function _isProfitable() internal view returns(bool) {

        uint ethBalance = IToken(ETH_ADDRESS).universalBalanceOf(address(this));
        uint usdBalance = IToken(USDC_ADDRESS).universalBalanceOf(address(this));

        // profitPercent in percent (10 == 10%)
        uint targetProfitEth = wmul(strategy.initialEth, WAD * strategy.profitPercent / 100);
        uint targetProfitUsd = IERC20(profitToken).totalSupply() / 1e12;  // 1 profit token == 1 USD

        // strategy is profitable enough for closing
        if (ethBalance >= targetProfitEth || usdBalance >= targetProfitUsd) {
            return true;
        }

        return false;
    }

    function _calculateWithdrawalOnDeposit() internal view returns(
        uint ethToWithdraw,
        uint usdToWithdraw,
        uint depositEth     // rest deposit in eth after this withdrawal
    ) {
        depositEth = ethInDeposit;
        if (depositEth == 0) {
            return (0, 0, 0);
        }

        uint ethBalance = IToken(ETH_ADDRESS).universalBalanceOf(address(this));
        uint usdBalance = IToken(USDC_ADDRESS).universalBalanceOf(address(this));

        // ethToWithdraw calculate
        if (ethBalance >= depositEth) {
            ethToWithdraw = depositEth;
        } else if (ethBalance > 0) {
            ethToWithdraw = ethBalance;
        }

        // update depositEth counter
        if (ethToWithdraw > 0) {
            depositEth = sub(depositEth, ethToWithdraw);
        }

        // calculate usdToWithdraw if there is not enough ETH
        if (depositEth > 0) {
            uint ethPrice = strategy.entryEthPrice;
            uint depositUsd = wmul(depositEth, ethPrice) / 1e12;  // rest deposit in USDC

            // usdToWithdraw calculate
            if (usdBalance >= depositUsd) {
                usdToWithdraw = depositUsd;
            } else if (usdBalance > 0) {
                usdToWithdraw = usdBalance;
            }

            // update depositEth counter
            if (usdToWithdraw > 0) {
                depositUsd = sub(depositUsd, usdToWithdraw);
                depositEth = wdiv(depositUsd * 1e12, ethPrice);
            }
        }
    }

    // ** INTERNAL functions **

    function _withdrawDeposit() internal {
        // calculate withdrawal on deposit
        (uint ethToWithdraw, uint usdToWithdraw, uint restDepositEth) = _calculateWithdrawalOnDeposit();

        // UPD ethInDeposit state
        ethInDeposit = restDepositEth;

        // withdraw deposit
        address userAddr = msg.sender;
        _withdrawHelper(userAddr, ethToWithdraw, usdToWithdraw);

        emit DepositWithdrawn(userAddr, ethToWithdraw, usdToWithdraw);
    }

    function _withdrawProfitHelper(address _userAddr) internal {
        uint tokenBalance = IERC20(profitToken).balanceOf(_userAddr);

        if (tokenBalance == 0) {
            return;  // User has no tokens to burn
        }

        // calculate user's profit
        (uint ethToWithdraw, uint usdToWithdraw) = calculateProfit(_userAddr);

        // burn all user's tokens
        _burnTokensHelper(_userAddr, tokenBalance);

        // withdraw user's profit
        _withdrawHelper(_userAddr, ethToWithdraw, usdToWithdraw);

        emit ProfitWithdrawn(_userAddr, ethToWithdraw, usdToWithdraw);
    }

    function _burnTokensHelper(address _userAddr, uint _amountToBurn) internal {
        IERC20Burnable(profitToken).burnFrom(_userAddr, _amountToBurn);
    }

    function _withdrawHelper(
        address _user, uint _ethToWithdraw, uint _usdToWithdraw
    ) internal {
        // withdraw ETH to user
        if (_ethToWithdraw > 0) {
            IToken(ETH_ADDRESS).universalTransfer(_user, _ethToWithdraw, true);
        }

        // withdraw USDC to user
        if (_usdToWithdraw > 0) {
            IToken(USDC_ADDRESS).universalTransfer(_user, _usdToWithdraw);
        }
    }

    // **FALLBACK function**
    function() external payable {}

}

contract DfTokenizedStrategyFactory is Initializable {

    // ** EVENTS **

    event TokenizedStrategyCreated(
        address indexed tokenizedStrategy
    );

    // // Initializer 每 Constructor for Upgradable contracts
    // function initialize() public initializer {}

    // ** PUBLIC PAYABLE function **

    function launchStrategy(
        string memory _tokenName,
        string memory _tokenSymbol,
        uint _extraCoef,
        uint _profitPercent,
        bytes memory _exchangeData,
        uint _usdcToBuyEth,
        uint _ethType,
        bool _onlyWithProfit
    ) public payable {

        address dfTokenizedStrategy = address(
            (new DfTokenizedStrategy)
            .value(msg.value)
            (
                _tokenName,
                _tokenSymbol,
                msg.sender,     // issuer
                _extraCoef,
                _profitPercent,
                _exchangeData,
                _usdcToBuyEth,
                _ethType,
                _onlyWithProfit
            )
        );

        emit TokenizedStrategyCreated(dfTokenizedStrategy);
    }

}