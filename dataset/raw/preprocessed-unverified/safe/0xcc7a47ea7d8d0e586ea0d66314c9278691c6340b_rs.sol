/**
 *Submitted for verification at Etherscan.io on 2021-05-07
*/

// SPDX-License-Identifier: agpl-3.0
pragma solidity ^0.6.12;



contract LevTreasuryVester {
    using SafeMath for uint256;

    address public lev;
    mapping(address => TreasuryVester) public _Treasury;

    struct TreasuryVester {
        uint256 vestingAmount;
        uint256 vestingBegin;
        uint256 vestingFirst;
        uint256 vestingShare;
        uint256 nextTime;
        uint256 vestingCycle;
    }

    constructor(address _lev) public {
        lev = _lev;
    }

    function creatTreasury(
        address recipient_,
        uint256 vestingAmount_,
        uint256 vestingFirst_,
        uint256 vestingShare_,
        uint256 vestingBegin_,
        uint256 vestingCycle_
    ) external {
        require(
            vestingBegin_ >= block.timestamp,
            "TreasuryVester::creat: vesting begin too early"
        );
        require(
            vestingCycle_ >= 24 * 3600 * 30,
            "TreasuryVester::creat: vesting cycle too small"
        );
        TreasuryVester storage treasury = _Treasury[recipient_];
        require(
            treasury.vestingAmount == 0,
            "TreasuryVester::creat: recipient already exists"
        );
        treasury.vestingAmount = vestingAmount_;
        treasury.vestingBegin = vestingBegin_;
        treasury.vestingFirst = vestingFirst_;
        treasury.vestingShare = vestingShare_;
        treasury.nextTime = vestingBegin_;
        treasury.vestingCycle = vestingCycle_;

        ILev(lev).transferFrom(msg.sender, address(this), vestingAmount_);
    }

    function setRecipient(address recipient_) external {
        TreasuryVester storage treasury = _Treasury[msg.sender];
        TreasuryVester storage treasury2 = _Treasury[recipient_];
        require(
            treasury.vestingAmount > 0,
            "TreasuryVester::setRecipient: unauthorized"
        );
        require(
            treasury2.vestingAmount == 0,
            "TreasuryVester::setRecipient: recipient already exists"
        );
        treasury2 = treasury;
        treasury.vestingAmount = 0;
    }

    function claim() external {
        TreasuryVester storage treasury = _Treasury[msg.sender];
        require(
            treasury.vestingAmount > 0,
            "TreasuryVester::claim: not sufficient funds"
        );
        require(
            block.timestamp >= treasury.nextTime,
            "TreasuryVester::claim: not time yet"
        );
        uint256 amount;
        if (treasury.nextTime == treasury.vestingBegin) {
            amount = treasury.vestingFirst;
        } else {
            amount = treasury.vestingShare;
        }
        if (ILev(lev).balanceOf(address(this)) < amount) {
            amount = ILev(lev).balanceOf(address(this));
        }
        if (treasury.vestingAmount < amount) {
            amount = treasury.vestingAmount;
        }
        treasury.nextTime = treasury.nextTime.add(treasury.vestingCycle);
        treasury.vestingAmount = treasury.vestingAmount.sub(amount);
        ILev(lev).transfer(msg.sender, amount);
    }
}

