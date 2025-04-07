pragma solidity ^0.4.18;


/**
 * @title ERC20Basic
 * @dev Simpler version of ERC20 interface
 * @dev see https://github.com/ethereum/EIPs/issues/179
 */
contract ERC20Basic {
    function totalSupply() public view returns (uint256);
    function balanceOf(address who) public view returns (uint256);
    function transfer(address to, uint256 value) public returns (bool);
    event Transfer(address indexed from, address indexed to, uint256 value);
}

/**
 * @title ERC20 interface
 * @dev see https://github.com/ethereum/EIPs/issues/20
 */
contract ERC20 is ERC20Basic {
    function allowance(address owner, address spender) public view returns (uint256);
    function transferFrom(address from, address to, uint256 value) public returns (bool);
    function approve(address spender, uint256 value) public returns (bool);
    event Approval(address indexed owner, address indexed spender, uint256 value);
}

contract TOSERC20  is ERC20 {
    function lockBalanceOf(address who) public view returns (uint256);
}

/**
 * @title SafeERC20
 * @dev Wrappers around ERC20 operations that throw on failure.
 * To use this library you can add a `using SafeERC20 for ERC20;` statement to your contract,
 * which allows you to call the safe operations as `token.safeTransfer(...)`, etc.
 */


/**
 * @title SafeMath
 * @dev Math operations with safety checks that throw on error
 */


/**
 * @title TosTeamLockContract
 * @dev TosTeamLockContract is a token holder contract that will allow a
 * beneficiary to extract the tokens after a given unlock time
 */
contract TosTeamLockContract {
    using SafeERC20 for TOSERC20;
    using SafeMath for uint;

    string public constant name = "TosTeamLockContract";

    uint256 public constant RELEASE_TIME                   = 1623254400;  //2021/6/10 0:0:0;

    uint256 public constant RELEASE_PERIODS                = 180 days;  

    TOSERC20 public tosToken = TOSERC20(0xFb5a551374B656C6e39787B1D3A03fEAb7f3a98E);
    address public beneficiary = 0xA24cB9920d882e084Cc29304d1f9c80D288F8054;

    uint256 public numOfReleased = 0;


    function TosTeamLockContract() public {}

    /**
     * @notice Transfers tokens held by timelock to beneficiary.
     */
    function release() public {
        // solium-disable-next-line security/no-block-members
        require(now >= RELEASE_TIME);

        uint256 num = (now - RELEASE_TIME) / RELEASE_PERIODS;
        require(num + 1 > numOfReleased);

        uint256 amount = tosToken.balanceOf(this).mul(30).div(100);

        require(amount > 0);

        tosToken.safeTransfer(beneficiary, amount);
        numOfReleased = numOfReleased.add(1);   
    }
}