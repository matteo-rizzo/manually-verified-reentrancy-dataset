// SPDX-License-Identifier: MIT
pragma solidity =0.8.3;
import {IAMB} from './interfaces/AMB/IAMB.sol';
import {IMultiTokenMediator} from './interfaces/AMB/IMultiTokenMediator.sol';
import {IERC20} from '@openzeppelin/contracts/token/ERC20/IERC20.sol';
import {
    SafeERC20
} from '@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol';
import '@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol';
import '@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol';
import '@openzeppelin/contracts-upgradeable/metatx/ERC2771ContextUpgradeable.sol';

/// @title UniswapV2Router02 Interface


/// @title LemmaXDAI interface. LemmaXDAI exists on XDAI network.


/// @title LemmaContract for Mainnet.
/// @author yashnaman
/// @dev All function calls are currently implemented.
contract LemmaMainnet is OwnableUpgradeable, ERC2771ContextUpgradeable {
    using SafeERC20 for IERC20;
    /// @notice mainnet AMB bridge contract
    IAMB public ambBridge;
    /// @notice mainnet multi-tokens mediator
    IMultiTokenMediator public multiTokenMediator;

    ILemmaxDAI public lemmaXDAI;
    uint256 public gasLimit;

    IERC20 public USDC;
    IERC20 public WETH;
    IUniswapV2Router02 public uniswapV2Router02;
    uint256 public totalETHDeposited;
    uint256 public cap;

    mapping(address => uint256) public withdrawalInfo;
    mapping(address => uint256) public minimumETHToBeWithdrawn;

    event ETHDeposited(address indexed account, uint256 indexed amount);
    event ETHWithdrawn(address indexed account, uint256 indexed amount);
    event WithdrawalInfoAdded(address indexed account, uint256 indexed amount);

    /// @notice Initialize proxy.
    /// @param _lemmaXDAI Lemma token deployed on xdai network.
    /// @param _ambBridge Bridge contract address on mainnet
    function initialize(
        IERC20 _USDC,
        IERC20 _WETH,
        ILemmaxDAI _lemmaXDAI,
        IUniswapV2Router02 _uniswapV2Router02,
        IAMB _ambBridge,
        IMultiTokenMediator _multiTokenMediator,
        address trustedForwarder,
        uint256 _cap
    ) public initializer {
        __Ownable_init();
        __ERC2771Context_init(trustedForwarder);
        USDC = _USDC;
        WETH = _WETH;
        lemmaXDAI = _lemmaXDAI;
        uniswapV2Router02 = _uniswapV2Router02;
        ambBridge = _ambBridge;
        require(
            _ambBridge.sourceChainId() == block.chainid,
            'ambBridge chainId not valid'
        );
        multiTokenMediator = _multiTokenMediator;
        require(
            _multiTokenMediator.bridgeContract() == address(_ambBridge),
            'Invalid ambBridge/multiTokenMediator'
        );
        setGasLimit(1000000);
        setCap(_cap);
    }

    function _msgSender()
        internal
        view
        virtual
        override(ContextUpgradeable, ERC2771ContextUpgradeable)
        returns (address sender)
    {
        //this is same as ERC2771ContextUpgradeable._msgSender();
        //We want to use the _msgSender() implementation of ERC2771ContextUpgradeable
        return super._msgSender();
    }

    function _msgData()
        internal
        view
        virtual
        override(ContextUpgradeable, ERC2771ContextUpgradeable)
        returns (bytes calldata)
    {
        //this is same as ERC2771ContextUpgradeable._msgData();
        //We want to use the _msgData() implementation of ERC2771ContextUpgradeable
        return super._msgData();
    }

    /// @notice Set gas limit that is used to call bridge.
    /// @dev Only owner can set gas limit.
    function setGasLimit(uint256 _gasLimit) public onlyOwner {
        gasLimit = _gasLimit;
    }

    /// @notice Set cap
    /// @dev Only owner can set cap.
    function setCap(uint256 _cap) public onlyOwner {
        cap = _cap;
    }

    /// @notice Pay ethereum to deposit USDC.
    /// @dev Paid eth is converted to USDC on Uniswap and then deposited to lemmaXDAI.
    /// @param _minimumUSDCAmountOut is the minumum amount to get from Paid Eth.
    /// @param _minLUSDCAmountOut minimum LUSDC user should get on XDAI
    function deposit(uint256 _minimumUSDCAmountOut, uint256 _minLUSDCAmountOut)
        external
        payable
    {
        totalETHDeposited += msg.value;
        require(totalETHDeposited <= cap, 'Lemma: cap reached');
        address[] memory path = new address[](2);
        path[0] = address(WETH);
        path[1] = address(USDC);

        uint256[] memory amounts =
            uniswapV2Router02.swapExactETHForTokens{value: msg.value}(
                _minimumUSDCAmountOut,
                path,
                address(this),
                type(uint256).max
            );

        multiTokenTransfer(USDC, address(lemmaXDAI), amounts[1]);

        //now relay the depositInfo to lemmaXDAI
        bytes4 functionSelector = ILemmaxDAI.setDepositInfo.selector;
        bytes memory data =
            abi.encodeWithSelector(
                functionSelector,
                _msgSender(),
                amounts[1],
                _minLUSDCAmountOut
            );
        callBridge(address(lemmaXDAI), data, gasLimit);
        emit ETHDeposited(_msgSender(), msg.value);
    }

    /// @notice Set Withdraw Info
    /// @dev This function can be called by only lemmaXDAI contract via ambBridge contract.
    /// @param _account account is withdrawing
    /// @param  _amount USDC amount
    /// @param _minETHOut minimum Eth amount user is willing to get out
    function setWithdrawalInfo(
        address _account,
        uint256 _amount,
        uint256 _minETHOut
    ) external {
        require(_msgSender() == address(ambBridge), 'not ambBridge');
        require(
            ambBridge.messageSender() == address(lemmaXDAI),
            "ambBridge's messageSender is not lemmaXDAI"
        );
        withdrawalInfo[_account] += _amount;
        minimumETHToBeWithdrawn[_account] = _minETHOut;
        emit WithdrawalInfoAdded(_account, _amount);
    }

    /// @notice update the minimum ETH amount to get out after withdrawing
    /// @param _minETHOut minimum ETH amount
    function setMinimuETHToBeWithdrawn(uint256 _minETHOut) external {
        minimumETHToBeWithdrawn[_msgSender()] = _minETHOut;
    }

    /// @notice Withdraw eth based on the USDC amount set by WithdrawInfo.
    /// @dev The USDC set by withdrawInfo is converted to ETH on sushiswap and the ETH is transferred to _account.
    /// @param _account is an account withdrawn to.
    function withdraw(address _account) public {
        uint256 amount = withdrawalInfo[_account];
        uint256 minETHOut = minimumETHToBeWithdrawn[_account];
        delete withdrawalInfo[_account];
        address[] memory path = new address[](2);
        path[0] = address(USDC);
        path[1] = address(WETH);
        // uint256[] memory amounts =
        USDC.safeApprove(address(uniswapV2Router02), amount);
        uint256[] memory amounts =
            uniswapV2Router02.swapExactTokensForETH(
                amount,
                minETHOut,
                path,
                _account,
                type(uint256).max
            );
        emit ETHWithdrawn(_account, amounts[1]);
    }

    /// @dev This function is used for sending USDC to multiTokenMediator
    function multiTokenTransfer(
        IERC20 _token,
        address _receiver,
        uint256 _amount
    ) internal {
        require(_receiver != address(0), 'receiver is empty');
        // approve to multi token mediator and call 'relayTokens'
        _token.safeApprove(address(multiTokenMediator), _amount);
        multiTokenMediator.relayTokens(address(_token), _receiver, _amount);
    }

    /// @param _contractOnOtherSide is lemmaXDAI address deployed on xdai network in our case
    /// @param _data is ABI-encoded function data
    function callBridge(
        address _contractOnOtherSide,
        bytes memory _data,
        uint256 _gasLimit
    ) internal returns (bytes32 messageId) {
        // server can check event, `UserRequestForAffirmation(bytes32 indexed messageId, bytes encodedData)`,
        // emitted by amb bridge contract
        messageId = ambBridge.requireToPassMessage(
            _contractOnOtherSide,
            _data,
            _gasLimit
        );
    }
}

// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity =0.8.3;



// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity =0.8.3;



// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
 */


// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "../IERC20.sol";
import "../../../utils/Address.sol";

/**
 * @title SafeERC20
 * @dev Wrappers around ERC20 operations that throw on failure (when the token
 * contract returns false). Tokens that return no value (and instead revert or
 * throw on failure) are also supported, non-reverting calls are assumed to be
 * successful.
 * To use this library you can add a `using SafeERC20 for IERC20;` statement to your contract,
 * which allows you to call the safe operations as `token.safeTransfer(...)`, etc.
 */


// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "../utils/ContextUpgradeable.sol";
import "../proxy/utils/Initializable.sol";
/**
 * @dev Contract module which provides a basic access control mechanism, where
 * there is an account (an owner) that can be granted exclusive access to
 * specific functions.
 *
 * By default, the owner account will be the one that deploys the contract. This
 * can later be changed with {transferOwnership}.
 *
 * This module is used through inheritance. It will make available the modifier
 * `onlyOwner`, which can be applied to your functions to restrict their use to
 * the owner.
 */
abstract contract OwnableUpgradeable is Initializable, ContextUpgradeable {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    function __Ownable_init() internal initializer {
        __Context_init_unchained();
        __Ownable_init_unchained();
    }

    function __Ownable_init_unchained() internal initializer {
        address msgSender = _msgSender();
        _owner = msgSender;
        emit OwnershipTransferred(address(0), msgSender);
    }

    /**
     * @dev Returns the address of the current owner.
     */
    function owner() public view virtual returns (address) {
        return _owner;
    }

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
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
    uint256[49] private __gap;
}

