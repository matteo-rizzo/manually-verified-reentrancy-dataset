/**
 *Submitted for verification at Etherscan.io on 2020-07-01
*/

pragma solidity ^0.5.0;

/**
 * @dev Interface of the ERC20 standard as defined in the EIP. Does not include
 * the optional functions; to access them see {ERC20Detailed}.
 */


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




/**
 * @title Bonding Curve Interface
 * @dev A bonding curve is a method for continous token minting / burning.
 */
/* solhint-disable func-order */


/**
 * @title Funds Module Interface
 * @dev Funds module is responsible for token transfers, provides info about current liquidity/debts and pool token price.
 */


/**
 * @title Liquidity Module Interface
 * @dev Liquidity module is responsible for deposits, withdrawals and works with Funds module.
 */


/**
 * @title Funds Module Interface
 * @dev Funds module is responsible for deposits, withdrawals, debt proposals, debts and repay.
 */


/**
 * @title Funds Module Interface
 * @dev Funds module is responsible for deposits, withdrawals, debt proposals, debts and repay.
 */


/**
 * @title Funds Module Interface
 * @dev Funds module is responsible for deposits, withdrawals, debt proposals, debts and repay.
 */


/**
 * @title PToken Interface
 */


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
contract Context is Initializable {
    // Empty internal constructor, to prevent people from mistakenly deploying
    // an instance of this contract, which should be used via inheritance.
    constructor () internal { }
    // solhint-disable-previous-line no-empty-blocks

    function _msgSender() internal view returns (address payable) {
        return msg.sender;
    }

    function _msgData() internal view returns (bytes memory) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}

/**
 * @dev Contract module which provides a basic access control mechanism, where
 * there is an account (an owner) that can be granted exclusive access to
 * specific functions.
 *
 * This module is used through inheritance. It will make available the modifier
 * `onlyOwner`, which can be aplied to your functions to restrict their use to
 * the owner.
 */
contract Ownable is Initializable, Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    function initialize(address sender) public initializer {
        _owner = sender;
        emit OwnershipTransferred(address(0), _owner);
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
        require(isOwner(), "Ownable: caller is not the owner");
        _;
    }

    /**
     * @dev Returns true if the caller is the current owner.
     */
    function isOwner() public view returns (bool) {
        return _msgSender() == _owner;
    }

    /**
     * @dev Leaves the contract without owner. It will not be possible to call
     * `onlyOwner` functions anymore. Can only be called by the current owner.
     *
     * > Note: Renouncing ownership will leave the contract without an owner,
     * thereby removing any functionality that is only available to the owner.
     */
    function renounceOwnership() public onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) public onlyOwner {
        _transferOwnership(newOwner);
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     */
    function _transferOwnership(address newOwner) internal {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }

    uint256[50] private ______gap;
}

/**
 * Base contract for all modules
 */
contract Base is Initializable, Context, Ownable {
    address constant  ZERO_ADDRESS = address(0);

    function initialize() public initializer {
        Ownable.initialize(_msgSender());
    }

}

/**
 * @dev List of module names
 */
contract ModuleNames {
    // Pool Modules
    string public constant MODULE_ACCESS            = "access";
    string public constant MODULE_PTOKEN            = "ptoken";
    string public constant MODULE_CURVE             = "curve";
    string public constant MODULE_FUNDS             = "funds";
    string public constant MODULE_LIQUIDITY         = "liquidity";
    string public constant MODULE_LOAN              = "loan";
    string public constant MODULE_LOAN_LIMTS        = "loan_limits";
    string public constant MODULE_LOAN_PROPOSALS    = "loan_proposals";

    // External Modules (used to store addresses of external contracts)
    string public constant MODULE_LTOKEN            = "ltoken";
}

/**
 * Base contract for all modules
 */
