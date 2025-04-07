/**
 *Submitted for verification at Etherscan.io on 2021-06-29
*/

pragma solidity ^0.8.0;
/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
 */


// File: @openzeppelin/contracts/math/SafeMath.sol

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
abstract contract Context {
    function _msgSender() internal view virtual returns (address payable) {
        return payable(msg.sender);
    }

    function _msgData() internal view virtual returns (bytes memory) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}

// File: @openzeppelin/contracts/access/Ownable.sol

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
    constructor ()  {
        address msgSender = _msgSender();
        _owner = msgSender;
        emit OwnershipTransferred(address(0), msgSender);
    }

    /**
     * @dev Returns the address of the current owner.
     */
    function owner() external view returns (address) {
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
    function renounceOwnership() external virtual onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) external virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}
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



contract Treasury is Ownable{
    using SafeERC20 for IERC20;
    using SafeMath for uint256;
    
    IERC20  public mainToken;
    
    uint256 airdropValue = 50000000 * 10**18;
    event transferOut(address from, address to, uint256 value);
    
    mapping(address =>uint256 ) public  airdropValues;
    
    constructor(IERC20 _mainToken){
        require(address(_mainToken ) != address(0),"_mainToken is zero value!");
        mainToken = _mainToken;
    }
    
    function donate(address[] memory  Recipients)external onlyOwner{
        
        uint256  addrNumber = Recipients.length;
        
        uint256 airdropBal = airdropValue.div(30).div(addrNumber);
        require(addrNumber <= 100,"The number of addresses cannot exceed 100!");
        for (uint16 i = 0 ;i < addrNumber;i++){
            // if (mainToken.balanceOf(Recipients[i]) >100000*10**18){
                 mainToken.safeTransfer(Recipients[i],airdropBal);
        emit transferOut(address(this),Recipients[i] , airdropBal);
            // }
       
        }
    }
    
    function airdropForImportantPerson(address[] memory Recipients,uint256[] memory values) external onlyOwner{
        require(Recipients.length == values.length,"The number of addresses is not the same as the number of values!");
        
        require(Recipients.length <= 100,"The number of important people cannot exceed 100!");
        
        for(uint16 i = 0 ; i < Recipients.length;i++){
            
            if (values[i] > 0  ){
                uint addrNumber = airdropValues[Recipients[i]].add(values[i]);
                if (addrNumber < airdropValue.div(100) ){
                     mainToken.safeTransfer(Recipients[i],values[i]);
                     airdropValues[Recipients[i]] = airdropValues[Recipients[i]].add(values[i]);
                     emit transferOut(address(this),Recipients[i] , values[i]);
                }
            }
        }
    }
    
      function migrate (address _to, uint256 _number) external onlyOwner{
        require(_number>0 ,"The quantity entered must be greater than zero!");
         mainToken.safeTransfer(_to,_number);
         emit transferOut(address(this),_to,_number);
    }
    
}