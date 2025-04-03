/**
 *Submitted for verification at Etherscan.io on 2021-03-31
*/

// SPDX-License-Identifier: MIT

// File: @openzeppelin/contracts/GSN/Context.sol

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
abstract contract Context {
    function _msgSender() internal view virtual returns (address payable) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes memory) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}

// File: @openzeppelin/contracts/token/ERC20/IERC20.sol

pragma solidity ^0.6.0;

/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
 */


// File: @openzeppelin/contracts/math/SafeMath.sol



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


// File: @openzeppelin/contracts/utils/Address.sol



pragma solidity ^0.6.2;

/**
 * @dev Collection of functions related to the address type
 */


// File: @openzeppelin/contracts/token/ERC20/ERC20.sol



pragma solidity ^0.6.0;





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
    constructor (string memory name, string memory symbol) public {
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
}

// File: @openzeppelin/contracts/token/ERC20/SafeERC20.sol



pragma solidity ^0.6.0;




/**
 * @title SafeERC20
 * @dev Wrappers around ERC20 operations that throw on failure (when the token
 * contract returns false). Tokens that return no value (and instead revert or
 * throw on failure) are also supported, non-reverting calls are assumed to be
 * successful.
 * To use this library you can add a `using SafeERC20 for IERC20;` statement to your contract,
 * which allows you to call the safe operations as `token.safeTransfer(...)`, etc.
 */


// File: @openzeppelin/contracts/utils/ReentrancyGuard.sol



pragma solidity ^0.6.0;

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
contract ReentrancyGuard {
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

    constructor () internal {
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
        require(_status != _ENTERED, "ReentrancyGuard: reentrant call");

        // Any calls to nonReentrant after this point will fail
        _status = _ENTERED;

        _;

        // By storing the original value once again, a refund is triggered (see
        // https://eips.ethereum.org/EIPS/eip-2200)
        _status = _NOT_ENTERED;
    }
}

// File: contracts/Pausable.sol



pragma solidity 0.6.12;


/**
 * @dev Contract module which allows children to implement an emergency stop
 * mechanism that can be triggered by an authorized account.
 *
 */
contract Pausable is Context {
    event Paused(address account);
    event Shutdown(address account);
    event Unpaused(address account);
    event Open(address account);

    bool public paused;
    bool public stopEverything;

    modifier whenNotPaused() {
        require(!paused, "Pausable: paused");
        _;
    }
    modifier whenPaused() {
        require(paused, "Pausable: not paused");
        _;
    }

    modifier whenNotShutdown() {
        require(!stopEverything, "Pausable: shutdown");
        _;
    }

    modifier whenShutdown() {
        require(stopEverything, "Pausable: not shutdown");
        _;
    }

    /// @dev Pause contract operations, if contract is not paused.
    function _pause() internal virtual whenNotPaused {
        paused = true;
        emit Paused(_msgSender());
    }

    /// @dev Unpause contract operations, allow only if contract is paused and not shutdown.
    function _unpause() internal virtual whenPaused whenNotShutdown {
        paused = false;
        emit Unpaused(_msgSender());
    }

    /// @dev Shutdown contract operations, if not already shutdown.
    function _shutdown() internal virtual whenNotShutdown {
        stopEverything = true;
        paused = true;
        emit Shutdown(_msgSender());
    }

    /// @dev Open contract operations, if contract is in shutdown state
    function _open() internal virtual whenShutdown {
        stopEverything = false;
        emit Open(_msgSender());
    }
}

// File: contracts/interfaces/vesper/IController.sol



pragma solidity 0.6.12;



// File: contracts/interfaces/vesper/IVesperPool.sol



pragma solidity 0.6.12;


interface IVesperPool is IERC20 {
    function approveToken() external;

    function deposit() external payable;

    function deposit(uint256) external;

    function multiTransfer(uint256[] memory) external returns (bool);

    function permit(
        address,
        address,
        uint256,
        uint256,
        uint8,
        bytes32,
        bytes32
    ) external;

    function rebalance() external;

    function resetApproval() external;

    function sweepErc20(address) external;

    function withdraw(uint256) external;

    function withdrawETH(uint256) external;

    function withdrawByStrategy(uint256) external;

    function feeCollector() external view returns (address);

    function getPricePerShare() external view returns (uint256);

