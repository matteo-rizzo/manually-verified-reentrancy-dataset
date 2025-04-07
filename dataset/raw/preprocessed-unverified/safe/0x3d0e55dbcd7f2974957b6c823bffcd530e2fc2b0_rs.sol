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




// Supported Pool Tokens:
// 0. 3pool [DAI, USDC, USDT]
// 1. BUSD [(y)DAI, (y)USDC, (y)USDT, (y)BUSD]
// 2. sUSD [DAI, USDC, USDT, sUSD]
// 3. husd [HUSD, 3pool]
// 4. Compound [(c)DAI, (c)USDC]
// 5. Y [(y)DAI, (y)USDC, (y)USDT, (y)TUSD]
// 6. Swerve [(y)DAI...(y)TUSD]
contract StableSwapBusdConverter is IMultiVaultConverter {
    using SafeMath for uint;
    using SafeERC20 for IERC20;

    IERC20[4] public bpoolTokens; // DAI, USDC, USDT, BUSD

    IERC20 public tokenBUSD; // BUSD
    IERC20 public tokenBCrv; // BCrv (yDAI+yUSDC+yUSDT+yBUSD)

    IERC20 public token3Crv; // 3Crv

    IERC20 public tokenSUSD; // sUSD
    IERC20 public tokenSCrv; // sCrv (DAI/USDC/USDT/sUSD)

    IERC20 public tokenHUSD; // hUSD
    IERC20 public tokenHCrv; // hCrv (HUSD/3Crv)

    address public governance;

    IStableSwap3Pool public stableSwap3Pool;
    IDepositBUSD public depositBUSD;
    IStableSwapBUSD public stableSwapBUSD;

    IStableSwapSUSD public stableSwapSUSD;

    IStableSwapHUSD public stableSwapHUSD;

    yTokenInterface[4] poolBUSDyTokens;

    IValueVaultMaster public vaultMaster;

    uint public defaultSlippage = 1; // very small 0.01%

    // tokens: 0. BUSD, 1. sUSD, 2. hUSD
    // tokenCrvs: 0. BCrv, 1. SCrv, 2. HCrv
    // stableSwapUSD: 0. stableSwapBUSD, 1. stableSwapSUSD, 2. stableSwapHUSD
    constructor (IERC20 _tokenDAI, IERC20 _tokenUSDC, IERC20 _tokenUSDT, IERC20 _token3Crv,
        IERC20[] memory _tokens, IERC20[] memory _tokenCrvs,
        address[] memory _stableSwapUSD,
        IStableSwap3Pool _stableSwap3Pool,
        IDepositBUSD _depositBUSD,
        yTokenInterface[4] memory _yTokens,
        IValueVaultMaster _vaultMaster) public {
        bpoolTokens[0] = _tokenDAI;
        bpoolTokens[1] = _tokenUSDC;
        bpoolTokens[2] = _tokenUSDT;
        bpoolTokens[3] = _tokens[0];
        token3Crv = _token3Crv;
        tokenBCrv = _tokenCrvs[0];
        tokenSUSD = _tokens[1];
        tokenSCrv = _tokenCrvs[1];
        tokenHUSD = _tokens[2];
        tokenHCrv = _tokenCrvs[2];
        stableSwap3Pool = _stableSwap3Pool;
        stableSwapBUSD = IStableSwapBUSD(_stableSwapUSD[0]);
        stableSwapSUSD = IStableSwapSUSD(_stableSwapUSD[1]);
        stableSwapHUSD = IStableSwapHUSD(_stableSwapUSD[2]);
        depositBUSD = _depositBUSD;
        poolBUSDyTokens = _yTokens;

        bpoolTokens[0].safeApprove(address(stableSwap3Pool), type(uint256).max);
        bpoolTokens[1].safeApprove(address(stableSwap3Pool), type(uint256).max);
        bpoolTokens[2].safeApprove(address(stableSwap3Pool), type(uint256).max);
        token3Crv.safeApprove(address(stableSwap3Pool), type(uint256).max);

        bpoolTokens[0].safeApprove(address(stableSwapBUSD), type(uint256).max);
        bpoolTokens[1].safeApprove(address(stableSwapBUSD), type(uint256).max);
        bpoolTokens[2].safeApprove(address(stableSwapBUSD), type(uint256).max);
        bpoolTokens[3].safeApprove(address(stableSwapBUSD), type(uint256).max);
        tokenBCrv.safeApprove(address(stableSwapBUSD), type(uint256).max);

        bpoolTokens[0].safeApprove(address(depositBUSD), type(uint256).max);
        bpoolTokens[1].safeApprove(address(depositBUSD), type(uint256).max);
        bpoolTokens[2].safeApprove(address(depositBUSD), type(uint256).max);
        bpoolTokens[3].safeApprove(address(depositBUSD), type(uint256).max);
        tokenBCrv.safeApprove(address(depositBUSD), type(uint256).max);

        bpoolTokens[0].safeApprove(address(stableSwapSUSD), type(uint256).max);
        bpoolTokens[1].safeApprove(address(stableSwapSUSD), type(uint256).max);
        bpoolTokens[2].safeApprove(address(stableSwapSUSD), type(uint256).max);
        tokenSUSD.safeApprove(address(stableSwapSUSD), type(uint256).max);
        tokenSCrv.safeApprove(address(stableSwapSUSD), type(uint256).max);

        token3Crv.safeApprove(address(stableSwapHUSD), type(uint256).max);
        tokenHUSD.safeApprove(address(stableSwapHUSD), type(uint256).max);
        tokenHCrv.safeApprove(address(stableSwapHUSD), type(uint256).max);

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
        return address(tokenBCrv);
    }

    // Average dollar value of pool token
    function get_virtual_price() external override view returns (uint) {
        return stableSwapBUSD.get_virtual_price();
    }

    function convert_rate(address _input, address _output, uint _inputAmount) public override view returns (uint _outputAmount) {
        if (_inputAmount == 0) return 0;
        if (_output == address(tokenBCrv)) { // convert to BCrv
            uint[4] memory _amounts;
            for (uint8 i = 0; i < 4; i++) {
                if (_input == address(bpoolTokens[i])) {
                    _amounts[i] = _convert_underlying_to_ytoken_rate(poolBUSDyTokens[i], _inputAmount);
                    _outputAmount = stableSwapBUSD.calc_token_amount(_amounts, true);
                    return _outputAmount.mul(10000 - defaultSlippage).div(10000);
                }
            }
            if (_input == address(tokenSUSD)) {
                uint dai = stableSwapSUSD.get_dy_underlying(int128(3), int128(0), _inputAmount); // convert to DAI
                _amounts[0] = _convert_underlying_to_ytoken_rate(poolBUSDyTokens[0], dai); // DAI -> yDAI
                _outputAmount = stableSwapBUSD.calc_token_amount(_amounts, true); // DAI -> BCrv
            }
            if (_input == address(tokenHUSD)) {
                uint _3crvAmount = stableSwapHUSD.get_dy(int128(0), int128(1), _inputAmount); // HUSD -> 3Crv
                uint dai = stableSwap3Pool.calc_withdraw_one_coin(_3crvAmount, 0); // 3Crv -> DAI
                _amounts[0] = _convert_underlying_to_ytoken_rate(poolBUSDyTokens[0], dai); // DAI -> yDAI
                _outputAmount = stableSwapBUSD.calc_token_amount(_amounts, true); // DAI -> BCrv
            }
            if (_input == address(token3Crv)) {
                uint dai = stableSwap3Pool.calc_withdraw_one_coin(_inputAmount, 0); // 3Crv -> DAI
                _amounts[0] = _convert_underlying_to_ytoken_rate(poolBUSDyTokens[0], dai); // DAI -> yDAI
                _outputAmount = stableSwapBUSD.calc_token_amount(_amounts, true); // DAI -> BCrv
            }
        } else if (_input == address(tokenBCrv)) { // convert from BCrv
            for (uint8 i = 0; i < 4; i++) {
                if (_output == address(bpoolTokens[i])) {
                    _outputAmount = depositBUSD.calc_withdraw_one_coin(_inputAmount, i);
                    return _outputAmount.mul(10000 - defaultSlippage).div(10000);
                }
            }
            if (_output == address(tokenSUSD)) {
                uint _daiAmount = depositBUSD.calc_withdraw_one_coin(_inputAmount, 0); // BCrv -> DAI
                _outputAmount = stableSwapSUSD.get_dy_underlying(int128(0), int128(3), _daiAmount); // DAI -> SUSD
            }
            if (_output == address(tokenHUSD)) {
                uint _3crvAmount = _convert_bcrv_to_3crv_rate(_inputAmount); // BCrv -> DAI -> 3Crv
                _outputAmount = stableSwapHUSD.get_dy(int128(1), int128(0), _3crvAmount); // 3Crv -> HUSD
            }
        }
        if (_outputAmount > 0) {
            uint _slippage = _outputAmount.mul(vaultMaster.convertSlippage(_input, _output)).div(10000);
            _outputAmount = _outputAmount.sub(_slippage);
        }
    }

    function _convert_bcrv_to_3crv_rate(uint _bcrvAmount) internal view returns (uint _3crv) {
        uint[3] memory _amounts;
        _amounts[0] = depositBUSD.calc_withdraw_one_coin(_bcrvAmount, 0); // BCrv -> DAI
        _3crv = stableSwap3Pool.calc_token_amount(_amounts, true); // DAI -> 3Crv
    }

    // 0: DAI, 1: USDC, 2: USDT, 3: 3Crv, 4: BUSD, 5: sUSD, 6: husd
    function calc_token_amount_deposit(uint[] calldata _amounts) external override view returns (uint _shareAmount) {
        uint[4] memory _bpoolAmounts;
        _bpoolAmounts[0] = _convert_underlying_to_ytoken_rate(poolBUSDyTokens[0], _amounts[0]);
        _bpoolAmounts[1] = _convert_underlying_to_ytoken_rate(poolBUSDyTokens[1], _amounts[1]);
        _bpoolAmounts[2] = _convert_underlying_to_ytoken_rate(poolBUSDyTokens[2], _amounts[2]);
        _bpoolAmounts[3] = _convert_underlying_to_ytoken_rate(poolBUSDyTokens[3], _amounts[4]);
        uint _bpoolToBcrv = stableSwapBUSD.calc_token_amount(_bpoolAmounts, true);
        uint _3crvToBCrv = convert_rate(address(token3Crv), address(tokenBCrv), _amounts[3]);
        uint _susdToBCrv = convert_rate(address(tokenSUSD), address(tokenBCrv), _amounts[5]);
        uint _husdToBCrv = convert_rate(address(tokenHUSD), address(tokenBCrv), _amounts[6]);
        return _shareAmount.add(_bpoolToBcrv).add(_3crvToBCrv).add(_susdToBCrv).add(_husdToBCrv);
    }

    function calc_token_amount_withdraw(uint _shares, address _output) external override view returns (uint _outputAmount) {
        for (uint8 i = 0; i < 4; i++) {
            if (_output == address(bpoolTokens[i])) {
                _outputAmount = depositBUSD.calc_withdraw_one_coin(_shares, i);
                return _outputAmount.mul(10000 - defaultSlippage).div(10000);
            }
        }
        if (_output == address(token3Crv)) {
            _outputAmount = _convert_bcrv_to_3crv_rate(_shares); // BCrv -> DAI -> 3Crv
        } else if (_output == address(tokenSUSD)) {
            uint _daiAmount = depositBUSD.calc_withdraw_one_coin(_shares, 0); // BCrv -> DAI
            _outputAmount = stableSwapSUSD.get_dy_underlying(int128(0), int128(3), _daiAmount); // DAI -> SUSD
        } else if (_output == address(tokenHUSD)) {
            uint _3crvAmount = _convert_bcrv_to_3crv_rate(_shares); // BCrv -> DAI -> 3Crv
            _outputAmount = stableSwapHUSD.get_dy(int128(1), int128(0), _3crvAmount); // 3Crv -> HUSD
        }
        if (_outputAmount > 0) {
            uint _slippage = _outputAmount.mul(vaultMaster.slippage(_output)).div(10000);
            _outputAmount = _outputAmount.sub(_slippage);
        }
    }

    function convert(address _input, address _output, uint _inputAmount) external override returns (uint _outputAmount) {
        require(vaultMaster.isVault(msg.sender) || vaultMaster.isController(msg.sender) || msg.sender == governance, "!(governance||vault||controller)");
        if (_output == address(tokenBCrv)) { // convert to BCrv
            uint[4] memory amounts;
            for (uint8 i = 0; i < 4; i++) {
                if (_input == address(bpoolTokens[i])) {
                    amounts[i] = _inputAmount;
                    uint _before = tokenBCrv.balanceOf(address(this));
                    depositBUSD.add_liquidity(amounts, 1);
                    uint _after = tokenBCrv.balanceOf(address(this));
                    _outputAmount = _after.sub(_before);
                    tokenBCrv.safeTransfer(msg.sender, _outputAmount);
                    return _outputAmount;
                }
            }
            if (_input == address(token3Crv)) {
                _outputAmount = _convert_3crv_to_shares(_inputAmount);
                tokenBCrv.safeTransfer(msg.sender, _outputAmount);
                return _outputAmount;
            }
            if (_input == address(tokenSUSD)) {
                _outputAmount = _convert_susd_to_shares(_inputAmount);
                tokenBCrv.safeTransfer(msg.sender, _outputAmount);
                return _outputAmount;
            }
            if (_input == address(tokenHUSD)) {
                _outputAmount = _convert_husd_to_shares(_inputAmount);
                tokenBCrv.safeTransfer(msg.sender, _outputAmount);
                return _outputAmount;
            }
        } else if (_input == address(tokenBCrv)) { // convert from BCrv
            for (uint8 i = 0; i < 4; i++) {
                if (_output == address(bpoolTokens[i])) {
                    uint _before = bpoolTokens[i].balanceOf(address(this));
                    depositBUSD.remove_liquidity_one_coin(_inputAmount, i, 1);
                    uint _after = bpoolTokens[i].balanceOf(address(this));
                    _outputAmount = _after.sub(_before);
                    bpoolTokens[i].safeTransfer(msg.sender, _outputAmount);
                    return _outputAmount;
                }
            }
            if (_output == address(token3Crv)) {
                // remove BCrv to DAI
                uint[3] memory amounts;
                uint _before = bpoolTokens[0].balanceOf(address(this));
                depositBUSD.remove_liquidity_one_coin(_inputAmount, 0, 1);
                uint _after = bpoolTokens[0].balanceOf(address(this));
                amounts[0] = _after.sub(_before);

                // add DAI to 3pool to get back 3Crv
                _before = token3Crv.balanceOf(address(this));
                stableSwap3Pool.add_liquidity(amounts, 1);
                _after = token3Crv.balanceOf(address(this));
                _outputAmount = _after.sub(_before);

                token3Crv.safeTransfer(msg.sender, _outputAmount);
                return _outputAmount;
            }
            if (_output == address(tokenSUSD)) {
                // remove BCrv to DAI
                uint _before = bpoolTokens[0].balanceOf(address(this));
                depositBUSD.remove_liquidity_one_coin(_inputAmount, 0, 1);
                uint _after = bpoolTokens[0].balanceOf(address(this));
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

    function _convert_underlying_to_ytoken_rate(yTokenInterface yToken, uint _inputAmount) internal view returns (uint _outputAmount) {
        return _inputAmount.mul(1e18).div(yToken.getPricePerFullShare());
    }

    // @dev convert from 3Crv to BCrv (via DAI)
    function _convert_3crv_to_shares(uint _3crv) internal returns (uint _shares) {
        // convert to DAI
        uint[4] memory amounts;
        uint _before = bpoolTokens[0].balanceOf(address(this));
        stableSwap3Pool.remove_liquidity_one_coin(_3crv, 0, 1);
        uint _after = bpoolTokens[0].balanceOf(address(this));
        amounts[0] = _after.sub(_before);

        // add DAI to bpool to get back BCrv
        _before = tokenBCrv.balanceOf(address(this));
        depositBUSD.add_liquidity(amounts, 1);
        _after = tokenBCrv.balanceOf(address(this));

        _shares = _after.sub(_before);
    }

    // @dev convert from SUSD to BCrv (via DAI)
    function _convert_susd_to_shares(uint _amount) internal returns (uint _shares) {
        // convert to DAI
        uint[4] memory amounts;
        uint _before = bpoolTokens[0].balanceOf(address(this));
        stableSwapSUSD.exchange_underlying(int128(3), int128(0), _amount, 1);
        uint _after = bpoolTokens[0].balanceOf(address(this));
        amounts[0] = _after.sub(_before);

        // add DAI to bpool to get back BCrv
        _before = tokenBCrv.balanceOf(address(this));
        depositBUSD.add_liquidity(amounts, 1);
        _after = tokenBCrv.balanceOf(address(this));

        _shares = _after.sub(_before);
    }

    // @dev convert from HUSD to BCrv (HUSD -> 3Crv -> DAI -> BCrv)
    function _convert_husd_to_shares(uint _amount) internal returns (uint _shares) {
        // convert to 3Crv
        uint _before = token3Crv.balanceOf(address(this));
        stableSwapHUSD.exchange(int128(0), int128(1), _amount, 1);
        uint _after = token3Crv.balanceOf(address(this));
        _amount = _after.sub(_before);

        // convert 3Crv to DAI
        uint[4] memory amounts;
        _before = bpoolTokens[0].balanceOf(address(this));
        stableSwap3Pool.remove_liquidity_one_coin(_amount, 0, 1);
        _after = bpoolTokens[0].balanceOf(address(this));
        amounts[0] = _after.sub(_before);

        // add DAI to bpool to get back BCrv
        _before = tokenBCrv.balanceOf(address(this));
        depositBUSD.add_liquidity(amounts, 1);
        _after = tokenBCrv.balanceOf(address(this));

        _shares = _after.sub(_before);
    }

    // @dev convert from BCrv to HUSD (BCrv -> DAI -> 3Crv -> HUSD)
    function _convert_shares_to_husd(uint _amount) internal returns (uint _husd) {
        // convert to DAI
        uint[3] memory amounts;
        uint _before = bpoolTokens[0].balanceOf(address(this));
        depositBUSD.remove_liquidity_one_coin(_amount, 0, 1);
        uint _after = bpoolTokens[0].balanceOf(address(this));
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

    function convertAll(uint[] calldata _amounts) external override returns (uint _outputAmount) {
        require(vaultMaster.isVault(msg.sender) || vaultMaster.isController(msg.sender) || msg.sender == governance, "!(governance||vault||controller)");
        uint _before = tokenBCrv.balanceOf(address(this));
        if (_amounts[0] > 0 || _amounts[1] > 0 || _amounts[2] > 0 || _amounts[4] == 0) {
            uint[4] memory _bpoolAmounts;
            _bpoolAmounts[0] = _amounts[0];
            _bpoolAmounts[1] = _amounts[1];
            _bpoolAmounts[2] = _amounts[2];
            _bpoolAmounts[3] = _amounts[4];
            depositBUSD.add_liquidity(_bpoolAmounts, 1);
        }
        if (_amounts[3] > 0) { // 3Crv
            _convert_3crv_to_shares(_amounts[3]);
        }
        if (_amounts[5] > 0) { // sUSD
            _convert_susd_to_shares(_amounts[5]);
        }
        if (_amounts[6] > 0) { // hUSD
            _convert_husd_to_shares(_amounts[6]);
        }
        uint _after = tokenBCrv.balanceOf(address(this));
        _outputAmount = _after.sub(_before);
        tokenBCrv.safeTransfer(msg.sender, _outputAmount);
        return _outputAmount;
    }

    function governanceRecoverUnsupported(IERC20 _token, uint _amount, address _to) external {
        require(msg.sender == governance, "!governance");
        _token.transfer(_to, _amount);
    }
}