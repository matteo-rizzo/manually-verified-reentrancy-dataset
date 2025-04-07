/**
 *Submitted for verification at Etherscan.io on 2021-06-08
*/

/**
 *Submitted for verification at Etherscan.io on 2021-06-04
*/

// SPDX-License-Identifier: MIT
pragma solidity =0.7.6;  
pragma abicoder v2;



 





abstract contract IWETH {
    function allowance(address, address) public virtual view returns (uint256);

    function balanceOf(address) public virtual view returns (uint256);

    function approve(address, uint256) public virtual;

    function transfer(address, uint256) public virtual returns (bool);

    function transferFrom(
        address,
        address,
        uint256
    ) public virtual returns (bool);

    function deposit() public payable virtual;

    function withdraw(uint256) public virtual;
}  



  



  







  






  




// Common interface for the Trove Manager.
  



// Common interface for the Trove Manager.
  



  



  



// Common interface for the SortedTroves Doubly Linked List.
  









contract LiquityHelper {
    address constant public LUSDTokenAddr = 0x5f98805A4E8be255a32880FDeC7F6728C6568bA0;
    address constant public PriceFeedAddr = 0x4c517D4e2C851CA76d7eC94B805269Df0f2201De;
    address constant public BorrowerOperationsAddr = 0x24179CD81c9e782A4096035f7eC97fB8B783e007;
    address constant public TroveManagerAddr = 0xA39739EF8b0231DbFA0DcdA07d7e29faAbCf4bb2;
    address constant public SortedTrovesAddr = 0x8FdD3fbFEb32b28fb73555518f8b361bCeA741A6;
    address constant public HintHelpersAddr = 0xE84251b93D9524E0d2e621Ba7dc7cb3579F997C0;

    IPriceFeed constant public PriceFeed = IPriceFeed(PriceFeedAddr);
    IBorrowerOperations constant public BorrowerOperations = IBorrowerOperations(BorrowerOperationsAddr);
    ITroveManager constant public TroveManager = ITroveManager(TroveManagerAddr);
    ISortedTroves constant public SortedTroves = ISortedTroves(SortedTrovesAddr);
    IHintHelpers constant public HintHelpers = IHintHelpers(HintHelpersAddr);
}  







contract LiquityView is LiquityHelper {
    using TokenUtils for address;
    using SafeMath for uint256;

    enum LiquityActionId {Open, Borrow, Payback, Supply, Withdraw}

    struct LoanInfo {
        uint256 troveStatus;
        uint256 collAmount;
        uint256 debtAmount;
        uint256 collPrice;
        uint256 TCRatio;
        bool recoveryMode;
    }

    function isRecoveryMode() public view returns (bool) {
        uint256 price = PriceFeed.lastGoodPrice();
        return TroveManager.checkRecoveryMode(price);
    }

    function computeNICR(uint256 _coll, uint256 _debt) public pure returns (uint256) {
        if (_debt > 0) {
            return _coll.mul(1e20).div(_debt);
        }
        // Return the maximal value for uint256 if the Trove has a debt of 0. Represents "infinite" CR.
        else {
            // if (_debt == 0)
            return 2**256 - 1;
        }
    }

    /// @notice Predict the resulting nominal collateral ratio after a trove modifying action
    /// @param _troveOwner Address of the trove owner, if the action specified is LiquityOpen this argument is ignored
    /// @param _action LiquityActionIds
    function predictNICR(
        address _troveOwner,
        LiquityActionId _action,
        address _from,
        uint256 _collAmount,
        uint256 _lusdAmount
    ) external view returns (uint256 NICR) {
        //  LiquityOpen
        if (_action == LiquityActionId.Open) {
            if (!isRecoveryMode())
                _lusdAmount = _lusdAmount.add(TroveManager.getBorrowingFeeWithDecay(_lusdAmount));
            _lusdAmount = BorrowerOperations.getCompositeDebt(_lusdAmount);

            if (_collAmount == type(uint256).max)
                _collAmount = TokenUtils.WETH_ADDR.getBalance(_from);

            return computeNICR(_collAmount, _lusdAmount);
        }

        (uint256 debt, uint256 coll, , ) = TroveManager.getEntireDebtAndColl(_troveOwner);

        //  LiquityBorrow
        if (_action == LiquityActionId.Borrow) {
            if (!isRecoveryMode())
                _lusdAmount = _lusdAmount.add(TroveManager.getBorrowingFeeWithDecay(_lusdAmount));
            return computeNICR(coll, debt.add(_lusdAmount));
        }

        //  LiquityPayback
        if (_action == LiquityActionId.Payback) {
            return computeNICR(coll, debt.sub(_lusdAmount));
        }

        //  LiquitySupply
        if (_action == LiquityActionId.Supply) {
            if (_collAmount == type(uint256).max)
                _collAmount = TokenUtils.WETH_ADDR.getBalance(_from);

            return computeNICR(coll.add(_collAmount), debt);
        }

        //  LiquityWithdraw
        if (_action == LiquityActionId.Withdraw) {
            return computeNICR(coll.sub(_collAmount), debt);
        }
    }

    function getApproxHint(
        uint256 _CR,
        uint256 _numTrials,
        uint256 _inputRandomSeed
    )
        external
        view
        returns (
            address hintAddress,
            uint256 diff,
            uint256 latestRandomSeed
        )
    {
        return HintHelpers.getApproxHint(_CR, _numTrials, _inputRandomSeed);
    }

    function findInsertPosition(
        uint256 _ICR,
        address _prevId,
        address _nextId
    ) external view returns (address upperHint, address lowerHint) {
        return SortedTroves.findInsertPosition(_ICR, _prevId, _nextId);
    }


    function getTroveInfo(address _troveOwner)
        external
        view
        returns (
            LoanInfo memory loanInfo
        )
    {
        
        uint256 collPrice = PriceFeed.lastGoodPrice();
        
        loanInfo = LoanInfo({
            troveStatus: TroveManager.getTroveStatus(_troveOwner),
            collAmount: TroveManager.getTroveColl(_troveOwner),
            debtAmount: TroveManager.getTroveDebt(_troveOwner),
            collPrice: collPrice,
            TCRatio: TroveManager.getTCR(collPrice),
            recoveryMode: TroveManager.checkRecoveryMode(collPrice)
        });
        
    }


    function getInsertPosition(
        uint256 _collAmount,
        uint256 _debtAmount,
        uint256 _numTrials,
        uint256 _inputRandomSeed
    ) external view returns (address upperHint, address lowerHint) {
        uint256 NICR = _collAmount.mul(1e20).div(_debtAmount);
        (address hintAddress, , ) = HintHelpers.getApproxHint(NICR, _numTrials, _inputRandomSeed);
        (upperHint, lowerHint) = SortedTroves.findInsertPosition(NICR, hintAddress, hintAddress);
    }
}