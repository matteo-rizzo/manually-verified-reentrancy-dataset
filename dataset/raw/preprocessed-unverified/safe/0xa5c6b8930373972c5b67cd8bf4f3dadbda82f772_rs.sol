/**
 *Submitted for verification at Etherscan.io on 2021-02-19
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
// Dependency file: @openzeppelin/contracts/GSN/Context.sol

// SPDX-License-Identifier: MIT

// pragma solidity ^0.6.0;

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


// Dependency file: contracts/truefi/common/Initializable.sol

// Copied from https://github.com/OpenZeppelin/openzeppelin-contracts-ethereum-package/blob/v3.0.0/contracts/Initializable.sol

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

    // Reserved storage space to allow for layout changes in the future.
    uint256[50] private ______gap;
}


// Dependency file: contracts/truefi/common/UpgradeableOwnable.sol

// pragma solidity 0.6.10;

// import {Context} from "@openzeppelin/contracts/GSN/Context.sol";

// import {Initializable} from "contracts/truefi/common/Initializable.sol";

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
contract Ownable is Initializable, Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    function initialize() internal initializer {
        address msgSender = _msgSender();
        _owner = msgSender;
        emit OwnershipTransferred(address(0), msgSender);
    }

    /**
     * @dev Returns the address of the current owner.
     */
    function owner() public view returns (address) {
        return _owner;
    }

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        require(_owner == _msgSender(), "Ownable: caller is not the owner");
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
}


// Dependency file: @openzeppelin/contracts/token/ERC20/IERC20.sol


// pragma solidity ^0.6.0;

/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
 */



// Dependency file: contracts/truefi/interface/ILoanToken.sol

// pragma solidity 0.6.10;

// import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";

interface ILoanToken is IERC20 {
    enum Status {Awaiting, Funded, Withdrawn, Settled, Defaulted, Liquidated}

    function borrower() external view returns (address);

    function amount() external view returns (uint256);

    function term() external view returns (uint256);

    function apy() external view returns (uint256);

    function start() external view returns (uint256);

    function lender() external view returns (address);

    function debt() external view returns (uint256);

    function profit() external view returns (uint256);

    function status() external view returns (Status);

    function borrowerFee() external view returns (uint256);

    function receivedAmount() external view returns (uint256);

    function isLoanToken() external pure returns (bool);

    function getParameters()
        external
        view
        returns (
            uint256,
            uint256,
            uint256
        );

    function fund() external;

    function withdraw(address _beneficiary) external;

    function close() external;

    function liquidate() external;

    function redeem(uint256 _amount) external;

    function repay(address _sender, uint256 _amount) external;

    function reclaim() external;

    function allowTransfer(address account, bool _status) external;

    function repaid() external view returns (uint256);

    function balance() external view returns (uint256);

    function value(uint256 _balance) external view returns (uint256);

    function currencyToken() external view returns (IERC20);

    function version() external pure returns (uint8);
}


// Dependency file: contracts/truefi/interface/ITrueFiPool.sol

// pragma solidity 0.6.10;

// import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";

/**
 * TruePool is an ERC20 which represents a share of a pool
 *
 * This contract can be used to wrap opportunities to be compatible
 * with TrueFi and allow users to directly opt-in through the TUSD contract
 *
 * Each TruePool is also a staking opportunity for TRU
 */
interface ITrueFiPool is IERC20 {
    /// @dev pool token (TUSD)
    function currencyToken() external view returns (IERC20);

    /// @dev stake token (TRU)
    function stakeToken() external view returns (IERC20);

    /**
     * @dev join pool
     * 1. Transfer TUSD from sender
     * 2. Mint pool tokens based on value to sender
     */
    function join(uint256 amount) external;

    /**
     * @dev exit pool
     * 1. Transfer pool tokens from sender
     * 2. Burn pool tokens
     * 3. Transfer value of pool tokens in TUSD to sender
     */
    function exit(uint256 amount) external;

    /**
     * @dev borrow from pool
     * 1. Transfer TUSD to sender
     * 2. Only lending pool should be allowed to call this
     */
    function borrow(uint256 amount, uint256 fee) external;

    /**
     * @dev join pool
     * 1. Transfer TUSD from sender
     * 2. Only lending pool should be allowed to call this
     */
    function repay(uint256 amount) external;
}


// Dependency file: contracts/truefi/interface/IStakingPool.sol

// pragma solidity 0.6.10;

// import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";

interface IStakingPool is IERC20 {
    function stakeSupply() external view returns (uint256);

    function withdraw(uint256 amount) external;

    function payFee(uint256 amount, uint256 endTime) external;
}


// Dependency file: contracts/truefi/interface/ITruPriceOracle.sol

// pragma solidity 0.6.10;




// Dependency file: contracts/truefi/interface/ILoanFactory.sol

// pragma solidity 0.6.10;




