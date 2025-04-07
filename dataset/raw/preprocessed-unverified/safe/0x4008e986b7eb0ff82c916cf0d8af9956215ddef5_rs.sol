/**
 *Submitted for verification at Etherscan.io on 2021-07-05
*/

pragma solidity 0.6.12;



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
abstract contract Ownable is Context {
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



contract XLONPriceAdapter is Ownable, AggregatorV3Interface {

    using SafeMath for uint256;
    address public immutable LON = 0x0000000000095413afC295d19EDeb1Ad7B71c952;
    address public immutable xLON = 0xf88506B0F1d30056B9e5580668D5875b9cd30F23;
    address public immutable LON_ORACLE = 0x13A8F2cC27ccC2761ca1b21d2F3E762445f201CE;

    function decimals() override external view returns (uint8){
        return 18;
    }

    function description() override external view returns (string memory){
        return "xLON / ETH";
    }

    function version() override external view returns (uint256){
        return 1;
    }

    function getRoundData(uint80 _roundId)
    override
    external
    view
    returns (
        uint80 roundId,
        int256 answer,
        uint256 startedAt,
        uint256 updatedAt,
        uint80 answeredInRound
    ){
        AggregatorV3Interface priceFeed = AggregatorV3Interface(LON_ORACLE);
        (uint80 roundId,int256 answer,uint256 startedAt,uint256 updatedAt, uint80 answeredInRound) = priceFeed.getRoundData(_roundId);
        uint256 _exchangeRate = exchangeRate();
        int256 price = int256(uint(answer).mul(_exchangeRate).div(1 ether));
        return (roundId, price, startedAt, updatedAt, answeredInRound);
    }

    function latestRoundData()
    override
    external
    view
    returns (
        uint80 roundId,
        int256 answer,
        uint256 startedAt,
        uint256 updatedAt,
        uint80 answeredInRound
    ){
        AggregatorV3Interface priceFeed = AggregatorV3Interface(LON_ORACLE);
        (uint80 roundId,int256 answer,uint256 startedAt,uint256 updatedAt, uint80 answeredInRound) = priceFeed.latestRoundData();
        uint256 _exchangeRate = exchangeRate();
        int256 price = int256(uint(answer).mul(_exchangeRate).div(1 ether));
        return (roundId, price, startedAt, updatedAt, answeredInRound);
    }

    function exchangeRate() public view returns (uint256) {
        uint256 exchangeRate = (IERC2O(LON).balanceOf(xLON).mul(1 ether)).div(IERC2O(xLON).totalSupply());
        return exchangeRate;
    }

}