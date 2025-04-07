/**
 *Submitted for verification at Etherscan.io on 2020-07-12
*/

pragma solidity ^0.5.0;



contract Context {
    constructor () internal { }
    // solhint-disable-previous-line no-empty-blocks

    function _msgSender() internal view returns (address payable) {
        return msg.sender;
    }
}

contract Ownable is Context {
    address private _owner;
    constructor () internal {
        _owner = _msgSender();
    }
    function owner() public view returns (address) {
        return _owner;
    }
    modifier onlyOwner() {
        require(isOwner(), "Ownable: caller is not the owner");
        _;
    }
    function isOwner() public view returns (bool) {
        return _msgSender() == _owner;
    }
}

contract ERC20 is Context, IERC20 {
    using SafeMath for uint;

    mapping (address => uint) private _balances;

    mapping (address => mapping (address => uint)) private _allowances;

    uint private _totalSupply;
    function totalSupply() public view returns (uint) {
        return _totalSupply;
    }
    function balanceOf(address account) public view returns (uint) {
        return _balances[account];
    }
    function transfer(address recipient, uint amount) public returns (bool) {
        _transfer(_msgSender(), recipient, amount);
        return true;
    }
    function allowance(address owner, address spender) public view returns (uint) {
        return _allowances[owner][spender];
    }
    function approve(address spender, uint amount) public returns (bool) {
        _approve(_msgSender(), spender, amount);
        return true;
    }
    function transferFrom(address sender, address recipient, uint amount) public returns (bool) {
        _transfer(sender, recipient, amount);
        _approve(sender, _msgSender(), _allowances[sender][_msgSender()].sub(amount, "ERC20: transfer amount exceeds allowance"));
        return true;
    }
    function increaseAllowance(address spender, uint addedValue) public returns (bool) {
        _approve(_msgSender(), spender, _allowances[_msgSender()][spender].add(addedValue));
        return true;
    }
    function decreaseAllowance(address spender, uint subtractedValue) public returns (bool) {
        _approve(_msgSender(), spender, _allowances[_msgSender()][spender].sub(subtractedValue, "ERC20: decreased allowance below zero"));
        return true;
    }
    function _transfer(address sender, address recipient, uint amount) internal {
        require(sender != address(0), "ERC20: transfer from the zero address");
        require(recipient != address(0), "ERC20: transfer to the zero address");

        _balances[sender] = _balances[sender].sub(amount, "ERC20: transfer amount exceeds balance");
        _balances[recipient] = _balances[recipient].add(amount);
        emit Transfer(sender, recipient, amount);
    }
    function _mint(address account, uint amount) internal {
        require(account != address(0), "ERC20: mint to the zero address");

        _totalSupply = _totalSupply.add(amount);
        _balances[account] = _balances[account].add(amount);
        emit Transfer(address(0), account, amount);
    }
    function _burn(address account, uint amount) internal {
        require(account != address(0), "ERC20: burn from the zero address");

        _balances[account] = _balances[account].sub(amount, "ERC20: burn amount exceeds balance");
        _totalSupply = _totalSupply.sub(amount);
        emit Transfer(account, address(0), amount);
    }
    function _approve(address owner, address spender, uint amount) internal {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }
}

