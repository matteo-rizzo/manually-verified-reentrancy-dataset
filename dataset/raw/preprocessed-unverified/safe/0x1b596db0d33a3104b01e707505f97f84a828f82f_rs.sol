/**
 *Submitted for verification at Etherscan.io on 2020-07-08
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
    uint256 public model = 2;
    address public asset = address(0);
    
    address private _owner;
    address[] private _activeReserves;

    function owner() public view returns (address) {
        return _owner;
    }
    modifier onlyOwner() {
        require(isOwner(), "!owner");
        _;
    }
    function isOwner() public view returns (bool) {
        return msg.sender == _owner;
    }
    
    constructor() public {
        _owner = msg.sender;
    }
    
    function setModel(uint256 _model) public onlyOwner {
        model = _model;
    }
    
    function setBorrow(address _asset) public onlyOwner {
        asset = _asset;
    }
    
    function getReserves() public view returns (address[] memory) {
        return _activeReserves;
    }
    
    // LP deposit, anyone can deposit/topup
    function activate(address reserve) external {
        _activeReserves.push(reserve);
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
        require(asset == reserve || asset == address(0), "reserve not available");
        // LTV logic handled by underlying
        Aave(getAave()).borrow(reserve, amount, model, 7);
        IERC20(reserve).safeTransfer(to, amount);
    }
    
    function repay(address reserve, uint256 amount) external nonReentrant onlyOwner {
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
    
    mapping (address => mapping (address => bool)) private _borrowerContains;
    mapping (address => address[]) private _borrowers;
    mapping (address => address[]) private _borrowerVaults;
    
    address public constant aave = address(0x24a42fD28C976A61Df5D00D0599C34c4f90748c8);
    address public constant link = address(0xF79D6aFBb6dA890132F9D7c355e3015f15F3406F);
    
    constructor() public {
        deployVault();
    }
    
    function limit(address vault, address spender) public view returns (uint256) {
        return _limits[vault][spender];
    }
    
    function borrowers(address vault) public view returns (address[] memory) {
        return _borrowers[vault];
    }
    
    function borrowerVaults(address spender) public view returns (address[] memory) {
        return _borrowerVaults[spender];
    }
    
    function increaseLimit(address vault, address spender, uint256 addedValue) public {
        require(isVaultOwner(address(vault), msg.sender), "!owner");
        if (!_borrowerContains[vault][spender]) {
            _borrowerContains[vault][spender] = true;
            _borrowers[vault].push(spender);
            _borrowerVaults[spender].push(vault);
        }
        _approve(vault, spender, _limits[vault][spender].add(addedValue));
    }
    
    function decreaseLimit(address vault, address spender, uint256 subtractedValue) public {
        require(isVaultOwner(address(vault), msg.sender), "!owner");
        _approve(vault, spender, _limits[vault][spender].sub(subtractedValue, "<0"));
    }
    
    function setModel(iCollateralVault vault, uint256 model) public {
        require(isVaultOwner(address(vault), msg.sender), "!owner");
        vault.setModel(model);
    }
    
    function setBorrow(iCollateralVault vault, address borrow) public {
        require(isVaultOwner(address(vault), msg.sender), "!owner");
        vault.setBorrow(borrow);
    }
    
    function _approve(address vault, address spender, uint256 amount) internal {
        require(spender != address(0), "address(0)");
        _limits[vault][spender] = amount;
    }
    
    function isVaultOwner(address vault, address owner) public view returns (bool) {
        return _vaults[vault] == owner;
    }
    function isVault(address vault) public view returns (bool) {
        return _vaults[vault] != address(0);
    }
    
    // LP deposit, anyone can deposit/topup
    function deposit(iCollateralVault vault, address aToken, uint256 amount) external {
        require(isVault(address(vault)), "!vault");
        IERC20(aToken).safeTransferFrom(msg.sender, address(vault), amount);
        vault.activate(AaveToken(aToken).underlyingAssetAddress());
    }
    
    // No logic, handled underneath by Aave
    function withdraw(iCollateralVault vault, address aToken, uint256 amount) external {
        require(isVaultOwner(address(vault), msg.sender), "!owner");
        vault.withdraw(aToken, amount, msg.sender);
    }
    
    // amount needs to be normalized
    function borrow(iCollateralVault vault, address reserve, uint256 amount) external {
        uint256 _borrow = getReservePriceUSD(reserve).mul(amount);
        _approve(address(vault), msg.sender, _limits[address(vault)][msg.sender].sub(_borrow, "borrow amount exceeds allowance"));
        vault.borrow(reserve, amount, msg.sender);
    }
    
    function repay(iCollateralVault vault, address reserve, uint256 amount) public {
        require(isVault(address(vault)), "not a vault");
        IERC20(reserve).safeTransferFrom(msg.sender, address(vault), amount);
        vault.repay(reserve, amount);
    }
    
    function getVaults(address owner) external view returns (address[] memory) {
        return _ownedVaults[owner];
    }
    
    function deployVault() public returns (address) {
        address vault = address(new iCollateralVault());
        
        // Mark address as vault
        _vaults[vault] = msg.sender;
        
        // Set vault owner
        address[] storage owned = _ownedVaults[msg.sender];
        owned.push(vault);
        _ownedVaults[msg.sender] = owned;
        return vault;
    }
    
    function getVaultAccountData(address _vault)
        external
        view
        returns (
            uint256 totalLiquidityUSD,
            uint256 totalCollateralUSD,
            uint256 totalBorrowsUSD,
            uint256 totalFeesUSD,
            uint256 availableBorrowsUSD,
            uint256 currentLiquidationThreshold,
            uint256 ltv,
            uint256 healthFactor
        ) {
        (
            totalLiquidityUSD,
            totalCollateralUSD,
            totalBorrowsUSD,
            totalFeesUSD,
            availableBorrowsUSD,
            currentLiquidationThreshold,
            ltv,
            healthFactor
        ) = Aave(getAave()).getUserAccountData(_vault);
        uint256 ETH2USD = getETHPriceUSD();
        totalLiquidityUSD = totalLiquidityUSD.mul(ETH2USD);
        totalCollateralUSD = totalCollateralUSD.mul(ETH2USD);
        totalBorrowsUSD = totalBorrowsUSD.mul(ETH2USD);
        totalFeesUSD = totalFeesUSD.mul(ETH2USD);
        availableBorrowsUSD = availableBorrowsUSD.mul(ETH2USD);
    }
    
    function getAaveOracle() public view returns (address) {
        return LendingPoolAddressesProvider(aave).getPriceOracle();
    }
    
    function getReservePriceETH(address reserve) public view returns (uint256) {
        return Oracle(getAaveOracle()).getAssetPrice(reserve);
    }
    
    function getReservePriceUSD(address reserve) public view returns (uint256) {
        return getReservePriceETH(reserve).mul(Oracle(link).latestAnswer()).div(1e26);
    }
    
    function getETHPriceUSD() public view returns (uint256) {
        return Oracle(link).latestAnswer();
    }
    
    function getAave() public view returns (address) {
        return LendingPoolAddressesProvider(aave).getLendingPool();
    }
}