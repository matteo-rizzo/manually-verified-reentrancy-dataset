/**
 *Submitted for verification at Etherscan.io on 2019-10-14
*/

pragma solidity 0.5.0;
// File: src/erc777/IERC777.sol


/**
 * @dev Interface of the ERC777Token standard as defined in the EIP.
 *
 * This contract uses the
 * [ERC1820 registry standard](https://eips.ethereum.org/EIPS/eip-1820) to let
 * token holders and recipients react to token movements by using setting implementers
 * for the associated interfaces in said registry. See `IERC1820Registry` and
 * `ERC1820Implementer`.
 */


// File: src/erc777/IERC777Recipient.sol


/**
 * @dev Interface of the ERC777TokensRecipient standard as defined in the EIP.
 *
 * Accounts can be notified of `IERC777` tokens being sent to them by having a
 * contract implement this interface (contract holders can be their own
 * implementer) and registering it on the
 * [ERC1820 global registry](https://eips.ethereum.org/EIPS/eip-1820).
 *
 * See `IERC1820Registry` and `ERC1820Implementer`.
 */


// File: src/erc777/IERC777Sender.sol


/**
 * @dev Interface of the ERC777TokensSender standard as defined in the EIP.
 *
 * `IERC777` Token holders can be notified of operations performed on their
 * tokens by having a contract implement this interface (contract holders can be
 *  their own implementer) and registering it on the
 * [ERC1820 global registry](https://eips.ethereum.org/EIPS/eip-1820).
 *
 * See `IERC1820Registry` and `ERC1820Implementer`.
 */


// File: openzeppelin-solidity/contracts/token/ERC20/IERC20.sol


/**
 * @dev Interface of the ERC20 standard as defined in the EIP. Does not include
 * the optional functions; to access them see `ERC20Detailed`.
 */


// File: openzeppelin-solidity/contracts/math/SafeMath.sol


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


// File: openzeppelin-solidity/contracts/utils/Address.sol


/**
 * @dev Collection of functions related to the address type,
 */


// File: openzeppelin-solidity/contracts/introspection/IERC1820Registry.sol


/**
 * @dev Interface of the global ERC1820 Registry, as defined in the
 * [EIP](https://eips.ethereum.org/EIPS/eip-1820). Accounts may register
 * implementers for interfaces in this registry, as well as query support.
 *
 * Implementers may be shared by multiple accounts, and can also implement more
 * than a single interface for each account. Contracts can implement interfaces
 * for themselves, but externally-owned accounts (EOA) must delegate this to a
 * contract.
 *
 * `IERC165` interfaces can also be queried via the registry.
 *
 * For an in-depth explanation and source code analysis, see the EIP text.
 */


// File: src/erc777/EarnERC777.sol









