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




// 0: DAI, 1: USDC, 2: USDT, 3: sUSD




// 0: hUSD, 1: 3Crv




// 0: DAI, 1: USDC






// 0. 3pool [DAI, USDC, USDT]                  ## APY: 0.88% +8.53% (CRV)                  ## Vol: $16,800,095  ## Liquidity: $163,846,738  (https://etherscan.io/address/0xbEbc44782C7dB0a1A60Cb6fe97d0b483032FF1C7)
// 1. BUSD [(y)DAI, (y)USDC, (y)USDT, (y)BUSD] ## APY: 2.54% +11.16%                       ## Vol: $6,580,652   ## Liquidity: $148,930,780  (https://etherscan.io/address/0x79a8C46DeA5aDa233ABaFFD40F3A0A2B1e5A4F27)
// 2. sUSD [DAI, USDC, USDT, sUSD]             ## APY: 2.59% +2.19% (SNX) +13.35% (CRV)    ## Vol: $11,854,566  ## Liquidity: $53,575,781   (https://etherscan.io/address/0xA5407eAE9Ba41422680e2e00537571bcC53efBfD)
// 3. husd [HUSD, 3pool]                       ## APY: 0.53% +8.45% (CRV)                  ## Vol: $0           ## Liquidity: $1,546,077    (https://etherscan.io/address/0x3eF6A01A0f81D6046290f3e2A8c5b843e738E604)
// 4. Compound [(c)DAI, (c)USDC]               ## APY: 3.97% +9.68% (CRV)                  ## Vol: $2,987,370   ## Liquidity: $121,783,878  (https://etherscan.io/address/0xA2B47E3D5c44877cca798226B7B8118F9BFb7A56)
// 5. Y [(y)DAI, (y)USDC, (y)USDT, (y)TUSD]    ## APY: 3.37% +8.39% (CRV)                  ## Vol: $8,374,971   ## Liquidity: $176,470,728  (https://etherscan.io/address/0x45F783CCE6B7FF23B2ab2D70e416cdb7D6055f51)
// 6. Swerve [(y)DAI...(y)TUSD]                ## APY: 0.43% +6.05% (CRV)                  ## Vol: $1,567,681   ## Liquidity: $28,631,966   (https://etherscan.io/address/0x329239599afB305DA0A2eC69c58F8a6697F9F88d)
contract ShareConverter is IShareConverter {
    using SafeMath for uint;
    using SafeERC20 for IERC20;

    IERC20[3] public pool3CrvTokens; // DAI, USDC, USDT
    yTokenInterface[4] public poolBUSDyTokens; // yDAI, yUSDC, yUSDT, yBUSD
    CTokenInterface[2] public poolCompoundCTokens;
    IERC20 public token3CRV; // 3Crv

    IERC20 public tokenBUSD; // BUSD
    IERC20 public tokenBCrv; // BCrv (yDAI+yUSDC+yUSDT+yBUSD)

    IERC20 public tokenSUSD; // sUSD
    IERC20 public tokenSCrv; // SCrv (DAI/USDC/USDT/sUSD)

    IERC20 public tokenHUSD; // hUSD
    IERC20 public tokenHCrv; // HCrv (hUSD/3CRV)

    IERC20 public tokenCCrv; // cDAI+cUSDC ((c)DAI+(c)USDC)

    address public governance;

    IStableSwap3Pool public stableSwap3Pool;

    IDepositBUSD public depositBUSD;
    IStableSwapBUSD public stableSwapBUSD;

    IDepositSUSD public depositSUSD;
    IStableSwapSUSD public stableSwapSUSD;

    IDepositHUSD public depositHUSD;
    IStableSwapHUSD public stableSwapHUSD;

    IDepositCompound public depositCompound;
    IStableSwapCompound public stableSwapCompound;

    IValueVaultMaster public vaultMaster;

    // tokens: 0. BUSD, 1. sUSD, 2. hUSD
    // tokenCrvs: 0. BCrv, 1. SCrv, 2. HCrv, 3. CCrv
    // depositUSD: 0. depositBUSD, 1. depositSUSD, 2. depositHUSD, 3. depositCompound
    // stableSwapUSD: 0. stableSwapBUSD, 1. stableSwapSUSD, 2. stableSwapHUSD, 3. stableSwapCompound
    constructor (
        IERC20 _tokenDAI, IERC20 _tokenUSDC, IERC20 _tokenUSDT, IERC20 _token3CRV,
        IERC20[] memory _tokens, IERC20[] memory _tokenCrvs,
        address[] memory _depositUSD, address[] memory _stableSwapUSD,
        yTokenInterface[4] memory _yTokens,
        CTokenInterface[2] memory _cTokens,
        IStableSwap3Pool _stableSwap3Pool,
        IValueVaultMaster _vaultMaster) public {
        pool3CrvTokens[0] = _tokenDAI;
        pool3CrvTokens[1] = _tokenUSDC;
        pool3CrvTokens[2] = _tokenUSDT;

        poolBUSDyTokens = _yTokens;
        poolCompoundCTokens = _cTokens;

        token3CRV = _token3CRV;
        tokenBUSD = _tokens[0];
        tokenBCrv = _tokenCrvs[0];
        tokenSUSD = _tokens[1];
        tokenSCrv = _tokenCrvs[1];
        tokenHUSD = _tokens[2];
        tokenHCrv = _tokenCrvs[2];
        tokenCCrv = _tokenCrvs[3];

        stableSwap3Pool = _stableSwap3Pool;

        depositBUSD = IDepositBUSD(_depositUSD[0]);
        stableSwapBUSD = IStableSwapBUSD(_stableSwapUSD[0]);

        depositSUSD = IDepositSUSD(_depositUSD[1]);
        stableSwapSUSD = IStableSwapSUSD(_stableSwapUSD[1]);

        depositHUSD = IDepositHUSD(_depositUSD[2]);
        stableSwapHUSD = IStableSwapHUSD(_stableSwapUSD[2]);

        depositCompound = IDepositCompound(_depositUSD[3]);
        stableSwapCompound = IStableSwapCompound(_stableSwapUSD[3]);

        for (uint i = 0; i < 3; i++) {
            pool3CrvTokens[i].safeApprove(address(stableSwap3Pool), type(uint256).max);
            pool3CrvTokens[i].safeApprove(address(stableSwapBUSD), type(uint256).max);
            pool3CrvTokens[i].safeApprove(address(depositBUSD), type(uint256).max);
            pool3CrvTokens[i].safeApprove(address(stableSwapSUSD), type(uint256).max);
            pool3CrvTokens[i].safeApprove(address(depositSUSD), type(uint256).max);
            pool3CrvTokens[i].safeApprove(address(stableSwapHUSD), type(uint256).max);
            pool3CrvTokens[i].safeApprove(address(depositHUSD), type(uint256).max);
            if (i < 2) { // DAI && USDC
                pool3CrvTokens[i].safeApprove(address(depositCompound), type(uint256).max);
                pool3CrvTokens[i].safeApprove(address(stableSwapCompound), type(uint256).max);
            }
        }

        token3CRV.safeApprove(address(stableSwap3Pool), type(uint256).max);

        tokenBUSD.safeApprove(address(stableSwapBUSD), type(uint256).max);
        tokenBCrv.safeApprove(address(stableSwapBUSD), type(uint256).max);
        tokenBCrv.safeApprove(address(depositBUSD), type(uint256).max);

        tokenSUSD.safeApprove(address(stableSwapSUSD), type(uint256).max);
        tokenSCrv.safeApprove(address(stableSwapSUSD), type(uint256).max);
        tokenSCrv.safeApprove(address(depositSUSD), type(uint256).max);

        tokenHCrv.safeApprove(address(stableSwapHUSD), type(uint256).max);
        tokenHCrv.safeApprove(address(depositHUSD), type(uint256).max);

        tokenCCrv.safeApprove(address(depositCompound), type(uint256).max);
        tokenCCrv.safeApprove(address(stableSwapCompound), type(uint256).max);

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

    function convert_shares_rate(address _input, address _output, uint _inputAmount) external override view returns (uint _outputAmount) {
        if (_output == address(token3CRV)) {
            if (_input == address(tokenBCrv)) { // convert from BCrv -> 3CRV
                uint[3] memory _amounts;
                _amounts[1] = depositBUSD.calc_withdraw_one_coin(_inputAmount, 1); // BCrv -> USDC
                _outputAmount = stableSwap3Pool.calc_token_amount(_amounts, true); // USDC -> 3CRV
            } else if (_input == address(tokenSCrv)) { // convert from SCrv -> 3CRV
                uint[3] memory _amounts;
                _amounts[1] = depositSUSD.calc_withdraw_one_coin(_inputAmount, 1); // SCrv -> USDC
                _outputAmount = stableSwap3Pool.calc_token_amount(_amounts, true); // USDC -> 3CRV
            } else if (_input == address(tokenHCrv)) { // convert from HCrv -> 3CRV
                _outputAmount = stableSwapHUSD.calc_withdraw_one_coin(_inputAmount, 1); // HCrv -> 3CRV
            } else if (_input == address(tokenCCrv)) { // convert from CCrv -> 3CRV
                uint[3] memory _amounts;
                uint usdc = depositCompound.calc_withdraw_one_coin(_inputAmount, 1); // CCrv -> USDC
                _amounts[1] = usdc;//convert_usdc_to_cusdc(usdc); // TODO: to implement
                _outputAmount = stableSwap3Pool.calc_token_amount(_amounts, true); // USDC -> 3CRV
            }
        } else if (_output == address(tokenBCrv)) {
            if (_input == address(token3CRV)) { // convert from 3CRV -> BCrv
                uint[4] memory _amounts;
                uint usdc = stableSwap3Pool.calc_withdraw_one_coin(_inputAmount, 1); // 3CRV -> USDC
                _amounts[1] = _convert_underlying_to_ytoken_rate(poolBUSDyTokens[1], usdc); // USDC -> yUSDC
                _outputAmount = stableSwapBUSD.calc_token_amount(_amounts, true); // yUSDC -> BCrv
            } else if (_input == address(tokenSCrv)) { // convert from SCrv -> BCrv
                uint[4] memory _amounts;
                uint usdc = depositSUSD.calc_withdraw_one_coin(_inputAmount, 1); // SCrv -> USDC
                _amounts[1] = _convert_underlying_to_ytoken_rate(poolBUSDyTokens[1], usdc); // USDC -> yUSDC
                _outputAmount = stableSwapBUSD.calc_token_amount(_amounts, true); // yUSDC -> BCrv
            } else if (_input == address(tokenHCrv)) { // convert from HCrv -> BCrv
                uint[4] memory _amounts;
                uint usdc = depositHUSD.calc_withdraw_one_coin(_inputAmount, 2); // HCrv -> USDC
                _amounts[1] = _convert_underlying_to_ytoken_rate(poolBUSDyTokens[1], usdc); // USDC -> yUSDC
                _outputAmount = stableSwapBUSD.calc_token_amount(_amounts, true); // yUSDC -> BCrv
            } else if (_input == address(tokenCCrv)) { // convert from CCrv -> BCrv
                uint[4] memory _amounts;
                uint usdc = depositCompound.calc_withdraw_one_coin(_inputAmount, 1); // CCrv -> USDC
                _amounts[1] = _convert_underlying_to_ytoken_rate(poolBUSDyTokens[1], usdc); // USDC -> yUSDC
                _outputAmount = stableSwapBUSD.calc_token_amount(_amounts, true); // yUSDC -> BCrv
            }
        } else if (_output == address(tokenSCrv)) {
            if (_input == address(token3CRV)) { // convert from 3CRV -> SCrv
                uint[4] memory _amounts;
                _amounts[1] = stableSwap3Pool.calc_withdraw_one_coin(_inputAmount, 1); // 3CRV -> USDC
                _outputAmount = stableSwapSUSD.calc_token_amount(_amounts, true); // USDC -> BCrv
            } else if (_input == address(tokenBCrv)) { // convert from BCrv -> SCrv
                uint[4] memory _amounts;
                _amounts[1] = depositBUSD.calc_withdraw_one_coin(_inputAmount, 1); // BCrv -> USDC
                _outputAmount = stableSwapSUSD.calc_token_amount(_amounts, true); // USDC -> SCrv
            } else if (_input == address(tokenHCrv)) { // convert from HCrv -> SCrv
                uint[4] memory _amounts;
                _amounts[1] = depositHUSD.calc_withdraw_one_coin(_inputAmount, 2); // HCrv -> USDC
                _outputAmount = stableSwapSUSD.calc_token_amount(_amounts, true); // USDC -> SCrv
            } else if (_input == address(tokenCCrv)) { // convert from CCrv -> SCrv
                uint[4] memory _amounts;
                _amounts[1] = depositCompound.calc_withdraw_one_coin(_inputAmount, 1); // CCrv -> USDC
                _outputAmount = stableSwapSUSD.calc_token_amount(_amounts, true); // USDC -> SCrv
            }
        } else if (_output == address(tokenHCrv)) {
            if (_input == address(token3CRV)) { // convert from 3CRV -> HCrv
                uint[2] memory _amounts;
                _amounts[1] = _inputAmount;
                _outputAmount = stableSwapHUSD.calc_token_amount(_amounts, true); // 3CRV -> HCrv
            } else if (_input == address(tokenBCrv)) { // convert from BCrv -> HCrv
                uint[4] memory _amounts;
                _amounts[2] = depositBUSD.calc_withdraw_one_coin(_inputAmount, 1); // BCrv -> USDC
                _outputAmount = depositHUSD.calc_token_amount(_amounts, true); // USDC -> HCrv
            } else if (_input == address(tokenSCrv)) { // convert from SCrv -> HCrv
                uint[4] memory _amounts;
                _amounts[2] = depositSUSD.calc_withdraw_one_coin(_inputAmount, 1); // SCrv -> USDC
                _outputAmount = depositHUSD.calc_token_amount(_amounts, true); // USDC -> HCrv
            } else if (_input == address(tokenCCrv)) { // convert from CCrv -> HCrv
                uint[4] memory _amounts;
                _amounts[2] = depositCompound.calc_withdraw_one_coin(_inputAmount, 1); // CCrv -> USDC
                _outputAmount = depositHUSD.calc_token_amount(_amounts, true); // USDC -> HCrv
            }
        } else if (_output == address(tokenCCrv)) {
            if (_input == address(token3CRV)) { // convert from 3CRV -> CCrv
                uint[2] memory _amounts;
                uint usdc = stableSwap3Pool.calc_withdraw_one_coin(_inputAmount, 1); // 3CRV -> USDC
                _amounts[1] = _convert_underlying_to_ctoken(poolCompoundCTokens[1], usdc); // USDC -> cUSDC
                _outputAmount = stableSwapCompound.calc_token_amount(_amounts, true); // cUSDC -> CCrv
            } else if (_input == address(tokenBCrv)) { // convert from BCrv -> CCrv
                uint[2] memory _amounts;
                uint usdc = depositBUSD.calc_withdraw_one_coin(_inputAmount, 1); // BCrv -> USDC
                _amounts[1] = _convert_underlying_to_ctoken(poolCompoundCTokens[1], usdc); // USDC -> cUSDC
                _outputAmount = stableSwapCompound.calc_token_amount(_amounts, true); // cUSDC -> CCrv
            } else if (_input == address(tokenSCrv)) { // convert from SCrv -> CCrv
                uint[2] memory _amounts;
                uint usdc = depositSUSD.calc_withdraw_one_coin(_inputAmount, 1); // SCrv -> USDC
                _amounts[1] = _convert_underlying_to_ctoken(poolCompoundCTokens[1], usdc); // USDC -> cUSDC
                _outputAmount = stableSwapCompound.calc_token_amount(_amounts, true); // cUSDC -> CCrv
            } else if (_input == address(tokenHCrv)) { // convert from HCrv -> CCrv
                uint[2] memory _amounts;
                uint usdc = depositHUSD.calc_withdraw_one_coin(_inputAmount, 2); // HCrv -> USDC
                _amounts[1] = _convert_underlying_to_ctoken(poolCompoundCTokens[1], usdc); // USDC -> cUSDC
                _outputAmount = stableSwapCompound.calc_token_amount(_amounts, true); // cUSDC -> CCrv
            }
        }
        if (_outputAmount > 0) {
            uint _slippage = _outputAmount.mul(vaultMaster.convertSlippage(_input, _output)).div(10000);
            _outputAmount = _outputAmount.sub(_slippage);
        }
    }

    function convert_shares(address _input, address _output, uint _inputAmount) external override returns (uint _outputAmount) {
        require(vaultMaster.isVault(msg.sender) || vaultMaster.isController(msg.sender) || msg.sender == governance, "!(governance||vault||controller)");
        if (_output == address(token3CRV)) {
            if (_input == address(tokenBCrv)) { // convert from BCrv -> 3CRV
                uint[3] memory _amounts;
                _amounts[1] = _convert_bcrv_to_usdc(_inputAmount);

                uint _before = token3CRV.balanceOf(address(this));
                stableSwap3Pool.add_liquidity(_amounts, 1);
                uint _after = token3CRV.balanceOf(address(this));

                _outputAmount = _after.sub(_before);
            } else if (_input == address(tokenSCrv)) { // convert from SCrv -> 3CRV
                uint[3] memory _amounts;
                _amounts[1] = _convert_scrv_to_usdc(_inputAmount);

                uint _before = token3CRV.balanceOf(address(this));
                stableSwap3Pool.add_liquidity(_amounts, 1);
                uint _after = token3CRV.balanceOf(address(this));

                _outputAmount = _after.sub(_before);
            } else if (_input == address(tokenHCrv)) { // convert from HCrv -> 3CRV
                _outputAmount = _convert_hcrv_to_3crv(_inputAmount);
            } else if (_input == address(tokenCCrv)) { // convert from CCrv -> 3CRV
                uint[3] memory _amounts;
                _amounts[1] = _convert_ccrv_to_usdc(_inputAmount);

                uint _before = token3CRV.balanceOf(address(this));
                stableSwap3Pool.add_liquidity(_amounts, 1);
                uint _after = token3CRV.balanceOf(address(this));

                _outputAmount = _after.sub(_before);
            }
        } else if (_output == address(tokenBCrv)) {
            if (_input == address(token3CRV)) { // convert from 3CRV -> BCrv
                uint[4] memory _amounts;
                _amounts[1] = _convert_3crv_to_usdc(_inputAmount);

                uint _before = tokenBCrv.balanceOf(address(this));
                depositBUSD.add_liquidity(_amounts, 1);
                uint _after = tokenBCrv.balanceOf(address(this));

                _outputAmount = _after.sub(_before);
            } else if (_input == address(tokenSCrv)) { // convert from SCrv -> BCrv
                uint[4] memory _amounts;
                _amounts[1] = _convert_scrv_to_usdc(_inputAmount);

                uint _before = tokenBCrv.balanceOf(address(this));
                depositBUSD.add_liquidity(_amounts, 1);
                uint _after = tokenBCrv.balanceOf(address(this));

                _outputAmount = _after.sub(_before);
            } else if (_input == address(tokenHCrv)) { // convert from HCrv -> BCrv
                uint[4] memory _amounts;
                _amounts[1] = _convert_hcrv_to_usdc(_inputAmount);

                uint _before = tokenBCrv.balanceOf(address(this));
                depositBUSD.add_liquidity(_amounts, 1);
                uint _after = tokenBCrv.balanceOf(address(this));

                _outputAmount = _after.sub(_before);
            } else if (_input == address(tokenCCrv)) { // convert from CCrv -> BCrv
                uint[4] memory _amounts;
                _amounts[1] = _convert_ccrv_to_usdc(_inputAmount);

                uint _before = tokenBCrv.balanceOf(address(this));
                depositBUSD.add_liquidity(_amounts, 1);
                uint _after = tokenBCrv.balanceOf(address(this));

                _outputAmount = _after.sub(_before);
            }
        } else if (_output == address(tokenSCrv)) {
            if (_input == address(token3CRV)) { // convert from 3CRV -> SCrv
                uint[4] memory _amounts;
                _amounts[1] = _convert_3crv_to_usdc(_inputAmount);

                uint _before = tokenSCrv.balanceOf(address(this));
                depositSUSD.add_liquidity(_amounts, 1);
                uint _after = tokenSCrv.balanceOf(address(this));

                _outputAmount = _after.sub(_before);
            } else if (_input == address(tokenBCrv)) { // convert from BCrv -> SCrv
                uint[4] memory _amounts;
                _amounts[1] = _convert_bcrv_to_usdc(_inputAmount);

                uint _before = tokenSCrv.balanceOf(address(this));
                depositSUSD.add_liquidity(_amounts, 1);
                uint _after = tokenSCrv.balanceOf(address(this));

                _outputAmount = _after.sub(_before);
            } else if (_input == address(tokenHCrv)) { // convert from HCrv -> SCrv
                uint[4] memory _amounts;
                _amounts[1] = _convert_hcrv_to_usdc(_inputAmount);

                uint _before = tokenSCrv.balanceOf(address(this));
                depositSUSD.add_liquidity(_amounts, 1);
                uint _after = tokenSCrv.balanceOf(address(this));

                _outputAmount = _after.sub(_before);
            } else if (_input == address(tokenCCrv)) { // convert from CCrv -> SCrv
                uint[4] memory _amounts;
                _amounts[1] = _convert_ccrv_to_usdc(_inputAmount);

                uint _before = tokenSCrv.balanceOf(address(this));
                depositSUSD.add_liquidity(_amounts, 1);
                uint _after = tokenSCrv.balanceOf(address(this));

                _outputAmount = _after.sub(_before);
            }
        } else if (_output == address(tokenHCrv)) {
            // todo: re-check
            if (_input == address(token3CRV)) { // convert from 3CRV -> HCrv
                uint[2] memory _amounts;
                _amounts[1] = _inputAmount;

                uint _before = tokenHCrv.balanceOf(address(this));
                stableSwapHUSD.add_liquidity(_amounts, 1);
                uint _after = tokenHCrv.balanceOf(address(this));

                _outputAmount = _after.sub(_before);
            } else if (_input == address(tokenBCrv)) { // convert from BCrv -> HCrv
                uint[4] memory _amounts;
                _amounts[2] = _convert_bcrv_to_usdc(_inputAmount);

                uint _before = tokenHCrv.balanceOf(address(this));
                depositHUSD.add_liquidity(_amounts, 1);
                uint _after = tokenHCrv.balanceOf(address(this));

                _outputAmount = _after.sub(_before);
            } else if (_input == address(tokenSCrv)) { // convert from SCrv -> HCrv
                uint[4] memory _amounts;
                _amounts[2] = _convert_scrv_to_usdc(_inputAmount);

                uint _before = tokenHCrv.balanceOf(address(this));
                depositHUSD.add_liquidity(_amounts, 1);
                uint _after = tokenHCrv.balanceOf(address(this));

                _outputAmount = _after.sub(_before);
            } else if (_input == address(tokenCCrv)) { // convert from CCrv -> HCrv
                uint[4] memory _amounts;
                _amounts[2] = _convert_ccrv_to_usdc(_inputAmount);

                uint _before = tokenHCrv.balanceOf(address(this));
                depositHUSD.add_liquidity(_amounts, 1);
                uint _after = tokenHCrv.balanceOf(address(this));

                _outputAmount = _after.sub(_before);
            }
        } else if (_output == address(tokenCCrv)) {
            if (_input == address(token3CRV)) { // convert from 3CRV -> CCrv
                uint[2] memory _amounts;
                _amounts[1] = _convert_3crv_to_usdc(_inputAmount);

                uint _before = tokenCCrv.balanceOf(address(this));
                depositCompound.add_liquidity(_amounts, 1);
                uint _after = tokenCCrv.balanceOf(address(this));

                _outputAmount = _after.sub(_before);
            } else if (_input == address(tokenBCrv)) { // convert from BCrv -> CCrv
                uint[2] memory _amounts;
                _amounts[1] = _convert_bcrv_to_usdc(_inputAmount);

                uint _before = tokenCCrv.balanceOf(address(this));
                depositCompound.add_liquidity(_amounts, 1);
                uint _after = tokenCCrv.balanceOf(address(this));

                _outputAmount = _after.sub(_before);
            } else if (_input == address(tokenSCrv)) { // convert from SCrv -> BCrv
                uint[2] memory _amounts;
                _amounts[1] = _convert_scrv_to_usdc(_inputAmount);

                uint _before = tokenCCrv.balanceOf(address(this));
                depositCompound.add_liquidity(_amounts, 1);
                uint _after = tokenCCrv.balanceOf(address(this));

                _outputAmount = _after.sub(_before);
            } else if (_input == address(tokenHCrv)) { // convert from HCrv -> BCrv
                uint[2] memory _amounts;
                _amounts[1] = _convert_hcrv_to_usdc(_inputAmount);

                uint _before = tokenCCrv.balanceOf(address(this));
                depositCompound.add_liquidity(_amounts, 1);
                uint _after = tokenCCrv.balanceOf(address(this));

                _outputAmount = _after.sub(_before);
            }
        }
        if (_outputAmount > 0) {
            IERC20(_output).safeTransfer(msg.sender, _outputAmount);
        }
        return _outputAmount;
    }

    function _convert_underlying_to_ctoken(CTokenInterface ctoken, uint _amount) internal view returns (uint _outputAmount) {
        _outputAmount = _amount.mul(10 ** 18).div(ctoken.exchangeRateStored());
    }

    function _convert_underlying_to_ytoken_rate(yTokenInterface yToken, uint _inputAmount) internal view returns (uint _outputAmount) {
        return _inputAmount.mul(1e18).div(yToken.getPricePerFullShare());
    }

    function _convert_3crv_to_usdc(uint _inputAmount) internal returns (uint _outputAmount) {
        // 3CRV -> USDC
        uint _before = pool3CrvTokens[1].balanceOf(address(this));
        stableSwap3Pool.remove_liquidity_one_coin(_inputAmount, 1, 1);
        _outputAmount = pool3CrvTokens[1].balanceOf(address(this)).sub(_before);
    }

    function _convert_bcrv_to_usdc(uint _inputAmount) internal returns (uint _outputAmount) {
        // BCrv -> USDC
        uint _before = pool3CrvTokens[1].balanceOf(address(this));
        depositBUSD.remove_liquidity_one_coin(_inputAmount, 1, 1);
        _outputAmount = pool3CrvTokens[1].balanceOf(address(this)).sub(_before);
    }

    function _convert_scrv_to_usdc(uint _inputAmount) internal returns (uint _outputAmount) {
        // SCrv -> USDC
        uint _before = pool3CrvTokens[1].balanceOf(address(this));
        depositSUSD.remove_liquidity_one_coin(_inputAmount, 1, 1);
        _outputAmount = pool3CrvTokens[1].balanceOf(address(this)).sub(_before);
    }

    function _convert_hcrv_to_usdc(uint _inputAmount) internal returns (uint _outputAmount) {
        // HCrv -> USDC
        uint _before = pool3CrvTokens[1].balanceOf(address(this));
        depositHUSD.remove_liquidity_one_coin(_inputAmount, 2, 1);
        _outputAmount = pool3CrvTokens[1].balanceOf(address(this)).sub(_before);
    }

    function _convert_ccrv_to_usdc(uint _inputAmount) internal returns (uint _outputAmount) {
        // CCrv -> USDC
        uint _before = pool3CrvTokens[1].balanceOf(address(this));
        depositCompound.remove_liquidity_one_coin(_inputAmount, 1, 1);
        _outputAmount = pool3CrvTokens[1].balanceOf(address(this)).sub(_before);
    }

    function _convert_hcrv_to_3crv(uint _inputAmount) internal returns (uint _outputAmount) {
        // HCrv -> 3CRV
        uint _before = token3CRV.balanceOf(address(this));
        stableSwapHUSD.remove_liquidity_one_coin(_inputAmount, 1, 1);
        _outputAmount = token3CRV.balanceOf(address(this)).sub(_before);
    }

    function governanceRecoverUnsupported(IERC20 _token, uint _amount, address _to) external {
        require(msg.sender == governance, "!governance");
        _token.transfer(_to, _amount);
    }
}