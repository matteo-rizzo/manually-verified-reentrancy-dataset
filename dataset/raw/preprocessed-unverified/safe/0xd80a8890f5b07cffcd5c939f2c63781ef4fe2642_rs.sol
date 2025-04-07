/**
 *Submitted for verification at Etherscan.io on 2021-03-18
*/

pragma solidity 0.6.12;

// SPDX-License-Identifier: MIT

/**
 * @dev Collection of functions related to the address type
 */


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
        return !AddressUpgradeable.isContract(address(this));
    }
}
/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
 */






contract DVFInterface2 is Initializable {
    IStarkExV2 public instance;

    function initialize(
      address _deployedStarkExProxy
    ) public initializer {
      instance = IStarkExV2(_deployedStarkExProxy);
    }

    function registerAndDeposit(
      uint256 starkKey,
      bytes calldata signature,
      uint256 assetType,
      uint256 vaultId,
      uint256 quantizedAmount,
      address tokenAddress,
      uint256 quantum
    ) public {
      instance.registerUser(msg.sender, starkKey, signature);
      deposit(starkKey, assetType, vaultId, quantizedAmount, tokenAddress, quantum);
    }

    function registerAndDepositEth(
      uint256 starkKey,
      bytes calldata signature,
      uint256 assetType,
      uint256 vaultId
    ) public payable {
      instance.registerUser(msg.sender, starkKey, signature);
      depositEth(starkKey, assetType, vaultId);
    }

    function deposit(
      uint256 starkKey,
      uint256 assetType,
      uint256 vaultId,
      uint256 quantizedAmount,
      address tokenAddress,
      uint256 quantum
    ) public {
      IERC20Upgradeable(tokenAddress).transferFrom(msg.sender, address(this), quantizedAmount * quantum);
      instance.deposit(starkKey, assetType, vaultId, quantizedAmount);
    }

    function depositEth(
      uint256 starkKey,
      uint256 assetType,
      uint256 vaultId
    ) public payable {
      require(gasleft() > 53000, 'INSUFFICIENT_GAS');
      address(instance).call{value: msg.value }(abi.encodeWithSignature("deposit(uint256,uint256,uint256)", starkKey, assetType, vaultId));

    }

    function approveTokenToDeployedProxy(
      address _token
    ) public {
      IERC20Upgradeable(_token).approve(address(instance), 2 ** 96 - 1);
    }

    function allWithdrawalBalances(
      uint256[] calldata _tokenIds,
      uint256 _whoKey
    ) public view returns (uint256[] memory balances) {
      balances = new uint256[](_tokenIds.length);
      for (uint i = 0; i < _tokenIds.length; i++) {
        balances[i] = instance.getWithdrawalBalance(_whoKey, _tokenIds[i]);
      }
    }
}