/**
 *Submitted for verification at Etherscan.io on 2019-07-10
*/

pragma solidity 0.5.10;


/**
 * @dev Wrappers over Solidity&#39;s arithmetic operations with added overflow
 * checks.
 *
 * Arithmetic operations in Solidity wrap on overflow. This can easily result
 * in bugs, because programmers usually assume that an overflow raises an
 * error, which is the standard behavior in high level programming languages.
 * `SafeMath` restores this intuition by reverting the transaction when an
 * operation overflows.
 *
 * Using this library instead of the unchecked operations eliminates an entire
 * class of bugs, so it&#39;s recommended to use it always.
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
 * these events, as it isn&#39;t required by the specification.
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
     * - the caller must have allowance for `sender`&#39;s tokens of at least
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
     * from the caller&#39;s allowance.
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



/**
 * @title SafeERC20
 * @dev Wrappers around ERC20 operations that throw on failure (when the token
 * contract returns false). Tokens that return no value (and instead revert or
 * throw on failure) are also supported, non-reverting calls are assumed to be
 * successful.
 * To use this library you can add a `using SafeERC20 for ERC20;` statement to your contract,
 * which allows you to call the safe operations as `token.safeTransfer(...)`, etc.
 */


contract TokenRecoverable is Ownable {
    using SafeERC20 for IERC20;

    function recoverTokens(IERC20 token, address to, uint256 amount) public onlyOwner {
        uint256 balance = token.balanceOf(address(this));
        require(balance >= amount, "Given amount is larger than current balance");
        token.safeTransfer(to, amount);
    }
}



