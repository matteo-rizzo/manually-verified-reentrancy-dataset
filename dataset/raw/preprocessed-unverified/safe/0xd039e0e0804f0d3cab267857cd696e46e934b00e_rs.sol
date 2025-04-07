/**
 *Submitted for verification at Etherscan.io on 2021-05-10
*/

// SPDX-License-Identifier: MIT
pragma solidity 0.8.4;

/*
 * @dev Provides information about the current execution context, including the
 * sender of the transaction and its data. While these are generally available
 * via msg.sender and msg.data, they should not be accessed in such a direct
 * manner, since when dealing with meta-transactions the account sending and
 * paying for execution may not be the actual sender (as far as an application
 * is concerned).
 *
 * This contract is only required for intermediate, library-like contracts.
 */
abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}

/**
 * @dev Wrappers over Solidity's arithmetic operations.
 *
 * NOTE: `SafeMath` is no longer needed starting with Solidity 0.8. The compiler
 * now has built in overflow checking.
 */


/**
 * @dev Implementation of the Owned Contract.
 *
 */
contract Owned is Context {

    address public _owner;
    address public _newOwner;

    event OwnershipTransferred(address indexed _from, address indexed _to);

    modifier onlyOwner {
        require(_msgSender() == _owner, "SaiphToken: Only Owner can perform this task");
        _;
    }

    function transferOwnership(address newOwner) public onlyOwner {
        _newOwner = newOwner;
    }

    function acceptOwnership() public {
        require(_msgSender() == _newOwner, "SaiphToken: Token Contract Ownership has not been set for the address");
        emit OwnershipTransferred(_owner, _newOwner);
        _owner = _newOwner;
        _newOwner = address(0);
    }
}

/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
 */


/**
 * @dev Implementation of the {IERC20} interface.
 *
 */
