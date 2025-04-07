/**
 *Submitted for verification at Etherscan.io on 2020-07-02
*/

// SPDX-License-Identifier: MIT

pragma solidity ^0.6.10;



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














contract iCollateralVault is ReentrancyGuard {
    using SafeERC20 for IERC20;
    
    address public constant aave = address(0x24a42fD28C976A61Df5D00D0599C34c4f90748c8);
    
    address private _owner;

    function owner() public view returns (address) {
        return _owner;
    }
    modifier onlyOwner() {
        require(isOwner(), "caller is not the owner");
        _;
    }
    function isOwner() public view returns (bool) {
        return msg.sender == _owner;
    }
    
    constructor() public {
        _owner = msg.sender;
    }
    
    // LP deposit, anyone can deposit/topup
    function activate(address reserve) external {
        Aave(getAave()).setUserUseReserveAsCollateral(reserve, true);
    }
    
    // No logic, logic handled underneath by Aave
    function withdraw(address reserve, uint256 amount, address to) external onlyOwner {
        IERC20(reserve).safeTransfer(to, amount);
    }
    
    function getAave() public view returns (address) {
        return LendingPoolAddressesProvider(aave).getLendingPool();
    }
    
    function getAaveCore() public view returns (address) {
        return LendingPoolAddressesProvider(aave).getLendingPoolCore();
    }
    
    // amount needs to be normalized
    function borrow(address reserve, uint256 amount, address to) external nonReentrant onlyOwner {
        // LTV logic handled by underlying
        Aave(getAave()).borrow(reserve, amount, 2, 7);
        IERC20(reserve).safeTransfer(to, amount);
    }
    
    function repay(address reserve, uint256 amount) public {
        // Required for certain stable coins (USDT for example)
        IERC20(reserve).approve(address(getAaveCore()), 0);
        IERC20(reserve).approve(address(getAaveCore()), amount);
        Aave(getAave()).repay(reserve, amount, address(uint160(address(this))));
    }
}

contract iCollateralVaultProxy {
    using SafeERC20 for IERC20;
    using Address for address;
    using SafeMath for uint256;
    
    mapping (address => address[]) private _ownedVaults;
    mapping (address => address) private _vaults;
    // Spending limits per user measured in dollars 1e8
    mapping (address => mapping (address => uint256)) private _limits;
    
    address public constant aave = address(0x24a42fD28C976A61Df5D00D0599C34c4f90748c8);
    address public constant link = address(0xF79D6aFBb6dA890132F9D7c355e3015f15F3406F);
    
    constructor() public {
        
    }
    
    function limit(address vault, address spender) public view returns (uint256) {
        return _limits[vault][spender];
    }
    
    function increaseLimit(address vault, address spender, uint256 addedValue) public {
        require(isVaultOwner(address(vault), msg.sender), "not vault owner");
        _approve(vault, spender, _limits[vault][spender].add(addedValue));
    }
    
    function decreaseLimit(address vault, address spender, uint256 subtractedValue) public {
        require(isVaultOwner(address(vault), msg.sender), "not vault owner");
        _approve(vault, spender, _limits[vault][spender].sub(subtractedValue, "decreased limit below zero"));
    }
    
    function _approve(address vault, address spender, uint256 amount) internal {
        require(spender != address(0), "approve to the zero address");
        _limits[vault][spender] = amount;
    }
    
    function isVaultOwner(address vault, address owner) public view returns (bool) {
        return _vaults[vault] == owner;
    }
    function isVault(address vault) public view returns (bool) {
        return _vaults[vault] != address(0);
    }
    
    // LP deposit, anyone can deposit/topup
    function deposit(iCollateralVault vault, address reserve, uint256 amount) external {
        IERC20(reserve).safeTransferFrom(msg.sender, address(this), amount);
        IERC20(reserve).safeTransfer(address(vault), amount);
        vault.activate(reserve);
    }
    
    // No logic, handled underneath by Aave
    function withdraw(iCollateralVault vault, address reserve, uint256 amount) external {
        require(isVaultOwner(address(vault), msg.sender), "not vault owner");
        vault.withdraw(reserve, amount, msg.sender);
    }
    
    // amount needs to be normalized
    function borrow(iCollateralVault vault, address reserve, uint256 amount) external {
        uint256 _borrow = getReservePriceUSD(reserve).mul(amount);
        _approve(address(vault), msg.sender, _limits[address(vault)][msg.sender].sub(_borrow, "borrow amount exceeds allowance"));
        vault.borrow(reserve, amount, msg.sender);
    }
    
    function repay(iCollateralVault vault, address reserve, uint256 amount) public {
        IERC20(reserve).safeTransferFrom(msg.sender, address(this), amount);
        IERC20(reserve).safeTransfer(address(vault), amount);
        vault.repay(reserve, amount);
    }
    
    function getVaults(address owner) external view returns (address[] memory) {
        return _ownedVaults[owner];
    }
    
    function deployVault() external returns (address) {
        address _vault = address(new iCollateralVault());
        
        // Mark address as vault
        _vaults[_vault] = msg.sender;
        
        // Set vault owner
        address[] memory vaults = _ownedVaults[msg.sender];
        vaults[vaults.length] = _vault;
        _ownedVaults[msg.sender] = vaults;
        return _vault;
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
}