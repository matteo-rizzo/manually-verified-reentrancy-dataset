/**
 *Submitted for verification at Etherscan.io on 2021-09-27
*/

/*
    .'''''''''''..     ..''''''''''''''''..       ..'''''''''''''''..
    .;;;;;;;;;;;'.   .';;;;;;;;;;;;;;;;;;,.     .,;;;;;;;;;;;;;;;;;,.
    .;;;;;;;;;;,.   .,;;;;;;;;;;;;;;;;;;;,.    .,;;;;;;;;;;;;;;;;;;,.
    .;;;;;;;;;,.   .,;;;;;;;;;;;;;;;;;;;;,.   .;;;;;;;;;;;;;;;;;;;;,.
    ';;;;;;;;'.  .';;;;;;;;;;;;;;;;;;;;;;,. .';;;;;;;;;;;;;;;;;;;;;,.
    ';;;;;,..   .';;;;;;;;;;;;;;;;;;;;;;;,..';;;;;;;;;;;;;;;;;;;;;;,.
    ......     .';;;;;;;;;;;;;,'''''''''''.,;;;;;;;;;;;;;,'''''''''..
              .,;;;;;;;;;;;;;.           .,;;;;;;;;;;;;;.
             .,;;;;;;;;;;;;,.           .,;;;;;;;;;;;;,.
            .,;;;;;;;;;;;;,.           .,;;;;;;;;;;;;,.
           .,;;;;;;;;;;;;,.           .;;;;;;;;;;;;;,.     .....
          .;;;;;;;;;;;;;'.         ..';;;;;;;;;;;;;'.    .',;;;;,'.
        .';;;;;;;;;;;;;'.         .';;;;;;;;;;;;;;'.   .';;;;;;;;;;.
       .';;;;;;;;;;;;;'.         .';;;;;;;;;;;;;;'.    .;;;;;;;;;;;,.
      .,;;;;;;;;;;;;;'...........,;;;;;;;;;;;;;;.      .;;;;;;;;;;;,.
     .,;;;;;;;;;;;;,..,;;;;;;;;;;;;;;;;;;;;;;;,.       ..;;;;;;;;;,.
    .,;;;;;;;;;;;;,. .,;;;;;;;;;;;;;;;;;;;;;;,.          .',;;;,,..
   .,;;;;;;;;;;;;,.  .,;;;;;;;;;;;;;;;;;;;;;,.              ....
    ..',;;;;;;;;,.   .,;;;;;;;;;;;;;;;;;;;;,.
       ..',;;;;'.    .,;;;;;;;;;;;;;;;;;;;'.
          ...'..     .';;;;;;;;;;;;;;,,,'.
                       ...............
*/

// https://github.com/trusttoken/smart-contracts
// Dependency file: @openzeppelin/contracts/math/SafeMath.sol

// SPDX-License-Identifier: MIT

// pragma solidity >=0.6.0 <0.8.0;

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



// Dependency file: @openzeppelin/contracts/token/ERC20/IERC20.sol


// pragma solidity >=0.6.0 <0.8.0;

/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
 */



// Dependency file: contracts/governance/interface/IVoteToken.sol

// pragma solidity ^0.6.10;

// import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";



interface IVoteTokenWithERC20 is IVoteToken, IERC20 {}


// Dependency file: contracts/governance/interface/IStkTruToken.sol

// pragma solidity 0.6.10;

// import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
// import {IVoteToken} from "contracts/governance/interface/IVoteToken.sol";

interface IStkTruToken is IERC20, IVoteToken {
    function stake(uint256 amount) external;

    function unstake(uint256 amount) external;

    function cooldown() external;

    function withdraw(uint256 amount) external;

    function claim() external;

    function claimRewards(IERC20 token) external;

    function claimRestake(uint256 extraStakeAmount) external;

    function stakeSupply() external view returns (uint256);

    function tfusd() external view returns (IERC20);

    function feeToken() external view returns (IERC20);
}


// Dependency file: @openzeppelin/contracts/utils/Address.sol


// pragma solidity >=0.6.2 <0.8.0;

/**
 * @dev Collection of functions related to the address type
 */



// Dependency file: @openzeppelin/contracts/token/ERC20/SafeERC20.sol


// pragma solidity >=0.6.0 <0.8.0;

// import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
// import "@openzeppelin/contracts/math/SafeMath.sol";
// import "@openzeppelin/contracts/utils/Address.sol";

/**
 * @title SafeERC20
 * @dev Wrappers around ERC20 operations that throw on failure (when the token
 * contract returns false). Tokens that return no value (and instead revert or
 * throw on failure) are also supported, non-reverting calls are assumed to be
 * successful.
 * To use this library you can add a `using SafeERC20 for IERC20;` statement to your contract,
 * which allows you to call the safe operations as `token.safeTransfer(...)`, etc.
 */



// Dependency file: @openzeppelin/contracts/utils/Context.sol


// pragma solidity >=0.6.0 <0.8.0;

