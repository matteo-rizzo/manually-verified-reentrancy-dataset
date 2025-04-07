/**
 *Submitted for verification at Etherscan.io on 2021-07-27
*/

// SPDX-License-Identifier: MIT

pragma solidity 0.6.12;
pragma experimental ABIEncoderV2;



// Part: IAlphaStakingTier



// Part: IBaseOracle



// Part: IERC20Wrapper



// Part: OpenZeppelin/[email protected]/Address

/**
 * @dev Collection of functions related to the address type
 */


// Part: OpenZeppelin/[email protected]/SafeMath

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


// Part: OpenZeppelin/[email protected]/Initializable

/**
 * @dev This is a base contract to aid in writing upgradeable contracts, or any kind of contract that will be deployed
 * behind a proxy. Since a proxied contract can't have a constructor, it's common to move constructor logic to an
 * external initializer function, usually called `initialize`. It then becomes necessary to protect this initializer
 * function so it can only be called once. The {initializer} modifier provided by this contract will have this effect.
 *
 * TIP: To avoid leaving the proxy in an uninitialized state, the initializer function should be called as early as
 * possible by providing the encoded function call as the `_data` argument to {UpgradeableProxy-constructor}.
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
        require(_initializing || _isConstructor() || !_initialized, "Initializable: contract is already initialized");

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

    /// @dev Returns true if and only if the function is running in the constructor
    function _isConstructor() private view returns (bool) {
        return !Address.isContract(address(this));
    }
}

// Part: Governable

contract Governable is Initializable {
  event SetGovernor(address governor);
  event SetPendingGovernor(address pendingGovernor);
  event AcceptGovernor(address governor);

  address public governor; // The current governor.
  address public pendingGovernor; // The address pending to become the governor once accepted.

  bytes32[64] _gap; // reserve space for upgrade

  modifier onlyGov() {
    require(msg.sender == governor, 'not the governor');
    _;
  }

  /// @dev Initialize using msg.sender as the first governor.
  function __Governable__init() internal initializer {
    governor = msg.sender;
    pendingGovernor = address(0);
    emit SetGovernor(msg.sender);
  }

  /// @dev Set the pending governor, which will be the governor once accepted.
  /// @param _pendingGovernor The address to become the pending governor.
  function setPendingGovernor(address _pendingGovernor) external onlyGov {
    pendingGovernor = _pendingGovernor;
    emit SetPendingGovernor(_pendingGovernor);
  }

  /// @dev Accept to become the new governor. Must be called by the pending governor.
  function acceptGovernor() external {
    require(msg.sender == pendingGovernor, 'not the pending governor');
    pendingGovernor = address(0);
    governor = msg.sender;
    emit AcceptGovernor(msg.sender);
  }
}

// File: TierProxyOracle.sol

contract TierProxyOracle is Governable {
  using SafeMath for uint;

  /// The governor sets oracle token factor for a token for a tier
  event SetTierTokenFactor(address indexed token, uint indexed tier, TokenFactor factor);
  /// The governor unsets oracle token factor for a token.
  event UnsetTierTokenInfo(address indexed token);
  /// The governor sets token whitelist for an ERC1155 token.
  event SetWhitelist(address indexed token, bool ok);
  /// The governor sets liquidation incentive for a token.
  event SetLiqIncentive(address indexed token, uint liqIncentive);

  struct TokenFactor {
    uint16 borrowFactor; // The borrow factor for this token, multiplied by 1e4.
    uint16 collateralFactor; // The collateral factor for this token, multiplied by 1e4.
  }

  IBaseOracle public immutable source; // Main oracle source
  IAlphaStakingTier public immutable alphaTier; // alpha tier contract address
  uint public immutable tierCount; // number of tiers
  mapping(address => TokenFactor[]) public tierTokenFactors; // Mapping from token to list of token factor by tier.
  mapping(address => uint) public liqIncentives; // Mapping from token to liquidation incentive, multiplied by 1e4.
  mapping(address => bool) public whitelistERC1155; // Mapping from token address to whitelist status

  /// @dev Create the contract and initialize the first governor.
  constructor(IBaseOracle _source, IAlphaStakingTier _alphaTier) public {
    __Governable__init();
    source = _source;
    alphaTier = _alphaTier;
    tierCount = _alphaTier.tierCount();
  }

  /// @dev Set token factors and liq incentives for the given list of token addresses in each tier
  /// @param _tokens List of token addresses
  /// @param _tokenFactors List of token factors in each tier for each token.
  /// @param _liqIncentives List of Liquidation incentive, multiplied by 1e4.
  function setTierTokenFactors(
    address[] calldata _tokens,
    TokenFactor[][] memory _tokenFactors,
    uint[] calldata _liqIncentives
  ) external onlyGov {
    require(_tokenFactors.length == _tokens.length, 'token factors & tokens length mismatched');
    require(_liqIncentives.length == _tokens.length, 'liq incentive & tokens length mismatched');
    for (uint idx = 0; idx < _tokens.length; idx++) {
      require(
        _tokenFactors[idx].length == tierCount,
        'token factor of token & tier count length mismatched'
      );
      // clear old values
      delete tierTokenFactors[_tokens[idx]];
      // push new values
      for (uint i = 0; i < _tokenFactors[idx].length; i++) {
        // check values
        if (i > 0) {
          require(
            _tokenFactors[idx][i - 1].borrowFactor >= _tokenFactors[idx][i].borrowFactor,
            'borrow factors should be non-increasing'
          );
          require(
            _tokenFactors[idx][i - 1].collateralFactor <= _tokenFactors[idx][i].collateralFactor,
            'collateral factors should be non-decreasing'
          );
        }
        // push
        tierTokenFactors[_tokens[idx]].push(_tokenFactors[idx][i]);
        emit SetTierTokenFactor(_tokens[idx], i, _tokenFactors[idx][i]);
      }
      require(
        _tokenFactors[idx][_tokenFactors[idx].length - 1].borrowFactor >= 1e4,
        'borrow factor must be at least 10000'
      );
      require(
        _tokenFactors[idx][_tokenFactors[idx].length - 1].collateralFactor <= 1e4,
        'collateral factor must be no more than 10000'
      );
      // set liq incentive
      require(_liqIncentives[idx] != 0, 'liq incentive should != 0');
      liqIncentives[_tokens[idx]] = _liqIncentives[idx];
      emit SetLiqIncentive(_tokens[idx], _liqIncentives[idx]);
    }
  }

  /// @dev Unset token factors and liq incentives for the given list of token addresses
  /// @param _tokens List of token addresses to unset info
  function unsetTierTokenInfos(address[] calldata _tokens) external onlyGov {
    for (uint idx = 0; idx < _tokens.length; idx++) {
      delete liqIncentives[_tokens[idx]];
      delete tierTokenFactors[_tokens[idx]];
      emit UnsetTierTokenInfo(_tokens[idx]);
    }
  }

  /// @dev Set whitelist status for the given list of token addresses.
  /// @param tokens List of tokens to set whitelist status
  /// @param ok Whitelist status
  function setWhitelistERC1155(address[] calldata tokens, bool ok) external onlyGov {
    for (uint idx = 0; idx < tokens.length; idx++) {
      whitelistERC1155[tokens[idx]] = ok;
      emit SetWhitelist(tokens[idx], ok);
    }
  }

  /// @dev Return whether the oracle supports evaluating collateral value of the given token.
  /// @param token ERC1155 token address to check for support
  /// @param id ERC1155 token id to check for support
  function supportWrappedToken(address token, uint id) external view returns (bool) {
    if (!whitelistERC1155[token]) return false;
    address tokenUnderlying = IERC20Wrapper(token).getUnderlyingToken(id);
    return liqIncentives[tokenUnderlying] != 0;
  }

  /// @dev Return the amount of token out as liquidation reward for liquidating token in.
  /// @param tokenIn Input ERC20 token
  /// @param tokenOut Output ERC1155 token
  /// @param tokenOutId Output ERC1155 token id
  /// @param amountIn Input ERC20 token amount
  function convertForLiquidation(
    address tokenIn,
    address tokenOut,
    uint tokenOutId,
    uint amountIn
  ) external view returns (uint) {
    require(whitelistERC1155[tokenOut], 'bad token');
    address tokenOutUnderlying = IERC20Wrapper(tokenOut).getUnderlyingToken(tokenOutId);
    uint rateUnderlying = IERC20Wrapper(tokenOut).getUnderlyingRate(tokenOutId);
    uint liqIncentiveIn = liqIncentives[tokenIn];
    uint liqIncentiveOut = liqIncentives[tokenOutUnderlying];
    require(liqIncentiveIn != 0, 'bad underlying in');
    require(liqIncentiveOut != 0, 'bad underlying out');
    uint pxIn = source.getETHPx(tokenIn);
    uint pxOut = source.getETHPx(tokenOutUnderlying);
    uint amountOut = amountIn.mul(pxIn).div(pxOut);
    amountOut = amountOut.mul(2**112).div(rateUnderlying);
    return amountOut.mul(liqIncentiveIn).mul(liqIncentiveOut).div(10000 * 10000);
  }

  /// @dev Return the value of the given input as ETH for collateral purpose.
  /// @param token ERC1155 token address to get collateral value
  /// @param id ERC1155 token id to get collateral value
  /// @param amount Token amount to get collateral value
  /// @param owner Token owner address
  function asETHCollateral(
    address token,
    uint id,
    uint amount,
    address owner
  ) external view returns (uint) {
    require(whitelistERC1155[token], 'bad token');
    address tokenUnderlying = IERC20Wrapper(token).getUnderlyingToken(id);
    uint rateUnderlying = IERC20Wrapper(token).getUnderlyingRate(id);
    uint amountUnderlying = amount.mul(rateUnderlying).div(2**112);
    uint tier = alphaTier.getAlphaTier(owner);
    uint collFactor = tierTokenFactors[tokenUnderlying][tier].collateralFactor;
    require(liqIncentives[tokenUnderlying] != 0, 'bad underlying collateral');
    require(collFactor != 0, 'bad coll factor');
    uint ethValue = source.getETHPx(tokenUnderlying).mul(amountUnderlying).div(2**112);
    return ethValue.mul(collFactor).div(10000);
  }

  /// @dev Return the value of the given input as ETH for borrow purpose.
  /// @param token ERC20 token address to get borrow value
  /// @param amount ERC20 token amount to get borrow value
  /// @param owner Token owner address
  function asETHBorrow(
    address token,
    uint amount,
    address owner
  ) external view returns (uint) {
    uint tier = alphaTier.getAlphaTier(owner);
    uint borrFactor = tierTokenFactors[token][tier].borrowFactor;
    require(liqIncentives[token] != 0, 'bad underlying borrow');
    require(borrFactor < 50000, 'bad borr factor');
    uint ethValue = source.getETHPx(token).mul(amount).div(2**112);
    return ethValue.mul(borrFactor).div(10000);
  }

  /// @dev Return whether the ERC20 token is supported
  /// @param token The ERC20 token to check for support
  function support(address token) external view returns (bool) {
    try source.getETHPx(token) returns (uint px) {
      return px != 0 && liqIncentives[token] != 0;
    } catch {
      return false;
    }
  }
}