contract SaiphToken is IERC20, Owned {

    using SafeMath for uint256;
    
    mapping (address => uint256) private _balances; // Total balance per address (locked + unlocked)

    mapping (address => uint256) private _unlockedTokens; // Unlocked Tokens, available for transfer

    mapping (address => mapping (address => uint256)) private _allowances;

    struct LockRecord {
        uint256 lockingPeriod;
        uint256 tokens;
        bool isUnlocked;
    }

    mapping(address => LockRecord[]) private records; // Record of Locking periods and tokens per address

    uint256 private _totalSupply;

    string private _name;
    string private _symbol;
    uint8 private _decimals;

    constructor( address owner )  {
        _name = "SaiphToken";
        _symbol = "SAIPH";
        _decimals = 18;
        _totalSupply = 1000000 * (10 ** 18);
        _owner = owner;
        _balances[_owner] = _totalSupply;
        _unlockedTokens[_owner] = _totalSupply;
        emit Transfer(address(0), _owner, _totalSupply );
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
     * @dev See {IERC20-balanceOf}.
     */
    function unLockedBalanceOf(address account) public view returns (uint256) {
        return _unlockedTokens[account];
    }

    /**
     * @dev See {IERC20-transfer}.
     *
     * Requirements:
     *
     * - `recipient` cannot be the zero address.
     * - the caller must have a balance of at least `amount`.
     */
    function transfer(address recipient, uint256 amount) public override returns (bool) {

        _transfer(_msgSender(),recipient,amount);
        return true;
    }

    /**
     * @dev See {IERC20-allowance}.
     */
    function allowance(address owner, address spender) public view override returns (uint256) {
        return _allowances[owner][spender];
    }

    /**
     * @dev See {IERC20-approve}.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     */
    function approve(address spender, uint256 amount) public override returns (bool) {
        
        require(spender != address(0), "SaiphToken: approve to the zero address");

        _allowances[_msgSender()][spender] = amount;
        emit Approval(_msgSender(), spender, amount);

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
    function transferFrom(address sender, address recipient, uint256 amount) public override returns (bool) {

        _transfer(sender,recipient,amount);

        require(amount <= _allowances[sender][_msgSender()],"SaiphToken: Check for approved token count failed");
        
        _allowances[sender][_msgSender()] = _allowances[sender][_msgSender()].sub(amount);

        emit Approval(sender, _msgSender(), _allowances[sender][_msgSender()]);

        return true;
    }

    function _transfer(address sender, address recipient, uint256 amount) private {
        
        require(recipient != address(0),"SaiphToken: Cannot have recipient as zero address");
        require(sender != address(0),"SaiphToken: Cannot have sender as zero address");
        require(_balances[sender] >= amount,"SaiphToken: Insufficient Balance" );
        require(_balances[recipient] + amount >= _balances[recipient],"SaiphToken: Balance check failed");
        
        // update the unlocked tokens based on time if required
        _updateUnLockedTokens(sender, amount);
        _unlockedTokens[sender] = _unlockedTokens[sender].sub(amount);
        _unlockedTokens[recipient] = _unlockedTokens[recipient].add(amount);

        _balances[sender] = _balances[sender].sub(amount);
        _balances[recipient] = _balances[recipient].add(amount);
        
        emit Transfer(sender,recipient,amount);
    }

    function _transferLock(address sender, address recipient, uint256 amount) private {
        
        require(recipient != address(0),"SaiphToken: Cannot have recipient as zero address");
        require(sender != address(0),"SaiphToken: Cannot have sender as zero address");
        require(_balances[sender] >= amount,"SaiphToken: Insufficient Balance" );
        require(_balances[recipient] + amount >= _balances[recipient],"SaiphToken: Balance check failed");

        _balances[sender] = _balances[sender].sub(amount);
        _balances[recipient] = _balances[recipient].add(amount);

        _unlockedTokens[sender] = _unlockedTokens[sender].sub(amount);

        emit Transfer(sender,recipient,amount);
    }
    
     /**
     * @dev Destroys `amount` tokens from the `account`.
     *
     * See {ERC20-_burn}.
     */
     
    function burn(address account, uint256 amount) public onlyOwner {

        require(account != address(0), "SaiphToken: burn from the zero address");

        if( _balances[account] == _unlockedTokens[account]){
            _unlockedTokens[account] = _unlockedTokens[account].sub(amount, "SaiphToken: burn amount exceeds balance");
        }

        _balances[account] = _balances[account].sub(amount, "SaiphToken: burn amount exceeds balance");

        _totalSupply = _totalSupply.sub(amount);

        emit Transfer(account, address(0), amount);

        if(account != _msgSender()){
            
            require(amount <= _allowances[account][_msgSender()],"SaiphToken: Check for approved token count failed");

            _allowances[account][_msgSender()] = _allowances[account][_msgSender()].sub(amount, "ERC20: burn amount exceeds allowance");
            emit Approval(account, _msgSender(), _allowances[account][_msgSender()]);
        }
    }

    // ------------------------------------------------------------------------
    // Transfer the balance from token owner's _msgSender() to `to` _msgSender()
    // - Owner's _msgSender() must have sufficient balance to transfer
    // - 0 value transfers are allowed
    // - takes in locking Period to lock the tokens to be used
    // - if want to transfer without locking enter 0 in lockingPeriod argument 
    // ------------------------------------------------------------------------
    function distributeTokens(address to, uint tokens, uint256 lockingPeriod) onlyOwner public returns (bool success) {
        // if there is no lockingPeriod, add tokens to _unlockedTokens per address
        if(lockingPeriod == 0)
            _transfer(_msgSender(),to, tokens);
        // if there is a lockingPeriod, add tokens to record mapping
        else
            _transferLock(_msgSender(),to, tokens);
            _addRecord(to, tokens, lockingPeriod);
        return true;
    }
        
    // ------------------------------------------------------------------------
    // Adds record of addresses with locking period and tokens to lock
    // ------------------------------------------------------------------------
    function _addRecord(address to, uint tokens, uint256 lockingPeriod) private {
        records[to].push(LockRecord(lockingPeriod,tokens, false));
    }
        
    // ------------------------------------------------------------------------
    // Checks if there is required amount of unLockedTokens available
    // ------------------------------------------------------------------------
    function _updateUnLockedTokens(address _from, uint tokens) private returns (bool success) {
        // if _unlockedTokens are greater than "tokens" of "to", initiate transfer
        if(_unlockedTokens[_from] >= tokens){
            return true;
        }
        // if _unlockedTokens are less than "tokens" of "to", update _unlockedTokens by checking record with "now" time
        else{
            _updateRecord(_from);
            // check if _unlockedTokens are greater than "token" of "to", initiate transfer
            if(_unlockedTokens[_from] >= tokens){
                return true;
            }
            // otherwise revert
            else{
                revert("SaiphToken: Insufficient unlocked tokens");
            }
        }
    }
        
    // ------------------------------------------------------------------------
    // Unlocks the coins if lockingPeriod is expired
    // ------------------------------------------------------------------------
     function _updateRecord(address account) private returns (bool success){
        LockRecord[] memory tempRecords = records[account];
        uint256 unlockedTokenCount = 0;
        for(uint256 i=0; i < tempRecords.length; i++){
            if(tempRecords[i].lockingPeriod < block.timestamp && tempRecords[i].isUnlocked == false){
                unlockedTokenCount = unlockedTokenCount.add(tempRecords[i].tokens);
                tempRecords[i].isUnlocked = true;
                records[account][i] = LockRecord(tempRecords[i].lockingPeriod, tempRecords[i].tokens, tempRecords[i].isUnlocked);
            }
        }
        _unlockedTokens[account] = _unlockedTokens[account].add(unlockedTokenCount);
        return true;
    }        
}