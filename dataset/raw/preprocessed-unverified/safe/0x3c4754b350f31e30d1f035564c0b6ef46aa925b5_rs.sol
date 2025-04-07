/**
 *Submitted for verification at Etherscan.io on 2020-10-20
*/

// SPDX-License-Identifier: MIT

pragma solidity 0.6.8;


// 
/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
 */


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
 * @dev Collection of functions related to the address type
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
        if (amount > 0) {
            IERC20(tokenAddress).safeApprove(targetAddress, amount);
        }
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

// 
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

// 
/**
 * @notice Interface for ERC20 token which supports minting new tokens.
 */
interface IERC20Mintable is IERC20 {
    
    function mint(address _user, uint256 _amount) external;

}

// 
/**
 * @notice Interface for ERC20 token which supports mint and burn.
 */
interface IERC20MintableBurnable is IERC20Mintable {
    
    function burn(address _user, uint256 _amount) external;
}

// 
/**
 * @notice ACoconut swap.
 */
contract ACoconutSwap is Initializable, ReentrancyGuard {
    using SafeMath for uint256;
    using SafeERC20 for IERC20;

    /**
     * @dev Token swapped between two underlying tokens.
     */
    event TokenSwapped(address indexed buyer, address indexed tokenSold, address indexed tokenBought, uint256 amountSold, uint256 amountBought);
    /**
     * @dev New pool token is minted.
     */
    event Minted(address indexed provider, uint256 mintAmount, uint256[] amounts, uint256 feeAmount);
    /**
     * @dev Pool token is redeemed.
     */
    event Redeemed(address indexed provider, uint256 redeemAmount, uint256[] amounts, uint256 feeAmount);
    /**
     * @dev Fee is collected.
     */
    event FeeCollected(address indexed feeRecipient, uint256 feeAmount);

    uint256 public constant feeDenominator = 10 ** 10;
    address[] public tokens;
    uint256[] public precisions; // 10 ** (18 - token decimals)
    uint256[] public balances; // Converted to 10 ** 18
    uint256 public mintFee; // Mint fee * 10**10
    uint256 public swapFee; // Swap fee * 10**10
    uint256 public redeemFee; // Redeem fee * 10**10
    address public feeRecipient;
    address public poolToken;
    uint256 public totalSupply; // The total amount of pool token minted by the swap.
                                // It might be different from the pool token supply as the pool token can have multiple minters.

    address public governance;
    mapping(address => bool) public admins;
    bool public paused;

    uint256 public initialA;

    /**
     * @dev Initialize the ACoconut Swap.
     */
    function initialize(address[] memory _tokens, uint256[] memory _precisions, uint256[] memory _fees,
        address _poolToken, uint256 _A) public initializer {
        require(_tokens.length == _precisions.length, "input mismatch");
        require(_fees.length == 3, "no fees");
        for (uint256 i = 0; i < _tokens.length; i++) {
            require(_tokens[i] != address(0x0), "token not set");
            require(_precisions[i] != 0, "precision not set");
            balances.push(0);
        }
        require(_poolToken != address(0x0), "pool token not set");

        governance = msg.sender;
        feeRecipient = msg.sender;
        tokens = _tokens;
        precisions = _precisions;
        mintFee = _fees[0];
        swapFee = _fees[1];
        redeemFee = _fees[2];
        poolToken = _poolToken;

        initialA = _A;

        // The swap must start with paused state!
        paused = true;
    }

    /**
     * @dev Returns the current value of A. This method might be updated in the future.
     */
    function getA() public view returns (uint256) {
        return initialA;
    }

    /**
     * @dev Computes D given token balances.
     * @param _balances Normalized balance of each token.
     * @param _A Amplification coefficient from getA()
     */
    function _getD(uint256[] memory _balances, uint256 _A) internal pure returns (uint256) {
        uint256 sum = 0;
        uint256 i = 0;
        uint256 Ann = _A;
        for (i = 0; i < _balances.length; i++) {
            sum = sum.add(_balances[i]);
            Ann = Ann.mul(_balances.length);
        }
        if (sum == 0)   return 0;

        uint256 prevD = 0;
        uint256 D = sum;
        for (i = 0; i < 255; i++) {
            uint256 pD = D;
            for (uint256 j = 0; j < _balances.length; j++) {
                // pD = pD * D / (_x * balance.length)
                pD = pD.mul(D).div(_balances[j].mul(_balances.length));
            }
            prevD = D;
            // D = (Ann * sum + pD * balance.length) * D / ((Ann - 1) * D + (balance.length + 1) * pD)
            D = Ann.mul(sum).add(pD.mul(_balances.length)).mul(D).div(Ann.sub(1).mul(D).add(_balances.length.add(1).mul(pD)));
            if (D > prevD) {
                if (D - prevD <= 1) break;
            } else {
                if (prevD - D <= 1) break;
            }
        }

        return D;
    }

    /**
     * @dev Computes token balance given D.
     * @param _balances Converted balance of each token except token with index _j.
     * @param _j Index of the token to calculate balance.
     * @param _D The target D value.
     * @param _A Amplification coeffient.
     * @return Converted balance of the token with index _j.
     */
    function _getY(uint256[] memory _balances, uint256 _j, uint256 _D, uint256 _A) internal pure returns (uint256) {
        uint256 c = _D;
        uint256 S_ = 0;
        uint256 Ann = _A;
        uint256 i = 0;
        for (i = 0; i < _balances.length; i++) {
            Ann = Ann.mul(_balances.length);
            if (i == _j) continue;
            S_ = S_.add(_balances[i]);
            // c = c * D / (_x * N)
            c = c.mul(_D).div(_balances[i].mul(_balances.length));
        }
        // c = c * D / (Ann * N)
        c = c.mul(_D).div(Ann.mul(_balances.length));
        // b = S_ + D / Ann
        uint256 b = S_.add(_D.div(Ann));
        uint256 prevY = 0;
        uint256 y = _D;

        // 255 since the result is 256 digits
        for (i = 0; i < 255; i++) {
            prevY = y;
            // y = (y * y + c) / (2 * y + b - D)
            y = y.mul(y).add(c).div(y.mul(2).add(b).sub(_D));
            if (y > prevY) {
                if (y - prevY <= 1) break;
            } else {
                if (prevY - y <= 1) break;
            }
        }

        return y;
    }

    /**
     * @dev Compute the amount of pool token that can be minted.
     * @param _amounts Unconverted token balances.
     * @return The amount of pool token minted.
     */
    function getMintAmount(uint256[] calldata _amounts) external view returns (uint256, uint256) {
        uint256[] memory _balances = balances;
        require(_amounts.length == _balances.length, "invalid amount");
        
        uint256 A = getA();
        uint256 oldD = totalSupply;
        uint256 i = 0;
        for (i = 0; i < _balances.length; i++) {
            if (_amounts[i] == 0)   continue;
            // balance = balance + amount * precision
            _balances[i] = _balances[i].add(_amounts[i].mul(precisions[i]));
        }
        uint256 newD = _getD(_balances, A);
        // newD should be bigger than or equal to oldD
        uint256 mintAmount = newD.sub(oldD);
        uint256 feeAmount = 0;

        if (mintFee > 0) {
            feeAmount = mintAmount.mul(mintFee).div(feeDenominator);
            mintAmount = mintAmount.sub(feeAmount);
        }

        return (mintAmount, feeAmount);
    }

    /**
     * @dev Mints new pool token.
     * @param _amounts Unconverted token balances used to mint pool token.
     * @param _minMintAmount Minimum amount of pool token to mint.
     */
    function mint(uint256[] calldata _amounts, uint256 _minMintAmount) external nonReentrant {
        uint256[] memory _balances = balances;
        // If swap is paused, only admins can mint.
        require(!paused || admins[msg.sender], "paused");
        require(_balances.length == _amounts.length, "invalid amounts");

        uint256 A = getA();
        uint256 oldD = totalSupply;
        uint256 i = 0;
        for (i = 0; i < _balances.length; i++) {
            if (_amounts[i] == 0) {
                // Initial deposit requires all tokens provided!
                require(oldD > 0, "zero amount");
                continue;
            }
            _balances[i] = _balances[i].add(_amounts[i].mul(precisions[i]));
        }
        uint256 newD = _getD(_balances, A);
        // newD should be bigger than or equal to oldD
        uint256 mintAmount = newD.sub(oldD);

        uint256 fee = mintFee;
        uint256 feeAmount;
        if (fee > 0) {
            feeAmount = mintAmount.mul(fee).div(feeDenominator);
            mintAmount = mintAmount.sub(feeAmount);
        }
        require(mintAmount >= _minMintAmount, "fewer than expected");

        // Transfer tokens into the swap
        for (i = 0; i < _amounts.length; i++) {
            if (_amounts[i] == 0)    continue;
            // Update the balance in storage
            balances[i] = _balances[i];
            IERC20(tokens[i]).safeTransferFrom(msg.sender, address(this), _amounts[i]);
        }
        totalSupply = newD;
        IERC20MintableBurnable(poolToken).mint(feeRecipient, feeAmount);
        IERC20MintableBurnable(poolToken).mint(msg.sender, mintAmount);

        emit Minted(msg.sender, mintAmount, _amounts, feeAmount);
    }

    /**
     * @dev Computes the output amount after the swap.
     * @param _i Token index to swap in.
     * @param _j Token index to swap out.
     * @param _dx Unconverted amount of token _i to swap in.
     * @return Unconverted amount of token _j to swap out.
     */
    function getSwapAmount(uint256 _i, uint256 _j, uint256 _dx) external view returns (uint256) {
        uint256[] memory _balances = balances;
        require(_i != _j, "same token");
        require(_i < _balances.length, "invalid in");
        require(_j < _balances.length, "invalid out");
        require(_dx > 0, "invalid amount");

        uint256 A = getA();
        uint256 D = totalSupply;
        // balance[i] = balance[i] + dx * precisions[i]
        _balances[_i] = _balances[_i].add(_dx.mul(precisions[_i]));
        uint256 y = _getY(_balances, _j, D, A);
        // dy = (balance[j] - y - 1) / precisions[j] in case there was rounding errors
        uint256 dy = _balances[_j].sub(y).sub(1).div(precisions[_j]);

        if (swapFee > 0) {
            dy = dy.sub(dy.mul(swapFee).div(feeDenominator));
        }

        return dy;
    }

    /**
     * @dev Exchange between two underlying tokens.
     * @param _i Token index to swap in.
     * @param _j Token index to swap out.
     * @param _dx Unconverted amount of token _i to swap in.
     * @param _minDy Minimum token _j to swap out in converted balance.
     */
    function swap(uint256 _i, uint256 _j, uint256 _dx, uint256 _minDy) external nonReentrant {
        uint256[] memory _balances = balances;
        // If swap is paused, only admins can swap.
        require(!paused || admins[msg.sender], "paused");
        require(_i != _j, "same token");
        require(_i < _balances.length, "invalid in");
        require(_j < _balances.length, "invalid out");
        require(_dx > 0, "invalid amount");

        uint256 A = getA();
        uint256 D = totalSupply;
        // balance[i] = balance[i] + dx * precisions[i]
        _balances[_i] = _balances[_i].add(_dx.mul(precisions[_i]));
        uint256 y = _getY(_balances, _j, D, A);
        // dy = (balance[j] - y - 1) / precisions[j] in case there was rounding errors
        uint256 dy = _balances[_j].sub(y).sub(1).div(precisions[_j]);
        // Update token balance in storage
        balances[_j] = y;
        balances[_i] = _balances[_i];

        uint256 fee = swapFee;
        if (fee > 0) {
            dy = dy.sub(dy.mul(fee).div(feeDenominator));
        }
        require(dy >= _minDy, "fewer than expected");

        IERC20(tokens[_i]).safeTransferFrom(msg.sender, address(this), _dx);
        // Important: When swap fee > 0, the swap fee is charged on the output token.
        // Therefore, balances[j] < tokens[j].balanceOf(this)
        // Since balances[j] is used to compute D, D is unchanged.
        // collectFees() is used to convert the difference between balances[j] and tokens[j].balanceOf(this)
        // into pool token as fees!
        IERC20(tokens[_j]).safeTransfer(msg.sender, dy);

        emit TokenSwapped(msg.sender, tokens[_i], tokens[_j], _dx, dy);
    }

    /**
     * @dev Computes the amounts of underlying tokens when redeeming pool token.
     * @param _amount Amount of pool tokens to redeem.
     * @return Amounts of underlying tokens redeemed.
     */
    function getRedeemProportionAmount(uint256 _amount) external view returns (uint256[] memory, uint256) {
        uint256[] memory _balances = balances;
        require(_amount > 0, "zero amount");

        uint256 D = totalSupply;
        uint256[] memory amounts = new uint256[](_balances.length);
        uint256 feeAmount = 0;
        if (redeemFee > 0) {
            feeAmount = _amount.mul(redeemFee).div(feeDenominator);
            // Redemption fee is charged with pool token before redemption.
            _amount = _amount.sub(feeAmount);
        }

        for (uint256 i = 0; i < _balances.length; i++) {
            // We might choose to use poolToken.totalSupply to compute the amount, but decide to use
            // D in case we have multiple minters on the pool token.
            amounts[i] = _balances[i].mul(_amount).div(D).div(precisions[i]);
        }

        return (amounts, feeAmount);
    }

    /**
     * @dev Redeems pool token to underlying tokens proportionally.
     * @param _amount Amount of pool token to redeem.
     * @param _minRedeemAmounts Minimum amount of underlying tokens to get.
     */
    function redeemProportion(uint256 _amount, uint256[] calldata _minRedeemAmounts) external nonReentrant {
        uint256[] memory _balances = balances;
        // If swap is paused, only admins can redeem.
        require(!paused || admins[msg.sender], "paused");
        require(_amount > 0, "zero amount");
        require(_balances.length == _minRedeemAmounts.length, "invalid mins");

        uint256 D = totalSupply;
        uint256[] memory amounts = new uint256[](_balances.length);
        uint256 fee = redeemFee;
        uint256 feeAmount;
        if (fee > 0) {
            feeAmount = _amount.mul(fee).div(feeDenominator);
            // Redemption fee is paid with pool token
            // No conversion is needed as the pool token has 18 decimals
            IERC20(poolToken).safeTransferFrom(msg.sender, feeRecipient, feeAmount);
            _amount = _amount.sub(feeAmount);
        }

        for (uint256 i = 0; i < _balances.length; i++) {
            // We might choose to use poolToken.totalSupply to compute the amount, but decide to use
            // D in case we have multiple minters on the pool token.
            uint256 tokenAmount = _balances[i].mul(_amount).div(D);
            // Important: Underlying tokens must convert back to original decimals!
            amounts[i] = tokenAmount.div(precisions[i]);
            require(amounts[i] >= _minRedeemAmounts[i], "fewer than expected");
            // Updates the balance in storage
            balances[i] = _balances[i].sub(tokenAmount);
            IERC20(tokens[i]).safeTransfer(msg.sender, amounts[i]);
        }

        totalSupply = D.sub(_amount);
        // After reducing the redeem fee, the remaining pool tokens are burned!
        IERC20MintableBurnable(poolToken).burn(msg.sender, _amount);

        emit Redeemed(msg.sender, _amount.add(feeAmount), amounts, feeAmount);
    }

    /**
     * @dev Computes the amount when redeeming pool token to one specific underlying token.
     * @param _amount Amount of pool token to redeem.
     * @param _i Index of the underlying token to redeem to.
     * @return Amount of underlying token that can be redeem to.
     */
    function getRedeemSingleAmount(uint256 _amount, uint256 _i) external view returns (uint256, uint256) {
        uint256[] memory _balances = balances;
        require(_amount > 0, "zero amount");
        require(_i < _balances.length, "invalid token");

        uint256 A = getA();
        uint256 D = totalSupply;
        uint256 feeAmount = 0;
        if (redeemFee > 0) {
            feeAmount = _amount.mul(redeemFee).div(feeDenominator);
            // Redemption fee is charged with pool token before redemption.
            _amount = _amount.sub(feeAmount);
        }
        // The pool token amount becomes D - _amount
        uint256 y = _getY(_balances, _i, D.sub(_amount), A);
        uint256 dy = _balances[_i].sub(y).div(precisions[_i]);

        return (dy, feeAmount);
    }

    /**
     * @dev Redeem pool token to one specific underlying token.
     * @param _amount Amount of pool token to redeem.
     * @param _i Index of the token to redeem to.
     * @param _minRedeemAmount Minimum amount of the underlying token to redeem to.
     */
    function redeemSingle(uint256 _amount, uint256 _i, uint256 _minRedeemAmount) external nonReentrant {
        uint256[] memory _balances = balances;
        // If swap is paused, only admins can redeem.
        require(!paused || admins[msg.sender], "paused");
        require(_amount > 0, "zero amount");
        require(_i < _balances.length, "invalid token");

        uint256 A = getA();
        uint256 D = totalSupply;
        uint256 fee = redeemFee;
        uint256 feeAmount = 0;
        if (fee > 0) {
            // Redemption fee is charged with pool token before redemption.
            feeAmount = _amount.mul(fee).div(feeDenominator);
            // No conversion is needed as the pool token has 18 decimals
            IERC20(poolToken).safeTransferFrom(msg.sender, feeRecipient, feeAmount);
            _amount = _amount.sub(feeAmount);
        }

        // y is converted(18 decimals)
        uint256 y = _getY(_balances, _i, D.sub(_amount), A);
        // dy is not converted
        uint256 dy = _balances[_i].sub(y).div(precisions[_i]);
        require(dy >= _minRedeemAmount, "fewer than expected");
        // Updates token balance in storage
        balances[_i] = y;
        uint256[] memory amounts = new uint256[](_balances.length);
        amounts[_i] = dy;
        IERC20(tokens[_i]).safeTransfer(msg.sender, dy);

        totalSupply = D.sub(_amount);
        IERC20MintableBurnable(poolToken).burn(msg.sender, _amount);

        emit Redeemed(msg.sender, _amount.add(feeAmount), amounts, feeAmount);
    }

    /**
     * @dev Compute the amount of pool token that needs to be redeemed.
     * @param _amounts Unconverted token balances.
     * @return The amount of pool token that needs to be redeemed.
     */
    function getRedeemMultiAmount(uint256[] calldata _amounts) external view returns (uint256, uint256) {
        uint256[] memory _balances = balances;
        require(_amounts.length == balances.length, "length not match");
        
        uint256 A = getA();
        uint256 oldD = totalSupply;
        for (uint256 i = 0; i < _balances.length; i++) {
            if (_amounts[i] == 0)   continue;
            // balance = balance + amount * precision
            _balances[i] = _balances[i].sub(_amounts[i].mul(precisions[i]));
        }
        uint256 newD = _getD(_balances, A);

        // newD should be smaller than or equal to oldD
        uint256 redeemAmount = oldD.sub(newD);
        uint256 feeAmount = 0;
        if (redeemFee > 0) {
            redeemAmount = redeemAmount.mul(feeDenominator).div(feeDenominator.sub(redeemFee));
            feeAmount = redeemAmount.sub(oldD.sub(newD));
        }

        return (redeemAmount, feeAmount);
    }

    /**
     * @dev Redeems underlying tokens.
     * @param _amounts Amounts of underlying tokens to redeem to.
     * @param _maxRedeemAmount Maximum of pool token to redeem.
     */
    function redeemMulti(uint256[] calldata _amounts, uint256 _maxRedeemAmount) external nonReentrant {
        uint256[] memory _balances = balances;
        require(_amounts.length == balances.length, "length not match");
        // If swap is paused, only admins can redeem.
        require(!paused || admins[msg.sender], "paused");
        
        uint256 A = getA();
        uint256 oldD = totalSupply;
        uint256 i = 0;
        for (i = 0; i < _balances.length; i++) {
            if (_amounts[i] == 0)   continue;
            // balance = balance + amount * precision
            _balances[i] = _balances[i].sub(_amounts[i].mul(precisions[i]));
        }
        uint256 newD = _getD(_balances, A);

        // newD should be smaller than or equal to oldD
        uint256 redeemAmount = oldD.sub(newD);
        uint256 fee = redeemFee;
        uint256 feeAmount = 0;
        if (fee > 0) {
            redeemAmount = redeemAmount.mul(feeDenominator).div(feeDenominator.sub(fee));
            feeAmount = redeemAmount.sub(oldD.sub(newD));
            // No conversion is needed as the pool token has 18 decimals
            IERC20(poolToken).safeTransferFrom(msg.sender, feeRecipient, feeAmount);
        }
        require(redeemAmount <= _maxRedeemAmount, "more than expected");

        // Updates token balances in storage.
        balances = _balances;
        uint256 burnAmount = redeemAmount.sub(feeAmount);
        totalSupply = oldD.sub(burnAmount);
        IERC20MintableBurnable(poolToken).burn(msg.sender, burnAmount);
        for (i = 0; i < _balances.length; i++) {
            if (_amounts[i] == 0)   continue;
            IERC20(tokens[i]).safeTransfer(msg.sender, _amounts[i]);
        }

        emit Redeemed(msg.sender, redeemAmount, _amounts, feeAmount);
    }

    /**
     * @dev Return the amount of fee that's not collected.
     */
    function getPendingFeeAmount() external view returns (uint256) {
        uint256[] memory _balances = balances;
        uint256 A = getA();
        uint256 oldD = totalSupply;

        for (uint256 i = 0; i < _balances.length; i++) {
            _balances[i] = IERC20(tokens[i]).balanceOf(address(this)).mul(precisions[i]);
        }
        uint256 newD = _getD(_balances, A);

        return newD.sub(oldD);
    }

    /**
     * @dev Collect fee based on the token balance difference.
     */
    function collectFee() external returns (uint256) {
        require(admins[msg.sender], "not admin");
        uint256[] memory _balances = balances;
        uint256 A = getA();
        uint256 oldD = totalSupply;

        for (uint256 i = 0; i < _balances.length; i++) {
            _balances[i] = IERC20(tokens[i]).balanceOf(address(this)).mul(precisions[i]);
        }
        uint256 newD = _getD(_balances, A);
        uint256 feeAmount = newD.sub(oldD);
        if (feeAmount == 0) return 0;

        balances = _balances;
        totalSupply = newD;
        address _feeRecipient = feeRecipient;
        IERC20MintableBurnable(poolToken).mint(_feeRecipient, feeAmount);

        emit FeeCollected(_feeRecipient, feeAmount);

        return feeAmount;
    }

    /**
     * @dev Updates the govenance address.
     */
    function setGovernance(address _governance) external {
        require(msg.sender == governance, "not governance");
        governance = _governance;
    }

    /**
     * @dev Updates the mint fee.
     */
    function setMintFee(uint256 _mintFee) external {
        require(msg.sender == governance, "not governance");
        mintFee = _mintFee;
    }

    /**
     * @dev Updates the swap fee.
     */
    function setSwapFee(uint256 _swapFee) external {
        require(msg.sender == governance, "not governance");
        swapFee = _swapFee;
    }

    /**
     * @dev Updates the redeem fee.
     */
    function setRedeemFee(uint256 _redeemFee) external {
        require(msg.sender == governance, "not governance");
        redeemFee = _redeemFee;
    }

    /**
     * @dev Updates the recipient of mint/swap/redeem fees.
     */
    function setFeeRecipient(address _feeRecipient) external {
        require(msg.sender == governance, "not governance");
        require(_feeRecipient != address(0x0), "fee recipient not set");
        feeRecipient = _feeRecipient;
    }

    /**
     * @dev Updates the pool token.
     */
    function setPoolToken(address _poolToken) external {
        require(msg.sender == governance, "not governance");
        require(_poolToken != address(0x0), "pool token not set");
        poolToken = _poolToken;
    }

    /**
     * @dev Pause mint/swap/redeem actions. Can unpause later.
     */
    function pause() external {
        require(msg.sender == governance, "not governance");
        require(!paused, "paused");

        paused = true;
    }

    /**
     * @dev Unpause mint/swap/redeem actions.
     */
    function unpause() external {
        require(msg.sender == governance, "not governance");
        require(paused, "not paused");

        paused = false;
    }

    /**
     * @dev Updates the admin role for the address.
     * @param _account Address to update admin role.
     * @param _allowed Whether the address is granted the admin role.
     */
    function setAdmin(address _account, bool _allowed) external {
        require(msg.sender == governance, "not governance");
        require(_account != address(0x0), "account not set");

        admins[_account] = _allowed;
    }
}

