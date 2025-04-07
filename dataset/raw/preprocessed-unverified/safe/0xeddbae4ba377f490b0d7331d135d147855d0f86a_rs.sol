/**
 *Submitted for verification at Etherscan.io on 2019-06-27
*/

pragma solidity ^0.5.7;

















contract AffiliateEscrow {
    using SafeMath for uint256;

    Storage data;
    Logger eventLogger;

    mapping(address => uint256) private payments;

    constructor(address storageAddress, address eventLoggerContract) public {
        data = Storage(storageAddress);
        eventLogger = Logger(eventLoggerContract);
    }

    modifier onlyNetworkContracts {
        if (data.allowOnlyDappContracts(msg.sender)) {
            _;
        } else {
            revert("Not allowed");
        }
    }

    function deposit(address affiliate) external payable onlyNetworkContracts {
        require (msg.value > 0, "Not a valid deposit");
        uint256 amount = msg.value;
        payments[affiliate] = payments[affiliate].add(amount);
        eventLogger.emitAffiliateDeposit(affiliate, amount);
    }

    function getAffiliatePayment(address affiliate) external view returns (uint256) {
        return payments[affiliate];
    }

    function withdraw(address payable to)
        external
        onlyNetworkContracts
    {
        uint256 amount = payments[to];
        payments[to] = 0;
        require(amount > 0, "No funds");
        to.transfer(amount);
        eventLogger.emitAffiliateWithdraw(to, amount);
    }
}