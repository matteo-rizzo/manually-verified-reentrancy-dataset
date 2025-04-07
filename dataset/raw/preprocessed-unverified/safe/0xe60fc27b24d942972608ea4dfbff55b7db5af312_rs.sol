/**
 *Submitted for verification at Etherscan.io on 2020-07-02
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














contract iCollateralVault is ReentrancyGuard, Ownable {
    using SafeERC20 for IERC20;
    using Address for address;
    using SafeMath for uint256;
    
    address public constant aave = address(0x24a42fD28C976A61Df5D00D0599C34c4f90748c8);
    address public constant link = address(0xF79D6aFBb6dA890132F9D7c355e3015f15F3406F);
    
    event Approved(address indexed spender, uint256 value);
    event Borrowed(address indexed from, address indexed to, uint256 value);
    
    // Spending limits per user measured in dollars 1e8
    mapping (address => uint256) private _limits;
    
    constructor() public {
    
    }
    
    function limit(address spender) public view returns (uint256) {
        return _limits[spender];
    }
    
    function increaseLimit(address spender, uint256 addedValue) public onlyOwner returns (bool) {
        _approve(spender, _limits[spender].add(addedValue));
        return true;
    }
    
    function _approve(address spender, uint256 amount) internal {
        require(spender != address(0), "approve to the zero address");

        _limits[spender] = amount;
        emit Approved(spender, amount);
    }
    
    function decreaseLimit(address spender, uint256 subtractedValue) public onlyOwner returns (bool) {
        _approve(spender, _limits[spender].sub(subtractedValue, "decreased limit below zero"));
        return true;
    }
    
    // LP deposit, anyone can deposit/topup
    function deposit(address reserve, uint256 amount) external nonReentrant {
        IERC20(reserve).safeTransferFrom(msg.sender, address(this), amount);
    }
    
    // No logic, logic handled underneath by Aave
    function withdraw(address reserve, uint256 amount) external nonReentrant onlyOwner {
        IERC20(reserve).safeTransfer(msg.sender, amount);
    }
    
    function getAave() public view returns (address) {
        return LendingPoolAddressesProvider(aave).getLendingPool();
    }
    
    function getAaveCore() public view returns (address) {
        return LendingPoolAddressesProvider(aave).getLendingPoolCore();
    }
    
    function getAaveOracle() public view returns (address) {
        return LendingPoolAddressesProvider(aave).getPriceOracle();
    }
    
    function getReservePriceETH(address reserve) public view returns (uint256) {
        return Oracle(getAaveOracle()).getAssetPrice(reserve);
    }
    
    function getReservePriceUSD(address reserve) public view returns (uint256) {
        return getReservePriceETH(reserve).mul(Oracle(link).latestAnswer());
    }
    
    // amount needs to be normalized
    function borrow(address reserve, uint256 amount) public returns (bool) {
        uint256 _borrow = getReservePriceUSD(reserve).mul(amount);
        
        // LTV logic handled by underlying
        Aave(getAave()).borrow(reserve, amount, 2, 7);
        IERC20(reserve).safeTransfer(msg.sender, amount);
        emit Borrowed(owner(), msg.sender, amount);
        
        _approve(msg.sender, _limits[msg.sender].sub(_borrow, "borrow amount exceeds allowance"));
        return true;
    }
    
    function repay(address reserve, uint256 amount) public {
        IERC20(reserve).safeTransferFrom(msg.sender, address(this), amount);
        Aave(getAave()).repay(reserve, amount, address(uint160(address(this))));
    }
}

contract iCollateralVaultFactory {
    
    constructor() public {
    
    }
    
    function deployVault() external returns (address) {
        return address(new iCollateralVault());
    }
}