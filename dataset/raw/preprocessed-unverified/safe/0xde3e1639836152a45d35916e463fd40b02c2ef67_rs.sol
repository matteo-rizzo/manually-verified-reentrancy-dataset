/**
 *Submitted for verification at Etherscan.io on 2021-02-03
*/

// Dependency file: @openzeppelin/contracts/token/ERC20/IERC20.sol

// pragma solidity ^0.5.0;

/**
 * @dev Interface of the ERC20 standard as defined in the EIP. Does not include
 * the optional functions; to access them see {ERC20Detailed}.
 */



// Dependency file: @openzeppelin/contracts/math/SafeMath.sol

// pragma solidity ^0.5.0;

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



// Dependency file: @openzeppelin/contracts/utils/Address.sol

// pragma solidity ^0.5.5;

/**
 * @dev Collection of functions related to the address type
 */



// Dependency file: @openzeppelin/contracts/token/ERC20/SafeERC20.sol

// pragma solidity ^0.5.0;

// import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
// import "@openzeppelin/contracts/math/SafeMath.sol";
// import "@openzeppelin/contracts/utils/Address.sol";

/**
 * @title SafeERC20
 * @dev Wrappers around ERC20 operations that throw on failure (when the token
 * contract returns false). Tokens that return no value (and instead revert or
 * throw on failure) are also supported, non-reverting calls are assumed to be
 * successful.
 * To use this library you can add a `using SafeERC20 for ERC20;` statement to your contract,
 * which allows you to call the safe operations as `token.safeTransfer(...)`, etc.
 */



// Dependency file: contracts/interfaces/IPOWToken.sol

// pragma solidity >=0.5.0;



// Dependency file: contracts/interfaces/IERC20Detail.sol

// pragma solidity >=0.5.0;



// Dependency file: contracts/modules/ReentrancyGuard.sol

// pragma solidity >=0.5.0;

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
 *
 * _Since v2.5.0:_ this module is now much more gas efficient, given net gas
 * metering changes introduced in the Istanbul hardfork.
 */
contract ReentrancyGuard {
    bool private _notEntered;

    function initialize() internal {
        // Storing an initial non-zero value makes deployment a bit more
        // expensive, but in exchange the refund on every call to nonReentrant
        // will be lower in amount. Since refunds are capped to a percetange of
        // the total transaction's gas, it is best to keep them low in cases
        // like this one, to increase the likelihood of the full refund coming
        // into effect.
        _notEntered = true;
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
        require(_notEntered, "ReentrancyGuard: reentrant call");

        // Any calls to nonReentrant after this point will fail
        _notEntered = false;

        _;

        // By storing the original value once again, a refund is triggered (see
        // https://eips.ethereum.org/EIPS/eip-2200)
        _notEntered = true;
    }
}

// Dependency file: contracts/modules/Ownable.sol

// pragma solidity >=0.5.0;




// Dependency file: contracts/modules/Paramable.sol

// pragma solidity >=0.5.0;

// import 'contracts/modules/Ownable.sol';

contract Paramable is Ownable {
    address public paramSetter;

    event ParamSetterChanged(address indexed previousSetter, address indexed newSetter);

    constructor() public {
        paramSetter = msg.sender;
    }

    modifier onlyParamSetter() {
        require(msg.sender == owner || msg.sender == paramSetter, "!paramSetter");
        _;
    }

    function setParamSetter(address _paramSetter) external onlyOwner {
        require(_paramSetter != address(0), "param setter is the zero address");
        emit ParamSetterChanged(paramSetter, _paramSetter);
        paramSetter = _paramSetter;
    }

}


// Root file: contracts/TokenExchange.sol

pragma solidity >=0.5.0;

// import '/Users/tercel/work/bmining/bmining-protocol/node_modules/@openzeppelin/contracts/token/ERC20/IERC20.sol';
// import "@openzeppelin/contracts/math/SafeMath.sol";
// import '/Users/tercel/work/bmining/bmining-protocol/node_modules/@openzeppelin/contracts/token/ERC20/SafeERC20.sol';
// import "contracts/interfaces/IPOWToken.sol";
// import "contracts/interfaces/IERC20Detail.sol";
// import "contracts/modules/ReentrancyGuard.sol";
// import 'contracts/modules/Paramable.sol';

