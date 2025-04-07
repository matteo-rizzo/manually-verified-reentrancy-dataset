// SPDX-License-Identifier: MIT

pragma solidity 0.6.8;


// 
/**
 * @dev Collection of functions related to the address type
 */


// 
/**
 * @title Proxy
 * @dev Implements delegation of calls to other contracts, with proper
 * forwarding of return values and bubbling of failures.
 * It defines a fallback function that delegates all calls to the address
 * returned by the abstract _implementation() internal function.
 *
 * Credit: https://github.com/OpenZeppelin/openzeppelin-sdk/blob/master/packages/lib/contracts/upgradeability/Proxy.sol
 */
abstract contract Proxy {

  /**
   * @dev Receive function.
   * Implemented entirely in `_fallback`.
   */
  receive () payable external {
    _fallback();
  }

  /**
   * @dev Fallback function.
   * Implemented entirely in `_fallback`.
   */
  fallback () payable external {
    _fallback();
  }

  /**
   * @return The Address of the implementation.
   */
  function _implementation() internal virtual view returns (address);

  /**
   * @dev Delegates execution to an implementation contract.
   * This is a low level function that doesn't return to its internal call site.
   * It will return to the external caller whatever the implementation returns.
   * @param implementation Address to delegate.
   */
  function _delegate(address implementation) internal {
    assembly {
      // Copy msg.data. We take full control of memory in this inline assembly
      // block because it will not return to Solidity code. We overwrite the
      // Solidity scratch pad at memory position 0.
      calldatacopy(0, 0, calldatasize())

      // Call the implementation.
      // out and outsize are 0 because we don't know the size yet.
      let result := delegatecall(gas(), implementation, 0, calldatasize(), 0, 0)

      // Copy the returned data.
      returndatacopy(0, 0, returndatasize())

      switch result
      // delegatecall returns 0 on error.
      case 0 { revert(0, returndatasize()) }
      default { return(0, returndatasize()) }
    }
  }

  /**
   * @dev Function that is run as the first thing in the fallback function.
   * Can be redefined in derived contracts to add functionality.
   * Redefinitions must call super._willFallback().
   */
  function _willFallback() internal virtual {
  }

  /**
   * @dev fallback implementation.
   * Extracted to enable manual triggering.
   */
  function _fallback() internal {
    _willFallback();
    _delegate(_implementation());
  }
}

// 
/**
 * @title BaseUpgradeabilityProxy
 * @dev This contract implements a proxy that allows to change the
 * implementation address to which it will delegate.
 * Such a change is called an implementation upgrade.
 *
 * Credit: https://github.com/OpenZeppelin/openzeppelin-sdk/blob/master/packages/lib/contracts/upgradeability/BaseUpgradeabilityProxy.sol
 */
contract BaseUpgradeabilityProxy is Proxy {
    /**
   * @dev Emitted when the implementation is upgraded.
   * @param implementation Address of the new implementation.
   */
    event Upgraded(address indexed implementation);

    /**
   * @dev Storage slot with the address of the current implementation.
   * This is the keccak-256 hash of "eip1967.proxy.implementation" subtracted by 1, and is
   * validated in the constructor.
   */
    bytes32 internal constant IMPLEMENTATION_SLOT = 0x360894a13ba1a3210667c828492db98dca3e2076cc3735a920a3ca505d382bbc;

    /**
   * @dev Returns the current implementation.
   * @return impl Address of the current implementation
   */
    function _implementation() internal override view returns (address impl) {
        bytes32 slot = IMPLEMENTATION_SLOT;
        assembly {
            impl := sload(slot)
        }
    }

    /**
   * @dev Sets the implementation address of the proxy.
   * @param newImplementation Address of the new implementation.
   */
    function _setImplementation(address newImplementation) internal {
        require(
            Address.isContract(newImplementation),
            "Implementation not set"
        );

        bytes32 slot = IMPLEMENTATION_SLOT;

        assembly {
            sstore(slot, newImplementation)
        }
        emit Upgraded(newImplementation);
    }
}

