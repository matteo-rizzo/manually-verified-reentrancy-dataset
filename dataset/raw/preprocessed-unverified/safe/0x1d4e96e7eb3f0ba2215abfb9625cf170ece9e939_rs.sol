pragma solidity 0.4.24;

// File: node_modules/@tokenfoundry/sale-contracts/contracts/interfaces/VaultI.sol



// File: openzeppelin-solidity/contracts/math/Math.sol

/**
 * @title Math
 * @dev Assorted math operations
 */


// File: openzeppelin-solidity/contracts/math/SafeMath.sol

/**
 * @title SafeMath
 * @dev Math operations with safety checks that throw on error
 */


// File: openzeppelin-solidity/contracts/ownership/Ownable.sol

/**
 * @title Ownable
 * @dev The Ownable contract has an owner address, and provides basic authorization control
 * functions, this simplifies the implementation of "user permissions".
 */


// File: node_modules/@tokenfoundry/sale-contracts/contracts/Vault.sol

// Adapted from Open Zeppelin's RefundVault

/**
 * @title Vault
 * @dev This contract is used for storing funds while a crowdsale
 * is in progress. Supports refunding the money if crowdsale fails,
 * and forwarding it if crowdsale is successful.
 */
contract Vault is VaultI, Ownable {
    using SafeMath for uint256;

    enum State { Active, Success, Refunding, Closed }

    // The timestamp of the first deposit
    uint256 public firstDepositTimestamp; 

    mapping (address => uint256) public deposited;

    // The amount to be disbursed to the wallet every month
    uint256 public disbursementWei;
    uint256 public disbursementDuration;

    // Wallet from the project team
    address public trustedWallet;

    // The eth amount the team will get initially if the sale is successful
    uint256 public initialWei;

    // Timestamp that has to pass before sending funds to the wallet
    uint256 public nextDisbursement;
    
    // Total amount that was deposited
    uint256 public totalDeposited;

    // Amount that can be refunded
    uint256 public refundable;

    State public state;

    event Closed();
    event RefundsEnabled();
    event Refunded(address indexed contributor, uint256 amount);

    modifier atState(State _state) {
        require(state == _state);
        _;
    }

    constructor (
        address _wallet,
        uint256 _initialWei,
        uint256 _disbursementWei,
        uint256 _disbursementDuration
    ) 
        public 
    {
        require(_wallet != address(0));
        require(_disbursementWei != 0);
        trustedWallet = _wallet;
        initialWei = _initialWei;
        disbursementWei = _disbursementWei;
        disbursementDuration = _disbursementDuration;
        state = State.Active;
    }

    /// @dev Called by the sale contract to deposit ether for a contributor.
    function deposit(address _contributor) onlyOwner external payable {
        require(state == State.Active || state == State.Success);
        if (firstDepositTimestamp == 0) {
            firstDepositTimestamp = now;
        }
        totalDeposited = totalDeposited.add(msg.value);
        deposited[_contributor] = deposited[_contributor].add(msg.value);
    }

    /// @dev Sends initial funds to the wallet.
    function saleSuccessful()
        onlyOwner 
        external 
        atState(State.Active)
    {
        state = State.Success;
        transferToWallet(initialWei);
    }

    /// @dev Called by the owner if the project didn't deliver the testnet contracts or if we need to stop disbursements for any reasone.
    function enableRefunds() onlyOwner external {
        require(state != State.Refunding);
        state = State.Refunding;
        uint256 currentBalance = address(this).balance;
        refundable = currentBalance <= totalDeposited ? currentBalance : totalDeposited;
        emit RefundsEnabled();
    }

    /// @dev Refunds ether to the contributors if in the Refunding state.
    function refund(address _contributor) external atState(State.Refunding) {
        require(deposited[_contributor] > 0);
        uint256 refundAmount = deposited[_contributor].mul(refundable).div(totalDeposited);
        deposited[_contributor] = 0;
        _contributor.transfer(refundAmount);
        emit Refunded(_contributor, refundAmount);
    }

    /// @dev Called by the owner if the sale has ended.
    function close() external atState(State.Success) onlyOwner {
        state = State.Closed;
        nextDisbursement = now;
        emit Closed();
    }

    /// @dev Sends the disbursement amount to the wallet after the disbursement period has passed. Can be called by anyone.
    function sendFundsToWallet() external atState(State.Closed) {
        require(nextDisbursement <= now);

        if (disbursementDuration == 0) {
            trustedWallet.transfer(address(this).balance);
            return;
        }

        uint256 numberOfDisbursements = now.sub(nextDisbursement).div(disbursementDuration).add(1);

        nextDisbursement = nextDisbursement.add(disbursementDuration.mul(numberOfDisbursements));

        transferToWallet(disbursementWei.mul(numberOfDisbursements));
    }

    function transferToWallet(uint256 _amount) internal {
        uint256 amountToSend = Math.min256(_amount, address(this).balance);
        trustedWallet.transfer(amountToSend);
    }
}