// 
/**
 * @dev Application to help interact with ACoconutSwap with account.
 */
contract SwapApplication is Initializable {
    using SafeMath for uint256;

    address public governance;
    ACoconutSwap public swap;

    /**
     * @dev Initializes swap application.
     */
    function initialize(address _swap) public initializer {
        require(_swap != address(0x0), "swap not set");
        
        governance = msg.sender;
        swap = ACoconutSwap(_swap);
    }

    /**
     * @dev Updates the govenance address.
     */
    function setGovernance(address _governance) public {
        require(msg.sender == governance, "not governance");
        governance = _governance;
    }

    /**
     * @dev Updates the swap address.
     */
    function setSwap(address _swap) public {
        require(msg.sender == governance, "not governance");
        require(_swap != address(0x0), "swap not set");

        swap = ACoconutSwap(_swap);
    }

    modifier validAccount(address _account) {
        Account account = Account(payable(_account));
        require(account.owner() == msg.sender, "not owner");
        require(account.isOperator(address(this)), "not operator");
        _;
    }

    /**
     * @dev Mints new pool token.
     * @param _account The account address used to mint.
     * @param _amounts Unconverted token balances used to mint pool token.
     * @param _minMintAmount Minimum amount of pool token to mint.
     */
    function mintToken(address _account, uint256[] memory _amounts, uint256 _minMintAmount) public validAccount(_account) {
        Account account = Account(payable(_account));
        // We don't perform input validations here as they are done in ACoconutSwap.
        for (uint256 i = 0; i < _amounts.length; i++) {
            account.approveToken(swap.tokens(i), address(swap), _amounts[i]);
        }

        bytes memory methodData = abi.encodeWithSignature("mint(uint256[],uint256)", _amounts, _minMintAmount);
        account.invoke(address(swap), 0, methodData);
    }

    /**
     * @dev Exchange between two underlying tokens.
     * @param _account The account address used to swap.
     * @param _i Token index to swap in.
     * @param _j Token index to swap out.
     * @param _dx Unconverted amount of token _i to swap in.
     * @param _minDy Minimum token _j to swap out in converted balance.
     */
    function swapToken(address _account, uint256 _i, uint256 _j, uint256 _dx, uint256 _minDy) public validAccount(_account) {
        Account account = Account(payable(_account));
        // We don't perform input validations here as they are done in ACoconutSwap.
        account.approveToken(swap.tokens(_i), address(swap), _dx);

        bytes memory methodData = abi.encodeWithSignature("swap(uint256,uint256,uint256,uint256)", _i, _j, _dx, _minDy);
        account.invoke(address(swap), 0, methodData);
    }

    /**
     * @dev Redeems pool token to underlying tokens proportionally.
     * @param _account The account address used to redeem.
     * @param _amount Amount of pool token to redeem.
     * @param _minRedeemAmounts Minimum amount of underlying tokens to get.
     */
    function redeemProportion(address _account, uint256 _amount, uint256[] memory _minRedeemAmounts) public validAccount(_account) {
        Account account = Account(payable(_account));
        // We don't perform input validations here as they are done in ACoconutSwap.
        account.approveToken(swap.poolToken(), address(swap), _amount);

        bytes memory methodData = abi.encodeWithSignature("redeemProportion(uint256,uint256[])", _amount, _minRedeemAmounts);
        account.invoke(address(swap), 0, methodData);
    }

    /**
     * @dev Redeem pool token to one specific underlying token.
     * @param _account The account address used to redeem.
     * @param _amount Amount of pool token to redeem.
     * @param _i Index of the token to redeem to.
     * @param _minRedeemAmount Minimum amount of the underlying token to redeem to.
     */
    function redeemSingle(address _account, uint256 _amount, uint256 _i, uint256 _minRedeemAmount) public validAccount(_account) {
        Account account = Account(payable(_account));
        // We don't perform input validations here as they are done in ACoconutSwap.
        account.approveToken(swap.poolToken(), address(swap), _amount);

        bytes memory methodData = abi.encodeWithSignature("redeemSingle(uint256,uint256,uint256)", _amount, _i, _minRedeemAmount);
        account.invoke(address(swap), 0, methodData);
    }

    /**
     * @dev Redeems underlying tokens.
     * @param _account The account address used to redeem.
     * @param _amounts Amounts of underlying tokens to redeem to.
     * @param _maxRedeemAmount Maximum of pool token to redeem.
     */
    function redeemMulti(address _account, uint256[] memory _amounts, uint256 _maxRedeemAmount) public validAccount(_account) {
        Account account = Account(payable(_account));
        // We don't perform input validations here as they are done in ACoconutSwap.
        // The amount of acBTC to burn is unknown yet. Simply set the allowance to the maximum redeem amount.
        account.approveToken(swap.poolToken(), address(swap), _maxRedeemAmount);

        bytes memory methodData = abi.encodeWithSignature("redeemMulti(uint256[],uint256)", _amounts, _maxRedeemAmount);
        account.invoke(address(swap), 0, methodData);

        // Clears the allowance afterward
        account.approveToken(swap.poolToken(), address(this), 0);
    }
}