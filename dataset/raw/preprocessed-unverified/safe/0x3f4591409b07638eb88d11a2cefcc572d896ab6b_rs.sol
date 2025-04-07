/**
 *Submitted for verification at Etherscan.io on 2021-03-25
*/

// Dependency file: contracts/interfaces/IERC20.sol

// pragma solidity ^0.6.12;




// Dependency file: contracts/Ownable.sol

// pragma solidity ^0.6.12;

/**
 * @dev Contract module which provides a basic access control mechanism, where
 * there is an account (an owner) that can be granted exclusive access to
 * specific functions.
 *
 * By default, the owner account will be the one that deploys the contract. This
 * can later be changed with {transferOwnership}.
 *
 * This module is used through inheritance. It will make available the modifier
 * `onlyOwner`, which can be applied to your functions to restrict their use to
 * the owner.
 */


// Root file: contracts/governance/PropolsalRewarder.sol

// SPDX-License-Identifier: GPL-3.0-or-later

// import 'contracts/interfaces/IERC20.sol';
// import 'contracts/Ownable.sol';

pragma experimental ABIEncoderV2;

pragma solidity ^0.6.12;

contract PropolsalRewarder is Ownable {
    address public rewardToken;
    address public governance;
    uint256 public idTreshold;

    uint256 public reward;
    mapping(uint256 => bool) public rewardedPropolsals;

    constructor(address _governance, address _rewardToken, uint256 _reward, uint256 _idTreshold) public {
        rewardToken = _rewardToken;
        governance = _governance;
        reward = _reward;
        idTreshold = _idTreshold;
    }

    function setReward(uint256 _newReward) external onlyOwner {
        reward = _newReward;
    }

    function setGovernance(address _newGovernance) external onlyOwner {
        governance = _newGovernance;
    }


    function withdrawLeftovers(address _to) external onlyOwner {
        IERC20(rewardToken).transfer(_to, IERC20(rewardToken).balanceOf(address(this)));
    }


    function getPropolsalReward(uint256 pid) external returns (bool) {
        require(pid > idTreshold, "This propolsal was created too early to be rewarded.");
        require(!rewardedPropolsals[pid], "This propolsal has been already rewarded.");
        rewardedPropolsals[pid] = true;

        bytes memory payload = abi.encodeWithSignature("proposals(uint256)", pid);
        (bool success, bytes memory returnData) = address(governance).call(payload);
        require(success, "Failed to get propolsal.");

        address proposer;
        bool executed;
        assembly {
            proposer := mload(add(returnData, add(0x20, 0x20)))
            executed := mload(add(returnData, add(0x20, 0x100)))
        }
        require(proposer == msg.sender, "Only proposer can achive reward.");
        require(executed, "Only executed porposers achive reward.");
        
        IERC20(rewardToken).transfer(msg.sender, reward);
    }

    receive() payable external {
        revert("Do not accept ether.");
    }
}