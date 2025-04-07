/**
 *Submitted for verification at Etherscan.io on 2021-03-17
*/

/*
    .'''''''''''..     ..''''''''''''''''..       ..'''''''''''''''..
    .;;;;;;;;;;;'.   .';;;;;;;;;;;;;;;;;;,.     .,;;;;;;;;;;;;;;;;;,.
    .;;;;;;;;;;,.   .,;;;;;;;;;;;;;;;;;;;,.    .,;;;;;;;;;;;;;;;;;;,.
    .;;;;;;;;;,.   .,;;;;;;;;;;;;;;;;;;;;,.   .;;;;;;;;;;;;;;;;;;;;,.
    ';;;;;;;;'.  .';;;;;;;;;;;;;;;;;;;;;;,. .';;;;;;;;;;;;;;;;;;;;;,.
    ';;;;;,..   .';;;;;;;;;;;;;;;;;;;;;;;,..';;;;;;;;;;;;;;;;;;;;;;,.
    ......     .';;;;;;;;;;;;;,'''''''''''.,;;;;;;;;;;;;;,'''''''''..
              .,;;;;;;;;;;;;;.           .,;;;;;;;;;;;;;.
             .,;;;;;;;;;;;;,.           .,;;;;;;;;;;;;,.
            .,;;;;;;;;;;;;,.           .,;;;;;;;;;;;;,.
           .,;;;;;;;;;;;;,.           .;;;;;;;;;;;;;,.     .....
          .;;;;;;;;;;;;;'.         ..';;;;;;;;;;;;;'.    .',;;;;,'.
        .';;;;;;;;;;;;;'.         .';;;;;;;;;;;;;;'.   .';;;;;;;;;;.
       .';;;;;;;;;;;;;'.         .';;;;;;;;;;;;;;'.    .;;;;;;;;;;;,.
      .,;;;;;;;;;;;;;'...........,;;;;;;;;;;;;;;.      .;;;;;;;;;;;,.
     .,;;;;;;;;;;;;,..,;;;;;;;;;;;;;;;;;;;;;;;,.       ..;;;;;;;;;,.
    .,;;;;;;;;;;;;,. .,;;;;;;;;;;;;;;;;;;;;;;,.          .',;;;,,..
   .,;;;;;;;;;;;;,.  .,;;;;;;;;;;;;;;;;;;;;;,.              ....
    ..',;;;;;;;;,.   .,;;;;;;;;;;;;;;;;;;;;,.
       ..',;;;;'.    .,;;;;;;;;;;;;;;;;;;;'.
          ...'..     .';;;;;;;;;;;;;;,,,'.
                       ...............
*/

// https://github.com/trusttoken/smart-contracts
// Dependency file: contracts/true-gold/common/ProxyStorage.sol

// SPDX-License-Identifier: UNLICENSED
// pragma solidity 0.6.10;

contract ProxyStorage {
    // Initializable.sol
    bool _initialized;
    bool _initializing;

    // Ownable.sol
    address _owner;

    // ERC20.sol
    mapping(address => uint256) _balances;
    mapping(address => mapping(address => uint256)) _allowances;
    uint256 _totalSupply;

    // TrueMintableBurnable.sol
    uint256 _minBurnAmount;
    uint256 _maxBurnAmount;

    /* Additionally, we have several keccak-based storage locations.
     * If you add more keccak-based storage mappings, such as mappings, you must document them here.
     * If the length of the keccak input is the same as an existing mapping, it is possible there could be a preimage collision.
     * A preimage collision can be used to attack the contract by treating one storage location as another,
     * which would always be a critical issue.
     * Carefully examine future keccak-based storage to ensure there can be no preimage collisions.
     *******************************************************************************************************
     ** length     input                                                         usage
     *******************************************************************************************************
     ** 20         "trueGold.proxy.owner"                                        Proxy Owner
     ** 28         "trueGold.pending.proxy.owner"                                Pending Proxy Owner
     ** 29         "trueGold.proxy.implementation"                               Proxy Implementation
     ** 64         uint256(address),uint256(1)                                   _balances
     ** 64         uint256(address),keccak256(uint256(address),uint256(2))       _allowances
     **/
}


// Dependency file: contracts/true-gold/common/Initializable.sol

// pragma solidity 0.6.10;

