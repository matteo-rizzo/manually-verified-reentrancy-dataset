/**
 *Submitted for verification at Etherscan.io on 2021-08-18
*/

// SPDX-License-Identifier: NONE

pragma solidity 0.6.12;



// Part: OpenZeppelin/[email protected]/Address

/**
 * @dev Collection of functions related to the address type
 */


// Part: OpenZeppelin/[email protected]/IERC20

/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
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
        // extcodesize checks the size of the code stored in an address, and
        // address returns the current address. Since the code is still not
        // deployed when running a constructor, any checks on its code size will
        // yield zero, making it an effective way to detect if a contract is
        // under construction or not.
        address self = address(this);
        uint256 cs;
        // solhint-disable-next-line no-inline-assembly
        assembly { cs := extcodesize(self) }
        return cs == 0;
    }
}

// Part: OpenZeppelin/[email protected]/ReentrancyGuard

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

        // By storing the original value once again, a refund is triggered (see
        // https://eips.ethereum.org/EIPS/eip-2200)
        _status = _NOT_ENTERED;
    }
}

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


// File: AlphaStakingV2.sol

contract AlphaStakingV2 is Initializable, ReentrancyGuard {
  using SafeERC20 for IERC20;
  using SafeMath for uint;

  event SetWorker(address worker);
  event Stake(address owner, uint share, uint amount);
  event Unbond(address owner, uint unbondTime, uint unbondShare);
  event Withdraw(address owner, uint withdrawShare, uint withdrawAmount);
  event CancelUnbond(address owner, uint unbondTime, uint unbondShare);
  event Reward(address worker, uint rewardAmount);
  event Extract(address governor, uint extractAmount);

  uint public constant STATUS_READY = 0;
  uint public constant STATUS_UNBONDING = 1;
  uint public constant UNBONDING_DURATION = 30 days;
  uint public constant WITHDRAW_DURATION = 3 days;

  struct Data {
    uint status;
    uint share;
    uint unbondTime;
    uint unbondShare;
  }

  IERC20 public alpha;
  address public governor;
  address public pendingGovernor;
  address public worker;
  uint public totalAlpha;
  uint public totalShare;
  mapping(address => Data) public users;

  modifier onlyGov() {
    require(msg.sender == governor, 'onlyGov/not-governor');
    _;
  }

  modifier onlyWorker() {
    require(msg.sender == worker || msg.sender == governor, 'onlyWorker/not-worker');
    _;
  }

  function initialize(IERC20 _alpha, address _governor) external initializer {
    alpha = _alpha;
    governor = _governor;
  }

  function setWorker(address _worker) external onlyGov {
    worker = _worker;
    emit SetWorker(_worker);
  }

  function setPendingGovernor(address _pendingGovernor) external onlyGov {
    pendingGovernor = _pendingGovernor;
  }

  function acceptGovernor() external {
    require(msg.sender == pendingGovernor, 'acceptGovernor/not-pending');
    pendingGovernor = address(0);
    governor = msg.sender;
  }

  function getStakeValue(address user) external view returns (uint) {
    uint share = users[user].share;
    return share == 0 ? 0 : share.mul(totalAlpha).div(totalShare);
  }

  function stake(uint amount) external nonReentrant {
    require(amount >= 1e18, 'stake/amount-too-small');
    Data storage data = users[msg.sender];
    if (data.status != STATUS_READY) {
      emit CancelUnbond(msg.sender, data.unbondTime, data.unbondShare);
      data.status = STATUS_READY;
      data.unbondTime = 0;
      data.unbondShare = 0;
    }
    alpha.safeTransferFrom(msg.sender, address(this), amount);
    uint share = totalAlpha == 0 ? amount : amount.mul(totalShare).div(totalAlpha);
    totalAlpha = totalAlpha.add(amount);
    totalShare = totalShare.add(share);
    data.share = data.share.add(share);
    emit Stake(msg.sender, share, amount);
  }

  function unbond(uint share) external nonReentrant {
    Data storage data = users[msg.sender];
    if (data.status != STATUS_READY) {
      emit CancelUnbond(msg.sender, data.unbondTime, data.unbondShare);
    }
    require(share <= data.share, 'unbond/insufficient-share');
    data.status = STATUS_UNBONDING;
    data.unbondTime = block.timestamp;
    data.unbondShare = share;
    emit Unbond(msg.sender, block.timestamp, share);
  }

  function withdraw() external nonReentrant {
    Data storage data = users[msg.sender];
    require(data.status == STATUS_UNBONDING, 'withdraw/not-unbonding');
    require(block.timestamp >= data.unbondTime.add(UNBONDING_DURATION), 'withdraw/not-valid');
    require(
      block.timestamp < data.unbondTime.add(UNBONDING_DURATION).add(WITHDRAW_DURATION),
      'withdraw/already-expired'
    );
    uint share = data.unbondShare;
    uint amount = totalAlpha.mul(share).div(totalShare);
    totalAlpha = totalAlpha.sub(amount);
    totalShare = totalShare.sub(share);
    data.share = data.share.sub(share);
    emit Withdraw(msg.sender, share, amount);
    data.status = STATUS_READY;
    data.unbondTime = 0;
    data.unbondShare = 0;
    alpha.safeTransfer(msg.sender, amount);
    require(totalAlpha >= 1e18, 'withdraw/too-low-total-alpha');
  }

  function reward(uint amount) external onlyWorker {
    require(totalShare >= 1e18, 'reward/share-too-small');
    alpha.safeTransferFrom(msg.sender, address(this), amount);
    totalAlpha = totalAlpha.add(amount);
    emit Reward(msg.sender, amount);
  }

  function skim(uint amount) external onlyGov {
    alpha.safeTransfer(msg.sender, amount);
    require(alpha.balanceOf(address(this)) >= totalAlpha, 'skim/not-enough-balance');
  }

  function extract(uint amount) external onlyGov {
    totalAlpha = totalAlpha.sub(amount);
    alpha.safeTransfer(msg.sender, amount);
    require(totalAlpha >= 1e18, 'extract/too-low-total-alpha');
    emit Extract(msg.sender, amount);
  }
}