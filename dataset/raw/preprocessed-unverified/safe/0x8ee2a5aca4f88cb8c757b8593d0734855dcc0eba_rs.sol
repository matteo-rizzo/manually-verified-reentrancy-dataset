/**
 *Submitted for verification at Etherscan.io on 2020-08-05
*/

/**
 *Submitted for verification at Etherscan.io on 2020-08-04
*/

pragma solidity ^0.5.16;



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

















contract yDelegatedVault is ERC20, ERC20Detailed {
    using SafeERC20 for IERC20;
    using Address for address;
    using SafeMath for uint256;
    
    IERC20 public token;
    
    address public governance;
    address public controller;
    uint public insurance;
    uint public healthFactor = 4;
    
    address public constant aave = address(0x24a42fD28C976A61Df5D00D0599C34c4f90748c8);
    
    constructor (address _token, address _controller) public ERC20Detailed(
        string(abi.encodePacked("yearn ", ERC20Detailed(_token).name())),
        string(abi.encodePacked("y", ERC20Detailed(_token).symbol())),
        ERC20Detailed(_token).decimals()
    ) {
        token = IERC20(_token);
        governance = msg.sender;
        controller = _controller;
    }
    
    function debt() public view returns (uint) {
        address _reserve = Controller(controller).want(address(this));
        (,uint currentBorrowBalance,,,,,,,,) = Aave(getAave()).getUserReserveData(_reserve, address(this));
        return currentBorrowBalance;
    }
    
    function credit() public view returns (uint) {
        return Controller(controller).balanceOf(address(this));
    }
    
    // % of tokens locked and cannot be withdrawn per user
    // this is impermanent locked, unless the debt out accrues the strategy
    function locked() public view returns (uint) {
        return credit().mul(1e18).div(debt());
    }
    
    function debtShare(address _lp) public view returns (uint) {
        return debt().mul(balanceOf(_lp)).mul(totalSupply());
    }
    
    function getAave() public view returns (address) {
        return LendingPoolAddressesProvider(aave).getLendingPool();
    }
    
    function getAaveCore() public view returns (address) {
        return LendingPoolAddressesProvider(aave).getLendingPoolCore();
    }
    
    function setHealthFactor(uint _hf) external {
        require(msg.sender == governance, "!governance");
        healthFactor = _hf;
    }
    
    function activate() public {
        Aave(getAave()).setUserUseReserveAsCollateral(underlying(), true);
    }
    
    function repay(address reserve, uint amount) public  {
        // Required for certain stable coins (USDT for example)
        IERC20(reserve).approve(address(getAaveCore()), 0);
        IERC20(reserve).approve(address(getAaveCore()), amount);
        Aave(getAave()).repay(reserve, amount, address(uint160(address(this))));
    }
    
    function repayAll() public {
        address _reserve = reserve();
        uint _amount = IERC20(_reserve).balanceOf(address(this));
        repay(_reserve, _amount);
    }
    
    // Used to swap any borrowed reserve over the debt limit to liquidate to 'token'
    function harvest(address reserve, uint amount) external {
        require(msg.sender == controller, "!controller");
        require(reserve != address(token), "token");
        IERC20(reserve).safeTransfer(controller, amount);
    }
    
    // Ignore insurance fund for balance calculations
    function balance() public view returns (uint) {
        return token.balanceOf(address(this)).sub(insurance);
    }
    
    function setController(address _controller) external {
        require(msg.sender == governance, "!governance");
        controller = _controller;
    }
    
    function getAaveOracle() public view returns (address) {
        return LendingPoolAddressesProvider(aave).getPriceOracle();
    }
    
    function getReservePriceETH(address reserve) public view returns (uint) {
        return Oracle(getAaveOracle()).getAssetPrice(reserve);
    }
    
    function shouldRebalance() external view returns (bool) {
        return (over() > 0);
    }
    
    function over() public view returns (uint) {
        over(0);
    }
    
    function over(uint _amount) public view returns (uint) {
        address _reserve = reserve();
        uint _eth = _amount.mul(getUnderlyingPrice()); // Calculate the amount we are withdrawing in ETH
        (uint _maxSafeETH,uint _totalBorrowsETH,) = maxSafeETH();
        _maxSafeETH = _maxSafeETH.mul(105).div(100); // 5% buffer so we don't go into a earn/rebalance loop
        _maxSafeETH = _maxSafeETH.add(_eth); // Add the ETH we are withdrawing
        if (_maxSafeETH < _totalBorrowsETH) {
            uint _over = _totalBorrowsETH.mul(_totalBorrowsETH.sub(_maxSafeETH)).div(_totalBorrowsETH);
            _over = _over.mul(ERC20Detailed(_reserve).decimals()).div(getReservePrice());
            return _over;
        } else {
            return 0;
        }
    }
    
    function _rebalance(uint _amount) internal {
        uint _over = over(_amount);
        if (_over > 0) {
            Controller(controller).withdraw(address(this), _over);
            repayAll();
        }
    }
    
    function rebalance() external {
        _rebalance(0);
    }
    
    function claimInsurance() external {
        require(msg.sender == controller, "!controller");
        token.safeTransfer(controller, insurance);
        insurance = 0;
    }
    
    function maxSafeETH() public view returns (uint maxBorrowsETH, uint totalBorrowsETH, uint availableBorrowsETH) {
         (,,uint _totalBorrowsETH,,uint _availableBorrowsETH,,,) = Aave(getAave()).getUserAccountData(address(this));
        uint _maxBorrowETH = (_totalBorrowsETH.add(_availableBorrowsETH));
        return (_maxBorrowETH.div(healthFactor), _totalBorrowsETH, _availableBorrowsETH);
    }
    
    function shouldBorrow() external view returns (bool) {
        return (availableToBorrowReserve() > 0);
    }
    
    function availableToBorrowETH() public view returns (uint) {
        (uint _maxSafeETH,uint _totalBorrowsETH, uint _availableBorrowsETH) = maxSafeETH();
        _maxSafeETH = _maxSafeETH.mul(95).div(100); // 5% buffer so we don't go into a earn/rebalance loop
        if (_maxSafeETH > _totalBorrowsETH) {
            return _availableBorrowsETH.mul(_maxSafeETH.sub(_totalBorrowsETH)).div(_availableBorrowsETH);
        } else {
            return 0;
        }
    }
    
    function availableToBorrowReserve() public view returns (uint) {
        address _reserve = reserve();
        uint _available = availableToBorrowETH();
        if (_available > 0) {
            return _available.mul(uint(10)**ERC20Detailed(_reserve).decimals()).div(getReservePrice());
        } else {
            return 0;
        }
    }
    
    function getReservePrice() public view returns (uint) {
        return getReservePriceETH(reserve());
    }
    
    function getUnderlyingPrice() public view returns (uint) {
        return getReservePriceETH(underlying());
    }
    
    function earn() external {
        address _reserve = reserve();
        uint _borrow = availableToBorrowReserve();
        if (_borrow > 0) {
            Aave(getAave()).borrow(_reserve, _borrow, 2, 7);
        }
        //rebalance here
        uint _balance = IERC20(_reserve).balanceOf(address(this));
        if (_balance > 0) {
            IERC20(_reserve).safeTransfer(controller, _balance);
            Controller(controller).earn(address(this), _balance);
        }
    }
    
    function depositAll() external {
        deposit(token.balanceOf(msg.sender));
    }
    
    function deposit(uint _amount) public {
        uint _pool = balance();
        token.safeTransferFrom(msg.sender, address(this), _amount);
        
        // 0.5% of deposits go into an insurance fund incase of negative profits to protect withdrawals
        // At a 4 health factor, this is a -2% position
        uint _insurance = _amount.mul(50).div(10000);
        _amount = _amount.sub(_insurance);
        insurance = insurance.add(_insurance);
        
        
        //Controller can claim insurance to liquidate to cover interest
        
        uint shares = 0;
        if (_pool == 0) {
            shares = _amount;
            activate();
        } else {
            shares = (_amount.mul(totalSupply())).div(_pool);
        }
        _mint(msg.sender, shares);
    }
    
    function reserve() public view returns (address) {
        return Controller(controller).want(address(this));
    }
    
    function underlying() public view returns (address) {
        return AaveToken(address(token)).underlyingAssetAddress();
    }
    
    function withdrawAll() public {
        withdraw(balanceOf(msg.sender));
    }
    
    // Calculates in impermanent lock due to debt
    function maxWithdrawal(address account) public view returns (uint) {
        uint _balance = balanceOf(account);
        uint _safeWithdraw = _balance.mul(locked()).div(1e18);
        if (_safeWithdraw > _balance) {
            return _balance;
        } else {
            return _safeWithdraw;
        }
    }
    
    function safeWithdraw() external {
        withdraw(maxWithdrawal(msg.sender));
    }
    
    // No rebalance implementation for lower fees and faster swaps
    function withdraw(uint _shares) public {
        uint r = (balance().mul(_shares)).div(totalSupply());
        _burn(msg.sender, _shares);
        _rebalance(r);
        token.safeTransfer(msg.sender, r);
        
    }
    
    function getPricePerFullShare() external view returns (uint) {
        return balance().mul(1e18).div(totalSupply());
    }
}