// File: localhost/internals/gasRefundable.sol

/**
 *  Copyright (C) 2019 The Contract Wallet Company Limited
 *
 *  This program is free software: you can redistribute it and/or modify
 *  it under the terms of the GNU General Public License as published by
 *  the Free Software Foundation, either version 3 of the License, or
 *  (at your option) any later version.
 *  This program is distributed in the hope that it will be useful,
 *  but WITHOUT ANY WARRANTY; without even the implied warranty of
 *  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 *  GNU General Public License for more details.
 *  You should have received a copy of the GNU General Public License
 *  along with this program.  If not, see <https://www.gnu.org/licenses/>.
 */
 
// SPDX-License-Identifier: GPLv3

pragma solidity ^0.6.11;
pragma experimental ABIEncoderV2;



contract GasRefundable {
    /// @notice Emits the new gas token information when it is set.
    event SetGasToken(address _gasTokenAddress, GasTokenParameters _gasTokenParameters);

    struct GasTokenParameters {
        uint256 freeCallGasCost;
        uint256 gasRefundPerUnit;
    }

    /// @dev Address of the gas token used to refund gas (default: CHI).
    IGasToken private _gasToken = IGasToken(0x0000000000004946c0e9F43F4Dee607b0eF1fA1c);
    /// @dev Gas token parameters parameters used in the gas refund calcualtion (default: CHI).
    GasTokenParameters private _gasTokenParameters = GasTokenParameters({freeCallGasCost: 14154, gasRefundPerUnit: 41130});

    /// @notice Refunds gas based on the amount of gas spent in the transaction and the gas token parameters.
    modifier refundGas() {
        uint256 gasStart = gasleft();
        _;
        uint256 gasSpent = 21000 + gasStart - gasleft() + 16 * msg.data.length;
        _gasToken.freeUpTo((gasSpent + _gasTokenParameters.freeCallGasCost) / _gasTokenParameters.gasRefundPerUnit);
    }

    /// @param _gasTokenAddress Address of the gas token used to refund gas.
    /// @param _parameters Gas cost of the gas token free method call and amount of gas refunded per unit of gas token.
    function _setGasToken(address _gasTokenAddress, GasTokenParameters memory _parameters) internal {
        require(_gasTokenAddress != address(0), "gas token address is 0x0");
        require(_parameters.freeCallGasCost != 0, "free call gas cost is 0");
        require(_parameters.gasRefundPerUnit != 0, "gas refund per unit is 0");
        _gasToken = IGasToken(_gasTokenAddress);
        _gasTokenParameters.freeCallGasCost = _parameters.freeCallGasCost;
        _gasTokenParameters.gasRefundPerUnit = _parameters.gasRefundPerUnit;
        emit SetGasToken(_gasTokenAddress, _parameters);
    }

    /// @return Address of the gas token used to refund gas.
    function gasToken() external view returns (address) {
        return address(_gasToken);
    }

    /// @return Gas cost of the gas token free method call/Amount of gas refunded per unit of gas token.
    function gasTokenParameters() external view returns (GasTokenParameters memory) {
        return _gasTokenParameters;
    }
}

// File: localhost/interfaces/IERC20.sol

/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
 */

// File: localhost/externals/SafeMath.sol

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

// File: localhost/externals/SafeERC20.sol




/**
 * @title SafeERC20
 * @dev Wrappers around ERC20 operations that throw on failure (when the token
 * contract returns false). Tokens that return no value (and instead revert or
 * throw on failure) are also supported, non-reverting calls are assumed to be
 * successful.
 * To use this library you can add a `using SafeERC20 for IERC20;` statement to your contract,
 * which allows you to call the safe operations as `token.safeTransfer(...)`, etc.
 */

// File: localhost/externals/Address.sol

/**
 * @dev Collection of functions related to the address type
 */

// File: localhost/internals/transferrable.sol

/**
 *  Transferrable - The Consumer Contract Wallet
 *  Copyright (C) 2019 The Contract Wallet Company Limited
 *
 *  This program is free software: you can redistribute it and/or modify
 *  it under the terms of the GNU General Public License as published by
 *  the Free Software Foundation, either version 3 of the License, or
 *  (at your option) any later version.

 *  This program is distributed in the hope that it will be useful,
 *  but WITHOUT ANY WARRANTY; without even the implied warranty of
 *  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 *  GNU General Public License for more details.

 *  You should have received a copy of the GNU General Public License
 *  along with this program.  If not, see <https://www.gnu.org/licenses/>.
 */




