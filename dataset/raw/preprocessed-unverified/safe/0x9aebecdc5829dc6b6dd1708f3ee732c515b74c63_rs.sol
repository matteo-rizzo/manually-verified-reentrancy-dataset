/**
 *Submitted for verification at Etherscan.io on 2020-12-06
*/

/**
 *Submitted for verification at Etherscan.io on 2020-12-06
*/

// SPDX-License-Identifier: MIT

pragma solidity 0.6.10;

/**
 * @dev Contract module which provides a basic access control mechanism, where
 * there is an account (an owner) that can be granted exclusive access to
 * specific functions.
 *
 * By default, the owner account will be the one that deploys the contract. This
 * can later be changed with {transferOwnership}.
 *
 * This module is used through inheritance. It will make available the modifier
 * `onlyOwner`, which can be applied to your functions to restrict their use to
 * the owner.
 */



/**
 * @dev Collection of functions related to the address type
 */



/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
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
 * @dev Contract module that helps prevent reentrant calls to a function.
 *
 * Inheriting from `ReentrancyGuard` will make the {nonReentrant} modifier
 * available, which can be applied to functions to make sure there are no nested
 * (reentrant) calls to them.
 *
 * Note that because there is a single `nonReentrant` guard, functions marked as
 * `nonReentrant` may not call one another. This can be worked around by making
 * those functions `private`, and then adding `external` `nonReentrant` entry
 * points to them.
 *
 * TIP: If you would like to learn more about reentrancy and alternative ways
 * to protect against it, check out our blog post
 * https://blog.openzeppelin.com/reentrancy-after-istanbul/[Reentrancy After Istanbul].
 */
contract ReentrancyGuard {
    // Booleans are more expensive than uint256 or any type that takes up a full
    // word because each write operation emits an extra SLOAD to first read the
    // slot's contents, replace the bits taken up by the boolean, and then write
    // back. This is the compiler's defense against contract upgrades and
    // pointer aliasing, and it cannot be disabled.

    // The values being non-zero value makes deployment a bit more expensive,
    // but in exchange the refund on every call to nonReentrant will be lower in
    // amount. Since refunds are capped to a percentage of the total
    // transaction's gas, it is best to keep them low in cases like this one, to
    // increase the likelihood of the full refund coming into effect.
    uint256 private constant _NOT_ENTERED = 1;
    uint256 private constant _ENTERED = 2;

    uint256 internal _status;

    /**
     * @dev Prevents a contract from calling itself, directly or indirectly.
     * Calling a `nonReentrant` function from another `nonReentrant`
     * function is not supported. It is possible to prevent this from happening
     * by making the `nonReentrant` function external, and make it call a
     * `private` function that does the actual work.
     */
    modifier nonReentrant() {
        // On the first call to nonReentrant, _notEntered will be true
        require(_status != _ENTERED, "ReentrancyGuard: reentrant call");

        // Any calls to nonReentrant after this point will fail
        _status = _ENTERED;

        _;

        // By storing the original value once again, a refund is triggered (see
        // https://eips.ethereum.org/EIPS/eip-2200)
        _status = _NOT_ENTERED;
    }
}


/**
 * @dev Contract module which allows children to implement an emergency stop
 * mechanism that can be triggered by an authorized account.
 *
 * This module is used through inheritance. It will make available the
 * modifiers `whenNotPaused` and `whenPaused`, which can be applied to
 * the functions of your contract. Note that they will not be pausable by
 * simply including this module, only once the modifiers are put in place.
 */
contract Pausable is Ownable {
    /**
     * @dev Emitted when the pause is triggered by `account`.
     */
    event Paused(address account);

    /**
     * @dev Emitted when the pause is lifted by `account`.
     */
    event Unpaused(address account);

    bool private _paused = false;

    /**
     * @dev Modifier to make a function callable only when the contract is not paused.
     *
     * Requirements:
     *
     * - The contract must not be paused.
     */
    modifier whenNotPaused() {
        require(!_paused, "Pausable: paused");
        _;
    }

    /**
     * @dev Modifier to make a function callable only when the contract is paused.
     *
     * Requirements:
     *
     * - The contract must be paused.
     */
    modifier whenPaused() {
        require(_paused, "Pausable: not paused");
        _;
    }

    /**
     * @dev Triggers stopped state.
     *
     * Requirements:
     *
     * - The contract must not be paused.
     */
    function _pause() internal virtual whenNotPaused {
        _paused = true;
        emit Paused(msg.sender);
    }

    /**
     * @dev Returns to normal state.
     *
     * Requirements:
     *
     * - The contract must be paused.
     */
    function _unpause() internal virtual whenPaused {
        _paused = false;
        emit Unpaused(msg.sender);
    }

    /**
     * @dev Pause contract.
     */
    function paused() external onlyOwner returns (bool) {
        _pause();
    }

    /**
     * @dev Unpause contract.
     */
    function unpaused() external onlyOwner returns (bool) {
        _unpause();
    }

    /**
     * @dev Returns true if the contract is paused, and false otherwise.
     */
    function isPaused() external onlyOwner view returns (bool) {
        return _paused;
    }
}



