/**
 *Submitted for verification at Etherscan.io on 2021-05-13
*/

pragma solidity ^0.5.7;

/**
 * @title SafeMath
 * @dev Math operations with safety checks that revert on error
 */




contract ERC20Pistachio is IERC20 {

    using SafeMath for uint256;

    mapping(address => uint256) private _balances;

    mapping(address => mapping(address => uint256)) private _allowed;

    mapping(address => uint256) private _locked;
    mapping(address => uint256) private _lockedTill;

    uint256 private _totalSupply;

    address private _admin;

    modifier onlyAdmin() {
        require(msg.sender == _admin);
        _;
    }

    /**
    * @dev Public parameters to define the token
    */

    // Token symbol (short)
    string public symbol;

    // Token name (Long)
    string public  name;

    // Decimals (18 maximum)
    uint8 public decimals;

    /**
    * @dev Public functions to make the contract accesible
    */
    constructor (address initialAccount, string memory _tokenSymbol, string memory _tokenName, uint256 initialBalance) public {

        // Initialize Contract Parameters
        symbol = _tokenSymbol;
        name = _tokenName;
        decimals = 18;
        // default decimals is going to be 18 always

        _mint(initialAccount, initialBalance);

        _admin = initialAccount;

    }

    /**
    * @dev Total number of tokens in existence
    */
    function totalSupply() public view returns (uint256) {
        return _totalSupply;
    }

    /**
    * @dev Gets the balance of the specified address.
    * @param owner The address to query the balance of.
    * @return An uint256 representing the amount owned by the passed address.
    */
    function balanceOf(address owner) public view returns (uint256) {
        return _balances[owner];
    }

    /**
     * @dev Function to check the amount of tokens that an owner allowed to a spender.
     * @param owner address The address which owns the funds.
     * @param spender address The address which will spend the funds.
     * @return A uint256 specifying the amount of tokens still available for the spender.
     */
    function allowance(address owner, address spender) public view returns (uint256) {
        return _allowed[owner][spender];
    }

    /**
     * @dev Function to check the amount of tokens that an owner has locked.
     * @param owner address The address which owns the funds.
     * @return A uint256 specifying the amount of tokens still available for the spender.
     */
    function locked(address owner) public view returns (uint256) {
        return _locked[owner];
    }

    /**
     * @dev Function to check the time until tokens of the owner has beem locked.
     * @param owner address The address which owns the funds.
     * @return A uint256 specifying the amount of tokens still available for the spender.
     */
    function lockedTill(address owner) public view returns (uint256) {
        return _lockedTill[owner];
    }

    /**
    * @dev Transfer token for a specified address
    * @param to The address to transfer to.
    * @param value The amount to be transferred.
    */
    function transfer(address to, uint256 value) public returns (bool) {
        _transfer(msg.sender, to, value);
        return true;
    }

    /**
     * @dev Approve the passed address to spend the specified amount of tokens on behalf of msg.sender.
     * Beware that changing an allowance with this method brings the risk that someone may use both the old
     * and the new allowance by unfortunate transaction ordering. One possible solution to mitigate this
     * race condition is to first reduce the spender's allowance to 0 and set the desired value afterwards:
     * https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729
     * @param spender The address which will spend the funds.
     * @param value The amount of tokens to be spent.
     */
    function approve(address spender, uint256 value) public returns (bool) {
        require(spender != address(0));

        _allowed[msg.sender][spender] = value;
        emit Approval(msg.sender, spender, value);
        return true;
    }

    /**
     * @dev Transfer tokens from one address to another.
     * Note that while this function emits an Approval event, this is not required as per the specification,
     * and other compliant implementations may not emit the event.
     * @param from address The address which you want to send tokens from
     * @param to address The address which you want to transfer to
     * @param value uint256 the amount of tokens to be transferred
     */
    function transferFrom(address from, address to, uint256 value) public returns (bool) {
        _allowed[from][msg.sender] = _allowed[from][msg.sender].sub(value);
        _transfer(from, to, value);
        emit Approval(from, msg.sender, _allowed[from][msg.sender]);
        return true;
    }

    /**
     * @dev Increase the amount of tokens that an owner allowed to a spender.
     * approve should be called when allowed_[_spender] == 0. To increment
     * allowed value is better to use this function to avoid 2 calls (and wait until
     * the first transaction is mined)
     * From MonolithDAO Token.sol
     * Emits an Approval event.
     * @param spender The address which will spend the funds.
     * @param addedValue The amount of tokens to increase the allowance by.
     */
    function increaseAllowance(address spender, uint256 addedValue) public returns (bool) {
        require(spender != address(0));

        _allowed[msg.sender][spender] = _allowed[msg.sender][spender].add(addedValue);
        emit Approval(msg.sender, spender, _allowed[msg.sender][spender]);
        return true;
    }

    /**
     * @dev Decrease the amount of tokens that an owner allowed to a spender.
     * approve should be called when allowed_[_spender] == 0. To decrement
     * allowed value is better to use this function to avoid 2 calls (and wait until
     * the first transaction is mined)
     * From MonolithDAO Token.sol
     * Emits an Approval event.
     * @param spender The address which will spend the funds.
     * @param subtractedValue The amount of tokens to decrease the allowance by.
     */
    function decreaseAllowance(address spender, uint256 subtractedValue) public returns (bool) {
        require(spender != address(0));

        _allowed[msg.sender][spender] = _allowed[msg.sender][spender].sub(subtractedValue);
        emit Approval(msg.sender, spender, _allowed[msg.sender][spender]);
        return true;
    }

    /**
    * @dev Transfer token for a specified addresses
    * @param from The address to transfer from.
    * @param to The address to transfer to.
    * @param value The amount to be transferred.
    */
    function _transfer(address from, address to, uint256 value) internal {
        require(to != address(0));
        require(_lockedTill[from] < now || _balances[from] - _locked[from] > value);

        _balances[from] = _balances[from].sub(value);
        _balances[to] = _balances[to].add(value);
        emit Transfer(from, to, value);
    }

    /**
     * @dev Internal function that mints an amount of the token and assigns it to
     * an account. This encapsulates the modification of balances such that the
     * proper events are emitted.
     * @param account The account that will receive the created tokens.
     * @param value The amount that will be created.
     */
    function _mint(address account, uint256 value) internal {
        require(account != address(0));

        _totalSupply = _totalSupply.add(value);
        _balances[account] = _balances[account].add(value);
        emit Transfer(address(0), account, value);
    }

    /**
     * @dev Internal function that burns an amount of the token of a given
     * account.
     * @param account The account whose tokens will be burnt.
     * @param value The amount that will be burnt.
     */
    function _burn(address account, uint256 value) internal {
        require(account != address(0));

        _totalSupply = _totalSupply.sub(value);
        _balances[account] = _balances[account].sub(value);
        emit Transfer(account, address(0), value);
    }

    /**
     * @dev Internal function that locks an amount of the token of a given
     * account.
     * @param account The account whose tokens will be locked.
     * @param value The amount that will be locked.
     */
    function _lock(address account, uint256 value, uint256 time) internal {
        require(account != address(0));
        require(time > 0);
        require(value > 0);

        _locked[account] = _locked[account].add(value);
        _lockedTill[account] = now.add(time);
        emit Lock(account, value, time);
    }
}

