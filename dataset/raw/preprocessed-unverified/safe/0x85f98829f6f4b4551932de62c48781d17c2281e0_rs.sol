/**
 *Submitted for verification at Etherscan.io on 2020-11-09
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

/**
 * @dev Collection of functions related to the address type
 */


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

/**
 * @title SafeERC20
 * @dev Wrappers around ERC20 operations that throw on failure (when the token
 * contract returns false). Tokens that return no value (and instead revert or
 * throw on failure) are also supported, non-reverting calls are assumed to be
 * successful.
 * To use this library you can add a `using SafeERC20 for IERC20;` statement to your contract,
 * which allows you to call the safe operations as `token.safeTransfer(...)`, etc.
 */






// 0: DAI, 1: USDC, 2: USDT


// 0: DAI, 1: USDC, 2: USDT, 3: BUSD


// 0: hUSD, 1: 3Crv


// 0: DAI, 1: USDC, 2: USDT, 3: sUSD


// 0: DAI, 1: USDC






// Supported Pool Tokens:
// 0. 3pool [DAI, USDC, USDT]
// 1. BUSD [(y)DAI, (y)USDC, (y)USDT, (y)BUSD]
// 2. sUSD [DAI, USDC, USDT, sUSD]
// 3. husd [HUSD, 3pool]
// 4. Compound [(c)DAI, (c)USDC]
// 5. Y [(y)DAI, (y)USDC, (y)USDT, (y)TUSD]
// 6. Swerve [(y)DAI...(y)TUSD]
contract StableSwapCompoundConverter is IMultiVaultConverter {
    using SafeMath for uint;
    using SafeERC20 for IERC20;

    IERC20[2] public cpoolTokens; // DAI, USDC

    CTokenInterface[2] public cpoolCTokens;

    IERC20 public tokenUSDT;

    IERC20 public tokenBUSD; // BUSD

    IERC20 public token3Crv; // 3Crv

    IERC20 public tokenSUSD; // sUSD

    IERC20 public tokenHUSD; // hUSD

    IERC20 public tokenCCrv; // cDAI+cUSDC ((c)DAI+(c)USDC)

    address public governance;

    IStableSwap3Pool public stableSwap3Pool;
    IStableSwapBUSD public stableSwapBUSD;
    IStableSwapSUSD public stableSwapSUSD;
    IStableSwapHUSD public stableSwapHUSD;
    IStableSwapCompound public stableSwapCompound;

    IDepositCompound public depositCompound;

    IValueVaultMaster public vaultMaster;

    uint public defaultSlippage = 1; // very small 0.01%

    // stableSwapUSD: 0. stableSwap3Pool, 1. stableSwapBUSD, 2. stableSwapSUSD, 3. stableSwapHUSD, 4. stableSwapCompound
    constructor (IERC20 _tokenDAI, IERC20 _tokenUSDC, IERC20 _tokenUSDT, IERC20 _token3Crv,
        IERC20 _tokenBUSD, IERC20 _tokenSUSD, IERC20 _tokenHUSD,
        IERC20 _tokenCCrv, CTokenInterface _tokenCDAI, CTokenInterface _tokenCUSDC,
        address[] memory _stableSwapUSD,
        IDepositCompound _depositCompound,
        IValueVaultMaster _vaultMaster) public {
        cpoolTokens[0] = _tokenDAI;
        cpoolTokens[1] = _tokenUSDC;
        tokenUSDT = _tokenUSDT;
        tokenBUSD = _tokenBUSD;
        token3Crv = _token3Crv;
        tokenSUSD = _tokenSUSD;
        tokenHUSD = _tokenHUSD;
        tokenCCrv = _tokenCCrv;

        cpoolCTokens[0] = _tokenCDAI;
        cpoolCTokens[1] = _tokenCUSDC;

        stableSwap3Pool = IStableSwap3Pool(_stableSwapUSD[0]);
        stableSwapBUSD = IStableSwapBUSD(_stableSwapUSD[1]);
        stableSwapSUSD = IStableSwapSUSD(_stableSwapUSD[2]);
        stableSwapHUSD = IStableSwapHUSD(_stableSwapUSD[3]);
        stableSwapCompound = IStableSwapCompound(_stableSwapUSD[4]);

        depositCompound = _depositCompound;

        cpoolTokens[0].safeApprove(address(stableSwap3Pool), type(uint256).max);
        cpoolTokens[1].safeApprove(address(stableSwap3Pool), type(uint256).max);
        tokenUSDT.safeApprove(address(stableSwap3Pool), type(uint256).max);
        token3Crv.safeApprove(address(stableSwap3Pool), type(uint256).max);

        cpoolTokens[0].safeApprove(address(stableSwapBUSD), type(uint256).max);
        cpoolTokens[1].safeApprove(address(stableSwapBUSD), type(uint256).max);
        tokenUSDT.safeApprove(address(stableSwapBUSD), type(uint256).max);
        tokenBUSD.safeApprove(address(stableSwapBUSD), type(uint256).max);

        cpoolTokens[0].safeApprove(address(stableSwapSUSD), type(uint256).max);
        cpoolTokens[1].safeApprove(address(stableSwapSUSD), type(uint256).max);
        tokenUSDT.safeApprove(address(stableSwapSUSD), type(uint256).max);
        tokenSUSD.safeApprove(address(stableSwapSUSD), type(uint256).max);

        token3Crv.safeApprove(address(stableSwapHUSD), type(uint256).max);
        tokenHUSD.safeApprove(address(stableSwapHUSD), type(uint256).max);

        cpoolTokens[0].safeApprove(address(stableSwapCompound), type(uint256).max);
        cpoolTokens[1].safeApprove(address(stableSwapCompound), type(uint256).max);
        tokenCCrv.safeApprove(address(stableSwapCompound), type(uint256).max);

        cpoolTokens[0].safeApprove(address(depositCompound), type(uint256).max);
        cpoolTokens[1].safeApprove(address(depositCompound), type(uint256).max);
        tokenCCrv.safeApprove(address(depositCompound), type(uint256).max);

        vaultMaster = _vaultMaster;
        governance = msg.sender;
    }

    function setGovernance(address _governance) public {
        require(msg.sender == governance, "!governance");
        governance = _governance;
    }

    function setVaultMaster(IValueVaultMaster _vaultMaster) external {
        require(msg.sender == governance, "!governance");
        vaultMaster = _vaultMaster;
    }

    function approveForSpender(IERC20 _token, address _spender, uint _amount) external {
        require(msg.sender == governance, "!governance");
        _token.safeApprove(_spender, _amount);
    }

    function setDefaultSlippage(uint _defaultSlippage) external {
        require(msg.sender == governance, "!governance");
        require(_defaultSlippage <= 100, "_defaultSlippage>1%");
        defaultSlippage = _defaultSlippage;
    }

    function token() external override returns (address) {
        return address(tokenCCrv);
    }

    // Average dollar value of pool token
    function get_virtual_price() external override view returns (uint) {
        return stableSwapCompound.get_virtual_price();
    }

    function convert_rate(address _input, address _output, uint _inputAmount) public override view returns (uint _outputAmount) {
        if (_inputAmount == 0) return 0;
        if (_output == address(tokenCCrv)) { // convert to CCrv
            uint[2] memory _amounts;
            for (uint8 i = 0; i < 2; i++) {
                if (_input == address(cpoolTokens[i])) {
                    _amounts[i] = _convert_underlying_to_ctoken(cpoolCTokens[i], _inputAmount);
                    _outputAmount = stableSwapCompound.calc_token_amount(_amounts, true);
                    return _outputAmount.mul(10000 - defaultSlippage).div(10000);
                }
            }
            if (_input == address(tokenUSDT)) {
                uint _dai = stableSwap3Pool.get_dy(int128(2), int128(0), _inputAmount); // convert to DAI
                _amounts[0] = _convert_underlying_to_ctoken(cpoolCTokens[0], _dai); // DAI -> cDAI
                _outputAmount = stableSwapCompound.calc_token_amount(_amounts, true); // cDAI -> CCrv
            }
            if (_input == address(tokenBUSD)) {
                uint _dai = stableSwapBUSD.get_dy_underlying(int128(3), int128(0), _inputAmount); // convert to DAI
                _amounts[0] = _convert_underlying_to_ctoken(cpoolCTokens[0], _dai); // DAI -> cDAI
                _outputAmount = stableSwapCompound.calc_token_amount(_amounts, true); // cDAI -> CCrv
            }
            if (_input == address(tokenSUSD)) {
                uint _dai = stableSwapSUSD.get_dy_underlying(int128(3), int128(0), _inputAmount); // convert to DAI
                _amounts[0] = _convert_underlying_to_ctoken(cpoolCTokens[0], _dai); // DAI -> cDAI
                _outputAmount = stableSwapCompound.calc_token_amount(_amounts, true); // cDAI -> CCrv
            }
            if (_input == address(tokenHUSD)) {
                uint _3crvAmount = stableSwapHUSD.get_dy(int128(0), int128(1), _inputAmount); // HUSD -> 3Crv
                uint _dai = stableSwap3Pool.calc_withdraw_one_coin(_3crvAmount, 0); // 3Crv -> DAI
                _amounts[0] = _convert_underlying_to_ctoken(cpoolCTokens[0], _dai); // DAI -> cDAI
                _outputAmount = stableSwapCompound.calc_token_amount(_amounts, true); // cDAI -> CCrv
            }
            if (_input == address(token3Crv)) {
                uint _dai = stableSwap3Pool.calc_withdraw_one_coin(_inputAmount, 0); // 3Crv -> DAI
                _amounts[0] = _convert_underlying_to_ctoken(cpoolCTokens[0], _dai); // DAI -> cDAI
                _outputAmount = stableSwapCompound.calc_token_amount(_amounts, true); // cDAI -> CCrv
            }
        } else if (_input == address(tokenCCrv)) { // convert from CCrv
            for (uint8 i = 0; i < 2; i++) {
                if (_output == address(cpoolTokens[i])) {
                    _outputAmount = depositCompound.calc_withdraw_one_coin(_inputAmount, i);
                    return _outputAmount.mul(10000 - defaultSlippage).div(10000);
                }
            }
            if (_output == address(tokenUSDT)) {
                uint _daiAmount = depositCompound.calc_withdraw_one_coin(_inputAmount, 0); // convert to DAI
                _outputAmount = stableSwap3Pool.get_dy(int128(0), int128(2), _daiAmount); // DAI -> USDT
            }
            if (_output == address(tokenBUSD)) {
                uint _daiAmount = depositCompound.calc_withdraw_one_coin(_inputAmount, 0); // convert to DAI
                _outputAmount = stableSwapBUSD.get_dy_underlying(int128(0), int128(3), _daiAmount); // DAI -> BUSD
            }
            if (_output == address(tokenSUSD)) {
                uint _daiAmount = depositCompound.calc_withdraw_one_coin(_inputAmount, 0); // CCrv -> DAI
                _outputAmount = stableSwapSUSD.get_dy_underlying(int128(0), int128(3), _daiAmount); // DAI -> SUSD
            }
            if (_output == address(tokenHUSD)) {
                uint _3crvAmount = _convert_ccrv_to_3crv_rate(_inputAmount); // CCrv -> DAI -> 3Crv
                _outputAmount = stableSwapHUSD.get_dy(int128(1), int128(0), _3crvAmount); // 3Crv -> HUSD
            }
        }
        if (_outputAmount > 0) {
            uint _slippage = _outputAmount.mul(vaultMaster.convertSlippage(_input, _output)).div(10000);
            _outputAmount = _outputAmount.sub(_slippage);
        }
    }

    function _convert_ccrv_to_3crv_rate(uint _ccrvAmount) internal view returns (uint _3crv) {
        uint[3] memory _amounts;
        _amounts[0] = depositCompound.calc_withdraw_one_coin(_ccrvAmount, 0); // CCrv -> DAI
        _3crv = stableSwap3Pool.calc_token_amount(_amounts, true); // DAI -> 3Crv
    }

    // 0: DAI, 1: USDC, 2: USDT, 3: 3Crv, 4: BUSD, 5: sUSD, 6: husd
    function calc_token_amount_deposit(uint[] calldata _amounts) external override view returns (uint _shareAmount) {
        if (_amounts[0] > 0 || _amounts[1] > 0) {
            uint[2] memory _cpoolAmounts;
            _cpoolAmounts[0] = _convert_underlying_to_ctoken(cpoolCTokens[0], _amounts[0]);
            _cpoolAmounts[1] = _convert_underlying_to_ctoken(cpoolCTokens[1], _amounts[1]);
            _shareAmount = stableSwapCompound.calc_token_amount(_cpoolAmounts, true);
        }
        if (_amounts[2] > 0) { // usdt
            _shareAmount = _shareAmount.add(convert_rate(address(tokenUSDT), address(tokenCCrv), _amounts[2]));
        }
        if (_amounts[3] > 0) { // 3crv
            _shareAmount = _shareAmount.add(convert_rate(address(token3Crv), address(tokenCCrv), _amounts[3]));
        }
        if (_amounts[4] > 0) { // busd
            _shareAmount = _shareAmount.add(convert_rate(address(tokenBUSD), address(tokenCCrv), _amounts[4]));
        }
        if (_amounts[5] > 0) { // susd
            _shareAmount = _shareAmount.add(convert_rate(address(tokenSUSD), address(tokenCCrv), _amounts[5]));
        }
        if (_amounts[6] > 0) { // husd
            _shareAmount = _shareAmount.add(convert_rate(address(tokenHUSD), address(tokenCCrv), _amounts[6]));
        }
        return _shareAmount;
    }

    function calc_token_amount_withdraw(uint _shares, address _output) external override view returns (uint _outputAmount) {
        for (uint8 i = 0; i < 2; i++) {
            if (_output == address(cpoolTokens[i])) {
                _outputAmount = depositCompound.calc_withdraw_one_coin(_shares, i);
                return _outputAmount.mul(10000 - defaultSlippage).div(10000);
            }
        }
        if (_output == address(token3Crv)) {
            _outputAmount = _convert_ccrv_to_3crv_rate(_shares); // CCrv -> DAI -> 3Crv
        } else if (_output == address(tokenUSDT)) {
            uint _daiAmount = depositCompound.calc_withdraw_one_coin(_shares, 0); // CCrv -> DAI
            _outputAmount = stableSwap3Pool.get_dy(int128(0), int128(2), _daiAmount); // DAI -> USDT
        } else if (_output == address(tokenBUSD)) {
            uint _daiAmount = depositCompound.calc_withdraw_one_coin(_shares, 0); // CCrv -> DAI
            _outputAmount = stableSwapBUSD.get_dy_underlying(int128(0), int128(3), _daiAmount); // DAI -> BUSD
        } else if (_output == address(tokenSUSD)) {
            uint _daiAmount = depositCompound.calc_withdraw_one_coin(_shares, 0); // CCrv -> DAI
            _outputAmount = stableSwapSUSD.get_dy_underlying(int128(0), int128(3), _daiAmount); // DAI -> SUSD
        } else if (_output == address(tokenHUSD)) {
            uint _3crvAmount = _convert_ccrv_to_3crv_rate(_shares); // CCrv -> DAI -> 3Crv
            _outputAmount = stableSwapHUSD.get_dy(int128(1), int128(0), _3crvAmount); // 3Crv -> HUSD
        }
        if (_outputAmount > 0) {
            uint _slippage = _outputAmount.mul(vaultMaster.slippage(_output)).div(10000);
            _outputAmount = _outputAmount.sub(_slippage);
        }
    }

    function convert(address _input, address _output, uint _inputAmount) external override returns (uint _outputAmount) {
        require(vaultMaster.isVault(msg.sender) || vaultMaster.isController(msg.sender) || msg.sender == governance, "!(governance||vault||controller)");
        if (_output == address(tokenCCrv)) { // convert to CCrv
            uint[2] memory amounts;
            for (uint8 i = 0; i < 2; i++) {
                if (_input == address(cpoolTokens[i])) {
                    amounts[i] = _inputAmount;
                    uint _before = tokenCCrv.balanceOf(address(this));
                    depositCompound.add_liquidity(amounts, 1);
                    uint _after = tokenCCrv.balanceOf(address(this));
                    _outputAmount = _after.sub(_before);
                    tokenCCrv.safeTransfer(msg.sender, _outputAmount);
                    return _outputAmount;
                }
            }
            if (_input == address(token3Crv)) {
                _outputAmount = _convert_3crv_to_shares(_inputAmount);
                tokenCCrv.safeTransfer(msg.sender, _outputAmount);
                return _outputAmount;
            }
            if (_input == address(tokenUSDT)) {
                _outputAmount = _convert_usdt_to_shares(_inputAmount);
                tokenCCrv.safeTransfer(msg.sender, _outputAmount);
                return _outputAmount;
            }
            if (_input == address(tokenBUSD)) {
                _outputAmount = _convert_busd_to_shares(_inputAmount);
                tokenCCrv.safeTransfer(msg.sender, _outputAmount);
                return _outputAmount;
            }
            if (_input == address(tokenSUSD)) {
                _outputAmount = _convert_susd_to_shares(_inputAmount);
                tokenCCrv.safeTransfer(msg.sender, _outputAmount);
                return _outputAmount;
            }
            if (_input == address(tokenHUSD)) {
                _outputAmount = _convert_husd_to_shares(_inputAmount);
                tokenCCrv.safeTransfer(msg.sender, _outputAmount);
                return _outputAmount;
            }
        } else if (_input == address(tokenCCrv)) { // convert from CCrv
            for (uint8 i = 0; i < 2; i++) {
                if (_output == address(cpoolTokens[i])) {
                    uint _before = cpoolTokens[i].balanceOf(address(this));
                    depositCompound.remove_liquidity_one_coin(_inputAmount, i, 1);
                    uint _after = cpoolTokens[i].balanceOf(address(this));
                    _outputAmount = _after.sub(_before);
                    cpoolTokens[i].safeTransfer(msg.sender, _outputAmount);
                    return _outputAmount;
                }
            }
            if (_output == address(token3Crv)) {
                // remove CCrv to DAI
                uint[3] memory amounts;
                uint _before = cpoolTokens[0].balanceOf(address(this));
                depositCompound.remove_liquidity_one_coin(_inputAmount, 0, 1);
                uint _after = cpoolTokens[0].balanceOf(address(this));
                amounts[0] = _after.sub(_before);

                // add DAI to 3pool to get back 3Crv
                _before = token3Crv.balanceOf(address(this));
                stableSwap3Pool.add_liquidity(amounts, 1);
                _after = token3Crv.balanceOf(address(this));
                _outputAmount = _after.sub(_before);

                token3Crv.safeTransfer(msg.sender, _outputAmount);
                return _outputAmount;
            }
            if (_output == address(tokenUSDT)) {
                // remove CCrv to DAI
                uint _before = cpoolTokens[0].balanceOf(address(this));
                depositCompound.remove_liquidity_one_coin(_inputAmount, 0, 1);
                uint _after = cpoolTokens[0].balanceOf(address(this));
                _outputAmount = _after.sub(_before);

                // convert DAI to USDT
                _before = tokenUSDT.balanceOf(address(this));
                stableSwap3Pool.exchange(int128(0), int128(2), _outputAmount, 1);
                _after = tokenUSDT.balanceOf(address(this));
                _outputAmount = _after.sub(_before);

                tokenUSDT.safeTransfer(msg.sender, _outputAmount);
                return _outputAmount;
            }
            if (_output == address(tokenBUSD)) {
                // remove CCrv to DAI
                uint _before = cpoolTokens[0].balanceOf(address(this));
                depositCompound.remove_liquidity_one_coin(_inputAmount, 0, 1);
                uint _after = cpoolTokens[0].balanceOf(address(this));
                _outputAmount = _after.sub(_before);

                // convert DAI to BUSD
                _before = tokenBUSD.balanceOf(address(this));
                stableSwapBUSD.exchange_underlying(int128(0), int128(3), _outputAmount, 1);
                _after = tokenBUSD.balanceOf(address(this));
                _outputAmount = _after.sub(_before);

                tokenBUSD.safeTransfer(msg.sender, _outputAmount);
                return _outputAmount;
            }
            if (_output == address(tokenSUSD)) {
                // remove CCrv to DAI
                uint _before = cpoolTokens[0].balanceOf(address(this));
                depositCompound.remove_liquidity_one_coin(_inputAmount, 0, 1);
                uint _after = cpoolTokens[0].balanceOf(address(this));
                _outputAmount = _after.sub(_before);

                // convert DAI to SUSD
                _before = tokenSUSD.balanceOf(address(this));
                stableSwapSUSD.exchange_underlying(int128(0), int128(3), _outputAmount, 1);
                _after = tokenSUSD.balanceOf(address(this));
                _outputAmount = _after.sub(_before);

                tokenSUSD.safeTransfer(msg.sender, _outputAmount);
                return _outputAmount;
            }
            if (_output == address(tokenHUSD)) {
                _outputAmount = _convert_shares_to_husd(_inputAmount);
                tokenHUSD.safeTransfer(msg.sender, _outputAmount);
                return _outputAmount;
            }
        }
        return 0;
    }

    function convertAll(uint[] calldata) external override returns (uint) {
        revert("Not implemented");
    }

    // @dev convert from USDC to cUSDC (via DAI)
    function _convert_underlying_to_ctoken(CTokenInterface ctoken, uint _amount) internal view returns (uint _outputAmount) {
        _outputAmount = _amount.mul(10 ** 18).div(ctoken.exchangeRateStored());
    }

    // @dev convert from 3Crv to CCrv (via DAI)
    function _convert_3crv_to_shares(uint _3crv) internal returns (uint _shares) {
        // convert to DAI
        uint[2] memory amounts;
        uint _before = cpoolTokens[0].balanceOf(address(this));
        stableSwap3Pool.remove_liquidity_one_coin(_3crv, 0, 1);
        uint _after = cpoolTokens[0].balanceOf(address(this));
        amounts[0] = _after.sub(_before);

        // add DAI to cpool to get back CCrv
        _before = tokenCCrv.balanceOf(address(this));
        depositCompound.add_liquidity(amounts, 1);
        _after = tokenCCrv.balanceOf(address(this));

        _shares = _after.sub(_before);
    }

    // @dev convert from USDT to CCrv (via DAI)
    function _convert_usdt_to_shares(uint _usdt) internal returns (uint _shares) {
        // convert to DAI
        uint[2] memory amounts;
        uint _before = cpoolTokens[0].balanceOf(address(this));
        stableSwap3Pool.exchange(2, 0, _usdt, 1);
        uint _after = cpoolTokens[0].balanceOf(address(this));
        amounts[0] = _after.sub(_before);

        // add DAI to cpool to get back CCrv
        _before = tokenCCrv.balanceOf(address(this));
        depositCompound.add_liquidity(amounts, 1);
        _after = tokenCCrv.balanceOf(address(this));

        _shares = _after.sub(_before);
    }

    // @dev convert from BUSD to CCrv (via DAI)
    function _convert_busd_to_shares(uint _busd) internal returns (uint _shares) {
        // convert to DAI
        uint[2] memory amounts;
        uint _before = cpoolTokens[0].balanceOf(address(this));
        stableSwapBUSD.exchange_underlying(3, 0, _busd, 1);
        uint _after = cpoolTokens[0].balanceOf(address(this));
        amounts[0] = _after.sub(_before);

        // add DAI to cpool to get back CCrv
        _before = tokenCCrv.balanceOf(address(this));
        depositCompound.add_liquidity(amounts, 1);
        _after = tokenCCrv.balanceOf(address(this));

        _shares = _after.sub(_before);
    }

    // @dev convert from SUSD to CCrv (via DAI)
    function _convert_susd_to_shares(uint _amount) internal returns (uint _shares) {
        // convert to DAI
        uint[2] memory amounts;
        uint _before = cpoolTokens[0].balanceOf(address(this));
        stableSwapSUSD.exchange_underlying(int128(3), int128(0), _amount, 1);
        uint _after = cpoolTokens[0].balanceOf(address(this));
        amounts[0] = _after.sub(_before);

        // add DAI to cpool to get back CCrv
        _before = tokenCCrv.balanceOf(address(this));
        depositCompound.add_liquidity(amounts, 1);
        _after = tokenCCrv.balanceOf(address(this));

        _shares = _after.sub(_before);
    }

    // @dev convert from HUSD to CCrv (HUSD -> 3Crv -> DAI -> CCrv)
    function _convert_husd_to_shares(uint _amount) internal returns (uint _shares) {
        // convert to 3Crv
        uint _before = token3Crv.balanceOf(address(this));
        stableSwapHUSD.exchange(int128(0), int128(1), _amount, 1);
        uint _after = token3Crv.balanceOf(address(this));
        _amount = _after.sub(_before);

        // convert 3Crv to DAI
        uint[2] memory amounts;
        _before = cpoolTokens[0].balanceOf(address(this));
        stableSwap3Pool.remove_liquidity_one_coin(_amount, 0, 1);
        _after = cpoolTokens[0].balanceOf(address(this));
        amounts[0] = _after.sub(_before);

        // add DAI to cpool to get back CCrv
        _before = tokenCCrv.balanceOf(address(this));
        depositCompound.add_liquidity(amounts, 1);
        _after = tokenCCrv.balanceOf(address(this));

        _shares = _after.sub(_before);
    }

    // @dev convert from CCrv to HUSD (CCrv -> DAI -> 3Crv -> HUSD)
    function _convert_shares_to_husd(uint _amount) internal returns (uint _husd) {
        // convert to DAI
        uint[3] memory amounts;
        uint _before = cpoolTokens[0].balanceOf(address(this));
        depositCompound.remove_liquidity_one_coin(_amount, 0, 1);
        uint _after = cpoolTokens[0].balanceOf(address(this));
        amounts[0] = _after.sub(_before);

        // add DAI to 3pool to get back 3Crv
        _before = token3Crv.balanceOf(address(this));
        stableSwap3Pool.add_liquidity(amounts, 1);
        _after = token3Crv.balanceOf(address(this));
        _amount = _after.sub(_before);

        // convert 3Crv to HUSD
        _before = tokenHUSD.balanceOf(address(this));
        stableSwapHUSD.exchange(int128(1), int128(0), _amount, 1);
        _after = tokenHUSD.balanceOf(address(this));
        _husd = _after.sub(_before);
    }

    function governanceRecoverUnsupported(IERC20 _token, uint _amount, address _to) external {
        require(msg.sender == governance, "!governance");
        _token.transfer(_to, _amount);
    }
}