// 
/**
 * @title AdminUpgradeabilityProxy
 * @dev This contract combines an upgradeability proxy with an authorization
 * mechanism for administrative tasks.
 * All external functions in this contract must be guarded by the
 * `ifAdmin` modifier. See ethereum/solidity#3864 for a Solidity
 * feature proposal that would enable this to be done automatically.
 * Credit: https://github.com/OpenZeppelin/openzeppelin-sdk/blob/master/packages/lib/contracts/upgradeability/BaseAdminUpgradeabilityProxy.sol
 */
contract AdminUpgradeabilityProxy is BaseUpgradeabilityProxy {
  /**
   * @dev Emitted when the administration has been transferred.
   * @param previousAdmin Address of the previous admin.
   * @param newAdmin Address of the new admin.
   */
  event AdminChanged(address previousAdmin, address newAdmin);

  /**
   * @dev Storage slot with the admin of the contract.
   * This is the keccak-256 hash of "eip1967.proxy.admin" subtracted by 1, and is
   * validated in the constructor.
   */

  bytes32 internal constant ADMIN_SLOT = 0xb53127684a568b3173ae13b9f8a6016e243e63b6e8ee1178d6a717850b5d6103;

  /**
   * Contract constructor.
   * @param _logic address of the initial implementation.
   * @param _admin Address of the proxy administrator.
   * It should include the signature and the parameters of the function to be called, as described in
   * https://solidity.readthedocs.io/en/v0.4.24/abi-spec.html#function-selector-and-argument-encoding.
   * This parameter is optional, if no data is given the initialization call to proxied contract will be skipped.
   */
  constructor(address _logic, address _admin) public payable {
    assert(ADMIN_SLOT == bytes32(uint256(keccak256('eip1967.proxy.admin')) - 1));
    assert(IMPLEMENTATION_SLOT == bytes32(uint256(keccak256("eip1967.proxy.implementation")) - 1));
    _setImplementation(_logic);
    _setAdmin(_admin);
  }

  /**
   * @dev Modifier to check whether the `msg.sender` is the admin.
   * If it is, it will run the function. Otherwise, it will delegate the call
   * to the implementation.
   */
  modifier ifAdmin() {
    if (msg.sender == _admin()) {
      _;
    } else {
      _fallback();
    }
  }

  /**
   * @return The address of the proxy admin.
   */
  function admin() external ifAdmin returns (address) {
    return _admin();
  }

  /**
   * @return The address of the implementation.
   */
  function implementation() external ifAdmin returns (address) {
    return _implementation();
  }

  /**
   * @dev Changes the admin of the proxy.
   * Only the current admin can call this function.
   * @param newAdmin Address to transfer proxy administration to.
   */
  function changeAdmin(address newAdmin) external ifAdmin {
    emit AdminChanged(_admin(), newAdmin);
    _setAdmin(newAdmin);
  }

  /**
   * @dev Upgrade the backing implementation of the proxy.
   * Only the admin can call this function.
   * @param newImplementation Address of the new implementation.
   */
  function changeImplementation(address newImplementation) external ifAdmin {
    _setImplementation(newImplementation);
  }

  /**
   * @return adm The admin slot.
   */
  function _admin() internal view returns (address adm) {
    bytes32 slot = ADMIN_SLOT;
    assembly {
      adm := sload(slot)
    }
  }

  /**
   * @dev Sets the address of the proxy admin.
   * @param newAdmin Address of the new proxy admin.
   */
  function _setAdmin(address newAdmin) internal {
    bytes32 slot = ADMIN_SLOT;

    assembly {
      sstore(slot, newAdmin)
    }
  }
}

// 
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


// 
/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
 */


// 
/**
 * @title SafeERC20
 * @dev Wrappers around ERC20 operations that throw on failure (when the token
 * contract returns false). Tokens that return no value (and instead revert or
 * throw on failure) are also supported, non-reverting calls are assumed to be
 * successful.
 * To use this library you can add a `using SafeERC20 for IERC20;` statement to your contract,
 * which allows you to call the safe operations as `token.safeTransfer(...)`, etc.
 */


// 
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
 *
 * Credit: https://github.com/OpenZeppelin/openzeppelin-upgrades/blob/master/packages/core/contracts/Initializable.sol
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

