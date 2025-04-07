/**
 *Submitted for verification at Etherscan.io on 2020-12-03
*/

// SPDX-License-Identifier: MIT
pragma solidity >=0.6.12;



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
 * @dev Contract module which provides a basic access control mechanism, where
 * there is an account (an owner) that can be granted exclusive access to
 * specific functions.
 *
 * By default, the owner account will be the one that deploys the contract. This
 * can later be changed with {transferOwnership}.
 *
 * This module is used through inheritance. It will make available the modifier
 * `onlyOwner`, which can be applied to your functions to restrict their use to
 * the owner.
 */
contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    constructor () internal {
        address msgSender = _msgSender();
        _owner = msgSender;
        emit OwnershipTransferred(address(0), msgSender);
    }

    /**
     * @dev Returns the address of the current owner.
     */
    function owner() public view returns (address) {
        return _owner;
    }

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        require(_owner == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    /**
     * @dev Leaves the contract without owner. It will not be possible to call
     * `onlyOwner` functions anymore. Can only be called by the current owner.
     *
     * NOTE: Renouncing ownership will leave the contract without an owner,
     * thereby removing any functionality that is only available to the owner.
     */
    function renounceOwnership() public virtual onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}

/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
 */


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

contract CarmaToken is ERC20("Carma", "CARMA"), Ownable {
    mapping(address => bool) private _minters;

    constructor() public {
        _minters[_msgSender()] = true;
    }

    function setMinter(address _address, bool _isMinter) external onlyOwner {
        _minters[_address] = _isMinter;
    }

    function mint(address _to, uint256 _amount) external {
        require(_minters[_msgSender()], "Not a minter!");
        _mint(_to, _amount);
    }

    /**
     * @dev Destroys `amount` tokens from the caller.
     *
     * See {TRC20-_burn}.
     */
    function burn(uint256 amount) external {
        _burn(_msgSender(), amount);
    }

    /**
     * @dev Destroys `amount` tokens from `account`, deducting from the caller's
     * allowance.
     *
     * See {TRC20-_burn} and {TRC20-allowance}.
     *
     * Requirements:
     *
     * - the caller must have allowance for ``accounts``'s tokens of at least
     * `amount`.
     */
    function burnFrom(address account, uint256 amount) external {
        uint256 decreasedAllowance = allowance(account, _msgSender()).sub(
            amount,
            "ERC20: burn amount exceeds allowance"
        );

        _approve(account, _msgSender(), decreasedAllowance);
        _burn(account, amount);
    }
}


contract xCombToken is ERC20("Combine.finance Vault Token", "xCOMB"), Ownable {
    mapping(address => bool) private _minters;

    constructor() public {
        _minters[_msgSender()] = true;
    }

    function setMinter(address _address, bool _isMinter) external onlyOwner {
        _minters[_address] = _isMinter;
    }

    function mint(address _to, uint256 _amount) external {
        require(_minters[_msgSender()], "Not a minter!");
        _mint(_to, _amount);
    }

    /**
     * @dev Destroys `amount` tokens from the caller.
     *
     * See {TRC20-_burn}.
     */
    function burn(uint256 amount) external {
        _burn(_msgSender(), amount);
    }

    /**
     * @dev Destroys `amount` tokens from `account`, deducting from the caller's
     * allowance.
     *
     * See {TRC20-_burn} and {TRC20-allowance}.
     *
     * Requirements:
     *
     * - the caller must have allowance for ``accounts``'s tokens of at least
     * `amount`.
     */
    function burnFrom(address account, uint256 amount) external {
        uint256 decreasedAllowance = allowance(account, _msgSender()).sub(
            amount,
            "ERC20: burn amount exceeds allowance"
        );

        _approve(account, _msgSender(), decreasedAllowance);
        _burn(account, amount);
    }
}

