/**
 *Submitted for verification at Etherscan.io on 2021-05-07
*/

pragma solidity ^0.5.0;

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
 * This module is used through inheritance. It will make available the modifier
 * `onlyOwner`, which can be applied to your functions to restrict their use to
 * the owner.
 */


/**
 * @dev Interface of the ERC20 standard as defined in the EIP. Does not include
 * the optional functions; to access them see {ERC20Detailed}.
 */


/**
 * @dev Implementation of the {IERC20} interface.
 *
 * This implementation is agnostic to the way tokens are created. This means
 * that a supply mechanism has to be added in a derived contract using {_mint}.
 * For a generic mechanism see {ERC20Mintable}.
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
contract ERC20 is IERC20 {
    using SafeMath for uint256;

    mapping (address => uint256) private _balances;

    mapping (address => mapping (address => uint256)) private _allowances;

    uint256 private _totalSupply;

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
        _transfer(msg.sender, recipient, amount);
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
        _approve(msg.sender, spender, amount);
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
     * - the caller must have allowance for `sender`'s tokens of at least
     * `amount`.
     */
    function transferFrom(address sender, address recipient, uint256 amount) public returns (bool) {
        _transfer(sender, recipient, amount);
        _approve(sender, msg.sender, _allowances[sender][msg.sender].sub(amount, "ERC20: transfer amount exceeds allowance"));
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
        _approve(msg.sender, spender, _allowances[msg.sender][spender].add(addedValue));
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
        _approve(msg.sender, spender, _allowances[msg.sender][spender].sub(subtractedValue, "ERC20: decreased allowance below zero"));
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
        require(sender != address(0), "ERC20: transfer from the zero address");
        require(recipient != address(0), "ERC20: transfer to the zero address");

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
     * Requirements
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
        _approve(account, msg.sender, _allowances[account][msg.sender].sub(amount, "ERC20: burn amount exceeds allowance"));
    }
}


contract Token is Ownable, ERC20 {

    using SafeMath for uint;

    string public constant name = "Bitxmi";
    string public constant symbol = "Bxmi";
    uint public constant decimals = 18;

    uint private constant _month = 30 days;
    uint public constant team_percents = 24;
    uint public constant advisors_percents = 3;
    uint public constant bounty_percents = 3;
    uint public constant tokenSale_percents = 70;
    uint public constant initialEmission = 210_000_000;

    uint private t_count;
    uint private a_count;
    uint private b_count;

    uint private deployTime;

    address public saleAddress;

    constructor() public {
        deployTime = now;

        _mint(address(this), initialEmission * 10 ** decimals);
    }

    function() external {
        revert();
    }

    function sendSaleTokens(address _tokenSale) public onlyOwner {
        saleAddress = _tokenSale;
        _transfer(address(this), _tokenSale, totalSupply().mul(tokenSale_percents).div(100));
    }

    function sendTokens(address[] memory _receivers, uint[] memory _amounts) public onlyOwner {
        require(_receivers.length == _amounts.length, "The length of the arrays must be equal");

        for (uint i = 0; i < _receivers.length; i++) {
            _transfer(address(this), _receivers[i], _amounts[i]);
        }
    }

    function sendTokens(address to, uint amount) public onlyOwner {
        _transfer(address(this), to, amount);
    }

    function sendTeamTokens(address _teamAddress) public onlyOwner {
        require(now >= deployTime.add(_month.mul(7)));
        require(t_count < 3, "All tokens send");
        if(now < deployTime.add(_month.mul(12))){
            _transfer(address(this), _teamAddress, totalSupply().mul(team_percents).div(100).div(3));
            t_count++;
        }
        else if(now >= deployTime.add(_month.mul(12)) && now < deployTime.add(_month.mul(18))){
            _transfer(address(this), _teamAddress, totalSupply().mul(team_percents).div(100).mul(uint(2).sub(t_count)).div(3));
            t_count = 2;
        }
        else if (now >= deployTime.add(_month.mul(18))){
            _transfer(address(this), _teamAddress, totalSupply().mul(team_percents).div(100).mul(uint(3).sub(t_count)).div(3));
            t_count = 3;
        }
    }

    function sendAdvisorsTokens(address _advisorsAddress) public onlyOwner {
        require(now >= deployTime.add(_month.mul(7)));
        require(a_count < 3, "All tokens send");
        if(now < deployTime.add(_month.mul(12))){
            _transfer(address(this), _advisorsAddress, totalSupply().mul(advisors_percents).div(100).div(3));
            a_count++;
        }
        else if(now >= deployTime.add(_month.mul(12)) && now < deployTime.add(_month.mul(18))){
            _transfer(address(this), _advisorsAddress, totalSupply().mul(advisors_percents).div(100).mul(uint(2).sub(a_count)).div(3));
            a_count = 2;
        }
        else if (now >= deployTime.add(_month.mul(18))){
            _transfer(address(this), _advisorsAddress, totalSupply().mul(advisors_percents).div(100).mul(uint(3).sub(a_count)).div(3));
            a_count = 3;
        }
    }

    function sendBountyTokens(address _bountyAddress) public onlyOwner {
        require(now >= deployTime.add(_month.mul(7)));
        require(b_count < 3, "All tokens send");
        if(now < deployTime.add(_month.mul(12))){
            _transfer(address(this), _bountyAddress, totalSupply().mul(bounty_percents).div(100).div(3));
            b_count++;
        }
        else if(now >= deployTime.add(_month.mul(12)) && now < deployTime.add(_month.mul(18))){
            _transfer(address(this), _bountyAddress, totalSupply().mul(bounty_percents).div(100).mul(uint(2).sub(b_count)).div(3));
            b_count = 2;
        }
        else if (now >= deployTime.add(_month.mul(18))){
            _transfer(address(this), _bountyAddress, totalSupply().mul(bounty_percents).div(100).mul(uint(3).sub(b_count)).div(3));
            b_count = 3;
        }
    }

    function burnUnsoldTokens() public {
        require(msg.sender == owner() || msg.sender == saleAddress, "Caller is not the owner or sale address");
        require(now >= deployTime.add(_month.mul(7)));
        _burn(saleAddress, balanceOf(saleAddress));
    }
}