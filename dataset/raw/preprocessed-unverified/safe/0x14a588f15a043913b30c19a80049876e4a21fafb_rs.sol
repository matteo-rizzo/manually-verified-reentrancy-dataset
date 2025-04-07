/**
 *Submitted for verification at Etherscan.io on 2020-08-02
*/

pragma solidity >=0.6.2;
pragma experimental ABIEncoderV2;

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
     * @dev Leaves the contract without owner. It will not be possible to call
     * `onlyOwner` functions anymore. Can only be called by the current owner.
     *
     * NOTE: Renouncing ownership will leave the contract without an owner,
     * thereby removing any functionality that is only available to the owner.
     */
    function renounceOwnership() public onlyOwner {
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
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     */
    function _transferOwnership(address newOwner) internal {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}







/**
 * @dev Collection of functions related to the address type
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


/// @title dxDAO Token Multi-Registry
/// @notice Maintains multiple token lists, curated by the DAO
contract DXTokenRegistry is Ownable {
    event AddList(uint256 listId, string listName);
    event AddToken(uint256 listId, address token);
    event RemoveToken(uint256 listId, address token);

    enum TokenStatus {NULL, ACTIVE}

    struct TCR {
        uint256 listId;
        string listName;
        address[] tokens;
        mapping(address => TokenStatus) status;
        uint256 activeTokenCount;
    }

    mapping(uint256 => TCR) public tcrs;
    uint256 public listCount;

    /// @notice Add new token list.
    /// @param _listName Name of new list.
    /// @return New list ID.
    function addList(string memory _listName) public onlyOwner returns (uint256) {
        listCount++;
        tcrs[listCount].listId = listCount;
        tcrs[listCount].listName = _listName;
        tcrs[listCount].activeTokenCount = 0;
        emit AddList(listCount, _listName);
        return listCount;
    }

    /// @notice The owner can add new token(s) to existing list, by address.
    /// @dev Attempting to add token addresses which are already in the list will cause revert.
    /// @param _listId ID of list to add new tokens.
    /// @param _tokens Array of token addresses to add.
    function addTokens(uint256 _listId, address[] memory _tokens) public onlyOwner {
        require(_listId <= listCount, 'DXTokenRegistry : INVALID_LIST');
        for (uint32 i = 0; i < _tokens.length; i++) {
            require(
                tcrs[_listId].status[_tokens[i]] != TokenStatus.ACTIVE,
                'DXTokenRegistry : DUPLICATE_TOKEN'
            );
            tcrs[_listId].tokens.push(_tokens[i]);
            tcrs[_listId].status[_tokens[i]] = TokenStatus.ACTIVE;
            tcrs[_listId].activeTokenCount++;
            emit AddToken(_listId, _tokens[i]);
        }
    }

    /// @notice The owner can remove token(s) on existing list, by address.
    /// @dev Attempting to remove token addresses which are not active, or not present in the list, will cause revert.
    /// @param _listId ID of list to remove tokens from.
    /// @param _tokens Array of token addresses to remove.
    function removeTokens(uint256 _listId, address[] memory _tokens) public onlyOwner {
        require(_listId <= listCount, 'DXTokenRegistry : INVALID_LIST');
        for (uint32 i = 0; i < _tokens.length; i++) {
            require(
                tcrs[_listId].status[_tokens[i]] == TokenStatus.ACTIVE,
                'DXTokenRegistry : INACTIVE_TOKEN'
            );
            tcrs[_listId].status[_tokens[i]] = TokenStatus.NULL;
            uint256 tokenIndex = getTokenIndex(_listId, _tokens[i]);
            tcrs[_listId].tokens[tokenIndex] = tcrs[_listId].tokens[tcrs[_listId].tokens.length -
                1];
            tcrs[_listId].tokens.pop();
            tcrs[_listId].activeTokenCount--;
            emit RemoveToken(_listId, _tokens[i]);
        }
    }

    /// @notice Get all tokens tracked by a token list
    /// @param _listId ID of list to get tokens from.
    /// @return Array of token addresses tracked by list.
    function getTokens(uint256 _listId) public view returns (address[] memory) {
        require(_listId <= listCount, 'DXTokenRegistry : INVALID_LIST');
        return tcrs[_listId].tokens;
    }

    /// @notice Get active tokens from a list, within a specified index range.
    /// @param _listId ID of list to get tokens from.
    /// @param _start Start index.
    /// @param _end End index.
    /// @return tokensRange Array of active token addresses in index range.
    function getTokensRange(
        uint256 _listId,
        uint256 _start,
        uint256 _end
    ) public view returns (address[] memory tokensRange) {
        require(_listId <= listCount, 'DXTokenRegistry : INVALID_LIST');
        require(
            _start <= tcrs[_listId].tokens.length && _end < tcrs[_listId].tokens.length,
            'DXTokenRegistry : INVALID_RANGE'
        );
        require(_start <= _end, 'DXTokenRegistry : INVALID_INVERTED_RANGE');
        tokensRange = new address[](_end - _start + 1);
        uint32 activeCount = 0;
        for (uint256 i = _start; i <= _end; i++) {
            if (tcrs[_listId].status[tcrs[_listId].tokens[i]] == TokenStatus.ACTIVE) {
                tokensRange[activeCount] = tcrs[_listId].tokens[i];
                activeCount++;
            }
        }
    }

    /// @notice Check if list has a given token address active.
    /// @param _listId ID of list to get tokens from.
    /// @param _token Token address to check.
    /// @return Active status of given token address in list.
    function isTokenActive(uint256 _listId, address _token) public view returns (bool) {
        require(_listId <= listCount, 'DXTokenRegistry : INVALID_LIST');
        return tcrs[_listId].status[_token] == TokenStatus.ACTIVE ? true : false;
    }

    /// @notice Returns the array index of a given token address
    /// @param _listId ID of list to get tokens from.
    /// @param _token Token address to check.
    /// @return index position of given token address in list.
    function getTokenIndex(uint256 _listId, address _token) internal view returns (uint256) {
        for (uint256 i = 0; i < tcrs[_listId].tokens.length; i++) {
            if (tcrs[_listId].tokens[i] == _token) {
                return i;
            }
        }
    }

    /// @notice Convenience method to get ERC20 metadata for given tokens.
    /// @param _tokens Array of token addresses.
    /// @return names for each token.
    /// @return symbols for each token.
    /// @return decimals for each token.
    function getTokensData(address[] memory _tokens)
        public
        view
        returns (
            string[] memory names,
            string[] memory symbols,
            uint256[] memory decimals
        )
    {
        names = new string[](_tokens.length);
        symbols = new string[](_tokens.length);
        decimals = new uint256[](_tokens.length);
        for (uint32 i = 0; i < _tokens.length; i++) {
            names[i] = ERC20(_tokens[i]).name();
            symbols[i] = ERC20(_tokens[i]).symbol();
            decimals[i] = ERC20(_tokens[i]).decimals();
        }
    }

    /// @notice Convenience method to get account balances for given tokens.
    /// @param _trader Account to check balances for.
    /// @param _assetAddresses Array of token addresses.
    /// @return Account balances for each token.
    function getExternalBalances(address _trader, address[] memory _assetAddresses)
        public
        view
        returns (uint256[] memory)
    {
        uint256[] memory balances = new uint256[](_assetAddresses.length);
        for (uint256 i = 0; i < _assetAddresses.length; i++) {
            balances[i] = ERC20(_assetAddresses[i]).balanceOf(_trader);
        }
        return balances;
    }
}