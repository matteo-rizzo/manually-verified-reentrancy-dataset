/**
 *Submitted for verification at Etherscan.io on 2021-05-11
*/

/**
 *Submitted for verification at Etherscan.io on 2021-02-16
*/

// SPDX-License-Identifier: MIT

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

abstract contract Ownable is Context {
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

contract BasketCoin is ERC20, Ownable {
    using SafeMath for uint256;
    using Address for address;
    
    uint256 public burnFee = 1;
    uint256 public stakeFee = 1;
    uint256 public minTotalSupplyToBurn = 21e23;
    
    address public rewardContract;
    
    uint256 public maxPurchasableETHForPresale = 5e18;      // max purchable ETH amount in presale = 5 ETH
    uint256 public publicSaleRate = 10000;                  // 10000 BSKT per 1 ETH
    uint256 public preSaleRate = 11000;                     // 11000 BSKT per 1 ETH
    
    bool public saleStatus;                                 // false: sale impossible, true: sale possible
    bool public saleMode;                                   // false: presale, true: public sale
    mapping (address => uint256) public purchaseMap;
    mapping (address => bool) public whiteList;
    uint256 public preSaleSum;
    uint256 public publicSaleSum;
    
    event Purchased(address indexed purchaser, uint256 purchasedETH);
    event RewardContractUpdated(address indexed stakeContract);
    event SaleModeUpdated(bool saleMode);
    event SaleStatusUpdated(bool saleStatus);
    
    constructor(
    ) public ERC20("BasketCoin", "BSKT") {
        _mint(_msgSender(), 546e22);
        _mint(address(this), 1554e22);
    }
    
    function _transfer(
        address from,
        address to,
        uint256 amount
    ) internal override {
        require(rewardContract != address(0), 'BSKT: rewardContract is zeor address.');
        
        if(from == owner() || to == owner()) {
            super._transfer(from, to,  amount);
        } else {
            uint256 burnAmount = amount.mul(burnFee).div(100);
            uint256 stakeAmount = amount.mul(stakeFee).div(100);
            
            if(totalSupply().sub(burnAmount) >= minTotalSupplyToBurn) {
                super._burn(from, burnAmount);
                super._transfer(from, rewardContract,  stakeAmount);
                super._transfer(from, to,  amount.sub(stakeAmount).sub(burnAmount));
            } else {
                super._transfer(from, rewardContract,  stakeAmount.add(burnAmount));
                super._transfer(from, to,  amount.sub(stakeAmount).sub(burnAmount));
            }
        }
    }

    receive() external payable { purchase(); }
    
    function min(uint256 value1, uint256 value2) internal pure returns (uint256) {
        if(value1 <= value2)
            return value1;
        else
            return value2;
    }

    function purchase() public payable {
        require(saleStatus, 'BSKT: sale not started yet.');
        
        uint256 purchaseTokenAmount;
        uint256 purchasableETH;
        if(!saleMode) {
            require(whiteList[_msgSender()], 'BSKT: you are not in white list.');
            require(purchaseMap[_msgSender()] < maxPurchasableETHForPresale, 'BSKT: you already purchased max.');
            
            purchasableETH = min(maxPurchasableETHForPresale.sub(purchaseMap[_msgSender()]), msg.value);
            purchaseTokenAmount = purchasableETH.mul(preSaleRate);
            preSaleSum = preSaleSum.add(purchaseTokenAmount);
            uint256 refundETH = msg.value.sub(purchasableETH);
            
            purchaseMap[_msgSender()] = purchaseMap[_msgSender()].add(purchasableETH);

            if(refundETH > 0) {
                (bool success,) = _msgSender().call{ value: refundETH }("");
                require(success, "refund failed");
            }
        } else {
            purchasableETH = msg.value;
            purchaseTokenAmount = purchasableETH.mul(publicSaleRate);
            publicSaleSum = publicSaleSum.add(purchaseTokenAmount);
        }
        
        super._transfer(address(this), _msgSender(), purchaseTokenAmount);
        Purchased(_msgSender(), purchasableETH);
    }
    
    function burn(uint256 amount) external onlyOwner {
        super._burn(_msgSender(), amount);
    }
    
    function withdrawETH() public onlyOwner {
        (bool success,) = _msgSender().call{ value: address(this).balance }("");
        require(success, "withdraw failed");
    }
    
    function withdrawALL() public onlyOwner {
        super._transfer(address(this), _msgSender(), balanceOf(address(this)));
    }
    
    function updateRewardContract(address _rewardContract) public onlyOwner {
        require(_rewardContract != address(0), 'BSKT: rewardContract is zeor address.');
        rewardContract = _rewardContract;
        emit RewardContractUpdated(_rewardContract);
    }
    
    function updateSaleMode(bool _saleMode) public onlyOwner {
        if(saleMode != _saleMode) {
            saleMode = _saleMode;
            SaleModeUpdated(saleMode);
        }
    }
    
    function updateSaleStatus(bool _saleStatus) public onlyOwner {
        if(saleStatus != _saleStatus) {
            saleStatus = _saleStatus;
            SaleStatusUpdated(saleStatus);
        }
    }
    
    function addAddressToWhiteList(address account) public onlyOwner {
        whiteList[account] = true;
    }
    
    function removeAddressFromWhiteList(address account) public onlyOwner {
        whiteList[account] = false;
    }
}