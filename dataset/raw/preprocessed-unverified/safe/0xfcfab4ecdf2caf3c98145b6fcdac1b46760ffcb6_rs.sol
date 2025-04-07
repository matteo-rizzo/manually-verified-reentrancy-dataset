/**
 *Submitted for verification at Etherscan.io on 2021-03-01
*/

// SPDX-License-Identifier: MIT

pragma solidity 0.6.12;

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


/**
 * @dev Elliptic Curve Digital Signature Algorithm (ECDSA) operations.
 *
 * These functions can be used to verify that a message was signed by the holder
 * of the private keys of a given address.
 */


/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
 */


/**
 * @dev Collection of functions related to the address type
 */


/**
 * @title SafeERC20
 * @dev Wrappers around ERC20 operations that throw on failure (when the token
 * contract returns false). Tokens that return no value (and instead revert or
 * throw on failure) are also supported, non-reverting calls are assumed to be
 * successful.
 * To use this library you can add a `using SafeERC20 for IERC20;` statement to your contract,
 * which allows you to call the safe operations as `token.safeTransfer(...)`, etc.
 */




contract ERC20BridgeGateway {
    using SafeMath for uint256;
    using SafeERC20 for IERC20;
    uint256 constant BIPS_DENOMINATOR = 10000;
    IERC20 public token;
    address public owner;
    address public admin; // adminAddress
    address public feeRecipient; // feeRecipientAddress
    mapping(bytes32 => bool) public status; /// @notice Each signature can only be seen once.
    bool public safeFundMoving; /// send fund to safe wallet
    address public safeFundWallet; /// safe place storing fund
    uint16 public depositFee; /// @notice The deposit fee in bips.
    uint16 public withdrawFee; /// @notice The withdraw fee in bips.
    uint256 public minDepositAmount; /// @notice The deposit fee in bips.
    uint256 public minWithdrawAmount; /// @notice The withdraw fee in bips.
    uint256 public index = 0; /// index of each deposit/withdraw order

    event Deposit(uint256 indexed _index, address indexed _to, uint256 _amount);
    event Withdraw(uint256 indexed _index, address indexed _to, uint256 _amount, bytes32 indexed _signedMessageHash);

    constructor(
        address _token,
        address _admin,
        address _feeRecipient,
        uint16 _depositFee,
        uint16 _withdrawFee,
        bool _safeFundMoving,
        address _safeFundWallet,
        uint256 _minDepositAmount,
        uint256 _minWithdrawAmount
    ) public {
        require(_token != address(0));
        token = IERC20(_token);
        admin = _admin;
        depositFee = _depositFee;
        withdrawFee = _withdrawFee;
        feeRecipient = _feeRecipient;
        safeFundMoving = _safeFundMoving;
        if (_safeFundWallet != address(0)) {
            safeFundWallet = _safeFundWallet;
        }
        minDepositAmount = _minDepositAmount;
        minWithdrawAmount = _minWithdrawAmount;
        owner = msg.sender;
    }

    modifier onlyAdmin() {
        require(msg.sender == admin, "admin: wut?");
        _;
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "!owner");
        _;
    }

    function deposit(uint256 _amount) public {
        require(_amount >= minDepositAmount, "Gateway: deposit amount to small");
        uint256 feeAmount = _amount.mul(depositFee).div(BIPS_DENOMINATOR);
        uint256 amountAfterFee = _amount.sub(feeAmount, "Gateway: fee exceeds amount");
        require(token.transferFrom(msg.sender, address(this), _amount), "token transfer failed");
        // transfer fee to feeRecipient
        if (feeAmount > 0) {
            token.safeTransfer(feeRecipient, feeAmount);
        }
        if (safeFundMoving && safeFundWallet != address(0)) {
            token.safeTransfer(safeFundWallet, amountAfterFee);
        }
        emit Deposit(index, msg.sender, amountAfterFee);
        index += 1;
    }

    function withdraw(
        string calldata _symbol,
        uint256 _amount,
        bytes32 _nHash,
        bytes calldata _sig
    ) public {
        require(_amount >= minDepositAmount, "Gateway: withdraw amount to small");
        require(token.balanceOf(address(this)) >= _amount, "Gateway: insufficient balance");

        bytes32 payloadHash = keccak256(abi.encode(_symbol, msg.sender));
        // Verify signature
        bytes32 signedMessageHash = hashForSignature(_symbol, msg.sender, _amount, _nHash);
        require(status[signedMessageHash] == false, "Gateway: nonce hash already spent");
        if (!verifySignature(signedMessageHash, _sig)) {
            // Return a detailed string containing the hash and recovered
            // signer. This is somewhat costly but is only run in the revert
            // branch.
            revert(
                String.add8(
                    "Gateway: invalid signature. pHash: ",
                    String.fromBytes32(payloadHash),
                    ", amount: ",
                    String.fromUint(_amount),
                    ", msg.sender: ",
                    String.fromAddress(msg.sender),
                    ", _nHash: ",
                    String.fromBytes32(_nHash)
                )
            );
        }
        status[signedMessageHash] = true;
        // Send `amount - fee` for the recipient and send `fee` to the fee recipient
        uint256 feeAmount = _amount.mul(withdrawFee).div(BIPS_DENOMINATOR);
        uint256 receivedAmount = _amount.sub(feeAmount, "Gateway: fee exceeds amount");

        // Mint amount minus the fee
        token.safeTransfer(msg.sender, receivedAmount);
        // Mint the fee
        if (feeAmount > 0) {
            token.safeTransfer(feeRecipient, feeAmount);
        }

        emit Withdraw(index, msg.sender, receivedAmount, signedMessageHash);
        index += 1;
    }

    /// @notice Allow the owner to update the fee recipient.
    /// @param _nextFeeRecipient The address to start paying fees to.
    function updateFeeRecipient(address _nextFeeRecipient) public onlyOwner {
        require(_nextFeeRecipient != address(0x0), "Gateway: fee recipient cannot be 0x0");
        feeRecipient = _nextFeeRecipient;
    }

    /// @notice Allow the owner to update the admin.
    /// @param _nextAdmin The address to start paying fees to.
    function updateAdmin(address _nextAdmin) public onlyOwner {
        require(_nextAdmin != address(0x0), "Gateway: admin cannot be 0x0");
        admin = _nextAdmin;
    }

    /// @notice Allow the owner to update the token tracker.
    /// @param _nextToken The address of the new tracking token.
    function updateToken(address _nextToken) public onlyOwner {
        require(_nextToken != address(0x0), "Gateway: token cannot be 0x0");
        token = IERC20(_nextToken);
    }

    function updateDepositFee(uint16 _nextDepositFee) public onlyOwner {
        depositFee = _nextDepositFee;
    }

    function updateWithdrawFee(uint16 _nextWithdrawFee) public onlyOwner {
        withdrawFee = _nextWithdrawFee;
    }

    function updateSafeFundMoving(bool _safeFundMoving) public onlyOwner {
        safeFundMoving = _safeFundMoving;
    }

    function updateSafeFundWallet(address _nextSafeFundWallet) public onlyOwner {
        safeFundWallet = _nextSafeFundWallet;
    }

    function updateMinDepositAmount(uint256 _minDepositAmount) public onlyOwner {
        minDepositAmount = _minDepositAmount;
    }

    function updateMinWithdrawAmount(uint256 _minWithdrawAmount) public onlyOwner {
        minWithdrawAmount = _minWithdrawAmount;
    }

    /// @notice verifySignature checks the the provided signature matches the provided
    /// parameters.
    function verifySignature(bytes32 _signedMessageHash, bytes memory _sig) public view returns (bool) {
        bytes32 ethSignedMessageHash = ECDSA.toEthSignedMessageHash(_signedMessageHash);
        address signer = ECDSA.recover(ethSignedMessageHash, _sig);
        return admin == signer;
    }

    /// @notice hashForSignature hashes the parameters so that they can be signed.
    function hashForSignature(
        string memory _symbol,
        address _recipient,
        uint256 _amount,
        bytes32 _nHash
    ) public view returns (bytes32) {
        bytes32 payloadHash = keccak256(abi.encode(_symbol, _recipient));
        return keccak256(abi.encode(payloadHash, _amount, address(token), _nHash));
    }
}