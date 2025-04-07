/**
 *Submitted for verification at Etherscan.io on 2021-03-15
*/

// SPDX-License-Identifier: MIT

pragma experimental ABIEncoderV2;
pragma solidity 0.6.12;


// 
/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
 */


// 
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


// 
/**
 * @dev Collection of functions related to the address type
 */


// 
/**
 * @title SafeERC20
 * @dev Wrappers around ERC20 operations that throw on failure (when the token
 * contract returns false). Tokens that return no value (and instead revert or
 * throw on failure) are also supported, non-reverting calls are assumed to be
 * successful.
 * To use this library you can add a `using SafeERC20 for IERC20;` statement to your contract,
 * which allows you to call the safe operations as `token.safeTransfer(...)`, etc.
 */


// 
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

// 
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
}

// 


// 


// 


// 


// 
interface ISTABLEX is IERC20 {
  function mint(address account, uint256 amount) external;

  function burn(address account, uint256 amount) external;

  function a() external view returns (IAddressProvider);
}

// 


// 


// 


// 


// 


// 


// 


// 


// 


// 


// 


// 
interface IMIMO is IERC20 {

  function burn(address account, uint256 amount) external;
  
  function mint(address account, uint256 amount) external;

}

// 


// 


// 


// 


// 


// 


// 


// solium-disable security/no-block-members
// 
/**
 * @title  MIMO
 * @notice  MIMO Governance token
 */
contract MIMO is ERC20("MIMO Parallel Governance Token", "MIMO") {
  IGovernanceAddressProvider public a;

  bytes32 public constant MIMO_MINTER_ROLE = keccak256("MIMO_MINTER_ROLE");

  constructor(IGovernanceAddressProvider _a) public {
    require(address(_a) != address(0));

    a = _a;
  }

  modifier onlyMIMOMinter() {
    require(a.controller().hasRole(MIMO_MINTER_ROLE, msg.sender), "Caller is not MIMO Minter");
    _;
  }

  function mint(address account, uint256 amount) public onlyMIMOMinter {
    _mint(account, amount);
  }

  function burn(address account, uint256 amount) public onlyMIMOMinter {
    _burn(account, amount);
  }
}

// 


