/**
 *Submitted for verification at Etherscan.io on 2021-08-24
*/

// SPDX-License-Identifier: BUSL-1.1

pragma solidity 0.8.6;



// Part: BetaRunnerWithCallback

contract BetaRunnerWithCallback {
  address private constant NO_CALLER = address(42); // nonzero so we don't repeatedly clear storage
  address private caller = NO_CALLER;

  modifier withCallback() {
    require(caller == NO_CALLER);
    caller = msg.sender;
    _;
    caller = NO_CALLER;
  }

  modifier isCallback() {
    require(caller == tx.origin);
    _;
  }
}

// Part: BytesLib



// Part: IBetaBank



// Part: IUniswapV3Pool



// Part: IUniswapV3SwapCallback



// Part: IWETH



// Part: OpenZeppelin/[email protected]/Address

/**
 * @dev Collection of functions related to the address type
 */


// Part: OpenZeppelin/[email protected]/Context

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

// Part: OpenZeppelin/[email protected]/IERC20

/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
 */


// Part: OpenZeppelin/[email protected]/Math

/**
 * @dev Standard math utilities missing in the Solidity language.
 */


// Part: SafeCast

/// @title Safe casting methods
/// @notice Contains methods for safely casting between types


// Part: OpenZeppelin/[email protected]/Ownable

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

// Part: OpenZeppelin/[email protected]/SafeERC20

/**
 * @title SafeERC20
 * @dev Wrappers around ERC20 operations that throw on failure (when the token
 * contract returns false). Tokens that return no value (and instead revert or
 * throw on failure) are also supported, non-reverting calls are assumed to be
 * successful.
 * To use this library you can add a `using SafeERC20 for IERC20;` statement to your contract,
 * which allows you to call the safe operations as `token.safeTransfer(...)`, etc.
 */


// Part: Path

/// @title Functions for manipulating path data for multihop swaps


// Part: BetaRunnerBase

contract BetaRunnerBase is Ownable {
  using SafeERC20 for IERC20;

  address public immutable betaBank;
  address public immutable weth;

  modifier onlyEOA() {
    require(msg.sender == tx.origin, 'BetaRunnerBase/not-eoa');
    _;
  }

  constructor(address _betaBank, address _weth) {
    address bweth = IBetaBank(_betaBank).bTokens(_weth);
    require(bweth != address(0), 'BetaRunnerBase/no-bweth');
    IERC20(_weth).safeApprove(_betaBank, type(uint).max);
    IERC20(_weth).safeApprove(bweth, type(uint).max);
    betaBank = _betaBank;
    weth = _weth;
  }

  function _borrow(
    address _owner,
    uint _pid,
    address _underlying,
    address _collateral,
    uint _amountBorrow,
    uint _amountCollateral
  ) internal {
    if (_pid == type(uint).max) {
      _pid = IBetaBank(betaBank).open(_owner, _underlying, _collateral);
    } else {
      (address collateral, address bToken) = IBetaBank(betaBank).getPositionTokens(_owner, _pid);
      require(_collateral == collateral, '_borrow/collateral-not-_collateral');
      require(_underlying == IBetaBank(betaBank).underlyings(bToken), '_borrow/bad-underlying');
    }
    _approve(_collateral, betaBank, _amountCollateral);
    IBetaBank(betaBank).put(_owner, _pid, _amountCollateral);
    IBetaBank(betaBank).borrow(_owner, _pid, _amountBorrow);
  }

  function _repay(
    address _owner,
    uint _pid,
    address _underlying,
    address _collateral,
    uint _amountRepay,
    uint _amountCollateral
  ) internal {
    (address collateral, address bToken) = IBetaBank(betaBank).getPositionTokens(_owner, _pid);
    require(_collateral == collateral, '_repay/collateral-not-_collateral');
    require(_underlying == IBetaBank(betaBank).underlyings(bToken), '_repay/bad-underlying');
    _approve(_underlying, bToken, _amountRepay);
    IBetaBank(betaBank).repay(_owner, _pid, _amountRepay);
    IBetaBank(betaBank).take(_owner, _pid, _amountCollateral);
  }

  function _transferIn(
    address _token,
    address _from,
    uint _amount
  ) internal {
    if (_token == weth) {
      require(_from == msg.sender, '_transferIn/not-from-sender');
      require(_amount <= msg.value, '_transferIn/insufficient-eth-amount');
      IWETH(weth).deposit{value: _amount}();
      if (msg.value > _amount) {
        (bool success, ) = _from.call{value: msg.value - _amount}(new bytes(0));
        require(success, '_transferIn/eth-transfer-failed');
      }
    } else {
      IERC20(_token).safeTransferFrom(_from, address(this), _amount);
    }
  }

  function _transferOut(
    address _token,
    address _to,
    uint _amount
  ) internal {
    if (_token == weth) {
      IWETH(weth).withdraw(_amount);
      (bool success, ) = _to.call{value: _amount}(new bytes(0));
      require(success, '_transferOut/eth-transfer-failed');
    } else {
      IERC20(_token).safeTransfer(_to, _amount);
    }
  }

  /// @dev Approves infinite on the given token for the given spender if current approval is insufficient.
  function _approve(
    address _token,
    address _spender,
    uint _minAmount
  ) internal {
    uint current = IERC20(_token).allowance(address(this), _spender);
    if (current < _minAmount) {
      if (current != 0) {
        IERC20(_token).safeApprove(_spender, 0);
      }
      IERC20(_token).safeApprove(_spender, type(uint).max);
    }
  }

  /// @dev Caps repay amount by current position's debt.
  function _capRepay(
    address _owner,
    uint _pid,
    uint _amountRepay
  ) internal returns (uint) {
    return Math.min(_amountRepay, IBetaBank(betaBank).fetchPositionDebt(_owner, _pid));
  }

  /// @dev Recovers lost tokens for whatever reason by the owner.
  function recover(address _token, uint _amount) external onlyOwner {
    if (_amount == type(uint).max) {
      _amount = IERC20(_token).balanceOf(address(this));
    }
    IERC20(_token).safeTransfer(msg.sender, _amount);
  }

  /// @dev Recovers lost ETH for whatever reason by the owner.
  function recoverETH(uint _amount) external onlyOwner {
    if (_amount == type(uint).max) {
      _amount = address(this).balance;
    }
    (bool success, ) = msg.sender.call{value: _amount}(new bytes(0));
    require(success, 'recoverETH/eth-transfer-failed');
  }

  /// @dev Override Ownable.sol renounceOwnership to prevent accidental call
  function renounceOwnership() public override onlyOwner {
    revert('renounceOwnership/disabled');
  }

  receive() external payable {
    require(msg.sender == weth, 'receive/not-weth');
  }
}

