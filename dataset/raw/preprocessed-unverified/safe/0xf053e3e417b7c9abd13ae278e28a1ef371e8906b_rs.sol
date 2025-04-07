/**
 *Submitted for verification at Etherscan.io on 2021-06-16
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



// Dependency file: @openzeppelin/contracts/token/ERC20/IERC20.sol


// pragma solidity ^0.6.0;

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


// Dependency file: @openzeppelin/contracts/utils/Address.sol


// pragma solidity ^0.6.2;

/**
 * @dev Collection of functions related to the address type
 */



// Dependency file: @openzeppelin/contracts/token/ERC20/SafeERC20.sol


// pragma solidity ^0.6.0;

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



// Root file: contracts/governance/TrueFiVault.sol

pragma solidity 0.6.10;

// import {SafeMath} from "@openzeppelin/contracts/math/SafeMath.sol";
// import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
// import {IVoteTokenWithERC20} from "contracts/governance/interface/IVoteToken.sol";
// import {IStkTruToken} from "contracts/governance/interface/IStkTruToken.sol";
// import {Initializable} from "contracts/common/Initializable.sol";
// import {SafeERC20} from "@openzeppelin/contracts/token/ERC20/SafeERC20.sol";

/**
 * @title TrueFiVault
 * @dev Vault for granting TRU tokens from owner to beneficiary after a lockout period.
 *
 * After the lockout period, beneficiary may withdraw any TRU in the vault.
 * During the lockout period, the vault still allows beneficiary to stake TRU
 * and cast votes in governance.
 *
 */
contract TrueFiVault is Initializable {
    using SafeMath for uint256;
    using SafeERC20 for IERC20;
    using SafeERC20 for IVoteTokenWithERC20;

    uint256 public constant DURATION = 365 days;

    address public owner;
    address public beneficiary;
    uint256 public expiry;
    uint256 public withdrawn;

    IVoteTokenWithERC20 public tru;
    IStkTruToken public stkTru;

    event Withdraw(IERC20 token, uint256 amount, address beneficiary);

    function initialize(
        address _beneficiary,
        address _finalOwner,
        uint256 _amount,
        uint256 _start,
        IVoteTokenWithERC20 _tru,
        IStkTruToken _stkTru
    ) external initializer {
        // Protect from accidental passing incorrect start timestamp
        require(_start >= block.timestamp, "TrueFiVault: lock start in the past");
        require(_start < block.timestamp + 90 days, "TrueFiVault: lock start too far in the future");
        owner = _finalOwner;
        beneficiary = _beneficiary;
        expiry = _start.add(DURATION);
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

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        require(msg.sender == owner, "TrueFiVault: only owner");
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
        tru.approve(address(stkTru), amount);
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