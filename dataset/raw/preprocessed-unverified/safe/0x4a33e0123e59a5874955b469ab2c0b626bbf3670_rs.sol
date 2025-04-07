/**
 *Submitted for verification at Etherscan.io on 2021-04-21
*/

pragma solidity ^0.7.6;

// SPDX-License-Identifier: MIT
// Source code: https://github.com/DeCash-Official/smart-contracts



/**
 * @dev Collection of functions related to the address type
 */




/// @title Base settings / modifiers for each contract in DeCash Token (Credits David Rugendyke/Rocket Pool)
/// @author Fabrizio Amodio (ZioFabry)

abstract contract DeCashBase {
    // Version of the contract
    uint8 public version;

    // The main storage contract where primary persistant storage is maintained
    DeCashStorageInterface internal _decashStorage = DeCashStorageInterface(0);

    /**
     * @dev Throws if called by any sender that doesn't match one of the supplied contract or is the latest version of that contract
     */
    modifier onlyLatestContract(
        string memory _contractName,
        address _contractAddress
    ) {
        require(
            _contractAddress ==
                _getAddress(
                    keccak256(
                        abi.encodePacked("contract.address", _contractName)
                    )
                ),
            "Invalid or outdated contract"
        );
        _;
    }

    modifier onlyOwner() {
        require(_isOwner(msg.sender), "Account is not the owner");
        _;
    }
    modifier onlyAdmin() {
        require(_isAdmin(msg.sender), "Account is not an admin");
        _;
    }
    modifier onlySuperUser() {
        require(_isSuperUser(msg.sender), "Account is not a super user");
        _;
    }
    modifier onlyDelegator(address _address) {
        require(_isDelegator(_address), "Account is not a delegator");
        _;
    }
    modifier onlyFeeRecipient(address _address) {
        require(_isFeeRecipient(_address), "Account is not a fee recipient");
        _;
    }
    modifier onlyRole(string memory _role) {
        require(_roleHas(_role, msg.sender), "Account does not match the role");
        _;
    }

    /// @dev Set the main DeCash Storage address
    constructor(address _decashStorageAddress) {
        // Update the contract address
        _decashStorage = DeCashStorageInterface(_decashStorageAddress);
    }

    function isOwner(address _address) external view returns (bool) {
        return _isOwner(_address);
    }

    function isAdmin(address _address) external view returns (bool) {
        return _isAdmin(_address);
    }

    function isSuperUser(address _address) external view returns (bool) {
        return _isSuperUser(_address);
    }

    function isDelegator(address _address) external view returns (bool) {
        return _isDelegator(_address);
    }

    function isFeeRecipient(address _address) external view returns (bool) {
        return _isFeeRecipient(_address);
    }

    function isBlacklisted(address _address) external view returns (bool) {
        return _isBlacklisted(_address);
    }

    /// @dev Get the address of a network contract by name
    function _getContractAddress(string memory _contractName)
        internal
        view
        returns (address)
    {
        // Get the current contract address
        address contractAddress =
            _getAddress(
                keccak256(abi.encodePacked("contract.address", _contractName))
            );
        // Check it
        require(contractAddress != address(0x0), "Contract not found");
        // Return
        return contractAddress;
    }

    /// @dev Get the name of a network contract by address
    function _getContractName(address _contractAddress)
        internal
        view
        returns (string memory)
    {
        // Get the contract name
        string memory contractName =
            _getString(
                keccak256(abi.encodePacked("contract.name", _contractAddress))
            );
        // Check it
        require(
            keccak256(abi.encodePacked(contractName)) !=
                keccak256(abi.encodePacked("")),
            "Contract not found"
        );
        // Return
        return contractName;
    }

    /// @dev Role Management
    function _roleHas(string memory _role, address _address)
        internal
        view
        returns (bool)
    {
        return
            _getBool(
                keccak256(abi.encodePacked("access.role", _role, _address))
            );
    }

    function _isOwner(address _address) internal view returns (bool) {
        return _roleHas("owner", _address);
    }

    function _isAdmin(address _address) internal view returns (bool) {
        return _roleHas("admin", _address);
    }

    function _isSuperUser(address _address) internal view returns (bool) {
        return _roleHas("admin", _address) || _isOwner(_address);
    }

    function _isDelegator(address _address) internal view returns (bool) {
        return _roleHas("delegator", _address) || _isOwner(_address);
    }

    function _isFeeRecipient(address _address) internal view returns (bool) {
        return _roleHas("fee", _address) || _isOwner(_address);
    }

    function _isBlacklisted(address _address) internal view returns (bool) {
        return _roleHas("blacklisted", _address) && !_isOwner(_address);
    }

    /// @dev Storage get methods
    function _getAddress(bytes32 _key) internal view returns (address) {
        return _decashStorage.getAddress(_key);
    }

    function _getUint(bytes32 _key) internal view returns (uint256) {
        return _decashStorage.getUint(_key);
    }

    function _getString(bytes32 _key) internal view returns (string memory) {
        return _decashStorage.getString(_key);
    }

    function _getBytes(bytes32 _key) internal view returns (bytes memory) {
        return _decashStorage.getBytes(_key);
    }

    function _getBool(bytes32 _key) internal view returns (bool) {
        return _decashStorage.getBool(_key);
    }

    function _getInt(bytes32 _key) internal view returns (int256) {
        return _decashStorage.getInt(_key);
    }

    function _getBytes32(bytes32 _key) internal view returns (bytes32) {
        return _decashStorage.getBytes32(_key);
    }

    function _getAddressS(string memory _key) internal view returns (address) {
        return _decashStorage.getAddress(keccak256(abi.encodePacked(_key)));
    }

    function _getUintS(string memory _key) internal view returns (uint256) {
        return _decashStorage.getUint(keccak256(abi.encodePacked(_key)));
    }

    function _getStringS(string memory _key)
        internal
        view
        returns (string memory)
    {
        return _decashStorage.getString(keccak256(abi.encodePacked(_key)));
    }

    function _getBytesS(string memory _key)
        internal
        view
        returns (bytes memory)
    {
        return _decashStorage.getBytes(keccak256(abi.encodePacked(_key)));
    }

    function _getBoolS(string memory _key) internal view returns (bool) {
        return _decashStorage.getBool(keccak256(abi.encodePacked(_key)));
    }

    function _getIntS(string memory _key) internal view returns (int256) {
        return _decashStorage.getInt(keccak256(abi.encodePacked(_key)));
    }

    function _getBytes32S(string memory _key) internal view returns (bytes32) {
        return _decashStorage.getBytes32(keccak256(abi.encodePacked(_key)));
    }

    /// @dev Storage set methods
    function _setAddress(bytes32 _key, address _value) internal {
        _decashStorage.setAddress(_key, _value);
    }

    function _setUint(bytes32 _key, uint256 _value) internal {
        _decashStorage.setUint(_key, _value);
    }

    function _setString(bytes32 _key, string memory _value) internal {
        _decashStorage.setString(_key, _value);
    }

    function _setBytes(bytes32 _key, bytes memory _value) internal {
        _decashStorage.setBytes(_key, _value);
    }

    function _setBool(bytes32 _key, bool _value) internal {
        _decashStorage.setBool(_key, _value);
    }

    function _setInt(bytes32 _key, int256 _value) internal {
        _decashStorage.setInt(_key, _value);
    }

    function _setBytes32(bytes32 _key, bytes32 _value) internal {
        _decashStorage.setBytes32(_key, _value);
    }

    function _setAddressS(string memory _key, address _value) internal {
        _decashStorage.setAddress(keccak256(abi.encodePacked(_key)), _value);
    }

    function _setUintS(string memory _key, uint256 _value) internal {
        _decashStorage.setUint(keccak256(abi.encodePacked(_key)), _value);
    }

    function _setStringS(string memory _key, string memory _value) internal {
        _decashStorage.setString(keccak256(abi.encodePacked(_key)), _value);
    }

    function _setBytesS(string memory _key, bytes memory _value) internal {
        _decashStorage.setBytes(keccak256(abi.encodePacked(_key)), _value);
    }

    function _setBoolS(string memory _key, bool _value) internal {
        _decashStorage.setBool(keccak256(abi.encodePacked(_key)), _value);
    }

    function _setIntS(string memory _key, int256 _value) internal {
        _decashStorage.setInt(keccak256(abi.encodePacked(_key)), _value);
    }

    function _setBytes32S(string memory _key, bytes32 _value) internal {
        _decashStorage.setBytes32(keccak256(abi.encodePacked(_key)), _value);
    }

    /// @dev Storage delete methods
    function _deleteAddress(bytes32 _key) internal {
        _decashStorage.deleteAddress(_key);
    }

    function _deleteUint(bytes32 _key) internal {
        _decashStorage.deleteUint(_key);
    }

    function _deleteString(bytes32 _key) internal {
        _decashStorage.deleteString(_key);
    }

    function _deleteBytes(bytes32 _key) internal {
        _decashStorage.deleteBytes(_key);
    }

    function _deleteBool(bytes32 _key) internal {
        _decashStorage.deleteBool(_key);
    }

    function _deleteInt(bytes32 _key) internal {
        _decashStorage.deleteInt(_key);
    }

    function _deleteBytes32(bytes32 _key) internal {
        _decashStorage.deleteBytes32(_key);
    }

    function _deleteAddressS(string memory _key) internal {
        _decashStorage.deleteAddress(keccak256(abi.encodePacked(_key)));
    }

    function _deleteUintS(string memory _key) internal {
        _decashStorage.deleteUint(keccak256(abi.encodePacked(_key)));
    }

    function _deleteStringS(string memory _key) internal {
        _decashStorage.deleteString(keccak256(abi.encodePacked(_key)));
    }

    function _deleteBytesS(string memory _key) internal {
        _decashStorage.deleteBytes(keccak256(abi.encodePacked(_key)));
    }

    function _deleteBoolS(string memory _key) internal {
        _decashStorage.deleteBool(keccak256(abi.encodePacked(_key)));
    }

    function _deleteIntS(string memory _key) internal {
        _decashStorage.deleteInt(keccak256(abi.encodePacked(_key)));
    }

    function _deleteBytes32S(string memory _key) internal {
        _decashStorage.deleteBytes32(keccak256(abi.encodePacked(_key)));
    }
}

