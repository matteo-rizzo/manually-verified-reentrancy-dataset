/**
 *Submitted for verification at Etherscan.io on 2020-10-15
*/

pragma solidity ^0.6.2;

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
 * @dev Interface of the ERC20 standard as defined in the EIP.
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
        revert("Transfers are not allowed");

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

contract ETHSteps is ERC20, Ownable {
    address public stepMarket;

    constructor()
    ERC20("CoinClash", "CoC")
    public {}

    function init(address _stepMarket) public onlyOwner {
        stepMarket = _stepMarket;
    }

    /**
     * mint tokens to user
     * @param  _to address token receiver
     * @param _value uint256 amount of tokens for mint
     */
    function mint(address _to, uint256 _value) public {
        require(msg.sender == stepMarket, "address not stepmarket");
        _mint(_to, _value);
    }

    /**
     * burn tokens from user
     * @param _from address address of user for burning
     * @param _value uint256 amount of tokens for burn
     */
    function burnFrom(address _from, uint256 _value) public {
        require(msg.sender == stepMarket, "address not stepmarket");
        _burn(_from, _value);
    }
}

contract ETHStepMarket is Ownable {
    using SafeMath for uint256;

    mapping(address => uint256) public percentages;
    address[] public admins;
    ETHSteps public stepAddress;
    uint256 public adminPart;
    uint256 public treasurePart;
    uint256 public commissionPart;

    /**
     * event of success airdrop of coc tokens
     */
    event WithdrawAdminProcessed(
        address caller,
        uint256 amount,
        uint256 timestamp
    );
    event AdminAddressAdded(
        address newAddress,
        uint256 percentage
    );
    event AdminAddressRemoved(
        address oldAddress
    );
    event AdminPercentageChanged(
        address admin,
        uint256 newPercentage
    );
    event StepsAirdropped(
        address indexed user,
        uint256 amount
    );
    event AirdropDeposited(
        address indexed user,
        uint256 amount
    );
    event StepsBoughtViaEth(
        address indexed user,
        uint256 ethAmount
    );
    event TreasureAdded(uint256 amount);
    event WithdrawEmitted(address indexed user);
    event EmitInternalDrop(address indexed user);
    event AccessChanged(bool status);

    function init(address _stepAddress) public onlyOwner {
        stepAddress = ETHSteps(_stepAddress);
    }

    /**
     * send free steps to many users as airdrop
     * @param _user address[] receivers address list
     * @param _amount uint256[] amount of tokens for sending
     */
    function airdropToMany(
        address[] memory _user,
        uint256[] memory _amount
    ) public onlyOwner {
        require(_user.length == _amount.length, "Length must be equal");

        for (uint256 i = 0; i < _user.length; i++) {
            stepAddress.mint(_user[i], _amount[i].mul(1 ether));

            emit StepsAirdropped(_user[i], _amount[i].mul(1 ether));
        }
    }

    function sendRewardToMany(
        address[] memory _user,
        uint256[] memory _amount,
        uint256 totaRewardSent
    ) public onlyOwner {
        require(_user.length == _amount.length, "Length must be equal");
        require(treasurePart >= totaRewardSent);

        treasurePart = treasurePart.sub(totaRewardSent);

        for (uint256 i = 0; i < _user.length; i++) {
            address(uint160(_user[i])).transfer(_amount[i]);
        }
    }

    function receiveCommission() public onlyOwner {
        require(commissionPart > 0);

        uint256 value = commissionPart;
        commissionPart = 0;

        msg.sender.transfer(value);
    }

    function getInternalAirdrop() public {
        stepAddress.mint(msg.sender, 1 ether);
        stepAddress.burnFrom(msg.sender, 1 ether);

        emit EmitInternalDrop(msg.sender);
    }

    function buySteps() public payable {
        require(msg.value != 0, "value can't be 0");

        stepAddress.mint(msg.sender, msg.value);
        stepAddress.burnFrom(msg.sender, msg.value);

        adminPart = adminPart.add(msg.value.mul(80).div(100));
        treasurePart = treasurePart.add(msg.value.mul(20).div(100));

        emit StepsBoughtViaEth(
            msg.sender,
            msg.value
        );
    }

    function depositToGame() public {
        require(stepAddress.balanceOf(msg.sender) != 0, "No tokens for deposit");

        emit AirdropDeposited(
            msg.sender,
            stepAddress.balanceOf(msg.sender)
        );

        stepAddress.burnFrom(msg.sender, stepAddress.balanceOf(msg.sender));
    }

    function addAdmin(address _admin, uint256 _percentage) public onlyOwner {
        require(percentages[_admin] == 0, "Admin exists");

        admins.push(_admin);
        percentages[_admin] = _percentage;

        emit AdminAddressAdded(
            _admin,
            _percentage
        );
    }

    function addToTreasure() public payable {
        treasurePart = treasurePart.add(msg.value);

        emit TreasureAdded(
            msg.value
        );
    }

    function emitWithdrawal() public payable {
        require(msg.value >= 4 finney);

        commissionPart = commissionPart.add(msg.value);

        emit WithdrawEmitted(
            msg.sender
        );
    }

    function changePercentage(
        address _admin,
        uint256 _percentage
    ) public onlyOwner {
        percentages[_admin] = _percentage;

        emit AdminPercentageChanged(
            _admin,
            _percentage
        );
    }

    function deleteAdmin(address _removedAdmin) public onlyOwner {
        uint256 found = 0;
        for (uint256 i = 0; i < admins.length; i++) {
            if (admins[i] == _removedAdmin) {
                found = i;
            }
        }

        for (uint256 i = found; i < admins.length - 1; i++) {
            admins[i] = admins[i + 1];
        }

        admins.pop();

        percentages[_removedAdmin] = 0;

        emit AdminAddressRemoved(_removedAdmin);
    }

    function withdrawAdmins() public payable {
        uint256 percent = 0;

        uint256 value = adminPart;
        adminPart = 0;

        for (uint256 i = 0; i < admins.length; i++) {
            percent = percent.add(percentages[admins[i]]);
        }

        require(percent == 10000, "Total admin percent must be 10000 or 100,00%");

        for (uint256 i = 0; i < admins.length; i++) {
            uint256 amount = value.mul(percentages[admins[i]]).div(10000);
            address(uint160(admins[i])).transfer(amount);
        }

        emit WithdrawAdminProcessed(
            msg.sender,
            adminPart,
            block.timestamp
        );
    }
}