// SPDX-License-Identifier: MIT

// solhint-disable-next-line compiler-version
pragma solidity ^0.8.0;

import "../../utils/AddressUpgradeable.sol";

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

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "../utils/ContextUpgradeable.sol";
import "../proxy/utils/Initializable.sol";

/*
 * @dev Context variant with ERC2771 support.
 */
abstract contract ERC2771ContextUpgradeable is Initializable, ContextUpgradeable {
    address _trustedForwarder;

    function __ERC2771Context_init(address trustedForwarder) internal initializer {
        __Context_init_unchained();
        __ERC2771Context_init_unchained(trustedForwarder);
    }

    function __ERC2771Context_init_unchained(address trustedForwarder) internal initializer {
        _trustedForwarder = trustedForwarder;
    }

    function isTrustedForwarder(address forwarder) public view virtual returns(bool) {
        return forwarder == _trustedForwarder;
    }

    function _msgSender() internal view virtual override returns (address sender) {
        if (isTrustedForwarder(msg.sender)) {
            // The assembly code is more direct than the Solidity version using `abi.decode`.
            assembly { sender := shr(96, calldataload(sub(calldatasize(), 20))) }
        } else {
            return super._msgSender();
        }
    }

    function _msgData() internal view virtual override returns (bytes calldata) {
        if (isTrustedForwarder(msg.sender)) {
            return msg.data[:msg.data.length-20];
        } else {
            return super._msgData();
        }
    }
    uint256[50] private __gap;
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

/**
 * @dev Collection of functions related to the address type
 */


// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;
import "../proxy/utils/Initializable.sol";

/*
 * @dev Provides information about the current execution context, including the
 * sender of the transaction and its data. While these are generally available
 * via msg.sender and msg.data, they should not be accessed in such a direct
 * manner, since when dealing with meta-transactions the account sending and
 * paying for execution may not be the actual sender (as far as an application
 * is concerned).
 *
 * This contract is only required for intermediate, library-like contracts.
 */
abstract contract ContextUpgradeable is Initializable {
    function __Context_init() internal initializer {
        __Context_init_unchained();
    }

    function __Context_init_unchained() internal initializer {
    }
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
    uint256[50] private __gap;
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

/**
 * @dev Collection of functions related to the address type
 */


{
  "optimizer": {
    "enabled": true,
    "runs": 200
  },
  "outputSelection": {
    "*": {
      "*": [
        "evm.bytecode",
        "evm.deployedBytecode",
        "abi"
      ]
    }
  },
  "libraries": {}
}