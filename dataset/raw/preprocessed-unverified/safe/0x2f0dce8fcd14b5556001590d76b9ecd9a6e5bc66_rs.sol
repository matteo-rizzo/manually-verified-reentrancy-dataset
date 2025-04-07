/**
 *Submitted for verification at Etherscan.io on 2021-09-16
*/

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
        return msg.data;
    }
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

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

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
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        _setOwner(newOwner);
    }

    function _setOwner(address newOwner) private {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
}


// CAUTION
// This version of SafeMath should only be used with Solidity 0.8 or later,
// because it relies on the compiler's built in overflow checks.
/**
 * @dev Wrappers over Solidity's arithmetic operations.
 *
 * NOTE: `SafeMath` is no longer needed starting with Solidity 0.8. The compiler
 * now has built in overflow checking.
 */


//SPDX-License-Identifier: Unlicense


contract MassMint is Ownable {

    using SafeMath for uint256;

    address public nftAddress;
    uint256 public price = 2E16; // 0.02 ETH
    uint256 public maxMintCount = 20; // max mint count at a time

    event MassMinted(address indexed _to, uint256 indexed _count);
    event MassPresaleMinted(address indexed _to, uint256 indexed _count);

    constructor() {}

    function massMint(address _to, uint256 _count) public payable {
        require(msg.value >= price.mul(_count), "Value below price");

        uint256 mintLeft = _count;
        while(mintLeft >= maxMintCount) {
            INFT(nftAddress).mint{value: price.mul(maxMintCount)}(_to, maxMintCount);
            mintLeft -= maxMintCount;
        }

        if(mintLeft > 0) {
            INFT(nftAddress).mint{value: price.mul(mintLeft)}(_to, mintLeft);
        }

        emit MassMinted(_to, _count);
    }

    function massPresaleMint(address _to, uint256 _count) public payable {
        require(msg.value >= price.mul(_count), "Value below price");

        uint256 mintLeft = _count;
        while(mintLeft >= maxMintCount) {
            INFT(nftAddress).presaleMint{value: price.mul(maxMintCount)}(_to, maxMintCount);
            mintLeft -= maxMintCount;
        }

        if(mintLeft > 0) {
            INFT(nftAddress).presaleMint{value: price.mul(mintLeft)}(_to, mintLeft);
        }

        emit MassPresaleMinted(_to, _count);
    }

    function setNftAddress(address _nftAddress) public onlyOwner {
        nftAddress = _nftAddress;
    }

    function setPrice(uint256 _price) public onlyOwner {
        price = _price;
    }

    function setMaxMintCount(uint256 _maxMintCount) public onlyOwner {
        maxMintCount = _maxMintCount;
    }

    function withdrawAll() public payable onlyOwner {
        uint256 balance = address(this).balance;
        require(balance > 0);
        _widthdraw(owner(), balance);
    }

    function _widthdraw(address _address, uint256 _amount) private {
        (bool success,) = _address.call{value : _amount}("");
        require(success, "Transfer failed.");
    }
}