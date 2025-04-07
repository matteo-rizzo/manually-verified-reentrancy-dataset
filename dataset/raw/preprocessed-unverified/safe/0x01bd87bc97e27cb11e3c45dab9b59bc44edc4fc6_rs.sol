/**
 *Submitted for verification at Etherscan.io on 2021-05-20
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
// Dependency file: @openzeppelin/contracts/token/ERC20/IERC20.sol

// SPDX-License-Identifier: MIT

// pragma solidity ^0.6.0;

/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
 */



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



// Dependency file: @openzeppelin/contracts/token/ERC20/SafeERC20.sol


// pragma solidity ^0.6.0;

// import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
// import "@openzeppelin/contracts/math/SafeMath.sol";
// import "@openzeppelin/contracts/utils/Address.sol";

/**
 * @title SafeERC20
 * @dev Wrappers around ERC20 operations that throw on failure (when the token
 * contract returns false). Tokens that return no value (and instead revert or
 * throw on failure) are also supported, non-reverting calls are assumed to be
 * successful.
 * To use this library you can add a `using SafeERC20 for IERC20;` statement to your contract,
 * which allows you to call the safe operations as `token.safeTransfer(...)`, etc.
 */



// Dependency file: @openzeppelin/contracts/GSN/Context.sol


// pragma solidity ^0.6.0;

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
abstract contract Context {
    function _msgSender() internal view virtual returns (address payable) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes memory) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}


// Dependency file: contracts/common/Initializable.sol

// Copied from https://github.com/OpenZeppelin/openzeppelin-contracts-ethereum-package/blob/v3.0.0/contracts/Initializable.sol
// Added public isInitialized() view of private initialized bool.

// pragma solidity 0.6.10;

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
        assembly {
            cs := extcodesize(self)
        }
        return cs == 0;
    }

    /**
     * @dev Return true if and only if the contract has been initialized
     * @return whether the contract has been initialized
     */
    function isInitialized() public view returns (bool) {
        return initialized;
    }

    // Reserved storage space to allow for layout changes in the future.
    uint256[50] private ______gap;
}


// Dependency file: contracts/common/UpgradeableERC20.sol

// pragma solidity 0.6.10;

// import {Address} from "@openzeppelin/contracts/utils/Address.sol";
// import {Context} from "@openzeppelin/contracts/GSN/Context.sol";
// import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
// import {SafeMath} from "@openzeppelin/contracts/math/SafeMath.sol";

// import {Initializable} from "contracts/common/Initializable.sol";

/**
 * @dev Implementation of the {IERC20} interface.
 *
 * This implementation is agnostic to the way tokens are created. This means
 * that a supply mechanism has to be added in a derived contract using {_mint}.
 * For a generic mechanism see {ERC20PresetMinterPauser}.
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
contract ERC20 is Initializable, Context, IERC20 {
    using SafeMath for uint256;
    using Address for address;

    mapping(address => uint256) private _balances;

    mapping(address => mapping(address => uint256)) private _allowances;

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
    function __ERC20_initialize(string memory name, string memory symbol) internal initializer {
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
    function decimals() public virtual view returns (uint8) {
        return _decimals;
    }

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
        _transfer(_msgSender(), recipient, amount);
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
    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) public virtual override returns (bool) {
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
        _approve(
            _msgSender(),
            spender,
            _allowances[_msgSender()][spender].sub(subtractedValue, "ERC20: decreased allowance below zero")
        );
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
    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual {}

    function updateNameAndSymbol(string memory __name, string memory __symbol) internal {
        _name = __name;
        _symbol = __symbol;
    }
}


// Dependency file: contracts/common/UpgradeableClaimable.sol

// pragma solidity 0.6.10;

// import {Context} from "@openzeppelin/contracts/GSN/Context.sol";

// import {Initializable} from "contracts/common/Initializable.sol";

/**
 * @title UpgradeableClaimable
 * @dev Contract module which provides a basic access control mechanism, where
 * there is an account (an owner) that can be granted exclusive access to
 * specific functions.
 *
 * By default, the owner account will be the one that deploys the contract. Since
 * this contract combines Claimable and UpgradableOwnable contracts, ownership
 * can be later change via 2 step method {transferOwnership} and {claimOwnership}
 *
 * This module is used through inheritance. It will make available the modifier
 * `onlyOwner`, which can be applied to your functions to restrict their use to
 * the owner.
 */
