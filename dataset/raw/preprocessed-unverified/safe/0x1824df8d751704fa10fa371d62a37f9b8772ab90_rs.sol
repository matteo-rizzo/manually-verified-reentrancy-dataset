/**
 *Submitted for verification at Etherscan.io on 2021-02-19
*/

// SPDX-License-Identifier: AGPL-3.0

pragma solidity 0.6.12;



// Part: Governable

contract Governable {
    address public governance;
    address public pendingGovernance;

    constructor(address _governance) public {
        require(
            _governance != address(0),
            "governable::should-not-be-zero-address"
        );
        governance = _governance;
    }

    function setPendingGovernance(address _pendingGovernance)
        external
        onlyGovernance
    {
        pendingGovernance = _pendingGovernance;
    }

    function acceptGovernance() external onlyPendingGovernance {
        governance = msg.sender;
        pendingGovernance = address(0);
    }

    modifier onlyGovernance {
        require(msg.sender == governance, "governable::only-governance");
        _;
    }

    modifier onlyPendingGovernance {
        require(
            msg.sender == pendingGovernance,
            "governable::only-pending-governance"
        );
        _;
    }
}

// Part: IRegistry



// Part: IVaultMigrator



// Part: OpenZeppelin/[email protected]0/Address

/**
 * @dev Collection of functions related to the address type
 */


// Part: OpenZeppelin/[email protected]/IERC20

/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
 */


// Part: OpenZeppelin/[email protected]/SafeMath

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


// Part: IChiToken

interface IChiToken is IERC20 {
    function mint(uint256 value) external;

    function computeAddress2(uint256 salt) external view returns (address);

    function free(uint256 value) external returns (uint256);

    function freeUpTo(uint256 value) external returns (uint256);

    function freeFrom(address from, uint256 value) external returns (uint256);

    function freeFromUpTo(address from, uint256 value)
        external
        returns (uint256);
}

// Part: ITrustedVaultMigrator

/**

Based on https://github.com/emilianobonassi/yearn-vaults-swap

 */

interface ITrustedVaultMigrator is IVaultMigrator {
    function registry() external returns (address);

    function sweep(address _token) external;

    function setRegistry(address _registry) external;
}

// Part: IVaultAPI

interface IVaultAPI is IERC20 {
    function deposit(uint256 _amount, address recipient)
        external
        returns (uint256 shares);

    function withdraw(uint256 _shares) external;

    function token() external view returns (address);

    function permit(
        address owner,
        address spender,
        uint256 value,
        uint256 deadline,
        bytes calldata signature
    ) external returns (bool);
}

// Part: OpenZeppelin/[email protected]/SafeERC20

/**
 * @title SafeERC20
 * @dev Wrappers around ERC20 operations that throw on failure (when the token
 * contract returns false). Tokens that return no value (and instead revert or
 * throw on failure) are also supported, non-reverting calls are assumed to be
 * successful.
 * To use this library you can add a `using SafeERC20 for IERC20;` statement to your contract,
 * which allows you to call the safe operations as `token.safeTransfer(...)`, etc.
 */


// Part: IGasBenefactor



// Part: VaultMigrator

contract VaultMigrator is IVaultMigrator {
    using SafeMath for uint256;
    using SafeERC20 for IERC20;
    using SafeERC20 for IVaultAPI;

    modifier onlyCompatibleVaults(address vaultA, address vaultB) {
        require(
            IVaultAPI(vaultA).token() == IVaultAPI(vaultB).token(),
            "Vaults must have the same token"
        );
        _;
    }

    function migrateAll(address vaultFrom, address vaultTo) external override {
        _migrate(
            vaultFrom,
            vaultTo,
            IVaultAPI(vaultFrom).balanceOf(msg.sender)
        );
    }

    function migrateAllWithPermit(
        address vaultFrom,
        address vaultTo,
        uint256 deadline,
        bytes calldata signature
    ) external override {
        uint256 shares = IVaultAPI(vaultFrom).balanceOf(msg.sender);

        _permit(vaultFrom, shares, deadline, signature);
        _migrate(vaultFrom, vaultTo, shares);
    }

    function migrateShares(
        address vaultFrom,
        address vaultTo,
        uint256 shares
    ) external override {
        _migrate(vaultFrom, vaultTo, shares);
    }

    function migrateSharesWithPermit(
        address vaultFrom,
        address vaultTo,
        uint256 shares,
        uint256 deadline,
        bytes calldata signature
    ) external override {
        _permit(vaultFrom, shares, deadline, signature);
        _migrate(vaultFrom, vaultTo, shares);
    }

    function _permit(
        address vault,
        uint256 value,
        uint256 deadline,
        bytes calldata signature
    ) internal {
        require(
            IVaultAPI(vault).permit(
                msg.sender,
                address(this),
                value,
                deadline,
                signature
            ),
            "Unable to permit on vault"
        );
    }

    function _migrate(
        address vaultFrom,
        address vaultTo,
        uint256 shares
    ) internal virtual onlyCompatibleVaults(vaultFrom, vaultTo) {
        // Transfer in vaultFrom shares
        IVaultAPI vf = IVaultAPI(vaultFrom);

        uint256 preBalanceVaultFrom = vf.balanceOf(address(this));

        vf.safeTransferFrom(msg.sender, address(this), shares);

        uint256 balanceVaultFrom =
            vf.balanceOf(address(this)).sub(preBalanceVaultFrom);

        // Withdraw token from vaultFrom
        IERC20 token = IERC20(vf.token());

        uint256 preBalanceToken = token.balanceOf(address(this));

        vf.withdraw(balanceVaultFrom);

        uint256 balanceToken =
            token.balanceOf(address(this)).sub(preBalanceToken);

        // Deposit new vault
        token.safeIncreaseAllowance(vaultTo, balanceToken);

        IVaultAPI(vaultTo).deposit(balanceToken, msg.sender);
    }
}