contract EarnERC777 is IERC777, IERC20 {
    using SafeMath for uint256;
    using Address for address;

    uint256 constant RATE_SCALE = 10**18;

    IERC1820Registry internal _erc1820 = IERC1820Registry(0x1820a4B7618BdE71Dce8cdc73aAB6C95905faD24);

    mapping(address => uint256) internal _balances;

    uint256 internal _totalShadow;
    uint256 internal _exchangeRate;

    string internal _name;
    string internal _symbol;
    uint8 internal _decimals;

    // We inline the result of the following hashes because Solidity doesn't resolve them at compile time.
    // See https://github.com/ethereum/solidity/issues/4024.

    // keccak256("ERC777TokensSender")
    bytes32 constant internal TOKENS_SENDER_INTERFACE_HASH =
        0x29ddb589b1fb5fc7cf394961c1adf5f8c6454761adf795e67fe149f658abe895;

    // keccak256("ERC777TokensRecipient")
    bytes32 constant internal TOKENS_RECIPIENT_INTERFACE_HASH =
        0xb281fc8c12954d22544db45de3159a39272895b169a852b314f9cc762e44c53b;

    //Empty, This is only used to respond the defaultOperators query.
    address[] internal _defaultOperatorsArray;

    // For each account, a mapping of its operators and revoked default operators.
    mapping(address => mapping(address => bool)) internal _operators;

    // ERC20-allowances
    mapping (address => mapping (address => uint256)) internal _allowances;

    constructor(
        string memory name,
        string memory symbol,
        uint8 decimals
    ) public {
        require(decimals <= 18, "decimals must be less or equal than 18");

        _name = name;
        _symbol = symbol;
        _decimals = decimals;

        _exchangeRate = RATE_SCALE;

        // register interfaces
        _erc1820.setInterfaceImplementer(address(this), keccak256("ERC777Token"), address(this));
        _erc1820.setInterfaceImplementer(address(this), keccak256("ERC20Token"), address(this));
    }

    /**
     * @dev See `IERC777.name`.
     */
    function name() external view returns (string memory) {
        return _name;
    }

    /**
     * @dev See `IERC777.symbol`.
     */
    function symbol() external view returns (string memory) {
        return _symbol;
    }

    /**
     * @dev See `ERC20Detailed.decimals`.
     *
     * Always returns 18, as per the
     * [ERC777 EIP](https://eips.ethereum.org/EIPS/eip-777#backward-compatibility).
     */
    function decimals() external view returns (uint8) {
        return _decimals;
    }

    /**
     * @dev See `IERC777.granularity`.
     *
     * This implementation always returns `1`.
     */
    function granularity() external view returns (uint256) {
        return 1;
    }

    /**
     * @dev See `IERC777.totalSupply`.
     */
    function totalSupply() external view returns (uint256) {
        return _calculateValue(_totalShadow);
    }

    function totalShadow() external view returns (uint256) {
        return _totalShadow;
    }

    /**
     * @dev Returns the amount of tokens owned by an account (`tokenHolder`).
     */
    function balanceOf(address who) external view returns (uint256) {
        return _calculateValue(_balances[who]);
    }

    function shadowOf(address who) external view returns (uint256) {
        return _balances[who];
    }

    function _calculateValue(uint256 shadow) internal view returns (uint256) {
         return shadow.mul(_exchangeRate).div(RATE_SCALE);
    }

    function _calculateShadow(uint256 value) internal view returns (uint256) {
        return value.mul(RATE_SCALE).div(_exchangeRate);
    }

    /**
     * @dev See `IERC777.send`.
     *
     * Also emits a `Transfer` event for ERC20 compatibility.
     */
    function send(address recipient, uint256 amount, bytes calldata data) external {
        _send(msg.sender, msg.sender, recipient, amount, data, "", true);
    }

    /**
     * @dev See `IERC20.transfer`.
     *
     * Unlike `send`, `recipient` is _not_ required to implement the `tokensReceived`
     * interface if it is a contract.
     *
     * Also emits a `Sent` event.
     */
    function transfer(address recipient, uint256 amount) external returns (bool) {
        return _transfer(recipient, amount);
    }

    function _transfer(address recipient, uint256 amount) internal returns (bool) {
        require(recipient != address(0), "ERC777: transfer to the zero address");

        address from = msg.sender;

        uint256 shadow = _calculateShadow(amount);
        uint256 realAmount = _calculateValue(shadow);

        _callTokensToSend(from, from, recipient, realAmount, "", "");

        _move(from, from, recipient, shadow, realAmount, "", "");

        _callTokensReceived(from, from, recipient, realAmount, "", "", false);

        return true;
    }

    /**
     * @dev See `IERC777.burn`.
     *
     * Also emits a `Transfer` event for ERC20 compatibility.
     */
    function burn(uint256 amount, bytes calldata data) external {
        _burn(msg.sender, msg.sender, amount, data, "");
    }

    /**
     * @dev See `IERC777.isOperatorFor`.
     */
    function isOperatorFor(
        address operator,
        address tokenHolder
    ) public view returns (bool) {
        return operator == tokenHolder ||
            _operators[tokenHolder][operator];
    }

    /**
     * @dev See `IERC777.authorizeOperator`.
     */
    function authorizeOperator(address operator) external {
        require(msg.sender != operator, "ERC777: authorizing self as operator");

       _operators[msg.sender][operator] = true;

        emit AuthorizedOperator(operator, msg.sender);
    }

    /**
     * @dev See `IERC777.revokeOperator`.
     */
    function revokeOperator(address operator) external {
        require(operator != msg.sender, "ERC777: revoking self as operator");

        delete _operators[msg.sender][operator];

        emit RevokedOperator(operator, msg.sender);
    }

    /**
     * @dev See `IERC777.defaultOperators`.
     */
    function defaultOperators() external view returns (address[] memory) {
        return _defaultOperatorsArray;
    }

    /**
     * @dev See `IERC777.operatorSend`.
     *
     * Emits `Sent` and `Transfer` events.
     */
    function operatorSend(
        address sender,
        address recipient,
        uint256 amount,
        bytes calldata data,
        bytes calldata operatorData
    ) external {
        require(isOperatorFor(msg.sender, sender), "ERC777: caller is not an operator for holder");
        _send(msg.sender, sender, recipient, amount, data, operatorData, true);
    }

    /**
     * @dev See `IERC777.operatorBurn`.
     *
     * Emits `Sent` and `Transfer` events.
     */
    function operatorBurn(address account, uint256 amount, bytes calldata data, bytes calldata operatorData) external {
        require(isOperatorFor(msg.sender, account), "ERC777: caller is not an operator for holder");
        _burn(msg.sender, account, amount, data, operatorData);
    }

    /**
     * @dev See `IERC20.allowance`.
     *
     * Note that operator and allowance concepts are orthogonal: operators may
     * not have allowance, and accounts with allowance may not be operators
     * themselves.
     */
    function allowance(address holder, address spender) external view returns (uint256) {
        return _allowances[holder][spender];
    }

    /**
     * @dev See `IERC20.approve`.
     *
     * Note that accounts cannot have allowance issued by their operators.
     */
    function approve(address spender, uint256 value) external returns (bool) {
        address holder = msg.sender;
        _approve(holder, spender, value);
        return true;
    }

   /**
    * @dev See `IERC20.transferFrom`.
    *
    * Note that operator and allowance concepts are orthogonal: operators cannot
    * call `transferFrom` (unless they have allowance), and accounts with
    * allowance cannot call `operatorSend` (unless they are operators).
    *
    * Emits `Sent` and `Transfer` events.
    */
    function transferFrom(address holder, address recipient, uint256 amount) external returns (bool) {
        return _transferFrom(holder, recipient, amount);
    }

    function _transferFrom(address holder, address recipient, uint256 amount) internal returns (bool) {
        require(recipient != address(0), "ERC777: transfer to the zero address");
        require(holder != address(0), "ERC777: transfer from the zero address");

        address spender = msg.sender;

        uint256 shadow = _calculateShadow(amount);
        uint256 realAmount = _calculateValue(shadow);

        _callTokensToSend(spender, holder, recipient, realAmount, "", "");

        _move(spender, holder, recipient, shadow, realAmount, "", "");
        _approve(holder, spender, _allowances[holder][spender].sub(realAmount));

        _callTokensReceived(spender, holder, recipient, realAmount, "", "", false);

        return true;
    }

    /**
     * @dev Creates `amount` tokens and assigns them to `account`, increasing
     * the total supply.
     *
     * If a send hook is registered for `raccount`, the corresponding function
     * will be called with `operator`, `data` and `operatorData`.
     *
     * See `IERC777Sender` and `IERC777Recipient`.
     *
     * Emits `Sent` and `Transfer` events.
     *
     * Requirements
     *
     * - `account` cannot be the zero address.
     * - if `account` is a contract, it must implement the `tokensReceived`
     * interface.
     */
    function _mint(
        address operator,
        address account,
        uint256 amount,
        bytes memory userData,
        bytes memory operatorData
    )
    internal
    {
        require(account != address(0), "ERC777: mint to the zero address");

        uint shadow = _calculateShadow(amount);
        uint realAmount = _calculateValue(shadow);

        // Update state variables
        _totalShadow = _totalShadow.add(shadow);
        _balances[account] = _balances[account].add(shadow);

        _callTokensReceived(operator, address(0), account, realAmount, userData, operatorData, false);

        emit Minted(operator, account, realAmount, userData, operatorData);
        emit Transfer(address(0), account, realAmount);
    }

    /**
     * @dev Send tokens
     * @param operator address operator requesting the transfer
     * @param from address token holder address
     * @param to address recipient address
     * @param amount uint256 amount of tokens to transfer
     * @param userData bytes extra information provided by the token holder (if any)
     * @param operatorData bytes extra information provided by the operator (if any)
     * @param requireReceptionAck if true, contract recipients are required to implement ERC777TokensRecipient
     */
    function _send(
        address operator,
        address from,
        address to,
        uint256 amount,
        bytes memory userData,
        bytes memory operatorData,
        bool requireReceptionAck
    )
        internal
    {
        require(from != address(0), "ERC777: send from the zero address");
        require(to != address(0), "ERC777: send to the zero address");

        uint256 shadow = _calculateShadow(amount);
        uint256 realAmount = _calculateValue(shadow);

        _callTokensToSend(operator, from, to, realAmount, userData, operatorData);

        _move(operator, from, to, shadow, realAmount, userData, operatorData);

        _callTokensReceived(operator, from, to, realAmount, userData, operatorData, requireReceptionAck);
    }

    /**
     * @dev Burn tokens
     * @param operator address operator requesting the operation
     * @param from address token holder address
     * @param amount uint256 amount of tokens to burn
     * @param data bytes extra information provided by the token holder
     * @param operatorData bytes extra information provided by the operator (if any)
     */
    function _burn(
        address operator,
        address from,
        uint256 amount,
        bytes memory data,
        bytes memory operatorData
    )
        internal
    {
        require(from != address(0), "ERC777: burn from the zero address");

        uint256 shadow = _calculateShadow(amount);
        uint256 realAmount = _calculateValue(shadow);

        _callTokensToSend(operator, from, address(0), realAmount, data, operatorData);

        // Update state variables
        _totalShadow = _totalShadow.sub(shadow);
        _balances[from] = _balances[from].sub(shadow);

        emit Burned(operator, from, realAmount, data, operatorData);
        emit Transfer(from, address(0), realAmount);
    }

    function _move(
        address operator,
        address from,
        address to,
        uint256 shadow,
        uint256 amount,
        bytes memory userData,
        bytes memory operatorData
    )
        internal
    {
        _balances[from] = _balances[from].sub(shadow);
        _balances[to] = _balances[to].add(shadow);

        emit Sent(operator, from, to, amount, userData, operatorData);
        emit Transfer(from, to, amount);
    }

    function _approve(address holder, address spender, uint256 value) internal {
        // TODO: restore this require statement if this function becomes internal, or is called at a new callsite. It is
        // currently unnecessary.
        //require(holder != address(0), "ERC777: approve from the zero address");
        require(spender != address(0), "ERC777: approve to the zero address");

        _allowances[holder][spender] = value;
        emit Approval(holder, spender, value);
    }

    /**
     * @dev Call from.tokensToSend() if the interface is registered
     * @param operator address operator requesting the transfer
     * @param from address token holder address
     * @param to address recipient address
     * @param amount uint256 amount of tokens to transfer
     * @param userData bytes extra information provided by the token holder (if any)
     * @param operatorData bytes extra information provided by the operator (if any)
     */
    function _callTokensToSend(
        address operator,
        address from,
        address to,
        uint256 amount,
        bytes memory userData,
        bytes memory operatorData
    )
        internal
    {
        address implementer = _erc1820.getInterfaceImplementer(from, TOKENS_SENDER_INTERFACE_HASH);
        if (implementer != address(0)) {
            IERC777Sender(implementer).tokensToSend(operator, from, to, amount, userData, operatorData);
        }
    }

    /**
     * @dev Call to.tokensReceived() if the interface is registered. Reverts if the recipient is a contract but
     * tokensReceived() was not registered for the recipient
     * @param operator address operator requesting the transfer
     * @param from address token holder address
     * @param to address recipient address
     * @param amount uint256 amount of tokens to transfer
     * @param userData bytes extra information provided by the token holder (if any)
     * @param operatorData bytes extra information provided by the operator (if any)
     * @param requireReceptionAck if true, contract recipients are required to implement ERC777TokensRecipient
     */
    function _callTokensReceived(
        address operator,
        address from,
        address to,
        uint256 amount,
        bytes memory userData,
        bytes memory operatorData,
        bool requireReceptionAck
    )
        internal
    {
        address implementer = _erc1820.getInterfaceImplementer(to, TOKENS_RECIPIENT_INTERFACE_HASH);
        if (implementer != address(0)) {
            IERC777Recipient(implementer).tokensReceived(operator, from, to, amount, userData, operatorData);
        } else if (requireReceptionAck) {
            require(!to.isContract(), "ERC777: token recipient contract has no implementer for ERC777TokensRecipient");
        }
    }

    function _distributeRevenue(address account) internal returns (bool) {
        uint256 shadow = _balances[account];

        require(_totalShadow != 0, 'Token: total shadow must be zero');
        require(shadow > 0, 'Token: the revenue must large than 0');

        uint256 value = _calculateValue(shadow);

        _balances[account] = 0;
        _totalShadow = _totalShadow.sub(shadow);
        _exchangeRate = _exchangeRate.add(value.mul(RATE_SCALE).div(_totalShadow));

        emit Transfer(account, address(0), value);
        emit RevenueDistributed(account, value);

        return true;
    }

    function exchangeRate() external view returns (uint256) {
        return _exchangeRate;
    }

    event RevenueDistributed(address indexed account, uint256 value);
}

