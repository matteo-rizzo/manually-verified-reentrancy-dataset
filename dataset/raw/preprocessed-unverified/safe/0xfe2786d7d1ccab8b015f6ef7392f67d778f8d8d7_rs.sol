/**
 *Submitted for verification at Etherscan.io on 2019-09-22
*/

// Parsiq Token
pragma solidity 0.5.11;

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
 * @dev Elliptic Curve Digital Signature Algorithm (ECDSA) operations.
 *
 * These functions can be used to verify that a message was signed by the holder
 * of the private keys of a given address.
 */


/**
 * @dev Collection of functions related to the address type,
 */


/**
 * @dev Interface of the ERC20 standard as defined in the EIP. Does not include
 * the optional functions; to access them see `ERC20Detailed`.
 */


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
 * @title SafeERC20
 * @dev Wrappers around ERC20 operations that throw on failure (when the token
 * contract returns false). Tokens that return no value (and instead revert or
 * throw on failure) are also supported, non-reverting calls are assumed to be
 * successful.
 * To use this library you can add a `using SafeERC20 for ERC20;` statement to your contract,
 * which allows you to call the safe operations as `token.safeTransfer(...)`, etc.
 */


/**
 * @dev Contract module which provides a basic access control mechanism, where
 * there is an account (an owner) that can be granted exclusive access to
 * specific functions.
 *
 * This module is used through inheritance. It will make available the modifier
 * `onlyOwner`, which can be aplied to your functions to restrict their use to
 * the owner.
 */








contract TokenRecoverable is Ownable {
    using SafeERC20 for IERC20;

    function recoverTokens(IERC20 token, address to, uint256 amount) public onlyOwner {
        uint256 balance = token.balanceOf(address(this));
        require(balance >= amount, "Given amount is larger than current balance");
        token.safeTransfer(to, amount);
    }
}

contract Burner is TokenRecoverable, ITokenReceiver {
    address payable public token;

    address public migrator;

    constructor(address payable _token) public TokenRecoverable() {
        token = _token;
    }

    function setMigrator(address _migrator) public onlyOwner {
        migrator = _migrator;
    }

    function tokensReceived(address from, address to, uint256 amount) external {
        require(token != address(0), "Burner is not initialized");
        require(msg.sender == token, "Only Parsiq Token can notify");
        require(ParsiqToken(token).burningEnabled(), "Burning is disabled");
        if (migrator != address(0)) {
            ITokenMigrator(migrator).migrate(from, to, amount);
        }
        ParsiqToken(token).burn(amount);
    }
}