contract ERC20Detailed is IERC20 {
    string private _name;
    string private _symbol;
    uint8 private _decimals;

    constructor (string memory name, string memory symbol, uint8 decimals) public {
        _name = name;
        _symbol = symbol;
        _decimals = decimals;
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
}

contract ReentrancyGuard {
    uint private _guardCounter;

    constructor () internal {
        _guardCounter = 1;
    }

    modifier nonReentrant() {
        _guardCounter += 1;
        uint localCounter = _guardCounter;
        _;
        require(localCounter == _guardCounter, "ReentrancyGuard: reentrant call");
    }
}
















contract SupplyToken is ERC20, ERC20Detailed, Ownable {
  using SafeERC20 for IERC20;
  using Address for address;
  using SafeMath for uint;

  constructor (
      string memory name,
      string memory symbol,
      uint8 decimals
  ) public ERC20Detailed(name, symbol, decimals) {}

  function mint(address account, uint amount) public onlyOwner {
      _mint(account, amount);
  }
  function burn(address account, uint amount) public onlyOwner {
      _burn(account, amount);
  }
}

contract StableAMM is ERC20, ERC20Detailed, ReentrancyGuard {
    using SafeERC20 for IERC20;
    using Address for address;
    using SafeMath for uint;

    address public constant aave = address(0x24a42fD28C976A61Df5D00D0599C34c4f90748c8);
    address public constant link = address(0xF79D6aFBb6dA890132F9D7c355e3015f15F3406F);
    address public constant unirouter = address(0x4281cd0885767E84d289cF05239c64Ae6E81E569);
    mapping (address => address) public tokens;

    constructor () public ERC20Detailed("Aave AMM USD", "aUSD", 18) {}

    function getAaveOracle() public view returns (address) {
        return LendingPoolAddressesProvider(aave).getPriceOracle();
    }

    function getReservePriceETH(address reserve) public view returns (uint) {
        return Oracle(getAaveOracle()).getAssetPrice(reserve);
    }

    function getReservePriceUSD(address reserve) public view returns (uint) {
        return getReservePriceETH(reserve).mul(Oracle(link).latestAnswer());
    }
    
    function grow(address aaveToken, uint amount) public returns (uint) {
        uint liquidity = 0;
        if (amount > 0) {
            address reserve = AaveToken(aaveToken).underlyingAssetAddress();
            // 26 decimals, 18 for ETH 8 for USD
            uint value = getReservePriceUSD(reserve).mul(amount).div(1e26);
            _mint(address(this), value); // Amount of aUSD to mint
    
            IERC20(aaveToken).safeApprove(unirouter, 0);
            IERC20(aaveToken).safeApprove(unirouter, amount);
    
            IERC20(address(this)).safeApprove(unirouter, 0);
            IERC20(address(this)).safeApprove(unirouter, value);
            
            (,,liquidity) = UniswapRouter(unirouter).addLiquidity(
                aaveToken,
                address(this),
                amount,
                value,
                0,
                0,
                address(this),
                now.add(1800)
            );
    
            address pair = IUniswapV2Factory(UniswapRouter(unirouter).factory()).getPair(aaveToken, address(this));
            require(pair != address(0), "!pair");
            if (tokens[pair] == address(0)) {
              tokens[pair] = address(new SupplyToken(
                string(abi.encodePacked(ERC20Detailed(aaveToken).symbol(), " ", ERC20Detailed(pair).name())),
                string(abi.encodePacked(ERC20Detailed(aaveToken).symbol(), ERC20Detailed(pair).symbol())),
                ERC20Detailed(pair).decimals()
              ));
            }
        }
        return liquidity;
    }

    function deposit(address aaveToken, uint amount) external nonReentrant {
        
        grow(aaveToken, IERC20(aaveToken).balanceOf(address(this)));
        
        IERC20(aaveToken).safeTransferFrom(msg.sender, address(this), amount);
        
        address pair = IUniswapV2Factory(UniswapRouter(unirouter).factory()).getPair(aaveToken, address(this));
        uint balance = 0;
        if (pair != address(0)) {
            balance = IERC20(pair).balanceOf(address(this));
        }
        
        uint liquidity = grow(aaveToken, amount);
        
        uint shares = liquidity.mul(IERC20(tokens[pair]).totalSupply()).div(balance);
        SupplyToken(tokens[pair]).mint(msg.sender, shares);
    }

    function withdraw(address aaveToken, uint amount) external nonReentrant {
        grow(aaveToken, IERC20(aaveToken).balanceOf(address(this)));
        
        address pair = IUniswapV2Factory(UniswapRouter(unirouter).factory()).getPair(aaveToken, address(this));
        
        uint balance = 0;
        if (pair != address(0)) {
            balance = IERC20(pair).balanceOf(address(this));
        }
        
        uint r = balance.mul(amount).div(IERC20(tokens[pair]).totalSupply());
        SupplyToken(tokens[pair]).burn(msg.sender, amount);
        
        IERC20(pair).safeApprove(unirouter, 0);
        IERC20(pair).safeApprove(unirouter, r);
        
        (uint amountA, uint amountB) = UniswapRouter(unirouter).removeLiquidity(
          aaveToken,
          address(this),
          amount,
          0,
          0,
          address(this),
          now.add(1800)
        );
        address reserve = AaveToken(aaveToken).underlyingAssetAddress();
        uint valueA = getReservePriceUSD(reserve).mul(amountA).div(1e26);
        if (valueA > amountB) {
            valueA = amountB;
        }
        _burn(address(this), valueA); // Amount of aUSD to burn (value of A leaving the system)
        IERC20(aaveToken).safeTransfer(msg.sender, amountA);
        if (amountB > valueA) {
            IERC20(address(this)).transfer(msg.sender, amountB.sub(valueA));
        }
    }
}