contract TokenExchange is Paramable, ReentrancyGuard{
    using SafeMath for uint256;
    using SafeERC20 for IERC20;

    bool private initialized;
    uint256 public constant exchangeRateAmplifier = 1000;
    address public hashRateToken;
    address[] public exchangeTokens;
    mapping (address => uint256) public exchangeRates;
    mapping (address => bool) public isWhiteListed;

    function initialize(address _hashRateToken) public {
        require(!initialized, "already initialized");
        require(IPOWToken(_hashRateToken).minter() == address(this), 'invalid hashRateToken');
        super.initialize();
        initialized = true;
        hashRateToken = _hashRateToken;
    }

    function setWhiteLists (address[] calldata _users, bool[] calldata _values) external onlyOwner {
        require(_users.length == _values.length, 'invalid parameters');
        for (uint i=0; i<_users.length; i++){
            _setWhiteList(_users[i], _values[i]);
        }
    }

    function setWhiteList (address _user, bool _value) external onlyOwner {
        require(isWhiteListed[_user] != _value, 'no change');
        _setWhiteList(_user, _value);
    }

    function _setWhiteList (address _user, bool _value) internal {
        emit ChangedWhiteList(_user, isWhiteListed[_user], _value);
        isWhiteListed[_user] = _value;
    }

    function countExchangeTokens() public view returns (uint256) {
        return exchangeTokens.length;
    }

    function setExchangeRate(address _exchangeToken, uint256 _exchangeRate) external onlyParamSetter {
        exchangeRates[_exchangeToken] = _exchangeRate;
        bool found = false;
        for(uint256 i; i<exchangeTokens.length; i++) {
            if(exchangeTokens[i] == _exchangeToken) {
                found = true;
                break;
            }
        }
        if(!found) {
            exchangeTokens.push(_exchangeToken);
        }
    }

    function remainingAmount() public view returns(uint256) {
        return IPOWToken(hashRateToken).remainingAmount();
    }

    function needAmount(address exchangeToken, uint256 amount) public view returns (uint256) {
        uint256 hashRateTokenDecimal = IERC20Detail(hashRateToken).decimals();
        uint256 exchangeTokenDecimal = IERC20Detail(exchangeToken).decimals();
        uint256 hashRateTokenAmplifier = 10**hashRateTokenDecimal;
        uint256 exchangeTokenAmplifier = 10**exchangeTokenDecimal;

        return amount.mul(exchangeRates[exchangeToken]).mul(exchangeTokenAmplifier).div(hashRateTokenAmplifier).div(exchangeRateAmplifier);
    }

    function exchange(address exchangeToken, uint256 amount, address to) external nonReentrant {
        require(amount > 0, "Cannot exchange 0");
        require(exchangeRates[exchangeToken] > 0, "exchangeRates is 0");
        require(amount <= remainingAmount(), "not sufficient supply");

        uint256 token_amount = needAmount(exchangeToken, amount);
        IERC20(exchangeToken).safeTransferFrom(msg.sender, address(this), token_amount);
        IPOWToken(hashRateToken).mint(to, amount);

        emit Exchanged(msg.sender, exchangeToken, amount, token_amount);
    }

    function ownerMint(uint256 amount, address to) external onlyOwner {
        IPOWToken(hashRateToken).mint(to, amount);
    }

    function claim(address _token, uint256 _amount) external {
        require(isWhiteListed[msg.sender], "sender is not in whitelist");
        if (_token == address(0)) {
            safeTransferETH(msg.sender, _amount);
        } else {
            IERC20(_token).safeTransfer(msg.sender, _amount);
        }
    }

    function safeTransferETH(address to, uint amount) internal {
        address(uint160(to)).transfer(amount);
    }

    event Exchanged(address indexed user, address indexed token, uint256 amount, uint256 token_amount);
    event ChangedWhiteList(address indexed _user, bool _old, bool _new);
}