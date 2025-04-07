/**
 *Submitted for verification at Etherscan.io on 2021-06-29
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




// Dependency file: contracts/truefi/interface/IYToken.sol

// pragma solidity 0.6.10;

// import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";

interface IYToken is IERC20 {
    function getPricePerFullShare() external view returns (uint256);
}


// Dependency file: contracts/truefi/interface/ICurve.sol

// pragma solidity 0.6.10;

// import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";

// import {IYToken} from "contracts/truefi/interface/IYToken.sol";










// Dependency file: contracts/truefi/interface/ICrvPriceOracle.sol

// pragma solidity 0.6.10;




// Dependency file: contracts/truefi/interface/IUniswapRouter.sol

// pragma solidity 0.6.10;




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


// Dependency file: contracts/truefi2/interface/ILoanToken2.sol

// pragma solidity 0.6.10;

// import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
// import {ERC20} from "contracts/common/UpgradeableERC20.sol";
// import {ITrueFiPool2} from "contracts/truefi2/interface/ITrueFiPool2.sol";

interface ILoanToken2 is IERC20 {
    enum Status {Awaiting, Funded, Withdrawn, Settled, Defaulted, Liquidated}

    function borrower() external view returns (address);

    function amount() external view returns (uint256);

    function term() external view returns (uint256);

    function apy() external view returns (uint256);

    function start() external view returns (uint256);

    function lender() external view returns (address);

    function debt() external view returns (uint256);

    function pool() external view returns (ITrueFiPool2);

    function profit() external view returns (uint256);

    function status() external view returns (Status);

    function getParameters()
        external
        view
        returns (
            uint256,
            uint256,
            uint256
        );

    function fund() external;

    function withdraw(address _beneficiary) external;

    function settle() external;

    function enterDefault() external;

    function liquidate() external;

    function redeem(uint256 _amount) external;

    function repay(address _sender, uint256 _amount) external;

    function repayInFull(address _sender) external;

    function reclaim() external;

    function allowTransfer(address account, bool _status) external;

    function repaid() external view returns (uint256);

    function isRepaid() external view returns (bool);

    function balance() external view returns (uint256);

    function value(uint256 _balance) external view returns (uint256);

    function token() external view returns (ERC20);

    function version() external pure returns (uint8);
}

//
//
//// Had to be split because of multiple inheritance problem
//interface ILoanToken2 is ILoanToken, IContractWithPool {
//
//}


// Dependency file: contracts/truefi2/interface/ITrueLender2.sol

// pragma solidity 0.6.10;

// import {ITrueFiPool2} from "contracts/truefi2/interface/ITrueFiPool2.sol";
// import {ILoanToken2} from "contracts/truefi2/interface/ILoanToken2.sol";




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
pragma experimental ABIEncoderV2;




// Dependency file: contracts/truefi2/interface/ISAFU.sol

// pragma solidity 0.6.10;




// Dependency file: contracts/truefi2/interface/ITrueFiPool2.sol

// pragma solidity 0.6.10;

// import {ERC20, IERC20} from "contracts/common/UpgradeableERC20.sol";
// import {ITrueLender2, ILoanToken2} from "contracts/truefi2/interface/ITrueLender2.sol";
// import {ITrueFiPoolOracle} from "contracts/truefi2/interface/ITrueFiPoolOracle.sol";
// import {I1Inch3} from "contracts/truefi2/interface/I1Inch3.sol";
// import {ISAFU} from "contracts/truefi2/interface/ISAFU.sol";

interface ITrueFiPool2 is IERC20 {
    function initialize(
        ERC20 _token,
        ERC20 _stakingToken,
        ITrueLender2 _lender,
        I1Inch3 __1Inch,
        ISAFU safu,
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

    /**
     * @dev SAFU buys LoanTokens from the pool
     */
    function liquidate(ILoanToken2 loan) external;
}


// Dependency file: contracts/truefi2/libraries/OneInchExchange.sol

// pragma solidity 0.6.10;
// pragma experimental ABIEncoderV2;