// Part: GasBenefactor

abstract contract GasBenefactor is IGasBenefactor {
    using SafeERC20 for IChiToken;

    IChiToken public override chiToken;

    constructor(IChiToken _chiToken) public {
        _setChiToken(_chiToken);
    }

    modifier subsidizeUserTx {
        uint256 _gasStart = gasleft();
        _;
        // NOTE: Per EIP-2028, gas cost is 16 per (non-empty) byte in calldata
        uint256 _gasSpent =
            21000 + _gasStart - gasleft() + 16 * msg.data.length;
        // NOTE: 41947 is the estimated amount of gas refund realized per CHI redeemed
        // NOTE: 14154 is the estimated cost of the call to `freeFromUpTo`
        chiToken.freeUpTo((_gasSpent + 14154) / 41947);
    }

    modifier discountUserTx {
        uint256 _gasStart = gasleft();
        _;
        // NOTE: Per EIP-2028, gas cost is 16 per (non-empty) byte in calldata
        uint256 _gasSpent =
            21000 + _gasStart - gasleft() + 16 * msg.data.length;
        // NOTE: 41947 is the estimated amount of gas refund realized per CHI redeemed
        // NOTE: 14154 is the estimated cost of the call to `freeFromUpTo`
        chiToken.freeFromUpTo(msg.sender, (_gasSpent + 14154) / 41947);
    }

    function _subsidize(uint256 _amount) internal {
        require(_amount > 0, "GasBenefactor::_subsidize::zero-amount");
        chiToken.safeTransferFrom(msg.sender, address(this), _amount);
        emit Subsidized(_amount, msg.sender);
    }

    function _setChiToken(IChiToken _chiToken) internal {
        require(
            address(_chiToken) != address(0),
            "GasBenefactor::_setChiToken::zero-address"
        );
        chiToken = _chiToken;
        emit ChiTokenSet(_chiToken);
    }
}

// File: TrustedVaultMigrator.sol

contract TrustedVaultMigrator is
    VaultMigrator,
    Governable,
    GasBenefactor,
    ITrustedVaultMigrator
{
    address public override registry;

    modifier onlyLatestVault(address vault) {
        require(
            IRegistry(registry).latestVault(IVaultAPI(vault).token()) == vault,
            "Target vault should be the latest for token"
        );
        _;
    }

    constructor(address _registry, IChiToken _chiToken)
        public
        VaultMigrator()
        Governable(address(0xFEB4acf3df3cDEA7399794D0869ef76A6EfAff52))
        GasBenefactor(_chiToken)
    {
        require(_registry != address(0), "Registry cannot be 0");

        registry = _registry;
    }

    function _migrate(
        address vaultFrom,
        address vaultTo,
        uint256 shares
    ) internal override onlyLatestVault(vaultTo) {
        super._migrate(vaultFrom, vaultTo, shares);
    }

    function sweep(address _token) external override onlyGovernance {
        IERC20(_token).safeTransfer(
            governance,
            IERC20(_token).balanceOf(address(this))
        );
    }

    function subsidize(uint256 _amount) external override {
        _subsidize(_amount);
    }

    // setters
    function setRegistry(address _registry) external override onlyGovernance {
        require(_registry != address(0), "Registry cannot be 0");
        registry = _registry;
    }

    function setChiToken(IChiToken _chiToken) external override onlyGovernance {
        _setChiToken(_chiToken);
    }
}