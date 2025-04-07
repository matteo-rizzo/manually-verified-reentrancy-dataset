/**
 *Submitted for verification at Etherscan.io on 2021-08-30
*/

pragma solidity ^0.8.0;


// SPDX-License-Identifier: MIT
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


/**
 * @dev Elliptic Curve Digital Signature Algorithm (ECDSA) operations.
 *
 * These functions can be used to verify that a message was signed by the holder
 * of the private keys of a given address.
 */



// CAUTION
// This version of SafeMath should only be used with Solidity 0.8 or later,
// because it relies on the compiler's built in overflow checks.
/**
 * @dev Wrappers over Solidity's arithmetic operations.
 *
 * NOTE: `SafeMath` is no longer needed starting with Solidity 0.8. The compiler
 * now has built in overflow checking.
 */



/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
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
 * To use this library you can add a `using SafeERC20 for IERC20;` statement to your contract,
 * which allows you to call the safe operations as `token.safeTransfer(...)`, etc.
 */



/**
 * @dev Contract module that helps prevent reentrant calls to a function.
 *
 * Inheriting from `ReentrancyGuard` will make the {nonReentrant} modifier
 * available, which can be applied to functions to make sure there are no nested
 * (reentrant) calls to them.
 *
 * Note that because there is a single `nonReentrant` guard, functions marked as
 * `nonReentrant` may not call one another. This can be worked around by making
 * those functions `private`, and then adding `external` `nonReentrant` entry
 * points to them.
 *
 * TIP: If you would like to learn more about reentrancy and alternative ways
 * to protect against it, check out our blog post
 * https://blog.openzeppelin.com/reentrancy-after-istanbul/[Reentrancy After Istanbul].
 */
abstract contract ReentrancyGuard {
    // Booleans are more expensive than uint256 or any type that takes up a full
    // word because each write operation emits an extra SLOAD to first read the
    // slot's contents, replace the bits taken up by the boolean, and then write
    // back. This is the compiler's defense against contract upgrades and
    // pointer aliasing, and it cannot be disabled.

    // The values being non-zero value makes deployment a bit more expensive,
    // but in exchange the refund on every call to nonReentrant will be lower in
    // amount. Since refunds are capped to a percentage of the total
    // transaction's gas, it is best to keep them low in cases like this one, to
    // increase the likelihood of the full refund coming into effect.
    uint256 private constant _NOT_ENTERED = 1;
    uint256 private constant _ENTERED = 2;

    uint256 private _status;

    constructor() {
        _status = _NOT_ENTERED;
    }

    /**
     * @dev Prevents a contract from calling itself, directly or indirectly.
     * Calling a `nonReentrant` function from another `nonReentrant`
     * function is not supported. It is possible to prevent this from happening
     * by making the `nonReentrant` function external, and make it call a
     * `private` function that does the actual work.
     */
    modifier nonReentrant() {
        // On the first call to nonReentrant, _notEntered will be true
        require(_status != _ENTERED, "ReentrancyGuard: reentrant call");

        // Any calls to nonReentrant after this point will fail
        _status = _ENTERED;

        _;

        // By storing the original value once again, a refund is triggered (see
        // https://eips.ethereum.org/EIPS/eip-2200)
        _status = _NOT_ENTERED;
    }
}



contract ReferrerRewardsDistribution is Ownable, ReentrancyGuard{
    using SafeMath for uint256;
    using SafeERC20 for IERC20;

    address signer;
    IRedistributor public redistributor;
    IERC20 public dflToken;
    mapping(address=>bool) public whiteList;
    mapping(address=>uint256) public claimedAmount;

    event SetWhiteList(address indexed account, bool isWhiteList);
    event Claimed(address indexed account,uint256 amount);
    event SignerChanged(address originalSigner, address newSigner);
    event RedistributorChanged(address originalRedistributer, address newRedistributer);

    constructor(IERC20 _dflToken, address _signer){
        dflToken = _dflToken;
        signer = _signer;
    }

    function setWhiteList(address account, bool isWhiteList) public onlyOwner{
        whiteList[account] = isWhiteList;
        emit SetWhiteList(account, isWhiteList);
    }

    function addWhiteListBatch(address[] calldata accounts) public onlyOwner{
        require(accounts.length>0, "account length is ZERO");

        for(uint i; i<accounts.length; i++){
            whiteList[accounts[i]] = true;
            emit SetWhiteList(accounts[i], true);
        }
    }

    function removeWhiteListBatch(address[] calldata accounts) public onlyOwner{
        require(accounts.length>0, "account length is ZERO");

        for(uint i; i<accounts.length; i++){
            whiteList[accounts[i]] = false;
            emit SetWhiteList(accounts[i], false);
        }
    }

    function setSigner(address _signer) public onlyOwner{
        require(_signer != address(0), "signer should not be 0");
        emit SignerChanged(signer, _signer);
        signer = _signer;
        
    }

    function setRedistributor(IRedistributor _redistributor) public onlyOwner{
        require(address(_redistributor)!=address(0), "address should not be 0");
        emit RedistributorChanged(address(redistributor), address(_redistributor));
        redistributor = _redistributor;
    }

    function claim(uint256 _amount, uint8 v, bytes32 r, bytes32 s) public nonReentrant{
        address _account = msg.sender;
        require(whiteList[_account] == true, "account not in white list");
        require(_amount > claimedAmount[_account], "no value to claim");

        bytes32 dataHash = keccak256(abi.encodePacked(_account, _amount));
        require(ECDSA.recover(dataHash, v, r, s) == signer, "illegal tx");

        redistributor.claimAll();

        uint256 delta = _amount.sub(claimedAmount[_account]);
        claimedAmount[_account] = _amount;

        dflToken.safeTransfer(_account, delta);

        emit Claimed(_account, delta);
    }

}