contract CarmaMaster {
    using SafeMath for uint256;

    struct UserInfo {
        uint256 stake;
        uint256 lastRewardBlock;
    }

    xCombToken public xcomb;
    CarmaToken public carma;

    uint256 MAX_INT = 115792089237316195423570985008687907853269984665640564039457584007913129639935;

    address private COMB_ETH_PAIR = address(
        0x6e168d4fD7569EA1C56d985256cd2E93ee12490e // mainnet
        // 0x39444e8Ee494c6212054CFaDF67abDBE97e70207 // ropsten
    );

    IUniswapV2ERC20 public wethToken = IUniswapV2ERC20(
        0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2 // mainnet
        // 0xc778417E063141139Fce010982780140Aa0cD5Ab // ropsten
    );

    IUniswapV2ERC20 public combToken = IUniswapV2ERC20(
        0x7d36cCe46DD2B0D28dde12A859C2ACe4a21E3678 // mainnet
        // 0xb93152b59e65a6De8D3464061BcC1d68f6749F98 // ropsten
    );

    IUniswapV2Router02 private UniswapV2Router02 = IUniswapV2Router02(
        0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D //mainnet
        // 0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D // ropsten
    );

    uint256 constant CARMA_PER_LP = 1693766930000000;

    uint256 public lastMintBlock = block.number;

    uint256 public totalStaked = 0;

    mapping(address => UserInfo) public users;

    constructor(CarmaToken _carma, xCombToken _xcomb) public {
        carma = _carma;
        xcomb = _xcomb;

        combToken.approve(address(UniswapV2Router02), MAX_INT);
    }

    receive() external payable {
        if (msg.sender != address(UniswapV2Router02)) {
            stake(0);
        }
    }

    // Lock ETH
    function stake(uint256 _amountOutMin) public payable {
        require(msg.value > 0, "amount can not be 0");
        require(_amountOutMin >= 0, "amount can not be negative");

        uint256 ethAmount = msg.value.div(2);

        address[] memory path = new address[](2);
        path[0] = address(wethToken);
        path[1] = address(combToken);

        UniswapV2Router02.swapExactETHForTokens{value: ethAmount}(
            _amountOutMin,
            path,
            address(this),
            block.timestamp + 60
        );
        
        uint256 amountTokenDesired = address(this).balance.mul(combToken.balanceOf(COMB_ETH_PAIR)).div(wethToken.balanceOf(COMB_ETH_PAIR));
        uint256 combBalance = combToken.balanceOf(address(this));
        if (amountTokenDesired > combBalance) {
            amountTokenDesired = combBalance;
        }

        (, , uint256 liquidity) = UniswapV2Router02.addLiquidityETH{
            value: address(this).balance
        }(
            address(combToken),
            amountTokenDesired,
            0,
            0,
            address(this),
            block.timestamp + 60
        );

        // Refund COMB if left any
        combToken.transfer(msg.sender, combToken.balanceOf(address(this)));

        // Refund ETH if left any
        msg.sender.transfer(address(this).balance);

        _addUserStake(msg.sender, liquidity);
    }

    // Lock COM-ETH LP tokens directly
    function addLPToken(uint256 _amount) public {
        require(_amount > 0, "Amount can not be 0");

        IUniswapV2ERC20(COMB_ETH_PAIR).transferFrom(
            msg.sender,
            address(this),
            _amount
        );

        _addUserStake(msg.sender, _amount);
    }

    // Get user's pending reward
    function pendingReward(address _address) public view returns (uint256) {
        UserInfo memory user = users[_address];
        return user.stake.mul(block.number.sub(user.lastRewardBlock)).mul(CARMA_PER_LP).div(1 ether);
    }

    // Mint CARMA and transfer reward
    function claimReward() external {
        _mintCarma();
        _claimReward();
    }

    // Sends Pending CARMA to the user
    function _addUserStake(address _address, uint256 _amount) internal {
        _mintCarma();

        if (users[_address].stake > 0) {
            _claimReward();
        }

        totalStaked = totalStaked.add(_amount);

        xcomb.mint(_address, _amount);
        users[_address].stake = users[_address].stake.add(_amount);
        users[_address].lastRewardBlock = block.number;
    }

    // Mints required amount of CARMA tokens to transfer to the stakers later
    function _mintCarma() internal {
        uint256 blocksPassed = block.number.sub(lastMintBlock);
        if (blocksPassed == 0) {
            return;
        }
        carma.mint(
            address(this),
            blocksPassed.mul(CARMA_PER_LP).mul(totalStaked)
        );
        lastMintBlock = block.number;
    }

    // Sends Pending CARMA to the user
    function _claimReward() internal {
        _safeCarmaTransfer(msg.sender, pendingReward(msg.sender));
        users[msg.sender].lastRewardBlock = block.number;
    }

    // Safe CARMA transfer to avoid rounding errors
    function _safeCarmaTransfer(address _to, uint256 _amount) internal {
        uint256 bal = carma.balanceOf(address(this));
        if (_amount > bal) {
            carma.transfer(_to, bal);
        } else {
            carma.transfer(_to, _amount);
        }
    }
}