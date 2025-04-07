/**
 *Submitted for verification at Etherscan.io on 2021-06-09
*/

pragma solidity 0.6.9;
pragma experimental ABIEncoderV2;









contract MigrationBSC is Ownable {
    using SafeMath for uint256;
    using SafeERC20 for IERC20;

    // ============ Storage ============

    address public immutable _ETH_WOO_TOKEN_;
    uint256 public balance;

    constructor(address ethWooToken) public {
        _ETH_WOO_TOKEN_ = ethWooToken;
    }

    // ============ Events ============

    event Lock(address indexed sender, address indexed mintToBscAccount, uint256 amount);
    event Unlock(address indexed to, uint256 amount);

    // ============ Functions ============

    function lock(uint256 amount, address mintToBscAccount) external {
        IERC20(_ETH_WOO_TOKEN_).safeTransferFrom(msg.sender, address(this), amount);
        balance = balance.add(amount);
        emit Lock(msg.sender, mintToBscAccount, amount);
    }

    function unlock(address unlockTo, uint256 amount) external onlyOwner {
        require(balance >= amount);
        balance = balance.sub(amount);
        IERC20(_ETH_WOO_TOKEN_).safeTransfer(unlockTo, amount);
        emit Unlock(unlockTo, amount);
    }

}