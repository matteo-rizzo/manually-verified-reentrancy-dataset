/**
 *Submitted for verification at Etherscan.io on 2021-01-02
*/

pragma solidity ^0.6.6;







abstract contract Context {
    function _msgSender() internal view virtual returns (address payable) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes memory) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}


contract ERC20 is Context, IERC20 {
    using SafeMath for uint256;

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
    constructor (string memory name_, string memory symbol_) public {
        _name = name_;
        _symbol = symbol_;
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
     * required by the EIP. See the note at the beginning of {ERC20}.
     *
     * Requirements:
     *
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
     * Requirements:
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
     * Requirements:
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







/**
 * @title Linear Bonding Curve Token
 * @author github.com/Shalquiana based on the work of Molly Wintermute
 * @dev Bonding curve ERC20 Token based on linear formula
 * inspired by Hegic.co
 */
contract LinearBondingCurve is ERC20{
  address payable devFund;
  address payable hegic;
  using SafeMath for uint;
  
  uint internal immutable K;
  uint internal immutable START_PRICE;
  uint public soldAmount;
  
  event Bought(address indexed account, uint amount, uint ethAmount);
  event Sold(address indexed account, uint amount, uint ethAmount, uint comission);

  constructor (string memory name_, string memory symbol_, uint k, uint startPrice, address payable hegic_) public ERC20(name_, symbol_){
    K = k;
    START_PRICE = startPrice;
    devFund = msg.sender;
    hegic = hegic_;
    _setupDecimals(9);
  }

  function buy(uint tokenAmount) external payable {
     uint nextSold = soldAmount.add(tokenAmount);
     uint ethAmount = s(soldAmount, nextSold);
     
     require(msg.value >= ethAmount, "Value is to small");
     _mint(msg.sender, tokenAmount);
     if (msg.value > ethAmount) {
         msg.sender.transfer(msg.value - ethAmount);
     }
     soldAmount = nextSold;
     emit Bought(msg.sender, tokenAmount, ethAmount);
  }
  
 
  function sell(uint tokenAmount) external {
     uint nextSold = soldAmount.sub(tokenAmount);
     uint ethAmount = s(nextSold, soldAmount);
     uint comission = ethAmount.div(10);
     uint refund = ethAmount.sub(comission);
     require(balanceOf(msg.sender) >= tokenAmount, "insufficent balance");
     require(comission > 0);
     uint hegicComission = comission.div(10);
     soldAmount = nextSold;
     _burn(msg.sender, tokenAmount);
     msg.sender.transfer(refund);
     
     if (hegicComission > 0) {
        devFund.transfer(comission.sub(hegicComission));
        hegic.transfer(hegicComission);
     } else {
        devFund.transfer(comission);
     } 
    
     emit Sold(msg.sender, tokenAmount, refund, comission);
    }

  

    function s(uint x0, uint x1) public view returns (uint) {
        require (x1 > x0, "invalid formula amounts");
        return  x1.add(x0).mul(x1.sub(x0))
            .div(2).div(K)
            .add(START_PRICE.mul(x1 - x0))
            .div(1e18);
    }
}


contract PoolERC20 is ERC20 {
    using SafeMath for uint256;
    address payable public tokenAddress;
    address public owner;
    mapping(address=>uint256) public lastStake;
    uint256 public lockedAmount;
    uint256 public feePercent;
    bool public open = true;

    modifier onlyOwner() {
        require(owner == msg.sender, "Ownable: caller is not the owner");
        _;
    }


    event Payout(uint256 poolLost, address winner);


    function getMaxAvailable() public view returns(uint256) {
        LinearBondingCurve token = LinearBondingCurve(tokenAddress);
        uint256 balance = token.balanceOf(address(this));
        if (balance > lockedAmount) {
            return balance.sub(lockedAmount);
        } else {
            return 0;
        }
    }

    constructor(string memory name_, string memory symbol_, address payable token_, address owner_, uint256 feePercent_) public ERC20(name_, symbol_){
        tokenAddress = token_;
        owner = owner_;
        feePercent = feePercent_;
        lockedAmount = 0;
    }

    function thisAddress() public view returns (address){
        return address(this);
    }

    function updateFeePercent(uint256 feePercent_) external onlyOwner {
        require(feePercent_ > 1 && feePercent_ < 50, "invalid fee");
        feePercent = feePercent_;
    }

     /**
     * @notice used to send this pool into EOL mode when a newer one is open
     */
    function closeStaking() external onlyOwner {
        open = false;
    }


    function stake(uint256 amount) external {
        require(open == true, "pool deposits has closed");
        lastStake[msg.sender] = block.timestamp;
        LinearBondingCurve token = LinearBondingCurve(tokenAddress);
        require(token.balanceOf(msg.sender) >= amount, "You don't have enough of the underlying token");
        token.transferFrom(msg.sender, address(this), amount);
        _mint(msg.sender, amount);
    }

    function withdraw(uint256 amount) public {
        LinearBondingCurve token = LinearBondingCurve(tokenAddress);
        require(block.timestamp >= lastStake[msg.sender]+14 days, "Incomplete staking time");
        require (balanceOf(msg.sender) >= amount, "Insufficent Share Balance");
        uint256 poolBalance = token.balanceOf(address(this));
        uint256 valueToRecieve = amount.mul(poolBalance).div(totalSupply());
        _burn(msg.sender, amount);
        require(token.transfer(msg.sender, valueToRecieve), "transfer failed");
    }

    /**
    @dev called by BinaryOptions contract to lock pool value coresponding to new binary options bought. 
    @param amount amount in BIOP to lock from the pool total.
    */
    function lock(uint256 amount) external onlyOwner {
        lockedAmount = lockedAmount.add(amount);
    }

    /**
    @dev called by BinaryOptions contract to unlock pool value coresponding to an option expiring otm. 
    @param amount amount in BIOP to unlock
    @param goodSamaritan the user paying to unlock these funds, they recieve a fee
    */
    function unlock(uint256 amount, address goodSamaritan) external onlyOwner {
        require(amount <= lockedAmount, "insufficent pool balance available to unlock");
        lockedAmount = lockedAmount.sub(amount);

        uint256 fee = amount.div(feePercent);
        LinearBondingCurve token = LinearBondingCurve(tokenAddress);
        token.transfer(goodSamaritan, fee);
    }

    /**
    @dev called by BinaryOptions contract to payout pool value coresponding to binary options expiring itm. 
    @param amount amount in BIOP to unlock
    @param exerciser address calling the exercise/expire function, this may the winner or another user who then earns a fee.
    @param winner address of the winner.
    @notice exerciser fees are subject to change see updateFeePercent above.
    */
    function payout(uint256 amount, address exerciser, address winner) external onlyOwner {
        require(amount <= lockedAmount, "insufficent pool balance available to payout");
        LinearBondingCurve token = LinearBondingCurve(tokenAddress);
        
        require(amount <= token.balanceOf(address(this)), "insufficent balance in pool");
        lockedAmount = lockedAmount.sub(amount);
        if (exerciser != winner && amount.div(feePercent) > 0) {
            //good samaratin fee
            uint256 fee = amount.div(feePercent);
            token.transfer(exerciser, fee);
            token.transfer(winner, amount.sub(fee));
        } else {
            token.transfer(winner, amount);
        }
        emit Payout(amount, winner);
    }


}