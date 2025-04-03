/**
 *Submitted for verification at Etherscan.io on 2021-06-25
*/

// SPDX-License-Identifier: MIT

pragma solidity ^0.7.0;

/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
 */


pragma solidity 0.7.6;




pragma solidity 0.7.6;



pragma solidity >=0.5.0;



pragma solidity >=0.5.0;

/// @title Math library for computing sqrt prices from ticks and vice versa
/// @notice Computes sqrt price for ticks of size 1.0001, i.e. sqrt(1.0001^tick) as fixed point Q64.96 numbers. Supports
/// prices between 2**-128 and 2**128


pragma solidity >=0.5.0;



/// @title Liquidity amount functions
/// @notice Provides functions for computing liquidity amounts from token amounts and prices


pragma solidity >=0.5.0;






/// @title Liquidity and ticks functions
/// @notice Provides functions for computing liquidity and ticks for token amounts and prices


pragma solidity >=0.5.0;

/// @title Permissionless pool actions
/// @notice Contains pool methods that can be called by anyone


pragma solidity >=0.5.0;

/// @title Pool state that is not stored
/// @notice Contains view functions to provide information about the pool that is computed rather than stored on the
/// blockchain. The functions here may have variable gas costs.


pragma solidity >=0.5.0;

/// @title Pool state that can change
/// @notice These methods compose the pool's state, and can change with any frequency including multiple times
/// per transaction


pragma solidity >=0.5.0;

/// @title Pool state that never changes
/// @notice These parameters are fixed for a pool forever, i.e., the methods will always return the same values


pragma solidity >=0.5.0;

/// @title The interface for a Uniswap V3 Pool
/// @notice A Uniswap pool facilitates swapping and automated market making between any two assets that strictly conform
/// to the ERC20 specification
/// @dev The pool interface is broken up into many smaller pieces
interface IUniswapV3Pool is
    IUniswapV3PoolImmutables,
    IUniswapV3PoolState,
    IUniswapV3PoolDerivedState,
    IUniswapV3PoolActions
{

}

pragma solidity 0.7.6;
pragma abicoder v2;



/// @title This library is created to conduct a variety of burn liquidity methods


pragma solidity >=0.4.0;

// computes square roots using the babylonian method
// https://en.wikipedia.org/wiki/Methods_of_computing_square_roots#Babylonian_method


pragma solidity ^0.7.0;


/**
 * @title Counters
 * @author Matt Condon (@shrugs)
 * @dev Provides counters that can only be incremented or decremented by one. This can be used e.g. to track the number
 * of elements in a mapping, issuing ERC721 ids, or counting request ids.
 *
 * Include with `using Counters for Counters.Counter;`
 * Since it is not possible to overflow a 256 bit integer with increments of one, `increment` can skip the {LowGasSafeMAth}
 * overflow check, thereby saving gas. This does assume however correct usage, in that the underlying `_value` is never
 * directly accessed.
 */


pragma solidity >=0.7.0;

/// @title Function for getting the current chain ID


pragma solidity =0.7.6;

/**
 * @dev Elliptic Curve Digital Signature Algorithm (ECDSA) operations.
 *
 * These functions can be used to verify that a message was signed by the holder
 * of the private keys of a given address.
 */


pragma solidity =0.7.6;



/**
 * @dev https://eips.ethereum.org/EIPS/eip-712[EIP 712] is a standard for hashing and signing of typed structured data.
 *
 * The encoding specified in the EIP is very generic, and such a generic implementation in Solidity is not feasible,
 * thus this contract does not implement the encoding itself. Protocols need to implement the type-specific encoding
 * they need in their contracts using a combination of `abi.encode` and `keccak256`.
 *
 * This contract implements the EIP 712 domain separator ({_domainSeparatorV4}) that is used as part of the encoding
 * scheme, and the final step of the encoding to obtain the message digest that is then signed via ECDSA
 * ({_hashTypedDataV4}).
 *
 * The implementation of the domain separator was designed to be as efficient as possible while still properly updating
 * the chain id to protect against replay attacks on an eventual fork of the chain.
 *
 * NOTE: This contract implements the version of the encoding known as "v4", as implemented by the JSON RPC method
 * https://docs.metamask.io/guide/signing-data.html[`eth_signTypedDataV4` in MetaMask].
 *
 * _Available since v3.4._
 */
