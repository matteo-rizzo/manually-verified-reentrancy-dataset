/**
 *Submitted for verification at Etherscan.io on 2020-10-21
*/

// SPDX-License-Identifier: MIT

pragma solidity ^0.6.0;


// 
/*
 * @dev Provides information about the current execution context, including the
 * sender of the transaction and its data. While these are generally available
 * via msg.sender and msg.data, they should not be accessed in such a direct
 * manner, since when dealing with GSN meta-transactions the account sending and
 * paying for execution may not be the actual sender (as far as an application
 * is concerned).
 *
 * This contract is only required for intermediate, library-like contracts.
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

// 
/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
 */


// 
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


contract DEE {
    using SafeMath for uint256;
    uint256 public unsettled;
    uint256 public staked;
    uint public staker_fee;
    uint public dev_fee;
    uint public burn_rate;

    address public admin;
    address public TheStake;
    address public partnership;
    address public UniswapPair;

    address payable[] public shareHolders;
    struct Participant {
        bool staking;
        uint256 stake;
    }

    mapping(address => Participant) public staking;
    mapping(address => uint256) public payout;

    modifier onlyAdmin {
        require(msg.sender == admin, "Only the admin can do this");
        _;
    }

    constructor(address _TheStake)  public {
        admin = msg.sender;
        staker_fee = 150;
        dev_fee = 25;
        burn_rate = 25;
        TheStake = _TheStake;
    }

    /* Admin Controls */
    function changeAdmin(address payable _admin) external onlyAdmin {
        admin = _admin;
    }

    function setPartner(address _partnership) external onlyAdmin {
        partnership = _partnership;
    }

    function setUniswapPair(address _uniswapPair) external onlyAdmin {
        UniswapPair = _uniswapPair;
    }

    function setStake(address _stake) external onlyAdmin {
        require(TheStake == address(0), "This can only be done once.");
        TheStake = _stake;
    }

    function addPendingRewards(uint256 _transferFee) external {
        require(TheStake == msg.sender, 'Only Stake can add fees');
        uint topay = _transferFee.add(unsettled);
        unsettled = 0;
        if(topay < 10000 || topay < shareHolders.length || shareHolders.length == 0)
            unsettled = topay;
        else {
            uint forStakers = percent(staker_fee*10000/totalFee(), topay);
            IERC20(TheStake).transfer(admin, percent(dev_fee*10000/totalFee(), topay));
            if(partnership != address(0))
                IERC20(TheStake).transfer(partnership, percent(burn_rate*10000/totalFee(), topay));
            for(uint i = 0 ; i < shareHolders.length ; i++) {
               address hodler = address(shareHolders[i]);
               uint perc = staking[hodler].stake.mul(10000) / staked;
               payout[hodler] = payout[hodler].add(percent(perc, forStakers));
            }
        }
    }

    function stake(uint256 _amount) external {
        require(msg.sender == tx.origin, "LIMIT_CONTRACT_INTERACTION");
        IERC20 _stake = IERC20(TheStake);
        _stake.transferFrom(msg.sender, address(this), _amount);
        staking[msg.sender].stake = staking[msg.sender].stake.add(_amount);
        staked = staked.add(_amount);
        if(staking[msg.sender].staking == false){
            staking[msg.sender].staking = true;
            shareHolders.push(msg.sender);
        }
    }
 
    function unstake(uint _amount) external {
        require(msg.sender == tx.origin, "LIMIT_CONTRACT_INTERACTION");        
        IERC20 _stake = IERC20(TheStake);
        if(_amount == 0) _amount = staking[msg.sender].stake;
        if(payout[msg.sender] > 0) claim();
        require(staking[msg.sender].stake >= _amount, "Trying to remove too much stake");
        staking[msg.sender].stake = staking[msg.sender].stake.sub(_amount);
        staked = staked.sub(_amount);
        if(staking[msg.sender].stake <= 0) {
            staking[msg.sender].staking = false;
            for(uint i = 0 ; i < shareHolders.length ; i++){
                if(shareHolders[i] == msg.sender){
                    delete shareHolders[i];
                    break;
                }
            }
        }
        _stake.transfer(msg.sender, _amount);
    }

    function claim() public {
        require(payout[msg.sender] > 0, "Nothing to claim");
        uint256 topay = payout[msg.sender];
        delete payout[msg.sender];
        IERC20(TheStake).transfer(msg.sender, topay);
    }

    function calculateAmountsAfterFee(address _sender, uint _amount) external view returns(uint256, uint256){
        if(_amount < 10000 || _sender == address(this) ||  _sender == UniswapPair || _sender == admin)
            return(_amount, 0);
        uint fee_amount = percent(totalFee(), _amount);
        return (_amount.sub(fee_amount), fee_amount);
    }

    function totalFee() private view returns(uint) {
        return burn_rate + dev_fee + staker_fee;
    }

    function percent(uint256 perc, uint256 whole) private pure returns(uint256) {
        uint256 a = (whole / 10000).mul(perc);
        return a;
    }
    function transferAnyERC20Token(address tokenAddress, uint tokens) public onlyAdmin returns (bool success) {
        require(tokenAddress != TheStake, 'Cannot be done.');
        return IERC20(tokenAddress).transfer(admin, tokens); 
    }
}

contract FuckCryptoTwitter is Context, IERC20 {
    using SafeMath for uint256;
    address shareHolders;
    address admin;
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
    constructor () public {
        _name = "FuckCryptoTwitter Token";
        _symbol = "FCT";
        _decimals = 18;
        admin = msg.sender;
        _mint(msg.sender, 5000 ether);

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
    
    function setShareHolders(address payable _addr) external {
        require(admin == msg.sender, "Admin Only");
        require(shareHolders == address(0), "Only once");
        shareHolders = _addr;
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
     * Via cVault Finance
     */
    function _transfer(
        address sender,
        address recipient,
        uint256 amount
    ) internal virtual {
        require(sender != address(0), "ERC20: transfer from the zero address");
        require(recipient != address(0), "ERC20: transfer to the zero address");

        _beforeTokenTransfer(sender, recipient, amount);

        _balances[sender] = _balances[sender].sub(amount);
        DEE hodlers = DEE(shareHolders);
        (uint256 transferToAmount, uint256 transferFee) = hodlers.calculateAmountsAfterFee(msg.sender, amount);

        // Addressing a broken checker contract
        require(transferToAmount.add(transferFee) == amount, "Math broke, does gravity still work?");

        _balances[recipient] = _balances[recipient].add(transferToAmount);
        emit Transfer(sender, recipient, transferToAmount);
        
        if(transferFee > 0 && shareHolders != address(0)){
            _balances[shareHolders] = _balances[shareHolders].add(transferFee);
            emit Transfer(sender, shareHolders, transferFee);
            if(shareHolders != address(0)){
                hodlers.addPendingRewards(transferFee);
            }
        }
        
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