/**
 *Submitted for verification at Etherscan.io on 2021-08-13
*/

//SPDX-License-Identifier: MIT

pragma solidity ^0.5.0;


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
 * @dev Interface of the ERC20 standard as defined in the EIP. Does not include
 * the optional functions; to access them see {ERC20Detailed}.
 */


contract NFTPOE is Ownable {
    uint256 public nftid;
    mapping(address => bool) private purchased;
    mapping(address => bool) private blacklist;
    address public seller;
    address public rarigang;
    address public currency;
    address public gdao;
    

    constructor(uint256 _nftid, address _seller, address _rarigang, address _currency, address _gdao) public{
        nftid = _nftid;
        seller = _seller;
        rarigang = _rarigang;
        currency = _currency;
        gdao = _gdao;
    }
    
    function addBlacklist(address user) public onlyOwner{
        blacklist[user] = true;
    }

    function addManyBlacklist(address[] memory user) public onlyOwner{
        for (uint i = 0; i < user.length; i++){
            blacklist[user[i]] = true;
        }
    }

    function removeBlacklist(address user) public onlyOwner{
        blacklist[user] = false;
    }

    function isBlacklisted(address user) public view returns (bool){
        return blacklist[user];
    }

    function hasPurchased(address buyer) public view returns (bool){
        return purchased[buyer];
    }

    function purchase() public {
        require(!isBlacklisted(msg.sender), "Cannot buy: blacklisted wallet!");
        require(IERC20(currency).balanceOf(msg.sender) == 1, "Need to authenticate first!");
        require(IERC20(gdao).balanceOf(msg.sender) >= 50*1e18, "Must hold 50 GDAO!");
        require(!hasPurchased(msg.sender), "Cannot buy: Already purchased!");
        require(IERC1155(rarigang).balanceOf(seller, nftid) > 0, "Cannot buy: No more available!");
        IERC1155(rarigang).safeTransferFrom(seller, msg.sender, nftid, 1, "");
        purchased[msg.sender] = true;
    }
}