abstract contract EIP712 {
    /* solhint-disable var-name-mixedcase */
    // Cache the domain separator as an immutable value, but also store the chain id that it corresponds to, in order to
    // invalidate the cached domain separator if the chain id changes.
    bytes32 private immutable _CACHED_DOMAIN_SEPARATOR;
    uint256 private immutable _CACHED_CHAIN_ID;

    bytes32 private immutable _HASHED_NAME;
    bytes32 private immutable _HASHED_VERSION;
    bytes32 private immutable _TYPE_HASH;
    /* solhint-enable var-name-mixedcase */

    /**
     * @dev Initializes the domain separator and parameter caches.
     *
     * The meaning of `name` and `version` is specified in
     * https://eips.ethereum.org/EIPS/eip-712#definition-of-domainseparator[EIP 712]:
     *
     * - `name`: the user readable name of the signing domain, i.e. the name of the DApp or the protocol.
     * - `version`: the current major version of the signing domain.
     *
     * NOTE: These parameters cannot be changed except through a xref:learn::upgrading-smart-contracts.adoc[smart
     * contract upgrade].
     */
    constructor(string memory name, string memory version) {
        bytes32 hashedName = keccak256(bytes(name));
        bytes32 hashedVersion = keccak256(bytes(version));
        bytes32 typeHash = keccak256("EIP712Domain(string name,string version,uint256 chainId,address verifyingContract)");
        _HASHED_NAME = hashedName;
        _HASHED_VERSION = hashedVersion;
        _CACHED_CHAIN_ID = ChainId.get();
        _CACHED_DOMAIN_SEPARATOR = _buildDomainSeparator(typeHash, hashedName, hashedVersion);
        _TYPE_HASH = typeHash;
    }

    /**
     * @dev Returns the domain separator for the current chain.
     */
    function _domainSeparatorV4() internal view returns (bytes32) {
        if (ChainId.get() == _CACHED_CHAIN_ID) {
            return _CACHED_DOMAIN_SEPARATOR;
        } else {
            return _buildDomainSeparator(_TYPE_HASH, _HASHED_NAME, _HASHED_VERSION);
        }
    }

    function _buildDomainSeparator(bytes32 typeHash, bytes32 name, bytes32 version) private view returns (bytes32) {
        return keccak256(
            abi.encode(
                typeHash,
                name,
                version,
                ChainId.get(),
                address(this)
            )
        );
    }

    /**
     * @dev Given an already https://eips.ethereum.org/EIPS/eip-712#definition-of-hashstruct[hashed struct], this
     * function returns the hash of the fully encoded EIP712 message for this domain.
     *
     * This hash can be used together with {ECDSA-recover} to obtain the signer of a message. For example:
     *
     * ```solidity
     * bytes32 digest = _hashTypedDataV4(keccak256(abi.encode(
     *     keccak256("Mail(address to,string contents)"),
     *     mailTo,
     *     keccak256(bytes(mailContents))
     * )));
     * address signer = ECDSA.recover(digest, signature);
     * ```
     */
    function _hashTypedDataV4(bytes32 structHash) internal view virtual returns (bytes32) {
        return ECDSA.toTypedDataHash(_domainSeparatorV4(), structHash);
    }
}

pragma solidity >=0.6.0 <0.8.0;

/**
 * @dev Interface of the ERC20 Permit extension allowing approvals to be made via signatures, as defined in
 * https://eips.ethereum.org/EIPS/eip-2612[EIP-2612].
 *
 * Adds the {permit} method, which can be used to change an account's ERC20 allowance (see {IERC20-allowance}) by
 * presenting a message signed by the account. By not relying on `{IERC20-approve}`, the token holder account doesn't
 * need to send a transaction, and thus is not required to hold Ether at all.
 */


pragma solidity >=0.6.0 <0.8.0;

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

