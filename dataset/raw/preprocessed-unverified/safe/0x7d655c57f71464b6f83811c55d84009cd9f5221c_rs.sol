/**
 *Submitted for verification at Etherscan.io on 2020-06-11
*/

pragma solidity ^0.6.2;
pragma experimental ABIEncoderV2;


contract ReentrancyGuard {
  bool private _notEntered;

  constructor() internal {
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


contract Context {
  // Empty internal constructor, to prevent people from mistakenly deploying
  // an instance of this contract, which should be used via inheritance.
  constructor() internal {}

  function _msgSender() internal virtual view returns (address payable) {
    return msg.sender;
  }

  function _msgData() internal virtual view returns (bytes memory) {
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
  constructor() internal {
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
   */
  modifier whenNotPaused() {
    require(!_paused, "Pausable: paused");
    _;
  }

  /**
   * @dev Modifier to make a function callable only when the contract is paused.
   */
  modifier whenPaused() {
    require(_paused, "Pausable: not paused");
    _;
  }

  /**
   * @dev Triggers stopped state.
   */
  function _pause() internal virtual whenNotPaused {
    _paused = true;
    emit Paused(_msgSender());
  }

  /**
   * @dev Returns to normal state.
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
  constructor() internal {
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














contract BulkCheckout is Ownable, Pausable, ReentrancyGuard {
  using Address for address payable;
  using SafeMath for uint256;
  /**
   * @notice Placeholder token address for ETH donations. This address is used in various other
   * projects as a stand-in for ETH
   */
  address constant ETH_TOKEN_PLACHOLDER = 0xEeeeeEeeeEeEeeEeEeEeeEEEeeeeEeeeeeeeEEeE;

  /**
   * @notice Required parameters for each donation
   */
  struct Donation {
    address token; // address of the token to donate
    uint256 amount; // amount of tokens to donate
    address payable dest; // grant address
  }

  /**
   * @dev Emitted on each donation
   */
  event DonationSent(
    address indexed token,
    uint256 indexed amount,
    address dest,
    address indexed donor
  );

  /**
   * @dev Emitted when a token or ETH is withdrawn from the contract
   */
  event TokenWithdrawn(address indexed token, uint256 indexed amount, address indexed dest);

  /**
   * @notice Bulk gitcoin grant donations
   * @dev We assume all token approvals were already executed
   * @param _donations Array of donation structs
   */
  function donate(Donation[] calldata _donations) external payable nonReentrant whenNotPaused {
    // We track total ETH donations to ensure msg.value is exactly correct
    uint256 _ethDonationTotal = 0;

    for (uint256 i = 0; i < _donations.length; i++) {
      emit DonationSent(_donations[i].token, _donations[i].amount, _donations[i].dest, msg.sender);
      if (_donations[i].token != ETH_TOKEN_PLACHOLDER) {
        // Token donation
        // This method throws on failure, so there is no return value to check
        SafeERC20.safeTransferFrom(
          IERC20(_donations[i].token),
          msg.sender,
          _donations[i].dest,
          _donations[i].amount
        );
      } else {
        // ETH donation
        // See comments in Address.sol for why we use sendValue over transer
        _donations[i].dest.sendValue(_donations[i].amount);
        _ethDonationTotal = _ethDonationTotal.add(_donations[i].amount);
      }
    }

    // Revert if the wrong amount of ETH was sent
    require(msg.value == _ethDonationTotal, "BulkCheckout: Too much ETH sent");
  }

  /**
   * @notice Transfers all tokens of the input adress to the recipient. This is
   * useful tokens are accidentally sent to this contrasct
   * @param _tokenAddress address of token to send
   * @param _dest destination address to send tokens to
   */
  function withdrawToken(address _tokenAddress, address _dest) external onlyOwner {
    uint256 _balance = IERC20(_tokenAddress).balanceOf(address(this));
    emit TokenWithdrawn(_tokenAddress, _balance, _dest);
    SafeERC20.safeTransfer(IERC20(_tokenAddress), _dest, _balance);
  }

  /**
   * @notice Transfers all Ether to the specified address
   * @param _dest destination address to send ETH to
   */
  function withdrawEther(address payable _dest) external onlyOwner {
    uint256 _balance = address(this).balance;
    emit TokenWithdrawn(ETH_TOKEN_PLACHOLDER, _balance, _dest);
    _dest.sendValue(_balance);
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