/**
 *Submitted for verification at Etherscan.io on 2020-10-04
*/

pragma solidity ^0.6.12;

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


/**
 * @title SafeERC20
 * @dev Wrappers around ERC20 operations that throw on failure (when the token
 * contract returns false). Tokens that return no value (and instead revert or
 * throw on failure) are also supported, non-reverting calls are assumed to be
 * successful.
 * To use this library you can add a `using SafeERC20 for IERC20;` statement to your contract,
 * which allows you to call the safe operations as `token.safeTransfer(...)`, etc.
 */


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

/*
   ____            __   __        __   _
  / __/__ __ ___  / /_ / /  ___  / /_ (_)__ __
 _\ \ / // // _ \/ __// _ \/ -_)/ __// / \ \ /
/___/ \_, //_//_/\__//_//_/\__/ \__//_/ /_\_\
     /___/

* Docs: https://docs.synthetix.io/
*
*
* MIT License
* ===========
*
* Copyright (c) 2020 Synthetix
*
* Permission is hereby granted, free of charge, to any person obtaining a copy
* of this software and associated documentation files (the "Software"), to deal
* in the Software without restriction, including without limitation the rights
* to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
* copies of the Software, and to permit persons to whom the Software is
* furnished to do so, subject to the following conditions:
*
* The above copyright notice and this permission notice shall be included in all
* copies or substantial portions of the Software.
*
* THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
* IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
* FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
* AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
* LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
* OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
*/


contract CritSupplySchedule is Ownable {
    using SafeERC20 for IERC20;
    using SafeMath for uint;
    using SafeDecimal for uint;
    uint256[157] public weeklySupplies = [
    // week 0
    0,
    // 1st year, week 1 ~ 52
    358025, 250600, 175420, 122794, 112970, 103932, 95618, 87968, 80931, 74456, 68500, 63020, 57978,
    53340, 49073, 45147, 41535, 38212, 35155, 32343, 29755, 27375, 25185, 23170, 21316, 19611,
    18042, 16599, 15271, 14049, 12925, 11891, 10940, 10064, 9259, 8518, 7837, 7210, 6633,
    6102, 5614, 5165, 4752, 4372, 4022, 3700, 3404, 3132, 2881, 2651, 2438, 2244,
    // 2nd year, week 53 ~ 104
    2244, 2244, 2244, 2244, 2244, 2244, 2244, 2244, 2244, 2244, 2244, 2244, 2244,
    2244, 2244, 2244, 2244, 2244, 2244, 2244, 2244, 2244, 2244, 2244, 2244, 2244,
    2244, 2244, 2244, 2244, 2244, 2244, 2244, 2244, 2244, 2244, 2244, 2244, 2244,
    2244, 2244, 2244, 2244, 2244, 2244, 2244, 2244, 2244, 2244, 2244, 2244, 2244,
    // 3rd year, week 105 ~ 156
    1734, 1734, 1734, 1734, 1734, 1734, 1734, 1734, 1734, 1734, 1734, 1734, 1734,
    1734, 1734, 1734, 1734, 1734, 1734, 1734, 1734, 1734, 1734, 1734, 1734, 1734,
    1734, 1734, 1734, 1734, 1734, 1734, 1734, 1734, 1734, 1734, 1734, 1734, 1734,
    1734, 1734, 1734, 1734, 1734, 1734, 1734, 1734, 1734, 1734, 1734, 1734, 1734
    ];
    uint public constant MINT_PERIOD_DURATION = 1 weeks;
    uint public constant SUPPLY_START_DATE = 1601258400; // 2020-09-28T02:00:00+00:00

    uint public constant MAX_OPERATION_SHARES = 20e16;

    address public rewardsToken;
    uint public lastMintEvent;
    uint public weekCounter;
    uint public operationShares = 2e16; // 2%

    event OperationSharesUpdated(uint newShares);
    event SupplyMinted(uint supplyMinted, uint numberOfWeeksIssued, uint lastMintEvent, uint timestamp);

    modifier onlyRewardsToken() {
        require(msg.sender == address(rewardsToken), "onlyRewardsToken");
        _;
    }

    constructor(address _rewardsToken, uint _lastMintEvent, uint _currentWeek) public {
        rewardsToken = _rewardsToken;
        lastMintEvent = _lastMintEvent;
        weekCounter = _currentWeek;
    }

    function mintableSupply() external view returns (uint) {
        uint totalAmount;
        if (!isMintable()) {
            return 0;
        }

        uint currentWeek = weekCounter;
        uint remainingWeeksToMint = weeksSinceLastIssuance();
        while (remainingWeeksToMint > 0) {
            currentWeek++;
            remainingWeeksToMint--;
            if (currentWeek >= weeklySupplies.length) {
                break;
            }
            totalAmount = totalAmount.add(weeklySupplies[currentWeek]);
        }
        return totalAmount.mul(1e18);
    }

    function weeksSinceLastIssuance() public view returns (uint) {
        uint timeDiff = lastMintEvent > 0 ? now.sub(lastMintEvent) : now.sub(SUPPLY_START_DATE);
        return timeDiff.div(MINT_PERIOD_DURATION);
    }

    function isMintable() public view returns (bool) {
        if (now - lastMintEvent > MINT_PERIOD_DURATION && weekCounter < weeklySupplies.length) {
            return true;
        }
        return false;
    }

    function recordMintEvent(uint _supplyMinted) external onlyRewardsToken returns (bool) {
        uint numberOfWeeksIssued = weeksSinceLastIssuance();
        weekCounter = weekCounter.add(numberOfWeeksIssued);
        lastMintEvent = SUPPLY_START_DATE.add(weekCounter.mul(MINT_PERIOD_DURATION));

        emit SupplyMinted(_supplyMinted, numberOfWeeksIssued, lastMintEvent, now);
        return true;
    }

    function setOperationShares(uint _shares) external onlyOwner {
        require(_shares <= MAX_OPERATION_SHARES, "shares");
        operationShares = _shares;
        emit OperationSharesUpdated(_shares);
    }

    function rewardOfOperation(uint _supplyMinted) public view returns (uint) {
        return _supplyMinted.mul(operationShares).div(SafeDecimal.unit());
    }

    function currentWeekSupply() external view returns(uint) {
        if (weekCounter < weeklySupplies.length) {
            return weeklySupplies[weekCounter];
        }
        return 0;
    }
}