pragma solidity ^0.7.0;




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
contract ERC20 is Context, IERC20 {
    using LowGasSafeMath for uint256;

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
    constructor (string memory name_, string memory symbol_) {
        _name = name_;
        _symbol = symbol_;
        _decimals = 18;
    }

    /**
     * @dev Returns the name of the token.
     */
    function name() public view virtual returns (string memory) {
        return _name;
    }

    /**
     * @dev Returns the symbol of the token, usually a shorter version of the
     * name.
     */
    function symbol() public view virtual returns (string memory) {
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
    function decimals() public view virtual returns (uint8) {
        return _decimals;
    }

    /**
     * @dev See {IERC20-totalSupply}.
     */
    function totalSupply() public view virtual override returns (uint256) {
        return _totalSupply;
    }

    /**
     * @dev See {IERC20-balanceOf}.
     */
    function balanceOf(address account) public view virtual override returns (uint256) {
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
     * required by the EIP. See the note at the beginning of {ERC20}.
     *
     * Requirements:
     *
     * - `sender` and `recipient` cannot be the zero address.
     * - `sender` must have a balance of at least `amount`.
     * - the caller must have allowance for ``sender``'s tokens of at least
     * `amount`.
     */
    function transferFrom(address sender, address recipient, uint256 amount) public virtual override returns (bool) {
        _transfer(sender, recipient, amount);
        _approve(sender, _msgSender(), _allowances[sender][_msgSender()].sub(amount, "TEA"));
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
        _approve(_msgSender(), spender, _allowances[_msgSender()][spender].sub(subtractedValue, "DEB"));
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
        require(sender != address(0), "FZA");
        require(recipient != address(0), "TZA");

        _beforeTokenTransfer(sender, recipient, amount);

        _balances[sender] = _balances[sender].sub(amount, "TEB");
        _balances[recipient] = _balances[recipient].add(amount);
        emit Transfer(sender, recipient, amount);
    }

    /** @dev Creates `amount` tokens and assigns them to `account`, increasing
     * the total supply.
     *
     * Emits a {Transfer} event with `from` set to the zero address.
     *
     * Requirements:
     *
     * - `to` cannot be the zero address.
     */
    function _mint(address account, uint256 amount) internal virtual {
        require(account != address(0), "MZA");

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
     * Requirements:
     *
     * - `account` cannot be the zero address.
     * - `account` must have at least `amount` tokens.
     */
    function _burn(address account, uint256 amount) internal virtual {
        require(account != address(0), "BZA");

        _beforeTokenTransfer(account, address(0), amount);

        _balances[account] = _balances[account].sub(amount, "BEB");
        _totalSupply = _totalSupply.sub(amount);
        emit Transfer(account, address(0), amount);
    }

    /**
     * @dev Sets `amount` as the allowance of `spender` over the `owner` s tokens.
     *
     * This internal function is equivalent to `approve`, and can be used to
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
        require(owner != address(0), "AFZA");
        require(spender != address(0), "ATZA");

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
    function _setupDecimals(uint8 decimals_) internal virtual {
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
}

pragma solidity =0.7.6;

/**
 * @dev Implementation of the ERC20 Permit extension allowing approvals to be made via signatures, as defined in
 * https://eips.ethereum.org/EIPS/eip-2612[EIP-2612].
 *
 * Adds the {permit} method, which can be used to change an account's ERC20 allowance (see {IERC20-allowance}) by
 * presenting a message signed by the account. By not relying on `{IERC20-approve}`, the token holder account doesn't
 * need to send a transaction, and thus is not required to hold Ether at all.
 *
 * _Available since v3.4._
 */
abstract contract ERC20Permit is ERC20, IERC20Permit, EIP712 {
    using Counters for Counters.Counter;

    mapping (address => Counters.Counter) private _nonces;
 
    //keccak256("Permit(address owner,address spender,uint256 value,uint256 nonce,uint256 deadline)");
    bytes32 private immutable _PERMIT_TYPEHASH = 0x6e71edae12b1b97f4d1f60370fef10105fa2faae0126114a169c64845d6126c9;

    /**
     * @dev Initializes the {EIP712} domain separator using the `name` parameter, and setting `version` to `"1"`.
     *
     * It's a good idea to use the same `name` that is defined as the ERC20 token name.
     */
    constructor(string memory name) EIP712(name, "1") {
    }

    /**
     * @dev See {IERC20Permit-permit}.
     */
    function permit(address owner, address spender, uint256 value, uint256 deadline, uint8 v, bytes32 r, bytes32 s) public virtual override {
        // solhint-disable-next-line not-rely-on-time
        require(block.timestamp <= deadline, "ED");

        bytes32 structHash = keccak256(
            abi.encode(
                _PERMIT_TYPEHASH,
                owner,
                spender,
                value,
                _useNonce(owner),
                deadline
            )
        );

        bytes32 hash = _hashTypedDataV4(structHash);

        address signer = ECDSA.recover(hash, v, r, s);
        require(signer == owner, "IS");

        _approve(owner, spender, value);
    }

    /**
     * @dev See {IERC20Permit-nonces}.
     */
    function nonces(address owner) public view virtual override returns (uint256) {
        return _nonces[owner].current();
    }

    /**
     * @dev See {IERC20Permit-DOMAIN_SEPARATOR}.
     */
    // solhint-disable-next-line func-name-mixedcase
    function DOMAIN_SEPARATOR() external view override returns (bytes32) {
        return _domainSeparatorV4();
    }

    /**
     * @dev "Consume a nonce": return the current value and increment.
     */
    function _useNonce(address owner) internal virtual returns (uint256 current) {
        Counters.Counter storage nonce = _nonces[owner];
        current = nonce.current();
        nonce.increment();
    }
}

pragma solidity >=0.4.0;

/// @title FixedPoint96
/// @notice A library for handling binary fixed point numbers, see https://en.wikipedia.org/wiki/Q_(number_format)
/// @dev Used in SqrtPriceMath.sol


pragma solidity >=0.5.0;

/// @title Math functions that do not check inputs or outputs
/// @notice Contains methods that perform common math functions but do not do any overflow or underflow checks


pragma solidity >=0.4.0;

/// @title Contains 512-bit math functions
/// @notice Facilitates multiplication and division that can have overflow of an intermediate value without any loss of precision
/// @dev Handles "phantom overflow" i.e., allows multiplication and division where an intermediate value overflows 256 bits


pragma solidity >=0.5.0;

/// @title Safe casting methods
/// @notice Contains methods for safely casting between types


pragma solidity >=0.7.0;

/// @title Optimized overflow and underflow safe math operations
/// @notice Contains methods for doing math operations that revert on overflow or underflow for minimal gas cost


pragma solidity >=0.5.0;






/// @title Functions based on Q64.96 sqrt price and liquidity
/// @notice Contains the math that uses square root of price as a Q64.96 and liquidity to compute deltas


pragma solidity >=0.6.0;





pragma solidity ^0.7.0;

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
 */
abstract contract ReentrancyGuard {
    // Booleans are more expensive than uint256 or any type that takes up a full
    // word because each write operation emits an extra SLOAD to first read the
    // slot's contents, replace the bits taken up by the boolean, and then write
    // back. This is the compiler's defense against contract upgrades and
    // pointer aliasing, and it cannot be disabled.

    // The values being non-zero value makes deployment a bit more expensive,
    // but in exchange the refund on every call to nonReentrant will be lower in
    // amount. Since refunds are capped to a percentage of the total
    // transaction's gas, it is best to keep them low in cases like this one, to
    // increase the likelihood of the full refund coming into effect.
    uint256 private constant _NOT_ENTERED = 1;
    uint256 private constant _ENTERED = 2;

    uint256 private _status;

    constructor () {
        _status = _NOT_ENTERED;
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
        require(_status != _ENTERED, "RC");

        // Any calls to nonReentrant after this point will fail
        _status = _ENTERED;

        _;

        // By storing the original value once again, a refund is triggered (see
        // https://eips.ethereum.org/EIPS/eip-2200)
        _status = _NOT_ENTERED;
    }
}

pragma solidity =0.7.6;


/// @title Interface for WETH9
interface IWETH9 is IERC20 {
    /// @notice Deposit ether to get wrapped ether
    function deposit() external payable;
}

pragma solidity 0.7.6;

/// @title Sorbetto Fragola is a yield enchancement v3 contract
/// @dev Sorbetto fragola is a Uniswap V3 yield enchancement contract which acts as
/// intermediary between the user who wants to provide liquidity to specific pools
/// and earn fees from such actions. The contract ensures that user position is in 
/// range and earns maximum amount of fees available at current liquidity utilization
/// rate. 
contract SorbettoFragola is ERC20Permit, ReentrancyGuard, ISorbettoFragola {
    using LowGasSafeMath for uint256;
    using LowGasSafeMath for uint160;
    using LowGasSafeMath for uint128;
    using UnsafeMath for uint256;
    using SafeCast for uint256;
    using PoolVariables for IUniswapV3Pool;
    using PoolActions for IUniswapV3Pool;
    
    //Any data passed through by the caller via the IUniswapV3PoolActions#mint call
    struct MintCallbackData {
        address payer;
    }
    //Any data passed through by the caller via the IUniswapV3PoolActions#swap call
    struct SwapCallbackData {
        bool zeroForOne;
    }
    // Info of each user
    struct UserInfo {
        uint256 token0Rewards; // The amount of fees in token 0
        uint256 token1Rewards; // The amount of fees in token 1
        uint256 token0PerSharePaid; // Token 0 reward debt 
        uint256 token1PerSharePaid; // Token 1 reward debt
    }

    /// @notice Emitted when user adds liquidity
    /// @param sender The address that minted the liquidity
    /// @param liquidity The amount of liquidity added by the user to position
    /// @param amount0 How much token0 was required for the added liquidity
    /// @param amount1 How much token1 was required for the added liquidity
    event Deposit(
        address indexed sender,
        uint256 liquidity,
        uint256 amount0,
        uint256 amount1
    );
    
    /// @notice Emitted when user withdraws liquidity
    /// @param sender The address that minted the liquidity
    /// @param shares of liquidity withdrawn by the user from the position
    /// @param amount0 How much token0 was required for the added liquidity
    /// @param amount1 How much token1 was required for the added liquidity
    event Withdraw(
        address indexed sender,
        uint256 shares,
        uint256 amount0,
        uint256 amount1
    );
    
    /// @notice Emitted when fees was collected from the pool
    /// @param feesFromPool0 Total amount of fees collected in terms of token 0
    /// @param feesFromPool1 Total amount of fees collected in terms of token 1
    /// @param usersFees0 Total amount of fees collected by users in terms of token 0
    /// @param usersFees1 Total amount of fees collected by users in terms of token 1
    event CollectFees(
        uint256 feesFromPool0,
        uint256 feesFromPool1,
        uint256 usersFees0,
        uint256 usersFees1
    );

    /// @notice Emitted when sorbetto fragola changes the position in the pool
    /// @param tickLower Lower price tick of the positon
    /// @param tickUpper Upper price tick of the position
    /// @param amount0 Amount of token 0 deposited to the position
    /// @param amount1 Amount of token 1 deposited to the position
    event Rerange(
        int24 tickLower,
        int24 tickUpper,
        uint256 amount0,
        uint256 amount1
    );
    
    /// @notice Emitted when user collects his fee share
    /// @param sender User address
    /// @param fees0 Exact amount of fees claimed by the users in terms of token 0 
    /// @param fees1 Exact amount of fees claimed by the users in terms of token 1
    event RewardPaid(
        address indexed sender,
        uint256 fees0,
        uint256 fees1
    );
    
    /// @notice Shows current Sorbetto's balances
    /// @param totalAmount0 Current token0 Sorbetto's balance
    /// @param totalAmount1 Current token1 Sorbetto's balance
    event Snapshot(uint256 totalAmount0, uint256 totalAmount1);

    event TransferGovernance(address indexed previousGovernance, address indexed newGovernance);
    
    /// @notice Prevents calls from users
    modifier onlyGovernance {
        require(msg.sender == governance, "OG");
        _;
    }
    
    mapping(address => UserInfo) public userInfo; // Info of each user that provides liquidity tokens.
    /// @inheritdoc ISorbettoFragola
    address public immutable override token0;
    /// @inheritdoc ISorbettoFragola
    address public immutable override token1;
    // WETH address
    address public immutable weth = 0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2;
    // @inheritdoc ISorbettoFragola
    int24 public immutable override tickSpacing;
    uint24 immutable GLOBAL_DIVISIONER = 1e6; // for basis point (0.0001%)

    // @inheritdoc ISorbettoFragola
    IUniswapV3Pool public override pool;
    // Accrued protocol fees in terms of token0
    uint256 public accruedProtocolFees0;
    // Accrued protocol fees in terms of token1
    uint256 public accruedProtocolFees1;
    // Total lifetime accrued users fees in terms of token0
    uint256 public usersFees0;
    // Total lifetime accrued users fees in terms of token1
    uint256 public usersFees1;
    // intermediate variable for user fee token0 calculation
    uint256 public token0PerShareStored;
    // intermediate variable for user fee token1 calculation
    uint256 public token1PerShareStored;
    
    // Address of the Sorbetto's owner
    address public governance;
    // Pending to claim ownership address
    address public pendingGovernance;
    //Sorbetto fragola settings address
    address public strategy;
    // Current tick lower of sorbetto pool position
    int24 public override tickLower;
    // Current tick higher of sorbetto pool position
    int24 public override tickUpper;
    // Checks if sorbetto is initialized
    bool public finalized;
    
    /**
     * @dev After deploying, strategy can be set via `setStrategy()`
     * @param _pool Underlying Uniswap V3 pool with fee = 3000
     * @param _strategy Underlying Sorbetto Strategy for Sorbetto settings
     */
     constructor(
        address _pool,
        address _strategy
    ) ERC20("Popsicle LP V3 WBTC/WETH", "PLP") ERC20Permit("Popsicle LP V3 WBTC/WETH") {
        pool = IUniswapV3Pool(_pool);
        strategy = _strategy;
        token0 = pool.token0();
        token1 = pool.token1();
        tickSpacing = pool.tickSpacing();
        governance = msg.sender;
    }
    //initialize strategy
    function init() external onlyGovernance {
        require(!finalized, "F");
        finalized = true;
        int24 baseThreshold = tickSpacing * ISorbettoStrategy(strategy).tickRangeMultiplier();
        ( , int24 currentTick, , , , , ) = pool.slot0();
        int24 tickFloor = PoolVariables.floor(currentTick, tickSpacing);
        
        tickLower = tickFloor - baseThreshold;
        tickUpper = tickFloor + baseThreshold;
        PoolVariables.checkRange(tickLower, tickUpper); //check ticks also for overflow/underflow
    }
    
    /// @inheritdoc ISorbettoFragola
     function deposit(
        uint256 amount0Desired,
        uint256 amount1Desired
    )
        external
        payable
        override
        nonReentrant
        checkDeviation
        updateVault(msg.sender)
        returns (
            uint256 shares,
            uint256 amount0,
            uint256 amount1
        )
    {
        require(amount0Desired > 0 && amount1Desired > 0, "ANV");
        uint128 liquidityLast = pool.positionLiquidity(tickLower, tickUpper);
        // compute the liquidity amount
        uint128 liquidity = pool.liquidityForAmounts(amount0Desired, amount1Desired, tickLower, tickUpper);
        
        (amount0, amount1) = pool.mint(
            address(this),
            tickLower,
            tickUpper,
            liquidity,
            abi.encode(MintCallbackData({payer: msg.sender})));

        shares = _calcShare(liquidity, liquidityLast);

        _mint(msg.sender, shares);
        refundETH();
        emit Deposit(msg.sender, shares, amount0, amount1);
    }
    
    /// @inheritdoc ISorbettoFragola
    function withdraw(
        uint256 shares
    ) 
        external
        override
        nonReentrant
        checkDeviation
        updateVault(msg.sender)
        returns (
            uint256 amount0,
            uint256 amount1
        )
    {
        require(shares > 0, "S");


        (amount0, amount1) = pool.burnLiquidityShare(tickLower, tickUpper, totalSupply(), shares,  msg.sender);
        
        // Burn shares
        _burn(msg.sender, shares);
        emit Withdraw(msg.sender, shares, amount0, amount1);
    }
    
    /// @inheritdoc ISorbettoFragola
    function rerange() external override nonReentrant checkDeviation updateVault(address(0)) {

        //Burn all liquidity from pool to rerange for Sorbetto's balances.
        pool.burnAllLiquidity(tickLower, tickUpper);
        

        // Emit snapshot to record balances
        uint256 balance0 = _balance0();
        uint256 balance1 = _balance1();
        emit Snapshot(balance0, balance1);

        int24 baseThreshold = tickSpacing * ISorbettoStrategy(strategy).tickRangeMultiplier();

        //Get exact ticks depending on Sorbetto's balances
        (tickLower, tickUpper) = pool.getPositionTicks(balance0, balance1, baseThreshold, tickSpacing);

        //Get Liquidity for Sorbetto's balances
        uint128 liquidity = pool.liquidityForAmounts(balance0, balance1, tickLower, tickUpper);
        
        // Add liquidity to the pool
        (uint256 amount0, uint256 amount1) = pool.mint(
            address(this),
            tickLower,
            tickUpper,
            liquidity,
            abi.encode(MintCallbackData({payer: address(this)})));
        
        emit Rerange(tickLower, tickUpper, amount0, amount1);
    }

    /// @inheritdoc ISorbettoFragola
    function rebalance() external override onlyGovernance nonReentrant checkDeviation updateVault(address(0))  {

        //Burn all liquidity from pool to rerange for Sorbetto's balances.
        pool.burnAllLiquidity(tickLower, tickUpper);
        
        //Calc base ticks
        (uint160 sqrtPriceX96, int24 currentTick, , , , , ) = pool.slot0();
        PoolVariables.Info memory cache = 
            PoolVariables.Info(0, 0, 0, 0, 0, 0, 0);
        int24 baseThreshold = tickSpacing * ISorbettoStrategy(strategy).tickRangeMultiplier();
        (cache.tickLower, cache.tickUpper) = PoolVariables.baseTicks(currentTick, baseThreshold, tickSpacing);
        
        cache.amount0Desired = _balance0();
        cache.amount1Desired = _balance1();
        emit Snapshot(cache.amount0Desired, cache.amount1Desired);
        // Calc liquidity for base ticks
        cache.liquidity = pool.liquidityForAmounts(cache.amount0Desired, cache.amount1Desired, cache.tickLower, cache.tickUpper);

        // Get exact amounts for base ticks
        (cache.amount0, cache.amount1) = pool.amountsForLiquidity(cache.liquidity, cache.tickLower, cache.tickUpper);

        // Get imbalanced token
        bool zeroForOne = PoolVariables.amountsDirection(cache.amount0Desired, cache.amount1Desired, cache.amount0, cache.amount1);
        // Calculate the amount of imbalanced token that should be swapped. Calculations strive to achieve one to one ratio
        int256 amountSpecified = 
            zeroForOne
                ? int256(cache.amount0Desired.sub(cache.amount0).unsafeDiv(2))
                : int256(cache.amount1Desired.sub(cache.amount1).unsafeDiv(2)); // always positive. "overflow" safe convertion cuz we are dividing by 2

        // Calculate Price limit depending on price impact
        uint160 exactSqrtPriceImpact = sqrtPriceX96.mul160(ISorbettoStrategy(strategy).priceImpactPercentage() / 2) / GLOBAL_DIVISIONER;
        uint160 sqrtPriceLimitX96 = zeroForOne ?  sqrtPriceX96.sub160(exactSqrtPriceImpact) : sqrtPriceX96.add160(exactSqrtPriceImpact);

        //Swap imbalanced token as long as we haven't used the entire amountSpecified and haven't reached the price limit
        pool.swap(
            address(this),
            zeroForOne,
            amountSpecified,
            sqrtPriceLimitX96,
            abi.encode(SwapCallbackData({zeroForOne: zeroForOne}))
        );


        (sqrtPriceX96, currentTick, , , , , ) = pool.slot0();

        // Emit snapshot to record balances
        cache.amount0Desired = _balance0();
        cache.amount1Desired = _balance1();
        emit Snapshot(cache.amount0Desired, cache.amount1Desired);
        //Get exact ticks depending on Sorbetto's new balances
        (tickLower, tickUpper) = pool.getPositionTicks(cache.amount0Desired, cache.amount1Desired, baseThreshold, tickSpacing);

        cache.liquidity = pool.liquidityForAmounts(cache.amount0Desired, cache.amount1Desired, tickLower, tickUpper);

        // Add liquidity to the pool
        (cache.amount0, cache.amount1) = pool.mint(
            address(this),
            tickLower,
            tickUpper,
            cache.liquidity,
            abi.encode(MintCallbackData({payer: address(this)})));
        emit Rerange(tickLower, tickUpper, cache.amount0, cache.amount1);
    }

    // Calcs user share depending on deposited amounts
    function _calcShare(uint128 liquidity, uint128 liquidityLast)
        internal
        view
        returns (
            uint256 shares
        )
    {
        shares = totalSupply() == 0 ? uint256(liquidity) : uint256(liquidity).mul(totalSupply()).unsafeDiv(uint256(liquidityLast));
    }
    
    /// @dev Amount of token0 held as unused balance.
    function _balance0() internal view returns (uint256) {
        return IERC20(token0).balanceOf(address(this));
    }

    /// @dev Amount of token1 held as unused balance.
    function _balance1() internal view returns (uint256) {
        return IERC20(token1).balanceOf(address(this));
    }
    
    /// @dev collects fees from the pool
    function _earnFees() internal returns (uint256 userCollect0, uint256 userCollect1) {
         // Do zero-burns to poke the Uniswap pools so earned fees are updated
        pool.burn(tickLower, tickUpper, 0);
        
        (uint256 collect0, uint256 collect1) =
            pool.collect(
                address(this),
                tickLower,
                tickUpper,
                type(uint128).max,
                type(uint128).max
            );

        // Calculate protocol's and users share of fees
        uint256 feeToProtocol0 = collect0.mul(ISorbettoStrategy(strategy).protocolFee()).unsafeDiv(GLOBAL_DIVISIONER);
        uint256 feeToProtocol1 = collect1.mul(ISorbettoStrategy(strategy).protocolFee()).unsafeDiv(GLOBAL_DIVISIONER);
        accruedProtocolFees0 = accruedProtocolFees0.add(feeToProtocol0);
        accruedProtocolFees1 = accruedProtocolFees1.add(feeToProtocol1);
        userCollect0 = collect0.sub(feeToProtocol0);
        userCollect1 = collect1.sub(feeToProtocol1);
        usersFees0 = usersFees0.add(userCollect0);
        usersFees1 = usersFees1.add(userCollect1);
        emit CollectFees(collect0, collect1, usersFees0, usersFees1);
    }

    /// @notice Returns current Sorbetto's position in pool
    function position() external view returns (uint128 liquidity, uint256 feeGrowthInside0LastX128, uint256 feeGrowthInside1LastX128, uint128 tokensOwed0, uint128 tokensOwed1) {
        bytes32 positionKey = PositionKey.compute(address(this), tickLower, tickUpper);
        (liquidity, feeGrowthInside0LastX128, feeGrowthInside1LastX128, tokensOwed0, tokensOwed1) = pool.positions(positionKey);
    }
    
    /// @notice Pull in tokens from sender. Called to `msg.sender` after minting liquidity to a position from IUniswapV3Pool#mint.
    /// @dev In the implementation you must pay to the pool for the minted liquidity.
    /// @param amount0 The amount of token0 due to the pool for the minted liquidity
    /// @param amount1 The amount of token1 due to the pool for the minted liquidity
    /// @param data Any data passed through by the caller via the IUniswapV3PoolActions#mint call
    function uniswapV3MintCallback(
        uint256 amount0,
        uint256 amount1,
        bytes calldata data
    ) external {
        require(msg.sender == address(pool), "FP");
        MintCallbackData memory decoded = abi.decode(data, (MintCallbackData));
        if (amount0 > 0) pay(token0, decoded.payer, msg.sender, amount0);
        if (amount1 > 0) pay(token1, decoded.payer, msg.sender, amount1);
    }

    /// @notice Called to `msg.sender` after minting swaping from IUniswapV3Pool#swap.
    /// @dev In the implementation you must pay to the pool for swap.
    /// @param amount0 The amount of token0 due to the pool for the swap
    /// @param amount1 The amount of token1 due to the pool for the swap
    /// @param _data Any data passed through by the caller via the IUniswapV3PoolActions#swap call
    function uniswapV3SwapCallback(
        int256 amount0,
        int256 amount1,
        bytes calldata _data
    ) external {
        require(msg.sender == address(pool), "FP");
        require(amount0 > 0 || amount1 > 0); // swaps entirely within 0-liquidity regions are not supported
        SwapCallbackData memory data = abi.decode(_data, (SwapCallbackData));
        bool zeroForOne = data.zeroForOne;

        if (zeroForOne) pay(token0, address(this), msg.sender, uint256(amount0)); 
        else pay(token1, address(this), msg.sender, uint256(amount1));
    }

    /// @param token The token to pay
    /// @param payer The entity that must pay
    /// @param recipient The entity that will receive payment
    /// @param value The amount to pay
    function pay(
        address token,
        address payer,
        address recipient,
        uint256 value
    ) internal {
        if (token == weth && address(this).balance >= value) {
            // pay with WETH9
            IWETH9(weth).deposit{value: value}(); // wrap only what is needed to pay
            IWETH9(weth).transfer(recipient, value);
        } else if (payer == address(this)) {
            // pay with tokens already in the contract (for the exact input multihop case)
            TransferHelper.safeTransfer(token, recipient, value);
        } else {
            // pull payment
            TransferHelper.safeTransferFrom(token, payer, recipient, value);
        }
    }
    
    
    /**
     * @notice Used to withdraw accumulated protocol fees.
     */
    function collectProtocolFees(
        uint256 amount0,
        uint256 amount1
    ) external nonReentrant onlyGovernance updateVault(address(0)) {
        require(accruedProtocolFees0 >= amount0, "A0F");
        require(accruedProtocolFees1 >= amount1, "A1F");
        
        uint256 balance0 = _balance0();
        uint256 balance1 = _balance1();
        
        if (balance0 >= amount0 && balance1 >= amount1)
        {
            if (amount0 > 0) pay(token0, address(this), msg.sender, amount0);
            if (amount1 > 0) pay(token1, address(this), msg.sender, amount1);
        }
        else
        {
            uint128 liquidity = pool.liquidityForAmounts(amount0, amount1, tickLower, tickUpper);
            pool.burnExactLiquidity(tickLower, tickUpper, liquidity, msg.sender);
        
        }
        
        accruedProtocolFees0 = accruedProtocolFees0.sub(amount0);
        accruedProtocolFees1 = accruedProtocolFees1.sub(amount1);
        emit RewardPaid(msg.sender, amount0, amount1);
    }
    
    /**
     * @notice Used to withdraw accumulated user's fees.
     */
    function collectFees(uint256 amount0, uint256 amount1) external nonReentrant updateVault(msg.sender) {
        UserInfo storage user = userInfo[msg.sender];

        require(user.token0Rewards >= amount0, "A0R");
        require(user.token1Rewards >= amount1, "A1R");

        uint256 balance0 = _balance0();
        uint256 balance1 = _balance1();

        if (balance0 >= amount0 && balance1 >= amount1) {

            if (amount0 > 0) pay(token0, address(this), msg.sender, amount0);
            if (amount1 > 0) pay(token1, address(this), msg.sender, amount1);
        }
        else {
            
            uint128 liquidity = pool.liquidityForAmounts(amount0, amount1, tickLower, tickUpper);
            (amount0, amount1) = pool.burnExactLiquidity(tickLower, tickUpper, liquidity, msg.sender);
        }
        user.token0Rewards = user.token0Rewards.sub(amount0);
        user.token1Rewards = user.token1Rewards.sub(amount1);
        emit RewardPaid(msg.sender, amount0, amount1);
    }
    
    // Function modifier that calls update fees reward function
    modifier updateVault(address account) {
        _updateFeesReward(account);
        _;
    }

    // Function modifier that checks if price has not moved a lot recently.
    // This mitigates price manipulation during rebalance and also prevents placing orders
    // when it's too volatile.
    modifier checkDeviation() {
        pool.checkDeviation(ISorbettoStrategy(strategy).maxTwapDeviation(), ISorbettoStrategy(strategy).twapDuration());
        _;
    }
    
    // Updates user's fees reward
    function _updateFeesReward(address account) internal {
        uint liquidity = pool.positionLiquidity(tickLower, tickUpper);
        if (liquidity == 0) return; // we can't poke when liquidity is zero
        (uint256 collect0, uint256 collect1) = _earnFees();
        
        
        token0PerShareStored = _tokenPerShare(collect0, token0PerShareStored);
        token1PerShareStored = _tokenPerShare(collect1, token1PerShareStored);

        if (account != address(0)) {
            UserInfo storage user = userInfo[msg.sender];
            user.token0Rewards = _fee0Earned(account, token0PerShareStored);
            user.token0PerSharePaid = token0PerShareStored;
            
            user.token1Rewards = _fee1Earned(account, token1PerShareStored);
            user.token1PerSharePaid = token1PerShareStored;
        }
    }
    
    // Calculates how much token0 is entitled for a particular user
    function _fee0Earned(address account, uint256 fee0PerShare_) internal view returns (uint256) {
        UserInfo memory user = userInfo[account];
        return
            balanceOf(account)
            .mul(fee0PerShare_.sub(user.token0PerSharePaid))
            .unsafeDiv(1e18)
            .add(user.token0Rewards);
    }
    
    // Calculates how much token1 is entitled for a particular user
    function _fee1Earned(address account, uint256 fee1PerShare_) internal view returns (uint256) {
        UserInfo memory user = userInfo[account];
        return
            balanceOf(account)
            .mul(fee1PerShare_.sub(user.token1PerSharePaid))
            .unsafeDiv(1e18)
            .add(user.token1Rewards);
    }
    
    // Calculates how much token is provided per LP token 
    function _tokenPerShare(uint256 collected, uint256 tokenPerShareStored) internal view returns (uint256) {
        uint _totalSupply = totalSupply();
        if (_totalSupply > 0) {
            return tokenPerShareStored
            .add(
                collected
                .mul(1e18)
                .unsafeDiv(_totalSupply)
            );
        }
        return tokenPerShareStored;
    }
    
    /// @notice Refunds any ETH balance held by this contract to the `msg.sender`
    /// @dev Useful for bundling with mint or increase liquidity that uses ether, or exact output swaps
    /// that use ether for the input amount
    function refundETH() internal {
        if (address(this).balance > 0) TransferHelper.safeTransferETH(msg.sender, address(this).balance);
    }

    /**
     * @notice `setGovernance()` should be called by the existing governance
     * address prior to calling this function.
     */
    function setGovernance(address _governance) external onlyGovernance {
        pendingGovernance = _governance;
    }

    /**
     * @notice Governance address is not updated until the new governance
     * address has called `acceptGovernance()` to accept this responsibility.
     */
    function acceptGovernance() external {
        require(msg.sender == pendingGovernance, "PG");
        emit TransferGovernance(governance, pendingGovernance);
        pendingGovernance = address(0);
        governance = msg.sender;
    }

    // Sets new strategy contract address for new settings
    function setStrategy(address _strategy) external onlyGovernance {
        require(_strategy != address(0), "NA");
        strategy = _strategy;
    }
}