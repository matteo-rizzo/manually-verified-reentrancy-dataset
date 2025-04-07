/**
 *Submitted for verification at Etherscan.io on 2021-04-16
*/

// SPDX-License-Identifier: NONE

pragma solidity 0.7.6;



// Part: Address

/**
 * @dev Collection of functions related to the address type
 */


// Part: Context

contract Context {
    // Empty internal constructor, to prevent people from mistakenly deploying
    // an instance of this contract, which should be used via inheritance.
    constructor() {}

    // solhint-disable-previous-line no-empty-blocks

    function _msgSender() internal view returns (address payable) {
        return msg.sender;
    }

    function _msgData() internal view returns (bytes memory) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}

// Part: IERC20

/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
 */


// Part: IVault



// Part: SafeMath

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



// Part: Ownable

contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(
        address indexed previousOwner,
        address indexed newOwner
    );

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    constructor() {
        address msgSender = _msgSender();
        _owner = msgSender;
        emit OwnershipTransferred(address(0), msgSender);
    }

    /**
     * @dev Returns the address of the current owner.
     */
    function owner() public view returns (address) {
        return _owner;
    }

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        require(isOwner(), "Ownable: caller is not the owner");
        _;
    }

    /**
     * @dev Returns true if the caller is the current owner.
     */
    function isOwner() public view returns (bool) {
        return _msgSender() == _owner;
    }

    /**
     * @dev Leaves the contract without owner. It will not be possible to call
     * `onlyOwner` functions anymore. Can only be called by the current owner.
     *
     * NOTE: Renouncing ownership will leave the contract without an owner,
     * thereby removing any functionality that is only available to the owner.
     */
    function renounceOwnership() public onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) public onlyOwner {
        _transferOwnership(newOwner);
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     */
    function _transferOwnership(address newOwner) internal {
        require(
            newOwner != address(0),
            "Ownable: new owner is the zero address"
        );
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}

// Part: SafeERC20

/**
 * @title SafeERC20
 * @dev Wrappers around ERC20 operations that throw on failure (when the token
 * contract returns false). Tokens that return no value (and instead revert or
 * throw on failure) are also supported, non-reverting calls are assumed to be
 * successful.
 * To use this library you can add a `using SafeERC20 for ERC20;` statement to your contract,
 * which allows you to call the safe operations as `token.safeTransfer(...)`, etc.
 */


// File: Vault.sol

/** 
 * @title Vault
 * @notice This contract is responsible for storing FET tokens being deposited by users
 * which can be withdrawn by the contract admin and send directly to an address
 */ 
contract Vault is IVault, Ownable {
    using SafeERC20 for IERC20;
    using Address for address;

    address public admin;
    address public fundsDepositAddress;
    address public token;

    modifier onlyAdmin() {
        require(msg.sender == admin, "!Admin");
        _;
    }

    /** 
     * @param _admin: the admin address authorised to call withdraw funds function
     * @param _fundsDepositAddress: the address where the funds withdrawn will be sent to
     * @param _token: FET token address
     */ 
    constructor(
        address _admin,
        address _fundsDepositAddress,
        address _token
    ) {
        require(
            _admin != address(0) &&
                _fundsDepositAddress != address(0) &&
                _token != address(0),
            "!zero address"
        );
        admin = _admin;
        fundsDepositAddress = _fundsDepositAddress;
        token = _token;
    }

    /** 
     * @notice Public function that allows users to send FET to the contract
     * The amount being sent must be approved by the user first.
     * Emits the deposit event
     * @param amount: the FET amount to be sent to the vault
     */ 
    function deposit(uint256 amount) external override returns (bool) {
        require(amount > 0, "Amount can't be 0");
        IERC20(token).safeTransferFrom(msg.sender, address(this), amount);

        emit fundsDeposited(token, msg.sender, amount);
        return true;
    }

    /** 
     * @notice Function to withdraw funds from the vault. Can only be called by admin
     * @param amount: the amount to withdraw (should be <= than the amount in vault)
     */ 
    function withdraw(uint256 amount)
        external
        override
        onlyAdmin
        returns (bool)
    {
        require(amount > 0, "Amount can't be 0");
        require(
            IERC20(token).balanceOf(address(this)) >= amount,
            "Amount > Balance"
        );

        IERC20(token).safeTransfer(fundsDepositAddress, amount);
        return true;
    }

    /** 
     * @notice Withdraws the whole balance of the Vault. Can only be called by admin
     */ 
    function withdrawAll() external override onlyAdmin returns (bool) {
        uint256 balance = IERC20(token).balanceOf(address(this));
        require(balance > 0, "Nothing to withdraw");

        IERC20(token).safeTransfer(fundsDepositAddress, balance);
        return true;
    }

    /** 
     * @notice Function to send funds from vault to a user. Can only be called by admin
     * @param user: user address to send FET to
     * @param amount: the amount to send
     */ 
    function refund(address user, uint256 amount)
        external
        override
        onlyAdmin
        returns (bool)
    {
        require(user != address(0), "User zero address");
        require(amount > 0, "Zero amount");
        require(
            IERC20(token).balanceOf(address(this)) > amount,
            "Amount > balance"
        );

        IERC20(token).safeTransfer(user, amount);
        fundsRefunded(token, user, amount);
        return true;
    }

    /** 
     * @notice Function to send funds to vault as admin. Can only be called by admin
     * This does not trigger a deposit event
     * @param amount: the amount to send
     */ 
    function depositAdmin(uint256 amount)
        external
        override
        onlyAdmin
        returns (bool)
    {
        require(amount > 0, "Amount can't be 0");
        IERC20(token).safeTransferFrom(msg.sender, address(this), amount);
        return true;
    }

    /** 
    * @notice Updates admin address, can only be called by owner of the contract
    * @param _newAdmin: new address for admin
    */
    function updateAdmin(address _newAdmin)
        external
        override
        onlyOwner
        returns (bool)
    {
        require(_newAdmin != address(0), "new admin zero address");
        admin = _newAdmin;
        return true;
    }

    /** 
    * @notice Updates fundsDepositAddress, can only be called by owner of the contract
    * @param _newFundsDepositAddress: new address for fundsDepositAddress
    */
    function updateFundsDepositAddress(address _newFundsDepositAddress)
        external
        override
        onlyOwner
        returns (bool)
    {
        require(
            _newFundsDepositAddress != address(0),
            "new FundsDepositAddress zero address"
        );
        fundsDepositAddress = _newFundsDepositAddress;
        return true;
    }

    /** 
    * @notice Updates FET token address, can only be called by owner of the contract
    * Also makes sure that previous token balance is sent to fundsDepositAddress before
    * updating token address
    * @param _newToken: new address for FET deposit token
    */
    function updateToken(address _newToken)
        external
        override
        onlyOwner
        returns (bool)
    {
        require(_newToken != address(0), "new token zero address");

        uint256 balance = IERC20(token).balanceOf(address(this));

        if (balance > 0) {
            IERC20(token).safeTransfer(fundsDepositAddress, balance);
        }

        token = _newToken;
        return true;
    }
}