/**
 *Submitted for verification at Etherscan.io on 2019-08-04
*/

pragma solidity ^0.5.0;
pragma experimental ABIEncoderV2;

/**
 * @dev Interface of the ERC20 standard as defined in the EIP. Does not include
 * the optional functions; to access them see `ERC20Detailed`.
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
 * @dev Optional functions from the ERC20 standard.
 */
contract ERC20Detailed is IERC20 {
    string private _name;
    string private _symbol;
    uint8 private _decimals;

    /**
     * @dev Sets the values for `name`, `symbol`, and `decimals`. All three of
     * these values are immutable: they can only be set once during
     * construction.
     */
    constructor (string memory name, string memory symbol, uint8 decimals) public {
        _name = name;
        _symbol = symbol;
        _decimals = decimals;
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
     * Ether and Wei.
     *
     * > Note that this information is only used for _display_ purposes: it in
     * no way affects any of the arithmetic of the contract, including
     * `IERC20.balanceOf` and `IERC20.transfer`.
     */
    function decimals() public view returns (uint8) {
        return _decimals;
    }
}

/**
 * @dev Implementation of the `IERC20` interface.
 *
 * This implementation is agnostic to the way tokens are created. This means
 * that a supply mechanism has to be added in a derived contract using `_mint`.
 * For a generic mechanism see `ERC20Mintable`.
 *
 * *For a detailed writeup see our guide [How to implement supply
 * mechanisms](https://forum.zeppelin.solutions/t/how-to-implement-erc20-supply-mechanisms/226).*
 *
 * We have followed general OpenZeppelin guidelines: functions revert instead
 * of returning `false` on failure. This behavior is nonetheless conventional
 * and does not conflict with the expectations of ERC20 applications.
 *
 * Additionally, an `Approval` event is emitted on calls to `transferFrom`.
 * This allows applications to reconstruct the allowance for all accounts just
 * by listening to said events. Other implementations of the EIP may not emit
 * these events, as it isn't required by the specification.
 *
 * Finally, the non-standard `decreaseAllowance` and `increaseAllowance`
 * functions have been added to mitigate the well-known issues around setting
 * allowances. See `IERC20.approve`.
 */
contract ERC20 is IERC20 {
    using SafeMath for uint256;

    mapping (address => uint256) private _balances;

    mapping (address => mapping (address => uint256)) private _allowances;

    uint256 private _totalSupply;

    /**
     * @dev See `IERC20.totalSupply`.
     */
    function totalSupply() public view returns (uint256) {
        return _totalSupply;
    }

    /**
     * @dev See `IERC20.balanceOf`.
     */
    function balanceOf(address account) public view returns (uint256) {
        return _balances[account];
    }

    /**
     * @dev See `IERC20.transfer`.
     *
     * Requirements:
     *
     * - `recipient` cannot be the zero address.
     * - the caller must have a balance of at least `amount`.
     */
    function transfer(address recipient, uint256 amount) public returns (bool) {
        _transfer(msg.sender, recipient, amount);
        return true;
    }

    /**
     * @dev See `IERC20.allowance`.
     */
    function allowance(address owner, address spender) public view returns (uint256) {
        return _allowances[owner][spender];
    }

    /**
     * @dev See `IERC20.approve`.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     */
    function approve(address spender, uint256 value) public returns (bool) {
        _approve(msg.sender, spender, value);
        return true;
    }

    /**
     * @dev See `IERC20.transferFrom`.
     *
     * Emits an `Approval` event indicating the updated allowance. This is not
     * required by the EIP. See the note at the beginning of `ERC20`;
     *
     * Requirements:
     * - `sender` and `recipient` cannot be the zero address.
     * - `sender` must have a balance of at least `value`.
     * - the caller must have allowance for `sender`'s tokens of at least
     * `amount`.
     */
    function transferFrom(address sender, address recipient, uint256 amount) public returns (bool) {
        _transfer(sender, recipient, amount);
        _approve(sender, msg.sender, _allowances[sender][msg.sender].sub(amount));
        return true;
    }

    /**
     * @dev Atomically increases the allowance granted to `spender` by the caller.
     *
     * This is an alternative to `approve` that can be used as a mitigation for
     * problems described in `IERC20.approve`.
     *
     * Emits an `Approval` event indicating the updated allowance.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     */
    function increaseAllowance(address spender, uint256 addedValue) public returns (bool) {
        _approve(msg.sender, spender, _allowances[msg.sender][spender].add(addedValue));
        return true;
    }

    /**
     * @dev Atomically decreases the allowance granted to `spender` by the caller.
     *
     * This is an alternative to `approve` that can be used as a mitigation for
     * problems described in `IERC20.approve`.
     *
     * Emits an `Approval` event indicating the updated allowance.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     * - `spender` must have allowance for the caller of at least
     * `subtractedValue`.
     */
    function decreaseAllowance(address spender, uint256 subtractedValue) public returns (bool) {
        _approve(msg.sender, spender, _allowances[msg.sender][spender].sub(subtractedValue));
        return true;
    }

    /**
     * @dev Moves tokens `amount` from `sender` to `recipient`.
     *
     * This is internal function is equivalent to `transfer`, and can be used to
     * e.g. implement automatic token fees, slashing mechanisms, etc.
     *
     * Emits a `Transfer` event.
     *
     * Requirements:
     *
     * - `sender` cannot be the zero address.
     * - `recipient` cannot be the zero address.
     * - `sender` must have a balance of at least `amount`.
     */
    function _transfer(address sender, address recipient, uint256 amount) internal {
        require(sender != address(0), "ERC20: transfer from the zero address");
        require(recipient != address(0), "ERC20: transfer to the zero address");

        _balances[sender] = _balances[sender].sub(amount);
        _balances[recipient] = _balances[recipient].add(amount);
        emit Transfer(sender, recipient, amount);
    }

    /** @dev Creates `amount` tokens and assigns them to `account`, increasing
     * the total supply.
     *
     * Emits a `Transfer` event with `from` set to the zero address.
     *
     * Requirements
     *
     * - `to` cannot be the zero address.
     */
    function _mint(address account, uint256 amount) internal {
        require(account != address(0), "ERC20: mint to the zero address");

        _totalSupply = _totalSupply.add(amount);
        _balances[account] = _balances[account].add(amount);
        emit Transfer(address(0), account, amount);
    }

     /**
     * @dev Destoys `amount` tokens from `account`, reducing the
     * total supply.
     *
     * Emits a `Transfer` event with `to` set to the zero address.
     *
     * Requirements
     *
     * - `account` cannot be the zero address.
     * - `account` must have at least `amount` tokens.
     */
    function _burn(address account, uint256 value) internal {
        require(account != address(0), "ERC20: burn from the zero address");

        _totalSupply = _totalSupply.sub(value);
        _balances[account] = _balances[account].sub(value);
        emit Transfer(account, address(0), value);
    }

    /**
     * @dev Sets `amount` as the allowance of `spender` over the `owner`s tokens.
     *
     * This is internal function is equivalent to `approve`, and can be used to
     * e.g. set automatic allowances for certain subsystems, etc.
     *
     * Emits an `Approval` event.
     *
     * Requirements:
     *
     * - `owner` cannot be the zero address.
     * - `spender` cannot be the zero address.
     */
    function _approve(address owner, address spender, uint256 value) internal {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        _allowances[owner][spender] = value;
        emit Approval(owner, spender, value);
    }

    /**
     * @dev Destoys `amount` tokens from `account`.`amount` is then deducted
     * from the caller's allowance.
     *
     * See `_burn` and `_approve`.
     */
    function _burnFrom(address account, uint256 amount) internal {
        _burn(account, amount);
        _approve(account, msg.sender, _allowances[account][msg.sender].sub(amount));
    }
}

/**
 * @dev Contract module which provides a basic access control mechanism, where
 * there is an account (an owner) that can be granted exclusive access to
 * specific functions.
 *
 * This module is used through inheritance. It will make available the modifier
 * `onlyOwner`, which can be aplied to your functions to restrict their use to
 * the owner.
 */


// Compound finance ERC20 market interface


// Compound finance comptroller


/**
 * @title CompoundPool
 * @author Nate Welch <github.com/flyging>
 * @notice Based on Zefram Lou's implementation https://github.com/ZeframLou/pooled-cdai
 * @dev A bank that will pool compound tokens and allows the beneficiary to withdraw
 */
contract CompoundPool is ERC20, ERC20Detailed, Ownable {
    using SafeMath for uint;

    uint256 internal constant PRECISION = 10 ** 18;

    ICompoundERC20 public compoundToken;
    IERC20 public depositToken;
    address public governance;
    address public beneficiary;

    /**
     * @notice Constructor
     * @param _name name of the pool share token
     * @param _symbol symbol of the pool share token
     * @param _comptroller the Compound Comptroller contract used to enter the compoundToken's market
     * @param _compoundToken the Compound Token contract (e.g. cDAI)
     * @param _depositToken the Deposit Token contract (e.g. DAI)
     * @param _beneficiary the address that can withdraw excess deposit tokens (interest/donations)
     */
    constructor(
        string memory _name,
        string memory _symbol,
        IComptroller _comptroller,
        ICompoundERC20 _compoundToken,
        IERC20 _depositToken,
        address _beneficiary
    )
        ERC20Detailed(_name, _symbol, 18)
        public
    {
        compoundToken = _compoundToken;
        depositToken = _depositToken;
        beneficiary = _beneficiary;

        _approveDepositToken(1);

        // Enter compound token market
        address[] memory markets = new address[](1);
        markets[0] = address(compoundToken);
        uint[] memory errors = _comptroller.enterMarkets(markets);
        require(errors[0] == 0, "Failed to enter compound token market");
    }

    /**
     * @dev used to restrict access of functions to the current beneficiary
     */
    modifier onlyBeneficiary() {
        require(msg.sender == beneficiary, "CompoundPool::onlyBeneficiary: Only callable by beneficiary");
        _;
    }

    /**
     * @notice Called by the `owner` to set a new beneficiary
     * @dev This function will fail if called by a non-owner address
     * @param _newBeneficiary The address that will become the new beneficiary
     */
    function updateBeneficiary(address _newBeneficiary) public onlyOwner {
        beneficiary = _newBeneficiary;
    }

    /**
     * @notice The beneficiary calls this function to withdraw excess deposit tokens
     * @dev This function will fail if called by a non-beneficiary or if _amount is higher than the excess deposit tokens
     * @param _to The address that the deposit tokens will be sent to
     * @param _amount The amount of deposit tokens to send to the `_to` address
     */
    function withdrawInterest(address _to, uint256 _amount) public onlyBeneficiary returns (uint256) {
        require(compoundToken.redeemUnderlying(_amount) == 0, "CompoundPool::withdrawInterest: Compound redeem failed");

        //Doing this *after* `redeemUnderlying` so I don't have compoundToken do `exchangeRateCurrent` twice, it's not cheap
        require(depositTokenStoredBalance() >= totalSupply(), "CompoundPool::withdrawInterest: Not enough excess deposit token");

        depositToken.transfer(_to, _amount);
    }

    /**
     * @notice Called by someone wishing to deposit to the bank. This amount, plus previous user's balance, will always be withdrawable
     * @dev Allowance for CompoundPool to transferFrom the msg.sender's balance must be set on the deposit token
     * @param _amount The amount of deposit tokens to deposit
     */
    function deposit(uint256 _amount) public {
        require(depositToken.transferFrom(msg.sender, address(this), _amount), "CompoundPool::deposit: Transfer failed");

        _approveDepositToken(_amount);

        require(compoundToken.mint(_amount) == 0, "CompoundPool::deposit: Compound mint failed");
    
        _mint(msg.sender, _amount);
    }

    /**
     * @notice Called by someone wishing to withdraw from the bank
     * @dev This will fail if msg.sender doesn't have at least _amount pool share tokens
     * @param _amount The amount of deposit tokens to withdraw
     */
    function withdraw(uint256 _amount) public {
        _burn(msg.sender, _amount);

        require(compoundToken.redeemUnderlying(_amount) == 0, "CompoundPool::withdraw: Compound redeem failed");

        require(depositToken.transfer(msg.sender, _amount), "CompoundPool::withdraw: Transfer failed");
    }

    /**
     * @notice Called by someone wishing to donate to the bank. This amount will *not* be added to users balance, and will be usable by the beneficiary.
     * @dev Allowance for CompoundPool to transferFrom the msg.sender's balance must be set on the deposit token
     * @param _amount The amount of deposit tokens to donate
     */
    function donate(uint256 _amount) public {
        require(depositToken.transferFrom(msg.sender, address(this), _amount), "CompoundPool::donate: Transfer failed");

        _approveDepositToken(_amount);

        require(compoundToken.mint(_amount) == 0, "CompoundPool::donate: Compound mint failed");
    }

    /**
     * @notice Returns the amount of deposit tokens that are usable by the beneficiary. Basically, interestEarned+donations
     * @dev Allowance for CompoundPool to transferFrom the msg.sender's balance must be set on the deposit token
     */
    function excessDepositTokens() public returns (uint256) {
        return compoundToken.exchangeRateCurrent().mul(compoundToken.balanceOf(address(this))).div(PRECISION).sub(totalSupply());
    }

    function depositTokenStoredBalance() internal returns (uint256) {
        return compoundToken.exchangeRateStored().mul(compoundToken.balanceOf(address(this))).div(PRECISION);
    }

    function _approveDepositToken(uint256 _minimum) internal {
        if(depositToken.allowance(address(this), address(compoundToken)) < _minimum){
            depositToken.approve(address(compoundToken),uint256(0xffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff));
        }
    }
}

contract IHumanityRegistry {
    function isHuman(address who) public view returns (bool);
}

/**
 * @title UniversalBasicIncome
 * @dev Dai that can be claimed by humans on the Human Registry.
 */
contract UniversalBasicIncome {
    using SafeMath for uint;

    IHumanityRegistry public registry;
    IERC20 public dai;
    CompoundPool public bank;

    uint public constant MONTHLY_INCOME = 1e18; // 1 Dai
    uint public constant INCOME_PER_SECOND = MONTHLY_INCOME / 30 days;

    mapping (address => uint) public claimTimes;

    constructor(IHumanityRegistry _registry, IERC20 _dai, CompoundPool _bank) public {
        registry = _registry;
        dai = _dai;
        bank = _bank;
    }

    function claim() public {
        require(registry.isHuman(msg.sender), "UniversalBasicIncome::claim: You must be on the Humanity registry to claim income");

        uint income;
        uint time = block.timestamp;

        // If claiming for the first time, send 1 month of UBI
        if (claimTimes[msg.sender] == 0) {
            income = MONTHLY_INCOME;
        } else {
            income = time.sub(claimTimes[msg.sender]).mul(INCOME_PER_SECOND);
        }

        uint balance = bank.excessDepositTokens();
        // If not enough Dai reserves, send the remaining balance
        uint actualIncome = balance < income ? balance : income;

        bank.withdrawInterest(msg.sender, actualIncome);
        claimTimes[msg.sender] = time;
    }

    function claimableBalance(address human) public returns (uint256) {
        if(!registry.isHuman(human)){
            return 0;
        }
        uint income;
        uint time = block.timestamp;

        // If claiming for the first time, send 1 month of UBI
        if (claimTimes[human] == 0) {
            income = MONTHLY_INCOME;
        } else {
            income = time.sub(claimTimes[human]).mul(INCOME_PER_SECOND);
        }

        uint balance = bank.excessDepositTokens();
        // If not enough Dai reserves, use the remaining amount
        return balance < income ? balance : income;

    }

}