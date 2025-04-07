/**
 *Submitted for verification at Etherscan.io on 2020-11-12
*/

// SPDX-License-Identifier: MIT

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










// 0: DAI, 1: USDC, 2: USDT








/*

 A strategy must implement the following calls;

 - deposit()
 - withdraw(address) must exclude any tokens used in the yield - Controller role - withdraw should return to Controller
 - withdraw(uint) - Controller | Vault role - withdraw should always return to vault
 - withdrawAll() - Controller | Vault role - withdraw should always return to vault
 - balanceOf()

 Where possible, strategies must remain as immutable as possible, instead of updating variables, we update the contract by linking it in the controller

*/
abstract contract StrategyCurveBase {
    using SafeERC20 for IERC20;
    using Address for address;
    using SafeMath for uint;

    Uni public unirouter = Uni(0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D);

    // used for Crv -> weth -> [dai/usdc/usdt] -> 3crv route
    address public crv = address(0xD533a949740bb3306d119CC777fa900bA034cd52);
    address public weth = address(0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2);
    address public t3crv = address(0x6c3F90f043a72FA612cbac8115EE7e52BDe6E490);

    // for add_liquidity via curve.fi to get back 3CRV (use getMostPremium() for the best stable coin used in the route)
    address public dai = address(0x6B175474E89094C44Da98b954EedeAC495271d0F);
    address public usdc = address(0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48);
    address public usdt = address(0xdAC17F958D2ee523a2206206994597C13D831ec7);

    Mintr public crvMintr = Mintr(0xd061D61a4d941c39E5453435B6345Dc261C2fcE0);
    IStableSwap3Pool public stableSwap3Pool = IStableSwap3Pool(0xbEbc44782C7dB0a1A60Cb6fe97d0b483032FF1C7);

    address public want;
    Gauge public gauge;

    uint public withdrawalFee = 0; // over 10000

    address public governance;
    address public timelock = address(0x105e62e4bDFA67BCA18400Cfbe2EAcD4D0Be080d);
    address public controller;
    address public strategist;

    IValueMultiVault public vault;
    IValueVaultMaster public vaultMaster;

    mapping(address => mapping(address => address[])) public uniswapPaths; // [input -> output] => uniswap_path
    mapping(address => mapping(address => address)) public balancerPools; // [input -> output] => balancer_pool

    constructor(address _want, address _crv, address _weth, address _t3crv,
        address _dai, address _usdc, address _usdt,
        Gauge _gauge, Mintr _crvMintr,
        IStableSwap3Pool _stableSwap3Pool, address _controller) public {
        want = _want;
        if (_crv != address(0)) crv = _crv;
        if (_weth != address(0)) weth = _weth;
        if (_t3crv != address(0)) t3crv = _t3crv;
        if (_dai != address(0)) dai = _dai;
        if (_usdc != address(0)) usdc = _usdc;
        if (_usdt != address(0)) usdt = _usdt;
        if (address(_stableSwap3Pool) != address(0)) stableSwap3Pool = _stableSwap3Pool;
        gauge = _gauge;
        if (address(_crvMintr) != address(0)) crvMintr = _crvMintr;
        controller = _controller;
        vault = IValueMultiVault(IMultiVaultController(_controller).vault());
        require(address(vault) != address(0), "!vault");
        vaultMaster = IValueVaultMaster(vault.getVaultMaster());
        governance = msg.sender;
        strategist = msg.sender;
        IERC20(want).safeApprove(address(gauge), type(uint256).max);
        IERC20(weth).safeApprove(address(unirouter), type(uint256).max);
        IERC20(crv).safeApprove(address(unirouter), type(uint256).max);
        IERC20(dai).safeApprove(address(stableSwap3Pool), type(uint256).max);
        IERC20(usdc).safeApprove(address(stableSwap3Pool), type(uint256).max);
        IERC20(usdt).safeApprove(address(stableSwap3Pool), type(uint256).max);
        IERC20(t3crv).safeApprove(address(stableSwap3Pool), type(uint256).max);
    }

    function getMostPremium() public view returns (address, uint256)
    {
        uint256[] memory balances = new uint256[](3);
        balances[0] = stableSwap3Pool.balances(0); // DAI
        balances[1] = stableSwap3Pool.balances(1).mul(10**12); // USDC
        balances[2] = stableSwap3Pool.balances(2).mul(10**12); // USDT

        // DAI
        if (balances[0] < balances[1] && balances[0] < balances[2]) {
            return (dai, 0);
        }

        // USDC
        if (balances[1] < balances[0] && balances[1] < balances[2]) {
            return (usdc, 1);
        }

        // USDT
        if (balances[2] < balances[0] && balances[2] < balances[1]) {
            return (usdt, 2);
        }

        // If they're somehow equal, we just want DAI
        return (dai, 0);
    }

    function getName() public virtual pure returns (string memory);

    function setStrategist(address _strategist) external {
        require(msg.sender == governance, "!governance");
        strategist = _strategist;
    }

    function setWithdrawalFee(uint _withdrawalFee) external {
        require(msg.sender == governance, "!governance");
        withdrawalFee = _withdrawalFee;
    }

    function approveForSpender(IERC20 _token, address _spender, uint _amount) external {
        require(msg.sender == controller || msg.sender == governance, "!authorized");
        _token.safeApprove(_spender, _amount);
    }

    function setUnirouter(Uni _unirouter) external {
        require(msg.sender == governance, "!governance");
        unirouter = _unirouter;
        IERC20(weth).safeApprove(address(unirouter), type(uint256).max);
        IERC20(crv).safeApprove(address(unirouter), type(uint256).max);
    }

    function deposit() public {
        uint _wantBal = IERC20(want).balanceOf(address(this));
        if (_wantBal > 0) {
            // deposit [want] to Gauge
            gauge.deposit(_wantBal);
        }
    }

    function skim() external {
        uint _balance = IERC20(want).balanceOf(address(this));
        IERC20(want).safeTransfer(controller, _balance);
    }

    // Controller only function for creating additional rewards from dust
    function withdraw(IERC20 _asset) external returns (uint balance) {
        require(msg.sender == controller || msg.sender == governance || msg.sender == strategist, "!authorized");

        require(want != address(_asset), "want");

        balance = _asset.balanceOf(address(this));
        _asset.safeTransfer(controller, balance);
    }

    function withdrawToController(uint _amount) external {
        require(msg.sender == controller || msg.sender == governance || msg.sender == strategist, "!authorized");
        require(controller != address(0), "!controller"); // additional protection so we don't burn the funds

        uint _balance = IERC20(want).balanceOf(address(this));
        if (_balance < _amount) {
            _amount = _withdrawSome(_amount.sub(_balance));
            _amount = _amount.add(_balance);
        }

        IERC20(want).safeTransfer(controller, _amount);
    }

    // Withdraw partial funds, normally used with a vault withdrawal
    function withdraw(uint _amount) external returns (uint) {
        require(msg.sender == controller || msg.sender == governance || msg.sender == strategist, "!authorized");

        uint _balance = IERC20(want).balanceOf(address(this));
        if (_balance < _amount) {
            _amount = _withdrawSome(_amount.sub(_balance));
            _amount = _amount.add(_balance);
        }

        IERC20(want).safeTransfer(address(vault), _amount);
        return _amount;
    }

    // Withdraw all funds, normally used when migrating strategies
    function withdrawAll() external returns (uint balance) {
        require(msg.sender == controller || msg.sender == governance || msg.sender == strategist, "!authorized");
        _withdrawAll();

        balance = IERC20(want).balanceOf(address(this));

        IERC20(want).safeTransfer(address(vault), balance);
    }

    function claimReward() public {
        crvMintr.mint(address(gauge));
    }

    function _withdrawAll() internal {
        uint _bal = gauge.balanceOf(address(this));
        gauge.withdraw(_bal);
    }

    function setUnirouterPath(address _input, address _output, address [] memory _path) public {
        require(msg.sender == governance || msg.sender == strategist, "!authorized");
        uniswapPaths[_input][_output] = _path;
    }

    function setBalancerPools(address _input, address _output, address _pool) public {
        require(msg.sender == governance || msg.sender == strategist, "!authorized");
        balancerPools[_input][_output] = _pool;
        IERC20(_input).safeApprove(_pool, type(uint256).max);
    }

    function _swapTokens(address _input, address _output, uint256 _amount) internal {
        address _pool = balancerPools[_input][_output];
        if (_pool != address(0)) { // use balancer/vliquid
            Balancer(_pool).swapExactAmountIn(_input, _amount, _output, 1, type(uint256).max);
        } else { // use Uniswap
            address[] memory path = uniswapPaths[_input][_output];
            if (path.length == 0) {
                // path: _input -> _output
                path = new address[](2);
                path[0] = _input;
                path[1] = _output;
            }
            unirouter.swapExactTokensForTokens(_amount, 1, path, address(this), now.add(1800));
        }
    }

    function _addLiquidity() internal {
        uint[3] memory amounts;
        amounts[0] = IERC20(dai).balanceOf(address(this));
        amounts[1] = IERC20(usdc).balanceOf(address(this));
        amounts[2] = IERC20(usdt).balanceOf(address(this));
        stableSwap3Pool.add_liquidity(amounts, 1);
    }

    function harvest(address _mergedStrategy) external {
        require(msg.sender == controller || msg.sender == strategist || msg.sender == governance, "!authorized");
        claimReward();
        uint _crvBal = IERC20(crv).balanceOf(address(this));

        _swapTokens(crv, weth, _crvBal);
        uint256 _wethBal = IERC20(weth).balanceOf(address(this));

        if (_wethBal > 0) {
            if (_mergedStrategy != address(0)) {
                require(vaultMaster.isStrategy(_mergedStrategy), "!strategy"); // additional protection so we don't burn the funds
                IERC20(weth).safeTransfer(_mergedStrategy, _wethBal); // forward WETH to one strategy and do the profit split all-in-one there (gas saving)
            } else {
                address govVault = vaultMaster.govVault();
                address performanceReward = vaultMaster.performanceReward();

                if (vaultMaster.govVaultProfitShareFee() > 0 && govVault != address(0)) {
                    address _valueToken = vaultMaster.valueToken();
                    uint256 _govVaultProfitShareFee = _wethBal.mul(vaultMaster.govVaultProfitShareFee()).div(10000);
                    _swapTokens(weth, _valueToken, _govVaultProfitShareFee);
                    IERC20(_valueToken).safeTransfer(govVault, IERC20(_valueToken).balanceOf(address(this)));
                }

                if (vaultMaster.gasFee() > 0 && performanceReward != address(0)) {
                    uint256 _gasFee = _wethBal.mul(vaultMaster.gasFee()).div(10000);
                    IERC20(weth).safeTransfer(performanceReward, _gasFee);
                }

                _wethBal = IERC20(weth).balanceOf(address(this));
                // stablecoin we want to convert to
                (address _stableCoin,) = getMostPremium();
                _swapTokens(weth, _stableCoin, _wethBal);
                _addLiquidity();

                uint _3crvBal = IERC20(t3crv).balanceOf(address(this));
                if (_3crvBal > 0) {
                    IERC20(t3crv).safeTransfer(address(vault), _3crvBal); // send back 3Crv (basedWant) to vault for auto-compounding
                }
            }
        }
    }

    function _withdrawSome(uint _amount) internal returns (uint) {
        uint _before = IERC20(want).balanceOf(address(this));
        gauge.withdraw(_amount);
        uint _after = IERC20(want).balanceOf(address(this));
        _amount = _after.sub(_before);

        return _amount;
    }

    function balanceOfWant() public view returns (uint) {
        return IERC20(want).balanceOf(address(this));
    }

    function balanceOfPool() public view returns (uint) {
        return gauge.balanceOf(address(this));
    }

    function balanceOf() public view returns (uint) {
        return balanceOfWant()
               .add(balanceOfPool());
    }

    function claimable_tokens() external view returns (uint) {
        return gauge.claimable_tokens(address(this));
    }

    function withdrawFee(uint _amount) external view returns (uint) {
        return _amount.mul(withdrawalFee).div(10000);
    }

    function setGovernance(address _governance) external {
        require(msg.sender == governance, "!governance");
        governance = _governance;
    }

    function setTimelock(address _timelock) external {
        require(msg.sender == timelock, "!timelock");
        timelock = _timelock;
    }

    function setController(address _controller) external {
        require(msg.sender == governance, "!governance");
        controller = _controller;
        vault = IValueMultiVault(IMultiVaultController(_controller).vault());
        require(address(vault) != address(0), "!vault");
        vaultMaster = IValueVaultMaster(vault.getVaultMaster());
    }

    event ExecuteTransaction(address indexed target, uint value, string signature, bytes data);

    /**
     * @dev This is from Timelock contract, the governance should be a Timelock contract before calling this emergency function!
     */
    function executeTransaction(address target, uint value, string memory signature, bytes memory data) public returns (bytes memory) {
        require(msg.sender == timelock, "!timelock");

        bytes memory callData;

        if (bytes(signature).length == 0) {
            callData = data;
        } else {
            callData = abi.encodePacked(bytes4(keccak256(bytes(signature))), data);
        }

        // solium-disable-next-line security/no-call-value
        (bool success, bytes memory returnData) = target.call{value : value}(callData);
        require(success, string(abi.encodePacked(getName(), "::executeTransaction: Transaction execution reverted.")));

        emit ExecuteTransaction(target, value, signature, data);

        return returnData;
    }
}

contract StrategyCurve3Crv is StrategyCurveBase {
    // want  = 0x6c3F90f043a72FA612cbac8115EE7e52BDe6E490 (3Crv)
    // gauge = 0xbFcF63294aD7105dEa65aA58F8AE5BE2D9d0952A (3Crv Gauge)
    constructor(address _want, address _crv, address _weth, address _t3crv,
        address _dai, address _usdc, address _usdt,
        Gauge _gauge, Mintr _crvMintr,
        IStableSwap3Pool _stableSwap3Pool, address _controller) public
            StrategyCurveBase(_want, _crv, _weth, _t3crv, _dai, _usdc, _usdt, _gauge, _crvMintr, _stableSwap3Pool, _controller) {
    }

    function getName() public override pure returns (string memory) {
        return "mvUSD:StrategyCurve3Crv";
    }
}