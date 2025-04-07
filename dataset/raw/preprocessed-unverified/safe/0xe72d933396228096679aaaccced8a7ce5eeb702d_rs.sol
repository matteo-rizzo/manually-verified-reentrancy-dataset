/**
 *Submitted for verification at Etherscan.io on 2021-05-23
*/

pragma solidity 0.6.9;
pragma experimental ABIEncoderV2;









contract MigrationBSC is Ownable {
    using SafeMath for uint256;
    using SafeERC20 for IERC20;

    // ============ Storage ============

    address public immutable _ETH_WOO_TOKEN_;
    mapping(address => uint256) public balances;

    constructor(address ethWooToken) public {
        _ETH_WOO_TOKEN_ = ethWooToken;
    }

    // ============ Events ============

    event Lock(address indexed sender, address indexed mintToBscAccount, uint256 amount);
    event Unlock(address indexed to, uint256 amount);

    // ============ Functions ============

    function lock(uint256 amount, address mintToBscAccount) external {
        IERC20(_ETH_WOO_TOKEN_).safeTransferFrom(msg.sender, address(this), amount);
        balances[msg.sender] = balances[msg.sender].add(amount);
        emit Lock(msg.sender, mintToBscAccount, amount);
    }

    function unlock(address unlockTo, uint256 amount) external onlyOwner {
        require(balances[unlockTo] >= amount);
        balances[unlockTo] = balances[unlockTo].sub(amount);
        IERC20(_ETH_WOO_TOKEN_).safeTransfer(unlockTo, amount);
        emit Unlock(unlockTo, amount);
    }

}