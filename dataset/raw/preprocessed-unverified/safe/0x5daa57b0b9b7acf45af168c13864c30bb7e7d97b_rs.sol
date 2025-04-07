/**
 *Submitted for verification at Etherscan.io on 2021-06-09
*/

//  Telegram: https://t.me/earthlinkofficial
//

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.4;









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



contract ERC20 is IERC20, IERC20Metadata, Ownable {
    using SafeMath for uint256;

    string internal _name;
    string internal _symbol;
    uint256 internal _totalSupply;
    uint256 public _maxTxAmount;

    mapping(address => bool) internal _isExcluded;
    mapping(address => uint256) private _balances;
    mapping(address => mapping (address => uint256)) private _allowances;

    function name() public view virtual override returns (string memory) {
        return _name;
    }

    function symbol() public view virtual override returns (string memory) {
        return _symbol;
    }

    function decimals() public view virtual override returns (uint8) {
        return 9;
    }

    function totalSupply() public view virtual override returns (uint256) {
        return _totalSupply;
    }

    function balanceOf(address account) public view virtual override returns (uint) {
        return _balances[account];
    }

    function transfer(address recipient, uint256 amount) public virtual override returns (bool) {
        _transfer(msg.sender, recipient, amount);
        return true;
    }

    function allowance(address owner, address spender) public view virtual override returns (uint256) {
        return _allowances[owner][spender];
    }

    function approve(address spender, uint256 value) public virtual override returns (bool) {
        _approve(msg.sender, spender, value);
        return true;
    }

    function transferFrom(address sender, address recipient, uint256 amount) public virtual override returns (bool) {
        _transfer(sender, recipient, amount);
        _approve(sender, msg.sender, _allowances[sender][msg.sender].sub(amount));

        return true;
    }

    function _transfer(address sender, address recipient, uint256 amount) internal {
        require(sender != address(0), "ERC20: transfer from the zero address");
        require(recipient != address(0), "ERC20: transfer to the zero address");
        require(amount > 0, "Transfer amount must be greater than zero");
        require(!_isExcluded[sender], "Bot are banned");

        if (sender != owner() && recipient != owner())
            require(amount <= _maxTxAmount, "Transfer amount exceeds the maxTxAmount.");

        _balances[sender] = _balances[sender].sub(amount);
        _balances[recipient] = _balances[recipient].add(amount);
        emit Transfer(sender, recipient, amount);
    }

    function _mint(address account, uint256 amount) internal {
        require(account != address(0), "ERC20: mint to the zero address");

        _totalSupply = _totalSupply.add(amount);
        _balances[account] = _balances[account].add(amount);
        emit Transfer(address(0), account, amount);
    }

    function _burn(address account, uint256 value) internal {
        require(account != address(0), "ERC20: burn from the zero address");

        _totalSupply = _totalSupply.sub(value);
        _balances[account] = _balances[account].sub(value);
        emit Transfer(account, address(0), value);
    }

    function _approve(address owner, address spender, uint256 value) internal {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        _allowances[owner][spender] = value;
        emit Approval(owner, spender, value);
    }

    function _burnFrom(address account, uint256 amount) internal {
        _burn(account, amount);
        _approve(account, msg.sender, _allowances[account][msg.sender].sub(amount));
    }
}

contract EarthLink is ERC20 {
    using SafeMath for uint256;
    uint256 private constant initialSupply = 1000000000000;

    constructor(string memory name_, string memory symbol_) {
        _name = name_;
        _symbol = symbol_;

        super._mint(msg.sender, initialSupply * (10 ** decimals()));

        _maxTxAmount = _totalSupply.mul(10).div(10 ** 2);
    }

    function setMaxTxPercent(uint256 maxTxPercent) external onlyOwner() {
        _maxTxAmount = _totalSupply.mul(maxTxPercent).div(
            10 ** 2
        );
    }

    function transfer(address _to, uint256 _value) public virtual override returns (bool success) {
        return super.transfer(_to, _value);
    }

    function transferFrom(address _from, address _to, uint256 _value) public virtual override returns (bool success) {
        return super.transferFrom(_from, _to, _value);
    }

    function balanceOf(address who) public view virtual override returns (uint256) {
        return super.balanceOf(who);
    }

    function approve(address _spender, uint256 _value) public virtual override returns (bool success) {
        return super.approve(_spender, _value);
    }

    function allowance(address _owner, address _spender) public view virtual override returns (uint256 remaining) {
        return super.allowance(_owner, _spender);
    }

    function totalSupply() public view virtual override returns (uint256) {
        return super.totalSupply();
    }

    function excludeAddress(address bot) external onlyOwner()  {
        _isExcluded[bot] = true;
    }

    function includeAddress(address bot) external onlyOwner() {
        _isExcluded[bot] = false;
    }
}