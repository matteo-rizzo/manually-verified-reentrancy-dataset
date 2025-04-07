pragma solidity ^0.5.17;

















/*

 A strategy must implement the following calls;
 
 - deposit()
 - withdraw(address) must exclude any tokens used in the yield - Controller role - withdraw should return to Controller
 - withdraw(uint) - Controller | Vault role - withdraw should always return to vault
 - withdrawAll() - Controller | Vault role - withdraw should always return to vault
 - balanceOf()
 
 Where possible, strategies must remain as immutable as possible, instead of updating variables, we update the contract by linking it in the controller
 
*/

contract StrategyVaultUSDT {
    using SafeERC20 for IERC20;
    using Address for address;
    using SafeMath for uint256;
    
    address constant public want = address(0xdAC17F958D2ee523a2206206994597C13D831ec7);
    address constant public vault = address(0x2927071efbC6BdC21B87c27F2923689Cec562FD7);
    
    address public constant aave = address(0x24a42fD28C976A61Df5D00D0599C34c4f90748c8);

    address public governance;
    address public controller;
    
    constructor(address _controller) public {
        governance = msg.sender;
        controller = _controller;
    }
    
    function deposit() external {
        uint _balance = IERC20(want).balanceOf(address(this));
        if (_balance > 0) {
            IERC20(want).safeApprove(address(vault), 0);
            IERC20(want).safeApprove(address(vault), _balance);
            Vault(vault).deposit(_balance);
        }
    }
    
    function getAave() public view returns (address) {
        return LendingPoolAddressesProvider(aave).getLendingPool();
    }
    
    function getName() external pure returns (string memory) {
        return "StrategyVaultUSDT";
    }
    
    function debt() external view returns (uint) {
        (,uint currentBorrowBalance,,,,,,,,) = Aave(getAave()).getUserReserveData(want, Controller(controller).vaults(address(this)));
        return currentBorrowBalance;
    }
    
    function have() public view returns (uint) {
        uint _have = balanceOf();
        return _have;
    }
    
    function skimmable() public view returns (uint) {
        (,uint currentBorrowBalance,,,,,,,,) = Aave(getAave()).getUserReserveData(want, Controller(controller).vaults(address(this)));
        uint _have = have();
        if (_have > currentBorrowBalance) {
            return _have.sub(currentBorrowBalance);
        } else {
            return 0;
        }
    }
    
    function skim() external {
        uint _balance = IERC20(want).balanceOf(address(this));
        uint _amount = skimmable();
        if (_balance < _amount) {
            _amount = _withdrawSome(_amount.sub(_balance));
            _amount = _amount.add(_balance);
        } 
        IERC20(want).safeTransfer(controller, _amount);
    }
    
    // Controller only function for creating additional rewards from dust
    function withdraw(IERC20 _asset) external returns (uint balance) {
        require(msg.sender == controller, "!controller");
        require(address(_asset) != address(want), "!want");
        require(address(_asset) != address(vault), "!vault");
        balance = _asset.balanceOf(address(this));
        _asset.safeTransfer(controller, balance);
    }
    
    // Withdraw partial funds, normally used with a vault withdrawal
    function withdraw(uint _amount) external {
        require(msg.sender == controller, "!controller");
        uint _balance = IERC20(want).balanceOf(address(this));
        if (_balance < _amount) {
            _amount = _withdrawSome(_amount.sub(_balance));
            _amount = _amount.add(_balance);
        }
        address _vault = Controller(controller).vaults(address(this));
        require(_vault != address(0), "!vault"); // additional protection so we don't burn the funds
        IERC20(want).safeTransfer(_vault, _amount);
    }
    
    // Withdraw all funds, normally used when migrating strategies
    function withdrawAll() external returns (uint balance) {
        require(msg.sender == controller, "!controller");
        _withdrawAll();
        balance = IERC20(want).balanceOf(address(this));
        address _vault = Controller(controller).vaults(address(this));
        require(_vault != address(0), "!vault"); // additional protection so we don't burn the funds
        IERC20(want).safeTransfer(_vault, balance);
    }
    
    function _withdrawAll() internal {
        Vault(vault).withdraw(IERC20(vault).balanceOf(address(this)));
    }
    
    function _withdrawSome(uint256 _amount) internal returns (uint) {
        uint _redeem = IERC20(vault).balanceOf(address(this)).mul(_amount).div(balanceSavingsInToken());
        uint _before = IERC20(want).balanceOf(address(this));
        Vault(vault).withdraw(_redeem);
        uint _after = IERC20(want).balanceOf(address(this));
        return _after.sub(_before);
    }
    
    function balanceOf() public view returns (uint) {
        return IERC20(want).balanceOf(address(this))
                .add(balanceSavingsInToken());
    }
    
    function balanceSavingsInToken() public view returns (uint256) {
        return IERC20(vault).balanceOf(address(this)).mul(Vault(vault).getPricePerFullShare()).div(1e18);
    }
    
    function setGovernance(address _governance) external {
        require(msg.sender == governance, "!governance");
        governance = _governance;
    }
    
    function setController(address _controller) external {
        require(msg.sender == governance, "!governance");
        controller = _controller;
    }
}