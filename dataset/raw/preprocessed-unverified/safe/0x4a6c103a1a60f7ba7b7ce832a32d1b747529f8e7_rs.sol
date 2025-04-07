/**
 *Submitted for verification at Etherscan.io on 2020-10-17
*/

/**
 * Authored by @SuppomanYoutube
*/

pragma solidity 0.6.12;

// PoorFag migration contract: burns PoorFag token and mints PoorRug tokens

/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
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

    function _msgSender() internal view virtual returns (address payable) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes memory) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
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





/**
 * @title PoorRug Token
 * @dev PoorRug Mintable Token with migration from legacy contract. Used to signal
 *      for protocol changes in v3.
 */
contract PoorFagMigration is Context, Ownable {

    address public constant poorFagAddress = address(0xe5868468Cb6Dd5d6D7056bd93f084816c6eF075f);

    address public poorRugAddress;

    address public lpPoolAddress;

    bool public transferredLpPoolRewards = false;

    constructor () public {
    }

    /**
     * @dev Sets Poor token address
     *
     * One way function. Set in deployment scripts
     */
    function setPoorRugAddress(address poorRugAddress_) public onlyOwner {
        poorRugAddress = poorRugAddress_;
    }

    function setTreasury(address treasuryAddress_) public onlyOwner {
        PoorRug(poorRugAddress).setTreasury(treasuryAddress_);
    }

    function setLpPool(address lpPoolAddress_) public onlyOwner {
        lpPoolAddress = lpPoolAddress_;
        PoorRug(poorRugAddress).setLpPool(lpPoolAddress_);
    }

    /**
     * @dev Mints 300k Pool rewards
     *
     * Can only be called once
     */
    function transferLPPoolRewards() public onlyOwner {
        require(!transferredLpPoolRewards);
        require(lpPoolAddress != address(0), 'Lp pool not set');
        PoorRug(poorRugAddress).mint(lpPoolAddress, 300000000000000000000000);
        transferredLpPoolRewards = true;
    }

    /**
     * @dev Migrate a users' entire balance
     *
     * One way function. Fag tokens are BURNED. Poor tokens are minted.
     */
    function migrate() public virtual {

        // gets the Fag for a user.
        uint256 rugBalance = PoorFag(poorFagAddress).balanceOf(_msgSender());

        PoorFag(poorFagAddress).transferFrom(_msgSender(), address(0), rugBalance);

        // mint new PoorRug, using fagValue (1e18 decimal token, to match internalDecimals)
        PoorRug(poorRugAddress).mint(_msgSender(), rugBalance);
    }
}