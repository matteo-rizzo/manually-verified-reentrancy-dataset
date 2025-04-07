/**
 *Submitted for verification at Etherscan.io on 2020-10-04
*/

pragma solidity ^0.6.12;
pragma experimental ABIEncoderV2;
/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
 */




/**
 * @dev Collection of functions related to the address type
 */


/**
 * @title SafeERC20
 * @dev Wrappers around ERC20 operations that throw on failure (when the token
 * contract returns false). Tokens that return no value (and instead revert or
 * throw on failure) are also supported, non-reverting calls are assumed to be
 * successful.
 * To use this library you can add a `using SafeERC20 for IERC20;` statement to your contract,
 * which allows you to call the safe operations as `token.safeTransfer(...)`, etc.
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








interface IUniswapV2Router02 is IUniswapV2Router01 {
    function removeLiquidityETHSupportingFeeOnTransferTokens(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline
    ) external returns (uint amountETH);
    function removeLiquidityETHWithPermitSupportingFeeOnTransferTokens(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline,
        bool approveMax, uint8 v, bytes32 r, bytes32 s
    ) external returns (uint amountETH);

    function swapExactTokensForTokensSupportingFeeOnTransferTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external;
    function swapExactETHForTokensSupportingFeeOnTransferTokens(
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external payable;
    function swapExactTokensForETHSupportingFeeOnTransferTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external;
}



contract CritBPool {
    using SafeMath for uint256;
    using SafeERC20 for IERC20;
    using UniswapPriceOracle for address;

    struct TokenWeight {
        address token;
        uint256 amount;
        uint256 denorm;
    }

    address public constant WETH = 0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2;

    address public governance;
    address public strategist;
    address public roundTable;

    BFactory public factory = BFactory(0x9424B1412450D0f8Fc2255FAf6046b98213B76Bd);
    BPool public pool;

    mapping (address => address) public strategies;
    uint256 public rebalancedAt;

    modifier onlyGovernance {
        require(msg.sender == governance, 'governance');
        _;
    }

    constructor() public {
        pool = factory.newBPool();
        pool.setSwapFee(15e14);

        governance = msg.sender;
        roundTable = msg.sender;
        strategist = msg.sender;
    }

    // ************************************************************** Controller
    function setSwapFee(uint256 _swapFee) external onlyGovernance {
        pool.setSwapFee(_swapFee);
    }

    function setStrategy(IERC20 _token, address _strategy) external onlyGovernance {
        strategies[address(_token)] = _strategy;
    }

    function setRoundTable(address _roundTable) external onlyGovernance {
        roundTable = _roundTable;
    }

    // **************************************************************
    function setPublicSwap(bool _swap) public {
        require(msg.sender == strategist || msg.sender == governance, "auth");
        if (_swap == true) {
            require(rebalancedAt + 5 <= block.number, 'not enough block');
            require(checkWellBalanced(), 'need rebalance');
        }
        pool.setPublicSwap(_swap);
    }

    function getTokenWeight(address[] calldata tokens) public view returns(TokenWeight[] memory) {
        TokenWeight[] memory tokenWeights = new TokenWeight[](tokens.length);
        uint[] memory ethValues = new uint[](tokens.length);
        uint[] memory balances = new uint[](tokens.length);

        uint256 minETHValue = uint256(~0);
        uint i;
        for (i=0; i<tokens.length; i++) {
            ERC20 token = ERC20(tokens[i]);
            balances[i] = balanceOf(address(token));
            ethValues[i] = address(token).ethValue(balances[i]);
            if (ethValues[i] < minETHValue) {
                minETHValue = ethValues[i];
            }
        }

        uint256 totalDenorm;
        for (i=0; i<tokens.length; i++) {
            tokenWeights[i].token = tokens[i];
            tokenWeights[i].denorm = uint(2e18).mul(ethValues[i]).div(minETHValue);
            tokenWeights[i].amount = balances[i];
            totalDenorm = totalDenorm.add(tokenWeights[i].denorm);
        }

        require(totalDenorm < 50e18, 'totalDenorm');

        return tokenWeights;
    }

    function compareUniswap(address token) public view returns(bool) {
        uint256 inputETHAmount = 1e18;
        uint256 poolOutput = pool.calcOutGivenIn(
            pool.getBalance(WETH),
            pool.getDenormalizedWeight(WETH),
            pool.getBalance(token),
            pool.getDenormalizedWeight(token),
            inputETHAmount,
            pool.getSwapFee()
        );

        uint256 uniswapOutput = token.swapAmountFromETH(inputETHAmount);
        uint256 decimal = 10**uint256(ERC20(token).decimals());

        uint MIN = decimal.mul(995).div(1000);
        uint MAX = decimal.mul(1005).div(1000);
        uint ratio = poolOutput.mul(decimal).div(uniswapOutput);
        if (MIN < ratio && ratio < MAX) {
            return true;
        }

        return false;
    }

    function checkWellBalanced() public view returns(bool) {
        address[] memory tokens = pool.getCurrentTokens();

        for (uint i=0; i<tokens.length; i++) {
            address token = tokens[i];
            if (token == WETH) continue;
            if (compareUniswap(token)) continue;

            return false;
        }

        return true;
    }

    //
    function rebalance(address[] calldata tokens) external {
        require(msg.sender == strategist || msg.sender == governance, "auth");
        rebalancedAt = block.number;
        setPublicSwap(false);
        bindPool(getTokenWeight(tokens));
    }

    function bindPool(TokenWeight[] memory _tokenWeight) private {
        address[] memory unboundTokens = pool.getCurrentTokens();

        for (uint256 i=0; i< _tokenWeight.length; i++) {
            TokenWeight memory weight = _tokenWeight[i];
            require(strategies[weight.token] != address(0), '!token');
            require(balanceOf(weight.token) >= weight.amount, '!amount');

            IERC20(weight.token).safeApprove(address(pool), 0);
            IERC20(weight.token).safeApprove(address(pool), weight.amount);
            if (pool.isBound(weight.token)) {
                pool.rebind(weight.token, weight.amount, weight.denorm);
            } else {
                pool.bind(weight.token, weight.amount, weight.denorm);
            }

            for (uint256 j=0; j<unboundTokens.length; j++) {
                if (weight.token == unboundTokens[j]) {
                    delete unboundTokens[j];
                    break;
                }
            }
        }

        for (uint256 i=0; i<unboundTokens.length; i++) {
            if (unboundTokens[i] != address(0)) {
                pool.unbind(unboundTokens[i]);
            }
        }
    }

    function add_liquidity(address _token, uint256 _amount) external {
        require(msg.sender == strategies[_token] || msg.sender == roundTable, 'auth');

        if (pool.isPublicSwap() == false || pool.isBound(_token) == false) {
            // not set yet, wait until the operator call rebalance()
            return;
        }

        uint256 oldBalance = pool.getBalance(_token);
        uint256 newBalance = oldBalance.add(_amount);
        uint256 tokenDenorm = pool.getDenormalizedWeight(_token);
        uint256 updatedDenorm = tokenDenorm.mul(newBalance).div(oldBalance);
        if (updatedDenorm > 50e18 || pool.getTotalDenormalizedWeight().add(updatedDenorm.sub(tokenDenorm)) > 50e18) {
            // wait until the operator call rebalance()
            return;
        }

        IERC20(_token).safeApprove(address(pool), 0);
        IERC20(_token).safeApprove(address(pool), _amount);
        pool.rebind(_token, newBalance, updatedDenorm);
    }

    function remove_liquidity(address _token, uint256 _amount) external {
        require(msg.sender == strategies[_token] || msg.sender == roundTable, 'auth');

        uint256 balanceOfThis = IERC20(_token).balanceOf(address(this));
        if (balanceOfThis >= _amount) {
            IERC20(_token).safeTransfer(msg.sender, _amount);
            return;
        }

        uint256 withdrawalAmount = _amount.sub(balanceOfThis);
        uint256 oldBalance = pool.getBalance(_token);
        if (oldBalance < withdrawalAmount) {
            // cause of impermanent loss
            revert("Ask for help on Crit discord");
            //            pool.unbind(_token);
            //            IERC20(_token).safeTransfer(msg.sender, IERC20(_token).balanceOf(address(this)));
            //            return;
        }

        uint256 newBalance = oldBalance.sub(withdrawalAmount);
        uint256 updatedDenorm = pool.getDenormalizedWeight(_token).mul(newBalance).div(oldBalance);
        if (updatedDenorm < 1e18) {
            pool.unbind(_token);
            IERC20(_token).safeTransfer(msg.sender, _amount);
            return;
        }

        pool.rebind(_token, newBalance, updatedDenorm);
        IERC20(_token).safeTransfer(msg.sender, _amount);
    }

    ///////////////////////// View
    function balanceOf(address _token) public view returns(uint256 balance) {
        balance = IERC20(_token).balanceOf(address(this));
        if (pool.isBound(_token)) {
            balance = balance.add(pool.getBalance(_token));
        }
    }
}