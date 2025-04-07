/**
 *Submitted for verification at Etherscan.io on 2020-10-07
*/

// SPDX-License-Identifier: MIT

pragma solidity ^0.5.17;


/**
 * @dev Interface of the ERC20 standard as defined in the EIP. Does not include
 * the optional functions; to access them see {ERC20Detailed}.
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
 * To use this library you can add a `using SafeERC20 for ERC20;` statement to your contract,
 * which allows you to call the safe operations as `token.safeTransfer(...)`, etc.
 */


// 


// 


// 
contract StrategyProxy {
    using SafeERC20 for IERC20;
    using Address for address;
    using SafeMath for uint256;

    Proxy public constant proxy = Proxy(0xF147b8125d2ef93FB6965Db97D6746952a133934);
    address public constant mintr = address(0xd061D61a4d941c39E5453435B6345Dc261C2fcE0);
    address public constant crv = address(0xD533a949740bb3306d119CC777fa900bA034cd52);
    address public constant gauge = address(0x2F50D538606Fa9EDD2B11E2446BEb18C9D5846bB);
    address public constant y = address(0xFA712EE4788C042e2B7BB55E6cb8ec569C4530c1);

    mapping(address => bool) public strategies;
    address public governance;

    constructor() public {
        governance = msg.sender;
    }

    function setGovernance(address _governance) external {
        require(msg.sender == governance, "!governance");
        governance = _governance;
    }

    function approveStrategy(address _strategy) external {
        require(msg.sender == governance, "!governance");
        strategies[_strategy] = true;
    }

    function revokeStrategy(address _strategy) external {
        require(msg.sender == governance, "!governance");
        strategies[_strategy] = false;
    }

    function lock() external {
        proxy.increaseAmount(IERC20(crv).balanceOf(address(proxy)));
    }

    function vote(address _gauge, uint256 _amount) public {
        require(strategies[msg.sender], "!strategy");
        proxy.execute(gauge, 0, abi.encodeWithSignature("vote_for_gauge_weights(address,uint256)", _gauge, _amount));
    }

    function max() external {
        require(strategies[msg.sender], "!strategy");
        vote(y, 10000);
    }

    function withdraw(
        address _gauge,
        address _token,
        uint256 _amount
    ) public returns (uint256) {
        require(strategies[msg.sender], "!strategy");
        uint256 _before = IERC20(_token).balanceOf(address(proxy));
        proxy.execute(_gauge, 0, abi.encodeWithSignature("withdraw(uint256)", _amount));
        uint256 _after = IERC20(_token).balanceOf(address(proxy));
        uint256 _net = _after.sub(_before);
        proxy.execute(_token, 0, abi.encodeWithSignature("transfer(address,uint256)", msg.sender, _net));
        return _net;
    }

    function balanceOf(address _gauge) public view returns (uint256) {
        return IERC20(_gauge).balanceOf(address(proxy));
    }

    function withdrawAll(address _gauge, address _token) external returns (uint256) {
        require(strategies[msg.sender], "!strategy");
        return withdraw(_gauge, _token, balanceOf(_gauge));
    }

    function deposit(address _gauge, address _token) external {
        uint256 _balance = IERC20(_token).balanceOf(address(this));
        IERC20(_token).safeTransfer(address(proxy), _balance);
        _balance = IERC20(_token).balanceOf(address(proxy));

        proxy.execute(_token, 0, abi.encodeWithSignature("approve(address,uint256)", _gauge, 0));
        proxy.execute(_token, 0, abi.encodeWithSignature("approve(address,uint256)", _gauge, _balance));
        (bool success, ) = proxy.execute(_gauge, 0, abi.encodeWithSignature("deposit(uint256)", _balance));
        if (!success) {
            throwInvalidOpcode();
        }
    }

    function harvest(address _gauge) external {
        require(strategies[msg.sender], "!strategy");
        uint256 _before = IERC20(crv).balanceOf(address(proxy));
        proxy.execute(mintr, 0, abi.encodeWithSignature("mint(address)", _gauge));
        uint256 _after = IERC20(crv).balanceOf(address(proxy));
        uint256 _balance = _after.sub(_before);
        proxy.execute(crv, 0, abi.encodeWithSignature("transfer(address,uint256)", msg.sender, _balance));
    }

    // Forces execution to fail with an invalid_opcode.
    // It might help with correct gas estimations.
    function throwInvalidOpcode() public pure {
        bool[] memory array = new bool[](0);
        array[0] = array[0];
    }
}