/**
 *Submitted for verification at Etherscan.io on 2020-10-10
*/

pragma solidity ^0.7.0;



/**
 * @dev Collection of functions related to the address type
 */


/**
 * @dev Standard math utilities missing in the Solidity language.
 */








abstract contract Context {
    function _msgSender() internal view virtual returns (address payable) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes memory) {
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
    constructor () {
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
    constructor (string memory name, string memory symbol) {
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


contract DokiCoinCore is ERC20("DokiDokiFinance", "DOKI") {
    using SafeMath for uint256;

    address internal _taxer;
    address internal _taxDestination;
    uint internal _taxRate = 0;
    mapping (address => bool) internal _taxWhitelist;

    function transfer(address recipient, uint256 amount) public override returns (bool) {
        uint256 taxAmount = amount.mul(_taxRate).div(100);
        if (_taxWhitelist[msg.sender] == true) {
            taxAmount = 0;
        }
        uint256 transferAmount = amount.sub(taxAmount);
        require(balanceOf(msg.sender) >= transferAmount, "insufficient balance.");
        super.transfer(recipient, amount);

        if (taxAmount != 0) {
            super.transfer(_taxDestination, taxAmount);
        }
        return true;
    }

    function transferFrom(address sender, address recipient, uint256 amount) public override returns (bool) {
        uint256 taxAmount = amount.mul(_taxRate).div(100);
        if (_taxWhitelist[sender] == true) {
            taxAmount = 0;
        }
        uint256 transferAmount = amount.sub(taxAmount);
        require(balanceOf(sender) >= transferAmount, "insufficient balance.");
        super.transferFrom(sender, recipient, amount);
        if (taxAmount != 0) {
            super.transferFrom(sender, _taxDestination, taxAmount);
        }
        return true;
    }
}

contract DokiCoin is DokiCoinCore, Ownable {
    mapping (address => bool) public minters;

    constructor() {
        _taxer = owner();
        _taxDestination = owner();
    }

    function mint(address to, uint amount) public onlyMinter {
        _mint(to, amount);
    }

    function burn(uint amount) public {
        require(amount > 0);
        require(balanceOf(msg.sender) >= amount);
        _burn(msg.sender, amount);
    }

    function addMinter(address account) public onlyOwner {
        minters[account] = true;
    }

    function removeMinter(address account) public onlyOwner {
        minters[account] = false;
    }

    modifier onlyMinter() {
        require(minters[msg.sender], "Restricted to minters.");
        _;
    }

    modifier onlyTaxer() {
        require(msg.sender == _taxer, "Only for taxer.");
        _;
    }

    function setTaxer(address account) public onlyTaxer {
        _taxer = account;
    }

    function setTaxRate(uint256 rate) public onlyTaxer {
        _taxRate = rate;
    }

    function setTaxDestination(address account) public onlyTaxer {
        _taxDestination = account;
    }

    function addToWhitelist(address account) public onlyTaxer {
        _taxWhitelist[account] = true;
    }

    function removeFromWhitelist(address account) public onlyTaxer {
        _taxWhitelist[account] = false;
    }

    function taxer() public view returns(address) {
        return _taxer;
    }

    function taxDestination() public view returns(address) {
        return _taxDestination;
    }

    function taxRate() public view returns(uint256) {
        return _taxRate;
    }

    function isInWhitelist(address account) public view returns(bool) {
        return _taxWhitelist[account];
    }
}


contract LPToDOKI is Ownable {
    using SafeMath for uint256;
    using SafeERC20 for DokiCoin;
    using SafeERC20 for IERC20;
    using Address for address;

    DokiCoin private doki;
    IERC20 private lpToken;

    //LP token balances
    mapping(address => uint256) private _lpBalances;
    uint private _lpTotalSupply;

    // halving period time
    uint256 public constant DURATION = 2 weeks;
    // initial amount of doki
    uint256 public initReward = 500 * 1e18;
    bool public haveStarted = false;
    // next time of halving
    uint256 public halvingTime = 0;
    uint256 public lastUpdateTime = 0;
    // distribution of per second
    uint256 public rewardRate = 0;
    uint256 public rewardPerLPToken = 0;
    mapping(address => uint256) private rewards;
    mapping(address => uint256) private userRewardPerTokenPaid;


    // Something about dev.
    address public devAddr;
    uint256 public devDistributeRate = 0;
    uint256 public lastDistributeTime = 0;
    uint256 public devFinishTime = 0;
    uint256 public devFundAmount = 90 * 1e18;
    uint256 public devDistributeDuration = 180 days;

    event Stake(address indexed from, uint amount);
    event Withdraw(address indexed to, uint amount);
    event Claim(address indexed to, uint amount);
    event Halving(uint amount);
    event Start(uint amount);

    constructor(address _doki, address _lpToken) {
        doki = DokiCoin(_doki);
        lpToken = IERC20(_lpToken);
        devAddr = owner();
    }

    function totalSupply() public view returns(uint256) {
        return _lpTotalSupply;
    }

    function balanceOf(address account) public view returns(uint256) {
        return _lpBalances[account];
    }

    function stake(uint amount) public shouldStarted {
        updateRewards(msg.sender);
        checkHalving();
        require(!address(msg.sender).isContract(), "Please use your individual account.");
        lpToken.safeTransferFrom(msg.sender, address(this), amount);
        _lpTotalSupply = _lpTotalSupply.add(amount);
        _lpBalances[msg.sender] = _lpBalances[msg.sender].add(amount);
        distributeDevFund();
        emit Stake(msg.sender, amount);
    }

    function withdraw(uint amount) public shouldStarted {
        updateRewards(msg.sender);
        checkHalving();
        require(amount <= _lpBalances[msg.sender] && _lpBalances[msg.sender] > 0, "Bad withdraw.");
        lpToken.safeTransfer(msg.sender, amount);
        _lpTotalSupply = _lpTotalSupply.sub(amount);
        _lpBalances[msg.sender] = _lpBalances[msg.sender].sub(amount);
        distributeDevFund();
        emit Withdraw(msg.sender, amount);
    }

    function claim(uint amount) public shouldStarted {
        updateRewards(msg.sender);
        checkHalving();
        require(amount <= rewards[msg.sender] && rewards[msg.sender] > 0, "Bad claim.");
        rewards[msg.sender] = rewards[msg.sender].sub(amount);
        doki.safeTransfer(msg.sender, amount);
        distributeDevFund();
        emit Claim(msg.sender, amount);
    }

    function checkHalving() internal {
        if (block.timestamp >= halvingTime) {
            initReward = initReward.mul(50).div(100);
            doki.mint(address(this), initReward);

            rewardRate = initReward.div(DURATION);
            halvingTime = halvingTime.add(DURATION);

            updateRewards(msg.sender);
            emit Halving(initReward);
        }
    }

    modifier shouldStarted() {
        require(haveStarted == true, "Have not started.");
        _;
    }

    function getRewardsAmount(address account) public view returns(uint256) {
        return balanceOf(account).mul(rewardPerToken().sub(userRewardPerTokenPaid[account]))
                .div(1e18)
                .add(rewards[account]);
    }

    function rewardPerToken() public view returns (uint256) {
        if (_lpTotalSupply == 0) {
            return rewardPerLPToken;
        }
        return rewardPerLPToken
            .add(Math.min(block.timestamp, halvingTime)
                    .sub(lastUpdateTime)
                    .mul(rewardRate)
                    .mul(1e18)
                    .div(_lpTotalSupply)
            );
    }

    function updateRewards(address account) internal {
        rewardPerLPToken = rewardPerToken();
        lastUpdateTime = lastRewardTime();
        if (account != address(0)) {
            rewards[account] = getRewardsAmount(account);
            userRewardPerTokenPaid[account] = rewardPerLPToken;
        }
    }

    function lastRewardTime() public view returns (uint256) {
        return Math.min(block.timestamp, halvingTime);
    }

    function startFarming() external onlyOwner {
        updateRewards(address(0));
        rewardRate = initReward.div(DURATION);

        uint256 mintAmount = initReward.add(devFundAmount);
        doki.mint(address(this), mintAmount);
        devDistributeRate = devFundAmount.div(devDistributeDuration);
        devFinishTime = block.timestamp.add(devDistributeDuration);

        lastUpdateTime = block.timestamp;
        lastDistributeTime = block.timestamp;
        halvingTime = block.timestamp.add(DURATION);

        haveStarted = true;
        emit Start(mintAmount);
    }

    function transferDevAddr(address newAddr) public onlyDev {
        require(newAddr != address(0), "zero addr");
        devAddr = newAddr;
    }

    function distributeDevFund() internal {
        uint256 nowTime = Math.min(block.timestamp, devFinishTime);
        uint256 fundAmount = nowTime.sub(lastDistributeTime).mul(devDistributeRate);
        doki.safeTransfer(devAddr, fundAmount);
        lastDistributeTime = nowTime;
    }

    modifier onlyDev() {
        require(msg.sender == devAddr, "This is only for dev.");
        _;
    }

    function lpTokenAddress() view public returns(address) {
        return address(lpToken);
    }

    function dokiAddress() view public returns(address) {
        return address(doki);
    }

    function testMint() public onlyOwner {
        doki.mint(address(this), 1);
    }
}