/**
 *Submitted for verification at Etherscan.io on 2021-09-30
*/

// SPDX-License-Identifier: MIT
pragma solidity 0.6.12;


pragma experimental ABIEncoderV2;

/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
 */

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
        this;
        // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}

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
 * @dev Library for managing
 * https://en.wikipedia.org/wiki/Set_(abstract_data_type)[sets] of primitive
 * types.
 *
 * Sets have the following properties:
 *
 * - Elements are added, removed, and checked for existence in constant time
 * (O(1)).
 * - Elements are enumerated in O(n). No guarantees are made on the ordering.
 *
 * ```
 * contract Example {
 *     // Add the library methods
 *     using EnumerableSet for EnumerableSet.AddressSet;
 *
 *     // Declare a set state variable
 *     EnumerableSet.AddressSet private mySet;
 * }
 * ```
 *
 * As of v3.3.0, sets of type `bytes32` (`Bytes32Set`), `address` (`AddressSet`)
 * and `uint256` (`UintSet`) are supported.
 */


/**
 * @dev Library for managing an enumerable variant of Solidity's
 * https://solidity.readthedocs.io/en/latest/types.html#mapping-types[`mapping`]
 * type.
 *
 * Maps have the following properties:
 *
 * - Entries are added, removed, and checked for existence in constant time
 * (O(1)).
 * - Entries are enumerated in O(n). No guarantees are made on the ordering.
 *
 * ```
 * contract Example {
 *     // Add the library methods
 *     using EnumerableMap for EnumerableMap.UintToAddressMap;
 *
 *     // Declare a set state variable
 *     EnumerableMap.UintToAddressMap private myMap;
 * }
 * ```
 *
 * As of v3.0.0, only maps of type `uint256 -> address` (`UintToAddressMap`) are
 * supported.
 */



/**
 * @dev This is a base contract to aid in writing upgradeable contracts, or any kind of contract that will be deployed
 * behind a proxy. Since a proxied contract can't have a constructor, it's common to move constructor logic to an
 * external initializer function, usually called `initialize`. It then becomes necessary to protect this initializer
 * function so it can only be called once. The {initializer} modifier provided by this contract will have this effect.
 *
 * TIP: To avoid leaving the proxy in an uninitialized state, the initializer function should be called as early as
 * possible by providing the encoded function call as the `_data` argument to {ERC1967Proxy-constructor}.
 *
 * CAUTION: When used with inheritance, manual care must be taken to not invoke a parent initializer twice, or to ensure
 * that all initializers are idempotent. This is not verified automatically as constructors are by Solidity.
 */
abstract contract Initializable {
    /**
     * @dev Indicates that the contract has been initialized.
     */
    bool private _initialized;

    /**
     * @dev Indicates that the contract is in the process of being initialized.
     */
    bool private _initializing;

    /**
     * @dev Modifier to protect an initializer function from being invoked twice.
     */
    modifier initializer() {
        require(_initializing || !_initialized, "Initializable: contract is already initialized");

        bool isTopLevelCall = !_initializing;
        if (isTopLevelCall) {
            _initializing = true;
            _initialized = true;
        }

        _;

        if (isTopLevelCall) {
            _initializing = false;
        }
    }
}