// File: BetaRunnerUniswapV3.sol

contract BetaRunnerUniswapV3 is BetaRunnerBase, BetaRunnerWithCallback, IUniswapV3SwapCallback {
  using SafeERC20 for IERC20;
  using Path for bytes;
  using SafeCast for uint;

  /// @dev Constants from Uniswap V3 to be used for swap
  /// (https://github.com/Uniswap/uniswap-v3-core/blob/main/contracts/libraries/TickMath.sol)
  uint160 internal constant MIN_SQRT_RATIO = 4295128739;
  uint160 internal constant MAX_SQRT_RATIO = 1461446703485210103287273052203988822378723970342;

  address public immutable factory;
  bytes32 public immutable codeHash;

  constructor(
    address _betaBank,
    address _weth,
    address _factory,
    bytes32 _codeHash
  ) BetaRunnerBase(_betaBank, _weth) {
    factory = _factory;
    codeHash = _codeHash;
  }

  struct ShortData {
    uint pid;
    uint amountBorrow;
    uint amountPutExtra;
    bytes path;
    uint amountOutMin;
  }

  struct CloseData {
    uint pid;
    uint amountRepay;
    uint amountTake;
    bytes path;
    uint amountInMax;
  }

  struct CallbackData {
    uint pid;
    address path0;
    uint amount0;
    int memo; // positive if short (extra collateral) | negative if close (amount to take)
    bytes path;
    uint slippageControl; // amountInMax if close | amountOutMin if short
  }

  /// @dev Borrows the asset using the given collateral, and swaps it using the given path.
  function short(ShortData calldata _data) external payable onlyEOA withCallback {
    (, address collateral, ) = _data.path.decodeLastPool();
    _transferIn(collateral, msg.sender, _data.amountPutExtra);
    (address tokenIn, address tokenOut, uint24 fee) = _data.path.decodeFirstPool();
    bool zeroForOne = tokenIn < tokenOut;
    CallbackData memory cb = CallbackData({
      pid: _data.pid,
      path0: tokenIn,
      amount0: _data.amountBorrow,
      memo: _data.amountPutExtra.toInt256(),
      path: _data.path,
      slippageControl: _data.amountOutMin
    });
    IUniswapV3Pool(_poolFor(tokenIn, tokenOut, fee)).swap(
      address(this),
      zeroForOne,
      _data.amountBorrow.toInt256(),
      zeroForOne ? MIN_SQRT_RATIO + 1 : MAX_SQRT_RATIO - 1,
      abi.encode(cb)
    );
  }

  /// @dev Swaps the collateral to the underlying asset using the given path, and repays it to the pool.
  function close(CloseData calldata _data) external payable onlyEOA withCallback {
    uint amountRepay = _capRepay(msg.sender, _data.pid, _data.amountRepay);
    (address tokenOut, address tokenIn, uint24 fee) = _data.path.decodeFirstPool();
    bool zeroForOne = tokenIn < tokenOut;
    CallbackData memory cb = CallbackData({
      pid: _data.pid,
      path0: tokenOut,
      amount0: amountRepay,
      memo: -_data.amountTake.toInt256(),
      path: _data.path,
      slippageControl: _data.amountInMax
    });
    IUniswapV3Pool(_poolFor(tokenIn, tokenOut, fee)).swap(
      address(this),
      zeroForOne,
      -amountRepay.toInt256(),
      zeroForOne ? MIN_SQRT_RATIO + 1 : MAX_SQRT_RATIO - 1,
      abi.encode(cb)
    );
  }

  /// @dev Continues the action through uniswapv3
  function uniswapV3SwapCallback(
    int _amount0Delta,
    int _amount1Delta,
    bytes calldata _data
  ) external override isCallback {
    CallbackData memory data = abi.decode(_data, (CallbackData));
    (uint amountToPay, uint amountReceived) = _amount0Delta > 0
      ? (uint(_amount0Delta), uint(-_amount1Delta))
      : (uint(_amount1Delta), uint(-_amount0Delta));
    if (data.memo > 0) {
      _shortCallback(amountToPay, amountReceived, data);
    } else {
      _closeCallback(amountToPay, amountReceived, data);
    }
  }

  function _shortCallback(
    uint _amountToPay,
    uint _amountReceived,
    CallbackData memory data
  ) internal {
    (address tokenIn, address tokenOut, uint24 prevFee) = data.path.decodeFirstPool();
    require(msg.sender == _poolFor(tokenIn, tokenOut, prevFee), '_shortCallback/bad-caller');
    if (data.path.hasMultiplePools()) {
      data.path = data.path.skipToken();
      (, address tokenNext, uint24 fee) = data.path.decodeFirstPool();
      bool zeroForOne = tokenOut < tokenNext;
      IUniswapV3Pool(_poolFor(tokenOut, tokenNext, fee)).swap(
        address(this),
        zeroForOne,
        _amountReceived.toInt256(),
        zeroForOne ? MIN_SQRT_RATIO + 1 : MAX_SQRT_RATIO - 1,
        abi.encode(data)
      );
    } else {
      uint amountPut = _amountReceived + uint(data.memo);
      require(_amountReceived >= data.slippageControl, '!slippage');
      _borrow(tx.origin, data.pid, data.path0, tokenOut, data.amount0, amountPut);
    }
    IERC20(tokenIn).safeTransfer(msg.sender, _amountToPay);
  }

  function _closeCallback(
    uint _amountToPay,
    uint,
    CallbackData memory data
  ) internal {
    (address tokenOut, address tokenIn, uint24 prevFee) = data.path.decodeFirstPool();
    require(msg.sender == _poolFor(tokenIn, tokenOut, prevFee), '_closeCallback/bad-caller');
    if (data.path.hasMultiplePools()) {
      data.path = data.path.skipToken();
      (, address tokenNext, uint24 fee) = data.path.decodeFirstPool();
      bool zeroForOne = tokenNext < tokenIn;
      IUniswapV3Pool(_poolFor(tokenIn, tokenNext, fee)).swap(
        msg.sender,
        zeroForOne,
        -_amountToPay.toInt256(),
        zeroForOne ? MIN_SQRT_RATIO + 1 : MAX_SQRT_RATIO - 1,
        abi.encode(data)
      );
    } else {
      require(_amountToPay <= data.slippageControl, '!slippage');
      uint amountTake = uint(-data.memo);
      _repay(tx.origin, data.pid, data.path0, tokenIn, data.amount0, amountTake);
      IERC20(tokenIn).safeTransfer(msg.sender, _amountToPay);
      _transferOut(tokenIn, tx.origin, IERC20(tokenIn).balanceOf(address(this)));
    }
  }

  function _poolFor(
    address tokenA,
    address tokenB,
    uint24 fee
  ) internal view returns (address) {
    (address token0, address token1) = tokenA < tokenB ? (tokenA, tokenB) : (tokenB, tokenA);
    bytes32 salt = keccak256(abi.encode(token0, token1, fee));
    return address(uint160(uint(keccak256(abi.encodePacked(hex'ff', factory, salt, codeHash)))));
  }
}