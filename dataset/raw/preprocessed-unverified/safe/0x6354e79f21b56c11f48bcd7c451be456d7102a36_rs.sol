/**
 *Submitted for verification at Etherscan.io on 2020-12-03
*/

// Dependency file: /Users/present/code/brownie-sett/deps/@openzeppelin/contracts-upgradeable/token/ERC20/IERC20Upgradeable.sol

// SPDX-License-Identifier: MIT

// pragma solidity ^0.6.0;

/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
 */



// Dependency file: /Users/present/code/brownie-sett/deps/@openzeppelin/contracts-upgradeable/math/SafeMathUpgradeable.sol


// pragma solidity ^0.6.0;

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



// Dependency file: /Users/present/code/brownie-sett/deps/@openzeppelin/contracts-upgradeable/utils/AddressUpgradeable.sol


// pragma solidity ^0.6.2;

/**
 * @dev Collection of functions related to the address type
 */



// Dependency file: /Users/present/code/brownie-sett/deps/@openzeppelin/contracts-upgradeable/token/ERC20/SafeERC20Upgradeable.sol


// pragma solidity ^0.6.0;

// import "/Users/present/code/brownie-sett/deps/@openzeppelin/contracts-upgradeable/token/ERC20/IERC20Upgradeable.sol";
// import "/Users/present/code/brownie-sett/deps/@openzeppelin/contracts-upgradeable/math/SafeMathUpgradeable.sol";
// import "/Users/present/code/brownie-sett/deps/@openzeppelin/contracts-upgradeable/utils/AddressUpgradeable.sol";

/**
 * @title SafeERC20
 * @dev Wrappers around ERC20 operations that throw on failure (when the token
 * contract returns false). Tokens that return no value (and instead revert or
 * throw on failure) are also supported, non-reverting calls are assumed to be
 * successful.
 * To use this library you can add a `using SafeERC20 for IERC20;` statement to your contract,
 * which allows you to call the safe operations as `token.safeTransfer(...)`, etc.
 */



// Dependency file: /Users/present/code/brownie-sett/deps/@openzeppelin/contracts-upgradeable/proxy/Initializable.sol


// pragma solidity >=0.4.24 <0.7.0;


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
        // extcodesize checks the size of the code stored in an address, and
        // address returns the current address. Since the code is still not
        // deployed when running a constructor, any checks on its code size will
        // yield zero, making it an effective way to detect if a contract is
        // under construction or not.
        address self = address(this);
        uint256 cs;
        // solhint-disable-next-line no-inline-assembly
        assembly { cs := extcodesize(self) }
        return cs == 0;
    }
}


// Dependency file: /Users/present/code/brownie-sett/interfaces/badger/IConverter.sol


// pragma solidity >=0.5.0 <0.8.0;




// Dependency file: /Users/present/code/brownie-sett/interfaces/badger/IOneSplitAudit.sol


// pragma solidity >=0.5.0 <0.8.0;




// Dependency file: /Users/present/code/brownie-sett/interfaces/badger/IStrategy.sol


// pragma solidity >=0.5.0 <0.8.0;




// Dependency file: contracts/badger-sett/SettAccessControl.sol

// pragma solidity ^0.6.11;

// import "/Users/present/code/brownie-sett/deps/@openzeppelin/contracts-upgradeable/proxy/Initializable.sol";

/*
    Common base for permissioned roles throughout Sett ecosystem
*/
contract SettAccessControl is Initializable {
    address public governance;
    address public strategist;
    address public keeper;

    // ===== MODIFIERS =====
    function _onlyGovernance() internal view {
        require(msg.sender == governance, "onlyGovernance");
    }

    function _onlyGovernanceOrStrategist() internal view {
        require(msg.sender == strategist || msg.sender == governance, "onlyGovernanceOrStrategist");
    }

    function _onlyAuthorizedActors() internal view {
        require(msg.sender == keeper || msg.sender == strategist || msg.sender == governance, "onlyAuthorizedActors");
    }

    // ===== PERMISSIONED ACTIONS =====

    /// @notice Change strategist address
    /// @notice Can only be changed by governance itself
    function setStrategist(address _strategist) external {
        _onlyGovernance();
        strategist = _strategist;
    }

    /// @notice Change keeper address
    /// @notice Can only be changed by governance itself
    function setKeeper(address _keeper) external {
        _onlyGovernance();
        keeper = _keeper;
    }

    /// @notice Change governance address
    /// @notice Can only be changed by governance itself
    function setGovernance(address _governance) public {
        _onlyGovernance();
        governance = _governance;
    }

    uint256[50] private __gap;
}


