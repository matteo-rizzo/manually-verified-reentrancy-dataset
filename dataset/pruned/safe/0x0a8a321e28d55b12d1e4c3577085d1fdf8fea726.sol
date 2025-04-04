/**
 *Submitted for verification at Etherscan.io on 2020-07-25
*/

// File: @openzeppelin/contracts-ethereum-package/contracts/math/SafeMath.sol

pragma solidity ^0.6.0;

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


// File: @openzeppelin/contracts-ethereum-package/contracts/Initializable.sol

pragma solidity >=0.4.24 <0.7.0;


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

// File: @openzeppelin/contracts-ethereum-package/contracts/GSN/Context.sol

pragma solidity ^0.6.0;


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
contract ContextUpgradeSafe is Initializable {
    // Empty internal constructor, to prevent people from mistakenly deploying
    // an instance of this contract, which should be used via inheritance.

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

// File: @openzeppelin/contracts-ethereum-package/contracts/access/Ownable.sol

pragma solidity ^0.6.0;


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
contract OwnableUpgradeSafe is Initializable, ContextUpgradeSafe {
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

// File: @openzeppelin/contracts-ethereum-package/contracts/token/ERC20/IERC20.sol

pragma solidity ^0.6.0;

/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
 */


// File: @openzeppelin/contracts-ethereum-package/contracts/utils/Address.sol

pragma solidity ^0.6.2;

/**
 * @dev Collection of functions related to the address type
 */


// File: @openzeppelin/contracts-ethereum-package/contracts/token/ERC20/ERC20.sol

pragma solidity ^0.6.0;






/**
 * @dev Implementation of the {IERC20} interface.
 *
 * This implementation is agnostic to the way tokens are created. This means
 * that a supply mechanism has to be added in a derived contract using {_mint}.
 * For a generic mechanism see {ERC20MinterPauser}.
 *
 * TIP: For a detailed writeup see our guide
 * https://forum.zeppelin.solutions/t/how-to-implement-erc20-supply-mechanisms/226[How
 * to implement supply mechanisms].
 *
 * We have followed general OpenZeppelin guidelines: functions revert instead
 * of returning `false` on failure. This behavior is nonetheless conventional
 * and does not conflict with the expectations of ERC20 applications.
 *
 * Additionally, an {Approval} event is emitted on calls to {transferFrom}.
 * This allows applications to reconstruct the allowance for all accounts just
 * by listening to said events. Other implementations of the EIP may not emit
 * these events, as it isn't required by the specification.
 *
 * Finally, the non-standard {decreaseAllowance} and {increaseAllowance}
 * functions have been added to mitigate the well-known issues around setting
 * allowances. See {IERC20-approve}.
 */
contract ERC20UpgradeSafe is Initializable, ContextUpgradeSafe, IERC20 {
    using SafeMath for uint256;
    using Address for address;

    mapping (address => uint256) private _balances;

    mapping (address => mapping (address => uint256)) private _allowances;

    uint256 private _totalSupply;

    string private _name;
    string private _symbol;
    uint8 private _decimals;

    /**
     * @dev Sets the values for {name} and {symbol}, initializes {decimals} with
     * a default value of 18.
     *
     * To select a different value for {decimals}, use {_setupDecimals}.
     *
     * All three of these values are immutable: they can only be set once during
     * construction.
     */

    function __ERC20_init(string memory name, string memory symbol) internal initializer {
        __Context_init_unchained();
        __ERC20_init_unchained(name, symbol);
    }

    function __ERC20_init_unchained(string memory name, string memory symbol) internal initializer {


        _name = name;
        _symbol = symbol;
        _decimals = 18;

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
     * Ether and Wei. This is the value {ERC20} uses, unless {_setupDecimals} is
     * called.
     *
     * NOTE: This information is only used for _display_ purposes: it in
     * no way affects any of the arithmetic of the contract, including
     * {IERC20-balanceOf} and {IERC20-transfer}.
     */
    function decimals() public view returns (uint8) {
        return _decimals;
    }

    /**
     * @dev See {IERC20-totalSupply}.
     */
    function totalSupply() public view override returns (uint256) {
        return _totalSupply;
    }

    /**
     * @dev See {IERC20-balanceOf}.
     */
    function balanceOf(address account) public view override returns (uint256) {
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
    function transfer(address recipient, uint256 amount) public virtual override returns (bool) {
        _transfer(_msgSender(), recipient, amount);
        return true;
    }

    /**
     * @dev See {IERC20-allowance}.
     */
    function allowance(address owner, address spender) public view virtual override returns (uint256) {
        return _allowances[owner][spender];
    }

    /**
     * @dev See {IERC20-approve}.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     */
    function approve(address spender, uint256 amount) public virtual override returns (bool) {
        _approve(_msgSender(), spender, amount);
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
     * - the caller must have allowance for ``sender``'s tokens of at least
     * `amount`.
     */
    function transferFrom(address sender, address recipient, uint256 amount) public virtual override returns (bool) {
        _transfer(sender, recipient, amount);
        _approve(sender, _msgSender(), _allowances[sender][_msgSender()].sub(amount, "ERC20: transfer amount exceeds allowance"));
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
    function increaseAllowance(address spender, uint256 addedValue) public virtual returns (bool) {
        _approve(_msgSender(), spender, _allowances[_msgSender()][spender].add(addedValue));
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
    function decreaseAllowance(address spender, uint256 subtractedValue) public virtual returns (bool) {
        _approve(_msgSender(), spender, _allowances[_msgSender()][spender].sub(subtractedValue, "ERC20: decreased allowance below zero"));
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
    function _transfer(address sender, address recipient, uint256 amount) internal virtual {
        require(sender != address(0), "ERC20: transfer from the zero address");
        require(recipient != address(0), "ERC20: transfer to the zero address");

        _beforeTokenTransfer(sender, recipient, amount);

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
    function _mint(address account, uint256 amount) internal virtual {
        require(account != address(0), "ERC20: mint to the zero address");

        _beforeTokenTransfer(address(0), account, amount);

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
    function _burn(address account, uint256 amount) internal virtual {
        require(account != address(0), "ERC20: burn from the zero address");

        _beforeTokenTransfer(account, address(0), amount);

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
    function _approve(address owner, address spender, uint256 amount) internal virtual {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    /**
     * @dev Sets {decimals} to a value other than the default one of 18.
     *
     * WARNING: This function should only be called from the constructor. Most
     * applications that interact with token contracts will not expect
     * {decimals} to ever change, and may work incorrectly if it does.
     */
    function _setupDecimals(uint8 decimals_) internal {
        _decimals = decimals_;
    }

    /**
     * @dev Hook that is called before any transfer of tokens. This includes
     * minting and burning.
     *
     * Calling conditions:
     *
     * - when `from` and `to` are both non-zero, `amount` of ``from``'s tokens
     * will be to transferred to `to`.
     * - when `from` is zero, `amount` tokens will be minted for `to`.
     * - when `to` is zero, `amount` of ``from``'s tokens will be burned.
     * - `from` and `to` are never both zero.
     *
     * To learn more about hooks, head to xref:ROOT:extending-contracts.adoc#using-hooks[Using Hooks].
     */
    function _beforeTokenTransfer(address from, address to, uint256 amount) internal virtual { }

    uint256[44] private __gap;
}

// File: @openzeppelin/contracts-ethereum-package/contracts/token/ERC20/ERC20Burnable.sol

pragma solidity ^0.6.0;




/**
 * @dev Extension of {ERC20} that allows token holders to destroy both their own
 * tokens and those that they have an allowance for, in a way that can be
 * recognized off-chain (via event analysis).
 */
abstract contract ERC20BurnableUpgradeSafe is Initializable, ContextUpgradeSafe, ERC20UpgradeSafe {
    function __ERC20Burnable_init() internal initializer {
        __Context_init_unchained();
        __ERC20Burnable_init_unchained();
    }

    function __ERC20Burnable_init_unchained() internal initializer {


    }

    /**
     * @dev Destroys `amount` tokens from the caller.
     *
     * See {ERC20-_burn}.
     */
    function burn(uint256 amount) public virtual {
        _burn(_msgSender(), amount);
    }

    /**
     * @dev Destroys `amount` tokens from `account`, deducting from the caller's
     * allowance.
     *
     * See {ERC20-_burn} and {ERC20-allowance}.
     *
     * Requirements:
     *
     * - the caller must have allowance for ``accounts``'s tokens of at least
     * `amount`.
     */
    function burnFrom(address account, uint256 amount) public virtual {
        uint256 decreasedAllowance = allowance(account, _msgSender()).sub(amount, "ERC20: burn amount exceeds allowance");

        _approve(account, _msgSender(), decreasedAllowance);
        _burn(account, amount);
    }

    uint256[50] private __gap;
}

// File: contracts/Bonded.sol

pragma solidity ^0.6.0;

contract Bonded is OwnableUpgradeSafe {

    using SafeMath for uint256;

    uint public TGE;
    uint public constant month = 30 days;
    uint constant decimals = 18;
    uint constant decMul = uint(10) ** decimals;

    address public advisorsAddress;
    address public foundationAddress;
    address public ecosystemAddress;
    address public reserveAddress;
    address public marketingAddress;
    address public employeesAddress;

    uint public constant SEED_POOL        = 50000000 * decMul;
    uint public constant ADVISORS_POOL    = 4800000 * decMul;
    uint public constant FOUNDATION_POOL  = 12000000 * decMul;
    uint public constant ECOSYSTEM_POOL   = 12000000 * decMul;
    uint public constant RESERVE_POOL     = 6000000 * decMul;
    uint public constant MARKETING_POOL   = 4800000 * decMul;
    uint public constant EMPLOYEES_POOL   = 8400000 * decMul;

    uint public currentSeedPool         = SEED_POOL;
    uint public currentAdvisorsPool     = ADVISORS_POOL;
    uint public currentFoundationPool   = FOUNDATION_POOL;
    uint public currentEcosystemPool    = ECOSYSTEM_POOL;
    uint public currentReservePool      = RESERVE_POOL;
    uint public currentMarketingPool    = MARKETING_POOL;
    uint public currentEmployeesPool    = EMPLOYEES_POOL;

    ERC20BurnableUpgradeSafe public token;

    mapping(address => uint) public seedWhitelist;

    modifier requireSetTGE() {
        require (TGE > 0, "TGE must be set");
        _;
    }


    constructor(
        address _advisorsAddress,
        address _foundationAddress,
        address _ecosystemAddress,
        address _reserveAddress,
        address _marketingAddress,
        address _employeesAddress
    )
        public
    {
        __Ownable_init_unchained();

        advisorsAddress = _advisorsAddress;
        foundationAddress = _foundationAddress;
        ecosystemAddress = _ecosystemAddress;
        reserveAddress = _reserveAddress;
        marketingAddress = _marketingAddress;
        employeesAddress = _employeesAddress;
    }

    /**
     * @dev Sets the Plutus ERC-20 token contract address
     */
    function setTokenContract(address _tokenAddress) public onlyOwner {
        require (true == isContract(_tokenAddress), "require contract");
        token = ERC20BurnableUpgradeSafe(_tokenAddress);
    }
    
    /**
     * @dev Sets the current TGE from where the vesting period will be counted. Can be used only if TGE is zero.
     */
    function setTGE() public onlyOwner {
        require (TGE == 0, "TGE has already been set");
        TGE = now;
    }
    
    /**
     * @dev Sets each address from `addresses` as the key and each balance
     * from `balances` to the privateWhitelist. Can be used only by an owner.
     */
    function addToWhitelist(
        address[] memory addresses,
        uint[] memory balances
    )
        public
        onlyOwner
    {
        require(
            addresses.length == balances.length,
            "Invalid request length"
        );
        for (uint i = 0; i < addresses.length; i++) {
            seedWhitelist[addresses[i]] = balances[i];
        }
    }
    
    /**
     * @dev claim seed tokens from the contract balance.
     * `amount` means how many tokens must be claimed.
     * Can be used only by an owner or by any whitelisted person
     */
    function claimSeedTokens(uint amount)
        public
        requireSetTGE()
    {
        require(
            seedWhitelist[msg.sender] > 0 ||
            msg.sender == owner(),
            "Sender is not whitelisted"
        );
        require(
            seedWhitelist[msg.sender] >= amount ||
            msg.sender == owner(),
            "Exceeded token amount"
        );
        require(currentSeedPool >= amount, "Exceeded seedpool");
        require(amount > 0, "Amount should be more than 0");

        currentSeedPool = currentSeedPool.sub(amount);
        
        // Bridge fees are not taken off for contract owner
        if (msg.sender == owner()) {
            token.transfer(msg.sender, amount);
            return;
        }
        
        seedWhitelist[msg.sender] = seedWhitelist[msg.sender].sub(amount);
        
        uint amountToBurn = calculateFee(amount);

        if (amountToBurn > 0) {
            token.burn(amountToBurn);
        }
        
        token.transfer(msg.sender, amount.sub(amountToBurn));
    }
    
    /**
     * @dev claim advisors tokens from the contract balance.
     * Can be used only by an owner or from advisorsAddress.
     * Tokens will be send to sender address.
     */
    function claimAdvisorsTokens()
        public
        requireSetTGE()
    {
        require(
            msg.sender == advisorsAddress || msg.sender == owner(),
            "Unauthorised sender"
        );
        require(currentAdvisorsPool > 0, "nothing to claim");

        uint amount = 0;
        uint256 periodsPass = now.sub(TGE).div(6*month);
        require(periodsPass >= 1, "Vesting period");

        uint amountToClaim = ADVISORS_POOL.div(4);
        for (uint i = 1; i <= periodsPass; i++) {
            if (
                currentAdvisorsPool <= ADVISORS_POOL.sub(
                    amountToClaim.mul(i)
                )
            ) {
                continue;
            }
            currentAdvisorsPool = currentAdvisorsPool.sub(amountToClaim);
            amount = amount.add(amountToClaim);
        }
        
        // 25% each 6 months
        require (amount > 0, "nothing to claim");
        
        uint amountToBurn = calculateFee(amount);

        if (amountToBurn > 0) {
            token.burn(amountToBurn);
        }
        
        token.transfer(advisorsAddress, amount.sub(amountToBurn));
    }
    
    /**
     * @dev claim foundation tokens from the contract balance.
     * Can be used only by an owner or from foundationAddress.
     * Tokens will be send to foundationAddress.
     */
    function claimFoundationTokens()
    public
    requireSetTGE()
    {
        require(
            msg.sender == foundationAddress || msg.sender == owner(),
            "Unauthorised sender"
        );
        require(currentFoundationPool > 0, "nothing to claim");
        require(now >= TGE + 30 * month, "Vesting period");

        uint amount = 0;
        // 2.5 years of vestiong period
        uint256 periodsPass = now.sub(TGE).sub(30 * month).div(6 * month);

        uint amountToClaim = FOUNDATION_POOL.div(4);
        for (uint i = 0; i <= periodsPass; i++) {
            if (
                currentFoundationPool <= FOUNDATION_POOL
                    .sub(amountToClaim.mul(i + 1))
            ) {
                continue;
            }
            currentFoundationPool = currentFoundationPool.sub(amountToClaim);
            amount = amount.add(amountToClaim);
        }

        // 25% each 6 months
        require(amount > 0, "nothing to claim");

        // No sense to burn because 2.5 years vestiong period
        token.transfer(foundationAddress, amount);
    }

    /**
     * @dev claim ecosystem tokens from the contract balance.
     * Can be used only by an owner or from ecosystemAddress.
     * Tokens will be send to ecosystemAddress.
     */
    function claimEcosystemTokens() public requireSetTGE() {
        require(
            msg.sender == ecosystemAddress || msg.sender == owner(),
            "Unauthorised sender"
        );

        //6 months of vestiong period
        require(now >= TGE + 6*month, "Vesting period");
        
        uint monthPassed = ((now.sub(TGE)).div(month)).sub(5);
        
        // Avoid overflow when releasing 2% each month
        if (monthPassed > 50) {
            monthPassed = 50;
        }

        uint amount = currentEcosystemPool.sub(
            ECOSYSTEM_POOL.sub(
                (ECOSYSTEM_POOL.mul(monthPassed*2)).div(100)
            )
        );
        require (amount > 0, "nothing to claim");
        
        currentEcosystemPool = currentEcosystemPool.sub(amount);
        
        uint amountToBurn = calculateFee(amount);

        if (amountToBurn > 0) {
            token.burn(amountToBurn);
        }
        
        token.transfer(ecosystemAddress, amount.sub(amountToBurn));
    }
    
    /**
     * @dev claim reserve tokens from the contract balance.
     * Can be used only by an owner or from reserveAddress.
     * Tokens will be send to reserveAddress.
     */
    function claimReserveTokens()
        public
        requireSetTGE()
    {
        require(
            msg.sender == reserveAddress || msg.sender == owner(),
            "Unauthorised sender"
        );

        //6 months of vesting period
        require(now >= TGE + 6*month, "Vesting period");
        
        uint monthPassed = now.sub(TGE).div(month).sub(5);
        
        // Avoid overflow when releasing 5% each month
        if (monthPassed > 20) {
            monthPassed = 20;
        }
        
        uint amount = currentReservePool.sub(
            RESERVE_POOL.sub(
                (RESERVE_POOL.mul(monthPassed*5)).div(100)
            )
        );

        currentReservePool = currentReservePool.sub(amount);
        require (amount > 0, "nothing to claim");
        
        uint amountToBurn = calculateFee(amount);

        if (amountToBurn > 0) {
            token.burn(amountToBurn);
        }
        
        token.transfer(reserveAddress, amount.sub(amountToBurn));
    }
    
    /**
     * @dev claim marketing tokens from the contract balance.
     * Can be used only by an owner or from marketingAddress.
     * Tokens will be send to marketingAddress.
     */
    function claimMarketingTokens()
        public
        requireSetTGE()
    {
        require(
            msg.sender == marketingAddress || msg.sender == owner(),
            "Unauthorised sender"
        );

        // no vestiong period
        uint monthPassed = (now.sub(TGE)).div(month).add(1);
        
        // Avoid overflow when releasing 10% each month
        if (monthPassed > 10) {
            monthPassed = 10;
        }
        
        uint amount = currentMarketingPool.sub(
            MARKETING_POOL.sub(
                MARKETING_POOL.mul(monthPassed*10).div(100)
            )
        );
        require (amount > 0, "nothing to claim");

        currentMarketingPool = currentMarketingPool.sub(amount);
        
        uint amountToBurn = calculateFee(amount);

        if (amountToBurn > 0) {
            token.burn(amountToBurn);
        }
        
        token.transfer(marketingAddress, amount.sub(amountToBurn));
    }

    /**
     * @dev claim employee tokens from the contract balance.
     * Can be used only by an owner or from employeesAddress
     */
    function claimEmployeeTokens()
        public
        requireSetTGE()
    {
        require(
            msg.sender == employeesAddress || msg.sender == owner(),
            "Unauthorised sender"
        );

        // 1.5 years of vesting period
        require(now >= TGE + 18 * month, "Vesting period");

        // Get the total months passed after the vesting period of 1.5 years
        uint monthPassed = (now.sub(TGE)).div(month).sub(18).add(1);

        // Avoid overflow when releasing 10% each month
        // If more than 10 months passed without token claim then 100% tokens can be claimed at once.
        if (monthPassed > 10) {
            monthPassed = 10;
        }

        uint amount = currentEmployeesPool.sub(
            EMPLOYEES_POOL.sub(
                EMPLOYEES_POOL.mul(monthPassed*10).div(100)
            )
        );
        require (amount > 0, "nothing to claim");

        currentEmployeesPool = currentEmployeesPool.sub(amount);

        //18 month of vesting period, no need to check fee        
        token.transfer(employeesAddress, amount);
    }


    /**
     * @dev getCurrentFee calculate current fee according to TGE and returns it.
     * NOTE: divide result by 1000 to calculate current percent.
     */
    function getCurrentFee() public view returns (uint) {
        if (now >= TGE + 9 * month) {
            return 0;
        }
        if (now >= TGE + 8 * month) {
            return 92;
        }
        if (now >= TGE + 7 * month) {
            return 115;
        }
        if (now >= TGE + 6 * month) {
            return 144;
        }
        if (now >= TGE + 5 * month) {
            return 180;
        }
        if (now >= TGE + 4 * month) {
            return 225;
        }
        if (now >= TGE + 3 * month) {
            return 282;
        }
        if (now >= TGE + 2 * month) {
            return 352;
        }
        if (now >= TGE + 1 * month) {
            return 440;
        }

        return 550;
    }

    function calculateFee(uint256 amount) public view returns (uint) {
        return amount.mul(getCurrentFee()).div(1000);
    }

    function isContract(address addr) private view returns (bool) {
        uint size;
        assembly { size := extcodesize(addr) }
        return size > 0;
    }
}