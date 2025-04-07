/**
 *Submitted for verification at Etherscan.io on 2021-05-14
*/

pragma solidity ^0.5.0;

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
 * @dev Interface of the ERC20 standard as defined in the EIP. Does not include
 * the optional functions; to access them see {ERC20Detailed}.
 */


// SPDX-License-Identifier: MIT









/**
 * @dev Collection of functions related to the address type
 */


/**
 * @title SafeERC20
 * @dev Wrappers around ERC20 operations that throw on failure (when the token
 * contract returns false). Tokens that return no value (and instead revert or
 * throw on failure) are also supported, non-reverting calls are assumed to be
 * successful.
 * To use this library you can add a `using SafeERC20 for ERC20;` statement to your contract,
 * which allows you to call the safe operations as `token.safeTransfer(...)`, etc.
 */




contract StrategyProxy {
    using SafeERC20 for IERC20;
    using Address for address;
    using SafeMath for uint256;
    using SafeProxy for IProxy;

    IProxy public constant proxy = IProxy(0xF147b8125d2ef93FB6965Db97D6746952a133934);
    address public constant mintr = address(0xd061D61a4d941c39E5453435B6345Dc261C2fcE0);
    address public constant crv = address(0xD533a949740bb3306d119CC777fa900bA034cd52);
    address public constant gauge = address(0x2F50D538606Fa9EDD2B11E2446BEb18C9D5846bB);
    address public constant yveCRV = address(0xc5bDdf9843308380375a611c18B50Fb9341f502A);
    address public constant CRV3 = address(0x6c3F90f043a72FA612cbac8115EE7e52BDe6E490);
    FeeDistribution public constant feeDistribution = FeeDistribution(0xA464e6DCda8AC41e03616F95f4BC98a13b8922Dc);

    // gauge => strategies
    mapping(address => address) public strategies;
    mapping(address => bool) public voters;
    address public governance;

    uint256 lastTimeCursor;

    constructor() public {
        governance = msg.sender;
    }

    function setGovernance(address _governance) external {
        require(msg.sender == governance, "!governance");
        governance = _governance;
    }

    function approveStrategy(address _gauge, address _strategy) external {
        require(msg.sender == governance, "!governance");
        strategies[_gauge] = _strategy;
    }

    function revokeStrategy(address _gauge) external {
        require(msg.sender == governance, "!governance");
        strategies[_gauge] = address(0);
    }

    function approveVoter(address _voter) external {
        require(msg.sender == governance, "!governance");
        voters[_voter] = true;
    }

    function revokeVoter(address _voter) external {
        require(msg.sender == governance, "!governance");
        voters[_voter] = false;
    }

    function lock() external {
        uint256 amount = IERC20(crv).balanceOf(address(proxy));
        if (amount > 0) proxy.increaseAmount(amount);
    }

    function vote(address _gauge, uint256 _amount) public {
        require(voters[msg.sender], "!voter");
        proxy.safeExecute(gauge, 0, abi.encodeWithSignature("vote_for_gauge_weights(address,uint256)", _gauge, _amount));
    }

    function withdraw(
        address _gauge,
        address _token,
        uint256 _amount
    ) public returns (uint256) {
        require(strategies[_gauge] == msg.sender, "!strategy");
        uint256 _balance = IERC20(_token).balanceOf(address(proxy));
        proxy.safeExecute(_gauge, 0, abi.encodeWithSignature("withdraw(uint256)", _amount));
        _balance = IERC20(_token).balanceOf(address(proxy)).sub(_balance);
        proxy.safeExecute(_token, 0, abi.encodeWithSignature("transfer(address,uint256)", msg.sender, _balance));
        return _balance;
    }

    function balanceOf(address _gauge) public view returns (uint256) {
        return IERC20(_gauge).balanceOf(address(proxy));
    }

    function withdrawAll(address _gauge, address _token) external returns (uint256) {
        require(strategies[_gauge] == msg.sender, "!strategy");
        return withdraw(_gauge, _token, balanceOf(_gauge));
    }

    function deposit(address _gauge, address _token) external {
        require(strategies[_gauge] == msg.sender, "!strategy");
        uint256 _balance = IERC20(_token).balanceOf(address(this));
        IERC20(_token).safeTransfer(address(proxy), _balance);
        _balance = IERC20(_token).balanceOf(address(proxy));

        proxy.safeExecute(_token, 0, abi.encodeWithSignature("approve(address,uint256)", _gauge, 0));
        proxy.safeExecute(_token, 0, abi.encodeWithSignature("approve(address,uint256)", _gauge, _balance));
        proxy.safeExecute(_gauge, 0, abi.encodeWithSignature("deposit(uint256)", _balance));
    }

    function harvest(address _gauge) external {
        require(strategies[_gauge] == msg.sender, "!strategy");
        uint256 _balance = IERC20(crv).balanceOf(address(proxy));
        proxy.safeExecute(mintr, 0, abi.encodeWithSignature("mint(address)", _gauge));
        _balance = (IERC20(crv).balanceOf(address(proxy))).sub(_balance);
        proxy.safeExecute(crv, 0, abi.encodeWithSignature("transfer(address,uint256)", msg.sender, _balance));
    }

    function claim(address recipient) external {
        require(msg.sender == yveCRV, "!strategy");
        if (now < lastTimeCursor.add(604800)) return;

        address p = address(proxy);
        feeDistribution.claim_many([p, p, p, p, p, p, p, p, p, p, p, p, p, p, p, p, p, p, p, p]);
        lastTimeCursor = feeDistribution.time_cursor_of(address(proxy));

        uint256 amount = IERC20(CRV3).balanceOf(address(proxy));
        if (amount > 0) {
            proxy.safeExecute(CRV3, 0, abi.encodeWithSignature("transfer(address,uint256)", recipient, amount));
        }
    }

    function claimRewards(address _gauge, address _token) external {
        require(strategies[_gauge] == msg.sender, "!strategy");
        Gauge(_gauge).claim_rewards(address(proxy));
        proxy.safeExecute(_token, 0, abi.encodeWithSignature("transfer(address,uint256)", msg.sender, IERC20(_token).balanceOf(address(proxy))));
    }
}