/**
 *Submitted for verification at Etherscan.io on 2020-07-13
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
    
    address public constant link = address(0x5f0711c689Ed216f97D91126C112Ad585d1a7aba);
    address public constant unirouter = address(0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D  );
    mapping (address => address) public tokens;

    constructor () public ERC20Detailed("Fantom AMM USD", "fUSD", 8) {}

    function deposit(address token, uint amount) external nonReentrant {
        IERC20(token).safeTransferFrom(msg.sender, address(this), amount);
        uint value = Oracle(link).getPriceUSD(token).mul(amount).div(1**ERC20Detailed(token).decimals());
        require(value > 0, "!value");
        _mint(address(this), value); // Amount of fUSD to mint

        IERC20(token).safeApprove(unirouter, 0);
        IERC20(token).safeApprove(unirouter, amount);

        IERC20(address(this)).safeApprove(unirouter, 0);
        IERC20(address(this)).safeApprove(unirouter, value);
        
        (,,uint liquidity) = UniswapRouter(unirouter).addLiquidity(
            token,
            address(this),
            amount,
            value,
            0,
            0,
            address(this),
            now.add(1800)
        );

        address pair = IUniswapV2Factory(UniswapRouter(unirouter).factory()).getPair(token, address(this));
        require(pair != address(0), "!pair");
        if (tokens[pair] == address(0)) {
          tokens[pair] = address(new SupplyToken(
            string(abi.encodePacked(ERC20Detailed(token).symbol(), " ", ERC20Detailed(pair).name())),
            string(abi.encodePacked(ERC20Detailed(token).symbol(), ERC20Detailed(pair).symbol())),
            ERC20Detailed(pair).decimals()
          ));
        }
        
        SupplyToken(tokens[pair]).mint(msg.sender, liquidity);
    }

    function withdraw(address token, uint amount) external nonReentrant {
        
        address pair = IUniswapV2Factory(UniswapRouter(unirouter).factory()).getPair(token, address(this));
        SupplyToken(tokens[pair]).burn(msg.sender, amount);
        
        IERC20(pair).safeApprove(unirouter, 0);
        IERC20(pair).safeApprove(unirouter, amount);
        
        (uint amountA, uint amountB) = UniswapRouter(unirouter).removeLiquidity(
          token,
          address(this),
          amount,
          0,
          0,
          address(this),
          now.add(1800)
        );
        
        uint valueA = Oracle(link).getPriceUSD(token).mul(amountA).div(1**ERC20Detailed(token).decimals());
        if (valueA > amountB) {
            valueA = amountB;
        }
        _burn(address(this), valueA); // Amount of fUSD to burn (value of A leaving the system)
        IERC20(token).safeTransfer(msg.sender, amountA);
        if (amountB > valueA) {
            IERC20(address(this)).transfer(msg.sender, amountB.sub(valueA));
        }
    }
}