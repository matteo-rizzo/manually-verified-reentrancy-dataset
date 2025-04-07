/**
 *Submitted for verification at Etherscan.io on 2020-10-10
*/

pragma solidity ^0.6.12;
/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
 */




/**
 * @dev Collection of functions related to the address type
 */


/**
 * @title SafeERC20
 * @dev Wrappers around ERC20 operations that throw on failure (when the token
 * contract returns false). Tokens that return no value (and instead revert or
 * throw on failure) are also supported, non-reverting calls are assumed to be
 * successful.
 * To use this library you can add a `using SafeERC20 for IERC20;` statement to your contract,
 * which allows you to call the safe operations as `token.safeTransfer(...)`, etc.
 */







/*

 A strategy must implement the following calls;

 - deposit()
 - withdraw(address) must exclude any tokens used in the yield - Controller role - withdraw should return to Controller
 - withdraw(uint) - Controller | Vault role - withdraw should always return to vault
 - withdrawAll() - Controller | Vault role - withdraw should always return to vault
 - balanceOf()

 Where possible, strategies must remain as immutable as possible, instead of updating variables, we update the contract by linking it in the controller

*/



contract StrategyCritAMM {
    using SafeERC20 for IERC20;
    using Address for address;
    using SafeMath for uint256;

    address public governance;
    address public controller;
    address public strategist;

    address public want;    // CRIT | WETH
    address public amm;

    modifier onlyGovernance {
        require(msg.sender == governance, "!governance");
        _;
    }

    constructor(address _want, address _controller) public {
        want = _want;
        governance = msg.sender;
        controller = _controller;
        strategist = msg.sender;
    }

    function getName() external pure returns (string memory) {
        return "StrategyCritAMM";
    }

    function deposit() public {
        uint balance = IERC20(want).balanceOf(address(this));
        if (balance > 0) {
            ICritAMM(amm).deposit(want, balance);
        }
    }

    // Controller only function for creating additional rewards from dust
    function withdraw(IERC20 _asset) external returns (uint balance) {
        require(msg.sender == controller, "!controller");
        require(want != address(_asset), "want");

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
        ICritAMM critAMM = ICritAMM(amm);
        critAMM.withdraw(want, critAMM.tokenBalance(want));
    }

    function _withdrawSome(uint256 _amount) internal returns (uint) {
        ICritAMM critAMM = ICritAMM(amm);
        critAMM.withdraw(want, _amount);
        return _amount;
    }

    function balanceOf() public view returns (uint) {
        return ICritAMM(amm).tokenBalance(want).add(IERC20(want).balanceOf(address(this)));
    }

    function setGovernance(address _governance) external onlyGovernance {
        require(_governance != address(0), "0x0");
        governance = _governance;
    }

    function setController(address _controller) external onlyGovernance {
        require(_controller != address(0), "0x0");
        controller = _controller;
    }

    function setStrategist(address _strategist) external onlyGovernance {
        require(_strategist != address(0), "0x0");
        strategist = _strategist;
    }

    function setAMM(address _amm) external onlyGovernance {
        require(_amm != address(0), "0x0");
        if (amm != address(0)) {
            IERC20(want).safeApprove(amm, 0);
        }
        amm = _amm;
        IERC20(want).safeApprove(_amm, 0);
        IERC20(want).safeApprove(_amm, uint(~0));
    }
}