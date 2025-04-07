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

    IERC20 public yUSD = IERC20(0x5dbcF33D8c2E976c6b560249878e6F1491Bca25c);
    yCurve public yCRV = yCurve(0x45F783CCE6B7FF23B2ab2D70e416cdb7D6055f51);

    uint256 public num = 1000000000000000000;
    uint256 private _totalSupply;

    function scalingFactor() public view returns (uint256) {
        uint256 virtualPrice = yCRV.get_virtual_price();
        uint256 pricePerFullShare = yUSD.getPricePerFullShare();
        return virtualPrice.mul(pricePerFullShare).div(num);
    }
    function totalSupply() public view returns (uint256) {
        return _totalSupply.mul(scalingFactor()).div(num);
    }
    function totalSupplyUnderlying() public view returns (uint256) {
        return _totalSupply;
    }
    function balanceOf(address account) public view returns (uint256) {
        return _balances[account].mul(scalingFactor()).div(num);
    }
    function balanceOfUnderlying(address account) public view returns (uint256) {
        return _balances[account];
    }
    function transfer(address recipient, uint256 amount) public returns (bool) {
        uint256 amountUnderlying = amount.mul(num).div(scalingFactor());
        _transfer(_msgSender(), recipient, amountUnderlying);
        return true;
    }
    function allowance(address owner, address spender) public view returns (uint256) {
        if (_allowances[owner][spender] == uint(-1)){
            return _allowances[owner][spender];
        }
        return _allowances[owner][spender].mul(scalingFactor()).div(num);
    }
    function allowanceUnderlying(address owner, address spender) public view returns (uint256) {
        return _allowances[owner][spender];
    }
    function approve(address spender, uint256 amount) public returns (bool) {
        uint256 amountUnderlying = amount;
        if (amount != uint(-1)){
            amountUnderlying = amount.mul(num).div(scalingFactor());
        }
        _approve(_msgSender(), spender, amountUnderlying);
        return true;
    }
    function transferFrom(address sender, address recipient, uint256 amount) public returns (bool) {
        uint256 amountUnderlying = amount.mul(num).div(scalingFactor());
        _transfer(sender, recipient, amountUnderlying);
        if (_allowances[sender][_msgSender()] != uint(-1)) {
            _approve(sender, _msgSender(), _allowances[sender][_msgSender()].sub(amountUnderlying, "ERC20: transfer amount exceeds allowance"));
        }
        return true;
    }
    function increaseAllowance(address spender, uint256 addedValue) public returns (bool) {
        require(_allowances[_msgSender()][spender] != uint(-1), "ERC20: allowance at max");
        uint256 addedValueUnderlying = addedValue.mul(num).div(scalingFactor());
        _approve(_msgSender(), spender, _allowances[_msgSender()][spender].add(addedValueUnderlying));
        return true;
    }
    function decreaseAllowance(address spender, uint256 subtractedValue) public returns (bool) {
        uint256 subtractedValueUnderlying = subtractedValue.mul(num).div(scalingFactor());
        _approve(_msgSender(), spender, _allowances[_msgSender()][spender].sub(subtractedValueUnderlying, "ERC20: decreased allowance below zero"));
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
        if (_allowances[account][_msgSender()] != uint(-1)) {
            _approve(account, _msgSender(), _allowances[account][_msgSender()].sub(amount, "ERC20: burn amount exceeds allowance"));
        }
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





 

contract syUSD is ERC20, ERC20Detailed {
    using SafeERC20 for IERC20;
    using Address for address;
    using SafeMath for uint256;

    constructor () public ERC20Detailed("Stable yUSD", "syUSD", 18) {}

    function mint(uint256 amount) public {
        yUSD.safeTransferFrom(msg.sender, address(this), amount);
        _mint(msg.sender, amount);
    }

    function burn(uint256 amount) public {
        _burn(msg.sender, amount);
        yUSD.safeTransfer(msg.sender, amount);
    }

    function getPricePerFullShare() public view returns (uint256) {
        return scalingFactor();
    }
}