// import "contracts/true-gold/common/ProxyStorage.sol";

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
contract Initializable is ProxyStorage {
    /**
     * @dev Indicates that the contract has been initialized.
     */
    // bool private _initialized;

    /**
     * @dev Indicates that the contract is in the process of being initialized.
     */
    // bool private _initializing;

    /**
     * @dev Modifier to use in the initializer function of a contract.
     */
    modifier initializer() {
        require(_initializing || isConstructor() || !_initialized, "Contract instance has already been initialized");

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
    function isConstructor() private view returns (bool) {
        // extcodesize checks the size of the code stored in an address, and
        // address returns the current address. Since the code is still not
        // deployed when running a constructor, any checks on its code size will
        // yield zero, making it an effective way to detect if a contract is
        // under construction or not.
        address self = address(this);
        uint256 cs;
        // solhint-disable-next-line no-inline-assembly
        assembly {
            cs := extcodesize(self)
        }
        return cs == 0;
    }
}


// Dependency file: contracts/true-gold/interface/IOwnable.sol

// pragma solidity 0.6.10;




// Dependency file: contracts/true-gold/common/Ownable.sol

// pragma solidity 0.6.10;

// import "contracts/true-gold/interface/IOwnable.sol";

// import "contracts/true-gold/common/ProxyStorage.sol";
// import "contracts/true-gold/common/Initializable.sol";

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
contract Ownable is ProxyStorage, Initializable, IOwnable {
    // address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    // solhint-disable-next-line func-name-mixedcase
    function __Ownable_init_unchained() internal initializer {
        _owner = msg.sender;
        emit OwnershipTransferred(address(0), msg.sender);
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
        require(_owner == msg.sender, "Ownable: caller is not the owner");
        _;
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) public virtual override onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}


// Dependency file: @openzeppelin/contracts/token/ERC20/IERC20.sol


// pragma solidity ^0.6.0;

/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
 */



// Dependency file: contracts/true-gold/Reclaimable.sol

// pragma solidity 0.6.10;

// import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

// import "contracts/true-gold/common/Ownable.sol";
// import "contracts/true-gold/common/ProxyStorage.sol";
// import "contracts/true-gold/interface/IOwnable.sol";

contract Reclaimable is Ownable {
    function reclaimEther(address payable to) public onlyOwner {
        to.transfer(address(this).balance);
    }

    function reclaimToken(IERC20 token, address to) public onlyOwner {
        uint256 balance = token.balanceOf(address(this));
        token.transfer(to, balance);
    }

    function reclaimContract(IOwnable ownable) public onlyOwner {
        ownable.transferOwnership(_owner);
    }
}


// Dependency file: @openzeppelin/contracts/math/SafeMath.sol


// pragma solidity ^0.6.0;

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



// Dependency file: @openzeppelin/contracts/utils/Address.sol


// pragma solidity ^0.6.2;

/**
 * @dev Collection of functions related to the address type
 */



// Dependency file: contracts/true-gold/common/ERC20.sol

// pragma solidity 0.6.10;

// import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
// import "@openzeppelin/contracts/math/SafeMath.sol";
// import "@openzeppelin/contracts/utils/Address.sol";

// import "contracts/true-gold/common/ProxyStorage.sol";

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
abstract contract ERC20 is ProxyStorage, IERC20 {
    using SafeMath for uint256;
    using Address for address;

    // mapping (address => uint256) private _balances;
    // mapping (address => mapping (address => uint256)) private _allowances;
    // uint256 private _totalSupply;

    /**
     * @dev Returns the name of the token.
     */
    function name() public virtual pure returns (string memory);

    /**
     * @dev Returns the symbol of the token, usually a shorter version of the
     * name.
     */
    function symbol() public virtual pure returns (string memory);

    /**
     * @dev Returns the number of decimals used to get its user representation.
     * For example, if `decimals` equals `2`, a balance of `505` tokens should
     * be displayed to a user as `5,05` (`505 / 10 ** 2`).
     *
     * NOTE: This information is only used for _display_ purposes: it in
     * no way affects any of the arithmetic of the contract, including
     * {IERC20-balanceOf} and {IERC20-transfer}.
     */
    function decimals() public virtual pure returns (uint8);

    /**
     * @dev See {IERC20-totalSupply}.
     */
    function totalSupply() public override view returns (uint256) {
        return _totalSupply;
    }

    /**
     * @dev See {IERC20-balanceOf}.
     */
    function balanceOf(address account) public override view returns (uint256) {
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
        _transfer(msg.sender, recipient, amount);
        return true;
    }

    /**
     * @dev See {IERC20-allowance}.
     */
    function allowance(address owner, address spender) public virtual override view returns (uint256) {
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
     * - the caller must have allowance for ``sender``'s tokens of at least
     * `amount`.
     */
    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) public virtual override returns (bool) {
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
    function increaseAllowance(address spender, uint256 addedValue) public virtual returns (bool) {
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
    function decreaseAllowance(address spender, uint256 subtractedValue) public virtual returns (bool) {
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
    function _transfer(
        address sender,
        address recipient,
        uint256 amount
    ) internal virtual {
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
    function _mint(address account, uint256 amount) internal virtual {
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
    function _burn(address account, uint256 amount) internal virtual {
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
    function _approve(
        address owner,
        address spender,
        uint256 amount
    ) internal virtual {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }
}


// Dependency file: contracts/true-gold/common/ERC20Burnable.sol

// pragma solidity 0.6.10;

// import "contracts/true-gold/common/ERC20.sol";

/**
 * @dev Extension of {ERC20} that allows token holders to destroy both their own
 * tokens and those that they have an allowance for, in a way that can be
 * recognized off-chain (via event analysis).
 */
abstract contract ERC20Burnable is ERC20 {
    /**
     * @dev Destroys `amount` tokens from the caller.
     *
     * See {ERC20-_burn}.
     */
    function burn(uint256 amount) public virtual {
        _burn(msg.sender, amount);
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
        uint256 decreasedAllowance = allowance(account, msg.sender).sub(amount, "ERC20Burnable: burn amount exceeds allowance");

        _approve(account, msg.sender, decreasedAllowance);
        _burn(account, amount);
    }
}


// Dependency file: contracts/true-gold/TrueMintableBurnable.sol

// pragma solidity 0.6.10;

// import "contracts/true-gold/common/ERC20Burnable.sol";
// import "contracts/true-gold/common/Initializable.sol";
// import "contracts/true-gold/common/Ownable.sol";
// import "contracts/true-gold/common/ProxyStorage.sol";

abstract contract TrueMintableBurnable is ProxyStorage, Initializable, Ownable, ERC20Burnable {
    uint256 constant REDEMPTION_ADDRESS_COUNT = 0x100000;

    event Mint(address indexed to, uint256 value);
    event Burn(address indexed burner, uint256 value);
    event SetBurnBounds(uint256 newMin, uint256 newMax);

    // solhint-disable-next-line func-name-mixedcase
    function __TrueMintableBurnable_init_unchained(uint256 minBurnAmount, uint256 maxBurnAmount) internal initializer {
        setBurnBounds(minBurnAmount, maxBurnAmount);
    }

    function burnMin() public view returns (uint256) {
        return _minBurnAmount;
    }

    function burnMax() public view returns (uint256) {
        return _maxBurnAmount;
    }

    // Change the minimum and maximum amount that can be burned at once. Burning may be disabled by setting both to 0
    // (this will not be done under normal operation, but we can't add checks to disallow it without losing a lot of
    // flexibility since burning could also be as good as disabled by setting the minimum extremely high, and we don't
    // want to lock in any particular cap for the minimum)
    function setBurnBounds(uint256 minAmount, uint256 maxAmount) public virtual onlyOwner {
        require(minAmount <= maxAmount, "TrueMintableBurnable: min is greater then max");
        _minBurnAmount = minAmount;
        _maxBurnAmount = maxAmount;
        emit SetBurnBounds(minAmount, maxAmount);
    }

    function mint(address account, uint256 amount) public virtual onlyOwner {
        require(uint256(account) > REDEMPTION_ADDRESS_COUNT, "TrueMintableBurnable: mint to a redemption or zero address");
        _mint(account, amount);
        emit Mint(account, amount);
    }

    function transfer(address recipient, uint256 amount) public virtual override returns (bool) {
        require(super.transfer(recipient, amount));
        if (uint256(recipient) <= REDEMPTION_ADDRESS_COUNT) {
            _burn(recipient, amount);
        }
        return true;
    }

    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) public virtual override returns (bool) {
        require(super.transferFrom(sender, recipient, amount));
        if (uint256(recipient) <= REDEMPTION_ADDRESS_COUNT) {
            _burn(recipient, amount);
        }
        return true;
    }

    function _burn(address account, uint256 amount) internal virtual override {
        require(amount >= _minBurnAmount, "TrueMintableBurnable: burn amount below min bound");
        require(amount <= _maxBurnAmount, "TrueMintableBurnable: burn amount exceeds max bound");
        super._burn(account, amount);
        emit Burn(account, amount);
    }
}


// Root file: contracts/true-gold/TrueGold.sol

pragma solidity 0.6.10;

// import "contracts/true-gold/common/Initializable.sol";
// import "contracts/true-gold/common/Ownable.sol";

// import "contracts/true-gold/Reclaimable.sol";
// import "contracts/true-gold/TrueMintableBurnable.sol";

contract TrueGold is Initializable, Ownable, TrueMintableBurnable, Reclaimable {
    using SafeMath for uint256;

    uint8 private constant DECIMALS = 6;
    uint256 private constant BURN_AMOUNT_MULTIPLIER = 12_441_000;

    function initialize(uint256 minBurnAmount, uint256 maxBurnAmount) public initializer {
        __Ownable_init_unchained();
        __TrueMintableBurnable_init_unchained(minBurnAmount, maxBurnAmount);
    }

    function decimals() public override pure returns (uint8) {
        return DECIMALS;
    }

    function name() public override pure returns (string memory) {
        return "TrueGold";
    }

    function symbol() public override pure returns (string memory) {
        return "TGLD";
    }

    function setBurnBounds(uint256 minAmount, uint256 maxAmount) public override onlyOwner {
        require(minAmount.mod(BURN_AMOUNT_MULTIPLIER) == 0, "TrueGold: min amount is not a multiple of 12,441,000");
        require(maxAmount.mod(BURN_AMOUNT_MULTIPLIER) == 0, "TrueGold: max amount is not a multiple of 12,441,000");
        super.setBurnBounds(minAmount, maxAmount);
    }

    function _burn(address account, uint256 amount) internal virtual override {
        require(amount.mod(BURN_AMOUNT_MULTIPLIER) == 0, "TrueGold: burn amount is not a multiple of 12,441,000");
        super._burn(account, amount);
    }
}