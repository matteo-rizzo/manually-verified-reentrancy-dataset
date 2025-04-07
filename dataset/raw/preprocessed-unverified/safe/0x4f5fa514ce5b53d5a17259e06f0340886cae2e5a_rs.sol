/**
 *Submitted for verification at Etherscan.io on 2021-03-15
*/

//SPDX-License-Identifier: SimPL-2.0
pragma solidity ^0.6.0;







contract TokenYouTest is Ownable, ITokenYou {
    using SafeMath for uint256;

    string private constant _name = 'YouSwap';
    string private constant _symbol = 'YOU';
    uint8 private constant _decimals = 6;
    uint256 private _totalSupply;
    uint256 private _transfers;
    uint256 private _holders;
    uint256 private _maxSupply;
    mapping(address => uint256) private _balanceOf;
    mapping(address => mapping(address => uint256)) private _allowances;

    mapping(address => uint8) private _minters;

    constructor() public {
        _totalSupply = 0;
        _transfers = 0;
        _holders = 0;
        _maxSupply = 2 * 10 ** 14;
    }

    /**
      * @dev Returns the name of the token.
      */
    function name() public pure returns (string memory) {
        return _name;
    }

    /**
     * @dev Returns the symbol of the token, usually a shorter version of the
     * name.
     */
    function symbol() public pure returns (string memory) {
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
     * {ITokenYou-balanceOf} and {ITokenYou-transfer}.
     */
    function decimals() public pure returns (uint8) {
        return _decimals;
    }

    /**
     * @dev See {ITokenYou-totalSupply}.
     */
    function totalSupply() public view override returns (uint256) {
        return _totalSupply;
    }

    /**
   * @dev See {ITokenYou-maxSupply}.
   */
    function maxSupply() public view returns (uint256) {
        return _maxSupply;
    }

    function transfers() public view returns (uint256) {
        return _transfers;
    }

    function holders() public view returns (uint256) {
        return _holders;
    }

    /**
     * @dev See {ITokenYou-balanceOf}.
     */
    function balanceOf(address account) public view override returns (uint256) {
        return _balanceOf[account];
    }

    /**
     * @dev See {ITokenYou-transfer}.
     *
     * Requirements:
     *
     * - `recipient` cannot be the zero address.
     * - the caller must have a balance of at least `amount`.
     */
    function transfer(address recipient, uint256 amount) public virtual override returns (bool) {
        _transfer(msg.sender, recipient, amount);
        return true;
    }

    /**
     * @dev See {ITokenYou-allowance}.
     */
    function allowance(address owner, address spender) public view virtual override returns (uint256) {
        return _allowances[owner][spender];
    }

    /**
     * @dev See {ITokenYou-approve}.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     */
    function approve(address spender, uint256 amount) public override returns (bool) {
        _approve(msg.sender, spender, amount);
        return true;
    }

    /**
     * @dev See {ITokenYou-transferFrom}.
     *
     * Emits an {Approval} event indicating the updated allowance. This is not
     * required by the EIP. See the note at the beginning of {ERC20}.
     *
     * Requirements:
     *
     * - `sender` and `recipient` cannot be the zero address.
     * - `sender` must have a balance of at least `amount`.
     * - the caller must have allowance for ``sender``'s tokens of at least
     * `amount`.
     */
    function transferFrom(address sender, address recipient, uint256 amount) public override returns (bool) {
        _transfer(sender, recipient, amount);
        _approve(sender, msg.sender, _allowances[sender][msg.sender].sub(amount, "YouSwap: TRANSFER_AMOUNT_EXCEEDS_ALLOWANCE"));
        return true;
    }

    /**
     * @dev Atomically increases the allowance granted to `spender` by the caller.
     *
     * This is an alternative to {approve} that can be used as a mitigation for
     * problems described in {ITokenYou-approve}.
     *
     * Emits an {Approval} event indicating the updated allowance.
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
     * This is an alternative to {approve} that can be used as a mitigation for
     * problems described in {ITokenYou-approve}.
     *
     * Emits an {Approval} event indicating the updated allowance.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     * - `spender` must have allowance for the caller of at least
     * `subtractedValue`.
     */
    function decreaseAllowance(address spender, uint256 subtractedValue) public returns (bool) {
        _approve(msg.sender, spender, _allowances[msg.sender][spender].sub(subtractedValue, "YouSwap: DECREASED_ALLOWANCE_BELOW_ZERO"));
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
    function _transfer(address sender, address recipient, uint256 amount) internal {
        require(sender != address(0), "YouSwap: TRANSFER_FROM_THE_ZERO_ADDRESS");
        require(recipient != address(0), "YouSwap: TRANSFER_TO_THE_ZERO_ADDRESS");
        require(amount > 0, "YouSwap: TRANSFER_ZERO_AMOUNT");

        if (_balanceOf[recipient] == 0) _holders++;

        _balanceOf[sender] = _balanceOf[sender].sub(amount, "YouSwap: TRANSFER_AMOUNT_EXCEEDS_BALANCE");
        _balanceOf[recipient] = _balanceOf[recipient].add(amount);

        _transfers ++;

        if (_balanceOf[sender] == 0) _holders--;

        emit Transfer(sender, recipient, amount);
    }

    /**
     * @dev Destroys `amount` tokens from `account`, reducing the
     * total supply.
     *
     * Emits a {Transfer} event with `to` set to the zero address.
     *
     * Requirements:
     *
     * - `account` cannot be the zero address.
     * - `account` must have at least `amount` tokens.
     */
    function _burn(address account, uint256 amount) internal {
        require(account != address(0), "YouSwap: BURN_FROM_THE_ZERO_ADDRESS");

        _balanceOf[account] = _balanceOf[account].sub(amount, "YouSwap: BURN_AMOUNT_EXCEEDS_BALANCE");
        if (_balanceOf[account] == 0) _holders --;
        _totalSupply = _totalSupply.sub(amount);
        _transfers++;
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
    function _approve(address owner, address spender, uint256 amount) internal {
        require(owner != address(0), "YouSwap: APPROVE_FROM_THE_ZERO_ADDRESS");
        require(spender != address(0), "YouSwap: APPROVE_TO_THE_ZERO_ADDRESS");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    /**
     * @dev Destroys `amount` tokens from the caller.
     *
     * See {TokenYou-_burn}.
     */
    function burn(uint256 amount) external override {
        _burn(msg.sender, amount);
    }

    /**
     * @dev Destroys `amount` tokens from `account`, deducting from the caller's
     * allowance.
     *
     * See {TokenYou-_burn} and {TokenYou-allowance}.
     *
     * Requirements:
     *
     * - the caller must have allowance for ``accounts``'s tokens of at least
     * `amount`.
     */
    function burnFrom(address account, uint256 amount) external override {
        uint256 decreasedAllowance = allowance(account, msg.sender).sub(amount, "YouSwap: BURN_AMOUNT_EXCEEDS_ALLOWANCE");

        _approve(account, msg.sender, decreasedAllowance);
        _burn(account, amount);
    }

    modifier isMinter() {
        require(_minters[msg.sender] == 1, "YouSwap: IS_NOT_A_MINTER");
        _;
    }

    function isContract(address account) internal view returns (bool) {
        uint256 size;
        assembly {size := extcodesize(account)}
        return size > 0;
    }

    function mint(address recipient, uint256 amount) external override isMinter {
        require(_totalSupply.add(amount) <= _maxSupply, 'YouSwap: EXCEEDS_MAX_SUPPLY');
        _totalSupply = _totalSupply.add(amount);

        if (_balanceOf[recipient] == 0) _holders++;
        _balanceOf[recipient] = _balanceOf[recipient].add(amount);

        _transfers++;
        emit Transfer(address(0), recipient, amount);
    }

    function addMinter(address account) external onlyOwner {
        require(isContract(account), "YouSwap: MUST_BE_A_CONTRACT_ADDRESS");
        _minters[account] = 1;
    }

    function removeMinter(address account) external onlyOwner {
        _minters[account] = 0;
    }

    function resetMaxSupply(uint256 newValue) external override onlyOwner {
        require(newValue > _totalSupply && newValue < _maxSupply, 'YouSwap: NOT_ALLOWED');
        emit MaxSupplyChanged(_maxSupply, newValue);
        _maxSupply = newValue;
    }
}