/**

 *Submitted for verification at Etherscan.io on 2019-02-25

*/



pragma solidity ^0.5.0;







contract BaseSwap is SwapInterface {

    string public VERSION; // Passed in as a constructor parameter.



    struct Swap {

        uint256 timelock;

        uint256 value;

        uint256 brokerFee;

        bytes32 secretLock;

        bytes32 secretKey;

        address payable funder;

        address payable spender;

        address payable broker;

    }



    enum States {

        INVALID,

        OPEN,

        CLOSED,

        EXPIRED

    }



    // Events

    event LogOpen(bytes32 _swapID, address _spender, bytes32 _secretLock);

    event LogExpire(bytes32 _swapID);

    event LogClose(bytes32 _swapID, bytes32 _secretKey);



    // Storage

    mapping (bytes32 => Swap) internal swaps;

    mapping (bytes32 => States) private _swapStates;

    mapping (address => uint256) private _brokerFees;

    mapping (bytes32 => uint256) private _redeemedAt;



    /// @notice Throws if the swap is not invalid (i.e. has already been opened)

    modifier onlyInvalidSwaps(bytes32 _swapID) {

        require(_swapStates[_swapID] == States.INVALID, "swap opened previously");

        _;

    }



    /// @notice Throws if the swap is not open.

    modifier onlyOpenSwaps(bytes32 _swapID) {

        require(_swapStates[_swapID] == States.OPEN, "swap not open");

        _;

    }



    /// @notice Throws if the swap is not closed.

    modifier onlyClosedSwaps(bytes32 _swapID) {

        require(_swapStates[_swapID] == States.CLOSED, "swap not redeemed");

        _;

    }



    /// @notice Throws if the swap is not expirable.

    modifier onlyExpirableSwaps(bytes32 _swapID) {

        /* solium-disable-next-line security/no-block-members */

        require(now >= swaps[_swapID].timelock, "swap not expirable");

        _;

    }



    /// @notice Throws if the secret key is not valid.

    modifier onlyWithSecretKey(bytes32 _swapID, bytes32 _secretKey) {

        require(swaps[_swapID].secretLock == sha256(abi.encodePacked(_secretKey)), "invalid secret");

        _;

    }



    /// @notice Throws if the caller is not the authorized spender.

    modifier onlySpender(bytes32 _swapID, address _spender) {

        require(swaps[_swapID].spender == _spender, "unauthorized spender");

        _;

    }



    /// @notice The contract constructor.

    ///

    /// @param _VERSION A string defining the contract version.

    constructor(string memory _VERSION) public {

        VERSION = _VERSION;

    }



    /// @notice Initiates the atomic swap.

    ///

    /// @param _swapID The unique atomic swap id.

    /// @param _spender The address of the withdrawing trader.

    /// @param _secretLock The hash of the secret (Hash Lock).

    /// @param _timelock The unix timestamp when the swap expires.

    /// @param _value The value of the atomic swap.

    function initiate(

        bytes32 _swapID,

        address payable _spender,

        bytes32 _secretLock,

        uint256 _timelock,

        uint256 _value

    ) public onlyInvalidSwaps(_swapID) payable {

        // Store the details of the swap.

        Swap memory swap = Swap({

            timelock: _timelock,

            brokerFee: 0,

            value: _value,

            funder: msg.sender,

            spender: _spender,

            broker: address(0x0),

            secretLock: _secretLock,

            secretKey: 0x0

        });

        swaps[_swapID] = swap;

        _swapStates[_swapID] = States.OPEN;



        // Logs open event

        emit LogOpen(_swapID, _spender, _secretLock);

    }



    /// @notice Initiates the atomic swap with fees.

    ///

    /// @param _swapID The unique atomic swap id.

    /// @param _spender The address of the withdrawing trader.

    /// @param _broker The address of the broker.

    /// @param _brokerFee The fee to be paid to the broker on success.

    /// @param _secretLock The hash of the secret (Hash Lock).

    /// @param _timelock The unix timestamp when the swap expires.

    /// @param _value The value of the atomic swap.

    function initiateWithFees(

        bytes32 _swapID,

        address payable _spender,

        address payable _broker,

        uint256 _brokerFee,

        bytes32 _secretLock,

        uint256 _timelock,

        uint256 _value

    ) public onlyInvalidSwaps(_swapID) payable {

        require(_value >= _brokerFee, "fee must be less than value");



        // Store the details of the swap.

        Swap memory swap = Swap({

            timelock: _timelock,

            brokerFee: _brokerFee,

            value: _value - _brokerFee,

            funder: msg.sender,

            spender: _spender,

            broker: _broker,

            secretLock: _secretLock,

            secretKey: 0x0

        });

        swaps[_swapID] = swap;

        _swapStates[_swapID] = States.OPEN;



        // Logs open event

        emit LogOpen(_swapID, _spender, _secretLock);

    }



    /// @notice Redeems an atomic swap.

    ///

    /// @param _swapID The unique atomic swap id.

    /// @param _receiver The receiver's address.

    /// @param _secretKey The secret of the atomic swap.

    function redeem(bytes32 _swapID, address payable _receiver, bytes32 _secretKey) public onlyOpenSwaps(_swapID) onlyWithSecretKey(_swapID, _secretKey) onlySpender(_swapID, msg.sender) {

        require(_receiver != address(0x0), "invalid receiver");



        // Close the swap.

        swaps[_swapID].secretKey = _secretKey;

        _swapStates[_swapID] = States.CLOSED;

        /* solium-disable-next-line security/no-block-members */

        _redeemedAt[_swapID] = now;



        // Update the broker fees to the broker.

        _brokerFees[swaps[_swapID].broker] += swaps[_swapID].brokerFee;



        // Logs close event

        emit LogClose(_swapID, _secretKey);

    }



    /// @notice Redeems an atomic swap to the spender. Can be called by anyone.

    ///

    /// @param _swapID The unique atomic swap id.

    /// @param _secretKey The secret of the atomic swap.

    function redeemToSpender(bytes32 _swapID, bytes32 _secretKey) public onlyOpenSwaps(_swapID) onlyWithSecretKey(_swapID, _secretKey) {

        // Close the swap.

        swaps[_swapID].secretKey = _secretKey;

        _swapStates[_swapID] = States.CLOSED;

        /* solium-disable-next-line security/no-block-members */

        _redeemedAt[_swapID] = now;



        // Update the broker fees to the broker.

        _brokerFees[swaps[_swapID].broker] += swaps[_swapID].brokerFee;



        // Logs close event

        emit LogClose(_swapID, _secretKey);

    }



    /// @notice Refunds an atomic swap.

    ///

    /// @param _swapID The unique atomic swap id.

    function refund(bytes32 _swapID) public onlyOpenSwaps(_swapID) onlyExpirableSwaps(_swapID) {

        // Expire the swap.

        _swapStates[_swapID] = States.EXPIRED;



        // Logs expire event

        emit LogExpire(_swapID);

    }



    /// @notice Allows broker fee withdrawals.

    ///

    /// @param _amount The withdrawal amount.

    function withdrawBrokerFees(uint256 _amount) public {

        require(_amount <= _brokerFees[msg.sender], "insufficient withdrawable fees");

        _brokerFees[msg.sender] -= _amount;

    }



    /// @notice Audits an atomic swap.

    ///

    /// @param _swapID The unique atomic swap id.

    function audit(bytes32 _swapID) external view returns (uint256 timelock, uint256 value, address to, uint256 brokerFee, address broker, address from, bytes32 secretLock) {

        Swap memory swap = swaps[_swapID];

        return (

            swap.timelock,

            swap.value,

            swap.spender,

            swap.brokerFee,

            swap.broker,

            swap.funder,

            swap.secretLock

        );

    }



    /// @notice Audits the secret of an atomic swap.

    ///

    /// @param _swapID The unique atomic swap id.

    function auditSecret(bytes32 _swapID) external view onlyClosedSwaps(_swapID) returns (bytes32 secretKey) {

        return swaps[_swapID].secretKey;

    }



    /// @notice Checks whether a swap is refundable or not.

    ///

    /// @param _swapID The unique atomic swap id.

    function refundable(bytes32 _swapID) external view returns (bool) {

        /* solium-disable-next-line security/no-block-members */

        return (now >= swaps[_swapID].timelock && _swapStates[_swapID] == States.OPEN);

    }



    /// @notice Checks whether a swap is initiatable or not.

    ///

    /// @param _swapID The unique atomic swap id.

    function initiatable(bytes32 _swapID) external view returns (bool) {

        return (_swapStates[_swapID] == States.INVALID);

    }



    /// @notice Checks whether a swap is redeemable or not.

    ///

    /// @param _swapID The unique atomic swap id.

    function redeemable(bytes32 _swapID) external view returns (bool) {

        return (_swapStates[_swapID] == States.OPEN);

    }



    function redeemedAt(bytes32 _swapID) external view returns (uint256) {

        return _redeemedAt[_swapID];

    }



    function brokerFees(address _broker) external view returns (uint256) {

        return _brokerFees[_broker];

    }



    /// @notice Generates a deterministic swap id using initiate swap details.

    ///

    /// @param _secretLock The hash of the secret.

    /// @param _timelock The expiry timestamp.

    function swapID(bytes32 _secretLock, uint256 _timelock) external pure returns (bytes32) {

        return keccak256(abi.encodePacked(_secretLock, _timelock));

    }

}