/**
 * @title Burnable Token
 * @dev Token that can be irreversibly burned (destroyed).
 */
contract ERC20Burnable is ERC20Pistachio {

    bool private _burnableActive;

    /**
     * @dev Burns a specific amount of tokens from the target address and decrements allowance
     * @param from address The address which you want to send tokens from
     * @param value uint256 The amount of token to be burned
     */
    function burn(address from, uint256 value) public onlyAdmin whenBurnableActive {
        _burn(from, value);
    }

    /**
     * @dev Options to activate or deactivate Burn ability
     */

    function _setBurnableActive(bool _active) internal {
        _burnableActive = _active;
    }

    modifier whenBurnableActive() {
        require(_burnableActive);
        _;
    }

}

/**
 * @title ERC20Mintable
 * @dev ERC20 minting logic
 */
contract ERC20Mintable is ERC20Pistachio {

    bool private _mintableActive;
    /**
     * @dev Function to mint tokens
     * @param to The address that will receive the minted tokens.
     * @param value The amount of tokens to mint.
     * @return A boolean that indicates if the operation was successful.
     */
    function mint(address to, uint256 value) public onlyAdmin whenMintableActive returns (bool) {
        _mint(to, value);
        return true;
    }

    /**
     * @dev Options to activate or deactivate Burn ability
     */

    function _setMintableActive(bool _active) internal {
        _mintableActive = _active;
    }

    modifier whenMintableActive() {
        require(_mintableActive);
        _;
    }

}