// File: openzeppelin-solidity/contracts/access/Roles.sol


/**
 * @title Roles
 * @dev Library for managing addresses assigned to a Role.
 */


// File: src/Ownable.sol


/**
 * @dev Contract module which provides a basic access control mechanism, where
 * there is an account (an owner) that can be granted exclusive access to
 * specific functions.
 *
 * This module is used through inheritance. It will make available the modifier
 * `onlyOwner`, which can be aplied to your functions to restrict their use to
 * the owner.
 */


// File: src/MinterRole.sol




 contract MinterRole is Ownable {
     using Roles for Roles.Role;

     event MinterAdded(address indexed operator, address indexed account);
     event MinterRemoved(address indexed operator, address indexed account);

     Roles.Role private _minters;

     constructor () internal {
         _addMinter(msg.sender);
     }

     modifier onlyMinter() {
         require(isMinter(msg.sender), "MinterRole: caller does not have the Minter role");
         _;
     }

     function isMinter(address account) public view returns (bool) {
         return _minters.has(account);
     }

     function addMinter(address account) public onlyOwner {
         _addMinter(account);
     }

     function removeMinter(address account) public onlyOwner {
         _removeMinter(account);
     }

     function _addMinter(address account) internal {
         _minters.add(account);
         emit MinterAdded(msg.sender, account);
     }

     function _removeMinter(address account) internal {
         _minters.remove(account);
         emit MinterRemoved(msg.sender, account);
     }
 }