contract Module is Base, ModuleNames {
    event PoolAddressChanged(address newPool);
    address public pool;

    function initialize(address _pool) public initializer {
        Base.initialize();
        setPool(_pool);
    }

    function setPool(address _pool) public onlyOwner {
        require(_pool != ZERO_ADDRESS, "Module: pool address can't be zero");
        pool = _pool;
        emit PoolAddressChanged(_pool);        
    }

    function getModuleAddress(string memory module) public view returns(address){
        require(pool != ZERO_ADDRESS, "Module: no pool");
        (bool success, bytes memory result) = pool.staticcall(abi.encodeWithSignature("get(string)", module));
        
        //Forward error from Pool contract
        if (!success) assembly {
            revert(add(result, 32), result)
        }

        address moduleAddress = abi.decode(result, (address));
        require(moduleAddress != ZERO_ADDRESS, "Module: requested module not found");
        return moduleAddress;
    }

}

contract LoanModule is Module, ILoanModule {
    using SafeMath for uint256;

    uint256 public constant INTEREST_MULTIPLIER = 10**3;    // Multiplier to store interest rate (decimal) in int
    uint256 public constant ANNUAL_SECONDS = 365*24*60*60+(24*60*60/4);  // Seconds in a year + 1/4 day to compensate leap years

    uint256 public constant DEBT_REPAY_DEADLINE_PERIOD = 90*24*60*60;   //Period before debt without payments may be defaulted

    uint256 public constant DEBT_LOAD_MULTIPLIER = 10**3;

    struct Debt {
        uint256 proposal;           // Index of DebtProposal in adress's proposal list
        uint256 lAmount;            // Current amount of debt (in liquid token). If 0 - debt is fully paid
        uint256 lastPayment;        // Timestamp of last interest payment (can be timestamp of last payment or a virtual date untill which interest is paid)
        uint256 pInterest;          // Amount of pTokens minted as interest for this debt
        mapping(address => uint256) claimedPledges;  //Amount of pTokens already claimed by supporter
        bool defaultExecuted;       // If debt default is already executed by executeDebtDefault()
    }

    mapping(address=>Debt[]) public debts;                 

    uint256 private lDebts;

    mapping(address=>uint256) public activeDebts;           // Counts how many active debts the address has 

    modifier operationAllowed(IAccessModule.Operation operation) {
        IAccessModule am = IAccessModule(getModuleAddress(MODULE_ACCESS));
        require(am.isOperationAllowed(operation, _msgSender()), "LoanModule: operation not allowed");
        _;
    }

    function initialize(address _pool) public initializer {
        Module.initialize(_pool);
    }

    /**
     * @notice Execute DebtProposal
     * @dev Creates Debt using data of DebtProposal
     * @param proposal Index of DebtProposal
     * @return Index of created Debt
     */
    function createDebt(address borrower, uint256 proposal, uint256 lAmount) public returns(uint256) {
        require(_msgSender() == getModuleAddress(MODULE_LOAN_PROPOSALS), "LoanModule: requests only accepted from LoanProposalsModule");
        //TODO: check there is no debt for this proposal
        debts[borrower].push(Debt({
            proposal: proposal,
            lAmount: lAmount,
            lastPayment: now,
            pInterest: 0,
            defaultExecuted: false
        }));
        uint256 debtIdx = debts[borrower].length-1; //It's important to save index before calling external contract

        uint256 maxDebts = limits().debtLoadMax().mul(fundsModule().lBalance().add(lDebts)).div(DEBT_LOAD_MULTIPLIER);

        lDebts = lDebts.add(lAmount);
        require(lDebts <= maxDebts, "LoanModule: Debt can not be created now because of debt loan limit");

        //Move locked pTokens to Funds - done in LoanProposals

        increaseActiveDebts(borrower);
        fundsModule().withdrawLTokens(borrower, lAmount);
        return debtIdx;
    }

    /**
     * @notice Repay amount of lToken and unlock pTokens
     * @param debt Index of Debt
     * @param lAmount Amount of liquid tokens to repay (it will not take more than needed for full debt repayment)
     */
    function repay(uint256 debt, uint256 lAmount) public operationAllowed(IAccessModule.Operation.Repay) {
        address borrower = _msgSender();
        Debt storage d = debts[borrower][debt];
        require(d.lAmount > 0, "LoanModule: Debt is already fully repaid"); //Or wrong debt index
        require(!_isDebtDefaultTimeReached(d), "LoanModule: debt is already defaulted");

        (, uint256 lCovered, , uint256 interest, uint256 pledgeLAmount, )
        = loanProposals().getProposalAndPledgeInfo(borrower, d.proposal, borrower);

        uint256 lInterest = calculateInterestPayment(d.lAmount, interest, d.lastPayment, now);

        uint256 actualInterest;
        if (lAmount < lInterest) {
            uint256 paidTime = now.sub(d.lastPayment).mul(lAmount).div(lInterest);
            assert(d.lastPayment + paidTime <= now);
            d.lastPayment = d.lastPayment.add(paidTime);
            actualInterest = lAmount;
        } else {
            uint256 fullRepayLAmount = d.lAmount.add(lInterest);
            if (lAmount > fullRepayLAmount) lAmount = fullRepayLAmount;

            d.lastPayment = now;
            uint256 debtReturned = lAmount.sub(lInterest);
            d.lAmount = d.lAmount.sub(debtReturned);
            lDebts = lDebts.sub(debtReturned);
            actualInterest = lInterest;
        }

        uint256 pInterest = calculatePoolEnter(actualInterest);
        d.pInterest = d.pInterest.add(pInterest);
        uint256 poolInterest = pInterest.mul(pledgeLAmount).div(lCovered);

        fundsModule().depositLTokens(borrower, lAmount); 
        fundsModule().distributePTokens(poolInterest);
        fundsModule().mintAndLockPTokens(pInterest.sub(poolInterest));

        emit Repay(_msgSender(), debt, d.lAmount, lAmount, actualInterest, pInterest, d.lastPayment);

        if (d.lAmount == 0) {
            //Debt is fully repaid
            decreaseActiveDebts(borrower);
            withdrawUnlockedPledge(borrower, debt);
        }
    }

    function repayPTK(uint256 debt, uint256 pAmount, uint256 lAmountMin) public operationAllowed(IAccessModule.Operation.Repay) {
        address borrower = _msgSender();
        Debt storage d = debts[borrower][debt];
        require(d.lAmount > 0, "LoanModule: Debt is already fully repaid"); //Or wrong debt index
        require(!_isDebtDefaultTimeReached(d), "LoanModule: debt is already defaulted");

        (, uint256 lAmount,) = fundsModule().calculatePoolExitInverse(pAmount);
        require(lAmount >= lAmountMin, "LoanModule: Minimal amount is too high");

        (uint256 actualPAmount, uint256 actualInterest, uint256 pInterest, uint256 poolInterest) 
            = repayPTK_calculateInterestAndUpdateDebt(borrower, d, lAmount);
        if (actualPAmount == 0) actualPAmount = pAmount; // Fix of stack too deep if send original pAmount to repayPTK_calculateInterestAndUpdateDebt

        liquidityModule().withdrawForRepay(borrower, actualPAmount);
        fundsModule().distributePTokens(poolInterest);
        fundsModule().mintAndLockPTokens(pInterest.sub(poolInterest));

        emit Repay(_msgSender(), debt, d.lAmount, lAmount, actualInterest, pInterest, d.lastPayment);

        if (d.lAmount == 0) {
            //Debt is fully repaid
            decreaseActiveDebts(borrower);
            withdrawUnlockedPledge(borrower, debt);
        }
    }

    function repayPTK_calculateInterestAndUpdateDebt(address borrower, Debt storage d, uint256 lAmount) private 
    returns(uint256 pAmount, uint256 actualInterest, uint256 pInterest, uint256 poolInterest){
        (, uint256 lCovered, , uint256 interest, uint256 lPledge, )
        = loanProposals().getProposalAndPledgeInfo(borrower, d.proposal, borrower);

        uint256 lInterest = calculateInterestPayment(d.lAmount, interest, d.lastPayment, now);
        if (lAmount < lInterest) {
            uint256 paidTime = now.sub(d.lastPayment).mul(lAmount).div(lInterest);
            assert(d.lastPayment + paidTime <= now);
            d.lastPayment = d.lastPayment.add(paidTime);
            actualInterest = lAmount;
        } else {
            uint256 fullRepayLAmount = d.lAmount.add(lInterest);
            if (lAmount > fullRepayLAmount) {
                lAmount = fullRepayLAmount;
                pAmount = calculatePoolExitWithFee(lAmount);
            }

            d.lastPayment = now;
            uint256 debtReturned = lAmount.sub(lInterest);
            d.lAmount = d.lAmount.sub(debtReturned);
            lDebts = lDebts.sub(debtReturned);
            actualInterest = lInterest;
        }

        //current liquidity already includes lAmount, which was never actually withdrawn, so we need to remove it here
        pInterest = calculatePoolEnter(actualInterest, lAmount); 
        d.pInterest = d.pInterest.add(pInterest);
        poolInterest = pInterest.mul(lPledge).div(lCovered);
    }

    function repayAllInterest(address borrower) public {
        require(_msgSender() == getModuleAddress(MODULE_LIQUIDITY), "LoanModule: call only allowed from LiquidityModule");
        Debt[] storage userDebts = debts[borrower];
        if (userDebts.length == 0) return;
        uint256 totalLFee;
        uint256 totalPWithdraw;
        uint256 totalPInterestToDistribute;
        uint256 totalPInterestToMint;
        uint256 activeDebtCount = 0;
        for (int256 i=int256(userDebts.length)-1; i >= 0; i--){
            Debt storage d = userDebts[uint256(i)];
            // bool isUnpaid = (d.lAmount != 0);
            // bool isDefaulted = _isDebtDefaultTimeReached(d);
            // if (isUnpaid && !isDefaulted){                      
            if ((d.lAmount != 0) && !_isDebtDefaultTimeReached(d)){ //removed isUnpaid and isDefaulted variables to preent "Stack too deep" error
                (uint256 pWithdrawn, uint256 lFee, uint256 poolInterest, uint256 pInterestToMint) 
                    = repayInterestForDebt(borrower, uint256(i), d, totalLFee);
                totalPWithdraw = totalPWithdraw.add(pWithdrawn);
                totalLFee = totalLFee.add(lFee);
                totalPInterestToDistribute = totalPInterestToDistribute.add(poolInterest);
                totalPInterestToMint = totalPInterestToMint.add(pInterestToMint);

                activeDebtCount++;
                if (activeDebtCount >= activeDebts[borrower]) break;
            }
        }
        if (totalPWithdraw > 0) {
            liquidityModule().withdrawForRepay(borrower, totalPWithdraw);
            fundsModule().distributePTokens(totalPInterestToDistribute);
            fundsModule().mintAndLockPTokens(totalPInterestToMint);
        } else {
            assert(totalPInterestToDistribute == 0);
            assert(totalPInterestToMint == 0);
        }
    }

    function repayInterestForDebt(address borrower, uint256 debt, Debt storage d, uint256 totalLFee) private 
    returns(uint256 pWithdrawn, uint256 lFee, uint256 poolInterest, uint256 pInterestToMint) {
        (, uint256 lCovered, , uint256 interest, uint256 lPledge, )
        = loanProposals().getProposalAndPledgeInfo(borrower, d.proposal, borrower);
        uint256 lInterest = calculateInterestPayment(d.lAmount, interest, d.lastPayment, now);
        pWithdrawn = calculatePoolExitWithFee(lInterest, totalLFee);
        lFee = calculateExitFee(lInterest);

        //Update debt
        d.lastPayment = now;
        //current liquidity already includes totalLFee, which was never actually withdrawn, so we need to remove it here
        uint256 pInterest = calculatePoolEnter(lInterest, lInterest.add(totalLFee)); 
        d.pInterest = d.pInterest.add(pInterest);
        poolInterest = pInterest.mul(lPledge).div(lCovered);
        pInterestToMint = pInterest.sub(poolInterest); //We substract interest that will be minted during distribution
        emitRepay(borrower, debt, d, lInterest, lInterest, pInterest);
    }

    function emitRepay(address borrower, uint256 debt, Debt storage d, uint256 lFullPaymentAmount, uint256 lInterestPaid, uint256 pInterestPaid) private {
        emit Repay(borrower, debt, d.lAmount, lFullPaymentAmount, lInterestPaid, pInterestPaid, d.lastPayment);
    }

    /**
     * @notice Allows anyone to default a debt which is behind it's repay deadline
     * @param borrower Address of borrower
     * @param debt Index of borrowers's debt
     */
    function executeDebtDefault(address borrower, uint256 debt) public operationAllowed(IAccessModule.Operation.ExecuteDebtDefault) {
        Debt storage dbt = debts[borrower][debt];
        require(dbt.lAmount > 0, "LoanModule: debt is fully repaid");
        require(!dbt.defaultExecuted, "LoanModule: default is already executed");
        require(_isDebtDefaultTimeReached(dbt), "LoanModule: not enough time passed");

        (uint256 proposalLAmount, , uint256 pCollected, , , uint256 pPledge)
        = loanProposals().getProposalAndPledgeInfo(borrower, dbt.proposal, borrower);

        withdrawDebtDefaultPayment(borrower, debt);

        uint256 pLockedBorrower = pPledge.mul(dbt.lAmount).div(proposalLAmount);
        uint256 pUnlockedBorrower = pPledge.sub(pLockedBorrower);
        uint256 pSupportersPledge = pCollected.sub(pPledge);
        uint256 pLockedSupportersPledge = pSupportersPledge.mul(dbt.lAmount).div(proposalLAmount);
        uint256 pLocked = pLockedBorrower.add(pLockedSupportersPledge);
        dbt.defaultExecuted = true;
        lDebts = lDebts.sub(dbt.lAmount);
        uint256 pExtra;
        if (pUnlockedBorrower > pLockedSupportersPledge){
            pExtra = pUnlockedBorrower - pLockedSupportersPledge;
            fundsModule().distributePTokens(pExtra);
        }
        fundsModule().burnLockedPTokens(pLocked.add(pExtra));
        decreaseActiveDebts(borrower);
        emit DebtDefaultExecuted(borrower, debt, pLocked);
    }

    /**
     * @notice Withdraw part of the pledge which is already unlocked (borrower repaid part of the debt) + interest
     * @param borrower Address of borrower
     * @param debt Index of borrowers's debt
     */
    function withdrawUnlockedPledge(address borrower, uint256 debt) public operationAllowed(IAccessModule.Operation.WithdrawUnlockedPledge) {
        (, uint256 pUnlocked, uint256 pInterest, uint256 pWithdrawn) = calculatePledgeInfo(borrower, debt, _msgSender());

        uint256 pUnlockedPlusInterest = pUnlocked.add(pInterest);
        require(pUnlockedPlusInterest > pWithdrawn, "LoanModule: nothing to withdraw");
        uint256 pAmount = pUnlockedPlusInterest.sub(pWithdrawn);

        Debt storage dbt = debts[borrower][debt];
        dbt.claimedPledges[_msgSender()] = dbt.claimedPledges[_msgSender()].add(pAmount);
        
        fundsModule().unlockAndWithdrawPTokens(_msgSender(), pAmount);
        emit UnlockedPledgeWithdraw(_msgSender(), borrower, dbt.proposal, debt, pAmount);
    }

    /**
     * @notice Calculates if default time for the debt is reached
     * @param borrower Address of borrower
     * @param debt Index of borrowers's debt
     * @return true if debt is defaulted
     */
    function isDebtDefaultTimeReached(address borrower, uint256 debt) public view returns(bool) {
        Debt storage dbt = debts[borrower][debt];
        return _isDebtDefaultTimeReached(dbt);
    }

    /**
     * @notice Calculates current pledge state
     * @param borrower Address of borrower
     * @param debt Index of borrowers's debt
     * @param supporter Address of supporter to check. If supporter == borrower, special rules applied.
     * @return current pledge state:
     *      pLocked - locked pTokens
     *      pUnlocked - unlocked pTokens (including already withdrawn)
     *      pInterest - received interest
     *      pWithdrawn - amount of already withdrawn pTokens
     */
    function calculatePledgeInfo(address borrower, uint256 debt, address supporter) public view
    returns(uint256 pLocked, uint256 pUnlocked, uint256 pInterest, uint256 pWithdrawn){
        Debt storage dbt = debts[borrower][debt];

        (uint256 proposalLAmount, uint256 lCovered, , , uint256 lPledge, uint256 pPledge)
        = loanProposals().getProposalAndPledgeInfo(borrower, dbt.proposal, supporter);

        pWithdrawn = dbt.claimedPledges[supporter];

        // DebtPledge storage dp = proposal.pledges[supporter];

        if (supporter == borrower) {
            if (dbt.lAmount == 0) {
                pLocked = 0;
                pUnlocked = pPledge;
            } else {
                pLocked = pPledge;
                pUnlocked = 0;
                if (dbt.defaultExecuted || _isDebtDefaultTimeReached(dbt)) {
                    pLocked = 0; 
                }
            }
            pInterest = 0;
        }else{
            pLocked = pPledge.mul(dbt.lAmount).div(proposalLAmount);
            assert(pLocked <= pPledge);
            pUnlocked = pPledge.sub(pLocked);
            pInterest = dbt.pInterest.mul(lPledge).div(lCovered);
            assert(pInterest <= dbt.pInterest);
            if (dbt.defaultExecuted || _isDebtDefaultTimeReached(dbt)) {
                (pLocked, pUnlocked) = calculatePledgeInfoForDefault(borrower, dbt, proposalLAmount, lCovered, lPledge, pLocked, pUnlocked);
            }
        }
    }

    function calculatePledgeInfoForDefault(
        address borrower, Debt storage dbt, uint256 proposalLAmount, uint256 lCovered, uint256 lPledge, 
        uint256 pLocked, uint256 pUnlocked) private view
    returns(uint256, uint256){
        (, , , , uint256 bpledgeLAmount, uint256 bpledgePAmount) = loanProposals().getProposalAndPledgeInfo(borrower, dbt.proposal, borrower);
        uint256 pLockedBorrower = bpledgePAmount.mul(dbt.lAmount).div(proposalLAmount);
        uint256 pUnlockedBorrower = bpledgePAmount.sub(pLockedBorrower);
        uint256 pCompensation = pUnlockedBorrower.mul(lPledge).div(lCovered.sub(bpledgeLAmount));
        if (pCompensation > pLocked) {
            pCompensation = pLocked;
        }
        if (dbt.defaultExecuted) {
            pLocked = 0;
            pUnlocked = pUnlocked.add(pCompensation);
        }else {
            pLocked = pCompensation;
        }
        return (pLocked, pUnlocked);
    }

    /**
     * @notice Calculates current pledge state
     * @param borrower Address of borrower
     * @param debt Index of borrowers's debt
     * @return Amount of unpaid debt, amount of interest payment
     */
    function getDebtRequiredPayments(address borrower, uint256 debt) public view returns(uint256, uint256) {
        Debt storage d = debts[borrower][debt];
        if (d.lAmount == 0) {
            return (0, 0);
        }
        uint256 interestRate = loanProposals().getProposalInterestRate(borrower, d.proposal);

        uint256 interest = calculateInterestPayment(d.lAmount, interestRate, d.lastPayment, now);
        return (d.lAmount, interest);
    }

    /**
     * @notice Check if user has active debts
     * @param borrower Address to check
     * @return True if borrower has unpaid debts
     */
    function hasActiveDebts(address borrower) public view returns(bool) {
        return activeDebts[borrower] > 0;
    }

    /**
     * @notice Calculates unpaid interest on all actve debts of the borrower
     * @dev This function may use a lot of gas, so it is not recommended to call it in the context of transaction. Use payAllInterest() instead.
     * @param borrower Address of borrower
     * @return summ of interest payments on all unpaid debts, summ of all interest payments per second
     */
    function getUnpaidInterest(address borrower) public view returns(uint256 totalLInterest, uint256 totalLInterestPerSecond){
        Debt[] storage userDebts = debts[borrower];
        if (userDebts.length == 0) return (0, 0);
        uint256 activeDebtCount;
        for (int256 i=int256(userDebts.length)-1; i >= 0; i--){
            Debt storage d = userDebts[uint256(i)];
            bool isUnpaid = (d.lAmount != 0);
            bool isDefaulted = _isDebtDefaultTimeReached(d);
            if (isUnpaid && !isDefaulted){
                uint256 interestRate = loanProposals().getProposalInterestRate(borrower, d.proposal);
                uint256 lInterest = calculateInterestPayment(d.lAmount, interestRate, d.lastPayment, now);
                uint256 lInterestPerSecond = lInterest.div(now.sub(d.lastPayment));
                totalLInterest = totalLInterest.add(lInterest);
                totalLInterestPerSecond = totalLInterestPerSecond.add(lInterestPerSecond);

                activeDebtCount++;
                if (activeDebtCount >= activeDebts[borrower]) break;
            }
        }
    }

    /**
     * @notice Total amount of debts
     * @return Sum of all liquid token in debts
     */
    function totalLDebts() public view returns(uint256){
        return lDebts;
    }

    /**
     * @notice Calculates interest amount for a debt
     * @param debtLAmount Current amount of debt
     * @param interest Annual interest rate multiplied by INTEREST_MULTIPLIER
     * @param prevPayment Timestamp of previous payment
     * @param currentPayment Timestamp of current payment
     */
    function calculateInterestPayment(uint256 debtLAmount, uint256 interest, uint256 prevPayment, uint currentPayment) public pure returns(uint256){
        require(prevPayment <= currentPayment, "LoanModule: prevPayment should be before currentPayment");
        uint256 annualInterest = debtLAmount.mul(interest).div(INTEREST_MULTIPLIER);
        uint256 time = currentPayment.sub(prevPayment);
        return time.mul(annualInterest).div(ANNUAL_SECONDS);
    }

    /**
     * @notice Calculates how many pTokens should be given to user for increasing liquidity
     * @param lAmount Amount of liquid tokens which will be put into the pool
     * @return Amount of pToken which should be sent to sender
     */
    function calculatePoolEnter(uint256 lAmount) internal view returns(uint256) {
        return fundsModule().calculatePoolEnter(lAmount);
    }

    /**
     * @notice Calculates how many pTokens should be given to user for increasing liquidity
     * @param lAmount Amount of liquid tokens which will be put into the pool
     * @param liquidityCorrection Amount of liquid tokens to remove from liquidity because it was "virtually" withdrawn
     * @return Amount of pToken which should be sent to sender
     */
    function calculatePoolEnter(uint256 lAmount, uint256 liquidityCorrection) internal view returns(uint256) {
        return fundsModule().calculatePoolEnter(lAmount, liquidityCorrection);
    }

    /**
     * @notice Calculates how many pTokens should be taken from user for decreasing liquidity
     * @param lAmount Amount of liquid tokens which will be removed from the pool
     * @return Amount of pToken which should be taken from sender
     */
    function calculatePoolExit(uint256 lAmount) internal view returns(uint256) {
        return fundsModule().calculatePoolExit(lAmount);
    }
    
    function calculatePoolExitWithFee(uint256 lAmount) internal view returns(uint256) {
        return fundsModule().calculatePoolExitWithFee(lAmount);
    }

    function calculatePoolExitWithFee(uint256 lAmount, uint256 liquidityCorrection) internal view returns(uint256) {
        return fundsModule().calculatePoolExitWithFee(lAmount, liquidityCorrection);
    }

    /**
     * @notice Calculates how many liquid tokens should be removed from pool when decreasing liquidity
     * @param pAmount Amount of pToken which should be taken from sender
     * @return Amount of liquid tokens which will be removed from the pool: total, part for sender, part for pool
     */
    function calculatePoolExitInverse(uint256 pAmount) internal view returns(uint256, uint256, uint256) {
        return fundsModule().calculatePoolExitInverse(pAmount);
    }

    function calculateExitFee(uint256 lAmount) internal view returns(uint256){
        return ICurveModule(getModuleAddress(MODULE_CURVE)).calculateExitFee(lAmount);
    }

    function fundsModule() internal view returns(IFundsModule) {
        return IFundsModule(getModuleAddress(MODULE_FUNDS));
    }

    function liquidityModule() internal view returns(ILiquidityModule) {
        return ILiquidityModule(getModuleAddress(MODULE_LIQUIDITY));
    }

    function pToken() internal view returns(IPToken){
        return IPToken(getModuleAddress(MODULE_PTOKEN));
    }

    function limits() internal view returns(ILoanLimitsModule) {
        return ILoanLimitsModule(getModuleAddress(MODULE_LOAN_LIMTS));
    }

    function loanProposals() internal view returns(ILoanProposalsModule) {
        return ILoanProposalsModule(getModuleAddress(MODULE_LOAN_PROPOSALS));
    }

    function increaseActiveDebts(address borrower) private {
        activeDebts[borrower] = activeDebts[borrower].add(1);
    }

    function decreaseActiveDebts(address borrower) private {
        activeDebts[borrower] = activeDebts[borrower].sub(1);
    }

    function withdrawDebtDefaultPayment(address borrower, uint256 debt) private {
        Debt storage d = debts[borrower][debt];

        uint256 lInterest = calculateInterestPayment(d.lAmount, loanProposals().getProposalInterestRate(borrower, d.proposal), d.lastPayment, now);

        uint256 lAmount = d.lAmount.add(lInterest);
        uint256 pAmount = calculatePoolExitWithFee(lAmount);
        uint256 pBalance = pToken().balanceOf(borrower);
        if (pBalance == 0) return;

        if (pAmount > pBalance) {
            pAmount = pBalance;
            (, lAmount,) = fundsModule().calculatePoolExitInverse(pAmount);
        }

        (uint256 pInterest, uint256 poolInterest) 
            = withdrawDebtDefaultPayment_calculatePInterest(borrower, d, lAmount, lInterest); 
        d.pInterest = d.pInterest.add(pInterest);
        
        if (lAmount < lInterest) {
            uint256 paidTime = now.sub(d.lastPayment).mul(lAmount).div(lInterest);
            assert(d.lastPayment + paidTime <= now);
            d.lastPayment = d.lastPayment.add(paidTime);
            lInterest = lAmount;
        } else {
            d.lastPayment = now;
            uint256 debtReturned = lAmount.sub(lInterest);
            d.lAmount = d.lAmount.sub(debtReturned);
            lDebts = lDebts.sub(debtReturned);
        }


        liquidityModule().withdrawForRepay(borrower, pAmount);
        fundsModule().distributePTokens(poolInterest);
        fundsModule().mintAndLockPTokens(pInterest.sub(poolInterest));

        emit Repay(borrower, debt, d.lAmount, lAmount, lInterest, pInterest, d.lastPayment);
    }

    function withdrawDebtDefaultPayment_calculatePInterest(address borrower, Debt storage d, uint256 lAmount, uint256 lInterest) private view 
    returns(uint256 pInterest, uint256 poolInterest) {
        //current liquidity already includes lAmount, which was never actually withdrawn, so we need to remove it here
        pInterest = calculatePoolEnter(lInterest, lAmount); 

        (, uint256 lCovered, , , uint256 lPledge, )
        = loanProposals().getProposalAndPledgeInfo(borrower, d.proposal, borrower);
        poolInterest = pInterest.mul(lPledge).div(lCovered);
    }

    function _isDebtDefaultTimeReached(Debt storage dbt) private view returns(bool) {
        uint256 timeSinceLastPayment = now.sub(dbt.lastPayment);
        return timeSinceLastPayment > DEBT_REPAY_DEADLINE_PERIOD;
    }
}