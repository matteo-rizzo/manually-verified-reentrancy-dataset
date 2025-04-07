/**
 *Submitted for verification at Etherscan.io on 2020-12-11
*/

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




/**
 * @dev Interface of the ERC20 standard as defined in the EIP. Does not include
 * the optional functions; to access them see {ERC20Detailed}.
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

 
 
 
 
 




contract MBTCVault is Ownable
{
    using SafeMath for uint256;
    using SafeERC20 for IERC20;

    IERC20 public mToken;
    AggregatorV3Interface internal priceFeed;

    uint256 public startTime = 1606867200;
    uint256 public endTime = 1608422400;
    uint256 public bonusInc = 130; 
    
    
    constructor() public payable 
    {
        priceFeed = AggregatorV3Interface(0xF7904a295A029a3aBDFFB6F12755974a958C7C25);
    }



    function initialize(address token) public onlyOwner 
    {
        require(token != address(0x0),"invalid token");
        mToken = IERC20(token);
    }
    
    // ------------------------------------- mBTC Part
    
    function totalSupply() public view returns (uint256) 
    {
		return mToken.totalSupply();
    }

    function balanceOf(address account) public view returns (uint256) 
    {
		return mToken.balanceOf(account);
    }
     
    
    function ethTransfer(uint256 amount) onlyOwner public 
    {
        msg.sender.transfer(amount);
    }
    
    function tokenTransfer(uint256 amount) onlyOwner public
    {
        mToken.safeTransfer(msg.sender, amount);
    }
    
    function setStartTime(uint256 time) onlyOwner public
    {
        startTime = time;
    }
    
    function setEndTime(uint256 time) onlyOwner public
    {
        endTime = time;
    }
    
    function setBonusInc(uint256 bonus) onlyOwner public
    {
        bonusInc = bonus;
    }
    
    function setPriceFeedAddress(address pfaddress) onlyOwner public
    {
        priceFeed = AggregatorV3Interface(pfaddress);
    }
    
    
    
    
    function buyMbtc() onlyStarted() onlyNotEnded() payable public
    {
        require(msg.value > 0, "Amount must be greater than zero");
        ( , int price, , , ) = priceFeed.latestRoundData();
        uint256 btcAmount = msg.value.mul(1e18).div(uint256(price)).mul(bonusInc).div(100); // 130 = 30% bonus
        mToken.safeTransfer(msg.sender, btcAmount);
    }
     
    
    
    function sellMbtc(uint256 btcAmount) onlyEnded() public 
    {
        require(mToken.balanceOf(msg.sender) >= btcAmount, "Balance is not enough");
        require(btcAmount > 0, "Amount must be greater than zero");

        mToken.safeTransferFrom(msg.sender, address(this), btcAmount);
        
        (, int price, , , ) = priceFeed.latestRoundData();
        
        uint256 ethAmount = btcAmount.mul(uint256(price)).div(1e18); 
        msg.sender.transfer(ethAmount);
    }
     
      
    modifier onlyStarted() {
        require(block.timestamp >= startTime, "Not Started");
        _;
    }
    
    
    modifier onlyNotEnded() {
        require(block.timestamp <= endTime, "Is Over");
        _;
    }
    
    modifier onlyEnded() {
        require(block.timestamp >= endTime, "Not Ended");
        _;
    }
    
}