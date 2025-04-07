/**
 *Submitted for verification at Etherscan.io on 2021-08-11
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

// Part: IBetaBank



// Part: IPancakeCallee



// Part: IUniswapV2Callee



// Part: IUniswapV2Pair



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

// File: BetaRunnerUniswapV2.sol

contract BetaRunnerUniswapV2 is
  BetaRunnerBase,
  BetaRunnerWithCallback,
  IUniswapV2Callee,
  IPancakeCallee
{
  using SafeCast for uint;
  using SafeERC20 for IERC20;

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

  struct CallbackData {
    uint pid;
    int memo; // positive if short (extra collateral) | negative if close (amount to take)
    address[] path;
    uint[] amounts;
  }

  function short(
    uint _pid,
    uint _amountBorrow,
    uint _amountPutExtra,
    address[] memory _path,
    uint _amountOutMin
  ) external payable onlyEOA withCallback {
    _transferIn(_path[_path.length - 1], msg.sender, _amountPutExtra);
    uint[] memory amounts = _getAmountsOut(_amountBorrow, _path);
    require(amounts[amounts.length - 1] >= _amountOutMin, 'short/not-enough-out');
    IUniswapV2Pair(_pairFor(_path[0], _path[1])).swap(
      _path[0] < _path[1] ? 0 : amounts[1],
      _path[0] < _path[1] ? amounts[1] : 0,
      address(this),
      abi.encode(
        CallbackData({pid: _pid, memo: _amountPutExtra.toInt256(), path: _path, amounts: amounts})
      )
    );
  }

  function close(
    uint _pid,
    uint _amountRepay,
    uint _amountTake,
    address[] memory _path,
    uint _amountInMax
  ) external payable onlyEOA withCallback {
    _amountRepay = _capRepay(msg.sender, _pid, _amountRepay);
    uint[] memory amounts = _getAmountsIn(_amountRepay, _path);
    require(amounts[0] <= _amountInMax, 'close/too-much-in');
    IUniswapV2Pair(_pairFor(_path[0], _path[1])).swap(
      _path[0] < _path[1] ? 0 : amounts[1],
      _path[0] < _path[1] ? amounts[1] : 0,
      address(this),
      abi.encode(
        CallbackData({pid: _pid, memo: -_amountTake.toInt256(), path: _path, amounts: amounts})
      )
    );
  }

  /// @dev Continues the action (uniswap / sushiswap)
  function uniswapV2Call(
    address sender,
    uint,
    uint,
    bytes calldata data
  ) external override isCallback {
    require(sender == address(this), 'uniswapV2Call/bad-sender');
    _pairCallback(data);
  }

  /// @dev Continues the action (pancakeswap)
  function pancakeCall(
    address sender,
    uint,
    uint,
    bytes calldata data
  ) external override isCallback {
    require(sender == address(this), 'pancakeCall/bad-sender');
    _pairCallback(data);
  }

  /// @dev Continues the action (uniswap / sushiswap / pancakeswap)
  function _pairCallback(bytes calldata data) internal {
    CallbackData memory cb = abi.decode(data, (CallbackData));
    require(msg.sender == _pairFor(cb.path[0], cb.path[1]), '_pairCallback/bad-caller');
    uint len = cb.path.length;
    if (len > 2) {
      address pair = _pairFor(cb.path[1], cb.path[2]);
      IERC20(cb.path[1]).safeTransfer(pair, cb.amounts[1]);
      for (uint idx = 1; idx < len - 1; idx++) {
        (address input, address output) = (cb.path[idx], cb.path[idx + 1]);
        address to = idx < len - 2 ? _pairFor(output, cb.path[idx + 2]) : address(this);
        uint amount0Out = input < output ? 0 : cb.amounts[idx + 1];
        uint amount1Out = input < output ? cb.amounts[idx + 1] : 0;
        IUniswapV2Pair(pair).swap(amount0Out, amount1Out, to, new bytes(0));
        pair = to;
      }
    }
    if (cb.memo > 0) {
      uint amountCollateral = uint(cb.memo);
      (address und, address col) = (cb.path[0], cb.path[len - 1]);
      _borrow(tx.origin, cb.pid, und, col, cb.amounts[0], cb.amounts[len - 1] + amountCollateral);
      IERC20(und).safeTransfer(msg.sender, cb.amounts[0]);
    } else {
      uint amountTake = uint(-cb.memo);
      (address und, address col) = (cb.path[len - 1], cb.path[0]);
      _repay(tx.origin, cb.pid, und, col, cb.amounts[len - 1], amountTake);
      IERC20(col).safeTransfer(msg.sender, cb.amounts[0]);
      _transferOut(col, tx.origin, IERC20(col).balanceOf(address(this)));
    }
  }

  /// Internal UniswapV2 library functions
  /// See https://github.com/Uniswap/uniswap-v2-periphery/blob/master/contracts/libraries/UniswapV2Library.sol
  function _sortTokens(address tokenA, address tokenB)
    internal
    pure
    returns (address token0, address token1)
  {
    require(tokenA != tokenB, 'IDENTICAL_ADDRESSES');
    (token0, token1) = tokenA < tokenB ? (tokenA, tokenB) : (tokenB, tokenA);
    require(token0 != address(0), 'ZERO_ADDRESS');
  }

  function _pairFor(address tokenA, address tokenB) internal view returns (address) {
    (address token0, address token1) = _sortTokens(tokenA, tokenB);
    bytes32 salt = keccak256(abi.encodePacked(token0, token1));
    return address(uint160(uint(keccak256(abi.encodePacked(hex'ff', factory, salt, codeHash)))));
  }

  function _getReserves(address tokenA, address tokenB)
    internal
    view
    returns (uint reserveA, uint reserveB)
  {
    (address token0, ) = _sortTokens(tokenA, tokenB);
    (uint reserve0, uint reserve1, ) = IUniswapV2Pair(_pairFor(tokenA, tokenB)).getReserves();
    (reserveA, reserveB) = tokenA == token0 ? (reserve0, reserve1) : (reserve1, reserve0);
  }

  function _getAmountOut(
    uint amountIn,
    uint reserveIn,
    uint reserveOut
  ) internal pure returns (uint amountOut) {
    require(amountIn > 0, 'INSUFFICIENT_INPUT_AMOUNT');
    require(reserveIn > 0 && reserveOut > 0, 'INSUFFICIENT_LIQUIDITY');
    uint amountInWithFee = amountIn * 997;
    uint numerator = amountInWithFee * reserveOut;
    uint denominator = (reserveIn * 1000) + amountInWithFee;
    amountOut = numerator / denominator;
  }

  function _getAmountIn(
    uint amountOut,
    uint reserveIn,
    uint reserveOut
  ) internal pure returns (uint amountIn) {
    require(amountOut > 0, 'INSUFFICIENT_OUTPUT_AMOUNT');
    require(reserveIn > 0 && reserveOut > 0, 'INSUFFICIENT_LIQUIDITY');
    uint numerator = reserveIn * amountOut * 1000;
    uint denominator = (reserveOut - amountOut) * 997;
    amountIn = (numerator / denominator) + 1;
  }

  function _getAmountsOut(uint amountIn, address[] memory path)
    internal
    view
    returns (uint[] memory amounts)
  {
    require(path.length >= 2, 'INVALID_PATH');
    amounts = new uint[](path.length);
    amounts[0] = amountIn;
    for (uint i; i < path.length - 1; i++) {
      (uint reserveIn, uint reserveOut) = _getReserves(path[i], path[i + 1]);
      amounts[i + 1] = _getAmountOut(amounts[i], reserveIn, reserveOut);
    }
  }

  function _getAmountsIn(uint amountOut, address[] memory path)
    internal
    view
    returns (uint[] memory amounts)
  {
    require(path.length >= 2, 'INVALID_PATH');
    amounts = new uint[](path.length);
    amounts[amounts.length - 1] = amountOut;
    for (uint i = path.length - 1; i > 0; i--) {
      (uint reserveIn, uint reserveOut) = _getReserves(path[i - 1], path[i]);
      amounts[i - 1] = _getAmountIn(amounts[i], reserveIn, reserveOut);
    }
  }
}