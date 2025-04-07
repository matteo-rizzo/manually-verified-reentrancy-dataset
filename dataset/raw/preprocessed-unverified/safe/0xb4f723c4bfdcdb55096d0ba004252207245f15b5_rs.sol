/**
 *Submitted for verification at Etherscan.io on 2020-11-18
*/

// SPDX-License-Identifier: MIT
pragma solidity 0.6.12;




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
 * @dev Interface of the ERC20 standard as defined in the EIP.
 */


// File: contracts/utils/Address.sol
/**
 * @dev Collection of functions related to the address type
 */


// File: contracts/token/ERC20/ERC20.sol
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


contract VoxVault is ERC20 {
    using SafeERC20 for IERC20;
    using Address for address;
    using SafeMath for uint256;

    IERC20 public token;
    IERC20 public vox;

    uint256 public min = 9500;
    uint256 public constant max = 10000;

    uint256 public burnFee = 5000;
    uint256 public constant burnFeeMax = 7500;
    uint256 public constant burnFeeMin = 2500;
    uint256 public constant burnFeeBase = 10000;

    bool public isActive = true;

    address public governance;
    address public treasury;
    address public timelock;
    address public strategy;
    address public burn = 0x000000000000000000000000000000000000dEaD;

    mapping(address => uint256) public depositBlocks;
    mapping(address => uint256) public deposits;
    mapping(address => uint256) public tiers;
    uint256[] public multiplierCosts;
    uint256 internal constant tierBase = 100;
    uint256 public totalDeposited = 0;

    // EVENTS
    event Deposit(address indexed user, uint256 amount);
    event Withdraw(address indexed user, uint256 amount);
    event SharesIssued(address indexed user, uint256 amount);
    event SharesPurged(address indexed user, uint256 amount);
    event ClaimRewards(address indexed user, uint256 amount);
    event MultiplierPurchased(address indexed user, uint256 tiers, uint256 totalCost);

    constructor(address _token, address _vox, address _governance, address _treasury, address _timelock)
        public
        ERC20(
            string(abi.encodePacked("voxie ", ERC20(_token).name())),
            string(abi.encodePacked("v", ERC20(_token).symbol()))
        )
    {
        _setupDecimals(ERC20(_token).decimals());
        token = IERC20(_token);
        vox = IERC20(_vox);
        governance = _governance;
        treasury = _treasury;
        timelock = _timelock;
    }

    // Check the total underyling token balance to see if we should earn();
    function balance() public view returns (uint256) {
        return
            token.balanceOf(address(this)).add(
                IStrategy(strategy).balanceOf()
            );
    }

    // Sets whether deposits are accepted by the vault
    function setActive(bool _isActive) public {
        require(msg.sender == governance, "!governance");
        isActive = _isActive;
    }

    // Set the minimum percentage of tokens that can be deposited to earn 
    function setMin(uint256 _min) external {
        require(msg.sender == governance, "!governance");
        require(_min <= max, "numerator cannot be greater than denominator");
        min = _min;
    }

    // Set a new governance address, can only be triggered by the old address
    function setGovernance(address _governance) public {
        require(msg.sender == governance, "!governance");
        governance = _governance;
    }

    // Set the timelock address, can only be triggered by the old address
    function setTimelock(address _timelock) public {
        require(msg.sender == timelock, "!timelock");
        timelock = _timelock;
    }

    // Set a new strategy address, can only be triggered by the timelock
    function setStrategy(address _strategy) public {
        require(msg.sender == timelock, "!timelock");
        require(IStrategy(_strategy).underlying() == address(token), 'strategy does not support this underlying');
        strategy = _strategy;
    }

    // Set the burn fee for multipliers
    function setBurnFee(uint256 _burnFee) public {
        require(msg.sender == timelock, "!timelock");
        require(_burnFee <= burnFeeMax, 'burn fee can not be more than 75,0 %');
        require(_burnFee >= burnFeeMin, 'burn fee can not be less than 25,0 %');
        burnFee = _burnFee;
    }

    // Add a new multplier with the selected cost
    function addMultiplier(uint256 _cost) public returns (uint256 index) {
        require(msg.sender == timelock, "!timelock");
        multiplierCosts.push(_cost);
        index = multiplierCosts.length - 1;
    }

    // Set new cost for multiplier, can only be triggered by the timelock
    function setMultiplier(uint256 index, uint256 _cost) public {
        require(msg.sender == timelock, "!timelock");
        multiplierCosts[index] = _cost;
    }

    // Custom logic in here for how much of the underlying asset can be deposited
    // Sets the minimum required on-hand to keep small withdrawals cheap
    function available() public view returns (uint256) {
        return token.balanceOf(address(this)).mul(min).div(max);
    }

    // Deposits collected underlying assets into the strategy and starts earning
    function earn() public {
        require(isActive, 'vault is not active');
        require(strategy != address(0), 'strategy is not set');
        uint256 _bal = available();
        token.safeTransfer(strategy, _bal);
        IStrategy(strategy).deposit();
    }

    // Deposits underlying assets from the user into the vault contract
    function deposit(uint256 _amount) public {
        require(isActive, 'vault is not active');
        require(strategy != address(0), 'strategy is not yet set');
        uint256 _pool = balance();
        uint256 _before = token.balanceOf(address(this));
        token.safeTransferFrom(msg.sender, address(this), _amount);
        uint256 _after = token.balanceOf(address(this));
        _amount = _after.sub(_before); // Additional check for deflationary tokens
        deposits[msg.sender] = deposits[msg.sender].add(_amount);
        totalDeposited = totalDeposited.add(_amount);
        uint256 shares = 0;
        if (totalSupply() == 0) {
            if (tiers[msg.sender] > 0) {
                uint256 userMultiplier = tiers[msg.sender].add(tierBase);
                shares = _amount.mul(userMultiplier).div(tierBase);
            } else {
                shares = _amount;
            }
        } else {
            if (tiers[msg.sender] > 0) {
                uint256 userMultiplier = tiers[msg.sender].add(tierBase);
                shares = (_amount.mul(userMultiplier).div(tierBase).mul(totalSupply())).div(_pool);
            } else {
                shares = (_amount.mul(totalSupply())).div(_pool);
            }
        }
        _mint(msg.sender, shares);
        depositBlocks[msg.sender] = block.number;
        emit Deposit(msg.sender, _amount);
        emit SharesIssued(msg.sender, shares);
    }

    // Deposits all the funds of the user
    function depositAll() external {
        deposit(token.balanceOf(msg.sender));
    }

    // No rebalance implementation for lower fees and faster swaps
    function withdraw(uint256 _amount) public {
        require(block.number > depositBlocks[msg.sender], 'withdrawals can not happen in the same block as deposits');
        require(_amount > 0, 'please withdraw a positive amount');
        require(_amount <= deposits[msg.sender], 'you can only withdraw up to the amount you have deposited');

        // Calculate amount of rewards the user has gained
        uint256 rewards = balance().sub(totalDeposited);
        uint256 shares = balanceOf(msg.sender);
        uint256 userRewards = 0;
        if (rewards > 0) {
            userRewards = (rewards.mul(shares)).div(totalSupply());
        }

        // Calculate percentage of principal being withdrawn
        uint256 p = (_amount.mul(1e18).div(deposits[msg.sender]));
        // Calculate amount of shares to be burned
        uint256 r = shares.mul(p).div(1e18);
        // Burn the proportion of shares that are being withdrawn
        _burn(msg.sender, r);

        // Receive the correct proportion of the rewards
        if (userRewards > 0) {
            userRewards = userRewards.mul(p).div(1e18);
        }

        // Calculate the withdrawal amount as _amount + user rewards
        uint256 withdrawAmount = _amount.add(userRewards);

        // Check balance
        uint256 b = token.balanceOf(address(this));
        if (b < withdrawAmount) {
            uint256 _withdraw = withdrawAmount.sub(b);
            IStrategy(strategy).withdraw(_withdraw);
            uint256 _after = token.balanceOf(address(this));
            uint256 _diff = _after.sub(b);
            if (_diff < _withdraw) {
                withdrawAmount = b.add(_diff);
            }
        }

        // Remove the withdrawn principal from total and user deposits
        deposits[msg.sender] = deposits[msg.sender].sub(_amount);
        totalDeposited = totalDeposited.sub(_amount);

        token.safeTransfer(msg.sender, withdrawAmount);
        emit Withdraw(msg.sender, _amount);
        emit SharesPurged(msg.sender, r);
        emit ClaimRewards(msg.sender, userRewards);
    }

    // Withdraws all underlying assets belonging to the user
    function withdrawAll() external {
        withdraw(deposits[msg.sender]);
    }

    function pendingRewards(address account) external view returns (uint256) {
        // Calculate amount of rewards the user has gained
        uint256 rewards = balance().sub(totalDeposited);
        uint256 shares = balanceOf(account);
        if (rewards > 0) {
            return (rewards.mul(shares)).div(totalSupply());
        }
    }

    // Purchase a multiplier tier for the user
    function purchaseMultiplier(uint256 _tiers) external returns (uint256 newTier) {
        require(_tiers > 0, 'you need to purchase at least one multiplier');
        uint256 multipliersLength = multiplierCosts.length;
        require(tiers[msg.sender].add(_tiers) <= multipliersLength, 'you can not purchase so many tiers');

        uint256 totalCost = 0;
        uint256 lastMultiplier = tiers[msg.sender].add(_tiers);
        for (uint256 i = tiers[msg.sender]; i < multipliersLength; i++) {
            if (i == lastMultiplier) {
                break;
            }
            totalCost = totalCost.add(multiplierCosts[i]);
        }

        require(IERC20(vox).balanceOf(msg.sender) >= totalCost, 'you do not have enough VOX to purchase the multiplier tiers');
        vox.safeTransferFrom(msg.sender, address(this), totalCost);
        newTier = tiers[msg.sender].add(_tiers);
        tiers[msg.sender] = newTier;
        emit MultiplierPurchased(msg.sender, _tiers, totalCost);
    }

    // Distribute the VOX tokens collected by the multiplier purchases
    function distribute() external {
        require(msg.sender == governance, "!governance");
        uint256 b = vox.balanceOf(address(this));
        if (b > 0) {
            uint256 toBurn = b.mul(burnFee).div(burnFeeBase);
            uint256 leftover = b.sub(toBurn);
            vox.safeTransfer(burn, toBurn);
            vox.safeTransfer(treasury, leftover);
        }
    }

    // Used to salvage any non-underlying assets to the treasury
    function salvage(address reserve, uint256 amount) external {
        require(msg.sender == governance, "!governance");
        require(reserve != address(token), "token");
        require(reserve != address(vox), "vox");
        IERC20(reserve).safeTransfer(treasury, amount);
    }

    // Returns the current multiplier tier for the user
    function getMultiplier() external view returns (uint256) {
        return tiers[msg.sender];
    }

    // Returns the next multiplier tier cost for the user
    function getNextMultiplierCost() external view returns (uint256) {
        require(tiers[msg.sender] < multiplierCosts.length, 'all tiers have already been purchased');
        return multiplierCosts[tiers[msg.sender]];
    }

    // Returns the total number of multipliers
    function getCountOfMultipliers() external view returns (uint256) {
        return multiplierCosts.length;
    }

    // Returns the current ratio between earned assets and deposited assets
    function getRatio() public view returns (uint256) {
        return (balance().sub(totalDeposited)).mul(1e18).div(totalSupply());
    }
}