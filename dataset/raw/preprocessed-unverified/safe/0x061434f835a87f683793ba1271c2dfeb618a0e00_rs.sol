/**
 *Submitted for verification at Etherscan.io on 2020-11-25
*/

// SPDX-License-Identifier: MIT

pragma solidity 0.6.12;

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
 * @dev Collection of functions related to the address type
 */


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

/**
 * @title SafeERC20
 * @dev Wrappers around ERC20 operations that throw on failure (when the token
 * contract returns false). Tokens that return no value (and instead revert or
 * throw on failure) are also supported, non-reverting calls are assumed to be
 * successful.
 * To use this library you can add a `using SafeERC20 for ERC20;` statement to your contract,
 * which allows you to call the safe operations as `token.safeTransfer(...)`, etc.
 */












abstract contract CompositeVaultBase is ERC20UpgradeSafe, ICompositeVault {
    using Address for address;
    using SafeMath for uint;
    using SafeERC20 for IERC20;

    IERC20 public basedToken;

    IERC20 public token0;
    IERC20 public token1;

    uint public min = 9500;
    uint public constant max = 10000;

    uint public earnLowerlimit = 1; // minimum to invest
    uint public depositLimit = 0; // limit for each deposit (set 0 to disable)
    uint private totalDepositCap = 0; // initial cap (set 0 to disable)

    address public governance;
    address public controller;

    IVaultMaster vaultMaster;
    ILpPairConverter public basedConverter; // converter for basedToken (SLP or BPT or UNI)

    mapping(address => address) public converterMap; // non-core token => converter

    bool public acceptContractDepositor = false;
    mapping(address => bool) public whitelistedContract;
    bool private _mutex;

    // variable used for avoid the call of mint and redeem in the same tx
    bytes32 private _minterBlock;

    uint public totalPendingCompound;
    uint public startReleasingCompoundBlk;
    uint public endReleasingCompoundBlk;

    function initialize(IERC20 _basedToken, IERC20 _token0, IERC20 _token1, IVaultMaster _vaultMaster) public initializer {
        __ERC20_init(_getName(), _getSymbol());
        basedToken = _basedToken;
        token0 = _token0;
        token1 = _token1;
        vaultMaster = _vaultMaster;
        governance = msg.sender;
    }

    function _getName() internal virtual view returns (string memory);

    function _getSymbol() internal virtual view returns (string memory);

    /**
     * @dev Throws if called by a not-whitelisted contract while we do not accept contract depositor.
     */
    modifier checkContract(address _account) {
        if (!acceptContractDepositor && !whitelistedContract[_account] && (_account != vaultMaster.bank(address(this)))) {
            require(!address(_account).isContract() && _account == tx.origin, "contract not support");
        }
        _;
    }

    modifier _non_reentrant_() {
        require(!_mutex, "reentry");
        _mutex = true;
        _;
        _mutex = false;
    }

    function setAcceptContractDepositor(bool _acceptContractDepositor) external {
        require(msg.sender == governance, "!governance");
        acceptContractDepositor = _acceptContractDepositor;
    }

    function whitelistContract(address _contract) external {
        require(msg.sender == governance, "!governance");
        whitelistedContract[_contract] = true;
    }

    function unwhitelistContract(address _contract) external {
        require(msg.sender == governance, "!governance");
        whitelistedContract[_contract] = false;
    }

    function cap() external override view returns (uint) {
        return totalDepositCap;
    }

    function getConverter() external override view returns (address) {
        return address(basedConverter);
    }

    function getVaultMaster() external override view returns (address) {
        return address(vaultMaster);
    }

    function accept(address _input) external override view returns (bool) {
        return basedConverter.accept(_input);
    }

    function addNewCompound(uint _newCompound, uint _blocksToReleaseCompound) external override {
        require(msg.sender == governance || vaultMaster.isStrategy(msg.sender), "!authorized");
        if (_blocksToReleaseCompound == 0) {
            totalPendingCompound = 0;
            startReleasingCompoundBlk = 0;
            endReleasingCompoundBlk = 0;
        } else {
            totalPendingCompound = pendingCompound().add(_newCompound);
            startReleasingCompoundBlk = block.number;
            endReleasingCompoundBlk = block.number.add(_blocksToReleaseCompound);
        }
    }

    function pendingCompound() public view returns (uint) {
        if (totalPendingCompound == 0 || endReleasingCompoundBlk <= block.number) return 0;
        return totalPendingCompound.mul(endReleasingCompoundBlk.sub(block.number)).div(endReleasingCompoundBlk.sub(startReleasingCompoundBlk).add(1));
    }

    function balance() public override view returns (uint _balance) {
        _balance = basedToken.balanceOf(address(this)).add(IController(controller).balanceOf()).sub(pendingCompound());
    }

    function tvl() public override view returns (uint) {
        return balance().mul(basedConverter.get_virtual_price()).div(1e18);
    }

    function setMin(uint _min) external {
        require(msg.sender == governance, "!governance");
        min = _min;
    }

    function setGovernance(address _governance) external {
        require(msg.sender == governance, "!governance");
        governance = _governance;
    }

    function setController(address _controller) external {
        require(msg.sender == governance, "!governance");
        require(IController(_controller).want() == address(basedToken), "!token");
        controller = _controller;
    }

    function setConverter(ILpPairConverter _converter) external {
        require(msg.sender == governance, "!governance");
        require(_converter.lpPair() == address(basedToken), "!token");
        basedConverter = _converter;
    }

    function setConverterMap(address _token, address _converter) external {
        require(msg.sender == governance, "!governance");
        converterMap[_token] = _converter;
    }

    function setVaultMaster(IVaultMaster _vaultMaster) external {
        require(msg.sender == governance, "!governance");
        vaultMaster = _vaultMaster;
    }

    function setEarnLowerlimit(uint _earnLowerlimit) external {
        require(msg.sender == governance, "!governance");
        earnLowerlimit = _earnLowerlimit;
    }

    function setCap(uint _cap) external {
        require(msg.sender == governance, "!governance");
        totalDepositCap = _cap;
    }

    function setDepositLimit(uint _limit) external {
        require(msg.sender == governance, "!governance");
        depositLimit = _limit;
    }

    function token() public override view returns (address) {
        return address(basedToken);
    }

    // Custom logic in here for how much the vault allows to be borrowed
    // Sets minimum required on-hand to keep small withdrawals cheap
    function available() public override view returns (uint) {
        return basedToken.balanceOf(address(this)).mul(min).div(max);
    }

    function earn() public override {
        if (controller != address(0)) {
            IController _contrl = IController(controller);
            if (!_contrl.investDisabled()) {
                uint _bal = available();
                if (_bal >= earnLowerlimit) {
                    basedToken.safeTransfer(controller, _bal);
                    _contrl.earn(address(basedToken), _bal);
                }
            }
        }
    }

    // Only allows to earn some extra yield from non-core tokens
    function earnExtra(address _token) external {
        require(msg.sender == governance, "!governance");
        require(converterMap[_token] != address(0), "!converter");
        require(address(_token) != address(basedToken), "token");
        require(address(_token) != address(this), "share");
        uint _amount = IERC20(_token).balanceOf(address(this));
        address _converter = converterMap[_token];
        IERC20(_token).safeTransfer(_converter, _amount);
        Converter(_converter).convert(_token);
    }

    function withdraw_fee(uint _shares) public override view returns (uint) {
        return (controller == address(0)) ? 0 : IController(controller).withdraw_fee(_shares);
    }

    function calc_token_amount_deposit(address _input, uint _amount) external override view returns (uint) {
        return basedConverter.convert_rate(_input, address(basedToken), _amount).mul(1e18).div(getPricePerFullShare());
    }

    function calc_add_liquidity(uint _amount0, uint _amount1) external override view returns (uint) {
        return basedConverter.calc_add_liquidity(_amount0, _amount1).mul(1e18).div(getPricePerFullShare());
    }

    function _calc_shares_to_amount_withdraw(uint _shares) internal view returns (uint) {
        uint _withdrawFee = withdraw_fee(_shares);
        if (_withdrawFee > 0) {
            _shares = _shares.sub(_withdrawFee);
        }
        uint _totalSupply = totalSupply();
        return (_totalSupply == 0) ? _shares : (balance().mul(_shares)).div(_totalSupply);
    }

    function calc_token_amount_withdraw(uint _shares, address _output) external override view returns (uint) {
        uint r = _calc_shares_to_amount_withdraw(_shares);
        if (_output != address(basedToken)) {
            r = basedConverter.convert_rate(address(basedToken), _output, r);
        }
        return r.mul(getPricePerFullShare()).div((1e18));
    }

    function calc_remove_liquidity(uint _shares) external override view returns (uint _amount0, uint _amount1) {
        uint r = _calc_shares_to_amount_withdraw(_shares);
        (_amount0, _amount1) = basedConverter.calc_remove_liquidity(r);
        uint _getPricePerFullShare = getPricePerFullShare();
        _amount0 = _amount0.mul(_getPricePerFullShare).div((1e18));
        _amount1 = _amount1.mul(_getPricePerFullShare).div((1e18));
    }

    function deposit(address _input, uint _amount, uint _min_mint_amount) external override returns (uint) {
        return depositFor(msg.sender, msg.sender, _input, _amount, _min_mint_amount);
    }

    function depositFor(address _account, address _to, address _input, uint _amount, uint _min_mint_amount) public override checkContract(_account) _non_reentrant_ returns (uint _mint_amount) {
        uint _pool = balance();
        require(totalDepositCap == 0 || _pool <= totalDepositCap, ">totalDepositCap");
        uint _before = basedToken.balanceOf(address(this));
        if (_input == address(basedToken)) {
            basedToken.safeTransferFrom(_account, address(this), _amount);
        } else {
            // require(basedConverter.convert_rate(_input, address(basedToken), _amount) > 0, "rate=0");
            uint _before0 = token0.balanceOf(address(this));
            uint _before1 = token1.balanceOf(address(this));
            IERC20(_input).safeTransferFrom(_account, address(basedConverter), _amount);
            basedConverter.convert(_input, address(basedToken), address(this));
            uint _after0 = token0.balanceOf(address(this));
            uint _after1 = token1.balanceOf(address(this));
            if (_after0 > _before0) {
                token0.safeTransfer(_account, _after0.sub(_before0));
            }
            if (_after1 > _before1) {
                token1.safeTransfer(_account, _after1.sub(_before1));
            }
        }
        uint _after = basedToken.balanceOf(address(this));
        _amount = _after.sub(_before); // additional check for deflationary tokens
        require(depositLimit == 0 || _amount <= depositLimit, ">depositLimit");
        require(_amount > 0, "no token");
        _mint_amount = _deposit(_to, _pool, _amount);
        require(_mint_amount >= _min_mint_amount, "slippage");
    }

    function addLiquidity(uint _amount0, uint _amount1, uint _min_mint_amount) external override returns (uint) {
        return addLiquidityFor(msg.sender, msg.sender, _amount0, _amount1, _min_mint_amount);
    }

    function addLiquidityFor(address _account, address _to, uint _amount0, uint _amount1, uint _min_mint_amount) public override checkContract(_account) _non_reentrant_ returns (uint _mint_amount) {
        require(msg.sender == _account || msg.sender == vaultMaster.bank(address(this)), "!bank && !yourself");
        uint _pool = balance();
        require(totalDepositCap == 0 || _pool <= totalDepositCap, ">totalDepositCap");
        uint _beforeToken = basedToken.balanceOf(address(this));
        uint _before0 = token0.balanceOf(address(this));
        uint _before1 = token1.balanceOf(address(this));
        token0.safeTransferFrom(_account, address(basedConverter), _amount0);
        token1.safeTransferFrom(_account, address(basedConverter), _amount1);
        basedConverter.add_liquidity(address(this));
        uint _afterToken = basedToken.balanceOf(address(this));
        uint _after0 = token0.balanceOf(address(this));
        uint _after1 = token1.balanceOf(address(this));
        uint _totalDepositAmount = _afterToken.sub(_beforeToken); // additional check for deflationary tokens
        require(depositLimit == 0 || _totalDepositAmount <= depositLimit, ">depositLimit");
        require(_totalDepositAmount > 0, "no token");
        if (_after0 > _before0) {
            token0.safeTransfer(_account, _after0.sub(_before0));
        }
        if (_after1 > _before1) {
            token1.safeTransfer(_account, _after1.sub(_before1));
        }
        _mint_amount = _deposit(_to, _pool, _totalDepositAmount);
        require(_mint_amount >= _min_mint_amount, "slippage");
    }

    function _deposit(address _mintTo, uint _pool, uint _amount) internal returns (uint _shares) {
        if (totalSupply() == 0) {
            _shares = _amount;
        } else {
            _shares = (_amount.mul(totalSupply())).div(_pool);
        }

        if (_shares > 0) {
            earn();

            _minterBlock = keccak256(abi.encodePacked(tx.origin, block.number));
            _mint(_mintTo, _shares);
        }
    }

    // Used to swap any borrowed reserve over the debt limit to liquidate to 'token'
    function harvest(address reserve, uint amount) external override {
        require(msg.sender == controller, "!controller");
        require(reserve != address(basedToken), "basedToken");
        IERC20(reserve).safeTransfer(controller, amount);
    }

    function harvestStrategy(address _strategy) external override {
        require(msg.sender == governance || msg.sender == vaultMaster.bank(address(this)), "!governance && !bank");
        IController(controller).harvestStrategy(_strategy);
    }

    function harvestAllStrategies() external override {
        require(msg.sender == governance || msg.sender == vaultMaster.bank(address(this)), "!governance && !bank");
        IController(controller).harvestAllStrategies();
    }

    function withdraw(uint _shares, address _output, uint _min_output_amount) external override returns (uint) {
        return withdrawFor(msg.sender, _shares, _output, _min_output_amount);
    }

    // No rebalance implementation for lower fees and faster swaps
    function withdrawFor(address _account, uint _shares, address _output, uint _min_output_amount) public override _non_reentrant_ returns (uint _output_amount) {
        // Check that no mint has been made in the same block from the same EOA
        require(keccak256(abi.encodePacked(tx.origin, block.number)) != _minterBlock, "REENTR MINT-BURN");

        _output_amount = (balance().mul(_shares)).div(totalSupply());
        _burn(msg.sender, _shares);

        uint _withdrawalProtectionFee = vaultMaster.withdrawalProtectionFee();
        if (_withdrawalProtectionFee > 0) {
            uint _withdrawalProtection = _output_amount.mul(_withdrawalProtectionFee).div(10000);
            _output_amount = _output_amount.sub(_withdrawalProtection);
        }

        // Check balance
        uint b = basedToken.balanceOf(address(this));
        if (b < _output_amount) {
            uint _toWithdraw = _output_amount.sub(b);
            uint _withdrawFee = IController(controller).withdraw(_toWithdraw);
            uint _after = basedToken.balanceOf(address(this));
            uint _diff = _after.sub(b);
            if (_diff < _toWithdraw) {
                _output_amount = b.add(_diff);
            }
            if (_withdrawFee > 0) {
                _output_amount = _output_amount.sub(_withdrawFee, "_output_amount < _withdrawFee");
            }
        }

        if (_output == address(basedToken)) {
            require(_output_amount >= _min_output_amount, "slippage");
            basedToken.safeTransfer(_account, _output_amount);
        } else {
            basedToken.safeTransfer(address(basedConverter), _output_amount);
            uint _received = basedConverter.convert(address(basedToken), _output, msg.sender);
            require(_received >= _min_output_amount, "slippage");
            IERC20(_output).safeTransfer(_account, _received);
        }
    }

    function getPricePerFullShare() public override view returns (uint) {
        return (totalSupply() == 0) ? 1e18 : balance().mul(1e18).div(totalSupply());
    }

    // @dev average dollar value of vault share token
    function get_virtual_price() external override view returns (uint) {
        return basedConverter.get_virtual_price().mul(getPricePerFullShare()).div(1e18);
    }

    /**
     * This function allows governance to take unsupported tokens out of the contract. This is in an effort to make someone whole, should they seriously mess up.
     * There is no guarantee governance will vote to return these. It also allows for removal of airdropped tokens.
     */
    function governanceRecoverUnsupported(IERC20 _token, uint amount, address to) external {
        require(msg.sender == governance, "!governance");
        require(address(_token) != address(basedToken), "token");
        require(address(_token) != address(this), "share");
        _token.safeTransfer(to, amount);
    }
}

contract CompositeVaultSlpEthUsdc is CompositeVaultBase {
    function _getName() internal override view returns (string memory) {
        return "CompositeVault:SlpEthUsdc";
    }

    function _getSymbol() internal override view returns (string memory) {
        return "cvETH-USDC:SLP";
    }
}