/**
 * @dev This abstract contract provides a fallback function that delegates all calls to another contract using the EVM
 * instruction `delegatecall`. We refer to the second contract as the _implementation_ behind the proxy, and it has to
 * be specified by overriding the virtual {_implementation} function.
 *
 * Additionally, delegation to the implementation can be triggered manually through the {_fallback} function, or to a
 * different contract through the {_delegate} function.
 *
 * The success and return data of the delegated call will be returned back to the caller of the proxy.
 */
abstract contract Proxy {
    /**
     * @dev Fallback function that delegates calls to the address returned by `_implementation()`. Will run if call data
     * is empty.
     */
    receive() external payable {
        _fallback();
    }

    /**
     * @dev Fallback function that delegates calls to the address returned by `_implementation()`. Will run if no other
     * function in the contract matches the call data.
     */
    fallback() external payable {
        _fallback();
    }

    /**
     * @dev Delegates the current call to `implementation`.
     *
     * This function does not return to its internall call site, it will return directly to the external caller.
     */
    function _delegate(address implementation) internal {
        // solhint-disable-next-line no-inline-assembly
        assembly {
            // Copy msg.data. We take full control of memory in this inline assembly
            // block because it will not return to Solidity code. We overwrite the
            // Solidity scratch pad at memory position 0.
            calldatacopy(0, 0, calldatasize())

            // Call the implementation.
            // out and outsize are 0 because we don't know the size yet.
            let result := delegatecall(
                gas(),
                implementation,
                0,
                calldatasize(),
                0,
                0
            )

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

    /**
     * @dev This is a virtual function that should be overriden so it returns the address to which the fallback function
     * and {_fallback} should delegate.
     */
    function _implementation() internal view virtual returns (address);

    /**
     * @dev Delegates the current call to the address returned by `_implementation()`.
     *
     * This function does not return to its internall call site, it will return directly to the external caller.
     */
    function _fallback() internal {
        _beforeFallback();
        _delegate(_implementation());
    }

    /**
     * @dev Hook that is called before falling back to the implementation. Can happen as part of a manual `_fallback`
     * call, or as part of the Solidity `fallback` or `receive` functions.
     *
     * If overriden should call `super._beforeFallback()`.
     */
    function _beforeFallback() internal virtual {}
}

/// @title DeCash Proxy Contract
/// @author Fabrizio Amodio (ZioFabry)

contract DeCashProxy is DeCashBase, Proxy {
    bytes32 private constant _IMPLEMENTATION_SLOT =
        0x360894a13ba1a3210667c828492db98dca3e2076cc3735a920a3ca505d382bbc;

    event ProxyInitiated(address indexed implementation);
    event ProxyUpgraded(address indexed implementation);

    // Construct
    constructor(address _decashStorageAddress)
        DeCashBase(_decashStorageAddress)
    {
        assert(
            _IMPLEMENTATION_SLOT ==
                bytes32(uint256(keccak256("eip1967.proxy.implementation")) - 1)
        );
        version = 1;
    }

    function upgrade(address _address)
        public
        onlyLatestContract("upgrade", msg.sender)
    {
        _setImplementation(_address);

        emit ProxyUpgraded(_address);
    }

    function initialize(address _address) external onlyOwner {
        require(
            !_getBool(keccak256(abi.encodePacked("proxy.init", address(this)))),
            "Proxy already initialized"
        );

        _setImplementation(_address);
        _setBool(keccak256(abi.encodePacked("proxy.init", address(this))), true);

        emit ProxyInitiated(_address);
    }

    /**
     * @dev Stores a new address in the EIP1967 implementation slot.
     */
    function _setImplementation(address _address) private {
        require(Address.isContract(_address), "address is not a contract");

        bytes32 slot = _IMPLEMENTATION_SLOT;

        // solhint-disable-next-line no-inline-assembly
        assembly {
            sstore(slot, _address)
        }
    }

    /**
     * @dev Returns the current implementation address.
     */
    function _implementation() internal view override returns (address impl) {
        bytes32 slot = _IMPLEMENTATION_SLOT;
        // solhint-disable-next-line no-inline-assembly
        assembly {
            impl := sload(slot)
        }
    }
}

contract GBPDProxy is DeCashProxy {
    constructor(address _storage) DeCashProxy(_storage) {}
}