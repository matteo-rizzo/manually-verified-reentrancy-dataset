/**
 *Submitted for verification at Etherscan.io on 2021-03-30
*/

// SPDX-License-Identifier: GPL-3.0-only

pragma solidity 0.7.4;




/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
 */


contract UniformTimeVault {
    using SafeMathLib for uint;

    IERC20 public token;
    uint public numTranches = 0;
    uint public startTime = 0;
    uint public endTime = 0;
    uint public vestingPeriodLength = 0;
    uint public totalAllocation = 0;

    struct Tranche {
        uint id;
        address destination;
        uint totalCoins;
        uint currentCoins;
        uint coinsPerSecond;
        uint lastWithdrawalTime;
    }

    mapping (uint => Tranche) public tranches;

    event WithdrawalOccurred(uint trancheId, uint numTokens, uint tokensLeft);
    event TrancheAdded(uint id, address destination, uint totalCoins);

    constructor(address tokenAddr, address[] memory destinations, uint[] memory tokenAllocations, uint _endTime, uint _startTime) {
        token = IERC20(tokenAddr);
        endTime = _endTime;
        startTime = _startTime;
        vestingPeriodLength = endTime - startTime;
        require(vestingPeriodLength > 0 , 'start time must be before end time');

        for (uint i = 0; i < destinations.length; i++)  {
            uint trancheId = i + 1;
            uint coinsPerSecond = tokenAllocations[i] / vestingPeriodLength;
            totalAllocation = totalAllocation.plus(tokenAllocations[i]);
            tranches[trancheId] = Tranche(
                trancheId,
                destinations[i],
                tokenAllocations[i],
                tokenAllocations[i],
                coinsPerSecond,
                _startTime
            );
            emit TrancheAdded(trancheId, destinations[i], tokenAllocations[i]);
        }
        numTranches = destinations.length;
    }

    function withdraw(uint trancheId) external {
        Tranche storage tranche = tranches[trancheId];
        require(tranche.currentCoins >  0, 'No coins left to withdraw');
        uint currentWithdrawal = 0;

        // if after vesting period ends, give them the remaining coins
        if (block.timestamp >= endTime) {
            currentWithdrawal = tranche.currentCoins;
        } else {
            // compute allowed withdrawal
            currentWithdrawal = (block.timestamp.minus(tranche.lastWithdrawalTime)).times(tranche.coinsPerSecond);
        }

        // update struct
        tranche.currentCoins = tranche.currentCoins.minus(currentWithdrawal);
        tranche.lastWithdrawalTime = block.timestamp;

        // transfer the tokens, brah
        token.transfer(tranche.destination, currentWithdrawal);
        emit WithdrawalOccurred(trancheId, currentWithdrawal, tranche.currentCoins);
    }

    function changeDestination(uint trancheId, address newDestination) external {
        Tranche storage tranche = tranches[trancheId];
        require(tranche.destination == msg.sender, 'Can only change destination if you are the destination');
        tranche.destination = newDestination;
    }
}