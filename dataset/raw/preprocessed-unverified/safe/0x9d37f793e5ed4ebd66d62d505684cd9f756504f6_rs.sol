pragma solidity 0.6.12;
pragma experimental ABIEncoderV2;
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
abstract contract Context {
    function _msgSender() internal view virtual returns (address payable) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes memory) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}
contract Pausable is Context {
    /**
     * @dev Emitted when the pause is triggered by `account`.
     */
    event Paused(address account);

    /**
     * @dev Emitted when the pause is lifted by `account`.
     */
    event Unpaused(address account);

    bool private _paused;

    /**
     * @dev Initializes the contract in unpaused state.
     */
    constructor () internal {
        _paused = false;
    }

    /**
     * @dev Returns true if the contract is paused, and false otherwise.
     */
    function paused() public view returns (bool) {
        return _paused;
    }

    /**
     * @dev Modifier to make a function callable only when the contract is not paused.
     *
     * Requirements:
     *
     * - The contract must not be paused.
     */
    modifier whenNotPaused() {
        require(!_paused, "Pausable: paused");
        _;
    }

    /**
     * @dev Modifier to make a function callable only when the contract is paused.
     *
     * Requirements:
     *
     * - The contract must be paused.
     */
    modifier whenPaused() {
        require(_paused, "Pausable: not paused");
        _;
    }

    /**
     * @dev Triggers stopped state.
     *
     * Requirements:
     *
     * - The contract must not be paused.
     */
    function _pause() internal virtual whenNotPaused {
        _paused = true;
        emit Paused(_msgSender());
    }

    /**
     * @dev Returns to normal state.
     *
     * Requirements:
     *
     * - The contract must be paused.
     */
    function _unpause() internal virtual whenPaused {
        _paused = false;
        emit Unpaused(_msgSender());
    }
}
contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    constructor () internal {
        address msgSender = _msgSender();
        _owner = msgSender;
        emit OwnershipTransferred(address(0), msgSender);
    }

    /**
     * @dev Returns the address of the current owner.
     */
    function owner() public view returns (address) {
        return _owner;
    }

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        require(_owner == _msgSender(), "Ownable: caller is not the owner");
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
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}





contract BatchZkSyncDeposit is Ownable, Pausable, ReentrancyGuard {
  using SafeERC20 for IERC20;

  // Placeholder token address to represent ETH deposits
  IERC20 private constant ETH_TOKEN_PLACEHOLDER = IERC20(
    0xEeeeeEeeeEeEeeEeEeEeeEEEeeeeEeeeeeeeEEeE
  );

  // Instance of the zkSync contract
  IZkSync public immutable zkSync;

  // Required parameters for each deposit
  struct Deposit {
    IERC20 token; // address of the token to deposit
    uint104 amount; // amount of tokens to deposit (uint104 because that's what zkSync uses)
  }

  // Emitted on each deposit
  event DepositMade(IERC20 indexed token, uint104 indexed amount, address indexed user);

  // Emitted when allowances are changed
  event AllowanceSet(IERC20 indexed token, uint256 amount);

  /**
   * @notice Sets address of the zkSync contract and approves zkSync contract to spend our tokens
   * @param _zkSync Address of the zkSync contract
   * @param _tokens Array of token address to approve
   */
  constructor(address _zkSync, IERC20[] memory _tokens) public {
    zkSync = IZkSync(_zkSync);

    for (uint256 i = 0; i < _tokens.length; i += 1) {
      // To use safeApprove, we must use solc 0.6.8 or above due to a constructor-related bug
      // fix in that version. See details at:
      //   Issue: https://github.com/ethereum/solidity/issues/8656
      //   Led to PR: https://github.com/ethereum/solidity/pull/8849
      //   Released in: https://github.com/ethereum/solidity/releases/tag/v0.6.8
      _tokens[i].safeApprove(_zkSync, uint256(-1));
    }
  }

  /**
   * @notice Sets allowance of zkSync to spend the specified token
   * @param _token Address of token to set allowance for
   * @param _amount Value to set allowance to
   */
  function setAllowance(IERC20 _token, uint256 _amount) external onlyOwner {
    _token.safeApprove(address(zkSync), _amount);
    emit AllowanceSet(_token, _amount);
  }

  /**
   * @notice Performs deposits to the zkSync contract
   * @dev We assume (1) all token approvals were already executed, and (2) all deposits go to
   * the same recipient
   * @param _recipient Address of the account that should receive the funds on zkSync
   * @param _deposits Array of deposit structs. A token address should only be present one time
   * in this array to minimize gas costs
   */
  function deposit(address _recipient, Deposit[] calldata _deposits)
    external
    payable
    nonReentrant
    whenNotPaused
  {
    for (uint256 i = 0; i < _deposits.length; i++) {
      emit DepositMade(_deposits[i].token, _deposits[i].amount, msg.sender);
      if (_deposits[i].token != ETH_TOKEN_PLACEHOLDER) {
        // Token deposit
        _deposits[i].token.safeTransferFrom(msg.sender, address(this), _deposits[i].amount);
        zkSync.depositERC20(_deposits[i].token, _deposits[i].amount, _recipient);
      } else {
        // ETH deposit
        // Make sure the value sent equals the specified deposit amount
        require(msg.value == _deposits[i].amount, "BatchZkSyncDeposit: ETH value mismatch");
        zkSync.depositETH{value: msg.value}(_recipient);
      }
    }
  }

  /**
   * @notice Pause contract
   */
  function pause() external onlyOwner whenNotPaused {
    _pause();
  }

  /**
   * @notice Unpause contract
   */
  function unpause() external onlyOwner whenPaused {
    _unpause();
  }
}