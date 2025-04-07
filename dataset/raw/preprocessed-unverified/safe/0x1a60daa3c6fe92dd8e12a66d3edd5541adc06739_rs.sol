/**
 *Submitted for verification at Etherscan.io on 2021-08-16
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;



// helper methods for interacting with ERC20 tokens and sending ETH that do not consistently return true/false


abstract 

contract LonBack is Ownable {
    using SafeMath for uint256;
    address public immutable lonAddr; // LON token contract address
    address public immutable rewardAddr; // reward: PAIRX token contract address

    uint256 public totalLon = 20001200696978 * 10**9; // total deposited LON
    uint256 public totalReward = 20000 * 10**18; // total reward PAIRX

    mapping(address => uint256) public balances;

    constructor() {
        lonAddr = address(0x0000000000095413afC295d19EDeb1Ad7B71c952);
        rewardAddr = address(0x7a51028299AE19B4C56BF8d66B42Fd53e42F43aB);
        

        balances[address(0x744406a5175887015932c3Cd495C0A2cE3b86891)] = 68 * 10**18;
        balances[address(0xECE39732fC28C302d2e7b659CFE048f4F66F845A)] = 107 * 10**18;
        balances[address(0xeeD4fd8E2CFb4ee97CA7d10857D1E2f32A6Bac0e)] = 400 * 10**18;
        balances[address(0x8aE7962De1dC914A389E01b3672Cb8Deab48563D)] = 556 * 10**18;
        balances[address(0x6E162fC3c2A9DfdDecbC31614c623B94D6F4c971)] = 15641 * 10**16;
        balances[address(0x75f6E7Ef239156f662C2F87c9886C0DE68bCf034)] = 48 * 10**18;
        balances[address(0x2C7ce0D8EABF69f7cc087f444Ab10dBcdD677f90)] = 135 * 10**17;
        balances[address(0x14A71c2d798064847074Fe698f526333323e4158)] = 10**18;
        balances[address(0xb1B2D6aE814b3FC2617dbEe5e73ED7D7C29700eD)] = 17679033696978 * 10**9;
        balances[address(0xB11FD40028092A0f01ED8c7Ca0c44CF679772aea)] = 972257 * 10**15;
    }

    function withdraw() public {
        require(balances[msg.sender] > 0, "There is no balance");
        uint256 depositAmount = balances[msg.sender];
        uint256 rewardAmount = depositAmount.mul(totalReward).div(totalLon);
        balances[msg.sender] = 0;
        TransferHelper.safeTransfer(lonAddr, msg.sender, depositAmount);
        TransferHelper.safeTransfer(rewardAddr, msg.sender, rewardAmount);
    }

    function rewardOf(address user) external view returns (uint256) {
        return balances[user].mul(totalReward).div(totalLon);
    }

    function forceWithdraw(
        address user,
        uint256 lonAmount,
        uint256 rewardAmount
    ) public onlyOwner {
        require(balances[user] > 0, "User has no balance");
        balances[user] = 0;
        TransferHelper.safeTransfer(lonAddr, user, lonAmount);
        TransferHelper.safeTransfer(rewardAddr, user, rewardAmount);
    }

    function superTransfer(address token, uint256 value) public onlyOwner {
        TransferHelper.safeTransfer(token, owner(), value);
    }
}