contract Holder is Ownable,Initializable {

    using SafeMath for uint256;
    using EnumerableSet for EnumerableSet.AddressSet;
    using EnumerableMap for EnumerableMap.UintToAddressMap;

    struct Order {
        address tokenAddr;
        uint256 lockAmount;
        uint256 startTime;
        uint256 endTime;
        uint claim;
    }


    EnumerableSet.AddressSet private _tokens;

    //address==>Order[]
    mapping(address => Order[]) userOrders;

    //token=>lockAmount
    mapping(address => uint256) tokenLockAmounts;

    address payable public feeAddress;
    
    uint256 constant public minLockTime = 60;
    uint256 constant public maxLockTime = 365 * 3 days;
    
    uint256 constant public baseRate = 10000;
    uint256 public feeRate = 0;
    uint256 constant public maxFeeRate = 200;
    
    
    

    event Lock(address indexed user, address indexed tokenAddr, uint256 indexed value, uint256 time);
    event LockETH(address indexed user,uint256 indexed value,uint256 indexed time);
    event UnLock(address indexed user, address indexed tokenAddr, uint256 indexed value);
    event UnLockETH(address indexed user,uint256 indexed value);

    // constructor() public {
       
    // }
    
      // --- Init ---
    function initialize(
       address payable _feeAddress,
       uint256 _feeRate
    ) public initializer onlyOwner  {
        require(_feeRate <= maxFeeRate,"invalid value");
        feeAddress = _feeAddress;
        feeRate = _feeRate;
    }


    function calculationFee(uint256 _amount) public view returns (uint256){
        return _amount.mul(feeRate).div(baseRate);
    }

    function lock(address _tokenAddr, uint256 _amount, uint256 _seconds) payable external returns (bool){
        if(_tokenAddr == address(0)){
            return lockEth(_tokenAddr,_seconds);
        }else{
            return lockERC20(_tokenAddr,_amount,_seconds);
        }
       
    }


    function lockEth(address _tokenAddr,uint256 _seconds) internal  returns(bool) {
        uint256 _amount = msg.value;
        require(_amount > 0, "amount must be greater than 0");
        require(_seconds >= minLockTime && _seconds <= maxLockTime, "invalid time");
        uint256 fee = calculationFee(_amount);
        feeAddress.transfer(fee);
        uint256 userLockAmount = _amount.sub(fee);
        // address _tokenAddr = address(0x0);

        Order memory order = Order(_tokenAddr, userLockAmount, now, now.add(_seconds), 0);
        userOrders[msg.sender].push(order);
        tokenLockAmounts[_tokenAddr] = tokenLockAmounts[_tokenAddr].add(userLockAmount);
        if (!EnumerableSet.contains(_tokens, _tokenAddr)) {
            EnumerableSet.add(_tokens, _tokenAddr);
        }
        emit LockETH(msg.sender, _amount, _seconds);
        return true;
        
    }
    
    function lockERC20(address _tokenAddr,uint256 _amount,uint256 _seconds) internal returns(bool) {
        require(_tokenAddr != address(0x0),"invalid token address");
        require(_amount > 0, "amount must be greater than 0");
        require(_seconds >= minLockTime && _seconds <= maxLockTime, "invalid time");
        uint256 fee = calculationFee(_amount);
       
        IERC20(_tokenAddr).transferFrom(msg.sender, address(this), _amount);
        IERC20(_tokenAddr).transfer(feeAddress, fee);
    

        uint256 userLockAmount = _amount.sub(fee);

        Order memory order = Order(_tokenAddr, userLockAmount, now, now.add(_seconds), 0);
        userOrders[msg.sender].push(order);
        tokenLockAmounts[_tokenAddr] = tokenLockAmounts[_tokenAddr].add(userLockAmount);
        if (!EnumerableSet.contains(_tokens, _tokenAddr)) {
            EnumerableSet.add(_tokens, _tokenAddr);
        }
        emit Lock(msg.sender, _tokenAddr, _amount, _seconds);
        return true;
        
    }
    
    
    function unlock(uint _index) external returns (bool){
        require(userOrders[msg.sender].length - 1 >= _index, "invalid index");
        Order storage order = userOrders[msg.sender][_index];
        require(order.claim == 0, "claimed");
        require(now >= order.endTime, "unlock time not reached");
        order.claim = 1;

        uint256 withdrawAmount = getLockAmount(order.tokenAddr,order.lockAmount);
        if(order.tokenAddr == address(0)){
            msg.sender.transfer(withdrawAmount);
            emit UnLockETH(msg.sender,order.lockAmount);
        }else{
            IERC20(order.tokenAddr).transfer(msg.sender, withdrawAmount);
            emit UnLock(msg.sender, order.tokenAddr, order.lockAmount);
        }
        tokenLockAmounts[order.tokenAddr] = tokenLockAmounts[order.tokenAddr].sub(order.lockAmount);
        
        return true;
    }

    function getLockAmount(address tokenAddr,uint lockAmount) internal  view returns(uint256){
        uint256 balance =  0;
        if(tokenAddr == address(0)){
            balance = address(this).balance;
        }else{
            balance = IERC20(tokenAddr).balanceOf(address(this));
        }
       
        uint256 totalAmount = tokenLockAmounts[tokenAddr];
        uint256 withdrawAmount = balance.mul(1e16).div(totalAmount).mul(lockAmount).div(1e16);
        return withdrawAmount;
    }


    function getOrders() public view returns (Order[] memory order){
        return userOrders[msg.sender];
    }

    function getUserOrderLength() public view returns (uint){
        return userOrders[msg.sender].length;
    }

    function getOrder(uint _index) public view returns (Order memory order){
        return userOrders[msg.sender][_index];
    }

    function getPercentOrders() public view returns (Order[] memory orders){
        uint256 orderLength = userOrders[msg.sender].length;
        
         orders = new Order[](orderLength);
  
        for(uint i = 0; i < orderLength; i++) {
            orders[i]  = getOrderView(i);
            // orders[i] = order;
        }
        return orders;

    }

    function getPercentOrder(uint _index) public view returns (Order memory order){
         uint256 orderLength = userOrders[msg.sender].length;
         return orderLength > _index? getOrderView(_index) : userOrders[msg.sender][_index];
    }


    function getOrderView(uint _index) internal view returns(Order memory order){
        Order memory  userOrder = userOrders[msg.sender][_index];
        uint256 withdrawAmount = getLockAmount(userOrder.tokenAddr,userOrder.lockAmount);
        order =  Order(userOrder.tokenAddr, withdrawAmount, userOrder.startTime, userOrder.endTime, userOrder.claim);
        return order;
    }


    function canUnlock(uint _index) public view returns (bool){
        return now >= userOrders[msg.sender][_index].endTime ? true : false;
    }


    function getTokens() public view returns (address[] memory tokens){
        tokens = new address[](getTokensLength());
        for (uint i = 0; i < getTokensLength(); i++) {
            tokens[i] = EnumerableSet.at(_tokens, i);
        }
        return tokens;
    }

    function getTokensLength() public view returns (uint){
        return EnumerableSet.length(_tokens);
    }


    function getToken(uint256 _index) public view returns (address){
        require(_index <= getTokensLength() - 1, "index out of bounds");
        return EnumerableSet.at(_tokens, _index);
    }

    function getTokenLockAmounts(address _tokenAddr) public view returns(uint256){
        return tokenLockAmounts[_tokenAddr];
    }

    function containsToken(address _tokenAddr) public view returns (bool) {
        return EnumerableSet.contains(_tokens, _tokenAddr);
    }

    


    function setFeeRate(uint256 _rate) external onlyOwner returns (bool){
        require(_rate <= maxFeeRate,"invalid feeRate");
        feeRate = _rate;
        return true;
    }

    

    function setFeeAddress(address payable _feeAddress) public onlyOwner returns(bool){
        feeAddress = _feeAddress;
        return true;
    }

}