/**

 * @title SafeMath

 * @dev Unsigned math operations with safety checks that revert on error

 */





/**

 * @title Math

 * @dev Assorted math operations

 */





/// @notice Implements safeTransfer, safeTransferFrom and

/// safeApprove for CompatibleERC20.

///

/// See https://github.com/ethereum/solidity/issues/4116

///

/// This library allows interacting with ERC20 tokens that implement any of

/// these interfaces:

///

/// (1) transfer returns true on success, false on failure

/// (2) transfer returns true on success, reverts on failure

/// (3) transfer returns nothing on success, reverts on failure

///

/// Additionally, safeTransferFromWithFees will return the final token

/// value received after accounting for token fees.





/// @notice ERC20 interface which doesn't specify the return type for transfer,

/// transferFrom and approve.





/// @notice ERC20WithFeesSwap implements the ERC20WithFeesSwap interface.

contract ERC20WithFeesSwap is SwapInterface, BaseSwap {

    using CompatibleERC20Functions for CompatibleERC20;



    address public TOKEN_ADDRESS; // Address of the ERC20 contract. Passed in as a constructor parameter



    /// @notice The contract constructor.

    ///

    /// @param _VERSION A string defining the contract version.

    constructor(string memory _VERSION, address _TOKEN_ADDRESS) BaseSwap(_VERSION) public {

        TOKEN_ADDRESS = _TOKEN_ADDRESS;

    }



    /// @notice Initiates the atomic swap.

    ///

    /// @param _swapID The unique atomic swap id.

    /// @param _spender The address of the withdrawing trader.

    /// @param _secretLock The hash of the secret (Hash Lock).

    /// @param _timelock The unix timestamp when the swap expires.

    /// @param _value The value of the atomic swap.

    function initiate(

        bytes32 _swapID,

        address payable _spender,

        bytes32 _secretLock,

        uint256 _timelock,

        uint256 _value

    ) public payable {

        // To abide by the interface, the function is payable but throws if

        // msg.value is non-zero

        require(msg.value == 0, "eth value must be zero");

        require(_spender != address(0x0), "spender must not be zero");



        // Transfer the token to the contract

        // TODO: Initiator will first need to call

        // ERC20(TOKEN_ADDRESS).approve(address(this), _value)

        // before this contract can make transfers on the initiator's behalf.

        uint256 value = CompatibleERC20(TOKEN_ADDRESS).safeTransferFromWithFees(msg.sender, address(this), _value);

        

        BaseSwap.initiate(

            _swapID,

            _spender,

            _secretLock,

            _timelock,

            value

        );

    }



    /// @notice Initiates the atomic swap with broker fees.

    ///

    /// @param _swapID The unique atomic swap id.

    /// @param _spender The address of the withdrawing trader.

    /// @param _broker The address of the broker.

    /// @param _brokerFee The fee to be paid to the broker on success.

    /// @param _secretLock The hash of the secret (Hash Lock).

    /// @param _timelock The unix timestamp when the swap expires.

    /// @param _value The value of the atomic swap.

    function initiateWithFees(

        bytes32 _swapID,

        address payable _spender,

        address payable _broker,

        uint256 _brokerFee,

        bytes32 _secretLock,

        uint256 _timelock,

        uint256 _value

    ) public payable {

        // To abide by the interface, the function is payable but throws if

        // msg.value is non-zero

        require(msg.value == 0, "eth value must be zero");

        require(_spender != address(0x0), "spender must not be zero");



        // Transfer the token to the contract

        // TODO: Initiator will first need to call

        // ERC20(TOKEN_ADDRESS).approve(address(this), _value)

        // before this contract can make transfers on the initiator's behalf.

        uint256 value = CompatibleERC20(TOKEN_ADDRESS).safeTransferFromWithFees(msg.sender, address(this), _value);



        BaseSwap.initiateWithFees(

            _swapID,

            _spender,

            _broker,

            _brokerFee,

            _secretLock,

            _timelock,

            value

        );

    }



    /// @notice Redeems an atomic swap.

    ///

    /// @param _swapID The unique atomic swap id.

    /// @param _receiver The receiver's address.

    /// @param _secretKey The secret of the atomic swap.

    function redeem(bytes32 _swapID, address payable _receiver, bytes32 _secretKey) public {

        BaseSwap.redeem(

            _swapID,

            _receiver,

            _secretKey

        );



        // Transfer the ERC20 funds from this contract to the withdrawing trader.

        CompatibleERC20(TOKEN_ADDRESS).safeTransfer(_receiver, swaps[_swapID].value);

    }



    /// @notice Redeems an atomic swap to the spender. Can be called by anyone.

    ///

    /// @param _swapID The unique atomic swap id.

    /// @param _secretKey The secret of the atomic swap.

    function redeemToSpender(bytes32 _swapID, bytes32 _secretKey) public {

        BaseSwap.redeemToSpender(

            _swapID,

            _secretKey

        );



        // Transfer the ERC20 funds from this contract to the withdrawing trader.

        CompatibleERC20(TOKEN_ADDRESS).safeTransfer(swaps[_swapID].spender, swaps[_swapID].value);

    }



    /// @notice Refunds an atomic swap.

    ///

    /// @param _swapID The unique atomic swap id.

    function refund(bytes32 _swapID) public {

        BaseSwap.refund(_swapID);



        // Transfer the ERC20 value from this contract back to the funding trader.

        CompatibleERC20(TOKEN_ADDRESS).safeTransfer(swaps[_swapID].funder, swaps[_swapID].value + swaps[_swapID].brokerFee);

    }



    /// @notice Allows broker fee withdrawals.

    ///

    /// @param _amount The withdrawal amount.

    function withdrawBrokerFees(uint256 _amount) public {

        BaseSwap.withdrawBrokerFees(_amount);

        

        CompatibleERC20(TOKEN_ADDRESS).safeTransfer(msg.sender, _amount);

    }

}