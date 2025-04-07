/**
 *Submitted for verification at Etherscan.io on 2019-10-08
*/

pragma solidity ^0.5.6;





contract IOperationalWallet2 {
    function setTrustedToggler(address _trustedToggler) external;
    function toggleTrustedWithdrawer(address _withdrawer, bool isEnabled) external;
    function withdrawCoin(address coin, address to, uint256 amount) external returns (bool);
}



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

contract IBookingFactory {

    function createBooking(uint128 _bookingId, uint32 _dateFrom, uint32 _dateTo, uint256 _guestAmount,
        uint256 _price, uint256 _cleaning, uint256 _deposit, IBooking.CancellationPolicy _cancellationPolicy,
        address _guest, address _host, address _guestCoin, address _hostCoin)
    public payable returns (address);

    function toggleCoin(address coinAddress, bool enable) public;

    function setFeeBeneficiary(address _feeBeneficiary) public;
    function setOperationalWallet1(address payable _operationalWallet1) public;
    function setOperationalWallet2(address _operationalWallet2) public;

    function addArbiter(address _arbiter) public;
    function removeArbiter(address _arbiter) public;
    function setBookingArbiter(address _arbiter, address _booking) public;
}



contract Booking is IBooking {

    using BookingLib for BookingLib.Booking;

    BookingLib.Booking booking;

    event StatusChanged (
        IBooking.Status indexed from,
        IBooking.Status indexed to
    );

    modifier onlyFactory {
        require(msg.sender == booking.factory);
        _;
    }

    modifier onlyGuest {
        require(msg.sender == booking.guest);
        _;
    }

    modifier onlyHost {
        require(msg.sender == booking.host);
        _;
    }

    modifier onlyFeeBeneficiary {
        require(msg.sender == booking.feeBeneficiary);
        _;
    }

    modifier onlyParticipant {
        require(msg.sender == booking.guest || msg.sender == booking.host || msg.sender == booking.feeBeneficiary);
        _;
    }

    modifier onlyArbiter {
        require(msg.sender == booking.arbiter);
        _;
    }

    constructor(address _znglToken, uint128 _bookingId, uint32 _dateFrom, uint32 _dateTo, uint256 _guestAmount,
        uint256 _price, uint256 _cleaning, uint256 _deposit, IBooking.CancellationPolicy _cancellationPolicy,
        address _guest, address _host, address _feeBeneficiary, address _defaultArbiter
    ) public {
        require(_dateFrom < _dateTo);
        require(_host != _guest);

        booking.znglToken = _znglToken;
        booking.bookingId = _bookingId;
        booking.dateFrom = _dateFrom;
        booking.dateTo = _dateTo;

        booking.guestAmount = _guestAmount;
        booking.price = _price;
        booking.cleaning = _cleaning;
        booking.deposit = _deposit;

        booking.cancellationPolicy = _cancellationPolicy;
        booking.host = _host;
        booking.guest = _guest;
        booking.feeBeneficiary = _feeBeneficiary;
        booking.arbiter = _defaultArbiter;

        booking.factory = msg.sender;

        booking.status = IBooking.Status.Booked;

        booking.guestFundsWithdriven = false;
        booking.hostFundsWithdriven = false;

        booking.guestWithdrawAllowance = _deposit;
        booking.hostWithdrawAllowance = _price + _cleaning;
    }

    function setAdditionalInfo(address _operationalWallet2, address _withdrawalOracle,
        address _guestCoin, address _hostCoin)
    external onlyFactory {
        booking.operationalWallet2 = _operationalWallet2;
        booking.withdrawalOracle = _withdrawalOracle;
        booking.guestCoin = _guestCoin;
        booking.hostCoin = _hostCoin;
    }

    function calculateCancel() external view onlyParticipant returns(bool, uint, uint, uint) {
        return booking.calculateCancel();
    }

    function cancel() external onlyParticipant {
        booking.cancel();
    }

    function setArbiter(address _arbiter) external {
        booking.setArbiter(_arbiter);
    }

    function submitToArbitration(int _ticket) external onlyParticipant {
        booking.submitToArbitration(_ticket);
    }

    function arbitrate(uint depositToHostPpm, uint cleaningToHostPpm, uint priceToHostPpm, bool useCancellationPolicy)
    external onlyArbiter {
        booking.arbitrate(depositToHostPpm, cleaningToHostPpm, priceToHostPpm, useCancellationPolicy);
    }

    function bookingId() external view returns (uint128) {
        return booking.bookingId;
    }

    function dateFrom() external view returns (uint32) {
        return booking.dateFrom;
    }

    function dateTo() external view returns (uint32) {
        return booking.dateTo;
    }

    function dateCancel() external view returns (uint32) {
        return booking.dateCancel;
    }

    function host() external view returns (address) {
        return booking.host;
    }

    function guest() external view returns (address) {
        return booking.guest;
    }

    function cancellationPolicy() external view returns (IBooking.CancellationPolicy) {
        return booking.cancellationPolicy;
    }

    function guestCoin() external view returns (address) {
        return booking.guestCoin;
    }

    function hostCoin() external view returns (address) {
        return booking.hostCoin;
    }

    function withdrawalOracle() external view returns (address) {
        return booking.withdrawalOracle;
    }

    function price() external view returns (uint256) {
        return booking.price;
    }

    function cleaning() external view returns (uint256) {
        return booking.cleaning;
    }

    function deposit() external view returns (uint256) {
        return booking.deposit;
    }

    function guestAmount() external view returns (uint256) {
        return booking.guestAmount;
    }

    function feeBeneficiary() external view returns (address) {
        return booking.feeBeneficiary;
    }

    function ticket() external view returns(int) {
        return booking.ticket;
    }

    function arbiter() external view returns(address) {
        return booking.arbiter;
    }

    function balance() external view returns (uint) {
        return address(this).balance;
    }

    function balanceToken(address _token) external view returns (uint) {
        return IERC20(_token).balanceOf(address(this));
    }

    function status() external view returns (IBooking.Status) {
        return booking.getStatus();
    }

    function calculateHostWithdraw() onlyHost external view
    returns (bool isPossible, uint zangllTokenAmountToPut, uint hostPart) {
        return booking.calculateHostWithdraw();
    }

    function hostWithdraw() external {
        require(msg.sender == booking.host || msg.sender == booking.znglToken);
        booking.hostWithdraw();
    }

    function calculateGuestWithdraw() onlyGuest external view
    returns (bool isPossible, uint guestPart) {
        return booking.calculateGuestWithdraw();
    }

    function guestWithdraw() external onlyGuest {
        booking.guestWithdraw();
    }
}

