/**
 *Submitted for verification at Etherscan.io on 2020-03-10
*/

pragma solidity ^0.5.0;



contract Context {
    constructor () internal { }
    // solhint-disable-previous-line no-empty-blocks

    function _msgSender() internal view returns (address payable) {
        return msg.sender;
    }

    function _msgData() internal view returns (bytes memory) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}

contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
    constructor () internal {
        _owner = _msgSender();
        emit OwnershipTransferred(address(0), _owner);
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
    function renounceOwnership() public onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }
    function transferOwnership(address newOwner) public onlyOwner {
        _transferOwnership(newOwner);
    }
    function _transferOwnership(address newOwner) internal {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}

contract ERC20 is Context, IERC20 {
    using SafeMath for uint256;

    mapping (address => uint256) private _balances;

    mapping (address => mapping (address => uint256)) private _allowances;

    uint256 private _totalSupply;
    function totalSupply() public view returns (uint256) {
        return _totalSupply;
    }
    function balanceOf(address account) public view returns (uint256) {
        return _balances[account];
    }
    function transfer(address recipient, uint256 amount) public returns (bool) {
        _transfer(_msgSender(), recipient, amount);
        return true;
    }
    function allowance(address owner, address spender) public view returns (uint256) {
        return _allowances[owner][spender];
    }
    function approve(address spender, uint256 amount) public returns (bool) {
        _approve(_msgSender(), spender, amount);
        return true;
    }
    function transferFrom(address sender, address recipient, uint256 amount) public returns (bool) {
        _transfer(sender, recipient, amount);
        _approve(sender, _msgSender(), _allowances[sender][_msgSender()].sub(amount, "ERC20: transfer amount exceeds allowance"));
        return true;
    }
    function increaseAllowance(address spender, uint256 addedValue) public returns (bool) {
        _approve(_msgSender(), spender, _allowances[_msgSender()][spender].add(addedValue));
        return true;
    }
    function decreaseAllowance(address spender, uint256 subtractedValue) public returns (bool) {
        _approve(_msgSender(), spender, _allowances[_msgSender()][spender].sub(subtractedValue, "ERC20: decreased allowance below zero"));
        return true;
    }
    function _transfer(address sender, address recipient, uint256 amount) internal {
        require(sender != address(0), "ERC20: transfer from the zero address");
        require(recipient != address(0), "ERC20: transfer to the zero address");

        _balances[sender] = _balances[sender].sub(amount, "ERC20: transfer amount exceeds balance");
        _balances[recipient] = _balances[recipient].add(amount);
        emit Transfer(sender, recipient, amount);
    }
    function _mint(address account, uint256 amount) internal {
        require(account != address(0), "ERC20: mint to the zero address");

        _totalSupply = _totalSupply.add(amount);
        _balances[account] = _balances[account].add(amount);
        emit Transfer(address(0), account, amount);
    }
    function _burn(address account, uint256 amount) internal {
        require(account != address(0), "ERC20: burn from the zero address");

        _balances[account] = _balances[account].sub(amount, "ERC20: burn amount exceeds balance");
        _totalSupply = _totalSupply.sub(amount);
        emit Transfer(account, address(0), amount);
    }
    function _approve(address owner, address spender, uint256 amount) internal {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }
    function _burnFrom(address account, uint256 amount) internal {
        _burn(account, amount);
        _approve(account, _msgSender(), _allowances[account][_msgSender()].sub(amount, "ERC20: burn amount exceeds allowance"));
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
    uint256 private _guardCounter;

    constructor () internal {
        _guardCounter = 1;
    }

    modifier nonReentrant() {
        _guardCounter += 1;
        uint256 localCounter = _guardCounter;
        _;
        require(localCounter == _guardCounter, "ReentrancyGuard: reentrant call");
    }
}













contract SupplyFactory is ERC20, ERC20Detailed, ReentrancyGuard, Ownable {
  using SafeERC20 for IERC20;
  using Address for address;
  using SafeMath for uint256;

  uint256 public constant maxBorrowBase = uint256(100);
  address public constant yCURVE = address(0xdF5e0e81Dff6FAF3A7e52BA697820c5e32D806A8);
  address public constant ySWAP = address(0x45F783CCE6B7FF23B2ab2D70e416cdb7D6055f51);
  SynthERC20 public sEUR;

  uint256 public maxBorrow;
  address public borrower;

  modifier onlyBorrower() {
      require(borrower == msg.sender, "Supply: caller is not the borrower");
      _;
  }
  function transferBorrower(address newBorrower) public onlyOwner {
      _transferBorrower(newBorrower);
  }
  function _transferBorrower(address newBorrower) internal {
      require(newBorrower != address(0), "Supply: new borrower is the zero address");
      borrower = newBorrower;
  }

  constructor() public ERC20Detailed("Supply EUR", "Supply EUR", 18) {
    sEUR = SynthERC20(0x0485a423c0b8Ff2f5Aa2EC35a32D1c67a2e99B6c);
    maxBorrow = uint256(50);
  }

  function setSEUR(SynthERC20 _newSEUR) external onlyOwner {
    sEUR = _newSEUR;
  }
  function setMaxBorrow(uint256 _maxBorrow) external onlyOwner {
    maxBorrow = _maxBorrow;
  }

  function deposit(uint256 _amount) external nonReentrant {
      require(_amount > 0, "deposit must be greater than 0");
      uint256 pool = calcPoolValueInToken();

      IERC20(yCURVE).safeTransferFrom(msg.sender, address(this), _amount);

      // Calculate collateral pool shares
      uint256 shares = 0;
      if (pool == 0) {
        shares = _amount;
        pool = _amount;
      } else {
        shares = (_amount.mul(totalSupply())).div(pool);
      }
      _mint(msg.sender, shares);
  }

  function withdraw(uint256 _shares) external nonReentrant {
      require(_shares > 0, "withdraw must be greater than 0");

      uint256 ibalance = balanceOf(msg.sender);
      require(_shares <= ibalance, "insufficient balance");

      // Could have over value from cTokens
      uint256 pool = calcPoolValueInToken();
      // Calc to redeem before updating balances
      uint256 r = (pool.mul(_shares)).div(totalSupply());

      _burn(msg.sender, _shares);

      uint maxDebt = supply().mul(maxBorrow).div(maxBorrowBase);
      require(calcSystemDebt() < maxDebt, "supply: over max collateralization");

      IERC20(yCURVE).safeTransfer(msg.sender, r);
  }

  function supply() public view returns (uint256) {
      return IERC20(yCURVE).balanceOf(address(this))
        .mul(yCurveFi(ySWAP)
        .get_virtual_price()).div(1e18);
  }

  function borrow(uint256 _amount) external onlyBorrower {
      sEUR.mint(address(this), _amount);
      uint maxDebt = supply().mul(maxBorrow).div(maxBorrowBase);
      require(calcSystemDebt() < maxDebt, "supply: over max collateralization");
      IERC20(address(sEUR)).safeTransfer(msg.sender, _amount);
  }

  function calcSystemDebt() public view returns (uint256) {
    return sEUR.totalSupply().mul(sEUR.price()).div(1e8);
  }

  function repay(uint256 _amount) public onlyBorrower {
      sEUR.burn(msg.sender, _amount);
      uint maxDebt = supply().mul(maxBorrow).div(maxBorrowBase);
      require(calcSystemDebt() < maxDebt, "itrade: over max collateralization");
  }

  function calcPoolValueInToken() public view returns (uint) {
      return supply();
  }
  function getPricePerFullShare() public view returns (uint) {
      uint _pool = calcPoolValueInToken();
      return _pool.mul(1e18).div(totalSupply());
  }

  // incase of half-way error
  function inCaseTokenGetsStuck(IERC20 _TokenAddress) onlyOwner public {
      uint qty = _TokenAddress.balanceOf(address(this));
      _TokenAddress.safeTransfer(msg.sender, qty);
  }
  // incase of half-way error
  function inCaseTokenGetsStuckPartial(IERC20 _TokenAddress, uint256 _amount) onlyOwner public {
      _TokenAddress.safeTransfer(msg.sender, _amount);
  }
  // incase of half-way error
  function inCaseETHGetsStuck() onlyOwner public{
      (bool result, ) = msg.sender.call.value(address(this).balance)("");
      require(result, "transfer of ETH failed");
  }
}