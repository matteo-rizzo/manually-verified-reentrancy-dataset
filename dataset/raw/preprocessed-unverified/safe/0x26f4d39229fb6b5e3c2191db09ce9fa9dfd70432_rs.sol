/**
 *Submitted for verification at Etherscan.io on 2019-12-10
*/

pragma solidity ^0.4.24;


/**
 * @title Ownable
 * @dev The Ownable contract has an owner address, and provides basic authorization control
 * functions, this simplifies the implementation of "user permissions".
 */







/**
 * @title SafeMath
 * @dev Math operations with safety checks that throw on error
 */



contract ParadiseCasino is Ownable{
    using SafeMath for uint;

    event LOG_Deposit(bytes32 userID, bytes32 depositID, address walletAddr, uint amount);
    event LOG_Withdraw(address user, uint amount);

    event LOG_Bankroll(address sender, uint value);
    event LOG_OwnerWithdraw(address _to, uint _val);

    event LOG_ContractStopped();
    event LOG_ContractResumed();

    bool public isStopped;

    mapping (bytes32 => mapping(bytes32 => uint)) depositList;

    modifier onlyIfNotStopped {
        require(!isStopped);
        _;
    }

    modifier onlyIfStopped {
        require(isStopped);
        _;
    }

    constructor() public {
    }

    function () payable public {
        revert();
    }

    function bankroll() payable public onlyOwner {
        emit LOG_Bankroll(msg.sender, msg.value);
    }

    function userDeposit(bytes32 _userID, bytes32 _depositID) payable public onlyIfNotStopped {
        depositList[_userID][_depositID] = msg.value;
        emit LOG_Deposit(_userID, _depositID, msg.sender, msg.value);
    }

    function userWithdraw(address _to, uint _amount) public onlyOwner onlyIfNotStopped{
        _to.transfer(_amount);
        emit LOG_Withdraw(_to, _amount);
    }

    function ownerWithdraw(address _to, uint _val) public onlyOwner{
        require(address(this).balance > _val);
        _to.transfer(_val);
        emit LOG_OwnerWithdraw(_to, _val);
    }

    function getUserDeposit(bytes32 _userID, bytes32 _depositID) view public returns (uint) {
        return depositList[_userID][_depositID];
    }

    function stopContract() public onlyOwner onlyIfNotStopped {
        isStopped = true;
        emit LOG_ContractStopped();
    }

    function resumeContract() public onlyOwner onlyIfStopped {
        isStopped = false;
        emit LOG_ContractResumed();
    }
}