contract NebulasToken is Pausable, ReentrancyGuard {
    using SafeMath for uint256;
    using SafeERC20 for IERC20;

    mapping (address => uint256) private _balances;
    uint256 private _totalSupply;

    address public nTokenController;
    IERC20 public underlyingToken;
    address public feeRecipient;

    bool private _initialized = false;

    // Record the addresses of the ethereum chain corresponding to the nebulas chain.
    // eg: account(at ethereum) => account(at nebulas).
    mapping (address => string) public mappingAccounts;
    // Record the addresses of the nebulas chain corresponding to the ethereum chain.
    // eg: account(at nebulas) => account(at ethereum).
    mapping (string => address) public convertMappingAccounts;

    event UpdateController(address indexed oldController, address indexed newController);

    event NewMappingAccount(address indexed underlyingToken, address indexed spender, string recipient);
    event UpdateMappingAccount(address indexed spender, string newRecipient,  string oldRecipient, address underlyingToken);

    event Staked(address indexed ethereumSpender, uint256 indexed amount, string nebulasRecipient);
    event Refund(address indexed ethereumRecipient, uint256 indexed amount, string nebulasSpender, uint256 fee);
    event UpdateFeeRecipient(address indexed oldFeeRecipient, address indexed newFeeRecipient);


    modifier onlyController(address _caller) {
        require(_caller == nTokenController, "onlyController: Caller is not the controller!");
        _;
    }

    modifier checkNebulasAccount(string memory _nebulasAccount) {
        bytes memory accountBytes = bytes(_nebulasAccount);
        require(
            accountBytes[0] == 0x6e && accountBytes[1] == 0x31,
            "checkNebulasAccount: Invalid nebulas account address!"
            );
        require(accountBytes.length == 35, "checkNebulasAccount: Invalid nebulas account length!");
        _;
    }

    /**
     * @dev Sets the values for {underlyingToken}, {nTokenController} and {_owner}.
     */
    constructor(
        address _newOwner,
        IERC20 _underlyingToken,
        address _nTokenController,
        address _feeRecipient
    ) public {
        initialize(_newOwner, _underlyingToken, _nTokenController, _feeRecipient);
    }

    /**
     * @dev For proxy.
     */
    function initialize(
        address _newOwner,
        IERC20 _underlyingToken,
        address _nTokenController,
        address _feeRecipient
    ) public {
        require(!_initialized, "initialize: Contract is already initialized!");

        require(
            _newOwner != address(0),
            "initialize: New owner is the zero address!"
        );
        require(
            _feeRecipient != address(0),
            "initialize: Fee recipient is the zero address!"
        );

        underlyingToken = _underlyingToken;
        nTokenController = _nTokenController;
        feeRecipient = _feeRecipient;
        _status = 1;

        _owner = _newOwner;
        emit OwnershipTransferred(address(0), _newOwner);

        _initialized = true;
    }

    /**
     * @dev Update controller contract.
     */
    function updateController(address _newController) external onlyOwner {
        require(_newController != nTokenController, "updateController: The same controller!");
        address _oldController = nTokenController;
        nTokenController = _newController;
        emit UpdateController(_oldController, _newController);
    }

    /**
     * @dev When stakes underlying token, recording staker on the ethereum, and recipient on the nebulas.
     * @param _recipient Account that user will get asset on the nebulas chain.
     */
    function setMappingAccount(
        string memory _recipient
    ) internal {
        if (keccak256(abi.encodePacked(mappingAccounts[msg.sender])) == keccak256(abi.encodePacked(""))) {
            mappingAccounts[msg.sender] = _recipient;
            convertMappingAccounts[_recipient] = msg.sender;
            emit NewMappingAccount(address(underlyingToken), msg.sender, _recipient);
        } else if (keccak256(abi.encodePacked(mappingAccounts[msg.sender])) != keccak256(abi.encodePacked(_recipient))){
            updateMappingAccount(_recipient);
        }
    }

    /**
     * @dev User who has staked wants to change recipient address on the nebulas chain.
     * @param _newRecipient New account that user will get asset on the nebulas chain.
     */
    function updateMappingAccount(
        string memory _newRecipient
    ) public checkNebulasAccount(_newRecipient) {
        require(
            keccak256(abi.encodePacked(mappingAccounts[msg.sender])) != keccak256(abi.encodePacked("")),
            "updateMappingAccount: Do not have staked!"
        );

        string memory _oldRecipient = mappingAccounts[msg.sender];
        mappingAccounts[msg.sender] = _newRecipient;
        delete convertMappingAccounts[_oldRecipient];
        convertMappingAccounts[_newRecipient] = msg.sender;
        emit UpdateMappingAccount(msg.sender, _oldRecipient, _newRecipient, address(underlyingToken));
    }

    /**
     * @dev Based on the underlying token and account{_spender} on the ethereum,
     *      gets recipient account on the nebulas chain.
     */
    function getMappingAccount(
        address _spender
    ) external view returns (string memory) {
        return mappingAccounts[_spender];
    }

    /**
     * @dev User stakes their assets on the ethereum, expects to get corresponding assets on the nebulas chain.
     * @param _amount Amount to stake on the ethereum.
     * @param _nebulasAccount Account address on the nubelas chain to get asset.
     */
    function stake(
        uint256 _amount,
        string memory _nebulasAccount
    ) external whenNotPaused nonReentrant checkNebulasAccount(_nebulasAccount) returns (bool) {
        require(_amount > 0, "stake: Staking amount should be greater than 0!");
        uint256 _originalBalance = underlyingToken.balanceOf(address(this));
        underlyingToken.safeTransferFrom(msg.sender, address(this), _amount);
        uint256 _currentBalance = underlyingToken.balanceOf(address(this));
        uint256 _actualStakeAmount = _currentBalance.sub(_originalBalance);

        setMappingAccount(_nebulasAccount);
        _balances[msg.sender] = _balances[msg.sender].add(_actualStakeAmount);
        _totalSupply = _totalSupply.add(_actualStakeAmount);

        emit Staked(msg.sender, _actualStakeAmount, _nebulasAccount);
        return true;
    }

    /**
     * @dev Returns asset on the ethereum to user.
     * @param _nebulasAccount Account on the nebulas chain that requests for a refund.
     * @param _recipient Account on the ethereum to get assets returned.
     * @param _amount Amount to return to user.
     * @param _fee Charge some fee when refunding.
     */
    function refund(
        string memory _nebulasAccount,
        address _recipient,
        uint256 _amount,
        uint256 _fee
    ) external onlyOwner nonReentrant checkNebulasAccount(_nebulasAccount) returns (bool) {
        require(_amount > 0, "refund: Refund amount should be greater than 0!");

        _totalSupply = _totalSupply.sub(_amount).sub(_fee);
        underlyingToken.safeTransfer(_recipient, _amount);
        underlyingToken.safeTransfer(feeRecipient, _fee);

        emit Refund(_recipient, _amount, _nebulasAccount, _fee);

        return true;
    }

    /**
     * @dev Reset the charging fee account.
     */
    function updateFeeRecipient(
        address _newFeeRecipient
    ) external onlyController(msg.sender) returns (bool) {
        require(_newFeeRecipient != feeRecipient, "updateFeeRecipient: New fee recipient is the same!");
        address _oldFeeRecipient = feeRecipient;
        feeRecipient = _newFeeRecipient;

        emit UpdateFeeRecipient(_oldFeeRecipient, _newFeeRecipient);
        return true;
    }

    /**
     * @dev Under some unexpected cases, transfer token out.
     *     eg: Someone transfers other token rather than underlying token into this contract,
     *         The nebulas community can transfer these token out after consultation and agreement.
     */
    function transferOut(
        IERC20 _token,
        address _recipient,
        uint256 _amount
    ) external onlyController(msg.sender) nonReentrant whenPaused returns (bool) {
        uint256 _totalBalance = _token.balanceOf(address(this));
        require(_amount <= _totalBalance, "transferOut: Insufficient balance!");
        _token.safeTransfer(_recipient, _amount);

        return true;
    }

    /**
     * @dev Current totally staking.
     */
    function totalSupply() external view returns (uint256) {
        return _totalSupply;
    }

    /**
     * @dev Returns the amount of tokens owned by `_account`.
     */
    function balanceOf(address _account) external view returns (uint256) {
        return _balances[_account];
    }
}