// 
/**
 * @notice An account contracted created for each user address.
 * @dev Anyone can directy deposit assets to the Account contract.
 * @dev Only operators can withdraw asstes or perform operation from the Account contract.
 */
contract Account is Initializable {
    using SafeMath for uint256;
    using SafeERC20 for IERC20;

    /**
     * @dev Asset is withdrawn from the Account.
     */
    event Withdrawn(address indexed tokenAddress, address indexed targetAddress, uint256 amount);

    /**
     * @dev Spender is allowed to spend an asset.
     */
    event Approved(address indexed tokenAddress, address indexed targetAddress, uint256 amount);

    /**
     * @dev A transaction is invoked on the Account.
     */
    event Invoked(address indexed targetAddress, uint256 value, bytes data);

    address public owner;
    mapping(address => bool) public admins;
    mapping(address => bool) public operators;

    /**
     * @dev Initializes the owner, admin and operator roles.
     * @param _owner Address of the contract owner
     * @param _initialAdmins The list of addresses that are granted the admin role.
     */
    function initialize(address _owner, address[] memory _initialAdmins) public initializer {
        owner = _owner;
        // Grant the admin role to the initial admins
        for (uint256 i = 0; i < _initialAdmins.length; i++) {
            admins[_initialAdmins[i]] = true;
        }
    }

    /**
     * @dev Throws if called by any account that does not have operator role.
     */
    modifier onlyOperator() {
        require(isOperator(msg.sender), "not operator");
        _;
    }

    /**
     * @dev Transfers the ownership of the account to another address.
     * The new owner can be an zero address which means renouncing the ownership.
     * @param _owner New owner address
     */
    function transferOwnership(address _owner) public {
        require(msg.sender == owner, "not owner");
        owner = _owner;
    }

    /**
     * @dev Grants admin role to a new address.
     * @param _account New admin address.
     */
    function grantAdmin(address _account) public {
        require(msg.sender == owner, "not owner");
        require(!admins[_account], "already admin");

        admins[_account] = true;
    }

    /**
     * @dev Revokes the admin role from an address. Only owner can revoke admin.
     * @param _account The admin address to revoke.
     */
    function revokeAdmin(address _account) public {
        require(msg.sender == owner, "not owner");
        require(admins[_account], "not admin");

        admins[_account] = false;
    }

    /**
     * @dev Grants operator role to a new address. Only owner or admin can grant operator roles.
     * @param _account The new operator address.
     */
    function grantOperator(address _account) public {
        require(msg.sender == owner || admins[msg.sender], "not admin");
        require(!operators[_account], "already operator");

        operators[_account] = true;
    }

    /**
     * @dev Revoke operator role from an address. Only owner or admin can revoke operator roles.
     * @param _account The operator address to revoke.
     */
    function revokeOperator(address _account) public {
        require(msg.sender == owner || admins[msg.sender], "not admin");
        require(operators[_account], "not operator");

        operators[_account] = false;
    }

    /**
     * @dev Allows Account contract to receive ETH.
     */
    receive() payable external {}

    /**
     * @dev Checks whether a user is an operator of the contract.
     * Since admin role can grant operator role and owner can grant admin role, we treat both
     * admins and owner as operators!
     * @param userAddress Address to check whether it's an operator.
     */
    function isOperator(address userAddress) public view returns (bool) {
        return userAddress == owner || admins[userAddress] || operators[userAddress];
    }

    /**
     * @dev Withdraws ETH from the Account contract. Only operators can withdraw ETH.
     * @param targetAddress Address to send the ETH to.
     * @param amount Amount of ETH to withdraw.
     */
    function withdraw(address payable targetAddress, uint256 amount) public onlyOperator {
        targetAddress.transfer(amount);
        // Use address(-1) to represent ETH.
        emit Withdrawn(address(-1), targetAddress, amount);
    }

    /**
     * @dev Withdraws ERC20 token from the Account contract. Only operators can withdraw ERC20 tokens.
     * @param tokenAddress Address of the ERC20 to withdraw.
     * @param targetAddress Address to send the ERC20 to.
     * @param amount Amount of ERC20 token to withdraw.
     */
    function withdrawToken(address tokenAddress, address targetAddress, uint256 amount) public onlyOperator {
        IERC20(tokenAddress).safeTransfer(targetAddress, amount);
        emit Withdrawn(tokenAddress, targetAddress, amount);
    }

    /**
     * @dev Withdraws ERC20 token from the Account contract. If the Account contract does not have sufficient balance,
     * try to withdraw from the owner's address as well. This is useful if users wants to keep assets in their own wallet
     * by setting adequate allowance to the Account contract.
     * @param tokenAddress Address of the ERC20 to withdraw.
     * @param targetAddress Address to send the ERC20 to.
     * @param amount Amount of ERC20 token to withdraw.
     */
    function withdrawTokenFallThrough(address tokenAddress, address targetAddress, uint256 amount) public onlyOperator {
        uint256 tokenBalance = IERC20(tokenAddress).balanceOf(address(this));
        // If we have enough token balance, send the token directly.
        if (tokenBalance >= amount) {
            IERC20(tokenAddress).safeTransfer(targetAddress, amount);
            emit Withdrawn(tokenAddress, targetAddress, amount);
        } else {
            IERC20(tokenAddress).safeTransferFrom(owner, targetAddress, amount.sub(tokenBalance));
            IERC20(tokenAddress).safeTransfer(targetAddress, tokenBalance);
            emit Withdrawn(tokenAddress, targetAddress, amount);
        }
    }

    /**
     * @dev Allows the spender address to spend up to the amount of token.
     * @param tokenAddress Address of the ERC20 that can spend.
     * @param targetAddress Address which can spend the ERC20.
     * @param amount Amount of ERC20 that can be spent by the target address.
     */
    function approveToken(address tokenAddress, address targetAddress, uint256 amount) public onlyOperator {
        IERC20(tokenAddress).safeApprove(targetAddress, 0);
        IERC20(tokenAddress).safeApprove(targetAddress, amount);
        emit Approved(tokenAddress, targetAddress, amount);
    }

    /**
     * @notice Performs a generic transaction on the Account contract.
     * @param target The address for the target contract.
     * @param value The value of the transaction.
     * @param data The data of the transaction.
     */
    function invoke(address target, uint256 value, bytes memory data) public onlyOperator returns (bytes memory result) {
        bool success;
        (success, result) = target.call{value: value}(data);
        if (!success) {
            // solhint-disable-next-line no-inline-assembly
            assembly {
                returndatacopy(0, 0, returndatasize())
                revert(0, returndatasize())
            }
        }
        emit Invoked(target, value, data);
    }
}

