/**

 *Submitted for verification at Etherscan.io on 2019-06-13

*/



pragma solidity ^0.4.24;



/**

 * @title ERC20 interface

 * @dev see https://github.com/ethereum/EIPs/issues/20

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



    constructor(address tokenContract) public payable {

        token = IERC20(tokenContract);

    }



    function deposit(address beneficiary, uint amount, uint releaseTime) public returns(bool success) {

        require(token.transferFrom(msg.sender, address(this), amount));

        LockBoxStruct memory l;

        l.beneficiary = beneficiary;

        l.balance = amount;

        l.releaseTime = releaseTime;

        lockBoxStructs.push(l);

        emit LogLockBoxDeposit(msg.sender, amount, releaseTime);

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