contract BookingFactory is Ownable, IBookingFactory {

    event BookingCreated (
        address indexed bookingContractAddress,
        uint128 indexed bookingId
    );

    // coins -------------------------------------------------------------------------------------------------
    mapping(address => bool) public enabledCoins;
    function toggleCoin(address coinAddress, bool enable) public onlyOwner {
        enabledCoins[coinAddress] = enable;
    }
    //--------------------------------------------------------------------------------------------------------

    address public znglToken;
    address payable public operationalWallet1; // funds receiver
    address public operationalWallet2; // funds storage to withdraw when booking is ready to pay
    address public withdrawalOracle;

    mapping(uint128 => bool) private bookingIds;
    mapping(address => bool) private arbiters;
    address public feeBeneficiary;

    constructor(address _znglToken, address _withdrawalOracle, address payable _operationalWallet1, address _operationalWallet2)
    public {
        feeBeneficiary = owner();
        znglToken = _znglToken;
        withdrawalOracle = _withdrawalOracle;
        operationalWallet1 = _operationalWallet1;
        operationalWallet2 = _operationalWallet2;
    }

    function createBooking(uint128 _bookingId, uint32 _dateFrom, uint32 _dateTo, uint256 _guestAmount,
        uint256 _price, uint256 _cleaning, uint256 _deposit, IBooking.CancellationPolicy _cancellationPolicy,
        address _guest, address _host, address _guestCoin, address _hostCoin)
    public payable returns (address) {
        require(msg.value > 0 || enabledCoins[_guestCoin]);
        require(enabledCoins[_hostCoin]);
        require(!bookingIds[_bookingId]);
        bookingIds[_bookingId] = true;

        Booking booking = new Booking(znglToken, _bookingId, _dateFrom, _dateTo, _guestAmount,
            _price, _cleaning, _deposit, _cancellationPolicy,
            _guest, _host, feeBeneficiary, owner());
        emit BookingCreated(address(booking), _bookingId);

        if (msg.value > 0) {
            booking.setAdditionalInfo(operationalWallet2, withdrawalOracle, 0x0000000000000000000000000000000000000000, _hostCoin);
            operationalWallet1.transfer(_guestAmount);
            if (address(this).balance > 0) {
                msg.sender.transfer(address(this).balance);
            }
        } else {
            booking.setAdditionalInfo(operationalWallet2, withdrawalOracle, _guestCoin, _hostCoin);
            IERC20(_guestCoin).transferFrom(_guest, operationalWallet1, _guestAmount);
        }

        IOperationalWallet2(operationalWallet2).toggleTrustedWithdrawer(address(booking), true);

        return address(booking);
    }

    function setFeeBeneficiary(address _feeBeneficiary) public onlyOwner {
        feeBeneficiary = _feeBeneficiary;
    }

    function setOperationalWallet1(address payable _operationalWallet1) public onlyOwner {
        operationalWallet1 = _operationalWallet1;
    }

    function setOperationalWallet2(address _operationalWallet2) public onlyOwner {
        operationalWallet2 = _operationalWallet2;
    }

    function addArbiter(address _arbiter) public {
        require (isOwner() || arbiters[msg.sender]);
        arbiters[_arbiter] = true;
    }

    function removeArbiter(address _arbiter) public {
        require (isOwner() || arbiters[msg.sender]);
        arbiters[_arbiter] = false;
    }

    function setBookingArbiter(address _arbiter, address _booking) public onlyOwner {
        require(arbiters[_arbiter], "Arbiter should be added to arbiter list first");
        Booking booking = Booking(_booking);
        booking.setArbiter(_arbiter);
    }
}