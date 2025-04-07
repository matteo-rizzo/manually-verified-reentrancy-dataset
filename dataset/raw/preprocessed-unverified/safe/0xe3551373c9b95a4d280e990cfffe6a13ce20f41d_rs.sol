/**
 *Submitted for verification at Etherscan.io on 2021-09-30
*/

pragma solidity ^0.8.0;


// SPDX-License-Identifier: MIT
/**
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



contract FeesOnTheBlock is Ownable {
    using SafeMath for uint;

    address public immutable COMMUNITY_WALLET;
    address public immutable TEAM_WALLET;
    address public immutable F1_WALLET;
    address public immutable F2_WALLET;
    address public immutable F3_WALLET;

    constructor(){
        COMMUNITY_WALLET = address(0xa87309f3b5096751d999b94C994F61D64183311D);
        TEAM_WALLET = address(0x7E3D3F0162bDEc5C86202a6A59d187fd2AFF226f);
        F1_WALLET = address(0x683C93BA044f46Da166F9181Ec48C535941B670F);
        F2_WALLET = address(0xA1d553AEF57d8619227F996a741f47dcd94CBE18);
        F3_WALLET = address(0xAF1fFb3Bd44f04d3cdC1301176FDCDB9CCd081d2); 
    }

    receive() external payable {

    }

    function withdraw() public onlyOwner {
        uint balance = address(this).balance;

        payable(COMMUNITY_WALLET).transfer(balance.div(10).mul(4));
        payable(TEAM_WALLET).transfer(balance.div(10).mul(3));
        payable(F1_WALLET).transfer(balance.div(10));
        payable(F2_WALLET).transfer(balance.div(10));
        payable(F3_WALLET).transfer(balance.div(10));
    }
}