/// @title SafeTransfer, allowing contract to withdraw tokens accidentally sent to itself
contract Transferrable {
    using Address for address payable;
    using SafeERC20 for IERC20;

    /// @dev This function is used to move tokens sent accidentally to this contract method.
    /// @dev The owner can chose the new destination address
    /// @param _to is the recipient's address.
    /// @param _asset is the address of an ERC20 token or 0x0 for ether.
    /// @param _amount is the amount to be transferred in base units.
    function _safeTransfer(
        address payable _to,
        address _asset,
        uint256 _amount
    ) internal {
        // address(0) is used to denote ETH
        if (_asset == address(0)) {
            _to.sendValue(_amount);
        } else {
            IERC20(_asset).safeTransfer(_to, _amount);
        }
    }
}

// File: localhost/externals/initializable.sol



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

// File: localhost/internals/ownable.sol

/**
 *  Ownable - The Consumer Contract Wallet
 *  Copyright (C) 2019 The Contract Wallet Company Limited
 *
 *  This program is free software: you can redistribute it and/or modify
 *  it under the terms of the GNU General Public License as published by
 *  the Free Software Foundation, either version 3 of the License, or
 *  (at your option) any later version.

 *  This program is distributed in the hope that it will be useful,
 *  but WITHOUT ANY WARRANTY; without even the implied warranty of
 *  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 *  GNU General Public License for more details.

 *  You should have received a copy of the GNU General Public License
 *  along with this program.  If not, see <https://www.gnu.org/licenses/>.
 */



/// @title Ownable has an owner address and provides basic authorization control functions.
/// This contract is modified version of the MIT OpenZepplin Ownable contract
/// This contract allows for the transferOwnership operation to be made impossible
/// https://github.com/OpenZeppelin/openzeppelin-solidity/blob/master/contracts/ownership/Ownable.sol
contract Ownable is Initializable {
    event TransferredOwnership(address _from, address _to);
    event LockedOwnership(address _locked);

    address payable private _owner;
    bool private _isTransferable;

    /// @notice Reverts if called by any account other than the owner.
    modifier onlyOwner() {
        require(_isOwner(msg.sender), "sender is not an owner");
        _;
    }

    /// @notice Allows the current owner to transfer control of the contract to a new address.
    /// @param _account address to transfer ownership to.
    /// @param _transferable indicates whether to keep the ownership transferable.
    function transferOwnership(address payable _account, bool _transferable) external onlyOwner {
        // Require that the ownership is transferable.
        require(_isTransferable, "ownership is not transferable");
        // Require that the new owner is not the zero address.
        require(_account != address(0), "owner cannot be set to zero address");
        // Set the transferable flag to the value _transferable passed in.
        _isTransferable = _transferable;
        // Emit the LockedOwnership event if no longer transferable.
        if (!_transferable) {
            emit LockedOwnership(_account);
        }
        // Emit the ownership transfer event.
        emit TransferredOwnership(_owner, _account);
        // Set the owner to the provided address.
        _owner = _account;
    }

    /// @notice check if the ownership is transferable.
    /// @return true if the ownership is transferable.
    function isTransferable() external view returns (bool) {
        return _isTransferable;
    }

    /// @notice Allows the current owner to relinquish control of the contract.
    /// @dev Renouncing to ownership will leave the contract without an owner and unusable.
    /// @dev It will not be possible to call the functions with the `onlyOwner` modifier anymore.
    function renounceOwnership() external onlyOwner {
        // Require that the ownership is transferable.
        require(_isTransferable, "ownership is not transferable");
        // note that this could be terminal
        _owner = address(0);

        emit TransferredOwnership(_owner, address(0));
    }

    /// @notice Find out owner address
    /// @return address of the owner.
    function owner() public view returns (address payable) {
        return _owner;
    }

    /// @notice Sets the original owner of the contract and whether or not it is one time transferable.
    function _initializeOwnable(address payable _account, bool _transferable) internal initializer {
        _owner = _account;
        _isTransferable = _transferable;
        // Emit the LockedOwnership event if no longer transferable.
        if (!_isTransferable) {
            emit LockedOwnership(_account);
        }
        emit TransferredOwnership(address(0), _account);
    }

    /// @notice Check if owner address
    /// @return true if sender is the owner of the contract.
    function _isOwner(address _address) internal view returns (bool) {
        return _address == _owner;
    }
}