// Dependency file: @openzeppelin/contracts/math/SafeMath.sol


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



// Root file: contracts/truefi/Liquidator.sol

pragma solidity 0.6.10;

// import {Ownable} from "contracts/truefi/common/UpgradeableOwnable.sol";
// import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";

// import {ILoanToken} from "contracts/truefi/interface/ILoanToken.sol";
// import {ITrueFiPool} from "contracts/truefi/interface/ITrueFiPool.sol";
// import {IStakingPool} from "contracts/truefi/interface/IStakingPool.sol";
// import {ITruPriceOracle} from "contracts/truefi/interface/ITruPriceOracle.sol";
// import {ILoanFactory} from "contracts/truefi/interface/ILoanFactory.sol";
// import {SafeMath} from "@openzeppelin/contracts/math/SafeMath.sol";

/**
 * @title Liquidator
 * @notice Liquidate LoanTokens with this Contract
 * @dev When a Loan becomes defaulted, Liquidator allows to
 * compensate pool participants, by transfering some of TRU to the pool
 */
contract Liquidator is Ownable {
    using SafeMath for uint256;

    // ================ WARNING ==================
    // ===== THIS CONTRACT IS INITIALIZABLE ======
    // === STORAGE VARIABLES ARE DECLARED BELOW ==
    // REMOVAL OR REORDER OF VARIABLES WILL RESULT
    // ========= IN STORAGE CORRUPTION ===========

    ITrueFiPool public pool;
    IStakingPool public stkTru;
    IERC20 public tru;
    ITruPriceOracle public oracle;
    ILoanFactory public factory;

    // max share of tru to be taken from staking pool during liquidation
    // 1000 -> 10%
    uint256 public fetchMaxShare;

    // ======= STORAGE DECLARATION END ============

    /**
     * @dev Emitted fetch max share is changed
     * @param newShare New share set
     */
    event FetchMaxShareChanged(uint256 newShare);

    /**
     * @dev Emitted when oracle is changed
     * @param newOracle New oracle address
     */
    event OracleChanged(ITruPriceOracle newOracle);

    /**
     * @dev Emitted when a loan gets liquidated
     * @param loan Loan that has been liquidated
     */
    event Liquidated(ILoanToken loan);

    /**
     * @dev Initialize this contract
     */
    function initialize(
        ITrueFiPool _pool,
        IStakingPool _stkTru,
        IERC20 _tru,
        ITruPriceOracle _oracle,
        ILoanFactory _factory
    ) public initializer {
        Ownable.initialize();

        pool = _pool;
        stkTru = _stkTru;
        tru = _tru;
        oracle = _oracle;
        factory = _factory;
        fetchMaxShare = 1000;
    }

    /**
     * @dev Set new max fetch share
     * @param newShare New share to be set
     */
    function setFetchMaxShare(uint256 newShare) external onlyOwner {
        require(newShare > 0, "Liquidator: Share cannot be set to 0");
        require(newShare <= 10000, "Liquidator: Share cannot be larger than 10000");
        fetchMaxShare = newShare;
        emit FetchMaxShareChanged(newShare);
    }

    /**
     * @dev Change oracle
     * @param newOracle New oracle for liquidator
     */
    function setOracle(ITruPriceOracle newOracle) external onlyOwner {
        // Check if new oracle implements method
        require(newOracle.usdToTru(1 ether) > 0, "Liquidator: Oracle lacks usdToTru method");

        oracle = newOracle;

        emit OracleChanged(newOracle);
    }

    /**
     * @dev Liquidates a defaulted Loan, withdraws a portion of tru from staking pool
     * then transfers tru to TrueFiPool as compensation
     * @param loan Loan to be liquidated
     */
    function liquidate(ILoanToken loan) external {
        require(factory.isLoanToken(address(loan)), "Liquidator: Unknown loan");
        uint256 defaultedValue = getAmountToWithdraw(loan.debt().sub(loan.repaid()));
        stkTru.withdraw(defaultedValue);
        require(loan.status() == ILoanToken.Status.Defaulted, "Liquidator: Loan must be defaulted");
        loan.liquidate();
        require(tru.transfer(address(pool), defaultedValue));
        emit Liquidated(loan);
    }

    /**
     * @dev Calculate amount of tru to be withdrawn from staking pool (not more than preset share)
     * @param deficit Amount of tusd lost on defaulted loan
     * @return amount of TRU to be withdrawn on liquidation
     */
    function getAmountToWithdraw(uint256 deficit) internal view returns (uint256) {
        uint256 stakingPoolSupply = stkTru.stakeSupply();
        uint256 maxWithdrawValue = stakingPoolSupply.mul(fetchMaxShare).div(10000);
        uint256 deficitInTru = oracle.usdToTru(deficit);
        return maxWithdrawValue > deficitInTru ? deficitInTru : maxWithdrawValue;
    }
}