// import {SafeMath} from "@openzeppelin/contracts/math/SafeMath.sol";
// import {I1Inch3} from "contracts/truefi2/interface/I1Inch3.sol";
// import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
// import {SafeERC20} from "@openzeppelin/contracts/token/ERC20/SafeERC20.sol";






// Root file: contracts/truefi2/strategies/CurveYearnStrategy.sol

pragma solidity 0.6.10;
// pragma experimental ABIEncoderV2;

// import {SafeERC20} from "@openzeppelin/contracts/token/ERC20/SafeERC20.sol";
// import {SafeMath} from "@openzeppelin/contracts/math/SafeMath.sol";
// import {UpgradeableClaimable} from "contracts/common/UpgradeableClaimable.sol";

// import {ITrueStrategy} from "contracts/truefi2/interface/ITrueStrategy.sol";
// import {ICurveGauge, ICurveMinter, ICurvePool, IERC20} from "contracts/truefi/interface/ICurve.sol";
// import {ICrvPriceOracle} from "contracts/truefi/interface/ICrvPriceOracle.sol";
// import {IUniswapRouter} from "contracts/truefi/interface/IUniswapRouter.sol";
// import {ITrueFiPool2} from "contracts/truefi2/interface/ITrueFiPool2.sol";
// import {I1Inch3} from "contracts/truefi2/interface/I1Inch3.sol";
// import {OneInchExchange} from "contracts/truefi2/libraries/OneInchExchange.sol";
// import {IERC20WithDecimals} from "contracts/truefi2/interface/IERC20WithDecimals.sol";

/**
 * @dev TrueFi pool strategy that allows depositing stablecoins into Curve Yearn pool (0x45F783CCE6B7FF23B2ab2D70e416cdb7D6055f51)
 * Supports DAI, USDC, USDT and TUSD
 * Curve LP tokens are being deposited into Curve Gauge and CRV rewards can be sold on 1Inch exchange and transferred to the pool
 */