// File: localhost/interfaces/IController.sol


/// @title The IController interface provides access to the isController and isAdmin checks.

// File: localhost/controller.sol

/**
 *  Controller - The Consumer Contract Wallet
 *  Copyright (C) 2019 The Contract Wallet Company Limited
 *
 *  This program is free software: you can redistribute it and/or modify
 *  it under the terms of the GNU General Public License as published by
 *  the Free Software Foundation, either version 3 of the License, or
 *  (at your option) any later version.

 *  This program is distributed in the hope that it will be useful,
 *  but WITHOUT ANY WARRANTY; without even the implied warranty of
 *  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 *  GNU General Public License for more details.

 *  You should have received a copy of the GNU General Public License
 *  along with this program.  If not, see <https://www.gnu.org/licenses/>.
 */




/// @title Controller stores a list of controller addresses that can be used for authentication in other contracts.
/// @notice The Controller implements a hierarchy of concepts, Owner, Admin, and the Controllers.
/// @dev Owner can change the Admins
/// @dev Admins and can the Controllers
/// @dev Controllers are used by the application.
contract Controller is IController, Ownable, Transferrable {
    event AddedController(address _sender, address _controller);
    event RemovedController(address _sender, address _controller);

    event AddedAdmin(address _sender, address _admin);
    event RemovedAdmin(address _sender, address _admin);

    event Claimed(address _to, address _asset, uint256 _amount);

    event Stopped(address _sender);
    event Started(address _sender);

    mapping(address => bool) private _isAdmin;
    uint256 private _adminCount;

    mapping(address => bool) private _isController;
    uint256 private _controllerCount;

    bool private _stopped;

    /// @notice Constructor initializes the owner with the provided address.
    /// @param _ownerAddress_ address of the owner.
    constructor(address payable _ownerAddress_) public {
        _initializeOwnable(_ownerAddress_, false);
    }

    /// @notice Checks if message sender is an admin.
    modifier onlyAdmin() {
        require(_isAdmin[msg.sender], "sender is not admin");
        _;
    }

    /// @notice Check if Owner or Admin
    modifier onlyAdminOrOwner() {
        require(_isOwner(msg.sender) || _isAdmin[msg.sender], "sender is not admin or owner");
        _;
    }

    /// @notice Check if controller is stopped
    modifier notStopped() {
        require(!isStopped(), "controller is stopped");
        _;
    }

    /// @notice Add a new admin to the list of admins.
    /// @param _account address to add to the list of admins.
    function addAdmin(address _account) external onlyOwner notStopped {
        _addAdmin(_account);
    }

    /// @notice Remove a admin from the list of admins.
    /// @param _account address to remove from the list of admins.
    function removeAdmin(address _account) external onlyOwner {
        _removeAdmin(_account);
    }

    /// @return the current number of admins.
    function adminCount() external view returns (uint256) {
        return _adminCount;
    }

    /// @notice Add a new controller to the list of controllers.
    /// @param _account address to add to the list of controllers.
    function addController(address _account) external onlyAdminOrOwner notStopped {
        _addController(_account);
    }

    /// @notice Remove a controller from the list of controllers.
    /// @param _account address to remove from the list of controllers.
    function removeController(address _account) external onlyAdminOrOwner {
        _removeController(_account);
    }

    /// @notice count the Controllers
    /// @return the current number of controllers.
    function controllerCount() external view returns (uint256) {
        return _controllerCount;
    }

    /// @notice is an address an Admin?
    /// @return true if the provided account is an admin.
    function isAdmin(address _account) external override view notStopped returns (bool) {
        return _isAdmin[_account];
    }

    /// @notice is an address a Controller?
    /// @return true if the provided account is a controller.
    function isController(address _account) external override view notStopped returns (bool) {
        return _isController[_account];
    }

    /// @notice this function can be used to see if the controller has been stopped
    /// @return true is the Controller has been stopped
    function isStopped() public view returns (bool) {
        return _stopped;
    }

    /// @notice Internal-only function that adds a new admin.
    function _addAdmin(address _account) private {
        require(!_isAdmin[_account], "provided account is already an admin");
        require(!_isController[_account], "provided account is already a controller");
        require(!_isOwner(_account), "provided account is already the owner");
        require(_account != address(0), "provided account is the zero address");
        _isAdmin[_account] = true;
        _adminCount++;
        emit AddedAdmin(msg.sender, _account);
    }

    /// @notice Internal-only function that removes an existing admin.
    function _removeAdmin(address _account) private {
        require(_isAdmin[_account], "provided account is not an admin");
        _isAdmin[_account] = false;
        _adminCount--;
        emit RemovedAdmin(msg.sender, _account);
    }

    /// @notice Internal-only function that adds a new controller.
    function _addController(address _account) private {
        require(!_isAdmin[_account], "provided account is already an admin");
        require(!_isController[_account], "provided account is already a controller");
        require(!_isOwner(_account), "provided account is already the owner");
        require(_account != address(0), "provided account is the zero address");
        _isController[_account] = true;
        _controllerCount++;
        emit AddedController(msg.sender, _account);
    }

    /// @notice Internal-only function that removes an existing controller.
    function _removeController(address _account) private {
        require(_isController[_account], "provided account is not a controller");
        _isController[_account] = false;
        _controllerCount--;
        emit RemovedController(msg.sender, _account);
    }

    /// @notice stop our controllers and admins from being useable
    function stop() external onlyAdminOrOwner {
        _stopped = true;
        emit Stopped(msg.sender);
    }

    /// @notice start our controller again
    function start() external onlyOwner {
        _stopped = false;
        emit Started(msg.sender);
    }

    //// @notice Withdraw tokens from the smart contract to the specified account.
    function claim(
        address payable _to,
        address _asset,
        uint256 _amount
    ) external onlyAdmin notStopped {
        _safeTransfer(_to, _asset, _amount);
        emit Claimed(_to, _asset, _amount);
    }
}

