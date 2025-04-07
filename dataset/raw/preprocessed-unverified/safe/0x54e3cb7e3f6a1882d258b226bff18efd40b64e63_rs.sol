// contracts/OffshiftVesting.sol
// SPDX-License-Identifier: MIT
pragma solidity ^0.6.0;

/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
 */


contract TimeLock {
    IERC20 token;

    struct LockBoxStruct {
        address beneficiary;
        uint balance;
        uint releaseTime;
    }

    LockBoxStruct[] public lockBoxStructs; // This could be a mapping by address, but these numbered lockBoxes support possibility of multiple tranches per address

    event LogLockBoxDeposit(address sender, uint amount, uint releaseTime);
    event LogLockBoxWithdrawal(address receiver, uint amount);

    constructor(address tokenContract) public {
        token = IERC20(tokenContract);
    }

    function deposit(address beneficiary, uint totalAmount, uint trenchAmount, uint firstRelease, uint releaseStride) public returns(bool success) {
        require(token.transferFrom(msg.sender, address(this), totalAmount));
        LockBoxStruct memory l;
        l.beneficiary = beneficiary;
        l.balance = trenchAmount;
        l.releaseTime = firstRelease;
        lockBoxStructs.push(l);
        for (uint i = 1; i < 60; ++i) {
            uint time = firstRelease + (releaseStride * i);
            l.releaseTime = time;
            lockBoxStructs.push(l);
            emit LogLockBoxDeposit(msg.sender, trenchAmount, time);
        }
        return true;
    }

    function withdraw(uint lockBoxNumber) public returns(bool success) {
        LockBoxStruct storage l = lockBoxStructs[lockBoxNumber];
        require(l.beneficiary == msg.sender);
        require(l.releaseTime <= now);
        uint amount = l.balance;
        l.balance = 0;
        emit LogLockBoxWithdrawal(msg.sender, amount);
        require(token.transfer(msg.sender, amount));
        return true;
    }

}