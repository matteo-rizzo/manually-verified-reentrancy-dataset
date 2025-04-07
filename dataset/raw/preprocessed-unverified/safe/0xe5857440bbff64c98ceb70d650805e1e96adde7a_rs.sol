/**
 *Submitted for verification at Etherscan.io on 2020-11-08
*/

// SPDX-License-Identifier: Apache-2.0
pragma solidity ^0.7.0;
// File: contracts/lib/Ownable.sol

// Copyright 2017 Loopring Technology Limited.


/// @title Ownable
/// @author Brecht Devos - <brecht@loopring.org>
/// @dev The Ownable contract has an owner address, and provides basic
///      authorization control functions, this simplifies the implementation of
///      "user permissions".


// File: contracts/iface/Wallet.sol

// Copyright 2017 Loopring Technology Limited.


/// @title Wallet
/// @dev Base contract for smart wallets.
///      Sub-contracts must NOT use non-default constructor to initialize
///      wallet states, instead, `init` shall be used. This is to enable
///      proxies to be deployed in front of the real wallet contract for
///      saving gas.
///
/// @author Daniel Wang - <daniel@loopring.org>


// File: contracts/iface/Module.sol

// Copyright 2017 Loopring Technology Limited.




/// @title Module
/// @dev Base contract for all smart wallet modules.
///
/// @author Daniel Wang - <daniel@loopring.org>


// File: contracts/lib/ERC20.sol

// Copyright 2017 Loopring Technology Limited.


/// @title ERC20 Token Interface
/// @dev see https://github.com/ethereum/EIPs/issues/20
/// @author Daniel Wang - <daniel@loopring.org>
abstract contract ERC20
{
    function totalSupply()
        public
        view
        virtual
        returns (uint);

    function balanceOf(
        address who
        )
        public
        view
        virtual
        returns (uint);

    function allowance(
        address owner,
        address spender
        )
        public
        view
        virtual
        returns (uint);

    function transfer(
        address to,
        uint value
        )
        public
        virtual
        returns (bool);

    function transferFrom(
        address from,
        address to,
        uint    value
        )
        public
        virtual
        returns (bool);

    function approve(
        address spender,
        uint    value
        )
        public
        virtual
        returns (bool);
}

// File: contracts/lib/ReentrancyGuard.sol

// Copyright 2017 Loopring Technology Limited.


/// @title ReentrancyGuard
/// @author Brecht Devos - <brecht@loopring.org>
/// @dev Exposes a modifier that guards a function against reentrancy
///      Changing the value of the same storage value multiple times in a transaction
///      is cheap (starting from Istanbul) so there is no need to minimize
///      the number of times the value is changed
contract ReentrancyGuard
{
    //The default value must be 0 in order to work behind a proxy.
    uint private _guardValue;

    modifier nonReentrant()
    {
        require(_guardValue == 0, "REENTRANCY");
        _guardValue = 1;
        _;
        _guardValue = 0;
    }
}

// File: contracts/iface/ModuleRegistry.sol

// Copyright 2017 Loopring Technology Limited.


/// @title ModuleRegistry
/// @dev A registry for modules.
///
/// @author Daniel Wang - <daniel@loopring.org>


// File: contracts/base/Controller.sol

// Copyright 2017 Loopring Technology Limited.



/// @title Controller
///
/// @author Daniel Wang - <daniel@loopring.org>
abstract contract Controller
{
    function moduleRegistry()
        external
        view
        virtual
        returns (ModuleRegistry);

    function walletFactory()
        external
        view
        virtual
        returns (address);
}

// File: contracts/base/BaseWallet.sol

// Copyright 2017 Loopring Technology Limited.







