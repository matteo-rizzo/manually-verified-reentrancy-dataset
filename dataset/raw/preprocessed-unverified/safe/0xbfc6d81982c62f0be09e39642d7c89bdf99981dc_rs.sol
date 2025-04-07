/**
 *Submitted for verification at Etherscan.io on 2021-07-05
*/

/*
 * Copyright Â© 2021 junedog.finance. ALL RIGHTS RESERVED.
 */

pragma solidity ^0.5.0;

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
contract Context {
    // Empty internal constructor, to prevent people from mistakenly deploying
    // an instance of this contract, which should be used via inheritance.
    constructor () internal { }
    // solhint-disable-previous-line no-empty-blocks

    function _msgSender() internal view returns (address payable) {
        return msg.sender;
    }

    function _msgData() internal view returns (bytes memory) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}

/**
 * @dev Interface of the ERC20 standard as defined in the EIP. Does not include
 * the optional functions; to access them see {ERC20Detailed}.
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
 * @dev Contract module which provides a basic access control mechanism, where
 * there is an account (an owner) that can be granted exclusive access to
 * specific functions.
 *
 * This module is used through inheritance. It will make available the modifiers
 * `onlyOwner` and 'onlyPrivileged', which can be applied to your functions to
 * restrict their use to the owner or priviledged respectively. In case ownership
 * is renounced, the modifier 'onlyPrivileged' is provided so certain functions
 * remain operational. Privileged use should only benefit the community.
 */
contract Ownable is Context {
    address private _owner;
    address private _privileged;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev Initializes the contract setting the deployer as the initial owner
     * and privileged.
     */
    constructor () internal {
        _owner = _msgSender();
        _privileged = _msgSender();
        emit OwnershipTransferred(address(0), _owner);
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
        require(isOwner(), "Ownable: caller is not the owner");
        _;
    }

    /**
     * @dev Returns true if the caller is the current owner.
     */
    function isOwner() public view returns (bool) {
        return _msgSender() == _owner;
    }

    /**
     * @dev Returns the address of the current privileged.
     */
    function privileged() public view returns (address) {
        return _privileged;
    }

    /**
     * @dev Throws if called by any account other than privileged.
     */
    modifier onlyPrivileged() {
        require(isPriviledged(), "Ownable: caller is not privileged");
        _;
    }

    /**
     * @dev Returns true if the caller is privileged.
     */
    function isPriviledged() public view returns (bool) {
        return _msgSender() == _privileged;
    }

    /**
     * @dev Leaves the contract without owner. It will not be possible to call
     * `onlyOwner` functions anymore. Can only be called by the current owner.
     * Requires ('currentOwner') to be passed in to make sure not accidentally
     * clicked.
     *
     * NOTE: Renouncing ownership will leave the contract without an owner,
     * thereby removing any functionality that is only available to the owner.
     */
     function renounceOwnership(address currentOwner) public onlyOwner {
         require(currentOwner == _owner, "Ownable: address entered needs to match owner");
         emit OwnershipTransferred(_owner, address(0));
         _owner = address(0);
     }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) public onlyOwner {
        _transferOwnership(newOwner);
    }

    /**
     * @dev Transfers ownership and privileged of the contract to a new
     * account (`newOwner`).
     */
    function _transferOwnership(address newOwner) internal {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        emit OwnershipTransferred(_owner, newOwner);
        _privileged = newOwner; // transfer priviledged
        _owner = newOwner;
    }
}

