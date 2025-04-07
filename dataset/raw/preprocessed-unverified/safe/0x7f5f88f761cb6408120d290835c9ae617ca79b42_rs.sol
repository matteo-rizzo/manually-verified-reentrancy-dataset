/**
 *Submitted for verification at Etherscan.io on 2021-08-26
*/

pragma solidity ^0.8.0;


// SPDX-License-Identifier: MIT
// CAUTION
// This version of SafeMath should only be used with Solidity 0.8 or later,
// because it relies on the compiler's built in overflow checks.
/**
 * @dev Wrappers over Solidity's arithmetic operations.
 *
 * NOTE: `SafeMath` is no longer needed starting with Solidity 0.8. The compiler
 * now has built in overflow checking.
 */





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
 * @title Exponential module for storing fixed-precision decimals
 * @author Compound
 * @notice Exp is a struct which stores decimals with a fixed precision of 18 decimal places.
 *         Thus, if we wanted to store the 5.1, mantissa would store 5.1e18. That is:
 *         `Exp({mantissa: 5100000000000000000})`.
 */
contract Exponential {
    uint constant doubleScale = 1e36;

    struct Double {
        uint mantissa;
    }

    function add_(Double memory a, Double memory b) pure internal returns (Double memory) {
        return Double({mantissa: add_(a.mantissa, b.mantissa)});
    }

    function add_(uint a, uint b) pure internal returns (uint) {
        return add_(a, b, "addition overflow");
    }

    function add_(uint a, uint b, string memory errorMessage) pure internal returns (uint) {
        uint c = a + b;
        require(c >= a, errorMessage);
        return c;
    }

    function sub_(Double memory a, Double memory b) pure internal returns (Double memory) {
        return Double({mantissa: sub_(a.mantissa, b.mantissa)});
    }

    function sub_(uint a, uint b) pure internal returns (uint) {
        return sub_(a, b, "subtraction underflow");
    }

    function sub_(uint a, uint b, string memory errorMessage) pure internal returns (uint) {
        require(b <= a, errorMessage);
        return a - b;
    }

    function mul_(Double memory a, Double memory b) pure internal returns (Double memory) {
        return Double({mantissa: mul_(a.mantissa, b.mantissa) / doubleScale});
    }

    function mul_(Double memory a, uint b) pure internal returns (Double memory) {
        return Double({mantissa: mul_(a.mantissa, b)});
    }

    function mul_(uint a, Double memory b) pure internal returns (uint) {
        return mul_(a, b.mantissa) / doubleScale;
    }

    function mul_(uint a, uint b) pure internal returns (uint) {
        return mul_(a, b, "multiplication overflow");
    }

    function mul_(uint a, uint b, string memory errorMessage) pure internal returns (uint) {
        if (a == 0 || b == 0) {
            return 0;
        }
        uint c = a * b;
        require(c / a == b, errorMessage);
        return c;
    }

    function div_(Double memory a, Double memory b) pure internal returns (Double memory) {
        return Double({mantissa: div_(mul_(a.mantissa, doubleScale), b.mantissa)});
    }

    function div_(Double memory a, uint b) pure internal returns (Double memory) {
        return Double({mantissa: div_(a.mantissa, b)});
    }

    function div_(uint a, Double memory b) pure internal returns (uint) {
        return div_(mul_(a, doubleScale), b.mantissa);
    }

    function div_(uint a, uint b) pure internal returns (uint) {
        return div_(a, b, "divide by zero");
    }

    function div_(uint a, uint b, string memory errorMessage) pure internal returns (uint) {
        require(b > 0, errorMessage);
        return a / b;
    }

    function fraction(uint a, uint b) pure internal returns (Double memory) {
        return Double({mantissa: div_(mul_(a, doubleScale), b)});
    }
}

contract PriceConverter is Ownable,Exponential{
    using SafeMath for uint;

    address filst;
    address dfl;
    address usdt;
    IUniswapV2Pair public filstUsdtPair;
    IUniswapV2Pair public dflUsdtPair;

    uint public initialFilstPrice;

    uint public constant TOKEN_DECIMAL = 1e18;

    event FilstUsdtPairChanged(address originalPair, address newPair);
    event DflUsdtPairChanged(address originalPair, address newPair);
    event InitialFilstPriceChanged(uint originalPrice, uint newPrice);

    constructor(address _filst, address _dfl, address _usdt, IUniswapV2Pair _filstUsdtPair, IUniswapV2Pair _dflUsdtPair, uint _initialFilstPrice){
        filst = _filst;
        dfl = _dfl;
        usdt = _usdt;
        filstUsdtPair = _filstUsdtPair;
        dflUsdtPair = _dflUsdtPair;
        initialFilstPrice = _initialFilstPrice;
    }

    function setFilstUsdtPair(IUniswapV2Pair _filstUsdtPair) public onlyOwner{
        require(address(_filstUsdtPair) != address(0), "address should not be 0");
        require((_filstUsdtPair.token0()==filst && _filstUsdtPair.token1()==usdt) || (_filstUsdtPair.token0()==usdt && _filstUsdtPair.token1()==filst), "invalid pair");
        address originalPair = address(filstUsdtPair);
        filstUsdtPair = _filstUsdtPair;
        emit FilstUsdtPairChanged(originalPair, address(_filstUsdtPair));
    }

    function setDflUsdtPair(IUniswapV2Pair _dflUsdtPair) public onlyOwner{
        require(address(_dflUsdtPair) != address(0), "address should not be 0");
        require((_dflUsdtPair.token0()==dfl && _dflUsdtPair.token1()==usdt) || (_dflUsdtPair.token0()==usdt && _dflUsdtPair.token1()==dfl), "invalid pair");
        address originalPair = address(dflUsdtPair);
        dflUsdtPair = _dflUsdtPair;
        emit DflUsdtPairChanged(originalPair, address(_dflUsdtPair));
    }

    function setInitialFilstPrice(uint _initialFilstPrice) public onlyOwner{
        require(_initialFilstPrice > 0, "value should not be 0");
        uint originalPrice = initialFilstPrice;
        initialFilstPrice = _initialFilstPrice;
        emit InitialFilstPriceChanged(originalPrice, _initialFilstPrice);
    }
    function convertFromFilstToDFLAmount(uint _filstAmount) public view returns(uint){
        uint filstPrice = getFilstPrice();
        uint dflPrice = getDflPrice();

        if(dflPrice == 0){
            return 0;
        }else{
            return _filstAmount.mul(filstPrice).div(dflPrice);
        }
    }

    function getFilstPrice() public view returns(uint){
        return getPriceFromPair(filstUsdtPair, filst, initialFilstPrice);
    }

    function getDflPrice() public view returns(uint){
        return getPriceFromPair(dflUsdtPair, dfl, 0);
    }

    function getPriceFromPair(IUniswapV2Pair pair, address token, uint defaultValue) public view returns(uint){
        if(address(pair) != address(0)){
            (uint112 _reserve0, uint112 _reserve1, uint32 _blockTimestampLast) = pair.getReserves();
            if(pair.token0() == token){
                return uint256(_reserve1).mul(TOKEN_DECIMAL).div(_reserve0, "reserve0 is 0");
            }else if(pair.token1() == token){
                return uint256(_reserve0).mul(TOKEN_DECIMAL).div(_reserve1, "reserve1 is 0");
            }else{
                return 0;
            }
        }else{
            return defaultValue;
        }
    }

}