contract CurveYearnStrategy is UpgradeableClaimable, ITrueStrategy {
    using SafeMath for uint256;
    using SafeERC20 for IERC20;
    using SafeERC20 for IERC20WithDecimals;
    using OneInchExchange for I1Inch3;

    // Number of tokens in Curve yPool
    uint8 public constant N_TOKENS = 4;
    // Max slippage during the swap
    uint256 public constant MAX_PRICE_SLIPPAGE = 200; // 2%

    // ================ WARNING ==================
    // ===== THIS CONTRACT IS INITIALIZABLE ======
    // === STORAGE VARIABLES ARE DECLARED BELOW ==
    // REMOVAL OR REORDER OF VARIABLES WILL RESULT
    // ========= IN STORAGE CORRUPTION ===========

    // Index of token in Curve pool
    // 0 - DAI
    // 1 - USDC
    // 2 - USDT
    // 3 - TUSD
    uint8 public tokenIndex;

    ICurvePool public curvePool;
    ICurveGauge public curveGauge;
    ICurveMinter public minter;
    I1Inch3 public _1Inch;

    IERC20WithDecimals public token;
    address public pool;

    // CRV price oracle
    ICrvPriceOracle public crvOracle;

    // ======= STORAGE DECLARATION END ===========

    event OracleChanged(ICrvPriceOracle newOracle);
    event Deposited(uint256 depositedAmount, uint256 receivedYAmount);
    event Withdrawn(uint256 minAmount, uint256 yAmount);
    event WithdrawnAll(uint256 yAmount);

    modifier onlyPool() {
        require(msg.sender == pool, "CurveYearnStrategy: Can only be called by pool");
        _;
    }

    function initialize(
        ITrueFiPool2 _pool,
        ICurvePool _curvePool,
        ICurveGauge _curveGauge,
        ICurveMinter _minter,
        I1Inch3 _1inchExchange,
        ICrvPriceOracle _crvOracle,
        uint8 _tokenIndex
    ) external initializer {
        UpgradeableClaimable.initialize(msg.sender);

        token = IERC20WithDecimals(address(_pool.token()));
        pool = address(_pool);

        curvePool = _curvePool;
        curveGauge = _curveGauge;
        minter = _minter;
        _1Inch = _1inchExchange;
        crvOracle = _crvOracle;
        tokenIndex = _tokenIndex;
    }

    /**
     * @dev Sets new  crv oracle address
     * @param _crvOracle new oracle address
     */
    function setOracle(ICrvPriceOracle _crvOracle) external onlyOwner {
        crvOracle = _crvOracle;
        emit OracleChanged(_crvOracle);
    }

    /**
     * @dev Transfer `amount` of `token` from pool and add it as
     * liquidity to the Curve yEarn Pool
     * Curve LP tokens are deposited into Curve Gauge
     * @param amount amount of token to add to curve
     */
    function deposit(uint256 amount) external override onlyPool {
        token.safeTransferFrom(pool, address(this), amount);

        uint256 totalAmount = token.balanceOf(address(this));
        uint256[N_TOKENS] memory amounts = [uint256(0), 0, 0, 0];
        amounts[tokenIndex] = totalAmount;

        token.safeApprove(address(curvePool), totalAmount);
        uint256 conservativeMinAmount = calcTokenAmount(totalAmount).mul(999).div(1000);
        curvePool.add_liquidity(amounts, conservativeMinAmount);

        // stake yCurve tokens in gauge
        uint256 yBalance = curvePool.token().balanceOf(address(this));
        curvePool.token().safeApprove(address(curveGauge), yBalance);
        curveGauge.deposit(yBalance);

        emit Deposited(amount, yBalance);
    }

    /**
     * @dev pull at least `minAmount` of tokens from strategy
     * Remove token liquidity from curve and transfer to pool
     * @param minAmount Minimum amount of tokens to remove from strategy
     */
    function withdraw(uint256 minAmount) external override onlyPool {
        // get rough estimate of how much yCRV we should sell
        uint256 roughCurveTokenAmount = calcTokenAmount(minAmount);
        uint256 yBalance = yTokenBalance();
        require(roughCurveTokenAmount <= yBalance, "CurveYearnStrategy: Not enough Curve liquidity tokens in pool to cover borrow");
        // Try to withdraw a bit more to be safe, but not above the total balance
        uint256 conservativeCurveTokenAmount = min(yBalance, roughCurveTokenAmount.mul(1005).div(1000));

        // pull tokens from gauge
        withdrawFromGaugeIfNecessary(conservativeCurveTokenAmount);
        // remove TUSD from curve
        curvePool.token().safeApprove(address(curvePool), conservativeCurveTokenAmount);
        curvePool.remove_liquidity_one_coin(conservativeCurveTokenAmount, tokenIndex, minAmount, false);
        transferAllToPool();

        emit Withdrawn(minAmount, conservativeCurveTokenAmount);
    }

    /**
     *@dev withdraw everything from strategy
     * Use with caution because Curve slippage is not controlled
     */
    function withdrawAll() external override onlyPool {
        curveGauge.withdraw(curveGauge.balanceOf(address(this)));
        uint256 yBalance = yTokenBalance();
        curvePool.token().safeApprove(address(curvePool), yBalance);
        curvePool.remove_liquidity_one_coin(yBalance, tokenIndex, 0, false);
        transferAllToPool();

        emit WithdrawnAll(yBalance);
    }

    /**
     * @dev Total pool value in USD
     * @notice Balance of CRV is not included into value of strategy,
     * because it cannot be converted to pool tokens automatically
     * @return Value of pool in USD
     */
    function value() external override view returns (uint256) {
        return yTokenValue();
    }

    /**
     * @dev Price of  in USD
     * @return Oracle price of TRU in USD
     */
    function yTokenValue() public view returns (uint256) {
        return normalizeDecimals(yTokenBalance().mul(curvePool.curve().get_virtual_price()).div(1 ether));
    }

    /**
     * @dev Get total balance of curve.fi pool tokens
     * @return Balance of y pool tokens in this contract
     */
    function yTokenBalance() public view returns (uint256) {
        return curvePool.token().balanceOf(address(this)).add(curveGauge.balanceOf(address(this)));
    }

    /**
     * @dev Price of CRV in USD
     * @return Oracle price of TRU in USD
     */
    function crvValue() public view returns (uint256) {
        uint256 balance = crvBalance();
        if (balance == 0 || address(crvOracle) == address(0)) {
            return 0;
        }
        return normalizeDecimals(conservativePriceEstimation(crvOracle.crvToUsd(balance)));
    }

    /**
     * @dev Get total balance of CRV tokens
     * @return Balance of stake tokens in this contract
     */
    function crvBalance() public view returns (uint256) {
        return minter.token().balanceOf(address(this));
    }

    /**
     * @dev Collect CRV tokens minted by staking at gauge
     */
    function collectCrv() external {
        minter.mint(address(curveGauge));
    }

    /**
     * @dev Swap collected CRV on 1inch and transfer gains to the pool
     * Receiver of the tokens should be the pool
     * Revert if resulting exchange price is much smaller than the oracle price
     * @param data Data that is forwarded into the 1inch exchange contract. Can be acquired from 1Inch API https://api.1inch.exchange/v3.0/1/swap
     * [See more](https://docs.1inch.exchange/api/quote-swap#swap)
     */
    function sellCrv(bytes calldata data) external {
        (I1Inch3.SwapDescription memory swap, uint256 balanceDiff) = _1Inch.exchange(data);

        uint256 expectedGain = normalizeDecimals(crvOracle.crvToUsd(swap.amount));

        require(swap.srcToken == address(minter.token()), "CurveYearnStrategy: Source token is not CRV");
        require(swap.dstToken == address(token), "CurveYearnStrategy: Destination token is not TUSD");
        require(swap.dstReceiver == pool, "CurveYearnStrategy: Receiver is not pool");

        require(balanceDiff >= conservativePriceEstimation(expectedGain), "CurveYearnStrategy: Not optimal exchange");
    }

    /**
     * @dev Expected amount of minted Curve.fi yDAI/yUSDC/yUSDT/yTUSD tokens.
     * @param currencyAmount amount to calculate for
     * @return expected amount minted given currency amount
     */
    function calcTokenAmount(uint256 currencyAmount) public view returns (uint256) {
        uint256 yTokenAmount = currencyAmount.mul(1e18).div(curvePool.coins(tokenIndex).getPricePerFullShare());
        uint256[N_TOKENS] memory yAmounts = [uint256(0), 0, 0, 0];
        yAmounts[tokenIndex] = yTokenAmount;
        return curvePool.curve().calc_token_amount(yAmounts, true);
    }

    /**
     * @dev ensure enough curve.fi pool tokens are available
     * Check if current available amount of TUSD is enough and
     * withdraw remainder from gauge
     * @param neededAmount amount required
     */
    function withdrawFromGaugeIfNecessary(uint256 neededAmount) internal {
        uint256 currentlyAvailableAmount = curvePool.token().balanceOf(address(this));
        if (currentlyAvailableAmount < neededAmount) {
            curveGauge.withdraw(neededAmount.sub(currentlyAvailableAmount));
        }
    }

    /**
     * @dev Internal function to transfer entire token balance to pool
     */
    function transferAllToPool() internal {
        token.safeTransfer(pool, token.balanceOf(address(this)));
    }

    /**
     * @dev Calculate price minus max percentage of slippage during exchange
     * This will lead to the pool value become a bit undervalued
     * compared to the oracle price but will ensure that the value doesn't drop
     * when token exchanges are performed.
     */
    function conservativePriceEstimation(uint256 price) internal pure returns (uint256) {
        return price.mul(uint256(10000).sub(MAX_PRICE_SLIPPAGE)).div(10000);
    }

    /**
     * @dev Helper function to calculate minimum of `a` and `b`
     * @param a First variable to check if minimum
     * @param b Second variable to check if minimum
     * @return Lowest value between a and b
     */
    function min(uint256 a, uint256 b) internal pure returns (uint256) {
        return a > b ? b : a;
    }

    /**
     * @dev Helper function to convert between token precision
     * @param _value Value to normalize decimals for
     * @return Normalized value
     */
    function normalizeDecimals(uint256 _value) internal view returns (uint256) {
        return _value.mul(10**token.decimals()).div(10**18);
    }
}