contract RewardsDistribution is Ownable {
    using SafeERC20 for IERC20;
    using SafeMath for uint;

    address public rewardsToken;

    address[] public distributions;
    mapping(address => uint) public shares;

    event RewardDistributionAdded(uint index, address distribution, uint shares);
    event RewardDistributionUpdated(address distribution, uint shares);
    event RewardsDistributed(uint amount);

    modifier onlyRewardsToken() {
        require(msg.sender == address(rewardsToken) || msg.sender == owner(), "onlyRewardsToken");
        _;
    }

    constructor(address _rewardsToken) public {
        rewardsToken = _rewardsToken;
    }

    function addRewardDistribution(address _distribution, uint _shares) external onlyOwner {
        require(_distribution != address(0), "distribution");
        require(shares[_distribution] == 0, "shares");

        distributions.push(_distribution);
        shares[_distribution] = _shares;
        emit RewardDistributionAdded(distributions.length - 1, _distribution, _shares);
    }

    function updateRewardDistribution(address _distribution, uint _shares) public onlyOwner {
        require(_distribution != address(0), "distribution");
        require(_shares > 0, "shares");

        shares[_distribution] = _shares;
        emit RewardDistributionUpdated(_distribution, _shares);
    }

    function removeRewardDistribution(uint index) external onlyOwner {
        require(index <= distributions.length - 1, "index");

        delete shares[distributions[index]];
        delete distributions[index];
    }

    function distributeRewards(uint amount) external onlyRewardsToken returns (bool) {
        require(rewardsToken != address(0), "rewardsToken");
        require(amount > 0, "amount");
        require(IERC20(rewardsToken).balanceOf(address(this)) >= amount, "balance");

        uint remainder = amount;
        for (uint i = 0; i < distributions.length; i++) {
            address distribution = distributions[i];
            uint amountOfShares = sharesOf(distribution, amount);

            if (distribution != address(0) && amountOfShares != 0) {
                remainder = remainder.sub(amountOfShares);

                IERC20(rewardsToken).transfer(distribution, amountOfShares);
                bytes memory payload = abi.encodeWithSignature("notifyRewardAmount(uint256)", amountOfShares);
                distribution.call(payload);
            }
        }

        emit RewardsDistributed(amount);
        return true;
    }

    function totalShares() public view returns (uint) {
        uint total = 0;
        for (uint i = 0; i < distributions.length; i++) {
            total = total.add(shares[distributions[i]]);
        }
        return total;
    }

    function sharesOf(address _distribution, uint _amount) public view returns (uint) {
        uint _totalShares = totalShares();
        if (_totalShares == 0) return 0;

        return _amount.mul(shares[_distribution]).div(_totalShares);
    }
}

contract Crit is ERC20, Ownable {
    using SafeERC20 for IERC20;
    using Address for address;
    using SafeMath for uint;

    address public governance;
    address public supplySchedule;
    address public rewardsDistribution;
    address public rewardsOperation;

    modifier onlyGovernance {
        require(msg.sender == governance, "onlyGovernance");
        _;
    }

    constructor() public ERC20("Crit", "CRIT") {
        governance = msg.sender;
    }

    function setGovernance(address _governance) public onlyGovernance {
        require(_governance != address(0), "governance");
        governance = _governance;
    }

    function setSupplySchedule(address _supplySchedule) public onlyGovernance {
        require(_supplySchedule != address(0), "supplySchedule");
        supplySchedule = _supplySchedule;
    }

    function setRewardDistribution(address _distribution) public onlyGovernance {
        require(_distribution != address(0), "distribution");
        rewardsDistribution = _distribution;
    }

    function setRewardsOperation(address _operation) public onlyGovernance {
        require(_operation != address(0), "operation");
        rewardsOperation = _operation;
    }

    function mint() external {
        require(supplySchedule != address(0), "supplySchedule");
        require(rewardsDistribution != address(0), "rewardsDistribution");
        require(rewardsOperation != address(0), "rewardsOperation");

        CritSupplySchedule _supplySchedule = CritSupplySchedule(supplySchedule);
        RewardsDistribution _rewardsDistribution = RewardsDistribution(rewardsDistribution);

        uint supplyToMint = _supplySchedule.mintableSupply();
        require(supplyToMint > 0, "supplyToMint");

        _supplySchedule.recordMintEvent(supplyToMint);
        uint amountToOperate = _supplySchedule.rewardOfOperation(supplyToMint);
        uint amountToDistribute = supplyToMint.sub(amountToOperate);

        _mint(rewardsOperation, amountToOperate);
        _mint(rewardsDistribution, amountToDistribute);
        _rewardsDistribution.distributeRewards(amountToDistribute);
    }
}