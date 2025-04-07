/**
 *Submitted for verification at Etherscan.io on 2020-08-03
*/

pragma solidity ^0.4.24;



/**
 * @title SafeMath
 * @dev Math operations with safety checks that revert on error
 */


/**
 * @title SafeMathInt
 * @dev Math operations for int256 with overflow safety checks.
 */


contract GeneralToken {
    using SafeMath for uint256;
    using SafeMathInt for int256;

    address private _owner;

    string private _name;
    string private _symbol;
    uint8 private _decimals = 8;

    // Precautionary emergency controls.
    bool public rebasePaused;
    bool public tokenPaused;

    uint256 private constant MAX_UINT256 = ~uint256(0);
    uint256 private _initalSupply;

    // TOTAL_GONS is a multiple of INITIAL_FRAGMENTS_SUPPLY so that _gonsPerFragment is an integer.
    // Use the highest value that fits in a uint256 for max granularity.
    uint256 private _totalGons;

    // MAX_SUPPLY = maximum integer < (sqrt(4*TOTAL_GONS + 1) - 1) / 2
    uint256 private constant MAX_SUPPLY = ~uint128(0);  // (2^128) - 1

    uint256 private _totalSupply;
    uint256 private _gonsPerFragment;
    mapping(address => uint256) private _gonBalances;

    // This is denominated in Fragments, because the gons-fragments conversion might change before
    // it's fully paid.
    mapping (address => mapping (address => uint256)) private _allowedFragments;

    // This generates a public event on the blockchain that will notify clients
    event Transfer(address indexed from, address indexed to, uint256 value);

    // This notifies clients about the amount burnt
    // event Burn(address indexed from, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);

    event LogRebase(uint256 totalSupply);
    event LogRebasePaused(bool paused);
    event LogTokenPaused(bool paused);

    // rebase whether paused,default false
    modifier whenRebaseNotPaused() {
        require(!rebasePaused);
        _;
    }

    // token whether paused,default false
    modifier whenTokenNotPaused() {
        require(!tokenPaused);
        _;
    }

    // validate to address
    modifier validRecipient(address to) {
        require(to != address(0x0));
        require(to != address(this));
        _;
    }

    /**
     * @return the address of the owner.
     */
    function owner() public view returns(address) {
        return _owner;
    }

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        require(isOwner());
        _;
    }

    /**
     * @return true if `msg.sender` is the owner of the contract.
     */
    function isOwner() public view returns(bool) {
        return msg.sender == _owner;
    }

    /**
     * Constructor function
     *
     * Initializes contract with initial supply tokens to the creator of the contract
     */
    constructor (
        uint256 initialSupply,
        string tokenName,
        string tokenSymbol
    ) public {
        // Set owner
        _owner = msg.sender;

        // set name,symbol,decimals
        _name = tokenName;
        _symbol = tokenSymbol;

        _initalSupply = initialSupply * 10 ** uint256(_decimals);
        _totalGons = MAX_UINT256 - (MAX_UINT256 % _initalSupply);

        rebasePaused = false;
        tokenPaused = false;

        _totalSupply = _initalSupply;
        _gonBalances[_owner] = _totalGons;
        _gonsPerFragment = _totalGons.div(_totalSupply);

        emit Transfer(address(0x0), _owner, _totalSupply);
    }

    /**
     * @dev Notifies Fragments contract about a new rebase cycle.
     * @param supplyDelta The number of new fragment tokens to add into circulation via expansion.
     * @return The total number of fragments after the supply adjustment.
     */
    function rebase(uint256 supplyDelta)
        external
        onlyOwner
        whenRebaseNotPaused
        returns (uint256)
    {
        if (supplyDelta == 0) {
            emit LogRebase(_totalSupply);
            return _totalSupply;
        }

        _totalSupply = supplyDelta * 10 ** uint256(_decimals);

        if (_totalSupply > MAX_SUPPLY) {
            _totalSupply = MAX_SUPPLY;
        }

        _gonsPerFragment = _totalGons.div(_totalSupply);

        emit LogRebase(_totalSupply);
        return _totalSupply;
    }

    /**
     * @dev Pauses or unpauses the execution of rebase operations.
     * @param paused Pauses rebase operations if this is true.
     */
    function setRebasePaused(bool paused)
        external
        onlyOwner
    {
        rebasePaused = paused;
        emit LogRebasePaused(paused);
    }

    /**
     * @dev Pauses or unpauses execution of ERC-20 transactions.
     * @param paused Pauses ERC-20 transactions if this is true.
     */
    function setTokenPaused(bool paused)
        external
        onlyOwner
    {
        tokenPaused = paused;
        emit LogTokenPaused(paused);
    }

    /**
     * @return The total number of fragments.
     */
    function totalSupply()
        public
        view
        returns (uint256)
    {
        return _totalSupply;
    }

    /**
     * @param who The address to query.
     * @return The balance of the specified address.
     */
    function balanceOf(address who)
        public
        view
        returns (uint256)
    {
        return _gonBalances[who].div(_gonsPerFragment);
    }

    /**
     * @return the name of the token.
     */
    function name() public view returns(string) {
        return _name;
    }

    /**
     * @return the symbol of the token.
     */
    function symbol() public view returns(string) {
        return _symbol;
    }

    /**
     * @return the number of decimals of the token.
     */
    function decimals() public view returns(uint8) {
        return _decimals;
    }

    /**
     * Internal transfer, only can be called by this contract
     */
    function _transfer(address _from, address _to, uint256 _value) internal {
        // Prevent transfer to 0x0 address. Use burn() instead
        // require(_to != address(0));

        uint256 gonValue = _value.mul(_gonsPerFragment);
        // Check if the sender has enough
        require(_gonBalances[_from] >= gonValue);
        // Check for overflows
        require(_gonBalances[_to].add(gonValue) >= _gonBalances[_to]);

        // Save this for an assertion in the future
        uint256 previousBalances = _gonBalances[_from].add(_gonBalances[_to]);
        // Subtract from the sender
        _gonBalances[_from] = _gonBalances[_from].sub(gonValue);
        _gonBalances[_to] = _gonBalances[_to].add(gonValue);

        // Add transfer event
        emit Transfer(_from, _to, _value);
        // Asserts are used to use static analysis to find bugs in your code. They should never fail
        assert(_gonBalances[_from].add(_gonBalances[_to]) == previousBalances);
    }

    /**
     * Transfer tokens
     *
     * Send `_value` tokens to `_to` from your account
     *
     * @param _to The address of the recipient
     * @param _value the amount to send
     */
    function transfer(address _to, uint256 _value) public validRecipient(_to) whenTokenNotPaused returns (bool) {
        _transfer(msg.sender, _to, _value);
        return true;
    }

    /**
     * @dev Function to check the amount of tokens that an owner has allowed to a spender.
     * @param owner_ The address which owns the funds.
     * @param spender The address which will spend the funds.
     * @return The number of tokens still available for the spender.
     */
    function allowance(address owner_, address spender)
        public
        view
        returns (uint256)
    {
        return _allowedFragments[owner_][spender];
    }

    /**
     * Transfer tokens from other address
     *
     * Send `_value` tokens to `_to` on behalf of `_from`
     *
     * @param _from The address of the sender
     * @param _to The address of the recipient
     * @param _value the amount to send
     */
    function transferFrom(address _from, address _to, uint256 _value) public validRecipient(_to) whenTokenNotPaused returns (bool) {
        require(_value <= _allowedFragments[_from][msg.sender]);     // Check allowance

        _allowedFragments[_from][msg.sender] = _allowedFragments[_from][msg.sender].sub(_value);
        _transfer(_from, _to, _value);
        return true;
    }

    /**
     * Set allowance for other address
     *
     * Allows `_spender` to spend no more than `_value` tokens on your behalf
     *
     * @param _spender The address authorized to spend
     * @param _value the max amount they can spend
     */
    function approve(address _spender, uint256 _value) public whenTokenNotPaused returns (bool) {
        require(_spender != address(0));

        _allowedFragments[msg.sender][_spender] = _value;
        emit Approval(msg.sender, _spender, _value);

        return true;
    }

    /**
     * @dev Increase the amount of tokens that an owner has allowed to a spender.
     * This method should be used instead of approve() to avoid the double approval vulnerability
     * described above.
     * @param spender The address which will spend the funds.
     * @param addedValue The amount of tokens to increase the allowance by.
     */
    function increaseAllowance(address spender, uint256 addedValue)
        public
        whenTokenNotPaused
        returns (bool)
    {
        _allowedFragments[msg.sender][spender] =
            _allowedFragments[msg.sender][spender].add(addedValue);
        emit Approval(msg.sender, spender, _allowedFragments[msg.sender][spender]);
        return true;
    }

    /**
     * @dev Decrease the amount of tokens that an owner has allowed to a spender.
     *
     * @param spender The address which will spend the funds.
     * @param subtractedValue The amount of tokens to decrease the allowance by.
     */
    function decreaseAllowance(address spender, uint256 subtractedValue)
        public
        whenTokenNotPaused
        returns (bool)
    {
        uint256 oldValue = _allowedFragments[msg.sender][spender];
        if (subtractedValue >= oldValue) {
            _allowedFragments[msg.sender][spender] = 0;
        } else {
            _allowedFragments[msg.sender][spender] = oldValue.sub(subtractedValue);
        }
        emit Approval(msg.sender, spender, _allowedFragments[msg.sender][spender]);
        return true;
    }

    /**
     * Set allowance for other address and notify
     *
     * Allows `_spender` to spend no more than `_value` tokens on your behalf, and then ping the contract about it
     *
     * @param _spender The address authorized to spend
     * @param _value the max amount they can spend
     * @param _extraData some extra information to send to the approved contract
     */
    function approveAndCall(address _spender, uint256 _value, bytes _extraData)
        public
        whenTokenNotPaused
        returns (bool) {
        tokenRecipient spender = tokenRecipient(_spender);
        if (approve(_spender, _value)) {
            spender.receiveApproval(msg.sender, _value, address(this), _extraData);
            return true;
        }
    }
}