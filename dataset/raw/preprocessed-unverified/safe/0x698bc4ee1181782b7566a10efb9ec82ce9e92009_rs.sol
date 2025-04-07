/**
 *Submitted for verification at Etherscan.io on 2021-03-26
*/

pragma experimental ABIEncoderV2;
pragma solidity 0.6.4;


// SPDX-License-Identifier: MIT


// SPDX-License-Identifier: MIT


// SPDX-License-Identifier: MIT


// SPDX-License-Identifier: MIT
/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
 */


// SPDX-License-Identifier: MIT
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


// SPDX-License-Identifier: MIT
/**
 * @dev Collection of functions related to the address type
 */


// SPDX-License-Identifier: MIT
/**
 * @title SafeERC20
 * @dev Wrappers around ERC20 operations that throw on failure (when the token
 * contract returns false). Tokens that return no value (and instead revert or
 * throw on failure) are also supported, non-reverting calls are assumed to be
 * successful.
 * To use this library you can add a `using SafeERC20 for IERC20;` statement to your contract,
 * which allows you to call the safe operations as `token.safeTransfer(...)`, etc.
 */






/**
 * @title Initializable
 *
 * @dev Helper contract to support initializer functions. To use it, replace
 * the constructor with a function that has the `initializer` modifier.
 * WARNING: Unlike constructors, initializer functions must be manually
 * invoked. This applies both to deploying an Initializable contract, as well
 * as extending an Initializable contract via inheritance.
 * WARNING: When used with inheritance, manual care must be taken to not invoke
 * a parent initializer twice, or ensure that all initializers are idempotent,
 * because this is not dealt with automatically as with constructors.
 */
