/**
 *Submitted for verification at Etherscan.io on 2019-10-08
*/

pragma solidity ^0.5.6;

contract IBooking {

    enum Status {
        New, Requested, Confirmed, Rejected, Canceled, Booked, Started,
        Finished, Arbitration, ArbitrationFinished, ArbitrationPossible
    }
    enum CancellationPolicy {Soft, Flexible, Strict}


    // methods
    function calculateCancel() external view returns(bool, uint, uint, uint);
    function cancel() external;

    function setArbiter(address _arbiter) external;
    function submitToArbitration(int _ticket) external;

    function arbitrate(uint depositToHostPpm, uint cleaningToHostPpm, uint priceToHostPpm, bool useCancellationPolicy) external;

    function calculateHostWithdraw() external view returns (bool isPossible, uint zangllTokenAmountToPut, uint hostPart);
    function hostWithdraw() external;

    function calculateGuestWithdraw() external view returns (bool isPossible, uint guestPart);
    function guestWithdraw() external;

    // fields
    function bookingId() external view returns(uint128);
    function dateFrom() external view returns(uint32);
    function dateTo() external view returns(uint32);
    function dateCancel() external view returns(uint32);
    function host() external view returns(address);
    function guest() external view returns(address);
    function cancellationPolicy() external view returns (IBooking.CancellationPolicy);

    function guestCoin() external view returns(address);
    function hostCoin() external view returns(address);
    function withdrawalOracle() external view returns(address);

    function price() external view returns(uint256);
    function cleaning() external view returns(uint256);
    function deposit() external view returns(uint256);

    function guestAmount() external view returns (uint256);

    function feeBeneficiary() external view returns(address);

    function ticket() external view returns(int);

    function arbiter() external view returns(address);

    function balance() external view returns (uint);
    function balanceToken(address) external view returns (uint);
    function status() external view returns(Status);
}



contract IOperationalWallet2 {
    function setTrustedToggler(address _trustedToggler) external;
    function toggleTrustedWithdrawer(address _withdrawer, bool isEnabled) external;
    function withdrawCoin(address coin, address to, uint256 amount) external returns (bool);
}




