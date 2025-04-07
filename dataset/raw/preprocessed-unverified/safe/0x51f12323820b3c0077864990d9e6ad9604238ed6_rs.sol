/**
 *Submitted for verification at Etherscan.io on 2020-12-08
*/

pragma solidity 0.5.17;











contract VestingVault is Ownable {
    using SafeMath for uint256;
    using SafeERC20 for IERC20;

    IERC20 public constant hakka = IERC20(0x0E29e5AbbB5FD88e28b2d355774e73BD47dE3bcd);

    uint256 public constant vestingPeriod = 19 days;
    uint256 public constant proportion = 173831376164413312; //17.38%

    mapping(address => uint256) public balanceOf;
    mapping(address => uint256) public lastWithdrawalTime;

    event Deposit(address indexed from, address indexed to, uint256 amount);
    event Withdraw(address indexed from, uint256 amount);

    function deposit(address to, uint256 amount) external {
        hakka.safeTransferFrom(msg.sender, address(this), amount);
        balanceOf[to] = balanceOf[to].add(amount);

        emit Deposit(msg.sender, to, amount);
    }

    function withdraw() external returns (uint256 amount) {
        address from = msg.sender;
        require(lastWithdrawalTime[from].add(vestingPeriod) < now);
        lastWithdrawalTime[from] = now;
        amount = balanceOf[from].mul(proportion).div(1e18);
        balanceOf[from] = balanceOf[from].sub(amount);
        hakka.safeTransfer(from, amount);

        emit Withdraw(msg.sender, amount);
    }

    function inCaseTokenGetsStuckPartial(IERC20 _TokenAddress, uint256 _amount) onlyOwner public {
        require(_TokenAddress != hakka);
        _TokenAddress.safeTransfer(msg.sender, _amount);
    }

}