// Root file: contracts/badger-sett/Controller.sol


pragma solidity ^0.6.11;

// import "/Users/present/code/brownie-sett/deps/@openzeppelin/contracts-upgradeable/token/ERC20/IERC20Upgradeable.sol";
// import "/Users/present/code/brownie-sett/deps/@openzeppelin/contracts-upgradeable/math/SafeMathUpgradeable.sol";
// import "/Users/present/code/brownie-sett/deps/@openzeppelin/contracts-upgradeable/utils/AddressUpgradeable.sol";
// import "/Users/present/code/brownie-sett/deps/@openzeppelin/contracts-upgradeable/token/ERC20/SafeERC20Upgradeable.sol";
// import "/Users/present/code/brownie-sett/deps/@openzeppelin/contracts-upgradeable/proxy/Initializable.sol";

// import "/Users/present/code/brownie-sett/interfaces/badger/IConverter.sol";
// import "/Users/present/code/brownie-sett/interfaces/badger/IOneSplitAudit.sol";
// import "/Users/present/code/brownie-sett/interfaces/badger/IStrategy.sol";
// import "contracts/badger-sett/SettAccessControl.sol";

contract Controller is SettAccessControl {
    using SafeERC20Upgradeable for IERC20Upgradeable;
    using AddressUpgradeable for address;
    using SafeMathUpgradeable for uint256;

    address public onesplit;
    address public rewards;
    mapping(address => address) public vaults;
    mapping(address => address) public strategies;
    mapping(address => mapping(address => address)) public converters;
    mapping(address => mapping(address => bool)) public approvedStrategies;

    uint256 public split = 500;
    uint256 public constant max = 10000;

    /// @param _governance Can take any permissioned action within the Controller, with the exception of Vault helper functions
    /// @param _strategist Can configure new Vaults, choose strategies among those approved by governance, and call operations involving non-core tokens
    /// @param _keeper An extra address that can call earn() to deposit tokens from a Sett into the associated active Strategy. Designed for use by a trusted bot in leiu of having this function publically callable.
    /// @param _rewards The recipient of standard fees (such as performance and withdrawal fees) from Strategies
    function initialize(
        address _governance,
        address _strategist,
        address _keeper,
        address _rewards
    ) public initializer {
        governance = _governance;
        strategist = _strategist;
        keeper = _keeper;

        rewards = _rewards;
        onesplit = address(0x50FDA034C0Ce7a8f7EFDAebDA7Aa7cA21CC1267e);
    }

    // ===== Modifiers =====

    /// @notice The Sett for a given token or any of the permissioned roles can call earn() to deposit accumulated deposit funds from the Sett to the active Strategy
    function _onlyApprovedForWant(address want) internal view {
        require(msg.sender == vaults[want] || msg.sender == keeper || msg.sender == strategist || msg.sender == governance, "!authorized");
    }

    // ===== View Functions =====

    /// @notice Get the balance of the given tokens' current strategy of that token.
    function balanceOf(address _token) external view returns (uint256) {
        return IStrategy(strategies[_token]).balanceOf();
    }

    function getExpectedReturn(
        address _strategy,
        address _token,
        uint256 parts
    ) public view returns (uint256 expected) {
        uint256 _balance = IERC20Upgradeable(_token).balanceOf(_strategy);
        address _want = IStrategy(_strategy).want();
        (expected, ) = IOneSplitAudit(onesplit).getExpectedReturn(_token, _want, _balance, parts, 0);
    }

    // ===== Permissioned Actions: Governance Only =====

    /// @notice Approve the given address as a Strategy for a want. The Strategist can freely switch between approved stratgies for a token.
    function approveStrategy(address _token, address _strategy) public {
        _onlyGovernance();
        approvedStrategies[_token][_strategy] = true;
    }

    /// @notice Revoke approval for the given address as a Strategy for a want.
    function revokeStrategy(address _token, address _strategy) public {
        _onlyGovernance();
        approvedStrategies[_token][_strategy] = false;
    }

    /// @notice Change the recipient of rewards for standard fees from Strategies
    function setRewards(address _rewards) public {
        _onlyGovernance();
        rewards = _rewards;
    }

    function setSplit(uint256 _split) public {
        _onlyGovernance();
        split = _split;
    }

    /// @notice Change the oneSplit contract, which is used in conversion of non-core strategy rewards
    function setOneSplit(address _onesplit) public {
        _onlyGovernance();
        onesplit = _onesplit;
    }

    // ===== Permissioned Actions: Governance or Strategist =====

    /// @notice Set the Vault (aka Sett) for a given want
    /// @notice The vault can only be set once
    function setVault(address _token, address _vault) public {
        _onlyGovernanceOrStrategist();

        require(vaults[_token] == address(0), "vault");
        vaults[_token] = _vault;
    }

    /// @notice Migrate assets from existing strategy to a new strategy.
    /// @notice The new strategy must have been previously approved by governance.
    /// @notice Strategist or governance can freely switch between approved strategies
    function setStrategy(address _token, address _strategy) public {
        _onlyGovernanceOrStrategist();

        require(approvedStrategies[_token][_strategy] == true, "!approved");

        address _current = strategies[_token];
        if (_current != address(0)) {
            IStrategy(_current).withdrawAll();
        }
        strategies[_token] = _strategy;
    }

    /// @notice Set the contract used to convert between two given assets
    function setConverter(
        address _input,
        address _output,
        address _converter
    ) public {
        _onlyGovernanceOrStrategist();
        converters[_input][_output] = _converter;
    }

    /// @notice Withdraw the entire balance of a token from that tokens' current strategy.
    /// @notice Does not trigger a withdrawal fee.
    /// @notice Entire balance will be sent to corresponding Sett.
    function withdrawAll(address _token) public {
        _onlyGovernanceOrStrategist();
        IStrategy(strategies[_token]).withdrawAll();
    }

    /// @dev Transfer an amount of the specified token from the controller to the sender.
    /// @dev Token balance are never meant to exist in the controller, this is purely a safeguard.
    function inCaseTokensGetStuck(address _token, uint256 _amount) public {
        _onlyGovernanceOrStrategist();
        IERC20Upgradeable(_token).safeTransfer(msg.sender, _amount);
    }

    /// @dev Transfer an amount of the specified token from the controller to the sender.
    /// @dev Token balance are never meant to exist in the controller, this is purely a safeguard.
    function inCaseStrategyTokenGetStuck(address _strategy, address _token) public {
        _onlyGovernanceOrStrategist();
        IStrategy(_strategy).withdrawOther(_token);
    }

    // ==== Permissioned Actions: Only Approved Actors =====

    /// @notice Deposit given token to strategy, converting it to the strategies' want first (if required).
    /// @dev Only the associated vault, or permissioned actors can call this function (keeper, strategist, governance)
    /// @param _token Token to deposit (will be converted to want by converter). If no converter is registered, the transaction will revert.
    /// @param _amount Amount of token to deposit
    function earn(address _token, uint256 _amount) public {
        address _strategy = strategies[_token];
        address _want = IStrategy(_strategy).want();

        _onlyApprovedForWant(_want);

        if (_want != _token) {
            address converter = converters[_token][_want];
            IERC20Upgradeable(_token).safeTransfer(converter, _amount);
            _amount = IConverter(converter).convert(_strategy);
            IERC20Upgradeable(_want).safeTransfer(_strategy, _amount);
        } else {
            IERC20Upgradeable(_token).safeTransfer(_strategy, _amount);
        }
        IStrategy(_strategy).deposit();
    }

    // ===== Permissioned Actions: Only Associated Vault =====

    /// @notice Wtihdraw a given token from it's corresponding strategy
    /// @notice Only the associated vault can call, in response to a user withdrawal request
    function withdraw(address _token, uint256 _amount) public {
        require(msg.sender == vaults[_token], "!vault");
        IStrategy(strategies[_token]).withdraw(_amount);
    }
}