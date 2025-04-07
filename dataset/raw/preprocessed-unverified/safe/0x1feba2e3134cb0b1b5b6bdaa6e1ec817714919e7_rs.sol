/**
 *Submitted for verification at Etherscan.io on 2021-03-26
*/

pragma solidity 0.6.4;
pragma experimental ABIEncoderV2;


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

// SPDX-License-Identifier: MIT
// chainlink 价格合约接口


contract ChainlinkWrapper is Initializable, IPriceOracles {
    using SafeERC20 for IERC20;
    using SafeMath for uint256;

    address public multiSig;
    address public admin;
    
    // ETH网络：存储 ETH/USD 交易对合约地址, 其他xxx_ETH合约通过ETH/USD进行中转计算
    address public ethToUsdPriceOracle;
    // 维护需要从chainlink取价格的token 地址 => chainlink 价格合约地址的映射
    mapping(address => address) public tokenChainlinkMap;

    struct Price {
        uint price;
        uint expiration;
    }

    mapping (address => Price) public prices;

    mapping (address => bool) public directTokenMap;//直接调用 token=> true, other false
    
    //BNB网络：存储BNB/USD 交易对合约地址, 其他xxx_BNB合约通过BNB/USD进行中转计算
    address public bnbToUsdPriceOracle;

    event SetTokenChainlinkMap(address token, address chainlink);
    event SetTokenChainlinkMaps(address[] tokens, address[] chainlinks);

    event SetDirectTokenMap(address token, bool direct);
    event SetDirectTokenMaps(address[] tokens, bool direct);


    function initialize(address _multiSig)
        public
        initializer
    {
        multiSig = _multiSig;
        admin = msg.sender;
    }

    // constructor(address _multiSig) public
    // {
    //     multiSig = _multiSig;
    //     admin = msg.sender;
    // }

    receive() external payable {}

    modifier onlyAdmin {
        require(msg.sender == admin, "require admin");
        _;
    }

    modifier onlyMultiSig {
        require(msg.sender == multiSig, "require multiSig");
        _;
    }

    function setMultiSig(address _multiSig) external onlyMultiSig {
        multiSig = _multiSig;
    }

    function setAdmin(address _admin) external onlyMultiSig {
        admin = _admin;
    }

    function isEthOrBnB(address token) public view returns (bool) {
        if (token == address(0xEeeeeEeeeEeEeeEeEeEeeEEEeeeeEeeeeeeeEEeE)
             || token == address(0)
             || token == address(0xbBbBBBBbbBBBbbbBbbBbbbbBBbBbbbbBbBbbBBbB)) {
            return true;
        }
        return false;
    }

    function get(address token) external override view returns (uint256, bool) {
        if (tokenChainlinkMap[token] != address(0)) {
            return getChainLinkPrice(token);
        }
        
        return (0, false);
    }

    function setEthToUsdPriceOracle(address _ethToUsdPriceOracle) external onlyAdmin {
        ethToUsdPriceOracle = _ethToUsdPriceOracle;
    }

    function setBnbToUsdPriceOracle(address _bnbToUsdPriceOracle) external onlyAdmin {
        bnbToUsdPriceOracle = _bnbToUsdPriceOracle;
    }

    function setTokenChainlinkMap(address token, address chainlink)
        public
        onlyAdmin
    {
        tokenChainlinkMap[token] = chainlink;
        emit SetTokenChainlinkMap(token, chainlink);
    }

    function setTokenChainlinkMaps(address[] calldata tokens, address[] calldata chainlinks)
        external
        onlyAdmin
    {
        require(tokens.length == chainlinks.length, "inconsistent length");
        for (uint i = 0; i < tokens.length; i++) {
            setTokenChainlinkMap(tokens[i], chainlinks[i]);
        }
        emit SetTokenChainlinkMaps(tokens, chainlinks);
    }

    function setDirectTokenMap(address token, bool direct) external onlyAdmin {
        directTokenMap[token] = direct;

        emit SetDirectTokenMap(token, direct);
    }

    function setDirectTokenMaps(address[] calldata tokens, bool direct) external onlyAdmin {
        for (uint i = 0; i < tokens.length; i++) {
            directTokenMap[tokens[i]] = direct;
        }

        emit SetDirectTokenMaps(tokens, direct);
    }

    function getChainLinkPrice(address token)
        public
        view
        returns (uint256, bool)
    {
        // 未设置中转，返回无效价格
        if (ethToUsdPriceOracle == address(0) && bnbToUsdPriceOracle == address(0)) {
            return (0, false);
        }

        // 同时设置，返回失败
        if (ethToUsdPriceOracle != address(0) && bnbToUsdPriceOracle != address(0)) {
            return (0, false);
        }

        address referenceOracle = address(0);
        
        if (ethToUsdPriceOracle != address(0) && bnbToUsdPriceOracle == address(0)) {
            referenceOracle = ethToUsdPriceOracle;
        }

        if (ethToUsdPriceOracle == address(0) && bnbToUsdPriceOracle != address(0)) {
            referenceOracle = bnbToUsdPriceOracle;
        }

        // 构造 chainlink 合约实例
        AggregatorInterface chainlinkContract = AggregatorInterface(
            referenceOracle
        );
        // 获取 ETH/USD 交易对的价格，单位是 1e8
        int256 basePrice = chainlinkContract.latestAnswer();
        // 若要获取 ETH 的价格，则返回 1e8 * 1e10 = 1e18
        // ETH上的ETH，BSC的BNB，直接调用chainlink，或者设置的直接调用的token，直接调用chainlink
        if (isEthOrBnB(token)) {
            return (uint256(basePrice).mul(1e10), true);
        }

        if (directTokenMap[token]) {
            // 构造 chainlink 合约实例
            chainlinkContract = AggregatorInterface(tokenChainlinkMap[token]);
            // 获取 XXX/USD 交易对的价格，单位是 1e8
            basePrice = chainlinkContract.latestAnswer();
            return (uint256(basePrice).mul(1e10), true);
        }

        // // 获取 token/ETH 交易对的价格（目前是 USDT 和 USDC ），单位是 1e18
        chainlinkContract = AggregatorInterface(tokenChainlinkMap[token]);
        int256 tokenPrice = chainlinkContract.latestAnswer();
        return (uint256(basePrice).mul(uint256(tokenPrice)).div(1e8), true);
    }

    function getLatestRoundData(address token)
        public
        view
        returns (uint256, uint256)
    {
        // 未设置中转，返回无效价格
        if (ethToUsdPriceOracle == address(0) && bnbToUsdPriceOracle == address(0)) {
            return (0, 0);
        }

        // 同时设置，返回失败
        if (ethToUsdPriceOracle != address(0) && bnbToUsdPriceOracle != address(0)) {
            return (0, 0);
        }

        address referenceOracle = address(0);
        
        if (ethToUsdPriceOracle != address(0) && bnbToUsdPriceOracle == address(0)) {
            referenceOracle = ethToUsdPriceOracle;
        }

        if (ethToUsdPriceOracle == address(0) && bnbToUsdPriceOracle != address(0)) {
            referenceOracle = bnbToUsdPriceOracle;
        }

        // 构造 chainlink 合约实例
        AggregatorInterface chainlinkContract = AggregatorInterface(
            referenceOracle
        );
        // 获取 ETH/USD 交易对的价格，单位是 1e8
        int256 basePrice = chainlinkContract.latestAnswer();

        (,,, uint256 updatedAt,) = chainlinkContract.latestRoundData();


        // 若要获取 ETH 的价格，则返回 1e8 * 1e10 = 1e18
        // ETH上的ETH，BSC的BNB，直接调用chainlink，或者设置的直接调用的token，直接调用chainlink
        if (isEthOrBnB(token)) {
            return (uint256(basePrice).mul(1e10), updatedAt);
        }

        if (directTokenMap[token]) {
            // 构造 chainlink 合约实例
            chainlinkContract = AggregatorInterface(tokenChainlinkMap[token]);
    
            (,,,updatedAt,) = chainlinkContract.latestRoundData();

            // 获取 XXX/USD 交易对的价格，单位是 1e8
            basePrice = chainlinkContract.latestAnswer();
            return (uint256(basePrice).mul(1e10), updatedAt);
        }

        // // 获取 token/ETH 交易对的价格（目前是 USDT 和 USDC ），单位是 1e18
        chainlinkContract = AggregatorInterface(tokenChainlinkMap[token]);
        int256 tokenPrice = chainlinkContract.latestAnswer();

        (,,, uint256 updatedAt1,) = chainlinkContract.latestRoundData();
        
        uint256 latest = updatedAt1 > updatedAt ? updatedAt1 : updatedAt;

        return (uint256(basePrice).mul(uint256(tokenPrice)).div(1e8), latest);
    }

    struct ChainlinkPrice {
        uint256 px;
        uint256 updatedAt;
    }

    function gets(address[] calldata tokens) external view returns (ChainlinkPrice[] memory) {
        uint n = tokens.length;
        ChainlinkPrice[] memory res = new ChainlinkPrice[](n);
        for (uint i = 0; i < n; i++) {
            (res[i].px, res[i].updatedAt) = getLatestRoundData(tokens[i]);
        }

        return res;
    }
}