/*
 * @dev Provides information about the current execution context, including the
 * sender of the transaction and its data. While these are generally available
 * via msg.sender and msg.data, they should not be accessed in such a direct
 * manner, since when dealing with GSN meta-transactions the account sending and
 * paying for execution may not be the actual sender (as far as an application
 * is concerned).
 *
 * This contract is only required for intermediate, library-like contracts.
 */
abstract contract Context {
    function _msgSender() internal view virtual returns (address payable) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes memory) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}


// Dependency file: @openzeppelin/contracts/GSN/Context.sol


// pragma solidity >=0.6.0 <0.8.0;

// import "@openzeppelin/contracts/utils/Context.sol";


// Dependency file: contracts/common/Initializable.sol

// Copied from https://github.com/OpenZeppelin/openzeppelin-contracts-ethereum-package/blob/v3.0.0/contracts/Initializable.sol
// Added public isInitialized() view of private initialized bool.

// pragma solidity 0.6.10;

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
        assembly {
            cs := extcodesize(self)
        }
        return cs == 0;
    }

    /**
     * @dev Return true if and only if the contract has been initialized
     * @return whether the contract has been initialized
     */
    function isInitialized() public view returns (bool) {
        return initialized;
    }

    // Reserved storage space to allow for layout changes in the future.
    uint256[50] private ______gap;
}


// Dependency file: contracts/common/UpgradeableClaimable.sol

// pragma solidity 0.6.10;

// import {Context} from "@openzeppelin/contracts/GSN/Context.sol";

// import {Initializable} from "contracts/common/Initializable.sol";

/**
 * @title UpgradeableClaimable
 * @dev Contract module which provides a basic access control mechanism, where
 * there is an account (an owner) that can be granted exclusive access to
 * specific functions.
 *
 * By default, the owner account will be the one that deploys the contract. Since
 * this contract combines Claimable and UpgradableOwnable contracts, ownership
 * can be later change via 2 step method {transferOwnership} and {claimOwnership}
 *
 * This module is used through inheritance. It will make available the modifier
 * `onlyOwner`, which can be applied to your functions to restrict their use to
 * the owner.
 */
