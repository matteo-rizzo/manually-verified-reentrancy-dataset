/**
 *Submitted for verification at Etherscan.io on 2021-06-09
*/

// Sources flattened with hardhat v2.3.0 https://hardhat.org

// File @openzeppelin/contracts/math/[emailÂ protected]

// SPDX-License-Identifier: MIT

pragma solidity ^0.7.0;
pragma experimental ABIEncoderV2;


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



// File contracts/InstaVestingResolver.sol







contract InstaTokenVestingResolver  {
    using SafeMath for uint256;

    TokenInterface public constant token = TokenInterface(0x6f40d4A6237C257fff2dB00FA0510DeEECd303eb);
    // InstaVestingFactoryInterface public constant factory = InstaVestingFactoryInterface(0x3730D9b06bc23fd2E2F84f1202a7e80815dd054a);
    InstaVestingFactoryInterface public immutable factory;

    constructor(address factory_) {
        factory = InstaVestingFactoryInterface(factory_);
    }
    struct VestingData {
        address recipient;
        address vesting;
        address owner;
        uint256 vestingAmount;
        uint256 vestingBegin;
        uint256 vestingCliff;
        uint256 vestingEnd;
        uint256 lastClaimed;
        uint256 terminatedTime;
        uint256 vestedAmount;
        uint256 unvestedAmount;
        uint256 claimedAmount;
        uint256 claimableAmount;
    }

    function getVestingByRecipient(address recipient) external view returns(VestingData memory vestingData) {
        address vestingAddr = factory.recipients(recipient);
        return getVesting(vestingAddr);
    }

    function getVesting(address vesting) public view returns(VestingData memory vestingData) {
        if (vesting == address(0)) return vestingData;
        InstaVestingInferface VestingContract = InstaVestingInferface(vesting);
        uint256 vestingBegin = uint256(VestingContract.vestingBegin());
        uint256 vestingEnd = uint256(VestingContract.vestingEnd());
        uint256 vestingCliff = uint256(VestingContract.vestingCliff());
        uint256 vestingAmount = VestingContract.vestingAmount();
        uint256 lastUpdate = uint256(VestingContract.lastUpdate());
        uint256 terminatedTime = uint256(VestingContract.terminateTime());

        
        uint256 claimedAmount;
        uint256 claimableAmount;
        uint256 vestedAmount;
        uint256 unvestedAmount;
        if (block.timestamp > vestingCliff) {
            uint256 time = terminatedTime == 0 ? block.timestamp : terminatedTime;
            vestedAmount = vestingAmount.mul(time - vestingBegin).div(vestingEnd - vestingBegin);
            unvestedAmount = vestingAmount.sub(vestedAmount);
            claimableAmount = vestingAmount.mul(time - lastUpdate).div(vestingEnd - vestingBegin);
            claimedAmount = vestedAmount.mul(time - vestingBegin).div(vestingEnd - vestingBegin);
        }

        vestingData = VestingData({
            recipient: VestingContract.recipient(),
            owner: VestingContract.owner(),
            vesting: vesting,
            vestingAmount: vestingAmount,
            vestingBegin: vestingBegin,
            vestingCliff: vestingCliff,
            vestingEnd: vestingEnd,
            lastClaimed: lastUpdate,
            terminatedTime: terminatedTime,
            vestedAmount: vestedAmount,
            unvestedAmount: unvestedAmount,
            claimedAmount: claimedAmount,
            claimableAmount: claimableAmount
        });
    }

}