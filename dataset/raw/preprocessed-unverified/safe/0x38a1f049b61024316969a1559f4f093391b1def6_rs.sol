/**
 *Submitted for verification at Etherscan.io on 2021-04-08
*/

// SPDX-License-Identifier: GPL-3.0-only

pragma solidity 0.7.4;




/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
 */



contract MostBasicYield {
    using SafeMathLib for uint;

    struct Receipt {
        uint id;
        uint amountDeposited;
        uint timeDeposited;
        uint timeWithdrawn;
        address owner;
    }

    uint[] public tokensPerSecondPerToken;
    uint public maximumDeposit;
    uint public totalDeposits = 0;
    uint[] public rewardsClaimed;
    uint public numReceipts = 0;
    uint public startTime;
    uint public endTime;

    address public management;

    IERC20 public depositToken;
    IERC20[] public rewardTokens;
    mapping (uint => Receipt) public receipts;

    event DepositOccurred(uint indexed id, address indexed owner);
    event WithdrawalOccurred(uint indexed id, address indexed owner);
    event ExcessRewardsWithdrawn();

    constructor(
        uint _startTime,
        uint maxDeposit,
        uint[] memory rewards,
        uint programLengthDays,
        address depositTokenAddress,
        address[] memory rewardTokenAddresses,
        address mgmt)
    {
        tokensPerSecondPerToken = rewards;
        startTime = _startTime > 0 ? _startTime : block.timestamp;
        endTime = startTime.plus(programLengthDays * 1 days);
        depositToken = IERC20(depositTokenAddress);
        require(tokensPerSecondPerToken.length == rewardTokenAddresses.length, 'Rewards and reward token arrays must be same length');

        for (uint i = 0; i < rewardTokenAddresses.length; i++) {
            rewardTokens.push(IERC20(rewardTokenAddresses[i]));
            rewardsClaimed.push(0);
        }

        maximumDeposit = maxDeposit;
        management = mgmt;
    }

    function getRewards(uint receiptId) public view returns (uint[] memory) {
        Receipt memory receipt = receipts[receiptId];
        uint nowish = block.timestamp;
        if (nowish > endTime) {
            nowish = endTime;
        }

        uint secondsDiff = nowish.minus(receipt.timeDeposited);
        uint[] memory rewardsLocal = new uint[](tokensPerSecondPerToken.length);
        for (uint i = 0; i < tokensPerSecondPerToken.length; i++) {
            rewardsLocal[i] = (secondsDiff.times(tokensPerSecondPerToken[i]).times(receipt.amountDeposited)) / 1e18;
        }

        return rewardsLocal;
    }

    function deposit(uint amount) external {
        require(block.timestamp > startTime, 'Cannot deposit before pool start');
        require(block.timestamp < endTime, 'Cannot deposit after pool ends');
        require(totalDeposits < maximumDeposit, 'Maximum deposit already reached');
        if (totalDeposits.plus(amount) > maximumDeposit) {
            amount = maximumDeposit.minus(totalDeposits);
        }
        depositToken.transferFrom(msg.sender, address(this), amount);
        totalDeposits = totalDeposits.plus(amount);

        Receipt storage receipt = receipts[++numReceipts];
        receipt.id = numReceipts;
        receipt.amountDeposited = amount;
        receipt.timeDeposited = block.timestamp;
        receipt.owner = msg.sender;

        emit DepositOccurred(numReceipts, msg.sender);
    }

    function withdraw(uint receiptId) external {
        Receipt storage receipt = receipts[receiptId];
        require(receipt.id == receiptId, 'Can only withdraw real receipts');
        require(receipt.owner == msg.sender || block.timestamp > endTime, 'Can only withdraw your own deposit');
        require(receipt.timeWithdrawn == 0, 'Can only withdraw once per receipt');
        receipt.timeWithdrawn = block.timestamp;
        uint[] memory rewards = getRewards(receiptId);
        totalDeposits = totalDeposits.minus(receipt.amountDeposited);

        for (uint i = 0; i < rewards.length; i++) {
            rewardsClaimed[i] = rewardsClaimed[i].plus(rewards[i]);
            rewardTokens[i].transfer(receipt.owner, rewards[i]);
        }
        depositToken.transfer(receipt.owner, receipt.amountDeposited);
        emit WithdrawalOccurred(receiptId, receipt.owner);
    }

    function withdrawExcessRewards() external {
        require(totalDeposits == 0, 'Cannot withdraw until all deposits are withdrawn');
        require(block.timestamp > endTime, 'Contract must reach maturity');

        for (uint i = 0; i < rewardTokens.length; i++) {
            uint rewards = rewardTokens[i].balanceOf(address(this));
            rewardTokens[i].transfer(management, rewards);
        }

        depositToken.transfer(management, depositToken.balanceOf(address(this)));
        emit ExcessRewardsWithdrawn();
    }
}