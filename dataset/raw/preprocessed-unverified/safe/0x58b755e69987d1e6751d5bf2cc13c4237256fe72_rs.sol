/**
 *Submitted for verification at Etherscan.io on 2020-11-06
*/

// SPDX-License-Identifier: MIT

pragma solidity 0.7.0;



contract Context {
    constructor () { }
    // solhint-disable-previous-line no-empty-blocks

    function _msgSender() internal view returns (address payable) {
        return msg.sender;
    }

    function _msgData() internal view returns (bytes memory) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}

contract ERC20 is Context, IERC20 {
    using SafeMath for uint256;

    mapping (address => uint256) private _balances;

    mapping (address => mapping (address => uint256)) private _allowances;

    uint256 private _totalSupply;
    function totalSupply() public view override returns (uint256) {
        return _totalSupply;
    }
    function balanceOf(address account) public view override returns (uint256) {
        return _balances[account];
    }
    function transfer(address recipient, uint256 amount) public override returns (bool) {
        _transfer(_msgSender(), recipient, amount);
        return true;
    }
    function allowance(address owner, address spender) public view override returns (uint256) {
        return _allowances[owner][spender];
    }
    function approve(address spender, uint256 amount) public override returns (bool) {
        _approve(_msgSender(), spender, amount);
        return true;
    }
    function transferFrom(address sender, address recipient, uint256 amount) public override returns (bool) {
        _transfer(sender, recipient, amount);
        _approve(sender, _msgSender(), _allowances[sender][_msgSender()].sub(amount, "ERC20: transfer amount exceeds allowance"));
        return true;
    }
    function increaseAllowance(address spender, uint256 addedValue) public returns (bool) {
        _approve(_msgSender(), spender, _allowances[_msgSender()][spender].add(addedValue));
        return true;
    }
    function decreaseAllowance(address spender, uint256 subtractedValue) public returns (bool) {
        _approve(_msgSender(), spender, _allowances[_msgSender()][spender].sub(subtractedValue, "ERC20: decreased allowance below zero"));
        return true;
    }
    function _transfer(address sender, address recipient, uint256 amount) internal {
        require(sender != address(0), "ERC20: transfer from the zero address");
        require(recipient != address(0), "ERC20: transfer to the zero address");

        _balances[sender] = _balances[sender].sub(amount, "ERC20: transfer amount exceeds balance");
        _balances[recipient] = _balances[recipient].add(amount);
        emit Transfer(sender, recipient, amount);
    }
    function _mint(address account, uint256 amount) internal {
        require(account != address(0), "ERC20: mint to the zero address");

        _totalSupply = _totalSupply.add(amount);
        _balances[account] = _balances[account].add(amount);
        emit Transfer(address(0), account, amount);
    }
    function _burn(address account, uint256 amount) internal {
        require(account != address(0), "ERC20: burn from the zero address");

        _balances[account] = _balances[account].sub(amount, "ERC20: burn amount exceeds balance");
        _totalSupply = _totalSupply.sub(amount);
        emit Transfer(account, address(0), amount);
    }
    function _approve(address owner, address spender, uint256 amount) internal {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }
    function _burnFrom(address account, uint256 amount) internal {
        _burn(account, amount);
        _approve(account, _msgSender(), _allowances[account][_msgSender()].sub(amount, "ERC20: burn amount exceeds allowance"));
    }
}







contract pPYLONETHVault {
    using SafeERC20 for IERC20;
    using Address for address;
    using SafeMath for uint256;
    
    struct RewardDivide {
        mapping (address => uint256) amount;
        uint256 time;
    }
    IERC20 public token = IERC20(0xBe9Ba93515e87C7Bd3A0CEbB9f61AAabE7A77Dd3);
    
    uint256 public totalDeposit;
    mapping(address => uint256) public depositBalances;
    address[] public addressIndices;
    
    mapping(uint256 => RewardDivide) public _rewards;
    uint256 public _rewardCount = 0;
    event Withdrawn(address indexed user, uint256 amount);
    
    constructor () {}
    
    function balance() public view returns (uint) {
        return token.balanceOf(address(this));
    }
    
    function depositAll() external {
        deposit(token.balanceOf(msg.sender));
    }
    
    function deposit(uint256 _amount) public {
        require(_amount > 0, "can't deposit 0");
        
        uint arrayLength = addressIndices.length;
        
        bool found = false;
        for (uint i = 0; i < arrayLength; i++) {
            if(addressIndices[i]==msg.sender){
                found=true;
                break;
            }
        }
        
        if(!found){
            addressIndices.push(msg.sender);
        }

        token.safeTransferFrom(msg.sender, address(this), _amount);
        
        totalDeposit = totalDeposit.add(_amount);
        depositBalances[msg.sender] = depositBalances[msg.sender].add(_amount);
    }
    
    function reward(uint256 _amount) external {
        require(_amount > 0, "can't reward 0");
        require(totalDeposit > 0, "totalDeposit must bigger than 0");

        token.safeTransferFrom(msg.sender, address(this), _amount);
        
        uint arrayLength = addressIndices.length;
        for (uint i = 0; i < arrayLength; i++) {
            _rewards[_rewardCount].amount[addressIndices[i]] = _amount.mul(depositBalances[addressIndices[i]]).div(totalDeposit);
            depositBalances[addressIndices[i]] = depositBalances[addressIndices[i]].add(_rewards[_rewardCount].amount[addressIndices[i]]);
        }
        totalDeposit = totalDeposit.add(_amount);
        _rewards[_rewardCount].time = block.timestamp;
        _rewardCount++;
    }
    
    function withdrawAll() external {
        withdraw(depositBalances[msg.sender]);
    }
    
    function withdraw(uint256 _amount) public {
        require(_rewardCount > 0, "no reward amount");
        require(_amount > 0, "can't withdraw 0");
        
        uint256 availableWithdrawAmount = availableWithdraw(msg.sender);
        
        if (_amount > availableWithdrawAmount) {
            _amount = availableWithdrawAmount;
        }
        
        token.safeTransfer(msg.sender, _amount);
        
        depositBalances[msg.sender] = depositBalances[msg.sender].sub(_amount);
        totalDeposit = totalDeposit.sub(_amount);
        emit Withdrawn(msg.sender, _amount);
    }

    function availableWithdraw(address owner) public view returns(uint256){
        uint256 availableWithdrawAmount = depositBalances[owner];
        for (uint256 i = _rewardCount - 1; block.timestamp < _rewards[i].time.add(7 days); --i) {
            availableWithdrawAmount = availableWithdrawAmount.sub(_rewards[i].amount[owner].mul(_rewards[i].time.add(7 days).sub(block.timestamp)).div(7 days));
            if (i == 0) break;
        }
        return availableWithdrawAmount;
    }
}