// File: src/Pausable.sol



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
     * @dev Emitted when the pause is triggered by a pauser (`account`).
     */
    event Paused(address indexed account);

    /**
     * @dev Emitted when the pause is lifted by a pauser (`account`).
     */
    event Unpaused(address indexed account);

    bool private _paused;

    /**
     * @dev Initializes the contract in unpaused state. Assigns the Pauser role
     * to the deployer.
     */
    constructor () internal {
        _paused = false;
    }

    /**
     * @dev Returns true if the contract is paused, and false otherwise.
     */
    function paused() public view returns (bool) {
        return _paused;
    }

    /**
     * @dev Modifier to make a function callable only when the contract is not paused.
     */
    modifier whenNotPaused() {
        require(!_paused, "Pausable: paused");
        _;
    }

    /**
     * @dev Modifier to make a function callable only when the contract is paused.
     */
    modifier whenPaused() {
        require(_paused, "Pausable: not paused");
        _;
    }

    /**
     * @dev Called by a pauser to pause, triggers stopped state.
     */
    function pause() public onlyOwner whenNotPaused {
        _paused = true;
        emit Paused(msg.sender);
    }

    /**
     * @dev Called by a pauser to unpause, returns to normal state.
     */
    function unpause() public onlyOwner whenPaused {
        _paused = false;
        emit Unpaused(msg.sender);
    }
}

