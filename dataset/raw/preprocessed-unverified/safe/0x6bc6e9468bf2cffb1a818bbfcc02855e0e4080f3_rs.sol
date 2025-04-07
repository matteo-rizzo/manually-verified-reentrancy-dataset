/**
 *Submitted for verification at Etherscan.io on 2020-10-31
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.7.0;

// _   _ _     __  ___ _  
//| |_| | |_/ / /\| |_) | Hikari.Finance - Yami Algorithm
//|_| |_|_| \/_/--\_| \_| Coded by nashec using Solidity 0.7.0

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
    constructor (string memory name_, string memory symbol_) {
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






contract Yami is ERC20 {

    using SafeERC20 for IERC20;
    using SafeMath for uint256;
    
    address private owner;
    address private HikariAddress;
    address private HikariAddressLP;
    
    IERC20 private HikariToken;
    IERC20 private HikariTokenLP;
    
    uint256 private varstakingRewards;
    uint256 private varstakingRewardsLP;
    uint256 private _totalHikariStaked;
    uint256 private _totalHikariStakedLP;
    uint256 private InitialSupply = 1000;
    uint256 private lockTime = 19500; //19500 - 72H
    uint256 private lockTimeLP = 19500; //19500 - 72H
    uint256 private deflationaryBlockTimestamp;
    uint256 private deflationaryBlocks = 39500;
    uint256 private deflationaryMultiplier = 2;

    mapping(address => Staking) private _stakedBalances;
    mapping(address => Staking) private _stakedBalancesLP;

    struct Staking{
        uint256 lastBlockChecked;
        uint256 lastBlockCheckedLP;
        uint256 rewards;
        uint256 rewardsLP;
        uint256 hikaristaked;
        uint256 hikaristakedLP;
        uint256 stakedAtBlock;
        uint256 stakedAtBlockLP;
    }
    
    constructor() payable ERC20("YAMI", "YAMI") {
        owner = msg.sender;
        _mint(msg.sender, InitialSupply.mul(10 ** 18));
        varstakingRewards = 100000; varstakingRewardsLP = 25000;
        deflationaryBlockTimestamp = block.number;
    }
    
    event Staked(address indexed user, uint256 amount, uint256 totalHikariStaked);
    event StakedLP(address indexed user, uint256 amountLP, uint256 totalHikariStakedLP);
    event Withdrawn(address indexed user, uint256 amount);
    event WithdrawnLP(address indexed user, uint256 amountLP);
    event Rewards(address indexed user, uint256 reward);
    event RewardsLP(address indexed user, uint256 rewardLP);
    
    modifier _onlyOwner() {require(msg.sender == owner);_;}

    modifier updateStakingReward(address account) {
        if(block.number > (deflationaryBlockTimestamp + deflationaryBlocks)){
            deflationaryBlockTimestamp = block.number;
            varstakingRewards = varstakingRewards * deflationaryMultiplier;
            varstakingRewardsLP = varstakingRewardsLP * deflationaryMultiplier;
        }
        if (block.number > _stakedBalances[account].lastBlockChecked) { uint256 rewardBlocks = block.number.sub(_stakedBalances[account].lastBlockChecked);
            if (_stakedBalances[account].hikaristaked > 0) { _stakedBalances[account].rewards = _stakedBalances[account].rewards.add(_stakedBalances[account].hikaristaked.mul(rewardBlocks)/varstakingRewards);}
            _stakedBalances[account].lastBlockChecked = block.number;
            emit Rewards(account, _stakedBalances[account].rewards);                                                     
        }_;
    }
    
    modifier updateStakingRewardLP(address account) {
        if (block.number > _stakedBalancesLP[account].lastBlockCheckedLP) { uint256 rewardBlocksLP = block.number.sub(_stakedBalancesLP[account].lastBlockCheckedLP);
            if (_stakedBalancesLP[account].hikaristakedLP > 0) { _stakedBalancesLP[account].rewardsLP = _stakedBalancesLP[account].rewardsLP.add(_stakedBalancesLP[account].hikaristakedLP.mul(rewardBlocksLP)/varstakingRewardsLP);}
            _stakedBalancesLP[account].lastBlockCheckedLP = block.number;
            emit RewardsLP(account, _stakedBalancesLP[account].rewardsLP);                                                     
        }_;
    }
    
    //Sets
    function setHikariAddress(address _hikariaddress) public _onlyOwner returns(uint256) {HikariAddress = _hikariaddress; HikariToken = IERC20(_hikariaddress);}
    function setHikariAddressLP(address _hikariaddressLP) public _onlyOwner returns(uint256) {HikariAddressLP = _hikariaddressLP; HikariTokenLP = IERC20(_hikariaddressLP);}
    function setRewardsVar(uint256 _amount) public _onlyOwner {varstakingRewards = _amount;}
    function setRewardsVarLP(uint256 _amount) public _onlyOwner {varstakingRewardsLP = _amount;}
    function setLockTime(uint256 _amount) public _onlyOwner {lockTime = _amount;}
    function setLockTimeLP(uint256 _amount) public _onlyOwner {lockTimeLP = _amount;}
    function setDeflationaryBlocks(uint256 _amount) public _onlyOwner {deflationaryBlocks = _amount;}
    function setDeflationaryMultiplier(uint256 _amount) public _onlyOwner {deflationaryMultiplier = _amount;}
    
    //Gets
    function getBlockNum() public view returns (uint256) {return block.number;}
    function getLastBlockCheckedNum(address _account) public view returns (uint256) {return _stakedBalances[_account].lastBlockChecked;}
    function getLastBlockCheckedNumLP(address _account) public view returns (uint256) {return _stakedBalancesLP[_account].lastBlockCheckedLP;}
    function getAddressStakeAmount(address _account) public view returns (uint256) {return _stakedBalances[_account].hikaristaked;}
    function getAddressStakeAmountLP(address _account) public view returns (uint256) {return _stakedBalancesLP[_account].hikaristakedLP;}
    function getStakedAtBlock(address _account) public view returns (uint256) {return _stakedBalances[_account].stakedAtBlock;}
    function getStakedAtBlockLP(address _account) public view returns (uint256) {return _stakedBalancesLP[_account].stakedAtBlockLP;}
    function getTotalStaked() public view returns (uint256) {return _totalHikariStaked;}
    function getTotalStakedLP() public view returns (uint256) {return _totalHikariStakedLP;}
    function getLockTime() public view returns (uint256) {return lockTime;}
    function getLockTimeLP() public view returns (uint256) {return lockTimeLP;}
    function getVarStakingReward() public view returns (uint256) {return varstakingRewards;}
    function getVarStakingRewardLP() public view returns (uint256) {return varstakingRewardsLP;}
    function getDeflationaryBlocks() public view returns (uint256) {return deflationaryBlocks;}
    function getDeflationaryCount() public view returns (uint256) {return deflationaryBlockTimestamp;}
    function getDeflationaryMultiplier() public view returns (uint256) {return deflationaryMultiplier;}

    function updatingStakingReward(address account) public returns(uint256) {
        if (block.number > _stakedBalances[account].lastBlockChecked) {uint256 rewardBlocks = block.number.sub(_stakedBalances[account].lastBlockChecked);
            if (_stakedBalances[account].hikaristaked > 0) {_stakedBalances[account].rewards = _stakedBalances[account].rewards.add(_stakedBalances[account].hikaristaked.mul(rewardBlocks)/ varstakingRewards);}
            _stakedBalances[account].lastBlockChecked = block.number;
            emit Rewards(account, _stakedBalances[account].rewards);} return(_stakedBalances[account].rewards);
    }
    
    function updatingStakingRewardLP(address account) public returns(uint256) {
        if (block.number > _stakedBalancesLP[account].lastBlockCheckedLP) {uint256 rewardBlocksLP = block.number.sub(_stakedBalancesLP[account].lastBlockCheckedLP);
            if (_stakedBalancesLP[account].hikaristakedLP > 0) {_stakedBalancesLP[account].rewardsLP = _stakedBalancesLP[account].rewardsLP.add(_stakedBalancesLP[account].hikaristakedLP.mul(rewardBlocksLP)/ varstakingRewardsLP);}
            _stakedBalancesLP[account].lastBlockCheckedLP = block.number;
            emit RewardsLP(account, _stakedBalancesLP[account].rewardsLP);} return(_stakedBalancesLP[account].rewardsLP);
    }

    function myRewardsBalance(address account) public view returns (uint256) {
        if (block.number > _stakedBalances[account].lastBlockChecked) {uint256 rewardBlocks = block.number.sub(_stakedBalances[account].lastBlockChecked);
            if (_stakedBalances[account].hikaristaked > 0) {return _stakedBalances[account].rewards.add(_stakedBalances[account].hikaristaked.mul(rewardBlocks)/ varstakingRewards);}}
    }
    
    function myRewardsBalanceLP(address account) public view returns (uint256) {
        if (block.number > _stakedBalancesLP[account].lastBlockCheckedLP) {uint256 rewardBlocksLP = block.number.sub(_stakedBalancesLP[account].lastBlockCheckedLP);
            if (_stakedBalancesLP[account].hikaristakedLP > 0) {return _stakedBalancesLP[account].rewardsLP.add(_stakedBalancesLP[account].hikaristakedLP.mul(rewardBlocksLP)/ varstakingRewardsLP);}}
    }
    
    function stake(uint256 amount) public updateStakingReward(msg.sender) {
        _totalHikariStaked = _totalHikariStaked.add(amount);
        _stakedBalances[msg.sender].hikaristaked = _stakedBalances[msg.sender].hikaristaked.add(amount);
        _stakedBalances[msg.sender].stakedAtBlock = block.number; 
        HikariToken.safeTransferFrom(msg.sender, address(this), amount);
        emit Staked(msg.sender, amount, _totalHikariStaked);
    }
    
    function stakeLP(uint256 amount) public updateStakingRewardLP(msg.sender) {
        _totalHikariStakedLP = _totalHikariStakedLP.add(amount);
        _stakedBalancesLP[msg.sender].hikaristakedLP = _stakedBalancesLP[msg.sender].hikaristakedLP.add(amount);
        _stakedBalancesLP[msg.sender].stakedAtBlockLP = block.number;
        HikariTokenLP.safeTransferFrom(msg.sender, address(this), amount);
        emit StakedLP(msg.sender, amount, _totalHikariStakedLP);
    }
    
    function withdraw(uint256 amount) public updateStakingReward(msg.sender) {
        require((block.number - _stakedBalances[msg.sender].stakedAtBlock) > lockTime, "Locktime not elapsed");
        _totalHikariStaked = _totalHikariStaked.sub(amount);
        _stakedBalances[msg.sender].hikaristaked = _stakedBalances[msg.sender].hikaristaked.sub(amount);
        HikariToken.safeTransfer(msg.sender, amount);
        emit Withdrawn(msg.sender, amount);
    }
    
    function withdrawLP(uint256 amount) public updateStakingRewardLP(msg.sender) {
        require((block.number - _stakedBalancesLP[msg.sender].stakedAtBlockLP) > lockTimeLP, "Locktime not elapsed");
        _totalHikariStakedLP = _totalHikariStakedLP.sub(amount);
        _stakedBalancesLP[msg.sender].hikaristakedLP = _stakedBalancesLP[msg.sender].hikaristakedLP.sub(amount);
        HikariTokenLP.safeTransfer(msg.sender, amount);
        emit WithdrawnLP(msg.sender, amount);
    }
    
    function getReward() public updateStakingReward(msg.sender) {
       uint256 reward = _stakedBalances[msg.sender].rewards;
       _stakedBalances[msg.sender].rewards = 0;
       _mint(msg.sender, reward.mul(8) / 10);
       uint256 fundingPoolReward = reward.mul(2) / 10;
       _mint(HikariAddress, fundingPoolReward);
       emit Rewards(msg.sender, reward);
   }
   
    function getRewardLP() public updateStakingRewardLP(msg.sender) {
       uint256 rewardLP = _stakedBalancesLP[msg.sender].rewardsLP;
       _stakedBalancesLP[msg.sender].rewardsLP = 0;
       _mint(msg.sender, rewardLP.mul(8) / 10);
       uint256 fundingPoolRewardLP = rewardLP.mul(2) / 10;
       _mint(HikariAddressLP, fundingPoolRewardLP);
       emit RewardsLP(msg.sender, rewardLP);
   }
   
   //end

}