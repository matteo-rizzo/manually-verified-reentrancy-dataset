/**
 *Submitted for verification at Etherscan.io on 2021-04-26
*/

// ====================================================================
//     ________                   _______                           
//    / ____/ /__  ____  ____ _  / ____(_)___  ____ _____  ________ 
//   / __/ / / _ \/ __ \/ __ `/ / /_  / / __ \/ __ `/ __ \/ ___/ _ \
//  / /___/ /  __/ / / / /_/ / / __/ / / / / / /_/ / / / / /__/  __/
// /_____/_/\___/_/ /_/\__,_(_)_/   /_/_/ /_/\__,_/_/ /_/\___/\___/                                                                                                                     
//                                                                        
// ====================================================================
// ====================== Elena Protocol (USE) ========================
// ====================================================================

// Dapp    :  https://elena.finance
// Twitter :  https://twitter.com/ElenaProtocol
// Telegram:  https://t.me/ElenaFinance
// ====================================================================

//SPDX-License-Identifier: MIT 
pragma solidity 0.6.11; 
pragma experimental ABIEncoderV2;


// File: contracts\@openzeppelin\contracts\GSN\Context.sol
// License: MIT

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

// File: contracts\@openzeppelin\contracts\access\Ownable.sol
// License: MIT


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

// File: contracts\@openzeppelin\contracts\token\ERC20\IERC20.sol
// License: MIT

/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
 */


// File: contracts\@openzeppelin\contracts\math\SafeMath.sol
// License: MIT

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


// File: contracts\@openzeppelin\contracts\utils\Address.sol
// License: MIT

/**
 * @dev Collection of functions related to the address type
 */


// File: contracts\@openzeppelin\contracts\token\ERC20\SafeERC20.sol
// License: MIT




/**
 * @title SafeERC20
 * @dev Wrappers around ERC20 operations that throw on failure (when the token
 * contract returns false). Tokens that return no value (and instead revert or
 * throw on failure) are also supported, non-reverting calls are assumed to be
 * successful.
 * To use this library you can add a `using SafeERC20 for IERC20;` statement to your contract,
 * which allows you to call the safe operations as `token.safeTransfer(...)`, etc.
 */


// File: contracts\AirDrop\ElenaAirDrop.sol
//License: MIT 

contract ElenaAirDrop  is Ownable{ 
    using SafeERC20 for IERC20; 
    address public timeLockAddr;
    address public airDropToken;
    uint256 public airDropId;
    uint256 public startClaimTime;
    uint256 public airDropEndTime;
    uint256 public airDropAmount;
    address[] public airDropList;
    address[] public airDropClaimedList; 
    modifier onlyAuthorized{
        require(msg.sender == owner() || msg.sender == timeLockAddr,"not authorized");
        _;
    }
    function init(address _token,address _timelock) public onlyAuthorized{
        airDropToken = _token;
        timeLockAddr = _timelock;
    } 
    function setAirDropInfo(uint256 _id,uint256 _startTime,uint256 _endTime,uint256 _amount) public onlyAuthorized{        
        airDropId = _id;
        startClaimTime = _startTime;
        airDropEndTime = _endTime;
        airDropAmount = _amount;       
    }
    function setAirDropList(address[] calldata addrs) public onlyAuthorized{
        require(startClaimTime > block.timestamp,"set startClaimTime First");
        delete airDropList;
        delete airDropClaimedList;
        airDropList = addrs; 
    }
    function emergencyStop() public onlyAuthorized{
        uint256 _bal = IERC20(airDropToken).balanceOf(address(this));
        IERC20(airDropToken).safeTransfer(msg.sender,_bal);     
    }  
    function getListInfo() public view returns(uint256,uint256,uint256){
         return (airDropList.length,airDropClaimedList.length,block.timestamp);
    }
    function getRewards(address _user) public view returns(uint256){
        uint256 i=0;
        bool haveRewards = false;
        bool claimedFlag = false;
        for(i=0; i < airDropList.length; i ++){
            if(airDropList[i] == _user){
                haveRewards = true;
                break;
            }
        }
        for(i=0; i < airDropClaimedList.length; i ++){
            if(airDropClaimedList[i] == _user){
                claimedFlag = true;
                break;
            }
        }
        if(haveRewards == true && claimedFlag == false){
            return airDropAmount;
        }
        return 0;
    }
    function claimReward() public {
        require(block.timestamp > startClaimTime,"not start!"); 
        require(block.timestamp < airDropEndTime,"");
        uint256 _amount = getRewards(msg.sender);
        require(_amount > 0,"no amount!"); 
        airDropClaimedList.push(msg.sender);
        IERC20(airDropToken).safeTransfer(msg.sender,_amount);        
    } 
}