// File: src/SwitchTransferable.sol



contract SwitchTransferable is Ownable {
    event TransferEnabled(address indexed operator);
    event TransferDisabled(address indexed operator);

    bool private _transferable;

    constructor () internal {
        _transferable = false;
    }

    modifier whenTransferable() {
        require(_transferable, "transferable must be true");
        _;
    }

    modifier whenNotTransferable() {
        require(!_transferable, "transferable must not be true");
        _;
    }

    function transferable() public view returns (bool) {
        return _transferable;
    }

    function enableTransfer() public onlyOwner whenNotTransferable {
        _transferable = true;
        emit TransferEnabled(msg.sender);
    }

    function disableTransfer() public onlyOwner whenTransferable {
        _transferable = false;
        emit TransferDisabled(msg.sender);
    }
}

// File: src/IMBTC.sol






contract IMBTC is EarnERC777, MinterRole, Pausable, SwitchTransferable {
    address internal _revenueAddress;

    constructor() EarnERC777("IMBTC","IMBTC",8) public {
    }

    function transfer(address recipient, uint256 amount) external whenNotPaused whenTransferable returns (bool) {
        return super._transfer(recipient, amount);
    }

    function send(address recipient, uint256 amount, bytes calldata data) external whenTransferable whenNotPaused {
        super._send(msg.sender, msg.sender, recipient, amount, data, "", true);
    }

    function burn(uint256 amount, bytes calldata data) external whenTransferable whenNotPaused {
        super._burn(msg.sender, msg.sender, amount, data, "");
    }

    function operatorSend(
        address sender,
        address recipient,
        uint256 amount,
        bytes calldata data,
        bytes calldata operatorData
    ) external whenTransferable whenNotPaused {
        require(isOperatorFor(msg.sender, sender), "ERC777: caller is not an operator for holder");
        super._send(msg.sender, sender, recipient, amount, data, operatorData, true);
    }

    function operatorBurn(address account, uint256 amount, bytes calldata data, bytes calldata operatorData)
        external whenTransferable whenNotPaused {
        require(isOperatorFor(msg.sender, account), "ERC777: caller is not an operator for holder");
        super._burn(msg.sender, account, amount, data, operatorData);
    }

    function mint(address recipient, uint256 amount,
            bytes calldata userData, bytes calldata operatorData) external onlyMinter whenNotPaused {
        super._mint(msg.sender, recipient, amount, userData, operatorData);
    }

    function transferFrom(address holder, address recipient, uint256 amount) external whenNotPaused returns (bool) {
        require(transferable(), "Token: transferable must be true");
        return super._transferFrom(holder, recipient, amount);
   }

   function setRevenueAddress(address account) external onlyOwner {
       _revenueAddress = account;

       emit RevenueAddressSet(account);
   }

   function revenueAddress() external view returns (address) {
       return _revenueAddress;
   }

   function revenue() external view returns (uint256) {
       return _calculateValue(_balances[_revenueAddress]);
   }

   event RevenueAddressSet(address indexed account);

   function distributeRevenue() external whenNotPaused {
       require(_revenueAddress != address(0), 'Token: revenue address must not be zero');

       _distributeRevenue(_revenueAddress);
   }
}