contract UpgradeableClaimable is Initializable, Context {
    address private _owner;
    address private _pendingOwner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev Initializes the contract setting a custom initial owner of choice.
     * @param __owner Initial owner of contract to be set.
     */
    function initialize(address __owner) internal initializer {
        _owner = __owner;
        emit OwnershipTransferred(address(0), __owner);
    }

    /**
     * @dev Returns the address of the current owner.
     */
    function owner() public view returns (address) {
        return _owner;
    }

    /**
     * @dev Returns the address of the pending owner.
     */
    function pendingOwner() public view returns (address) {
        return _pendingOwner;
    }

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        require(_owner == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    /**
     * @dev Modifier throws if called by any account other than the pendingOwner.
     */
    modifier onlyPendingOwner() {
        require(msg.sender == _pendingOwner, "Ownable: caller is not the pending owner");
        _;
    }

    /**
     * @dev Allows the current owner to set the pendingOwner address.
     * @param newOwner The address to transfer ownership to.
     */
    function transferOwnership(address newOwner) public onlyOwner {
        _pendingOwner = newOwner;
    }

    /**
     * @dev Allows the pendingOwner address to finalize the transfer.
     */
    function claimOwnership() public onlyPendingOwner {
        emit OwnershipTransferred(_owner, _pendingOwner);
        _owner = _pendingOwner;
        _pendingOwner = address(0);
    }
}


// Dependency file: contracts/truefi2/interface/ITrueStrategy.sol

// pragma solidity 0.6.10;




// Dependency file: contracts/truefi2/interface/ITrueLender2.sol

// pragma solidity 0.6.10;

// import {ITrueFiPool2} from "contracts/truefi2/interface/ITrueFiPool2.sol";




// Dependency file: contracts/truefi2/interface/IERC20WithDecimals.sol

// pragma solidity 0.6.10;

// import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";

interface IERC20WithDecimals is IERC20 {
    function decimals() external view returns (uint256);
}


// Dependency file: contracts/truefi2/interface/ITrueFiPoolOracle.sol

// pragma solidity 0.6.10;

// import {IERC20WithDecimals} from "contracts/truefi2/interface/IERC20WithDecimals.sol";

/**
 * @dev Oracle that converts any token to and from TRU
 * Used for liquidations and valuing of liquidated TRU in the pool
 */



// Dependency file: contracts/truefi2/interface/I1Inch3.sol

// pragma solidity 0.6.10;




// Dependency file: contracts/truefi2/interface/ITrueFiPool2.sol

// pragma solidity 0.6.10;

// import {ERC20, IERC20} from "contracts/common/UpgradeableERC20.sol";
// import {ITrueLender2} from "contracts/truefi2/interface/ITrueLender2.sol";
// import {ITrueFiPoolOracle} from "contracts/truefi2/interface/ITrueFiPoolOracle.sol";
// import {I1Inch3} from "contracts/truefi2/interface/I1Inch3.sol";

interface ITrueFiPool2 is IERC20 {
    function initialize(
        ERC20 _token,
        ERC20 _stakingToken,
        ITrueLender2 _lender,
        I1Inch3 __1Inch,
        address __owner
    ) external;

    function token() external view returns (ERC20);

    function oracle() external view returns (ITrueFiPoolOracle);

    /**
     * @dev Join the pool by depositing tokens
     * @param amount amount of tokens to deposit
     */
    function join(uint256 amount) external;

    /**
     * @dev borrow from pool
     * 1. Transfer TUSD to sender
     * 2. Only lending pool should be allowed to call this
     */
    function borrow(uint256 amount) external;

    /**
     * @dev pay borrowed money back to pool
     * 1. Transfer TUSD from sender
     * 2. Only lending pool should be allowed to call this
     */
    function repay(uint256 currencyAmount) external;
}


// Dependency file: contracts/common/interface/IPauseableContract.sol


// pragma solidity 0.6.10;

/**
 * @dev interface to allow standard pause function
 */



// Dependency file: contracts/truefi/Log.sol

/*
 * ABDK Math 64.64 Smart Contract Library.  Copyright © 2019 by ABDK Consulting.
 * Author: Mikhail Vladimirov <[email protected]>
 */
// pragma solidity 0.6.10;

/**
 * Smart contract library of mathematical functions operating with signed
 * 64.64-bit fixed point numbers.  Signed 64.64-bit fixed point number is
 * basically a simple fraction whose numerator is signed 128-bit integer and
 * denominator is 2^64.  As long as denominator is always the same, there is no
 * need to store it, thus in Solidity signed 64.64-bit fixed point numbers are
 * represented by int128 type holding only the numerator.
 */



// Dependency file: contracts/truefi2/libraries/OneInchExchange.sol

// pragma solidity 0.6.10;

// import {I1Inch3} from "contracts/truefi2/interface/I1Inch3.sol";
// import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";






// Root file: contracts/truefi2/TrueFiPool2.sol

pragma solidity 0.6.10;
pragma experimental ABIEncoderV2;

// import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
// import {SafeMath} from "@openzeppelin/contracts/math/SafeMath.sol";
// import {SafeERC20} from "@openzeppelin/contracts/token/ERC20/SafeERC20.sol";
// import {ERC20} from "contracts/common/UpgradeableERC20.sol";
// import {UpgradeableClaimable as Claimable} from "contracts/common/UpgradeableClaimable.sol";

// import {ITrueStrategy} from "contracts/truefi2/interface/ITrueStrategy.sol";
// import {ITrueFiPool2, ITrueFiPoolOracle, I1Inch3} from "contracts/truefi2/interface/ITrueFiPool2.sol";
// import {ITrueLender2} from "contracts/truefi2/interface/ITrueLender2.sol";
// import {IPauseableContract} from "contracts/common/interface/IPauseableContract.sol";

// import {ABDKMath64x64} from "contracts/truefi/Log.sol";
// import {OneInchExchange} from "contracts/truefi2/libraries/OneInchExchange.sol";

/**
 * @title TrueFiPool2
 * @dev Lending pool which may use a strategy to store idle funds
 * Earn high interest rates on currency deposits through uncollateralized loans
 *
 * Funds deposited in this pool are not fully liquid.
 * Exiting the pool has 2 options:
 * - withdraw a basket of LoanTokens backing the pool
 * - take an exit penalty depending on pool liquidity
 * After exiting, an account will need to wait for LoanTokens to expire and burn them
 * It is recommended to perform a zap or swap tokens on Uniswap for increased liquidity
 *
 * Funds are managed through an external function to save gas on deposits
 */
contract TrueFiPool2 is ITrueFiPool2, IPauseableContract, ERC20, UpgradeableClaimable {
    using SafeMath for uint256;
    using SafeERC20 for ERC20;
    using OneInchExchange for I1Inch3;

    uint256 private constant BASIS_PRECISION = 10000;

    // max slippage on liquidation token swaps
    // Measured in basis points, e.g. 10000 = 100%
    uint16 public constant TOLERATED_SLIPPAGE = 100; // 1%

    // tolerance difference between
    // expected and actual transaction results
    // when dealing with strategies
    // Measured in  basis points, e.g. 10000 = 100%
    uint16 public constant TOLERATED_STRATEGY_LOSS = 10; // 0.1%

    // ================ WARNING ==================
    // ===== THIS CONTRACT IS INITIALIZABLE ======
    // === STORAGE VARIABLES ARE DECLARED BELOW ==
    // REMOVAL OR REORDER OF VARIABLES WILL RESULT
    // ========= IN STORAGE CORRUPTION ===========

    uint8 public constant VERSION = 0;

    ERC20 public override token;

    ITrueStrategy public strategy;
    ITrueLender2 public lender;

    // fee for deposits
    // fee precision: 10000 = 100%
    uint256 public joiningFee;
    // track claimable fees
    uint256 public claimableFees;

    mapping(address => uint256) latestJoinBlock;

    IERC20 public liquidationToken;

    ITrueFiPoolOracle public override oracle;

    // allow pausing of deposits
    bool public pauseStatus;

    // cache values during sync for gas optimization
    bool private inSync;
    uint256 private strategyValueCache;
    uint256 private loansValueCache;

    // who gets all fees
    address public beneficiary;

    I1Inch3 public _1Inch;

    // ======= STORAGE DECLARATION END ===========

    /**
     * @dev Helper function to concatenate two strings
     * @param a First part of string to concat
     * @param b Second part of string to concat
     * @return Concatenated string of `a` and `b`
     */
    function concat(string memory a, string memory b) internal pure returns (string memory) {
        return string(abi.encodePacked(a, b));
    }

    function initialize(
        ERC20 _token,
        ERC20 _liquidationToken,
        ITrueLender2 _lender,
        I1Inch3 __1Inch,
        address __owner
    ) external override initializer {
        ERC20.__ERC20_initialize(concat("TrueFi ", _token.name()), concat("tf", _token.symbol()));
        UpgradeableClaimable.initialize(__owner);

        token = _token;
        liquidationToken = _liquidationToken;
        lender = _lender;
        _1Inch = __1Inch;
    }

    /**
     * @dev Emitted when fee is changed
     * @param newFee New fee
     */
    event JoiningFeeChanged(uint256 newFee);

    /**
     * @dev Emitted when beneficiary is changed
     * @param newBeneficiary New beneficiary
     */
    event BeneficiaryChanged(address newBeneficiary);

    /**
     * @dev Emitted when oracle is changed
     * @param newOracle New oracle
     */
    event OracleChanged(ITrueFiPoolOracle newOracle);

    /**
     * @dev Emitted when someone joins the pool
     * @param staker Account staking
     * @param deposited Amount deposited
     * @param minted Amount of pool tokens minted
     */
    event Joined(address indexed staker, uint256 deposited, uint256 minted);

    /**
     * @dev Emitted when someone exits the pool
     * @param staker Account exiting
     * @param amount Amount unstaking
     */
    event Exited(address indexed staker, uint256 amount);

    /**
     * @dev Emitted when funds are flushed into the strategy
     * @param currencyAmount Amount of tokens deposited
     */
    event Flushed(uint256 currencyAmount);

    /**
     * @dev Emitted when funds are pulled from the strategy
     * @param minTokenAmount Minimal expected amount received tokens
     */
    event Pulled(uint256 minTokenAmount);

    /**
     * @dev Emitted when funds are borrowed from pool
     * @param borrower Borrower address
     * @param amount Amount of funds borrowed from pool
     */
    event Borrow(address borrower, uint256 amount);

    /**
     * @dev Emitted when borrower repays the pool
     * @param payer Address of borrower
     * @param amount Amount repaid
     */
    event Repaid(address indexed payer, uint256 amount);

    /**
     * @dev Emitted when fees are collected
     * @param beneficiary Account to receive fees
     * @param amount Amount of fees collected
     */
    event Collected(address indexed beneficiary, uint256 amount);

    /**
     * @dev Emitted when strategy is switched
     * @param newStrategy Strategy to switch to
     */
    event StrategySwitched(ITrueStrategy newStrategy);

    /**
     * @dev Emitted when joining is paused or unpaused
     * @param pauseStatus New pausing status
     */
    event PauseStatusChanged(bool pauseStatus);

    /**
     * @dev only lender can perform borrowing or repaying
     */
    modifier onlyLender() {
        require(msg.sender == address(lender), "TrueFiPool: Caller is not the lender");
        _;
    }

    /**
     * @dev pool can only be joined when it's unpaused
     */
    modifier joiningNotPaused() {
        require(!pauseStatus, "TrueFiPool: Joining the pool is paused");
        _;
    }

    /**
     * Sync values to avoid making expensive calls multiple times
     * Will set inSync to true, allowing getter functions to return cached values
     * Wipes cached values to save gas
     */
    modifier sync() {
        // sync
        strategyValueCache = strategyValue();
        loansValueCache = loansValue();
        inSync = true;
        _;
        // wipe
        inSync = false;
        strategyValueCache = 0;
        loansValueCache = 0;
    }

    /**
     * @dev Allow pausing of deposits in case of emergency
     * @param status New deposit status
     */
    function setPauseStatus(bool status) external override onlyOwner {
        pauseStatus = status;
        emit PauseStatusChanged(status);
    }

    /**
     * @dev Number of decimals for user-facing representations.
     * Delegates to the underlying pool token.
     */
    function decimals() public override view returns (uint8) {
        return token.decimals();
    }

    /**
     * @dev Virtual value of liquid assets in the pool
     * @return Virtual liquid value of pool assets
     */
    function liquidValue() public view returns (uint256) {
        return currencyBalance().add(strategyValue());
    }

    /**
     * @dev Value of funds deposited into the strategy denominated in underlying token
     * @return Virtual value of strategy
     */
    function strategyValue() public view returns (uint256) {
        if (address(strategy) == address(0)) {
            return 0;
        }
        if (inSync) {
            return strategyValueCache;
        }
        return strategy.value();
    }

    /**
     * @dev Calculate pool value in underlying token
     * "virtual price" of entire pool - LoanTokens, UnderlyingTokens, strategy value
     * @return pool value denominated in underlying token
     */
    function poolValue() public view returns (uint256) {
        // this assumes defaulted loans are worth their full value
        return liquidValue().add(loansValue());
    }

    /**
     * @dev Get total balance of stake tokens
     * @return Balance of stake tokens denominated in this contract
     */
    function liquidationTokenBalance() public view returns (uint256) {
        return liquidationToken.balanceOf(address(this));
    }

    /**
     * @dev Price of TRU denominated in underlying tokens
     * @return Oracle price of TRU in underlying tokens
     */
    function liquidationTokenValue() public view returns (uint256) {
        uint256 balance = liquidationTokenBalance();
        if (balance == 0 || address(oracle) == address(0)) {
            return 0;
        }
        // Use conservative price estimation to avoid pool being overvalued
        return withToleratedSlippage(oracle.truToToken(balance));
    }

    /**
     * @dev Virtual value of loan assets in the pool
     * Will return cached value if inSync
     * @return Value of loans in pool
     */
    function loansValue() public view returns (uint256) {
        if (inSync) {
            return loansValueCache;
        }
        return lender.value(this);
    }

    /**
     * @dev ensure enough tokens are available
     * Check if current available amount of `token` is enough and
     * withdraw remainder from strategy
     * @param neededAmount amount required
     */
    function ensureSufficientLiquidity(uint256 neededAmount) internal {
        uint256 currentlyAvailableAmount = currencyBalance();
        if (currentlyAvailableAmount < neededAmount) {
            require(address(strategy) != address(0), "TrueFiPool: Pool has no strategy to withdraw from");
            strategy.withdraw(neededAmount.sub(currentlyAvailableAmount));
            require(currencyBalance() >= neededAmount, "TrueFiPool: Not enough funds taken from the strategy");
        }
    }

    /**
     * @dev set pool join fee
     * @param fee new fee
     */
    function setJoiningFee(uint256 fee) external onlyOwner {
        require(fee <= BASIS_PRECISION, "TrueFiPool: Fee cannot exceed transaction value");
        joiningFee = fee;
        emit JoiningFeeChanged(fee);
    }

    /**
     * @dev set beneficiary
     * @param newBeneficiary new beneficiary
     */
    function setBeneficiary(address newBeneficiary) external onlyOwner {
        require(newBeneficiary != address(0), "TrueFiPool: Beneficiary address cannot be set to 0");
        beneficiary = newBeneficiary;
        emit BeneficiaryChanged(newBeneficiary);
    }

    /**
     * @dev Join the pool by depositing tokens
     * @param amount amount of token to deposit
     */
    function join(uint256 amount) external override joiningNotPaused {
        uint256 fee = amount.mul(joiningFee).div(BASIS_PRECISION);
        uint256 mintedAmount = mint(amount.sub(fee));
        claimableFees = claimableFees.add(fee);

        // TODO: tx.origin will be depricated in a future ethereum upgrade
        latestJoinBlock[tx.origin] = block.number;
        token.safeTransferFrom(msg.sender, address(this), amount);

        emit Joined(msg.sender, amount, mintedAmount);
    }

    /**
     * @dev Exit pool
     * This function will withdraw a basket of currencies backing the pool value
     * @param amount amount of pool tokens to redeem for underlying tokens
     */
    function exit(uint256 amount) external {
        require(block.number != latestJoinBlock[tx.origin], "TrueFiPool: Cannot join and exit in same block");
        require(amount <= balanceOf(msg.sender), "TrueFiPool: Insufficient funds");

        uint256 _totalSupply = totalSupply();

        // get share of tokens kept in the pool
        uint256 liquidAmountToTransfer = amount.mul(liquidValue()).div(_totalSupply);

        // burn tokens sent
        _burn(msg.sender, amount);

        // withdraw basket of loan tokens
        lender.distribute(msg.sender, amount, _totalSupply);

        // if tokens remaining, transfer
        if (liquidAmountToTransfer > 0) {
            ensureSufficientLiquidity(liquidAmountToTransfer);
            token.safeTransfer(msg.sender, liquidAmountToTransfer);
        }

        emit Exited(msg.sender, amount);
    }

    /**
     * @dev Exit pool only with liquid tokens
     * This function will only transfer underlying token but with a small penalty
     * Uses the sync() modifier to reduce gas costs of using strategy and lender
     * @param amount amount of pool liquidity tokens to redeem for underlying tokens
     */
    function liquidExit(uint256 amount) external sync {
        require(block.number != latestJoinBlock[tx.origin], "TrueFiPool: Cannot join and exit in same block");
        require(amount <= balanceOf(msg.sender), "TrueFiPool: Insufficient funds");

        uint256 amountToWithdraw = poolValue().mul(amount).div(totalSupply());
        amountToWithdraw = amountToWithdraw.mul(liquidExitPenalty(amountToWithdraw)).div(BASIS_PRECISION);
        require(amountToWithdraw <= liquidValue(), "TrueFiPool: Not enough liquidity in pool");

        // burn tokens sent
        _burn(msg.sender, amount);

        ensureSufficientLiquidity(amountToWithdraw);

        token.safeTransfer(msg.sender, amountToWithdraw);

        emit Exited(msg.sender, amountToWithdraw);
    }

    /**
     * @dev Penalty (in % * 100) applied if liquid exit is performed with this amount
     * returns BASIS_PRECISION (10000) if no penalty
     */
    function liquidExitPenalty(uint256 amount) public view returns (uint256) {
        uint256 lv = liquidValue();
        uint256 pv = poolValue();
        if (amount == pv) {
            return BASIS_PRECISION;
        }
        uint256 liquidRatioBefore = lv.mul(BASIS_PRECISION).div(pv);
        uint256 liquidRatioAfter = lv.sub(amount).mul(BASIS_PRECISION).div(pv.sub(amount));
        return BASIS_PRECISION.sub(averageExitPenalty(liquidRatioAfter, liquidRatioBefore));
    }

    /**
     * @dev Calculates integral of 5/(x+50)dx times 10000
     */
    function integrateAtPoint(uint256 x) public pure returns (uint256) {
        return uint256(ABDKMath64x64.ln(ABDKMath64x64.fromUInt(x.add(50)))).mul(50000).div(2**64);
    }

    /**
     * @dev Calculates average penalty on interval [from; to]
     * @return average exit penalty
     */
    function averageExitPenalty(uint256 from, uint256 to) public pure returns (uint256) {
        require(from <= to, "TrueFiPool: To precedes from");
        if (from == BASIS_PRECISION) {
            // When all liquid, don't penalize
            return 0;
        }
        if (from == to) {
            return uint256(50000).div(from.add(50));
        }
        return integrateAtPoint(to).sub(integrateAtPoint(from)).div(to.sub(from));
    }

    /**
     * @dev Deposit idle funds into strategy
     * @param amount Amount of funds to deposit into strategy
     */
    function flush(uint256 amount) external {
        require(address(strategy) != address(0), "TrueFiPool: Pool has no strategy set up");
        require(amount <= currencyBalance(), "TrueFiPool: Insufficient currency balance");

        uint256 expectedMinStrategyValue = strategy.value().add(withToleratedStrategyLoss(amount));
        token.approve(address(strategy), amount);
        strategy.deposit(amount);
        require(strategy.value() >= expectedMinStrategyValue, "TrueFiPool: Strategy value expected to be higher");
        emit Flushed(amount);
    }

    /**
     * @dev Remove liquidity from strategy
     * @param minTokenAmount minimum amount of tokens to withdraw
     */
    function pull(uint256 minTokenAmount) external onlyOwner {
        require(address(strategy) != address(0), "TrueFiPool: Pool has no strategy set up");

        uint256 expectedCurrencyBalance = currencyBalance().add(minTokenAmount);
        strategy.withdraw(minTokenAmount);
        require(currencyBalance() >= expectedCurrencyBalance, "TrueFiPool: Currency balance expected to be higher");

        emit Pulled(minTokenAmount);
    }

    /**
     * @dev Remove liquidity from strategy if necessary and transfer to lender
     * @param amount amount for lender to withdraw
     */
    function borrow(uint256 amount) external override onlyLender {
        require(amount <= liquidValue(), "TrueFiPool: Insufficient liquidity");
        if (amount > 0) {
            ensureSufficientLiquidity(amount);
        }

        token.safeTransfer(msg.sender, amount);

        emit Borrow(msg.sender, amount);
    }

    /**
     * @dev repay debt by transferring tokens to the contract
     * @param currencyAmount amount to repay
     */
    function repay(uint256 currencyAmount) external override onlyLender {
        token.safeTransferFrom(msg.sender, address(this), currencyAmount);
        emit Repaid(msg.sender, currencyAmount);
    }

    /**
     * @dev Claim fees from the pool
     */
    function collectFees() external {
        require(beneficiary != address(0), "TrueFiPool: Beneficiary is not set");

        uint256 amount = claimableFees;
        claimableFees = 0;

        if (amount > 0) {
            token.safeTransfer(beneficiary, amount);
        }

        emit Collected(beneficiary, amount);
    }

    /**
     * @dev Switches current strategy to a new strategy
     * @param newStrategy strategy to switch to
     */
    function switchStrategy(ITrueStrategy newStrategy) external onlyOwner {
        require(strategy != newStrategy, "TrueFiPool: Cannot switch to the same strategy");

        ITrueStrategy previousStrategy = strategy;
        strategy = newStrategy;

        if (address(previousStrategy) != address(0)) {
            uint256 expectedMinCurrencyBalance = currencyBalance().add(withToleratedStrategyLoss(previousStrategy.value()));
            previousStrategy.withdrawAll();
            require(currencyBalance() >= expectedMinCurrencyBalance, "TrueFiPool: All funds should be withdrawn to pool");
            require(previousStrategy.value() == 0, "TrueFiPool: Switched strategy should be depleted");
        }

        emit StrategySwitched(newStrategy);
    }

    /**
     * @dev Change oracle, can only be called by owner
     */
    function setOracle(ITrueFiPoolOracle newOracle) external onlyOwner {
        oracle = newOracle;
        emit OracleChanged(newOracle);
    }

    function sellLiquidationToken(bytes calldata data) external {
        uint256 balanceBefore = token.balanceOf(address(this));

        I1Inch3.SwapDescription memory swap = _1Inch.exchange(data);

        uint256 expectedGain = oracle.truToToken(swap.amount);

        uint256 balanceDiff = token.balanceOf(address(this)).sub(balanceBefore);
        require(balanceDiff >= withToleratedSlippage(expectedGain), "TrueFiPool: Not optimal exchange");

        require(swap.srcToken == address(liquidationToken), "TrueFiPool: Source token is not TRU");
        require(swap.dstToken == address(token), "TrueFiPool: Invalid destination token");
        require(swap.dstReceiver == address(this), "TrueFiPool: Receiver is not pool");
    }

    /**
     * @dev Currency token balance
     * @return Currency token balance
     */
    function currencyBalance() internal view returns (uint256) {
        return token.balanceOf(address(this)).sub(claimableFees);
    }

    /**
     * @param depositedAmount Amount of currency deposited
     * @return amount minted from this transaction
     */
    function mint(uint256 depositedAmount) internal returns (uint256) {
        if (depositedAmount == 0) {
            return depositedAmount;
        }
        uint256 mintedAmount = depositedAmount;

        // first staker mints same amount as deposited
        if (totalSupply() > 0) {
            mintedAmount = totalSupply().mul(depositedAmount).div(poolValue());
        }
        // mint pool liquidity tokens
        _mint(msg.sender, mintedAmount);

        return mintedAmount;
    }

    /**
     * @dev Decrease provided amount percentwise by error
     * @param amount Amount to decrease
     * @return Calculated value
     */
    function withToleratedSlippage(uint256 amount) internal pure returns (uint256) {
        return amount.mul(BASIS_PRECISION - TOLERATED_SLIPPAGE).div(BASIS_PRECISION);
    }

    /**
     * @dev Decrease provided amount percentwise by error
     * @param amount Amount to decrease
     * @return Calculated value
     */
    function withToleratedStrategyLoss(uint256 amount) internal pure returns (uint256) {
        return amount.mul(BASIS_PRECISION - TOLERATED_STRATEGY_LOSS).div(BASIS_PRECISION);
    }
}