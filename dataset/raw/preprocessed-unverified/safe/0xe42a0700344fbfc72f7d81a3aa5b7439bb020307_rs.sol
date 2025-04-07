/**
 *Submitted for verification at Etherscan.io on 2021-03-05
*/

pragma solidity ^0.5.16;


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
contract Context {
    // Empty internal constructor, to prevent people from mistakenly deploying
    // an instance of this contract, which should be used via inheritance.
    constructor () internal { }
    // solhint-disable-previous-line no-empty-blocks

    function _msgSender() internal view returns (address payable) {
        return msg.sender;
    }

    function _msgData() internal view returns (bytes memory) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}

/**
 * @dev Contract module which provides a basic access control mechanism, where
 * there is an account (an owner) that can be granted exclusive access to
 * specific functions.
 *
 * This module is used through inheritance. It will make available the modifier
 * `onlyOwner`, which can be applied to your functions to restrict their use to
 * the owner.
 */
contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    constructor () internal {
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
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}

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


contract IReleaser {
    function release() external;

    function isReleaser() external pure returns (bool) {
        return true;
    }
}

contract TokenSplitter is IReleaser, Ownable {
    using SafeMath for uint256;
    using SafeERC20 for IERC20;

    event PayeeAdded(address account, uint256 shares);
    event PaymentReleased(address to, uint256 amount);

    IERC20 public token;

    address[] public payees;
    mapping(address => uint256) public shares;
    mapping(address => bool) public releasers;

    uint256 private _totalShares;

    constructor (IERC20 token_, address[] memory payees_, uint256[] memory shares_, bool[] memory releasers_) public {
        require(address(token_) != address(0), "TokenSplitter: token is the zero address");
        require(payees_.length == shares_.length, "TokenSplitter: payees and shares length mismatch");
        require(payees_.length == releasers_.length, "TokenSplitter: payees and releasers length mismatch");
        require(payees_.length > 0, "TokenSplitter: no payees");

        token = token_;
        for (uint256 i = 0; i < payees_.length; i++) {
            _addPayee(payees_[i], shares_[i], releasers_[i]);
        }
    }

    function payeesCount() public view returns (uint256) {
        return payees.length;
    }

    function totalShares() public view returns (uint256) {
        return _totalShares;
    }

    function release() external onlyOwner {
        uint256 balance = token.balanceOf(address(this));
        if (balance > 0) {
            for (uint256 i = 0; i < payees.length; i++) {
                address account = payees[i];
                uint256 payment = balance.mul(shares[account]).div(_totalShares);
                if (payment > 0) {
                    token.safeTransfer(account, payment);
                    if (releasers[account]) {
                        IReleaser(address(account)).release();
                    }
                    emit PaymentReleased(account, payment);
                }
            }
        }
    }

    function _addPayee(address account_, uint256 shares_, bool releaser_) private {
        require(account_ != address(0), "TokenSplitter: account is the zero address");
        require(shares_ > 0, "TokenSplitter: shares are 0");
        require(shares[account_] == 0, "TokenSplitter: account already has shares");
        // if announced as releaser - should implement interface 
        require(
            !releaser_ || IReleaser(account_).isReleaser(), 
            "TokenSplitter: account releaser status wrong"
        );

        payees.push(account_);
        shares[account_] = shares_;
        releasers[account_] = releaser_;
        _totalShares = _totalShares.add(shares_);
        emit PayeeAdded(account_, shares_);
    }
}

contract Reserved is TokenSplitter {
    constructor(
        IERC20 token_, address[] memory payees_, uint256[] memory shares_, bool[] memory releasers_
    ) public TokenSplitter(token_, payees_, shares_, releasers_) {
    }
}