// 
contract PreUseAirdrop {
  using SafeERC20 for IERC20;

  struct Payout {
    address recipient;
    uint256 amount;
  }

  Payout[] public payouts;

  IGovernanceAddressProvider public ga;
  IMIMODistributor public mimoDistributor;

  modifier onlyManager() {
    require(ga.controller().hasRole(ga.controller().MANAGER_ROLE(), msg.sender), "Caller is not a Manager");
    _;
  }

  constructor(IGovernanceAddressProvider _ga, IMIMODistributor _mimoDistributor) public {
    require(address(_ga) != address(0));
    require(address(_mimoDistributor) != address(0));

    ga = _ga;
    mimoDistributor = _mimoDistributor;

    payouts.push(Payout(0xBBd92c75C6f8B0FFe9e5BCb2e56a5e2600871a10, 271147720731494841509243076));
    payouts.push(Payout(0xcc8793d5eB95fAa707ea4155e09b2D3F44F33D1E, 210989402066696530434956148));
    payouts.push(Payout(0x185f19B43d818E10a31BE68f445ef8EDCB8AFB83, 22182938994846641176273320));
    payouts.push(Payout(0xDeD9F901D40A96C3Ee558E6885bcc7eFC51ad078, 13678603288816593264718593));
    payouts.push(Payout(0x0B3890bbF2553Bd098B45006aDD734d6Fbd6089E, 8416873402881706143143730));
    payouts.push(Payout(0x3F41a1CFd3C8B8d9c162dE0f42307a0095A6e5DF, 7159719590701445955473554));
    payouts.push(Payout(0x9115BaDce4873d58fa73b08279529A796550999a, 5632453715407980754075398));
    payouts.push(Payout(0x7BC8C0B66d7f0E2193ED11eeCAAfE7c1837b926f, 5414893264683531027764823));
    payouts.push(Payout(0xE7809aaaaa78E5a24E059889E561f598F3a4664c, 4712320945661497844704387));
    payouts.push(Payout(0xf4D3566729f257edD0D4bF365d8f0Db7bF56e1C6, 2997276841876706895655431));
    payouts.push(Payout(0x6Cf9AA65EBaD7028536E353393630e2340ca6049, 2734992792750385321760387));
    payouts.push(Payout(0x74386381Cb384CC0FBa0Ac669d22f515FfC147D2, 1366427847282177615773594));
    payouts.push(Payout(0x9144b150f28437E06Ab5FF5190365294eb1E87ec, 1363226310703652991601514));
    payouts.push(Payout(0x5691d53685e8e219329bD8ADf62b1A0A17df9D11, 702790464733701088417744));
    payouts.push(Payout(0x2B91B4f5223a0a1f5c7e1D139dDdD6B5B57C7A51, 678663683269882192090830));
    payouts.push(Payout(0x8ddBad507F3b20239516810C308Ba4f3BaeAf3a1, 635520835923336863138335));
    payouts.push(Payout(0xc3874A2C59b9779A75874Be6B5f0b578120A8701, 488385391000796390198744));
    payouts.push(Payout(0x0A22C160f7E57F2e7d88b2fa1B1B03571bdE6128, 297735186117080365383063));
    payouts.push(Payout(0x0a1aa2b65832fC0c71f2Ba488c84BeE0b9DB9692, 132688033756581498940995));
    payouts.push(Payout(0xAf7b7AbC272a3aE6dD6dA41b9832C758477a85f2, 130254714680714068405131));
    payouts.push(Payout(0xCDb17d9bCbA8E3bab6F68D59065efe784700Bee1, 71018627162763037055295));
    payouts.push(Payout(0x4Dec19003F9Bb01A4c0D089605618b2d76deE30d, 69655357581389001902516));
    payouts.push(Payout(0x31AacA1940C82130c2D4407E609e626E87A7BC18, 21678478730854029506989));
    payouts.push(Payout(0xBc77AB8dd8BAa6ddf0D0c241d31b2e30bcEC127d, 21573657481017931484432));
    payouts.push(Payout(0x1c25cDD83Cd7106C3dcB361230eC9E6930Aadd30, 14188368728356337446426));
    payouts.push(Payout(0xf1B78ed53fa2f9B8cFfa677Ad8023aCa92109d08, 13831474058511281838532));
    payouts.push(Payout(0xd27962455de27561e62345a516931F2392997263, 6968208393315527988941));
    payouts.push(Payout(0xD8A4411C623aD361E98bC9D98cA33eE1cF308Bca, 4476771187861728227997));
    payouts.push(Payout(0x1f06fA59809ee23Ee06e533D67D29C6564fC1964, 3358338614042115121460));
    payouts.push(Payout(0xeDccc1501e3BCC8b3973B9BE33f6Bd7072d28388, 2328788070517256560738));
    payouts.push(Payout(0xD738A884B2aFE625d372260E57e86E3eB4d5e1D7, 466769668474372743140));
    payouts.push(Payout(0x6942b1b6526Fa05035d47c09B419039c00Ef7545, 442736084997163005698));
  }

  function airdrop() public onlyManager {
    MIMO mimo = MIMO(address(ga.mimo()));
    for (uint256 i = 0; i < payouts.length; i++) {
      Payout memory payout = payouts[i];
      mimo.mint(payout.recipient, payout.amount);
    }
    require(mimoDistributor.mintableTokens() > 0);

    bytes32 MIMO_MINTER_ROLE = mimo.MIMO_MINTER_ROLE();
    ga.controller().renounceRole(MIMO_MINTER_ROLE, address(this));
  }
}