contract UpgradeableClaimable is Initializable, Context {
    address private _owner;
    address private _pendingOwner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev Initializes the contract setting a custom initial owner of choice.
     * @param __owner Initial owner of contract to be set.
     */
    function initialize(address __owner) internal initializer {
        _owner = __owner;
        emit OwnershipTransferred(address(0), __owner);
    }

    /**
     * @dev Returns the address of the current owner.
     */
    function owner() public view returns (address) {
        return _owner;
    }

    /**
     * @dev Returns the address of the pending owner.
     */
    function pendingOwner() public view returns (address) {
        return _pendingOwner;
    }

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        require(_owner == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    /**
     * @dev Modifier throws if called by any account other than the pendingOwner.
     */
    modifier onlyPendingOwner() {
        require(msg.sender == _pendingOwner, "Ownable: caller is not the pending owner");
        _;
    }

    /**
     * @dev Allows the current owner to set the pendingOwner address.
     * @param newOwner The address to transfer ownership to.
     */
    function transferOwnership(address newOwner) public onlyOwner {
        _pendingOwner = newOwner;
    }

    /**
     * @dev Allows the pendingOwner address to finalize the transfer.
     */
    function claimOwnership() public onlyPendingOwner {
        emit OwnershipTransferred(_owner, _pendingOwner);
        _owner = _pendingOwner;
        _pendingOwner = address(0);
    }
}


// Root file: contracts/governance/TrueFiVault.sol

pragma solidity 0.6.10;

// import {SafeMath} from "@openzeppelin/contracts/math/SafeMath.sol";
// import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
// import {IVoteTokenWithERC20} from "contracts/governance/interface/IVoteToken.sol";
// import {IStkTruToken} from "contracts/governance/interface/IStkTruToken.sol";
// import {SafeERC20} from "@openzeppelin/contracts/token/ERC20/SafeERC20.sol";
// import {UpgradeableClaimable} from "contracts/common/UpgradeableClaimable.sol";

/**
 * @title TrueFiVault
 * @dev Vault for granting TRU tokens from owner to beneficiary after a lockout period.
 *
 * After the lockout period, beneficiary may withdraw any TRU in the vault.
 * During the lockout period, the vault still allows beneficiary to stake TRU
 * and cast votes in governance.
 *
 */
contract TrueFiVault is UpgradeableClaimable {
    using SafeMath for uint256;
    using SafeERC20 for IERC20;
    using SafeERC20 for IVoteTokenWithERC20;

    uint256 public constant DURATION = 365 days;

    address public beneficiary;
    uint256 public expiry;
    uint256 public withdrawn;

    IVoteTokenWithERC20 public tru;
    IStkTruToken public stkTru;

    event Withdraw(IERC20 token, uint256 amount, address beneficiary);

    function initialize(
        address _beneficiary,
        uint256 _amount,
        IVoteTokenWithERC20 _tru,
        IStkTruToken _stkTru
    ) external initializer {
        UpgradeableClaimable.initialize(msg.sender);

        beneficiary = _beneficiary;
        expiry = block.timestamp.add(DURATION);
        tru = _tru;
        stkTru = _stkTru;

        // TODO Uncomment after TRU is updated to support voting
        //        tru.delegate(beneficiary);
        stkTru.delegate(beneficiary);

        // transfer from sender
        tru.safeTransferFrom(msg.sender, address(this), _amount);
    }

    /**
     * @dev Throws if called by any account other than the beneficiary.
     */
    modifier onlyBeneficiary() {
        require(msg.sender == beneficiary, "TrueFiVault: only beneficiary");
        _;
    }

    function withdrawable(IERC20 token) public view returns (uint256) {
        uint256 tokenBalance = token.balanceOf(address(this));
        uint256 timePassed = block.timestamp.sub(expiry.sub(DURATION));
        if (timePassed > DURATION) {
            timePassed = DURATION;
        }
        uint256 amount = totalBalance().add(withdrawn).mul(timePassed).div(DURATION).sub(withdrawn);
        if (token == stkTru) {
            amount = amount.mul(stkTru.totalSupply()).div(stkTru.stakeSupply());
        }
        return amount > tokenBalance ? tokenBalance : amount;
    }

    /**
     * @dev Withdraw vested TRU to beneficiary
     */
    function withdrawTru(uint256 amount) external onlyBeneficiary {
        claimRewards();
        require(amount <= withdrawable(tru), "TrueFiVault: attempting to withdraw more than allowed");
        withdrawn = withdrawn.add(amount);
        _withdraw(tru, amount);
    }

    /**
     * @dev Withdraw vested stkTRU to beneficiary
     */
    function withdrawStkTru(uint256 amount) external onlyBeneficiary {
        require(amount <= withdrawable(stkTru), "TrueFiVault: attempting to withdraw more than allowed");
        withdrawn = withdrawn.add(amount.mul(stkTru.stakeSupply()).div(stkTru.totalSupply()));
        _withdraw(stkTru, amount);
    }

    /**
     * @dev Withdraw all funds to beneficiary after expiry time
     */
    function withdrawToBeneficiary() external onlyBeneficiary {
        uint256 timePassed = block.timestamp.sub(expiry.sub(DURATION));
        require(timePassed >= DURATION, "TrueFiVault: vault is not expired yet");
        claimRewards();
        _withdraw(tru, tru.balanceOf(address(this)));
        _withdraw(stkTru, stkTru.balanceOf(address(this)));
    }

    function _withdraw(IERC20 token, uint256 amount) private {
        token.safeTransfer(beneficiary, amount);
        emit Withdraw(token, amount, beneficiary);
    }

    /**
     * @dev Stake `amount` TRU in staking contract
     * @param amount Amount of TRU to stake
     */
    function stake(uint256 amount) external onlyBeneficiary {
        tru.safeApprove(address(stkTru), amount);
        stkTru.stake(amount);
    }

    /**
     * @dev unstake `amount` TRU in staking contract
     * @param amount Amount of TRU to unstake
     */
    function unstake(uint256 amount) external onlyBeneficiary {
        stkTru.unstake(amount);
    }

    /**
     * @dev Initiate cooldown for staked TRU
     */
    function cooldown() external onlyBeneficiary {
        stkTru.cooldown();
    }

    /**
     * @dev Claim TRU rewards from staking contract
     */
    function claimRewards() public onlyBeneficiary {
        stkTru.claimRewards(tru);
    }

    /**
     * @dev Claim TRU rewards, then restake without transferring
     * Allows account to save more gas by avoiding out-and-back transfers
     */
    function claimRestake() external onlyBeneficiary {
        stkTru.claimRestake(0);
    }

    /**
     * @dev Delegate tru+stkTRU voting power to another address
     * @param delegatee Address to delegate to
     */
    function delegate(address delegatee) external onlyBeneficiary {
        tru.delegate(delegatee);
        stkTru.delegate(delegatee);
    }

    /**
     * @dev Claim rewards in tfTUSD and feeToken from stake and transfer to the beneficiary
     */
    function claimFeeRewards() external onlyBeneficiary {
        stkTru.claim();
        IERC20 tfTUSD = stkTru.tfusd();
        tfTUSD.safeTransfer(beneficiary, tfTUSD.balanceOf(address(this)));
        IERC20 feeToken = stkTru.feeToken();
        feeToken.safeTransfer(beneficiary, feeToken.balanceOf(address(this)));
    }

    function totalBalance() public view returns (uint256) {
        uint256 normalizedStkTruBalance = stkTru.balanceOf(address(this)).mul(stkTru.stakeSupply()).div(stkTru.totalSupply());
        return tru.balanceOf(address(this)).add(normalizedStkTruBalance);
    }
}