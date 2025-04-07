/**
 *Submitted for verification at Etherscan.io on 2020-11-05
*/

// SPDX-License-Identifier: MIT

pragma solidity 0.6.6;


// 
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


// 
/**
 * @dev Collection of functions related to the address type
 */


// 
/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
 */


/**
 * @dev Optional functions from the ERC20 standard.
 */
abstract contract ERC20Detailed is IERC20 {
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
     * NOTE: This information is only used for _display_ purposes: it in
     * no way affects any of the arithmetic of the contract, including
     * {IERC20-balanceOf} and {IERC20-transfer}.
     */
    function decimals() public view returns (uint8) {
        return _decimals;
    }
}

enum RebaseResult { Double, Park, Draw }

contract TautrinoToken is ERC20Detailed {

    using SafeMath for uint;
    using Address for address;

    event LogTokenRebase(uint64 epoch, RebaseResult result, uint totalSupply);

    address public governance;

    uint private _baseTotalSupply;
    uint256 private _factor2;

    uint64 private _lastRebaseEpoch;
    RebaseResult private _lastRebaseResult;

    mapping(address => uint) private _baseBalances;
    // This is denominated in Fragments, because the gons-fragments conversion might change before
    // it's fully paid.
    mapping (address => mapping (address => uint)) private _allowedFragments;

    /**
     * @dev Throws if called by any account other than the governance.
     */
    modifier onlyGovernance() {
        require(governance == msg.sender, "governance!");
        _;
    }

    /**
     * @dev Constructor.
     * @param symbol symbol of token - TAU or TRINO.
     */

    constructor(string memory symbol) public ERC20Detailed("Tautrino", symbol, 18) {
        governance = msg.sender;
        _baseTotalSupply = 300 * (10**uint(decimals()));
        _baseBalances[msg.sender] = totalSupply();
        _factor2 = 0;
        emit Transfer(address(0x0), msg.sender, totalSupply());
    }

    /**
     * @dev Update governance.
     * @param _governance The address of governance.
     */

    function setGovernance(address _governance) external onlyGovernance {
        governance = _governance;
    }

    /**
     * @dev Rebase Tautrino token.
     * @return The total number of fragments after the supply adjustment.
     */

    function rebase(RebaseResult _result) external onlyGovernance returns (uint) {
        if (_result == RebaseResult.Double) { // 2x total supply
            _factor2 = _factor2.add(1);
        } else if (_result == RebaseResult.Park) { // debased
            _factor2 = 0;
        }

        _lastRebaseResult = _result;
        _lastRebaseEpoch = uint64(block.timestamp);

        uint _totalSupply = totalSupply();
        LogTokenRebase(_lastRebaseEpoch, _lastRebaseResult, _totalSupply);

        return _totalSupply;
    }

    /**
     * @return The total number of fragments.
     */

    function totalSupply() public override view returns (uint) {
        return _baseTotalSupply.mul(2 ** _factor2);
    }

    /**
     * @param who The address to query.
     * @return The balance of the specified address.
     */

    function balanceOf(address who) public override view returns (uint) {
        return _baseBalances[who].mul(2 ** _factor2);
    }

    /**
     * @dev Transfer tokens to a specified address.
     * @param to The address to transfer to.
     * @param value The amount to be transferred.
     * @return True on success, false otherwise.
    */

    function transfer(address to, uint value) public override returns (bool) {
        uint merValue = value.div(2 ** _factor2);
        _baseBalances[msg.sender] = _baseBalances[msg.sender].sub(merValue);
        _baseBalances[to] = _baseBalances[to].add(merValue);
        emit Transfer(msg.sender, to, value);
        return true;
    }

    /**
     * @dev Function to check the amount of tokens that an owner has allowed to a spender.
     * @param owner_ The address which owns the funds.
     * @param spender The address which will spend the funds.
     * @return The number of tokens still available for the spender.
     */
    
    function allowance(address owner_, address spender) public override view returns (uint) {
        return _allowedFragments[owner_][spender];
    }

    /**
     * @dev Transfer tokens from one address to another.
     * @param from The address you want to send tokens from.
     * @param to The address you want to transfer to.
     * @param value The amount of tokens to be transferred.
     */

    function transferFrom(address from, address to, uint value) public override returns (bool) {
        _allowedFragments[from][msg.sender] = _allowedFragments[from][msg.sender].sub(value);

        uint merValue = value.div(2 ** _factor2);
        _baseBalances[from] = _baseBalances[from].sub(merValue);
        _baseBalances[to] = _baseBalances[to].add(merValue);
        emit Transfer(from, to, value);

        return true;
    }

    /**
     * @dev Approve the passed address to spend the specified amount of tokens on behalf of
     * msg.sender. This method is included for ERC20 compatibility.
     * increaseAllowance and decreaseAllowance should be used instead.
     * Changing an allowance with this method brings the risk that someone may transfer both
     * the old and the new allowance - if they are both greater than zero - if a transfer
     * transaction is mined before the later approve() call is mined.
     *
     * @param spender The address which will spend the funds.
     * @param value The amount of tokens to be spent.
     */

    function approve(address spender, uint value) public override returns (bool) {
        _allowedFragments[msg.sender][spender] = value;
        emit Approval(msg.sender, spender, value);
        return true;
    }

    /**
     * @dev Increase the amount of tokens that an owner has allowed to a spender.
     * This method should be used instead of approve() to avoid the double approval vulnerability
     * described above.
     * @param spender The address which will spend the funds.
     * @param addedValue The amount of tokens to increase the allowance by.
     */

    function increaseAllowance(address spender, uint addedValue) public returns (bool) {
        _allowedFragments[msg.sender][spender] = _allowedFragments[msg.sender][spender].add(addedValue);
        emit Approval(msg.sender, spender, _allowedFragments[msg.sender][spender]);
        return true;
    }

    /**
     * @dev Decrease the amount of tokens that an owner has allowed to a spender.
     *
     * @param spender The address which will spend the funds.
     * @param subtractedValue The amount of tokens to decrease the allowance by.
     */

    function decreaseAllowance(address spender, uint subtractedValue) public returns (bool) {
        uint oldValue = _allowedFragments[msg.sender][spender];
        if (subtractedValue >= oldValue) {
        _allowedFragments[msg.sender][spender] = 0;
        } else {
        _allowedFragments[msg.sender][spender] = oldValue.sub(subtractedValue);
        }
        emit Approval(msg.sender, spender, _allowedFragments[msg.sender][spender]);
        return true;
    }

    /**
     * @return Last rebase epoch.
     */

    function lastRebaseEpoch() public view returns (uint64) {
        return _lastRebaseEpoch;
    }

    /**
     * @return Last rebase result.
     */

    function lastRebaseResult() public view returns (RebaseResult) {
        return _lastRebaseResult;
    }

    /**
     * @return Return factor2
     */

    function factor2() public view returns (uint) {
        return _factor2;
    }
}