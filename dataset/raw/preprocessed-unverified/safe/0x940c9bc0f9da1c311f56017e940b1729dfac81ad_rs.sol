/**
 *Submitted for verification at Etherscan.io on 2020-07-27
*/

pragma solidity 0.5.16;


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






contract LidPromoFund is Initializable {
    using SafeMath for uint;

    ILidCertifiableToken private lidToken;
    address public authorizor;
    address public releaser;

    uint public totalLidAuthorized;
    uint public totalLidReleased;

    uint public totalEthAuthorized;
    uint public totalEthReleased;

    function initialize(
        address _authorizor,
        address _releaser,
        ILidCertifiableToken _lidToken
    ) external initializer {
        lidToken = _lidToken;
        authorizor = _authorizor;
        releaser = _releaser;
    }

    function() external payable { }

    function releaseLidToAddress(address receiver, uint amount) external returns(uint) {
        require(msg.sender == releaser, "Can only be called releaser.");
        require(amount <= totalLidAuthorized.sub(totalLidReleased), "Cannot release more Lid than available.");
        totalLidReleased = totalLidReleased.add(amount);
        lidToken.transfer(receiver, amount);
    }

    function authorizeLid(uint amount) external returns (uint) {
        require(msg.sender == authorizor, "Can only be called authorizor.");
        totalLidAuthorized = totalLidAuthorized.add(amount);
    }

    function releaseEthToAddress(address receiver, uint amount) external returns(uint) {
        require(msg.sender == releaser, "Can only be called releaser.");
        require(amount <= totalEthAuthorized.sub(totalEthReleased), "Cannot release more Eth than available.");
        totalEthReleased = totalEthReleased.add(amount);
        lidToken.transfer(receiver, amount);
    }

    function authorizeEth(uint amount) external returns (uint) {
        require(msg.sender == authorizor, "Can only be called authorizor.");
        totalEthAuthorized = totalEthAuthorized.add(amount);
    }
}