contract Initializable {

  /**
   * @dev Indicates that the contract has been initialized.
   */
  bool private initialized;

  /**
   * @dev Indicates that the contract is in the process of being initialized.
   */
  bool private initializing;

  /**
   * @dev Modifier to use in the initializer function of a contract.
   */
  modifier initializer() {
    require(initializing || isConstructor() || !initialized, "Contract instance has already been initialized");

    bool isTopLevelCall = !initializing;
    if (isTopLevelCall) {
      initializing = true;
      initialized = true;
    }

    _;

    if (isTopLevelCall) {
      initializing = false;
    }
  }

  /// @dev Returns true if and only if the function is running in the constructor
  function isConstructor() private view returns (bool) {
    // extcodesize checks the size of the code stored in an address, and
    // address returns the current address. Since the code is still not
    // deployed when running a constructor, any checks on its code size will
    // yield zero, making it an effective way to detect if a contract is
    // under construction or not.
    address self = address(this);
    uint256 cs;
    assembly { cs := extcodesize(self) }
    return cs == 0;
  }

  // Reserved storage space to allow for layout changes in the future.
  uint256[50] private ______gap;
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
 * As of v3.0.0, only sets of type `address` (`AddressSet`) and `uint256`
 * (`UintSet`) are supported.
 */


/**
 *Submitted for verification at Etherscan.io on 2020-06-04
*/
contract ForTubeOracle is Initializable, IPriceOracles {
    using EnumerableSet for EnumerableSet.AddressSet;
    using EnumerableSet for EnumerableSet.UintSet;

    event Enable(address feeder);
    event Disable(address feeder);

    event Enables(address[] feeder);
    event Disables(address[] feeder);

    event EnableToken(address token);
    event DisableToken(address token);

    event EnableTokens(address[] ts);
    event DisableTokens(address[] ts);

    event Set(address who, address token, uint val, uint exp);
    event BatchSet(address[] tokens, uint[] vals, uint exp);

    address public multiSig;
    address public admin;

    //所有喂价地址列表，每个节点一个喂价地址，下架节点时，需要删除下架节点的数据。
    EnumerableSet.AddressSet private _tokens;// 支持的币种列表

    // to save gas
    struct Price {
        uint192 price;
        uint64 expiration;
    }
    mapping (address => Price) public finalPrices;//最终结果

    //使用新的address作为Key
    EnumerableSet.AddressSet private _feeders;// 支持的喂价者列表
    mapping (address => mapping (address => Price)) public _prices;

    function initialize(address _multiSig, address[] memory _initFeeders)
        public
        initializer
    {
        multiSig = _multiSig;
        admin = msg.sender;

        require(_initFeeders.length >= 1, "invalid length");
        for (uint256 i = 0; i < _initFeeders.length; i++) {
            _feeders.add(_initFeeders[i]);
        }
    }

    // constructor(address _multiSig, address[] memory _initFeeders) public
    // {
    //     multiSig = _multiSig;
    //     admin = msg.sender;

    //     require(_initFeeders.length >= 1, "invalid length");
    //     for (uint256 i = 0; i < _initFeeders.length; i++) {
    //         _feeders.add(_initFeeders[i]);
    //     }
    // }

    // 每个节点都能访问该喂价合约，但只能喂价属于本节点的数据
    modifier auth {
        require(_feeders.contains(msg.sender), "unauthorized feeder");
        _;
    }

    modifier onlyMultiSig {
        require(msg.sender == multiSig, "require multiSig");
        _;
    }

    function setMultiSig(address _multiSig) external onlyMultiSig {
        multiSig = _multiSig;
    }

    modifier onlyAdmin {
        require(msg.sender == admin, "require admin");
        _;
    }

    function setAdmin(address _admin) external onlyMultiSig {
        admin = _admin;
    }

    function enable(address feeder) public onlyMultiSig {
        require(!_feeders.contains(feeder), "duplicated feeder");
        _feeders.add(feeder);
        emit Enable(feeder);
    }

    function disable(address feeder) public onlyMultiSig {
        require(_feeders.contains(feeder), "not exist");
        _feeders.remove(feeder);

        for (uint i = 0; i < _tokens.length(); i++) {
            delete _prices[feeder][_tokens.at(i)];
        }
        emit Disable(feeder);
    }

    function enables(address[] calldata feeders) external onlyMultiSig {
        for (uint256 i = 0; i < feeders.length; i++) {
            enable(feeders[i]);
        }
        emit Enables(feeders);
    }

    function disables(address[] calldata feeders) external onlyMultiSig {
        for (uint256 i = 0; i < feeders.length; i++) {
            disable(feeders[i]);
        }
        emit Disables(feeders);
    }

    function enableToken(address token) public onlyAdmin {
        require(_tokens.add(token), "Duplicate token");
        emit EnableToken(token);
    }

    function disableToken(address token) public onlyAdmin {
        require(_tokens.remove(token), "nonexist token");
        //TODO: delete feeder's history price data
        emit DisableToken(token);
    }

    function enableTokens(address[] calldata tokens) external onlyAdmin {
        for (uint256 i = 0; i < tokens.length; i++) {
            enableToken(tokens[i]);
        }
        emit EnableTokens(tokens);
    }

    function disableTokens(address[] calldata tokens) external onlyAdmin {
        for (uint256 i = 0; i < tokens.length; i++) {
            disableToken(tokens[i]);
        }
        emit DisableTokens(tokens);
    }

    function tokens() public view returns (address[] memory) {
        address[] memory values = new address[](_tokens.length());
        for (uint256 i = 0; i < _tokens.length(); ++i) {
            values[i] = _tokens.at(i);
        }
        return values;
    }

    // 设置价格为 @val, 保持有效时间为 @exp second.
    function set(address token, uint val, uint exp) public auth {
        require(_feeders.contains(msg.sender), "unauth feeder");

        _prices[msg.sender][token].price = uint192(val);
        _prices[msg.sender][token].expiration = uint64(now + exp);

        int256[] memory priceList = new int256[](_feeders.length());
        uint256 j = 0;
        for (uint256 i = 0; i < _feeders.length(); i++) {
            address who = _feeders.at(i);
            if (_prices[who][token].price != 0 && now < _prices[who][token].expiration) {
                priceList[j++] = int256(_prices[who][token].price);
            }
        }

        int256[] memory priceFilter = new int256[](j);
        for (uint256 i = 0; i < j; i++) {
            priceFilter[i] = priceList[i];
        }

        finalPrices[token].price = uint192(Median.calculateInplace(priceFilter));
        finalPrices[token].expiration = uint64(now + exp);

        emit Set(msg.sender, token, val, exp);
    }

    //批量设置，减少gas使用
    function batchSet(address[] calldata tokens, uint[] calldata vals, uint exp) external auth {
        uint nToken = tokens.length;
        require(nToken == vals.length, "invalid array length");

        for (uint i = 0; i < nToken; ++i) {
            set(tokens[i], vals[i], now + exp);
        }

        emit BatchSet(tokens, vals, exp);
    }

    function getExpiration(address token) external view returns (uint) {
        return finalPrices[token].expiration;
    }

    function getPrice(address token) external view returns (uint) {
        return finalPrices[token].price;
    }

    function get(address token) external override view returns (uint, bool) {
        return (finalPrices[token].price, valid(token));
    }

    function valid(address token) public view returns (bool) {
        return now < finalPrices[token].expiration;
    }

    function getLastPriceByFeeder(address feeder, address token) public view returns (uint price, uint expiration) {
        return (_prices[feeder][token].price, _prices[feeder][token].expiration);
    }
}