/**
 * @dev Implementation of the {IERC20} interface for Junedog contract. The
 * above imports are originally from the following and customized as needed:
 * https://github.com/OpenZeppelin/openzeppelin-contracts/blob/release-v2.4.0/contracts/
 *
 * Below here is where the real work is done.
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
contract JUNE is Context, IERC20, Ownable {
    using SafeMath for uint256;

    mapping (address => uint256) private _balances;
    mapping (address => mapping (address => uint256)) private _allowances;
    address[] private _luckyEntries;
    struct LuckyWinners {
        address winner;
        uint256 amount;
    }
    LuckyWinners[] private _luckyWinners;

    string private _name = "Junedog.finance";
    string private _symbol = "JUNE";
    uint256 private _totalSupply;
    uint256 private _decimals = 18;

    uint256 private numTokens = 10000000000000 * (10 ** (uint256(_decimals)));
    uint256 private _maxTransfer = numTokens.div(200); // limit transfers
    uint256 private _burnDenominator = 50; // 2.0%
    uint256 private _luckyDenominator = 200; // 0.5%
    uint256 private _luckyMinimum = _maxTransfer.div(100000);
    uint256 private _luckyMaximum = _maxTransfer.div(100);
    uint256 private _luckyEntriesMinimum = 20;

    /**
     * @dev Constructor.
     */
    constructor () public {
        _mint(_msgSender(), numTokens);
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
     */
    function decimals() public view returns (uint256) {
        return _decimals;
    }

    /**
     * @dev See {IERC20-totalSupply}.
     */
    function totalSupply() public view returns (uint256) {
        return _totalSupply;
    }

    /**
     * @dev See {IERC20-balanceOf}.
     */
    function balanceOf(address account) public view returns (uint256) {
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
    function transfer(address recipient, uint256 amount) public returns (bool) {
        _transfer(_msgSender(), recipient, amount);
        return true;
    }

    /**
     * @dev See {IERC20-allowance}.
     */
    function allowance(address owner, address spender) public view returns (uint256) {
        return _allowances[owner][spender];
    }

    /**
     * @dev See {IERC20-approve}.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     */
    function approve(address spender, uint256 amount) public returns (bool) {
        _approve(_msgSender(), spender, amount);
        return true;
    }

    /**
     * @dev See {IERC20-transferFrom}.
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
    function transferFrom(address sender, address recipient, uint256 amount) public returns (bool) {
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
    function increaseAllowance(address spender, uint256 addedValue) public returns (bool) {
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
    function decreaseAllowance(address spender, uint256 subtractedValue) public returns (bool) {
        _approve(_msgSender(), spender, _allowances[_msgSender()][spender].sub(subtractedValue, "ERC20: decreased allowance below zero"));
        return true;
    }

    /**
     * @dev Returns the '_maxTransfer' amount.
     */
    function maxTransfer() public view returns (uint256) {
        return _maxTransfer;
    }

    /**
     * @dev Returns '_luckyEntries' since last lucky winner pick.
     */
    function luckyEntries() public view returns (address[] memory) {
        return _luckyEntries;
    }

    /**
     * @dev Returns the number of '_luckyEntries' stored.
     */
    function luckyEntriesCount() public view returns (uint256) {
        return _luckyEntries.length;
    }

    /**
     * @dev Resets '_luckyEntries' to empty.
     */
    function resetLuckyEntries() private {
        require(_luckyEntries.length > 0, "Lucky entries must be greater than zero");
        _luckyEntries = new address[](0);
    }

    /**
     * @dev Picks 'newLuckyWinner' from '_luckyEntries' and transfers 'luckyBalance' to them.
     */
    function pickLuckyWinner() public {
        require(_luckyEntries.length >= _luckyEntriesMinimum, "More lucky entries required to pick winner");
        uint index = getRandomish() % _luckyEntries.length;
        address newLuckyWinner = _luckyEntries[index];
        uint256 luckyBalance = balanceOf(privileged());

        require(luckyBalance >= _luckyMinimum, "Lucky balance is less than minimum");
        if (luckyBalance > _luckyMaximum) {
          luckyBalance = _luckyMaximum;
        }

        _transfer(privileged(), newLuckyWinner, luckyBalance);

        LuckyWinners memory lw = LuckyWinners(newLuckyWinner, luckyBalance);
        _luckyWinners.push(lw);

        resetLuckyEntries();
    }

    /**
     * @dev Generates random-ish number and returns it.
     */
    function getRandomish() private view returns (uint) {
        return uint(keccak256(abi.encodePacked(block.difficulty, block.timestamp, _luckyEntries))); //get pseudo random number
    }

    /**
     * @dev Returns the '_luckyMinimum' amount.
     */
    function luckyMinimum() public view returns (uint256) {
        return _luckyMinimum;
    }

    /**
     * @dev Returns the '_luckyMaximum' amount.
     */
    function luckyMaximum() public view returns (uint256) {
        return _luckyMaximum;
    }

    /**
     * @dev Returns the '_luckyEntriesMinimum' amount.
     */
    function luckyEntriesMinimum() public view returns (uint256) {
        return _luckyEntriesMinimum;
    }

    /**
     * @dev Returns the '_luckyWinners' address and amount for 'index'.
     */
    function luckyWinners(uint index) public view returns (address, uint256) {
        require(luckyWinnersCount() >= index + 1, "Invalid entry specified for index, out of range");
        return (
          _luckyWinners[index].winner,
          _luckyWinners[index].amount
        );
    }

    /**
     * @dev Returns the number of '_luckyWinners' picked.
     */
    function luckyWinnersCount() public view returns (uint256) {
        return _luckyWinners.length;
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
        require(sender != address(0), "ERC20: transfer from the zero address");
        require(recipient != address(0), "ERC20: transfer to the zero address");
        require(amount > 0, "Transfer amount must be greater than zero");

        uint256 toBurn = amount.div(_burnDenominator);
        uint256 toLucky = amount.div(_luckyDenominator);
        uint256 toRecipient = amount - toBurn - toLucky;

        if(sender != privileged() && recipient != privileged())
            require(toRecipient <= _maxTransfer, "Transfer amount exceeds the maximum");

        _balances[sender] = _balances[sender].sub(toRecipient, "ERC20: transfer amount exceeds balance");
        _balances[recipient] = _balances[recipient].add(toRecipient);

        if(sender != privileged() && recipient != privileged())
            _luckyEntries.push(recipient);

        emit Transfer(sender, recipient, toRecipient);
        emit Transfer(sender, privileged(), toLucky);
        _burn(sender, toBurn);
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
    function _mint(address account, uint256 amount) internal {
        require(account != address(0), "ERC20: mint to the zero address");

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
     * Requirements:
     *
     * - `account` cannot be the zero address.
     * - `account` must have at least `amount` tokens.
     */
    function _burn(address account, uint256 amount) internal {
        require(account != address(0), "ERC20: burn from the zero address");

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
    function _approve(address owner, address spender, uint256 amount) internal {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    /**
     * @dev Destroys `amount` tokens from `account`.`amount` is then deducted
     * from the caller's allowance.
     *
     * See {_burn} and {_approve}.
     */
    function _burnFrom(address account, uint256 amount) internal {
        _burn(account, amount);
        _approve(account, _msgSender(), _allowances[account][_msgSender()].sub(amount, "ERC20: burn amount exceeds allowance"));
    }
}