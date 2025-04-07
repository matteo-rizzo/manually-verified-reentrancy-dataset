/**
 *Submitted for verification at Etherscan.io on 2019-06-22
*/

pragma solidity ^0.5.9;

/**
 * @dev Interface of the ERC20 standard as defined in the EIP. Does not include
 * the optional functions; to access them see `ERC20Detailed`.
 */


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


pragma experimental ABIEncoderV2;




/**
 * @title Etherclear
 * @dev The Etherclear contract is meant to serve as a transition step for funds between a sender
 * and a recipient, where the sender can take the funds back if they cancel the payment,
 * and the recipient can only retrieve the funds in a specified amount of time, using
 * a passphrase communicated privately by the sender.
 *
 * The usage of the contract is as follows:
 *
 * 1) The sender generates a passphrase, and passes keccak256(passphrase,recipient_address) to the
 * contract, along with a hold time. This registers a payment ID (which must be unique), and
 * marks the start of the holding time window.
 * 2) The sender communicates this passphrase to the recipient over a secure channel.
 * 3) Before the holding time has passed, the recipient can send the passphrase to the contract to withdraw the funds.
 * 4) After the holding time has passed, the recipient is no longer able to withdraw the funds, regardless
 * of whether they have the passphrase or not.
 *
 * At any time, the sender can cancel the payment if they provide the payment ID, which
 * will initiate a transfer of funds back to the sender.
 * The sender is expected to cancel the payment if they have made a mistake in specifying
 * the recipient's address, the recipient does not claim the funds, or if the holding period has expired and the
 * funds need to be retrieved.
 *
 * TODO: Currently, the payment ID is a truncated version of the passphrase hash that is used to ensure knowledge of the
 * passphrase. They will be left as separate entities for now in case they need to be constructed differently.
 *
 * NOTE: the hold time functionality is not very secure for small time periods since it uses now (block.timestamp). It is meant to be an additional security measure, and should not be relied upon in the case of an
 attack. The current known tolerance is 900 seconds:
 * https://github.com/ethereum/wiki/blob/c02254611f218f43cbb07517ca8e5d00fd6d6d75/Block-Protocol-2.0.md
 *
 * Some parts are modified from https://github.com/forkdelta/smart_contract/blob/master/contracts/ForkDelta.sol
*/

/*
 * This is used as an interface to provide functionality when setting up the contract with ENS.
*/
contract ReverseRegistrar {
    function setName(string memory name) public returns (bytes32);
}

