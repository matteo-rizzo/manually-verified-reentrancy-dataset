/**
 *Submitted for verification at Etherscan.io on 2021-04-15
*/

pragma solidity 0.6.12;


/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
 */


/**
 * @dev Wrappers over Solidity's arithmetic operations with added overflow
 * checks.
 *
 * Arithmetic operations in Solidity wrap on overflow. This can easily result
 * in bugs, because programmers usually assume that an overflow raises an
 * error, which is the standard behavior in high level programming languages.
 * `SafeMath` restores this intuition by reverting the transaction when an
 * operation overflows.
 *
 * Using this library instead of the unchecked operations eliminates an entire
 * class of bugs, so it's recommended to use it always.
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








// Forked from the original yearn Controller (https://github.com/yearn/yearn-protocol/blob/develop/contracts/controllers/Controller.sol) with the following changes:
// - change mapping of vault and strategy from token -> vault, token -> strategy to vault <-> strategy
contract Controller is IController {
    using SafeERC20 for IERC20;
    using Address for address;
    using SafeMath for uint256;

    /* ========== STATE VARIABLES ========== */

    address public governance;

    // Strategy to vault mapping
    mapping(address => address) public vaults;
    // Vault to strategy mapping
    mapping(address => address) public strategies;

    /* ========== CONSTRUCTOR ========== */

    constructor() public {
        governance = msg.sender;
    }

    /* ========== VIEW FUNCTIONS ========== */

    function balanceOf(address _vault) external override view returns (uint) {
        return IStrategy(strategies[_vault]).balanceOf();
    }

    /* ========== MUTATIVE FUNCTIONS ========== */

    function farm(address _vault, uint _amount) external override {
        address _strategy = strategies[_vault];
        address _want = IStrategy(_strategy).want();
        IERC20(_want).safeTransfer(_strategy, _amount);
        IStrategy(_strategy).deposit();
    }

    function harvest(address _vault) external override {
        require(msg.sender == _vault, "!vault");
        IStrategy(strategies[_vault]).harvest();
    }

    function withdraw(address _vault, uint _amount) external override {
        require(msg.sender == _vault, "!vault");
        IStrategy(strategies[_vault]).withdraw(_amount);
    }

    /* ========== RESTRICTED FUNCTIONS ========== */

    function setGovernance(address _governance) external {
        require(msg.sender == governance, "!governance");
        governance = _governance;
    }

    function setStrategy(address _vault, address _strategy) external {
        require(msg.sender == governance, "!governance");
        require(IStrategy(_strategy).want() == IVault(_vault).token(), "unmatching want tokens between vault and strategy");

        address _current = strategies[_vault];
        if (_current != address(0)) {
           IStrategy(_current).withdrawAll();
        }
        strategies[_vault] = _strategy;
        vaults[_strategy] = _vault;
    }

    function withdrawAll(address _strategy) external {
        require(msg.sender == governance, "!governance");
        // WithdrawAll sends 'want' to 'vault'
        IStrategy(_strategy).withdrawAll();
    }

    function inCaseTokensGetStuck(address _token, uint _amount) external {
        require(msg.sender == governance, "!governance");
        IERC20(_token).safeTransfer(governance, _amount);
    }

    function inCaseStrategyTokenGetStuck(address _strategy, address _token) external {
        require(msg.sender == governance, "!governance");
        IStrategy(_strategy).withdraw(_token);
        IERC20(_token).safeTransfer(governance, IERC20(_token).balanceOf(address(this)));
    }
}