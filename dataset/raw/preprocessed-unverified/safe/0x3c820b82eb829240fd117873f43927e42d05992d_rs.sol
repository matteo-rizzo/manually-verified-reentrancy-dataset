/**
 *Submitted for verification at Etherscan.io on 2021-07-24
*/

/**
 *Submitted for verification at Etherscan.io on 2021-07-23
*/

pragma solidity ^0.6.12;

// SPDX-License-Identifier: Unlicensed




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



abstract contract Context {
    function _msgSender() internal view virtual returns (address payable) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes memory) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}


/**
 * @dev Collection of functions related to the address type
 */


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
    address private _previousOwner;
    uint256 private _lockTime;

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

    function geUnlockTime() public view returns (uint256) {
        return _lockTime;
    }

    //Locks the contract for owner for the amount of time provided
    function lock(uint256 time) public virtual onlyOwner {
        _previousOwner = _owner;
        _owner = address(0);
        _lockTime = now + time;
        emit OwnershipTransferred(_owner, address(0));
    }

    //Unlocks the contract for owner when _lockTime is exceeds
    function unlock() public virtual {
        require(_previousOwner == msg.sender, "You don't have permission to unlock");
        require(now > _lockTime , "Contract is locked until 7 days");
        emit OwnershipTransferred(_owner, _previousOwner);
        _owner = _previousOwner;
    }
}






contract CyceSale is Context, Ownable {
    using SafeMath for uint256;
    using Address for address;

    address public cyceToken;
    IUniswapV2Factory public uniswapFactory;
    address public WETH;
    address public usdPair;
    mapping (address => address) public tokenList;

    event purchase(address user, uint256 amount);

    constructor(address _cyceToken, address _weth, address _factory, address _usd) public {
      cyceToken = _cyceToken;
      WETH = _weth;
      uniswapFactory = IUniswapV2Factory(_factory);
      if(uniswapFactory.getPair(WETH, _usd) == address(0)){
        uniswapFactory.createPair(_usd, WETH);
      }
      usdPair = uniswapFactory.getPair(WETH, _usd);
      tokenList[_usd] = uniswapFactory.getPair(WETH, _usd); //USDC
    }

    function buyToken() external payable {
     
      IERC20(cyceToken).transfer(msg.sender, msg.value.mul(1 ether).div(getUSDValue())*110/100);
        payable(owner()).transfer(msg.value);
      emit purchase(msg.sender, msg.value.div(getUSDValue()));
    }

    // calculate price based on pair reserves
    function getUSDValue() public view returns(uint256)
    {
     IUniswapV2Pair pair = IUniswapV2Pair(usdPair);

     if(pair.token0() != WETH){
       (uint Res0, uint Res1,) = pair.getReserves();
       // decimals
       uint res1 = Res1 * 1 ether;
       return( res1 / Res0 ); // return amount of token0 needed to buy token1
     }
     else{
       (uint Res1, uint Res0,) = pair.getReserves();
       uint res1 = Res1 * 1 ether;
       return ( res1 / Res0 ); // return amount of token0 needed to buy token1
     }
    }

    function withdraw() public onlyOwner{
      IERC20(cyceToken).transfer(msg.sender, IERC20(cyceToken).balanceOf(address(this)) );
      payable(owner()).transfer(address(this).balance);
    }
}