contract ParsiqToken is TokenRecoverable, ERC20 {
    using SafeMath for uint256;
    using ECDSA for bytes32;
    using Address for address;

    uint256 internal constant MAX_UINT256 = ~uint256(0);
    uint256 internal constant TOTAL_TOKENS = 500000000e18; // 500 000 000 tokens
    string public constant name = "Parsiq Token";
    string public constant symbol = "PRQ";
    uint8 public constant decimals = uint8(18);

    mapping(address => bool) public notify;
    mapping(address => Timelock[]) public timelocks;
    mapping(address => Timelock[]) public relativeTimelocks;
    mapping(bytes32 => bool) public hashedTxs;
    mapping(address => bool) public whitelisted;
    uint256 public transfersUnlockTime = MAX_UINT256; // MAX_UINT256 - transfers locked
    address public burnerAddress;
    bool public burningEnabled;
    bool public etherlessTransferEnabled = true;

    struct Timelock {
        uint256 time;
        uint256 amount;
    }

    event TransferPreSigned(
        address indexed from,
        address indexed to,
        address indexed delegate,
        uint256 amount,
        uint256 fee);
    event TransferLocked(address indexed from, address indexed to, uint256 amount, uint256 until);
    event TransferLockedRelative(address indexed from, address indexed to, uint256 amount, uint256 duration);
    event Released(address indexed to, uint256 amount);
    event WhitelistedAdded(address indexed account);
    event WhitelistedRemoved(address indexed account);

    modifier onlyWhenEtherlessTransferEnabled {
        require(etherlessTransferEnabled == true, "Etherless transfer functionality disabled");
        _;
    }
    
    modifier onlyBurner() {
        require(msg.sender == burnerAddress, "Only burnAddress can burn tokens");
        _;
    }

    modifier onlyWhenTransfersUnlocked(address from, address to) {
        require(
            transfersUnlockTime <= now ||
            whitelisted[from] == true ||
            whitelisted[to] == true, "Transfers locked");
        _;
    }

    modifier onlyWhitelisted() {
        require(whitelisted[msg.sender] == true, "Not whitelisted");
        _;
    }

    modifier notTokenAddress(address _address) {
        require(_address != address(this), "Cannot transfer to token contract");
        _;
    }

    modifier notBurnerUntilBurnIsEnabled(address _address) {
        require(burningEnabled == true || _address != burnerAddress, "Cannot transfer to burner address, until burning is not enabled");
        _;
    }

    constructor() public TokenRecoverable() {
        _mint(msg.sender, TOTAL_TOKENS);
        _addWhitelisted(msg.sender);
        burnerAddress = address(new Burner(address(this)));
        notify[burnerAddress] = true; // Manually register Burner, because it cannot call register() while token constructor is not complete
        Burner(burnerAddress).transferOwnership(msg.sender);
    }

    function () external payable {
        _release(msg.sender);
        if (msg.value > 0) {
            msg.sender.transfer(msg.value);
        }
    }

    function register() public {
        notify[msg.sender] = true;
    }

    function unregister() public {
        notify[msg.sender] = false;
    }

    function enableEtherlessTransfer() public onlyOwner {
        etherlessTransferEnabled = true;
    }

    function disableEtherlessTransfer() public onlyOwner {
        etherlessTransferEnabled = false;
    }

    function addWhitelisted(address _address) public onlyOwner {
        _addWhitelisted(_address);
    }

    function removeWhitelisted(address _address) public onlyOwner {
        _removeWhitelisted(_address);
    }

    function renounceWhitelisted() public {
        _removeWhitelisted(msg.sender);
    }

    function transferOwnership(address newOwner) public onlyOwner {
        _removeWhitelisted(owner());
        super.transferOwnership(newOwner);
        _addWhitelisted(newOwner);
    }

    function renounceOwnership() public onlyOwner {
        renounceWhitelisted();
        super.renounceOwnership();
    }

    function unlockTransfers(uint256 when) public onlyOwner {
        require(transfersUnlockTime == MAX_UINT256, "Transfers already unlocked");
        require(when >= now, "Transfer unlock must not be in past");
        transfersUnlockTime = when;
    }

    function transfer(address to, uint256 value) public
        onlyWhenTransfersUnlocked(msg.sender, to)
        notTokenAddress(to)
        notBurnerUntilBurnIsEnabled(to)
        returns (bool)
    {
        bool success = super.transfer(to, value);
        if (success) {
            _postTransfer(msg.sender, to, value);
        }
        return success;
    }

    function transferFrom(address from, address to, uint256 value) public
        onlyWhenTransfersUnlocked(from, to)
        notTokenAddress(to)
        notBurnerUntilBurnIsEnabled(to)
        returns (bool)
    {
        bool success = super.transferFrom(from, to, value);
        if (success) {
            _postTransfer(from, to, value);
        }
        return success;
    }

    // We do not limit batch size, it's up to caller to determine maximum batch size/gas limit
    function transferBatch(address[] memory to, uint256[] memory value) public returns (bool) {
        require(to.length == value.length, "Array sizes must be equal");
        uint256 n = to.length;
        for (uint256 i = 0; i < n; i++) {
            transfer(to[i], value[i]);
        }
        return true;
    }

    function transferLocked(address to, uint256 value, uint256 until) public
        onlyWhitelisted
        notTokenAddress(to)
        returns (bool)
    {
        require(to != address(0), "ERC20: transfer to the zero address");
        require(value > 0, "Value must be positive");
        require(until > now, "Until must be future value");
        require(timelocks[to].length.add(relativeTimelocks[to].length) <= 100, "Too many locks on address");

        _transfer(msg.sender, address(this), value);

        timelocks[to].push(Timelock({ time: until, amount: value }));

        emit TransferLocked(msg.sender, to, value, until);
        return true;
    }

    /**
    This function is analogue to transferLocked(), but uses relative time locks to synchornize
    with transfer unlocking time
     */
    function transferLockedRelative(address to, uint256 value, uint256 duration) public
        onlyWhitelisted
        notTokenAddress(to)
        returns (bool)
    {
        require(transfersUnlockTime > now, "Relative locks are disabled. Use transferLocked() instead");
        require(to != address(0), "ERC20: transfer to the zero address");
        require(value > 0, "Value must be positive");
        require(timelocks[to].length.add(relativeTimelocks[to].length) <= 100, "Too many locks on address");

        _transfer(msg.sender, address(this), value);

        relativeTimelocks[to].push(Timelock({ time: duration, amount: value }));

        emit TransferLockedRelative(msg.sender, to, value, duration);
        return true;
    }

    function release() public {
        _release(msg.sender);
    }

    function lockedBalanceOf(address who) public view returns (uint256) {
        return _lockedBalanceOf(timelocks[who])
            .add(_lockedBalanceOf(relativeTimelocks[who]));
    }
    
    function unlockableBalanceOf(address who) public view returns (uint256) {
        uint256 tokens = _unlockableBalanceOf(timelocks[who], 0);
        if (transfersUnlockTime > now) return tokens;

        return tokens.add(_unlockableBalanceOf(relativeTimelocks[who], transfersUnlockTime));
    }

    function totalBalanceOf(address who) public view returns (uint256) {
        return balanceOf(who).add(lockedBalanceOf(who));
    }

    /**
     * @dev Burns a specific amount of tokens.
     * @param value The amount of token to be burned.
     */
    function burn(uint256 value) public onlyBurner {
        _burn(msg.sender, value);
    }

    function enableBurning() public onlyOwner {
        burningEnabled = true;
    }

    /** Etherless Transfer (ERC865 based) */
    /**
     * @notice Submit a presigned transfer
     * @param _signature bytes The signature, issued by the owner.
     * @param _to address The address which you want to transfer to.
     * @param _value uint256 The amount of tokens to be transferred.
     * @param _fee uint256 The amount of tokens paid to msg.sender, by the owner.
     * @param _nonce uint256 Presigned transaction number. Should be unique, per user.
     */
    function transferPreSigned(
        bytes memory _signature,
        address _to,
        uint256 _value,
        uint256 _fee,
        uint256 _nonce
    )
        public
        onlyWhenEtherlessTransferEnabled
        notTokenAddress(_to)
        notBurnerUntilBurnIsEnabled(_to)
        returns (bool)
    {
        require(_to != address(0), "Transfer to the zero address");

        bytes32 hashedParams = hashForSign(msg.sig, address(this), _to, _value, _fee, _nonce);
        address from = hashedParams.toEthSignedMessageHash().recover(_signature);
        require(from != address(0), "Invalid signature");

        require(
            transfersUnlockTime <= now ||
            whitelisted[from] == true ||
            whitelisted[_to] == true, "Transfers are locked");

        bytes32 hashedTx = keccak256(abi.encodePacked(from, hashedParams));
        require(hashedTxs[hashedTx] == false, "Nonce already used");
        hashedTxs[hashedTx] = true;

        if (msg.sender == _to) {
            _transfer(from, _to, _value.add(_fee));
            _postTransfer(from, _to, _value.add(_fee));
        } else {
            _transfer(from, _to, _value);
            _postTransfer(from, _to, _value);
            _transfer(from, msg.sender, _fee);
            _postTransfer(from, msg.sender, _fee);
        }

        emit TransferPreSigned(from, _to, msg.sender, _value, _fee);
        return true;
    }

    /**
     * @notice Hash (keccak256) of the payload used by transferPreSigned
     * @param _token address The address of the token.
     * @param _to address The address which you want to transfer to.
     * @param _value uint256 The amount of tokens to be transferred.
     * @param _fee uint256 The amount of tokens paid to msg.sender, by the owner.
     * @param _nonce uint256 Presigned transaction number.
     */
    function hashForSign(
        bytes4 _selector,
        address _token,
        address _to,
        uint256 _value,
        uint256 _fee,
        uint256 _nonce
    )
        public
        pure
        returns (bytes32)
    {
        return keccak256(abi.encodePacked(_selector, _token, _to, _value, _fee, _nonce));
    }

    function releasePreSigned(bytes memory _signature, uint256 _fee, uint256 _nonce)
        public
        onlyWhenEtherlessTransferEnabled
        returns (bool)
    {
        bytes32 hashedParams = hashForReleaseSign(msg.sig, address(this), _fee, _nonce);
        address from = hashedParams.toEthSignedMessageHash().recover(_signature);
        require(from != address(0), "Invalid signature");

        bytes32 hashedTx = keccak256(abi.encodePacked(from, hashedParams));
        require(hashedTxs[hashedTx] == false, "Nonce already used");
        hashedTxs[hashedTx] = true;

        uint256 released = _release(from);
        require(released > _fee, "Too small release");
        if (from != msg.sender) { // "from" already have all the tokens, no need to charge
            _transfer(from, msg.sender, _fee);
            _postTransfer(from, msg.sender, _fee);
        }
        return true;
    }

    /**
     * @notice Hash (keccak256) of the payload used by transferPreSigned
     * @param _token address The address of the token.
     * @param _fee uint256 The amount of tokens paid to msg.sender, by the owner.
     * @param _nonce uint256 Presigned transaction number.
     */
    function hashForReleaseSign(
        bytes4 _selector,
        address _token,
        uint256 _fee,
        uint256 _nonce
    )
        public
        pure
        returns (bytes32)
    {
        return keccak256(abi.encodePacked(_selector, _token, _fee, _nonce));
    }

    function recoverTokens(IERC20 token, address to, uint256 amount) public onlyOwner {
        require(address(token) != address(this), "Cannot recover Parsiq tokens");
        super.recoverTokens(token, to,  amount);
    }

    function _release(address beneficiary) internal
        notBurnerUntilBurnIsEnabled(beneficiary)
        returns (uint256) {
        uint256 tokens = _releaseLocks(timelocks[beneficiary], 0);
        if (transfersUnlockTime <= now) {
            tokens = tokens.add(_releaseLocks(relativeTimelocks[beneficiary], transfersUnlockTime));
        }

        if (tokens == 0) return 0;
        _transfer(address(this), beneficiary, tokens);
        _postTransfer(address(this), beneficiary, tokens);
        emit Released(beneficiary, tokens);
        return tokens;
    }

    function _releaseLocks(Timelock[] storage locks, uint256 relativeTime) internal returns (uint256) {
        uint256 tokens = 0;
        uint256 lockCount = locks.length;
        uint256 i = lockCount;
        while (i > 0) {
            i--;
            Timelock storage timelock = locks[i]; 
            if (relativeTime.add(timelock.time) > now) continue;
            
            tokens = tokens.add(timelock.amount);
            lockCount--;
            if (i != lockCount) {
                locks[i] = locks[lockCount];
            }
        }
        locks.length = lockCount;
        return tokens;
    }

    function _lockedBalanceOf(Timelock[] storage locks) internal view returns (uint256) {
        uint256 tokens = 0;
        uint256 n = locks.length;
        for (uint256 i = 0; i < n; i++) {
            tokens = tokens.add(locks[i].amount);
        }
        return tokens;
    }

    function _unlockableBalanceOf(Timelock[] storage locks, uint256 relativeTime) internal view returns (uint256) {
        uint256 tokens = 0;
        uint256 n = locks.length;
        for (uint256 i = 0; i < n; i++) {
            Timelock storage timelock = locks[i];
            if (relativeTime.add(timelock.time) <= now) {
                tokens = tokens.add(timelock.amount);
            }
        }
        return tokens;
    }

    function _postTransfer(address from, address to, uint256 value) internal {
        if (!to.isContract()) return;
        if (notify[to] == false) return;

        ITokenReceiver(to).tokensReceived(from, to, value);
    }

    function _addWhitelisted(address _address) internal {
        whitelisted[_address] = true;
        emit WhitelistedAdded(_address);
    }

    function _removeWhitelisted(address _address) internal {
        whitelisted[_address] = false;
        emit WhitelistedRemoved(_address);
    }
}