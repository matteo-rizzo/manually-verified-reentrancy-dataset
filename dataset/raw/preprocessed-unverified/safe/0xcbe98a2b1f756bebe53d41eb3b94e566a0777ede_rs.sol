pragma solidity ^0.4.15;




/**
 * @title Ownable
 * @dev The Ownable contract has an owner address, and provides basic authorization control
 * functions, this simplifies the implementation of "user permissions".
 */


/**
 * @title RefundVault.
 * @dev This contract is used for storing funds while a crowdsale
 * is in progress. Supports refunding the money if crowdsale fails,
 * and forwarding it if crowdsale is successful.
 */
contract IRBPreRefundVault is Ownable {
    using SafeMath for uint256;

    enum State {Active, Refunding, Closed}
    State public state;

    mapping (address => uint256) public deposited;

    uint256 public totalDeposited;

    address public constant wallet = 0x26dB9eF39Bbfe437f5b384c3913E807e5633E7cE;

    address preCrowdsaleContractAddress;

    event Closed();

    event RefundsEnabled();

    event Refunded(address indexed beneficiary, uint256 weiAmount);

    event Withdrawal(address indexed receiver, uint256 weiAmount);

    function IRBPreRefundVault() {
        state = State.Active;
    }

    modifier onlyCrowdsaleContract() {
        require(msg.sender == preCrowdsaleContractAddress);
        _;
    }

    function setPreCrowdsaleAddress(address _preCrowdsaleAddress) external onlyOwner {
        require(_preCrowdsaleAddress != address(0));
        preCrowdsaleContractAddress = _preCrowdsaleAddress;
    }

    function deposit(address investor) onlyCrowdsaleContract external payable {
        require(state == State.Active);
        uint256 amount = msg.value;
        deposited[investor] = deposited[investor].add(amount);
        totalDeposited = totalDeposited.add(amount);
    }

    function close() onlyCrowdsaleContract external {
        require(state == State.Active);
        state = State.Closed;
        totalDeposited = 0;
        Closed();
        wallet.transfer(this.balance);
    }

    function enableRefunds() onlyCrowdsaleContract external {
        require(state == State.Active);
        state = State.Refunding;
        RefundsEnabled();
    }

    function refund(address investor) public {
        require(state == State.Refunding);
        uint256 depositedValue = deposited[investor];
        deposited[investor] = 0;
        investor.transfer(depositedValue);
        Refunded(investor, depositedValue);
    }

    /**
     * @dev withdraw method that can be used by crowdsale contract&#39;s owner
     *      for the withdrawal funds to the owner
     */
    function withdraw(uint value) onlyCrowdsaleContract external returns (bool success) {
        require(state == State.Active);
        require(totalDeposited >= value);
        totalDeposited = totalDeposited.sub(value);
        wallet.transfer(value);
        Withdrawal(wallet, value);
        return true;
    }

    /**
     * @dev killer method that can be used by owner to
     *      kill the contract and send funds to owner
     */
    function kill() onlyOwner {
        require(state == State.Closed);
        selfdestruct(owner);
    }
}