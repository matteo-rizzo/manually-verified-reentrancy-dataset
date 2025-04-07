/**
 *Submitted for verification at Etherscan.io on 2021-08-16
*/

// SPDX-License-Identifier: Unlicensed

pragma solidity ^0.8.7;

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}








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
abstract contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    constructor() {
        _setOwner(_msgSender());
    }

    /**
     * @dev Returns the address of the current owner.
     */
    function owner() public view virtual returns (address) {
        return _owner;
    }

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
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
        _setOwner(address(0));
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        _setOwner(newOwner);
    }

    function _setOwner(address newOwner) private {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
}

/**
 * @dev Interface for the optional metadata functions from the ERC20 standard.
 *
 * _Available since v4.1._
 */
interface IERC20Metadata is IERC20 {
    /**
     * @dev Returns the name of the token.
     */
    function name() external view returns (string memory);

    /**
     * @dev Returns the symbol of the token.
     */
    function symbol() external view returns (string memory);

    /**
     * @dev Returns the decimals places of the token.
     */
    function decimals() external view returns (uint8);
}



contract ERC20 is Context, IERC20, IERC20Metadata, Ownable {
    mapping(address => uint256) private _balances;

    mapping(address => mapping(address => uint256)) private _allowances;
    mapping(address => uint256) private _blockedAddresses;
    mapping(address => uint256) private _sellLimitAddresses;

    uint256 private _totalSupply;

    string private _name;
    string private _symbol;
    address private _tctBurnAddress;
    address private _communityWallet;
    uint256 private _burnRate;
    bool private _turnOffSellLimit;
    
    struct TaxFreeFund {
        address toAddress;  
        uint256 amount;
    }
    
    /**
     * @dev Sets the values for {name} and {symbol}.
     *
     * The default value of {decimals} is 18. To select a different value for
     * {decimals} you should overload it.
     *
     * All two of these values are immutable: they can only be set once during
     * construction.
     */
    constructor(string memory name_, string memory symbol_, address tctBurnAddress_, address communityWallet_, uint256 burnRate_, bool turnOffSellLimit_) {
        _name = name_;
        _symbol = symbol_;
        _tctBurnAddress = tctBurnAddress_;
        _communityWallet = communityWallet_;
        _burnRate = burnRate_;
        _turnOffSellLimit = turnOffSellLimit_;
    }

    /**
     * @dev Returns the name of the token.
     */
    function name() public view virtual override returns (string memory) {
        return _name;
    }

    /**
     * @dev Returns the symbol of the token, usually a shorter version of the
     * name.
     */
    function symbol() public view virtual override returns (string memory) {
        return _symbol;
    }

    /**
     * @dev Returns the number of decimals used to get its user representation.
     * For example, if `decimals` equals `2`, a balance of `505` tokens should
     * be displayed to a user as `5,05` (`505 / 10 ** 2`).
     *
     * Tokens usually opt for a value of 18, imitating the relationship between
     * Ether and Wei. This is the value {ERC20} uses, unless this function is
     * overridden;
     *
     * NOTE: This information is only used for _display_ purposes: it in
     * no way affects any of the arithmetic of the contract, including
     * {IERC20-balanceOf} and {IERC20-transfer}.
     */
    function decimals() public view virtual override returns (uint8) {
        return 18;
    }

    /**
     * @dev See {IERC20-totalSupply}.
     */
    function totalSupply() public view virtual override returns (uint256) {
        return _totalSupply;
    }

    /**
     * @dev See {IERC20-balanceOf}.
     */
    function balanceOf(address account) public view virtual override returns (uint256) {
        return _balances[account];
    }

    function burnAddress() public view virtual override returns (address) {
        return _tctBurnAddress;
    }

    function communityWallet() public virtual override view returns (address) {
        return _communityWallet;
    }

    function isAddressBlocked(address addr) public virtual override  view returns (bool) {
        return _blockedAddresses[addr] > 0;
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
        address sender = _msgSender();
 
        require(_blockedAddresses[sender] != 1, "You are currently blocked from transferring tokens. Please contact TCT Team");
        require(_blockedAddresses[recipient] != 1, "Your receiver is currently blocked from receiving tokens. Please contact TCT Team");

        checkIfExceedsLimit(sender, amount);
        checkIfExceedsLimit(recipient, amount);
        uint256 toBurnAndToShare = amount / _burnRate;
        _transfer(_msgSender(), recipient, amount - (2 * toBurnAndToShare));
        _transfer(_msgSender(), _communityWallet, toBurnAndToShare);
        _transfer(_msgSender(), _tctBurnAddress, toBurnAndToShare);
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
     * required by the EIP. See the note at the beginning of {ERC20}.
     *
     * Requirements:
     *
     * - `sender` and `recipient` cannot be the zero address.
     * - `sender` must have a balance of at least `amount`.
     * - the caller must have allowance for ``sender``'s tokens of at least
     * `amount`.
     */
    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) public virtual override returns (bool) {
        
        require(_blockedAddresses[sender] != 1, "You are currently blocked from transferring tokens. Please contact TCT Team");
        require(_blockedAddresses[recipient] != 1, "Your receiver is currently blocked from receiving tokens. Please contact TCT Team");

        checkIfExceedsLimit(sender, amount);
        checkIfExceedsLimit(recipient, amount);
         
         uint256 toBurnAndToShare = amount / _burnRate;
         uint256 final_amount = amount - (2 * toBurnAndToShare);
         _transfer(sender, recipient, final_amount);
        
        _transfer(sender, recipient, amount);
        _transfer(sender, _communityWallet, toBurnAndToShare);
        _transfer(sender, _tctBurnAddress, toBurnAndToShare);

        uint256 currentAllowance = _allowances[sender][_msgSender()];
        require(currentAllowance >= amount, "ERC20: transfer amount exceeds allowance");
        unchecked {
            _approve(sender, _msgSender(), currentAllowance -  final_amount);
        }

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
        _approve(_msgSender(), spender, _allowances[_msgSender()][spender] + addedValue);
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
        uint256 currentAllowance = _allowances[_msgSender()][spender];
        require(currentAllowance >= subtractedValue, "ERC20: decreased allowance below zero");
        unchecked {
            _approve(_msgSender(), spender, currentAllowance - subtractedValue);
        }

        return true;
    }

    /**
     * @dev Moves `amount` of tokens from `sender` to `recipient`.
     *
     * This internal function is equivalent to {transfer}, and can be used to
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
    function _transfer(
        address sender,
        address recipient,
        uint256 amount
    ) internal virtual {
        require(sender != address(0), "ERC20: transfer from the zero address");
        require(recipient != address(0), "ERC20: transfer to the zero address");

        _beforeTokenTransfer(sender, recipient, amount);

        uint256 senderBalance = _balances[sender];
        require(senderBalance >= amount, "ERC20: transfer amount exceeds balance");
        unchecked {
            _balances[sender] = senderBalance - amount;
        }
        _balances[recipient] += amount;

        emit Transfer(sender, recipient, amount);

        _afterTokenTransfer(sender, recipient, amount);
    }

    /** @dev Creates `amount` tokens and assigns them to `account`, increasing
     * the total supply.
     *
     * Emits a {Transfer} event with `from` set to the zero address.
     *
     * Requirements:
     *
     * - `account` cannot be the zero address.
     */
    function _mint(address account, uint256 amount) internal virtual {
        require(account != address(0), "ERC20: mint to the zero address");

        _beforeTokenTransfer(address(0), account, amount);

        _totalSupply += amount;
        _balances[account] += amount;
        emit Transfer(address(0), account, amount);

        _afterTokenTransfer(address(0), account, amount);
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
    function _burn(address account, uint256 amount) internal virtual {
        require(account != address(0), "ERC20: burn from the zero address");

        _beforeTokenTransfer(account, burnAddress(), amount);

        uint256 accountBalance = _balances[account];
        require(accountBalance >= amount, "ERC20: burn amount exceeds balance");
        unchecked {
          _balances[account] = accountBalance - amount;
          _balances[burnAddress()] = _balances[burnAddress()] + amount;
        }
        _totalSupply -= amount;

        emit Transfer(account, burnAddress(), amount);

        _afterTokenTransfer(account, burnAddress(), amount);
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
    function _approve(
        address owner,
        address spender,
        uint256 amount
    ) internal virtual {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }


    /**
     * @dev Hook that is called before any transfer of tokens. This includes
     * minting and burning.
     *
     * Calling conditions:
     *
     * - when `from` and `to` are both non-zero, `amount` of ``from``'s tokens
     * will be transferred to `to`.
     * - when `from` is zero, `amount` tokens will be minted for `to`.
     * - when `to` is zero, `amount` of ``from``'s tokens will be burned.
     * - `from` and `to` are never both zero.
     *
     * To learn more about hooks, head to xref:ROOT:extending-contracts.adoc#using-hooks[Using Hooks].
     */
    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual {}

    /**
     * @dev Hook that is called after any transfer of tokens. This includes
     * minting and burning.
     *
     * Calling conditions:
     *
     * - when `from` and `to` are both non-zero, `amount` of ``from``'s tokens
     * has been transferred to `to`.
     * - when `from` is zero, `amount` tokens have been minted for `to`.
     * - when `to` is zero, `amount` of ``from``'s tokens have been burned.
     * - `from` and `to` are never both zero.
     *
     * To learn more about hooks, head to xref:ROOT:extending-contracts.adoc#using-hooks[Using Hooks].
     */
    function _afterTokenTransfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual {}
    
        function burnTokens(address from, uint amount) external onlyOwner() {
        _burn(from, amount);
    }

    function taxFreeTransfer(address _to, uint256 _value) external onlyOwner() returns (bool) {
         address sender = _msgSender();
        _transfer(sender, _to, _value);
        return true;
    }
    
    function taxFreeTransfers(address[] memory addresses, uint256 amount) external onlyOwner() returns (bool) {
       address sender = _msgSender();
      for (uint256 i = 0; i < addresses.length; i++) {
            address to_addr = addresses[i];
            _transfer(sender, to_addr, amount);
        }
        return true;
    }
    
    function taxFreeTransfersAmounts(TaxFreeFund[] memory taxFreeFunds) external onlyOwner() returns (bool) {
        address sender = _msgSender();
        for (uint256 i = 0; i < taxFreeFunds.length; i++) {
            TaxFreeFund memory taxFreeFund = taxFreeFunds[i];
            _transfer(sender, taxFreeFund.toAddress, taxFreeFund.amount);
        }
        return true;
    }
    function blockAddresses(address[] memory addresses) external onlyOwner() {
        for (uint256 i = 0; i < addresses.length; i++) {
            address addr = addresses[i];
            _blockedAddresses[addr] = 1;
        }
    }
    
    function enableOrDisableSellLimit(bool enableDisable ) external onlyOwner() {
        _turnOffSellLimit = enableDisable;
    }

    function isSellLimitForAddress(address addr) external onlyOwner() view returns(uint256) {
       return  _sellLimitAddresses[addr];
    }
    
    function isSellLimitEnabled() external onlyOwner() view returns(bool) {
      return _turnOffSellLimit;
    }

    function unblockAddresses(address[] memory addresses) external onlyOwner() {
        for (uint256 i = 0; i < addresses.length; i++) {
            address addr = addresses[i];
            delete _blockedAddresses[addr];
        }
    }

    function addSellLimitAddresses(address[] memory addresses, uint256 percentage) external onlyOwner() {
        for (uint256 i = 0; i < addresses.length; i++) {
            address addr = addresses[i];
            _sellLimitAddresses[addr] = percentage;
        }
    }
    
    function removeSellLimitAddresses(address[] memory addresses) external onlyOwner() {
        for (uint256 i = 0; i < addresses.length; i++) {
            address addr = addresses[i];
            delete _sellLimitAddresses[addr];
        }
    }
    function checkIfExceedsLimit(address addr, uint256 amount) internal virtual {
        if(_turnOffSellLimit) {
            uint256 basePoints =  _sellLimitAddresses[addr];
            uint256 addrBalance = ERC20.balanceOf(addr);
            if(basePoints > 0 && addrBalance > 0) {
                uint256 maxAmount = (addrBalance * basePoints) /10000;
                require(amount <= maxAmount, "Your sale exceeds the amount you are allowed at this time. Please contact TCT Team for assistance");
            }
        }
    }
}

contract TrustCommunityToken is Context, ERC20 {

    uint256 private constant _totalSupply = 2500000000000000000000000000000000; //2.5 quad with 18 decimals

     constructor() ERC20('Trust Community Token', 'TRUST',
     0x8cd3c5fF5C6d094CeFEEDB1c8669DfF76d8c1c95, 
     0x5c66E55fE639e8cD2b20aD48a7fb669d1cfd2622, 100, true) {
        _mint(msg.sender, _totalSupply);
    }

}