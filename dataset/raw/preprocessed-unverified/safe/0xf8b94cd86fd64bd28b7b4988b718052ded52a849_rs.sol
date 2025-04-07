/**
 *Submitted for verification at Etherscan.io on 2021-09-29
*/

// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

/**
 * @dev Collection of functions related to the address type
 */



/**
 * @dev Library for reading and writing primitive types to specific storage slots.
 *
 * Storage slots are often used to avoid storage conflict when dealing with upgradeable contracts.
 * This library helps with reading and writing to such slots without the need for inline assembly.
 *
 * The functions in this library return Slot structs that contain a `value` member that can be used to read or write.
 *
 * Example usage to set ERC1967 implementation slot:
 * ```
 * contract ERC1967 {
 *     bytes32 internal constant _IMPLEMENTATION_SLOT = 0x360894a13ba1a3210667c828492db98dca3e2076cc3735a920a3ca505d382bbc;
 *
 *     function _getImplementation() internal view returns (address) {
 *         return StorageSlot.getAddressSlot(_IMPLEMENTATION_SLOT).value;
 *     }
 *
 *     function _setImplementation(address newImplementation) internal {
 *         require(Address.isContract(newImplementation), "ERC1967: new implementation is not a contract");
 *         StorageSlot.getAddressSlot(_IMPLEMENTATION_SLOT).value = newImplementation;
 *     }
 * }
 * ```
 *
 * _Available since v4.1 for `address`, `bool`, `bytes32`, and `uint256`._
 */
 

/**
 * @dev This is a base contract to aid in writing upgradeable contracts, or any kind of contract that will be deployed
 * behind a proxy. Since a proxied contract can't have a constructor, it's common to move constructor logic to an
 * external initializer function, usually called `initialize`. It then becomes necessary to protect this initializer
 * function so it can only be called once. The {initializer} modifier provided by this contract will have this effect.
 *
 * TIP: To avoid leaving the proxy in an uninitialized state, the initializer function should be called as early as
 * possible by providing the encoded function call as the `_data` argument to {ERC1967Proxy-constructor}.
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
        require(_initializing || !_initialized, "Initializable: contract is already initialized");

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
}



contract Proxy
{
    bytes32 private constant _IMPLEMENTATION_SLOT = 0x360894a13ba1a3210667c828492db98dca3e2076cc3735a920a3ca505d382bbc;
    bytes32 private constant _ADMIN_SLOT = 0xb53127684a568b3173ae13b9f8a6016e243e63b6e8ee1178d6a717850b5d6103;

    constructor(address implementation)
    {
        StorageSlotUpgradeable.getAddressSlot(_IMPLEMENTATION_SLOT).value = implementation;
        StorageSlotUpgradeable.getAddressSlot(_ADMIN_SLOT).value = msg.sender;
    }

    fallback() external payable
    {
        _fallback();
    }

    receive() external payable 
    {
        _fallback();
    }

    function _fallback() private
    {
        address implementation = StorageSlotUpgradeable.getAddressSlot(_IMPLEMENTATION_SLOT).value;

        // from OpenZeppelin/contracts
        assembly 
        {
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
            case 0 {
                revert(0, returndatasize())
            }
            default {
                return(0, returndatasize())
            }
        }
    }
}


contract ProxyImplementation is Initializable
{
    bytes32 private constant _IMPLEMENTATION_SLOT = 0x360894a13ba1a3210667c828492db98dca3e2076cc3735a920a3ca505d382bbc;
    bytes32 private constant _ADMIN_SLOT = 0xb53127684a568b3173ae13b9f8a6016e243e63b6e8ee1178d6a717850b5d6103;

    modifier onlyAdmin() 
    {
        require(admin() == msg.sender, "Implementation: caller is not admin");
        _;
    }

    function setImplementation(address implementation) external onlyAdmin
    {
        require(AddressUpgradeable.isContract(implementation), "ERC1967: new implementation is not a contract");
        StorageSlotUpgradeable.getAddressSlot(_IMPLEMENTATION_SLOT).value = implementation;
    }

    function admin() public view returns(address)
    {
        return StorageSlotUpgradeable.getAddressSlot(_ADMIN_SLOT).value;
    }

    function setAdmin(address newAdmin) external onlyAdmin
    {
        require(newAdmin != address(0), "invalid newAdmin address");
        _setAdmin(newAdmin);
    }

    function renounceAdminPowers() external onlyAdmin
    {
        _setAdmin(address(0));
    }

    function _setAdmin(address newAdmin) private
    {
        StorageSlotUpgradeable.getAddressSlot(_ADMIN_SLOT).value = newAdmin;
    }
}


contract SplitWallet is ProxyImplementation
{
    uint256 _denominator;
    uint256[] _numerator;
    address payable[] _recipient;

    function init(
        uint256 denominator, 
        uint256[] memory numerator, 
        address payable[] memory recipient)
        public onlyAdmin initializer
    {
        _denominator = denominator;
        _numerator = numerator;
        _recipient = recipient;

        uint256 totalNumerator = 0;
        for (uint256 i = 0; i < numerator.length; ++i)
        {
            totalNumerator += numerator[i];
        }
        require(totalNumerator == denominator, "numerators don't add up to denominator");
    }

    receive() external payable
    {
    }

    function payOut() public
    {
        _payOut(address(this).balance);
    }

    function _payOut(uint256 total) private
    {
        uint256 remaining = total;

        for (uint i = 0; i < _recipient.length; ++i)
        {
            uint256 cut = (total * _numerator[i]) / _denominator;
            require(cut <= remaining, "not enough remaining to deduct");
            remaining -= cut;

            (bool success, ) = _recipient[i].call{value:cut}("");
            require(success, "Transfer failed.");
        }
    }

    function setPayoutSplits(
        uint256 denominator, 
        uint256[] memory numerator, 
        address payable[] memory recipient) public onlyAdmin
    {
        _denominator = denominator;
        _numerator = numerator;
        _recipient = recipient;
    }
    function getPayoutSplits() public view returns(
        uint256 denominator, 
        uint256[] memory numerator, 
        address payable[] memory recipient)
    {
        return (_denominator, _numerator, _recipient);
    }
}