// File: localhost/interfaces/IPublicResolver.sol





// File: localhost/interfaces/IENS.sol





// File: localhost/internals/ensResolvable.sol

/**
 *  ENSResolvable - The Consumer Contract Wallet
 *  Copyright (C) 2019 The Contract Wallet Company Limited
 *
 *  This program is free software: you can redistribute it and/or modify
 *  it under the terms of the GNU General Public License as published by
 *  the Free Software Foundation, either version 3 of the License, or
 *  (at your option) any later version.

 *  This program is distributed in the hope that it will be useful,
 *  but WITHOUT ANY WARRANTY; without even the implied warranty of
 *  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 *  GNU General Public License for more details.

 *  You should have received a copy of the GNU General Public License
 *  along with this program.  If not, see <https://www.gnu.org/licenses/>.
 */




///@title ENSResolvable - Ethereum Name Service Resolver
///@notice contract should be used to get an address for an ENS node
contract ENSResolvable is Initializable {
    /// @dev Address of the ENS registry contract set to the default ENS registry address.
    address private _ensRegistry = address(0x00000000000C2E074eC69A0dFb2997BA6C7d2e1e);

    /// @notice Checks if the contract has been initialized succesfully i.e. the ENS registry has been set.
    modifier initialized() {
        require(_ensRegistry != address(0), "ENSResolvable not initialized");
        _;
    }

    /// @return Current address of the ENS registry contract.
    function ensRegistry() public view returns (address) {
        return _ensRegistry;
    }

    /// @notice Helper function used to get the address of a node.
    /// @param _node of the ENS entry that needs resolving.
    /// @return The address of the resolved ENS node.
    function _ensResolve(bytes32 _node) internal view initialized returns (address) {
        return IPublicResolver(IENS(_ensRegistry).resolver(_node)).addr(_node);
    }

    /// @param _ensReg is the ENS registry used.
    function _initializeENSResolvable(address _ensReg) internal initializer {
        // Set ENS registry or use default
        if (_ensReg != address(0)) {
            _ensRegistry = _ensReg;
        }
    }
}

// File: localhost/internals/controllable.sol

