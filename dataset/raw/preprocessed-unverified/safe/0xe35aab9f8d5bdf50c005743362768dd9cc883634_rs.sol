/**
 *Submitted for verification at Etherscan.io on 2021-02-20
*/

// SPDX-License-Identifier: GPL-3.0-or-later

pragma solidity 0.7.1;



// Part: IKeepRandomBeaconOperator



// Part: openzeppelin/[email protected]/Context

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

// Part: openzeppelin/[email protected]/IERC20

/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
 */


// Part: openzeppelin/[email protected]/Ownable

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

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    constructor () {
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
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}

// File: BulkClaimer.sol

/*
BulkClaimer's withdrawal methods only ever send eth to the owner.
These are only used when tokens or eth is accidentally sent to this contract.
*/
contract BulkClaimer is Ownable {
    IKeepRandomBeaconOperator private randomBeaconOperator;

    event ReceivedEther(address, uint);

    // solhint-disable-next-line func-visibility
    constructor(address randomBeaconOperatorAddress) {
        randomBeaconOperator = IKeepRandomBeaconOperator(randomBeaconOperatorAddress);
    }

    /*
    Withdraw eth to the contract owner
    */
    function withdrawEth(uint amount) public {
        require(amount <= address(this).balance);

        // must use type "address payable", to send eth, not just "address"
        address payable payableOwner = payable(owner());
        payableOwner.transfer(amount);
    }

    /*
    Withdraw an arbitrary erc20 token to the contract owner
    */
    function withdrawERC20(uint amount, IERC20 token) public {
        require(amount <= token.balanceOf(address(this)));

        token.transfer(owner(), amount);
    }

    /*
    Claim beacon rewards in bulk for a given list of beacon groups
    */
    function claimBeaconEarnings(uint256[] calldata groupIndicies, address operator) public {
        for (uint256 i = 0; i < groupIndicies.length; i++) {
            randomBeaconOperator.withdrawGroupMemberRewards(operator, groupIndicies[i]);
        }
    }

    /*
    To make this contract able to receive ether

    NOTE: solhint doesn't seem to understand the receive function w/out function keyword...
    */
    /* solhint-disable */
    receive() external payable {
        emit ReceivedEther(msg.sender, msg.value);
    }
    /* solhint-enable */
}