/// @title BaseWallet
/// @dev This contract provides basic implementation for a Wallet.
///
/// @author Daniel Wang - <daniel@loopring.org>
abstract contract BaseWallet is ReentrancyGuard, Wallet
{
    // WARNING: do not delete wallet state data to make this implementation
    // compatible with early versions.
    //
    //  ----- DATA LAYOUT BEGINS -----
    address internal _owner;

    mapping (address => bool) private modules;

    Controller public controller;

    mapping (bytes4  => address) internal methodToModule;
    //  ----- DATA LAYOUT ENDS -----

    event OwnerChanged          (address newOwner);
    event ControllerChanged     (address newController);
    event ModuleAdded           (address module);
    event ModuleRemoved         (address module);
    event MethodBound           (bytes4  method, address module);
    event WalletSetup           (address owner);

    modifier onlyFromModule
    {
        require(modules[msg.sender], "MODULE_UNAUTHORIZED");
        _;
    }

    modifier onlyFromFactory
    {
        require(
            msg.sender == controller.walletFactory(),
            "UNAUTHORIZED"
        );
        _;
    }

    /// @dev We need to make sure the Factory address cannot be changed without wallet owner's
    ///      explicit authorization.
    modifier onlyFromFactoryOrModule
    {
        require(
            modules[msg.sender] || msg.sender == controller.walletFactory(),
            "UNAUTHORIZED"
        );
        _;
    }

    /// @dev Set up this wallet by assigning an original owner
    ///
    ///      Note that calling this method more than once will throw.
    ///
    /// @param _initialOwner The owner of this wallet, must not be address(0).
    function initOwner(
        address _initialOwner
        )
        external
        onlyFromFactory
    {
        require(controller != Controller(0), "NO_CONTROLLER");
        require(_owner == address(0), "INITIALIZED_ALREADY");
        require(_initialOwner != address(0), "ZERO_ADDRESS");

        _owner = _initialOwner;
        emit WalletSetup(_initialOwner);
    }

    /// @dev Set up this wallet by assigning a controller and initial modules.
    ///
    ///      Note that calling this method more than once will throw.
    ///      And this method must be invoked before owner is initialized
    ///
    /// @param _controller The Controller instance.
    /// @param _modules The initial modules.
    function init(
        Controller _controller,
        address[]  calldata _modules
        )
        external
    {
        require(
            _owner == address(0) &&
            controller == Controller(0) &&
            _controller != Controller(0),
            "CONTROLLER_INIT_FAILED"
        );

        controller = _controller;

        ModuleRegistry moduleRegistry = controller.moduleRegistry();
        for (uint i = 0; i < _modules.length; i++) {
            _addModule(_modules[i], moduleRegistry);
        }
    }

    function owner()
        override
        public
        view
        returns (address)
    {
        return _owner;
    }

    function setOwner(address newOwner)
        external
        override
        onlyFromModule
    {
        require(newOwner != address(0), "ZERO_ADDRESS");
        require(newOwner != address(this), "PROHIBITED");
        require(newOwner != _owner, "SAME_ADDRESS");
        _owner = newOwner;
        emit OwnerChanged(newOwner);
    }

    function setController(Controller newController)
        external
        onlyFromModule
    {
        require(newController != controller, "SAME_CONTROLLER");
        require(newController != Controller(0), "INVALID_CONTROLLER");
        controller = newController;
        emit ControllerChanged(address(newController));
    }

    function addModule(address _module)
        external
        override
        onlyFromFactoryOrModule
    {
        _addModule(_module, controller.moduleRegistry());
    }

    function removeModule(address _module)
        external
        override
        onlyFromModule
    {
        // Allow deactivate to fail to make sure the module can be removed
        require(modules[_module], "MODULE_NOT_EXISTS");
        try Module(_module).deactivate() {} catch {}
        delete modules[_module];
        emit ModuleRemoved(_module);
    }

    function hasModule(address _module)
        public
        view
        override
        returns (bool)
    {
        return modules[_module];
    }

    function bindMethod(bytes4 _method, address _module)
        external
        override
        onlyFromModule
    {
        require(_method != bytes4(0), "BAD_METHOD");
        if (_module != address(0)) {
            require(modules[_module], "MODULE_UNAUTHORIZED");
        }

        methodToModule[_method] = _module;
        emit MethodBound(_method, _module);
    }

    function boundMethodModule(bytes4 _method)
        public
        view
        override
        returns (address)
    {
        return methodToModule[_method];
    }

    function transact(
        uint8    mode,
        address  to,
        uint     value,
        bytes    calldata data
        )
        external
        override
        onlyFromFactoryOrModule
        returns (bytes memory returnData)
    {
        bool success;
        (success, returnData) = _call(mode, to, value, data);

        if (!success) {
            assembly {
                returndatacopy(0, 0, returndatasize())
                revert(0, returndatasize())
            }
        }
    }

    receive()
        external
        payable
    {
    }

    /// @dev This default function can receive Ether or perform queries to modules
    ///      using bound methods.
    fallback()
        external
        payable
    {
        address module = methodToModule[msg.sig];
        require(modules[module], "MODULE_UNAUTHORIZED");

        (bool success, bytes memory returnData) = module.call{value: msg.value}(msg.data);
        assembly {
            switch success
            case 0 { revert(add(returnData, 32), mload(returnData)) }
            default { return(add(returnData, 32), mload(returnData)) }
        }
    }

    function _addModule(address _module, ModuleRegistry moduleRegistry)
        internal
    {
        require(_module != address(0), "NULL_MODULE");
        require(modules[_module] == false, "MODULE_EXISTS");
        require(
            moduleRegistry.isModuleEnabled(_module),
            "INVALID_MODULE"
        );
        modules[_module] = true;
        emit ModuleAdded(_module);
        Module(_module).activate();
    }

    function _call(
        uint8          mode,
        address        target,
        uint           value,
        bytes calldata data
        )
        private
        returns (
            bool success,
            bytes memory returnData
        )
    {
        if (mode == 1) {
            // solium-disable-next-line security/no-call-value
            (success, returnData) = target.call{value: value}(data);
        } else if (mode == 2) {
            // solium-disable-next-line security/no-call-value
            (success, returnData) = target.delegatecall(data);
        } else if (mode == 3) {
            require(value == 0, "INVALID_VALUE");
            // solium-disable-next-line security/no-call-value
            (success, returnData) = target.staticcall(data);
        } else {
            revert("UNSUPPORTED_MODE");
        }
    }
}

// File: contracts/modules/WalletImpl.sol

// Copyright 2017 Loopring Technology Limited.



/// @title WalletImpl
contract WalletImpl is BaseWallet {
    function version()
        public
        override
        pure
        returns (string memory)
    {
        // 使用中国省会作为别名
        return "1.2.0 (daqing)";
    }
}