/**
 *  Controllable - The Consumer Contract Wallet
 *  Copyright (C) 2019 The Contract Wallet Company Limited
 *
 *  This program is free software: you can redistribute it and/or modify
 *  it under the terms of the GNU General Public License as published by
 *  the Free Software Foundation, either version 3 of the License, or
 *  (at your option) any later version.

 *  This program is distributed in the hope that it will be useful,
 *  but WITHOUT ANY WARRANTY; without even the implied warranty of
 *  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 *  GNU General Public License for more details.

 *  You should have received a copy of the GNU General Public License
 *  along with this program.  If not, see <https://www.gnu.org/licenses/>.
 */




/// @title Controllable implements access control functionality of the Controller found via ENS.
contract Controllable is ENSResolvable {
    // Default values for mainnet ENS
    // controller.tokencard.eth
    bytes32 private constant _DEFAULT_CONTROLLER_NODE = 0x7f2ce995617d2816b426c5c8698c5ec2952f7a34bb10f38326f74933d5893697;

    /// @dev Is the registered ENS node identifying the controller contract.
    bytes32 private _controllerNode = _DEFAULT_CONTROLLER_NODE;

    /// @notice Checks if message sender is a controller.
    modifier onlyController() {
        require(_isController(msg.sender), "sender is not a controller");
        _;
    }

    /// @notice Checks if message sender is an admin.
    modifier onlyAdmin() {
        require(_isAdmin(msg.sender), "sender is not an admin");
        _;
    }

    /// @return the controller node registered in ENS.
    function controllerNode() public view returns (bytes32) {
        return _controllerNode;
    }

    /// @notice Initializes the controller contract object.
    /// @param _controllerNode_ is the ENS node of the Controller.
    /// @dev pass in bytes32(0) to use the default, production node labels for ENS
    function _initializeControllable(bytes32 _controllerNode_) internal initializer {
        // Set controllerNode or use default
        if (_controllerNode_ != bytes32(0)) {
            _controllerNode = _controllerNode_;
        }
    }

    /// @return true if the provided account is a controller.
    function _isController(address _account) internal view returns (bool) {
        return IController(_ensResolve(_controllerNode)).isController(_account);
    }

    /// @return true if the provided account is an admin.
    function _isAdmin(address _account) internal view returns (bool) {
        return IController(_ensResolve(_controllerNode)).isAdmin(_account);
    }
}

// File: localhost/gasProxy.sol

/**
 *  Copyright (C) 2019 The Contract Wallet Company Limited
 *
 *  This program is free software: you can redistribute it and/or modify
 *  it under the terms of the GNU General Public License as published by
 *  the Free Software Foundation, either version 3 of the License, or
 *  (at your option) any later version.
 *  This program is distributed in the hope that it will be useful,
 *  but WITHOUT ANY WARRANTY; without even the implied warranty of
 *  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 *  GNU General Public License for more details.
 *  You should have received a copy of the GNU General Public License
 *  along with this program.  If not, see <https://www.gnu.org/licenses/>.
 */


contract GasProxy is Controllable, GasRefundable {
    /// @notice Emits the transaction executed by the controller.
    event ExecutedTransaction(address _destination, uint256 _value, bytes _data, bytes _returnData);

    /// @param _ens_ is the address of the ENS registry.
    /// @param _controllerNode_ ENS node of the controller contract.
    constructor(address _ens_, bytes32 _controllerNode_) public {
        _initializeENSResolvable(_ens_);
        _initializeControllable(_controllerNode_);
    }

    /// @param _gasTokenAddress Address of the gas token used to refund gas.
    /// @param _parameters Gas cost of the gas token free method call and amount of gas refunded per unit of gas token.
    function setGasToken(address _gasTokenAddress, GasTokenParameters calldata _parameters) external onlyAdmin {
        _setGasToken(_gasTokenAddress, _parameters);
    }

    /// @notice Executes a controller operation and refunds gas using gas tokens.
    /// @param _destination Destination address of the executed transaction.
    /// @param _value Amount of ETH (wei) to be sent together with the transaction.
    /// @param _data Data payload of the controller transaction.
    function executeTransaction(
        address _destination,
        uint256 _value,
        bytes calldata _data
    ) external payable onlyController refundGas returns (bytes memory) {
        (bool success, bytes memory returnData) = _destination.call{value: _value}(_data);
        require(success, "external call failed");
        emit ExecutedTransaction(_destination, _value, _data, returnData);
        return returnData;
    }
}