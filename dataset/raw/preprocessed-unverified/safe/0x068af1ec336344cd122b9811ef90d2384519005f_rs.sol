/**
 *Submitted for verification at Etherscan.io on 2021-08-11
*/

// SPDX-License-Identifier: BUSL-1.1

pragma solidity 0.8.6;



// Part: IBetaBank



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

// File: BetaRunnerLending.sol

contract BetaRunnerLending is BetaRunnerBase {
  constructor(address _betaBank, address _weth) BetaRunnerBase(_betaBank, _weth) {}

  /// @dev Borrows the asset using the given collateral.
  function borrow(
    uint _pid,
    address _underlying,
    address _collateral,
    uint _amountBorrow,
    uint _amountPut
  ) external payable onlyEOA {
    _transferIn(_collateral, msg.sender, _amountPut);
    _borrow(msg.sender, _pid, _underlying, _collateral, _amountBorrow, _amountPut);
    _transferOut(_underlying, msg.sender, _amountBorrow);
  }

  /// @dev Repays the debt and takes collateral for owner.
  function repay(
    uint _pid,
    address _underlying,
    address _collateral,
    uint _amountRepay,
    uint _amountTake
  ) external payable onlyEOA {
    _amountRepay = _capRepay(msg.sender, _pid, _amountRepay);
    _transferIn(_underlying, msg.sender, _amountRepay);
    _repay(msg.sender, _pid, _underlying, _collateral, _amountRepay, _amountTake);
    _transferOut(_collateral, msg.sender, _amountTake);
  }
}