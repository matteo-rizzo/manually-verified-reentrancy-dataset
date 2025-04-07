/**
 *Submitted for verification at Etherscan.io on 2021-03-26
*/

pragma solidity 0.6.4;
pragma experimental ABIEncoderV2;


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

// SPDX-License-Identifier: MIT
contract OracleProxy is Initializable, IOracleProxy {
    using SafeERC20 for IERC20;
    using SafeMath for uint256;

    address public multiSig;
    address public admin;
    address public proposedAdmin;
    
    //token价格来源, token地址=> 底层预言机或者底层预言机封装,The address to query price data, or zero if not supported.
    mapping (address => address) public oracles;//fortube oracle or chainlinkwrapper

    address public chainlinkWrapper;// oracles[token] == 0 ==> chainlink wrapper, otherwise fortube
    
    /// The governor sets oracle information for a token.
    event SetOracle(address _token, address _oracle);
    event SetOracles(address[] _tokens, address[] _oracles);
    event SetOraclesTo(address[] _tokens, address _oracle);
    event SetChainlinkWrapper(address _chainlinkWrapper);

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
    
    function setOracle(address _token, address _oracle) public onlyAdmin {
        oracles[_token] = _oracle;
        emit SetOracle(_token, _oracle);
    }

    function setOracles(address[] calldata _tokens, address[] calldata _oracles) external onlyAdmin {
        require(_tokens.length == _oracles.length, "inconsistent length");

        for (uint i = 0; i < _tokens.length; i++) {
            setOracle(_tokens[i], _oracles[i]);
        }

        emit SetOracles(_tokens, _oracles);
    }

    function setOraclesTo(address[] calldata _tokens, address _oracle) external onlyAdmin {
        for (uint i = 0; i < _tokens.length; i++) {
            setOracle(_tokens[i], _oracle);
        }
        emit SetOraclesTo(_tokens, _oracle);
    }

    function get(address token) public override view returns (uint, bool) {
        if (oracles[token] != address(0)) {
            return IPriceOracles(oracles[token]).get(token);//fortube
        }
        return IPriceOracles(chainlinkWrapper).get(token);
    }

    function setChainlinkWrapper(address _chainlinkWrapper) external onlyAdmin {
        chainlinkWrapper = _chainlinkWrapper;

        emit SetChainlinkWrapper(_chainlinkWrapper);
    }

    struct Price {
        uint256 px;
        bool ok;
    }

    function gets(address[] calldata tokens) external view returns (Price[] memory) {
        uint n = tokens.length;
        Price[] memory res = new Price[](n);
        for (uint i = 0; i < n; i++) {
            (res[i].px, res[i].ok) = get(tokens[i]);
        }

        return res;
    }
}