contract Etherclear {
    // TODO: think about adding a ERC223 fallback method.

    // NOTE: PaymentClosed has the same signature
    // because we want to look for payments
    // from the latest block backwards, and
    // we want to terminate the search for
    // past events as soon as possible when doing so.
    event PaymentOpened(
        uint txnId,
        uint holdTime,
        uint openTime,
        uint closeTime,
        address token,
        uint sendAmount,
        address indexed sender,
        address indexed recipient,
        bytes codeHash
    );
    event PaymentClosed(
        uint txnId,
        uint holdTime,
        uint openTime,
        uint closeTime,
        address token,
        uint sendAmount,
        address indexed sender,
        address indexed recipient,
        bytes codeHash,
        uint state
    );

    // A Payment starts in the OPEN state.
    // Once it is COMPLETED or CANCELLED, it cannot be changed further.
    enum PaymentState {OPEN, COMPLETED, CANCELLED}
    // Used when receiving signed messages to cancel or complete
    // a payment.
    enum CompletePaymentRequestType {CANCEL, RETRIEVE}

    // A Payment is created each time a sender wants to
    // send an amount to a recipient.
    struct Payment {
        // timestamps are in epoch seconds
        uint holdTime;
        uint paymentOpenTime;
        uint paymentCloseTime;
        // Token contract address, 0 is Ether.
        address token;
        uint sendAmount;
        address payable sender;
        address payable recipient;
        bytes codeHash;
        PaymentState state;
    }

    ReverseRegistrar reverseRegistrar;

    // EIP-712 code uses the examples provided at
    // https://medium.com/metamask/eip712-is-coming-what-to-expect-and-how-to-use-it-bb92fd1a7a26
    // TODO: the salt and verifyingContract still need to be changed.
    // This struct and the associated typed signature are used for both
    // cancelling and retrieving payments.
    struct CompletePaymentRequest {
        uint txnId;
        address sender;
        address recipient;
        // Passphrase doesn't matter if the request ype is CANCEL.
        string passphrase;
        // CompletePaymentRequestType
        uint requestType;
    }

    // Payments are looked up with a uint UUID generated within the contract.
    mapping(uint => Payment) openPayments;

    // This contract's owner (gives ability to set fees).
    address payable public owner;
    // The fees are represented with a percentage times 1 ether.
    // The baseFee is to cover feeless retrieval
    // The paymentFee is to cover development costs
    uint public baseFee;
    uint public paymentFee;
    // mapping of token addresses to mapping of account balances (token=0 means Ether)
    mapping(address => mapping(address => uint)) public tokens;

    // NOTE: We do not lock the cancel payment functionality, so that users
    // will still be able to withdraw funds from payments they created.
    // Failsafe to lock the create payments functionality for both ether and tokens.
    bool public createPaymentEnabled;
    // Failsafe to lock the retrieval (withdraw) functionality.
    bool public retrieveFundsEnabled;

    address constant verifyingContract = 0x1C56346CD2A2Bf3202F771f50d3D14a367B48070;
    bytes32 constant salt = 0xf2d857f4a3edcb9b78b4d503bfe733db1e3f6cdc2b7971ee739626c97e86a558;
    string private constant COMPLETE_PAYMENT_REQUEST_TYPE = "CompletePaymentRequest(uint256 txnId,address sender,address recipient,string passphrase,uint256 requestType)";
    string private constant EIP712_DOMAIN_TYPE = "EIP712Domain(string name,string version,uint256 chainId,address verifyingContract,bytes32 salt)";
    bytes32 private constant EIP712_DOMAIN_TYPEHASH = keccak256(
        abi.encodePacked(EIP712_DOMAIN_TYPE)
    );
    bytes32 private constant COMPLETE_PAYMENT_REQUEST_TYPEHASH = keccak256(
        abi.encodePacked(COMPLETE_PAYMENT_REQUEST_TYPE)
    );
    bytes32 private DOMAIN_SEPARATOR;
    // The chainId is public because it differs between
    // contract instances
    uint256 public chainId;

    function hashCompletePaymentRequest(CompletePaymentRequest memory request)
        private
        view
        returns (bytes32 hash)
    {
        return keccak256(
            abi.encodePacked(
                "\x19\x01",
                DOMAIN_SEPARATOR,
                keccak256(
                    abi.encode(
                        COMPLETE_PAYMENT_REQUEST_TYPEHASH,
                        request.txnId,
                        request.sender,
                        request.recipient,
                        keccak256(bytes(request.passphrase)),
                        request.requestType
                    )
                )
            )
        );
    }

    // Used to test the sign and recover functionality.
    function getSignerForPaymentCompleteRequest(
        uint256 txnId,
        address sender,
        address recipient,
        string memory passphrase,
        uint requestType,
        bytes32 sigR,
        bytes32 sigS,
        uint8 sigV
    ) public view returns (address result) {
        CompletePaymentRequest memory request = CompletePaymentRequest(
            txnId,
            sender,
            recipient,
            passphrase,
            requestType
        );
        address signer = ecrecover(
            hashCompletePaymentRequest(request),
            sigV,
            sigR,
            sigS
        );
        return signer;
    }

    constructor(uint256 _chainId) public {
        owner = msg.sender;
        baseFee = 0.001 ether;
        paymentFee = 0.005 ether;
        createPaymentEnabled = true;
        retrieveFundsEnabled = true;
        chainId = _chainId;
        DOMAIN_SEPARATOR = keccak256(
            abi.encode(
                EIP712_DOMAIN_TYPEHASH,
                keccak256("Etherclear"),
                keccak256("1"),
                chainId,
                verifyingContract,
                salt
            )
        );
    }

    modifier onlyOwner {
        require(
            msg.sender == owner,
            "Only the contract owner is allowed to use this function."
        );
        _;
    }

    /*
    * SetENS sets the name of the reverse record so that it points to this contract address.
    */
    function setENS(address reverseRegistrarAddr, string memory name)
        public
        onlyOwner
    {
        reverseRegistrar = ReverseRegistrar(reverseRegistrarAddr);
        reverseRegistrar.setName(name);

    }

    function withdrawFees(address token) external onlyOwner {
        // The "owner" account is considered the fee account.
        uint total = tokens[token][owner];
        tokens[token][owner] = 0;
        if (token == address(0)) {
            owner.transfer(total);
        } else {
            require(
                IERC20(token).transfer(owner, total),
                "Could not successfully withdraw token"
            );
        }
    }

    function viewBalance(address token, address user)
        external
        view
        returns (uint balance)
    {
        return tokens[token][user];
    }

    // TODO: change this so that the fee can only be decreased
    // (once a suitable starting fee is reached).
    function changeBaseFee(uint newFee) external onlyOwner {
        baseFee = newFee;
    }
    function changePaymentFee(uint newFee) external onlyOwner {
        paymentFee = newFee;
    }

    function disableRetrieveFunds(bool disabled) public onlyOwner {
        retrieveFundsEnabled = !disabled;
    }

    function disableCreatePayment(bool disabled) public onlyOwner {
        createPaymentEnabled = !disabled;
    }

    function getPaymentInfo(uint paymentID)
        external
        view
        returns (
            uint holdTime,
            uint paymentOpenTime,
            uint paymentCloseTime,
            address token,
            uint sendAmount,
            address sender,
            address recipient,
            bytes memory codeHash,
            uint state
        )
    {
        Payment memory txn = openPayments[paymentID];
        return (
            txn.holdTime,
            txn.paymentOpenTime,
            txn.paymentCloseTime,
            txn.token,
            txn.sendAmount,
            txn.sender,
            txn.recipient,
            txn.codeHash,
            uint(txn.state)
        );
    }

    function cancelPaymentAsSender(uint txnId) external {
        // Check txn sender and state.
        Payment memory txn = openPayments[txnId];
        require(
            txn.sender == msg.sender,
            "Payment sender does not match message sender."
        );
        require(
            txn.state == PaymentState.OPEN,
            "Payment must be open to cancel."
        );
        cancelPayment(txnId);
    }

    // Cancels the payment and returns the funds to the payment's sender.
    // Assumes that checks have already been done on any external calls.
    function cancelPayment(uint txnId) private {
        // Check txn sender and state.
        Payment memory txn = openPayments[txnId];

        // Update txn state.
        txn.paymentCloseTime = now;
        txn.state = PaymentState.CANCELLED;

        delete openPayments[txnId];

        // Return funds to sender.
        if (txn.token == address(0)) {
            tokens[address(0)][txn.sender] = SafeMath.sub(
                tokens[address(0)][txn.sender],
                txn.sendAmount
            );
            txn.sender.transfer(txn.sendAmount);
        } else {
            withdrawToken(txn.token, txn.sender, txn.sender, txn.sendAmount);
        }

        emit PaymentClosed(
            txnId,
            txn.holdTime,
            txn.paymentOpenTime,
            txn.paymentCloseTime,
            txn.token,
            txn.sendAmount,
            txn.sender,
            txn.recipient,
            txn.codeHash,
            uint(txn.state)
        );
    }

    /**
* This function handles deposits of ERC-20 tokens to the contract.
* Does not allow Ether.
* If token transfer fails, payment is reverted and remaining gas is refunded.
* Additionally, includes a fee which must be accounted for when approving the amount.
* Note: Remember to call Token(address).approve(this, amount) or this contract will not be able to do the transfer on your behalf.
* @param token Ethereum contract address of the token or 0 for Ether
* @param originalAmount uint of the amount of the token the user wishes to deposit
* @param feeAmount uint total amount of the fee charged by the contract
*/
    // TODO: this doesn't follow checks-effects-interactions
    // https://solidity.readthedocs.io/en/develop/security-considerations.html?highlight=check%20effects#use-the-checks-effects-interactions-pattern
    function transferToken(
        address token,
        address user,
        uint originalAmount,
        uint feeAmount
    ) internal {
        require(token != address(0));
        // TODO: use depositingTokenFlag in the ERC223 fallback function
        //depositingTokenFlag = true;
        require(
            IERC20(token).transferFrom(
                user,
                address(this),
                SafeMath.add(originalAmount, feeAmount)
            )
        );
        //depositingTokenFlag = false;
        tokens[token][user] = SafeMath.add(
            tokens[token][msg.sender],
            originalAmount
        );
        tokens[token][owner] = SafeMath.add(tokens[token][owner], feeAmount);
    }

    // TODO: Make sure to check if amounts are available
    // We don't increment any balances because the funds are sent
    // outside of the contract.
    function withdrawToken(
        address token,
        address userFrom,
        address userTo,
        uint amount
    ) internal {
        require(token != address(0));
        require(IERC20(token).transfer(userTo, amount));
        tokens[token][userFrom] = SafeMath.sub(tokens[token][userFrom], amount);
    }

    /* This takes ether for the fee amount*/
    // TODO check order of execution.
    function createPayment(
        uint amount,
        address payable recipient,
        uint holdTime,
        bytes calldata codeHash
    ) external payable {
        return createTokenPayment(
            address(0),
            amount,
            recipient,
            holdTime,
            codeHash
        );

    }

    // Meant to be used for the approve() call, since the
    // amount in the ERC20 contract implementation will be
    // overwritten with the amount requested in the next approve().
    // This returns the amount of the token that the
    // contract still holds.
    // TODO: ensure this value will be correct.
    function getBalance(address token) external view returns (uint amt) {
        return tokens[token][msg.sender];
    }

    function getPaymentId(address recipient, bytes memory codeHash)
        public
        pure
        returns (uint result)
    {
        bytes memory txnIdBytes = abi.encodePacked(
            keccak256(abi.encodePacked(codeHash, recipient))
        );
        uint txnId = sliceUint(txnIdBytes);
        return txnId;
    }
    // Creates a new payment with the msg.sender as sender.
    // Expected to take a base fee in ETH.
    // Also takes a payment fee in either ETH or the token used,
    // this payment fee is calculated from the original amount.
    // We assume here that an approve() call has already been made for
    // the original amount + payment fee.
    function createTokenPayment(
        address token,
        uint amount,
        address payable recipient,
        uint holdTime,
        bytes memory codeHash
    ) public payable {
        // Check amount and fee, make sure to truncate fee.
        require(
            createPaymentEnabled,
            "The create payments functionality is currently disabled"
        );
        uint paymentFeeTotal = uint(
            SafeMath.mul(paymentFee, amount) / (1 ether)
        );
        if (token == address(0)) {
            require(
                msg.value >= (
                    SafeMath.add(SafeMath.add(amount, baseFee), paymentFeeTotal)
                ),
                "Message value is not enough to cover amount and fees"
            );
        } else {
            require(
                msg.value >= baseFee,
                "Message value is not enough to cover base fee"
            );
            // We don't check for a minimum when taking the paymentFee here. Since we don't
            // care what the original sent amount was supposed to be, we just take a percentage and
            // subtract that from the sent amount.
        }

        // Check payment ID.
        // TODO: should other components be included in the hash? This isn't secure
        // if someone uses a bad codeHash. But they could mess up other components anyway,
        // unless a UUID was generated in the contract, which is expensive.
        uint txnId = getPaymentId(recipient, codeHash);
        // If txnId already exists, don't overwrite.
        require(
            openPayments[txnId].sender == address(0),
            "Payment ID must be unique. Use a different passphrase hash."
        );

        // Create payments.
        Payment memory txn = Payment(
            holdTime,
            now,
            0,
            token,
            amount,
            msg.sender,
            recipient,
            codeHash,
            PaymentState.OPEN
        );

        openPayments[txnId] = txn;

        // Take fees; mark ether or token balances.
        if (token == address(0)) {
            // Mark sender's ether balance with the sent amount
            tokens[address(0)][msg.sender] = SafeMath.add(
                tokens[address(0)][msg.sender],
                amount
            );

            // Take baseFee and paymentFee (and any ether sent in the message)
            tokens[address(0)][owner] = SafeMath.add(
                tokens[address(0)][owner],
                SafeMath.sub(msg.value, amount)
            );

        } else {
            // Take baseFee (and any ether sent in the message)
            tokens[address(0)][owner] = SafeMath.add(
                tokens[address(0)][owner],
                msg.value
            );
            // Transfer tokens; mark sender's balance; take paymentFee
            transferToken(token, msg.sender, amount, paymentFeeTotal);
        }

        // TODO: is this the best step to emit events?
        emit PaymentOpened(
            txnId,
            txn.holdTime,
            txn.paymentOpenTime,
            txn.paymentCloseTime,
            txn.token,
            txn.sendAmount,
            txn.sender,
            txn.recipient,
            txn.codeHash
        );

    }

    // Meant to be called by anyone, on behalf of the recipient
    // or sender of a payment, in order to retrieve funds or
    // cancel the payment, respectively.
    // Will only work if the correct signature is passed in.
    function completePaymentAsProxy(
        uint256 txnId,
        address sender,
        address recipient,
        string memory passphrase,
        uint requestType,
        bytes32 sigR,
        bytes32 sigS,
        uint8 sigV
    ) public {
        CompletePaymentRequest memory request = CompletePaymentRequest(
            txnId,
            sender,
            recipient,
            passphrase,
            requestType
        );
        address signer = ecrecover(
            hashCompletePaymentRequest(request),
            sigV,
            sigR,
            sigS
        );

        require(
            requestType == uint(
                CompletePaymentRequestType.CANCEL
            ) || requestType == uint(CompletePaymentRequestType.RETRIEVE),
            "requestType must be 0 (CANCEL) or 1 (RETRIEVE)"
        );

        if (requestType == uint(CompletePaymentRequestType.RETRIEVE)) {
            require(
                recipient == signer,
                "The message recipient must be the same as the signer of the message"
            );
            Payment memory txn = openPayments[txnId];
            require(
                txn.recipient == recipient,
                "The payment's recipient must be the same as signer of the message"
            );
            retrieveFunds(txn, txnId, passphrase);
        } else {
            require(
                sender == signer,
                "The message sender must be the same as the signer of the message"
            );
            Payment memory txn = openPayments[txnId];
            require(
                txn.sender == sender,
                "The payment's sender must be the same as signer of the message"
            );
            cancelPayment(txnId);
        }
    }

    // Meant to be called by the recipient.
    function retrieveFundsAsRecipient(uint txnId, string memory code) public {
        Payment memory txn = openPayments[txnId];

        // Check recipient
        require(
            txn.recipient == msg.sender,
            "Message sender must match payment recipient"
        );
        retrieveFunds(txn, txnId, code);
    }

    // Sends funds to a payment recipient.
    // Internal ONLY, because it does not do any checks with msg.sender,
    // and leaves that for calling functions.
    // TODO: find a more secure way to implement the recipient check.
    function retrieveFunds(Payment memory txn, uint txnId, string memory code)
        private
    {
        require(
            retrieveFundsEnabled,
            "The retrieve funds functionality is currently disabled."
        );
        require(
            txn.state == PaymentState.OPEN,
            "Payment must be open to retrieve funds"
        );
        // TODO: make sure this is secure.
        bytes memory actualHash = abi.encodePacked(
            keccak256(abi.encodePacked(code, txn.recipient))
        );
        // Check codeHash
        require(
            sliceUint(actualHash) == sliceUint(txn.codeHash),
            "Passphrase is not correct"
        );

        // Check holdTime
        require(
            (txn.paymentOpenTime + txn.holdTime) > now,
            "Hold time has already expired"
        );

        // Update state.
        txn.paymentCloseTime = now;
        txn.state = PaymentState.COMPLETED;

        delete openPayments[txnId];

        // Transfer either ether or tokens.
        if (txn.token == address(0)) {
            // Pay out retrieved funds based on payment amount
            // TODO: recipient must be valid!
            txn.recipient.transfer(txn.sendAmount);
            tokens[address(0)][txn.sender] = SafeMath.sub(
                tokens[address(0)][txn.sender],
                txn.sendAmount
            );

        } else {
            withdrawToken(txn.token, txn.sender, txn.recipient, txn.sendAmount);
        }

        emit PaymentClosed(
            txnId,
            txn.holdTime,
            txn.paymentOpenTime,
            txn.paymentCloseTime,
            txn.token,
            txn.sendAmount,
            txn.sender,
            txn.recipient,
            txn.codeHash,
            uint(txn.state)
        );

    }

    // Utility function to go from bytes -> uint
    // This is apparently not reversible.
    function sliceUint(bytes memory bs) public pure returns (uint) {
        uint start = 0;
        if (bs.length < start + 32) {
            return 0;
        }
        uint x;
        assembly {
            x := mload(add(bs, add(0x20, start)))
        }
        return x;
    }

}