contract CloudToken is TokenRecoverable, ERC20 {
    using SafeMath for uint256;
    using ECDSA for bytes32;
    using Address for address;
    
    string public constant name = "Files.fm Cloud Token";
    string public constant symbol = "CLOUD";
    uint8 public constant decimals = uint8(18);

    mapping(address => bool) public notify;
    mapping(address => Timelock[]) public timelocks;
    address public burnAddress;
    address public controller;
    mapping(bytes32 => bool) private hashedTxs;
    bool public etherlessTransferEnabled = true;

    struct Timelock {
        uint256 till;
        uint256 amount;
    }

    event TransferPreSigned(address indexed from, address indexed to, address indexed delegate, uint256 amount, uint256 fee);
    event TransferLocked(address indexed from, address indexed to, uint256 amount, uint256 until);
    event Released(address indexed to, uint256 amount);

    modifier onlyEtherlessTransferEnabled {
        require(etherlessTransferEnabled == true, "Etherless transfer functionality disabled");
        _;
    }
    
    modifier onlyController() {
        require(msg.sender == controller, "Only controller can mint tokens");
        _;
    }

    modifier onlyBurnAddress() {
        require(msg.sender == burnAddress, "Only burnAddress can burn tokens");
        _;
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

    function transfer(address to, uint256 value) public returns (bool) {
        if (to == address(this)) {
            _release(msg.sender);
            return true;
        }
        bool success = super.transfer(to, value);
        if (success) {
            _postTransfer(msg.sender, to, value);
        }
        return success;
    }

    function transferFrom(address from, address to, uint256 value) public returns (bool) {
        if (to == address(this)) {
            _release(msg.sender);
            return true;
        }
        bool success = super.transferFrom(from, to, value);
        if (success) {
            _postTransfer(from, to, value);
        }
        return success;
    }

    function transferLocked(address to, uint256 value, uint256 until) public returns (bool) {
        require(to != address(this), "Cannot lock on contract address");
        require(to != address(0), "ERC20: transfer to the zero address");
        require(value > 0, "Value must be positive");
        require(until > now, "Until must be future value");

        _transfer(msg.sender, address(this), value);

        timelocks[to].push(Timelock({ till: until, amount: value }));

        emit TransferLocked(msg.sender, to, value, until);
    }

    function release() public {
        _release(msg.sender);
    }

    function lockedBalanceOf(address who) public view returns (uint256) {
        Timelock[] storage locks = timelocks[who];
        uint256 tokens = 0;
        uint256 n = locks.length;
        for (uint256 i = 0; i < n; i++) {
            tokens = tokens.add(locks[i].amount);
        }
        return tokens;  
    }
    
    function unlockableBalanceOf(address who) public view returns (uint256) {
        Timelock[] storage locks = timelocks[who];
        uint256 tokens = 0;
        uint256 n = locks.length;
        for (uint256 i = 0; i < n; i++) {
            Timelock storage timelock = locks[i];
            if (timelock.till <= now) {
                tokens = tokens.add(timelock.amount);
            }
        }
        return tokens;  
    }

    function totalBalanceOf(address who) public view returns (uint256) {
        return balanceOf(who).add(lockedBalanceOf(who));
    }

    /**
     * @dev Burns a specific amount of tokens.
     * @param value The amount of token to be burned.
     */
    function burn(uint256 value) public onlyBurnAddress {
        _burn(msg.sender, value);
    }

    function setBurnAddress(address _burnAddress) public onlyOwner {
        require(balanceOf(_burnAddress) == 0, "Burn address must have zero balance!");

        burnAddress = _burnAddress;
    }

    /**
     * @dev Function to mint tokens
     * @param to The address that will receive the minted tokens.
     * @param value The amount of tokens to mint.
     * @return A boolean that indicates if the operation was successful.
     */
    function mint(address to, uint256 value) public onlyController returns (bool) {
        require(to != address(this), "Cannot mint to token contract");
        _mint(to, value);
        _postTransfer(address(0), to, value);
        return true;
    }

    /**
     * @dev Function to mint tokens
     * @param to The address that will receive the minted tokens.
     * @param amounts The amount of tokens to mint.
     * @return A boolean that indicates if the operation was successful.
     */
    function mintTokens(address[] memory to, uint256[] memory amounts) public onlyController returns (bool) {
        require(to.length > 0 && to.length <= 100);
        require(to.length == amounts.length);

        for (uint256 i = 0; i < to.length; i++) {
            require(to[i] != address(this), "Cannot mint to token contract");
            _mint(to[i], amounts[i]);
            _postTransfer(address(0), to[i], amounts[i]);
        }
        return true;
    }

    function setController(address _controller) public onlyOwner {
        require(controller == address(0));
        controller = _controller;
    }

    /** Etherless Transfer */
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
        onlyEtherlessTransferEnabled
        returns (bool)
    {
        require(_to != address(0), "Transfer to the zero address");

        bytes32 hashedParams = hashForSign(msg.sig, address(this), _to, _value, _fee, _nonce);
        address from = hashedParams.toEthSignedMessageHash().recover(_signature);
        require(from != address(0), "Invalid signature");

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
        onlyEtherlessTransferEnabled
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
        if (from != msg.sender) { // "from" already have all the tokens
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


    function _release(address beneficiary) internal returns (uint256) {
        Timelock[] storage locks = timelocks[beneficiary];
        uint256 tokens = 0;
        uint256 till;
        uint256 n = locks.length;
        uint256 i = n;
        while (i > 0) {
            i--;
            Timelock storage timelock = locks[i];
            till = timelock.till;
            if (till <= now) {
                tokens = tokens.add(timelock.amount);
                n--;
                if (i != n) {
                    locks[i] = locks[n];
                }
            }
        }
        locks.length = n;
        if (tokens == 0) return 0;

        _transfer(address(this), beneficiary, tokens);
        _postTransfer(address(this), beneficiary, tokens);
        emit Released(beneficiary, tokens);
        return tokens;
    }

    function _postTransfer(address from, address to, uint256 value) internal {
        if (to.isContract()) {
            if (notify[to] == false) return;

            ITokenReceiver(to).tokensReceived(from, to, value);
        } else {
            if (to == burnAddress) {
                _burn(burnAddress, value);
            }
        }
    }
}


contract CloudTokenController is TokenRecoverable {
    using SafeMath for uint256;

    struct MintScheduleItem {
        uint256 amount;
        uint256 till;
    }

    address public token;
    address public tokenMinter;
    MintScheduleItem[] public mintingSchedule;
    uint256 public currentItem = 0;

    modifier canMint() {
        require(mintingSchedule.length > 0, "Contract not initialized");
        require(msg.sender == owner() || msg.sender == tokenMinter, "Only owner or token minter can mint tokens");
        _;
    }

    constructor(address _token) public {
        token = _token;
    }

    function initialize() public {
        require(mintingSchedule.length == 0);
        require(CloudToken(address(token)).controller() == address(this));
        require(IERC20(address(token)).totalSupply() == 0);

        mintingSchedule.push(MintScheduleItem({ amount: 1703000000e18, till: 1577836800 })); // 01-01-2020
        mintingSchedule.push(MintScheduleItem({ amount: 1572000000e18, till: 1609459200 })); // 01-01-2021
        mintingSchedule.push(MintScheduleItem({ amount: 2148400000e18, till: 1640995200 })); // 01-01-2022
        mintingSchedule.push(MintScheduleItem({ amount: 2148400000e18, till: 1672531200 })); // 01-01-2023
        mintingSchedule.push(MintScheduleItem({ amount: 2428200000e18, till: 1704067200 })); // 01-01-2024
        mintingSchedule.push(MintScheduleItem({ amount: 0, till: ~uint256(0) }));
    }

    function setTokenMinter(address _tokenMinter) public onlyOwner {
        tokenMinter = _tokenMinter;
    }

    function mint(address _tokenHolder, uint256 _amount) public canMint {
        ensureCurrentSchedule();
        require(mintingSchedule[currentItem].amount >= _amount, "Not enough tokens");
        mintingSchedule[currentItem].amount = mintingSchedule[currentItem].amount.sub(_amount);
        CloudToken(address(token)).mint(_tokenHolder, _amount);
    }

    function mintTokens(address[] memory _tokenHolders, uint256[] memory _amounts) public canMint {
        ensureCurrentSchedule();
        uint256 total = 0;
        for (uint256 i = 0; i < _amounts.length; i++) {
            total = total.add(_amounts[i]);
        }
        require(mintingSchedule[currentItem].amount >= total, "Not enough tokens");
        mintingSchedule[currentItem].amount = mintingSchedule[currentItem].amount.sub(total);
        CloudToken(address(token)).mintTokens(_tokenHolders, _amounts);
    }

    function ensureCurrentSchedule() internal {
        MintScheduleItem storage item = mintingSchedule[currentItem];
        while (item.till < now) {
            MintScheduleItem storage lastItem = mintingSchedule[mintingSchedule.length - 1]; 
            lastItem.amount = lastItem.amount.add(item.amount); // move all unsold tokens to last stage
            item.amount = 0;
            currentItem = currentItem.add(1);
            item = mintingSchedule[currentItem];
        }
    }

    function recoverTokens(IERC20 _token, address _to, uint256 _amount) public onlyOwner {
        require(
            address(token) != address(_token) || 
            IERC20(address(token)).balanceOf(address(this)) >= _amount, "Insufficient balance");
        super.recoverTokens(_token, _to, _amount);
    }
}