/**
 * @title Pausable
 * @dev Base contract which allows children to implement an emergency stop mechanism.
 */
contract ERC20Pausable is ERC20Pistachio {
    event Paused(address account);
    event Unpaused(address account);

    bool private _pausableActive;
    bool private _paused;

    constructor () internal {
        _paused = false;
    }

    /**
     * @return true if the contract is paused, false otherwise.
     */
    function paused() public view returns (bool) {
        return _paused;
    }

    /**
     * @dev Modifier to make a function callable only when the contract is not paused.
     */
    modifier whenNotPaused() {
        require(!_paused);
        _;
    }

    /**
     * @dev Modifier to make a function callable only when the contract is paused.
     */
    modifier whenPaused() {
        require(_paused);
        _;
    }

    /**
     * @dev called by the owner to pause, triggers stopped state
     */
    function pause() public onlyAdmin whenNotPaused whenPausableActive {
        _paused = true;
        emit Paused(msg.sender);
    }

    /**
     * @dev called by the owner to unpause, returns to normal state
     */
    function unpause() public onlyAdmin whenPaused whenPausableActive {
        _paused = false;
        emit Unpaused(msg.sender);
    }

    /**
     * @dev Options to activate or deactivate Pausable ability
     */

    function _setPausableActive(bool _active) internal {
        _pausableActive = _active;
    }

    modifier whenPausableActive() {
        require(_pausableActive);
        _;
    }

}

/**
 * @title ERC20Lockable
 * @dev ERC20 locking logic
 */
contract ERC20Lockable is ERC20Pistachio {

    bool private _lockableActive;
    /**
     * @dev Function to lock tokens
     * @param from The address that will receive the locked tokens.
     * @param value The amount of tokens to lock.
     * @return A boolean that indicates if the operation was successful.
     */
    function lock(address from, uint256 value, uint256 time) public onlyAdmin whenLockableActive returns (bool) {
        _lock(from, value, time);
        return true;
    }

    /**
     * @dev Options to activate or deactivate Burn ability
     */

    function _setLockableActive(bool _active) internal {
        _lockableActive = _active;
    }

    modifier whenLockableActive() {
        require(_lockableActive);
        _;
    }

}

/**
 * @title Advanced ERC20 token
 *
 * @dev Implementation of the basic standard token plus mint and burn public functions.
 *
 * Version 2. This version delegates the minter and pauser renounce to parent-factory contract
 * that allows ICOs to be minter for token selling
 *
 */
contract ETM is ERC20Pistachio, ERC20Burnable, ERC20Lockable, ERC20Mintable, ERC20Pausable {
    constructor (
        address initialAccount
    ) public
    ERC20Pistachio(initialAccount, "ETM", "EtherM Token", 5000000000000000000000000000) {
        _setBurnableActive(true);
        _setLockableActive(true);
        _setMintableActive(true);
        _setPausableActive(true);

    }

    /**
     * Pausable options
     */
    function transfer(address to, uint256 value) public whenNotPaused returns (bool) {
        return super.transfer(to, value);
    }

    function transferFrom(address from, address to, uint256 value) public whenNotPaused returns (bool) {
        return super.transferFrom(from, to, value);
    }

    function approve(address spender, uint256 value) public whenNotPaused returns (bool) {
        return super.approve(spender, value);
    }

    function increaseAllowance(address spender, uint addedValue) public whenNotPaused returns (bool success) {
        return super.increaseAllowance(spender, addedValue);
    }

    function decreaseAllowance(address spender, uint subtractedValue) public whenNotPaused returns (bool success) {
        return super.decreaseAllowance(spender, subtractedValue);
    }
}