    function token() external view returns (address);

    function tokensHere() external view returns (uint256);

    function totalValue() external view returns (uint256);

    function withdrawFee() external view returns (uint256);
}

// File: contracts/interfaces/vesper/IPoolRewards.sol



pragma solidity 0.6.12;



// File: sol-address-list/contracts/interfaces/IAddressList.sol



pragma solidity ^0.6.6;



// File: sol-address-list/contracts/interfaces/IAddressListExt.sol



pragma solidity ^0.6.6;


interface IAddressListExt is IAddressList {
    function hasRole(bytes32 role, address account) external view returns (bool);

    function getRoleMemberCount(bytes32 role) external view returns (uint256);

    function getRoleMember(bytes32 role, uint256 index) external view returns (address);

    function getRoleAdmin(bytes32 role) external view returns (bytes32);

    function grantRole(bytes32 role, address account) external;

    function revokeRole(bytes32 role, address account) external;

    function renounceRole(bytes32 role, address account) external;
}

// File: sol-address-list/contracts/interfaces/IAddressListFactory.sol



pragma solidity ^0.6.6;



// File: contracts/pools/PoolShareToken.sol



pragma solidity 0.6.12;










/// @title Holding pool share token
// solhint-disable no-empty-blocks
abstract contract PoolShareToken is ERC20, Pausable, ReentrancyGuard {
    using SafeERC20 for IERC20;
    IERC20 public immutable token;
    IAddressListExt public immutable feeWhiteList;
    IController public immutable controller;

    /// @dev The EIP-712 typehash for the contract's domain
    bytes32 public constant DOMAIN_TYPEHASH =
        keccak256(
            "EIP712Domain(string name,string version,uint256 chainId,address verifyingContract)"
        );

    /// @dev The EIP-712 typehash for the permit struct used by the contract
    bytes32 public constant PERMIT_TYPEHASH =
        keccak256(
            "Permit(address owner,address spender,uint256 value,uint256 nonce,uint256 deadline)"
        );

    bytes32 public immutable domainSeparator;

    uint256 internal constant MAX_UINT_VALUE = uint256(-1);
    mapping(address => uint256) public nonces;
    event Deposit(address indexed owner, uint256 shares, uint256 amount);
    event Withdraw(address indexed owner, uint256 shares, uint256 amount);

    constructor(
        string memory _name,
        string memory _symbol,
        address _token,
        address _controller
    ) public ERC20(_name, _symbol) {
        uint256 chainId;
        assembly {
            chainId := chainid()
        }
        token = IERC20(_token);
        controller = IController(_controller);
        IAddressListFactory factory =
            IAddressListFactory(0xD57b41649f822C51a73C44Ba0B3da4A880aF0029);
        IAddressListExt _feeWhiteList = IAddressListExt(factory.createList());
        _feeWhiteList.grantRole(keccak256("LIST_ADMIN"), _controller);
        feeWhiteList = _feeWhiteList;
        domainSeparator = keccak256(
            abi.encode(
                DOMAIN_TYPEHASH,
                keccak256(bytes(_name)),
                keccak256(bytes("1")),
                chainId,
                address(this)
            )
        );
    }

    /**
     * @notice Deposit ERC20 tokens and receive pool shares depending on the current share price.
     * @param amount ERC20 token amount.
     */
    function deposit(uint256 amount) external virtual nonReentrant whenNotPaused {
        _deposit(amount);
    }

    /**
     * @notice Deposit ERC20 tokens with permit aka gasless approval.
     * @param amount ERC20 token amount.
     * @param deadline The time at which signature will expire
     * @param v The recovery byte of the signature
     * @param r Half of the ECDSA signature pair
     * @param s Half of the ECDSA signature pair
     */
    function depositWithPermit(
        uint256 amount,
        uint256 deadline,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external virtual nonReentrant whenNotPaused {
        IVesperPool(address(token)).permit(_msgSender(), address(this), amount, deadline, v, r, s);
        _deposit(amount);
    }

    /**
     * @notice Withdraw collateral based on given shares and the current share price.
     * Transfer earned rewards to caller. Withdraw fee, if any, will be deduced from
     * given shares and transferred to feeCollector. Burn remaining shares and return collateral.
     * @param shares Pool shares. It will be in 18 decimals.
     */
    function withdraw(uint256 shares) external virtual nonReentrant whenNotShutdown {
        _withdraw(shares);
    }

    /**
     * @notice Withdraw collateral based on given shares and the current share price.
     * Transfer earned rewards to caller. Burn shares and return collateral.
     * @dev No withdraw fee will be assessed when this function is called.
     * Only some white listed address can call this function.
     * @param shares Pool shares. It will be in 18 decimals.
     */
    function withdrawByStrategy(uint256 shares) external virtual nonReentrant whenNotShutdown {
        require(feeWhiteList.get(_msgSender()) != 0, "Not a white listed address");
        _withdrawByStrategy(shares);
    }

    /**
     * @notice Transfer tokens to multiple recipient
     * @dev Left 160 bits are the recipient address and the right 96 bits are the token amount.
     * @param bits array of uint
     * @return true/false
     */
    function multiTransfer(uint256[] memory bits) external returns (bool) {
        for (uint256 i = 0; i < bits.length; i++) {
            address a = address(bits[i] >> 96);
            uint256 amount = bits[i] & ((1 << 96) - 1);
            require(transfer(a, amount), "Transfer failed");
        }
        return true;
    }

    /**
     * @notice Triggers an approval from owner to spends
     * @param owner The address to approve from
     * @param spender The address to be approved
     * @param amount The number of tokens that are approved (2^256-1 means infinite)
     * @param deadline The time at which to expire the signature
     * @param v The recovery byte of the signature
     * @param r Half of the ECDSA signature pair
     * @param s Half of the ECDSA signature pair
     */
    function permit(
        address owner,
        address spender,
        uint256 amount,
        uint256 deadline,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external {
        require(deadline >= block.timestamp, "Expired");
        bytes32 digest =
            keccak256(
                abi.encodePacked(
                    "\x19\x01",
                    domainSeparator,
                    keccak256(
                        abi.encode(
                            PERMIT_TYPEHASH,
                            owner,
                            spender,
                            amount,
                            nonces[owner]++,
                            deadline
                        )
                    )
                )
            );
        address signatory = ecrecover(digest, v, r, s);
        require(signatory != address(0) && signatory == owner, "Invalid signature");
        _approve(owner, spender, amount);
    }

    /**
     * @notice Get price per share
     * @dev Return value will be in token defined decimals.
     */
    function getPricePerShare() external view returns (uint256) {
        if (totalSupply() == 0) {
            return convertFrom18(1e18);
        }
        return totalValue().mul(1e18).div(totalSupply());
    }

    /// @dev Convert to 18 decimals from token defined decimals. Default no conversion.
    function convertTo18(uint256 amount) public pure virtual returns (uint256) {
        return amount;
    }

    /// @dev Convert from 18 decimals to token defined decimals. Default no conversion.
    function convertFrom18(uint256 amount) public pure virtual returns (uint256) {
        return amount;
    }

    /// @dev Get fee collector address
    function feeCollector() public view virtual returns (address) {
        return controller.feeCollector(address(this));
    }

    /// @dev Returns the token stored in the pool. It will be in token defined decimals.
    function tokensHere() public view virtual returns (uint256) {
        return token.balanceOf(address(this));
    }

    /**
     * @dev Returns sum of token locked in other contracts and token stored in the pool.
     * Default tokensHere. It will be in token defined decimals.
     */
    function totalValue() public view virtual returns (uint256) {
        return tokensHere();
    }

    /**
     * @notice Get withdraw fee for this pool
     * @dev Format: 1e16 = 1% fee
     */
    function withdrawFee() public view virtual returns (uint256) {
        return controller.withdrawFee(address(this));
    }

    /**
     * @dev Hook that is called just before burning tokens. To be used i.e. if
     * collateral is stored in a different contract and needs to be withdrawn.
     * @param share Pool share in 18 decimals
     */
    function _beforeBurning(uint256 share) internal virtual {}

    /**
     * @dev Hook that is called just after burning tokens. To be used i.e. if
     * collateral stored in a different/this contract needs to be transferred.
     * @param amount Collateral amount in collateral token defined decimals.
     */
    function _afterBurning(uint256 amount) internal virtual {}

    /**
     * @dev Hook that is called just before minting new tokens. To be used i.e.
     * if the deposited amount is to be transferred from user to this contract.
     * @param amount Collateral amount in collateral token defined decimals.
     */
    function _beforeMinting(uint256 amount) internal virtual {}

    /**
     * @dev Hook that is called just after minting new tokens. To be used i.e.
     * if the deposited amount is to be transferred to a different contract.
     * @param amount Collateral amount in collateral token defined decimals.
     */
    function _afterMinting(uint256 amount) internal virtual {}

    /**
     * @dev Calculate shares to mint based on the current share price and given amount.
     * @param amount Collateral amount in collateral token defined decimals.
     */
    function _calculateShares(uint256 amount) internal view returns (uint256) {
        require(amount != 0, "amount is 0");

        uint256 _totalSupply = totalSupply();
        uint256 _totalValue = convertTo18(totalValue());
        uint256 shares =
            (_totalSupply == 0 || _totalValue == 0)
                ? amount
                : amount.mul(_totalSupply).div(_totalValue);
        return shares;
    }

    /// @dev Deposit incoming token and mint pool token i.e. shares.
    function _deposit(uint256 amount) internal whenNotPaused {
        uint256 shares = _calculateShares(convertTo18(amount));
        _beforeMinting(amount);
        _mint(_msgSender(), shares);
        _afterMinting(amount);
        emit Deposit(_msgSender(), shares, amount);
    }

    /// @dev Handle withdraw fee calculation and fee transfer to fee collector.
    function _handleFee(uint256 shares) internal returns (uint256 _sharesAfterFee) {
        if (withdrawFee() != 0) {
            uint256 _fee = shares.mul(withdrawFee()).div(1e18);
            _sharesAfterFee = shares.sub(_fee);
            _transfer(_msgSender(), feeCollector(), _fee);
        } else {
            _sharesAfterFee = shares;
        }
    }

    /// @dev Update pool reward of sender and receiver before transfer.
    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 /* amount */
    ) internal virtual override {
        address poolRewards = controller.poolRewards(address(this));
        if (poolRewards != address(0)) {
            if (from != address(0)) {
                IPoolRewards(poolRewards).updateReward(from);
            }
            if (to != address(0)) {
                IPoolRewards(poolRewards).updateReward(to);
            }
        }
    }

    /// @dev Burns shares and returns the collateral value, after fee, of those.
    function _withdraw(uint256 shares) internal whenNotShutdown {
        require(shares != 0, "share is 0");
        _beforeBurning(shares);
        uint256 sharesAfterFee = _handleFee(shares);
        uint256 amount =
            convertFrom18(sharesAfterFee.mul(convertTo18(totalValue())).div(totalSupply()));

        _burn(_msgSender(), sharesAfterFee);
        _afterBurning(amount);
        emit Withdraw(_msgSender(), shares, amount);
    }

    /// @dev Burns shares and returns the collateral value of those.
    function _withdrawByStrategy(uint256 shares) internal {
        require(shares != 0, "Withdraw must be greater than 0");
        _beforeBurning(shares);
        uint256 amount = convertFrom18(shares.mul(convertTo18(totalValue())).div(totalSupply()));
        _burn(_msgSender(), shares);
        _afterBurning(amount);
        emit Withdraw(_msgSender(), shares, amount);
    }
}

// File: contracts/interfaces/uniswap/IUniswapV2Router01.sol



pragma solidity 0.6.12;



// File: contracts/interfaces/uniswap/IUniswapV2Router02.sol



pragma solidity 0.6.12;


interface IUniswapV2Router02 is IUniswapV2Router01 {
    function swapExactTokensForTokensSupportingFeeOnTransferTokens(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external;

    function swapExactETHForTokensSupportingFeeOnTransferTokens(
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external payable;

    function swapExactTokensForETHSupportingFeeOnTransferTokens(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external;
}

// File: contracts/interfaces/vesper/IStrategy.sol



pragma solidity 0.6.12;



// File: contracts/pools/VTokenBase.sol



pragma solidity 0.6.12;




abstract contract VTokenBase is PoolShareToken {
    address internal constant WETH = 0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2;

    constructor(
        string memory name,
        string memory symbol,
        address _token,
        address _controller
    ) public PoolShareToken(name, symbol, _token, _controller) {
        require(_controller != address(0), "Controller address is zero");
    }

    modifier onlyController() {
        require(address(controller) == _msgSender(), "Caller is not the controller");
        _;
    }

    function pause() external onlyController {
        _pause();
    }

    function unpause() external onlyController {
        _unpause();
    }

    function shutdown() external onlyController {
        _shutdown();
    }

    function open() external onlyController {
        _open();
    }

    /// @dev Approve strategy to spend collateral token and strategy token of pool.
    function approveToken() external virtual onlyController {
        address strategy = controller.strategy(address(this));
        token.safeApprove(strategy, MAX_UINT_VALUE);
        IERC20(IStrategy(strategy).token()).safeApprove(strategy, MAX_UINT_VALUE);
    }

    /// @dev Reset token approval of strategy. Called when updating strategy.
    function resetApproval() external virtual onlyController {
        address strategy = controller.strategy(address(this));
        token.safeApprove(strategy, 0);
        IERC20(IStrategy(strategy).token()).safeApprove(strategy, 0);
    }

    /**
     * @dev Rebalance invested collateral to mitigate liquidation risk, if any.
     * Behavior of rebalance is driven by risk parameters defined in strategy.
     */
    function rebalance() external virtual {
        IStrategy strategy = IStrategy(controller.strategy(address(this)));
        strategy.rebalance();
    }

    /**
     * @dev Convert given ERC20 token into collateral token via Uniswap
     * @param _erc20 Token address
     */
    function sweepErc20(address _erc20) external virtual {
        _sweepErc20(_erc20);
    }

    /// @dev Returns collateral token locked in strategy
    function tokenLocked() public view virtual returns (uint256) {
        IStrategy strategy = IStrategy(controller.strategy(address(this)));
        return strategy.totalLocked();
    }

    /// @dev Returns total value of vesper pool, in terms of collateral token
    function totalValue() public view override returns (uint256) {
        return tokenLocked().add(tokensHere());
    }

    /**
     * @dev After burning hook, it will be called during withdrawal process.
     * It will withdraw collateral from strategy and transfer it to user.
     */
    function _afterBurning(uint256 _amount) internal override {
        uint256 balanceHere = tokensHere();
        if (balanceHere < _amount) {
            _withdrawCollateral(_amount.sub(balanceHere));
            balanceHere = tokensHere();
            _amount = balanceHere < _amount ? balanceHere : _amount;
        }
        token.safeTransfer(_msgSender(), _amount);
    }

    /**
     * @dev Before burning hook.
     * Some actions, like resurface(), can impact share price and has to be called before withdraw.
     */
    function _beforeBurning(
        uint256 /* shares */
    ) internal override {
        IStrategy strategy = IStrategy(controller.strategy(address(this)));
        strategy.beforeWithdraw();
    }

    function _beforeMinting(uint256 amount) internal override {
        token.safeTransferFrom(_msgSender(), address(this), amount);
    }

    function _withdrawCollateral(uint256 amount) internal virtual {
        IStrategy strategy = IStrategy(controller.strategy(address(this)));
        strategy.withdraw(amount);
    }

    function _sweepErc20(address _from) internal {
        IStrategy strategy = IStrategy(controller.strategy(address(this)));
        require(
            _from != address(token) && _from != address(this) && !strategy.isReservedToken(_from),
            "Not allowed to sweep"
        );
        IUniswapV2Router02 uniswapRouter = IUniswapV2Router02(controller.uniswapRouter());
        uint256 amt = IERC20(_from).balanceOf(address(this));
        IERC20(_from).safeApprove(address(uniswapRouter), 0);
        IERC20(_from).safeApprove(address(uniswapRouter), amt);
        address[] memory path;
        if (address(token) == WETH) {
            path = new address[](2);
            path[0] = _from;
            path[1] = address(token);
        } else {
            path = new address[](3);
            path[0] = _from;
            path[1] = WETH;
            path[2] = address(token);
        }
        uniswapRouter.swapExactTokensForTokens(amt, 1, path, address(this), now + 30);
    }
}

// File: contracts/pools/VLINK.sol



pragma solidity 0.6.12;


//solhint-disable no-empty-blocks
contract VLINK is VTokenBase {
    constructor(address _controller)
        public
        VTokenBase("vLINK Pool", "vLINK", 0x514910771AF9Ca656af840dff83E8264EcF986CA, _controller)
    {}
}