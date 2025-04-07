/**
 *Submitted for verification at Etherscan.io on 2021-06-14
*/

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

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
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}

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




contract Splitter is Ownable {
    using Address for address;

    address payable private _feeAddress;

    event splitEvent(address from, address to, uint256 amount, uint256 fee);
    event donationEvent(address from, uint256 amount);
    event withdrawEvent(address to, uint256 amount);

    constructor() {
        _feeAddress = payable(owner());
    }

    function changeFeeAddress(address newFeeAddress) public onlyOwner {
        require(newFeeAddress != address(0), "Splitter: wrong fee address");
        require(
            !newFeeAddress.isContract(),
            "Splitter: fee address can't be a contract address"
        );
        _feeAddress = payable(newFeeAddress);
    }

    function split(address payable to, uint256 feePercent) public payable {
        if (feePercent > 100) feePercent = 100;
        uint256 change = msg.value % 100;
        uint256 total = msg.value - change;
        uint256 fee = (total / 100) * feePercent + change;
        uint256 value = (total / 100) * (100 - feePercent);
        if (fee > 0) {
            // keep in a contract - don't transfer
            //_feeAddress.transfer(fee);
            if (value == 0) {
                emit donationEvent(msg.sender, fee);
            }
        }
        if (value > 0) {
            to.transfer(value);
            emit splitEvent(msg.sender, to, value, fee);
        }
    }

    function withdraw() public onlyOwner {
        uint256 contractBalance = address(this).balance;
        if (contractBalance > 0) {
            _feeAddress.transfer(contractBalance);
            emit withdrawEvent(_feeAddress, contractBalance);
        }
    }
}