/**
 *Submitted for verification at Etherscan.io on 2021-08-05
*/

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

// CAUTION
// This version of SafeMath should only be used with Solidity 0.8 or later,
// because it relies on the compiler's built in overflow checks.

/**
 * @dev Wrappers over Solidity's arithmetic operations.
 *
 * NOTE: `SafeMath` is no longer needed starting with Solidity 0.8. The compiler
 * now has built in overflow checking.
 */


/*
 * @dev Provides information about the current execution context, including the
 * sender of the transaction and its data. While these are generally available
 * via msg.sender and msg.data, they should not be accessed in such a direct
 * manner, since when dealing with meta-transactions the account sending and
 * paying for execution may not be the actual sender (as far as an application
 * is concerned).
 *
 * This contract is only required for intermediate, library-like contracts.
 */
abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}

/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
 */


/**
 * @dev Interface for the optional metadata functions from the ERC20 standard.
 *
 * _Available since v4.1._
 */
interface IERC20Metadata is IERC20 {
    /**
     * @dev Returns the name of the token.
     */
    function name() external view returns (string memory);

    /**
     * @dev Returns the symbol of the token.
     */
    function symbol() external view returns (string memory);

    /**
     * @dev Returns the decimals places of the token.
     */
    function decimals() external view returns (uint8);
}

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
abstract contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(
        address indexed previousOwner,
        address indexed newOwner
    );

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    constructor() {
        _setOwner(_msgSender());
    }

    /**
     * @dev Returns the address of the current owner.
     */
    function owner() public view virtual returns (address) {
        return _owner;
    }

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
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
        _setOwner(address(0));
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
        _setOwner(newOwner);
    }

    function _setOwner(address newOwner) private {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
}

contract VegionBonus is Context, Ownable {
    using SafeMath for uint256;

    address public farm;
    IERC20 public vt;

    mapping(address => uint8) public bonusPercent_100;
    mapping(address => address) public parents;

    constructor(address _farm, IERC20 _vt) {
        farm = _farm;
        vt = _vt;
    }

    function batchSetBonusPercent(
        address[] memory targets,
        uint8[] memory percents
    ) public onlyOwner {
        require(targets.length == percents.length, "length not equal");
        for (uint256 i = 0; i < targets.length; i++) {
            if (targets[i] != address(0)) {
                bonusPercent_100[targets[i]] = percents[i];
            }
        }
    }

    function setBonusPercent(address target, uint8 percent) public onlyOwner {
        require(target != address(0), "address cannot be zero");
        bonusPercent_100[target] = percent;
    }

    function setParent(address target, address parent) public {
        require(target != address(0), "target cannot be zero");
        require(parent != address(0), "target cannot be zero");
        require(
            _msgSender() == owner() || _msgSender() == address(farm),
            "wrong caller"
        );

        parents[target] = parent;
    }

    // Safe vt transfer function, just in case if rounding error causes pool to not have enough Vts.
    function safeVtTransfer(address _to, uint256 _amount) external {
        require(
            _msgSender() == owner() || _msgSender() == address(farm),
            "wrong caller"
        );
        uint256 vtBal = vt.balanceOf(address(this));
        if (_amount > vtBal) {
            vt.transfer(_to, vtBal);
        } else {
            vt.transfer(_to, _amount);
        }
    }
}