// 
/**
 * @notice Factory of Account contracts.
 */
contract AccountFactory {

    /**
     * @dev A new Account contract is created.
     */
    event AccountCreated(address indexed userAddress, address indexed accountAddress);

    address public governance;
    address public accountBase;
    mapping(address => address) public accounts;

    /**
     * @dev Constructor for Account Factory.
     * @param _accountBase Base account implementation.
     */
    constructor(address _accountBase) public {
        require(_accountBase != address(0x0), "account base not set");
        governance = msg.sender;
        accountBase = _accountBase;
    }

    /**
     * @dev Updates the base account implementation. Base account must be set.
     */
    function setAccountBase(address _accountBase) public {
        require(msg.sender == governance, "not governance");
        require(_accountBase != address(0x0), "account base not set");

        accountBase = _accountBase;
    }

    /**
     * @dev Updates the govenance address. Governance can be empty address which means
     * renouncing the governance.
     */
    function setGovernance(address _governance) public {
        require(msg.sender == governance, "not governance");
        governance = _governance;
    }

    /**
     * @dev Creates a new Account contract for the caller.
     * Users can create multiple accounts by invoking this method multiple times. However,
     * only the latest one is actively tracked and used by the platform.
     * @param _initialAdmins The list of addresses that are granted the admin role.
     */
    function createAccount(address[] memory _initialAdmins) public returns (Account) {
        AdminUpgradeabilityProxy proxy = new AdminUpgradeabilityProxy(accountBase, msg.sender);
        Account account = Account(address(proxy));
        account.initialize(msg.sender, _initialAdmins);
        accounts[msg.sender] = address(account);

        emit AccountCreated(msg.sender, address(account));

        return account;
    }
}